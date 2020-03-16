///////////////////////////////////////////////////////////////////////////////
// MutNoCrack
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Change crack to medkits
//
///////////////////////////////////////////////////////////////////////////////
class MutNoCrack extends Mutator;

///////////////////////////////////////////////////////////////////////////////
// Make all weapons super strong (also, explosions, fire, projectiles, etc)
///////////////////////////////////////////////////////////////////////////////
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	// Check normal crack pickups
	if(CrackPickup(Other) != None)
	{
		return !(ReplaceWith(Other, "Inventory.PizzaPickup"));
	}
	// Remove also any crack from cycling pickups
	else if(MultiPickup(Other) != None)
	{
		MultiPickup(Other).SwapClass(class'CrackPickup', class'MedKitPickup');
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
	GroupName="NoCrack"
	FriendlyName="No Health Pipes"
	Description="Changes all health pipes to medkits.  This keeps you from getting huge health boosts during battle."
}