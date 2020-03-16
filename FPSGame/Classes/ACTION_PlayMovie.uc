class ACTION_PlayMovie extends LatentScriptedAction;

var(Action)		string	MovieFileName;
var(Action)		sound	Sound;
var(Action)		bool	bWaitUntilFinished;

function bool InitActionFor(ScriptedController C)
{
	local FPSPlayer P;
	local float duration;
	local bool bWait;

	if (MovieFileName != "" && Sound != None)
	{
		foreach C.AllActors(class'FPSPlayer', P)
			break;
		if (P != None && P.myHud != None)
		{
			P.myHud.PlayMovieScaled(MovieTexture(DynamicLoadObject("MovieTextures.Generic", class'MovieTexture')), MovieFileName, 0, 0, 1, 1, false, false); 

			C.GetSoundSource().PlaySound(Sound, SLOT_Interact, 1.0, , , , );

			if (bWaitUntilFinished)
			{
				C.CurrentAction = self;
				C.SetTimer(C.GetSoundSource().GetSoundDuration(Sound), false);
				bWait = true;
			}
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
	return ActionString @ MovieFileName @ Sound;
}

defaultproperties
{
	ActionString="play movie"
}
