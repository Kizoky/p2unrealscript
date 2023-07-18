///////////////////////////////////////////////////////////////////////////////
// ClipboardAmmoInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Clipboard ammo inventory item (as opposed to pickup).
//
// But we use AmmoAmount to record how many sigs you've gotten and 
// we use MaxAmmo to determine if you've achieved your goal or not.
//
// This used to a 'collection can' so that might explain some references to money and donations
//
///////////////////////////////////////////////////////////////////////////////
class ClipboardAmmoInv extends P2AmmoInv;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	// Skip the 9999 ammo in enhanced mode -- doesn't make sense for the urethra
	Super(Ammunition).PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Keep these from doing anything
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
}
function UseAmmoForShot(optional float UseThisAmmo)
{
}

// Change by Man Chzan: xPatch 2.0
// Dunno why but it's causing weapon to change after using middle finger.
/*
///////////////////////////////////////////////////////////////////////////////
// Doesn't check weapon/ammo readiness, just checks if you have ammo in some
// way or another.
///////////////////////////////////////////////////////////////////////////////
simulated function bool HasAmmoStrict()
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Check to invalidate the hands when you get added, so the clipboard is the
// only hands option
///////////////////////////////////////////////////////////////////////////////

function AddedToPawnInv(Pawn UsePawn, Controller UseCont)
{
	local P2Player p2p;

	// Check to invalidate the hands
	p2p = P2Player(UseCont);
	if(p2p != None)
	{
		if(bReadyForUse)
			p2p.SetWeaponUseability(false, p2p.MyPawn.HandsClass);
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// Add money up to our max
// If we reach it, return false, saying the errand is over
///////////////////////////////////////////////////////////////////////////////
function bool AddAmmo(int AmmoToAdd)
{
	AmmoAmount = Min(MaxAmmo, AmmoAmount+AmmoToAdd);

	if(AmmoAmount >= MaxAmmo)
		return false;	// enough money for errand

	return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function bool HasAmmo()
{
	return bReadyForUse;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bInstantHit=true
	RefireRate=0.990000

	bShowAmmoOnHud=true
	bShowMaxAmmoOnHud=true

	// This determines how many signatures to get
	MaxAmmo=8

	Texture=Texture'HUDPack.Icons.Icon_Inv_Clipboard'
	}
