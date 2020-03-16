///////////////////////////////////////////////////////////////////////////////
// AWCatPickup
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// AWCat pickup.
//
// AWCatInv MUST COMPILE IN AWPAWNS instead of awinventory, so it can access a
// new function in the controller when it drops. It's ugly, sorry.
// This one doesn't really need to be in awpawns, but it paired it with AWCatInv
// just cause it made some conceptual sense to keep them together.
///////////////////////////////////////////////////////////////////////////////

class AWCatPickup extends CatPickup;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     InventoryType=Class'AWPawns.AWCatInv'
     Skins(0)=Texture'AnimalSkins.Cat_Orange'
}
