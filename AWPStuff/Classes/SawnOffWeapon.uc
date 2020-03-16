class SawnOffWeapon extends P2Weapon;

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

simulated function PlayFiring()
{
	//bForceReload=true;
	SetupMuzzleFlash();
	Super.PlayFiring();
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
// See what we hit
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local int i;
	local PersonController perc;
	local vector dir;

	// Reduce the ammo only by 1 here, for the shotgun, but shoot
	// ShotCountMaxForNotify number of pellets each time.
	P2AmmoInv(AmmoType).UseAmmoForShot();

	perc = PersonController(Instigator.Controller);

	if(perc != None
		&& perc.Target != None)
	{
		if(perc.MyPawn.bAdvancedFiring)
			bAltFiring=true;
	}

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
    local bool bEnhancedMode;

    bEnhancedMode = P2GameInfoSingle(Level.Game).VerifySeqTime();

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

		if (!bEnhancedMode)
		{
		    ReloadCount--;
			UpdateHudHints();
		}

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

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	// Only primary fire for now
	bUsesAltFire=False
	//bUsesAltFire=False
	ViolenceRank=4
	RecognitionDist=1100.000000
	ShotCountMaxForNotify=16
	//AltShotCountMaxForNotify=8
	AI_BurstCountMin=16
	holdstyle=WEAPONHOLDSTYLE_Double
	switchstyle=WEAPONHOLDSTYLE_Double
	firingstyle=WEAPONHOLDSTYLE_Double
	MinRange=200.000000
	ShakeOffsetTime=2.500000
	CombatRating=4.000000
	WeaponSpeedLoad=1.500000
	WeaponSpeedHolster=1.500000
	WeaponSpeedShoot1Rand=0.300000
	WeaponSpeedShoot2=0.250000
	WeaponSpeedShoot2Rand=0.300000
	WeaponSpeedIdle=0.800000
	AmmoName=Class'ShotgunBulletAmmoInv'
	AutoSwitchPriority=3
	ShakeRotMag=(X=400.000000)
	ShakeRotTime=2.500000
	ShakeOffsetMag=(X=20.000000,Y=4.000000,Z=4.000000)
	TraceAccuracy=2.000000
	aimerror=400.000000
	AIRating=0.300000
	MaxRange=512.000000
	FireSound=Sound'AW7Sounds.MiscWeapons.SawnOff_Fire'
	//AltFireSound=Sound'WeaponSounds.shotgun_fire'
	FlashOffsetY=-0.050000
	FlashOffsetX=0.060000
	FlashLength=0.050000
	MuzzleFlashSize=128.000000
	MFTexture=Texture'Timb.muzzle_flash.shotgun_corona'
	bDrawMuzzleFlash=False
	MuzzleFlashScale=2.400000
	MuzzleFlashStyle=STY_Normal
	InventoryGroup=3
	GroupOffset=11
	PickupClass=Class'SawnOffPickup'
	BobDamping=0.975000
	AttachmentClass=Class'SawnOffAttachment'
	ItemName="Sawed-Off Shotgun"
	Mesh=SkeletalMesh'AW7_EDWeapons.ED_SawnOff_NEW'
	Skins(0)=Texture'AW7EDTex.Weapons.SawnOff'
	Skins(1)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	SoundRadius=255.000000
	WeaponsPackageStr="AW7_EDWeapons."
	//ReloadSound=Sound'WeaponSounds.Sniper_EjectShell'
	//BettyIncSound=Sound'WeaponSounds.Explosion_Small'
	ThirdPersonRelativeRotation=(Pitch=-1600)
	ReloadCount = 2
    OverrideHUDIcon=Texture'AW7EDTex.Icons.hud_SawnOff'

	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	PawnHitMarkerMade=class'PawnShotMarker'

	HudHint1="Press %KEY_AltFire% to reload manually."
	bAllowHints=true
	bShowHints=true
	bUsesAltFire=true	
}
