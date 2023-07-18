///////////////////////////////////////////////////////////////////////////////
// ACTION_AtMyHouse.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Setup to handle all the various cases of when the dude arrives at his house
// and expects the game to end, to go to home for the night, etc..
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_AtMyHouse extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
	{
	P2GameInfoSingle(C.Level.Game).AtPlayerHouse(GetPlayer(C));
	return false;
	}

function string GetActionString()
	{
	return ActionString;
	}

defaultproperties
	{
	ActionString="Action AtMyHouse"
	bRequiresValidGameInfo=true
	}
