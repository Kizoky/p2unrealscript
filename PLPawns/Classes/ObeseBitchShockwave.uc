/**
 * ObeseBitchShockwave
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Essentially a "walking" explosive shockwave caused by Obese Bitch's
 * incredible power
 *
 * @author Gordon Cheng
 */
class ObeseBitchShockwave extends Actor
    notplaceable;

var float ShockwaveSpeed;
var float ShockwaveExplosionInterval;
var float ShockwaveExplosionZOffset;
var class<P2Explosion> ShockwaveExplosionClass;

/** Initializes the shockwave by giving it a direction it can travel in
 * @param Dir - Direction vector it should move in
 */
function InitializeShockwave(vector Dir) {
    Velocity = ShockwaveSpeed * Normal(Dir);

    if (ShockwaveExplosionClass != none)
        SetTimer(ShockwaveExplosionInterval, true);
}

/** Create an explosion on the ground */
function Timer() {
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    local vector ExplosionLocation;

    StartTrace = Location;
    EndTrace = StartTrace + vect(0,0,-1000);
    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

    if (Other != none) {
        ExplosionLocation = HitLocation;
        ExplosionLocation.Z += ShockwaveExplosionZOffset;

        Spawn(ShockwaveExplosionClass,,, ExplosionLocation);
    }
}

defaultproperties
{
    ShockwaveSpeed=800
    ShockwaveExplosionZOffset=32
    ShockwaveExplosionInterval=0.25

    ShockwaveExplosionClass=class'ObeseBitchShockwaveExplosion'

    Lifespan=2.5

    bHidden=true

	bCollideActors=false
	bCollideWorld=false

	bBlockActors=false
	bBlockPlayers=false
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false

	Physics=PHYS_Projectile
}
