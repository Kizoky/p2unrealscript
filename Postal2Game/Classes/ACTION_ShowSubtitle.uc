class ACTION_ShowSubtitle extends ScriptedAction;

var(Action) String SubtitleTag;

function bool InitActionFor(ScriptedController C) {

	local SubtitleManager S;
	
	foreach C.AllActors(class'SubtitleManager',S)
	{
		if(S!= none)
		{
			S.ShowSubtitle(SubtitleTag);
		}
	}

    return false;
}

defaultproperties
{
}