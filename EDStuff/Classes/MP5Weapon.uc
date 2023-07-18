class MP5Weapon extends EDWeapon;

var sound cocksound;

// Romoved by Man Chrzan: xPatch 2.0
// Here's our reason for sound stuttering.
// Instead of changing volume in script I've edited sound file.
/*simulated function PlayFiring()
{
	IncrementFlashCount();

	// ED fire sounds are a bit too loud, tone it down here
    if(Level.Game == None || !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(FireSound,SLOT_Interact,0.5,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else
		Instigator.PlaySound(FireSound, SLOT_None, 0.5, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

    if (FireMode == FM_Auto)
        PlayAnim(LoopFireAnim, WeaponSpeedLoopFire, 0);
    else
        PlayAnim(FireAnims[FireMode], GetFireAnimRate() + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}
*/

///////////////////////////////////////////////////////////////////////////////
// Modify your speed based on your owners body speed
///////////////////////////////////////////////////////////////////////////////
function ChangeSpeed(float NewSpeed)
{
	Super.ChangeSpeed(NewSpeed);
	WeaponSpeedLoopFire = default.WeaponSpeedLoopFire*NewSpeed;
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// HACK: Fix for some Workshop Weapons that are based on MP5
// Use ThreeStageFire only if it's MP5.
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	if (Class == class'MP5Weapon')
	{
	    bThreeStageFire=True;
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Cat Silencer
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	local float UsePitch;
	
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
	
	Super.PlayFiring();
}

function PlayIdleAnim()
{
	Super.PlayIdleAnim();
	
	if( Cat != None && bCatStateControl)
		Cat.PlayAnim(CatIdleAnim);	
	if (P2WeaponAttachment(ThirdPersonActor).CatSilencer3rd != None)
		P2WeaponAttachment(ThirdPersonActor).CatSilencer3rd.PlayAnim(CatIdleAnim);
}

function PlayDownAnim()
{
	Super.PlayDownAnim();
	
	if( Cat != None && bCatStateControl)
		Cat.PlayAnim(CatIdleAnim);
	if (P2WeaponAttachment(ThirdPersonActor).CatSilencer3rd != None)
		P2WeaponAttachment(ThirdPersonActor).CatSilencer3rd.PlayAnim(CatIdleAnim);
}

///////////////////////////////////////////////////////////////////////////////
// Handle these sounds with script notify and allow only for players. 
// This sound can be a little annoying when made by NPCs when the level loads...
///////////////////////////////////////////////////////////////////////////////
function Notify_Cock()
{
	if ( Instigator.IsHumanControlled() )
	{
        Instigator.PlaySound(CockSound, SLOT_None, 1.0, true,,);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Okay since MP5 and Glock now use new ammo class I guess I should do
// something to prevent losing ammo on old saves.
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	FixOldAmmo(Class'MP5AmmoInv', AmmoName);
	
	// We might need to fix animations too!
	if (Class == class'MP5Weapon' && !bThreeStageFire)
	{
	    bThreeStageFire=True;
		PlayIdleAnim();
	}
	
	Super.PostLoadGame();
}

defaultproperties
{
	 NoAmmoChangeState="DownWeapon"
	 bDisplayFireMode=True
     bSwitchesFireMode=True
//	 bThreeStageFire=True	// Handled in PreBeginPlay
     PrepFireAnim="Shoot1_autoPrep"
     LoopFireAnim="shoot1_auto"
     EndFireAnim="Shoot1_autoend"
     SelectAnims(0)="load_semi"
     SelectAnims(2)="load_auto"
     DeselectAnims(0)="Holster_semi"
     DeselectAnims(2)="Holster_auto"
     FireAnims(0)="shoot1_semi"
	 FireAnims(2)="shoot1_auto"
     IdleAnims(0)="Idle_Semi"
     IdleAnims(2)="Idle_auto"
     ReloadAnims(0)="reload_semi"
     ReloadAnims(2)="reload_auto"
     SwitchAnims(0)="shoot2_semi2auto"
     SwitchAnims(2)="shoot2_auto2semi"
     FireModeStrings(0)="Semi"
     FireModeStrings(1)="Burst"
     FireModeStrings(2)="Auto"
     FireMode=FM_Auto
     bUsesAltFire=True
     ViolenceRank=3
     RecognitionDist=1100.000000
     ShotMarkerMade=Class'Postal2Game.GunfireMarker'
     BulletHitMarkerMade=Class'Postal2Game.BulletHitMarker'
     PawnHitMarkerMade=class'PawnShotMarker'
     holdstyle=WEAPONHOLDSTYLE_Both
     switchstyle=WEAPONHOLDSTYLE_Both
     firingstyle=WEAPONHOLDSTYLE_Both
     MinRange=100.000000
    
     bAllowHints=True
     bShowHints=True
     HudHint1="%KEY_AltFire% selects semi-auto"
     HudHint2="or full-auto."
	 
     CombatRating=2.000000
	 AutoSwitchPriority=8
	 
     FirstPersonMeshSuffix="ED_MP5_NEW"
     WeaponsPackageStr="ED_Weapons."
	 
	 WeaponSpeedLoad=1.000000
     WeaponSpeedHolster=1.000000
     WeaponSpeedShoot1=1.000000 		// Semi
     WeaponSpeedShoot1Rand=0.000000
     WeaponSpeedShoot2=2.500000			// Auto (no 3Stage Fire, Multiplayer)	
	 
	 WeaponSpeedPrepFire=6.000000
     WeaponSpeedLoopFire=1.500000	// Auto (3Stage Fire)
     WeaponSpeedEndFire=3.000000
     WeaponSpeedSwitch=1.7500000
    
     AmmoName=class'NineAmmoInv' //Class'MP5AmmoInv'
     
	 /**
     ShakeRotMag=(X=300.000000)
     ShakeRotTime=2.500000
     ShakeOffsetMag=(X=20.000000,Y=4.000000,Z=4.000000)
     ShakeOffsetRate=(X=800.000000,Y=800.000000,Z=800.000000)*/

     ShakeOffsetMag=(X=3.0,Y=2.5,Z=2.5)
	 ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	 ShakeOffsetTime=2.0
	 //ShakeRotMag=(X=120.0,Y=30.0,Z=30.0)
	 ShakeRotMag=(X=60.0,Y=15.0,Z=15.0)
	 ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	 ShakeRotTime=2.0

     TraceAccuracySemi=0.150000
	 TraceAccuracyAuto=0.750000			//0.500000
     aimerror=0.000000
     AIRating=0.800000
     MaxRange=200.000000
     
	 FireSound=Sound'EDWeaponSounds.Weapons.MP5'
     AltFireSound=Sound'EDWeaponSounds.Weapons.MP5'
	 
	 bDrawMuzzleFlash=False
   	 FlashOffsetY=-0.090000
     FlashOffsetX=0.095000
     MuzzleFlashSize=96.000000
     MFTexture=Texture'Timb.muzzle_flash.machine_gun_corona'
     MuzzleFlashScale=2.400000
     MuzzleFlashStyle=STY_Normal
	 
	 InventoryGroup=4
     GroupOffset=2
	 
     PickupClass=Class'MP5Pickup'
     PlayerViewOffset=(X=0.000000,Y=0.300000,Z=-7)
     //BobDamping=0.975000
	 BobDamping=1.120000
     AttachmentClass=Class'MP5Attachment'
     ItemName="Submachine Gun"
     Mesh=SkeletalMesh'ED_Weapons.ED_MP5_NEW'
     Skins(0)=Texture'ED_WeaponSkins.Rifles.MP5skin'
     Skins(1)=Texture'ED_WeaponSkins.Pistol.beretta'
     Skins(2)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     AmbientGlow=128
     SoundRadius=255.000000
	 SoundVolume=92
	
	 ThirdPersonRelativeLocation=(X=1)
	 ThirdPersonRelativeRotation=(Pitch=-256)
	 AI_BurstCountExtra=10
	 AI_BurstCountMin=6
	 AI_BurstTime=0.12
	
	 // Muzzle Flash
	 bSpawnMuzzleFlash=True
	 MFClass[0]=class'MuzzleFlash_SMG'
	 MFBoneName="Muzzle"
	 MFRelativeLocation=(X=0,Y=0,Z=0)
	 MFScale[0]=(Min=0.25,Max=0.75) 
	 MFSizeRange[0]=(Min=15,Max=20) 
	 MFLifetime[0]=(Min=0.07,Max=0.07)
	 
	 MFClass[2]=class'FX2.MuzzleFlash01'
 
	 // Meow! 
	 bAttachCat=True
	 CatFireSound=Sound'WeaponSounds.machinegun_catfire'
	 CatBoneName="Muzzle"
	 CatRelativeLocation=(X=1,Y=-3,Z=-2)
	 CatRelativeRotation=(Pitch=-16384,Yaw=-13384)
	 StartShotsWithCat=9
	 bCatStateControl=True
	 CatIdleAnim="idle_mg"
	 CatFireAnim="shoot_mg"
	 
	 // Shell
	 ShellBoneName="MESH_Shell"
     ShellRelativeLocation=(Y=5.000000,Z=8.000000)
	 ShellSpeedY=350.000000
     ShellSpeedZ=400.000000
     ShellClass=Class'P2Shell_9mm'
	 bCheckShell=True
	 ShellTex=Texture'ED_WeaponSkins.Pistol.beretta'
	 
	 cocksound=Sound'EDWeaponSounds.Weapons.mp5cock'
}
