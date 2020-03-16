///////////////////////////////////////////////////////////////////////////////
// DudeClothesPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Stack of clothes pickup for dude to wear 
// of the dude's original clothes.
//
///////////////////////////////////////////////////////////////////////////////

class DudeClothesPickup extends ClothesPickup
placeable;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'DudeClothesInv'
	PickupMessage="You picked up your Jacket and Clothes."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Stuff.stuff1.DudeUniform'
	bPaidFor=true
	Price=100
	LegalOwnerTag="Qing"
	bUseForErrands=true
	bAllowMovement=false
	}
