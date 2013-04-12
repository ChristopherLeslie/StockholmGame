class BotController extends GameAIController;

var class<UTFamilyInfo> CharacterClass; 
var MaterialInterface defaultMaterial0; //for some reason necessary for setting the materials later even though I don't ever define what the defaultMaterial0 is


var HostagePawn hostageTarget;
var float close_enough_to_capture;


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
	//A lot of textures are missing if we don't do this step
	//but it functions the same and looks like a crappy human
	
	//let's leave it out to make the enemy look different
	//for( i= 0; i < inPawn.Mesh.SkeletalMesh.Materials.length; i++){
	//	inPawn.Mesh.SetMaterial(i,defaultMaterial0);
	//}

	CaptorPawn(Pawn).teamNum = 0;//Red

}

simulated function byte getTeamNum(){
  return CaptorPawn(Pawn).teamNum;
}
function int distTo(Actor other){
  return VSize2D(Pawn.Location-other.Location);
}

function HostagePawn closestHostage(){
	local float maxRange;
	local float searchRange;
	local HostagePawn closestHostage;
	local float distToHostage;
	local HostagePawn hostageP;

	//Smell them from up to 10,000 away
	maxRange = 10000;
	searchRange = maxRange;

	foreach WorldInfo.AllPawns(class'HostagePawn', hostageP){
		distToHostage = distTo(hostageP);

      	if(distToHostage < searchRange){
      		closestHostage = hostageP;
      		searchRange = distToHostage;
      	}
      
    }
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
    Pawn.SetDesiredRotation(final_rot,true);
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









function bool FindNavMeshPathToActor(Actor dest)
  {
    // Clear cache and constraints (ignore recycling for the moment)
    NavigationHandle.PathConstraintList = none;
    NavigationHandle.PathGoalList = none;

    // Create constraints
    class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,dest );
    class'NavMeshGoal_At'.static.AtActor( NavigationHandle, dest,32 );

    // Find path
    return NavigationHandle.FindPath();
  }

function bool FindNavMeshPathToLocation(Vector dest)
  {
    // Clear cache and constraints (ignore recycling for the moment)
    NavigationHandle.PathConstraintList = none;
    NavigationHandle.PathGoalList = none;

    // Create constraints
    class'NavMeshPath_Toward'.static.TowardPoint( NavigationHandle,dest );
    class'NavMeshGoal_At'.static.AtLocation( NavigationHandle, dest,32 );

    // Find path
    return NavigationHandle.FindPath();
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
		





		/*
		Pawn.ZeroMovementVariables();
	    Sleep(1); //Give the pawn the time to stop.
	 	
	    Aim();
	    Pawn.StartFire(0);
	    Pawn.StopFire(0);
	    sleep(1);
	    Pawn.StartFire(1);
	    sleep(1);
	    Pawn.StopFire(1);
	    Sleep(0.5);
	    GoTo('Begin');
	    */








	/*
		newRot = Pawn.Rotation;
		newRot.pitch = newRot.pitch + 1000;
		Pawn.StartFire(1);
		Pawn.LockDesiredRotation(false,false);
        Pawn.SetDesiredRotation(newRot,true);
		sleep(0.1);
		WorldInfo.Game.Broadcast(self,Pawn.Rotation);
		endpoint = Pawn.Location + normal(vector(Rotation))*400;
		DrawDebugLine(Pawn.Location,endpoint,255,0,0,true);
		GoTo('Begin');
*/
		GoToState('LookForHostages');
}

State LookForHostages{
	Begin:
		hostageTarget = closestHostage();
		if(hostageTarget == none){
			Sleep(1);
			GoTo('Begin');
		}

		PushState('ApproachTargetHostage');
}

State ApproachTargetHostage{
	local Vector TempDest;

	Begin:
		Pawn.GroundSpeed = 400;
		GoTo('ContinueApproaching');

	ContinueApproaching:

		if( NavigationHandle.ActorReachable( hostageTarget) ){
	         MoveToward(hostageTarget,hostageTarget);
	    }     	

	    if(distTo(hostageTarget) < close_enough_to_capture){
	    	GoToState('Capturing');
	    }
     
     	else if( FindNavMeshPathToActor(hostageTarget) ){
	        NavigationHandle.SetFinalDestination(hostageTarget.Location);
	        NavigationHandle.DrawPathCache(,TRUE);

	        // move to the first node on the path
	        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
	        {
	          DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
	          DrawDebugSphere(TempDest,16,20,255,0,0,true);

	          do{
	            runInDirectionOf(TempDest);
	            lookAtVector(TempDest);
	            sleep(0.25);
	          }
	          until(NavigationHandle.ActorReachable(hostageTarget) ||               //we can run straight to our goal 
	          VSize2D(Pawn.Location-TempDest) < Pawn.GetCollisionRadius());   //or we've reached TempDest
	        }
	        else{
	          WorldInfo.Game.Broadcast(self,"failure case 1");
	          sleep(1);
	        }
	    }
	    
	    else{
	      WorldInfo.Game.Broadcast(self,"failure case 2");
	      sleep(1);
	    }

	GoTo('ContinueApproaching');

}

State Capturing{
	local Rotator newRotation;
	local Vector out_location;
	local Rotator out_rotation;
	local ImpactInfo testImpact;	

	Begin:
		GoTo('ContinueCapturing');

	ContinueCapturing:
		moveToward(hostageTarget);	
		//WorldInfo.Game.Broadcast(self,Pawn.Weapon);

		if(distTo(hostageTarget) > close_enough_to_capture){
			Pawn.StopFire(1);
			
		}
		else{
			CaptorGun(Pawn.Weapon).linkedTo = hostageTarget;
			Pawn.StartFire(1);
			if(Pawn.Weapon.isA('UTWeap_LinkGun')){
				hostageTarget.Controller.GetActorEyesViewPoint(out_Location, out_Rotation);
				DrawDebugLine(Pawn.Location,out_location,255,0,0,true);
				DrawDebugSphere(out_Location,16,20,255,0,0,true);
				testImpact.HitActor = hostageTarget;
				testImpact.HitLocation = out_location;
				CaptorGun(Pawn.Weapon).create_beam_from_me_to_you(CaptorPawn(Pawn),hostageTarget);
				CaptorGun(Pawn.Weapon).create_beam_from_me_to_you(CaptorPawn(Pawn),hostageTarget);
				CaptorGun(Pawn.Weapon).create_beam_from_me_to_you(CaptorPawn(Pawn),hostageTarget);
				CaptorGun(Pawn.Weapon).create_beam_from_me_to_you(CaptorPawn(Pawn),hostageTarget);

				//CaptorGun(Pawn.Weapon).ProcessBeamHit(Pawn.Location, out_location-Pawn.Location, testImpact, 0.05);

			}

		}

		
		
		sleep(1);
				Pawn.StopFire(1);


		GoTo('ContinueCapturing');
}




























defaultproperties
{
  //Points to the UTFamilyInfo class for your custom character
  CharacterClass=class'UTFamilyInfo_Liandri_Male'

  close_enough_to_capture = 500;
  
}