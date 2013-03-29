class SentryController extends GameAIController;

//declaring variables here means
//they may be used throughout this script
var Vector MyTarget;
var CaptorPawn captorToFollow;
var CaptorPawn captorToFlee;
var Vector placeToGo;
var Bool bIsFollowingCaptor;
var Bool bIsFollowingOrder;

var int currentActionPriority;
var Vector currentPrioritizedDestination;
var Pawn currentPrioritizedTargetToFireAt;



enum EHostageAction {
  followShot,
  followCaptor,
  fleeCaptor,
  wander,
  wait,
  fireAtEnemyHostage,
  nothing
};

var EHostageAction currentAction;
var Bool continueCurrentAction;

var int followShotPriority;
var int followCaptorPriority;
var int fleeCaptorPriority;
var int wanderPriority;
var int waitPriority;
var int nothingPriority;
var int fireAtEnemyHostagePriority;

//at the start of the level
simulated event PostBeginPlay()
{
  super.PostBeginPlay();

  SetTimer(0.1, true, 'BrainTimer');
}



function BrainTimer(){
	local float distance;
	local CaptorPawn captor;
	local HostagePawn hostage;
	local Pawn P;
	local Vector v;
	local float scale;
	if(currentPrioritizedTargetToFireAt == none 
       ||  currentPrioritizedTargetToFireAt.health <= 0)
	{
	  `log("Looking for a target");
	  currentPrioritizedTargetToFireAt = none;
	  Pawn.StopFire(1);
	  foreach WorldInfo.AllPawns(class'Pawn', P){
		  if(P.isA('CaptorPawn')){ //Captor
			captor = CaptorPawn(P);
			distance =  VSize2D(Pawn.Location - captor.Location);
			if(captor.getTeamNum() == Pawn.getTeamNum()){ //Friendly Captor 
			  
			}
			else{                         //Enemy Captor
			  if(distance < 400){
				currentPrioritizedTargetToFireAt = captor;
			  }
			}
		  }
		  else{//NOT a CaptorPawn
		  
		  } 
      }
    }
	else
	{
		`log("Priority target:"$currentPrioritizedTargetToFireAt);
		Pawn.LockDesiredRotation(false,false);
        Pawn.SetDesiredRotation(rotator(currentPrioritizedTargetToFireAt.Location - Pawn.Location),true,true,0.25);
		distance =  VSize2D(currentPrioritizedTargetToFireAt.Location - Pawn.Location);
		Pawn.StartFire(1);
		if(distance > 800)
		{
			currentPrioritizedTargetToFireAt = none;
		}
	}
}

defaultproperties
{

}
