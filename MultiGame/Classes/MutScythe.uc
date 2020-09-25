///////////////////////////////////////////////////////////////////////////////
// MutScythe.uc
// Copyright 2019 Running With Scissors.  All Rights Reserved.
// by NickP, nickp@gopostal.com
///////////////////////////////////////////////////////////////////////////////
class MutScythe extends Mutator;

///////////////////////////////////////////////////////////////////////////////
// Make all weapons super strong (also, explosions, fire, projectiles, etc)
///////////////////////////////////////////////////////////////////////////////
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(ShovelPickup(Other) != None)
	{
		ReplaceWith(Other, "AWInventory.ScythePickup");
		Other.LifeSpan = 0.1;
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
	GroupName="Scythe"
	FriendlyName="Scythe replaces shovel"
	Description="Changes all shovels pickups to scythes."
}