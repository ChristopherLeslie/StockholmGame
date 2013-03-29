class CaptorController extends UTPlayerController;

var class<UTFamilyInfo> CharacterClass; 
var MaterialInterface defaultMaterial0; //for some reason necessary for setting the materials later even though I don't ever define what the defaultMaterial0 is

var byte teamNum;

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

}



simulated function byte getTeamNum(){
  return teamNum;
}


defaultproperties
{
  //Points to the UTFamilyInfo class for your custom character
  CharacterClass=class'UTFamilyInfo_Liandri_Male'
  teamNum = 1; //blue
}