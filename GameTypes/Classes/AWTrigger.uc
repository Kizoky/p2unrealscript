///////////////////////////////////////////////////////////////////////////////
// AWTrigger
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Only trigger your event after you've been triggered a certain number of times.
// And more stuff!
//
///////////////////////////////////////////////////////////////////////////////
class AWTrigger extends TriggerSuper;

var ()int TimesTillTrigger;		// Number of times you can be triggered before you trigger
								// your event. Must be in CountTriggers state to work.
var ()Sound TriggeredSound;		// Played each time a trigger is counted
var int UseTimes;				// To preserve TimesTillTrigger as the max, we use this during
								// actual triggers
var DudePlayer		PlayerWatch;// If a dude player is using us to count kills, notify him when
								// we're done
								
var Actor LastTriggerActor;		// Don't allow the same actor to trigger us twice, maybe?
var() bool bUniqueActorsOnly;	// If true, ignores repeat triggers from previous actor

// Other trigger turns this on.
state() CountTriggers
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ((bUniqueActorsOnly) && (LastTriggerActor == Other))
			return;
			
		LastTriggerActor = Other;
		UseTimes++;
		PlaySound(TriggeredSound,,TransientSoundVolume,,TransientSoundRadius,SoundPitch);

		if(UseTimes >= TimesTillTrigger)
		{
			TriggerEvent(Event, self, EventInstigator);
			if(PlayerWatch != None)
			{
				PlayerWatch.FinishKillCount(Tag);
				PlayerWatch = None;
			}
			// I'm done
			Destroy();
		}
	}
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.TriggerCounter'
	DrawScale=0.25
	bUniqueActorsOnly=true
	InitialState=CountTriggers
}
