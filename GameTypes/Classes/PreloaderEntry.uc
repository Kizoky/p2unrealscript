///////////////////////////////////////////////////////////////////////////////
// PreLoaderEntry.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// History:
//	10/16/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
//
// This PreLoader is designed to be placed into the Entry map so it can
// preload objects that will be used throughout the entire game.  Anything
// loaded in Entry is never unloaded because Entry itself is never unloaded.
//
///////////////////////////////////////////////////////////////////////////////
class PreLoaderEntry extends PreLoader
	placeable;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// Default properties
//
// Most preloads can be handled here by simply referencing the item.
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	AutoLoads(0)=class'Inventory.BatonWeapon'
//	AutoLoads=class'Inventory.ClipboardWeapon'		// only used in one map
//	AutoLoads=class'Inventory.CowHeadWeapon'		// can't remember why I left this out
	AutoLoads(1)=class'Inventory.FootWeapon'
	AutoLoads(2)=class'Inventory.GasCanWeapon'
	AutoLoads(3)=class'Inventory.GrenadeWeapon'
	AutoLoads(4)=class'Inventory.HandsWeapon'
	AutoLoads(5)=class'Inventory.LauncherWeapon'
	AutoLoads(6)=class'Inventory.MachineGunWeapon'
	AutoLoads(7)=class'Inventory.MatchesWeapon'
	AutoLoads(8)=class'Inventory.MolotovWeapon'
	AutoLoads(9)=class'Inventory.NapalmWeapon'
	AutoLoads(10)=class'Inventory.PistolWeapon'
	AutoLoads(11)=class'Inventory.RifleWeapon'
	AutoLoads(12)=class'Inventory.ScissorsWeapon'
	AutoLoads(13)=class'Inventory.ShotgunWeapon'
	AutoLoads(14)=class'Inventory.ShovelWeapon'
	AutoLoads(15)=class'Inventory.ShockerWeapon'
	AutoLoads(16)=class'Inventory.UrethraWeapon'

	AutoLoads(17)=class'People.DogPawn'
	AutoLoads(18)=class'People.CatPawn'
	}
