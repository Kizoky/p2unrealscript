class GSelectWeapon extends EDWeapon;

simulated function PlayFiring()
{
	local float UseVol;
	
	IncrementFlashCount();
	
	UseVol = 0.5;
	if (FireMode == FM_Burst)
		UseVol = 0.4;

	// ED fire sounds are a bit too loud, tone it down here
    if(Level.Game == None || !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(FireSound,SLOT_Interact,UseVol,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else
		Instigator.PlaySound(FireSound, SLOT_None, UseVol, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

    if (FireMode == FM_Auto && bThreeStageFire)
        PlayAnim(LoopFireAnim, WeaponSpeedLoopFire, 0);
    else
        PlayAnim(FireAnims[FireMode], GetFireAnimRate() + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

function Notify_Fire()
{
	local float UseVol;
	
	UseVol = 0.5;
	if (FireMode == FM_Burst)
		UseVol = 0.4;
//    if (MagazineCount > 0)
//    {
        TraceFire(GetTraceAccuracy(), 0, 0);
//        MagazineCount--;

        if (Level.Game == None || !FPSGameInfo(Level.Game).bIsSinglePlayer)
            PlayOwnedSound(FireSound,SLOT_Interact,UseVol,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
        else
            Instigator.PlaySound(FireSound, SLOT_None, UseVol, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
//    }
}

function Notify_skinflash_start()
{
	local float UseVol;
    AmbientGlow = 400;

	UseVol = 0.5;
	if (FireMode == FM_Burst)
		UseVol = 0.4;
		
    if (FireMode == FM_Burst && MagazineCount > 0 && AmmoType.HasAmmo())
    {
        TraceFire(GetTraceAccuracy(), 0, 0);
//        MagazineCount--;

        if (Level.Game == None || !FPSGameInfo(Level.Game).bIsSinglePlayer)
            PlayOwnedSound(FireSound,SLOT_Interact,UseVol,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
        else
            Instigator.PlaySound(FireSound, SLOT_None, UseVol, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

        if (MagazineCount == 0)
        {
            PlayIdleAnim();
            GotoState('Idle');
        }
    }
}


function ToggleFireMode()
{
	TurnOffHint();
    switch (FireMode)
    {
        case FM_Semi:    FireMode = FM_Burst;
                         break;

        case FM_Burst:   FireMode = FM_Auto;
                         break;

        case FM_Auto:    FireMode = FM_Semi;
                         break;
    }
}

defaultproperties
{
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
     SwitchAnims(1)="shoot2_semi2auto"
     SwitchAnims(2)="shoot2_auto2semi"
     FireModeStrings(0)="Semi"
     FireModeStrings(1)="Burst"
     FireModeStrings(2)="Auto"
     MagazineCount=16
     bUsesAltFire=True
     ViolenceRank=3
     RecognitionDist=1100.000000
     ShotMarkerMade=Class'Postal2Game.GunfireMarker'
     BulletHitMarkerMade=Class'Postal2Game.BulletHitMarker'
	PawnHitMarkerMade=class'PawnShotMarker'
	holdstyle=WEAPONHOLDSTYLE_Single
     switchstyle=WEAPONHOLDSTYLE_Single
     firingstyle=WEAPONHOLDSTYLE_Single
     NoAmmoChangeState="GunEmpty"
     MinRange=100.000000
     ShakeOffsetTime=2.000000
     bAllowHints=True
     bShowHints=True
     HudHint1="%KEY_AltFire% selects semi-auto,"
     HudHint2="burst, or full-auto."
     CombatRating=2.000000
     FirstPersonMeshSuffix="ED_Glock_NEW"
     WeaponsPackageStr="ED_Weapons."
     WeaponSpeedLoad=1.000000
     WeaponSpeedHolster=1.000000
     WeaponSpeedShoot1=1.000000
     WeaponSpeedShoot1Rand=0.000000
     WeaponSpeedShoot2=1.000000
     AltFireSound=Sound'EDWeaponSounds.Pistol.Glock_fire'
     //AmmoName=Class'MaD_ED.NineAmmunition'
	 AmmoName=class'GSelectAmmoInv'
     AutoSwitchPriority=8
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

     TraceAccuracySemi=0.100000
	 TraceAccuracyAuto=2
	 TraceAccuracyBurst=0.75
     aimerror=0.000000
     AIRating=0.800000
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
     BobDamping=0.975000
     AttachmentClass=Class'GSelectAttachment'
     ItemName="Glock"
     //Texture=Texture'ED_Hud.HUDglock'
     Mesh=SkeletalMesh'ED_Weapons.ED_Glock_NEW'
     Skins(0)=Texture'ED_WeaponSkins.Pistol.glockskin'
     Skins(1)=Texture'ED_WeaponSkins.Pistol.beretta'
     Skins(2)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     AmbientGlow=128
     SoundRadius=255.000000
}
