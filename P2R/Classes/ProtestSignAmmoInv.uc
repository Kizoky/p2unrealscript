class ProtestSignAmmoInv extends ShovelAmmoInv;

/*
var Sound BatonHit;

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
//	BatonHit=Sound'WeaponSounds.foot_kickbody'
	DamageAmount=10.000000
//	MomentumHitMag=30000.000000
	DamageTypeInflicted=Class'ProtestSignDamage'
	AltDamageTypeInflicted=class'ProtestSignDamage'
	AltDamageTypeInflictedSever=class'ProtestSignDamage'
//	DamageAmountMP=25.000000
	bInstantHit=True
	Texture=Texture'P2R_Tex_D.Weapons.Protest_HUD'
	ShovelStab=Sound'WeaponSounds.foot_kickbody'
	ShovelHitWall=Sound'WeaponSounds.foot_kickwall'
	ShovelHitBody=Sound'WeaponSounds.foot_kickhead'
//	TransientSoundRadius=80.000000
}

*/

var Sound SignHitBody;
var Sound SignStab;
var Sound SignHitWall;

const MIN_Z_MOMENTUM = 0.3;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local vector Momentum;

	if ( Other == None )
		return;

	if(Pawn(Other) == None
		&& PeoplePart(Other) == None)
	{
		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-HitNormal);
		NewRot.Roll=(65536*FRand());

		smoke1 = Spawn(class'Fx.SmokeHitPuffMelee',Owner,,HitLocation, Rotator(HitNormal));
		if(FRand()<0.3)
		{
			dirt1 = Spawn(class'Fx.DirtClodsMachineGun',Owner,,HitLocation, Rotator(HitNormal));
		}
		if(FRand()<0.15)
		{
			spark1 = Spawn(class'Fx.SparkHitMachineGun',Owner,,HitLocation, Rotator(HitNormal));
		}
	}


	if ( (Other != self) && (Other != Owner) ) 
	{
		if(!P2Weapon(W).bAltFiring)
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = (Y+Z)/2;
				// Ensure things go up always at least some.
				if(Momentum.z < 2*MIN_Z_MOMENTUM)
					Momentum.z = (MIN_Z_MOMENTUM*FRand()) + MIN_Z_MOMENTUM;
				Momentum = MomentumHitMag*Momentum;

				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
			}
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = MomentumHitMag*X + MomentumHitMag*vect(0, 0, 1.0)*FRand();				
				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, AltDamageTypeInflicted);
			}
		}

		if(FPSPawn(Other) != None)
		{
			if(P2Weapon(W).bAltFiring)
			{
				Instigator.PlayOwnedSound(SignStab, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlaySound(SignStab, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
			}
			else
			{
				Instigator.PlayOwnedSound(SignHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlaySound(SignHitBody, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
			}
		}
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(SignHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
			{
				Instigator.PlayOwnedSound(SignHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlaySound(SignHitWall, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
			}
		}
	}
	
	// If we hit a pawn make the weapon a little bloody
	if ((W.Class == class'ProtestSignWeapon')
		&& Pawn(Other) != None
		&& (P2MocapPawn(Other) == None
		|| P2MocapPawn(Other).MyRace < RACE_Automaton))
		P2BloodWeapon(W).DrewBlood();
}

defaultproperties
{
	DamageAmount=10.000000
	DamageTypeInflicted=Class'ProtestSignDamage'
	AltDamageTypeInflicted=class'ProtestSignDamage'
	AltDamageTypeInflictedSever=class'ProtestSignDamage'
	bInstantHit=True
	Texture=Texture'P2R_Tex_D.Weapons.Protest_HUD'
	SignStab=Sound'WeaponSounds.foot_kickbody'
	SignHitWall=Sound'WeaponSounds.foot_kickwall'
	SignHitBody=Sound'WeaponSounds.foot_kickbody'
	MomentumHitMag=120000
	TransientSoundRadius=80
}
