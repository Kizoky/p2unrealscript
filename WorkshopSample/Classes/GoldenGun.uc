///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Mod
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This mod gives the player a golden pistol with infinite ammo that
// instagibs everything.
///////////////////////////////////////////////////////////////////////////////
class GoldenGun extends P2GameMod;

///////////////////////////////////////////////////////////////////////////////
// ModifyPlayerInventory
// Called by the PlayerController after adding default inventory.
// Use this to add/remove items at the start of the game
// This is called only once -- at the very beginning of the game when the player
// gets his starting inventory. Use this to give the player custom weapons,
// powerups, etc., but beware of ammo concerns.
///////////////////////////////////////////////////////////////////////////////
function ModifyPlayerInventory(Pawn Other)
{
	// Add a Golden Gun Weapon to the player's inventory.
	if (P2Pawn(Other) != None)
		P2Pawn(Other).CreateInventory("WorkshopSample.GoldenGunWeapon");	// Use P2Pawn's CreateInventory function to spawn a Golden Gun Weapon.

	// Don't forget to call super!
	Super.ModifyPlayerInventory(Other);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties required by all P2GameMods.
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// GroupName - any Game Mods with the same GroupName will be considered incompatible, and only one will be allowed to run.
	// Use this if you make mods that are not designed to run alongside each other.
	GroupName=""
	// FriendlyName - the name of your Game Mod, displayed in the game mod menu.
	FriendlyName="Golden Gun"
	// Description - optional short description of your Game Mod
	Description="Gives the player a powerful Golden Gun with infinite ammo that instagibs everything."
}