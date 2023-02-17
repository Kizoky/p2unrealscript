///////////////////////////////////////////////////////////////////////////////
// LawmanClothesPickup
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////

class LawmanClothesPickup extends ClothesPickup
	placeable;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	InventoryType=class'LawmanClothesInv'
	PickupMessage="You picked up some Lawman chaps."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Stuff.stuff1.CopUniform'
	Skins[0]=Texture'PLPickupTex.clothes.Dude_CowboyDisguisePickup'
	bBreaksWindows=false
	Price=0
	bPaidFor=true
	LegalOwnerTag=""
}
