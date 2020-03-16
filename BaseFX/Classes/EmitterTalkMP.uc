///////////////////////////////////////////////////////////////////////////////
// EmitterTalkMP
//
// Simple object to fake multicasting so that emitters can be changed
// on all clients games. Emitters can't get changed normally by modifying
// the server's version.
//
///////////////////////////////////////////////////////////////////////////////
class EmitterTalkMP extends Keypoint;

var name GoHereState;		// Make this the next state the emitter owner goes to

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	local Emitter em;

	Super.PostNetBeginPlay();

	if(Level.NetMode != NM_DedicatedServer)
	{
		// Find your owner on this client and either change it's state, or
		// destroy it right then.
		foreach DynamicActors(class'Emitter', em)
		{
			if(em == Owner)
			{
				if(GoHereState != '')
					em.GotoState(GoHereState);
				else
					em.Destroy();
			}
		}
	}
}

defaultproperties
{
	bAlwaysRelevant=true
	Lifespan=3
	bStatic=false
	bNoDelete=false
}