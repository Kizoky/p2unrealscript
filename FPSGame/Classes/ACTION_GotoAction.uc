class ACTION_GotoAction extends ScriptedAction;

var(Action) int ActionNumber;

function ProceedToNextAction(ScriptedController C)
{
	C.ActionNum = Max(0,ActionNumber);
}

function string GetActionString()
{
	return ActionString@ActionNumber;
}

defaultproperties
{
	ActionString="go to action"
}