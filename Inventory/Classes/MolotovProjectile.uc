//////////////////////////////////////////////////////////////////////////////
// MolotovProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual Molotov that goes flying through the air.
//
///////////////////////////////////////////////////////////////////////////////
class MolotovProjectile extends GrenadeProjectile;

var MolotovWickFire	wickfire;		// Fire on the cloth hanging out of bottle

var float MaxSafeBounceSpeed;		// If you gently toss the molotov (alt-fire) but it gets
									// going faster than this and hits something (you gently tossed
									// out a second story window) it will blow up anyway. Nice going.

///////////////////////////////////////////////////////////////////////////////
// Make the fire too
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	local Rotator uprot;

	Super.PostBeginPlay();

	// Call this on client or single player
	if ( Level.NetMode != NM_DedicatedServer)
	{
		wickfire = spawn(class'MolotovWickFire', self,,Location);
		wickfire.SetBase(self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Send it with a certain speed and arm it
// A ChargeTime of 0 means it was alt-fired. 
// The reason we don't just explicitly set some boolean like bArmed to say
// that the one 'thrown' is armed and the one 'set down' by alt-fire is 
// not armed, is because, unlike a grenade, we say that if you alt-fire
// and gently set down a molotov that's lit but it falls a long way, it
// should still blow up.
///////////////////////////////////////////////////////////////////////////////
function SetupThrown(float ChargeTime)
{
	local Rotator uprot;

	// If it was tossed gently to the ground, it will arrive upright.
	if(ChargeTime == 0)
		StartSpinMag = 0;

	Super.SetupThrown(ChargeTime);

	if(ChargeTime == 0)
	{
		// Keep it upright
		uprot.Yaw=0;
		SetRotation(uprot);
	}
}

///////////////////////////////////////////////////////////////////////////////
// destroy fire
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	if(wickfire != None)
	{
		wickfire.Destroy();
		wickfire = None;
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Take damage or be force around
///////////////////////////////////////////////////////////////////////////////
simulated function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	// Don't do anything if there's no damage
	if(Dam <= 0)
		return;
	// several things don't hurt us
	if(ClassIsChildOf(damageType, class'AnthDamage')
		|| damageType == class'ElectricalDamage')
		return;

	Health-=Dam;

	if(Health <= 0)
	{
		GenExplosion(HitLocation, vect(0, 0, 1), None);
		return;
	}

	SetPhysics(PHYS_Projectile);
	// Now add in momentum if we didn't explode
	Velocity+=(Momentum/Mass);
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector newhit, newnormal, EndPt;
	local bool bStopped;
	local float usespeed;
	local SmokeHitPuff smoke1;

	if(!bArmed)
	{
		if(bBounce)
		{
			usespeed = VSize(Velocity);
			if(usespeed >= MaxSafeBounceSpeed)
			{
				bArmed=true; // It needs to blow up before leaving this function
				// it hit the wall too hard.
			}
			else
			{
				// Check for a slowed z
				if(usespeed < MinSpeedForBounce)
				{
					// Check for possible stop by seeing if we're stopped in z and
					// on the ground.
					EndPt = Location;
					EndPt.z-=DIST_CHECK_BELOW;
					// If there is a hit below (ground) then you are stopped.
					if(Trace(newhit, newnormal, EndPt, Location, false) != None)
						bStopped=true;
					else	// if we're not stopping, cap the usespeed at the minimum
					{
						Velocity = MinSpeedForBounce*Normal(Velocity);
						if(SameSpotBounce == 0)
						{
							SameSpot = Location;
							SameSpotBounce++;
						}
						else
						{
							if(VSize(SameSpot - Location) < SAME_SPOT_RADIUS)
							{
								SameSpotBounce++;
							}
							else
							{
								SameSpotBounce=0;
							}
							// We've bounce too many times in this spot--stop anyways.
							if(SameSpotBounce >= SAME_SPOT_BOUNCE_MAX)
								bStopped=true;
						}
					}
				}
				// If we've stopped, zero out the appropriate entries
				if(bStopped)
				{
					//bArmed=true;
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
				smoke1 = spawn(class'Fx.SmokeHitPuffMelee',Owner,,Location,rotator(HitNormal));
			}
		}
	}

	// You may have caused it to arm by bouncing it to hard,
	// or just by throwing it in the primary fashion, either way, after
	// a hit, it blows up now
	if(bArmed)
		GenExplosion(Location + ExploWallOut * HitNormal, HitNormal, Wall);
}

///////////////////////////////////////////////////////////////////////////////
// Gets done in GenExplosion
///////////////////////////////////////////////////////////////////////////////
simulated function BlowUp(vector HitLocation)
{
}

///////////////////////////////////////////////////////////////////////////////
// We can hurt ourselves with this if it's bounced once.
// Otherwise, it hurts everyone else all the same
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (Pawn(Other) != None)
	{
		if(Other != Instigator)
		{
			if(bArmed
				&& Pawn(Other).Health > 0)
				GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
		}
	}
	else
	{
		if(Other.bStatic)
			GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
		else
			Other.Bump(self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local MolotovExplosion me;

	if(Role == ROLE_Authority)
	{
		me = spawn(class'MolotovExplosion',GetMaker(),,HitLocation);
		me.SetupExp(HitNormal, Other);
		me.UseNormal = HitNormal;
		me.ImpactActor = Other;
	}

 	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// JustThrown
// Don't let fire damage effect a molotov just after it was thrown. Wait a split
// second. Before, when this wasn't here, if you threw a molotov when you were
// on fire, it burst and would never really get thrown.
///////////////////////////////////////////////////////////////////////////////
auto state JustThrown
{
	///////////////////////////////////////////////////////////////////////////////
	// Take damage or be force around
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
								Vector momentum, class<DamageType> damageType)
	{
		// several things don't hurt us
		if(damageType == class'BurnedDamage')
			return;

		Global.TakeDamage(Dam, instigatedBy, hitlocation, momentum, damageType);
	}
Begin:
	Sleep(0.5);
	GotoState('');
}

defaultproperties
{
	 MyDamageType=class'FireExplodedDamage'
     Speed=1000.000000
     MaxSpeed=2500.000000
	 MaxSafeBounceSpeed = 1200.0
     Damage=25.000000
	 Damage=25
	 DamageRadius=400
     MomentumTransfer=50000
	 DetonateTime=30.0
	 //ExplosionDecal=class'BlastMark'
     //ImpactSound=Sound'MolotovFloor'
     CollisionRadius=15.0
     CollisionHeight=15.0
	 bFixedRotationDir=true
	 RotationRate=(Yaw=50000)
	 DrawType=DT_StaticMesh
	 StaticMesh=StaticMesh'stuff.stuff1.molotov'
     AmbientGlow=64
	 VelDampen=0.4
	 RotDampen=0.0
	 StartSpinMag=20000
	 Acceleration=(Z=-1000)
	 Health=1
	 MinChargeTime=0.5
	 UpRatio=0.6
	 ExploWallOut=0
	 bProjTarget=true
     bUseCylinderCollision=true
	 Lifespan=0.0
	 bArmed=true
}
