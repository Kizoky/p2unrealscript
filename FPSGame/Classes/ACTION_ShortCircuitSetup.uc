///////////////////////////////////////////////////////////////////////////
// ACTION_ShortCircuitSetup
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Sets up a "short-circuit" on a scripted controller.
///////////////////////////////////////////////////////////////////////////
class ACTION_ShortCircuitSetup extends ScriptedAction;

var(Action) name ShortCircuitTag;	// Tag of sequence to short circuit to

function bool InitActionFor(ScriptedController C)
{
	local ScriptedSequence UseScript;
	
	foreach C.DynamicActors(class'ScriptedSequence', UseScript, ShortCircuitTag)
		break;
		
	if (UseScript != None)
		C.ShortCircuitScript = UseScript;
	else
		warn(self@"could not find short-circuit sequence with tag"@ShortCircuitTag);
		
	return false;
}

function string GetActionString()
{
	return ActionString@ShortCircuitTag;
}

defaultproperties
{
	ActionString="Setup short circuit to"
}