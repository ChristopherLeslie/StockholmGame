class StockholmGame extends UTDeathMatch;

var byte redTeamNum;
var byte blueTeamNum;
var byte neutralTeamNum;

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
	local int i;
	//-may give the physics gun to non-bots
	//PlayerPawn.DefaultInventory = class'none';
	//if(PlayerPawn.IsHumanControlled() )
	if(PlayerPawn.isA('CaptorPawn'))
	{
		PlayerPawn.CreateInventory(class'CaptorGun',true);
		PlayerPawn.AddDefaultInventory();
	}
/*
	for (i=0; i<DefaultInventory.Length; i++)
	{
		//-Ensure we don't give duplicate items
		if (PlayerPawn.FindInventoryType( DefaultInventory[i] ) == None)
		{
			//-Only activate the first weapon
			PlayerPawn.CreateInventory(DefaultInventory[i], (i > 0));
		}

	}
*/
	`Log("Adding inventory");
	

}




defaultproperties
{
	DefaultPawnClass = class'CaptorPawn'
	PlayerControllerClass = class'CaptorController'

	redTeamNum = 0
 	blueTeamNum = 1
 	neutralTeamNum = 255

 	redTeamBaseInitialized = False
 	blueTeamBaseInitialized = False
}