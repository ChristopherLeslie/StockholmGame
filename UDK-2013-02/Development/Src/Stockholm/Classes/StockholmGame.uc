class StockholmGame extends UTDeathMatch;

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


var PathNode privateBlueTeamPen;
var PathNode privateRedTeamPen;

var bool blueTeamPenInitialized;
var bool redTeamPenInitialized;



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
function dispHostageNums(){
	Broadcast(self,"Red: "$redHostages$". Blue: "$blueHostages$". Neut: "$neutralHostages$". Total: "$totalHostages);
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

function PathNode baseByTeam(byte the_team_num){
	if(the_team_num == redTeamNum){
		return redTeamBase();
	}
	if(the_team_num == blueTeamNum){
		return blueTeamBase();
	}
}
function PathNode blueTeamPen(){
	local PathNode node;
	if(blueTeamPenInitialized){
		return PrivateBlueTeamPen;
	}
	foreach AllActors( class 'PathNode', node) { //iterate through PlayerPawns
		if(node.tag == 'bluePen'){
			PrivateBlueTeamPen = node;
			blueTeamPenInitialized = true;
			return node;
		}
	} 
}

function PathNode redTeamPen(){
	local PathNode node;
	if(redTeamPenInitialized){
		return PrivateRedTeamPen;
	}
	foreach AllActors( class 'PathNode', node) { //iterate through PlayerPawns
		if(node.tag == 'redPen'){
			PrivateredTeamPen = node;
			redTeamPenInitialized = true;
			return node;
		}
	} 
}

function PathNode penByTeam(byte the_team_num){
	if(the_team_num == redTeamNum){
		return redTeamPen();
	}
	if(the_team_num == blueTeamNum){
		return blueTeamPen();
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

 	//bUseClassicHUD = true;
}