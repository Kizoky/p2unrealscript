class GSelectWeapon extends EDWeapon;

var float FiringWaitTime;
var bool bCanFireAgain;		// If you're the player and this is set to true, then you
							// shoot again if even you're still in NormalFire
var sound SlideBackSound, SlideSnapSound;

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: Change for xPatch Options
///////////////////////////////////////////////////////////////////////////////
simulated function ToggleFireMode()
{
	local byte GlockMode;
	
	if(P2GameInfoSingle(Level.Game).xManager != None)
		GlockMode = P2GameInfoSingle(Level.Game).xManager.iGlockMode;
	else
		GlockMode = 2;
	
	TurnOffHint();
	
	// in multiplayer always use Semi and Auto (Burst doesn't work correctly)
	if (Level.Game == None || !FPSGameInfo(Level.Game).bIsSinglePlayer)
		Super.ToggleFireMode(); 		
	else
	{
		switch (FireMode)
		{
			case FM_Semi:   
				if(GlockMode == 1) // Semi and Auto
					FireMode = FM_Auto;
				else
					FireMode = FM_Burst;
				break;

			case FM_Burst:   
				if(GlockMode == 0)	// Semi and Burst
					FireMode = FM_Semi;  
				else
					FireMode = FM_Auto; 
				 break;

			case FM_Auto:    
				FireMode = FM_Semi;
				break;
		}					 
	}
}

///////////////////////////////////////////////////////////////////////////////
// Fire the weapon
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	local float UsePitch;
	
	if(PlayerController(Instigator.Controller) != None
		&& FireMode == FM_Semi )
		bCanFireAgain=false;
		
	// Reduce the cat ammo if we're using one
	if(CatOnGun == 1)
	{
		CatAmmoLeft--;
		
		// Switch to special sound
		FireSound=CatFireSound;
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
		FireSound=Default.FireSound;
		UsePitch = WeaponFirePitchStart + (FRand()*WeaponFirePitchRand);
	}
	
	if(PersonPawn(Instigator) != None 
		&& !PersonPawn(Instigator).bPlayer
		&& PersonPawn(Instigator).bAdvancedFiring)
		FireMode = FM_Burst;
	
	Super.PlayFiring();
}

/*
function ServerFire()
{
	// Don't allow holding LMB to fire in Burst unless it's in Dual Wielding.
	if (FireMode == FM_Burst && !bDualWielding && LeftWeapon != none)
		Instigator.Controller.bFire = 0;
	
	Super.ServerFire();
}
*/

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
	ignores AltFire;

	///////////////////////////////////////////////////////////////////////////////
	// Same as global
	///////////////////////////////////////////////////////////////////////////////
	simulated function Fire( float Value )
	{
		if(bCanFireAgain && FireMode==FM_Semi)
		{
			global.Fire(0);
			// Animation-canceling makes our accuracy worse
			if(TraceAccuracySemi < TraceAccuracyAuto)
				TraceAccuracySemi = (TraceAccuracySemi + 0.05);
		}
	}
	function ServerFire()
	{
		if(bCanFireAgain && FireMode==FM_Semi)
		{
			global.ServerFire();
			// Animation-canceling makes our accuracy worse
			if(TraceAccuracySemi < TraceAccuracyAuto)
				TraceAccuracySemi = (TraceAccuracySemi + 0.05);
		}
	}
	function AnimEnd(int Channel)
	{
		Super.AnimEnd(Channel);
		TraceAccuracySemi=default.TraceAccuracySemi;
	}
	simulated function EndState()
	{
		Super.EndState();
	}
Begin:
	Sleep(FiringWaitTime);
	bCanFireAgain=true;
}

///////////////////////////////////////////////////////////////////////////////
// NPCs with bAdvancedFiring set to True will use Burst fire. 
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(PersonPawn(Instigator) != None 
		&& !PersonPawn(Instigator).bPlayer
		&& PersonPawn(Instigator).bAdvancedFiring)
		FireMode = FM_Burst;
}

///////////////////////////////////////////////////////////////////////////////
// Pre-update Glock used skinflash notify to fire for some reason.
// Added it back for compability with mods that still might be using it.
///////////////////////////////////////////////////////////////////////////////
function Notify_skinflash_start()
{
	Notify_Fire();
	AmbientGlow = 400;
}

function Notify_Fire()
{
	Super.Notify_Fire();
	Notify_SpawnShell();
}

///////////////////////////////////////////////////////////////////////////////
// Handle these sounds with script notify and allow only for players. 
// This sound can be a little annoying when made by NPCs when the level loads...
///////////////////////////////////////////////////////////////////////////////
function Notify_SlideSnap()
{
	if ( Instigator.IsHumanControlled() )
	{
        Instigator.PlaySound(SlideSnapSound, SLOT_None, 1.0, true);
	}
}

function Notify_SlideBack()
{
	if ( Instigator.IsHumanControlled() )
	{
        Instigator.PlaySound(SlideBackSound, SLOT_Pain, 1.0, true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Little trick to keep the "fake" shell during load animation.
///////////////////////////////////////////////////////////////////////////////
state Active
{
	function BeginState()
	{
		Super.BeginState();
		UnCheckShell();
	}
}

function UnCheckShell()
{
	local int i;
	
	for(i=0; i<Skins.Length; i++)
	{
		if(default.Skins[i] == ShellTex)
			Skins[i] = default.Skins[i];
	}
}

///////////////////////////////////////////////////////////////////////////////
// Okay since MP5 and Glock now use new ammo class I guess I should do
// something to prevent losing ammo on old saves.
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	FixOldAmmo(Class'GSelectAmmoInv', AmmoName);
	Super.PostLoadGame();
}

defaultproperties
{
	// Change by NickP: MP fix
	 NoAmmoChangeState="DownWeapon"
	
	 FireMode=FM_Semi
     bDisplayFireMode=True
     bSwitchesFireMode=True
    
	 SelectAnims(0)="load_semi"
     SelectAnims(1)="load_auto"
     SelectAnims(2)="load_auto"
     DeselectAnims(0)="Holster_semi"
     DeselectAnims(1)="Holster_auto"
     DeselectAnims(2)="Holster_auto"
     FireAnims(0)="shoot1_semi"
     FireAnims(1)="shoot1_auto"
     FireAnims(2)="new_shoot_full"
     IdleAnims(0)="Idle_Semi"
     IdleAnims(1)="Idle_auto"
     IdleAnims(2)="Idle_auto"
     ReloadAnims(0)="reload_auto"
     ReloadAnims(1)="reload_auto"
     ReloadAnims(2)="reload_semi"
     SwitchAnims(0)="shoot2_semi2auto"
     SwitchAnims(1)="shoot2_auto2semi" //shoot2_semi2auto
     SwitchAnims(2)="shoot2_auto2semi"
     FireModeStrings(0)="Semi"
     FireModeStrings(1)="Burst"
     FireModeStrings(2)="Auto"

     bUsesAltFire=True
     ViolenceRank=3
	 AutoSwitchPriority=8
	 CombatRating=2.000000
     RecognitionDist=1100.000000
     ShotMarkerMade=Class'Postal2Game.GunfireMarker'
     BulletHitMarkerMade=Class'Postal2Game.BulletHitMarker'
	 PawnHitMarkerMade=class'PawnShotMarker'
	 holdstyle=WEAPONHOLDSTYLE_Single
     switchstyle=WEAPONHOLDSTYLE_Single
     firingstyle=WEAPONHOLDSTYLE_Single
     MinRange=100.000000

     bAllowHints=True
     bShowHints=True
     HudHint1="%KEY_AltFire% selects semi-auto,"
     HudHint2="burst, or full-auto."
	 
     FirstPersonMeshSuffix="ED_Glock_NEW"
     WeaponsPackageStr="ED_Weapons."
     WeaponSpeedLoad=1.000000
     WeaponSpeedHolster=1.000000
     WeaponSpeedShoot1=0.700000
     WeaponSpeedShoot1Rand=0.000000
     WeaponSpeedShoot2=1.000000
	 WeaponSpeedSwitch=1.5000000
	 
     AltFireSound=Sound'EDWeaponSounds.Pistol.Glock_fire'
     AmmoName=Class'NineAmmoInv'
	 //AmmoName=class'GSelectAmmoInv'
    
     /**
     ShakeRotMag=(X=350.000000)
	 ShakeRotMag=(X=220.0,Y=30.0,Z=30.0)
     ShakeRotTime=2.500000
     ShakeOffsetMag=(X=20.000000,Y=2.000000,Z=2.000000)
     ShakeOffsetRate=(X=800.000000,Y=800.000000,Z=800.000000)*/

     ShakeOffsetMag=(X=3.0,Y=2.5,Z=2.5)
	 ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	 ShakeOffsetTime=2.0
	 ShakeRotMag=(X=120.0,Y=30.0,Z=30.0)
	 ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	 ShakeRotTime=2.0

     TraceAccuracySemi=0.250000
	 TraceAccuracyAuto=0.750000  //2
	 TraceAccuracyBurst=0.400000 //0.75
	 
     aimerror=0.000000
     AIRating=0.2 //0.800000	// Fix for NPCs not using MP5 with highier priority than Glock
     MaxRange=1024.000000
     FireSound=Sound'EDWeaponSounds.Pistol.Glock_fire'
     FlashOffsetY=-0.090000
     FlashOffsetX=0.095000
     MuzzleFlashSize=96.000000
     MFTexture=Texture'Timb.muzzle_flash.machine_gun_corona'
     MuzzleFlashScale=2.400000
     MuzzleFlashStyle=STY_Normal
	 
     InventoryGroup=2
     GroupOffset=2
	 
     PickupClass=Class'GSelectPickup'
     //PlayerViewOffset=(X=0.000000,Z=-1.000000)
     PlayerViewOffset=(X=0.000000,Y=0.00,Z=-8.000000)
     AttachmentClass=Class'GSelectAttachment'
     ItemName="Machine Pistol"
     //Texture=Texture'ED_Hud.HUDglock'
     Mesh=SkeletalMesh'ED_Weapons.ED_Glock_NEW'
     Skins(0)=Texture'ED_WeaponSkins.Pistol.glockskin'
     Skins(1)=Texture'ED_WeaponSkins.Pistol.beretta'
     Skins(2)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     AmbientGlow=128
     SoundRadius=255.000000
	 BobDamping=1.150000
	 
	 OverrideHUDIcon=Texture'EDHud.hud_Glock'
	 
	 // Muzzle Flash
	 bSpawnMuzzleFlash=True
	 MFClass[0]=class'MuzzleFlash_SMG'
	 MFBoneName="Muzzle"
	 MFRelativeLocation=(X=0,Y=0,Z=0)
	 
	 MFClass[2]=class'FX2.MuzzleFlash01'
	 
	 // Meow! 
	 bAttachCat=True
	 CatFireSound=Sound'WeaponSounds.machinegun_catfire'
	 CatBoneName="Muzzle"
	 CatRelativeLocation=(X=0,Y=-2,Z=0)
	 CatRelativeRotation=(Pitch=33000,Yaw=0,Roll=-16384)
	 StartShotsWithCat=9
	 
	 // Shell
	 ShellBoneName="shell02"
     ShellRelativeLocation=(X=12.000000,Z=-5.000000)
	 ShellSpeedY=350.000000
     ShellSpeedZ=400.000000
     ShellClass=Class'P2Shell_9mm'
	 bCheckShell=True
	 ShellTex=Texture'ED_WeaponSkins.Pistol.beretta'
	 
	 bCanFireAgain=true
	 FiringWaitTime=0.15
	 SlideBackSound=Sound'EDWeaponSounds.Pistol.Glock_slideback'
	 SlideSnapSound='EDWeaponSounds.Pistol.Glock_slidesnap'
	 
	 bAllowMiddleFinger=True
}
