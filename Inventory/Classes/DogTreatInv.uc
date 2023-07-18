///////////////////////////////////////////////////////////////////////////////
// DogTreatInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Food to feed your dog
//
//	Not included in your quickhealth, because it gives you so little. The
// player should just search for it otherwise.
//
///////////////////////////////////////////////////////////////////////////////
class DogTreatInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// vars/consts
///////////////////////////////////////////////////////////////////////////////
var float HealingPct;	// Percentage of how much health you add

///////////////////////////////////////////////////////////////////////////////
// Toss this item out.
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	Super.DropFrom(StartLocation);
	// We've completed how we're 'supposed' to use this
	TurnOffHints();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function EatingFood()
{
	local P2MocapPawn CheckPawn;
	local P2Player p2p;

	CheckPawn = P2MocapPawn(Owner);
	p2p = P2Player(CheckPawn.Controller);

	p2p.EatingFood();
}

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	function bool EatIt()
	{
		local P2Pawn CheckPawn;

		CheckPawn = P2Pawn(Owner);

		if(CheckPawn.AddHealthPct(HealingPct, Tainted, , , , true))
		{
			ReduceAmount(1);
			EatingFood();
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
	PickupClass=class'DogTreatPickup'
	Icon=Texture'Hudpack.icons.Icon_Inv_DogTreats'
	//ClassicIcon=Texture'ClassicHUDPack.Inventory.Icon_Inv_DogTreats'
	InventoryGroup=101
	GroupOffset=5
	PowerupName="Dog Treat"
	PowerupDesc="Make a friend for life."
	bEdible=true
	Tainted=1
	HealingPct=1
	Hint1="Press %KEY_ThrowPowerup% to drop the"
	Hint2="biscuit and befriend"
	Hint3="a nearby dog."
	}
