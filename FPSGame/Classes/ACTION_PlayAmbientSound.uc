class ACTION_PlayAmbientSound extends ScriptedAction;

var(Action)		sound	AmbientSound;
var(Action)		array<Sound>	SoundList;
var(Action)		byte	SoundVolume;
var(Action)		byte	SoundPitch;
var(Action)		float	SoundRadius;
var(Action)		bool	bRandomizeSounds;	// If true, randomizes SoundList if non-empty, otherwise plays them sequentially.

var Sound UseSound;
var int SoundIndex;

function bool InitActionFor(ScriptedController C)
{
	// play appropriate sound
	PickSound();
	if ( AmbientSound != None )
	{
		C.SequenceScript.AmbientSound = UseSound;
		C.SequenceScript.SoundVolume = SoundVolume;
		C.SequenceScript.SoundPitch = SoundPitch;
		C.SequenceScript.SoundRadius = SoundRadius;
	}
	return false;	
}

function PickSound()
{
	// If sound list is empty, use pre-defined sound
	if (SoundList.Length == 0)
		UseSound = AmbientSound;
	else if (bRandomizeSounds)
		UseSound = SoundList[Rand(SoundList.Length)];
	else
	{
		UseSound = SoundList[SoundIndex];
		SoundIndex++;
		if (SoundIndex >= SoundList.Length)
			SoundIndex = 0;
	}
}

function string GetActionString()
{
	return ActionString@UseSound;
}

defaultproperties
{
	ActionString="play ambient sound"
    SoundRadius=64
    SoundVolume=128
    SoundPitch=64
}
