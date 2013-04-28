class StockholmPawn extends UTPawn;

var byte shInnerTeamNum;

var int redLoyalty;
var int blueLoyalty;
var int maxLoyalty;

var SoundCue killVoice;

simulated event PostBeginPlay()
{
  super.PostBeginPlay();
  `log("Stockholm Pawn online");
}



simulated function byte shTeamNum(){
  return shInnerTeamNum;
}

function setShTeamNum(byte newTeamNum){
  shInnerTeamNum = newTeamNum;
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









event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
  Super.TakeDamage(DamageAmount, EventInstigator,  HitLocation,  Momentum, DamageType, HitInfo, DamageCauser);
  
  if(EventInstigator.isA('PlayerController')){

    if(Health < 1){
      //i killed an enemy
	  PlaySound (killVoice,,,true,EventInstigator.Pawn.Location);
    }

	else{
		//i hurt an enemy couldnt escape bullets
	}
	
  }

}






defaultproperties
{

	killVoice = SoundCue'Stockholm_Sounds.kill5_Cue';

}