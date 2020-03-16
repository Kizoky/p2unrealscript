///////////////////////////////////////////////////////////////////////////////
// SoundThing.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Plays sounds in a much more deluxe manner than basic Actors.
//
///////////////////////////////////////////////////////////////////////////////
//
// A SoundThing lets you specify one or more sounds along with a bunch of
// settings that determine how to play the sound(s).  For instance, you
// can set ranges for pitch, radius and volume, you can determine whether it
// repeats and how often, and so on.
//
// The SoundThing can be initially turned on or not (if not then the only
// way to turn it on is via a trigger).
//
// The SoundThing can be controlled by a Trigger.  There are multiple available
// trigger-related states, which are set using InitialState in the Object
// properties.  The first is where the trigger turns on the sound and it
// stays on.  The second is where the trigger turns off the sound (which is
// only useful if the sound is turned on initially).  And the last is where
// the trigger controls the sound directly, so it is on while the trigger
// is being triggered and turns off when the trigger is untriggered.
//
// The SoundRepeater is a useful object designed to allow you to use all
// the same sound settings in many different places in a level.  See that
// class for details.
//
///////////////////////////////////////////////////////////////////////////////
class SoundThing extends Actor
	placeable
	hidecategories(Collision,Force,Karma,LightColor,Lighting,Shadow);

#exec Texture Import File=Textures\SoundThing.pcx Name=SoundThingIcon Mips=Off MASKED=1


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

struct FloatRange
	{
	var() float Min;
	var() float Max;
	};

struct IntRange
	{
	var() int Min;
	var() int Max;
	};

enum ERandomMode
	{
	EPM_EveryTime,
	EPM_FirstTimeOnly,
	};

enum ERepeatMode
	{
	ERM_Infinite,
	ERM_Count,
	ERM_Once,
	};

// General settings (these stay the same throughout)
struct SGeneral
	{
	var() FloatRange			DelayBetweenRepeats;
	var() FloatRange			InitialDelay;
	var() ERepeatMode			RepeatMode;
	var() IntRange				RepeatCount;
	var() bool					bAttenuate;
	};

// Per-sound settings (these can change each time a sound is played)
struct SPerSound
	{
	var() ERandomMode			RandomMode;
	var() FloatRange			DelayAfterSound;
	var() FloatRange			PitchRange;
	var() FloatRange			RadiusRange;
	var() FloatRange			VolumeRange;
	};

// All settings are combined in a single struct (primarily to
// make it easy to copy them from one SoundThing to another)
struct SSettings
	{
	var() SGeneral				General;
	var() SPerSound				PerSound;
	var() array<Sound>			Sounds;
	};

var() bool							bInitiallyTurnedOn;
var(SoundThingSettings) SSettings	Settings;
var() Sound							ThisAmbientSound;
var() bool							bPickRandomSound;

var bool							bRunning;
var bool							bFirstTime;
var float							DelayBetweenRepeats;
var int								RepeatCount;
var int								SoundIndex;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
	{
	Super.PostBeginPlay();

	// Make sure there's at least one sound
	if (Settings.Sounds.Length >= 1
		|| ThisAmbientSound != None)
		{
		// If initially active then start it now (otherwise wait for triggers)
		if (bInitiallyTurnedOn)
			TurnOn();
		}
	else
		{
		// Disable trigger states since they won't work without sounds to play
		GotoState('');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Turn on
///////////////////////////////////////////////////////////////////////////////
function TurnOn()
	{
	local float InitialDelay;

	// This is the first time
	bFirstTime = true;
	// Setup general stuff
	DelayBetweenRepeats = PickFloat(Settings.General.DelayBetweenRepeats);
	InitialDelay = PickFloat(Settings.General.InitialDelay);
	if (Settings.General.RepeatMode == ERM_Count)
		RepeatCount = PickInt(Settings.General.RepeatCount);
	else
		RepeatCount = 0;

	// At this point we're officially up and running
	bRunning = true;

	// If there's an initial delay then setup the timer, otherwise
	// play the sound immediately
	if (InitialDelay > 0.0)
		SetTimer(InitialDelay, false);
	else
		PlayIt();
	}

///////////////////////////////////////////////////////////////////////////////
// Turn off
///////////////////////////////////////////////////////////////////////////////
function TurnOff()
	{
	bRunning = false;
	SetTimer(0.0, false);
	}

///////////////////////////////////////////////////////////////////////////////
// When the timer expires it's time to play the next sound.
///////////////////////////////////////////////////////////////////////////////
event Timer()
	{
	PlayIt();
	}

///////////////////////////////////////////////////////////////////////////////
// Play the current sound and if appropriate setup timer for next one
///////////////////////////////////////////////////////////////////////////////
function PlayIt()
	{
	local float TimeUntilNext;
	local Sound TheSound;
	local float DelayAfterSound;
	local float Pitch;
	local float Radius;
	local float Volume;

	// If they specified an ambient sound, set that now
	if(bRunning)
	{
		if(ThisAmbientSound != None)
			AmbientSound = ThisAmbientSound;
	}
	else	// Turn off the ambient sound (may not work)
		AmbientSound = None;

	// Only do this stuff if random mode is set for every time (or if it's the
	// first time we're playing any sound)
	if (Settings.PerSound.RandomMode == EPM_EveryTime || bFirstTime)
		{
		// Choose sound and settings
		if(Settings.Sounds.Length > 0)
		{
			// Pick any random sound in your array
			if(bPickRandomSound)
			{
				SoundIndex = Rand(Settings.Sounds.Length);
				TheSound = Settings.Sounds[SoundIndex];
			}
			else // find the next sound in your array
			{
				TheSound = Settings.Sounds[SoundIndex];
				SoundIndex++;
				if(SoundIndex >= Settings.Sounds.Length)
					SoundIndex=0;
			}
		}
		DelayAfterSound = PickFloat(Settings.PerSound.DelayAfterSound);
		Pitch = PickFloat(Settings.PerSound.PitchRange);
		Radius = PickFloat(Settings.PerSound.RadiusRange);
		Volume = PickFloat(Settings.PerSound.VolumeRange);
		}

	// Play sound using current settings
	PlaySound(TheSound, , Volume, false, Radius, Pitch, Settings.General.bAttenuate);

	// If using the counter, adjust it now
	if (Settings.General.RepeatMode == ERM_Count)
		RepeatCount--;

	// If counter still > 0 or if we're in infinite mode, set timer for next sound
	if (bRunning && (RepeatCount > 0 || Settings.General.RepeatMode == ERM_Infinite))
		{
		// Set timer to when the next sound should be played (note that we must
		// take the pitch into account to calculate the sound's duration)
		TimeUntilNext = (GetSoundDuration(TheSound) / Pitch) +
						DelayAfterSound +
						DelayBetweenRepeats;
		SetTimer(TimeUntilNext, false);
		}

	// Not the first time any more
	bFirstTime = false;
	}

///////////////////////////////////////////////////////////////////////////////
// Helper functions to pick values from range
///////////////////////////////////////////////////////////////////////////////
function float PickFloat(FloatRange range)
	{
	if (range.Max >= range.Min)
		return RandRange(range.Min, range.Max);
	return RandRange(range.Max, range.Min);
	}

function int PickInt(IntRange range)
	{
	if (range.Max >= range.Min)
		return range.Min + Rand((range.Max - range.Min) + 1);
	return range.Max + Rand((range.Min - range.Max) + 1);
	}

///////////////////////////////////////////////////////////////////////////////
// States are selected as per normal Unreal fashion, meaning you look under
// the "Object" section and set the "InitialState" to whatever you want.
///////////////////////////////////////////////////////////////////////////////

// Trigger turns on the sounds
state() TriggerTurnsOn
	{
	function Trigger(Actor Other, Pawn EventInstigator)
		{
		if (!bRunning)
			TurnOn();
		}
	}

// Trigger turns off the sounds
state() TriggerTurnsOff
	{
	function Trigger(Actor Other, Pawn EventInstigator)
		{
		if (bRunning)
			TurnOff();
		}
	}

// Trigger controls the sounds IN TOGGLE FASHION
// Doesn't use Untrigger
state() TriggerControls
	{
	function Trigger(Actor Other, Pawn EventInstigator)
		{
		if (!bRunning)
			TurnOn();
		else	// toggle it back off DO NOT REMOVE--scripts that trigger this can't
			// use Untrigger to turn it off, they must toggle it
			TurnOff();
		}
	}

// Trigger controls the sounds using only trigger/untrigger to turn it off. Calling
// trigger again after it's on *will not* toggle it off.
state() TriggerControlsNoToggle
	{
	function Trigger(Actor Other, Pawn EventInstigator)
		{
		if (!bRunning)
			TurnOn();
		}
	function Untrigger(Actor Other, Pawn EventInstigator)
		{
		if (bRunning)
			TurnOff();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bHidden=True
	Texture=Texture'PostEd.Icons_256.SoundThing'
	bInitiallyTurnedOn=true
	bPickRandomSound=true
	Settings=(General=(bAttenuate=true),PerSound=(PitchRange=(Min=1,Max=1),RadiusRange=(Min=100,Max=100),VolumeRange=(Min=1,Max=1)))
	DrawScale=0.25
	}
