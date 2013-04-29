class CaptorController extends UTPlayerController;

var class<UTFamilyInfo> CharacterClass; 
var MaterialInterface defaultMaterial0; //for some reason necessary for setting the materials later even though I don't ever define what the defaultMaterial0 is

var SoundCue wardVoice;
var SoundCue mineVoice;
var SoundCue sentryVoice;
var SoundCue startVoice;

simulated event PostBeginPlay()
{

 	`log("CAPTOR CONTROLLER ON-LINE");
     super.PostBeginPlay();
   
}

simulated event Possess(Pawn inPawn, bool bVehicleTransition)
{
	local int i;

	Super.Possess(inPawn, bVehicleTransition);
	
	//Set the pawn that CaptorController is controlling to look like a human
	inPawn.Mesh.SetSkeletalMesh(SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA');


	
	//A lot of textures are missing if we don't do this step
	//but it functions the same and looks like a crappy human


	for( i= 0; i < inPawn.Mesh.SkeletalMesh.Materials.length; i++){
		inPawn.Mesh.SetMaterial(i,defaultMaterial0);
	}

	CaptorPawn(Pawn).setShTeamNum(1); //Blue
	//start playing
	
	PlaySound (startVoice,,,true,);
	
}


function bool captured(HostagePawn hostageP){
	// alive and same teams
	return ((hostageP.Health > 0) && StockholmPawn(Pawn).sameTeam(hostageP));
}

exec function CreateWard()
{
	/*local vector loc, norm, end;
	local TraceHitInfo hitInfo;
	local Actor traceHit;
	local HostagePawn target;
	`log("Trying to create a ward");
	`log("Pawn has "$CaptorPawn(Pawn).WardPickups$" ward pickups");
	if(CaptorPawn(Pawn).WardPickups > 0)
	{
		//`log(Pawn.Location$" and "$vector(Rotation));
		//end = Location + normal(vector(Rotation));
		end = Location + vector(Rotation)*10000;
		//`log(end);
		traceHit = trace(loc, norm, end, Pawn.Location, true,, hitInfo);
		if(traceHit == none)
		{
			`log("Hit Nothing");
		}
		else if(traceHit.isA('HostagePawn'))
		{
			`log("Hit a hostage!");
			target = HostagePawn(traceHit);
			//if(Pawn.shTeamNum()==target.shTeamNum()) //Commented for test purposes only!
			//{
				HostageController(target.Controller).GoToWard();
				
				PlaySound (wardVoice,,,true,);
				
				CaptorPawn(Pawn).WardPickups = CaptorPawn(Pawn).WardPickups -1;
			//}
		}
		else
		{
			`log("Missed all hostages");
		}
	}
	else
	{
		`log("Not enough ward pickups");
	}*/
	local HostagePawn hpawn;
	local HostagePawn hostageP;
	local bool isFollowing;
	hpawn = None;
	`log("Trying to create a mine");
	`log("Pawn has "$CaptorPawn(Pawn).WardPickups$" sentry pickups");
	if(CaptorPawn(Pawn).WardPickups > 0)
	{
		foreach WorldInfo.AllPawns(class'HostagePawn', hostageP){
			isFollowing = HostageController(hostageP.Controller).getStateName() == 'Following';

			if(captured(hostageP)&& isFollowing){
				hpawn = hostageP;
			}
		}
		if(hpawn == None)
		{
			`log("No pawns are following you!");
		}
		else
		{
			`log("WardGo!");
			HostageController(hpawn.Controller).GoToWard(LocationImLookingAt());
			PlaySound (wardVoice,,,true,);
			CaptorPawn(Pawn).WardPickups = CaptorPawn(Pawn).WardPickups -1;
		}
	}
	else
	{
		`log("Not enough mine pickups");
	}
	
}

exec function CreateSentry()
{
	/*local vector loc, norm, end;
	local TraceHitInfo hitInfo;
	local Actor traceHit;
	local HostagePawn target;
	`log("Trying to create a sentry");
	`log("Pawn has "$CaptorPawn(Pawn).SentryPickups$" sentry pickups");
	if(CaptorPawn(Pawn).SentryPickups > 0)
	{
		//`log(Pawn.Location$" and "$vector(Rotation));
		//end = Location + normal(vector(Rotation));
		end = Location + vector(Rotation)*10000;
		//`log(end);
		traceHit = trace(loc, norm, end, Pawn.Location, true,, hitInfo);
		if(traceHit == none)
		{
			`log("Hit Nothing");
		}
		else if(traceHit.isA('HostagePawn'))
		{
			`log("Hit a hostage!");
			target = HostagePawn(traceHit);
			//if(Pawn.shTeamNum()==target.shTeamNum()) //Commented for test purposes only!
			//{
				HostageController(target.Controller).GoToSentry();
				
				PlaySound (sentryVoice,,,true,);
				
				CaptorPawn(Pawn).SentryPickups = CaptorPawn(Pawn).SentryPickups -1;
			//}
		}
		else
		{
			`log("Missed all hostages");
		}
	}
	else
	{
		`log("Not enough sentry pickups");
	}*/
	local HostagePawn hpawn;
	local HostagePawn hostageP;
	local bool isFollowing;
	hpawn = None;
	`log("Trying to create a mine");
	`log("Pawn has "$CaptorPawn(Pawn).SentryPickups$" sentry pickups");
	if(CaptorPawn(Pawn).SentryPickups > 0)
	{
		foreach WorldInfo.AllPawns(class'HostagePawn', hostageP){
			isFollowing = HostageController(hostageP.Controller).getStateName() == 'Following';

			if(captured(hostageP)&& isFollowing){
				hpawn = hostageP;
			}
		}
		if(hpawn == None)
		{
			`log("No pawns are following you!");
		}
		else
		{
			`log("SentryGo!");
			HostageController(hpawn.Controller).GoToSentry(LocationImLookingAt());
			PlaySound (sentryVoice,,,true,);
			CaptorPawn(Pawn).SentryPickups = CaptorPawn(Pawn).SentryPickups -1;
		}
	}
	else
	{
		`log("Not enough mine pickups");
	}
}

exec function CreateMine()
{
	/*local vector loc, norm, end;
	local TraceHitInfo hitInfo;
	local Actor traceHit;
	local HostagePawn target;
	`log("Trying to create a mine");
	`log("Pawn has "$CaptorPawn(Pawn).MinePickups$" mine pickups");
	if(CaptorPawn(Pawn).MinePickups > 0)
	{
		//`log(Pawn.Location$" and "$vector(Rotation));
		//end = Location + normal(vector(Rotation));
		end = Location + vector(Rotation)*10000;
		//`log(end);
		traceHit = trace(loc, norm, end, Pawn.Location, true,, hitInfo);
		if(traceHit == none)
		{
			`log("Hit Nothing");
		}
		else if(traceHit.isA('HostagePawn'))
		{
			`log("Hit a hostage!");
			target = HostagePawn(traceHit);
			//if(Pawn.shTeamNum()==target.shTeamNum()) //Commented for test purposes only!
			//{
				HostageController(target.Controller).GoToRemoteMine();
				
				PlaySound (mineVoice,,,true,);
				
				CaptorPawn(Pawn).MinePickups = CaptorPawn(Pawn).MinePickups -1;
			//}
		}
		else
		{
			`log("Missed all hostages");
		}
	}
	else
	{
		`log("Not enough mine pickups");
	}*/
	local HostagePawn hpawn;
	local HostagePawn hostageP;
	local bool isFollowing;
	hpawn = None;
	`log("Trying to create a mine");
	`log("Pawn has "$CaptorPawn(Pawn).MinePickups$" mine pickups");
	if(CaptorPawn(Pawn).MinePickups > 0)
	{
		foreach WorldInfo.AllPawns(class'HostagePawn', hostageP){
			isFollowing = HostageController(hostageP.Controller).getStateName() == 'Following';

			if(captured(hostageP)&& isFollowing){
				hpawn = hostageP;
			}
		}
		if(hpawn == None)
		{
			`log("No pawns are following you!");
		}
		else
		{
			`log("RemoteMineGo!");
			HostageController(hpawn.Controller).GoToRemoteMine();
			PlaySound (mineVoice,,,true,);
			CaptorPawn(Pawn).MinePickups = CaptorPawn(Pawn).MinePickups -1;
		}
	}
	else
	{
		`log("Not enough mine pickups");
	}
}

exec function SendHostageHome(){
	local HostagePawn hostageP;
	local bool isGoingHome;
	foreach WorldInfo.AllPawns(class'HostagePawn', hostageP){
			isGoingHome = HostageController(hostageP.Controller).getStateName() == 'GoingHome';
			if(captured(hostageP) && !isGoingHome){
				HostageController(hostageP.Controller).GoHome();
				return;
			}
	}
}

exec function FollowMe(){
	local HostagePawn hostageP;
	local bool isFollowing;
	StockholmGame(WorldInfo.Game).dispHostageNums();
	StockholmGame(WorldInfo.Game).dispBaseHostageNums();
	foreach WorldInfo.AllPawns(class'HostagePawn', hostageP){
		isFollowing = HostageController(hostageP.Controller).getStateName() == 'Following';

		if(captured(hostageP)&& !isFollowing){
			HostageController(hostageP.Controller).followCaptor();
			return;
		}
		
	}
}
//////////////////////////////////////////////CHRIS///////////////////////////////////

function Vector LocationImLookingAt(){
		local vector loc, norm, end;
	local TraceHitInfo hitInfo;
	local Actor traceHit;
	local Vector viewPosition;
	local Rotator viewRotation;

	WorldInfo.Game.Broadcast(self,"looking at...");

	GetPlayerViewPoint(viewPosition,viewRotation);

	end = Pawn.Location + normal(vector(viewRotation))*10000; // trace to 'infinity'
	traceHit = trace(loc, norm, end, viewPosition, true,, hitInfo);

	WorldInfo.Game.Broadcast(self,"looking at "$tracehit);
	return loc;
}

//////////////////////////////////////////////////////////////////////////////////////



simulated function byte shTeamNum(){
  return CaptorPawn(Pawn).shteamNum();
}

function debug(String s){
	WorldInfo.Game.Broadcast(self,s);
}

defaultproperties
{
	
	startVoice = SoundCue'Stockholm_Sounds.Start1_Cue';
	wardVoice = SoundCue'Stockholm_Sounds.Ward1_Cue';
	sentryVoice = SoundCue'Stockholm_Sounds.Turret1_Cue';
	mineVoice = SoundCue'Stockholm_Sounds.RemoteDetonator_Cue';
  //Points to the UTFamilyInfo class for your custom character
  CharacterClass=class'UTFamilyInfo_Liandri_Male'
}