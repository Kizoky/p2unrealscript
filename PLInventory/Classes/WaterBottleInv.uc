///////////////////////////////////////////////////////////////////////////////
// WaterBottleInv
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Water bottle that heals some health and refills the dude's Urethra ammo
///////////////////////////////////////////////////////////////////////////////
class WaterBottleInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
var float HealingPct;	// Percentage of how much health you add
var int UrethraAmmoAdd; // How much urethra ammo you add

///////////////////////////////////////////////////////////////////////////////
// Generally used by QuickHealth player key to determine which powerup he
// should use next when healing himself.
///////////////////////////////////////////////////////////////////////////////
simulated function float RateHealingPower()
{
	local P2Pawn CheckPawn;

	CheckPawn = P2Pawn(Owner);
	if(CheckPawn != None)
	{
		return CheckPawn.HealthPctConversion*HealingPct;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add ammo to the dude's pisser
///////////////////////////////////////////////////////////////////////////////
function bool DrankWater()
{
	local Inventory Inv;
	local bool bDrank;
	
	if (Pawn(Owner) != None)
	{
		for (Inv = Pawn(Owner).Inventory; Inv != None; Inv = Inv.Inventory)
			if (UrethraAmmoInv(Inv) != None)
			{
				if (Ammunition(Inv).AmmoAmount < Ammunition(Inv).MaxAmmo)
				{
					Ammunition(Inv).AddAmmo(UrethraAmmoAdd);
					bDrank = true;
				}
			}
	}
	
	return bDrank;
}

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	function bool EatIt()
	{
		local P2Pawn CheckPawn;
		local bool bAte, bDrank;

		CheckPawn = P2Pawn(Owner);
		
		// we want both of these functions to go through
		// this way the water will be used if the dude needs health or piss ammo
		bAte = CheckPawn.AddHealthPct(HealingPct/(1 + Tainted), Tainted, , , , true);
		bDrank = DrankWater();

		// if tainted == 1, we'll divide 2, otherwise, the normal amount will be granted.
		if(bAte || bDrank)
		{
			TurnOffHints();			// When you use it, turn off the hints
			DrankWater();			
			CheckPawn.Say(CheckPawn.myDialog.lGotHealthFood);	// Comment on it whether or not they got healed.
			ReduceAmount(1);
			return true;
		}
		return false;
	}
Begin:
	EatIt();
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	HealingString="You drank a bottle of water."
	HealingPct=2
	PickupClass=class'WaterBottlePickup'
	Icon=Texture'PLHud.Icons.Icon_Inv_WaterBottle'
	bEdible=true
	Hint1="Might just give you that extra"
	Hint2="'ammo' you need for your 'gun'."
	UrethraAmmoAdd=10
	InventoryGroup=100
	PowerupName="Nuka Aqua"
	PowerupDesc="Might just give you that extra 'ammo' you need for your 'gun'"
	GroupOffset=8
}
