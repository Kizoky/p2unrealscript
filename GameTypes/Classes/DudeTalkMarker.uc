///////////////////////////////////////////////////////////////////////////////
// Apocalypse Weekend DudeTalkMarker
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Keeps track of the dude complaining about something every once in a while.
// Doesn't travel, is usually instigated through scripted actions.
//
///////////////////////////////////////////////////////////////////////////////
class DudeTalkMarker extends Keypoint;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var float WaitTime;
var float WaitTimeRand;		// random extra added to waittime each wait
var float RedoTime;
var array<Sound> DudeSaying;
var float UseVolume;
var float UseRadius;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Waiting
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function SayThing()
	{
		local int i;
		local P2Pawn usepawn;
		local float usetime;

		log(self$" say thing "$Owner);

		if(DudeSaying.Length > 0
			&& AWPlayer(Owner) != None
			&& AWPlayer(Owner).Pawn != None
			&& AWPlayer(Owner).Pawn.Health > 0)
		{
			// Check if he's already talking, if so, wait a second
			if(!AWPlayer(Owner).bStillTalking)
			{
				i = Rand(DudeSaying.Length);
				log(self$" num of sounds "$DudeSaying.Length$" pick num "$i);
				usepawn = P2Pawn(AWPlayer(Owner).Pawn);
				usepawn.PlaySound(
					DudeSaying[i],			// sound
					SLOT_Talk,				// slot (see ESoundSlot)
					UseVolume,				// volume (0.0 to 1.0)
					false,					// no override (true=don't let next sound interrupt this one)
					UseRadius,				// radius (attenuation starts at radius)
					usepawn.VoicePitch);	// pitch (0.5 to 2.0)
				// Mark that we said something
				AWPlayer(Owner).bStillTalking=true;
				usetime = usepawn.GetSoundDuration(DudeSaying[i]) / usepawn.VoicePitch;
				log(self$" say time "$usetime);
				AWPlayer(Owner).SetTimer(usetime, false);
			}
			else
				GotoState(GetStateName(), 'QuickWait');
		}
	}

QuickWait:
	Sleep(RedoTime);
	goto('PlaySound');
Begin:
	Sleep(WaitTime + FRand()*WaitTimeRand);

PlaySound:
	SayThing();
	goto('Begin');
}

defaultproperties
{
	WaitTime=5.000000
	RedoTime=1.000000
	UseVolume=1.000000
	UseRadius=256.000000
	bStatic=False
	bCollideActors=True
	bBlockZeroExtentTraces=False
	bBlockNonZeroExtentTraces=False
	Texture=Texture'PostEd.Icons_256.DudeTalkMarker'
	DrawScale=0.25
}
