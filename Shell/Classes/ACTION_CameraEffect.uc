///////////////////////////////////////////////////////////////////////////////
// ACTION_CameraEffect.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This action lets you enable/disable camera effects.
//
//	History:
//		06/10/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_CameraEffect extends LatentScriptedAction;

// This isn't anywhere near working, so I'll comment out the vars to make
// it clear that it can't do anything in case someone tries to use it.
//
// The work to be done includes (1) figuring out how to get hold of the
// current viewport (or playercontroller or whatever), then (2) adding the
// camera effect, then (3) figuring out how to tick or otherwise update the
// effect, and finally (4) removing the effect.

//var(Action) editinline CameraEffect	CameraEffect;
//var(Action) float EffectTime;

function bool InitActionFor(ScriptedController C)
	{
//	C.CurrentAction = self;
//	C.SetTimer(EffectTime, false);
	return true;
	}

function ProceedToNextAction(ScriptedController C)
	{
	Super.ProceedToNextAction(C);
	}

function bool CompleteWhenTriggered()
	{
	return true;
	}

function bool CompleteWhenTimer()
	{
	return true;
	}

function string GetActionString()
	{
	return ActionString;
	}

defaultproperties
	{
	ActionString="camera effect"
	}
