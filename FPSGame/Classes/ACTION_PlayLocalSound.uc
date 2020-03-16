class ACTION_PlayLocalSound extends ScriptedAction;

var(Action)		sound	Sound;
var(Action)		array<Sound>	SoundList;
var(Action)		bool	bRandomizeSounds;	// If true, randomizes SoundList if non-empty, otherwise plays them sequentially.

var Sound UseSound;
var int SoundIndex;

function bool InitActionFor(ScriptedController C)
{
	local PlayerController P;

	// play appropriate sound
	PickSound();
		ForEach C.DynamicActors(class'PlayerController', P)
			P.ClientPlaySound(UseSound);
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
}

function string GetActionString()
{
	return ActionString@UseSound;
}

defaultproperties
{
	ActionString="play sound"
}
