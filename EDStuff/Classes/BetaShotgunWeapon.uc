///////////////////////////////////////////////////////////////////////////////
// Beta Shotgun.
// Edited by Man Chrzan.
//
// Added alt-fire, cat-silencer, removed unnecessary spaghetti code.
///////////////////////////////////////////////////////////////////////////////

class BetaShotgunWeapon extends CatableWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var int AltShotCountMaxForNotify;
var int AltShotAmmoUse;
var texture BetaGimpHands;
var texture BetaCopHands;

// Network replication
replication
{
	reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
		Notify_AltFire;
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
		// Based on the difficulty, bump up the number of times AI will continuously
		// shoot this weapon
		diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();
		if(diffoffset > 0)
		{
			AI_BurstCountExtra+=(diffoffset/2);
		}
	}
	
	// If it's enhanced game we don't do reloads.
	if(P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer )
	{
	    default.ReloadCount=0;
		ReloadCount=0;
	}
	else if(default.ReloadCount == 0)
	{
		default.ReloadCount=6;
	}
	
	// Give new HudHint2 in place of HudHint1
	// Do this this way to prevent problems with outdated .int localizations etc.
	HudHint1=HudHint2;	
	HudHint2="";
}

///////////////////////////////////////////////////////////////////////////////
// Called after a saved game has been loaded
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Super.PostLoadGame();
	
	// If it's enhanced game we don't do reloads.
	if(P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer )
	{
	    default.ReloadCount=0;
		ReloadCount=0;
	}
	else if(default.ReloadCount == 0)
	{
		default.ReloadCount=6;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Reloading
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	// First-Person Reload
	PlayAnim('Reload', WeaponSpeedReload, 0.05);
	
	// Third-Person Reload
	P2MocapPawn(Instigator).PlayWeaponReload(self);
}

simulated function ServerForceReload()
{
	bForceReload = true;

	PlayReloading();
	
	if (ReloadCount != default.ReloadCount && HasAmmo())
	{
        GotoState('Reloading');
    }
}

///////////////////////////////////////////////////////////////////////////////
// Alternative Fire
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
{
	PlayAnim('Shoot2', WeaponSpeedShoot2, 0.05);
}

function bool CanAltFire()
{
	if(P2GameInfoSingle(Level.Game).VerifySeqTime() && Pawn(Owner).Controller.bIsPlayer)
		return (AmmoType.AmmoAmount >= AltShotAmmoUse);
	else
		return (ReloadCount >= AltShotAmmoUse);
}

simulated function AltFire( float Value )
{
	// Needs 2 shells to alt fire
	if (!CanAltFire()) 
		return;

	if ( !RepeatFire() )
		ServerAltFire();

	if ( Role < ROLE_Authority
		&& bUsesAltFire)
	{
		LocalAltFire();
		GotoState('ClientFiring');
	}
}

function ServerAltFire()
{
	TurnOffHint();
		
	if ( AmmoType == None )
	{
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}
	if ( HasAmmo()
		&& bUsesAltFire)
	{
		bAltFiring=true;
		
		GotoState('NormalFire');
		LocalAltFire();	
	}
}

simulated function LocalAltFire()
{
	bPointing = true;
	PlayAltFiring();
}

///////////////////////////////////////////////////////////////////////////////
// See what we hit 
///////////////////////////////////////////////////////////////////////////////
simulated function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local int i;
	
	// Reduce the cat ammo if we're using one
	if(CatOnGun == 1)
		CatAmmoLeft--;
	
	// Reduce ammo if we are not reloadable (enhanced game)
	if(default.ReloadCount == 0)
		P2AmmoInv(AmmoType).UseAmmoForShot(); 
	
	for(i=0; i<ShotCountMaxForNotify; i++)
	{
	    Super.TraceFire(TraceAccuracy,0,0);
    }
}

///////////////////////////////////////////////////////////////////////////////
// See what we hit - alt-fire
///////////////////////////////////////////////////////////////////////////////
simulated function TraceAltFire( float Accuracy, float YOffset, float ZOffset )
{
	local int i;
	
	for(i=0; i<AltShotCountMaxForNotify; i++)
	{
	    Super.TraceFire(TraceAccuracy,0,0);
    }
}

function Notify_AltFire()
{
	local bool bEnhancedMode;
	local PlayerController P;
	local float UsePitch;
	
	bEnhancedMode = P2GameInfoSingle(Level.Game).VerifySeqTime();
	
	// Reduce the cat ammo if we're using one
	if(CatOnGun == 1)
	{
		if (CatAmmoLeft >= AltShotAmmoUse)
			CatAmmoLeft-=AltShotAmmoUse;
		else
			CatAmmoLeft--;
	}
	
	// If the cat is on the gun and we want it to fly off, then set it up to fly off,
	// by switching the animation
	if(CatOnGun==1)
		{
		// Switch to special sound
		AltFireSound=CatFireSound;
		// Pitch higher with each consecutive shot
		UsePitch = WeaponFirePitchStart + (CAT_PITCH_INCREASE*(StartShotsWithCat - CatAmmoLeft));

		if (CatAmmoLeft==0
			|| !AmmoType.HasAmmo())
			{
			// Remove our cat and shoot him off, unless we have a cheat set to
			// keep shooting them off
			if(RepeatCatGun == 0)
				{
				SwapCatOff();
				ShootOffCat();
				CatOnGun=0;
				}
			else // Cheat
				{
				CatAmmoLeft=1;
				ShootOffCat();
				}
			}
		}
	else
		{
		// Use normal firing sound
		AltFireSound=Default.AltFireSound;
		UsePitch = WeaponFirePitchStart + (FRand()*WeaponFirePitchRand);
		}
	
	
    // Notified in Amnimation? FIRE!
	if ( AmmoType.bInstantHit )
			TraceAltFire(TraceAccuracy,0,0);
		else
			ProjectileAltFire();
	
	// MuzzleFlash
	bAltFiring=True;
	SetupMuzzleFlashEmitter();
	
	// 3rd Person MuzzleFlash
	IncrementFlashCount();

	// Use ammo (or ReloadCount)
	if(bEnhancedMode) 
		P2AmmoInv(AmmoType).UseAmmoForShot(AltShotAmmoUse); 
    else 
		ReloadCount -= AltShotAmmoUse;
	
	// camera shake effect
	if ( (Instigator != None) && Instigator.IsLocallyControlled() )
	{
		P = PlayerController(Instigator.Controller);
		if (P!=None)
		{
			if ( InstFlash != 0.0 )
				P.ClientInstantFlash( InstFlash, InstFog);

			P.ShakeView(ShakeRotMag * AltShotAmmoUse, ShakeRotRate, ShakeRotTime,
						ShakeOffsetMag * AltShotAmmoUse, ShakeOffsetRate, ShakeOffsetTime);
		}
	}
	
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(AltFireSound,SLOT_Interact,1.5,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(AltFireSound, SLOT_None, 1.5, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
}

///////////////////////////////////////////////////////////////////////////////
// Set first person hands texture
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeHandTexture(Texture NewHandsTexture, Texture DefHandsTexture, Texture NewFootTexture)
{
	local Texture GimpHands;
	local Texture CopHands;
	
	GimpHands = Class'GimpClothesInv'.default.HandsTexture;
	CopHands = Class'CopClothesInv'.default.HandsTexture;
	
	if(NewHandsTexture == GimpHands)
		Skins[0] = BetaGimpHands;
	else if(NewHandsTexture == CopHands)
		Skins[0] = BetaCopHands;	
	else
		Skins[0] = Default.Skins[0];
}

///////////////////////////////////////////////////////////////////////////////
// Decides which effects to spawn
///////////////////////////////////////////////////////////////////////////////
simulated function SetupMuzzleFlashEmitter() 
{
	if (IsFirstPersonView() && bSpawnMuzzleFlash)
	{
		// Spawn Effect
		if(bAltFiring && MFClass[1] != none && MFType == 0)
			PlayFireEffects(MFClass[1], 1);
		else 
		{
			if (MFType == 1 && MFClass[2] != None)
				PlayFireEffects(MFClass[2], 2); 
			else
				PlayFireEffects(MFClass[0], 0);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bReloadableWeapon=True
    bAllowReloadHints=True
	bNoHudReticleReload=True
	AltShotAmmoUse = 2
	
	ItemName="Beta Shotgun"
	AmmoName=class'ShotGunBulletAmmoInv'
	PickupClass=class'BetaShotgunPickup'
	AttachmentClass=class'BetaShotgunAttachment'

	Mesh=Mesh'ED_Weapons.Hidden_Shotgun'

//	Skins[0]=Texture'ED_WeaponSkins.John_Arms'
	Skins[0]=Texture'xPatchTex.Weapons.BetaShotgun_dudeArms'
	Skins[1]=Texture'ED_WeaponSkins.shotgun'
	FirstPersonMeshSuffix="Hidden_Shotgun"
	
	// Beta Hands skins
	BetaGimpHands=Texture'xPatchTex.Weapons.BetaShotgun_gimpArms'
	BetaCopHands=Texture'xPatchTex.Weapons.BetaShotgun_copArms'

	holdstyle=WEAPONHOLDSTYLE_Double
	switchstyle=WEAPONHOLDSTYLE_Double
	firingstyle=WEAPONHOLDSTYLE_Double

	ShakeOffsetMag=(X=20.0,Y=4.0,Z=4.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2.5
	ShakeRotMag=(X=400.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2.5

	FireSound=Sound'WeaponSoundsToo.BetaShotgun' //'WeaponSounds.shotgun_fire'
	AltFireSound=Sound'WeaponSoundsToo.BetaShotgunAlt'
	SoundRadius=255
	CombatRating=4.0
	AIRating=0.3
	AutoSwitchPriority=3
	InventoryGroup=3
	GroupOffset=4
//	BobDamping=0.975000	
	BobDamping=1.150000
	ReloadCount=6
	TraceAccuracy=1.4
	ShotCountMaxForNotify=6
	AltShotCountMaxForNotify=12
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
	
	HudHint2="Press %KEY_AltFire% to fire two shells."
	HudHint1="Press %KEY_AltFire% to reload manually."	// Old hint, should be not used anymore.
	bAllowHints=true
	bShowHints=true
	bUsesAltFire=true	
	PlayerViewOffset=(X=-2.5,Z=-7.5,Y=-0.75)
	
	AmbientGlow=128
  
	// Muzzle Flash
	bSpawnMuzzleFlash=True
	MFBoneName="MESH_Trigger"
	MFRelativeLocation=(X=-73,Y=-3.5,Z=0)
	MFClass[0]=class'xMuzzleFlashEmitter'
	MFTex[0]=Texture'nathans.muzzleflashes.mf_shotgun_new'
	MFScale[0]=(Min=1.3,Max=1.3) 
	MFSizeRange[0]=(Min=25,Max=30) 
	MFLifetime[0]=(Min=0.05,Max=0.05)
	MFClass[1]=class'xMuzzleFlashEmitter'
	MFTex[1]=Texture'nathans.muzzleflashes.mf_shotgun_new'
	MFScale[1]=(Min=2.2,Max=2.2) 
	MFSizeRange[1]=(Min=50,Max=60) 
	MFLifetime[1]=(Min=0.05,Max=0.05)
	
	MFClass[2]=class'FX2.MuzzleFlash02'
	
	// Meow! 
	bAttachCat=True
	CatFireSound=Sound'WeaponSounds.shotgun_catfire'
	CatBoneName="MESH_Trigger"
	CatRelativeLocation=(X=-70,Y=-8,Z=0)
	CatRelativeRotation=(Pitch=32768,Roll=-16384)
	StartShotsWithCat=9
	}