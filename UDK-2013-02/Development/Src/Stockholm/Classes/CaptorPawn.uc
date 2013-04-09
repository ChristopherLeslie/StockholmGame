class CaptorPawn extends StockholmPawn;

var float ElapsedRegenTime;
var float RegenAmount;
var float RegenTime;
var int WardPickups;
var int SentryPickups;
var int MinePickups;


simulated event PostBeginPlay()
{
  super.PostBeginPlay();
  `log("Captor Pawn online");
}

event Tick(float DeltaTime)
{
	//`log("hello, I'm a captor pawn ticking");

        //DrawDebugLine(Location,Location+400*normal(vector(Rotation)),255,0,0,true);

  //calculate elapsed time
  ElapsedRegenTime += DeltaTime;
   
  //has enough time elapsed?
  if(ElapsedRegenTime >= RegenTime)
  {
  
    //heal the Pawn and reset elapsed time
    HealDamage(RegenAmount, Controller, class'DamageType');
    ElapsedRegenTime = 0.0f;
    GroundSpeed = 400;
    if(Velocity != Vect(0,0,0)){
      `log("footstep noise!");
      makeNoise(0.01,'footsteps');
    }
  }
}

function IncWard(SeqAct_IncWard action)
{
	WardPickups = WardPickups + 1;
}

function IncSentry(SeqAct_IncSentry action)
{
	SentryPickups = SentryPickups + 1;
}

function IncMine(SeqAct_IncMine action)
{
	MinePickups = MinePickups + 1;
}


defaultproperties
{
  //set defaults for regeneration properties
  RegenAmount=2
  RegenTime=0.3
  WardPickups = 0
  SentryPickups = 0
  MinePickups = 0
}