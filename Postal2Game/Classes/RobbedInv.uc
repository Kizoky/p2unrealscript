///////////////////////////////////////////////////////////////////////////////
// RobbedInv
// Copyright 2014, Running With Scissors, Inc.
//
// Inventory item that keeps a record of all the Dude's shit stolen from him.
///////////////////////////////////////////////////////////////////////////////
class RobbedInv extends TravelInv;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, etc.
///////////////////////////////////////////////////////////////////////////////
struct StolenWeapon
{
	var class<P2Weapon> WeaponClass;
	var int AmmoAmount;
};
struct StolenPowerup
{
	var class<P2PowerupInv> PowerupClass;
	var float Amount;
};

var travel array<StolenWeapon> StolenWeapons;	// Array of stolen weapons.
var travel array<StolenPowerup> StolenPowerups;	// Array of stolen powerups.

///////////////////////////////////////////////////////////////////////////////
// StealThisItem
// Returns true if the item was stolen.
///////////////////////////////////////////////////////////////////////////////
function bool StealThisItem(Inventory StealMe, P2Pawn DudePawn)
{
	// Only steal P2PowerupInv or P2Weapon.
	// Any other inventory class is probably used for internal purposes and should not be disturbed
	// Ammo is taken along with the weapon, so skip it too.
	if (P2PowerupInv(StealMe) != None)
	{
		// Only take the ones that the player could actually toss from their inventory. (No map, stats clipboard, etc.)
		if (!P2PowerupInv(StealMe).bCannotBeStolen)
		{
			StolenPowerups.Insert(0,1);
			StolenPowerups[0].PowerupClass = class<P2PowerupInv>(StealMe.Class);
			StolenPowerups[0].Amount = P2PowerupInv(StealMe).Amount;
			// Force it to drop them all
			P2PowerupInv(StealMe).bThrowIndividually=false;
			// destroy the inventory for the dude
			StealMe.DetachFromPawn(DudePawn);
			DudePawn.DeleteInventory(StealMe);
			return true;
		}
	}
	else if (P2Weapon(StealMe) != None)
	{
		// Don't take the hands, foot, or matches
		if (!P2Weapon(StealMe).bCannotBeStolen)
		{
			StolenWeapons.Insert(0,1);
			StolenWeapons[0].WeaponClass = class<P2Weapon>(StealMe.Class);
			StolenWeapons[0].AmmoAmount = Weapon(StealMe).AmmoType.AmmoAmount;
			// Zero out the ammo, because it was stolen too
			Weapon(StealMe).AmmoType.AmmoAmount = 0;
			// First remove the ammo for this weapon from the dude
			Weapon(StealMe).AmmoType.DetachFromPawn(DudePawn);
			DudePawn.DeleteInventory(Weapon(StealMe).AmmoType);
			// Then destroy the inventory for the dude
			StealMe.DetachFromPawn(DudePawn);
			DudePawn.DeleteInventory(StealMe);
			return true;
		}
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// ReturnThisItem
// Returns the amount of ammo/powerup that was in the item.
// Returns -1 if the item was not stolen
///////////////////////////////////////////////////////////////////////////////
function float ReturnThisItem(class<Inventory> GiveMeBack)
{
	local int i;
	local float returnval;
	
	if (class<P2Weapon>(GiveMeBack) != None)
		for (i = 0; i < StolenWeapons.Length; i++)
			if (StolenWeapons[i].WeaponClass == GiveMeBack)
			{
				returnval = StolenWeapons[i].AmmoAmount;
				StolenWeapons.Remove(i, 1);
				return returnval;
			}

	if (class<P2PowerupInv>(GiveMeBack) != None)
		for (i = 0; i < StolenPowerups.Length; i++)
			if (StolenPowerups[i].PowerupClass == GiveMeBack)
			{
				returnval = StolenPowerups[i].Amount;
				StolenPowerups.Remove(i, 1);
				return returnval;
			}
			
	return -1;
}
