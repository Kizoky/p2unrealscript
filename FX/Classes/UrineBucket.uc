///////////////////////////////////////////////////////////////////////////////
// UrineBucket
//
// Used to have something (probably the dude) piss in/on and it
// through TakeDamage, record how much piss has been hitting it. 
// 
// Note that this object decides the volume per hit--no the stream
// hitting it. Yes, it's backwards, but that's so we can easily
// use TakeDamage and send a Damage=0 so other things won't get actually
// hurt by urine hitting them. We'd have to do a lot of checks otherwise
// in lots of other Actors.
//
// It's in FX because while it fits better in Postal2Game it needs to 
// access UrineDamage that's defined later. While it's not a effect itself,
// it is driven by them.
///////////////////////////////////////////////////////////////////////////////
class UrineBucket extends StaticMeshActor;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
var ()float VolumeNeededInSecs;	// How much volume you need to trigger your event.
							// This is how many second you'll have to pee on it
							// consistently to trigger it
var float	CurrentVolume;	// How much we currently have.

var ()bool	bTriggerErrands;// Defaults to true, saying we'll use this to trigger
							// an errand. If it's true, it will only
							// cause the event to be triggered, if the errand 
							// was completed. If false, it will trigger the
							// event based solely on if it has hit the volume needed.
var ()int  TimesToUse;		// 0 for infinite, defaults to 1. If over 0, then
							// each time it's used the thing is reset until the
							// count is 0.

var float SavedDeltaTime;	// Used for damage to volume calculations.

///////////////////////////////////////////////////////////////////////////////
// Set how much volume we have
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
	CurrentVolume = VolumeNeededInSecs;
}

///////////////////////////////////////////////////////////////////////////////
// Only allow UrineDamage to register with us.
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local P2Player p2p;
	local P2GameInfoSingle checkg;
	local bool bErrandComplete;

	//log(self$" hit by "$instigatedby$" damage was "$DamageType);
	// only allow piss to do anything to us
	if(damageType == class'UrineDamage'
		&& CurrentVolume > 0)
	{
		CurrentVolume-=SavedDeltaTime;
		// We've reached out necessary volume, try for an errand completion
		// and trigger our event
		if(CurrentVolume <= 0)
		{
			if(InstigatedBy != None)
				p2p = P2Player(InstigatedBy.Controller);
			if(p2p != None)
			{
				checkg = P2GameInfoSingle(Level.Game);
				if(checkg != None)
				{
					bErrandComplete = checkg.CheckForErrandCompletion(self, None, InstigatedBy, p2p, false);
				}
			}

			//log(self$" quota met ec "$bErrandComplete$" trigger "$bTriggerErrands$" event "$Event);

			// Only trigger our event if we want to do it only on errand completion
			// or just do it because we have enough volume.
			if((bTriggerErrands && bErrandComplete)
				|| !bTriggerErrands)
				// Broadcast the Trigger message to all matching actors.
				TriggerEvent(Event, self, instigatedBy);

			// Check for reuse
			if(TimesToUse > 0)
			{
				TimesToUse--;
				// Check if that was our last time
				if(TimesToUse == 0)
				{
					CurrentVolume=0;	// this won't allow it to take damage anymore
					return;
				}
			}
			// If we're here, we can reset the volume count and start again
			CurrentVolume=VolumeNeededInSecs;
		}
	}
	// reset the time we just used
	SavedDeltaTime=0;
}

function Tick(float DeltaTime)
{
	// Save the time we've ticked by so if we get hit, we can use it to check 
	// for 'damage'
	SavedDeltaTime=DeltaTime;
}

defaultproperties
{
	bStatic=false
	VolumeNeededInSecs=2.0
	TimesToUse=1
	bTriggerErrands=false
    StaticMesh=StaticMesh'Timb_mesh.home.urinal_timb'
}
