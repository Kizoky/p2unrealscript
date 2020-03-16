///////////////////////////////////////////////////////////////////////////////
// Action
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_WaitForTimer extends LatentScriptedAction;

var(Action) float PauseTime;		// How many seconds the sequence should pause.
var(Action) bool bTriggerSkips;		// If true, triggering the sequence's Tag will abort the timer.

function bool InitActionFor(ScriptedController C)
{
	C.CurrentAction = self;
	C.SetTimer(PauseTime, false);
	return true;
}

function bool CompleteWhenTriggered()
{
	return bTriggerSkips;
}

function bool CompleteWhenTimer()
{
	return true;
}

function string GetActionString()
{
	return ActionString@PauseTime;
}

defaultproperties
{
	ActionString="Wait for timer"
	bTriggerSkips=true
}