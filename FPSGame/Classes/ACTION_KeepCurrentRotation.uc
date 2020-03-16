class ACTION_KeepCurrentRotation extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.bUseScriptFacing = false;
	return false;	
}

defaultproperties
{
	ActionString="keep current rotation"
}