///////////////////////////////////////////////////////////////////////////////
// DualWieldPickup
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class CrackColaPickup extends OwnedPickup;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	MyAnimalClass = class<AnimalPawn>(DynamicLoadObject(AnimalClassString, class'Class'));
	SetPhysics(PHYS_Falling);
	// If we start tainted (from a level designer setting) then set it so
	if(bStartTainted)
		Taint();
	if(bForTransferOnly)
		bAllowMovement=false;
	//log(self$" prebeginplay");
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
     InventoryType=Class'CrackColaInv'
     PickupMessage="You picked up a can of Crackola."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'xPatchMesh.Pickup.CrackColaCan'
	 
	 bAllowMovement=true
	 Physics=PHYS_Falling
}
