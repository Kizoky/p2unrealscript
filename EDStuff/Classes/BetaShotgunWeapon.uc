// Beta Shotgun.
// Can't extend from normal shotgun, because we don't put cats on this one.
class BetaShotgunWeapon extends P2Weapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////

var float SPAccuracy;				// How accurate we are in single player games.

//const BASE_FLASH_OFFSET_X = 0.06;
//const BASE_FLASH_OFFSET_Y = 0.015;
const BASE_FLASH_OFFSET_X = 0.055;
const BASE_FLASH_OFFSET_Y = 0.01;
const RAND_OFFSET = 0.01;

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bShowHints
		&& bAllowHints
		&& ReloadCount < Default.ReloadCount)
	{
		str1=HudHint1;
		return true;
	}
	return false;
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
			AI_BurstCountExtra+=(diffoffset/2);
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
	LightSaturation=150;
	LightHue=22+FRand()*10;
	LightRadius=24+FRand()*6;
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

	for(i=0; i<ShotCountMaxForNotify; i++)
	{
		Super.TraceFire(Accuracy, YOffset, ZOffset);
	}
}
state ClientFiring
{
}
state NormalFire
{
}

///////////////////////////////////////////////////////////////////////////////
// Same as original
// DO reloadcounts for these.
///////////////////////////////////////////////////////////////////////////////
function ServerFire()
{
	DQShovel();

	if ( AmmoType == None )
	{
		// ammocheck
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}

	//log(self$" serverfire, ammo "$AmmoType.AmmoAmount$" get state "$GetStateName());

	if ( AmmoType.HasAmmo() )
	{
		GotoState('NormalFire');

		// Don't do reloadcount because we usually force reloads (grenades) or don't
		// do them at all (machinegun)
		ReloadCount--;
		UpdateHudHints();
		if ( AmmoType.bInstantHit )
			TraceFire(TraceAccuracy,0,0);
		else
			ProjectileFire();
		LocalFire();
	}
}
///////////////////////////////////////////////////////////////////////////////
// Same as original
// DO reloadcounts for these.
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	//log(self$" Fire, ammo "$AmmoType.AmmoAmount);
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
		ReloadCount--;
		UpdateHudHints();
		LocalFire();
		//log(self$" going to client firing");
		GotoState('ClientFiring');
	}
}

///////////////////////////////////////////////////////////////////////////////
// play reloading sounds
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	// temp speed up because with no animation, you can't tell you're
	// why you can't shoot (becuase it's playing a reload anim)
	PlayAnim('Reload', WeaponSpeedReload, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
{
	// Forces a reload on alt-fire.
	if (ReloadCount < Default.ReloadCount)
	{
		GotoState('Reloading');
		TurnOffHint();
	}
}

// Change by NickP: MP fix
simulated function PlayAltFiring()
{
	PlayReloading();
}
// End

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ItemName="Beta Shotgun"
	AmmoName=class'ShotGunBulletAmmoInv'
	PickupClass=class'BetaShotgunPickup'
	AttachmentClass=class'BetaShotgunAttachment'

//	Mesh=Mesh'FP_Weapons.FP_Dude_Shotgun'
	Mesh=Mesh'ED_Weapons.Hidden_Shotgun'

	Skins[0]=Texture'ED_WeaponSkins.John_Arms'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[1]=Texture'ED_WeaponSkins.shotgun'
	FirstPersonMeshSuffix="Hidden_Shotgun"

    bDrawMuzzleFlash=False
	MuzzleScale=1.0
	FlashOffsetY=-0.05
	FlashOffsetX=0.06
	FlashLength=0.05
	MuzzleFlashSize=128
    MFTexture=Texture'Timb.muzzleflash.shotgun_corona'
	//MFBloodTexture=Texture'nathans.muzzleflashes.bloodmuzzleflash'

    //MuzzleFlashStyle=STY_Translucent
	MuzzleFlashStyle=STY_Normal
    //MuzzleFlashMesh=Mesh'Weapons.Shotgun3'
    MuzzleFlashScale=2.40000
    //MuzzleFlashTexture=Texture'MuzzyPulse'

	holdstyle=WEAPONHOLDSTYLE_Double
	switchstyle=WEAPONHOLDSTYLE_Double
	firingstyle=WEAPONHOLDSTYLE_Double

	//ShakeMag=1000.000000
	//ShakeRollRate=20000
	//ShakeOffsetTime=2.0
	//ShakeTime=0.500000
	//ShakeVert=(Z=10.0)
	ShakeOffsetMag=(X=20.0,Y=4.0,Z=4.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2.5
	ShakeRotMag=(X=400.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2.5

	FireSound=Sound'WeaponSounds.shotgun_fire'
	SoundRadius=255
	CombatRating=4.0
	AIRating=0.3
	AutoSwitchPriority=3
	InventoryGroup=3
	GroupOffset=99
	BobDamping=0.975000
	ReloadCount=6
	TraceAccuracy=0.7
	SPAccuracy=1.4
	ShotCountMaxForNotify=6
	AI_BurstCountExtra=0
	AI_BurstCountMin=3
	ViolenceRank=3

	WeaponSpeedIdle	   = 0.8
	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.5
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.3
	WeaponSpeedShoot2  = 1.0

	AimError=400
	RecognitionDist=1100

	MaxRange=512
	MinRange=200
	
	ThirdPersonRelativeLocation=(X=14,Z=1)
	ThirdPersonRelativeRotation=(Pitch=-512)
	OverrideHUDIcon=Texture'EDHud.hud_OriginalShotgun'
	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	PawnHitMarkerMade=class'PawnShotMarker'
	
	HudHint1="Press %KEY_AltFire% to reload manually."
	bAllowHints=true
	bShowHints=true
	bUsesAltFire=true	
	PlayerViewOffset=(X=-1,Z=-10)
	}

	