///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Mod
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This mod doubles the walking speed of all bystanders.
///////////////////////////////////////////////////////////////////////////////
class FastBystanders extends P2GameMod;

var config float SpeedMult;				// Defining a config var allows the user to tweak the mod to their liking in mods.ini.

///////////////////////////////////////////////////////////////////////////////
// ModifyNPC
// Called by PersonController after adding default inventory.
// Use this function to alter any aspect of the NPC you like.
// Note that there is no ModifyNPCInventory -- if you want to mess with
// their inventory, you do it here.
///////////////////////////////////////////////////////////////////////////////
function ModifyNPC(Pawn Other)
{
	Other.GroundSpeed *= SpeedMult;		// Multiplies the pawn's ground speed by the defined variable (defaults to 2.0).
	Super.ModifyNPC(Other);				// Don't forget to call Super or you could break the mod chain.
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
	FriendlyName="Fast Bystanders"
	// Description - optional short description of your Game Mod
	Description="Increases the walking speed of all bystanders."
	
	// SpeedMult - defined above as a config variable. By default, we'll have it double NPC speed.
	SpeedMult=2.0
}