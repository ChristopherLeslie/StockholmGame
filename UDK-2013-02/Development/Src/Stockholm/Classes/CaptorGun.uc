class CaptorGun extends UTWeap_LinkGun;


simulated function ProcessBeamHit(vector StartTrace, vector AimDir, out ImpactInfo TestImpact, float DeltaTime)
{
	local float DamageAmount;
	local vector PushForce, ShotDir, SideDir; //, HitLocation, HitNormal, AttachDir;
	local UTPawn UTP;
	local HostageController hostageC;
	local HostagePawn hostageP;
	local CaptorPawn captorP;
	local CaptorController captorC;
	local StockholmPawn stockholmP;

	Victim = TestImpact.HitActor;

	// If we are on the server, attempt to setup the link
	if (Role == ROLE_Authority)
	{
		// Try linking
		AttemptLinkTo(Victim, TestImpact.HitInfo.HitComponent);

		// set the correct firemode on the pawn, since it will change when linked
		SetCurrentFireMode(CurrentFireMode);

		// if we do not have a link, set the flash location to whatever we hit
		// (if we do have one, AttemptLinkTo() will set the correct flash location for the Actor we're linked to)
		if (LinkedTo == None)
		{
			SetFlashLocation(TestImpact.HitLocation);
		}

		// cause damage or add health/power/etc.
		bBeamHit = false;

		// compute damage amount
		CalcLinkStrength();
		DamageAmount = InstantHitDamage[1];
		UTP = UTPawn(Instigator);
		if ( UTP != None )
		{
			DamageAmount = DamageAmount/UTP.FireRateMultiplier;
		}
		if ( LinkStrength > 1 )
		{
			DamageAmount *= FClamp(0.75*LinkStrength, 1.5, 2.0);
		}
		SavedDamage += DamageAmount * DeltaTime;
		DamageAmount = int(SavedDamage);
		SavedAmmoUse += BeamAmmoUsePerSecond * DeltaTime;
		if (DamageAmount >= MinimumDamage)
		{
			SavedDamage -= DamageAmount;
			if (LinkedTo != None)
			{
				// heal them if linked
				// linked players will use ammo when they fire
				if (!LinkedTo.IsA('UTPawn'))
				{
					if (LinkedTo.IsA('UTVehicle') || LinkedTo.IsA('UTGameObjective'))
					{
						// use ammo only if we actually healed some damage
						if ( LinkedTo.HealDamage(DamageAmount * Instigator.GetDamageScaling(), Instigator.Controller, InstantHitDamageTypes[1]) )
							ConsumeBeamAmmo(SavedAmmoUse);
					}
					else
					{
						// otherwise always use ammo
						//DONT USE AMMO!
						//ConsumeBeamAmmo(SavedAmmoUse);
					}
				}
			}
			else
			{
				// If not on the same team, hurt them
				//DONT USE AMMO!
				//ConsumeBeamAmmo(SavedAmmoUse);
				if (Victim != None && !WorldInfo.Game.GameReplicationInfo.OnSameTeam(Victim, Instigator))
				{
					bBeamHit = !Victim.bWorldGeometry;
					if ( DamageAmount > 0 )
					{
						ShotDir = Normal(TestImpact.HitLocation - Location);
						SideDir = Normal(ShotDir Cross vect(0,0,1));
						PushForce =  vect(0,0,1) + Normal(SideDir * (SideDir dot (TestImpact.HitLocation - Victim.Location)));
						PushForce *= (Victim.Physics == PHYS_Walking) ? 0.1*MomentumTransfer : DeltaTime*MomentumTransfer;
						
						//DONT TAKE DAMAGE!
						DamageAmount = 0;
						if(Victim.isA('HostagePawn')){
							hostageP = HostagePawn(Victim);
							captorP = CaptorPawn(Instigator);
							
							hostageP.receivePersuasion(captorP);

						}
						Victim.TakeDamage(DamageAmount, Instigator.Controller, TestImpact.HitLocation, PushForce, InstantHitDamageTypes[1], TestImpact.HitInfo, self);
					}
				}
			}
			SavedAmmoUse = 0.0;
		}
	}
	else
	{
		// if we do not have a link, set the flash location to whatever we hit
		// (otherwise beam update will override with link location)
		if (LinkedTo == None)
		{
			SetFlashLocation(TestImpact.HitLocation);
		}
		else if (TestImpact.HitActor == LinkedTo && TestImpact.HitInfo.HitComponent != None)
		{
			// the linked component can't be replicated to the client, so set it here
			LinkedComponent = TestImpact.HitInfo.HitComponent;
		}
		if (Victim != None && (Victim.Role == ROLE_Authority) )
		{
			bBeamHit = !Victim.bWorldGeometry;
			if ( DamageAmount > 0 )
			{
				ShotDir = Normal(TestImpact.HitLocation - Location);
				SideDir = Normal(ShotDir Cross vect(0,0,1));
				PushForce =  vect(0,0,1) + Normal(SideDir * (SideDir dot (TestImpact.HitLocation - Victim.Location)));
				PushForce *= (Victim.Physics == PHYS_Walking) ? 0.1*MomentumTransfer : DeltaTime*MomentumTransfer;
				Victim.TakeDamage(DamageAmount, Instigator.Controller, TestImpact.HitLocation, PushForce, InstantHitDamageTypes[1], TestImpact.HitInfo, self);
			}
		}
	}
}




defaultproperties
{
	
}