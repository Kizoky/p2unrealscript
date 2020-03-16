///////////////////////////////////////////////////////////////////////////////
// SoundVolume
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
class SoundVolume extends PhysicsVolume;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
struct SoundDef
{
	var() sound Sound;					// Sound to play
	var() ESoundSlot Slot;				// Sound slot
	var() float Volume;					// Volume
	var() float Pitch;					// Pitch
	var() bool bAttenuate;				// Attenuation
	var() vector RelativeLocation;		// Location relative to player
};

var(Sound) array<SoundDef> Sounds;		// Definition of sounds
var array<SoundActor> SoundActors;		// One for each defined sound

///////////////////////////////////////////////////////////////////////////////
// PawnEnteredVolume
// Attach our sound actor, position it accordingly, and set its sound
///////////////////////////////////////////////////////////////////////////////
event PawnEnteredVolume(Pawn Other)
{
	local int i;
	
	Super.PawnEnteredVolume(Other);
	if (Other.Controller.bIsPlayer)
	{
		for (i=0; i < Sounds.Length; i++)
		{
			SoundActors[i] = Spawn(class'SoundActor',,, Other.Location);
			Other.AttachToBone(SoundActors[i], 'MALE01');
			SoundActors[i].SetRelativeLocation(Sounds[i].RelativeLocation);
			SoundActors[i].AmbientSound = Sounds[i].Sound;
		}
	}
}

event PawnLeavingVolume(Pawn Other)
{
	local int i;
	
	Super.PawnLeavingVolume(Other);
	if (Other.Controller.bIsPlayer)
	{
		for (i=0; i < Sounds.Length; i++)
		{
			SoundActors[i].AmbientSound = None;
			SoundActors[i].Destroy();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
}