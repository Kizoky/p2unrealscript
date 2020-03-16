///////////////////////////////////////////////////////////////////////////////
// ErrandGoalGetAmmoMax
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Errand Goal that requires the dude gets the ammo max for a certain
// weapon
//
///////////////////////////////////////////////////////////////////////////////
class ErrandGoalGetAmmoMax extends ErrandGoalGetInvClass;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Check to see if this errand is done
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCompletion(Actor Other, Actor Another, Pawn ActionPawn)
{
	local Weapon weapcheck;

	weapcheck = Weapon(Other);

	// If the weapon exists and we have ammo for it, and the max ammo has
	// been achieved, then say it's good
	if(weapcheck != None
		&& InvClassName != ''
		&& weapcheck.IsA(InvClassName)
		&& weapcheck.AmmoType != None
		&& weapcheck.AmmoType.AmmoAmount == weapcheck.AmmoType.MaxAmmo)
		return true;

	// something didn't work just write
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// For testing we need to force goals to complete instead of completing them
// the normal way.
//
// Make sure to give this weapon all it's ammo
///////////////////////////////////////////////////////////////////////////////
function ForceCompletion(P2Player CurPlayer)
{
	local class<Inventory> WeapClass;
	local P2Weapon p2weap;
	local String InvPreface;

	Super.ForceCompletion(CurPlayer);

	InvPreface = "Inventory.";
	WeapClass = CurPlayer.Pawn.Level.Game.BaseMutator.GetInventoryClass(InvPreface$String(InvClassName));
	//log(self$" ForceCompletion weapclass "$WeapClass$" string "$String(InvClassName)$" inv class name "$InvClassName$" player "$CurPlayer);

	// Make sure the weapon we're concerned about has max ammo now, 
	// and try to put it away
	if(CurPlayer != None)
	{
		p2weap = P2Weapon(CurPlayer.Pawn.FindInventoryType(WeapClass));
		log(self$" weapon "$p2weap);
		if(p2weap != None)
		{
			log(self$" ammo "$P2AmmoInv(p2weap.AmmoType));
			P2AmmoInv(p2weap.AmmoType).AddAmmo(P2AmmoInv(p2weap.AmmoType).MaxAmmo);
			p2weap.Finish();
		}
	}
}

defaultproperties
{
}
