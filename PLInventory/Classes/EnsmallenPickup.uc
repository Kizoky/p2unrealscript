///////////////////////////////////////////////////////////////////////////////
// EnsmallenPickup
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Weapon version of the Ensmallen Cure
///////////////////////////////////////////////////////////////////////////////
class EnsmallenPickup extends P2WeaponPickup;

defaultproperties
{
	InventoryType=class'EnsmallenWeapon'
	PickupMessage="You picked up a vial of Ensmallen Cure."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.Needle_PU'
	Skins[1]=Shader'MrD_PL_Tex.Weapons.Needle_Goo_Yellow'
	Skins[2]=Shader'MrD_PL_Tex.Weapons.Needle_Goo_Yellow'
}
