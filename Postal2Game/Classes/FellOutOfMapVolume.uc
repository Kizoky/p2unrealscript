///////////////////////////////////////////////////////////////////////////
// FellOutOfMapVolume
//
// Copyright 2014 RWS, Inc.  All Rights Reserved.
//
// If the player falls into this volume, he'll be considered "stuck" and
// warped back to the map immediately.
//
///////////////////////////////////////////////////////////////////////////
class FellOutOfMapVolume extends PhysicsVolume;

event PawnEnteredVolume(Pawn Other)
{
	//log(Other@"pawn fell out of world");
	if (Other.Controller != None
		&& P2Player(Other.Controller) != None)
		P2Player(Other.Controller).HandleStuckPlayer(1);
		
	Super.PawnEnteredVolume(Other);
}

defaultproperties
{
	BrushColor=(A=255,B=238,G=0,R=238)
}