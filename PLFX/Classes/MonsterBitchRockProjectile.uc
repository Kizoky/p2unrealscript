///////////////////////////////////////////////////////////////////////////////
// MonsterBitchRockProjectile
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Giant flaming rock the Bitch spits out
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchRockProjectile extends P2Projectile;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, whatever the fuck...
///////////////////////////////////////////////////////////////////////////////
var() sound RockBounce;			// Sound made when the rock bounces
var() float WaitToDieTime;		// How long we sit idle until dying
var() float ShrinkAndDieTime;	// Time it takes to shrink and die
var float ShrinkAndDieStart;	// Time we started to shrink and die
var bool bArmed;
var vector SameSpot;			// Last spot we bounced when below min speed
var int	  SameSpotBounce;		// Number of times we've bounced slowly in the same spot.
								// Counting these up and doing something about it when we're too high
								// helps us from never settling down.

const FORCE_RAD_CHECK		= 50;
const SAME_SPOT_RADIUS		= 40;
const SAME_SPOT_BOUNCE_MAX	= 4;
const EXPLODED_DRAWSCALE	= 0.8;

///////////////////////////////////////////////////////////////////////////////
// Set up our spinning
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
	RandSpin(1.0);
}

simulated singular function Touch(Actor Other)
{
	Super.Touch(Other);
	//log(self@"TOUCH"@Other);
	Other.Touch(Self);
}
///////////////////////////////////////////////////////////////////////////////
// If this hits a pawn, it HURTS. A LOT.
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (Pawn(Other) != None && bArmed)
		Other.TakeDamage(Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
	else if (P2Pawn(Other) != None)	// Even if we're not "armed" we're still a giant ball of lava
		P2Pawn(Other).SetOnFire(FPSPawn(Instigator), false);	
	
	Super.ProcessTouch(Other, HitLocation);
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
	
	// Explode when we hit something
	GenExplosion(Location, HitNormal, None);

	if(bBounce == true)
	{
		speed = VSize(Velocity);
		// Check for a slowed speed
		if(speed < MinSpeedForBounce)
		{
			// Check for possible stop by seeing if we're stopped in z and
			// on the ground.
			EndPt = Location;
			EndPt.z-=DIST_CHECK_BELOW;
			// If there is a hit below (ground) then you are stopped.
			if(Trace(newhit, newnormal, EndPt, Location, false) != None)
				bStopped=true;
			else	// if we're not stopping, cap the speed at the minimum
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
					if(SameSpotBounce >= SAME_SPOT_BOUNCE_MAX && !IsInState('ShrinkAndDie'))
						bStopped=true;
				}
			}
		}
		// If we've stopped, zero out the appropriate entries
		if(bStopped)
		{
			bBounce=false;
			Acceleration = vect(0, 0, 0);
			Velocity = vect(0, 0, 0);
			RotationRate.Pitch=0;
			RotationRate.Yaw=0;
			RotationRate.Roll=0;
			SetPhysics(PHYS_None);
		}
		else	// do bouncing
			BounceRecoil(HitNormal);

		// Throw out some hit effects, like dust or sparks
		smoke1 = spawn(class'Fx.SmokeHitPuffMelee',Owner,,Location,rotator(HitNormal));
		if(!bStopped)
			// play a noise
			smoke1.PlaySound(RockBounce,,,,TransientSoundRadius,GetRandPitch());
	}
}

///////////////////////////////////////////////////////////////////////////////
// I splo stuff up
///////////////////////////////////////////////////////////////////////////////
simulated function Explode(vector HitLocation, vector HitNormal)
{
	GenExplosion(HitLocation, HitNormal, None);
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
// Unlike most projectiles, this thing stays in the arena, so the Bitch can
// suck it in and hurt herself
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local MonsterBitchRockExplosion exp;
	local vector WallHitPoint;

	// You only live^H^H^H^Hexplode once
	if(Role == ROLE_Authority && bArmed)
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
		exp = spawn(class'MonsterBitchRockExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
		exp.SetupExp(HitNormal, Other);
		exp.UseNormal = HitNormal;
		exp.ImpactActor = Other;
		exp.ShakeCamera(exp.ExplosionDamage);
		exp.ForceLocation = WallHitPoint;
		bArmed = false;	// No, Spike, you can't explode twice.
		
		// After exploding we shrink down a bit
		GotoState('WaitToDie');
	}
}

///////////////////////////////////////////////////////////////////////////////
// WaitToDie
// Idle here, we can be sucked in by the bitch, but after a set time we shrink
// and vanish.
///////////////////////////////////////////////////////////////////////////////
state WaitToDie
{
	ignores BlowUp, Explode, GenExplosion;
	
	event Touch( Actor Other )
	{
		if (P2Pawn(Other) != None)	// Even if we're not "armed" we're still a giant ball of lava
			P2Pawn(Other).SetOnFire(FPSPawn(Instigator), false);
	}
	event Bump( Actor Other )	
	{
		if (P2Pawn(Other) != None)	// Even if we're not "armed" we're still a giant ball of lava
			P2Pawn(Other).SetOnFire(FPSPawn(Instigator), false);
	}
	
Begin:
	Sleep(WaitToDieTime);
	GotoState('ShrinkAndDie');
}

///////////////////////////////////////////////////////////////////////////////
// ShrinkAndDie
// Gradually melt down and disappear, during this time we're inert and can't
// damage or be inhaled by the bitch.
///////////////////////////////////////////////////////////////////////////////
state ShrinkAndDie
{
	ignores BlowUp, Explode, GenExplosion, Touch;
	
	event BeginState()
	{
		ShrinkAndDieStart = Level.TimeSeconds;
		// Set it so that we can fall and bounce while shrinking
		SetPhysics(PHYS_Falling);
		MinSpeedForBounce=0;
		bBounce=true;
		Velocity.Z = 150;
	}
	event Tick(float dT)
	{
		local float Alpha;
		Alpha = (Level.TimeSeconds - ShrinkAndDieStart) / ShrinkAndDieTime;
		SetCollisionSize(Smerp(Alpha, Default.CollisionRadius, 0), Smerp(Alpha, Default.CollisionHeight, 0));
		SetDrawScale(Smerp(Alpha, Default.DrawScale, 0));
		// Destroy when vanished
		if (Alpha >= 1.0)
			Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bArmed=True
	bBounce=True
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MrD_PL_Mesh.FX.RoundRock'
	Skins[0]=Shader'PL-KamekTex.derp.LavaRock'
	Speed=2000
	MaxSpeed=2000
	Damage=100
	MyDamageType=class'BludgeonDamage'
	DrawScale=0.35
	bUseCylinderCollision=False
	CollisionRadius=250
	CollisionHeight=180
	VelDampen=0.3
	Acceleration=(Z=-500)
	MinSpeedForBounce=200
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
	RotDampen=0.45
	WaitToDieTime=20
	ShrinkAndDieTime=5
}