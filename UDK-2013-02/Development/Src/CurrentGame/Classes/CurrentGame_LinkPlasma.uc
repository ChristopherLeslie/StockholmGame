/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class CurrentGame_LinkPlasma extends UTProjectile;

var vector ColorLevel;
var vector ExplosionColor;

simulated function ProcessTouch (Actor Other, vector HitLocation, vector HitNormal)
{
	if ( Other != Instigator )
	{
		if ( !Other.IsA('Projectile') || Other.bProjTarget )
		{
			/**************************/
			//ADDED BY STEVEN

			//Other is the hostagepawn (or any actor) who is getting shot.
			//Instigator is the actor who shot the bullet (captorpawn)

			//`log("Other: "$Other.class);
			//`log("Instigator: "$ Instigator.class);

			if(Other.isA('HostagePawn')){
				HostagePawn(Other).shotBy(Instigator);
			}
			else{

			/**************************/

			MomentumTransfer = (UTPawn(Other) != None) ? 0.0 : 1.0;
			Other.TakeDamage(Damage, InstigatorController, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
			Explode(HitLocation, HitNormal);

			/***************************/
			//ADDED BY STEVEN

			}

			/***************************/
		}
	}
}

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{

	/****************************/
	//ADDED BY STEVEN

	local Pawn P;
	local HostagePawn hostage;
	local CaptorPawn captor;
	local HostageController myController;

	if(Instigator.isA('CaptorPawn')){
		captor = CaptorPawn(Instigator);
		foreach WorldInfo.AllPawns(class'Pawn', P){
			if(P.isA('HostagePawn')){
				hostage = HostagePawn(P);
				myController = HostageController(hostage.Controller);
				myController.hearShot(captor, Location);
			}
		}

	}
	/****************************/


	MomentumTransfer = 1.0;

	Super.HitWall(HitNormal, Wall, WallComp);



}

simulated function SpawnFlightEffects()
{
	Super.SpawnFlightEffects();
	if (ProjEffects != None)
	{
		ProjEffects.SetVectorParameter('LinkProjectileColor', ColorLevel);
	}
}


simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
	Super.SetExplosionEffectParameters(ProjExplosion);
	ProjExplosion.SetVectorParameter('LinkImpactColor', ExplosionColor);
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'
	ProjExplosionTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Impact'
	MaxEffectDistance=7000.0

	Speed=1400
	MaxSpeed=5000
	AccelRate=3000.0

	Damage=26
	DamageRadius=0
	MomentumTransfer=0
	CheckRadius=26.0

	MyDamageType=class'UTDmgType_LinkPlasma'
	LifeSpan=3.0
	NetCullDistanceSquared=+144000000.0

	bCollideWorld=true
	DrawScale=1.2

	ExplosionSound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_ImpactCue'
	ColorLevel=(X=1,Y=1.3,Z=1)
	ExplosionColor=(X=1,Y=1,Z=1);
}
