///////////////////////////////////////////////////////////////////////////////
// Put this in a trigger
///////////////////////////////////////////////////////////////////////////////
class ACTION_WaitForValidGameInfo extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	return false;
}

defaultproperties
{
	bRequiresValidGameInfo=True
}
