class ACTION_ToggleCinematicView extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local PlayerController pc;
	
	foreach C.AllActors(class'PlayerController', pc)
		break;
	if (pc != None
		&& pc.MyHud != None)
		pc.MyHud.bCinematicView = !pc.MyHud.bCinematicView;

	return false;	
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="toggle cinematic view"
}