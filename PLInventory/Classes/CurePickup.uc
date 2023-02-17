///////////////////////////////////////////////////////////////////////////////
// CurePickup
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Unprocessed Ensmallen Cure chemicals. This is the "raw" form of the cure,
// before Gary adds the secret ingredient. Thus, it's an inventory item,
// and not a weapon yet.
///////////////////////////////////////////////////////////////////////////////
class CurePickup extends OwnedPickup;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	InventoryType=class'CureInv'
	PickupMessage="You picked up a syringe containing the Ensmallen Cure's required chemical compound."
	bUseForErrands=True
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.Needle_PU'
	Skins[1]=WetTexture'Zo_Smeg.Special_Brushes.zo_liquidnapalm'
	Skins[2]=WetTexture'Zo_Smeg.Special_Brushes.zo_liquidnapalm'
}
