///////////////////////////////////////////////////////////////////////////////
// LavaSpewProjectile
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Little chunks of hot rock that spew from the lava when the bitch dives in/out
///////////////////////////////////////////////////////////////////////////////
class LavaSpewProjectile extends P2Projectile;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, whatever the fuck...
///////////////////////////////////////////////////////////////////////////////
var vector SameSpot;			// Last spot we bounced when below min speed
var int	  SameSpotBounce;		// Number of times we've bounced slowly in the same spot.
								// Counting these up and doing something about it when we're too high
								// helps us from never settling down.
var FireTorsoEmitter MyFire;	// Fire emitter
var class<FireTorsoEmitter> FireClass;	// Class of fire emitter								
var float ShrinkRate;			// Rate we shrink to nothingness

const FORCE_RAD_CHECK		= 50;
const SAME_SPOT_RADIUS		= 40;
const SAME_SPOT_BOUNCE_MAX	= 4;

///////////////////////////////////////////////////////////////////////////////
// Set up our spinning and fire
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	RotationRate = RotRand();
	MyFire = Spawn(FireClass, Instigator, , Location);
	MyFire.SetBase(self);
	MyFire.SetPawns(None, FPSPawn(Instigator));
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Kill off the fire
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	if (MyFire != None)
	{
		MyFire.GotoState('Fading');
		MyFire = None;
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// If this hits a pawn, they get lit on fire
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (P2Pawn(Other) != None && MyFire != None)
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
					if(SameSpotBounce >= SAME_SPOT_BOUNCE_MAX)
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
			GotoState('Dying');
		}
		else	// do bouncing
			BounceRecoil(HitNormal);

		// Throw out some hit effects, like dust or sparks
		smoke1 = spawn(class'Fx.SmokeHitPuffMelee',Owner,,Location,rotator(HitNormal));
		//if(!bStopped)
			// play a noise
			//smoke1.PlaySound(RockBounce,,,,TransientSoundRadius,GetRandPitch());
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dying
{
	event Tick(float dT)
	{
		local float NewDrawScale;
		
		NewDrawScale = DrawScale - ShrinkRate * dT;
		if (NewDrawScale <= 0)
			Destroy();
		else
			SetDrawScale(NewDrawScale);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bBounce=True
	Speed=2000
	MaxSpeed=2500
	VelDampen=0.5
	Acceleration=(Z=-1000)
	MinSpeedForBounce=200
	RotationRate=(Yaw=50000)
	bFixedRotationDir=true
	RotDampen=0.45
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock02'
	FireClass=class'LavaProjectileFire'
	ShrinkRate=1.0
	TossZ=1500
}