/**
 * PLPointsKActorExplodable
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Like the PLPointsKActor but subclasses from KActorExplodable instead
 *
 * @author Gordon Cheng
 * adapted to KActorExplodable by Rick F
 */
class PLPointsKActorExplodable extends KActorExplodable;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() float PeeHealth;		// How much "pee health" we have. If zero, cannot destroy with pee
var() int Points;			// Number of points awarded upon destruction
var(Events) name DestroyedEvent;	// Event to trigger when destroyed.
var(KActorExplodable) class<P2Emitter> ExtraExplosionEffect;	// Another emitter to spawn when destroyed
var(KActorExplodable) array<Material> DamageSkins;	// Multiple-skin version of DamageSkin, if you need it.

var float TickDeltaTime;
var AWTrigger CounterTrigger;
var bool bUsePeeHealth;

/**
 * Overriden so we can perform the intensive process of finding our AWTrigger
 * at the beginning of gameplay
 */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    foreach DynamicActors(class'AWTrigger', CounterTrigger, Event)
        if (CounterTrigger != none)
            break;

    if (CounterTrigger == none)
        log("ERROR: Unable to find AWTrigger");

	if (PeeHealth > 0)
		bUsePeeHealth = true;
}

///////////////////////////////////////////////////////////////////////////////
// Set it to dead, trigger sounds and all, and blow it up, setting off the physics
///////////////////////////////////////////////////////////////////////////////
function BlowThisUp(vector HitLocation, vector Momentum)
{
	local Actor A;
	local P2Emitter Asplosion;
	local int i;
	
	// Can't blow up twice
	if(bBlownUp)
		return;

	if (CounterTrigger != None)
	{
		// add up points for the AWTrigger
		CounterTrigger.UseTimes += Points - 1;

		// Don't actually trigger it here, it'll get triggered in Super.BlowThisUp
		// with the KActorExplodable's general Event trigger.
		/*
		// Finally we Trigger it so it does anything it has to do
		CounterTrigger.Trigger(self, EventInstigator);
		*/
	}	

	// Trigger any extra actors when destroyed
	TriggerEvent(DestroyedEvent, Self, Instigator);
	
	Super.BlowThisUp(HitLocation, Momentum);
	
	//PlaySound(ExplodingSound,SLOT_Interact);
	// Make an asplosion
	// KActorExplodable has its own a splode effects, but we might want to null those and attach our own P2Emitter.
	if (ExtraExplosionEffect != None)
	{
		Asplosion = Spawn(ExtraExplosionEffect, , , Location, Rotation);
		if (Asplosion != None)
		{
			Asplosion.Instigator = Instigator;
			Asplosion.SetBase(Self);
		}
	}
	
	// Set multiple destroyed skins, if they specified them
	for (i = 0; i < DamageSkins.Length; i++)
		if (DamageSkins[i] != None)
			Skins[i] = DamageSkins[i];	
}

// Super handles regular damage and destruction trigger, so we just check for "pee health" here
function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType) {

	local int i;
	local P2Emitter Asplosion;
	local Actor A;
	local float tempf;

    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

    if (Health == 0 || (PeeHealth <= 0 && bUsePeeHealth))
        return;

	// Take "pee" damage
	if (ClassIsChildOf(DamageType, class'UrineDamage')
		&& bUsePeeHealth)
	{
		// KActors don't get ticks until they wake up, so have pee damage wake 'em up, then we can count pee damage dT accurately.
		KWake();
		PeeHealth -= TickDeltaTime;

		// Once the dude's peed on it enough, consider it destroyed
		if (PeeHealth <= 0)
		{
			tempf = CollisionRadius/2;
			HitLocation.x = Location.x + (CollisionRadius*FRand() - tempf);
			HitLocation.y = Location.y + (CollisionRadius*FRand() - tempf);
			HitLocation.z = Location.z;

			BlowThisUp(HitLocation, Momentum); // momentum gets initted in this function, so don't worry about
					// setting it before hand
		}
	}
}

/** Overriden so we can record the DeltaTime value for measuring urine damage */
function Tick(float DeltaTime) {
    super.Tick(DeltaTime);

    TickDeltaTime = DeltaTime;
}

defaultproperties
{
    Health=3
    Points=1

	bUseCylinderCollision=false

    StaticMesh=StaticMesh'furniture-STV.HOME_interior.COMPUTER-MONITOR-SW'
	BrokenStaticMesh=StaticMesh'furniture-STV.HOME_interior.COMPUTER-MONITOR-SW'
	DamageSkin=Texture'Zo_AsylumTex.Other.zo_as_monitor'
}
