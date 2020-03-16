///////////////////////////////////////////////////////////////////////////////
// ACTION_AddTodaysHater.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
//	Add only this day's Haters. Handles adding haters twice. Doesn't make the map pop right now
// and show the haters, but *does* make all pawns in the level that are supposed to
// hate you, hate you. If you then cross through a transition, the map will pop up
// and show the new haters.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_AddTodaysHaters extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local P2GameInfoSingle game;

	game = P2GameInfoSingle(C.Level.Game);
	if(game != None)
		game.AddTodaysHaters();
	return false;
}

defaultproperties
	{
	ActionString="Add Today's Haters"
	}
