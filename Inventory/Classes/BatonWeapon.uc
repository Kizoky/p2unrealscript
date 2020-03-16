///////////////////////////////////////////////////////////////////////////////
// BatonWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Police baton weapon (first and third person).
//
// Low damage bludgeoning attacks.
//
// Enhanced mode: explodes heads with one hit.
//
///////////////////////////////////////////////////////////////////////////////

class BatonWeapon extends ShovelWeapon;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bNoHudReticle=true
	bUsesAltFire=true
	ItemName="Baton"
	AmmoName=class'BatonAmmoInv'
	PickupClass=class'BatonPickup'
	AttachmentClass=class'BatonAttachment'

//	Mesh=Mesh'FP_Weapons.FP_Dude_Baton'
	Mesh=Mesh'MP_Weapons.MP_LS_Baton'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'

	FirstPersonMeshSuffix="Baton"

    //PlayerViewOffset=(X=1.0000,Y=0.000000,Z=-2.0000)
	PlayerViewOffset=(X=1.0000,Y=0.000000,Z=-18.0000)

	bMeleeWeapon=true
	ShotMarkerMade=None
	BulletHitMarkerMade=None
    bDrawMuzzleFlash=false

	holdstyle=WEAPONHOLDSTYLE_Melee
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Melee

	//shakemag=350.000000
	//shaketime=0.200000
	//shakevert=(X=0.0,Y=0.0,Z=4.00000)
	FireOffset=(X=2.000000,Y=0.00000,Z=-1.00000)
	ShakeOffsetMag=(X=0,Y=6,Z=0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=3.0
	ShakeRotMag=(X=30.0,Y=250.0,Z=30.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=3.0

	//FireSound=Sound'WeaponSounds.baton_fire1'
	//AltFireSound=Sound'WeaponSounds.baton_fire2'
	CombatRating=1.0
	AIRating=0.1
	AutoSwitchPriority=1
	InventoryGroup=1
	GroupOffset=3
	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.1
	ViolenceRank=1
	bBumpStartsFight=false
	AI_BurstCountExtra=2
	AI_BurstCountMin=1
	AI_BurstTime=1.0

	WeaponSpeedIdle	   = 0.3
	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.25
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 0.9
	WeaponSpeedShoot1Rand=0.2
	WeaponSpeedShoot2  = 0.9
	AimError=200

	HudHint1="Press %KEY_Fire% to swing."
	HudHint2="Press %KEY_AltFire% to bash."
	bCanThrowMP=false

	PlayerMeleeDist=100
	NPCMeleeDist=90.0
	MaxRange=90
	RecognitionDist=600
	BloodTextures[0]=Texture'WeaponSkins_Bloody.baton_timb_blood01'
	BloodTextures[1]=Texture'WeaponSkins_Bloody.baton_timb_blood02'
	}
