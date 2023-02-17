/**
 * LabMonkey
 * Copyright 2014, Running With Scissors, Inc.
 *
 * An adorable little homocidal monkey that follows you around and help you
 * gun people down. It's just like Pikmin but with guns! :D
 *
 * @author Gordon Cheng
 */
class LabMonkey extends AnimalPawn
    placeable;

/** Various monkey specific variables */
var() bool bMonkeyLockedUp;

var() name PistolRackNodeTag;

/** Debug the monkey by giving them a Pistol right off the bat */
var bool bMonkeyAlreadyHasPistol;

/** The one and only health variable */
var float LabMonkeyHealth;

/** Movement variables for speeds and animations */
var float WalkSpeed, RunSpeed;

var float WalkAnimRate, RunAnimRate, RunNoWeaponAnimRate;
var float DeathAnimRate;

/** Firing and trace processing stuff */
var float PistolDamage, PistolMomentum, PistolTraceDist, PistolAccuracy;

var vector PistolFireOffset;
var sound PistolFireSound;
var class<DamageType> PistolDamageType;
var class<PLPersistantEmitter> PistolMuzzleFlashClass;

var array<sound> FleshHitSounds;

var class<TimedMarker> ShotMarkerMade;
var class<TimedMarker> BulletHitMarkerMade;
var class<TimedMarker> PawnHitMarkerMade;

var float PistolDropVelocity;
var class<P2WeaponPickup> PistolPickupClass;

/** Whether or not this Monkey is armed and dangerous */
var bool bMonkeyHasPistol;
var name PistolBone;
var StaticMesh PistolStaticMesh;
var sound PistolEquipSound;

/** Objects we need to keep track of */
var BoltonPart PistolBolton;
var LabMonkeyController LabMonkeyController;
var PLPersistantEmitter PistolMuzzleFlash;

/** Overriden so we can change our movement speed */
event SetWalking(bool bNewIsWalking) {
	if (bNewIsWalking != bIsWalking) {
		bIsWalking = bNewIsWalking;

		if (bIsWalking)
		    GroundSpeed = WalkSpeed;
		else
		    GroundSpeed = RunSpeed;

		ChangeAnimation();
	}
}

/** Return one of our death animations */
simulated function name GetAnimDeath() {
    if (Rand(2) == 0)
        return 'death1';
    else
        return 'death2';
}

/** Might include more animation packages besides the default here */
simulated function SetupAnims() {
    // STUB
}

/** Loops the walking animation */
simulated function SetAnimWalking() {
    LoopAnim('Walk', WalkAnimRate);
}

/** Loops either the run animation, or running with no weapon */
simulated function SetAnimRunning() {
    if (bMonkeyHasPistol)
        LoopAnim('Run', RunAnimRate);
    else
        LoopAnim('run_noweapon', RunNoWeaponAnimRate);
}

/** Loop our idle animation here */
simulated function SetAnimStanding() {
    PlayAnimStanding();
}

/** Play one of our two death animations */
simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc) {
    PlayAnim(GetAnimDeath(), DeathAnimRate);
}

/** Loop our idle animation here */
simulated function PlayAnimStanding() {
    if (LabMonkeyController != none && LabMonkeyController.IsInState('Idle'))
        LoopAnim('stand');
    else {
        if (Rand(2) == 0)
            LoopAnim('Shoot1');
        else
            LoopAnim('Shoot2');
    }
}

/** Play the firing sound when the lab monkey fires its Pistol */
function PlayFireSound() {
    if (PistolFireSound != none)
        PlaySound(PistolFireSound, SLOT_None, 1.0, true);
}

/** Play the firing effects such as the muzzle flash */
function PlayFireEffects() {
    local vector MuzzleFlashLoc;

    if (PistolMuzzleFlash != none) {
        MuzzleFlashLoc = PistolBolton.Location +
            class'P2EMath'.static.GetOffset(PistolBolton.Rotation,
            PistolFireOffset);

        PistolMuzzleFlash.SetLocation(MuzzleFlashLoc);
        PistolMuzzleFlash.SetDirection(vector(PistolBolton.Rotation), 0);
        PistolMuzzleFlash.SpawnParticle(0, 1);
    }
}

/** Equip our Pistol by attaching a bolton and changing a vital flag */
function EquipPistol() {
    PistolBolton = Spawn(class'BoltonPart');

    if (PistolBolton != none) {
        PistolBolton.SetStaticMesh(PistolStaticMesh);
        PistolBolton.SetDrawType(DT_StaticMesh);

        AttachToBone(PistolBolton, PistolBone);

        if (PistolMuzzleFlashClass != none)
            PistolMuzzleFlash = Spawn(PistolMuzzleFlashClass);
    }

    bMonkeyHasPistol = true;
}

/** Drops our current Pistol for the Dude to pickup */
function DropPistol() {
    local P2WeaponPickup PistolPickup;

    if (PistolBolton == none)
        return;

    if (PistolPickupClass != none)
        PistolPickup = Spawn(PistolPickupClass);

    if (PistolPickup != none) {
        PistolPickup.AmmoGiveCount = RandRange(PistolPickup.DeadNPCAmmoGiveRange.Min,
            PistolPickup.DeadNPCAmmoGiveRange.Max);

        PistolPickup.SetPhysics(PHYS_Falling);

        PistolPickup.Velocity.X = FRand() * PistolDropVelocity - FRand() * PistolDropVelocity;
        PistolPickup.Velocity.Y = FRand() * PistolDropVelocity - FRand() * PistolDropVelocity;
        PistolPickup.Velocity.Z = FRand() * PistolDropVelocity;
    }

    if (PistolBolton != none)
        PistolBolton.Destroy();

    if (PistolMuzzleFlash != none)
        PistolMuzzleFlash.Destroy();

    bMonkeyHasPistol = false;
}

/** Copied and modified from P2Weapon */
function TraceFire(Pawn Enemy) {
	local vector markerpos, markerpos2;
	local bool secondary;
	local BulletTracer bullt;
	local vector usev;
	local rotator newrot, ShootRotation;

	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Actor Other;

	// If a cat's scratching you, just hit it, the pussy is point blank anyways
    if (CatPawn(Enemy) != none) {
	    ProcessTraceHit(Enemy, Enemy.Location, HitNormal, X);
	    return;
	}

	StartTrace = PistolBolton.Location +
        class'P2EMath'.static.GetOffset(GetViewRotation(), PistolFireOffset);

    ShootRotation = rotator((Enemy.Location + Enemy.EyePosition()) - StartTrace);

	GetAxes(ShootRotation, X, Y, Z);
	EndTrace = StartTrace + (PistolAccuracy * (FRand() - 0.5 )) * Y * 1000 +
        (PistolAccuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(ShootRotation);
	EndTrace += (PistolTraceDist * X);

    foreach TraceActors(class'Actor', Other, HitLocation, HitNormal, EndTrace, StartTrace) {

        if (LabMonkey(Other) == none && Trigger(Other) == none &&
            DoorBufferPoint(Other) == none &&
            Other != LabMonkeyController.PostalDude) {

            ProcessTraceHit(Other, HitLocation, HitNormal, X);
            break;
        }
    }

	if (P2GameInfo(Level.Game).bShowTracers) {

        usev = (HitLocation - StartTrace);

        if (Level.Game != none && FPSGameInfo(Level.Game).bIsSinglePlayer) {
			bullt = spawn(class'BulletTracer', Owner,, (HitLocation +
                StartTrace) / 2);
			bullt.SetDirection(Normal(usev), VSize(usev));
		}
	}

	if (P2Player(Controller) != none && FPSPawn(Other) != none)
		P2Player(Controller).Enemy = FPSPawn(Other);

	if (Controller != none) {

        markerpos = Location;
		markerpos2 = HitLocation;
		secondary = true;

		if (ShotMarkerMade != none)
			ShotMarkerMade.static.NotifyControllersStatic(Level, ShotMarkerMade,
				self, self, ShotMarkerMade.default.CollisionRadius, markerpos);

		if (P2Pawn(Other) != none && PawnHitMarkerMade != none)
			PawnHitMarkerMade.static.NotifyControllersStatic(Level,
                PawnHitMarkerMade, self, FPSPawn(Other),
				PawnHitMarkerMade.default.CollisionRadius,
				markerpos2);
		else if (secondary && BulletHitMarkerMade != none)
			BulletHitMarkerMade.static.NotifyControllersStatic(Level,
				BulletHitMarkerMade, self, none,
				BulletHitMarkerMade.default.CollisionRadius, markerpos2);
    }
}

/**
 * Modified from the weapons, so we can deal damage as well has handle any
 * particle effects we may need to create as well
 */
function ProcessTraceHit(Actor Other, vector HitLocation, vector HitNormal,
                         vector X) {
	if (Other == none)
		return;

	if (Other.bStatic)
		Spawn(class'PistolBulletHitPack',,, HitLocation, rotator(HitNormal));
	else {
		Other.TakeDamage(PistolDamage, self, HitLocation, PistolMomentum * X,
            PistolDamageType);

		if ((Pawn(Other) != none && Other != Owner) ||
             PeoplePart(Other) != none ||
             CowheadProjectile(Other) != none)
			 Other.PlaySound(FleshHitSounds[Rand(FleshHitSounds.length)],
                 SLOT_Pain,,, 200.0);
		else
			Spawn(class'BulletSparkPack',,, HitLocation, rotator(HitNormal));
	}
}

/**
 * Causes this Lab Monkey to fire his pistol
 *
 * @param Other - Pawn we're attempting to shoot at
 */
function FirePistol(Pawn Other) {
    if (bMonkeyHasPistol && PistolBoltOn != none) {
        TraceFire(Other);

        PlayFireSound();
        PlayFireEffects();
    }
}

/** Overriden so we notify our Controller when we've been broken out */
event Trigger(Actor Other, Pawn EventInstigator) {
    if (LabMonkeyController(Controller) != none)
        LabMonkeyController(Controller).NotifyLockBreak();
}

/** Overriden so we can implement the dropping of a PistolPickup upon death */
function Died(Controller Killer, class<DamageType> DamageType,
              vector HitLocation) {

    DropPistol();

    if (LabMonkeyController != none)
        LabMonkeyController.NotifyPawnDied();
		
	PLBaseGameInfo(Level.Game).MonkeyDied(Self);

    super.Died(Killer, DamageType, HitLocation);
}

defaultproperties
{
	ActorID="LabMonkey"

    bMonkeyLockedUp=true
    bMonkeyAlreadyHasPistol=true

    WalkAnimRate=2
    RunAnimRate=2
    RunNoWeaponAnimRate=3

    PistolBone="Bip01 R Hand"
    PistolStaticMesh=StaticMesh'TP_Weapons.Pistol3'
    PistolEquipSound=sound'WeaponSounds.weapon_select'

    HealthMax=100

    GroundSpeed=450

    WalkSpeed=200
    RunSpeed=450

    DeathAnimRate=1.5

    PistolDamage=18
    PistolMomentum=30000
    PistolTraceDist=10000
    PistolAccuracy=0.7

    PistolFireOffset=(X=30,Z=6)
    PistolFireSound=sound'WeaponSounds.pistol_fire'
    PistolDamageType=class'BulletDamage'
    PistolMuzzleFlashClass=class'LabMonkeyPistolMuzzleFlashEmitter'

    FleshHitSounds(0)=sound'WeaponSounds.bullet_hitflesh1'
	FleshHitSounds(1)=sound'WeaponSounds.bullet_hitflesh2'
	FleshHitSounds(2)=sound'WeaponSounds.bullet_hitflesh3'
	FleshHitSounds(3)=sound'WeaponSounds.bullet_hitflesh4'

	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	PawnHitMarkerMade=class'PawnShotMarker'

	PistolDropVelocity=256
    PistolPickupClass=class'PistolPickup'

    ControllerClass=class'LabMonkeyController'

    bEdShouldSnap=true

    bBlockActors=false
    bBlockPlayers=false

    CollisionHeight=32
    CollisionRadius=16

    Mesh=SkeletalMesh'Animals.meshMonkey'
	AmbientGlow=30
}