///////////////////////////////////////////////////////////////////////////
// ACTION_ShortCircuitCancel
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Cancels a previously-set short-circuit.
///////////////////////////////////////////////////////////////////////////
class ACTION_ShortCircuitCancel extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	if (C.ShortCircuitScript != None)
		C.ShortCircuitScript = None;
	else
		log(self@"in ShortCircuitCancel:"@C@"short-circuit was already disabled. (This message is usually harmless but may indicate a problem with your script. Check it just to make sure.)");
		
	return false;
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="Cancel short circuit"
}
