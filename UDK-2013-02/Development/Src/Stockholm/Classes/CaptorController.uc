class CaptorController extends UTPlayerController;

var class<UTFamilyInfo> CharacterClass; 
var MaterialInterface defaultMaterial0; //for some reason necessary for setting the materials later even though I don't ever define what the defaultMaterial0 is


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

	CaptorPawn(Pawn).teamNum = 1; //Blue
}

exec function CreateWard()
{
	local vector loc, norm, end;
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
			//if(Pawn.getTeamNum()==target.getTeamNum()) //Commented for test purposes only!
			//{
				HostageController(target.Controller).GoToWard();
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
	}
}

exec function CreateSentry()
{
	local vector loc, norm, end;
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
			//if(Pawn.getTeamNum()==target.getTeamNum()) //Commented for test purposes only!
			//{
				HostageController(target.Controller).GoToSentry();
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
	}
}

exec function CreateMine()
{
	local vector loc, norm, end;
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
			//if(Pawn.getTeamNum()==target.getTeamNum()) //Commented for test purposes only!
			//{
				HostageController(target.Controller).GoToRemoteMine();
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
	}
}



simulated function byte getTeamNum(){
  return CaptorPawn(Pawn).teamNum;
}


defaultproperties
{
  //Points to the UTFamilyInfo class for your custom character
  CharacterClass=class'UTFamilyInfo_Liandri_Male'
}