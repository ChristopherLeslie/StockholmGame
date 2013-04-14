class StockholmPawn extends UTPawn;

var byte teamNum;

var int redLoyalty;
var int blueLoyalty;
var int maxLoyalty;


simulated event PostBeginPlay()
{
  super.PostBeginPlay();
  `log("Stockholm Pawn online");
}



simulated function byte shTeamNum(){
  return teamNum;
}





function bool sameTeam(StockholmPawn other){
  
  return(shTeamNum() == other.shTeamNum());
  
}

function bool enemyTeam(StockholmPawn other){
  local StockholmGame game;
  game = StockholmGame(WorldInfo.Game);

  if(shTeamNum()==game.neutralTeamNum
    ||other.shTeamNum()==game.neutralTeamNum){
    return false;
    }

  return !sameTeam(other);

}




  

/*
simulated function shotBy(Pawn antagonist){
  if(antagonist.isA('CaptorPawn')){
    Pawn.setDrawScale(0.5f + (blueLoyalty / 10.0f));
    `log("i got shot by a captor!");
  }
}
*/
















defaultproperties
{

}