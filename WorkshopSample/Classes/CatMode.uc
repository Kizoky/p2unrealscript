///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Mod
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This mod replaces all Bystander pawns with CatPawns.
///////////////////////////////////////////////////////////////////////////////
class CatMode extends P2GameMod;

var config array<Material> CatSkins;	// Defining a config var allows the user to tweak the mod to their liking in mods.ini.

///////////////////////////////////////////////////////////////////////////////
// CheckReplacement
// This function is called for any actor spawned into the world.
// You can use this function to change any default properties of that actor,
// or replace it entirely with something else using ReplaceWith.
// Return FALSE if you replace the actor or just want it to be destroyed.
// Return TRUE if you want to keep the actor and don't want to replace it.
// Unlike other functions you do NOT need to call Super here.
///////////////////////////////////////////////////////////////////////////////
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local Actor NewActor;

	// Check specifically for class Bystanders.
	// We don't want to get specialized subclasses of Bystanders, like Taliban or RWS pawns or the like.
	if (Other.Class == class'Bystanders')
	{
		// Do a few sanity checks before we actually replace the pawn with a cat.
		// They could be used for an errand, or it might be an enemy/friend of the player.
		// We only want to replace unarmed, unimportant Bystanders.
		if (FPSPawn(Other).bPlayerIsEnemy
			|| FPSPawn(Other).bPlayerIsFriend
			|| FPSPawn(Other).bUseForErrands
			|| ClassIsChildOf(Pawn(Other).ControllerClass, class'CashierController'))
			return true;
			
		// We're positive this is an innocent, unnecessary bystander -- let's replace it with a pawn!
		NewActor = ReplaceActorWith(Other, "People.AWCatPawn");
		
		// Now that we have a cat, let's give it a randomized skin instead of the boring old default skin
		NewActor.Skins[0] = CatSkins[Rand(CatSkins.Length)];
	}
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// GroupName - any Game Mods with the same GroupName will be considered incompatible, and only one will be allowed to run.
	// Use this if you make mods that are not designed to run alongside each other.
	GroupName=""
	// FriendlyName - the name of your Game Mod, displayed in the game mod menu.
	FriendlyName="Cat Mode"
	// Description - optional short description of your Game Mod
	Description="Replaces all bystanders with... cats!"

	// Some default Cat Skins to give our new cats.
	// Feel free to change this in Mods.ini and give them your own custom cat skins.
	CatSkins[0]=Texture'AnimalSkins.Cat_Black'
	CatSkins[1]=Texture'AnimalSkins.Cat_Grey'
	CatSkins[2]=Texture'AnimalSkins.Cat_Orange'
	CatSkins[3]=Texture'AnimalSkins.Cat_Siamese'
}