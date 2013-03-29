class CurrentGame_CaptorController extends UTPlayerController;

var class<UTFamilyInfo> CharacterClass;
var MaterialInterface defaultMaterial0; //for some reason necessary for setting the materials later even though I don't ever define what the defaultMaterial0 is

simulated event PostBeginPlay()
{

 	`log("hello, i'm a player ");
  super.PostBeginPlay();
   
  SetupPlayerCharacter();
}

simulated event Possess(Pawn inPawn, bool bVehicleTransition)
{
	local int i;

	Super.Possess(inPawn, bVehicleTransition);
	
	//Set the pawn that CurrentGame_CaptorController is controlling to look like a human
	inPawn.Mesh.SetSkeletalMesh(SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA');
	//A lot of textures are missing if we don't do this step
	//but it functions the same and looks like a crappy human
	for( i= 0; i < inPawn.Mesh.SkeletalMesh.Materials.length; i++){
		inPawn.Mesh.SetMaterial(i,defaultMaterial0);
	}

}

/** Set player's character info class & perform any other initialization */
function SetupPlayerCharacter()
{
  //Set character to our custom character
  ServerSetCharacterClass(CharacterClass);
}

defaultproperties
{
  //Points to the UTFamilyInfo class for your custom character
  CharacterClass=class'UTFamilyInfo_Liandri_Male'

}