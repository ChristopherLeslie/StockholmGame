class StockholmGame extends UTDeathMatch
config(StockholmGame);

var byte redTeamNum;
var byte blueTeamNum;
var byte neutralTeamNum;
var byte nobodyTeamNum;
var byte winner;

var bool gameOver;

var int redHostages;
var int blueHostages;
var int neutralHostages;
var int liveHostages;
var int deadHostages;

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

var int privatecurrentTime;

var SoundCue winVoice;
var SoundCue loseVoice;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	WorldInfo.Game.Broadcast(self,"we are playing a game of STOCKHOLM");
	`log("We are playing a game of STOCKHOLM");
	privatecurrentTime = 240;
}

function myGameStart(){
	setTimer(1,true,'timePasses');
}


function int currentTime(){
	return privatecurrentTime;
}

function timePasses(){
	privatecurrentTime--;
	if(privateCurrentTime <= 0 && !gameOver){
		GameEnd();
	}
}



function byte whosWinning(){
	if(blueBaseHostages > redBaseHostages){
		return blueTeamNum;
	}
	if(redBaseHostages > blueBaseHostages){
		return redTeamNum;
	}

	return nobodyTeamNum;
}

function byte whoWon(){
	if(blueBaseHostages > (liveHostages+deadHostages)/2){
		return blueTeamNum;
	}
	if(redBaseHostages > (liveHostages+deadHostages)/2){
		return redTeamNum;
	}

	return nobodyTeamNum;
}

function GameEnd(){
	local CaptorPawn cp;
	Local CaptorController cc;
		cc = CaptorController(getalocalplayercontroller());
		cp = CaptorPawn(cc.Pawn);
		cc.GoToState('BaseSpectating');
		cp.Groundspeed = 0;
		cp.Velocity = VRAND()*0;

		cc.SetBehindView(true);
        cp.SetMeshVisibility(cc.bBehindView);
		


	setTimer(6,false,'restartTheWholeShabang');
	setTimer(3, false, 'explodeEveryone');
	
	if(whosWinning() == blueTeamNum){
		BlueTeamWin();
		return;
	}
	if(whosWinning() == redTeamNum){
		RedTeamWin();
		return;
	}
	
	NobodyWin();

}
function restartTheWholeShabang(){
	Broadcast(self,"restart");

	//ConsoleCommand("RestartLevel");
	ConsoleCommand("Servertravel?Restart");
}
function explodeEveryone(){

	local Pawn poorSoul;
	local bool youDie;
	local bool ragdoll;
		Broadcast(self,"explode");


	youDie = false;
	ragdoll = false;

	if(winner == redTeamNum){
		youDie = true;
	}
	if(winner == nobodyTeamNum){
		ragdoll = true;
	}

	if(ragdoll){
		foreach WorldInfo.AllPawns(class'Pawn', poorSoul){
			
				poorSoul.Gasp();
				UTPawn(poorSoul).forceRagdoll();
			

	    }
	}
	else{
		foreach WorldInfo.AllPawns(class'Pawn', poorSoul){
			if(poorSoul.Controller.isA('PlayerController')){
				if(youDie){
					poorSoul.gibbedBy(poorSoul);
				}
				else{
					UTPawn(poorSoul).setBigHead();
					UTPawn(poorSoul).PlayVictoryAnimation();
				}
			}
			else{
				poorSoul.Gasp();
				poorSoul.gibbedBy(GetALocalPlayerController());
			}

	    }
    }
}

function BlueTeamWin(){
	setwinner(blueTeamNum);
	gameOver = true;
	PlaySound (winVoice);
}
function RedTeamWin(){
	setwinner(redTeamNum);
	gameOver = true;
	PlaySound (loseVoice);
}
function NobodyWin(){
	setwinner(nobodyTeamNum);
	gameOver = true;
}


function setWinner(byte team_num){
	if(!gameOver){
		winner = team_num;
	}
}









function int hostagesByTeam(byte team_number){//0 is red, 1 is blue
	if(team_number == redTeamNum){
		return redHostages;
	}
	else if(team_number == blueTeamNum){
		return blueHostages;
	}
	else if(team_number == neutralTeamNum){
		return neutralHostages;
	}
}


function bool teamByNumHasAllHostages(byte team_number){
	return hostagesByTeam(team_number) >= liveHostages;
}

function int capturableHostagesForTeam(byte team_number){
	if(team_number == blueTeamNum){
		return hostagesByTeam(redTeamNum) - redBaseHostages + hostagesByTeam(neutralTeamNum);
	}
	if(team_number == redTeamNum){
		return hostagesByTeam(blueTeamNum) - blueBaseHostages + hostagesByTeam(neutralTeamNum);
	}
}

function enterBase(byte team_number){
	if(team_number == redteamNum){
		redBaseHostages += 1;
	}
	if(team_number == blueTeamNum){
		blueBaseHostages += 1;
	}
	if(whoWon() != nobodyTeamNum){
		GameEnd();
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
	liveHostages -=1;
	deadHostages +=1;
	dispHostageNums();
}
function addHostage(){
	liveHostages++;
	neutralHostages++;
}
function string dispHostageNums(){
	local string response;
		response = "Red: "$redBaseHostages$". Blue: "$blueBaseHostages$". Neut: "$neutralHostages$". Total: "$liveHostages;
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
	bUseClassicHUD = true;
	HUDType=class'Stockholm.StockholmHUD'
	
	DefaultPawnClass = class'CaptorPawn'
	PlayerControllerClass = class'CaptorController'
    
	winVoice = SoundCue'Stockholm_Sounds.AnnouncementWon_Cue';
	loseVoice = SoundCue'Stockholm_Sounds.AnnouncementLost_Cue';

	redTeamNum = 0
 	blueTeamNum = 1
 	neutralTeamNum = 255
 	nobodyTeamNum = 3


 	redHostages = 0
	blueHostages = 0
	neutralHostages = 0
	liveHostages = 0
	deadHostages = 0

 	redTeamBaseInitialized = False
 	blueTeamBaseInitialized = False

}