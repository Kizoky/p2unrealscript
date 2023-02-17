class HammerAmmoInv extends BatonAmmoInv;

var() class<DamageType> HeadDamageTypeInflicted;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local vector mom;
	local float UseDamage;
	local float PercentUpBody;
	local class<DamageType> UseDamageType;

	if ( Other == None )
		return;

	if(Pawn(Other) == None
		&& PeoplePart(Other) == None)
	{
		// randomly orient the splat on the wall (rotate around the normal)
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
			
		PercentUpBody = (HitLocation.Z - Other.Location.Z) / Other.CollisionHeight;

		// If it's a headshot, explode the head
		if (P2MoCapPawn(Other) != None				// MoCap pawns only
			&& P2Pawn(Other).bHasHead				// Pawns with heads only
			&& P2Pawn(Other).bHeadCanComeOff		// Pawns with REMOVABLE heads only
			&& P2MoCapPawn(Other).MyHead != None	// Pawn has a head
			&& PercentUpBody > P2Pawn(Other).HEAD_RATIO_OF_FULL_HEIGHT	// Headshot ok
			)
			UseDamageType = HeadDamageTypeInflicted;
		else
			UseDamageType = DamageTypeInflicted;

		if(P2Weapon(W).bAltFiring)
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, -MomentumHitMag*Y  + MomentumHitMag*vect(0, 0, 1.0)*(FRand() + 0.2), UseDamageType);
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

				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, -MomentumHitMag*Z + MomentumHitMag*mom, UseDamageType);
			}
		}
	}
}

defaultproperties
{
	BatonHit=Sound'EDWeaponSounds.Fight.Punch1'
	DamageTypeInflicted=class'BludgeonDamage'
	HeadDamageTypeInflicted=class'SledgeDamage'
	DamageAmount=20
}
