//////////////////////////////////////////////////////////////////////////////
// VomitProjectile.
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Zombie spit balls--hurts things on contact
//
///////////////////////////////////////////////////////////////////////////////
class VomitProjectile extends P2Projectile;

var P2Emitter	SpitTrail;		// spit trail to make them easier to see
var float UpRatio;				// How fast up it should go in relation to how fast outward it goes.
var class<splatmaker> splatmakerclass;
var class<P2Emitter> TrailClass;	// nasty trail that follows behind us
var class<P2Explosion> explclass;
var class<P2Explosion> explflyclass;

const FORCE_RAD_CHECK		= 50;
const DIST_TO_WALL_FOR_SPLAT = 100;
const CEILING_Z				=	-0.5;
const BOUNCE_WALL_DOT		=	0.4;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	KillSpitTrail();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function MakeSpitTrail()
{
	if(SpitTrail == None
		&& trailclass != None)
	{
		if(Level.Game.bIsSinglePlayer)
		{
			// Send player as owner so it will keep up in slomo time
			SpitTrail = spawn(trailclass,Owner,,Location); 
			SpitTrail.SetBase(self);
		}
		else
		{
			SpitTrail = spawn(trailclass,self,,Location);
			SpitTrail.SetBase(self);
		}
	}
}
function KillSpitTrail()
{
	if(SpitTrail != None)
	{
		SpitTrail.SelfDestroy();
		// Change by NickP: MP fix
		if (Level.NetMode != NM_StandAlone)
			SpitTrail.Destroy();
		// End
		SpitTrail = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Send it with a certain speed and arm it
///////////////////////////////////////////////////////////////////////////////
function PrepVelocity(vector usevel)
{
	MakeSpitTrail();

	Speed = VSize(usevel);
	if(Speed > MaxSpeed)
	{
		Speed = MaxSpeed;
		usevel = Speed*Normal(usevel);
	}
	//log(self$" setupshot "$ChargeTime$" speed "$speed);

	Velocity = usevel;

	RandSpin(StartSpinMag);
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

	// several things don't hurt us
	if(ClassIsChildOf(damageType, class'AnthDamage')
		|| damageType == class'ElectricalDamage'
		|| ClassIsChildOf(damageType, class'BurnedDamage')
		|| ClassIsChildOf(damageType, class'VomitDamage'))
		return;

	// Damage means it wasn't hitting a wall--the only way to kill this
	// and it was off the ground, so that means it was flying around
	// so use the flying explosion
		GenFlyingExplosion(HitLocation, vect(0, 0, 1), None);
	return;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PerformBounce(vector HitNormal)
{
	local vector stpt, checkpoint, HitLocation, hitnorm;
	local Actor HitActor;

	Velocity = Velocity - 2 * HitNormal * (Velocity Dot HitNormal);

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
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector mydir;
	local float hitdot;

	mydir = Normal(Velocity);
	hitdot = mydir Dot HitNormal;

	// If it hits a ceiling, then bounce down
	if(HitNormal.z < CEILING_Z
		&& abs(hitdot) < BOUNCE_WALL_DOT)
	{
		PerformBounce(HitNormal);
	}
	else // otherwise explode on contact
	{
		GenExplosion(Location, HitNormal, None);
	}
}

///////////////////////////////////////////////////////////////////////////////
// We can hurt ourselves with this if it's bounced once.
// Otherwise, it hurts everyone else all the same
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local SmokeHitPuff smoke1;

	if (Pawn(Other) != None
		&& Pawn(Other).Health > 0)
	{
		// If not from me, blow up
		if(!RelatedToMe(Pawn(Other)))
		{
			GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
		}
	}
	else 
	{
		// Blow up on static things
		if(Other.bStatic)
		{
			GenExplosion(Location, vect(0,0,1), None);
		}
		else
			Other.Bump(self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local P2Explosion exp;
	local vector WallHitPoint;
	local vector checkpoint, stpt;
	local Actor HitActor;

	if(Role == ROLE_Authority)
	{
		if(Other != None
			&& Other.bStatic)
		{
			// Make sure the force of this explosion is all the way against the wall that
			// we hit
			WallHitPoint = HitLocation - FORCE_RAD_CHECK*HitNormal;
			Trace(HitLocation, HitNormal, WallHitPoint, HitLocation);
		}
		else
			WallHitPoint = HitLocation;
		exp = spawn(explclass,GetMaker(),,HitLocation + ExploWallOut*HitNormal);
		exp.ForceLocation = WallHitPoint;

		// Check to make a splat on the surface too
		checkpoint = HitLocation + DIST_TO_WALL_FOR_SPLAT*Normal(Velocity);
		stpt = HitLocation;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, stpt, true);
		if ( HitActor != None
			&& HitActor.bStatic 
			&& splatmakerclass != None) 
		{
			spawn(splatmakerclass,self,,HitLocation,rotator(HitNormal));
		}

	}
 	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects when you were destroyed flying through the air
///////////////////////////////////////////////////////////////////////////////
simulated function GenFlyingExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local VomitExplosion exp;

	if(Role == ROLE_Authority)
	{
		exp = VomitExplosion(spawn(explflyclass,GetMaker(),,HitLocation + ExploWallOut*HitNormal));
		if(exp != None)
		{
			exp.AddVelocity(Velocity/2);
			exp.ForceLocation = HitLocation;
		}
	}
 	Destroy();
}

defaultproperties
{
     UpRatio=0.450000
     splatmakerclass=Class'VomitSplatMaker'
     TrailClass=Class'VomitTrail'
     explclass=Class'VomitExplosion'
     explflyclass=Class'VomitExplosion'
     DetonateTime=4.000000
     MinSpeedForBounce=100.000000
     VelDampen=0.600000
     RotDampen=0.850000
     StartSpinMag=20000.000000
     speed=200.000000
     MaxSpeed=1000.000000
     DamageRadius=0.000000
     MomentumTransfer=80000.000000
     MyDamageType=Class'VomitDamage'
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     DrawType=DT_StaticMesh
     LifeSpan=0.000000
     AmbientSound=Sound'LevelSounds.potBoil'
     Acceleration=(Z=-400.000000)
     StaticMesh=StaticMesh'Timb_mesh.fooo.nasty_deli2_timb'
     DrawScale=0.010000
     AmbientGlow=64
     SoundRadius=30.000000
     SoundVolume=128
     SoundPitch=0
     TransientSoundVolume=128.000000
     TransientSoundRadius=30.000000
     CollisionRadius=20.000000
     CollisionHeight=20.000000
     bProjTarget=True
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     RotationRate=(Pitch=1000,Yaw=1000,Roll=1000)
}
