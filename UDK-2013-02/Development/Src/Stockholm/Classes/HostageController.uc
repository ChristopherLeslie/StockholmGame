class HostageController extends GameAIController;

//declaring variables here means
//they may be used throughout this script


var Pawn pawnImThinkingAbout;
var Pawn myCaptor;

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


  Pawn.bAvoidLedges=true;
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

function int distTo(Actor other){
  return VSize2D(Pawn.Location-other.Location);
}


function reactToSeeingAPlayer(Pawn seen){
  if(seen.isA('HostagePawn')){
    //Saw another hostage
    return;
  }
  else if(seen.isA('CaptorPawn')){
    //Saw a captor
  }
  
}



auto State Begin{
  Begin:
  goToState('Roaming');
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

    lookAt(NoiseMaker);
  }
  

  
  event seePlayer(Pawn seen){

    `log(Pawn$" sees "$seen);
    if(seen.isA('HostagePawn')){
      return;
    }

    if(distTo(seen) < Pawn.sightRadius){    //it's a captorpawn, and we don't roam while on the same team with any captor 
      pawnImThinkingAbout = seen;
      goToState('Cautious');    //so it is also not on our team
    }

  }
  

  Begin:
    WorldInfo.Game.Broadcast(self,"ROAMING");
    Pawn.GroundSpeed = 100;
    percentOfTimeSpentJustLooking = 40;
    maxWaitTime = 2;
     
    //Generate random vector "random" and random wait time

  ContinueRoaming:
    FlushPersistentDebugLines();

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
          DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
          DrawDebugSphere(TempDest,16,20,255,0,0,true);


          do{
            runInDirectionOf(TempDest);
            sleep(0.5);
          }
          until(NavigationHandle.PointReachable(dest) ||                //we can run straight to our goal 
          VSize2D(Pawn.Location-TempDest) < Pawn.GetCollisionRadius());   //or we've reached TempDest
          
        }
        else{
          `log(Pawn$" failure to do any path planning to get to "$dest);
          WorldInfo.Game.Broadcast(self,"failure case 1");
          sleep(1);
        }
    }
    
    else{
      WorldInfo.Game.Broadcast(self,"failure case 2");
      sleep(1);
    }


   
    goTo('ContinueRoaming');
}
























State Cautious{
  local Vector dest;
  local Vector random;
  local float waitTime;
  local float percentWorried;
  local array<CaptorPawn> captors;

  local int percentOfTimeSpentJustLooking;
  local int maxWaitTime;

  
  event HearNoise(float Loudness, Actor NoiseMaker, optional name NoiseType = 'unknown'){
    local float distance;
    distance = VSize2d(Pawn.Location - NoiseMaker.Location);

    WorldInfo.Game.Broadcast(self,Pawn$" heard a "$NoiseType$" noise from "$NoiseMaker $" that was "$distance$" away from him and it was "$loudness$" db");
  
    
    lookAt(NoiseMaker);
  }

 

 

  
  event seePlayer(Pawn seen){//triggers for pawns that are players

    `log(Pawn$"sees "$seen$", which is a player.");
    
    if(seen.isA('HostagePawn')){
      return;
    }

    //it's a captorpawn and we aren't on the same team
   
    pawnImThinkingAbout = seen;

    if(distTo(seen) < 1000){
      goToState('BackingUp');
    }
    else{
     percentWorried = 100;
    }
    lookAt(seen);
  }


  Begin:
    Pawn.GroundSpeed = 200;
    WorldInfo.Game.Broadcast(self,"CAUTIOUS");
    stopMoving();
    percentWorried = 100;
    maxWaitTime = 2;
    
    //foreach WorldInfo.AllPawns(class'CaptorPawn', P){
    //  captors.addItem(P);
    //}
    goTo('ContinueCaution');

  ContinueCaution:

      waitTime = RandRange(1,maxWaitTime);
      WorldInfo.Game.Broadcast(self,"waiting for "$waitTime$" seconds.");
      sleep(waitTime);

      if(!canSee(pawnImThinkingAbout)){
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
      else{
        lookAt(pawnImThinkingAbout);
      }
     
      if(percentWorried <= 0){
        stopMoving();
        goToState('Roaming');
      }
      else{
        goTo('ContinueCaution');
      }

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

  event seePlayer(Pawn seen){
    if(!seen.Controller.isA('PlayerController')){
      WorldInfo.Game.Broadcast(self,"SAW A MONSTER!");
    }
    else{
      `log("see a player");
    }
  }


  Begin:


     WorldInfo.Game.Broadcast(self,"doing path planning");

    dest = myCaptor; //GetALocalPlayerController().Pawn;


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

  event SeePlayer(Pawn seen){
    if(pawnToFlee != none){
      return;
    }
    if(seen.isA('HostagePawn')){
      return;
    }
    //it's a captor!
    pawnImThinkingAbout = seen;
    pawnToFlee = seen;
  }

  Begin:
  Pawn.GroundSpeed = 200;
  WorldInfo.Game.Broadcast(self,"BACKING UP");
  pawnToFlee = pawnImThinkingAbout;
    while(pawnToFlee == none){
      `log("looking for pawn to flee");
      sleep(0.3f);
    }
  stopMoving();

  GoTo('ContinueBackingUp');

  ContinueBackingUp:
    WorldInfo.Game.Broadcast(self,"continuing to back up.  dist = "$distTo(pawnToFlee));

    distance = distTo(pawnToFlee);
    if(distance > 1200){
      goToState('Cautious');
    }
    if(distance < 600){
      goToState('Fleeing');
    }

    dest = Pawn.Location - pawnToFlee.Location; //offset
    dest = normal(dest)*1000; //scaled offset
    dest = dest+ Pawn.Location; //actual destination


    `log("dest: "$dest);
    
    lookAt(pawnToFlee);
    runInDirectionOf(dest);
    //finishRotation();
    Sleep(0.5);
   
    goTo('ContinueBackingUp');
}











State Fleeing{
  local int certainty;
  local vector estimated_player_location;
  local Pawn player;
  local float distance;
  local vector dest;

  local float forward_looking_distance;

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
function Vector turn_until_you_can_run(){
//FIX THIS FUNCTION!


  local vector dest_attempt;
  local Rotator xyOrientation;

  local float adjustment_increment;
  local int adjustment_counter;
  local float startYaw;

  //randomly choose to seek out a path to the left or to the right
  if(RandRange(1,100) > 50){
    adjustment_increment = 50;
  }
  else{
    adjustment_increment = -50;
  }


  
  xyOrientation = Pawn.Rotation;
  adjustment_counter = 0;
  startYaw = xyOrientation.yaw;

 
  do{
    WorldInfo.Game.Broadcast(self,"turning");
    adjustment_counter += 1;
    adjustment_increment *= -1;

   xyOrientation.yaw = startYaw + adjustment_increment*adjustment_counter;

    dest_attempt = Pawn.Location + normal(vector(xyOrientation))*forward_looking_distance;

    DrawDebugLine(Pawn.Location,dest_attempt,255,0,0,true);


  }until( adjustment_counter > 400 || NavigationHandle.PointReachable(dest_attempt));
  return dest_attempt;

}
  event SeePlayer(Pawn seen){
    if(seen.isA('HostagePawn')){
      return;
    }
    certainty = 100;
    player = seen;
    pawnImThinkingAbout = seen;
    estimated_player_location = player.Location; //a perfect estimation!
  }

  event HearNoise(float Loudness, Actor NoiseMaker, optional name NoiseType = 'unknown'){
    local float the_distance;
    the_distance = VSize2d(Pawn.Location - NoiseMaker.Location);

    `log(Pawn$" heard a "$NoiseType$" noise from "$NoiseMaker $" that was "$the_distance$" away from him and it was "$loudness$" db");

    if(player == NoiseMaker){
      certainty = 100;
      estimated_player_location = player.Location;
    }
  }

  Begin:
    WorldInfo.Game.Broadcast(self,"FLEEING");
    stopMoving();
    Pawn.GroundSpeed = 350;
    certainty = 100;
    forward_looking_distance = 400;
    player = pawnImThinkingAbout;
    while(player == none){ //wait for the seePlayer event to trigger
          sleep(0.1f);
    }
    GoTo('ContinueFleeing');


  ContinueFleeing:
    distance = distTo(player);
    if(distance < 600){                                       //we hear the footsteps
      estimated_player_location = player.Location;
      certainty = 100;
    }
    certainty -= 3;
    if(certainty < 0){
      stopMoving();
      lookAtVector(estimated_player_location);
      finishRotation();
      if(!canSee(player)){
        goToState('Cautious');
      }
    }
    
    dest = Pawn.Location - estimated_player_location; //offset
    dest = normal(dest)*forward_looking_distance; //scaled offset
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
          if(!(VSize2D(Pawn.Location-TempDest) < Pawn.GetCollisionRadius())){


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
            runInDirectionOf(dest);
          }
        }
        else{
          `log(Pawn$" failure to do any path planning to get to "$dest);
          WorldInfo.Game.Broadcast(self,"failure case 1");
          sleep(0.1);
        }
    }
    
    else{
     dest = turn_until_you_can_run();
     runInDirectionOf(dest);
     sleep(0.5);
    }
  }







    sleep(0.1f);
    goTo('ContinueFleeing');
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
  bIsPlayer=True
}
