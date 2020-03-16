class ACTION_ShutUp extends P2ScriptedAction;

var Sound SilentSound;

function bool InitActionFor(ScriptedController C)
{
	local PersonPawn pp;

	pp = PersonPawn(C.GetSoundSource());
	if (pp != None && pp.MyHead != None)
	{
		pp.PlaySound(SilentSound, SLOT_Interact);
		Head(pp.MyHead).Talk(0.01);
	}

	return false;
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="shut up"
	SilentSound=Sound'QuietMiscSounds.Shaddup.Silence'
}
