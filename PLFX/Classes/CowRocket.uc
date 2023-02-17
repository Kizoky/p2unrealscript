///////////////////////////////////////////////////////////////////////////////
// CowRocket
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// "I gotta go Julia, we got cows!"
///////////////////////////////////////////////////////////////////////////////
class CowRocket extends CatRocket;

simulated function PostBeginPlay()
{
	local vector Dir;

	Super(P2Projectile).PostBeginPlay();

	Dir = vector(Rotation);
	Velocity = speed * Dir;
}

auto state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local MeatExplosion exp;
		local Rotator NewRot;
		local coords usecoords;

		if(!bExploded)
		{
			if(class'P2Player'.static.BloodMode())
			{
				exp = spawn(class'PawnExplosion',,,HitLocation);
				exp.FitToNormal(HitNormal);
				usecoords = GetBoneCoords('Bip01 Head');
				spawn(class'CowHeadExplode',,,usecoords.Origin);

				NewRot = Rotator(-HitNormal);
				NewRot.Roll=(65536*FRand());
				spawn(class'BloodMachineGunSplat',self,,HitLocation,NewRot);
			}
			else
				spawn(class'RocketSmokePuff',,,Location);	// gotta give the lame no-blood mode something!

			bExploded=true;

 			Destroy();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Play your movement noise again
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer()
	{
		PlaySound(CatFlying, SLOT_Misc, 1.0, false, TransientSoundRadius, 1.0);
		SetTimer(GetSoundDuration(CatFlying), false);
	}
	function BeginState()
	{
		if ( PhysicsVolume.bWaterVolume )
		{
			//bHitWater = True;
			Velocity=0.6*Velocity;
		}
		// Play initial flying sound
		PlaySound(CatStartFlying, SLOT_Misc, 1.0, false, TransientSoundRadius, 1.0);
		SetTimer(GetSoundDuration(CatStartFlying), false);

		PlayAnim('freefall');
	}
}

defaultproperties
{
	 Mesh=SkeletalMesh'PLAnimals.meshCow_PL'
	 Skins[0]=Texture'AW_Characters.Zombie_Cows.AW_Cow3'
	 CatStartFlying=Sound'AWSoundFX.Cow.cowconfusedmoo'
	 CatFlying=Sound'AWSoundFX.Cow.cowconfusedmoo'
	 Mass=200
     BouncingSound=Sound'AWSoundFX.Cow.CowHeadExplode'
	 TransientSoundRadius=500
}