// 11/10/14 - Backported fix to regular PropBreakable, this class is no longer needed - Rick

///////////////////////////////////////////////////////////////////////////////
// A breakable prop.
// Adds a second mesh to be swapped out when the prop gets broken and an
// emitter slot for an accompanying effect.
//
// Bug fixed where the emitter *is not* now given this 'self' as it's owner
// becuase it messes up the game time that is given to the effect to operate with.
///////////////////////////////////////////////////////////////////////////////
class AWPropBreakable extends PropBreakable
	notplaceable;


///////////////////////////////////////////////////////////////////////////////
// Set it to dead, trigger sounds and all, and blow it up, setting off the physics
///////////////////////////////////////////////////////////////////////////////
/*
function BlowThisUp(int Damage, vector HitLocation, vector Momentum)
{
	local P2Emitter p2e;

	// Say we're broken so we won't break anymore
	GotoState('Broken');

	// set to dead
	Health=0;

	// Spawn effect so we don't have to record the hit values and 
	// do it later in Broken beginstate or something. It's just
	// more efficient here
	p2e = spawn(BreakEffectClass,,,Location);
	if(bFitEffectToProp)
		FitTheEffect(p2e, damage, HitLocation, momentum);

	// Play the breaking sound (code copied from mover)
	PlaySound( BreakingSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, 0.96 + FRand()*0.8);
}

defaultproperties
{
}
*/
