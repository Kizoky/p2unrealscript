///////////////////////////////////////////////////////////////////////////////
// ACTION_SuppressWeaponChangeSound
// Copyright 2014 Running With Scissors, Inc. All Rights Reserved.
//
// Does Exactly What It Says On The Tin
///////////////////////////////////////////////////////////////////////////////
class ACTION_SuppressWeaponChangeSound extends P2ScriptedAction;

var(Action) float SuppressDuration;

function bool InitActionFor(ScriptedController C)
{
	if (P2Pawn(C.Pawn) != None)
		P2Pawn(C.Pawn).SpawnTime = (C.Level.TimeSeconds + SuppressDuration - 1.0);
	return false;
}

defaultproperties
{
	SuppressDuration = 1.0
}