class BotController extends StockholmController;

var class<UTFamilyInfo> CharacterClass; 
var MaterialInterface defaultMaterial0; //for some reason necessary for setting the materials later even though I don't ever define what the defaultMaterial0 is


var HostagePawn hostageTarget;
var float close_enough_to_capture;
var Vector wayPoint;

simulated event PostBeginPlay()
{

 	`log("BOT CONTROLLER ON-LINE");
     super.PostBeginPlay();
    
}

event Tick(float DeltaTime)
{
  
}

simulated event Possess(Pawn inPawn, bool bVehicleTransition)
{

	Super.Possess(inPawn, bVehicleTransition);
	
	//Set the pawn that CaptorController is controlling to look like a human
	inPawn.Mesh.SetSkeletalMesh(SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA');
	inPawn.Mesh.SetMaterial(0,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_VRed');
    inPawn.Mesh.SetMaterial(1,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_VRed');
	//A lot of textures are missing if we don't do this step
	//but it functions the same and looks like a crappy human
	
	//let's leave it out to make the enemy look different
	//for( i= 0; i < inPawn.Mesh.SkeletalMesh.Materials.length; i++){
	//	inPawn.Mesh.SetMaterial(i,defaultMaterial0);
	//}

	CaptorPawn(Pawn).setSHteamNum(0); //red

}


function bool capturable(HostagePawn hostageP){
	//alive and different teams
	return (
		hostageP.Health > 0 
		&& !StockholmPawn(Pawn).sameTeam(hostageP) 
		&& !hostageP.isInState('Warding') 
		&& !hostageP.isInState('RemoteMineWandering')
		&& !hostageP.isInState('RemoteMineAttacking')
		&& !hostageP.isInState('BlowUpAndDie')
		&& !hostageP.isInState('Sentry')
	);
}
function bool captured(HostagePawn hostageP){
	// alive and same teams
	return ((hostageP.Health > 0) && StockholmPawn(Pawn).sameTeam(hostageP));
}

function HostagePawn closestHostage(){
	local float maxRange;
	local float searchRange;
	local HostagePawn closestHostage;
	local float distToHostage;
	local HostagePawn hostageP;

	//Smell them from up to 100,000 away
	maxRange = 100000;
	searchRange = maxRange;

	foreach WorldInfo.AllPawns(class'HostagePawn', hostageP){
		if(capturable(hostageP)){
			distToHostage = distToActor(hostageP);

	      	if(distToHostage < searchRange){
	      		closestHostage = hostageP;
	      		searchRange = distToHostage;
	      	}
      	}

    }
  
    return closestHostage;
}





function stopMoving(){
  Pawn.ZeroMovementVariables();
  setDestinationPosition(Location);
  bPreciseDestination = false;
}


auto State idle{
	Begin:
		GoToState('LookForHostages');
}



State Sit{
	Begin:
		stopMoving();
		sleep(3);
		if(game.capturableHostagesForTeam( shTeamNum() ) > 0){
			GoToState('LookForHostages');
		}

		GoTo('Begin');
}



State LookForHostages{

	Begin:
 
		
		if(game.capturableHostagesForTeam( shTeamNum() ) < 1){
			debug("No more hostages left");
			GoToState('Sit');
		}

		//There is at least one hostage of the kind that I want
		
		hostageTarget = closestHostage();

		if(hostageTarget == none){
			Sleep(1);
			debug("couldn't find hostage");
			GoTo('Begin');
		}

		GoToState('ApproachTargetHostage');
}

State ApproachTargetHostage{
	local int times_pursued;


	Begin:
		Pawn.GroundSpeed = 400;
 		times_pursued = 0;
		GoTo('ContinueApproaching');

	ContinueApproaching:

	    if(distToActor(hostageTarget) < close_enough_to_capture){
	    	GoToState('Capturing');
	    }

	    if(captured(hostageTarget) || hostageTarget.Health < 1){
			GoToState('LookForHostages');
		}
 
		wayPoint = simplePathFindToActorOrRandom(hostageTarget);
		runInDirectionOf(wayPoint);
		lookAtVector(wayPoint);
		
		times_pursued++;
		if(times_pursued % 4 == 0){
			hostageTarget = closestHostage();
		}
		sleep(0.3);

	GoTo('ContinueApproaching');

}















State Capturing{
	local Rotator newRotation;
	local Vector out_location;
	local Rotator out_rotation;
	local ImpactInfo testImpact;
	local HostagePawn nullHP;	
	local HostagePawn target;
	


	Begin:
 
		GoTo('ContinueCapturing');

	ContinueCapturing:
		target = hostageTarget;
		
		if(captured(target) || target.Health < 1){
			Pawn.StopFire(1);
			GoToState('LookForHostages');
		}

		wayPoint = simplePathFindToActorOrRandom(target);
		runInDirectionOf(wayPoint);
		lookAtVector(wayPoint);
		sleep(0.3);

		if(distToActor(target) > close_enough_to_capture || !canSeeByPoints(Pawn.Location,target.Location,Pawn.Rotation)){
			Pawn.StopFire(1);
		}
		else{
			//we're close enough and have LoS to the hostage
			lookAt(target);
			if(Pawn.Weapon.isA('CaptorGun')){
				CaptorGun(Pawn.Weapon).create_beam_from_me_to_you(CaptorPawn(Pawn),target);
				CaptorGun(Pawn.Weapon).create_beam_from_me_to_you(CaptorPawn(Pawn),target);
				CaptorGun(Pawn.Weapon).create_beam_from_me_to_you(CaptorPawn(Pawn),target);

				sleep(0.1);
				Pawn.StartFire(1);
			}

		}
		
		


		GoTo('ContinueCapturing');
}






















function debug(String s){
 // WorldInfo.Game.Broadcast(self,s);
}

function byte shTeamNum(){
	return StockholmPawn(Pawn).shTeamNum();
}




defaultproperties
{
  //Points to the UTFamilyInfo class for your custom character
  CharacterClass=class'UTFamilyInfo_Liandri_Male'
  bIsPlayer = True

  close_enough_to_capture = 1000;
  
}