class StockholmGame extends UTDeathMatch
config(StockholmGame);

var byte redTeamNum;
var byte blueTeamNum;
var byte neutralTeamNum;

var int redHostages;
var int blueHostages;
var int neutralHostages;
var int totalHostages;

var int blueBaseHostages;
var int redBaseHostages;


var PathNode PrivateBlueTeamBase;
var PathNode PrivateRedTeamBase;

var bool blueTeamBaseInitialized;
var bool redTeamBaseInitialized;



event PostBeginPlay()
{
	Super.PostBeginPlay();
	WorldInfo.Game.Broadcast(self,"we are playing a game of STOCKHOLM");
	`log("We are playing a game of STOCKHOLM");
	
}
function int hostagesByTeam(byte team_number){
	if(team_number == redTeamNum){
		return redHostages;
	}
	else if(team_number == blueTeamNum){
		return blueHostages;
	}
	else if(team_number == neutralTeamNum){
		return neutralHostages;
	}
	dispHostageNums();
}
function bool teamByNumHasAllHostages(byte team_number){
	return hostagesByTeam(team_number) >= totalHostages;
	dispHostageNums();
}

function enterBase(byte team_number){
	if(team_number == redteamNum){
		redBaseHostages += 1;
	}
	if(team_number == blueTeamNum){
		blueBaseHostages += 1;
	}
}

function leaveBase(byte team_number){
	if(team_number == redteamNum){
		redBaseHostages -= 1;
	}
	if(team_number == blueTeamNum){
		blueBaseHostages -= 1;
	}
}

function killHostage(byte team_number){
	if(team_number == redTeamNum){
		redHostages -=1;
	}
	else if(team_number == blueTeamNum){
		blueHostages -=1;
	}
	else{
		neutralHostages -=1;
	}
	totalHostages -=1;
	dispHostageNums();
}
function string dispHostageNums(){
	local string response;
		response = "Red: "$redHostages$". Blue: "$blueHostages$". Neut: "$neutralHostages$". Total: "$totalHostages;
	//Broadcast(self,response);
	return response;
}
function dispBaseHostageNums(){
	Broadcast(self,"Red Base: "$redBaseHostages$".  Blue Base: "$blueBaseHostages);
}


function PathNode blueTeamBase(){
	local PathNode node;
	if(blueTeamBaseInitialized){
		return PrivateBlueTeamBase;
	}
	foreach AllActors( class 'PathNode', node) { //iterate through PlayerPawns
		if(node.tag == 'blueTeamBase'){
			PrivateBlueTeamBase = node;
			blueTeamBaseInitialized = true;
			return node;
		}
	} 
}
function PathNode redTeamBase(){
	local PathNode node;
	if(redTeamBaseInitialized){
		return PrivateRedTeamBase;
	}
	foreach AllActors( class 'PathNode', node) { //iterate through PlayerPawns
		if(node.tag == 'redTeamBase'){
			PrivateRedTeamBase = node;
			redTeamBaseInitialized = true;
			return node;
		}
	} 
}




function AddDefaultInventory( pawn PlayerPawn )
{
	
	//-may give the physics gun to non-bots
	//PlayerPawn.DefaultInventory = class'none';
	//if(PlayerPawn.IsHumanControlled() )
	if(PlayerPawn.isA('CaptorPawn'))
	{
		PlayerPawn.CreateInventory(class'CaptorGun',true);
		//PlayerPawn.AddDefaultInventory();
	}


	`Log("Adding inventory");
	

}




defaultproperties
{
	bUseClassicHUD = true;
	HUDType=class'Stockholm.StockholmHUD'
	
	DefaultPawnClass = class'CaptorPawn'
	PlayerControllerClass = class'CaptorController'
    

	redTeamNum = 0
 	blueTeamNum = 1
 	neutralTeamNum = 255

 	redHostages = 0
	blueHostages = 0
	neutralHostages = 0
	totalHostages = 0

 	redTeamBaseInitialized = False
 	blueTeamBaseInitialized = False

 	
}