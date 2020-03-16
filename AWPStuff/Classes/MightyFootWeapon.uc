///////////////////////////////////////////////////////////////////////////////
// FootWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Foot weapon (first and third person).
//
// Gets used when you kick
//
// This weapon is SEPERATE from the player's normal inventory. It's in 
// P2Pawn::MyFoot and thus must be handled seperately. 
//
// It is only to be visible during it's fire (the kick) and is handled
// seperately in P2Hud. 
//
// It is like this so that the player can kick with any other weapon and 
// at mostly any time.
//
///////////////////////////////////////////////////////////////////////////////

class MightyFootWeapon extends FootWeapon;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	AmmoName=class'MightyFootAmmoInv'
	WeaponSpeedHolster = 10
	WeaponSpeedLoad    = 10
	WeaponSpeedReload  = 10
	WeaponSpeedShoot1  = 10
	WeaponSpeedShoot1Rand=0.3
	WeaponSpeedShoot2  = 10
//	FireSound=Sound'AW7Sounds.MightyFoot.swish'
	}
