///////////////////////////////////////////////////////////////////////////////
// GrenadePickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class DynamitePickup extends P2WeaponPickup;

defaultproperties
{
     BounceSound=Sound'WeaponSounds.grenade_bounce'
     bNoBotPickup=True
     MaxDesireability=-1.000000
     InventoryType=Class'DynamiteWeapon'
     PickupMessage="You picked up a stick of Dynamite."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ED_TPMeshes.Emitter.dynamite'
     CollisionRadius=35.000000
     CollisionHeight=20.000000
	 AmmoGiveCount=3
	 MPAmmoGiveCount=1
}
