//////////////////////////////////////////////////////////////////////////////
// xGrenadeProjectile.
// Added by Man Chrzan, xPatch 3.0
//
// This is a modified grenade to attach to cats.
///////////////////////////////////////////////////////////////////////////////
class xCatGrenadeProjectile extends GrenadeProjectile;

///////////////////////////////////////////////////////////////////////////////
// Take damage or be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	// Nope
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	// Nope
}

///////////////////////////////////////////////////////////////////////////////
// Have the un-armed projectile give the player back itself (as weapon ammo)
///////////////////////////////////////////////////////////////////////////////
simulated function MakePickup(Pawn Other)
{
	// Nope
}

///////////////////////////////////////////////////////////////////////////////
// We can hurt ourselves with this if it's bounced once.
// Otherwise, it hurts everyone else all the same
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	// Nope
}

///////////////////////////////////////////////////////////////////////////////
// Explodes 
///////////////////////////////////////////////////////////////////////////////
function ExplodeCat()
{
	GenExplosion(Location, vect(0,0,1), None);
}

defaultproperties
{
	DetonateTime=5
}