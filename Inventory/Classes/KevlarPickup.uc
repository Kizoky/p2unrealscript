///////////////////////////////////////////////////////////////////////////////
// KevlarPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Kevlar pickup.
// Armor powerup. Once touched, its used and goes into your armor which
// absorbs certain damage types.
//
///////////////////////////////////////////////////////////////////////////////

class KevlarPickup extends OwnedPickup;

var float ArmorAmount;	// How much armor you add

///////////////////////////////////////////////////////////////////////////////
// Make sure the amount we had carries over
///////////////////////////////////////////////////////////////////////////////
function InitDroppedPickupFor(Inventory Inv)
{
	local KevlarInv kInv;

	Super.InitDroppedPickupFor(Inv);

	kInv = KevlarInv(Inv);
	// If the kevlar was damaged, transfer the lesser amount over to the pickup
	if(kInv != None)
	{
		ArmorAmount = kInv.ArmorAmount;
	}
}

///////////////////////////////////////////////////////////////////////////////
// First hit of this type, so add in what we've found
///////////////////////////////////////////////////////////////////////////////
function inventory SpawnCopy( Pawn Other )
{
	local KevlarInv Copy;

	Copy = KevlarInv(Super.SpawnCopy(Other));
	if(Copy != None)
		Copy.ArmorAmount = ArmorAmount;
	return Copy;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Pickup.. add the health
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Pickup
{	
	function bool ValidTouch( actor Other )
	{
		local P2Pawn CheckPawn;
			
		if(P2Pawn(Other) == None
			|| P2Pawn(Other).AcceptThisArmor(ArmorAmount, default.ArmorAmount))
			return Super.ValidTouch(Other);
		else
			return false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'KevlarInv'
	ArmorAmount=75
	PickupMessage="You put on a Kevlar Vest."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Stuff.stuff1.kevlarvest'
	bPaidFor=true
	bAllowMovement=false
	}