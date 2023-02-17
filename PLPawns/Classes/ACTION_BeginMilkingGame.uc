///////////////////////////////////////////////////////////////////////////////
// ACTION_BeginMilkingGame
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
class ACTION_BeginMilkingGame extends ScriptedAction;

var(Action) int MilkRequired;				// Amount of milk required to complete the game. Shows up as the maximum ammo value on the dude's bucket.
var(Action) name CompletedEvent;			// Event to trigger when the required amount of milk is collected.
var(Action) int MilkRequiredSecondary;		// Amount of milk required to trigger a secondary event. Should be less than MilkRequired
var(Action) name SecondaryEvent;			// Event to trigger when MilkRequiredSecondary is hit

function bool InitActionFor(ScriptedController C)
{
	local BucketWeapon bukkit;
	
	foreach C.DynamicActors(class'BucketWeapon', bukkit)
	{
		P2AmmoInv(bukkit.AmmoType).bShowAmmoOnHud = true;
		P2AmmoInv(bukkit.AmmoType).bShowMaxAmmoOnHud = true;
		P2AmmoInv(bukkit.AmmoType).bShowAmmoAsPercent = true;
		bukkit.AmmoType.AmmoAmount = 0;
		bukkit.AmmoType.MaxAmmo = MilkRequired;
		bukkit.Event = CompletedEvent;		
		bukkit.SecondaryMilkRequired = MilkRequiredSecondary;
		bukkit.SecondaryEvent = SecondaryEvent;
	}
	
	return false;
}

defaultproperties
{
}