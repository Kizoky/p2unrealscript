///////////////////////////////////////////////////////////////////////////////
// ACPartInv
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Various parts for a busted air conditioner.
///////////////////////////////////////////////////////////////////////////////
class ACPartInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
// This is a stack of static meshes for the visual display of each donut we've
// picked up. We'll transfer this back to the pickup we drop, so it looks
// like we dropped the same donut we picked up. It's a stack so first doughnut
// in, will be last doughnut out.
//
// This was copied from the dummied-out donut code. Unlike donuts, we WON'T
// be potentially carrying hundreds of these between levels, so there's no
// chance of overflowing the travel buffer array. Probably.
var travel array<StaticMesh> DonutMeshes;

///////////////////////////////////////////////////////////////////////////////
// Add this in
// We can send in the skin of the new types being added.
///////////////////////////////////////////////////////////////////////////////
function AddAmount(int AddThis, 
				   optional Texture NewSkin, 
				   optional StaticMesh NewMesh,
				   optional int IsTainted)
{
	local int cur, i;

	// Add in the number
	Super.AddAmount(AddThis);

	if(AddThis > 0)
	{
		// Save the mesh, no matter if it's different or the same for the
		// donuts we have already, add it to the stack
		cur = DonutMeshes.Length;
		DonutMeshes.Insert(DonutMeshes.Length, AddThis);
		for(i=0; i < AddThis; i++)
		{
			if(NewMesh != None)
				DonutMeshes[cur + i] = NewMesh;
			else
				DonutMeshes[cur + i] = StaticMesh;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add this in and save the mesh
///////////////////////////////////////////////////////////////////////////////
function ReduceAmount(int UseAmount, 
					  optional out Texture NewSkin, 
					  optional out StaticMesh NewMesh,
					  optional out int IsTainted,
					  optional bool bNoUsedUp)
{
	if(UseAmount > 1)
		Warn(self$" ReduceAmount can't drop more than one thing at a time");
	// Send the mesh back out.
	NewMesh = DonutMeshes[DonutMeshes.Length-1];
	if (NewMesh == None)
		NewMesh = StaticMesh;

	log(self$" removing "$NewMesh$" length "$DonutMeshes.Length);

	DonutMeshes.Remove(DonutMeshes.Length-1, 1);

	Super.ReduceAmount(UseAmount, NewSkin, NewMesh, IsTainted, bNoUsedUp);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PickupClass=class'ACPartPickup'
	Icon=Texture'PLHud.Icons.Icon_Inv_ACParts'
	UseForErrands=1
	bCanThrow=false
	InventoryGroup=102
	GroupOffset=17
	PowerupName="Air Conditioning Parts"
	PowerupDesc="You need to collect three of these for Mike J."
}
