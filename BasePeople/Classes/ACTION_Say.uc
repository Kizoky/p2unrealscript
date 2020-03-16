class ACTION_Say extends LatentScriptedAction;

var(Action)		sound	Sound;					// Line to be spoken
var(Action)		float	Volume;					// Volume to play sound
var				bool	bAttenuate;				// no longer used but not deleted to avoid possible load/save problems
var(Action)		bool	bYell;					// Whether we should yell or not
var(Action)		bool	bWaitUntilFinished;		// If true, do not advance to the next action until the sound is finished playing
var(Action)		float	Radius;					// Radius to play sound

function bool InitActionFor(ScriptedController C)
{
	local PersonPawn pp;
	local float duration;
	local bool bWait;

	pp = PersonPawn(C.GetSoundSource());
	if (pp != None && pp.MyHead != None && Sound != None)
	{
		pp.PlaySound(Sound, SLOT_Interact, Volume, bYell, Radius, pp.VoicePitch);
		duration = pp.GetSoundDuration(Sound) / pp.VoicePitch;
		if(bYell)
			Head(pp.MyHead).Yell(duration);
		else
			Head(pp.MyHead).Talk(duration);

		if (bWaitUntilFinished)
			{
			C.CurrentAction = self;
			C.SetTimer(duration, false);
			bWait = true;
			}
	}

	return bWait;
}

function bool CompleteWhenTimer()
{
	return bWaitUntilFinished;
}

function string GetActionString()
{
	return ActionString@Sound;
}

defaultproperties
{
	ActionString="say"
	Volume=+1.0
	Radius=300
}