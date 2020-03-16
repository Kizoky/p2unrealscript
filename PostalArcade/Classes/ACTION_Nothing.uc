class ACTION_Nothing extends ScriptedAction;

var(Action) string ReasonForNothing;

function bool InitActionFor(ScriptedController C)
{
     return false;
}

function string GetActionString()
{
	return ActionString@ReasonForNothing;
}

defaultproperties
{
     ActionString="Nothing"
}
