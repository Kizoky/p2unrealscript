/**
 * MountedMinigun
 *
 * @author Gordon Cheng
 */
class MountedMinigun extends MountedWeapon
    placeable;

/** The bones we'll use to "animate" the weapon */
var name MuzzleFlashBone;
var name ShellEjectionBone;
var name BarrelBone;
var name PivotBone;
var name BaseBone;

/** Values that dictate the speed and deceleration of the barrels */
var int BarrelMaxSpinRate;
var int BarrelAccelerationRate;
var int BarrelDecelerationRate;

/** Various sounds used for the minigun unique sounds */
var sound FireAmbientSound;
var sound WindDownSound;

/** Various effect classes to use; Removed in favor of animation notifies */
/*var int FlashCount;
var int MuzzleFlashPerShot;

var class<PLPersistantEmitter> MuzzleFlashEmitterClass;
var class<PLPersistantEmitter> ShellCasingEmitterClass;*/
var class<PLPersistantEmitter> TracerEmitterClass;

/** Used to identify when we let go of firing */
var bool bOldWeaponFiring, bNewWeaponFiring;
var int CurBarrelRotation, CurBarrelSpeed;

/** Emitters we need to spawn particles for */
/*var PLPersistantEmitter MuzzleFlashEmitter;
var PLPersistantEmitter ShellCasingEmitter;*/
var PLPersistantEmitter TracerEmitter;

// Added by Man Chrzan - Muzzle Flash
var P2Emitter MF;
var class<P2Emitter>  MFClass; 
var() name MFBoneName;
var() vector MFRelativeLocation;
var() rotator MFRelativeRotation;


/** Create objects the Minigun may need to function or look freakin' sweet */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    if ((MuzzleFlashBone != '' && MuzzleFlashBone != 'None') && TracerEmitterClass != none)
         TracerEmitter = Spawn(TracerEmitterClass);

    if (TracerEmitter != none)
        AttachToBone(TracerEmitter, MuzzleFlashBone);
}

/** Copied and modified from MountedWeapon */
function TraceFire(int Mode) {
    local float accuracy;
	local vector markerpos, markerpos2;
	local bool secondary;
	local vector usev;
	local Rotator newrot;

	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;

	if (bNPCMountedWeaponUser)
	    accuracy = FiringModes[Mode].NPCAccuracy;
    else
        accuracy = FiringModes[Mode].Accuracy;

	GetAxes(AimRotation, X, Y, Z);
    StartTrace = Location + class'P2EMath'.static.GetOffset(AimRotation,
        FiringModes[Mode].FireOffset);
	EndTrace = StartTrace + (accuracy * (FRand() - 0.5 )) * Y * 1000 +
        (accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AimRotation);
	EndTrace += (FiringModes[Mode].TraceDist * X);
	Other = Trace(HitLocation, HitNormal ,EndTrace, StartTrace, true);

	ProcessTraceHit(Mode, Other, HitLocation, HitNormal, X);

	if (P2GameInfo(Level.Game).bShowTracers && TracerEmitter != none) {
        if (Other != none) {
            usev = (HitLocation - StartTrace);
            TracerEmitter.SetDirection(Normal(usev), VSize(usev));
        }
        else {
            usev = (EndTrace - StartTrace);
            TracerEmitter.SetDirection(Normal(usev), VSize(usev));
        }
	}

	if (P2Player(MountedWeaponUser.Controller) != none && FPSPawn(Other) != none)
		P2Player(MountedWeaponUser.Controller).Enemy = FPSPawn(Other);

	if (MountedWeaponUser.Controller != none) {
		markerpos = MountedWeaponUser.Location;
		markerpos2 = HitLocation;
		secondary = true;

		if (ShotMarkerMade != none)
			ShotMarkerMade.static.NotifyControllersStatic(Level, ShotMarkerMade,
				FPSPawn(MountedWeaponUser), FPSPawn(MountedWeaponUser),
                ShotMarkerMade.default.CollisionRadius, markerpos);

		if (P2Pawn(Other) != none && PawnHitMarkerMade != none)
			PawnHitMarkerMade.static.NotifyControllersStatic(Level,
                PawnHitMarkerMade, FPSPawn(MountedWeaponUser), FPSPawn(Other),
				PawnHitMarkerMade.default.CollisionRadius,
				markerpos2);
		else if(secondary && BulletHitMarkerMade != none)
			BulletHitMarkerMade.static.NotifyControllersStatic(Level,
				BulletHitMarkerMade, FPSPawn(MountedWeaponUser), none,
				BulletHitMarkerMade.default.CollisionRadius, markerpos2);
    }
}

/** Plays the "activate" animation */
function PlayBringUpAnim() {
    PlayAnim('Load');
}

/** Plays the "deactivate" animation */
function PlayDownAnim() {
    PlayAnim('Holster');
}

/** Play the Idle Animation to return the weapon back to a state of rest */
function PlayIdleAnim() {
    PlayAnim('Idle');
}

/** Play or rather, loop the firing animation */
function PlayFiringAnim() {
    LoopAnim('Shoot1');
}

/** Overriden so we can play the "activate" animation */
function MountUser(Pawn User) {
    super.MountUser(User);

    PlayBringUpAnim();

    if (MountedWeaponTracer(TracerEmitter) != none)
        MountedWeaponTracer(TracerEmitter).bNPCMountedWeaponUser = bNPCMountedWeaponUser;
}

/** Overriden so we can play the "deactivate" animation */
function DismountUser() {
    super.DismountUser();

    PlayDownAnim();
}

/** Plays the wind down sound for the minigun motor */
function PlayWindDownSound() {
    if (WindDownSound != none)
        PlaySound(WindDownSound, SLOT_None, 1.0, true);
}

/** Overriden so we gib anyone who dies from the minigun */
/*
function ProcessTraceHit(int Mode, Actor Other, vector HitLocation,
                         vector HitNormal, vector X) {
    super.ProcessTraceHit(Mode, Other, HitLocation, HitNormal, X);

    if (Pawn(Other) != none && Pawn(Other).Health <= 0)
        Pawn(Other).ChunkUp(0);
}
*/

/**
 * Overriden so we can perform firing effects here; Removed in favor of effects
 * through animation notifies
 * X = Yaw, Y = Pitch, Z = Roll; no need to touch roll
 */
function PlayFiringEffects(int Mode) {
    if (TracerEmitter != none)
        TracerEmitter.SpawnParticle(0, 1);
		
	PlayFireEffects(MFClass);	// Added by Man Chrzan
}

/**
 * This code can go anywhere, but I'll do it under fire. Overriden so we can
 * implement the firing ambient sound and barrel rotation
 */
function UpdateFire(float DeltaTime) {
    local rotator BarrelRotation;

    super.UpdateFire(DeltaTime);

    if (MountedWeaponUser != none && MountedWeaponUser.PressingFire())
        bNewWeaponFiring = true;
    else
        bNewWeaponFiring = false;

    if (!bOldWeaponFiring && bNewWeaponFiring) {
        PlayFiringAnim();
        AmbientSound = FireAmbientSound;
    }

    if (bOldWeaponFiring && !bNewWeaponFiring) {
        PlayIdleAnim();
        PlayWindDownSound();
        AmbientSound = none;
    }

    bOldWeaponFiring = bNewWeaponFiring;

    if (BarrelBone != '' && BarrelBone != 'None') {
        if (MountedWeaponUser != none && MountedWeaponUser.PressingFire())
            CurBarrelSpeed = Min(CurBarrelSpeed + BarrelAccelerationRate *
                DeltaTime, BarrelMaxSpinRate);
        else
            CurBarrelSpeed = Max(CurBarrelSpeed - BarrelDecelerationRate *
                DeltaTime, 0);

        CurBarrelRotation = (CurBarrelRotation + CurBarrelSpeed * DeltaTime) %
            65536;

        BarrelRotation.Roll = CurBarrelRotation;

        SetBoneRotation(BarrelBone, BarrelRotation);
    }
}

// Added by Man Chrzan
simulated function PlayFireEffects(class<P2Emitter> MyMFClass)
{
	local int i;
	local P2Emitter MF;
	
	// Spawn only if it disappeared
	if (MyMFClass != none) //&& MF == none )
	{
		MF = Spawn( MyMFClass );
		
		// If it's xMuzzleFlashEmitter we can setup it.
		if( xMuzzleFlashEmitter(MF) != None )
		{
			if(P2GameInfoSingle(Level.Game).xManager.bDynamicLights)
				xMuzzleFlashEmitter(MF).SetDynamicLight();
		}
		
		// Basic setup for any P2Emitter
		MF.SetOwner( Owner );
		AttachToBone( MF, MuzzleFlashBone );
		MF.SetDirection(vector(Rotation), 0.0);
		MF.SetRelativeRotation(MFRelativeRotation);
		MF.SetRelativeLocation(MFRelativeLocation);

		// Disable upon completion of effect
		for( i=0; i < MF.Emitters.Length; i++ )
			MF.Emitters[i].AutoDestroy = true; 
	}
}


defaultproperties
{
    HUDIcon=texture'MrD_PL_Tex.HUD.MiniGun_HUD'
    Message="Press %KEY_InventoryActivate% for a good time!"

    MuzzleFlashBone="Bone_Flash"
    ShellEjectionBone=""
    BarrelBone="Bone_Barrel"
    PivotBone="Bone_Pivot"
    BaseBone="Bone_Base"

    BarrelMaxSpinRate=500000
    BarrelAccelerationRate=1000000
    BarrelDecelerationRate=150000

    FireAmbientSound=sound'TempMinigunSounds.minigun_shoot'
    WindDownSound=sound'TempMinigunSounds.minigun_wind_down'
	SoundVolume=255
	SoundRadius=512

    //MuzzleFlashPerShot=3

    //MuzzleFlashEmitterClass=class'MountedWeaponMuzzleFlashEmitter'
    //ShellCasingEmitterClass=none

    BulletHitPackClass=class'MountedWeaponBulletHitPack'

    //TracerEmitterClass=class'MountedWeaponTracer'

    CameraFOV=70 //50

    CameraOffset=(X=0,Y=0.45,Z=45.6)
    TriggerOffset=(X=-80)
    DismountOffset=(X=-80,Z=-16)

    FiringModes(0)=(FireType=FIRETYPE_Instant,DamageAmount=10,NPCDamageAmount=5,Momentum=30000,FireInterval=0.02,NPCFireInterval=0.1,Accuracy=0.25,NPCAccuracy=0.5,TraceDist=10000,FireOffset=(X=104,Z=30),DamageType=class'MinigunDamage')	//was DamageType=class'MachineGunDamage')
    FiringModes(1)=(FireType=FIRETYPE_None)

    DrawType=DT_Mesh
    Mesh=SkeletalMesh'MrD_PL_Anims.M_MiniGun_D'

    DrawScale=0.55
	
	MFClass=class'FX2.MuzzleFlash_Minigun'
	MFRelativeLocation=(X=5,Y=0,Z=0)
}
