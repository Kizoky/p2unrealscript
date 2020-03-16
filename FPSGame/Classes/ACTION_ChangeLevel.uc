class ACTION_ChangeLevel extends ScriptedAction;

var(Action) string URL;	// URL to travel to.
var/*(Action)*/ bool bShowLoadingMessage;

function bool InitActionFor(ScriptedController C)
{
	if( bShowLoadingMessage )
		C.Level.ServerTravel(URL, false);
	else
		C.Level.ServerTravel(URL$"?quiet", false);
	return true;	
}

function string GetActionString()
{
	return ActionString;
}


defaultproperties
{
	ActionString="Change level"
	bShowLoadingMessage=False
}