///////////////////////////////////////////////////////////////////////////////
// MpPlayerReplicationInfo.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
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