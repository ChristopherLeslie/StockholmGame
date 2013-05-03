class StockholmController extends GameAIController;


var float forward_looking_distance;
var StockholmGame game;
var float slowSpeed;
var float normalSpeed;




simulated event PostBeginPlay()
{

  game = StockholmGame(WorldInfo.Game);
     super.PostBeginPlay();

     slowSpeed = 200;
     normalSpeed = 400;
   
}

 //StockholmGame(WorldInfo.Game).totalHostages+=1;
    //StockholmGame(WorldInfo.Game).neutralHostages+=1;


function int distToActor(Actor other){
  return VSize2D(Pawn.Location-other.Location);
}
function int distToVector(Vector other){
  return VSize2D(Pawn.Location-other);
}


function runInDirectionOf(Vector destination){
  SetDestinationPosition(10000*(destination-Pawn.Location)+Pawn.Location);
  bPreciseDestination = True;
}

function runTo(Vector destination){
    SetDestinationPosition(destination);
    bPreciseDestination = True;
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













function Vector simplePathFindToActor(Actor dest){
	return simplePathFindToPoint(dest.Location);
}












function Vector simplePathFindToPoint(Vector dest){
	local Vector TempDest;


	if( NavigationHandle.PointReachable( dest) ){
     	return(dest);
    }
          if(Pawn.isA('CaptorPawn')){
 
 
          }

   	if( FindNavMeshPathToLocation(dest) ){
      	//`log(Pawn$" finding nav mesh path");
        NavigationHandle.SetFinalDestination(dest);
 
 

        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) ){
        	//`log(Pawn$" moving to temp dest");
 
 
          	return TempDest;
        }
        else{
        `log(Pawn$" failure to do any path planning to get to "$dest);
 
        return turn_until_you_can_run();
        
        }
    }
    
        
    
    
    
   	//debug("failure case 2");

    return turn_until_you_can_run();
    
   
}













function Vector simplePathFindToActorOrRandom(Actor a){
  return simplePathFindToPointOrRandom(a.location);
}

function Vector simplePathFindToPointOrRandom(Vector dest){
  local Vector TempDest;


  if( NavigationHandle.PointReachable( dest) ){
      return(dest);
    }
          if(Pawn.isA('CaptorPawn')){
 
 
          }

    if( FindNavMeshPathToLocation(dest) ){
        //`log(Pawn$" finding nav mesh path");
        NavigationHandle.SetFinalDestination(dest);
 
 

        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) ){
          //`log(Pawn$" moving to temp dest");
 
 
            return TempDest;
        }
        else{
          `log(Pawn$" failure to do any path planning to get to "$dest);
 
          return findRandomDest().Location;
        
        }
    }
    
        

    
    
    
    //debug("failure case 2");

    return findRandomDest().Location;
    
   
}







function Vector turn_until_you_can_run(){

  local vector dest_attempt;
  local Rotator xyOrientation;

  local float adjustment_increment;
  local int adjustment_counter;
  local float startYaw;

  //randomly choose to seek out a path to the left or to the right
  if(RandRange(1,100) > 50){
    adjustment_increment = 200;
  }
  else{
    adjustment_increment = -200;
  }


  
  xyOrientation = Pawn.Rotation;
  adjustment_counter = 0;
  startYaw = xyOrientation.yaw;

 
  do{
    adjustment_counter += 1;
    adjustment_increment *= -1;

   xyOrientation.yaw = startYaw + adjustment_increment*adjustment_counter;

    dest_attempt = Pawn.Location + normal(vector(xyOrientation))*forward_looking_distance;

    if(Pawn.isA('CaptorPawn')){
 
    }

  }until( adjustment_counter > 400 || NavigationHandle.PointReachable(dest_attempt));
  return dest_attempt;
}





function byte shTeamNum(){
  return StockholmPawn(Pawn).shTeamNum();
}




function bool teleportToActorSafely(Actor teleport_target){
  local vector offset;
  local Pawn Neighbor;
  local bool retVal;
  local vector teleport_vector;
  local float oldRad;
  local float oldHeight;

  forEach CollidingActors(class'Pawn', Neighbor, 32, teleport_target.Location)
  {
  return false;
  break;
  }

  retVal = teleport_target.findSpot(Pawn.getCollisionExtent(),offset);
  teleport_vector = teleport_target.Location+offset;
  Pawn.setLocation(teleport_vector);

  if(retVal){
    Pawn.setLocation(teleport_vector);
  }
  else{
    debug("trouble teleporting safely");
  }
  return retVal;
}

function vector myFindSpot(Vector first_target_location){
  local bool success;
  local vector target_location;
  local float dist_to_move;
  local vector rand;
  local vector offset;
  local Pawn Neighbor;

  target_location = first_target_location;
    success = false;
    while(!success){
      success = true;
     forEach CollidingActors(class'Pawn', Neighbor, 32, target_location) {
        success = false;
        dist_to_move = Neighbor.getCollisionRadius()+Pawn.getCollisionRadius();
        rand = VRand();
        rand.z = 0;
        rand = normal(rand);
        offset = rand*dist_to_move;
        target_location = Neighbor.Location+offset;
        break;
      }

    }
    return target_location;

}








function debug(String s){
  
	WorldInfo.Game.Broadcast(self,s);
}







































defaultProperties{
	  forward_looking_distance = 250;

}