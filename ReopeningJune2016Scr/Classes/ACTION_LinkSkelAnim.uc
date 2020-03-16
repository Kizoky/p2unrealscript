//=============================================================================
// ACTION_LinkSkelAnim
// Erik Rossik
//=============================================================================
class ACTION_LinkSkelAnim extends ScriptedAction;

var(Action) MeshAnimation NewAnim;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.LinkSkelAnim(NewAnim);
	return false;	
}

defaultproperties
{
}
