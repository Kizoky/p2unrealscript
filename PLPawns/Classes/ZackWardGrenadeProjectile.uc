/**
 * ZackWardGrenadeProjectile
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * A special grenade for Zack. The difference being that the first bounce
 * will have a significant amount of velocity dampening while the rest won't.
 *
 * This helps ensure that the grenade will land near the Dude's feet as opposed
 * to bouncing off several feet away and harmlessly exploding
 *
 * @author Gordon Cheng
 */
class ZackWardGrenadeProjectile extends GrenadeProjectile;

var bool bFirstBounce;

var float FirstBounceVelDampen;

/** Overriden so we can dampen the first bounce so it lands near the Dude */
simulated function BounceRecoil(vector HitNormal)
{
	local vector addvec;

	if (Physics != PHYS_Projectile)
        SetPhysics(PHYS_Projectile);

	addvec = VRand()*0.05;

	if (addvec.z < 0)
		addvec.z = -addvec.z;

	HitNormal += addvec;

    if (bFirstBounce) {

        Velocity = FirstBounceVelDampen * (Velocity - 2 * HitNormal *
            (Velocity Dot HitNormal));

        bFirstBounce = false;
    }
    else
        Velocity = VelDampen * (Velocity - 2 * HitNormal *
            (Velocity Dot HitNormal));

	StartSpinMag = RotDampen*StartSpinMag;
	RandSpin(StartSpinMag);
}

defaultproperties
{
    bFirstBounce=true

    FirstBounceVelDampen=0.2
}