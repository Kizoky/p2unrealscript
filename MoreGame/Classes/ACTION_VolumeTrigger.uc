class ACTION_VolumeTrigger extends ScriptedAction;

var(Action) name Event;

function bool InitActionFor(ScriptedController C)
{
	local Actor A;
	
	// trigger event associated with action
	foreach C.AllActors(class'Actor', A, Event)
		A.Trigger(C.SequenceScript,C.GetInstigator());

	return false;	
}

function string GetActionString()
{
	return ActionString@Event;
}

defaultproperties
{
	ActionString="trigger volume"
}
