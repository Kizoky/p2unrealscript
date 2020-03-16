///////////////////////////////////////////////////////////////////////////////
// A breakable prop.
// Adds a second mesh to be swapped out when the prop gets broken and an
// emitter slot for an accompanying effect.
///////////////////////////////////////////////////////////////////////////////

class PropBreakable extends Prop;

var ()float DamageThreshold;		// How much damage in a single shot you have to
									// do in order to break the prop
var ()float Health;					// How much health we have. At 0, we break
var ()class<P2Emitter> BreakEffectClass;	// Effect generated when you break the prop
var ()StaticMesh BrokenStaticMesh;	// Mesh subbed assigned to StaticMesh when the 
									// prop is broken
var ()bool bFitEffectToProp;		// Whether or not to attempt to make the effect
									// rotate to fit the prop.
var() sound BreakingSound;			// Sound played when it breaks

var() class<DamageType> DamageFilter;// Damage type we're concerned about.
									// To allow all damage types, have this be none (default)
var() bool bBlockFilter;			// true means you'll accept all damages except DamageFilter
									// false means you'll only accept DamageFilter.(default is false)
var() bool bTriggerControlled;		// Triggers are the only things that allow these kactors to explode, if true

var() class<TimedMarker>DangerMarker;// Danger notifier (if any) this makes when broken


///////////////////////////////////////////////////////////////////////////////
// Orient the breaking effect and size it
///////////////////////////////////////////////////////////////////////////////
function FitTheEffect(P2Emitter pse, int damage, vector HitLocation, vector HitMomentum)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Triggers explosion
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	local vector Momentum, HitLocation;
	local float tempf;

	Super.Trigger(Other, EventInstigator);
	
	tempf = CollisionRadius/2;
	HitLocation.x = Location.x + (CollisionRadius*FRand() - tempf);
	HitLocation.y = Location.y + (CollisionRadius*FRand() - tempf);
	HitLocation.z = Location.z;

	Instigator = EventInstigator;
	BlowThisUp(1, HitLocation, Momentum); // momentum gets initted in this function, so don't worry about
			// setting it before hand
	return;
}

///////////////////////////////////////////////////////////////////////////////
// If DamageFilter is set, 
// and bBlockFilter is false only allow this damage
// else don't allow only this damage
///////////////////////////////////////////////////////////////////////////////
function bool AcceptThisDamage(class<DamageType> damageType)
{
	if(bTriggerControlled)
		return false;

	if(DamageFilter != None)
	{
		// accept only filter
		if(!bBlockFilter)
		{
			if(!ClassIsChildOf(DamageFilter, damageType))
				return false;
		}
		else	// block the filter type
		{
			if(ClassIsChildOf(DamageFilter, damageType))
				return false;
		}
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Set it to dead, trigger sounds and all, and blow it up, setting off the physics
///////////////////////////////////////////////////////////////////////////////
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

	// Trigger breaking event, if any.
	if (Event != '')
		TriggerEvent(Event, self, Instigator);
}

///////////////////////////////////////////////////////////////////////////////
// If strong enough, it breaks the prop
///////////////////////////////////////////////////////////////////////////////
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local TimedMarker ADanger;

	// Check first if we take this damage
	if(!AcceptThisDamage(damageType))
		return;

	// If so, check to make panic noises for people around us.
	// Only panic, if the damage before us *didn't* make some kind of
	// panic noise (like a bullet hitting this would, and so would an
	// explosion)
	if(DangerMarker != None
		&& (ClassIsChildOf(damageType, class'CuttingDamage')
			|| ClassIsChildOf(damageType, class'BludgeonDamage')))
	{
		ADanger = spawn(DangerMarker,,,HitLocation);
		ADanger.CreatorPawn = FPSPawn(InstigatedBy);
		ADanger.OriginActor = self;
		// This will cause people to see if they noticed and decide what to do
		ADanger.NotifyAndDie();
	}

	// Only remove health if the singular damage was strong enough
	if(damage > DamageThreshold)
	{
		Health -= damage;
		// if you run out of health, break
		if(Health <= 0)
		{
			Instigator = InstigatedBy;
			BlowThisUp(Damage, HitLocation, Momentum);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Broken
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Broken
{
	ignores TakeDamage;

	///////////////////////////////////////////////////////////////////////////////
	// You've just been freshly broken, generate effects
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		// Swap the mesh to the broken mesh if you have one
		if(BrokenStaticMesh != None)
		{
			SetDrawType(DT_StaticMesh);
			SetStaticMesh(BrokenStaticMesh);
		}
		else	// If we don't have a broken mesh, they don't want to
				// see it anymore, so just destroy it
		{
			if (P2GameInfoSingle(Level.Game) != None
				&& P2GameInfoSingle(Level.Game).TheGameState != None)
				// record as being broken in the gamestate
				P2GameInfoSingle(Level.Game).TheGameState.AddPersistentWindow(self);
			Destroy();
		}
	}
}

defaultproperties
{
	bFitEffectToProp=true
    SoundVolume=255
}

