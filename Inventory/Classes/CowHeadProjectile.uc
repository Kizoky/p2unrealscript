///////////////////////////////////////////////////////////////////////////////
// CowHeadProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual cow head that goes flying through the air.
//
// Previously this would be thrown out, bounce along leaving little puffs then
// make a big, persistant cloud when it stopped. Now it should make that first
// cloud on the first (hardest) impact.
//
// If it's alt-thrown, that is, sort of lightly tossed on the ground, it likely
// won't make a cloud, but it will still be active. It can then be shot
// from a distance or hurt in general, and it will make a big cloud like before.
//
// If the head is damaged by fire, however, it is ruined, and will not emit
// any more anthrax.
//
///////////////////////////////////////////////////////////////////////////////
class CowHeadProjectile extends P2Projectile;

var AnthBall clingball;
var AnthCloud MyCloud;
var AnthTrailList atrails;
var Sound CowHeadBounce;
var Sound ExplodeSound;
//var Sound CowHeadGas;
var bool bMakeCloudOnBounce;	// Damaging has different rules, but this must be
								// true before it can make a cloud on the move (among other things)
var bool bBurned;			// It's been burned and used up--it's no good anymore.
var Material BurnSkin;		// what I switch to after I get hit by fire
var float MinExtraSoundSpeed;
var float MinSpeedForSelfDamage;	// Speed you need to hit something in order to hurt yourself
var bool bCanPlayBounceSound;

const START_VEL_RATIO = 	1000;
const DEFAULT_CHARGE_TIME=	1.0;
const SPEED_DAMAGE_RATIO = 0.01;
const MIN_MAKE_PUFF_SPEED = 700;
const DIST_CHECK_BELOW = 100;
const MIN_FROM_OLD_CLOUD =  200;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CalcStartVelocity(float VelRatio)
{
	local vector Dir;

	Dir = vector(Rotation);

	// getting thrown into the air
	Speed=VelRatio*Speed;

	Velocity = Speed * Dir;

	// make upward arc a factor of the overall speed
	Velocity.z += Speed/2;

	RandSpin(StartSpinMag);
}

///////////////////////////////////////////////////////////////////////////////
// A puff is made when you bounce hard on the ground, but won't be there long
// because your bouncing forward more
///////////////////////////////////////////////////////////////////////////////
function MakeAnthPuff(optional vector HitNormal)
{
	spawn(class'AnthPuff',Owner,,Location, Rotator(HitNormal));
}

///////////////////////////////////////////////////////////////////////////////
// A ball is made to cling to the head itself after it settles, so you know
// the head is dangerous/active
///////////////////////////////////////////////////////////////////////////////
function MakeAnthBall()
{
	if(!bBurned)
	{
		// Kill the old clinging anthball, before you set a new one
		if(clingball != None)
			clingball.GotoState('WaitAndFade');
		clingball = spawn(class'AnthBall',self,,Location);
		clingball.SetBase(self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// A cloud is the real threat. It is a very large cloud of anthrax that causes
// people to vomit blood and die.
///////////////////////////////////////////////////////////////////////////////
function bool MakeAnthCloud(optional vector HitNormal)
{
	// Only don't make a cloud if you're too close to your old one
	if(MyCloud != None)
	{
		if(MyCloud.bDeleteMe)
			MyCloud = None;
		else if(VSize(Location - MyCloud.Location) > MIN_FROM_OLD_CLOUD)
		{
			// Detach from the old cloud and make a new one (but let the old one burn out on
			// it's own
			MyCloud = None;
		}
	}

	if(MyCloud == None)
	{
		// make it a puff's height above the ground/hitnormal
		MyCloud = spawn(class'AnthCloud',Owner,,Location+class'AnthPuff'.default.CollisionHeight*HitNormal);
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	if(clingball != None)
	{
		clingball.GotoState('WaitAndFade');
		clingball = None;
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AbleToMove
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//auto state AbleToMove
//{
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local CatExplosion exp;
	local Rotator NewRot;

	if(ClassIsChildOf(damageType, class'BurnedDamage'))
	{
		// mark it as burned and swap out the fire texture
		if(!bBurned)
		{
			bBurned = true;
			Skins[0] = BurnSkin;
			if(clingball != None)
			{
				clingball.GotoState('WaitAndFade');
				clingball = None;
			}
		}
		return;
	}

	if(!ClassIsChildOf(damageType, class'AnthDamage')
		&& damageType != class'ElectricalDamage'
		&& Dam > 0)
	{
		// Don't move it if it's hit by a bullet, so you can shoot it right
		// where you dropped it.
		if(!ClassIsChildOf(damageType, class'BulletDamage')
			&& damageType != class'CuttingDamage')
		{
			bBounce=true;
			Acceleration = default.Acceleration;
			Velocity += momentum/Mass;
		}

		if(InstigatedBy != None
			&& !ClassIsChildOf(damageType, class'BludgeonDamage'))
		{
			// If you don't already have a big cloud around you, 
			// make one after being hurt
			MakeAnthCloud(vect(0,0,1.0));
		}
		// Someone must inflict the damage before we care. When we fall, we get hurt
		// by SmashDamage and instigated by no one--we don't want that to reset this.
		else if(InstigatedBy != None)
		{
			bMakeCloudOnBounce=true;
		}

		// Remove life
		Health -= Dam;

		if(Health <= 0)
		{
			if(class'P2Player'.static.BloodMode())
			{
				// Make blood explosion
				exp = spawn(class'CatExplosion',,,HitLocation);
				exp.PlaySound(ExplodeSound,,,,,GetRandPitch());
			}

 			Destroy();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function BounceOffSomething( vector HitNormal, actor Wall )
{
	local vector newhit, newnormal, EndPt;
	local bool bStopped;
	local float speed, hitdot;
	local vector zeromomentum;
	local float DamageFromBounce;
	local AnthCloud acloud;

	if(bBounce == true)
	{
		speed = VSize(Velocity);

		// if we're burned, we're not lethal anymore--we don't make anthrax
		if(!bBurned)
		{
			// Check first if we've already made a cloud. 
			// If we have, but it's done, then make another
			if(speed > MIN_MAKE_PUFF_SPEED
				&& bMakeCloudOnBounce)
			{
				if(MakeAnthCloud(HitNormal))
				{
					bMakeCloudOnBounce=false;
				}
			}
		}

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
		// If we've stopped, zero out the appropriate entries
		// and emit the final, large cloud.
		if(bStopped)
		{
			bBounce=false;
			Acceleration = vect(0, 0, 0);
			Velocity = vect(0, 0, 0);
			RotationRate.Pitch=0;
			RotationRate.Yaw=0;
			RotationRate.Roll=0;

			// if we're burned, we're not lethal anymore--we don't make anthrax
			if(!bBurned)
			{
				// If we bounce before getting here, or we didn't have a clingy ball, then make one
				if(clingball == None)
					MakeAnthBall();
			}
		}
		else
		{
			// Make the head bounce
			// But first, take damage from the bounce
			zeromomentum = vect(0, 0, 0);
			hitdot = (Velocity Dot HitNormal);
			DamageFromBounce = abs(hitdot)*SPEED_DAMAGE_RATIO;

			if(VSize(Velocity) > MinSpeedForSelfDamage)
				TakeDamage( DamageFromBounce, None, Location,
							zeromomentum, MyDamageType);

			// When you hit a person, don't bounce straight back, either go left or right
			if(Pawn(Wall) != None)
			{
				Velocity = VelDampen*VSize(Velocity)*(Normal(Velocity) Cross vect(0, 0, 1));
				if(FRand() < 0.5)
					Velocity = -Velocity;	// go right, instead of left, 50% of the time
				StartSpinMag = RotDampen*StartSpinMag;
				RandSpin(StartSpinMag);
				// play a noise
				//PlaySound(CowHeadBounce);
				self.PlaySound(CowHeadBounce,,1.0,false,200.0,GetRandPitch());	// xPatch: Sound Fix
			}
			else
				BounceRecoil(HitNormal);

			// if we're burned, we're not lethal anymore--we don't make anthrax
			if(!bBurned)
			{
				// if not stopped, and still going pretty fast, then fire out some puffs
				if(speed > MIN_MAKE_PUFF_SPEED) 
				{
					// throw out an anth puff
					MakeAnthPuff(HitNormal);
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	bCanPlayBounceSound=true;
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function BounceRecoil(vector HitNormal)
{
	Super.BounceRecoil(HitNormal);
	// play a noise
	if(bCanPlayBounceSound)
	{
		//PlaySound(CowHeadBounce,,,,0.0,GetRandPitch());
		self.PlaySound(CowHeadBounce,,1.0,false,200.0,GetRandPitch());	// xPatch: Sound Fix
		SetTimer(GetSoundDuration(CowHeadBounce), false);
		if(VSize(Velocity) < MinExtraSoundSpeed)
			bCanPlayBounceSound=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local vector HitNormal;

	if(Other != Instigator)
	{
		// Don't bounce off windows, break them
		if(Window(Other) != None)
			Other.Bump(self);
		else
		{
			HitNormal = -Normal(Velocity);

			BounceOffSomething(HitNormal, Other);

			// after bouncing off it, hurt the thing we hit
			Other.TakeDamage(Damage, Instigator, HitLocation, -MomentumTransfer*HitNormal, MyDamageType);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	BounceOffSomething(HitNormal, Wall);
}

/*
function BeginState()
{
	PlayAnim('Still', 0.1);
	atrails = spawn(class'AnthTrailList',,,Location);
}
*/
//}

defaultproperties
{
	Speed=1000.000000
	MaxSpeed=1300.000000
	MinExtraSoundSpeed=200
    MinSpeedForBounce=60
	MinSpeedForSelfDamage=400
	Damage=5.000000
	MomentumTransfer=10000.000000
	MyDamageType=class'SmashDamage'
//	SpawnSound=Sound'WarEffects.EightBall.Ignite'
	LifeSpan=100.000000
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.cowhead'
	Skins[0]=Texture'StuffSkins.Items.CowHead_new'
	BurnSkin=Texture'ChameleonSkins.Special.BurnVictim'
	AmbientGlow=96
	bBounce=true
	bFixedRotationDir=true
	ForceType=FT_DragAlong
	ForceRadius=100.000000
	ForceScale=4.000000
	CollisionHeight=12.0
	CollisionRadius=20.0
	StartSpinMag=10000
	VelDampen=0.7
	RotDampen=0.9
	Health=40
	Acceleration=(Z=-1500)
	CowHeadBounce=Sound'WeaponSounds.cowhead_bounce'
	Mass=16
	//CowHeadGas=Sound'WeaponSounds.cowhead_gas'
	bProjTarget=true
	bUseCylinderCollision=true
	bCanPlayBounceSound=true
	ExplodeSound=Sound'WeaponSounds.flesh_explode'

	bNetTemporary=false
	bUpdateSimulatedPosition=true
	bMakeCloudOnBounce=true
}
