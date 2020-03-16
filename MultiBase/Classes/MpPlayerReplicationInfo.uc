///////////////////////////////////////////////////////////////////////////////
// MpPlayerReplicationInfo.uc
// Copyright 2003 Running With Scissors.  All Rights Reserved.
//
// Extra replication info for multiplayer games.
//
///////////////////////////////////////////////////////////////////////////////
class MpPlayerReplicationInfo extends PlayerReplicationInfo;

var SquadAI Squad;
var int Ranking;		// not replicated

replication
{
	reliable if ( Role == ROLE_Authority )
		Squad;
}

function Reset()
{
	Super.Reset();
	Squad = None;
}