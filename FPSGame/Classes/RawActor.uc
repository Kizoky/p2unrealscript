///////////////////////////////////////////////////////////////////////////////
// RawActor.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// If Actor wasn't abstract then we wouldn't need this.  It's just a very
// simple class that can be used for various situations, like when you need
// a temporary actor or something like that.
//
///////////////////////////////////////////////////////////////////////////////
class RawActor extends Actor;

defaultproperties
	{
	bHidden=true
	bStasis=true
	bCollideActors=False
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
 	bBlockZeroExtentTraces=False
 	bBlockNonZeroExtentTraces=False
	}