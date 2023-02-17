///////////////////////////////////////////////////////////////////////////////
// RockProjectile
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Various rocks that fall from the ceiling when the Bitch pounds the ground hard
///////////////////////////////////////////////////////////////////////////////
class RockProjectile extends P2Projectile;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, whatever the fuck...
///////////////////////////////////////////////////////////////////////////////
struct RandomRock				// Array of random rocks to use
{
	var() StaticMesh StaticMesh;	// Static mesh to use
	var() array<Material> Skins;	// Skins to use
	var() float DrawScale;			// DrawScale to use
};
var() array<RandomRock> RandomRocks;	// Array of random rocks
var vector SameSpot;			// Last spot we bounced when below min speed
var int	  SameSpotBounce;		// Number of times we've bounced slowly in the same spot.
								// Counting these up and doing something about it when we're too high
								// helps us from never settling down.
var float ShrinkRate;			// Rate we shrink to nothingness
var bool bBouncedOnce;			// True if we've bounced once
var sound RockBounce;			// Sound made when bouncing

const FORCE_RAD_CHECK		= 50;
const SAME_SPOT_RADIUS		= 40;
const SAME_SPOT_BOUNCE_MAX	= 4;

///////////////////////////////////////////////////////////////////////////////
// Set up our spinning and display
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	local int i, j;
	
	RotationRate = RotRand();
	
	i = Rand(RandomRocks.Length);
	SetStaticMesh(RandomRocks[i].StaticMesh);
	if (RandomRocks[i].DrawScale != 0)
		SetDrawScale(RandomRocks[i].DrawScale);
	if (RandomRocks[i].Skins.Length != 0)
	{
		Skins.Length = RandomRocks[i].Skins.Length;
		for (j = 0; j < Skins.Length; j++)
			Skins[j] = RandomRocks[i].Skins[j];
	}
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// If this hits a pawn, they take some damage, but only on the way down
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	Other.TakeDamage(Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
	
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
		bBouncedOnce = true;
		if(!bStopped)
			// play a noise
			smoke1.PlaySound(RockBounce,,,,TransientSoundRadius,GetRandPitch());
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
	Speed=3000
	MaxSpeed=6000
	VelDampen=0.1
	Acceleration=(Z=-6000)
	MinSpeedForBounce=200
	RotationRate=(Yaw=50000)
	bFixedRotationDir=true
	RotDampen=0.1
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock02'
	ShrinkRate=1.0
	TossZ=1500
	Damage=45
	MyDamageType=class'P2Damage'
	RandomRocks[0]=(StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock01')
	RandomRocks[1]=(StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock02')
	RandomRocks[2]=(StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock03')
	RandomRocks[3]=(StaticMesh=StaticMesh'MrD_PL_Mesh.FX.RoundRock',DrawScale=0.1)
}