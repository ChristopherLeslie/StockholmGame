class RemoteMineController extends GameAIController;

//declaring variables here means
//they may be used throughout this script
var Vector MyTarget;
var CurrentGame_CaptorPawn captorToFollow;
var CurrentGame_CaptorPawn captorToFlee;
var Vector placeToGo;
var Bool bIsFollowingCaptor;
var Bool bIsFollowingOrder;

var int currentActionPriority;
var Vector currentPrioritizedDestination;
var Pawn currentPrioritizedTargetToFireAt;

var array<Pawn> targets;
var Pawn targetToFollow;

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

  //start the brain going at half second intervals
  Pawn.Groundspeed = 100;
  //wander();
  SetTimer(5, true, 'BrainTimer');
  SetTimer(0.01, true, 'B2');
}

function B2()
{
	local int i;
	if(IsInState('Idle'))
	{
		for(i = 0; i<targets.Length; i++)
		{
			if(CanSee(targets[i]))
			{
				`log("I can see target:"$targets[i]);
				targetToFollow = targets[i];
				GotoState('Follow');
			}
		}
	}
}

function BrainTimer()
{
	local array<Pawn> temp_targets;
	local CurrentGame_CaptorPawn captor;
	local Pawn P;
	foreach WorldInfo.AllPawns(class'Pawn', P){
		if(P.isA('CurrentGame_CaptorPawn')){ //Captor
			captor = CurrentGame_CaptorPawn(P);
			if(captor.getTeamNum() != Pawn.getTeamNum()){ //Ememy Captor
				temp_targets.AddItem(P);
			}
		}
	}
	targets = temp_targets;
}

auto state Idle
{
	event SeePlayer (Pawn Seen)
	{
		`log("I SEE THE PLAYER");
		// Call AIControllers SeePlayer function
		super.SeePlayer(Seen);
	}

	Begin:
		`log("Attempting to find Path Node at Start");
		MoveTo(FindRandomDest().Location);
	goto 'Begin';
}

state Follow
{
	Begin:
		`log("Following:"$targetToFollow);
		if(targetToFollow == none 
		   ||targetToFollow.health <= 0)
		{
			Gotostate('Idle');
		}
		else
		{
			MoveTo(targetToFollow.Location);
		}
	goto 'Begin';
}

defaultproperties
{
  
}
