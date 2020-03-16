///////////////////////////////////////////////////////////////////////////////
// ScissorsPickupSingle
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// A single pair of scissors as a pickup. Made to make multiplayer
// pickup easier to do.
//
///////////////////////////////////////////////////////////////////////////////
class ScissorsPickupSingle extends ScissorsPickup;

defaultproperties
	{
	AmmoGiveCount=1
	MPAmmoGiveCount=1
	StaticMesh=StaticMesh'stuff.stuff1.scissors'
	CollisionRadius=15.000000
	CollisionHeight=15.000000
	bAlwaysRelevant=false
	bOnlyReplicateHidden=false
	RespawnTime=0.0
	}