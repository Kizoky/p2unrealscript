//////////////////////////////////////////////////////////////////////////////
// GaryHeadOrbit -- Projectile.
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Gary head that orbits the cow boss and protects him
//
///////////////////////////////////////////////////////////////////////////////
class GaryHeadOrbit extends GaryHeadProjectile;

var float UpdateTime;
var float SpitOutTime;
var vector SeekAdjust;	// 1.0 to 0.0, how hard it tries to seek
var float AccSeekMag;
var float VelMag;
var float SeekRandFreq;			// how often the Mag is a randomly added
var float SeekRandMag;			// random addition to seeking acceleration
var Actor SeekTarget;	// thing we're after
var class<P2Emitter> BossZapClass;
var P2Emitter BossZapper;	// lightning effect aimed at owner
var class<AWBossEye> bigeyeclass; // eye that eye link to (haha)
var AWBossEye BigEye;
var class<P2Damage> ProjHitDamage;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(!bDeleteMe)
	{
		if(BigEye != None)
			BigEye.HeadRemoved();
		if(AWCowBossPawn(Owner) != None)
			AWCowBossPawn(Owner).RemoveOrbitHead(self);
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

///////////////////////////////////////////////////////////////////////////////
// If there is an eye, link to it, if there's not, make one
///////////////////////////////////////////////////////////////////////////////
function CheckForEye()
{
	local Actor findeye;

	foreach DynamicActors(bigeyeclass, findeye)
	{
		if(AWBossEye(findeye) != None
			&& !AWBossEye(findeye).bDying)
		{
			BigEye = AWBossEye(findeye);
			break;
		}
	}

	if(BigEye == None)
	{
		BigEye = spawn(bigeyeclass, Owner, , Owner.Location);
		// Link it up to the cowboss
		if(AWCowBossPawn(Owner) != None)
		{
			AWCowBossPawn(Owner).GreatEye = BigEye;
			BigEye.BossOffset = AWCowBossPawn(Owner).EyeOffset;
		}
	}

	// Update the eye
	if(BigEye != None)
	{
		BigEye.HeadAdded();
		SetTarget(BigEye);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You just shot out of your owner
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state SpitOut
{
	function RandStartAcc()
	{
		Acceleration = VSize(Acceleration)*VRand();
	}
Begin:
	RandStartAcc();
	Sleep(SpitOutTime);
	CheckForEye();
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
     SpitOutTime=0.200000
     SeekAdjust=(X=0.120000,Y=0.120000,Z=0.150000)
     AccSeekMag=125.000000
     velmag=350.000000
     SeekRandFreq=0.300000
     SeekRandMag=1200.000000
     bigeyeclass=Class'AWPawns.AWBossEye'
     ProjHitDamage=Class'BaseFX.BulletDamage'
     TrailClass=Class'AWEffects.HeadTrail'
     VelDampen=1.000000
     Mass=50.000000
}
