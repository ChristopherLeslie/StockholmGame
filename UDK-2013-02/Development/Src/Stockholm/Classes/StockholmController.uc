class StockholmController extends GameAIController;


var float forward_looking_distance;
var StockholmGame game;




simulated event PostBeginPlay()
{

  game = StockholmGame(WorldInfo.Game);
     super.PostBeginPlay();
   
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
     
	dest.y += 100;
	         	 DrawDebugSphere(TempDest,16,20,255,0,255,true);
   	if( FindNavMeshPathToLocation(dest) ){
      	`log(Pawn$" finding nav mesh path");
        NavigationHandle.SetFinalDestination(dest);
        FlushPersistentDebugLines();
        NavigationHandle.DrawPathCache(,TRUE);

        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) ){
        	`log(Pawn$" moving to temp dest");
          	DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
         	 DrawDebugSphere(TempDest,16,20,255,0,0,true);
          	return TempDest;
        }
    }
    else{
      	`log(Pawn$" failure to do any path planning to get to "$dest);
      	debug("failure case 1");
      	return turn_until_you_can_run();
      	
    }
        
    
    
    
   	debug("failure case 2");
    return turn_until_you_can_run();
    
   
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

    DrawDebugLine(Pawn.Location,dest_attempt,255,0,0,true);


  }until( adjustment_counter > 400 || NavigationHandle.PointReachable(dest_attempt));
  return dest_attempt;
}















function debug(String s){
	//WorldInfo.Game.Broadcast(self,s);
}







































defaultProperties{
	  forward_looking_distance = 250;

}