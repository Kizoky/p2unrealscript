/**
 * VendACureProjectile
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * A Urine bullet going straight for the Dude's mouth!
 *
 * @author Gordon Cheng
 */
class VendACureProjectile extends BossMilkProjectile;

/** Overriden so we can set the gravity */
function PrepVelocity(vector usevel) {
    super.PrepVelocity(usevel);

    Acceleration = PhysicsVolume.Gravity;
}

/** Overriden so we don't collid with our owner or other Craptraps */
simulated function ProcessTouch(Actor Other, vector HitLocation) {
    if (Pawn(Other) != none && VendACurePawn(Other) == none &&
        Pawn(Other).Health > 0)
	    GenExplosion(HitLocation, Normal(HitLocation - Other.Location), Other);
	else {
		if (Other.bStatic)
			GenExplosion(Location, vect(0,0,1), none);
		else
			Other.Bump(self);
	}
}

/** Overriden so we can update our UrineProjectileTrail */
auto state Flying
{
	function UpdateRotation() {
        SetRotation(rotator(Velocity));

        if (UrineProjectileTrail(SpitTrail) != none)
			UrineProjectileTrail(SpitTrail).UpdateLongStream(LongStreamRatio * Velocity);
	}
}

defaultproperties
{
    TrailClass=class'UrineProjectileTrail'
    explclass=class'UrineExplosion'
    explflyclass=class'UrineExplosionAir'

    MaxSpeed=16384
    MyDamageType=class'PLFX.UrineGlobDamage'
}