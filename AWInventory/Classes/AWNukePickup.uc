///////////////////////////////////////////////////////////////////////////////
// AWNukePickup
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Nuclear warhead pickup.
//
///////////////////////////////////////////////////////////////////////////////

class AWNukePickup extends OwnedPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     bPaidFor=True
     bUseForErrands=True
     bAllowMovement=False
     InventoryType=Class'AWInventory.AWNukeInv'
     PickupMessage="You picked up a thermo-nuclear warhead."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AW_Meshes.Misc.Nuke'
}
