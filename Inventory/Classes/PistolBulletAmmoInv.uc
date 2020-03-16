///////////////////////////////////////////////////////////////////////////////
// PistolBulletAmmoInv
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Pistol ammo inventory item (as opposed to pickup).
//
//	History:
//		01/29/02 MJR	Started history, probably won't be updated again until
//							the pace of change slows down.
//
///////////////////////////////////////////////////////////////////////////////

class PistolBulletAmmoInv extends P2AmmoInv;

const FLESH_HIT_MAX	=	4;
var Sound FleshHit[FLESH_HIT_MAX];

var array<Sound> BotHit, SkelHit;

var float FleshRad;

///////////////////////////////////////////////////////////////////////////////
// Process a trace hitting something
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Rotator NewRot;

	// reduce the ammo
	UseAmmoForShot();

	if ( Other == None )
		return;

	if ( Other.bStatic)//Other.bWorldGeometry ) 
		{	
		spawn(class'PistolBulletHitPack',W.Owner, ,HitLocation, Rotator(HitNormal));
		}
	else 
	{
		Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, DamageTypeInflicted);
		
		if (P2MocapPawn(Other) != None)
		{
			if (P2MocapPawn(Other).MyRace < RACE_Automaton)
				Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
			else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
				Other.PlaySound(BotHit[Rand(BotHit.Length)],SLOT_Pain,,,FleshRad,GetRandPitch());
			else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
				Other.PlaySound(SkelHit[Rand(SkelHit.Length)],SLOT_Pain,,,FleshRad,GetRandPitch());
		}
		else if((Pawn(Other) != None 
				&& Other != Owner)
			|| PeoplePart(Other) != None
			|| CowheadProjectile(Other) != None)
		{
			Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
		}
		else // anything else--make a spark hit
		{
			spawn(class'BulletSparkPack',W.Owner, ,HitLocation, Rotator(HitNormal));
		}
	}
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
//	ProjectileClass=Class'MachineGunBulletProj'
	PickupClass=class'PistolAmmoPickup'
	bInstantHit=true
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=500
	DamageAmount=18
	MomentumHitMag=30000
	DamageTypeInflicted=class'BulletDamage'
	Texture=Texture'HUDPack.Icon_Weapon_Pistol'

	FleshHit[0]=Sound'WeaponSounds.bullet_hitflesh1'
	FleshHit[1]=Sound'WeaponSounds.bullet_hitflesh2'
	FleshHit[2]=Sound'WeaponSounds.bullet_hitflesh3'
	FleshHit[3]=Sound'WeaponSounds.bullet_hitflesh4'
	BotHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	BotHit[1]=Sound'WeaponSounds.bullet_ricochet2'
	SkelHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	SkelHit[1]=Sound'WeaponSounds.bullet_ricochet2'
	FleshRad=200
	}
