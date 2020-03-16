//=============================================================================
// MrDTNadeProjectile.
//=============================================================================
class MrDKNadeProjectile extends GrenadeProjectile;




///////////////////////////////////////////////////////////////////////////////
// Have the un-armed projectile give the player back itself (as weapon ammo)
///////////////////////////////////////////////////////////////////////////////
simulated function MakePickup(Pawn Other)
{
	local Inventory Copy;
	local P2Weapon p2weap;
	local MrDKNadePickup gp;

	// Has to have bounced at least once to allow it to be picked up
	// (other-wise you'd be picking them up as you dropped them)
	if(bBouncedOnce
		&& Other != None)
	{
		if(Role == ROLE_Authority)
		{
			// Quickly make a pickup inside the player, then try to get the player
			// to touch it.. then remove them both, if he does.
			gp = spawn(class'MrDKNadePickup',,,Other.Location);
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

	if (Pawn(Other) != None
		&& Pawn(Other).Health > 0)
	{
		// If it was un-armed,
		// and the special alt-grenade,
		// allow it to be picked back up
		if(!bArmed
			&& MrDKNadeAltProjectile(self) != None
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

///////////////////////////////////////////////////////////////////////////////
// It explodes after DetonateTime no matter what
///////////////////////////////////////////////////////////////////////////////
simulated function Timer()
{
	GenExplosion(Location, vect(0,0,1), None);
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local MrDKNadeExplosion exp;
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
//		expb = spawn(class'MrDKNadeBoom',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
		exp = spawn(class'MrDKNadeExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
		exp.CheckForHitType(Other);
		exp.ShakeCamera(exp.ExplosionDamage);
		exp.ForceLocation = WallHitPoint;
	}
 	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// JustThrown
// Don't let fire damage effect a molotov just after it was thrown. Wait a split
// second. Before, when this wasn't here, if you threw a molotov when you were
// on fire, it burst and would never really get thrown.
///////////////////////////////////////////////////////////////////////////////
auto state JustThrown
{
	///////////////////////////////////////////////////////////////////////////////
	// Take damage or be force around
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation,
								Vector momentum, class<DamageType> damageType)
	{
		// several things don't hurt us
		if(damageType == class'BurnedDamage')
			return;

		Global.TakeDamage(Dam, instigatedBy, hitlocation, momentum, damageType);
	}
Begin:
	Sleep(0.5);
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     Health=10
     MyDamageType=Class'MrDKNadeDamage'
     StaticMesh=StaticMesh'P2R_Meshes_D.Weapons.Krotchy'
     DrawScale=0.150000
     SoundRadius=450.000000
     SoundVolume=100
     CollisionRadius=17.000000
     CollisionHeight=17.000000
}
