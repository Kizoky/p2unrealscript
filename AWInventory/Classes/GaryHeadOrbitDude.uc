//////////////////////////////////////////////////////////////////////////////
// GaryHeadOrbitDude -- Projectile.
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Gary head that orbits the player and protects him
//
///////////////////////////////////////////////////////////////////////////////
class GaryHeadOrbitDude extends GaryHeadProjectile;

var float UpdateTime;
var float ShootOutTime;
var vector SeekAdjust;	// 1.0 to 0.0, how hard it tries to seek
var float AccSeekMag;
var float VelMag;
var float SeekRandFreq;			// how often the Mag is a randomly added
var float SeekRandMag;			// random addition to seeking acceleration
var Actor SeekTarget;	// thing we're after
var class<P2Damage> ProjHitDamage;

const TARGET_TOO_FAR	=	1000;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(!bDeleteMe)
	{
		if(P2Player(Pawn(Owner).Controller) != None)
			P2Player(Pawn(Owner).Controller).HeadRemoved();
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetTarget(Actor newtarget)
{
	SeekTarget = newtarget;
}

///////////////////////////////////////////////////////////////////////////////
// Take damage or be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	// Don't do anything if there's no damage
	if(Dam <= 0)
		return;

	// Change by Man Chrzan: xPatch 2.0
	// Allow player to destroy heads if they want to...
/*  // Can't be hurt by my owner
	if(InstigatedBy == Owner)
		return; 	*/

	// explosions knock them a distance away
	if(ClassIsChildOf(damageType, class'ExplodedDamage'))
	{
		//log(self$" momentum "$momentum$" mass "$mass);
		Velocity = momentum/Mass;
	}
	// Only bullets and kicking/stabbing/hitting hurts this
	else if(ClassIsChildOf(damageType, class'BulletDamage')
		|| ClassIsChildOf(damageType, class'BludgeonDamage'))
		GenExplosion(HitLocation, vect(0, 0, 1), None);
	return;
}


///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	if(Owner == None)
		GenExplosion(Location, HitNormal, None);	
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
	if(Owner == None)
		GenExplosion(HitLocation, vect(0, 0, 1), None);	
	else if(Owner != Other)
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
				&& VomitProjectile(Other) == None)
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

	BounceRecoil(HitNormal);

	// It can get chunky, don't do splats for these
	/*
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
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Link to our dude owner
///////////////////////////////////////////////////////////////////////////////
function CheckForDude()
{
	// Update the dude
	if(Owner != None)
	{
		P2Player(Pawn(Owner).Controller).HeadAdded();
		SetTarget(Pawn(Owner));
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You just shot out of your owner
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state ShootOut
{
	function RandStartAcc()
	{
		Acceleration = VSize(Acceleration)*VRand();
	}
Begin:
	RandStartAcc();
	Sleep(ShootOutTime);
	CheckForDude();
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
		local vector newloc;

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
			// If you ever get too far from the dude, warp next to him
			if(VSize(Location - SeekTarget.Location) > TARGET_TOO_FAR)
			{
				//log(self$" target too far ");
				newloc = SeekTarget.Location;
				SetLocation(newloc);
			}
		}
		else
			GenExplosion(Location, vect(0, 0, 1), None);	
	}
Begin:
	Sleep(UpdateTime);

	UpdateDir();

	goto('Begin');
}

defaultproperties
{
     UpdateTime=0.100000
     ShootOutTime=0.200000
     SeekAdjust=(X=0.200000,Y=0.200000,Z=0.200000)
     AccSeekMag=300.000000
     velmag=500.000000
     SeekRandFreq=0.300000
     SeekRandMag=800.000000
     ProjHitDamage=Class'BaseFX.BulletDamage'
     TrailClass=Class'AWEffects.HeadTrail'
     VelDampen=1.000000
     SoundVolume=24
     TransientSoundVolume=32.000000
     bBounce=False
     Mass=50.000000
	 
	 // Added by Man Chrzan: xPatch 2.0
	 // Please don't rape my ears. Thank you.
	 BurningSoundVolume=0.075
}
