///////////////////////////////////////////////////////////////////////////////
// BouncyProjectile
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// small bouncing projectile
// 
///////////////////////////////////////////////////////////////////////////////
class BouncyProjectile extends P2Projectile;

var sound BounceSound;

// Change by NickP: MP fix
var int BounceCounter;
const MAX_BOUNCES = 3;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role < ROLE_Authority)
	{
		// setup linear speed
		Velocity = VRand()*Speed;
		if(Velocity.z < 0)
			Velocity.z = -Velocity.z;
		Velocity.z += TossZ;
		// setup spin
		RotationRate.Pitch = Rand(RotationRate.Yaw);
		RotationRate.Roll = Rand(RotationRate.Yaw);

		LifeSpan = 10.0;
	}
}
// End

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function BounceRecoil(vector HitNormal)
{
	Super.BounceRecoil(HitNormal);
	// play a noise
	PlaySound(BounceSound);
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector newhit, newnormal, EndPt;
	local bool bStopped;
	local float speed;
	local SmokeHitPuff smoke1;

	if(bBounce == true)
	{
		speed = VSize(Velocity);
		// Check for a slowed z
		if(speed < MinSpeedForBounce)
		{
			// Check for possible stop by seeing if we're stopped in z and
			// on the ground.
			EndPt = Location;
			EndPt.z-=DIST_CHECK_BELOW;
			// If there is a hit below (ground) then you are stopped.
			if(Trace(newhit, newnormal, EndPt, Location, false) != None)
				bStopped=true;
		}

		// Change by NickP: MP fix
		if (Role < ROLE_Authority)
		{
			if (BounceCounter >= MAX_BOUNCES)
				bStopped=true;
			BounceCounter++;
		}
		// End

		// If we've stopped, zero out the appropriate entries
		if(bStopped)
		{
			bBounce=false;
			Acceleration = vect(0, 0, 0);
			Velocity = vect(0, 0, 0);
			RotationRate.Pitch=0;
			RotationRate.Yaw=0;
			RotationRate.Roll=0;
		}
		else	// do bouncing
			BounceRecoil(HitNormal);

		// Throw out some hit effects, like dust or sparks
		smoke1 = spawn(class'Fx.SmokeHitPuffMelee',Owner,,Location, rotator(HitNormal));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function Explode(vector HitLocation, vector HitNormal)
{
}

defaultproperties
{
	 MyDamageType=None
	 Speed=300
     MaxSpeed=2500.000000
     Damage=0.000000
	 DamageMP=0
	 DamageRadius=0
     MomentumTransfer=50000
     bBounce=true
	 bFixedRotationDir=true
	 RotationRate=(Yaw=50000)
	 DrawType=DT_StaticMesh
	 StaticMesh=StaticMesh'stuff.stuff1.catnip_lid'
     AmbientGlow=64
	 MinSpeedForBounce=50
	 VelDampen=0.6
	 RotDampen=0.85
	 StartSpinMag=0
	 Acceleration=(Z=-1000)
	 Health=10
	 ExploWallOut=100
	 BounceSound=Sound'WeaponSounds.grenade_bounce_small'
	 CollisionRadius=11
	 CollisionHeight=11
}
