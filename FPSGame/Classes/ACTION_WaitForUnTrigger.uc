class ACTION_WaitForUnTrigger extends LatentScriptedAction;

var(Action) name ExternalEvent;	//tag to give controller (to affect triggering)

function bool InitActionFor(ScriptedController C)
{
	C.CurrentAction = self;
	C.Tag = ExternalEvent;
	return true;
}

function bool CompleteWhenUnTriggered()
{
	return true;
}

function string GetActionString()
{
	return ActionString@ExternalEvent;
}

defaultproperties
{
	ActionString="Wait for UnTrigger"
}
