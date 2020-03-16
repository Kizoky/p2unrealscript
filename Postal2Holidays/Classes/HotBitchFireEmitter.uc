/**
 * HotBitchFireEmitter
 *
 * A special FireTorsoEmitter that makes out bitch hot, and it doesn't damage
 * our bitch so she can infinitely work the Dude's nuts
 */
class HotBitchFireEmitter extends FireCatEmitter;

function DealDamage(float DeltaTime) {
    local Actor Victims;
	local float DamageScale, Dist;
	local vector Dir;

	if (bHurtEntry)
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors(class'Actor', Victims, CollisionRadius) {
		if (Victims != self && Victims.Role == ROLE_Authority &&
            Victims != MyPawn) {
			Dir = Victims.Location - Location;
			Dist = FMax(1,VSize(dir));
			Dir = Dir / Dist;
			DamageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/CollisionRadius);
			Victims.TakeDamage
			(
				Max(DamageScale * Damage, 1),
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(DamageScale * dir),
				MyDamageType
			);
		}
	}
	bHurtEntry = false;
}

///////////////////////////////////////////////////////////////////////////////
// Get put out by non-flammable liquids... or don't
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	// STUBBED OUT
}

defaultproperties
{
    Lifespan=0.0f
}