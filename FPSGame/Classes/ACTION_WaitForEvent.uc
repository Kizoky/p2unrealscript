class ACTION_WaitForEvent extends LatentScriptedAction
	native;

var(Action) name ExternalEvent;	//tag to give controller (to affect triggering)
var transient TriggeredCondition T;

function bool InitActionFor(ScriptedController C)
{
	if ( T == None )
		ForEach C.AllActors(class'TriggeredCondition',T,ExternalEvent)
			break;

	if ( (T != None) && T.bEnabled )
		return false;
	
	C.CurrentAction = self;
	C.Tag = ExternalEvent;
	return true;
}

function bool CompleteWhenTriggered()
{
	return true;
}

function string GetActionString()
{
	return ActionString@ExternalEvent;
}

defaultproperties
{
	ActionString="Wait for external event"
}