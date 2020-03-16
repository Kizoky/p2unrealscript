///////////////////////////////////////////////////////////////////////////////
// SkeletonHead
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Skeletons don't bleed
///////////////////////////////////////////////////////////////////////////////
class SkeletonHead extends ZombieHead;

///////////////////////////////////////////////////////////////////////////////
// Bounce off the wall
// Taken from Fragment.uc and modified (warfare code 829)
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall (vector HitNormal, actor HitWallActor)
{
	local Actor HitActor;
	local float speed, dampval;
	local vector checkpoint, NewHitNormal, HitLocation, addvel;
	local PlayerController P;
	local float DistFlew;
	local float MetersFlew;

	// If we're hitting an person, lose a lot of speed, so it will be around him
	// to kick it.
	if(P2Pawn(HitWallActor) != None)
	{
		speed = VSize(Velocity);
		// If it's too slow, or if it's on top of the pawn, don't slow down
		if(speed <= SPEED_READY_TO_STOP
			|| (Location.z - HitWallActor.Location.z) > HitWallActor.CollisionHeight)
			dampval = 1.0;
		else
			dampval = PAWN_DAMPEN_VELOCITY;
	}
	else
		dampval = DAMPEN_VELOCITY;

	Velocity = dampval*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping

	// Bounce the head
	speed = VSize(Velocity);

	// Record time if you weren't in the same spot. When you are, the time is recorded the last time
	// you moved, so it'll lock in that spot if you sit there too long
	if(LastSpot != Location)
	{
		LastSpot = Location;
		SameSpotTime = Level.TimeSeconds;
	}


	// We've landed
	if ( (speed < SPEED_READY_TO_STOP
			&& FPSPawn(HitWallActor) == None)
		|| (Level.TimeSeconds - SameSpotTime) > STOP_TIME)
	{
		// If the surface we've hit is vaguely flat, allow the head to stop
		if(HitNormal.Z > 0.7
			|| (Level.TimeSeconds - SameSpotTime) > STOP_TIME)
		{
			bFixedRotationDir=false;
			RotationRate.Yaw = 0;//RotationRate.Yaw*(DAMPEN_ROTATION);
			RotationRate.Roll = 0;//RotationRate.Roll*(DAMPEN_ROTATION);
			RotationRate.Pitch = 0;//RotationRate.Pitch*(DAMPEN_ROTATION + FRand()*DAMPEN_ROTATION_ADD);

			SetPhysics(PHYS_none);
			bBounce = false;
			TearOffNetworkConnection(None);
			GoToState('RemoveMe');
			// If the player tossed us around somehow (kicked us, hit us), then
			// tell dogs in the area, so they can go retrieve us
			if(PlayerMovedMe != None)
			{
				CallDog(PlayerMovedMe);
				PlayerMovedMe=None;
			}
			// If the player shoveled us, maybe give an achievement for it.
			if (bBeingShoveled)
			{
				DistFlew = VSize(Location - StartPos);
				MetersFlew = DistFlew/UNITS_PER_METER;
				//P2GameInfoSingle(Level.Game).GetPlayer().ClientMessage("head flew"@MetersFlew$"m");
				if (MetersFlew >= METERS_FOR_ACHIEVEMENT)
				{
					foreach DynamicActors(class'PlayerController', P)
						break;
					if(Level.NetMode != NM_DedicatedServer ) P.GetEntryLevel().EvaluateAchievement(P,'ArodWho');
				}
			}
		}
		else if(speed < SPEED_READY_TO_STOP) // If it's not, pick a random new direction to bounce slowly in
		{
			addvel = VRand();
			if(addvel.z < 0)
				addvel.z = -addvel.z;
			addvel.z +=0.25;
			addvel = SPEED_READY_TO_STOP*addvel;
			Velocity += addvel;
		}
	}
	else if (speed > SPEED_HARD_BOUNCE)		// we're still bouncing around
	{
		// Make it rotate slower sometimes and faster sometimes
		RotationRate.Yaw = RotationRate.Yaw*(DAMPEN_ROTATION + FRand()*DAMPEN_ROTATION_ADD);
		RotationRate.Roll = RotationRate.Roll*(DAMPEN_ROTATION + FRand()*DAMPEN_ROTATION_ADD);
		RotationRate.Pitch = RotationRate.Pitch*(DAMPEN_ROTATION + FRand()*DAMPEN_ROTATION_ADD);

		/*
		if(class'P2Player'.static.BloodMode())
		{
			// Blood effects!
			// Check wall surface and leave blood splat on this wall
			checkpoint = Location - BLOOD_CHECK_DIST*HitNormal;
			HitActor = Trace(HitLocation, NewHitNormal, checkpoint, Location, true);
			if ( HitActor != None
				&& HitActor.bWorldGeometry)
			{
				spawn(class'BloodDripSplatMaker',Owner,,HitLocation,rotator(NewHitNormal));
			}
		}
		*/
		
		// play a noise
		if(bCanPlayBounceSound)
		{
			PlaySound(HeadBounce[Rand(HeadBounce.Length)],,1.0,,,GetRandPitch());
			//SetTimer(GetSoundDuration(HeadBounce), false);
			//bCanPlayBounceSound=false;
		}
	}
}

defaultproperties
{
	HeadExplosionEffect=class'SkeletonHeadEffects'
	ExplodeHeadSound=Sound'WeaponSounds.explosion_small'
}
