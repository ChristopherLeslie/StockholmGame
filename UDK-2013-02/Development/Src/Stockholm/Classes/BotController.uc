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



















auto State idle{
	Begin:
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
	Begin:
		GoTo('ContinueCapturing');

	ContinueCapturing:
		lookAt(hostageTarget);
		if(distTo(hostageTarget) < close_enough_to_capture){
			moveToward(hostageTarget);
		}
		Pawn.StartFire(1);
		GoTo('ContinueCapturing');
}




























defaultproperties
{
  //Points to the UTFamilyInfo class for your custom character
  CharacterClass=class'UTFamilyInfo_Liandri_Male'

  close_enough_to_capture = 500;
  
}