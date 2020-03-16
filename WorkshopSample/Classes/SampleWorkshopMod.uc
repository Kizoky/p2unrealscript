///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Mod
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This mod does not actually do anything, it only explains the functions.
// For example of a mod that actually does something, see the other mods in
// this folder.
//
// For all functions remember to call the SUPER function or you will break
// the game if multiple mods are in use!
//
// Another important note: P2GameMods do not survive the "travel" process
// between load zones. If you need to preserve data between level changes,
// try storing data in a config variable, or create a data-holding Inventory
// item you can give to the player before the travel process, then take back
// and read the data after the travel.
///////////////////////////////////////////////////////////////////////////////
class SampleWorkshopMod extends P2GameMod;

///////////////////////////////////////////////////////////////////////////////
// MutatorIsAllowed
// Lets you check for arbitrary conditions under which this mod should
// not be allowed to run.
///////////////////////////////////////////////////////////////////////////////
function bool MutatorIsAllowed()
{
	return Super.MutatorIsAllowed();
}

///////////////////////////////////////////////////////////////////////////////
// ModifyPlayer
// Called by the PlayerController after traveling.
// Do not add inventory here -- that is defined in another function
// You can also use this function to do anything that needs to be done
// after the player travels to another map.
///////////////////////////////////////////////////////////////////////////////
function ModifyPlayer(Pawn Other)
{
	Super.ModifyPlayer(Other);
}

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
	Super.ModifyPlayerInventory(Other);
}

///////////////////////////////////////////////////////////////////////////////
// ModifyAppearance
// Called by P2Pawn/AnimalPawn just before initial setup.
// This function is the very first thing called by any "person" in the world
// If you want to screw with their appearance, this is the place to do it.
// You can also use this function to replace controller classes.
///////////////////////////////////////////////////////////////////////////////
function ModifyAppearance(Pawn Other)
{
	Super.ModifyAppearance(Other);
}

///////////////////////////////////////////////////////////////////////////////
// ModifyNPC
// Called by PersonController/AnimalController after adding default inventory.
// Use this function to alter any aspect of the NPC you like.
// This function is called AFTER ModifyAppearance -- at this point, the pawn
// is all set up with head, skins, dialog, default inventory, and so on.
// If you want to change things before the pawn is set up, use ModifyAppearance.
// Note that there is no ModifyNPCInventory -- if you want to mess with
// their inventory, you do it here.
// This function works on most people and animals!
///////////////////////////////////////////////////////////////////////////////
function ModifyNPC(Pawn Other)
{
	Super.ModifyNPC(Other);
}

///////////////////////////////////////////////////////////////////////////////
// GetInventoryClassOverride
// Allows you to swap out inventory items before they're spawned.
// Warning - may not work on all inventory items all the time.
///////////////////////////////////////////////////////////////////////////////
function string GetInventoryClassOverride(string InventoryClassName)
{
	// here, in mutator subclass, change InventoryClassName if desired.  For example:
	// if ( InventoryClassName == "Weapons.DorkyDefaultWeapon"
	//		InventoryClassName = "ModWeapons.SuperDisintegrator"

	return Super.GetInventoryClassOverride(InventoryClassName);
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
	Super.PreTravel(Player, MapName, TelepadName, bMaybePawnless);
}

///////////////////////////////////////////////////////////////////////////////
// PostTravel
// Called after the player spawns on a new map.
// Unlike PreTravel, this just has one parameter, the P2Pawn of the player.
//
// If you need to create a data-holding Inventory item to send with the player,
// this is the part where you take it from him and read in the stored data.
///////////////////////////////////////////////////////////////////////////////
function PostTravel(P2Pawn PlayerPawn)
{
	Super.PostTravel(PlayerPawn);
}

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
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Mutate
// Using this function you can create new console commands for the player to
// use to control your mod.
// The actual command typed by the player is "mutate (whatever)", and the Mutate
// function gives you the "(whatever)" part as a String, it is your job to parse
// this string to find your command and react to it accordingly.
// For a real-world example, see PsychoBystanders.uc
///////////////////////////////////////////////////////////////////////////////
function Mutate(string Params, PlayerController Sender)
{
	Super.Mutate(Params, Sender);
}

///////////////////////////////////////////////////////////////////////////////
// ReplaceActorWith
// Forces the game to replace an actor "Other" with an actor of "aClassName".
// If successful, returns an Actor reference to the newly-spawned actor.
// Otherwise, it returns NONE.
//
// final function Actor ReplaceActorWith(actor Other, string aClassName)
//
// Example:
// ReturnedActor = ReplaceActorWith(ActorToDelete, "MyPackage.AwesomeReplacementActor");
//
// For a real-world example, see CatMode.uc
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Default properties required by all P2GameMods.
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// GroupName - any Game Mods with the same GroupName will be considered incompatible, and only one will be allowed to run.
	// Use this if you make mods that are not designed to run alongside each other.
	GroupName=""
	// FriendlyName - the name of your Game Mod, displayed in the game mod menu.
	FriendlyName="Sample Workshop Mod"
	// Description - optional short description of your Game Mod
	Description="An example of how to do various things with P2GameMod."
}