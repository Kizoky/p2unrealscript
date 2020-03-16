class ACTION_TriggerEvent extends ScriptedAction;

var(Action) name Event;

function bool InitActionFor(ScriptedController C)
{
	// trigger event associated with action
	C.TriggerEvent(Event,C.SequenceScript,C.GetInstigator());
	return false;	
}

function string GetActionString()
{
	return ActionString@Event;
}

defaultproperties
{
	ActionString="trigger event"
}
