///////////////////////////////////////////////////////////////////////////////
// ACTION_Loop.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Allows a section of actions to be looped 'n' times.
//
//	History:
//		05/14/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
//
// NOTE: This is not a general-purpose solution because it does NOT support
// nested sections.
//
// This uses the IterationCounter and IterationSectionStart vars that Epic
// already had in ScriptedController to count the iterations and keep track of
// where to loop back to.  Epic also already had code in ACTION_EndSection to
// do what's necessary at the end of the section (check counter, decrement
// count, and loop back to start if needed).  Oddly enough, they didn't have
// any code to setup a loop, so I added this.
//
// It is possible to have nested sections (ProceedToSectionEnd() handles them
// properly).  However, since there's only one counter in ScriptedController,
// you can't have multiple loops.  The solution would be to use an array of
// counters and a current nesting level.  But for now it seems unlikely that
// action sequences are going to get all that complicated due to the
// limited user interface.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_Loop extends ScriptedAction;

var(Action) int LoopCount;

function ProceedToNextAction(ScriptedController C)
	{
	C.ActionNum += 1;
	if (LoopCount > 0)
		{
		C.IterationCounter = Max(0, LoopCount - 1);
		C.IterationSectionStart= C.ActionNum;
		}
	else
		ProceedToSectionEnd(C);
	}

function bool StartsSection()
	{
	return true;
	}

function string GetActionString()
	{
	return ActionString@LoopCount;
	}

defaultproperties
	{
	LoopCount=1
	ActionString="Loop count"
	}