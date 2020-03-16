///////////////////////////////////////////////////////////////////////////////
// P2GameMod
// Copyright 2014, Running With Scissors
//
// This is the base class for any Workshop game mods.
// Create your new game assets, then use this class to instruct the game on
// how to use them.
// Do not copy and paste this code into your new game mod -- you must
// create a subclass of P2GameMod for your mod to work properly.
// See SampleWorkshopMod for details
///////////////////////////////////////////////////////////////////////////////
class P2GameMod extends Mutator
	config(Mods);
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// MODDER-ACCESSIBLE FUNCTIONS
// Subclass/modify these for mod implementation.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// ModifyPlayerInventory
// Allows modders to give the player extra goodies at the start of a game.
///////////////////////////////////////////////////////////////////////////////
function ModifyPlayerInventory(Pawn Other)
{
	if (NextMutator != None
		&& P2GameMod(NextMutator) != None)
		P2GameMod(NextMutator).ModifyPlayerInventory(Other);
}

///////////////////////////////////////////////////////////////////////////////
// ModifyNPC
// Allows modders to screw with the bystanders.
///////////////////////////////////////////////////////////////////////////////
function ModifyNPC(Pawn Other)
{
	if (NextMutator != None
		&& P2GameMod(NextMutator) != None)
		P2GameMod(NextMutator).ModifyNPC(Other);
}

///////////////////////////////////////////////////////////////////////////////
// ModifyAppearance
// Allows modders to modify pawns before any of the SetupAppearance, etc.
// functions are called.
///////////////////////////////////////////////////////////////////////////////
function ModifyAppearance(Pawn Other)
{
	if (NextMutator != None
		&& P2GameMod(NextMutator) != None)
		P2GameMod(NextMutator).ModifyAppearance(Other);
}

///////////////////////////////////////////////////////////////////////////////
// PreTravel
// Called before sending player to another map.
// Modders can do any last-minute things before traveling, such as storing data
// into an Inventory item to give to the player (and then take back after the travel)
///////////////////////////////////////////////////////////////////////////////
function PreTravel(PlayerController Player, out string MapName, out string TelepadName, bool bMaybePawnless)
{
	if (NextMutator != None
		&& P2GameMod(NextMutator) != None)
		P2GameMod(NextMutator).PreTravel(Player, MapName, TelepadName, bMaybePawnless);
}

///////////////////////////////////////////////////////////////////////////////
// PostTravel
// Called after sending player to another map.
// Modders can do any last-minute things after traveling, such as recovering
// data stored in an Inventory item given to the player.
///////////////////////////////////////////////////////////////////////////////
function PostTravel(P2Pawn PlayerPawn)
{
	if (NextMutator != None
		&& P2GameMod(NextMutator) != None)
		P2GameMod(NextMutator).PostTravel(PlayerPawn);
}

///////////////////////////////////////////////////////////////////////////////
// Mutate
// Allows the modder to create a new executable console command.
///////////////////////////////////////////////////////////////////////////////
function Mutate(string Params, PlayerController Sender)
{
	Super.Mutate(Params, Sender);
}

///////////////////////////////////////////////////////////////////////////////
// GameInfoIsNowValid
// Called when the GameInfo becomes valid, at this point it is safe to check
// GameState etc.
///////////////////////////////////////////////////////////////////////////////
function GameInfoIsNowValid()
{
	if (NextMutator != None
		&& P2GameMod(NextMutator) != None)
		P2GameMod(NextMutator).GameInfoIsNowValid();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// INTERNAL FUNCTIONS
// Should not be subclassed or modified
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// ReplaceActorWith
// Same as ReplaceWith, but now returns a reference to the newly-spawned Actor
// so that we can do stuff with it.
///////////////////////////////////////////////////////////////////////////////
final function Actor ReplaceActorWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	// RWS CHANGE: Merged check for empty class name from UT2003
	if ( aClassName == "" )
		return None;
	if ( Other.IsA('Inventory') && (Other.Location == vect(0,0,0)) )
		return None;
	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);

	// Our pickups don't have markers so ignore this step
	/*
	if ( Other.IsA('Pickup') )
	{
		if ( Pickup(Other).MyMarker != None )
		{
			Pickup(Other).MyMarker.markedItem = Pickup(A);
			if ( Pickup(A) != None )
			{
				Pickup(A).MyMarker = Pickup(Other).MyMarker;
				A.SetLocation(A.Location 
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Pickup(Other).MyMarker = None;
		}
		else if ( A.IsA('Pickup') )
			Pickup(A).Respawntime = 0.0;
	}
	*/

	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return A;
	}
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
// Save any config data into mods.ini, so user can go in and edit it with
// minimal hassle.
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	SaveConfig();
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// SendPlayerTo
// Called before sending the player to a map.
// Do not override this function -- the modder implementation is in PreTravel
// instead.
///////////////////////////////////////////////////////////////////////////////
final function SendPlayerTo(PlayerController Player, out string URL, bool bMaybePawnless)
{
	local int peer,pound;
	local string MapName,TelepadName,BaseURL,temp1,temp2,peerstr;

	// Passed-in URL is the "short" version. Example: "estates#pod3?peer"	
	// What we want to pass on to the modders for change is the map name and the destination Telepad.
	// So for the string above, we actually want to pass on "estates" and "pod3".
	
	// First strip out the "?peer"
	peer = InStr(URL,"?peer");
	if (peer >= 0)
	{
		BaseURL = Left(URL, peer);
	}
	else
		BaseURL = URL;

	// String should now be "mapname#telepadname"
	pound = InStr(BaseURL, "#");
	if (pound >= 0)
	{
		MapName = Left(BaseURL, pound);
		TelepadName = Right(BaseURL, Len(BaseURL) - pound - 1);
	}
	// If no pound sign found, then they didn't specify a telepad, the string is now just the mapname.
	else
		MapName = BaseURL;
	
	//log(self@"SendPlayer to map"@MapName@"telepad"@TelepadName);
	
	// Now see if the mods want to do anything
	PreTravel(Player, MapName, TelepadName, bMaybePawnless);
	
	// Re-assemble the URL based on what the mods did
	// Skip the "?peer" if not provided
	if (peer >= 0)
		peerstr = "?peer";
		
	if (TelepadName != "")
		URL = MapName $ "#" $ TelePadName $ peerstr;
	else
		URL = MapName $ peerstr;
}

defaultproperties
{
	GroupName=""
	FriendlyName="Game Mod"
	Description="Fill me in with something more descriptive."
}