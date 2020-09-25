///////////////////////////////////////////////////////////////////////////////
// MutEDStuff.uc
// Copyright 2019 Running With Scissors.  All Rights Reserved.
// by NickP, nickp@gopostal.com
///////////////////////////////////////////////////////////////////////////////
class MutEDStuff extends Mutator;

///////////////////////////////////////////////////////////////////////////////
// Make all weapons super strong (also, explosions, fire, projectiles, etc)
///////////////////////////////////////////////////////////////////////////////
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(ShovelPickup(Other) != None)
	{
		ReplaceWith(Other, "EDStuff.AxePickup");
		Other.LifeSpan = 0.1;
	}
	else if(PistolPickup(Other) != None)
	{
		ReplaceWith(Other, "EDStuff.GSelectPickup");
		Other.LifeSpan = 0.1;
	}
	else if(PistolAmmoPickup(Other) != None)
	{
		ReplaceWith(Other, "EDStuff.GSelectAmmoPickup");
		Other.LifeSpan = 0.1;
	}
	else if(MachinegunPickup(Other) != None)
	{
		ReplaceWith(Other, "EDStuff.MP5Pickup");
		Other.LifeSpan = 0.1;
	}
	else if(MachinegunAmmoPickup(Other) != None)
	{
		ReplaceWith(Other, "EDStuff.MP5AmmoPickup");
		Other.LifeSpan = 0.1;
	}
	else if(GrenadePickup(Other) != None)
	{
		ReplaceWith(Other, "EDStuff.DynamitePickup");
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
	GroupName="ED stuff"
	FriendlyName="ED weapons stuff"
	Description="Changes some weapons to ED ones."
}