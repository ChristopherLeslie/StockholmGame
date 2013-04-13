class HostagePawn extends StockholmPawn; 


var float ElapsedTime;

var CaptorPawn captorCapturingMe;

var CaptorPawn myCaptor;

var MaterialInterface defaultMaterial0;


simulated event PostBeginPlay()
{
  setDrawScale(0.80f);
  `log("hello, I'm a bot");
   Super.PostBeginPlay();
}


event Tick(float DeltaTime)
{
  
  //calculate elapsed time
  ElapsedTime += DeltaTime;
   
  //has enough time elapsed?
  if(ElapsedTime >= 0.1)
  {

        //DrawDebugLine(Location,Location+400*normal(vector(Rotation)),255,0,0,true);

    
  }
}








simulated function receivePersuasion(CaptorPawn captor){
  
  increaseLoyalty(captor.getTeamNum());
  captorCapturingMe = captor;
  `log("My team loyalties- red: "$redLoyalty$".  blue: "$blueLoyalty);
}

simulated function switchToTeam(byte team_number){
  local StockholmGame game;

  game = StockholmGame(WorldInfo.Game);

  if(team_number != game.neutralTeamNum){ //The Hostage joined a team
    myCaptor = captorCapturingMe;
    HostageController(Controller).capturedBy(myCaptor);
    HostageController(Controller).GoToState('Following');
  }
  else{ //The Hostage Became Neutral
    HostageController(Controller).GoToState('Fleeing');
  }

  if(team_number == game.redTeamNum){
    `log("I've switched to the red team.");
    teamNum = game.redTeamNum;
     Mesh.SetMaterial(0,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_VRed');
     Mesh.SetMaterial(1,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_VRed');

  }

  if(team_number == game.blueTeamNum){
    `log("I've switched to the blue team");
    teamNum = game.blueTeamNum;
     Mesh.SetMaterial(0,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_VBlue');
     Mesh.SetMaterial(1,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_VBlue');

  }

  if(team_number == game.neutralTeamNum){
    `log("I've switched to the neutral team");
    teamNum = game.neutralTeamNum;
     Mesh.SetMaterial(0,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_V01');
     Mesh.SetMaterial(1,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_V01');

  }


}







simulated function increaseLoyalty(byte team_number){
  local StockholmGame game;

  game = StockholmGame(WorldInfo.Game);


  if(team_number == game.redTeamNum){
    if(blueLoyalty > 0){
      --blueLoyalty;
      if(blueLoyalty == 0){
        switchToTeam(game.neutralTeamNum);
      }
    }
    else if(redLoyalty < maxLoyalty){
      ++redLoyalty;
    }
    else if(teamNum != game.redTeamNum){
      switchToTeam(game.redTeamNum);
    }
    else{
      //do nothing, we're already on the red team and don't need to gain loyalty
    }
  }

  if(team_number == game.blueTeamNum){
    if(redLoyalty > 0){
      --redLoyalty;
      if(redLoyalty == 0){
        switchToTeam(game.neutralTeamNum);
      }
    }
    else if(blueLoyalty < maxLoyalty){
      ++blueLoyalty;
    }
    else if(teamNum != game.blueTeamNum){
      switchToTeam(game.blueTeamNum);
    }
    else{
      //do nothing, we're already on the blue team and don't need to gain loyalty
    }
  }
}


event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
  Super.TakeDamage(DamageAmount, EventInstigator,  HitLocation,  Momentum, DamageType, HitInfo, DamageCauser);
  if(damageAmount > 0){
    HostageController(Controller).pawnImThinkingAbout = EventInstigator.Pawn;
    HostageController(Controller).GoToState('Fleeing');
  }
}





defaultproperties 
{
 Begin Object Name=CollisionCylinder
        //is 40 by default, we could half it to match a drawscale of 0.5
        CollisionHeight= 32
    End Object


 redLoyalty = 0
 blueLoyalty = 0
 maxLoyalty = 20
 teamNum = 255

 sightRadius = 1400;
}
