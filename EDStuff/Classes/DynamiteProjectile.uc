//////////////////////////////////////////////////////////////////////////////
// GrenadeProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual grenade that goes flying through the air.
//
///////////////////////////////////////////////////////////////////////////////
class DynamiteProjectile extends P2Projectile;

var float MinChargeTime;		// What's the min time for how long it can be charged. This


var DynamiteSparkler	wickfire;    // added by Tom

var Sound   dynamitefusethrown;

var byte	BounceMax;								// Determines the min velocity.
var float MinTossTime;			// Same as above, but smaller for when he lightly tosses it.
var float UpRatio;				// How fast up it should go in relation to how fast outward it goes.
var bool  bArmed;				// If it will go off at the touch of a pawn, or in a few seconds
var bool  bBouncedOnce;			// Has bounced at least once if true
var vector SameSpot;			// Last spot we bounced when below min speed
var int	  SameSpotBounce;		// Number of times we've bounced slowly in the same spot.
								// Counting these up and doing something about it when we're too high
								// helps us from never settling down.
var Sound dynamitebounce;
var Sound NullSound;
var GrenadeTrail            GTrail;		// grenade smoke trail to make them easier to see


const FORCE_RAD_CHECK		= 50;
const SAME_SPOT_RADIUS		= 30;
const SAME_SPOT_BOUNCE_MAX	= 4;



//Dopamine
function SetFuseTime(int fusetime)
{
//	DetonateTime=DetonateTime;
	SetTimer(DetonateTime - FuseTime, false);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(DetonateTime > 0)
	{
		// Arm the grenade
		SetTimer(DetonateTime,false);

	}
	

///////////////////////////////////////////////////////////////////////////
 	// Call this on client or single player
	if ( Level.NetMode != NM_DedicatedServer)
	{
		wickfire = spawn(class'DynamiteSparkler', self,,Location);
		wickfire.SetBase(self);
		fusesound1();
	}
//////////////////////////////////////////////////////////////////////////




}





///////////////////////////////////////////////////////////////////////////////
	simulated function fusesound1()
	{
		PlaySound(dynamitefusethrown, SLOT_Misc, 1.0, false, 112.0, 1.0);
		//PlaySound(DynamiteFuseThrown);
		//SetTimer(GetSoundDuration(dynamitefusethrown), false);
	}


///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	KillSmokeTrail();
	Super.Destroyed();


		if(wickfire != None)
	{
		wickfire.Destroy();
		wickfire = None;
	}
	Super.Destroyed();

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function MakeSmokeTrail()
{
//	if(GTrail == None)
//	{
//		if(Level.Game.bIsSinglePlayer)
//		{
			// Send player as owner so it will keep up in slomo time
//			GTrail = spawn(class'Fx.GrenadeTrail',Owner,,Location);
//			GTrail.SetBase(self);
//		}
//		else
//			GTrail = spawn(class'Fx.GrenadeTrail',self,,Location);
//	}
}
function KillSmokeTrail()
{
	if(GTrail != None)
	{
		GTrail.Destroy();
		GTrail = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Send it with a certain speed and arm it
///////////////////////////////////////////////////////////////////////////////
function SetupThrown(float ChargeTime)
{
	local float ThrowMod;

//	if ( Role == ROLE_Authority )
//	{
		if(bArmed)
		{
			if(ChargeTime < MinChargeTime)
				ChargeTime = MinChargeTime;
			ThrowMod = 0.4;
			MakeSmokeTrail();
		}
		else
		{
			if(ChargeTime < MinTossTime)
				ChargeTime = MinTossTime;
			ThrowMod = 1.0;
		}

		Speed = Speed*ChargeTime;
		if(Speed > MaxSpeed)
			Speed = MaxSpeed;
		//log(self$" setupshot "$ChargeTime$" speed "$speed);

		if(bArmed)
			// goes up a ratio of what it goes forward
			TossZ = Speed*UpRatio;
		else
			TossZ = 0;
		
		Velocity = GetThrownVelocity(Instigator, Rotation, ThrowMod);

		//log(self$" speed "$Speed$" vel "$Velocity$" charge time "$ChargeTime);

		RandSpin(StartSpinMag);
//	}
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
	// If you're moving, you can't take damage (unless it's
	// kicking/bludgeoning from anyone or bullet damage from an npc damage, then you can take it anytime)
	if(Physics == PHYS_Projectile
		&& !(ClassIsChildOf(damageType, class'BludgeonDamage')
			|| (ClassIsChildOf(damageType, class'BulletDamage')
				&& P2Player(Instigator.Controller) == None)))
		return;

	//log(self$" take damage ");
	// several things don't hurt us
	if(ClassIsChildOf(damageType, class'AnthDamage')
		|| damageType == class'ElectricalDamage')
		return;

	SetPhysics(PHYS_Projectile);
	// Make sure it can move
	bBounce=true;
	Acceleration = default.Acceleration;

	// You can kick your own alt-fired grenades and kick normally thrown grenades, but
	// you can't kick another's (usually only in MP with other players) alt-fired grenades.
	// But this handles any and all damage from another other than the instigator. Basically
	// the alt-fired acts like a mine and as soon as they do anything to it, it blows up.
	if(DynamiteAltProjectile(self) != None
		&& !RelatedToMe(InstigatedBy))
	{
		Dam = Health;
	}
	else
	{
		// For kicking, shovel, baton type damages, the health is basically a 
		// counter for how many hits (minus the last one) you can deliver
		// to a grenade before it blows up
		// Also, because of the nature of the instantaneous momentum delivery
		// and the full contact, don't add to the velocity, simply set the velocity.
		if(ClassIsChildOf(damageType, class'BludgeonDamage')
			&& damageType != class'CuttingDamage')
		{
			// If you kick it, you know 'own' it, so it won't blow up on you
			// anymore, but will blow up on anyone else (like, if you kick it
			// back at the attacker). The explosion will of course still hurt anyone.
			//log(self$" setting instigator "$Instigator$" to instigatedby "$Instigatedby);
			Instigator = instigatedBy;
			Dam = 1;
			Velocity=(Momentum/Mass);
		}
		else
		{
			Velocity+=(Momentum/Mass);
		}
		MakeSmokeTrail();
	}

	Health-=Dam;

	if(Health <= 0)
	{
		GenExplosion(HitLocation, vect(0, 0, 1), None);
		return;
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function BounceRecoil(vector HitNormal)
{
	local vector addvec;

//	log(self$" BounceRecoil");
	if(Physics != PHYS_Projectile)
		SetPhysics(PHYS_Projectile);
	// Make the normal a little crazy to promote some random bouncing
	addvec = (VRand()*0.05);
	if(addvec.z < 0)
		addvec.z = -addvec.z;
	HitNormal += addvec;

	Super.BounceRecoil(HitNormal);
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
		bBouncedOnce=true;

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
			KillSmokeTrail();
		}
		else	// do bouncing
			BounceRecoil(HitNormal);

		// Throw out some hit effects, like dust or sparks
		smoke1 = spawn(class'Fx.SmokeHitPuffMelee',Owner,,Location,rotator(HitNormal));
		if(!bStopped)
			// play a noise
			smoke1.PlaySound(dynamitebounce,,,,TransientSoundRadius,GetRandPitch());
	}
}

///////////////////////////////////////////////////////////////////////////////
// Have the un-armed projectile give the player back itself (as weapon ammo)
///////////////////////////////////////////////////////////////////////////////
simulated function MakePickup(Pawn Other)
{
	local Inventory Copy;
	local P2Weapon p2weap;
	local DynamitePickup gp;

	// Has to have bounced at least once to allow it to be picked up
	// (other-wise you'd be picking them up as you dropped them)
	if(bBouncedOnce
		&& Other != None)
	{
		if(Role == ROLE_Authority)
		{
			// Quickly make a pickup inside the player, then try to get the player
			// to touch it.. then remove them both, if he does.
			gp = spawn(class'DynamitePickup',,,Other.Location);
			if(gp != None)
			{
				gp.RespawnTime=0.0; // Don't allow this to respawn
				gp.AmmoGiveCount = 1;	// There's only one grenade here.
				gp.MPAmmoGiveCount = 1;
				gp.GotoState('Pickup');
				gp.Touch(Other);
				gp.Destroy();
				// Conditional destroy if we're a single player game--it gets better
				// service. A server/client game will always destroy the grenade.
				if(gp == None
					|| gp.bDeleteMe
					|| Level.NetMode == NM_DedicatedServer)
					Destroy();
			}
		}
		else
			Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
// We can hurt ourselves with this if it's bounced once.
// Otherwise, it hurts everyone else all the same
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local SmokeHitPuff smoke1;

	/*Dopamine we do not want to detonate on pawn contact
	*/ // Kamek: we do now!
	if (Pawn(Other) != None
		&& Pawn(Other).Health > 0)
	{
		// If it was un-armed,
		// and the special alt-grenade,
		// allow it to be picked back up
		if(!bArmed
			&& DynamiteAltProjectile(self) != None
			&& Pawn(Other).bCanPickupInventory
			// Only allow maker to pick it back up
			&& MadeMe(Pawn(Other)))
		{
			// SP players can pick them back up after alt-fired
			if(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
			{
				MakePickup(Pawn(Other));
				if(bDeleteMe)
					return;
			}
			else // Let the guy that dropped them run over them in MP
				// it's better for team games and we wanted something consistent in MP.
				return;
		}
		// If not, check to detonate
		else if(!RelatedToMe(Pawn(Other)))
		{
			GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
		}
	}
	else
//	*/
	//{
		// Bounce off static things
		if(Other.bStatic)
		{
			// Throw out some hit effects, like dust or sparks
			smoke1 = spawn(class'Fx.SmokeHitPuffMelee',Owner,,Location,rotator(Normal(HitLocation-Other.Location)));
			// play a noise
			smoke1.PlaySound(dynamitebounce,,,,TransientSoundRadius,GetRandPitch());
			BounceRecoil(-Normal(Velocity));
		}
		else
			Other.Bump(self);
	//}
}

///////////////////////////////////////////////////////////////////////////////
// It explodes after DetonateTime no matter what
///////////////////////////////////////////////////////////////////////////////
simulated function Timer()
{
	PlaySound(None, SLOT_Misc, 1.0, false, 112.0, 1.0);
	GenExplosion(Location, vect(0,0,1), None);
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local GrenadeExplosion exp;
	local vector WallHitPoint;

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
		exp = spawn(class'DynamiteExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
		exp.CheckForHitType(Other);
		exp.ShakeCamera(exp.ExplosionDamage);
		exp.ForceLocation = WallHitPoint;
	}
 	Destroy();
}

defaultproperties
{
     MinChargeTime=0.500000
     BounceMax=3
     MinTossTime=0.100000
     UpRatio=0.450000
     bArmed=True
     dynamitebounce=Sound'WeaponSounds.grenade_bounce'
//     NullSound=Sound'ed_moresounds.Weapons.Null'
     DetonateTime=7.000000
     MinSpeedForBounce=100.000000
     VelDampen=0.300000
     RotDampen=0.300000
     StartSpinMag=-400000.000000
     Health=4
     speed=1200.000000
     MaxSpeed=2800.000000
     DamageRadius=0.000000
     MomentumTransfer=800000.000000
     MyDamageType=Class'AWEffects.ScytheDamage'
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     DrawType=DT_StaticMesh
     LifeSpan=0.000000
     AmbientSound=Sound'EDWeaponSounds.Heavy.DynamiteFuse'
     Acceleration=(Z=-1000.000000)
     StaticMesh=StaticMesh'ED_TPMeshes.Emitter.dynamite'
     AmbientGlow=64
     TransientSoundRadius=150.000000
     CollisionRadius=50.000000
     CollisionHeight=10.000000
     bProjTarget=True
     bBounce=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
}
