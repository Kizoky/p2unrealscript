class ACTION_Run extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.ShouldCrouch(false);
	C.Pawn.SetWalking(false);
	C.Pawn.ChangeAnimation();
	return false;	
}

defaultproperties
{
	ActionString="Run"
	bValidForTrigger=false
}