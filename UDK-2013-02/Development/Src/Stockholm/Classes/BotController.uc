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
  
  //calculate elapsed time

  aim();
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

simulated function byte shTeamNum(){
  return CaptorPawn(Pawn).shteamNum();
}

function bool capturable(HostagePawn hostageP){
	//alive and different teams
	return (hostageP.Health > 0 && !StockholmPawn(Pawn).sameTeam(hostageP));
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
    //debug("closest hostage is "$VSize2D(closestHostage.Location-Pawn.Location)$" units away"); 
    return closestHostage;
}

function LookAt(Actor a){
	lookAtVector(a.Location); 
}
function aim(){
	local Rotator final_rot;
    final_rot = Rotator(vect(0,0,1)); //Look straight up
    Pawn.SetViewRotation(final_rot);
}
function shootAt(Pawn p){
	SetFocalPoint(p.Location);
	Focus = p;
	FireWeaponAt(p);
}
function LookAtPawn(Pawn p){
	local Vector out_Location;
	local Rotator out_Rotation;
	p.Controller.GetActorEyesViewPoint(out_Location, out_Rotation);
	DrawDebugSphere(out_Location,16,20,255,0,0,true);
	lookAtVector(out_Location);
}

function LookAtVector(Vector locationVec){
	local Rotator final_rot;
    final_rot = Rotator(locationVec-Pawn.Location);
    Pawn.LockDesiredRotation(false,false);
    Pawn.SetDesiredRotation(final_rot,true,false,0.1);
}
function runInDirectionOf(Vector destination){
  SetDestinationPosition(destination);
  bPreciseDestination = True;
}
function stopMoving(){
  Pawn.ZeroMovementVariables();
  setDestinationPosition(Location);
  bPreciseDestination = false;
}










 simulated event GetPlayerViewPoint(out vector out_Location, out Rotator out_Rotation){
    // AI does things from the Pawn
    if (Pawn != None)
    {
        out_Location = Pawn.Location;
        out_Rotation = Rotation; //That's what we've changed
    }
    else
    {
        Super.GetPlayerViewPoint(out_Location, out_Rotation);
    }
}



















auto State idle{
	local Rotator newRot;
	local Vector endpoint;
	Begin:
		GoToState('LookForHostages');
}
State Sit{
	Begin:
		debug("SITTING");
		sleep(3);
		if(!StockholmGame(WorldInfo.Game).teamByNumHasAllHostages(StockholmPawn(Pawn).shTeamNum())){
			GoToState('LookForHostages');
		}

		GoTo('Begin');
}
State LookForHostages{

	Begin:
		debug("LOOKING FOR HOSTAGES");
		
		if(game.teamByNumHasAllHostages(StockholmPawn(Pawn).shTeamNum())){
			GoToState('Sit');
		}
		//There is at least one hostage of the kind that I want
		
		hostageTarget = closestHostage();

		if(hostageTarget == none){
			Sleep(1);
			GoTo('Begin');
		}

		GoToState('ApproachTargetHostage');
}

State ApproachTargetHostage{
	

	Begin:
		Pawn.GroundSpeed = 400;
		debug("approaching target hostage");
		GoTo('ContinueApproaching');

	ContinueApproaching:

	    if(distToActor(hostageTarget) < close_enough_to_capture){
	    	GoToState('Capturing');
	    }
	    	DrawDebugSphere(hostageTarget.Location,16,20,0,0,255,true);
		wayPoint = simplePathFindToActor(hostageTarget);
		runInDirectionOf(wayPoint);
		lookAtVector(wayPoint);
		sleep(0.7);

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
		debug("I'm a "$Pawn$" looking to capture "$hostageTarget$" with a "$Pawn.Weapon);
		GoTo('ContinueCapturing');

	ContinueCapturing:
		target = hostageTarget;
		
		if(captured(target) || target.Health < 1){
			Pawn.StopFire(1);
			GoToState('LookForHostages');
		}

		wayPoint = simplePathFindToActor(target);
		runInDirectionOf(wayPoint);
		lookAtVector(wayPoint);
		sleep(0.7);

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
				CaptorGun(Pawn.Weapon).create_beam_from_me_to_you(CaptorPawn(Pawn),target);

				sleep(0.1);
				Pawn.StartFire(1);
			}

		}
		
		


		GoTo('ContinueCapturing');
}






















function debug(String s){
  WorldInfo.Game.Broadcast(self,s);
}





defaultproperties
{
  //Points to the UTFamilyInfo class for your custom character
  CharacterClass=class'UTFamilyInfo_Liandri_Male'

  close_enough_to_capture = 1000;
  
}