//////////////////////////////////////////////////////////////////////////////
// GaryHeadHomingProjectile.
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Laughing gary heads--hurts things on contact--homes in on a target
// Also on fire
//
///////////////////////////////////////////////////////////////////////////////
class GaryHeadHomingProjectile extends GaryHeadBurnProjectile;

var float UpdateTime;
var float StartTime;
var vector SeekAdjust;	// 1.0 to 0.0, how hard it tries to seek
var float AccSeekMag;
var float VelMag;
var float SeekRandFreq;			// how often the Mag is a randomly added
var float SeekRandMag;			// random addition to seeking acceleration
var Actor SeekTarget;	// thing we're after
var class<P2Damage> ProjHitDamage;

const FIND_DIST			=	1500;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetTarget(Actor newtarget)
{
	SeekTarget = newtarget;
}

///////////////////////////////////////////////////////////////////////////////
// Only for player throws
///////////////////////////////////////////////////////////////////////////////
function FindTarget()
{
	local vector endpt, stpt;
	local vector HitNormal, HitLocation;
	local Actor HitActor;
	local FPSPawn checkp, keepp;
	local float checkdist, keepdist;

	stpt = Location + 2*CollisionRadius*vector(Rotation);
	endpt = Location + FIND_DIST*vector(Rotation);
	HitActor = Trace(HitLocation, HitNormal, endpt, stpt, true);

	if(Pawn(HitActor) != None
		&& HitActor != Owner)
	{
		SetTarget(HitActor);
	}
	else
	{
		if(HitActor == None)
			HitLocation = endpt;

		foreach VisibleCollidingActors(class'FPSPawn', checkp, FIND_DIST, HitLocation)
		{
			// Don't let it target player, or dead things, or people that are your friend.
			if(checkp != Instigator
				&& checkp.Health > 0
				&& !checkp.bPlayerIsFriend)
			{
				if(keepp == None)
					keepp = checkp;
				else
				{
					checkdist = VSize(checkp.Location - HitLocation);
					if(checkdist < keepdist)
					{
						keepdist = checkdist;
						keepp = checkp;
					}
				}
			}
		}
		SetTarget(keepp);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	if(SeekTarget == None)
		GenExplosion(Location, HitNormal, Wall);
	else if(Wall != None
		&& Wall.bStatic)
		PerformBounce(HitNormal);
}

///////////////////////////////////////////////////////////////////////////////
// We can hurt ourselves with this if it's bounced once.
// Otherwise, it hurts everyone else all the same
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if(Owner != Other)
	{
		if (Pawn(Other) != None
			&& Pawn(Other).Health > 0)
		{
			// If not from me, blow up
			if(!RelatedToMe(Pawn(Other)))
			{
				GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
			}
		}
		else if(Other != None)
		{
			// Blow up the projectile on me
			if(Projectile(Other) != None
				&& ProjHitDamage != None
				&& GaryHeadProjectile(Other) == None)
				Other.TakeDamage(1000, None, Other.Location, vect(0,0,1), ProjHitDamage);
			else if(Other.bStatic)
				PerformBounce(-Normal(Velocity));
			else
				Other.Bump(self);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PerformBounce(vector HitNormal)
{
	local vector stpt, checkpoint, HitLocation, hitnorm;
	local Actor HitActor;

	if(SeekTarget != None
		&& !SeekTarget.bDeleteMe)
	{
		BounceRecoil(HitNormal);

		if(Role == ROLE_Authority)
		{
			// Check to make a splat on the surface too
			checkpoint = Location - DIST_TO_WALL_FOR_SPLAT*HitNormal;
			stpt = Location;
			HitActor = Trace(HitLocation, HitNorm, checkpoint, stpt, true);
			if ( HitActor != None
				&& HitActor.bStatic 
				&& splatmakerclass != None) 
			{
				spawn(splatmakerclass,self,,HitLocation,rotator(HitNorm));
			}
		}
	}
	else
		GenExplosion(Location,HitNormal,None);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You just shot out of your owner
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state StartOut
{
	function RandStartAcc()
	{
		Acceleration = VSize(Acceleration)*VRand();
	}
Begin:
	RandStartAcc();
	Sleep(StartTime);
	GotoState('Flying');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Orbit your SeekTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Flying
{
	///////////////////////////////////////////////////////////////////////////////
	// Seek to fly around our SeekTarget
	///////////////////////////////////////////////////////////////////////////////
	function UpdateDir()
	{
		local vector seekdir, veldir;
		local float userand;

		if(SeekTarget != None
			&& !SeekTarget.bDeleteMe)
		{
			veldir = Normal(Velocity);
			seekdir = Normal(SeekTarget.Location - Location);
			// point velocity at the target some too
			Velocity = (vect(1,1,1) - SeekAdjust)*velmag*veldir + SeekAdjust*velmag*seekdir;
			// point acceleration there
			Acceleration = SeekAdjust*AccSeekMag*seekdir;
			// randomly kick it up or down more
			if(FRand() < SeekRandFreq)
			{
				userand = SeekRandMag*(FRand() - 0.5);
				Acceleration.z += userand;
			}
		}
	}
Begin:
	Sleep(UpdateTime);

	UpdateDir();

	goto('Begin');
}

defaultproperties
{
     UpdateTime=0.100000
     StartTime=0.200000
     SeekAdjust=(X=0.200000,Y=0.200000,Z=0.200000)
     AccSeekMag=250.000000
     velmag=800.000000
     SeekRandFreq=0.300000
     SeekRandMag=1000.000000
     ProjHitDamage=Class'BaseFX.BulletDamage'
     splatmakerclass=Class'AWEffects.VomitSplatMaker'
     TrailClass=Class'AWEffects.GreenGaryHeadFire'
     speed=800.000000
     MaxSpeed=1000.000000
     Mass=50.000000
}
