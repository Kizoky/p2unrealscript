///////////////////////////////////////////////////////////////////////////////
// ACTION_ForceReload.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// This action causes a reload, the same way as if a player were dead and he pressed the spacebar
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_ForceReload extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	P2GameInfoSingle(C.Level.Game).LoadMostRecentGame();
	return false;
}

defaultproperties
{
     ActionString="Force reload"
     bRequiresValidGameInfo=True
}
