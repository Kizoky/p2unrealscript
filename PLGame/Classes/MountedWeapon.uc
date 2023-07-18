/**
 * MountedWeapon
 *
 * Supports the basic functionality needed for a weapon mounted on a stand.
 * This includes mounting, dismounting, and different styles of firing.
 *
 * @author Gordon Cheng
 */
class MountedWeapon extends Actor
    abstract;

/** Defines whether we perform a TraceFire, ProjectileFire, or nothing */
enum EFireType {
    FIRETYPE_None,
    FIRETYPE_Instant,
    FIRETYPE_Projectile,
};

/** Struct defining the two firing modes this mounted weapon has */
struct FireMode {
    var EFireType FireType;

    var float DamageAmount;
    var float Momentum;
    var float FireInterval;
    var float Accuracy;
    var float TraceDist;

    var float NPCFireInterval;
    var float NPCDamageAmount;
    var float NPCAccuracy;

    var vector FireOffset;

    var class<P2Projectile> ProjectileClass;
    var class<DamageType> DamageType;

    var sound FireSound;

    var float FireElapsedTime;
};

var() bool bThirdPersonDebugMode;

/** Whether or not the weapon is currently in use */
var bool bMountedWeaponInUse;

/** Variables used for mounting and dismounting from the weapon */
var bool bMountingWeapon, bDismountingWeapon;
var float MountTime, DismountTime;
var vector MountInterpStart, MountInterpEnd;
var vector MountInterpRotStart, MountInterpRotEnd;
var float MountElapsedTime;

/** Defines the primary and alternate firing modes for this weapon */
var FireMode FiringModes[2];

/** Field of vision to use when using the mounted weapon */
var float DefaultFOV;
var float CameraFOV;

/** Locational offsets for the weapon */
var vector CameraOffset, TriggerOffset, DismountOffset;

/** Copied over from the other weapons, various hit sounds */
var array<sound> FleshHitSounds;

/** Important rotations we should keep track of */
var rotator OriginalRotation;
var rotator AimRotation;

/** Marker classes needed to notify Pawns when this weapon makes noises */
var class<TimedMarker> ShotMarkerMade;
var class<TimedMarker> BulletHitMarkerMade;
var class<TimedMarker> PawnHitMarkerMade;

/** Particle stuff */
var class<PLWeaponBulletHitPack> BulletHitPackClass;

/** Various objects we need to keep track of to function properly */
var bool bNPCMountedWeaponUser;

var Actor MountedWeaponCamera;
var Pawn MountedWeaponUser;
var Weapon MountedWeaponUserWeapon;
var PlayerController MountedWeaponPlayerController;
var MountedWeaponTrigger MountedWeaponTrigger;

var PLWeaponBulletHitPack BulletHitPack;

// Trigger stuff
var(UseTrigger) localized string Message;
var(UseTrigger) Texture HUDIcon;

/** Used to spawn various helpful objects such as the MountedWeaponTrigger */
simulated function PostBeginPlay() {
    local vector SpawnLoc;

    super.PostBeginPlay();

    OriginalRotation = Rotation;
    AimRotation = Rotation;

    // Spawn our camera
    MountedWeaponCamera = Spawn(class'MountedWeaponCamera',,,, Rotation);

    if (MountedWeaponCamera == none)
        log(self$": ERROR: Failed to spawn MountedWeaponCamera");

    // Spawn and setup our use trigger
    SpawnLoc = Location +
        class'P2EMath'.static.GetOffset(OriginalRotation, TriggerOffset);
    MountedWeaponTrigger = Spawn(class'MountedWeaponTrigger',,, SpawnLoc);

    if (MountedWeaponTrigger != none)
	{
        MountedWeaponTrigger.MountedWeapon = self;
		MountedWeaponTrigger.Message = Message;
		MountedWeaponTrigger.HUDIcon = HUDIcon;
	}
    else
        log(self$": ERROR: Failed to spawn MountedWeaponTrigger");

    // Ensure there's no wait time to use the weapon initially
    FiringModes[0].FireElapsedTime = FiringModes[0].FireInterval;
    FiringModes[1].FireElapsedTime = FiringModes[1].FireInterval;

    // If one of our firing modes uses bullets create our BulletHitPack
    if ((FiringModes[0].FireType == FIRETYPE_Instant ||
         FiringModes[1].FireType == FIRETYPE_Instant) &&
         BulletHitPackClass != none)
         BulletHitPack = Spawn(BulletHitPackClass);

    // If we're debugging, don't do the camera zoom
    if (bThirdPersonDebugMode)
        CameraFOV = 0;
}

/** Copied and modified from P2Weapon */
function TraceFire(int Mode) {
    local float accuracy;
	local vector markerpos, markerpos2;
	local bool secondary;
	local BulletTracer bullt;
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

	if (P2GameInfo(Level.Game).bShowTracers) {
		usev = (HitLocation - StartTrace);

        if (Level.Game != none && FPSGameInfo(Level.Game).bIsSinglePlayer) {
			bullt = spawn(class'BulletTracer', Owner,, (HitLocation +
                StartTrace) / 2);
			bullt.SetDirection(Normal(usev), VSize(usev));
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

/** Modified from the weapons, so we can deal damage as well has handle any
 * particle effects we may need to create as well
 * @param Other - Object we're gonna deal damage to
 * @param HitLocation - Location in the world where the hit happened
 * @param HitNormal - Normal vector used mainly for impact particles
 */
function ProcessTraceHit(int Mode, Actor Other, vector HitLocation,
                         vector HitNormal, vector X) {
    local float WeaponDamage;

    if (Other == none || MountedWeaponUser == none)
		return;

    if (bNPCMountedWeaponUser)
        WeaponDamage = FiringModes[Mode].NPCDamageAmount;
    else
        WeaponDamage = FiringModes[Mode].DamageAmount;

	if (Other.bStatic && BulletHitPack != none)
		BulletHitPack.SpawnImpactEffects(HitLocation, rotator(HitNormal));
	else {
		Other.TakeDamage(WeaponDamage, MountedWeaponUser, HitLocation,
            FiringModes[Mode].Momentum * X, FiringModes[Mode].DamageType);

		if ((Pawn(Other) != none && Other != Owner) ||
             PeoplePart(Other) != none ||
             CowheadProjectile(Other) != none) {
			 Other.PlaySound(FleshHitSounds[Rand(FleshHitSounds.length)],
                 SLOT_Pain,,, 200.0);
			}
		else if (BulletHitPack != none)
		    BulletHitPack.SpawnImpactEffects(HitLocation, rotator(HitNormal));
	}
}

/** Spawns a projectile
 * @param Mode -
 */
function ProjectileFire(int Mode) {
    // TODO: Implement me... maybe...
}

/** Using the given Pawn object, we'll transfer the view point from
 * the PlayerController and over to our MountedWeaponCamera to dictate the
 * camera movement and lock the Pawn in place as well.
 * @param User - The Pawn to lock into place
 */
function MountUser(Pawn User) {
    local vector DismountLoc;

    MountedWeaponPlayerController = PlayerController(User.Controller);

    // Change the view target from the PlayerController itself to our camera
    if (MountedWeaponPlayerController != none && MountedWeaponCamera != none) {
        bNPCMountedWeaponUser = false;

        MountedWeaponCamera.SetBase(none);
        MountedWeaponCamera.SetLocation(User.Location + User.EyePosition());
        MountedWeaponCamera.SetRotation(User.GetViewRotation());

        MountInterpStart = MountedWeaponCamera.Location;
        MountInterpEnd = Location + class'P2EMath'.static.GetOffset(AimRotation, CameraOffset);

        MountInterpRotStart = vector(User.GetViewRotation());
        MountInterpRotEnd = vector(AimRotation);

        MountedWeaponPlayerController.bFire = 0;
        MountedWeaponPlayerController.bAltFire = 0;

        if (!bThirdPersonDebugMode) {
            MountedWeaponPlayerController.SetViewTarget(MountedWeaponCamera);
            DefaultFOV = MountedWeaponPlayerController.DefaultFOV;
        }

        if (PLDudePlayer(User.Controller) != none)
            PLDudePlayer(User.Controller).bUsingMountedWeapon = true;
    }
    else
        bNPCMountedWeaponUser = true;

    // Set the player behind the gun and disable movement
    if (User != none) {
        DismountLoc = Location + class'P2EMath'.static.GetOffset(OriginalRotation, DismountOffset);

        if (!bThirdPersonDebugMode && !bNPCMountedWeaponUser) {
            User.SetLocation(DismountLoc);
            User.SetPhysics(PHYS_None);
            User.bHidden = true;
        }

        MountedWeaponUser = User;
        MountedWeaponUserWeapon = User.Weapon;
		
		User.Weapon = none;
    }

    // Start the mounting process
    bMountingWeapon = true;
    MountElapsedTime = 0.0;
}

/** Dismounts the player by returning the Player's view back to normal, and
 * allows the player to move again.
 */
function DismountUser() {
    local vector DismountLoc;

    // Change the view target from the camera back to the PlayerController
    if (MountedWeaponCamera != none) {
        MountedWeaponCamera.SetBase(none);

        MountInterpStart = MountedWeaponCamera.Location;
        MountInterpEnd = MountedWeaponUser.Location + MountedWeaponUser.EyePosition();

        MountInterpRotStart = vector(AimRotation);
        MountInterpRotEnd = vector(OriginalRotation);
    }

    // Start the dismounting process
    bDismountingWeapon = true;
    MountElapsedTime = 0.0;
}

/** Called when the camera finishes transitioning into position */
function FinishedUserMount() {
    if (MountedWeaponCamera != none)
        MountedWeaponCamera.SetBase(self);

    if (MountedWeaponUser != none && !bThirdPersonDebugMode)
        MountedWeaponUser.SetViewRotation(Rotation);

    bMountedWeaponInUse = true;
    bMountingWeapon = false;
}

/** Called when the camera finishes transitioning back to the player view */
function FinishedUserDismount() {
    local PlayerController PlayerC;

    if (MountedWeaponUser != none && !bThirdPersonDebugMode) {

        MountedWeaponUser.SetViewRotation(OriginalRotation);
		if (MountedWeaponUser.Health > 0)
			MountedWeaponUser.SetPhysics(PHYS_Falling);
        MountedWeaponUser.bHidden = false;

        MountedWeaponUser.Weapon = MountedWeaponUserWeapon;

        if (MountedWeaponPlayerController != none)
            MountedWeaponPlayerController.SetViewTarget(MountedWeaponUser);
    }

    if (PLDudePlayer(MountedWeaponPlayerController) != none)
        PLDudePlayer(MountedWeaponPlayerController).bUsingMountedWeapon = false;

    bMountedWeaponInUse = false;
    bMountingWeapon = false;
	bNPCMountedWeaponUser = false;	

    MountedWeaponUser = none;
    MountedWeaponUserWeapon = none;
    MountedWeaponPlayerController = none;
}

/** Notification from our MountedWeaponTrigger that a player has requested this
 * mounted weapon to be mounted or dismounted.
 * @param User - Pawn that's attempting to use this weapon
 */
function NotifyUse(Pawn User) {
    // If we're currently mounting or dismounting from the weapon, ignore
    if (bMountingWeapon || bDismountingWeapon)
        return;

    if (!bMountedWeaponInUse && User != none)
        MountUser(User);
    else if (MountedWeaponUser != none && MountedWeaponUser == User)
        DismountUser();
}

/** Plays the primary firing sound using the given firing mode
 * @param Mode - 0 representing primary, and 1 prepresenting the alternate
 */
function PlayFiringSound(int Mode) {
    if (FiringModes[Mode].FireSound != none)
        PlaySound(FiringModes[Mode].FireSound, SLOT_None, 1.0, true);
}

/** Creates any needed particle effects using the given firing mode
 * @param Mode - 0 presenting primary, and 1 representing the alternate
 */
function PlayFiringEffects(int Mode) {
    // STUB
}

/** Updates the primary firing method using the given time from the last tick.
 * @param DeltaTime - Time in seconds since the last Tick call
 */
function UpdateFire(float DeltaTime) {
    if (FiringModes[0].FireType == FIRETYPE_None)
        return;

    if (bNPCMountedWeaponUser)
        FiringModes[0].FireElapsedTime = FMin(FiringModes[0].FireElapsedTime +
            DeltaTime, FiringModes[0].NPCFireInterval);
    else
        FiringModes[0].FireElapsedTime = FMin(FiringModes[0].FireElapsedTime +
            DeltaTime, FiringModes[0].FireInterval);

    if (MountedWeaponUser != none && MountedWeaponUser.PressingFire() &&
       ((bNPCMountedWeaponUser && FiringModes[0].FireElapsedTime == FiringModes[0].NPCFireInterval) ||
        (!bNPCMountedWeaponUser && FiringModes[0].FireElapsedTime == FiringModes[0].FireInterval))) {
        switch (FiringModes[0].FireType) {
            case FIRETYPE_Instant:
                TraceFire(0);
                break;

            case FIRETYPE_Projectile:
                ProjectileFire(0);
                break;
        }

        PlayFiringSound(0);
        PlayFiringEffects(0);

        FiringModes[0].FireElapsedTime = 0.0;
    }
}

/** Updates the alternate firing method using the given time from the last tick.
 * @param DeltaTime - Time in seconds since the last Tick call
 */
function UpdateAltFire(float DeltaTime) {
    if (FiringModes[1].FireType == FIRETYPE_None)
        return;

    if (bNPCMountedWeaponUser)
        FiringModes[1].FireElapsedTime = FMin(FiringModes[1].FireElapsedTime +
            DeltaTime, FiringModes[1].NPCFireInterval);
    else
        FiringModes[1].FireElapsedTime = FMin(FiringModes[1].FireElapsedTime +
            DeltaTime, FiringModes[1].FireInterval);

    if (MountedWeaponUser != none && MountedWeaponUser.PressingFire() &&
       ((bNPCMountedWeaponUser && FiringModes[1].FireElapsedTime == FiringModes[1].NPCFireInterval) ||
        (!bNPCMountedWeaponUser && FiringModes[1].FireElapsedTime == FiringModes[1].FireInterval))) {
        switch (FiringModes[1].FireType) {
            case FIRETYPE_Instant:
                TraceFire(1);
                break;

            case FIRETYPE_Projectile:
                ProjectileFire(1);
                break;
        }

        PlayFiringSound(1);
        PlayFiringEffects(1);

        FiringModes[1].FireElapsedTime = 0.0;
    }
}

/** Updates the weapon's rotation using the given DeltaTime. Not sure if the
 * DeltaTime is of any use, but it's there if you need it.
 * @param DeltaTime - Time in seconds since the last Tick call
 */
function UpdateWeaponRotation(float DeltaTime) {
    local bool bAIEnemyValid;

    // Don't perform any weapon rotation updates when we're currently
    // mounting or dismounting from the weapon
    if (bMountingWeapon || bDismountingWeapon || MountedWeaponUser == none)
        return;

    bAIEnemyValid = (bNPCMountedWeaponUser && MountedWeaponUser.Controller != none &&
        MountedWeaponUser.Controller.Enemy != none);

    if (bThirdPersonDebugMode)
        AimRotation = rotator(MountedWeaponUser.Location - Location);
    else if (MountedWeaponUser != none) {
        if (bAIEnemyValid) {
            AimRotation = MountedWeaponUser.Rotation;
            AimRotation.Pitch = rotator(MountedWeaponUser.Controller.Enemy.Location - Location).Pitch;
        }
        else
            AimRotation = MountedWeaponUser.GetViewRotation();
    }

    SetRotation(AimRotation);
}

/** Keep track of the firing time here */
function Tick(float DeltaTime) {
    local float MountingPct, ZoomingPct;
    local float AimFOVDif;
    local vector MountInterpLoc, MountInterpRot;

    if (MountedWeaponUser != none && MountedWeaponUser.Health <= 0)
        FinishedUserDismount();

    // Perform any mounting or dismounting camera calculations here
    if (bMountingWeapon) {
        MountElapsedTime = FMin(MountElapsedTime + DeltaTime, MountTime);
        MountingPct = MountElapsedTime / MountTime;
    }
    else if (bDismountingWeapon) {
        MountElapsedTime = FMin(MountElapsedTime + DeltaTime, DismountTime);
        MountingPct = MountElapsedTime / DismountTime;
    }

    if (bMountingWeapon || bDismountingWeapon) {

        if (MountedWeaponPlayerController != none && CameraFOV > 0) {

            AimFOVDif = CameraFOV - DefaultFOV;

            if (bMountingWeapon)
                ZoomingPct = MountElapsedTime / MountTime;
            else if (bDismountingWeapon)
                ZoomingPct = (DismountTime - MountElapsedTime) / DismountTime;

            MountedWeaponPlayerController.SetFOV(DefaultFOV + AimFOVDif *
                ZoomingPct);
        }

        MountInterpLoc = MountInterpStart + (MountInterpEnd - MountInterpStart)
            * MountingPct;

        MountInterpRot = MountInterpRotStart + (MountInterpRotEnd -
            MountInterpRotStart) * MountingPct;

        if (MountedWeaponCamera != none) {
            MountedWeaponCamera.SetLocation(MountInterpLoc);
            MountedWeaponCamera.SetRotation(rotator(MountInterpRot));
        }

        if (bMountingWeapon && MountElapsedTime == MountTime) {
            bMountingWeapon = false;
            FinishedUserMount();
        }

        if (bDismountingWeapon && MountElapsedTime == DismountTime) {
            bDismountingWeapon = false;
            FinishedUserDismount();
        }
    }

    // Update the mounted weapon's rotation
    UpdateWeaponRotation(DeltaTime);

    // Update both firing modes
    UpdateFire(DeltaTime);
    UpdateAltFire(DeltaTime);
}

defaultproperties
{
    bEdShouldSnap=true

    MountTime=0.5
    DismountTime=0.5

    FleshHitSounds(0)=sound'WeaponSounds.bullet_hitflesh1'
	FleshHitSounds(1)=sound'WeaponSounds.bullet_hitflesh2'
	FleshHitSounds(2)=sound'WeaponSounds.bullet_hitflesh3'
	FleshHitSounds(3)=sound'WeaponSounds.bullet_hitflesh4'

	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	PawnHitMarkerMade=class'PawnShotMarker'

}
