//////////////////////////////////////////////////////////////////////////////
// MolotovAltProjectile.
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual Molotov that falls on the ground, ready to blow up
// Explicit extra projectiles are made so multiplayer works better. This is
// because by setting default props ahead of time you can avoid 
// trying to replicate things after spawning.
//
///////////////////////////////////////////////////////////////////////////////
class MolotovAltProjectile extends MolotovProjectile;


defaultproperties
{
	bArmed=false
	DetonateTime=8.0
}
