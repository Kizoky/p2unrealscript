class PL_DildoAmmoInv extends InfiniteAmmoInv;

var Sound BatonHit;

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local vector mom;
	local float UseDamage;

	if ( Other == None )
		return;

	if(Pawn(Other) == None
		&& PeoplePart(Other) == None)
	{
		NewRot = Rotator(-HitNormal);
		NewRot.Roll=(65536*FRand());

		smoke1 = Spawn(class'Fx.SmokeHitPuffMelee',,,HitLocation, Rotator(HitNormal));
		if(FRand()<0.3)
		{
			dirt1 = Spawn(class'Fx.DirtClodsMachineGun',,,HitLocation, Rotator(HitNormal));
		}
		if(FRand()<0.15)
		{
			spark1 = Spawn(class'Fx.SparkHitMachineGun',,,HitLocation, Rotator(HitNormal));
		}
	}


	if ( (Other != self) && (Other != Owner) ) 
	{
		Instigator.PlaySound(BatonHit, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());

		if(Level.Game != None
			&& Level.Game.bIsSinglePlayer)
			UseDamage = DamageAmount;
		else
			UseDamage = DamageAmountMP;

		if(!P2Weapon(W).bAltFiring)
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, -MomentumHitMag*Y  + MomentumHitMag*vect(0, 0, 1.0)*(FRand() + 0.2), DamageTypeInflicted);
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				mom = VRand();
				mom.z=0;
				mom.x*=0.1;
				mom.y*=0.1;

				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, -MomentumHitMag*Z + MomentumHitMag*mom, DamageTypeInflicted);
			}
		}
	}
}

defaultproperties
{
     BatonHit=Sound'WeaponSounds.foot_kickbody'
     DamageAmount=10.000000
     MomentumHitMag=30000.000000
     DamageTypeInflicted=Class'PL_DildoDamage'
     DamageAmountMP=25.000000
     bInstantHit=True
     Texture=Texture'MrD_PL_Tex.HUD.chud'
     TransientSoundRadius=80.000000
}
