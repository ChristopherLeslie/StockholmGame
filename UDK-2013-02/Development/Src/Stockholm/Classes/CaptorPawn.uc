class CaptorPawn extends StockholmPawn;

var float ElapsedRegenTime;
var float RegenAmount;
var float RegenTime;
var int WardPickups;
var int SentryPickups;
var int MinePickups;

var SoundCue deathVoice;
var SoundCue injuryVoice;

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
      //`log("footstep noise!");
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

function AddDefaultInventory()
{
    InvManager.CreateInventory(class'Stockholm.CaptorGun');
}


event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
  Super.TakeDamage(DamageAmount, EventInstigator,  HitLocation,  Momentum, DamageType, HitInfo, DamageCauser);
  if(damageAmount > 0){
  
	if(Controller.isA('PlayerController')){
		if(Health < 1){
		  //death noises
		  PlaySound (deathVoice,,,,);
		  
		}
		else if(Health < 20){
		  //GUSHIN OUT LIKE ONE OF THEM CANDIES
		  //PlaySound (Voice,,,true,);
		}
		else{
			//GOT ME!
			PlaySound (injuryVoice,,,true,);
		}
    }
  }
}




defaultproperties
{
  //set defaults for regeneration properties
  RegenAmount=2
  RegenTime=0.3
  WardPickups = 0
  SentryPickups = 0
  MinePickups = 0
  
  deathVoice = SoundCue'Stockholm_Sounds.Death1_Cue';
  injuryVoice = SoundCue'Stockholm_Sounds.Injured1_Cue';
  
}