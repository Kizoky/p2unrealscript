///////////////////////////////////////////////////////////////////////////////
// AWCatInv
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// MUST COMPILE IN AWPAWNS instead of awinventory, so it can access a
// new function in the controller when it drops. It's ugly, sorry.
//
///////////////////////////////////////////////////////////////////////////////
class AWCatInv extends CatInv;

///////////////////////////////////////////////////////////////////////////////
// vars, consts
///////////////////////////////////////////////////////////////////////////////
var string DropCatClassStr;		// Kind of cat we drop (must extend AWCatPawn)

///////////////////////////////////////////////////////////////////////////////
// Toss out a cat pawn, but load it dynamically
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	local AnimalPawn ThrowMe;
	local class<AnimalPawn> aclass;
	local vector DropSpot, rot;
	local Texture NewSkin;

	log(self$" drop from "$DropCatClassStr);
	aclass = class<AnimalPawn>(DynamicLoadObject(DropCatClassStr, class'Class'));

	// Create it a distance in front of you
	DropSpot = Instigator.Location;
	rot = vector(Instigator.Rotation);
	DropSpot = rot*DROP_CAT_RADIUS + DropSpot;
	DropSpot.z+=Instigator.CollisionHeight;

	ThrowMe = spawn(aclass,,,DropSpot);
	// Throw out one
	if ( ThrowMe == None )
		return;

	ThrowMe.Instigator = Instigator;
	// It worked so alert the dogs
	ThrowMe.AlertPredator();

	// If throw each one and you have more than one, then only spawn a copy
	if(bThrowIndividually)
	{
		AddController(ThrowMe);
		AWCatController(ThrowMe.Controller).ThrownToGround(Instigator);
		// Force the throw speed to be the animal's running speed
		ThrowMe.Velocity = ThrowMe.GroundSpeed*Normal(Velocity);
		Velocity = vect(0,0,0);
		// Reduce out inventory if this worked
		ReduceAmount(1,NewSkin);
		// Put the right skin on the new cat
		ThrowMe.Skins[0] = NewSkin;
	}
	else if(Amount == 0)
	{
		///////////////////////////////////////////////////////////////////////////////
		// Same as DropFrom in Inventory.uc, but we pass the instigator along to
		// the spawned pickup as its owner, because we want to know who most recently
		// dropped this for errands
		///////////////////////////////////////////////////////////////////////////////
		if ( Instigator != None )
		{
			DetachFromPawn(Instigator);	
			Instigator.DeleteInventory(self);
		}	
		SetDefaultDisplayProperties();
		Inventory = None;
		Instigator = None;
		StopAnimating();
		GotoState('');

		Destroy();
	}
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	DropCatClassStr="AWPawns.AWCatPawn"
	InventoryGroup=101
	GroupOffset=2
	PickupClass=Class'AWPawns.AWCatPickup'
	Skins(0)=Texture'AnimalSkins.Cat_Orange'
}
