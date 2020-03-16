class ACTION_Stand extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.ShouldCrouch(false);
	return false;	
}

defaultproperties
{
	ActionString="stand"
	bValidForTrigger=false
}