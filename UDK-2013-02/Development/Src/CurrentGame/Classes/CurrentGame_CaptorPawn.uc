class CurrentGame_CaptorPawn extends UTPawn;

var float ElapsedRegenTime;
var float RegenAmount;
var float RegenTime;


var byte teamNum;

/*event Tick(float DeltaTime)
{
	`log("hello, I'm a captor pawn ticking");
  //calculate elapsed time
  ElapsedRegenTime += DeltaTime;
   
  //has enough time elapsed?
  if(ElapsedRegenTime >= RegenTime)
  {
    //heal the Pawn and reset elapsed time
    HealDamage(RegenAmount, Controller, class'DamageType');
    ElapsedRegenTime = 0.0f;
  }
}*/


simulated function byte getTeamNum(){
  return teamNum;
}

defaultproperties
{
  //set defaults for regeneration properties
  RegenAmount=2
  RegenTime=1
  teamNum = 1

}