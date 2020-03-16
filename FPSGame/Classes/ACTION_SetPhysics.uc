class ACTION_SetPhysics extends ScriptedAction;

var(Action) Actor.EPhysics NewPhysicsMode;

function bool InitActionFor(ScriptedController C)
{
	C.GetInstigator().SetPhysics(NewPhysicsMode);
	return false;	
}

function string GetActionString()
{
	return ActionString@NewPhysicsMode;
}

defaultproperties
{
	ActionString="change physics to "
}