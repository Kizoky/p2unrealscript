/**
 * BoltonEditorPickup
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Pickup for an in game development tool
 *
 * @author Gordon Cheng
 */
class BoltonEditorPickup extends P2WeaponPickup;

defaultproperties
{
	InventoryType=class'BoltonEditor'
	ShortSleeveType=class'BoltonEditor'
	PickupMessage="You picked up a Bolton Editor"
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.Clipboard3'
	BounceSound=Sound'MiscSounds.PickupSounds.woodhitsground1'
}