//=============================================================================
// PistolPickup
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Pistol weapon pickup.
//
//	History:
//		01/29/02 MJR	Started history, probably won't be updated again until
//							the pace of change slows down.
//
//=============================================================================

class GrenadeLauncherPickup extends P2WeaponPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     AmmoGiveCount=5
     DeadNPCAmmoGiveRange=(Min=2.000000,Max=5.000000)
     BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
     InventoryType=Class'GrenadeLauncherWeapon'
     PickupMessage="You picked up a M79 GrenadeLauncher."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ED_TPMeshes.WeaponPickups.PU_M79'
     CollisionRadius=40.000000
     CollisionHeight=5.000000
}
