class ACTION_DestroyActor extends ScriptedAction;

var(Action)		name			DestroyTag;

function bool InitActionFor(ScriptedController C)
{
	local Actor a;

	if(DestroyTag != 'None')
	{
		ForEach C.AllActors(class'Actor', a, DestroyTag)
		{
			a.Destroy();
			log("Destroyed actor:"@a);
		}
	}

	return false;	
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="Destroy actor"
}
