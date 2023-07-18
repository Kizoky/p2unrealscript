//////////////////////////////////////////////////////////////////////////////
// DynamiteProjectile.
// New re-written class, based on GrenadeProjectile.
// Man Chrzan, 2021. 
///////////////////////////////////////////////////////////////////////////////

class DynamiteProjectile extends GrenadeProjectile;   

var byte	BounceMax;								// Determines the min velocity.
var DynamiteSparkler	wickfire;    				// added by Tom
var Sound   DynamiteFuse;

///////////////////////////////////////////////////////////////////////////////
// Setup the effects and detonation time.
// (ExploTime comes from the weapon)
///////////////////////////////////////////////////////////////////////////////
function SetupDynamite(float ExploTime)
{
	if(ExploTime > 0)
	{
		// Arm the dynamite
		SetTimer(ExploTime,false);
	}
	MakeWickfire();
}

function MakeWickfire()
{
	if(wickfire == None)
	{
		if(Level.Game.bIsSinglePlayer)
		{
			// Send player as owner so it will keep up in slomo time
			wickfire = spawn(class'DynamiteSparkler',Owner,,Location); 
			wickfire.SetBase(self);
		}
		else
			wickfire = spawn(class'DynamiteSparkler',self,,Location); 
			
		PlaySound(DynamiteFuse, SLOT_Misc, 3.0, false, 64.0, 1.0);
	}
}

function KillWickfire()
{	
	if(wickfire != None)
	{
		wickfire.Destroy();
		wickfire = None;
	}
	
	if(DynamiteFuse != None)
	{
		PlaySound(GrenadeBounce, SLOT_Misc, 0.01);
		DynamiteFuse = None;
	}
}

function Destroyed()
{
	KillWickfire();
	Super.Destroyed();
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

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local SmokeHitPuff smoke1;
//	local FireMatch match;
//	match = FireMatch(Other);
	
	// Chuj, nie działa.
/*	if(match != None)
	{
		DetonateTime = Class'DynamiteProjectile'.default.DetonateTime;
		SetupDynamite();
	}	*/
	
	if (Pawn(Other) != None
		&& Pawn(Other).Health > 0)
	{
		// If it was un-armed, 
		// and the special alt-grenade, 
		// allow it to be picked back up
		if(!bArmed
			//&& DynamiteAltProjectile(self) != None
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
			if(bArmed)
			GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
		}
	}
	else
	{
		// Bounce off static things
		if(Other.bStatic)
		{
			// Throw out some hit effects, like dust or sparks
			smoke1 = spawn(class'Fx.SmokeHitPuffMelee',Owner,,Location,rotator(Normal(HitLocation-Other.Location)));
			// play a noise
			smoke1.PlaySound(GrenadeBounce,,,,TransientSoundRadius,GetRandPitch());
			BounceRecoil(-Normal(Velocity));
		}
		else
			Other.Bump(self);
	}
}

function MakeSmokeTrail()
{
  //REMOVED
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
			smoke1.PlaySound(GrenadeBounce,,,,TransientSoundRadius,GetRandPitch());
	}
}

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

defaultproperties
{
     BounceMax=3
     bArmed=True
     DetonateTime=5.000000 //was 7
     VelDampen=0.300000
     RotDampen=0.300000
     MomentumTransfer=800000.000000
     StaticMesh=StaticMesh'ED_TPMeshes.Emitter.dynamite'
     CollisionRadius=+00018.000000
     CollisionHeight=+00018.000000
	 //StartSpinMag=-400000
	 StartSpinMag=150000
	 DynamiteFuse=Sound'WeaponSoundsToo.DynamiteLoop'
}
