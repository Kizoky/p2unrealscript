///////////////////////////////////////////////////////////////////////////////
// ACTION_EndOfGame.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Make the stat screen come up as it loads and
// sends you back to the main menu.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_EndOfGame extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
	{
	P2GameInfoSingle(C.Level.Game).EndOfGame(GetPlayer(C));
	return false;
	}

function string GetActionString()
	{
	return ActionString;
	}

defaultproperties
	{
	ActionString="Action EndOfGame"
	bRequiresValidGameInfo=true
	}
