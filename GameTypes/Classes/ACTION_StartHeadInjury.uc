///////////////////////////////////////////////////////////////////////////////
// ACTION_StartHeadInjury.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Begins the visual effect of the dude's intense head injury
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_StartHeadInjury extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local AWDudePlayer dp;

	dp = AWDudePlayer(GetPlayer(C));
	if (dp != None)
	{
		dp.StartHeadInjury();
	}
	return false;
	}

defaultproperties
{
     ActionString="Start Head Injury"
}
