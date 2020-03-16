class MP5Weapon extends EDWeapon;

function ToggleFireMode()
{
	TurnOffHint();
	Super.ToggleFireMode();
}

simulated function PlayFiring()
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

///////////////////////////////////////////////////////////////////////////////
// Modify your speed based on your owners body speed
///////////////////////////////////////////////////////////////////////////////
function ChangeSpeed(float NewSpeed)
{
	Super.ChangeSpeed(NewSpeed);
	WeaponSpeedLoopFire = default.WeaponSpeedLoopFire*NewSpeed;
}

defaultproperties
{
     bDisplayFireMode=True
     bSwitchesFireMode=True
     bThreeStageFire=False
     WeaponSpeedPrepFire=2.000000
     WeaponSpeedLoopFire=1.500000
     WeaponSpeedEndFire=2.000000
     WeaponSpeedSwitch=2.000000
     //PrepFireAnim="Shoot1_auto"
     LoopFireAnim="shoot1_auto"
     //EndFireAnim="Shoot1_auto"
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
     MagazineCount=30
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
     ShakeOffsetTime=2.500000
     bAllowHints=True
     bShowHints=True
     HudHint1="%KEY_AltFire% selects"
     HudHint2="semi-auto or full-auto."
     CombatRating=2.000000
     FirstPersonMeshSuffix="ED_MP5_NEW"
     WeaponsPackageStr="ED_Weapons."
     WeaponSpeedLoad=1.000000
     WeaponSpeedHolster=1.000000
     WeaponSpeedShoot1=1.000000
     WeaponSpeedShoot1Rand=0.000000
     WeaponSpeedShoot2=2.500000
     AltFireSound=Sound'EDWeaponSounds.Weapons.MP5'
     AmmoName=Class'MP5AmmoInv'
     AutoSwitchPriority=8
     /**
     ShakeRotMag=(X=300.000000)
     ShakeRotTime=2.500000
     ShakeOffsetMag=(X=20.000000,Y=4.000000,Z=4.000000)
     ShakeOffsetRate=(X=800.000000,Y=800.000000,Z=800.000000)*/

     ShakeOffsetMag=(X=3.0,Y=2.5,Z=2.5)
	 ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	 ShakeOffsetTime=2.0
	 ShakeRotMag=(X=120.0,Y=30.0,Z=30.0)
	 ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	 ShakeRotTime=2.0

     TraceAccuracySemi=0.150000
	 TraceAccuracyAuto=0.500000
     aimerror=0.000000
     AIRating=0.800000
     MaxRange=200.000000
     FireSound=Sound'EDWeaponSounds.Weapons.MP5'
     FlashOffsetY=-0.090000
     FlashOffsetX=0.095000
     MuzzleFlashSize=96.000000
     MFTexture=Texture'Timb.muzzle_flash.machine_gun_corona'
     MuzzleFlashScale=2.400000
     MuzzleFlashStyle=STY_Normal
     InventoryGroup=4
     GroupOffset=5
     PickupClass=Class'MP5Pickup'
     PlayerViewOffset=(X=0.000000,Y=0.300000,Z=-7)
     BobDamping=0.975000
     AttachmentClass=Class'MP5Attachment'
     ItemName="MP5"
	//OverrideHUDIcon=Texture'EDHud.hud_mp5'
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
}
