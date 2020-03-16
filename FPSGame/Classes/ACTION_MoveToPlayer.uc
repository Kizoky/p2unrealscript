///////////////////////////////////////////////////////////////////////////////
// Action
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_MoveToPlayer extends LatentScriptedAction;

function bool MoveToGoal()
{
	return true;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	return C.GetMyPlayer();
}

defaultproperties
{
	ActionString="Move to player"
	bValidForTrigger=false
}
