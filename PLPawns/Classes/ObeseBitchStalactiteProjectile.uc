/**
 * ObeseBitchStalactiteProjectile
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * A stalactite that falls from the ceiling come crashing down on the Dude
 *
 * @author Gordon Cheng
 */
class ObeseBitchStalactiteProjectile extends P2Projectile;

var float FallVelocity;

var class<P2Emitter> RockExplosionClass;

/** We don't bounce and we're too large to be moved */
simulated function BounceRecoil(vector HitNormal);
function AddRelativeVelocity(vector OwnerVel);
simulated function BlowUp(vector HitLocation);

function InitializeFallVelocity() {
    local rotator InitialRotation;

    Velocity.Z = -Abs(FallVelocity);

    InitialRotation = Rotation;
    InitialRotation.Yaw = int(FRand() * 65535.0);

    SetRotation(InitialRotation);
}

/** Overriden so we explode when we hit something... anything */
simulated function ProcessTouch(Actor Other, Vector HitLocation) {
    GenExplosion(HitLocation, vect(0,0,1), none);
}

/** Overriden so we explode when we hit something... anything */
simulated function HitWall (vector HitNormal, Actor Wall) {
    GenExplosion(Location, HitNormal, Wall);
}

/** Create a rock explosion and disappear */
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other) {
    if (RockExplosionClass != none)
        Spawn(RockExplosionClass,,, HitLocation);

    Destroy();
}

defaultproperties
{
    FallVelocity=-2000

    RockExplosionClass=class'ObeseBitchRockDropExplosion'

    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'MRT_HellProps.rock.stalactite_1'

    Physics=PHYS_Falling

    bBounce=true
    bUnlit=false
    bProjTarget=true
    bUseCylinderCollision=true
}