///////////////////////////////////////////////////////////////////////////////
// ACTION_SpeedrunCallTime.uc
// Copyright 2017 Running With Scissors, Inc.  All Rights Reserved.
//
// Scripted action that "calls time" for a speedrun, indicating that no further
// player input is required and the game is complete or about to be complete.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_SpeedrunCallTime extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
	{
	P2GameInfoSingle(C.Level.Game).TheGameState.TimeStop = C.Level.GetMillisecondsNow();
	return false;
	}

function string GetActionString()
	{
	return ActionString;
	}

defaultproperties
	{
	ActionString="Action Speedrun Call Time"
	bRequiresValidGameInfo=true
	}
