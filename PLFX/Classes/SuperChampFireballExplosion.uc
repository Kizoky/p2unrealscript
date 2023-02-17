class SuperChampFireballExplosion extends MutantChampFireballExplosion;

auto state Exploding
{
Begin:
	if (bGroundHit)
 		PlaySound(GrenadeExplodeGround,,1.0,,,,true);
	else
		PlaySound(GrenadeExplodeAir,,1.0,,,,true);

	Sleep(DelayToHurtTime);

	MyCheckHurtRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, Location);
	NotifyPawns();
}

///////////////////////////////////////////////////////////////////////////////
// For some reason HurtRadius is flakey, so we use this slower version to
// make sure it hits stuff
///////////////////////////////////////////////////////////////////////////////
simulated function MyCheckHurtRadius( float DamageAmount, float DamageRadius, 
										 class<DamageType> DamageType, float MomMag, vector HitLocation )
{
	// Call explosion form of HurtRadiusEX, and also passes in the instigator and our hero as immune to the damage
	local Actor Hero;

	if (Instigator.Controller != None && LambController(Instigator.Controller) != None)
		Hero = LambController(Instigator.Controller).Hero;
		
	HurtRadiusEX(DamageAmount, DamageRadius, DamageType, MomMag, HitLocation,,,true,true,Hero,,true);
	
	/*
	local actor Victims;
	local float damageScale, dist, OldHealth;
	local vector dir;
	local vector Momentum;
	local bool bDoHurt;
	local PlayerController PlayerLocal;
	local bool bSuicideTaliban;
	
	foreach CollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (!Victims.bHidden)
			&& (Victims != self) 
			&& (Victims.Role == ROLE_Authority) )
		{
			// If it's a player pawn (main player in single, or anyone in multi)
			// then check to have explosions blocked by 'walls'. 
			if(Pawn(Victims) != None
				&& PlayerController(Pawn(Victims).Controller) != None)
			{
				// solid check
				if(FastTrace(Victims.Location, Location))
					bDoHurt=true;
				else // something in the way, so don't do hurt this time
					bDoHurt=false;
			}
			else
				bDoHurt=true;
				
			// Ignore our instigator and his hero
			if (Victims == Instigator
				|| (Instigator.Controller != None && LambController(Instigator.Controller) != None && LambController(Instigator.Controller).Hero == Victims))
				bDoHurt=false;

			if(bDoHurt)
			{
				if (Pawn(Victims) != None)				
					OldHealth = Pawn(Victims).Health;
				else
					OldHealth = 0;
				dir = Victims.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist; 
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
				Momentum = (damageScale * MomMag * dir);
				// Create a fake momentum vector which emphasizes being thrown into the air
				if(dir.z > 0)
					Momentum.z += (MomMag*(1- dist/DamageRadius));
				Victims.TakeDamage
				(
					damageScale * DamageAmount,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					Momentum,
					DamageType
				);
				// Kamek 6-19 napalm check
				if (Self.IsA('NapalmExplosion'))
				{
					if (PeopleBurned >= 5
						&& Instigator != None
						&& Instigator.Controller != None
						&& PlayerController(Instigator.Controller) != None)
						PlayerController(Instigator.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Instigator.Controller),'GoodMorningVietnam');
					PeopleBurned++;
					//debuglog(self@"people burned"@peopleburned);
				}	
				if (Pawn(Victims) != None
					&& OldHealth > 0
					&& Pawn(Victims).Health <= 0)
				{
					//log(self@"killed"@Victims,'Debug');
					Kills++;
					if (Victims.IsA('Kumquat') || Victims.IsA('Fanatic'))
						bSuicideTaliban=True;
				}
			}
		} 
	}
	*/
}
