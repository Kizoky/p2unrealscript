///////////////////////////////////////////////////////////////////////////////
// PizzaPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A tastey, fatty, slice of pizza
//
///////////////////////////////////////////////////////////////////////////////

class PizzaPickup extends OwnedPickup;


var float HealingPctMP;	// Percentage of how much health you add (only in MP)

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
	InventoryType=class'PizzaInv'
	NightmareInventoryType=class'PizzaInvAuto'
	PickupMessage="You picked up a slice of pizza."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'furniture-STV.Misc.PIZZASLICE'

	bEdible=true
	DesireMarkerClass=class'OtherFoodMarker'

	HealingPctMP=5
	}
