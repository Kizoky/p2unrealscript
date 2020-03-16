class ACTION_SayList extends LatentScriptedAction;

var(Action) array<sound> SoundList;
var(Action)	float Volume;
var(Action)	bool bYell;
var(Action) bool bAllowRepeats;
var(Action)	bool bWaitUntilFinished;
var(Action) bool bRandomizeSayList;
var(Action)	float Radius;

var	bool bAttenuate;
var int SoundListIndx;

function bool InitActionFor(ScriptedController C)
{
	local PersonPawn pp;
	local int i;
	local float duration;
	local bool bWait;

	if (bRandomizeSayList)
	    SoundListIndx = Rand(SoundList.length);
	else
	{
        SoundListIndx++;

	    if (SoundListIndx >= SoundList.length)
	        SoundListIndx = 0;
    }

    // That's gay, we can't use ternary operators. :(
    //SoundListIndx = SoundListIndx >= SoundList.length ? 0 : SoundListIndx;

	pp = PersonPawn(C.GetSoundSource());

	if (pp != None && pp.MyHead != None && SoundList[SoundListIndx] != None)
	{
		pp.PlaySound(SoundList[SoundListIndx], SLOT_Interact, Volume, false, Radius, pp.VoicePitch);
		duration = pp.GetSoundDuration(SoundList[SoundListIndx]) / pp.VoicePitch;

		if (!bAllowRepeats)
		    SoundList.Remove(SoundListIndx, 1);

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
	return ActionString@SoundList[SoundListIndx];
}

defaultproperties
{
     Volume=1.000000
     bWaitUntilFinished=True
     Radius=300.000000
     SoundListIndx=-1
     ActionString="say"
}
