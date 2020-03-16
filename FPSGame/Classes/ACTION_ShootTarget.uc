class ACTION_ShootTarget extends ScriptedAction;

var(Action) int NumShots;
var(Action) name FiringMode;
var(Action) bool bSpray;

function bool InitActionFor(ScriptedController C)
{
	C.NumShots = NumShots;
	C.FiringMode = FiringMode;
	C.bShootTarget = true;
	C.bShootSpray = bSpray;
	return false;	
}

defaultproperties
{
	ActionString="shoot target"
}