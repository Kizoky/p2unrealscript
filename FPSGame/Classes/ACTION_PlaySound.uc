class ACTION_PlaySound extends ScriptedAction;

var(Action)		sound	Sound;				// Sound to play
var(Action)		array<Sound>	SoundList;	// Picks a random sound to play
var(Action)		float	Volume;				// Sound volume
var(Action)		float	Pitch;				// Sound pitch
var(Action)		float	Radius;				// Playback radius
var(Action)		bool	bAttenuate;			// Whether to attenuate sound
var(Action)		bool	bNoOverride;		// If true, prevents other sounds from overriding this one
var(Action)		bool	bRandomizeSounds;	// If true, randomizes SoundList if non-empty, otherwise plays them sequentially.
var(Action)		bool	bPlayHere;			// If true, sound played on scripted sequence location, else sound played on pawn location.

var Sound UseSound;
var int SoundIndex;

function bool InitActionFor(ScriptedController C)
{
	PickSound();
	
	// play appropriate sound
	if (Sound != None)
	{
		if (bPlayHere)
		{
			C.SequenceScript.PlaySound(UseSound, SLOT_Interact, Volume, bNoOverride, Radius, Pitch, bAttenuate);
		}
		else
		{
			C.GetSoundSource().PlaySound(UseSound, SLOT_Interact, Volume, bNoOverride, Radius, Pitch, bAttenuate);
		}
	}
	return false;	
}

function PickSound()
{
	// If sound list is empty, use pre-defined sound
	if (SoundList.Length == 0)
		UseSound = Sound;
	else if (bRandomizeSounds)
		UseSound = SoundList[Rand(SoundList.Length)];
	else
	{
		UseSound = SoundList[SoundIndex];
		SoundIndex++;
		if (SoundIndex >= SoundList.Length)
			SoundIndex = 0;
	}
	// Sanity check
	if (UseSound == None)
		UseSound = Sound;
}

function string GetActionString()
{
	return ActionString@UseSound;
}

defaultproperties
{
	ActionString="play sound"
	Volume=+1.0
	Pitch=+1.0
	bAttenuate=true
	bNoOverride=false
}
