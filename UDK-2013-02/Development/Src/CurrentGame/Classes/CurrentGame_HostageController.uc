class CurrentGame_HostageController extends GameAIController;

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
  SetTimer(0.5, true, 'BrainTimer');
  SetTimer(0.01, true, 'wardCaptor');
}



function BrainTimer(){
  local float distance;
  local CurrentGame_CaptorPawn captor;
  local CurrentGame_HostagePawn hostage;
  local Pawn P;
  local Vector v;
  local float scale;
  scale = Pawn.Health / 100.0f;
  Pawn.setDrawScale(scale);

  Pawn.Groundspeed = 200;
  //if i'm continuing my current action
  //switch case which action i'm doing
  //test to see if i'm done
  //if i Am, finish that action, let my priority back down to -1
  //else don't lower my priority, so that only actions with higher priority will interrupt me

  if(continueCurrentAction){
    switch(currentAction){
      case EHostageAction.fireAtEnemyHostage:

            if(     !currentPrioritizedTargetToFireAt.isA('CurrentGame_HostagePawn')
                ||   currentPrioritizedTargetToFireAt == none 
                ||  currentPrioritizedTargetToFireAt.health <= 0){ //the target dies
              finishCurrentAction();
            }
            else{
              Pawn.GroundSpeed = 1;
              currentPrioritizedDestination = currentPrioritizedTargetToFireAt.Location;
              Pawn.StartFire(1);
            }
            break;
      case EHostageAction.followShot:
        distance = VSize2D(Pawn.Location - currentPrioritizedDestination);
        if(distance < 50){//I reached where the shot hit the wall
          finishCurrentAction();
        }
        break;
      case EHostageAction.followCaptor:
        //no reason as of yet to have different beginning and end reasons to follow Captor
        finishCurrentAction();
        break;
      case EHostageAction.fleeCaptor:
        //no reason as of yet to have different start and end reasons to flee Captor
        finishCurrentAction();
        break;
      case EHostageAction.wander:
      distance =  VSize2D(Pawn.Location - currentPrioritizedDestination);
        //if(distance  < 50){
          finishCurrentAction();
       // }
        break;
      case EHostageAction.wait:
        //no reason to wait yet
        finishCurrentAction();
        break;
      default:
        //probably shouldn't execute
        finishCurrentAction();
    }
  }
    else{
      finishCurrentAction();
    }
    //every brain tick I look around and decide...
    //if a friendly captor is near, i'll follow him
    //if an enemy captor is near, i'll run from him
    //else i'll wander

    
    
  
    foreach WorldInfo.AllPawns(class'Pawn', P){
      if(P.isA('CurrentGame_CaptorPawn')){                            //Captor
        captor = CurrentGame_CaptorPawn(P);
        distance =  VSize2D(Pawn.Location - captor.Location);
        if(captor.getTeamNum() == Pawn.getTeamNum()){ //Friendly Captor 
          
          if(distance < 400){ //Friendly Captor is near me
            followCaptor(captor); //begin following the captor
          }
        }
        else{                         //Enemy Captor
          if(distance < 400){         //Enemy Captor is too close to me
			  //wardCaptor(captor, Pawn);
              //fleeCaptor(captor);
          }
        }
      }
      else{//NOT a CurrentGame_CaptorPawn
        if(P.isA('CurrentGame_HostagePawn')){                         //it's a hostage
          hostage = CurrentGame_HostagePawn(P);
          distance =  VSize2D(Pawn.Location - hostage.Location);

          if(  hostage.getTeamNum() != Pawn.getTeamNum() && distance < 400){  //it's a close enemy hostage
            fireAtEnemyHostage(hostage);
          } 
        }
      }
    }

    //wander();
  
    GoToState('MoveAbout');
  
}

simulated function wander(){
  local Bool beganWandering;
  beganWandering = addDestinationWithPriority(  FindRandomDest().Location , wanderPriority);
  if(beganWandering){
    lockAction(EHostageAction.wander);
  }
}

simulated function followCaptor(CurrentGame_CaptorPawn captor){
  local Bool beganFollowing;
  beganFollowing = addDestinationWithPriority(captor.Location, followCaptorPriority);
  if(beganFollowing){
    currentAction = EHostageAction.followCaptor;
  }
}

simulated function wardCaptor(){
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

simulated function fleeCaptor(CurrentGame_CaptorPawn captor){
   local Vector dest;
   local Bool beganFleeing;
   dest = 2* Pawn.Location - captor.Location;
   //Test priority before doing these calculations?
   beganFleeing = addDestinationWithPriority(dest,fleeCaptorPriority);
   if(beganFleeing){
    currentAction = EHostageAction.fleeCaptor;
   }
}
simulated function fireAtEnemyHostage(CurrentGame_HostagePawn hostage){
    if(addDestinationWithPriority(Pawn.Location, fireAtEnemyHostagePriority)){
        //target them
        currentPrioritizedTargetToFireAt = hostage;
        lockAction(EHostageAction.fireAtEnemyHostage);
    }

}

simulated function lockAction(EHostageAction action){
  currentAction = action;
  continueCurrentAction = true;
}
simulated function finishCurrentAction(){

  currentActionPriority = -1;
  continueCurrentAction = false;
  currentAction = EHostageAction.nothing;
  Pawn.StopFire(0);
  Pawn.StopFire(1);
  //currentPrioritizedTargetToFireAt = none;
}

simulated function bool addDestinationWithPriority(Vector theLocation, int priority){
  local Vector resultDestination;
  if(priority < currentActionPriority){
    return false;
  }
  if(priority == currentActionPriority){
    //resultDestination.x = (theLocation.x + currentPrioritizedDestination.x) /2;
    //resultDestination.y = (theLocation.y + currentPrioritizedDestination.y) /2;
    //resultDestination.z = (theLocation.z + currentPrioritizedDestination.z) /2;
    //currentPrioritizedDestination = resultDestination;
    //currentActionPriority = priority;
    return false;
  }
  else{
    currentPrioritizedDestination = theLocation;
    currentActionPriority = priority;
    return true;
  }
}



function hearShot(CurrentGame_CaptorPawn captor, Vector hitLocation){
  //If my Captor shot that bullet, follow it!
  local bool beganFollowingShot;
  if(captor.getTeamNum() == Pawn.getTeamNum()){
    beganFollowingShot = addDestinationWithPriority(hitLocation,followShotPriority);
    if(beganFollowingShot){
      lockAction(EHostageAction.followShot);
    }
  }

}




state MoveAbout{
  Begin:
    MoveTo(currentPrioritizedDestination);
}






/*
auto State Idle{
  event SeePlayer(Pawn SeenPlayer){
  local 
 //   local CurrentGame_CaptorPawn captor;
    //if(SeenPlayer.isA('CurrentGame_CaptorPawn')){
      //captor = CurrentGame_CaptorPawn(SeenPlayer);
      if(SeenPlayer
    //}
  }
}

State Fleeing{
  Begin:
}
*/

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
