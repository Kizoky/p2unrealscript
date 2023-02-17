/**
 * PLPointsKActor
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Basically a KActor similar to a KActorExplodable except its a big stripped
 * down, and more importantly, it Triggers an event, so we can notify
 *
 * @author Gordon Cheng
 */
class PLPointsKActor extends KActor;

var() int Health;			// How much health we have
var() float PeeHealth;		// How much "pee health" we have. If zero, cannot destroy with pee
var() int Points;			// Number of points awarded upon destruction
var() StaticMesh DestroyedStaticMesh;	// Static mesh to switch to upon destruction. If None, does not switch static mesh
var() array<Material> DestroyedSkins;	// Skins to switch to upon destruction. Any empty slots are not assigned
var() class<P2Emitter> DestroyedExplosionEmitter;	// Emitter to spawn when destroyed.
var(Events) name DestroyedEvent;	// Event to trigger when destroyed.
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

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType) {

	local int i;
	local P2Emitter Asplosion;
	local Actor A;

    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

    if (Health == 0 || (PeeHealth <= 0 && bUsePeeHealth))
        return;

	// Take "pee" damage
	if (ClassIsChildOf(DamageType, class'UrineDamage')
		&& bUsePeeHealth)
	{
		PeeHealth -= TickDeltaTime;
		// Once the dude's peed on it enough, consider it destroyed
		if (PeeHealth <= 0)
			Damage = Health;
	}

    Health = Max(Health - Damage, 0);

    if (Health <= 0) {

		// Swap out our damaged skin/mesh, if any
		if (DestroyedStaticMesh != None)
			SetStaticMesh(DestroyedStaticMesh);
		for (i = 0; i < DestroyedSkins.Length; i++)
			if (DestroyedSkins[i] != None)
				Skins[i] = DestroyedSkins[i];

		// Make an asplosion
		if (DestroyedExplosionEmitter != None)
		{
			Asplosion = Spawn(DestroyedExplosionEmitter, , , Location, Rotation);
			if (Asplosion != None)
			{
				Asplosion.Instigator = EventInstigator;
				Asplosion.SetBase(Self);
			}
		}
		
		if (CounterTrigger != None)
		{
			// add up points for the AWTrigger
			CounterTrigger.UseTimes += Points - 1;

			// Finally we Trigger it so it does anything it has to do
			CounterTrigger.Trigger(self, EventInstigator);
		}
		
		// Trigger any extra actors when destroyed
		if (DestroyedEvent != '')
		{
			foreach DynamicActors(class'Actor', A, DestroyedEvent)
				A.Trigger(Self, EventInstigator);
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

    bBlockPlayers=false

    StaticMesh=StaticMesh'furniture-STV.HOME_interior.COMPUTER-MONITOR-SW'
}