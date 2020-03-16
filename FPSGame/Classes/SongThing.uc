///////////////////////////////////////////////////////////////////////////////
// SongThing.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Plays songs in a more deluxe manner than basic Actors.
//
///////////////////////////////////////////////////////////////////////////////
//
// What seemed quite simple because a little more complicated due primarily
// to the fact that triggers (which are commonly used to control this thing)
// can be made to generate a barrage of calls to Trigger() and Untrigger()
// (the trigger code is flaky).  If the song was set to fade out over some
// period of time, then the sound channel used by that song would not actually
// be free until that time had elapsed.  If another Trigger() occurred during
// that time, the song would be played again, but it would be using a new
// sound channel.  If this happened often enough (as it did in testing) then
// we would quicly use up the maximum of 8 song channels and the engine would
// crash.  I worked around this by using the timer to keep track of when the
// sound channel would actually be free, and only allowing a new song to be
// played after that time.
// 
///////////////////////////////////////////////////////////////////////////////
class SongThing extends Actor
	placeable
	native
	hidecategories(Collision,Force,Karma,LightColor,Lighting,Shadow);

#exec Texture Import File=Textures\SoundThing.pcx Name=SoundThingIcon Mips=Off MASKED=1


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////


var() bool							bInitiallyTurnedOn;		// If true, starts up automatically.

var() String						SongName;				// song (ex: "MySong.ogg")
var() float							FadeInTime;				// time (in seconds) to fade in song
var() float							FadeOutTime;			// time (in seconds) to fade out song
var() bool							bAttenuate;				// whether to attenuate song
var() float							AttenuateVolume;		// volume for song
var() float							AttenuateRadius;		// radius for song
var() float							VolumeOverride;			// If nonzero, overrides user's music volume setting with this value.

var() bool							bLegacy;				// If true, uses old broken legacy behavior for SongThing

var int								MusicHandle;			// Handle to currently playing music
var bool							bChannelInUse;			// Whether music is using a channel

var bool							bTurnedOn;
var bool							bDelayedStart;

var int								NumTriesToStart;


///////////////////////////////////////////////////////////////////////////////
// Turn on
///////////////////////////////////////////////////////////////////////////////
function TurnOn()
	{
	// First we end the currently playing song (if there is one).  The song
	// may end immediately, in which case we can start the new song now, or it
	// may take a while to fade out, in which case the new song will start
	// after the fade is finished.
	EndMusic();
	if (!bChannelInUse)
		StartMusic();
	else
		bDelayedStart = true;
	
	bTurnedOn = true;
//	Log("SongThing.TurnOn(): bDelayedStart="$bDelayedStart);
	}

///////////////////////////////////////////////////////////////////////////////
// Turn off
///////////////////////////////////////////////////////////////////////////////
function TurnOff()
	{
	// End the currently playing song (if there is one) and also prevent any
	// delayed start.  Note that there may still be a pending call to
	// Timer() which we don't want to interfere with because TurnOn() might
	// be called again and it will need to know whether the last song is
	// still playing (fading).
	EndMusic();
	bDelayedStart = false;

	bTurnedOn = false;
//	Log("SongThing.TurnOff()");
	}

///////////////////////////////////////////////////////////////////////////////
// Private function
// Start music
///////////////////////////////////////////////////////////////////////////////
function StartMusic()
	{
	if (bAttenuate)
		MusicHandle = FPSGameInfo(Level.Game).PlayMusicAttenuateExt(self, SongName, FadeInTime, AttenuateVolume, AttenuateRadius, 1.0, VolumeOverride, bLegacy);
	else
		MusicHandle = FPSGameInfo(Level.Game).PlayMusicExt(SongName, FadeInTime, VolumeOverride);

	if (MusicHandle != 0)
		bChannelInUse = true;

//	Log("SongThing.StartMusic(): MusicHandle="$MusicHandle@"Legacy"@bLegacy);
	}

///////////////////////////////////////////////////////////////////////////////
// Private function
// End music
///////////////////////////////////////////////////////////////////////////////
function EndMusic()
	{
	if (MusicHandle != 0)
		{
		FPSGameInfo(Level.Game).StopMusicExt(MusicHandle, FadeOutTime);
		MusicHandle = 0;
		if (FadeOutTime > 0.0)
			SetTimer(FadeOutTime, false);
		else
			bChannelInUse = false;
		}
//	Log("SongThing.EndMusic(): bChannelInUse="$bChannelInUse);
	}

///////////////////////////////////////////////////////////////////////////////
// Timer indicates that song has ended so it's safe to start a new song
///////////////////////////////////////////////////////////////////////////////
function Timer()
	{
	// Song has stopped playing
	bChannelInUse = false;

	// If there's a delayed start then start the new song now
	if (bDelayedStart)
		{
		StartMusic();
		bDelayedStart = false;
		}
	}


///////////////////////////////////////////////////////////////////////////////
// This state starts the music.  Music can't be started in PostBeginPlay()
// because the audio subsystem isn't ready until after that point.  There
// isn't any way to know when music can be started, so we simply keep trying
// until it works.
///////////////////////////////////////////////////////////////////////////////
auto state InternalStartUp
	{
Begin:
	// When I first wrote this I forgot to check bInitiallyTurnedOn.  Unfortunately,
	// many of these actors are already being used and we're only a few days away
	// from gold, so now is not a good time to change this because it could break
	// existing functionality.  This should be fixed some day.  In the meantime,
	// I changed bInitiallyTurnedOn so it isn't exposed in the editor.
	if (bInitiallyTurnedOn)
		{
		Sleep(0.5);
		NumTriesToStart = 0;
Retry:
		NumTriesToStart++;
		TurnOn();
		if (MusicHandle == 0)
			{
			Sleep(1.0);
			goto('Retry');
			}
//		Log(self @ "Started "$SongName$" in "$NumTriesToStart$" tries");
		}
	//GotoState('');
	}

///////////////////////////////////////////////////////////////////////////////
// States are selected as per normal Unreal fashion, meaning you look under
// the "Object" section and set the "InitialState" to whatever you want.
///////////////////////////////////////////////////////////////////////////////

// Trigger turns on song
state() TriggerTurnsOn extends InternalStartUp
	{
	function Trigger(Actor Other, Pawn EventInstigator)
		{
		if (!bTurnedOn)
			GotoState(GetStateName(), 'Retry');	// Attempt to turn on ASAP
		}
	}

// Trigger turns off song
state() TriggerTurnsOff extends InternalStartUp
	{
	function Trigger(Actor Other, Pawn EventInstigator)
		{
//		log("Triggered by"@Other@EventInstigator);
		if (bTurnedOn)
			TurnOff();
		}
	}

// Trigger controls the sounds IN TOGGLE FASHION
// Doesn't use Untrigger
state() TriggerControls extends InternalStartUp
	{
	function Trigger(Actor Other, Pawn EventInstigator)
		{
		if (!bTurnedOn)
			GotoState(GetStateName(), 'Retry');	// Attempt to turn on ASAP
		else	// toggle it back off DO NOT REMOVE--scripts that trigger this can't
			// use Untrigger to turn it off, they must toggle it
			TurnOff();
		}
	}

// Trigger controls the sounds using only trigger/untrigger to turn it off. Calling
// trigger again after it's on *will not* toggle it off.
state() TriggerControlsNoToggle extends InternalStartUp
	{
	function Trigger(Actor Other, Pawn EventInstigator)
		{
		if (!bTurnedOn)
			GotoState(GetStateName(), 'Retry');	// Attempt to turn on ASAP
		}
	function Untrigger(Actor Other, Pawn EventInstigator)
		{
		if (bTurnedOn)
			TurnOff();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bHidden=True
	Texture=Texture'PostEd.Icons_256.Music'
	bInitiallyTurnedOn=true
	bAttenuate=false
	AttenuateVolume=1.0
	AttenuateRadius=100.0
	FadeInTime=0.1
	FadeOutTime=0.1
	DrawScale=0.25
	bLegacy=True
	}
