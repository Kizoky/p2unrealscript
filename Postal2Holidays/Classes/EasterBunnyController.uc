/**
 * EasterBunnyController
 *
 * AI Controller for the Easter Bunny. It's responsible for coordinating his
 * movement and decision making during the boss fight. Due to the possible
 * uniqueness of each attack, I decided not to keep
 *
 * NOTE: A lot of the code is pretty inefficient in that there's a bit of copy
 * and pasting of code going on and an excessive use of my own multi timer
 * system. This is because this is also me experimenting with me implementing
 * new stuff, so yeah, definitely not the best written code there is.
 */
class EasterBunnyController extends P2EAIController;

/** Struct containing settings for the smoke bomb telelport move */
struct SmokeBombInfo {
    var float MoveTime;
    var float ReuseTime;
    var float UseRange;
};

/** Struct containing settings for the clone summon move */
struct CloneSummonInfo {
    var float MoveTime;
    var float ReuseTime;
    var float CloneDamageCoef;
};

/** Struct containign the settings for the ground attacks */
struct GroundAttackInfo {
    var float PrepTime;
    var float AttackTime;
    var float UseRange;
    var float Damage;
    var float Radius;
    var float FlyVelocity;
    var class<DamageType> DamageType;
};

/** Struct containing all the settings that pertain to the dash attack */
struct DashAttackInfo {
    var float PrepTime;
    var float StartTime;
    var float EndTime;
    var float CancelTime;
    var float UseRange;
    var float Speed;
    var float Range;
    var float Damage;
    var float FlyVelocity;
    var class<DamageType> DamageType;
};

/** Struct containing all the settings for the Dive Kick attack */
struct DiveAttackInfo {
    var float JumpTime;
    var float StartTime;
    var float JumpHeight;
    var float JumpExponent;
    var float WallPushoffTime;
    var float WallPushoffVelocity;
    var float LandingTime;
    var float DiveSpeed;
    var float Damage;
    var float Radius;
    var float FlyVelocity;
    var class<DamageType> DamageType;
};

/** Struct containg all the settings for the Grapple attack */
struct GrappleAttackInfo {
    var float PrepTime;
    var float AttackTime;
    var float FallDownTime;
    var float GetUpTime;
    var float UseRange;
    var float RunSpeed;
    var float FallDownDamage;
    var float PunchDamage;
    var float UppercutDamage;
    var float FlyVelocity;
    var int PunchViewPitch;
    var int PunchViewYaw;
    var class<DamageType> PunchDamageType;
    var class<DamageType> UppercutDamageType;
};

/** Struct containing all the settings for the Finisher Attack */
struct FinisherAttackInfo {
    var float PrepTime;
    var float UppercutTime;
    var float JumpTime;
    var float FlurryPunchTime;
    var float DownPunchTime;
    var float LandingTime;
    var float FallDownTime;
    var float GetUpTime;
    var float RunSpeed;
    var float UppercutHeight;
    var float FallDownDamage;
    var float UppercutDamage;
    var float FlurryPunchDamage;
    var float DownPunchDamage;
    var float FlyVelocity;
    var vector FlyDir;
    var int FlurryViewPitch;
    var int FlurryViewYaw;
    var class<DamageType> UppercutDamageType;
    var class<DamageType> FlurryPunchDamageType;
    var class<DamageType> DownPunchDamageType;
};

/** The kind of items that will be dropped and awarded to the player */
struct KnockoutItem {
    var int ItemDropCount;
    var class<Pickup> ItemPickup;
};

var bool bUseAdvancedAttacks;
var bool bUseSuperAttacks;
var bool bUseFinisherAttack;

var bool bAttacking;
var bool bAttackConnected;

var float AdvancedAttacksHealthPct;
var float SuperAttacksHealthPct;
var float FinisherAttackHealthPct;

var float IdleThinkDelay;
var float MoveThinkInterval;

var float MoveReachedRange;

//-----------------------------------------------------------------------------
// Entrance Variables

var AnimInfo EntranceAnim;

var sound EntranceDialog;

var PathNode EntranceNode;

//-----------------------------------------------------------------------------
// Smoke Bomb Telelport Variables

var bool bCanUseSmokeBomb;

var float SmokeBombMinDistance;

var float SmokeBombBlendTime;

var SmokeBombInfo SmokeBombTeleport;

var AnimInfo SmokeBombAnim;

var name SmokeBombBone;
var vector SmokeBombOffset;
var StaticMesh SmokeBombStaticMesh;

var BoltonPart SmokeBombBoltOn;

var class<Emitter> SmokeBombEmitter;

//-----------------------------------------------------------------------------
// Clone Summoning Variables

var bool bIsClone;
var bool bCanUseCloneSummon;

var int CloneCount;

var vector CloneSummonOffsets[3];
var CloneSummonInfo CloneSummon;

var float CloneSummonBlendTime;

var AnimInfo CloneSummonAnim;

//-----------------------------------------------------------------------------
// Ground Attack Variables

var bool bGroundAttack;

var int GroundAttackAnim;

var GroundAttackInfo GroundAttacks[2];

var float GroundAttackBlendTime;

var AnimInfo GroundAttackPrepAnims[2];
var AnimInfo GroundAttackAnims[2];

var sound GroundSwooshSound;
var sound GroundImpactSound;

var vector GroundEmitterOffset;

var class<Emitter> GroundRockEmitter;
var class<Emitter> GroundExplosionEmitter;

//-----------------------------------------------------------------------------
// Dash Attack Variables

var bool bDashAttack;

var int DashAttackAnim;

var float DashAttackUpdateInterval;

var float DashCollisionCheckDist;
var array<vector> DashCollisionChecks;

var DashAttackInfo DashAttacks[2];

var float DashAttackBlendTime;

var AnimInfo DashAttackPrepAnims[2];
var AnimInfo DashAttackStartAnims[2];
var AnimInfo DashAttackCancelAnims[2];
var AnimInfo DashAttackLoopAnims[2];
var AnimInfo DashAttackEndAnims[2];

var sound DashStartSound;
var sound DashAmbientSound;
var sound DashHitSound;

var float DashFireEmitterBurnTime;
var float DashFireEmitterPerDistance;
var vector DashFireEmitterOffset;
var class<Emitter> DashSmokeEmitter;
var class<FireEmitter> DashFireEmitter;

//-----------------------------------------------------------------------------
// Dive Kick Attack Variables

var bool bDiveKickAttack;
var bool bDiveKickWallHit;

var float DiveKickUpdateInterval;

var float DiveKickCollisionCheckDist;
var array<vector> DiveKickCollisionChecks;

var DiveAttackInfo DiveKickAttacks[2];

var float DiveKickBlendTime;
var float DiveKickJumpAnimPct;
var float DiveKickLandingAnimDelay;

var AnimInfo DiveKickJumpAnim;
var AnimInfo DiveKickStartAnim;
var AnimInfo DiveKickLoopAnim;
var AnimInfo DiveKickWallHitAnim;
var AnimInfo DiveKickFallAnim;
var AnimInfo DiveKickLandingAnim;

var sound DiveKickJumpSound;
var sound DiveKickStartSound;
var sound DiveKickAmbientSound;
var sound DiveKickHitSound;
var sound DiveKickWallHitSound;
var sound DiveKickLandingSound;

var vector DiveKickLandEmitterOffset;
var class<Emitter> DiveKickLandEmitter;

//-----------------------------------------------------------------------------
// Grapple Attack Variables

var bool bGrappleAttack;
var bool bCanUseGrappleAttack;

var float GrappleUpdateInterval;

var float GrappleReuseTime;
var float GrappleFallDownSpeedCoef;

var GrappleAttackInfo GrappleAttacks[2];

var float GrappleBlendTime;

var float GrappleLiftPct;
var vector GrappleLiftStartOffset;
var vector GrappleLiftDestOffset;

var AnimInfo GrapplePrepAnim;
var AnimInfo GrappleRunAnim;
var AnimInfo GrappleAttackAnim;
var AnimInfo GrappleFallAnim;
var AnimInfo GrappleGetUpAnim;

var sound GrappleSwooshSound;
var sound GrappleHitSound;

//-----------------------------------------------------------------------------
// Finisher Attack Variables

var bool bFinisherAttack;
var bool bCanUseFinisherAttack;

var float FinisherUpdateInterval;

var float FinisherReuseTime;

var FinisherAttackInfo FinisherAttack;

var float FinisherBlendTime;

var float FinisherUppercutPct;
var vector FinisherUppercutStartOffset;

var AnimInfo FinisherPrepAnim;
var AnimInfo FinisherRunAnim;
var AnimInfo FinisherUppercutAnim;
var AnimInfo FinisherJumpAnim;
var AnimInfo FinisherFlurryPunchAnim;
var AnimInfo FinisherDownPunchAnim;

var sound FinisherJumpSound;
var sound FinisherSwooshSound;
var sound FinisherHitSound;

//-----------------------------------------------------------------------------
// Knockout Variables

var float KnockoutTime;
var float KnockoutSpeed;

var AnimInfo KnockoutAnim;
var AnimInfo KnockoutLoopAnim;

var sound KnockoutSound;
var array<sound> KnockoutFartSounds;

var float KnockoutItemDropVelocity;
var float KnockoutItemDropRange;
var array<KnockoutItem> KnockoutItemDrops;

//-----------------------------------------------------------------------------
// Postal Dude Humiliation Variables

var float HumiliationWalkSpeed;
var float HumiliationTime;
var float HumiliationUpdateInterval;

var float HumiliationBlendTime;

var AnimInfo HumiliationPrepAnim;
var AnimInfo HumiliationAnim;
var array<AnimInfo> HumiliationDanceAnims;

var sound HumiliationSound;

//-----------------------------------------------------------------------------
// Dialog Variables

var float AttackCancelDialogChance;
var array<sound> AttackCancelSounds;

var float DashHitDialogChance;
var sound DashHitDialogSound;

var float DiveDialogChance;
var sound DiveDialogSound;

var float GrappleGrabDialogChance;
var sound GrappleGrabDialogSound;

var float GrappleUppercutDialogChance;
var sound GrappleUppercutDialogSound;

var bool bPlayHitSound;
var float HitSoundInterval;
var array<sound> HitSounds;

var float TauntSoundInterval;
var array<sound> TauntSounds;

var sound DeathSound;

//-----------------------------------------------------------------------------
// Music Variables

var int FightSongHandle;

var float FightSongFadeInTime;
var float FightSongFadeOutTime;

var string FightSongName;

//-----------------------------------------------------------------------------
// Level Variables

var name FightStartEvent;


//-----------------------------------------------------------------------------
// General Behavior Variables

var P2MoCapPawn PostalDude;
var EasterBunny EasterBunny;

var EasterBunnyController Original;

var float DashSpeed;
var vector DashDest;
var vector DashDir;

var float DiveKickSpeed;
var vector DiveKickDir;

var float GrappleDamageTaken;
var bool bGrappleInterp;
var float GrappleElapsedTime;
var float GrappleFinishTime;
var vector GrappleLiftStart;
var vector GrappleLiftEnd;

var float FinisherDamageTaken;
var bool bFinisherInterp;
var float FinisherElapsedTime;
var float FinisherFinishTime;
var vector FinisherUppercutStart;
var vector FinisherUppercutEnd;

var vector HumiliationDir;
var vector HumiliationDest;

/** Animation channels we may use */
const RESTINGPOSECHANNEL	= 0;
const FALLINGCHANNEL		= 1;

const MOVEMENT_FORWARD      = 4;
const MOVEMENT_BACKWARD     = 5;
const MOVEMENT_LEFT         = 6;
const MOVEMENT_RIGHT        = 7;

// Only use these two if bPhysicsAnimUpdate is off.
const RIGHTTURNCHANNEL_NO_PHYSICS	= 2;
const LEFTTURNCHANNEL_NO_PHYSICS	= 3;

const TAKEHITCHANNEL		= 12;
const WEAPONCHANNEL			= 13;
const HEADCHANNEL			= 14;
const EXCHANGEITEMCHANNEL	= 15;

const MOVE_BUFFER = 100;

/** Returns whether or not the current position, if we jump, will be clear
 * @return TRUE if at our jump position, we have a line of sight
 */
function bool IsDiveAttackClear() {
    local int i;
    local float TraceLength;
    local vector AirLocation, TraceDir;
    local vector EndTrace, StartTrace;

    AirLocation = Pawn.Location;
    AirLocation.Z += GetDiveKickJumpHeight();

    TraceDir = GetDiveKickDest() - AirLocation;
    TraceLength = VSize(TraceDir);

    for (i=0;i<DiveKickCollisionChecks.length;i++) {
        StartTrace = AirLocation +
                     class'P2EMath'.static.GetOffset(rotator(TraceDir),
                         DiveKickCollisionChecks[i]);
        EndTrace = StartTrace + Normal(TraceDir) * TraceLength;

        if (!FastTrace(EndTrace, StartTrace))
            return false;
    }

    return true;
}

/** Returns whether or not the Postal Dude's head is near the ground
 * @return TRUE if the Postal Dude head is near the ground; FALSE otherwise
 */
function bool IsDudeHeadOnGround() {
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    StartTrace = PostalDude.myHead.Location;
    EndTrace = StartTrace + vect(0,0,-64);
    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

    return (Other != none);
}

/** Returns whether or not the Easter Bunny has reached the Postal Dude
 * @return TRUE if we've reached the Postal Dude; FALSE otherwise
 */
function bool HasReachedPostalDude() {
    return VSize(PostalDude.Location - Pawn.Location) <= MoveReachedRange;
}

/** Returns whether or not the Easter Bunny has reached the Postal Dude's head
 * @return TRUE if we've reached the Postal Dude's head; FALSE otherwise
 */
function bool HasReachedDudesHead() {
    return VSize(HumiliationDest - Pawn.Location) <= MoveReachedRange;
}

/** Returns the optimal Path Node to teleport to during the smoke bomb teleport
 * @return PathNode to teleport to while the smoke bomb goes off
 */
function PathNode GetSmokeBombTeleport() {
    local float TempDist, DistanceToDude;
    local PathNode Temp, TeleportNode;

    DistanceToDude = 8192;

    foreach AllActors(class'PathNode', Temp) {
        if (!IsPawnFacingActor(PostalDude, Temp, 90)) {
            TempDist = VSize(PostalDude.Location - Temp.Location);

            if (TempDist > SmokeBombMinDistance && TempDist < DistanceToDude) {
                DistanceToDude = TempDist;
                TeleportNode = Temp;
            }
        }
    }

    return TeleportNode;
}

/** Returns the best available height we can achieve
 * @return Jump height the Easter Bunny should be able to reach
 */
function float GetDiveKickJumpHeight() {
    local float JumpHeight, HeightDif;
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    if (bUseSuperAttacks)
        JumpHeight = DiveKickAttacks[1].JumpHeight;
    else
        JumpHeight = DiveKickAttacks[0].JumpHeight;

    HeightDif = FMax(PostalDude.Location.Z - Pawn.Location.Z, 0);

    StartTrace = Pawn.Location;
    EndTrace = StartTrace;
    EndTrace.Z += JumpHeight + HeightDif + Pawn.CollisionHeight / 2;

    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

    if (Other != none) {
        HitLocation.Z -= (32 + Pawn.CollisionHeight / 2);
        return VSize(HitLocation - Pawn.Location);
    }
    else
        return JumpHeight + HeightDif;
}

/** Returns the dive kick should target, ideally where the Postal Dude would be
 * standing, if he already is or the ground below him if he's jumping around
 * @return Location in the world the dive kick should target
 */
function vector GetDiveKickDest() {
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    StartTrace = PostalDude.Location;
    EndTrace = StartTrace + vect(0,0,-1024);

    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

    if (Other != none) {
        HitLocation.Z += Pawn.CollisionHeight / 2;
        return HitLocation;
    }
    else
        return PostalDude.Location;
}

/** Returns the best available height we can achieve
 * @return Jump height the Easter Bunny should be able to reach
 */
function float GetFinisherJumpHeight() {
    local float HeightDif;
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    HeightDif = FMax(PostalDude.Location.Z - Pawn.Location.Z, 0);

    StartTrace = Pawn.Location;
    EndTrace = StartTrace;
    EndTrace.Z += FinisherAttack.UppercutHeight + HeightDif +
                  Pawn.CollisionHeight / 2;

    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

    if (Other != none) {
        HitLocation.Z -= (32 + Pawn.CollisionHeight / 2);
        return VSize(HitLocation - Pawn.Location);
    }
    else
        return FinisherAttack.UppercutHeight + HeightDif;
}

/** Returns the location in the world where the Easter Bunny should walk to to
 * take a crap over the Postal Dude's head
 * @return Location in the world where the Easter Bunny should walk to
 */
function vector GetDudeHeadLocation() {
    local vector DudeHeadLoc;

    local vector HitNormal, EndTrace, StartTrace;
    local Actor Other;

    HumiliationDir = Normal(PostalDude.myHead.Location - Pawn.Location);

    StartTrace = PostalDude.myHead.Location + vect(0,0,256);
    EndTrace = StartTrace + vect(0,0,-512);
    Other = Trace(DudeHeadLoc, HitNormal, EndTrace, StartTrace, false);

    if (Other != none) {
        DudeHeadLoc.Z += Pawn.CollisionHeight;
        DudeHeadLoc += HumiliationDir * Pawn.CollisionRadius * 1.5;
        return DudeHeadLoc;
    }

    return vect(0,0,0);
}

/** Returns whether or not current conditions are optimal for a teleport
 * @param OpponentDist - Distance to the Postal Dude
 * @return TRUE if the teleport should be used; FALSE otherwise
 */
function bool ShouldUseSmokeBombTeleport(float OpponentDist) {
    return bUseAdvancedAttacks && bCanUseSmokeBomb &&
           OpponentDist > SmokeBombTeleport.UseRange &&
           GetSmokeBombTeleport() != none;
}

/** Returns whether or not we need to summon more clones of ourself
 * @return TRUE if the teleport should be used; FALSE otherwise
 */
function bool ShouldUseCloneSummon() {
    return bUseAdvancedAttacks && bCanUseCloneSummon && CloneCount == 0;
}

/** Returns whether or not current conditions are optimal for a Ground Attack
 * @param OpponentDist - Distance to the Postal Dude
 * @return TRUE if the ground attack should be used; FALSE otherwise
 */
function bool ShouldUseGroundAttack(float OpponentDist) {
    return (bUseSuperAttacks && OpponentDist < GroundAttacks[1].UseRange) ||
           (OpponentDist < GroundAttacks[0].UseRange);
}

/** Returns whether or not current conditions are optimal for the Dash Attack
 * @param OpponentDist - Distance to the Postal Dude
 * @return TRUE if the dash attack should be used; FALSE otherwise
 */
function bool ShouldUseDashAttack(float OpponentDist) {
    return ((bUseSuperAttacks && OpponentDist > DashAttacks[1].UseRange &&
             OpponentDist < DashAttacks[1].Range) ||
            (OpponentDist > DashAttacks[0].UseRange &&
             OpponentDist < DashAttacks[0].Range)) &&
             PointReachable(PostalDude.Location);
}

/** Returns whether or not we should use our dive kick attack
 * @return TRUE if we should use the dive kick; FALSE otherwise
 */
function bool ShouldUseDiveKickAttack() {
    local bool bOnTopOfSomething, bNextToTheDude;
    local OnTopVolume OnTopVolume;

    bOnTopOfSomething = false;

    foreach AllActors(class'OnTopVolume', OnTopVolume) {
        if (PostalDude.IsInVolume(OnTopVolume)) {
            bOnTopOfSomething = true;
            break;
        }
    }

    bNextToTheDude = Pawn.IsInVolume(OnTopVolume);

    //LogDebug("OnTopVolume: " $ OnTopVolume);
    //LogDebug("bOnTopOfSomething: " $ bOnTopOfSomething);
    //LogDebug("bNextToTheDude: " $ bNextToTheDude);
    //LogDebug("IsDiveAttackClear(): " $ IsDiveAttackClear());
    //LogDebug("");

    // The Postal Dude is on top of a crate or something, and we're not on the
    // crate right next to him
    return bOnTopOfSomething && !bNextToTheDude && IsDiveAttackClear();
}

/** Returns whether or not the grapple attack should be used
 * @param OpponentDist - Distance to the Postal Dude
 * @return TRUE if the grapple attack should be used; FALSE otherwise
 */
function bool ShouldUseGrappleAttack(float OpponentDist) {
    return ((bUseSuperAttacks && OpponentDist > GrappleAttacks[1].UseRange) ||
           (OpponentDist > GrappleAttacks[0].UseRange)) &&
            bCanUseGrappleAttack && bUseAdvancedAttacks;
}

/** Returns whether or not the almighty finisher attack should be used
 * @return TRUE if we should finish off the Postal Dude; FALSE otherwise
 */
function bool ShouldUseFinisherAttack() {
    return bUseFinisherAttack && bCanUseFinisherAttack;
}

/** Renables the forward, backward, and strafing movement animation channels */
function EnableMovementChannels() {
    Pawn.AnimBlendParams(MOVEMENT_FORWARD, 1, 0);
    Pawn.AnimBlendParams(MOVEMENT_BACKWARD, 1, 0);
    Pawn.AnimBlendParams(MOVEMENT_LEFT, 1, 0);
    Pawn.AnimBlendParams(MOVEMENT_RIGHT, 1, 0);
}

/** Disables the forward, backward, and strafing movement animation channels */
function DisableMovementChannels() {
    Pawn.AnimBlendParams(MOVEMENT_FORWARD, 0, 0);
    Pawn.AnimBlendParams(MOVEMENT_BACKWARD, 0, 0);
    Pawn.AnimBlendParams(MOVEMENT_LEFT, 0, 0);
    Pawn.AnimBlendParams(MOVEMENT_RIGHT, 0, 0);
}

/** Shadow Clone Jutsu! */
function SpawnClones() {
    local int i;
    local vector SpawnLoc;

    local EasterBunny BunnyClone;
    local EasterBunnyController BunnyControllerClone;

    for (i=0;i<3;i++) {
        SpawnLoc = Pawn.Location +
                   class'P2EMath'.static.GetOffset(Pawn.Rotation,
                       CloneSummonOffsets[i]);

        BunnyClone = Spawn(class'EasterBunny',,, SpawnLoc);

        if (BunnyClone != none) {
            BunnyControllerClone = Spawn(class'EasterBunnyController');

            if (BunnyControllerClone != none) {
                BunnyControllerClone.bIsClone = true;
                BunnyControllerClone.Original = self;
                BunnyControllerClone.Possess(BunnyClone);

                BunnyClone.SetPhysics(PHYS_Falling);
                BunnyClone.SetClone();

                if (SmokeBombEmitter != none)
                    Spawn(SmokeBombEmitter,,, SpawnLoc);

                CloneCount++;
            }
        }
    }
}

/** As a clone, we don't go ragdoll, but instead we go poof! */
function ClonePoof() {
    if (SmokeBombEmitter != none)
        Spawn(SmokeBombEmitter,,, Pawn.Location);

    Pawn.Destroy();
    Destroy();
}

/** Destroy all clones either after we have died, or the Postal Dude does */
function PoofAllClones() {
    local EasterBunnyController BunnyController;

    // If we're the original, tell all our clones to go poof!
    foreach DynamicActors(class'EasterBunnyController', BunnyController)
        if (BunnyController.bIsClone)
            BunnyController.ClonePoof();
}

/** Given a Pawn, sends the poor bastard or bitch flying
 * @param Other - Pawn to send flying into the air
 * @param FlyVelocity - The XY velocity and Z velocity to send them flying at
 */
function SendPawnFlying(Pawn Other, float FlyVelocity) {
    local vector OtherLocation, PawnLocation;
    local vector FlyDir;

    // Let's not screw with ragdolls and we should ignore any clones or the
    // original Easter Bunny
    if (Other.Physics == PHYS_KarmaRagDoll ||
        EasterBunny(Other) != none)
        return;

    // Get the fly direction based only on the XY plane, not the Z
    OtherLocation = Other.Location;
    OtherLocation.Z = 0;

    PawnLocation = Pawn.Location;
    PawnLocation.Z = 0;

    FlyDir = Normal(OtherLocation - PawnLocation);

    Other.SetPhysics(PHYS_Falling);
    Other.Velocity = Normal(Other.Location - Pawn.Location) * FlyVelocity;
    Other.Velocity.Z = FlyVelocity;
}

/** Overriden to find the Postal Dude and mark him as our primary target */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    aPawn.SetPhysics(PHYS_Falling);

    if (EasterBunny(aPawn) != none)
        EasterBunny = EasterBunny(aPawn);

    if (EasterBunny != none) {
        EasterBunny.EasterBunnyController = self;
        EasterBunny.SetAnimRunning();
    }
    else
        LogDebug("ERROR: EasterBunny Pawn not found!");

    foreach AllActors(class'PathNode', EntranceNode, EasterBunny.EntrancePathNodeTag)
        if (EntranceNode != none)
            break;

    if (EntranceNode == none)
        LogDebug("ERROR: No Entrance node found!");

    AddTimer(0.5, 'FindPostalDude', false);
    AddTimer(TauntSoundInterval, 'PlayTauntDialog', true);
}

/** Overriden to implement Multi-Timer functionality */
function TimerFinished(name ID) {
    switch (ID) {
        case 'FindPostalDude':
            FindPostalDude();
            break;

        case 'IdleThink':
            IdleThink();
            break;

        case 'MoveThink':
            MoveThink();
            break;

        case 'EntranceUpdate':
            EntranceUpdate();
            break;

        case 'EntranceSpeechFinished':
            EntranceSpeechFinished();
            break;

        case 'SmokeBombFinished':
            SmokeBombFinished();
            break;

        case 'CloneSummonFinished':
            CloneSummonFinished();
            break;

        case 'GroundPrepFinished':
            GroundPrepFinished();
            break;

        case'GroundAttackFinished':
            GroundAttackFinished();
            break;

        case 'DashPrepFinished':
            DashPrepFinished();
            break;

        case 'DashStartFinished':
            DashStartFinished();
            break;

        case 'DashAttackUpdate':
            DashAttackUpdate();
            break;

        case 'DashEndFinished':
            DashEndFinished();
            break;

        case 'DashCancelFinished':
            DashCancelFinished();
            break;

        case 'DiveKickJumpInterp':
            DiveKickJumpInterp();
            break;

        case 'DiveKickJumpFinished':
            DiveKickJumpFinished();
            break;

        case 'DiveKickStartFinished':
            DiveKickStartFinished();
            break;

        case 'DiveKickUpdate':
            DiveKickUpdate();
            break;

        case 'DiveKickLandingFinished':
            DiveKickLandingFinished();
            break;

        case 'GrappleAttackPrepFinished':
            GrappleAttackPrepFinished();
            break;

        case 'GrappleUpdate':
            GrappleUpdate();
            break;

        case 'GrappleAttackFinished':
            GrappleAttackFinished();
            break;

        case 'GrappleFallDownFinished':
            GrappleFallDownFinished();
            break;

        case 'GrappleGetUpFinished':
            GrappleGetUpFinished();
            break;

        case 'FinisherPrepFinished':
            FinisherPrepFinished();
            break;

        case 'FinisherUpdate':
            FinisherUpdate();
            break;

        case 'FinisherUppercutFinished':
            FinisherUppercutFinished();
            break;

        case 'FinisherJumpFinished':
            FinisherJumpFinished();
            break;

        case 'FinisherFlurryFinished':
            FinisherFlurryFinished();
            break;

        case 'FinisherDownPunchFinished':
            FinisherDownPunchFinished();
            break;

        case 'FinisherFallDownFinished':
            FinisherFallDownFinished();
            break;

        case 'FinisherGetUpFinished':
            FinisherGetUpFinished();
            break;

        case 'HumiliationPrepFinished':
            HumiliationPrepFinished();
            break;

        case 'HumiliationUpdate':
            HumiliationUpdate();
            break;

        case 'HumiliationFinished':
            HumiliationFinished();
            break;

        case 'HumiliationDanceFinished':
            HumiliationDanceFinished();
            break;

        case 'PlayDiveKickLandingAnim':
            PlayDiveKickLandingAnim();
            break;

        case 'PlayHumiliationDance':
            PlayHumiliationDance();
            break;

        case 'PlayTauntDialog':
            PlayTauntDialog();
            break;

        case 'EnableSmokeBomb':
            EnableSmokeBomb();
            break;

        case 'EnableCloneSummon':
            EnableCloneSummon();
            break;

        case 'EnableGrapple':
            EnableGrapple();
            break;

        case 'EnableFinisher':
            EnableFinisher();
            break;

        case 'EnableHitSound':
            EnableHitSound();
            break;

        case 'InterpolatePostalDude':
            InterpolatePostalDude();
            break;

        case 'SpawnDashTrailEmitter':
            SpawnDashTrailEmitter();
            break;
    }
}

/** Overriden to get notifications when the interpolation has finished */
function InterpolationFinished() {
   // STUB
}

/** Iterates through the Pawns in the world until we find the player controlled
 * one or the Postal Dude
 */
function FindPostalDude() {
    foreach DynamicActors(class'P2MoCapPawn', PostalDude)
        if (AWDude(PostalDude) != none)
            break;

    if (PostalDude != none)
        GotoState('MoveTowardEntranceNode');
    else
        LogDebug("ERROR: Couldn't find the Postal Dude");

    if (!bIsClone && FightSongName != "") {
        FightSongHandle = FPSGameInfo(Level.Game).PlayMusicExt(FightSongName, FightSongFadeInTime);
        LogDebug("Play that kickass song!");
    }
}

function IdleThink() {
    local float PostalDudeDistance;

    PostalDudeDistance = VSize(PostalDude.Location - Pawn.Location);

    // If we're a clone of the original, then we can only perform basic ground
    // and dash attacks, just to annoy the piss out of the Dude
    if (bIsClone) {
        if (ShouldUseGroundAttack(PostalDudeDistance)) {
            GotoState('GroundAttackPrep');
            return;
        }

        if (ShouldUseDashAttack(PostalDudeDistance)) {
            GotoState('DashAttackPrep');
            return;
        }

        // If none of our moves should be used, move closer to the Postal Dude
        // but only if we're currently not attacking right now
        if (!bAttacking)
            GotoState('MoveTowardPlayer');

        return;
    }

    // Canceling the players attempt at slowing down time via Catnip is our
    // utmost priority, as slow motion makes things waaay too easy
    if (Level.TimeDilation < 1) {
        GotoState('GroundAttackPrep');
        return;
    }

    // Damn, Postal Dude has brung too much heat, time to finish this!
    if (ShouldUseFinisherAttack()) {
        GotoState('FinisherAttackPrep');
        return;
    }

    // Since this is a flanking type of attack, we should use this before we
    // use other advanced attacks so close the distance more effectively
    if (ShouldUseSmokeBombTeleport(PostalDudeDistance)) {
        GotoState('SmokeBombMove');
        return;
    }

    // We want to use the clone summon move right after a smoke bomb teleport,
    // this way all of our clones are near the Postal Dude
    if (ShouldUseCloneSummon()) {
        GotoState('CloneSummonMove');
        return;
    }

    // More advanced attacks should have a higher priority, if we can use them
    if (ShouldUseGrappleAttack(PostalDudeDistance)) {
        GotoState('GrappleAttackPrep');
        return;
    }

    // If the Postal Dude is on top of a crate or something attempting to hide
    // then we should jump into the air and dive kick him
    if (ShouldUseDiveKickAttack()) {
        GotoState('DiveKickJump');
        return;
    }

    // If we're really close to the player, do a close range ground attack
    if (ShouldUseGroundAttack(PostalDudeDistance)) {
        GotoState('GroundAttackPrep');
        return;
    }

    // If we're too far to use close range attacks, but not so far that we can
    // close in on the Postal Dude using a Dash Attack
    if (ShouldUseDashAttack(PostalDudeDistance)) {
        GotoState('DashAttackPrep');
        return;
    }

    // If none of our moves should be used, move closer to the Postal Dude
    // but only if we're currently not attacking right now
    if (!bAttacking)
        GotoState('MoveTowardPlayer');
}

/** While we're moving toward the Postal Dude, check which attacks we can
 * can use depending on our situation
 */
function MoveThink() {
    local float PostalDudeDistance;

    PostalDudeDistance = VSize(PostalDude.Location - Pawn.Location);

    // If we're a clone of the original, then we can only perform basic ground
    // and dash attacks, just to annoy the piss out of the Dude
    if (bIsClone) {
        if (ShouldUseGroundAttack(PostalDudeDistance)) {
            GotoState('GroundAttackPrep');
            return;
        }

        if (ShouldUseDashAttack(PostalDudeDistance)) {
            GotoState('DashAttackPrep');
            return;
        }

        return;
    }

    // Canceling the players attempt at slowing down time via Catnip is our
    // utmost priority, as slow motion makes things waaay too easy
    if (Level.TimeDilation < 1) {
        GotoState('GroundAttackPrep');
        return;
    }

    // Damn, Postal Dude has brung too much heat, time to finish this!
    if (ShouldUseFinisherAttack()) {
        GotoState('FinisherAttackPrep');
        return;
    }

    // Since this is a flanking type of attack, we should use this before we
    // use other advanced attacks so close the distance more effectively
    if (ShouldUseSmokeBombTeleport(PostalDudeDistance)) {
        GotoState('SmokeBombMove');
        return;
    }

    // We want to use the clone summon move right after a smoke bomb teleport,
    // this way all of our clones are near the Postal Dude
    if (ShouldUseCloneSummon()) {
        GotoState('CloneSummonMove');
        return;
    }

    // More advanced attacks should have a higher priority, if we can use them
    if (ShouldUseGrappleAttack(PostalDudeDistance)) {
        GotoState('GrappleAttackPrep');
        return;
    }

    // If the Postal Dude is on top of a crate or something attempting to hide
    // then we should jump into the air and dive kick him
    if (ShouldUseDiveKickAttack()) {
        GotoState('DiveKickJump');
        return;
    }

    // If we're really close to the player, do a close range ground attack
    if (ShouldUseGroundAttack(PostalDudeDistance)) {
        GotoState('GroundAttackPrep');
        return;
    }

    // If we're too far to use close range attacks, but not so far that we can
    // close in on the Postal Dude using a Dash Attack
    if (ShouldUseDashAttack(PostalDudeDistance)) {
        GotoState('DashAttackPrep');
        return;
    }
}

/** Update for when we've reached the Entrance node */
function EntranceUpdate() {
    if (VSize(EntranceNode.Location - Pawn.Location) < 32)
        GotoState('EntranceSpeech');
}

/** We've finished our little spiel, so now let's get the Dude */
function EntranceSpeechFinished() {
    GotoState('Idle');
}

/** We've finished teleporting, no return to idle to think of something nasty
 * to do to the Postal Dude
 */
function SmokeBombFinished() {
    GotoState('Idle');
}

/** We've finished summoning out clones, now let's decide out next move */
function CloneSummonFinished() {
    GotoState('Idle');
}

/** We've finished winding up our ground attack */
function GroundPrepFinished() {
    GotoState('GroundAttack');
}

/** Finished playing our ground attack animation */
function GroundAttackFinished() {
    GotoState('Idle');
}

/** Function prototypes to be implemented in the states */
function DashPrepFinished() {
    local float StartTime;

    if (bUseSuperAttacks)
        StartTime = DashAttacks[1].StartTime;
    else
        StartTime = DashAttacks[0].StartTime;

    AddTimer(StartTime, 'DashStartFinished', false);
    PlayAnimByDuration(DashAttackStartAnims[DashAttackAnim],
                       StartTime, DashAttackBlendTime);
}

/** We've unwound our fists, so let's start the attack */
function DashStartFinished() {
    GotoState('DashAttack');
}

/** Check if we hit anything in front of me */
function DashAttackUpdate() {
    local int i;
    local vector EndTrace, StartTrace;

    // Temporary animation hack, permanent if I'm lazy
    PlayAnimInfo(DashAttackLoopAnims[DashAttackAnim], DashAttackBlendTime);

    // Stop the attack if we've dash right past the Dude
    if (!IsLocationInFacingAngle(PostalDude.Location, 180))
        GotoState('DashAttackEnd');

    // Stop the attack if we've dash attack right past our maximum range
    if (!IsLocationInFacingAngle(DashDest, 180))
        GotoState('DashAttackEnd');

    // Stop the dash attack if we've ran into something solid, such as
    // world geometry
    for (i=0;i<DashCollisionChecks.length;i++) {
        StartTrace = Pawn.Location +
                     class'P2EMath'.static.GetOffset(Pawn.Rotation,
                         DashCollisionChecks[i]);
        EndTrace = StartTrace + vector(Pawn.Rotation) * DashCollisionCheckDist;

        if (!FastTrace(EndTrace, StartTrace))
            GotoState('DashAttackEnd');
    }
}

/** We've finished playing our attack end animation, so let's go back to idle */
function DashEndFinished() {
    GotoState('Idle');
}

/** We've finished playing our cancel animation, so let's go back to idle */
function DashCancelFinished() {
    GotoState('Idle');
}

/** Perform the interpolation in sync with the animation */
function DiveKickJumpInterp() {
    local float JumpTime, JumpExponent;
    local vector JumpDest;

    if (bUseSuperAttacks) {
        JumpTime = DiveKickAttacks[1].JumpTime;
        JumpExponent = DiveKickAttacks[1].JumpExponent;
    }
    else {
        JumpTime = DiveKickAttacks[0].JumpTime;
        JumpExponent = DiveKickAttacks[0].JumpExponent;
    }

    JumpTime = JumpTime - (JumpTime * DiveKickJumpAnimPct);

    JumpDest = Pawn.Location;
    JumpDest.Z += GetDiveKickJumpHeight();

    InterpolateByDuration(JumpTime, JumpDest, INTERP_Linear, JumpExponent);

    if (DiveKickLandEmitter != none)
        Spawn(DiveKickLandEmitter,,, Pawn.Location + DiveKickLandEmitterOffset);
}

/** We've reached the height of our jump */
function DiveKickJumpFinished() {
    local float StartTime;

    Focus = PostalDude;
    Pawn.SetRotation(rotator(PostalDude.Location - Pawn.Location));

    Pawn.SetPhysics(PHYS_Flying);
    StopMoving();

    if (bUseSuperAttacks)
        StartTime = DiveKickAttacks[1].StartTime;
    else
        StartTime = DiveKickAttacks[0].StartTime;

    AddTimer(StartTime, 'DiveKickStartFinished', false);
    PlayAnimByDuration(DiveKickStartAnim, StartTime, DashAttackBlendTime);
}

/** Just finished up playing our start animation, so let's dive forward! */
function DiveKickStartFinished() {
    GotoState('DiveKick');
}

/** Perform a half-assed animation hack as well as wall hit collision checks */
function DiveKickUpdate() {
    local int i;
    local vector EndTrace, StartTrace;

    // Temporary animation hack, permanent if I'm lazy
    PlayAnimInfo(DiveKickLoopAnim, DiveKickBlendTime);

    for (i=0;i<DashCollisionChecks.length;i++) {
        StartTrace = Pawn.Location +
                     class'P2EMath'.static.GetOffset(Pawn.Rotation,
                         DiveKickCollisionChecks[i]);
        EndTrace = StartTrace +
                   vector(Pawn.Rotation) * DiveKickCollisionCheckDist;

        if (!FastTrace(EndTrace, StartTrace)) {
            GotoState('DiveKickWallHit');
        }
    }
}

/** Finished creating our dive kick landing impact explosion */
function DiveKickLandingFinished() {
    GotoState('Idle');
}

/** Finished prepping for a made dash toward the Postal Dude */
function GrappleAttackPrepFinished() {
    GotoState('GrappleAttackRun');
}

/** If the player jumps on top of something, we may need to change attacks */
function GrappleUpdate() {
    // If the Postal Dude is on top of a crate or something attempting to hide
    // then we should jump into the air and dive kick him
    if (ShouldUseDiveKickAttack())
        GotoState('DiveKickJump');
}

/** We've finished playing our grapple attack animation, go back to idle */
function GrappleAttackFinished() {
    GotoState('Idle');
}

/** Now that we've fallen down, play a getup animation */
function GrappleFallDownFinished() {
    GotoState('GrappleGetUp');
}

/** Now that we've gotten back up, go back to idle and decide what to do next */
function GrappleGetUpFinished() {
    GotoState('Idle');
}

/** We've finished prepping our finisher attack, so now */
function FinisherPrepFinished() {
    GotoState('FinisherRun');
}

/** If the player jumps on top of something, we may need to change attacks */
function FinisherUpdate() {
    // If the Postal Dude is on top of a crate or something attempting to hide
    // then we should jump into the air and dive kick him
    if (ShouldUseDiveKickAttack())
        GotoState('DiveKickJump');
}

/** We've finished performing our uppercut, so now let's jump into the air */
function FinisherUppercutFinished() {
    GotoState('FinisherJump');
}

/** Finished jumping, now for the fun part! */
function FinisherJumpFinished() {
    GotoState('FinisherAttacks');
}

/** We've finished our flurry attack, now let's smack him back down */
function FinisherFlurryFinished() {
    AddTimer(FinisherAttack.DownPunchTime, 'FinisherDownPunchFinished',
        false);

    PlayAnimByDuration(FinisherDownPunchAnim, FinisherAttack.DownPunchTime,
        FinisherBlendTime);
}

/** We've finished our attack, now we fall back down to Earth */
function FinisherDownPunchFinished() {
    GotoState('FinisherFall');
}

/** We've finished falling down, now let's get right back up */
function FinisherFallDownFinished() {
    GotoState('FinisherGetUp');
}

/** Now that we're right back up, go back to idle to decide what to do next */
function FinisherGetUpFinished() {
    GotoState('Idle');
}

/** Just finished rubbing our crotch, now let's get ready for the steamer! */
function HumiliationPrepFinished() {
    if (IsDudeHeadOnGround()) {
        HumiliationDest = GetDudeHeadLocation();

        if (HumiliationDest != vect(0,0,0)) {
            GotoState('MoveTowardPlayersHead');
            return;
        }
    }

    // If we can't crap on his head, just dance on his corpse
    GotoState('HumiliationDance');
}

/** Constantly check to see when we've arrived of the Postal Dude's head */
function HumiliationUpdate() {
    if (HasReachedDudesHead())
        GotoState('HumiliatePostalDude');
}

/** Now let's dance our ass off after defeating the scourge of Paradise! */
function HumiliationFinished() {
    GotoState('HumiliationDance');
}

/** We've finished out dance, so now let's dance again! */
function HumiliationDanceFinished() {
    PlayHumiliationDance();
}

/** Play the animation after a short delay
 * NOTE: The Time delay is a temporary animation hack, permanent if I'm lazy
 * Psst... 99% chance it's permanent
 */
function PlayDiveKickLandingAnim() {
    local float LandingTime;

    if (bUseSuperAttacks)
        LandingTime = DiveKickAttacks[1].LandingTime;
    else
        LandingTime = DiveKickAttacks[0].LandingTime;

    PlayAnimByDuration(DiveKickLandingAnim,
        LandingTime - DiveKickLandingAnimDelay, DiveKickBlendTime);
}

/** Dance on top of the Postal Dude's corpse cause the player sucks */
function PlayHumiliationDance() {
    local int i;

    i = Rand(HumiliationDanceAnims.length);

    AddTimer(HumiliationDanceAnims[i].AnimTime, 'HumiliationDanceFinished',
        false);

    PlayAnimInfo(HumiliationDanceAnims[i], HumiliationBlendTime);
}

/** Renable the use of the smoke bomb after a period of time */
function EnableSmokeBomb() {
    bCanUseSmokeBomb = true;
    LogDebug("Smoke Bomb ability has been renabled");
}

/** Renable the use of the clone summon move */
function EnableCloneSummon() {
    bCanUseCloneSummon = true;
    LogDebug("Clone Summon ability has been renabled");
}

/** Renable the use of the Grapple attack after a certain time has passed */
function EnableGrapple() {
    bCanUseGrappleAttack = true;
    LogDebug("Grapple Attack has been renabled");
}

/** Renable the use of the Finisher attack after a certain time has passed */
function EnableFinisher() {
    bCanUseFinisherAttack = true;
    LogDebug("Finisher Attack has been renabled");
}

/** Renable the ability to say ouch! */
function EnableHitSound() {
    bPlayHitSound = true;
}

/** Interpolate the Postal Dude into the air as a result of the uppercut */
function InterpolatePostalDude() {
    local float UppercutTime;
    local vector UppercutHeight;

    UppercutTime = FinisherAttack.UppercutTime;
    UppercutHeight.Z = GetFinisherJumpHeight();

    FinisherElapsedTime = 0;

    FinisherFinishTime = UppercutTime - (UppercutTime * FinisherUppercutPct) +
                         FinisherAttack.JumpTime;

    FinisherUppercutStart = Pawn.Location +
                            class'P2EMath'.static.GetOffset(Pawn.Rotation,
                                FinisherUppercutStartOffset);

    FinisherUppercutEnd = FinisherUppercutStart + UppercutHeight;

    bFinisherInterp = true;

    PostalDude.SetPhysics(PHYS_Flying);

    PostalDude.TakeDamage(FinisherAttack.UppercutDamage, Pawn,
        PostalDude.Location, vect(0,0,0), FinisherAttack.UppercutDamageType);

    if (FinisherHitSound != none)
        PostalDude.PlaySound(FinisherHitSound, SLOT_Pain, 1, false, 300);
}

/** Spawn a FireEmitter while performing our super dash attack */
function SpawnDashTrailEmitter() {
    local FireEmitter DashFire;

    if (bUseSuperAttacks && DashFireEmitter != none) {
        DashFire = Spawn(DashFireEmitter,,,
            Pawn.Location + DashFireEmitterOffset);

        if (DashFire != none) {
            DashFire.GotoState('Burning');
            DashFire.Lifespan = DashFireEmitterBurnTime;
            DashFire.SetTimer(DashFireEmitterBurnTime -
                (DashFire.FadeTime + DashFire.WaitAfterFadeTime),
                 false);
        }
    }
    else if (DashSmokeEmitter != none)
        Spawn(DashSmokeEmitter,,, Pawn.Location + DashFireEmitterOffset);
}

/** Give the Postal Dude a quick speech on why he sucks */
function PlayEntranceSpeechDialog() {
    if (EntranceDialog != none)
        Pawn.PlaySound(EntranceDialog, SLOT_Talk, 1, false, 300);
}

/** Play an attack cancel dialog after being shot enough he fell down */
function PlayAttackCancelDialog() {
    local int i;

    if (FRand() < AttackCancelDialogChance) {
        i = Rand(AttackCancelSounds.length);

        if (AttackCancelSounds[i] != none) {
            Pawn.PlaySound(AttackCancelSounds[i], SLOT_Talk, 1, false, 300);

            DisableHitDialog(GetSoundDuration(AttackCancelSounds[i]));
        }
    }
}

/** Play a taunt for when we hit the Postal Dude with a Dash Attack */
function PlayDashHitDialog() {
    if (FRand() < DashHitDialogChance && DashHitDialogSound != none) {
        Pawn.PlaySound(DashHitDialogSound, SLOT_Talk, 1, false, 300);
        DisableHitDialog(GetSoundDuration(DashHitDialogSound));
    }
}

/** Play a taunt for when we hit the Postal Dude with */
function PlayDiveDialog() {
    if (FRand() < DiveDialogChance && DiveDialogSound != none) {
        Pawn.PlaySound(DiveDialogSound, SLOT_Talk, 1, false, 300);
        DisableHitDialog(GetSoundDuration(DiveDialogSound));
    }
}

/** Play a taunt for when we grabbed the Postal Dude by his neck */
function PlayGrappleGrabDialog() {
    if (FRand() < GrappleGrabDialogChance && GrappleGrabDialogSound != none) {
        Pawn.PlaySound(GrappleGrabDialogSound, SLOT_Talk, 1, false, 300);
        DisableHitDialog(GetSoundDuration(GrappleGrabDialogSound));
    }
}

/** Play a taunt to go along with the final uppercut punch */
function PlayGrappleUppercutDialog() {
    if (FRand() < GrappleUppercutDialogChance &&
        GrappleUppercutDialogSound != none) {
        Pawn.PlaySound(GrappleUppercutDialogSound, SLOT_Talk, 1, false, 300);

        DisableHitDialog(GetSoundDuration(GrappleUppercutDialogSound));
    }
}

/** Play a pain grunt sound whenever we're shot every once in a while */
function PlayHitDialog() {
    local int i;

    i = Rand(HitSounds.length);

    if (bPlayHitSound && (IsInState('Idle') || IsInState('MoveTowardPlayer')) &&
        HitSounds[i] != none) {
        Pawn.PlaySound(HitSounds[i], SLOT_Talk, 1, false, 300);

        DisableHitDialog(HitSoundInterval);
    }
}

/** Disables the hit sound for a specified period of time
 * @param HitDialogDelay - Time in seconds before the hit dialog are renabled
 */
function DisableHitDialog(float HitDialogDelay) {
    bPlayHitSound = false;
    AddTimer(HitDialogDelay, 'EnableHitSound', false);
}

/** Play general taunt dialog that can go with any situation */
function PlayTauntDialog() {
    local int i;

    i = Rand(TauntSounds.length);

    if (TauntSounds[i] != none) {
        Pawn.PlaySound(TauntSounds[i], SLOT_Talk, 1, false, 300);
        DisableHitDialog(GetSoundDuration(TauntSounds[i]));
    }
}

/** Might need this in the future */
event bool NotifyLanded(vector HitNormal) {
    LogDebug("NotifyLanded method called...");

    if (IsInState('DiveKick') || IsInState('DiveKickWallHit') ||
        IsInState('FinisherFall'))
        GotoState('DiveKickEnd');

    return true;
}

/** Also might be using this in the future */
event bool NotifyHitWall(vector HitNormal, Actor Wall) {
    //LogDebug("NotifyHitWall method called...");

    /**if (IsInState('DashAttack')) {
        LogDebug("HitWall while in DashAttack");
        GotoState('DashAttackEnd');
    }*/

    return true;
}

/** Overriden to implement bump based attacks */
event bool NotifyBump(Actor Other) {
    local float AttackDamage, AttackFlyVelocity;
    local class<DamageType> AttackDamageType;

    //LogDebug("Bump: " $ Other);

    // Unless it's a combo attack, only hit once per contact attack
    if (bAttackConnected) return true;

    // We should ignore dealing damage to other Easter Bunnys, whether it's
    // a clone or the original
    if (bDashAttack && Pawn(Other) != none && EasterBunny(Other) == none) {
        if (bUseSuperAttacks) {
            AttackDamage = DashAttacks[1].Damage;
            AttackFlyVelocity = DashAttacks[1].FlyVelocity;
            AttackDamageType = DashAttacks[1].DamageType;
        }
        else {
            AttackDamage = DashAttacks[0].Damage;
            AttackFlyVelocity = DashAttacks[0].FlyVelocity;
            AttackDamageType = DashAttacks[0].DamageType;
        }

        // Clones do reduced damage, so we don't absolutely obliterate the Dude
        if (bIsClone) AttackDamage *= CloneSummon.CloneDamageCoef;

        SendPawnFlying(Pawn(Other), AttackFlyVelocity);

        Other.TakeDamage(AttackDamage, Pawn, Other.Location,
                         vect(0,0,0), AttackDamageType);

        if (DashHitSound != none)
            Other.PlaySound(DashHitSound, SLOT_Pain, 1, false, 300);

        PlayDashHitDialog();

        // Probably won't have this situation, but only allow the Dude to only
        // take one hit, let everyone else have the crap pummeled out of them
        if (Other == PostalDude)
            bAttackConnected = true;
    }

    if (bDiveKickAttack && Pawn(Other) != none) {
        if (bUseSuperAttacks) {
            AttackDamage = DiveKickAttacks[1].Damage;
            AttackFlyVelocity = DiveKickAttacks[1].FlyVelocity;
            AttackDamageType = DiveKickAttacks[1].DamageType;
        }
        else {
            AttackDamage = DiveKickAttacks[0].Damage;
            AttackFlyVelocity = DiveKickAttacks[0].FlyVelocity;
            AttackDamageType = DiveKickAttacks[0].DamageType;
        }

        SendPawnFlying(Pawn(Other), AttackFlyVelocity);

        Other.TakeDamage(AttackDamage, Pawn, Other.Location,
                         vect(0,0,0), AttackDamageType);

        if (DiveKickHitSound != none)
            Other.PlaySound(DiveKickHitSound, SLOT_Pain, 1, false, 300);

        PlayDiveDialog();

        // Probably won't have this situation, but only allow the Dude to only
        // take one hit, let everyone else have the crap pummeled out of them
        if (Other == PostalDude)
            bAttackConnected = true;
    }

    if (bGrappleAttack && Other == PostalDude) {
        GotoState('GrappleAttack');
        bAttackConnected = true;
    }

    if (bFinisherAttack && Other == PostalDude) {
        GotoState('FinisherUppercut');
        bAttackConnected = true;
    }

    return true;
}

/** Called whenver the Pawn takes damage */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    local float DamageThreshold;

    // Ignore making pain sounds for fire damage
    if (ClassIsChildOf(DamageType, class'BurnedDamage'))
        return;

    // Only the original Easter Bunny can use super attacks
    if (!bUseSuperAttacks && !bIsClone &&
        EasterBunny.Health < EasterBunny.HealthMax * SuperAttacksHealthPct) {
        LogDebug("");
        LogDebug("Super attacks unlocked");
        LogDebug("");

        bUseSuperAttacks = true;
    }

    if (!bUseAdvancedAttacks &&
        EasterBunny.Health < EasterBunny.HealthMax * AdvancedAttacksHealthPct) {
        LogDebug("");
        LogDebug("Advanced attacks unlocked");
        LogDebug("");

        bUseAdvancedAttacks = true;
    }

    if (!bUseFinisherAttack &&
        EasterBunny.Health < EasterBunny.HealthMax * FinisherAttackHealthPct) {
        LogDebug("");
        LogDebug("Finisher attacks unlocked");
        LogDebug("");

        bUseFinisherAttack = true;
    }

    if (bGrappleAttack) {
        GrappleDamageTaken += Damage;

        if (bUseSuperAttacks)
            DamageThreshold = GrappleAttacks[1].FallDownDamage;
        else
            DamageThreshold = GrappleAttacks[0].FallDownDamage;

        if (GrappleDamageTaken >= DamageThreshold)
            GotoState('GrappleFallDown');
    }

    if (bFinisherAttack) {
        FinisherDamageTaken += Damage;

        if (FinisherDamageTaken >= FinisherAttack.FallDownDamage)
            GotoState('FinisherFallDown');
    }

    PlayHitDialog();
}

/** Called from the Pawn whenever the Easter Bunny has died so we can ensure
 * the Postal Dude is in the proper physics mode when the Easter Bunny dies.
 */
function NotifyDied() {
    local int i, j;
    local vector ItemLoc;
    local Pickup ItemPickup;

    if (bIsClone) {
        if (Original != none)
            Original.NotifyCloneDied();

        ClonePoof();
        return;
    }

    PoofAllClones();

    for (i=0;i<KnockoutItemDrops.length;i++) {
        for (j=0;j<KnockoutItemDrops[i].ItemDropCount;j++) {
            ItemLoc = Pawn.Location;
            ItemLoc.X += FRand() * KnockoutItemDropRange - FRand() * KnockoutItemDropRange;
            ItemLoc.Y += FRand() * KnockoutItemDropRange - FRand() * KnockoutItemDropRange;
            ItemLoc.Z += FRand() * KnockoutItemDropRange - FRand() * KnockoutItemDropRange;

            ItemPickup = Spawn(KnockoutItemDrops[i].ItemPickup,,, ItemLoc);

            if (ItemPickup != none) {
                ItemPickup.SetPhysics(PHYS_Falling);

                ItemPickup.Velocity.X = FRand() * KnockoutItemDropVelocity - FRand() * KnockoutItemDropVelocity;
                ItemPickup.Velocity.Y = FRand() * KnockoutItemDropVelocity - FRand() * KnockoutItemDropVelocity;
                ItemPickup.Velocity.Z = FRand() * KnockoutItemDropVelocity;
            }
        }
    }

    if (FightSongHandle != 0)
        FPSGameInfo(Level.Game).StopMusicExt(FightSongHandle,
            FightSongFadeOutTime);

    TriggerEvent(EasterBunny.KnockoutTriggerEvent, self, Pawn);

    if (PostalDude.Physics != PHYS_Walking ||
        PostalDude.Physics != PHYS_Falling)
        PostalDude.SetPhysics(PHYS_Falling);
}

/** Animation notify from our Pawn to perform a Smoke bomb teleport */
function NotifySmokeBombTeleport() {
    local vector TeleportLocation;
    local PathNode TeleportNode;

    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    if (SmokeBombBolton != none)
        SmokeBombBolton.Destroy();

    TeleportNode = GetSmokeBombTeleport();

    if (SmokeBombEmitter != none) {
        Spawn(SmokeBombEmitter,,, Pawn.Location);

        if (TeleportNode != none)
            Spawn(SmokeBombEmitter,,, TeleportNode.Location);
    }

    if (TeleportNode != none) {
        StartTrace = TeleportNode.Location;
        EndTrace = StartTrace + vect(0,0,-1024);
        Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
    }

    if (Other != none) {
        TeleportLocation = HitLocation + Pawn.Collisionheight * HitNormal;
        Pawn.SetLocation(TeleportLocation);
    }
}

/** Animation notify from our Pawn to summon our clones */
function NotifyCloneSummon() {
    SpawnClones();
}

/** Notify from our various clone controllers that it's Pawn died */
function NotifyCloneDied() {
    CloneCount--;
}

/** Animation notify from our Pawn to perform the attack */
function NotifyGroundAttack() {
    local float GroundDamage, GroundRadius, GroundFlyVel;
    local class<DamageType> GroundDamageType;

    local Pawn Victim;

    local vector EmitterLocation;

    EmitterLocation = Pawn.Location +
                      class'P2EMath'.static.GetOffset(Pawn.Rotation,
                          GroundEmitterOffset);

    if (bUseSuperAttacks) {
        GroundDamage = GroundAttacks[1].Damage;
        GroundRadius = GroundAttacks[1].Radius;
        GroundFlyVel = GroundAttacks[1].FlyVelocity;
        GroundDamageType = GroundAttacks[1].DamageType;

        if (GroundExplosionEmitter != none)
            Spawn(GroundExplosionEmitter,,, EmitterLocation);
    }
    else {
        GroundDamage = GroundAttacks[0].Damage;
        GroundRadius = GroundAttacks[0].Radius;
        GroundFlyVel = GroundAttacks[0].FlyVelocity;
        GroundDamageType = GroundAttacks[0].DamageType;

        if (GroundRockEmitter != none)
            Spawn(GroundRockEmitter,,, EmitterLocation);
    }

    if (bIsClone) GroundDamage *= CloneSummon.CloneDamageCoef;

    foreach VisibleCollidingActors(class'Pawn', Victim, GroundRadius, Pawn.Location)
        if (Victim != Pawn)
            SendPawnFlying(Victim, GroundFlyVel);

    Pawn.HurtRadius(GroundDamage, GroundRadius, GroundDamageType,
        0, Pawn.Location);

    if (GroundImpactSound != none)
        Pawn.PlaySound(GroundImpactSound, SLOT_Pain, 1, false, 300);

    if (Level.TimeDilation < 1 && P2Player(PostalDude.Controller) != none) {
        P2Player(PostalDude.Controller).CatnipUseTime = 0.1;
        Spawn(GroundExplosionEmitter,,, EmitterLocation);
    }
}

/** Animation notify from our Pawn to push off from our wall after dive
 * kicking it instead of the Postal Dude
 */
function NotifyWallPushoff() {
    local float WallPushoffVel;

    Pawn.SetPhysics(PHYS_Falling);

    DiveKickDir.Z = 0;

    if (bUseSuperAttacks)
        WallPushoffVel = DiveKickAttacks[1].WallPushoffVelocity;
    else
        WallPushoffVel = DiveKickAttacks[0].WallPushoffVelocity;

    Pawn.Velocity = Normal(DiveKickDir) * -WallPushoffVel;
    Pawn.Velocity.Z = WallPushoffVel;
}

/** Animation notify from our Pawn to deal grapple punch damage */
function NotifyGrapplePunch() {
    local int PunchPitch, PunchYaw;
    local float PunchDamage;
    local rotator PunchRotation;
    local class<DamageType> PunchDamageType;

    if (bUseSuperAttacks) {
        PunchPitch = GrappleAttacks[1].PunchViewPitch;
        PunchYaw = GrappleAttacks[1].PunchViewYaw;

        PunchDamage = GrappleAttacks[1].PunchDamage;
        PunchDamageType = GrappleAttacks[1].PunchDamageType;
    }
    else {
        PunchPitch = GrappleAttacks[0].PunchViewPitch;
        PunchYaw = GrappleAttacks[0].PunchViewYaw;

        PunchDamage = GrappleAttacks[0].PunchDamage;
        PunchDamageType = GrappleAttacks[0].PunchDamageType;
    }

    PostalDude.TakeDamage(PunchDamage, Pawn, PostalDude.Location,
        vect(0,0,0), PunchDamageType);

    if (GrappleHitSound != none)
        PostalDude.PlaySound(GrappleHitSound, SLOT_Pain, 1, false, 300);

    if (PostalDude.Controller != none) {
        PunchRotation = PostalDude.Controller.Rotation;

        PunchRotation.Pitch += Rand(PunchPitch);
        PunchRotation.Yaw += Rand(PunchYaw);
        PunchRotation.Yaw -= Rand(PunchYaw);

        PostalDude.Controller.SetRotation(PunchRotation);
    }
}

/** Animation notify from our Pawn to deal grapple uppercut damage */
function NotifyGrappleUppercut() {
    local float UppercutDamage, UppercutFlyVel;
    local class<DamageType> UppercutDamageType;

    bGrappleInterp = false;

    if (bUseSuperAttacks) {
        UppercutDamage = GrappleAttacks[1].UppercutDamage;
        UppercutFlyVel = GrappleAttacks[1].FlyVelocity;
        UppercutDamageType = GrappleAttacks[1].UppercutDamageType;
    }
    else {
        UppercutDamage = GrappleAttacks[0].UppercutDamage;
        UppercutFlyVel = GrappleAttacks[0].FlyVelocity;
        UppercutDamageType = GrappleAttacks[0].UppercutDamageType;
    }

    SendPawnFlying(PostalDude, UppercutFlyVel);

    PostalDude.TakeDamage(UppercutDamage, Pawn, PostalDude.Location,
        vect(0,0,0), UppercutDamageType);

    if (GrappleHitSound != none)
        PostalDude.PlaySound(GrappleHitSound, SLOT_Pain, 1, false, 300);

    PlayGrappleUppercutDialog();
}

/** Animation notify from our Pawn to deal one of our many flurry punches */
function NotifyFinisherFlurryPunch() {
    local rotator PunchRotation;

    PostalDude.TakeDamage(FinisherAttack.FlurryPunchDamage, Pawn,
        PostalDude.Location, vect(0,0,0), FinisherAttack.FlurryPunchDamageType);

    if (FinisherHitSound != none)
        PostalDude.PlaySound(FinisherHitSound, SLOT_None, 1, false, 300);


    if (PostalDude.Controller != none) {
        PunchRotation = PostalDude.Controller.Rotation;

        PunchRotation.Pitch += Rand(FinisherAttack.FlurryViewPitch);
        PunchRotation.Yaw += Rand(FinisherAttack.FlurryViewYaw);
        PunchRotation.Yaw -= Rand(FinisherAttack.FlurryViewYaw);

        PostalDude.Controller.SetRotation(PunchRotation);
    }
}

/** Animation notify from our Pawn to deal the final downward punch blow */
function NotifyFinisherDownPunch() {
    bFinisherInterp = false;

    if (PostalDude.Physics != PHYS_KarmaRagDoll) {
        PostalDude.SetPhysics(PHYS_Falling);

        PostalDude.Velocity = FinisherAttack.FlyVelocity *
                              class'P2EMath'.static.GetOffset(Pawn.Rotation,
                                  FinisherAttack.FlyDir);
    }

    PostalDude.TakeDamage(FinisherAttack.DownPunchDamage, Pawn,
        PostalDude.Location, vect(0,0,0), FinisherAttack.DownPunchDamageType);

    if (FinisherHitSound != none)
        PostalDude.PlaySound(FinisherHitSound, SLOT_Pain, 1, false, 300);
}

/** Animation notify from our Pawn to play a punch swoosh sound */
function NotifyPlayGrappleSwooshSound() {
    if (GrappleSwooshSound != none)
        Pawn.PlaySound(GrappleSwooshSound, SLOT_Pain, 1, false, 300);
}

/** Animation notify from our Pawn to play a punch swoosh sound */
function NotifyPlayFlurryPunchSwoosh() {
    if (FinisherSwooshSound != none)
        Pawn.PlaySound(FinisherSwooshSound, SLOT_Pain, 1, false, 300);
}

/** Animation notify to leave an Easter Egg on the Dude's face */
function NotifyCrapOnDudesFace() {
    if (HumiliationSound != none)
        Pawn.PlaySound(HumiliationSound, SLOT_Pain, 1, false, 300);
}

state MoveTowardEntranceNode
{
    function BeginState() {
        LogDebug("Entered MoveTowardEntranceNode state...");

        Focus = none;

        Pawn.GroundSpeed = HumiliationWalkSpeed;
        EasterBunny.SetAnimWalking();

        TriggerEvent(EasterBunny.EntranceMatineeEvent, self, Pawn);

        AddTimer(0.1, 'EntranceUpdate', true);
    }

    function EndState() {
        RemoveTimerByID('EntranceUpdate');
    }

Begin:
    while (VSize(EntranceNode.Location - Pawn.Location) > 32) {
        if (ActorReachable(EntranceNode))
            MoveToward(EntranceNode);
		else {
			MoveTarget = FindPathToward(EntranceNode);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                GotoState('Idle');
		}
    }
}

state EntranceSpeech
{
    function BeginState() {
        LogDebug("Entered EntranceSpeech state...");

        Focus = PostalDude;

        PlayEntranceSpeechDialog();

        AddTimer(GetSoundDuration(EntranceDialog), 'EntranceSpeechFinished', false);
        PlayAnimByDuration(EntranceAnim, GetSoundDuration(EntranceDialog), 0.2);
    }

Begin:
    StopMoving();
}

/** Our initial state where we decide what to do */
state Idle
{
    function BeginState() {
        LogDebug("Entered Idle state...");

        Focus = PostalDude;

        // Go idle for now if the Postal Dude is dead
        if (PostalDude.Health > 0)
            AddTimer(IdleThinkDelay, 'IdleThink', true);
        else
            GotoState('HumiliationPrep');
    }

    function EndState() {
        RemoveTimerByID('IdleThink');
    }

Begin:
    StopMoving();
}

/** Move toward our player so we can perform an attack */
state MoveTowardPlayer
{
    function BeginState() {
        LogDebug("Entered MoveTowardPlayer state...");

        Focus = none;

        Pawn.GroundSpeed = Pawn.default.GroundSpeed;
        //Pawn.GroundSpeed = EasterBunny.DefaultGroundSpeed;

        EasterBunny.SetAnimRunning();

        AddTimer(MoveThinkInterval, 'MoveThink', true);
    }

    function EndState() {
        RemoveTimerByID('MoveThink');
    }

Begin:
    while (!HasReachedPostalDude()) {
        if (ActorReachable(PostalDude))
            MoveToward(PostalDude);
		else {
			MoveTarget = FindPathToward(PostalDude);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else // Go back to idle state and wait to see if we can find a path
                GotoState('Idle');
		}
    }
}

/** Perform a smoke bomb teleport move right behind the player */
state SmokeBombMove
{
    function BeginState() {
        LogDebug("Entered SmokeBombMove state...");

        bAttacking = true;
        bCanUseSmokeBomb = false;

        SmokeBombBolton = Spawn(class'BoltonPart');

        if (SmokeBombBolton != none) {
            SmokeBombBolton.SetStaticMesh(SmokeBombStaticMesh);
            SmokeBombBolton.SetDrawType(DT_StaticMesh);

            Pawn.AttachToBone(SmokeBombBolton, SmokeBombBone);
	        SmokeBombBolton.SetRelativeLocation(SmokeBombOffset);
        }

        AddTimer(SmokeBombTeleport.MoveTime, 'SmokeBombFinished', false);
        AddTimer(SmokeBombTeleport.ReuseTime, 'EnableSmokeBomb', false);
        PlayAnimByDuration(SmokeBombAnim, SmokeBombTeleport.MoveTime,
            SmokeBombBlendTime );
    }

    function EndState() {
        bAttacking = false;
    }

Begin:
    StopMoving();
}

/** Summon our imaginary, yet really real posse of bunnys to beat up the Dude */
state CloneSummonMove
{
    function BeginState() {
        LogDebug("Entered CloneSummonMove state...");

        bAttacking = true;
        bCanUseCloneSummon = false;

        AddTimer(CloneSummon.MoveTime, 'CloneSummonFinished', false);
        AddTimer(CloneSummon.ReuseTime, 'EnableCloneSummon', false);
        PlayAnimByDuration(CloneSummonAnim, CloneSummon.MoveTime,
            CloneSummonBlendTime);
    }

    function EndState() {
        bAttacking = false;
    }

Begin:
    StopMoving();
}

/** Winding up for a ground attack */
state GroundAttackPrep
{
    function BeginState() {
        local float PrepTime;

        LogDebug("Entered GroundAttackPrep state...");

        bAttacking = true;

        GroundAttackAnim = Rand(2);

        Focus = PostalDude;

        //EasterBunny.ChangePhysicsAnimUpdate(false);

        if (bUseSuperAttacks)
            PrepTime = GroundAttacks[1].PrepTime;
        else
            PrepTime = GroundAttacks[0].PrepTime;

        if (Level.TimeDilation < 1)
            PrepTime = PrepTime * Level.TimeDilation;

        AddTimer(PrepTime, 'GroundPrepFinished', false);
        PlayAnimByDuration(GroundAttackPrepAnims[GroundAttackAnim],
            PrepTime, GroundAttackBlendTime);
    }

Begin:
    StopMoving();
}

/** Unlesh a devastating ground attack */
state GroundAttack
{
    function BeginState() {
        local float AttackTime;

        LogDebug("Entered GroundAttack state...");

        //EasterBunny.ChangePhysicsAnimUpdate(false);

        if (bUseSuperAttacks)
            AttackTime = GroundAttacks[1].AttackTime;
        else
            AttackTime = GroundAttacks[0].AttackTime;

        if (GroundSwooshSound != none)
            Pawn.PlaySound(GroundSwooshSound, SLOT_Pain, 1, false, 300);

        AddTimer(AttackTime, 'GroundAttackFinished', false);
        PlayAnimByDuration(GroundAttackAnims[GroundAttackAnim],
            AttackTime, GroundAttackBlendTime);
    }

    function EndState() {
        bAttacking = false;
    }

Begin:
    StopMoving();
}

/** The Easter Bunny is winding up for a devastating punch */
state DashAttackPrep
{
    function BeginState() {
        local int i;
        local float PrepTime;

        LogDebug("Entered DashAttackPrep state...");

        bAttacking = true;

        DashAttackAnim = Rand(2);

        Focus = PostalDude;
        Pawn.SetRotation(rotator(PostalDude.Location - Pawn.Location));

        if (bUseSuperAttacks)
            PrepTime = DashAttacks[1].PrepTime;
        else
            PrepTime = DashAttacks[0].PrepTime;

        AddTimer(PrepTime, 'DashPrepFinished', false);
        PlayAnimByDuration(DashAttackPrepAnims[DashAttackAnim],
            PrepTime, DashAttackBlendTime);
    }

    function EndState() {
        local vector PostalDudeLocation;

        PostalDudeLocation = PostalDude.Location;
        PostalDudeLocation.Z = Pawn.Location.Z;

        DashDir = Normal(PostalDudeLocation - Pawn.Location);

        if (bUseSuperAttacks) {
            DashSpeed = DashAttacks[1].Speed;
            DashDest = Pawn.Location + DashDir * DashAttacks[1].Range;
        }
        else {
            DashSpeed = DashAttacks[0].Speed;
            DashDest = Pawn.Location + DashDir * DashAttacks[0].Range;
        }
    }

Begin:
    StopMoving();
}

/** To close in and possible hurt the Dude, dash forward with a mighty punch
 * or kick. Will be upgraded to a more powerful version if we've taken too
 * much damage
 */
state DashAttack
{
    function BeginState() {
        LogDebug("Entered DashAttack state...");

        bDashAttack = true;
        bAttackConnected = false;

        // We want the Easter Bunny to always be facing in the same direction
        Focus = none;
        FocalPoint = Pawn.Location + Normal(DashDest - Pawn.Location) * 8192;

        Pawn.GroundSpeed = DashSpeed;

        if (DashStartSound != none)
            Pawn.PlaySound(DashStartSound, SLOT_Pain, 1, false, 300);

        if (DashAmbientSound != none)
            Pawn.AmbientSound = DashAmbientSound;

        AddTimer(DashAttackUpdateInterval, 'DashAttackUpdate', true);
        AddTimer(DashFireEmitterPerDistance / DashSpeed,
            'SpawnDashTrailEmitter', true);
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = DashDir * DashSpeed;
    }

    function EndState() {
        bDashAttack = false;
        bAttackConnected = true;

        Pawn.GroundSpeed = Pawn.default.GroundSpeed;
        //Pawn.GroundSpeed = EasterBunny.DefaultGroundSpeed;

        Pawn.AmbientSound = none;

        RemoveTimerByID('DashAttackUpdate');
        RemoveTimerByID('SpawnDashTrailEmitter');
    }
}

state DashAttackEnd
{
    function BeginState() {
        local float EndTime;

        LogDebug("Entered DashAttackEnd state...");

        if (bUseSuperAttacks)
            EndTime = DashAttacks[1].EndTime;
        else
            EndTime = DashAttacks[0].EndTime;

        InterpolateSpeed(EndTime, 0, INTERP_Linear);

        AddTimer(EndTime, 'DashEndFinished', false);
        PlayAnimByDuration(DashAttackEndAnims[DashAttackAnim],
            EndTime, DashAttackBlendTime);
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        // Animation hack, we really want to disable the damn movement channels
        // as they keep automatically re-enabling themselves!
        DisableMovementChannels();
    }

    function EndState() {
        bAttacking = false;

        Pawn.GroundSpeed = Pawn.default.GroundSpeed;
        //Pawn.GroundSpeed = EasterBunny.DefaultGroundSpeed;
    }
}

/** We've taken enough damage to have the attack canceled */
state DashAttackCancel
{
    function BeginState() {
        local float CancelTime;

        LogDebug("Entered DashAttackCancel state...");

        if (bUseSuperAttacks)
            CancelTime = DashAttacks[1].CancelTime;
        else
            CancelTime = DashAttacks[0].CancelTime;

        AddTimer(CancelTime, 'DashCancelFinished', false);
        PlayAnimByDuration(DashAttackCancelAnims[DashAttackAnim],
            CancelTime, DashAttackBlendTime);
    }

    function EndState() {
        bAttacking = false;
    }
}

/** Jump into the air so we can have a vantage point on the Postal Dude */
state DiveKickJump
{
    function BeginState() {
        local float JumpTime;

        LogDebug("Entered DiveKickAirJump state...");

        bAttacking = true;

        Focus = PostalDude;

        if (bUseSuperAttacks)
            JumpTime = DiveKickAttacks[1].JumpTime;
        else
            JumpTime = DiveKickAttacks[0].JumpTime;

        if (DiveKickJumpSound != none)
            Pawn.PlaySound(DiveKickJumpSound, SLOT_Pain, 1, false, 300);

        AddTimer(JumpTime, 'DiveKickJumpFinished', false);
        AddTimer(JumpTime * DiveKickJumpAnimPct, 'DiveKickJumpInterp', false);

        PlayAnimByDuration(DiveKickJumpAnim, JumpTime, DiveKickBlendTime);
    }

    function EndState() {
        DiveKickDir = Normal(GetDiveKickDest() - Pawn.Location);

        if (bUseSuperAttacks)
            DiveKickSpeed = DiveKickAttacks[1].DiveSpeed;
        else
            DiveKickSpeed = DiveKickAttacks[0].DiveSpeed;
    }

Begin:
    StopMoving();
}

/** Fly down towards the Postal Dude to perform the attack */
state DiveKick
{
    function BeginState() {
        LogDebug("Entered DiveKick state...");

        bDiveKickAttack = true;
        bDiveKickWallHit = false;
        bAttackConnected = false;

        Pawn.SetPhysics(PHYS_Falling);

        Focus = none;
        FocalPoint = Pawn.Location + DiveKickDir * 8192;

        if (DiveKickStartSound != none)
            Pawn.PlaySound(DiveKickStartSound, SLOT_Pain, 1, false, 300);

        if (DiveKickAmbientSound != none)
            Pawn.AmbientSound = DiveKickAmbientSound;

        AddTimer(DashAttackUpdateInterval, 'DiveKickUpdate', true);
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = DiveKickDir * DiveKickSpeed;
    }

    function EndState() {
        bDiveKickAttack = false;
        bAttackConnected = true;

        RemoveTimerByID('DiveKickUpdate');

        Pawn.AmbientSound = none;
    }
}

state DiveKickWallHit
{
    function BeginState() {
        local float WallPushoffTime;

        LogDebug("Entered DiveKickWallHit state...");

        bDiveKickWallHit = true;

        Pawn.SetPhysics(PHYS_Flying);
        StopMoving();

        if (bUseSuperAttacks)
            WallPushoffTime = DiveKickAttacks[1].WallPushoffTime;
        else
            WallPushoffTime = DiveKickAttacks[0].WallPushoffTime;

        if (DiveKickWallHitSound != none)
            Pawn.PlaySound(DiveKickWallHitSound, SLOT_Pain, 1, false, 300);

        PlayAnimByDuration(DiveKickWallHitAnim, WallPushoffTime,
            DiveKickBlendTime);
    }

Begin:
    StopMoving();
}

/** Land with a destructive impact sporting a three point stance */
state DiveKickEnd
{
    function BeginState() {
        local float LandingTime;
        local float DiveKickFlyVel;
        local float DiveKickDamage, DiveKickRadius;

        local class<DamageType> DiveKickDamageType;

        local Pawn Victim;

        LogDebug("Entered DiveKickEnd state...");

        Focus = PostalDude;

        if (bUseSuperAttacks) {
            LandingTime = DiveKickAttacks[1].LandingTime;

            DiveKickDamage = DiveKickAttacks[1].Damage;
            DiveKickRadius = DiveKickAttacks[1].Radius;
            DiveKickFlyVel = DiveKickAttacks[1].FlyVelocity;
            DiveKickDamageType = DiveKickAttacks[1].DamageType;
        }
        else {
            LandingTime = DiveKickAttacks[0].LandingTime;

            DiveKickDamage = DiveKickAttacks[0].Damage;
            DiveKickRadius = DiveKickAttacks[0].Radius;
            DiveKickFlyVel = DiveKickAttacks[0].FlyVelocity;
            DiveKickDamageType = DiveKickAttacks[0].DamageType;
        }

        if (!bDiveKickWallHit) {
            foreach VisibleCollidingActors(class'Pawn', Victim,
                DiveKickRadius, Pawn.Location)
                if (Victim != Pawn)
                    SendPawnFlying(Victim, DiveKickFlyVel);

            Pawn.HurtRadius(DiveKickDamage, DiveKickRadius, DiveKickDamageType,
                0, Pawn.Location);
        }

        if (DiveKickLandingSound != none)
            Pawn.PlaySound(DiveKickLandingSound, SLOT_Pain, 1, false, 300);

        AddTimer(LandingTime, 'DiveKickLandingFinished', false);
        AddTimer(DiveKickLandingAnimDelay, 'PlayDiveKickLandingAnim', false);

        if (DiveKickLandEmitter != none)
            Spawn(DiveKickLandEmitter,,,
                Pawn.Location + DiveKickLandEmitterOffset);
    }

    function EndState() {
        bAttacking = false;
    }
}

/** Getting ready for a mad dash toward the Postal Dude */
state GrappleAttackPrep
{
    function BeginState() {
        local float PrepTime;

        LogDebug("Entered GrappleAttackPrep state...");

        GrappleDamageTaken = 0;
        bCanUseGrappleAttack = false;

        bAttacking = true;

        Focus = PostalDude;

        if (bUseSuperAttacks)
            PrepTime = GrappleAttacks[1].PrepTime;
        else
            PrepTime = GrappleAttacks[0].PrepTime;

        AddTimer(PrepTime, 'GrappleAttackPrepFinished', false);
        AddTimer(GrappleReuseTime, 'EnableGrapple', false);
        PlayAnimByDuration(GrapplePrepAnim, PrepTime, GrappleBlendTime);
    }

Begin:
    StopMoving();
}

/** Dashing toward the Postal Dude so we can grab and pummel him */
state GrappleAttackRun
{
    function BeginState() {
        LogDebug("Entered GrapplAttackRun state...");

        bGrappleAttack = true;
        bAttackConnected = false;

        if (bUseSuperAttacks)
            Pawn.GroundSpeed = GrappleAttacks[1].RunSpeed;
        else
            Pawn.GroundSpeed = GrappleAttacks[0].RunSpeed;

        EasterBunny.SetAnimRunning();

        Focus = PostalDude;

        AddTimer(GrappleUpdateInterval, 'GrappleUpdate', true);
    }

    function EndState() {
        bGrappleAttack = false;
        bAttackConnected = true;

        Pawn.GroundSpeed = Pawn.default.GroundSpeed;
        //Pawn.GroundSpeed = EasterBunny.DefaultGroundSpeed;

        RemoveTimerByID('GrappleUpdate');
    }

Begin:
    while (!HasReachedPostalDude()) {
        if (ActorReachable(PostalDude))
            MoveToward(PostalDude);
		else {
			MoveTarget = FindPathToward(PostalDude);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else // Go back to idle state and wait to see if we can find a path
                GotoState('Idle');
		}
    }
}

/** We've managed to touch the Postal Dude so now he's in our grasp */
state GrappleAttack
{
    function BeginState() {
        local float AttackTime;

        LogDebug("Entered GrappleAttack state...");

        Focus = none;
        FocalPoint = Pawn.Location + vector(Pawn.Rotation) * 8192;

        if (bUseSuperAttacks)
            AttackTime = GrappleAttacks[1].AttackTime;
        else
            AttackTime = GrappleAttacks[0].AttackTime;

        GrappleElapsedTime = 0;
        GrappleFinishTime = AttackTime * GrappleLiftPct;
        GrappleLiftStart = Pawn.Location +
                           class'P2EMath'.static.GetOffset(Pawn.Rotation,
                               GrappleLiftStartOffset);
        GrappleLiftEnd = Pawn.Location +
                         class'P2EMath'.static.GetOffset(Pawn.Rotation,
                             GrappleLiftDestOffset);

        bGrappleInterp = true;

        PostalDude.SetPhysics(PHYS_Flying);

        AddTimer(AttackTime, 'GrappleAttackFinished', false);
        PlayAnimByDuration(GrappleAttackAnim, AttackTime, GrappleBlendTime);

        PlayGrappleGrabDialog();
    }

    event Tick(float DeltaTime) {
        local float InterpPct;
        local vector InterpDif;

        super.Tick(DeltaTime);

        if (bGrappleInterp) {
            GrappleElapsedTime = FMin(GrappleElapsedTime + DeltaTime,
                                     GrappleFinishTime);

            InterpPct = GrappleElapsedTime / GrappleFinishTime;

            PostalDude.SetLocation(GrappleLiftStart +
                (GrappleLiftEnd - GrappleLiftStart) * InterpPct);
        }
    }

    function EndState() {
        bAttacking = false;
    }

Begin:
    StopMoving();
}

/** Easter Bunny has been shot enough that he falls down and gets back up */
state GrappleFallDown
{
    function BeginState() {
        local float FallDownTime;

        LogDebug("Entered GrappleFallDown state...");

        Focus = none;
        FocalPoint = Pawn.Location + vector(Pawn.Rotation) * 8192;

        if (bUseSuperAttacks)
            FallDownTime = GrappleAttacks[1].FallDownTime;
        else
            FallDownTime = GrappleAttacks[0].FallDownTime;

        InterpolateSpeed(FallDownTime, 0, INTERP_Linear);

        AddTimer(FallDownTime, 'GrappleFallDownFinished', false);
        PlayAnimByDuration(GrappleFallAnim, FallDownTime, GrappleBlendTime);

        PlayAttackCancelDialog();
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        // Animation hack, we really want to disable the damn movement channels
        // as they keep automatically re-enabling themselves!
        DisableMovementChannels();
    }

    function EndState() {
        Pawn.GroundSpeed = Pawn.default.GroundSpeed;
        //Pawn.GroundSpeed = EasterBunny.DefaultGroundSpeed;
    }
}

/** Get back up after we have fallen down */
state GrappleGetUp
{
    function BeginState() {
        local float GetUpTime;

        LogDebug("Entered GrappleGetUp state...");

        EnableMovementChannels();

        if (bUseSuperAttacks)
            GetUpTime = GrappleAttacks[1].GetUpTime;
        else
            GetUpTime = GrappleAttacks[0].GetUpTime;

        AddTimer(GetUpTime, 'GrappleGetUpFinished', false);
        PlayAnimByDuration(GrappleGetUpAnim, GetUpTime, GrappleBlendTime);
    }

    function EndState() {
        bAttacking = false;
    }

Begin:
    StopMoving();
}

/** Getting ready for a mad dash toward the Postal Dude */
state FinisherAttackPrep
{
    function BeginState() {
        LogDebug("Entered FinisherPrep state...");

        FinisherDamageTaken = 0;
        bCanUseFinisherAttack = false;

        bAttacking = true;

        Focus = PostalDude;

        AddTimer(FinisherAttack.PrepTime, 'FinisherPrepFinished', false);
        AddTimer(FinisherReuseTime, 'EnableFinisher', false);
        PlayAnimByDuration(FinisherPrepAnim, FinisherAttack.PrepTime,
            FinisherBlendTime);
    }

Begin:
    StopMoving();
}

/** Dashing toward the Postal Dude so we can uppercut him into the sky */
state FinisherRun
{
    function BeginState() {
        LogDebug("Entered FinisherRun state...");

        bFinisherAttack = true;
        bAttackConnected = false;

        Pawn.GroundSpeed = FinisherAttack.RunSpeed;

        EasterBunny.SetAnimRunning();

        Focus = PostalDude;

        AddTimer(FinisherUpdateInterval, 'FinisherUpdate', true);
    }

    function EndState() {
        bFinisherAttack = false;
        bAttackConnected = true;

        Pawn.GroundSpeed = Pawn.default.GroundSpeed;
        //Pawn.GroundSpeed = EasterBunny.DefaultGroundSpeed;

        RemoveTimerByID('FinisherUpdate');
    }

Begin:
    while (!HasReachedPostalDude()) {
        if (ActorReachable(PostalDude))
            MoveToward(PostalDude);
		else {
			MoveTarget = FindPathToward(PostalDude);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else // Go back to idle state and wait to see if we can find a path
                GotoState('Idle');
		}
    }
}

/** Perform a mighty uppercut that knocks the Postal Dude high into the air */
state FinisherUppercut
{
    function BeginState() {
        LogDebug("Entered FinisherUppercut state...");

        Focus = PostalDude;

        AddTimer(FinisherAttack.UppercutTime * FinisherUppercutPct,
            'InterpolatePostalDude', false);
        AddTimer(FinisherAttack.UppercutTime, 'FinisherUppercutFinished',
            false);

        PlayAnimByDuration(FinisherUppercutAnim, FinisherAttack.UppercutTime,
            FinisherBlendTime);
    }

    event Tick(float DeltaTime) {
        local float InterpPct;
        local vector InterpDif;

        super.Tick(DeltaTime);

        if (bFinisherInterp) {
            FinisherElapsedTime = FMin(FinisherElapsedTime + DeltaTime,
                                       FinisherFinishTime);

            InterpPct = FinisherElapsedTime / FinisherFinishTime;

            PostalDude.SetLocation(FinisherUppercutStart +
                (FinisherUppercutEnd - FinisherUppercutStart) * InterpPct);
        }
    }

Begin:
    StopMoving();
}

/** Jump like fifty million feet into the air in some ninja shit! */
state FinisherJump
{
    function BeginState() {
        local float JumpTime, JumpExponent;
        local vector JumpDest;

        LogDebug("Entered FinisherJump state...");

        Focus = PostalDude;

        JumpTime = FinisherAttack.JumpTime;

        JumpDest = Pawn.Location;
        JumpDest.Z = FinisherUppercutEnd.Z;

        Pawn.SetPhysics(PHYS_Flying);

        InterpolateByDuration(JumpTime, JumpDest, INTERP_Linear);

        AddTimer(FinisherAttack.JumpTime, 'FinisherJumpFinished', false);
    }

    event Tick(float DeltaTime) {
        local float InterpPct;
        local vector InterpDif;

        super.Tick(DeltaTime);

        if (bFinisherInterp) {
            FinisherElapsedTime = FMin(FinisherElapsedTime + DeltaTime,
                                       FinisherFinishTime);

            InterpPct = FinisherElapsedTime / FinisherFinishTime;

            PostalDude.SetLocation(FinisherUppercutStart +
                (FinisherUppercutEnd - FinisherUppercutStart) * InterpPct);
        }
    }
}

/** Perform a flurry of punches, all ending with a downward punch */
state FinisherAttacks
{
    function BeginState() {
        LogDebug("Entered FinisherFlurryPunch state...");

        Focus = PostalDude;

        AddTimer(FinisherAttack.FlurryPunchTime, 'FinisherFlurryFinished',
            false);

        PlayAnimByDuration(FinisherFlurryPunchAnim,
            FinisherAttack.FlurryPunchTime, FinisherBlendTime);
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        if (bFinisherInterp)
            PostalDude.SetLocation(FinisherUppercutEnd);
    }
}

/** Fall back down to Earth. */
state FinisherFall
{
    function BeginState() {
        LogDebug("Entered FinisherFall state...");

        Pawn.SetPhysics(PHYS_Falling);
    }
}

/** Easter Bunny has been shot enough that he falls down and gets back up */
state FinisherFallDown
{
    function BeginState() {
        LogDebug("Entered FinisherFallDown state...");

        Focus = none;
        FocalPoint = Pawn.Location + vector(Pawn.Rotation) * 8192;

        InterpolateSpeed(FinisherAttack.FallDownTime, 0, INTERP_Linear);

        AddTimer(FinisherAttack.FallDownTime, 'FinisherFallDownFinished',
            false);

        // We can reuse the Grapple fall down animation
        PlayAnimByDuration(GrappleFallAnim, FinisherAttack.FallDownTime,
            FinisherBlendTime);

        PlayAttackCancelDialog();
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        // Animation hack, we really want to disable the damn movement channels
        // as they keep automatically re-enabling themselves!
        DisableMovementChannels();
    }

    function EndState() {
        Pawn.GroundSpeed = Pawn.default.GroundSpeed;
        //Pawn.GroundSpeed = EasterBunny.DefaultGroundSpeed;
    }
}

/** Get back up after we have fallen down */
state FinisherGetUp
{
    function BeginState() {
        LogDebug("Entered FinisherGetUp state...");

        EnableMovementChannels();

        AddTimer(FinisherAttack.GetUpTime, 'FinisherGetUpFinished', false);
        PlayAnimByDuration(GrappleGetUpAnim, FinisherAttack.GetUpTime,
            FinisherBlendTime);
    }

    function EndState() {
        bAttacking = false;
    }

Begin:
    StopMoving();
}

/** Here we wait to see if the Postal Dude's corpse falls flat on the ground */
state HumiliationPrep
{
    function BeginState() {
        LogDebug("Entered HumiliationPrep state...");

        Focus = PostalDude;

        // Remove all the clones now that the Postal Dude is dead
        PoofAllClones();

        AddTimer(HumiliationPrepAnim.AnimTime, 'HumiliationPrepFinished',
            false);

        PlayAnimInfo(HumiliationPrepAnim, HumiliationBlendTime);
    }

Begin:
    StopMoving();
}

/** Get your bunny as closer to the Postal Dude */
state MoveTowardPlayersHead
{
    function BeginState() {
        LogDebug("Entered MoveTowardPlayersHead state...");

        Pawn.GroundSpeed = HumiliationWalkSpeed;
        EasterBunny.SetAnimWalking();

        AddTimer(HumiliationUpdateInterval, 'HumiliationUpdate', true);
    }

    function EndState() {
        RemoveTimerByID('HumiliationUpdate');
    }

Begin:
    while (!HasReachedDudesHead()) {
        if (PointReachable(HumiliationDest))
            MoveTo(HumiliationDest);
		else {
			MoveTarget = FindPathTo(HumiliationDest);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else // Go back to idle state and wait to see if we can find a path
                GotoState('Idle');
		}
    }
}

/** For now, let's just fart on his face */
state HumiliatePostalDude
{
    function BeginState() {
        LogDebug("Entered HumiliatePostalDude state...");

        Focus = none;
        FocalPoint = Pawn.Location + HumiliationDir * 8192;

        AddTimer(HumiliationTime, 'HumiliationFinished', false);
        PlayAnimByDuration(HumiliationAnim, HumiliationTime,
            HumiliationBlendTime);
    }

Begin:
    StopMoving();
}

state HumiliationDance
{
    function BeginState() {
        LogDebug("Entered HumiliationDance state...");

        Focus = PostalDude;

        PlayHumiliationDance();

        RemoveTimerByID('PlayTauntDialog');
    }

Begin:
    StopMoving();
}

defaultproperties
{
    AdvancedAttacksHealthPct=0.75
    SuperAttacksHealthPct=0.5
    FinisherAttackHealthPct=0.35

    IdleThinkDelay=0.2

    MoveThinkInterval=0.2
    MoveReachedRange=32

    //-------------------------------------------------------------------------
    // Entrance Default Values

    EntranceAnim=(Anim="s_angry",Rate=1,AnimTime=1.36)

    EntranceDialog=sound'EasterSounds.Misc.enterence'

    //-------------------------------------------------------------------------
    // Smoke Bomb Telelport Default Values

    bCanUseSmokeBomb=true

    SmokeBombMinDistance=64

    SmokeBombTeleport=(MoveTime=1,ReuseTime=15,UseRange=512)

    SmokeBombBlendTime=0.2

    SmokeBombAnim=(Anim="SmokeBomb",Rate=1,AnimTime=1.2)

    SmokeBombBone="MALE01 r hand"
    SmokeBombOffset=(X=8,Y=-3.5,Z=0)
    SmokeBombStaticMesh=StaticMesh'TP_Weapons.Grenade3'

    SmokeBombEmitter=class'EasterBunnySmokeExplosion'

    //-------------------------------------------------------------------------
    // Clone Summon Default Values

    bCanUseCloneSummon=true

    CloneSummonOffsets(0)=(X=256,Y=0,Z=0)
    CloneSummonOffsets(1)=(X=0,Y=-256,Z=0)
    CloneSummonOffsets(2)=(X=0,Y=256,Z=0)

    CloneSummon=(MoveTime=1,ReuseTime=60,CloneDamageCoef=0.25)

    CloneSummonBlendTime=0.2

    CloneSummonAnim=(Anim="CloneSummon",Rate=1,AnimTime=1.36)

    //-------------------------------------------------------------------------
    // Ground Attack Default Values

    GroundAttacks(0)=(PrepTime=0.5,AttackTime=0.75,UseRange=128,Damage=75,Radius=384,FlyVelocity=512,DamageType=class'BludgeonDamage')
    GroundAttacks(1)=(PrepTime=0.35,AttackTime=0.75,UseRange=128,Damage=100,Radius=512,FlyVelocity=768,DamageType=class'BludgeonDamage')

    GroundAttackBlendTime=0.2

    GroundAttackPrepAnims(0)=(Anim="GroundPunchPrep",Rate=1,AnimTime=0.16)
    GroundAttackPrepAnims(1)=(Anim="AxeKickPrep",Rate=1,AnimTime=0.53)

    GroundAttackAnims(0)=(Anim="GroundPunch",Rate=1,AnimTime=0.7)
    GroundAttackAnims(1)=(Anim="AxeKick",Rate=1,AnimTime=0.86)

    GroundSwooshSound=sound'WeaponSounds.foot_fire'
    GroundImpactSound=sound'LevelSoundsToo.library.woodCrash03'

    GroundEmitterOffset=(X=64,Y=0,Z=-64)

    GroundRockEmitter=class'EasterBunnyGroundImpact'
    GroundExplosionEmitter=class'EasterBunnyGroundExplosion'

    //-------------------------------------------------------------------------
    // Dash Attack Default Values

    DashAttackUpdateInterval=0.1

    DashCollisionCheckDist=64

    DashCollisionChecks(0)=(X=0,Y=-28,Z=-64)
    DashCollisionChecks(1)=(X=0,Y=0,Z=-64)
    DashCollisionChecks(2)=(X=0,Y=28,Z=-64)

    DashAttacks(0)=(PrepTime=0.5,StartTime=0.25,EndTime=0.5,CancelTime=0.5,UseRange=512,Speed=2048,Range=1024,Damage=35,FlyVelocity=512,DamageType=class'BludgeonDamage')
    DashAttacks(1)=(PrepTime=0.25,StartTime=0.25,EndTime=0.5,CancelTime=0.25,UseRange=512,Speed=3072,Range=1024,Damage=50,FlyVelocity=768,DamageType=class'BurnedDamage')

    DashAttackBlendTime=0.2

    DashAttackPrepAnims(0)=(Anim="DashPunchPrep",Rate=1,AnimTime=0.7)
    DashAttackPrepAnims(1)=(Anim="DashKickPrep",Rate=1,AnimTime=0.7)

    DashAttackStartAnims(0)=(Anim="DashPunchStart",Rate=1,AnimTime=0.7)
    DashAttackStartAnims(1)=(Anim="DashKickStart",Rate=1,AnimTime=0.7)

    DashAttackCancelAnims(0)=(Anim="DashPunchCancel",Rate=1,AnimTime=0.86)
    DashAttackCancelAnims(1)=(Anim="DashKickCancel",Rate=1,AnimTime=0.86)

    DashAttackLoopAnims(0)=(Anim="DashPunchLoop",Rate=1,AnimTime=1)
    DashAttackLoopAnims(1)=(Anim="DashKickLoop",Rate=1,AnimTime=1)

    DashAttackEndAnims(0)=(Anim="DashPunchEnd",Rate=1,AnimTime=0.7)
    DashAttackEndAnims(1)=(Anim="DashKickEnd",Rate=1,AnimTime=0.7)

    DashStartSound=sound'WeaponSounds.rocket_launch'
    DashAmbientSound=sound'WeaponSounds.rocket_flying'
    DashHitSound=sound'WeaponSounds.foot_kickhead'

    DashFireEmitterBurnTime=5
    DashFireEmitterPerDistance=64
    DashFireEmitterOffset=(X=0,Y=0,Z=-32)
    DashSmokeEmitter=class'EasterBunnyDashSmoke'
    DashFireEmitter=class'EasterBunnyFireEmitter'

    //-------------------------------------------------------------------------
    // Dive Kick Attack Default Values

    DiveKickUpdateInterval=0.1

    DiveKickAttacks(0)=(JumpTime=1,StartTime=0.5,JumpHeight=384,JumpExponent=1,WallPushoffTime=1,WallPushoffVelocity=256,LandingTime=1,DiveSpeed=1536,Damage=35,Radius=256,FlyVelocity=512,DamageType=class'BludgeonDamage')
    DiveKickAttacks(1)=(JumpTime=1,StartTime=0.5,JumpHeight=256,JumpExponent=1,WallPushoffTime=0.75,WallPushoffVelocity=256,LandingTime=1,DiveSpeed=2048,Damage=50,Radius=384,FlyVelocity=768,DamageType=class'BludgeonDamage')

    DiveKickCollisionCheckDist=64

    DiveKickCollisionChecks(0)=(X=0,Y=-28,Z=0)
    DiveKickCollisionChecks(1)=(X=0,Y=0,Z=0)
    DiveKickCollisionChecks(2)=(X=0,Y=28,Z=0)

    DiveKickBlendTime=0.2
    DiveKickJumpAnimPct=0.69
    DiveKickLandingAnimDelay=0.1

    DiveKickJumpAnim=(Anim="DiveKickAirJump",Rate=1,AnimTime=0.86)
    DiveKickStartAnim=(Anim="DiveKickStart",Rate=1,AnimTime=0.63)
    DiveKickLoopAnim=(Anim="DashKickLoop",Rate=1,AnimTime=1)
    DiveKickWallHitAnim=(Anim="DiveKickWallHit",Rate=1,AnimTime=1.8)
    DiveKickFallAnim=(Anim="DiveKickFall",Rate=1,AnimTime=1)
    DiveKickLandingAnim=(Anim="DiveKickEnd",Rate=1,AnimTime=1.8)

    DiveKickJumpSound=sound'WeaponSounds.molotov_fire'
    DiveKickStartSound=sound'WeaponSounds.rocket_launch'
    DiveKickAmbientSound=sound'WeaponSounds.rocket_flying'
    DiveKickHitSound=sound'WeaponSounds.foot_kickhead'
    DiveKickWallHitSound=sound'WeaponSounds.foot_kickwall'
    DiveKickLandingSound=none

    DiveKickLandEmitterOffset=(X=0,Y=0,Z=-40)
    DiveKickLandEmitter=class'EasterBunnyGroundImpact'

    //-------------------------------------------------------------------------
    // Grapple Attack Default Values

    bCanUseGrappleAttack=true

    GrappleUpdateInterval=0.1
    GrappleReuseTime=20

    GrappleFallDownSpeedCoef=0.5

    GrappleAttacks(0)=(PrepTime=0.5,AttackTime=3,FallDownTime=1.5,GetUpTime=1,UseRange=256,RunSpeed=750,FallDownDamage=100,PunchDamage=15,UppercutDamage=25,FlyVelocity=512,PunchViewPitch=10000,PunchViewYaw=20000,PunchDamageType=class'BludgeonDamage',UppercutDamageType=class'BludgeonDamage')
    GrappleAttacks(1)=(PrepTime=0.5,AttackTime=3,FallDownTime=1.5,GetUpTime=1,UseRange=256,RunSpeed=750,FallDownDamage=150,PunchDamage=20,UppercutDamage=35,FlyVelocity=512,PunchViewPitch=10000,PunchViewYaw=20000,PunchDamageType=class'BludgeonDamage',UppercutDamageType=class'BludgeonDamage')

    GrappleBlendTime=0.2

    GrappleLiftPct=0.17
    GrappleLiftStartOffset=(X=48,Y=16,Z=0)
    GrappleLiftDestOffset=(X=48,Y=16,Z=32)

    GrapplePrepAnim=(Anim="GrabPrep",Rate=1,AnimTime=1.66)
    GrappleRunAnim=(Anim="GrabRun",Rate=1,AnimTime=0.63)
    GrappleAttackAnim=(Anim="GrabAttack",Rate=1,AnimTime=4.2)
    GrappleFallAnim=(Anim="GrabFallDown",Rate=1,AnimTime=1.6)
    GrappleGetUpAnim=(Anim="GrabGetUp",Rate=1,AnimTime=1.5)

    GrappleSwooshSound=sound'WeaponSounds.foot_fire'
    GrappleHitSound=sound'WeaponSounds.foot_kickhead'

    //-------------------------------------------------------------------------
    // Finisher Attack Default Values

    bCanUseFinisherAttack=true

    FinisherUpdateInterval=0.1

    FinisherReuseTime=20

    FinisherAttack=(PrepTime=0.5,UppercutTime=0.75,JumpTime=0.25,FlurryPunchTime=3,DownPunchTime=0.75,LandingTime=1,FallDownTime=1.5,GetUpTime=1,RunSpeed=750,UppercutHeight=512,FallDownDamage=200,UppercutDamage=30,FlurryPunchDamage=3,DownPunchDamage=30,FlyVelocity=1024,FlyDir=(X=0.5,Y=0,Z=-0.5),FlurryViewPitch=2500,FlurryViewYaw=5000,UppercutDamageType=class'BludgeonDamage',FlurryPunchDamageType=class'BludgeonDamage',DownPunchDamageType=class'BludgeonDamage')

    FinisherBlendTime=0.2

    FinisherUppercutPct=0.37
    FinisherUppercutStartOffset=(X=128,Y=16,Z=0)

    FinisherPrepAnim=(Anim="FinisherPrep",Rate=1,AnimTime=1.36)
    FinisherRunAnim=(Anim="FinisherRun",Rate=1,AnimTime=0.63)
    FinisherUppercutAnim=(Anim="FinisherUppercut",Rate=1,AnimTime=1.43)
    FinisherJumpAnim=(Anim="FinisherAirJump",Rate=1,AnimTime=0.9)
    FinisherFlurryPunchAnim=(Anim="FinisherFlurryPunch",Rate=1,AnimTime=4.86)
    FinisherDownPunchAnim=(Anim="FinisherDownPunch",Rate=1,AnimTime=1.46)

    FinisherJumpSound=sound'WeaponSounds.molotov_fire'
    FinisherSwooshSound=sound'WeaponSounds.foot_fire'
    FinisherHitSound=sound'WeaponSounds.foot_kickhead'

    //-------------------------------------------------------------------------
    // Knockout Default Values

    KnockoutTime=2
    KnockoutSpeed=512

    KnockoutAnim=(Anim="Knockout",Rate=1,AnimTime=2.73)
    KnockoutLoopAnim=(Anim="KnockoutLoop",Rate=1,AnimTime=1)

    KnockoutSound=none
    KnockoutFartSounds(0)=sound'AmbientSounds.fart1'
    KnockoutFartSounds(1)=sound'AmbientSounds.fart3'
    KnockoutFartSounds(2)=sound'AmbientSounds.fart4'
    KnockoutFartSounds(3)=sound'AmbientSounds.fart5'

    KnockoutItemDropVelocity=400
    KnockoutItemDropRange=32

    KnockoutItemDrops(0)=(ItemDropCount=10,ItemPickup=class'GSelectAmmoPickup')
    KnockoutItemDrops(1)=(ItemDropCount=10,ItemPickup=class'MP5AmmoPickup')
    KnockoutItemDrops(2)=(ItemDropCount=10,ItemPickup=class'PlagueAmmoPickup')
    KnockoutItemDrops(3)=(ItemDropCount=1,ItemPickup=class'BodyArmorPickup')
    KnockoutItemDrops(4)=(ItemDropCount=4,ItemPickup=class'MedKitPickup')
    KnockoutItemDrops(4)=(ItemDropCount=20,ItemPickup=class'MoneyPickup')

    //-------------------------------------------------------------------------
    // Humiliation Default Values

    HumiliationWalkSpeed=112
    HumiliationTime=4
    HumiliationUpdateInterval=0.1

    HumiliationBlendTime=0.2

    HumiliationPrepAnim=(Anim="s_idle_crotch",Rate=1,AnimTime=2.86)
    HumiliationAnim=(Anim="Squat",Rate=1,AnimTime=6.7)

    HumiliationDanceAnims(0)=(Anim="s_dance1",Rate=1,AnimTime=6.43)
    HumiliationDanceAnims(1)=(Anim="s_dance2",Rate=1,AnimTime=3.4)
    HumiliationDanceAnims(2)=(Anim="s_dance3",Rate=1,AnimTime=3.03)

    HumiliationSound=sound'AmbientSounds.fart1'

    //-------------------------------------------------------------------------
    // Dialog Default Values

    AttackCancelDialogChance=1
    AttackCancelSounds(0)=sound'EasterSounds.CancelDialog.cancel1'
    AttackCancelSounds(1)=sound'EasterSounds.CancelDialog.cancel2'
    AttackCancelSounds(2)=sound'EasterSounds.CancelDialog.cancel3'
    AttackCancelSounds(3)=sound'EasterSounds.CancelDialog.cancel4'

    DashHitDialogChance=0.5
    DashHitDialogSound=sound'EasterSounds.Taunts.taunt4'

    DiveDialogChance=0.5
    DiveDialogSound=sound'EasterSounds.Taunts.taunt3'

    GrappleGrabDialogChance=0.5
    GrappleGrabDialogSound=sound'EasterSounds.GrappleTaunts.grabattack2'

    GrappleUppercutDialogChance=0.5
    GrappleUppercutDialogSound=sound'EasterSounds.GrappleTaunts.grabattack1'

    bPlayHitSound=true
    HitSoundInterval=2
    HitSounds(0)=sound'EasterSounds.HitSounds.hit1'
    HitSounds(1)=sound'EasterSounds.HitSounds.hit2'
    HitSounds(2)=sound'EasterSounds.HitSounds.hit3'
    HitSounds(3)=sound'EasterSounds.HitSounds.hit4'
    HitSounds(4)=sound'EasterSounds.HitSounds.hit5'
    HitSounds(5)=sound'EasterSounds.HitSounds.hit6'

    TauntSoundInterval=20
    TauntSounds(0)=sound'EasterSounds.Taunts.taunt1'
    TauntSounds(1)=sound'EasterSounds.Taunts.taunt5'

    //-------------------------------------------------------------------------
    // Music Default Values

    FightSongFadeInTime=1
    FightSongFadeOutTime=1

    FightSongName="Holy_Defication.ogg"

    //-------------------------------------------------------------------------
    // General AI Controller Default Values

    bLogDebug=false
}