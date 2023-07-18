//=============================================================================
// MachineGunWeapon
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Machine gun weapon (first and third person).
//
// For AI characters, this weapon scales the number of times it's shot continuously
// with the difficulty level. Higher difficulty--more they shoot in one burst.
//
//	History:
//		01/29/02 MJR	Started history, probably won't be updated again until
//							the pace of change slows down.
//
//=============================================================================

class MachineGunWeapon extends DualCatableWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var travel byte ShootScissors;		// Cheat that makes you shoot bouncing scissors instead
var float SPAccuracy;				// How accurate we are in single player games.
var float ActualFireRate;			// HACK to adjust actual fire rate.

///////////////////////////////////////////////////////////////////////////////
// Fire the weapon
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
{
	local float UsePitch;
	local vector StartTrace, X,Y,Z;

	// If the cat is on the gun and we want it to fly off, then set it up to fly off,
	// by switching the animation
	if(CatOnGun==1)
		{
		// Switch to special sound
		FireSound=CatFireSound;
		// Pitch higher with each consecutive shot
		UsePitch = WeaponFirePitchStart + (CAT_PITCH_INCREASE*(StartShotsWithCat - CatAmmoLeft));

		if (CatAmmoLeft==0
			|| !AmmoType.HasAmmo())
			{
			// Remove our cat and shoot him off, unless we have a cheat set to
			// keep shooting them off
			CatAmmoLeft=1;
			ShootOffCat();
			}
		}
	else
		{
		// Use normal firing sound
		FireSound=Default.FireSound;
		UsePitch = WeaponFirePitchStart + (FRand()*WeaponFirePitchRand);
		}

	// Normal playfiring for P2Weapon, but we pitch the fire sound for a cat, higher and
	// higher with each shot, if we're shooting with a cat.
	IncrementFlashCount();

	// Play it here (instead of in the attachment) in SP games
	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , UsePitch);

	PlayAnim('Shoot1', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);

	SetupMuzzleFlash();
	SetupMuzzleFlashEmitter();
}

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bShowHints
		&& bAllowHints
		&& P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
	{
		str1=HudHint1;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
{
	TurnOffHint();
	Super.ServerAltFire();
}

///////////////////////////////////////////////////////////////////////////////
// AltFire - shoots scissors
// Enhanced only.
///////////////////////////////////////////////////////////////////////////////
simulated function AltFire( float Value )
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer
		|| ShootScissors==1)
	{
		Super.AltFire(Value);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
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
			AI_BurstCountExtra+=diffoffset;
		}
	}


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
	LightSaturation=180;
	LightHue=12+FRand()*15;
	LightRadius=16+FRand()*16;
}

///////////////////////////////////////////////////////////////////////////////
// Tell ammo to make this scissors type
///////////////////////////////////////////////////////////////////////////////
function SpawnScissors(bool bMakeSpinner)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local ScissorsProjectile sic;
	local P2Player p2p;

	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
	HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
	//log("traced from"@StartTrace@"to"@Instigator.Location@"hit"@HitActor);
	if(HitActor == None
		|| (!HitActor.bStatic
			&& !HitActor.bWorldGeometry
			&& ScissorsProjectile(HitActor) == None))
		sic = spawn(class'ScissorsAltProjectile',Instigator,,StartTrace, AdjustedAim);

	// If we didn't make it, give the ammo back
	if (sic == None)
		AmmoType.AddAmmo(1);
}

///////////////////////////////////////////////////////////////////////////////
// See what we hit
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local int i;

	// Reduce the ammo only by 1 here, for the shotgun, but shoot
	// ShotCountMaxForNotify number of pellets each time.
	P2AmmoInv(AmmoType).UseAmmoForShot();

	// Reduce the cat ammo if we're using one
	if(CatOnGun == 1)
		CatAmmoLeft--;
/*
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
		ShootScissors = 1;

	if(ShootScissors==1)
		SpawnScissors(true);
	else
*/
		Super.TraceFire(Accuracy, YOffset, ZOffset);
}

simulated event RenderOverlays(Canvas canvas)
{
    super.RenderOverlays(canvas);
 	// Checks for Ultra WS and corrections draw scale, fov, and position.
    // Sorry for the hacky method, but cannot seem to fix the view model clipping.
	// ApplyPositionHack(0.25,133,vect(2.0000,0.000000,-4.3000),,0.2,vect(1.0000,0.300000,-1.3000));

}

///////////////////////////////////////////////////////////////////////////////
// DrawMuzzleFlash()
//Default implementation assumes that flash texture can be drawn inverted in X and/or Y direction to increase apparent
//number of flash variations
// We might need to draw a dark blood splat
///////////////////////////////////////////////////////////////////////////////
simulated function DrawMuzzleFlash(Canvas Canvas)
{
	local float Scale, ULength, VLength, UStart, VStart;

	// Form dynamic muzzle flash size
	MuzzleScale = FRand()*(default.MuzzleScale);
	// Form offset based on that
//	FlashOffsetX = -(MuzzleScale/500) + default.FlashOffsetX;
//	FlashOffsetY = -(MuzzleScale/500) + default.FlashOffsetY;

	MuzzleScale += 1.0;

	if(CatOnGun == 0
		|| !class'P2Player'.static.BloodMode())
		Super.DrawMuzzleFlash(Canvas);
	else	// if a cat, then draw it alpha blended with a gross blood splat
	{
		Scale = MuzzleScale * Canvas.ClipX/640.0;
		Canvas.Style = ERenderStyle.STY_Alpha;
		ULength = MFTexture.USize;
		if ( FRand() <= 0.5 )
		{
			UStart = ULength;
			ULength = -1 * ULength;
		}
		VLength = MFTexture.VSize;
		if ( FRand() <= 0.5 )
		{
			VStart = VLength;
			VLength = -1 * VLength;
		}

		Canvas.DrawTile(MFTexture, Scale * MFTexture.USize, Scale * MFTexture.VSize,
					UStart, VStart, ULength, VLength);
		Canvas.Style = ERenderStyle.STY_Normal;
	}
}
///////////////////////////////////////////////////////////////////////////////
// See what we hit - alt-fire
///////////////////////////////////////////////////////////////////////////////
function TraceAltFire( float Accuracy, float YOffset, float ZOffset )
{
	local int i;
	local bool bProj;

	// Reduce the ammo only by 1 here, for the shotgun, but shoot
	// ShotCountMaxForNotify number of pellets each time.
	P2AmmoInv(AmmoType).UseAmmoForShot();

	// If we have a cat on our gun, alt-fire shoots it off every time and doesn't use "cat ammo"
	// (like the Rockin' Cats cheat)

	// Don't do this -- the scissors make the cat explode every time. Instead, make the alt-fire NOT decrease "cat ammo".
	/*
	if(CatOnGun == 1)
		ShootOffCat();
	*/

	SpawnScissors(true);
}
state ClientFiring
{
}
state NormalFire
{
// HACK to improve machinegun fire rate
Begin:
	if (Class == class'MachineGunWeapon')
		Goto('BeginHack');
	else
		Goto('');
BeginHack:
	Sleep(1/ActualFireRate);
	Finish();
	Goto('BeginHack');
}

///////////////////////////////////////////////////////////////////////////////
// Modify your speed based on your owners body speed
///////////////////////////////////////////////////////////////////////////////
function ChangeSpeed(float NewSpeed)
{
	Super.ChangeSpeed(NewSpeed);
	ActualFireRate = default.ActualFireRate*NewSpeed;
}

// xPatch: Make sure that this gun is not extension!
function bool CanSwapHands()
{
	return (Class == Class'MachineGunWeapon');
}

// xPatch: So apparently the old cat mesh has no Cylinder01 bone huh...
function SwapCatOn()
{
	Super.SwapCatOn();
	
	if(Mesh == OldCatMesh)
	{
		MFBoneName=CatBoneName;
		MFRelativeLocation.X=-40;
		MFRelativeLocation.Y=-12;
		MFRelativeLocation.Z=1;
	}
}
function SwapCatOff()
{
	Super.SwapCatOff();
	MFBoneName=default.MFBoneName;
	MFRelativeLocation=default.MFRelativeLocation;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ItemName="Machine Gun"
	AmmoName=class'MachineGunBulletAmmoInv'
	PickupClass=class'MachineGunPickup'
	AttachmentClass=class'MachinegunAttachment'

	OldMesh=Mesh'FP_Weapons.FP_Dude_Machinegun'
	Mesh=Mesh'MP_Weapons.MP_LS_Machinegun'

//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[1]=Texture'WeaponSkins.m-16_timb'
	Skins[2]=Texture'WeaponSkins.brass-01'
	Skins[3]=Texture'AnimalSkins.Cat_Orange'
	FirstPersonMeshSuffix="MachineGun"

	OldCatMesh=Mesh'FP_Weapons.FP_Dude_MachinegunCat'
	CatMesh=Mesh'MP_Weapons.MP_LS_MachinegunCat'
	CatFireSound=Sound'WeaponSounds.machinegun_catfire'

	//PlayerViewOffset=(X=1.0000,Y=0.300000,Z=-1.3000)
    PlayerViewOffset=(X=1.0000,Y=0.300000,Z=-10.3000)
    bDrawMuzzleFlash=False
	MuzzleScale=0.2
	FlashOffsetY=-0.03
	FlashOffsetX=0.03
	FlashLength=0.1
	MuzzleFlashSize=128
    MFTexture=Texture'Timb.muzzleflash.machine_gun_corona'
	MFBloodTexture=Texture'nathans.muzzleflashes.bloodmuzzleflash'

    //MuzzleFlashStyle=STY_Translucent
	MuzzleFlashStyle=STY_Normal
    //MuzzleFlashMesh=Mesh'Weapons.Shotgun3'
    MuzzleFlashScale=2.40000
    //MuzzleFlashTexture=Texture'MuzzyPulse'

	holdstyle=WEAPONHOLDSTYLE_Both
	switchstyle=WEAPONHOLDSTYLE_Both
	firingstyle=WEAPONHOLDSTYLE_Both

//	ShakeOffsetMag=(X=3.0,Y=2.5,Z=2.5)
//	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
//	ShakeOffsetTime=2.0
//	ShakeRotMag=(X=120.0,Y=30.0,Z=30.0)
//	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
//	ShakeRotTime=2.0

	FireSound=Sound'WeaponSounds.machinegun_fire'
	SoundRadius=255
	CombatRating=5.0
	AIRating=0.4
	AutoSwitchPriority=4
	InventoryGroup=4
	GroupOffset=1
	BobDamping=1.15 //0.975000
	ReloadCount=0
	SPAccuracy=0.7
	TraceAccuracy=0.11
	ShotCountMaxForNotify=20
	AI_BurstCountExtra=10
	AI_BurstCountMin=6
	AI_BurstTime=0.15
	ViolenceRank=5

	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.5
	WeaponSpeedReload  = 1.5
	WeaponSpeedShoot1  = 25.0
	WeaponSpeedShoot1Rand=0.0
	WeaponSpeedShoot2  = 1.0
	ActualFireRate		= 7.5

	StartShotsWithCat=9
	AimError=600
	RecognitionDist=1300

	MaxRange=1200
	MinRange=300

	HudHint1="Press %KEY_AltFire% to fire something a bit sharper than a bullet."
	bAllowHints=true
	bShowHints=true
	bUsesAltFire=true
	
	// Muzzle Flash
	bSpawnMuzzleFlash=true
	MFClass[0]=class'xMuzzleFlashEmitter'
	MFClass[2]=class'FX2.MuzzleFlash01'
	MFTex[0]=Texture'Timb.muzzleflash.machine_gun_corona'
	MFScale[0]=(Min=1.6,Max=1.6) 
	MFSizeRange[0]=(Min=20,Max=25) 
	MFLifetime[0]=(Min=0.05,Max=0.05)
	MFSpinRan[0]=(Min=-0.05,Max=0.05)
	MFSpinsPerSec[0]=(Max=1)
	MFBoneName="Cylinder01"
	CatBoneName="MESH_Clip"
	MFRelativeLocation=(X=0,Y=0,Z=98)
	
	// Shell
	ShellBoneName="MESH_Rnd01"
    ShellRelativeLocation=(Y=5.000000,Z=12.000000)
    ShellClass=Class'P2Shell_MachineGun'
    ShellSpeedY=650.000000
    ShellSpeedZ=450.000000
	ShellTex=Texture'WeaponSkins.brass-01'
	bCheckShell=True
	
	VeteranModeDropChance=0.45
	}

