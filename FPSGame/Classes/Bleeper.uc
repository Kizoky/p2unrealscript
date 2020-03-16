///////////////////////////////////////////////////////////////////////////////
// Bleeper
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Bleeps out offensive language.
//
///////////////////////////////////////////////////////////////////////////////
class Bleeper extends Actor;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var bool				bInUse;
var Pawn				BleepPawn;
var float				BleepVolume;
var float				BleepRadius;
var float				BleepTime2;
var float				BleepTime3;
var array<Sound>		BleepSounds;
var int					BleepIndex;


///////////////////////////////////////////////////////////////////////////////
// Check if this bleeper is available
///////////////////////////////////////////////////////////////////////////////
function bool IsAvailable()
	{
	return !bInUse;
	}

///////////////////////////////////////////////////////////////////////////////
// Play the bleep.  The location, volume and radius should match with the
// pawn playing the actual dialog.  The delay indicates how long from now the
// beep should start playing.
///////////////////////////////////////////////////////////////////////////////
function Bleep(Pawn ThePawn, float Volume, float Radius, float Time1, float Time2, float Time3)
	{
	if (Time1 > 0.0)
		{
		// Save info
		BleepPawn = ThePawn;
		BleepVolume = Volume;
		BleepRadius = Radius;

		// Convert times so they're relative to previous time.
		// It's okay if the times cause the beeps to overlap because if we
		// play the next beep before the previous beep is finished, the new
		// beep will simply cut off the old beep.
		if (Time2 > 0.0)
			{
			BleepTime2 = Time2 - Time1;
			}
		else
			BleepTime2 = 0.0;
		if (Time3 > 0.0)
			BleepTime3 = Time3 - Time2;
		else
			BleepTime3 = 0.0;

		// Set timer for first bleep
		SetTimer(Time1, false);

		// Set location now in case pawn is killed before we play the beep
		// (this would probably be close enough, but in case the pawn is
		// running fast or drops off a cliff, we'll update the location
		// again just before the beep is played)
		SetLocation(BleepPawn.Location);

		bInUse = true;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// When timer expires, it's time to play the beep
///////////////////////////////////////////////////////////////////////////////
event Timer()
	{
	// If pawn still exists, refresh our location
	if (BleepPawn != None)
		SetLocation(BleepPawn.Location);

	// Always play bleep, even if pawn was deleted (we assume that the
	// line of dialog was played, and once played, there's no stopping
	// it, so we still need the beep)
	PlaySound(BleepSounds[BleepIndex], SLOT_Talk, BleepVolume, false, BleepRadius, 1.0);

	// Use next bleep sound
	BleepIndex++;
	if (BleepIndex == BleepSounds.length)
		BleepIndex = 0;

	// Check for additional bleeps for this line of dialog
	if (BleepTime2 > 0.0)
		{
		SetTimer(BleepTime2, false);
		BleepTime2 = 0.0;
		}
	else if (BleepTime3 > 0.0)
		{
		SetTimer(BleepTime3, false);
		BleepTime3 = 0.0;
		}
	else
		{
		bInUse = false;
		}
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	BleepSounds(0)=Sound'MiscSounds.Bleeps.Bleep0'
	BleepSounds(1)=Sound'MiscSounds.Bleeps.Bleep1'
	BleepSounds(2)=Sound'MiscSounds.Bleeps.Bleep2'
	BleepSounds(3)=Sound'MiscSounds.Bleeps.Bleep3'
	}
