class CaptorPawn extends StockholmPawn;

var float ElapsedRegenTime;
var float RegenAmount;
var float RegenTime;
var int WardPickups;


simulated event PostBeginPlay()
{
  super.PostBeginPlay();
  `log("Captor Pawn online");
}

event Tick(float DeltaTime)
{
	//`log("hello, I'm a captor pawn ticking");

  //calculate elapsed time
  ElapsedRegenTime += DeltaTime;
   
  //has enough time elapsed?
  if(ElapsedRegenTime >= RegenTime)
  {
    //heal the Pawn and reset elapsed time
    HealDamage(RegenAmount, Controller, class'DamageType');
    ElapsedRegenTime = 0.0f;
    GroundSpeed = 400;
	//`log("Ward Pickups is at "$WardPickups);
  }
}

function IncWard(SeqAct_IncWard action)
{
	`log("INCWARDINCWARD");
	WardPickups = WardPickups + 1;
}



defaultproperties
{
  //set defaults for regeneration properties
  RegenAmount=2
  RegenTime=1
}