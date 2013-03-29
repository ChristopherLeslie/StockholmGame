class WardController extends GameAIController;

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

  SetTimer(0.005, true, 'wardTimer');
}


function WardTimer(){
	local Pawn P;
	local CurrentGame_CaptorPawn captor;
	local float distance;
	local float zcomponent;
	local Vector BackwardVector;
    local Vector captorLocation;
    local Vector captorVelocity;
    local Vector botLocation;
    local float currentDistance;
    local float acceleratedDistance;
	local Vector tempVector;
	local Vector unitVector;
	local Vector notunitvector;
	foreach WorldInfo.AllPawns(class'Pawn', P){
      if(P.isA('CurrentGame_CaptorPawn')){                            //Captor
        captor = CurrentGame_CaptorPawn(P);
        distance =  VSize2D(Pawn.Location - captor.Location);
        if(captor.getTeamNum() != Pawn.getTeamNum()) //Enemy Captor 
		{
          if(distance < 400) //Enemy Captor is near me
		  { 
			   captorLocation = captor.Location;
			   captorVelocity = captor.Velocity;
			   botLocation = Pawn.Location;
			   currentDistance = (captorLocation.x - botLocation.x)+(captorLocation.y - botLocation.y)+(captorLocation.z - botLocation.z);
			   if(currentDistance < 0)
			   {
				  currentDistance = currentDistance * -1;
			   }
			   notunitvector = captorLocation - botLocation;
			   unitVector = notunitvector / Sqrt(Square(notunitvector.x) + Square(notunitvector.y) + Square(notunitvector.z));
			   acceleratedDistance = (captorLocation.x + captorVelocity.x - botLocation.x) + (captorLocation.y + captorVelocity.y - botLocation.y) + (captorLocation.z + captorVelocity.z - botLocation.z);
			   if(acceleratedDistance < 0)
			   {
				  acceleratedDistance = acceleratedDistance * -1;
			   }
			   if(acceleratedDistance < currentDistance)
			   {
				 `log("Attempting to reverse the captor");
				 if(captor.Velocity.x < 0)
				 {
					BackwardVector.x = 200;
				 }
				 else
				 {
					BackwardVector.x = -200;
				 }
				 if(captor.Velocity.y < 0)
				 {
					BackwardVector.y = 200;
				 }
				 else
				 {
					BackwardVector.y = -200;
				 }
				 BackwardVector.z = 100;
				 //BackwardVector = captor.Velocity * vect(-3,-3,0);
				 //BackwardVector.x = -5;
				 //BackwardVector.y = -5;
				 //BackwardVector.x = 0;
				 //BackwardVector.y = 0;
				 //BackwardVector.z = 0;
				 //captor.SetPhysics(PHYS_Falling);
				 zcomponent = botLocation.z+50-captor.Location.z;
				 if(zcomponent < 45)
				 {
					zcomponent = 45;
				 }
				 else
				 {
					if(zcomponent<0)
					{
						zcomponent = 0;
					}
				 }
				 tempVector = zcomponent * vect(0,0,1);
				 captor.SetLocation(captor.Location + tempVector);
				 captor.Velocity = 500 * unitVector;
			   }
			   else
			   {
				 //`log("Captor direction is good");
			   }
          }
		}
      }
	}
}

defaultproperties
{
  
  followShotPriority = 5
  fleeCaptorPriority = 4
  fireAtEnemyHostagePriority = 3
  followCaptorPriority = 2
  wanderPriority = 1
  waitPriority = 0
  nothingPriority = -1
  continueCurrentAction = false
}
