///////////////////////////////////////////////////////////////////////////////
// ACTION_NextDayNoSend.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// This action causes the day to incremented, but nothing else
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_NextDayNoSend extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	P2GameInfoSingle(C.Level.Game).IncrementDay();
	return false;
}

defaultproperties
{
     ActionString="Next day no send"
     bRequiresValidGameInfo=True
}
