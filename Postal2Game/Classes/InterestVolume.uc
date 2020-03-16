///////////////////////////////////////////////////////////////////////////
// InterestVolume
//
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// If people see the player doing this thing, they'll respond with the given
// reaction. This toggles the player's action, so as long as he's in the volume
// and people see/hear him, they'll respond appropriately.
//
///////////////////////////////////////////////////////////////////////////

class InterestVolume extends PhysicsVolume;

var() FPSPawn.EPawnInitialState SightReaction;	// Type of reaction player instills in others that see
								// him enter this volume
var() bool bActive;		// If it's on or not, trigger toggles this

///////////////////////////////////////////////////////////////////////////
// Set the player as causing this reaction when sighted by npc's
///////////////////////////////////////////////////////////////////////////
event PawnEnteredVolume(Pawn Other)
{
	local P2Player p2p;

	if(bActive)
	{
		p2p = P2Player(Other.Controller);

		if(p2p != None)
			p2p.SetSightReaction(SightReaction);
	}
}

///////////////////////////////////////////////////////////////////////////
// Clear the reaction the player causes in npc's on sight
///////////////////////////////////////////////////////////////////////////
event PawnLeavingVolume(Pawn Other)
{
	local P2Player p2p;

	if(bActive)
	{
		p2p = P2Player(Other.Controller);

		if(p2p != None)
			p2p.ClearSightReaction();
	}
}

///////////////////////////////////////////////////////////////////////////
// Toggle active state
///////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	bActive = !bActive;
}

defaultproperties
{
	bActive=true
    Gravity=(X=0.000000,Y=0.000000,Z=-3000.000000)
	bBlockZeroExtentTraces=False
	bColored=true
	BrushColor=(A=255,B=238,G=0,R=238)
}