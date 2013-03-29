class RemoteMinePawn extends UTPawn; 

var int redLoyalty;
var int blueLoyalty;
var int maxLoyalty;

var byte redTeamNum;
var byte blueTeamNum;
var byte neutralTeamNum;

var byte teamNum;

var float ElapsedLoyaltyTime;
var float loyaltyRate;

var MaterialInterface defaultMaterial0;


simulated event PostBeginPlay()
{
  setDrawScale(1.0f);
  `log("hello, I'm a bot");
   Super.PostBeginPlay();
}

event Tick(float DeltaTime)
{
  //calculate elapsed time
  ElapsedLoyaltyTime += DeltaTime;
   
  //has enough time elapsed?
  if(ElapsedLoyaltyTime >= loyaltyRate)
  {
  	receivePersuasion(redTeamNum);
    ElapsedLoyaltyTime = 0.0f;
  }
}


simulated function receivePersuasion(byte team_number){
	
	increaseLoyalty(team_number);

	`log("My team loyalties- red: "$redLoyalty$".  blue: "$blueLoyalty);
}
simulated function switchToTeam(byte team_number){
	local int i;
	local int r;


	if(team_number == redTeamNum){
		`log("I've switched to the red team.");
		teamNum = redTeamNum;
		 Mesh.SetMaterial(0,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_VRed');
 		 Mesh.SetMaterial(1,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_VRed');

	}

	if(team_number == blueTeamNum){
		`log("I've switched to the blue team");
		teamNum = blueTeamNum;
		 Mesh.SetMaterial(0,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_VBlue');
 	     Mesh.SetMaterial(1,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_VBlue');

	}

	if(team_number == neutralTeamNum){
		`log("I've switched to the neutral team");
		teamNum = neutralTeamNum;
		 Mesh.SetMaterial(0,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_V01');
 	     Mesh.SetMaterial(1,MaterialInstanceConstant'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_V01');

	}

	
}
simulated function shotBy(Pawn antagonist){
	if(antagonist.isA('CaptorPawn')){
		setDrawScale(0.5f + (blueLoyalty / 10.0f));
		`log("i got shot by a captor!");
	}
}




simulated function increaseLoyalty(byte team_number){


	if(team_number == redTeamNum){
		if(blueLoyalty > 0){
			--blueLoyalty;
			if(blueLoyalty == 0){
				switchToTeam(neutralTeamNum);
			}
		}
		else if(redLoyalty < maxLoyalty){
			++redLoyalty;
		}
		else if(teamNum != redTeamNum){
			switchToTeam(redTeamNum);
		}
		else{
			//do nothing, we're already on the red team and don't need to gain loyalty
		}
	}

	if(team_number == blueTeamNum){
		if(redLoyalty > 0){
			--redLoyalty;
			if(redLoyalty == 0){
				switchToTeam(neutralTeamNum);
			}
		}
		else if(blueLoyalty < maxLoyalty){
			++blueLoyalty;
		}
		else if(teamNum != blueTeamNum){
			switchToTeam(blueTeamNum);
		}
		else{
			//do nothing, we're already on the blue team and don't need to gain loyalty
		}
	}
}

simulated function byte getTeamNum(){
	return teamNum;
}

defaultproperties 
{
 Begin Object Name=CollisionCylinder
        //is 40 by default, we half it to match the drawscale of 0.5
        CollisionHeight= 40
    End Object

 redLoyalty = 0
 blueLoyalty = 0
 maxLoyalty = 20
 redTeamNum = 0
 blueTeamNum = 1
 neutralTeamNum = 255
 teamNum = 255
 loyaltyRate = 2.0f

}
