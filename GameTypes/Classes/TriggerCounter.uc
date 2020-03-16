///////////////////////////////////////////////////////////////////////////////
// TriggerCounter
//
// Basically the AW Trigger, but without the player-kill stuff.
// Use this to count stuff for achievements
///////////////////////////////////////////////////////////////////////////////
class TriggerCounter extends TriggerSuper;

var ()int TimesTillTrigger;		// Number of times you can be triggered before you trigger
								// your event. Must be in CountTriggers state to work.

var() bool bRepeatable;			// If true, can be triggered over and over again so long
								// as the number of triggers is met
								
var int UseTimes;				// To preserve TimesTillTrigger as the max, we use this during
								// actual triggers
								
/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	UseTimes = 0;
}

// Other trigger turns this on.
state() CountTriggers
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (bInitiallyActive)
		{
			UseTimes++;
			if(UseTimes >= TimesTillTrigger)
			{
				TriggerEvent(Event, self, EventInstigator);
				// Repeat y/n?
				if (bRepeatable)
					UseTimes = 0;
				else
				// I'm done
					bInitiallyActive = false;
			}
		}
	}
}

// Most of these are going to be triggered by ScriptedTriggers and the like, so default to no player interaction
defaultproperties
{
	InitialState=CountTriggers
	bCollideActors=False
	Texture=Texture'PostEd.Icons_256.TriggerCounter'
	DrawScale=0.25
}
