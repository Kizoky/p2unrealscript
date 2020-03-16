//=============================================================================
// NineAmmunition.
// Created on: 26.04.2006 13:49:00
// Written by Eduard Klemens
// Mail to: madjackal_x@hotmail.com.
// © 2006, MaD Inc. All Rights Reserved.
//=============================================================================
class GSelectAmmoInv extends P2AmmoInv;

var() class<DamageType> GlockDamage;			// Damage caused by glocks
var() class<DamageType> AkimboDamage;			// Damage caused by akimbo glocks
var() class<DamageType> MP5Damage;				// Damage caused by MP5
var() class<DamageType> IngramDamage;			// Not used in P2
var() class<DamageType> BerettaDamage;			// Not used in P2
var() class<DamageType> ZombieHeadDamage;		// Not used in P2

const FLESH_HIT_MAX	=	4;
var Sound FleshHit[FLESH_HIT_MAX];
var float FleshRad;
var array<Sound> BotHit, SkelHit;

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Rotator NewRot;
	local class<DamageType> ThisDamage;
	
	UseAmmoForShot();

	if (Other == None)
		return;

	// Have to use IsA thanks to crummy compile order concerns
	if (W.IsA('GSelectWeapon'))
		ThisDamage = GlockDamage;
	/*
	else if (W.IsA('GlockAkimboWeapon'))
		ThisDamage = AkimboDamage;
	else if (W.IsA('MP5Weapon'))
		ThisDamage = MP5Damage;
	else if (W.IsA('IngramWeapon'))
		ThisDamage = IngramDamage;
	else if (W.IsA('BerettaWeapon'))
		ThisDamage = BerettaDamage;
	*/
	else
		ThisDamage = DamageTypeInflicted;

	if (ZombieHead(Other) != None)
		ThisDamage = ZombieHeadDamage;

	if (Other.bStatic)//Other.bWorldGeometry )
	{
		//spawn(class'EDGenericHitPack',Owner, ,HitLocation, Rotator(HitNormal));
		//spawn(class'MaDBulletHitPack',Owner, ,HitLocation, Rotator(HitNormal));
		spawn(class'PistolBulletHitPack',Owner, ,HitLocation, Rotator(HitNormal));
	}
	else
	{
		Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, ThisDamage);

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
				//spawn(class'EDSplatterPack',Owner, ,HitLocation,Rotator(HitNormal));
				spawn(class'PistolBulletSplat',Owner, ,HitLocation,Rotator(HitNormal));
		}
		else // anything else--make a spark hit
		{
			//spawn(class'EDGenericHitPack',Owner, ,HitLocation, Rotator(HitNormal));
			//spawn(class'MaDBulletHitPack',Owner, ,HitLocation, Rotator(HitNormal));
		spawn(class'PistolBulletHitPack',Owner, ,HitLocation, Rotator(HitNormal));
		}
	}
}

function SpawnNineProjectile(vector Start, vector Dir)
{
}

defaultproperties
{
     //GlockDamage=Class'MaD_EDDamage.GlockDamage'
	 GlockDamage=class'BulletDamage'
     //AkimboDamage=Class'MaD_EDDamage.AkimboDamage'
     //MP5Damage=Class'MaD_EDDamage.MP5Damage'
     //IngramDamage=Class'MaD_EDDamage.IngramDamage'
     //BerettaDamage=Class'MaD_EDDamage.BerettaDamage'
     ZombieHeadDamage=Class'AWEffects.SledgeDamage'
     FleshHit(0)=Sound'EDWeaponSounds.Misc.hit1'
     FleshHit(1)=Sound'EDWeaponSounds.Misc.hit2'
     FleshHit(2)=Sound'EDWeaponSounds.Misc.hit3'
     FleshHit(3)=Sound'EDWeaponSounds.Misc.hit4'
	BotHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	BotHit[1]=Sound'WeaponSounds.bullet_ricochet2'
	SkelHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	SkelHit[1]=Sound'WeaponSounds.bullet_ricochet2'
     FleshRad=200.000000
     DamageAmount=15.000000
     MomentumHitMag=10000.000000
     //AltDamageTypeInflicted=Class'MaD_EDDamage.NineDamage'
	 AltDamageTypeInflicted=class'BulletDamage'
     MaxAmmoMP=500
     MaxAmmo=1000
     bLeadTarget=True
     bInstantHit=True
     //ProjectileClass=Class'MaD_ED.NineProjectile'
     WarnTargetPct=0.200000
     RefireRate=0.990000
     //PickupClass=Class'MaD_ED.NineAmmoPickup'
	 PickupClass=Class'GSelectAmmoPickup'
	 Texture=Texture'EDHud.hud_Glock'
}
