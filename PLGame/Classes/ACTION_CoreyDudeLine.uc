///////////////////////////////////////////////////////////////////////////////
// ACTION_CoreyDudeLine.uc
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Spawns visual effects associated with Corey Dude dialog
///////////////////////////////////////////////////////////////////////////////
class ACTION_CoreyDudeLine extends P2ScriptedAction;

var(Action) float Duration;

function bool InitActionFor(ScriptedController C)
{
	local PLDudePlayer dp;
	local TWPDudePlayer dp2;

	dp = PLDudePlayer(GetPlayer(C));
	if (dp != None)
	{
		dp.SaidCoreyLine(duration);
	}
	// Two Weeks In Paradise
	dp2 = TWPDudePlayer(GetPlayer(C));
	if (dp2 != None)
	{
		dp2.SaidCoreyLine(duration);
	}
	return false;
	}

defaultproperties
{
     ActionString="Say Corey Dude Line"
}
