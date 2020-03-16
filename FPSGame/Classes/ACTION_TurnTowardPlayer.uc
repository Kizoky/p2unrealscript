class ACTION_TurnTowardPlayer extends LatentScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.ScriptedFocus = C.GetMyPlayer();
	C.CurrentAction = self;
	return true;	
}
function bool TurnToGoal()
{
	return true;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	return C.GetMyPlayer();
}

defaultproperties
{
	ActionString="Turn toward player"
	bValidForTrigger=false
}
