class HostageController extends GameAIController;

//declaring variables here means
//they may be used throughout this script

var CaptorPawn captorToFollow;
var CaptorPawn captorToFlee;

var Bool bIsFollowingCaptor;
var Bool bIsFollowingOrder;

var int currentActionPriority;
var Vector currentPrioritizedDestination;
var() Vector TempDest;
var Pawn currentPrioritizedTargetToFireAt;


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
  //Pawn.Groundspeed = 100;
  //wander();
  //SetTimer(0.5, true, 'BrainTimer');
  //preferredDestination = Spawn(class'ActorWaypoint');
  Pawn.bAvoidLedges=true;
  Pawn.sightRadius = 2000;
}

function LookAt(Actor a){

local Rotator final_rot;
        final_rot = Rotator(a.Location-Pawn.Location);
        Pawn.LockDesiredRotation(false,false);
        Pawn.SetDesiredRotation(final_rot,true);
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

auto State Begin{
  Begin:
  goToState('Roaming');
}


function GoToWard(){
	goToState('Ward');
}


State Ward{
	local float distance;
	local CaptorPawn captor;
	local HostagePawn hostage;
	local Pawn P;
	local Vector v;
	local float scale;
	local float sleep_time;
	local Pawn currentPrioritizedTargetToFireAtSentry;
	Begin:
		if(currentPrioritizedTargetToFireAtSentry == none 
		   ||  currentPrioritizedTargetToFireAtSentry.health <= 0)
		{
		  `log("Looking for a target");
		  Pawn.StopFire(0);
		  Pawn.StopFire(1);
		  currentPrioritizedTargetToFireAtSentry = none;
		  Pawn.StopFire(1);
		  foreach WorldInfo.AllPawns(class'Pawn', P){
			  if(P.isA('CaptorPawn')){ //Captor
				captor = CaptorPawn(P);
				distance =  VSize2D(Pawn.Location - captor.Location);
				if(captor.getTeamNum() == Pawn.getTeamNum()){ //Friendly Captor 
				  if(distance < 400){
					currentPrioritizedTargetToFireAtSentry = captor;
				  }
				}
				else{                         //Enemy Captor
				  if(distance < 400){
					currentPrioritizedTargetToFireAtSentry = captor;
				  }
				}
			  }
			  else{//NOT a CurrentGame_CaptorPawn
			  
			  } 
		  }
		  sleep_time=0.1;
		}
		else
		{
			`log("Priority target:"$currentPrioritizedTargetToFireAtSentry);
			Pawn.LockDesiredRotation(false,false);
			Pawn.SetDesiredRotation(rotator(currentPrioritizedTargetToFireAtSentry.Location - Pawn.Location),true,true,0.25);
			distance =  VSize2D(currentPrioritizedTargetToFireAtSentry.Location - Pawn.Location);
			Pawn.StartFire(1);
			if(distance > 1500)
			{
				currentPrioritizedTargetToFireAtSentry = none;
				Pawn.StopFire(0);
				Pawn.StopFire(1);
				goToState('Roaming');
			}
			sleep_time = 0.03;
		}
		sleep(sleep_time);
		goTo('Begin');
}

















State Roaming{
  local Vector dest;
  local Vector random;
  local float waitTime;
  //local bool justLooking;

  local int percentOfTimeSpentJustLooking;
  local int maxWaitTime;


function bool FindNavMeshPath()
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




  
  event HearNoise(float Loudness, Actor NoiseMaker, optional name NoiseType = 'unknown'){
    local float distance;
    distance = VSize2d(Pawn.Location - NoiseMaker.Location);

    `log(Pawn$" heard a "$NoiseType$" noise from "$NoiseMaker $" that was "$distance$" away from him and it was "$loudness$" db");
    goToState('Cautious');
    `log("finishing the hearNoise event in Roaming");
    lookAt(NoiseMaker);
  }
  
 

  event seeMonster(Pawn seen){ //only triggers for pawns with bIsPlayer set to false
    `log(Pawn$"sees "$seen$", which is a monster.");

  }

  
  event seePlayer(Pawn seen){//triggers for pawns that are players
    `log(Pawn$"sees "$seen$", which is a player.");
    if(VSize2D(Location-seen.Location) < 600){
      goToState('Cautious');
      LookAt(seen);
    }
  }
  

  event MayFall(bool bFloor, Object.Vector floorNormal){
    `log("hi1");
    WorldInfo.Game.Broadcast(self,"bfloor: "$bFloor$".  floorNormal: "$floorNormal);
  }

  event MoveUnreachable (Object.Vector AttemptedDest, Actor AttemptedTarget){
    `log("hi2");
    WorldInfo.Game.Broadcast(self,"AttemptedDest: "$ AttemptedDest$ ".  AttemptedTarget: "$attemptedTarget);
  }


  Begin:
        WorldInfo.Game.Broadcast(self,"ROAMING");
        Pawn.GroundSpeed = 100;
    FlushPersistentDebugLines();
    percentOfTimeSpentJustLooking = 40;
    maxWaitTime = 2;
     
    //Generate random vector "random" and random wait time



    while(RandRange(1,100) < percentOfTimeSpentJustLooking ){
      random  = VRand();
      random = Pawn.Location + random * 250;
     
      //random.z = Pawn.Location.z;

      dest = random;
      DrawDebugLine(Pawn.Location,dest,255,0,0,true);
      DrawDebugSphere(dest,16,20,255,0,0,true);

      lookAtVector(dest);
      finishRotation();
      waitTime = RandRange(1,maxWaitTime);
      WorldInfo.Game.Broadcast(self,"waiting for "$waitTime$" seconds.");
      sleep(waitTime);
    }
    

    random  = VRand();
    random = Pawn.Location + random * 250;
    random.z = Pawn.Location.z;
    dest = random;
    DrawDebugLine(Pawn.Location,dest,255,0,0,true);
    DrawDebugSphere(dest,16,20,255,0,0,true);

    lookAtVector(dest);
     
    if( NavigationHandle.PointReachable( dest) ){
     MoveTo(dest);
     //WorldInfo.Game.Broadcast(self,"sleeping1");
     //sleep(1);
     //WorldInfo.Game.Broadcast(self,"moving toward the player");
    }
     
     else if( FindNavMeshPath() ){
      `log(Pawn$" finding nav mesh path");
        NavigationHandle.SetFinalDestination(dest);
        FlushPersistentDebugLines();
        NavigationHandle.DrawPathCache(,TRUE);

        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
          `log(Pawn$" moving to temp dest");
          WorldInfo.Game.Broadcast(self,"moving to temp dest");
          DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
          DrawDebugSphere(TempDest,16,20,255,0,0,true);


          do{
            WorldInfo.Game.Broadcast(self,"running in direction of temp dest");
            runInDirectionOf(TempDest);
            sleep(0.5);
          }
          until(NavigationHandle.PointReachable(dest) ||                //we can run straight to our goal 
          VSize2D(Pawn.Location-TempDest) < Pawn.GetCollisionRadius());   //or we've reached TempDest
          

          //MoveTo( TempDest, dest );
          WorldInfo.Game.Broadcast(self,"done moving to temp dest");
        }
        else{
          `log(Pawn$" failure to do any path planning to get to "$dest);
          WorldInfo.Game.Broadcast(self,"failure case 1");
          sleep(1);
        }
    }
    
    else{
      `log(Pawn$" failure to do path planning to get to "$dest);
      //if(canSee(Pawn(dest))){
      //  WorldInfo.Game.Broadcast(self,"I can see you...");
      //}
      WorldInfo.Game.Broadcast(self,"failure case 2");
      sleep(1);
    }


   
    goTo('Begin');
}
























State Cautious{
  local Vector dest;
  local Vector random;
  local float waitTime;
  local float percentWorried;

  local int percentOfTimeSpentJustLooking;
  local int maxWaitTime;

  
  event HearNoise(float Loudness, Actor NoiseMaker, optional name NoiseType = 'unknown'){
    local float distance;
    distance = VSize2d(Pawn.Location - NoiseMaker.Location);

    WorldInfo.Game.Broadcast(self,Pawn$" heard a "$NoiseType$" noise from "$NoiseMaker $" that was "$distance$" away from him and it was "$loudness$" db");
  
    
    lookAt(NoiseMaker);
    goToState('Cautious');
  }

 

 

  
  event seePlayer(Pawn seen){//triggers for pawns that are players
    `log(Pawn$"sees "$seen$", which is a player.");
    LookAt(seen);
    if(VSize2D(seen.Location - Pawn.Location) < 600){
      goToState('BackingUp');
    }
    else{
      goToState('Cautious');
    }

  }

  Begin:
    Pawn.GroundSpeed = 200;
        WorldInfo.Game.Broadcast(self,"CAUTIOUS");
        stopMoving();
   percentWorried = 100;
    maxWaitTime = 4;
     

    while(percentWorried > 0 ){
      waitTime = RandRange(1,maxWaitTime);
      WorldInfo.Game.Broadcast(self,"waiting for "$waitTime$" seconds.");
      sleep(waitTime);
      percentWorried -= 40*waitTime;

      random  = VRand();
      random = Pawn.Location + random * 250;
     
      //random.z = Pawn.Location.z;

      dest = random;
      DrawDebugLine(Pawn.Location,dest,255,0,0,true);
      DrawDebugSphere(dest,16,20,255,0,0,true);

      lookAtVector(dest);
      finishRotation();
     
    }
    

     stopMoving();
    goToState('Roaming');
}















State Following{
local Actor dest;


function bool FindNavMeshPath()
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


  Begin:


     WorldInfo.Game.Broadcast(self,"doing path planning");

    dest = GetALocalPlayerController().Pawn;


     `log(Pawn$"attempting navigation");
     
     if( NavigationHandle.ActorReachable( dest) ){
        FlushPersistentDebugLines();
         Pawn.GroundSpeed = 200;
         lookAt(dest);
         MoveToward(dest,dest);
         //WorldInfo.Game.Broadcast(self,"sleeping1");
         //sleep(1);
         WorldInfo.Game.Broadcast(self,"moving toward the player");
     }
     
     else if( FindNavMeshPath() ){
      `log(Pawn$" finding nav mesh path");
        NavigationHandle.SetFinalDestination(dest.Location);
        FlushPersistentDebugLines();
        NavigationHandle.DrawPathCache(,TRUE);

        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
          `log(Pawn$" moving to temp dest");
          WorldInfo.Game.Broadcast(self,"moving to temp dest");
          DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
          DrawDebugSphere(TempDest,16,20,255,0,0,true);


          do{
            WorldInfo.Game.Broadcast(self,"running in direction of temp dest");
            runInDirectionOf(TempDest);
            lookAt(dest);
            sleep(0.5);
          }
          until(NavigationHandle.ActorReachable(dest) ||                //we can run straight to our goal 
          VSize2D(Pawn.Location-TempDest) < Pawn.GetCollisionRadius());   //or we've reached TempDest
          

          //MoveTo( TempDest, dest );
          WorldInfo.Game.Broadcast(self,"done moving to temp dest");
        }
        else{
          `log(Pawn$" failure to do any path planning to get to "$dest);
          WorldInfo.Game.Broadcast(self,"failure case 1");
          sleep(1);
        }
    }
    
    else{
      `log(Pawn$" failure to do path planning to get to "$dest);
      if(canSee(Pawn(dest))){
        WorldInfo.Game.Broadcast(self,"I can see you...");
      }
      WorldInfo.Game.Broadcast(self,"failure case 2");
      sleep(1);
    }


   
    goTo('Begin');
}


















State BackingUp{
  //ignores FunctionName, OtherFunction; //don't perform FunctionName or OtherFunction while fleeing
  local Pawn pawnToFlee;
  local Vector dest;
  local float distance;
  local string message;

  event SeePlayer(Pawn SeenPlayer){
    pawnToFlee = SeenPlayer;
  }

  Begin:
  WorldInfo.Game.Broadcast(self,"BACKING UP");
    while(pawnToFlee == none){
      sleep(0.3f);
    }

    distance = VSize2D(Pawn.Location - pawnToFlee.Location);
    if(distance > 800){
      goToState('Cautious');
    }
    if(distance < 400){
      goToState('Following');
    }

    dest = Pawn.Location - pawnToFlee.Location; //offset
    dest = normal(dest)*1000; //scaled offset
    dest = dest+ Pawn.Location; //actual destination
    //preferredDestination = Spawn(class'Actor');
    //preferredDestination.setLocation(dest);

    `log("dest: "$dest);
    Pawn.GroundSpeed = 200;
    lookAt(pawnToFlee);
    finishRotation();
       
        runInDirectionOf(dest);
    
        //WorldInfo.Game.Broadcast(self,"after moving");

   
    goTo('Begin');
}










State Fleeing{
  local int certainty;
  local vector estimated_player_location;
  local Pawn player;
  local float distance;
  local vector dest;

function bool FindNavMeshPath()
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

  event SeePlayer(Pawn SeenPlayer){
    certainty = 100;
    player = SeenPlayer;

    estimated_player_location = player.Location; //a perfect estimation!
  }

  Begin:
    WorldInfo.Game.Broadcast(self,"FLEEING");
    Pawn.GroundSpeed = 350;

    while(player == none){ //wait for the seePlayer event to trigger
          sleep(0.1f);
    }

    distance = VSize2D(player.location-Pawn.location);
    if(distance < 600){                                       //we hear the footsteps
      estimated_player_location = player.Location;
      certainty = 100;
    }
    certainty -= 5;
    if(certainty < 0){
      stopMoving();
      lookAtVector(estimated_player_location);
      finishRotation();
      if(!canSee(player)){
        goToState('Cautious');
      }
    }
    
    dest = Pawn.Location - estimated_player_location; //offset
    dest = normal(dest)*400; //scaled offset
    dest = Pawn.Location+dest; //actual destination
    //preferredDestination.setLocation(dest);

    lookAtVector(dest); //run away facing away
    runInDirectionOf(dest);




if( !NavigationHandle.PointReachable( dest) ){
     if( FindNavMeshPath() ){
      `log(Pawn$" finding nav mesh path");
        NavigationHandle.SetFinalDestination(dest);
        FlushPersistentDebugLines();
        NavigationHandle.DrawPathCache(,TRUE);

        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
          `log(Pawn$" moving to temp dest");
          WorldInfo.Game.Broadcast(self,"moving to temp dest");
          DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
          DrawDebugSphere(TempDest,16,20,255,0,0,true);


          do{
            WorldInfo.Game.Broadcast(self,"running in direction of temp dest");
            runInDirectionOf(TempDest);
            sleep(0.1);
          }
          until(NavigationHandle.PointReachable(dest) ||                //we can run straight to our goal 
          VSize2D(Pawn.Location-TempDest) < Pawn.GetCollisionRadius());   //or we've reached TempDest
          

          //MoveTo( TempDest, dest );
          WorldInfo.Game.Broadcast(self,"done moving to temp dest");
        }
        else{
          `log(Pawn$" failure to do any path planning to get to "$dest);
          WorldInfo.Game.Broadcast(self,"failure case 1");
          sleep(0.1);
        }
    }
    
    else{
     runInDirectionOf(FindRandomDest().Location);
    }
  }







    sleep(0.1f);
    goTo('Begin');
}





























function hearShot(Captorpawn captor, Vector hitLocation){
  
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
  //continueCurrentAction = false

}
