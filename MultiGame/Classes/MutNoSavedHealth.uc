///////////////////////////////////////////////////////////////////////////////
// MutNoSavedHealth
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Change crack to medkits, fast food to donuts, so no one can save healths
// in their inventory and use them later.
//
///////////////////////////////////////////////////////////////////////////////
class MutNoSavedHealth extends Mutator;

///////////////////////////////////////////////////////////////////////////////
// Make all weapons super strong (also, explosions, fire, projectiles, etc)
///////////////////////////////////////////////////////////////////////////////
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	// Check normal crack pickups
	if(CrackPickup(Other) != None)
	{
		// if it makes it, return false so the other pickup will be destroyed.
		return !(ReplaceWith(Other, "Inventory.MedKitPickup"));
	}
	// fast food
	else if(FastFoodPickup(Other) != None)
	{
		return (!ReplaceWith(Other, "Inventory.DonutPickup"));
	}
	// Remove also any crack/fast food from cycling pickups
	else if(MultiPickup(Other) != None)
	{
		MultiPickup(Other).SwapClass(class'CrackPickup', class'MedKitPickup');
		MultiPickup(Other).SwapClass(class'FastFoodPickup', class'DonutPickup');
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool MutatorIsAllowed()
{
	return true;
}

defaultproperties
{
	GroupName="NoSavedHealth"
	FriendlyName="No Health Hoarding"
	Description="Changes health pipes and fast food so they give you health when you pick them up instead of going into your inventory.  This keeps you from hoarding health and then using it during battle."
}