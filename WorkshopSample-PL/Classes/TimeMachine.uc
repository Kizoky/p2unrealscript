///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Mod
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This mod grants the player a Time Machine item which they can use to travel
// between Paradise Lost and POSTAL 2.
///////////////////////////////////////////////////////////////////////////////
class TimeMachine extends P2GameMod;

var() String TimeMachineClassName;	// Class of inventory to give to the player

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
		P2Pawn(Other).CreateInventory(TimeMachineClassName);	// Use P2Pawn's CreateInventory function to spawn a Time Machine.

	// Don't forget to call super!
	Super.ModifyPlayerInventory(Other);
}

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
// Here you can do any "general" stuff not related to any of the GameMod-specific
// functions. It gets called every time the player changes levels.
// The reason we're overriding this function here is because in PLGameInfo
// we don't exclude the "DEMO" group. This causes problems if the player time
// travels back to Suburbs-3 or Police, and they'll see DayBlockers advising
// them to "BUY THE FULL VERSION MONKEY BOY" and we don't want them to run
// into that. Basically this goes through and destroys any actors that are
// "demo-only". (At one point the P2 demo gave you access to both Suburbs-3
// and Suburbs-1, in a later build they were consolidated into a single "demo"
// map, but these demo-only actors were never removed.)
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	local Actor A;

	// Call super first
	Super.PostBeginPlay();
	
	// Go through all actors in the map. This uses ForEach AllActors which is slow, but it also
	// iterates through "static" actors like BlockingVolumes. Normally you want to use DynamicActors.
	foreach AllActors(class'Actor', A)
		if (A.Group == 'Demo')			// If the actor belongs ONLY to the Demo group
			A.Destroy();				// Remove it from play
}

defaultproperties
{
	// GroupName - any Game Mods with the same GroupName will be considered incompatible, and only one will be allowed to run.
	// Use this if you make mods that are not designed to run alongside each other.
	GroupName=""
	// FriendlyName - the name of your Game Mod, displayed in the game mod menu.
	FriendlyName="Time Machine"
	// Description - optional short description of your Game Mod
	Description="(Paradise Lost) Gives you a Time Machine to travel back and forth between the original Paradise and the post-apocalypse Paradise! Best when used with the PL Sandbox or PL Ultimate Sandbox game modes."
	
	TimeMachineClassName="WorkshopSample-PL.TimeMachineInv"
}
