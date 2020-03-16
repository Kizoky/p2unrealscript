//=============================================================================
// PistolWeapon
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Pistol weapon (first and third person).
//
// For AI characters, this weapon scales the number of times it's shot continuously
// with the difficulty level. Higher difficulty--more they shoot in one burst.
//
//	History:
//		07/22/03 NPF	Fires faster per click only in single player. In MP, it
//						fires faster just by holding down the fire button.
//
//		01/11/03 NPF	Allowed pistol to fire faster than firing animation
//						normally permits, if player clicks Fire again.
//
//		01/29/02 MJR	Started history, probably won't be updated again until
//							the pace of change slows down.
//
//
//=============================================================================

class PistolWeapon extends P2DualWieldWeapon;


var bool bCanFireAgain;		// If you're the player and this is set to true, then you
							// shoot again if even you're still in NormalFire

var float WeaponSpeedShoot1MP;	// Allow faster shooting in multiplayer.
var float SPAccuracy;				// How accurate we are in single player games.

const FIRING_WAIT_TIME = 0.4;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	local float diffoffset;

	Super.PostBeginPlay();

	// If it's a single player game, make our accuracy much worse
	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		TraceAccuracy = SPAccuracy;

		// Based on the difficulty, bump up the number of times AI will continuously
		// shoot this weapon
		diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();
		if(diffoffset > 0)
		{
			AI_BurstCountExtra+=(diffoffset/2);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Fire the weapon
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
	{
	// Basics
	IncrementFlashCount();
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		// Play your sound in MP in your attachment to save bandwidth
		PlayAnim('Shoot1', WeaponSpeedShoot1MP + (WeaponSpeedShoot1Rand*FRand()), 0.05);
	}
	else
	{
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
		PlayAnim('Shoot1', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
	}

	// Adv.
	SetupMuzzleFlash();
	// Once the player started his fire, don't let it fire again
	// until the sleep in the NormalFire state let's him
	if(PlayerController(Instigator.Controller) != None)
		bCanFireAgain=false;
	}

///////////////////////////////////////////////////////////////////////////////
// This will randomly change the color and the size of the dynamic
// light associate with the flash. Change in each weapon's file,
// but call each time you start up the flash again.
// This function is also used by the third-person muzzle flash, so the
// colors will look the same
///////////////////////////////////////////////////////////////////////////////
simulated function PickLightValues()
{
	LightBrightness=150;
	LightSaturation=150;
	LightHue=12+FRand()*15;
	LightRadius=12+FRand()*6;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the muzzle flash renders, and move it around some
///////////////////////////////////////////////////////////////////////////////
simulated function SetupMuzzleFlash()
{
	bMuzzleFlash = true;
	bSetFlashTime = false;
	// Gets turned off in weapon, in RenderOverlays
	// Slightly change colors each time
	if(IsFirstPersonView()
		&& bDrawMuzzleFlash)
	{
		PickLightValues();
		bDynamicLight=bAllowDynamicLights;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// NormalFire
// If we're in here, and it's the player and he presses fire before the fire
// anim is done and *after* the FIRING_WAIT_TIME sleep is over, then we
// let him fire again.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	///////////////////////////////////////////////////////////////////////////////
	// Same as standard ServerFire
	///////////////////////////////////////////////////////////////////////////////
	function ServerFire()
	{
		if(FPSPawn(Instigator).bPlayer
			&& bCanFireAgain)
		{
			if ( AmmoType == None )
			{
				// ammocheck
				log("WARNING "$self$" HAS NO AMMO!!!");
				GiveAmmo(Pawn(Owner));
			}
			if ( AmmoType.HasAmmo() )
			{
				GotoState('NormalFire');
				if ( AmmoType.bInstantHit )
					TraceFire(TraceAccuracy,0,0);
				else
					ProjectileFire();
				LocalFire();
			}
		}
		else
			Super.ServerFire();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Same as standard Fire
	///////////////////////////////////////////////////////////////////////////////
	simulated function Fire( float Value )
	{
		if (FPSPawn(Instigator).bPlayer && bCanFireAgain)
		{
			if ( AmmoType == None
				|| !AmmoType.HasAmmo() )
			{
			ClientForceFinish();
			ServerForceFinish();
				return;
			}

			if ( !RepeatFire() )
				ServerFire();
			else if ( StopFiringTime < Level.TimeSeconds + 0.3 )
			{
				StopFiringTime = Level.TimeSeconds + 0.6;
				ServerRapidFire();
			}
			if ( Role < ROLE_Authority )
			{
				bCanFireAgain=false;
				LocalFire();
				GotoState('ClientFiring');
			}
		}
		else
			Super.Fire(Value);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		bCanFireAgain=true;
		Super.EndState();
	}
Begin:
	Sleep(FIRING_WAIT_TIME);
	bCanFireAgain=true;
}
state ClientFiring
{
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ItemName="Pistol"
	AmmoName=class'PistolBulletAmmoInv'
	PickupClass=class'PistolPickup'
	AttachmentClass=class'PistolAttachment'

	Mesh=Mesh'MP_Weapons.MP_LS_Pistol'
//	Mesh=Mesh'FP_Weapons.FP_Dude_Pistol'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	FirstPersonMeshSuffix="Pistol"

	AmbientGlow = 64
    //PlayerViewOffset=(X=0.0000,Y=0.000000,Z=-1.0000)
	PlayerViewOffset=(X=0.0000,Y=0.000000,Z=-7.0000)

    bDrawMuzzleFlash=False
	MuzzleScale=1.0
	FlashOffsetY=0.15
	FlashOffsetX=0.215
	FlashLength=0.01
	MuzzleFlashSize=128
    MFTexture=Texture'Timb.muzzleflash.pistol_corona'

    //MuzzleFlashStyle=STY_Translucent
	MuzzleFlashStyle=STY_Normal
    //MuzzleFlashMesh=Mesh'Weapons.Pistol3'
    MuzzleFlashScale=2.40000
    //MuzzleFlashTexture=Texture'MuzzyPulse'

	holdstyle=WEAPONHOLDSTYLE_Single
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Single

	//ShakeMag=3.000000
	//ShakeRollRate=20000
	//ShakeOffsetTime=2.0
	//ShakeTime=2.000000
	//ShakeSpeed=(Z=100.0)
	//ShakeVert=(Z=5.0)
	ShakeOffsetMag=(X=10.0,Y=2.0,Z=2.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2.2
	ShakeRotMag=(X=220.0,Y=30.0,Z=30.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2.2

	FireSound=Sound'WeaponSounds.pistol_fire'
	SoundRadius=255
	CombatRating=3.0
	AIRating=0.2
	AutoSwitchPriority=2
	InventoryGroup=2
	GroupOffset=1
	BobDamping=0.975000
	ReloadCount=0
	SPAccuracy=0.15
	TraceAccuracy=0.02
	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	AI_BurstCountExtra=3
	AI_BurstTime=0.8
	ViolenceRank=3

	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.5
	WeaponSpeedReload  = 1.5
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.04
	WeaponSpeedShoot1MP= 1.7
	WeaponSpeedShoot2  = 1.0
	AimError=400
	RecognitionDist=900

	MaxRange=1024
	MinRange=250
	bCanFireAgain=true
	}
