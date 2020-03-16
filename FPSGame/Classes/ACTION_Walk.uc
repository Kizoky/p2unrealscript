class ACTION_Walk extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.ShouldCrouch(false);
	C.Pawn.SetWalking(true);
	C.Pawn.ChangeAnimation();
	return false;	
}

defaultproperties
{
	ActionString="walk"
	bValidForTrigger=false
}