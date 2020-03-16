///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Mod
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This mod restores the School map from AW7 by using the PreTravel function
// to redirect the player to a modified version of the Chicken Queen Estates
// map.
//
// It does NOT change the map or the voting errand (though you can complete
// the voting errand at the school like in AW7) -- to do this, we'll need
// to make a new GameInfo class too.
///////////////////////////////////////////////////////////////////////////////
class AW7School extends P2GameMod;

///////////////////////////////////////////////////////////////////////////////
// MutatorIsAllowed
// Lets you check for arbitrary conditions under which this mod should
// not be allowed to run.
///////////////////////////////////////////////////////////////////////////////
function bool MutatorIsAllowed()
{
	// Not designed for Apocalypse Weekend.
	
	return Level.Game.Class != class'AWGameSPFinal';
}

///////////////////////////////////////////////////////////////////////////////
// PreTravel
// Called before sending the player to another map.
// Four parameters are passed in to this function, two of which are also
// passed back out.
//	PlayerController Player - The playercontroller of the player (duh)
//	out string MapName - Name of the map the player is going to. If changed,
//		you can redirect where the player is sent. Useful for remapping
//		exits of stock maps to send the Dude to a modified map.
//	out string TelepadName - Name of the destination telepad. If changed, you
//		can redirect which telepad the player is dumped at. Useful for remapping
//		exits of stock maps.
//	bool bMaybePawnless - If true, the player might not have a pawn. Use caution.
//
// If you need to create a data-holding Inventory item to send with the player,
// this is the part where you give it to him.
///////////////////////////////////////////////////////////////////////////////
function PreTravel(PlayerController Player, out string MapName, out string TelepadName, bool bMaybePawnless)
{
	// Redirect all exits to the Estates and have them put the player into our replacement Estates map.
	// We don't need to check TelepadName, just the MapName -- the replacement map has all the same
	// telepads.
	if (MapName ~= "Estates")
		MapName = "AW7S-Estates";

	// Don't forget to call Super!
	Super.PreTravel(Player, MapName, TelepadName, bMaybePawnless);
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
	FriendlyName="AW7 School"
	// Description - optional short description of your Game Mod
	Description="Restores the AW7 School map in POSTAL 2 or A Week In Paradise."
}