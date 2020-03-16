///////////////////////////////////////////////////////////////////////////////
// DonutPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A donut
//
//
///////////////////////////////////////////////////////////////////////////////

class DonutPickup extends OwnedPickup;

var float HealingPctMP;	// Percentage of how much health you add (only in MP)

///////////////////////////////////////////////////////////////////////////////
// Donuts handle tainted things specially... with a long array for each
// tainted donut
///////////////////////////////////////////////////////////////////////////////
function TransferStateBack(P2PowerupInv maker)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Reduce the amount of the inventory we just got generated from
///////////////////////////////////////////////////////////////////////////////
function TakeAmountFromInv(P2PowerupInv p2Inv, int amounttoremove)
{
	local StaticMesh newmesh;
	local int IsTainted;

	// Take some from it and use this static mesh
	p2Inv.ReduceAmount(amounttoremove,,newmesh, IsTainted, true);

	// Make sure it's tainted after we drop it
	if(IsTainted == 1)
		Taint();

	// Set our mesh from whoever dropped us
	SetStaticMesh(newmesh);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Pickup.. add the health instantly in MP, store it in inventory in SP
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Pickup
{	
	///////////////////////////////////////////////////////////////////////////////
	// ValidTouch()
	// Validate touch (if valid return true to let other pick me up and trigger event).
	//
	///////////////////////////////////////////////////////////////////////////////
	function bool ValidTouch( actor Other )
	{
		// In nightmare mode don't pick up the item unless you really need it.
		if (P2GameInfo(Level.Game).InNightmareMode()
			&& P2Pawn(Other) != None
			&& P2Pawn(Other).Health >= P2Pawn(Other).HealthMax)
			return false;
		else
			return Super.ValidTouch(Other);
	}

	function Touch( actor Other )
	{
		local P2Pawn CheckPawn;
			
		// In MP instant pickup only
		if(Level.Game == None
			|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		{
			if ( ValidTouch(Other) ) 
			{	
				CheckPawn = P2Pawn(Other);	
				if(CheckPawn.AddHealthPct(HealingPctMP, , , , , true))
				{
					AnnouncePickup(CheckPawn);
				}
			}
		}
		else // Single player, picks up and keeps it
			Super.Touch(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'DonutInv'
	NightmareInventoryType=class'DonutInvAuto'
	PickupMessage="You picked up a Doughnut."
	DrawType=DT_StaticMesh
	// make sure these default to the same
	StaticMesh=StaticMesh'Timb_mesh.fast_food.donut1_timb'

	bEdible=true
	DesireMarkerClass=class'DonutMarker'
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'

	HealingPctMP=3

	MaxDesireability = 0.6
	}
