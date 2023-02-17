//////////////////////////////////////////////////////////////////////////////
// PLVomitProjectile
// Copyright 2014, Running With Scissors, All Rights Reserved
// Uses damage amount from the PLZombie.
//////////////////////////////////////////////////////////////////////////////
class PLVomitProjectile extends VomitProjectile;

//////////////////////////////////////////////////////////////////////////////
// Vars and shit
//////////////////////////////////////////////////////////////////////////////
var float UseDamage;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
function SetupThrown(vector UseVel, float DamageAmount)
{
	UseDamage = DamageAmount;
	PrepVelocity(UseVel);
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
		if (exp != None)
		{
			exp.ExplosionDamage = UseDamage;
			exp.ForceLocation = WallHitPoint;
		}

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
			exp.ExplosionDamage = UseDamage;
			exp.AddVelocity(Velocity/2);
			exp.ForceLocation = HitLocation;
		}
	}
 	Destroy();
}
