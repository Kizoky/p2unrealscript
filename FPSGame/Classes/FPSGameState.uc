///////////////////////////////////////////////////////////////////////////////
// FPSGameState.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Special inventory item that stores persistent game information.
//
// History:
//	07/09/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
//
// This base class exists only so classes in other packages can use the
// structs defined here.  See GameState for the real deal.
//
///////////////////////////////////////////////////////////////////////////////
class FPSGameState extends Inventory;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

// Data for persistent pawns
struct PersistentPawnInfo
	{
	var String		LevelName;			// Level the pawn is located on
	var Name		Tag;				// Unique tag used to find the pawn
	var Material    Skin;				// My own skin that I was placed with in the level and must save as I travel
										// (probably just for cats)
	};

// Data for persistent weapons (P2WeaponPickups)
struct PersistentWeaponInfo
	{
	// We handle this stuff
	var String		LevelName;			// Level the pawn is located on
	// Object handles this stuff
	var String		ClassName;
	var Name		Tag;
	var Vector		Location;
	var Rotator		Rotation;
	var int			AmmoGiveCount;
	};

// Data for persistent pickups (P2PowerupPickups)
struct PersistentPowerupInfo
	{
	// We handle this stuff
	var String		LevelName;			// Level the pawn is located on
	// Object handles this stuff
	var String		ClassName;
	var Name		Tag;
	var Vector		Location;
	var Rotator		Rotation;
	var float		AmountToAdd;
	var StaticMesh  StaticMesh;			// My own mesh that I was placed with in the level and must save as I travel
										// (probably just for donuts)
	};

// Data for teleporting pawns with player
struct TeleportedPawnInfo
	{
	var String		ClassName;
	var Name		Tag;
	var vector		Offset;
	var bool		bPlayerIsEnemy;
	var bool		bPlayerIsFriend;
	var bool		bPlayerIsHero;
	var bool		bPersistent;
	var int			Health;
	var Material	CurrentSkin;
	var Mesh		CurrentMesh;
	var Material 	HeadSkin;
	var Mesh		HeadMesh;
	var class<FPSDialog> DialogClass;
	var float		FloatVal1;	// Generic across pawns.. each class uses interprets it's differently in
	var float		FloatVal2;	// their version of LambController::PreTeleportWithPlayer.
	//var byte		UsingLinkpad;	// non-zero if you used a linkpad and need the other linkpad to offset from
	var string		OrigLevelName;	// Original level we came from (since we're travelling around and all)
	};

// Unique data across the whole game for each pickup
struct RecordedPickupInfo
	{
	var String		LevelName;			// Level the pickup is located on
	var name		PickupName;			// Unique pickup recorded
	};


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
DefaultProperties
	{
	}
