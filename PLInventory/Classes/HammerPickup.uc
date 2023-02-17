///////////////////////////////////////////////////////////////////////////////
// HammerWeapon
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Hammer "weapon" for third-person display purposes only
///////////////////////////////////////////////////////////////////////////////
class HammerPickup extends P2WeaponPickup
	notplaceable;

///////////////////////////////////////////////////////////////////////////////
// Make sure the amount we had carries over
///////////////////////////////////////////////////////////////////////////////
function InitDroppedPickupFor(Inventory Inv)
{
	// Mark the pickup as persistent if the player dropped it
	if(Instigator != None
		&& Instigator.Controller != None
		&& Instigator.Controller.bIsPlayer)
		Super.InitDroppedPickupFor(Inv);
	else
	// ERROR MESSAGE ERROR MESSAGE
	// THIS GUN SHOULD NEVER DROP
		Destroy();
}

defaultproperties
{
     BounceSound=Sound'MiscSounds.Props.woodhitsground1'
     InventoryType=Class'HammerWeapon'
     PickupMessage="You picked up a hammer."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'hammer.HammerPickupMesh'
}
