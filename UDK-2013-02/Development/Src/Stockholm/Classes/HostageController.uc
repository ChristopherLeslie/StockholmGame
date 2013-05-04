class HostageController extends StockholmController;

//declaring variables here means
//they may be used throughout this script


var SoundCue hostageScream;



var Pawn frightener;
var Pawn myCaptor;
var PathNode homeZone;


var Bool bIsFollowingCaptor;
var Bool bIsFollowingOrder;

var int currentActionPriority;
var Vector currentPrioritizedDestination;
var Vector wayPoint;
var Pawn currentPrioritizedTargetToFireAt;




var bool captured;

var int SentryDistanceToTargetStart;
var int SentryDistanceToTargetStop;
var int SentryMaxConsecutiveMisses;
var Rotator currentRotation;

var int WardingDistance;

var vector LocationForItemToGoTo;

var Pawn MineTargetPawn;
var int MineDistanceToBlowUp;

var array<Pathnode> Waypoints;
var array<int> WaypointOrder;


//at the start of the level
simulated event PostBeginPlay()
{
  local pathnode Current;
  local int i;
  super.PostBeginPlay();
  i = 0;
  foreach WorldInfo.AllActors(class'Pathnode',Current)
  {
    if((Current.tag != 'redPen')&&(Current.tag != 'bluePen'))
	{
		Waypoints.AddItem( Current );
		WaypointOrder.AddItem(i);
		i = i + 1;
	}
  }
  ShuffleWaypointOrder();

  captured = false;
  Pawn.bAvoidLedges=true;
}

simulated event Possess(Pawn inPawn, bool bVehicleTransition)
{

  Super.Possess(inPawn, bVehicleTransition);

  HostagePawn(Pawn).setSHteamNum(255); //Neutral

}

function ShuffleWaypointOrder()
{
	local int i;
	local int j;
	local int randomNumber;
	local int tempNumber;
	local String WaypointOrderString;
	local String newOrderString;
	local array<int> newOrder;
	for( i = WaypointOrder.length ; i > 0 ; i--)
	{
		randomNumber = Rand(i-1);
		tempNumber = WaypointOrder[randomNumber];
		newOrder.AddItem(tempNumber);
		WaypointOrderString = "";
		for( j = 0 ; j < WaypointOrder.length; j++)
		{	
			WaypointOrderString = WaypointOrderString$""$WaypointOrder[j]$",";
		}
		//`log("From "$WaypointOrderString$" the "$randomNumber$" element");
		WaypointOrder.Remove(randomNumber, 1);
		WaypointOrderString = "";
		for( j = 0 ; j < WaypointOrder.length; j++)
		{	
			WaypointOrderString = WaypointOrderString$""$WaypointOrder[j]$",";
		}
		newOrderString = "";
		for( j = 0 ; j < newOrder.length; j++)
		{	
			newOrderString = newOrderString$""$newOrder[j]$",";
		}
		//`log("Old :"$WaypointOrderString$" and New:"$newOrderString);
	}
	WaypointOrder = newOrder;
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




function reactToSeeingAPlayer(Pawn seen){
  if(seen.isA('HostagePawn')){
    //Saw another hostage
    return;
  }
  else if(seen.isA('CaptorPawn')){
    //Saw a captor
  }
  
}

function capturedBy(CaptorPawn captor){
  

  myCaptor = captor;
 
  Pawn.Groundspeed = 400;

  if(myCaptor.Controller.isA('PlayerController')){
    GoToState('Following');
  }
  else{
    goHome();
  }
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




function GoHome(){
  if(StockholmPawn(Pawn).shTeamNum()==1){//blue
    homeZone = StockholmGame(WorldInfo.Game).blueTeamBase();
  }
  else{
    homeZone = StockholmGame(WorldInfo.Game).redTeamBase();
  } 

  if(isInState('BlowUpAndDie')||isInState('RemoteMineAttacking')||isInState('RemoteMineWandering')||isInState('Sentry')||isInState('Warding'))
	  `log("Items won't go home");
  else
  {
    GoToState('GoingHome');
  }
}

function followCaptor(){
  if(isInState('AtHome')){
    if(canTeleportToLocationSafely(game.BaseByTeam(shTeamNum()).Location)){
      GoToState('Following');
    }
    else{
      debug("try again in a second");
    }
  }
  else{
	if(isInState('BlowUpAndDie')||isInState('RemoteMineAttacking')||isInState('RemoteMineWandering')||isInState('Sentry')||isInState('Warding'))
	  `log("Items won't follow captor");
	else
	{
      GoToState('Following');
	}
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


  event HearNoise(float Loudness, Actor NoiseMaker, optional name NoiseType = 'unknown'){
   // local float distance;
    //distance = VSize2d(Pawn.Location - NoiseMaker.Location);

    //`log(Pawn$" heard a "$NoiseType$" noise from "$NoiseMaker $" that was "$distance$" away from him and it was "$loudness$" db");

    lookAt(NoiseMaker);
  }
  

  
  event seePlayer(Pawn seen){

    //`log(Pawn$" sees "$seen);
    if(seen.isA('HostagePawn')){
      return;
    }

    if(distToActor(seen) < Pawn.sightRadius){    //it's a captorpawn, and we don't roam while on the same team with any captor 
      frightener = seen;
      goToState('Cautious');    //so it is also not on our team
    }

  }
  

  Begin:
	Pawn.StopFire(0);
    Pawn.GroundSpeed = 100;
    percentOfTimeSpentJustLooking = 40;
    maxWaitTime = 2;
     
    //Generate random vector "random" and random wait time

  ContinueRoaming:

    while(RandRange(1,100) < percentOfTimeSpentJustLooking ){
      random  = VRand();
      random = Pawn.Location + random * 250;
     
      //random.z = Pawn.Location.z;

      dest = random;

      lookAtVector(dest);
      finishRotation();
      waitTime = RandRange(1,maxWaitTime);
      sleep(waitTime);
    }
    

    random  = VRand();
    random = Pawn.Location + random * 250;
    random.z = Pawn.Location.z;
    dest = random;

    wayPoint = simplePathFindToPoint(dest);
                  
    runInDirectionOf(wayPoint);
    lookAtVector(wayPoint);
    sleep(0.5f);


   
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
    
    lookAt(NoiseMaker);
  }

 

 

  
  event seePlayer(Pawn seen){//triggers for pawns that are players

    //`log(Pawn$"sees "$seen$", which is a player.");
    
    if(seen.isA('HostagePawn')){
      return;
    }

    //it's a captorpawn and we aren't on the same team
   
    frightener = seen;

    if(distToActor(seen) < 1000){
      goToState('BackingUp');
    }
    else{
     percentWorried = 100;
    }
    lookAt(seen);
  }


  Begin:
    Pawn.GroundSpeed = 200;
    stopMoving();
    percentWorried = 100;
    maxWaitTime = 2;

    goTo('ContinueCaution');

  ContinueCaution:

      waitTime = RandRange(1,maxWaitTime);
      sleep(waitTime);

      if(!canSee(frightener)){
        percentWorried -= 40*waitTime;

        random  = VRand();
        random = Pawn.Location + random * 250;
       
        //random.z = Pawn.Location.z;
      
        dest = random;


        lookAtVector(dest);
        finishRotation();
      }
      else{
        lookAt(frightener);
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
local vector dest;
local vector offsetFromCaptor;
local float followDistance;
local float stopDistance;


  Begin:
	Pawn.StopFire(0);
    followDistance = 250;
    stopDistance = 250;


     offsetFromCaptor = Pawn.Location-myCaptor.Location;
     dest = myCaptor.Location + normal(offsetFromCaptor) * followDistance;


    wayPoint = simplePathFindToPoint(dest);

    if(distToVector(dest)<= stopDistance){
      runTo(wayPoint);
    }
    else{
      runInDirectionOf(wayPoint);
    }

    lookAt(myCaptor);
    sleep(0.5f);

   
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
    frightener = seen;
    pawnToFlee = seen;
  }

  Begin:
  Pawn.GroundSpeed = 200;
  pawnToFlee = frightener;
    while(pawnToFlee == none){
      //`log("looking for pawn to flee");
      sleep(0.3f);
    }
  stopMoving();

  GoTo('ContinueBackingUp');

  ContinueBackingUp:

    distance = distToActor(pawnToFlee);
    if(distance > 1200){
      goToState('Cautious');
    }
    if(distance < 600){
      goToState('Fleeing');
    }

    dest = Pawn.Location - pawnToFlee.Location; //offset
    dest = normal(dest)*1000; //scaled offset
    dest = dest+ Pawn.Location; //actual destination


    //`log("dest: "$dest);
    
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




  event SeePlayer(Pawn seen){
    if(seen == frightener){
      certainty = 100;
	  if(player != None)
	  {
		estimated_player_location = player.Location; //a perfect estimation!
	  }
    }
  }

  event HearNoise(float Loudness, Actor NoiseMaker, optional name NoiseType = 'unknown'){
    //local float the_distance;
    //the_distance = VSize2d(Pawn.Location - NoiseMaker.Location);

    //`log(Pawn$" heard a "$NoiseType$" noise from "$NoiseMaker $" that was "$the_distance$" away from him and it was "$loudness$" db");

    if(frightener == NoiseMaker){
      certainty = 100;
	  if(player != None)
	  {
		estimated_player_location = player.Location;
	  }
    }
  }

  Begin:
    
     
    
   
       PlaySound ( hostageScream,,,true,Pawn.Location);


    stopMoving();
    Pawn.GroundSpeed = 350;
    certainty = 100;
    
    estimated_player_location = frightener.Location;

    GoTo('ContinueFleeing');


  ContinueFleeing:

    distance = distToActor(frightener);
    if(distance < 600){                                       //we hear the footsteps
      estimated_player_location = frightener.Location;
      certainty = 100;
    }
    certainty -= 10;
    if(certainty < 0){
      stopMoving();
      lookAtVector(estimated_player_location);
      finishRotation();
      if(!canSee(frightener)){
        if(StockholmPawn(Pawn).shTeamNum() != game.neutralTeamNum){
          goHome();
        }
        else{
          goToState('Cautious');
        }
      }
    }
    
    dest = Pawn.Location - estimated_player_location; //offset
    dest = normal(dest)*forward_looking_distance; //scaled offset
    dest = Pawn.Location+dest; //actual destination


    
    wayPoint = simplePathFindToPoint(dest);
                  // 
    runInDirectionOf(wayPoint);
    lookAtVector(wayPoint);
    sleep(0.5f);



    goTo('ContinueFleeing');
}



function GoToRemoteMine()
{
	GoToState('RemoteMineWandering');
}

State BlowUpAndDie
{
	local int LoadedShotCount;
	local int i;
	local float theta;
	local Vector SpreadVector;
	local Projectile SpawnedProjectile;
	Begin:
		`log("BOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOM");
		`log("BOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOM");
		LoadedShotCount = 1;
		for (i = 0; i < LoadedShotCount; i++)
		{
			// Give them some gradual spread.
			theta = 10 * PI / 32768.0 * (i - float(LoadedShotCount - 1) / 2.0);
			SpreadVector.X = Cos(theta);
			SpreadVector.Y = Sin(theta);
			SpreadVector.Z = 0.0;
			
			SpreadVector = vect(0,0,-1);

			SpawnedProjectile = Spawn(class'UTProj_Rocket',,, Pawn.Location, Rotator(SpreadVector));
			SpawnedProjectile.DamageRadius = 400; //default = 220
			SpawnedProjectile.Damage= 200; //default = 100.0
			if ( SpawnedProjectile != None )
			{
				//UTProjectile(SpawnedProjectile).TossZ += (frand() * 200 - 100);
				SpawnedProjectile.Init(SpreadVector);
			}
		}
}

State RemoteMineAttacking
{
  local Actor dest;
  local Vector TempDest;


  event seePlayer(Pawn seen){

  }


  Begin:

	dest = MineTargetPawn; //GetALocalPlayerController().Pawn;

	if(VSize2D(Pawn.Location-MineTargetPawn.Location) < MineDistanceToBlowUp)
    {
		GoToState('BlowUpAndDie');
    }

    `log(Pawn$" attempting navigation to mine target "$MineTargetPawn);
     
     if( NavigationHandle.ActorReachable( dest) ){
 
         Pawn.GroundSpeed = 500;
         lookAt(dest);
         MoveToward(dest,dest);
 
         //sleep(1);
         sleep(0.5);
     }
     
     else if( FindNavMeshPathToActor(dest) ){
      //`log(Pawn$" finding nav mesh path");
        NavigationHandle.SetFinalDestination(dest.Location);
 

        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
          //`log(Pawn$" moving to temp dest");
           
           


          do{
            //`log("running in direction of temp dest");
            MoveTo(TempDest);
            lookAt(dest);
			if(VSize2D(Pawn.Location-MineTargetPawn.Location) < MineDistanceToBlowUp)
			{
				GoToState('BlowUpAndDie');
			}
          }
          until(NavigationHandle.ActorReachable(dest) || //we can run straight to our goal
          VSize2D(Pawn.Location-TempDest) < Pawn.GetCollisionRadius()); //or we've reached TempDest

          //MoveTo( TempDest, dest );
          //`log("done moving to temp dest");
        }
        else{
          `log(Pawn$" failure to do any path planning to get to "$dest);
          `log("failure case 1");
          sleep(1);
        }
    }
    
    else{
      `log(Pawn$" failure to do path planning to get to "$dest);
      if(canSee(Pawn(dest))){
        `log("I can see you...");
      }
      `log("failure case 2");
      sleep(1);
    }
	goto('Begin');
}

State RemoteMineWandering
{
  local Vector dest;
  local Vector random;
  local int pathnodeNumber;
  local Vector TempDest;


  event HearNoise(float Loudness, Actor NoiseMaker, optional name NoiseType = 'unknown'){
    //local float distance;
    //distance = VSize2d(Pawn.Location - NoiseMaker.Location);

    //`log(Pawn$" heard a "$NoiseType$" noise from "$NoiseMaker $" that was "$distance$" away from him and it was "$loudness$" db");

    lookAt(NoiseMaker);
  }
  

  
  event seePlayer(Pawn seen){

    //`log(Pawn$" sees "$seen);
    if(seen.isA('CaptorPawn'))
	{
		if(!StockholmPawn(Pawn).sameTeam(StockholmPawn(seen)))
		{
			MineTargetPawn = seen;
			GoToState('RemoteMineAttacking');
		}
		else
		{
			`log("RM: Same Team!");
		}
    }
  }
  

  Begin:
    Pawn.GroundSpeed = 300;
	pathnodeNumber = 0;
    dest = Waypoints[WaypointOrder[pathnodeNumber]].Location;
	`log("Number: "$pathnodeNumber$". Pathnode: "$WaypointOrder[pathnodeNumber]);
    //Generate random vector "random" and random wait time

  Roam:
 
	`log("Here");
    //random = VRand();
    //random = Pawn.Location + random * 250;
    //random.z = Pawn.Location.z;
    //dest = random;
	if(VSize2d(Pawn.Location - dest) < 100)
	{
		`log("Close enough!");
		pathnodeNumber = pathnodeNumber+1;
		if(pathnodeNumber == Waypoints.Length)
		{
			`log("Reset!");
			pathnodeNumber = 0;
			ShuffleWaypointOrder();
		}
		`log("Number: "$pathnodeNumber$". Pathnode: "$WaypointOrder[pathnodeNumber]);
		dest = Waypoints[WaypointOrder[pathnodeNumber]].Location;
	}
	 
	 

    wayPoint = simplePathFindToPoint(dest);
    runInDirectionOf(wayPoint);
    lookAtVector(wayPoint);
	sleep(0.5);
   
    goTo('Roam');
}





function GoToSentry(vector destination)
{
	LocationForItemToGoTo = destination;
	GoToState('Sentry');
}


State Sentry
{
	local float distance;
	local CaptorPawn captor;
	local HostagePawn hostage;
	local Pawn P;
	local Actor hitActor;
	local Vector v;
	local Vector hitLocation;
	local Vector hitNormal;
	local float scale;
	local int successiveMisses;
	
	event SeePlayer(Pawn seen){
		if(seen.isA('CaptorPawn')){
			if(!StockHolmPawn(Pawn).sameTeam(CaptorPawn(seen))) //Enemy Captor
			{
				`log("I see youuuuuuuu");
				currentPrioritizedTargetToFireAt = seen;
			}
		}
	}
	
	Begin:
		wayPoint = simplePathFindToPoint(LocationForItemToGoTo);
		moveTo(wayPoint);
		lookAtVector(wayPoint);
		if(VSize2D(Pawn.Location - LocationForItemToGoTo) < Pawn.GetCollisionRadius())
		{
			stopMoving();
			GoTo('SentryOn');
		}
		`log("Somewhere I have to get to first :"$LocationForItemToGoTo);
		sleep(0.5);
		GoTo('Begin');
		
		
	SentryOn:
		if(currentPrioritizedTargetToFireAt == none
			   || currentPrioritizedTargetToFireAt.health <= 0)
		{
			//`log("Looking for a target");
			successiveMisses = 0;
			currentPrioritizedTargetToFireAt = none;
			Pawn.StopFire(0);
			Pawn.LockDesiredRotation(false,false);
			Pawn.SetDesiredRotation(currentRotation,true,true,0.25);
			currentRotation.pitch = currentRotation.pitch + (32677/9); 
			currentRotation.yaw = currentRotation.yaw + (32677/9);
			//`log("Rotating to "$currentRotation);
			/*foreach WorldInfo.AllPawns(class'Pawn', P)
			{
				if(P.isA('CaptorPawn')) //Captor
				{ 
					captor = CaptorPawn(P);
					distance = VSize2D(Pawn.Location - captor.Location);
					if(captor.shTeamNum() == Pawn.shTeamNum()) //Friendly Captor
					{

					}
					else //Enemy Captor
					{
						if(distance < SentryDistanceToTargetStart)
						{
							currentPrioritizedTargetToFireAt = captor;
							`log("Priority target:"$currentPrioritizedTargetToFireAt);
						}
					}
				}
				else //NOT a CaptorPawn
				{
					if(P.isA('HostagePawn')) //HostagePawn
					{
						hostage = HostagePawn(P);
						distance = VSize2D(Pawn.Location - hostage.Location);
						if(hostage.shTeamNum() == Pawn.shTeamNum()) //Friendly Hostage
						{

						}
						else //Enemy Hostage
						{
							if(distance < SentryDistanceToTargetStart)
							{
								currentPrioritizedTargetToFireAt = hostage;
								`log("Priority target:"$currentPrioritizedTargetToFireAt);
							}
						}
					}
				}
			}*/
			sleep(0.2);
		}
		else
		{
			//`log("Priority target:"$currentPrioritizedTargetToFireAt);
			hitActor = Trace(hitLocation, hitNormal, currentPrioritizedTargetToFireAt.Location, Pawn.Location, true); //HitLocation, Hit Normal, TraceEnd, TraceStart
			if((hitActor == none) || (hitActor.isA('WorldInfo')))
			{
				//`log("Target is behind something:"$hitActor);
				successiveMisses = successiveMisses + 1;
				if(SentryMaxConsecutiveMisses < successiveMisses)
				{
					currentPrioritizedTargetToFireAt = none;
				}
				else
				{
					`log("Target has been missed "$successiveMisses$" times");
					Pawn.LockDesiredRotation(false,false);
					Pawn.SetDesiredRotation(rotator(currentPrioritizedTargetToFireAt.Location - Pawn.Location),true,true,0.25);
				}
			}
			else
			{
				//`log("Target is hit:"$hitActor);
				successiveMisses = 0;
				Pawn.LockDesiredRotation(false,false);
				Pawn.SetDesiredRotation(rotator(currentPrioritizedTargetToFireAt.Location - Pawn.Location),true,true,0.25);
				distance = VSize2D(currentPrioritizedTargetToFireAt.Location - Pawn.Location);
				Pawn.StartFire(0);
				if(distance > SentryDistanceToTargetStop)
				{
					currentPrioritizedTargetToFireAt = none;
				}
			}
		}
		sleep(0.1);
		GoTo('SentryOn');
}












function GoToWard(vector destination)
{
	LocationForItemToGoTo = destination;
	`log("Warding");
	GoToState('Warding');
}


State Warding
{
	local Pawn P;
	local CaptorPawn captor;
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
	Begin:
		wayPoint = simplePathFindToPoint(LocationForItemToGoTo);
		moveTo(wayPoint);
		lookAtVector(wayPoint);
		if(VSize2D(Pawn.Location - LocationForItemToGoTo) < Pawn.GetCollisionRadius())
		{
			stopMoving();
			`log("Now Warding");
			GoTo('WardingOn');
		}
		`log("Somewhere I have to get to first :"$LocationForItemToGoTo);
		sleep(0.5);
		GoTo('Begin');
		
	WardingOn:
		foreach WorldInfo.AllPawns(class'Pawn', P)
		{
			if(P.isA('CaptorPawn')) //Captor
			{
				captor = CaptorPawn(P);
				distance = VSize2D(Pawn.Location - captor.Location);
				if(!StockHolmPawn(Pawn).sameTeam(captor)) //Enemy Captor
				{
					if(distance < WardingDistance) //Enemy Captor is near me
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
		sleep(0.005);
		GoTo('WardingOn');
}








State GoingHome{
    local PathNode dest;
    local Vector turn_dest;
  Begin:
    Pawn.StopFire(0);
    dest = homeZone;
    GoTo('ContinuingToGoHome');



  ContinuingToGoHome:
 
      if(distToActor(dest) < 100){
        runTo(dest.Location);
        sleep(1);
        GoToState('AtHome');
      }
     wayPoint = simplePathFindToActor(dest);
    runInDirectionOf(wayPoint);
    lookAtVector(wayPoint);
    sleep(0.5f);

        GoTo('ContinuingToGoHome');

}

State AtHome{
  local Vector teleport_offset;
  local actor teleport_actor;
  local PathNode my_pen;
  local Vector pawn_size;
  local bool success;


  event EndState(name nextStateName){
        WorldInfo.Game.Broadcast(self,string(nextStateName));

        game.leaveBase(shTeamNum());
        success = teleportToActorSafely(game.baseByTeam(shTeamNum()));

  }

  event Landed (Vector hitNormal, Actor FloorActor){
    myFeign();
    super.Landed(hitNormal,FloorActor);
  }
  event Falling(){
    super.Falling();
    myFeign();
  }


  Begin:
    GoTo('AttemptToTeleport');

  AttemptToTeleport:
      teleport_actor = game.penByteam(shTeamNum());
      
      drawdebugsphere(teleport_actor.location,24,10,255,255,255);
      success = teleportToActorSafely(teleport_actor);
    if(success){
        game.enterBase(StockholmPawn(Pawn).shTeamNum());
        GoTo('Lounge');
    }
    else{
      debug("FAILED TO FIND A PLACE TO TELEPORT TO");
      sleep(0.5);
      GoTo('AttemptToTeleport');
    }
 

  Lounge:



    
    
}
function myFeign(){
  if(StockholmPawn(Pawn).bFeigningDeath){
    return;
  }
  else{
    //StockholmPawn(Pawn).playFeignDeath();
    StockholmPawn(Pawn).forceRagdoll();
  }
}
function myGetUp(){
  if(StockholmPawn(Pawn).bFeigningDeath){
    StockholmPawn(Pawn).playFeignDeath();
  }
  else{
    return;
  }
}

function debug(String s){
  WorldInfo.Game.Broadcast(self,s);
}






















function hearShot(Captorpawn captor, Vector hitLocation){
  
}

defaultproperties
{
  

  bIsPlayer=True;
  SentryDistanceToTargetStart = 1000;
  SentryDistanceToTargetStop = 3000;
  SentryMaxConsecutiveMisses = 20;
  WardingDistance = 450;
  MineTargetPawn = None;
  MineDistanceToBlowUp = 200;

  forward_looking_distance = 250;
  
  


  hostageScream = SoundCue'Stockholm_Sounds.HostageFlee1_Cue';
  
}
