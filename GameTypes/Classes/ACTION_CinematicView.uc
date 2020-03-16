// Changes cinematic view
class ACTION_CinematicView extends P2ScriptedAction;

var() enum ECinematicType
{
	CINEMATICS_Off,
	CINEMATICS_On
} SetCinematicsTo;

function bool InitActionFor(ScriptedController C)
{
	local P2Player OurPlayer;
	
	OurPlayer = GetPlayer(C);
	OurPlayer.ConsoleCommand("CINEMATICS" @ SetCinematicsTo);
	
	return true;
}

function string GetActionString()
{
	return ActionString @ String(SetCinematicsTo);
}

defaultproperties
{
	ActionString="CINEMATICS"
}