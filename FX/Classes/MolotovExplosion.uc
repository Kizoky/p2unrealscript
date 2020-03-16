///////////////////////////////////////////////////////////////////////////////
// MolotovExplosion
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
// 
// Effect and damage for molotov cocktails
///////////////////////////////////////////////////////////////////////////////
class MolotovExplosion extends P2Explosion;

var vector BallPoint;
var vector UseNormal;
var Actor  ImpactActor;
var class<FirePuddle> puddclass;
var class<FirePillar> pillclass;
var class<FireBall>   ballclass;
var class<MolotovBreak> breakclass;

//const RING_GROW_TIME=	0.7;
const FLAT_GROUND	=	0.8;
const RING_RADIUS	=	200;


replication
{
	// functions server sends to client
	reliable if (Role == ROLE_Authority)
		SetupExp;
}


///////////////////////////////////////////////////////////////////////////////
// Set a few more vars before we get going
///////////////////////////////////////////////////////////////////////////////
simulated function SetupExp(vector HitNormal, Actor Other)
{
	UseNormal = HitNormal;
	ImpactActor = Other;
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
	///////////////////////////////////////////////////////////////////////////////
	// Make the explosion of tiny broken glass
	// Make the ring of expanding fire with puddle, if we're on a flat enough surface
	///////////////////////////////////////////////////////////////////////////////
	function MakeBase()
	{
		local MolotovBreak mb;
		local vector loc;
		local DynamicFireStarterRing fr;

		if(breakclass != None)
		{
			mb = spawn(breakclass,,,Location);
			mb.FitToNormal(UseNormal);
		}

		if(UseNormal.z > FLAT_GROUND
			&& ImpactActor != None
			&& ImpactActor.bStatic
			&& puddclass != None)
		{
			loc = 2*UseNormal + Location;
			fr = spawn(class'DynamicFireStarterRing',Owner,,loc);
			// We don't make a fire puddle and link it now.. this is a dynamic 
			// fire ring, and it will make it for us.
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Central fire pillar
	///////////////////////////////////////////////////////////////////////////////
	function MakePillar()
	{
		local FirePillar fp;
		local vector loc;

		loc = 2*UseNormal + Location;
		fp = spawn(pillclass,,,loc);
		fp.CheckCeiling(UseNormal);

		BallPoint = fp.Location;
		BallPoint.z += fp.BallHeight;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Top fireball
	///////////////////////////////////////////////////////////////////////////////
	function MakeBall()
	{
		local FireBall fp;
		fp = spawn(ballclass,,,BallPoint);
	}
Begin:
	MakeBase();	
	PlaySound(ExplodingSound,,1.0,,,,true);
	CheckHurtRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, Location);
	NotifyPawns();

	MakePillar();
	Sleep(0.4);
	MakeBall();
}

defaultproperties
{
	DelayToHurtTime=0.2
	ExplosionMag=0
	ExplosionRadius=400
	ExplosionDamage=100
	MyDamageType = class'FireExplodedDamage'
    ExplodingSound=Sound'WeaponSounds.Molotov_explode'

	puddclass = class'FirePuddle'
	pillclass = class'FirePillar'
	ballclass = class'FireBall'
	breakclass= class'MolotovBreak'

	LifeSpan=5.0
	TransientSoundRadius=300
}
