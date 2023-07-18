///////////////////////////////////////////////////////////////////////////////
// LauncherSeekingProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual rocket that goes flying through the air.
// Seeks a target. Like it's ancestor, it can run out of fuel, and then 
// tumble, still potent, to the ground.
// Can bounce BounceMax-1 before it detonates if not hitting target, or
// on collision with a non-static thing.
//
// This one can slow down after a bump, and turn faster to find it's target,
// then blast off again.
//
///////////////////////////////////////////////////////////////////////////////
class NukeSeekingProjectile extends LauncherSeekingProjectile;

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local RocketExplosion exp;
	local vector WallHitPoint, OrigLoc;
	local Actor ViewThing;
	
	if (Role < ROLE_Authority)
		return;

	if(Other != None
		&& Other.bStatic)
	{
		// Make sure the force of this explosion is all the way against the wall that
		// we hit
		OrigLoc = HitLocation;
		WallHitPoint = HitLocation - FORCE_RAD_CHECK*HitNormal;
		if(Trace(HitLocation, HitNormal, WallHitPoint, HitLocation) == None)
		{
			HitLocation = OrigLoc;
			WallHitPoint = OrigLoc;
		}
	}
	else
		WallHitPoint = HitLocation;

	exp = spawn(class'MiniNukeExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
	exp.CheckForHitType(Other);
	exp.ShakeCamera(exp.ExplosionDamage);
	exp.ForceLocation = WallHitPoint;

	// If we're controlling this particular rocket, tell the player about it
	if(Instigator != None
		&& P2Player(Instigator.Controller) != None
		&& P2Player(Instigator.Controller).ViewTarget == self)
	{
		// If we hit a person or animal or interesting thing, view it directly
		if(FPSPawn(Other) != None)
			ViewThing = Other;
		else // Otherwise, just watch the pretty explosion
			ViewThing = exp;
		P2Player(Instigator.Controller).RocketDetonated(ViewThing);
	}

 	Destroy();
}

state Flying
{
	simulated function BlastOff()
	{
		local vector Dir;
		local Actor useowner;

		Dir = vector(Rotation);
		// blast off
		Velocity += BlastOffVelMag*Dir;
		//Velocity.z/=8;
		Acceleration = ForwardAccelerationMag*Dir;

		if (Level.NetMode != NM_DedicatedServer)
		{
			if(Level.Game == None
				|| !Level.Game.bIsSinglePlayer)
				useowner = self;
			else // Send player as owner so it will keep up in slomo time
				useowner = Owner;

			// Send player as owner so it will keep up in slomo time
			if(STrail == None )
			{
				STrail = spawn(class'NukeTrail',useowner,,Location);
				if(Level.Game != None
					&& Level.Game.bIsSinglePlayer)
					STrail.SetBase(self);
			}
			if (FTrail == None )
			{
				FTrail = spawn(class'Fx.RocketFire',useowner,,Location);
				FTrail.SetBase(self);
			}
		}
	}
}

defaultproperties
{
	Skins[0]=Texture'AW7Tex.Nuke.nuclear_rocket'
}
