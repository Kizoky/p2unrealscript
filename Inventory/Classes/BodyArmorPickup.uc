///////////////////////////////////////////////////////////////////////////////
// BodyArmorPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Silicon Carbide ceramic plates inside a kevlar vest. Tougher than Kevlar armor
//
// Armor powerup. Once touched, its used and goes into your armor which
// absorbs certain damage types.
//
///////////////////////////////////////////////////////////////////////////////

class BodyArmorPickup extends KevlarPickup;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'BodyArmorInv'
	ArmorAmount=150
	PickupMessage="You put on SiC Body Armor."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Stuff.stuff1.kevlarvest'
	Skins[0]=Texture'StuffSkins.items.KevlarHeavy'
	bPaidFor=true
	}
