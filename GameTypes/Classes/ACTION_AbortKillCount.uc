class ACTION_AbortKillCount extends P2ScriptedAction;

var(Action) name TriggerOrBossTag;

function bool InitActionFor(ScriptedController C)
	{
	if(AWPlayer(GetPlayer(C)) != None)
		AWPlayer(GetPlayer(C)).FinishKillCount(TriggerOrBossTag);
	else
		warn(" Tried to start action without AWPlayer");

	return false;
	}

defaultproperties
{
	ActionString="action abort kill counter"
	bRequiresValidGameInfo=True
}
