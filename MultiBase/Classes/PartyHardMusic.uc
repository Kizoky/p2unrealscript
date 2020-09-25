//=============================================================================
// PartyHardMusic.uc
// From: xAdmin 2.02
// Author: Kamek
//=============================================================================

class PartyHardMusic extends Actor
	config(MultiplayerMusic);

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var bool							bInitiallyTurnedOn;		// Don't expose in editor until code uses it (see explanation elsewhere)
var() String						SongName;				// song (ex: "MySong.ogg")
var() float							FadeInTime;				// time (in seconds) to fade in song
var() float							FadeOutTime;			// time (in seconds) to fade out song
var() bool							bAttenuate;				// whether to attenuate song
var() float							AttenuateVolume;		// volume for song
var() float							AttenuateRadius;		// radius for song
var int								MusicHandle;			// Handle to currently playing music
var bool							bChannelInUse;			// Whether music is using a channel
var bool							bTurnedOn;
var bool							bDelayedStart;
var int								NumTriesToStart;

/// Nick's change 01/04/2017
var globalconfig array<string> SongNames;

replication
{
	reliable if (Role == ROLE_Authority)
		TurnOn, TurnOff;

	unreliable if (Role == ROLE_Authority)
		SongName, FadeInTime, FadeOutTime, bAttenuate, AttenuateVolume, AttenuateRadius;
}

/// Nick's change 01/04/2017
simulated function PostBeginPlay()
{
	SongName = SongNames[Rand(SongNames.Length-1)];
	if( SongName == "" )
		SongName = default.SongName;
	Super.PostBeginPlay();
}

simulated event PostNetBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
		GotoState('InternalStartup');
}

///////////////////////////////////////////////////////////////////////////////
// Turn on
///////////////////////////////////////////////////////////////////////////////
simulated function TurnOn()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

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
}

///////////////////////////////////////////////////////////////////////////////
// Turn off
///////////////////////////////////////////////////////////////////////////////
simulated function TurnOff()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

	// End the currently playing song (if there is one) and also prevent any
	// delayed start.  Note that there may still be a pending call to
	// Timer() which we don't want to interfere with because TurnOn() might
	// be called again and it will need to know whether the last song is
	// still playing (fading).
	EndMusic();
	bDelayedStart = false;

	bTurnedOn = false;
}

///////////////////////////////////////////////////////////////////////////////
// Private function
// Start music
///////////////////////////////////////////////////////////////////////////////
simulated function StartMusic()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (bAttenuate)
		MusicHandle = PlayMusicAttenuate(SongName, FadeInTime, AttenuateVolume, AttenuateRadius, 1.0);
	else
		MusicHandle = PlayMusic(SongName, FadeInTime);

	if (MusicHandle != 0)
		bChannelInUse = true;
}

///////////////////////////////////////////////////////////////////////////////
// Private function
// End music
///////////////////////////////////////////////////////////////////////////////
simulated function EndMusic()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (MusicHandle != 0)
	{
		StopMusic(MusicHandle, FadeOutTime);
		MusicHandle = 0;
		if (FadeOutTime > 0.0)
			SetTimer(FadeOutTime, false);
		else
			bChannelInUse = false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Timer indicates that song has ended so it's safe to start a new song
///////////////////////////////////////////////////////////////////////////////
simulated function Timer()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

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
simulated state InternalStartUp
{
Begin:
	// When I first wrote this I forgot to check bInitiallyTurnedOn.  Unfortunately,
	// many of these actors are already being used and we're only a few days away
	// from gold, so now is not a good time to change this because it could break
	// existing functionality.  This should be fixed some day.  In the meantime,
	// I changed bInitiallyTurnedOn so it isn't exposed in the editor.
	if (true)
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
		//Log(self @ "Started "$SongName$" in "$NumTriesToStart$" tries");
	}
	GotoState('');
}

defaultproperties
{
	SongNames(0)="uncledave_heavymetal.ogg"
	SongNames(1)="AFTBStoleMyFaith.ogg"
	SongNames(2)="OnSilentWings.ogg"
	SongNames(3)="OnSilentWings.ogg"

     bInitiallyTurnedOn=True
     SongName="uncledave_heavymetal.ogg"
     FadeInTime=0.100000
     FadeOutTime=0.100000
     AttenuateVolume=2.000000
     AttenuateRadius=200.000000
     bHidden=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     Texture=Texture'FPSGame.SoundThingIcon'
     SoundVolume=150
}
