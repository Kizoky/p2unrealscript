/**
 * SlimBitchController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Insert ninja skills, a love for cake, a hate for the Dude, and low standards
 * for dating as seen when it comes to Mike J
 *
 * @author Gordon Cheng
 */
class SlimBitchController extends P2EAIController;

/** Basic attack and movement variables */
var float ThinkInterval;
var float MoveReachedRadius;
var float AnimBlendTime;
var name LedgeNodeTag;

var AnimInfo IdleAnim, WalkAnim, RunAnim;

var int PathNotFoundCnt, PathNotFoundThreshold;

/** Dialog variables */
var range CombatTauntInterval;
var range PainSoundInterval;

var array<sound> CombatTaunts;
var array<sound> BansheeScreamSounds;
var array<sound> PainSounds;
var array<sound> CakeReactions;
var array<sound> VictoryTaunts;

/** Various sword swinging and hit sounds */
var array<sound> SwordSwingSounds, SwordHitSounds;

/** Slash variables shared by all basic slash attacks */
var float SlashMovementSpeed;
var float SlashRadius;
var float StartSlashRadius, StartSlashAngle;
var class<DamageType> SlashDamageType;

/** Settings for a basic horizontal slash */
var float HorizontalSlashDamage;
var float HorizontalSlashMomentum;
var float HorizontalSlashAngle;

/** Settings for a vertical slash */
var float VerticalSlashDamage;
var float VerticalSlashMomentum;
var float VerticalSlashAngle;

/** Banshee scream; Used to snap the Dude out of his super powered catnip high */
var float BansheeScreamTime;
var AnimInfo BansheeScreamAnim;

/** Leap; Jump closer to the Dude or farther for a dash attack */
var bool bUseHigherLeapArcToDude, bUseHigherLeapArcFromDude, bUseHigherLeapArcToLedge;
var float LeapToDudeSpeed, LeapBackFromDudeSpeed, LeapToLedgeSpeed;
var float LeapTowardMinDistance, LeapBackDistance, LeapToDudeOffset;
var float LeapPrepTime, LeapLandTime;
var AnimInfo LeapPrepAnim, LeapAnim, LeapLandAnim;

/** Single slash attack; Nothing fancy, just run up and slash the Dude */
var float BasicSlashTime;
var array<AnimInfo> BasicSlashAnims;

/** Dash slash attack; Here we dash toward the Dude to hit him */
var float DashSlashCooldown;
var float DashSlashMinDistance, DashSlashMinCakeDistance;
var float DashSlashSpeed, DashSlashHomingMinDistance, DashSlashStopTime;
var float DashSlashHitDampFactor, DashSlashFinisherDampFactor, DashSlashMissDampFactor, DashSlashWallHitDampFactor;
var float DashSlashPrepTime, DashSlashStartTime, DashSlashTime, DashSlashEndTime, DashSlashCakeTime;
var array<vector> DashSlashCakeCheckOffsets;
var AnimInfo DashPrepAnim, DashStartAnim, DashHitAnim, DashMissAnim, DashCakeAnim;

/** Finisher; We heavily damage the Dude with a high flying aerial attack */
var float FinisherHealthPct, FinisherCooldown;
var float FinisherUpwardSlashDamage, FinisherUpwardSlashAngle, FinisherUpwardSlashTime;
var float FinisherHeight, FinisherOffset, FinisherDudeJumpTime, FinisherBitchJumpTime;
var int FinisherAerialLoops;
var float FinisherAerialSlashDamage, FinisherAerialTime;
var float FinisherDownwardSlashDamage, FinisherDownardSlashVelocity, FinisherDownwardSlashTime;
var float FinisherFallTime, FinisherLandTime;
var AnimInfo FinisherUpwardSlashAnim, FinisherJumpAnim, FinisherAerialAnim,
    FinisherDownSlashAnim, FinisherFallAnim, FinisherLandAnim;

/** Flashbang Blinding Variables */
var bool bCanBeBlinded;

var float ReblindDelay;

var float BlindFallTime, BlindGetUpTime;
var float BlindStartTime, BlindTime, BlindEndTime;

var AnimInfo BlindFallAnim, BlindGetUpAnim;
var AnimInfo BlindStartAnim, BlindAnim, BlindEndAnim;

/** Cake stuff */
var int CakesForTakedown;

/** Gloating variables */
var float DanceAnimBlendTime;
var array<AnimInfo> GestureAnims;
var array<AnimInfo> DanceAnims;

/** Various objects and variables we should keep track of */
var bool bPlayPainSound;
var bool bCakeHit;

var bool bCanUseDashSlash;

var bool bFinisherUnlocked, bCanUseFinisher, bFinisherInterp;
var int FinisherAerialCurLoops;
var float FinisherCurTime;
var vector FinisherStart, FinisherEnd;

var bool bEndDashWithSlash;
var bool bFinisherSlashHit;

var bool bLeapToDude, bLeapToLedge;
var vector LeapDestination;
var PathNode LeapToNode;
var PathNode LeapFromNode;

var int CakesCrashedInto;

var SlimBitch SlimBitch;
var Pawn PostalDude;

// Var to have the Bitch wait a bit before attacking, so as not to rekt autosaves
var bool bPrebattleWait;
var float PrebattleWaitTime;

/** Prototype to be implemented in the states, here so we don't possibly get scope errors */
function PerformAttack();
function PerformDance();

/** Returns whether or not the Postal Dude is still a valid target
 * @return TRUE if he exists and is not dead; FALSE otherwise
 */
function bool IsPostalDudeValid() {
    return PostalDude != none && PostalDude.Health > 0;
}

/** Returns whether or not we're facing the Postal Dude
 * @return TRUE if we're facing him; FALSE otherwise
 */
function bool IsFacingPostalDude() {
    local vector PostalDudeDir;

    PostalDudeDir = PostalDude.Location;
    PostalDudeDir.Z = Pawn.Location.Z;

    return IsLocationInFacingAngle(PostalDudeDir, StartSlashAngle);
}

/** Returns whether or not Slim Bitch is close enough for the slash to connect
 * @return TRUE if the Dude is close enough to get hit; FALSE otherwise
 */
function bool IsCloseEnoughToHit() {
    if (!IsPostalDudeValid())
        return false;

    return VSize(PostalDude.Location - Pawn.Location) <= SlashRadius;
}

/** Returns whether or not Slim Bitch is close enough to perform a slash We
 * use this because we want to be close enough to the Dude so his chances of
 * running or jumping out of range is lower.
 * @return TRUE if the Dude is in a good range for a slash; FALSE otherwise
 */
function bool IsCloseEnoughToAttack() {
    if (!IsPostalDudeValid())
        return false;

    return VSize(PostalDude.Location - Pawn.Location) <= StartSlashRadius;
}

/** Returns whether or not the specified Actor is inside a SlimBitchArenaVolume
 * @param Other - Actor we're gonna test if its inside a SlimBitchArenaVolume
 * @return TRUE if the specified Actor is inside a SlimBitchArenaVolume; FALSE otherwise
 */
function bool IsInArenaVolume(Actor Other) {
    local SlimBitchArenaVolume ArenaVolume;

    foreach AllActors(class'SlimBitchArenaVolume', ArenaVolume)
        if (Other.IsInVolume(ArenaVolume))
            return true;

    return false;
}

/** Returns whether or not we're just moving normally
 * @return TRUE if we're moving normally; FALSE otherwise
 */
function bool IsPerformingNormalMove() {
    return IsInState('MoveToDude');
}

/** Returns whether or not we currently have a cake in front of us
 * @return TRUE if we have a cake in front of us; FALSE otherwise
 */
function bool IsCakeInFrontOfBitch() {
    local int i;
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    // First we check to see if a cake is three inches in front of me
    for (i=0;i<DashSlashCakeCheckOffsets.length;i++) {
        StartTrace = Pawn.Location;
        EndTrace = StartTrace + class'P2EMath'.static.GetOffset(
            Pawn.Rotation, DashSlashCakeCheckOffsets[i]);

        Other = Pawn.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

        if (SlimBitchCake(Other) != none)
            return true;
    }

    // Next check to see if the Dude is currently hiding behind a cake
    Other = Pawn.Trace(HitLocation, HitNormal, PostalDude.Location, Pawn.Location, true);

    if (SlimBitchCake(Other) != none)
        return true;

    // If not, we're clear
    return false;
}

/** Returns whether or not a cake is close to Slim Bitch
 * @return TRUE if we're close to a wedding; FALSE otherwise
 */
function bool IsCakeCloseToBitch() {
    local SlimBitchCake Cake;

    foreach DynamicActors(class'SlimBitchCake', Cake)
        if (Cake != none && VSize(Cake.Location - Pawn.Location) < DashSlashMinCakeDistance)
            return true;

    return false;
}

/** Returns whether or not the Dude is hiding behind a cake
 * @return TRUE if there's a cake in the way; FALSE otherwise
 */
function bool IsDudeBehindACake() {
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    if (!IsPostalDudeValid())
        return true;

    StartTrace = Pawn.Location;
    EndTrace = PostalDude.Location;
    Other = Pawn.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

    return (SlimBitchCake(Other) != none);
}

/** Returns whether or not we're performing a dash attack
 * @return TRUE if we're forming a dash attack; FALSE otherwise
 */
function bool IsPerformingDash() {
    return (IsInState('DashSlash') || IsInState('DashSlashEnd'));
}

/** Returns whether or not we're performing the first slash of the finisher move
 * @return TRUE if we're currently performing the upward slas; FALSE otherwise
 */
function bool IsPerformingFinisherSlash() {
    return (IsInState('FinisherSlash'));
}

/** Returns whether or not we've tripped and fallen from being hit with a flashbang
 * @return TRUE if we're currently rolling around; FALSE otherwise
 */
function bool IsFallingDownFromFlashbang() {
    return (IsInState('BlindFallDown'));
}

/** Returns whether or not we're currently soaring through the air
 * @return TRUE if we're in the leaping state; FALSE otherwise
 */
function bool IsPerformingLeap() {
    return (IsInState('LeapPrep') || IsInState('Leaping') || IsInState('LeapLand'));
}

/** Returns whether or not we're currently falling from a finisher attack
 * @return TRUE if we're falling from from a finisher; FALSE otherwise
 */
function bool IsFinisherFalling() {
    return (IsInState('FinisherFall'));
}

/** Returns whether or not we're currently in a flashbang blinded state
 * @return TRUE if we're already disabled from a flashbang; FALSE otherwise
 */
function bool IsBlinded() {
    return IsInState('BlindStart') || IsInState('Blind') || IsInState('BlindEnd') ||
        IsInState('BlindFallDown') || IsInState('BlindGetUp');
}

/** Returns whether or not Slim Bitch has reached the leaping PathNode
 * @return TRUE if we've reached it the leaping PathNode; FALSE otherwise
 */
function bool HasReachedLeapFromNode() {
    if (LeapFromNode == none)
        return false;

    return VSize(LeapFromNode.Location - Pawn.Location) <= MoveReachedRadius;
}

/** Returns whether or not we've arrived at the Postal Dude's corpse for taunting
 * @return TRUE if we're close enough to the Dude; FALSE otherwise
 */
function bool HasReachedPostalDude() {
    if (!IsPostalDudeValid())
        return true;

    return VSize(PostalDude.Location - Pawn.Location) <= MoveReachedRadius;
}

/** Returns whether or not we can can leap over to the specified location
 * @param Point - Location in the world we want to leap to
 * @param LeapSpeed - Speed at which you're gonna try to jump there
 * @return TRUE if we can backflip over to the point, FALSE otherwise
 */
function bool CanLeapToPoint(vector Point, float LeapSpeed) {
    return class'P2EMath'.static.CanHitTarget(Pawn.Location,
        LeapDestination, LeapSpeed, Pawn.PhysicsVolume.Gravity.Z);
}

/** Returns whether or not there's enough room to leap backwards
 * @return TRUE if there's enough room; FALSE otherwise
 */
function bool CanLeapBack() {
    local vector LeapBackDir, LeapBackDestination;
    local vector HitLocation, HitNormal;

    LeapBackDir = Pawn.Location - PostalDude.Location;
    LeapBackDir.Z = 0;

    LeapBackDestination = Pawn.Location + (Normal(LeapBackDir) * LeapBackDistance);

    return (Pawn.Trace(HitLocation, HitNormal, LeapDestination, Pawn.Location, true) == none);
}

/** Returns whether or not Slim Bitch can use her finisher move
 * @return TRUE if we've unlocked it, and if the cooldown time is up; FALSE otherwise
 */
function bool CanUseFinisher() {
    return (bFinisherUnlocked && bCanUseFinisher);
}

/** Returns whether or not we can be blinded
 * @return TRUE if we can be blinded; FALSE otherwise
 */
function bool CanBeBlinded() {
    return bCanBeBlinded && !IsBlinded();
}

/** Returns whether or not we should use our basic single slash attack
 * @return TRUE if we just run up to the Dude and slash him; FALSE otherwise
 */
function bool ShouldUseBasicSlashAttack() {
    if (!IsPostalDudeValid())
        return false;

    return VSize(PostalDude.Location - Pawn.Location) < DashSlashMinDistance;
}

/** Returns whether or not we should use our banshee scream attack
 * @return TRUE if we're in slowdown; FALSE otherwise
 */
function bool ShouldUseBansheeScream() {
    return Level.TimeDilation < 1;
}

/** Returns whether or not we should leap onto the raised ledges in the map
 * @return TRUE if the Postal Dude is up there but we aren't; FALSE otherwise
 */
function bool ShouldLeapOntoLedge() {
    if (!IsPostalDudeValid())
        return false;

    return (IsInArenaVolume(PostalDude) && !IsInArenaVolume(Pawn));
}

/** Returns whether or not we should, and if we can perform our leap ability
 * I didn't feel like coming up with a good elegant boolean value so I just
 * used a whole bunch of if statements.
 * @return TRUE if we should use our leap to get closer, FALSE otherwise
 */
function bool ShouldLeapTowardsDude() {
    local SlimBitchArenaVolume ArenaVolume;

    // If the Postal Dude is dead, don't
    if (!IsPostalDudeValid())
        return false;

    // If the Dude is on the ledge and we're not or vice versa, do
    if (IsInArenaVolume(PostalDude) != IsInArenaVolume(Pawn))
        return true;

    // If the Dude is far away, do
    if (VSize(PostalDude.Location - Pawn.Location) >= LeapTowardMinDistance)
        return true;

    return false;
}

/** Returns whether or not conditions are optimal for a dash attack
 * @return TRUE if we should use a dash attack; FALSE otherwise
 */
function bool ShouldUseDashSlashAttack() {
    if (!IsPostalDudeValid() || !bCanUseDashSlash || IsCakeInFrontOfBitch() || IsCakeCloseToBitch())
        return false;

    return true;
}

function bool ShouldHomeInOnPlayer() {
    return IsPostalDudeValid() && VSize(PostalDude.Location - Pawn.Location) > DashSlashHomingMinDistance;
}

/** Takes a range and returns a value between the specified min and max values
 * @param r - A range value consisting of a minimum and maximum value
 * @return A value in between the specified min and max
 */
function float GetRangeValue(range r) {
    return r.Min + (r.Max - r.Min) * FRand();
}

/** Returns a PathNode that's closest to the Postal Dude on the raised paths
 * @return PathNode that's closest to the Postal Dude on the raised path
 */
function PathNode GetLeapToPathNode() {
    local int i, Closest;
    local float Distance, ClosestDistance;
    local PathNode PathNode;
    local array<PathNode> PathNodeList;

    foreach AllActors(class'PathNode', PathNode, LedgeNodeTag) {
        PathNodeList.Insert(PathNodeList.length, 1);
        PathNodeList[PathNodeList.length - 1] = PathNode;
    }

    Closest = -1;
    ClosestDistance = 3.4028e38;

    for (i=0;i<PathNodeList.length;i++) {
        Distance = VSize(PathNodeList[i].Location - PostalDude.Location);

        if (Distance < ClosestDistance) {
            ClosestDistance = Distance;
            Closest = i;
        }
    }

    if (Closest == -1)
        return none;
    else
        return PathNodeList[Closest];
}

/** Returns a PathNode that we should move to and leap from to get to the Dude
 * @return PathNode that should be leapt from in order to reach the Dude
 */
function PathNode GetLeapFromPathNode() {
    local int i, Closest;
    local float Distance, ClosestDistance;
    local PathNode PathNode;
    local array<PathNode> PathNodeList;

    foreach AllActors(class'PathNode', PathNode) {
        if (PathNode.Tag != LedgeNodeTag) {
            PathNodeList.Insert(PathNodeList.length, 1);
            PathNodeList[PathNodeList.length - 1] = PathNode;
        }
    }

    Closest = -1;
    ClosestDistance = 3.4028e38;

    for (i=0;i<PathNodeList.length;i++) {
        Distance = VSize(PathNodeList[i].Location - PostalDude.Location);

        if (Distance < ClosestDistance) {
            ClosestDistance = Distance;
            Closest = i;
        }
    }

    if (Closest == -1)
        return none;
    else
        return PathNodeList[Closest];
}

/** Sets up various values to prepare to leap to the ledge */
function SetupLeapToLedge() {
    LeapToNode = GetLeapToPathNode();
    LeapFromNode = GetLeapFromPathNode();
    LeapDestination = LeapToNode.Location;

    bLeapToDude = false;
    bLeapToLedge = true;

    if (CanLeapToPoint(LeapToNode.Location, LeapToLedgeSpeed))
        GotoState('LeapPrep');
    else
        GotoState('MoveToLeapNode');
}

/** Sets up various values to prepare a leap to the Postal Dude */
function SetupLeapToDude() {
    local vector LeapDir;

    LeapDir = Pawn.Location - PostalDude.Location;
    LeapDir.Z = 0;

    LeapDestination = PostalDude.Location + (Normal(LeapDir) * LeapToDudeOffset);

    if (CanLeapToPoint(LeapDestination, LeapToDudeSpeed)) {
        bLeapToDude = true;
        bLeapToLedge = false;
        GotoState('LeapPrep');
    }
}

/** Setups up various values to prepare a leap away from the Postal Dude */
function SetupLeapAwayFromDude() {
    local vector LeapBackDir;

    LeapBackDir = Pawn.Location - PostalDude.Location;
    LeapBackDir.Z = 0;

    LeapDestination = Pawn.Location + (Normal(LeapBackDir) * LeapBackDistance);

    if (CanLeapToPoint(LeapDestination, LeapBackFromDudeSpeed)) {
        bLeapToDude = false;
        bLeapToLedge = false;
        GotoState('LeapPrep');
    }
}

/** Sends the Slim Bitch into the air towards her destination
 * @param LeapSpeed - Speed in which we launch ourselves into the air
 * @param bUseHigherArc - Whether or not we use the higher trajectory arc
 */
function LeapToDestination(float LeapSpeed, bool bUseHigherArc) {
    local rotator LeapTrajectory;

    LeapTrajectory = class'P2EMath'.static.GetProjectileTrajectory(Pawn.Location,
        LeapDestination, LeapSpeed, vect(0,0,0), 0,
        Pawn.PhysicsVolume.Gravity.Z,, bUseHigherArc);

    Pawn.AirSpeed = LeapSpeed * 2;
    Pawn.SetPhysics(PHYS_Falling);
    Pawn.Velocity = vector(LeapTrajectory) * LeapSpeed;
}

/** Given a Pawn, sends the poor bastard flying
 * Copied from the EasterBunnyController
 * @param Other - Pawn to send flying into the air
 * @param FlyVelocity - The XY velocity and Z velocity to send them flying at
 */
function SendPawnFlying(Pawn Other, float FlyVelocity) {
    local vector OtherLocation, PawnLocation;
    local vector FlyDir;

    // Let's not screw with ragdolls
    if (Other.Physics == PHYS_KarmaRagDoll)
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

/** Perform the Postal Dude finisher movement interpolation here
 * @param DeltaTime - Time in seconds since the last Tick
 */
function FinisherInterp(float DeltaTime) {
    local vector FinisherInterpLoc;

    if (bFinisherInterp) {
        FinisherCurTime = FMin(FinisherCurTime + DeltaTime, FinisherDudeJumpTime);
        FinisherInterpLoc = FinisherStart + (FinisherEnd - FinisherStart) *
            class'P2EMath'.static.SineEaseIn(FinisherCurTime, FinisherDudeJumpTime);

        PostalDude.SetLocation(FinisherInterpLoc);
    }
}

/** Overriden to ensure that Slim Bitch's movement speed is always reset to normal */
function SpeedInterpolationFinished() {
    if (IsPostalDudeValid()) {
        Pawn.AirSpeed = Pawn.default.AirSpeed;
        SlimBitch.GroundSpeed = SlimBitch.RunSpeed;
    }
    else {
        Pawn.AirSpeed = Pawn.default.AirSpeed;
        SlimBitch.GroundSpeed = SlimBitch.WalkSpeed;
    }
}

/** Overriden so we can do stuff based on stuff we bumped into */
event Bump(Actor Other) {
    if (IsPerformingDash() || IsFallingDownFromFlashbang()) {
        if (SlimBitchCake(Other) != none) {
            bCakeHit = true;
            CakesCrashedInto++;

            if ((float(CakesCrashedInto) / float(CakesForTakedown)) >= 0.5)
                bFinisherUnlocked = true;

            SlimBitchCake(Other).BlowThisUp(0, Pawn.Location, Pawn.Velocity * Pawn.Mass);
        }
        else
            bCakeHit = false;

        if (CakesCrashedInto == CakesForTakedown)
            Pawn.Died(self, class'P2Damage', Pawn.Location);
        else if (StaticMeshActor(Other) != none || SlimBitchCake(Other) != none)
            GotoState('DashSlashWallHit');
    }
}

/** Overriden to initialize some stuff */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    aPawn.SetPhysics(PHYS_Falling);

    SlimBitch = SlimBitch(aPawn);

    if (SlimBitch != none)
        SlimBitch.SlimBitchController = self;

    AddTimer(0.1, 'FindPostalDude', true);

    AddTimer(GetRangeValue(CombatTauntInterval), 'PlayCombatTauntSound', false);
}

/** Overriden to implement Multi-Timer functionality */
function TimerFinished(name ID) {
    switch(ID) {
        case 'FindPostalDude':
            FindPostalDude();
            break;

        case 'EnableDashSlash':
            bCanUseDashSlash = true;
            break;

        case 'EnableFinisher':
            bCanUseFinisher = true;
            break;

        case 'EnablePainSound':
            bPlayPainSound = true;
            break;

        case 'PlayCombatTauntSound':
            PlayCombatTauntSound();
            break;

        case 'EnableBlind':
            bCanBeBlinded = true;
            break;
    }
}

/** Iterates through the Pawns in the map until we find the player */
function FindPostalDude() {
    local Pawn Pawn;

    foreach DynamicActors(class'Pawn', Pawn) {
        if (Pawn.Controller != none && Pawn.Controller.bIsPlayer) {
            PostalDude = Pawn;
            break;
        }
    }

    if (PostalDude != none) {
        RemoveTimerByID('FindPostalDude');
        DecideNextMove();
    }
}

/** Take a look at our current situation and decide what to do next */
function DecideNextMove() {
    // Prioritize canceling Catnip first and foremost
    if (ShouldUseBansheeScream())
        GotoState('BansheeScream');
		
	// Pre-battle grace period
	if (!bPrebattleWait)
		GotoState('PrebattleWait');

    // Next, we should use the dash attack
    else if (ShouldUseDashSlashAttack()) {

        // If we can make room to perform a dash, do so
        if (CanLeapBack())
            SetupLeapAwayFromDude();

        // Otherwise just perform the dash
        else
            GotoState('DashSlashPrep');
    }
    else {

        // If we're not performing a dash attack, then perform basic attacks
        if (IsCloseEnoughToAttack() && IsFacingPostalDude()) {
            if (CanUseFinisher())
                GotoState('FinisherSlash');
            else
                GotoState('SlashPlayer');
        }
        else
            GotoState('MoveToDude');
    }
}

/** Play our sword swinging sound */
function PlaySwordSwingSound() {
    Pawn.PlaySound(SwordSwingSounds[Rand(SwordSwingSounds.length)], SLOT_Misc, 1, false, 300);
}

/** Play our body hit sounds */
function PlayBodyHitSound() {
    PostalDude.PlaySound(SwordHitSounds[Rand(SwordHitSounds.length)], SLOT_Misc, 1, false, 300);
}

/** Play our banshee scream sound */
function PlayBansheeScreamSound() {
    local float SoundDuration;
    local sound BansheeScreamSound;

    BansheeScreamSound = BansheeScreamSounds[Rand(BansheeScreamSounds.length)];
    SoundDuration = GetSoundDuration(BansheeScreamSound);
    Pawn.PlaySound(BansheeScreamSound, SLOT_Talk, 2, false, 500);

    bPlayPainSound = false;
    AddTimer(SoundDuration, 'EnablePainSound', false);
}

/** Play our reaction sound to accidently crashing in a wedding cake */
function PlayCakeReactionSound() {
    local float SoundDuration;
    local sound CakeReactionSound;

    CakeReactionSound = CakeReactions[Rand(CakeReactions.length)];
    SoundDuration = GetSoundDuration(CakeReactionSound);
    Pawn.PlaySound(CakeReactionSound, SLOT_Talk, 2, false, 500);

    bPlayPainSound = false;
    AddTimer(SoundDuration, 'EnablePainSound', false);
}

/** Play a pain sound */
function PlayPainSound() {
    local sound PainSound;

    PainSound = PainSounds[Rand(PainSounds.length)];
    Pawn.PlaySound(PainSound, SLOT_Talk, 2, false, 500);

    bPlayPainSound = false;
    AddTimer(GetRangeValue(PainSoundInterval), 'EnablePainSound', false);
}

/** Play a normal combat taunt sound */
function PlayCombatTauntSound() {
    local float SoundDuration;
    local sound CombatTaunt;

    CombatTaunt = CombatTaunts[Rand(CombatTaunts.length)];
    Pawn.PlaySound(CombatTaunt, SLOT_Talk, 2, false, 500);
    SoundDuration = GetSoundDuration(CombatTaunt);

    AddTimer(SoundDuration + GetRangeValue(CombatTauntInterval),
        'PlayCombatTauntSound', false);
}

/** Play a victory taunt sound
 * @return Duration of the victory comment we played
 */
function float PlayVictoryTauntSound() {
    local sound VictoryTaunt;

    VictoryTaunt = VictoryTaunts[Rand(VictoryTaunts.length)];
    Pawn.PlaySound(VictoryTaunt, SLOT_Talk, 2, false, 500);

    return GetSoundDuration(VictoryTaunt);
}

/** Called whenever Slim Bitch cannot find a path to the Postal Dude */
function CantFindPathToDude() {
    LogDebug("WARNING: Could not find a path to the Postal Dude");
    GotoState('Idle');
}

/** Notification from our Pawn that we just took some damage */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    if (SlimBitch == none)
        return;

    if (bPlayPainSound)
        PlayPainSound();

    if (ClassIsChildOf(DamageType, class'FlashBangDamage') && CanBeBlinded()) {
        bCanBeBlinded = false;

        if (IsPerformingDash())
            GotoState('BlindFallDown');
        else
            GotoState('BlindStart');
    }

    if (!bFinisherUnlocked && SlimBitch.Health < (SlimBitch.HealthMax * FinisherHealthPct))
        bFinisherUnlocked = true;
}

/** Notification from our Pawn that she died */
function NotifyPawnDied() {
    if (IsPostalDudeValid() && PostalDude.Physics == PHYS_Flying)
        PostalDude.SetPhysics(PHYS_Falling);
}

/** Notification from our Pawn to perform a banshee scream attack */
function NotifyBansheeScream() {
    PlayBansheeScreamSound();
}

/** Notification from our Pawn to play our sword swing sound */
function NotifyStartSwing() {
    PlaySwordSwingSound();
}

/** Notification from our Pawn to perform basic slash */
function NotifyHorizontalSlash() {
    if (IsCloseEnoughToHit() && IsInFacingAngle(PostalDude, HorizontalSlashAngle)) {
        PostalDude.TakeDamage(HorizontalSlashDamage, Pawn, PostalDude.Location,
        Normal(PostalDude.Location - Pawn.Location) * HorizontalSlashMomentum,
        SlashDamageType);
        PlayBodyHitSound();
    }
}

/** Notification from our Pawn to perform basic vertical slash */
function NotifyVerticalSlash() {
    if (IsCloseEnoughToHit() && IsInFacingAngle(PostalDude, VerticalSlashAngle)) {
        PostalDude.TakeDamage(VerticalSlashDamage, Pawn, PostalDude.Location,
        Normal(PostalDude.Location - Pawn.Location) * VerticalSlashMomentum,
        SlashDamageType);
        PlayBodyHitSound();
    }
}

/** Notification from our Pawn to perform an upward slash */
function NotifySlashUp() {
    if (IsCloseEnoughToHit() && IsInFacingAngle(PostalDude, FinisherUpwardSlashAngle)) {
        PostalDude.TakeDamage(FinisherUpwardSlashDamage, Pawn, PostalDude.Location,
        vect(0,0,0), SlashDamageType);

        bFinisherSlashHit = true;
        bCanUseFinisher = false;

        FinisherCurTime = 0;
        FinisherStart = PostalDude.Location;
        FinisherEnd = FinisherStart;
        FinisherEnd.Z += FinisherHeight;

        PostalDude.SetPhysics(PHYS_Flying);

        PlayBodyHitSound();

        bFinisherInterp = true;

        AddTimer(FinisherCooldown, 'EnableFinisher', false);
    }
    else
        bFinisherSlashHit = false;
}

/** Notification from our Pawn to perform a low damage, but rapid aerial slash */
function NotifyAerialSlash() {
    PostalDude.TakeDamage(FinisherAerialSlashDamage, Pawn, PostalDude.Location,
        vect(0,0,0), SlashDamageType);

    PlayBodyHitSound();
}

/** Notification from our Pawn to perform a downward slash */
function NotifySlashDown() {
    PostalDude.TakeDamage(FinisherDownwardSlashDamage, Pawn, PostalDude.Location,
        vect(0,0,0), SlashDamageType);

    PlayBodyHitSound();

    bFinisherInterp = false;

    PostalDude.SetPhysics(PHYS_Falling);
    PostalDude.Velocity = Normal(PostalDude.Location - Pawn.Location) * FinisherDownardSlashVelocity;
}

/** We mostly use this state to decide what to do next */
state Idle
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        LoopAnimInfo(IdleAnim, AnimBlendTime);

        SetTimer(ThinkInterval, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

// Prebattle Wait - Bitch waits for a second before attacking so as not to rekt autosaves
state PrebattleWait extends Idle
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

		bPrebattleWait = true;

        FaceForward();

        LoopAnimInfo(IdleAnim, AnimBlendTime);

        SetTimer(PrebattleWaitTime, false);
    }
}

/** Move closer to the Dude so we can hit them with our sword */
state MoveToDude
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = none;

        if (IsPostalDudeValid())
            LoopAnimInfo(RunAnim, AnimBlendTime);
        else
            LoopAnimInfo(WalkAnim, AnimBlendTime);

        Pawn.SetPhysics(PHYS_Walking);

        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        if (!IsPostalDudeValid() && HasReachedPostalDude())
            GotoState('TauntDeadDude');
        else if (ShouldUseBansheeScream())
            GotoState('BansheeScream');
        else if (ShouldUseDashSlashAttack()) {
            if (CanLeapBack())
                SetupLeapAwayFromDude();
            else
                GotoState('DashSlashPrep');
        }
        else if (IsCloseEnoughToAttack() && IsFacingPostalDude()) {
            if (CanUseFinisher())
                GotoState('FinisherSlash');
            else
                GotoState('SlashPlayer');
        }
        else if (ShouldLeapOntoLedge())
            SetupLeapToLedge();
        else if (ShouldLeapTowardsDude())
            SetupLeapToDude();
    }

Begin:
    while (!IsCloseEnoughToAttack()) {
        if (ActorReachable(PostalDude)) {
            PathNotFoundCnt = 0;
            MoveToward(PostalDude);
        }
		else {
			MoveTarget = FindPathToward(PostalDude);

            if (MoveTarget != none) {
                PathNotFoundCnt = 0;
				MoveToward(MoveTarget);
            }
            else {
                PathNotFoundCnt++;
                Sleep(0.1);

                if (PathNotFoundCnt == PathNotFoundThreshold)
                    CantFindPathToDude();
            }
		}
    }

    if (!IsPostalDudeValid())
        GotoState('TauntDeadDude');
    else {
        if (CanUseFinisher())
            GotoState('FinisherSlash');
        else
            GotoState('SlashPlayer');
    }
}

/** Move to a good leaping location so we can leap onto the ledges */
state MoveToLeapNode
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = none;

        if (IsPostalDudeValid())
            LoopAnimInfo(RunAnim, AnimBlendTime);
        else
            LoopAnimInfo(WalkAnim, AnimBlendTime);

        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        local vector LeapDir;
        local PathNode RaisedPathNode;

        LeapToNode = GetLeapToPathNode();
        LeapFromNode = GetLeapFromPathNode();
        LeapDestination = LeapToNode.Location;

        bLeapToDude = false;
        bLeapToLedge = true;

        if (ShouldUseBansheeScream())
            GotoState('BansheeScream');
        else if (!IsInArenaVolume(PostalDude))
            GotoState('MoveToDude');
        else if (HasReachedLeapFromNode() && CanLeapToPoint(LeapToNode.Location, LeapToLedgeSpeed))
            GotoState('LeapPrep');
    }

Begin:
    while (!HasReachedLeapFromNode()) {
        if (ActorReachable(LeapFromNode)) {
            PathNotFoundCnt = 0;
            MoveToward(LeapFromNode);
        }
		else {
			MoveTarget = FindPathToward(LeapFromNode);

            if (MoveTarget != none) {
                PathNotFoundCnt = 0;
				MoveToward(MoveTarget);
            }
            else {
                PathNotFoundCnt++;
                Sleep(0.1);

                if (PathNotFoundCnt == PathNotFoundThreshold)
                    CantFindPathToDude();
            }
		}
    }

    if (CanLeapToPoint(LeapToNode.Location, LeapToLedgeSpeed))
        GotoState('LeapPrep');
    else {
        LogDebug("Cannot leap from " $ LeapFromNode $ " to " $ LeapToNode);
        GotoState('MoveToDude');
    }
}

/** Say some closing comments about the dead Postal Dude */
state TauntDeadDude
{
    function BeginState() {
        local int i;
        local float VictoryDuration;

        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = PostalDude;

        i = Rand(GestureAnims.length);
        VictoryDuration = PlayVictoryTauntSound();

        PlayAnimByDuration(GestureAnims[i], VictoryDuration);

        SetTimer(VictoryDuration, false);

        RemoveTimerByID('PlayCombatTauntSound');
    }

    function Timer() {
        GotoState('Dance');
    }

Begin:
    StopMoving();
}

/** We've killed the player since he or she sucks, now gloat */
state Dance
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = none;
        FocalPoint = Pawn.Location + vector(Pawn.Rotation) * 256;

        PerformDance();
    }

    function Timer() {
        PerformDance();
    }

    function PerformDance() {
        local int i;

        i = Rand(DanceAnims.length);

        PlayAnimInfo(DanceAnims[i], DanceAnimBlendTime);
        SetTimer(DanceAnims[i].AnimTime, false);
    }

Begin:
    StopMoving();
}

/** Shwing! Blood squirts! This is just a basic single slash */
state SlashPlayer
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Pawn.AirSpeed = SlashMovementSpeed;
        Pawn.GroundSpeed = SlashMovementSpeed;

        Pawn.SetRotation(rotator(PostalDude.Location - Pawn.Location));
        FaceForward();

        PerformAttack();
    }

    function PerformAttack() {
        local int SlashAttack;

        SlashAttack = Rand(BasicSlashAnims.length);

        InterpolateSpeed(BasicSlashTime, 0, INTERP_SineEaseIn);
        PlayAnimByDuration(BasicSlashAnims[SlashAttack], BasicSlashTime, AnimBlendTime);
        SetTimer(BasicSlashTime, false);
    }

    function Timer() {
        if (ShouldUseBansheeScream())
            GotoState('BansheeScream');
        else if (ShouldUseDashSlashAttack()) {
            if (CanLeapBack())
                SetupLeapAwayFromDude();
            else
                GotoState('DashSlashPrep');
        }
        else {
            if (IsCloseEnoughToAttack() && IsFacingPostalDude())
                PerformAttack();
            else
                GotoState('MoveToDude');
        }
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = vector(Pawn.Rotation) * Pawn.GroundSpeed;
    }

Begin:
    StopMoving();
}

/** Dude is cheating by slowing down time, let's snap him out of it! */
state BansheeScream
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = PostalDude;

        if (Level.TimeDilation < 1 && P2Player(PostalDude.Controller) != none)
            P2Player(PostalDude.Controller).CatnipUseTime = 0.1;

        PlayAnimByDuration(BansheeScreamAnim, BansheeScreamTime, AnimBlendTime);
        SetTimer(BansheeScreamTime, false);

        SetTimerPauseByID('PlayCombatTauntSound', true);
    }

    function EndState() {
        SetTimerPauseByID('PlayCombatTauntSound', false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Crouch down in preparation for a massive leap! */
state LeapPrep
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = none;
        FocalPoint = Pawn.Location + Normal(LeapDestination - Pawn.Location) * 32768;

        PlayAnimByDuration(LeapPrepAnim, LeapPrepTime, AnimBlendTime);
        SetTimer(LeapPrepTime, false);
    }

    function Timer() {
        GotoState('Leaping');
    }

Begin:
    StopMoving();
}

/** Soaring through the sky so fancy-free! */
state Leaping
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        LoopAnimInfo(LeapAnim, AnimBlendTime);

        if (bLeapToLedge)
            LeapToDestination(LeapToLedgeSpeed, bUseHigherLeapArcToLedge);
        else if (bLeapToDude)
            LeapToDestination(LeapToDudeSpeed, bUseHigherLeapArcToDude);
        else
            LeapToDestination(LeapBackFromDudeSpeed, bUseHigherLeapArcFromDude);
    }
}

/** Play a cool three point stance and proceed to kill the crap out of the Dude */
state LeapLand
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        // Don't blend the animation here, it looks ugly
        PlayAnimByDuration(LeapLandAnim, LeapLandTime);
        SetTimer(LeapLandTime, false);
    }

    function Timer() {
        if (ShouldUseBansheeScream())
            GotoState('BansheeScream');
        else if (ShouldUseDashSlashAttack())
            GotoState('DashSlashPrep');
        else {
            if (IsCloseEnoughToAttack() && IsFacingPostalDude()) {
                if (CanUseFinisher())
                    GotoState('FinisherSlash');
                else
                    GotoState('SlashPlayer');
            }
            else
                GotoState('MoveToDude');
        }
    }

Begin:
    StopMoving();
}

/** Strike a deadly pose before we dash toward the Dude for a slash */
state DashSlashPrep
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = PostalDude;

        PlayAnimByDuration(DashPrepAnim, DashSlashPrepTime, AnimBlendTime);
        SetTimer(DashSlashPrepTime, false);
    }

    function Timer() {
        if (IsCakeInFrontOfBitch())
            GotoState('MoveToDude');
        else
            GotoState('DashSlash');
    }

Begin:
    StopMoving();
}

/** Here we go from our dash to our slash */
state DashSlash
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCanUseDashSlash = false;
        AddTimer(DashSlashCooldown, 'EnableDashSlash', false);

        FaceForward();
    }

    function EndState() {

    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        if (!IsPostalDudeValid())
            GotoState('DashSlashEnd');

        Pawn.PlayAnim('DashSliceLoop',, AnimBlendTime);

        if (ShouldHomeInOnPlayer()) {
            Pawn.SetRotation(rotator(PostalDude.Location - Pawn.Location));
            FaceForward();
        }

        SlimBitch.AirSpeed = DashSlashSpeed;
        SlimBitch.GroundSpeed = DashSlashSpeed;

        Pawn.Velocity = vector(Pawn.Rotation) * DashSlashSpeed;
        Pawn.Velocity.Z = -1000;

        // If the Dude has side stepped or if he's in range
        if (!IsInFacingAngle(PostalDude, 180) || IsCloseEnoughToHit() || IsDudeBehindACake()) {
            bEndDashWithSlash = IsInFacingAngle(PostalDude, VerticalSlashAngle);
            GotoState('DashSlashEnd');
        }
    }

Begin:
    StopMoving();
}

/** End our dash either with slashing the Dude or come to a skidding stop */
state DashSlashEnd
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        if (bEndDashWithSlash) {
            Pawn.GroundSpeed *= DashSlashHitDampFactor;
            InterpolateSpeed(DashSlashTime, 0, INTERP_SineEaseIn);
            PlayAnimByDuration(DashHitAnim, DashSlashTime, AnimBlendTime);
            SetTimer(DashSlashTime, false);
        }
        else {
            Pawn.GroundSpeed *= DashSlashMissDampFactor;
            InterpolateSpeed(DashSlashStopTime, 0, INTERP_SineEaseIn);
            PlayAnimByDuration(DashMissAnim, DashSlashEndTime, AnimBlendTime);
            SetTimer(DashSlashEndTime, false);
        }
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = vector(Pawn.Rotation) * Pawn.GroundSpeed;
        Pawn.Velocity.Z = -1000;
    }

    function Timer() {
        DecideNextMove();
    }
}

/** We've instead managed to hit a wall, so recoil a bit from the hit */
state DashSlashWallHit
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        if (bCakeHit)
            PlayCakeReactionSound();

        Pawn.GroundSpeed *= DashSlashWallHitDampFactor;

        InterpolateSpeed(DashSlashCakeTime, 0, INTERP_SineEaseIn);
        PlayAnimByDuration(DashCakeAnim, DashSlashCakeTime, AnimBlendTime);
        SetTimer(DashSlashCakeTime, false);

        SetTimerPauseByID('PlayCombatTauntSound', true);
    }

    function EndState() {
        SetTimerPauseByID('PlayCombatTauntSound', false);
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = vector(Pawn.Rotation) * -Pawn.GroundSpeed;
        Pawn.Velocity.Z = -1000;
    }

    function Timer() {
        DecideNextMove();
    }
}

/** Slim Bitch has been hit with a flashbang while dashing and basically tripped */
state BlindFallDown
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        InterpolateSpeed(BlindFallTime, 0, INTERP_SineEaseIn);

        PlayAnimByDuration(BlindFallAnim, BlindFallTime, AnimBlendTime);
        SetTimer(BlindFallTime, false);
    }

    function EndState() {
        // We need this here because we may not reach the BlindGetUp state
        AddTimer(ReblindDelay, 'EnableBlind', false);
    }

    function Timer() {
        GotoState('BlindGetUp');
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = vector(Pawn.Rotation) * Pawn.GroundSpeed;
        Pawn.Velocity.Z = -1000;
    }

Begin:
    StopMoving();
}

/** After we've had a bit of a tumble, get straight back up */
state BlindGetUp
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(BlindGetUpAnim, BlindGetUpTime, AnimBlendTime);
        SetTimer(BlindGetUpTime, false);
    }

    function EndState() {
        Pawn.GroundSpeed = Pawn.default.GroundSpeed;

        AddTimer(ReblindDelay, 'EnableBlind', false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Just got hit with a flashbang, so quickly cover our eyes */
state BlindStart
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(BlindStartAnim, BlindStartTime, AnimBlendTime);
        SetTimer(BlindStartTime, false);
    }

    function Timer() {
        GotoState('Blind');
    }

Begin:
    StopMoving();
}

/** Loop our blind animation until the effect has worn off */
state Blind
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        LoopAnimInfo(BlindAnim);
        SetTimer(BlindTime, false);
    }

    function Timer() {
        GotoState('BlindEnd');
    }

Begin:
    StopMoving();
}

/** Blinding effect has finally worn off, now we get back to kicking ass */
state BlindEnd
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(BlindEndAnim, BlindEndTime, AnimBlendTime);
        SetTimer(BlindEndTime, false);
    }

    function EndState() {
        AddTimer(ReblindDelay, 'EnableBlind', false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** An alternate to the Dash slash, this one sends the Dude into the air */
state FinisherSlash
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        InterpolateSpeed(FinisherUpwardSlashTime, 0, INTERP_SineEaseIn);

        PlayAnimByDuration(FinisherUpwardSlashAnim, FinisherUpwardSlashTime, AnimBlendTime);
        SetTimer(FinisherUpwardSlashTime, false);
    }

    function Timer() {
        if (bFinisherSlashHit)
            GotoState('FinisherJump');
        else
            DecideNextMove();
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.SetRotation(rotator(PostalDude.Location - Pawn.Location));

        Pawn.Velocity = vector(Pawn.Rotation) * Pawn.GroundSpeed;
        Pawn.Velocity.Z = -1000;

        FinisherInterp(DeltaTime);
    }
}

/** Leap into the air to finish off the Dude */
state FinisherJump
{
    function BeginState() {
        local vector PostalDudeXYLoc, SlimBitchXYLoc;
        local vector FinisherJumpDir, FinisherJumpLoc;

        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = PostalDude;

        PostalDudeXYLoc = PostalDude.Location;
        PostalDudeXYLoc.Z = 0;

        SlimBitchXYLoc = SlimBitch.Location;
        SlimBitchXYLoc.Z = 0;

        FinisherJumpDir = Normal(SlimBitchXYLoc - PostalDudeXYLoc);

        FinisherJumpLoc = FinisherEnd + FinisherJumpDir * FinisherOffset;

        Pawn.SetPhysics(PHYS_Flying);

        InterpolateByDuration(FinisherBitchJumpTime, FinisherJumpLoc, INTERP_SineEaseIn);

        PlayAnimByDuration(FinisherJumpAnim, FinisherBitchJumpTime, AnimBlendTime);
        SetTimer(FinisherBitchJumpTime, false);
    }

    function Timer() {
        GotoState('FinisherAerial');
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        FinisherInterp(DeltaTime);
    }

Begin:
    StopMoving();
}

/** Blade Mode */
state FinisherAerial
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = PostalDude;

        FinisherAerialCurLoops = 0;

        PerformAttack();
    }

    function PerformAttack() {
        FinisherAerialCurLoops++;
        PlayAnimByDuration(FinisherAerialAnim, FinisherAerialTime, AnimBlendTime);
        SetTimer(FinisherAerialTime, false);
    }

    function Timer() {
        if (FinisherAerialCurLoops < FinisherAerialLoops)
            PerformAttack();
        else
            GotoState('FinisherDownSlash');
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        if (!IsPostalDudeValid())
            GotoState('FinisherFall');

        PostalDude.SetLocation(FinisherEnd);
    }

Begin:
    StopMoving();
}

/** Finally we send the Dude back to ground with a downward slash */
state FinisherDownSlash
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(FinisherDownSlashAnim, FinisherDownwardSlashTime, AnimBlendTime);
        SetTimer(FinisherDownwardSlashTime, false);
    }

    function Timer() {
        GotoState('FinisherFall');
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        if (bFinisherInterp)
            PostalDude.SetLocation(FinisherEnd);
    }

Begin:
    StopMoving();
}

/** We've just finished our Finisher attack, so now let's fall back down */
state FinisherFall
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        Pawn.SetPhysics(PHYS_Falling);

        PlayAnimByDuration(FinisherFallAnim, FinisherFallTime, AnimBlendTime);
    }

    function Timer() {
        // STUB
    }
}

/** Play our three point stance animation when we land */
state FinisherLand
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(FinisherLandAnim, FinisherLandTime, AnimBlendTime);
        SetTimer(FinisherLandTime, false);
    }

    function Timer() {
        DecideNextMove();
    }
}

defaultproperties
{
    bLogDebug=false

    bControlAnimations=true

    bPlayPainSound=true

    bCanUseFinisher=true
    bCanUseDashSlash=true
    bCanBeBlinded=true

    ThinkInterval=0.1
    MoveReachedRadius=128
    AnimBlendTime=0.1

    CombatTauntInterval=(Min=10,Max=15)
    PainSoundInterval=(Min=7,Max=10)

    PathNotFoundThreshold=10

    LedgeNodeTag="LedgeNode"

    IdleAnim=(Anim="bitch_idle",Rate=1,AnimTime=3.36)
    WalkAnim=(Anim="s_walk_4",Rate=1,AnimTime=1.16)
    RunAnim=(Anim="bitch_run",Rate=1,AnimTime=0.63)

    //--------------------------------------------------------------------------
    // Katana Slash Damaging

    SlashMovementSpeed=750
    SlashRadius=150
    StartSlashRadius=175
    StartSlashAngle=30

    HorizontalSlashDamage=30
    HorizontalSlashMomentum=60000
    HorizontalSlashAngle=180

    VerticalSlashDamage=30
    VerticalSlashMomentum=60000
    VerticalSlashAngle=45

    SlashDamageType=class'SlimBitchKatanaDamage'

    //--------------------------------------------------------------------------
    // Banshee Scream

    BansheeScreamTime=1
    BansheeScreamAnim=(Anim="bitch_shriek",AnimTime=2.03)

    //--------------------------------------------------------------------------
    // Leap

    bUseHigherLeapArcToDude=false
    bUseHigherLeapArcFromDude=true
    bUseHigherLeapArcToLedge=true

    LeapToDudeSpeed=1500
    LeapBackFromDudeSpeed=1500
    LeapToLedgeSpeed=1500

    LeapTowardMinDistance=750
    LeapBackDistance=1000
    LeapToDudeOffset=0

    LeapPrepTime=0.53
    LeapLandTime=0.7

    LeapPrepAnim=(Anim="LeapStart",AnimTime=0.53)
    LeapAnim=(Anim="LeapLoop",Rate=1,AnimTime=0.36)
    LeapLandAnim=(Anim="LeapLand",AnimTime=0.7)

    //--------------------------------------------------------------------------
    // Basic Slash Attack

    BasicSlashTime=1

    BasicSlashAnims(0)=(Anim="bitch_slash1",AnimTime=1.36)
    BasicSlashAnims(1)=(Anim="bitch_slash2",AnimTime=1.36)

    //--------------------------------------------------------------------------
    // Dash Slash Attack

    DashSlashCooldown=5
    DashSlashMinDistance=500
    DashSlashMinCakeDistance=250

    DashSlashSpeed=2000
    DashSlashHomingMinDistance=500
    DashSlashStopTime=1

    DashSlashHitDampFactor=0.35
    DashSlashFinisherDampFactor=0.25
    DashSlashMissDampFactor=0.5
    DashSlashWallHitDampFactor=0.3

    DashSlashPrepTime=1
    DashSlashStartTime=0.9
    DashSlashTime=1
    DashSlashEndTime=0.86
    DashSlashCakeTime=1.38

    DashSlashCakeCheckOffsets(0)=(X=256,Y=-256,Z=0)
    DashSlashCakeCheckOffsets(1)=(X=256,Y=-128,Z=0)
    DashSlashCakeCheckOffsets(2)=(X=256,Y=0,Z=0)
    DashSlashCakeCheckOffsets(3)=(X=256,Y=128,Z=0)
    DashSlashCakeCheckOffsets(4)=(X=256,Y=256,Z=0)

    DashPrepAnim=(Anim="DashSlicePrep",AnimTime=1)
    DashStartAnim=(Anim="DashSliceStart",AnimTime=0.9)
    DashHitAnim=(Anim="DashSliceHit",AnimTime=1.36)
    DashMissAnim=(Anim="DashSliceMiss",AnimTime=0.86)
    DashCakeAnim=(Anim="DashSliceCakeSmash",AnimTime=2.76)

    //--------------------------------------------------------------------------
    // Finisher Attack

    FinisherHealthPct=0.5
    FinisherCooldown=20

    FinisherUpwardSlashDamage=30
    FinisherUpwardSlashAngle=120
    FinisherUpwardSlashTime=1.3

    FinisherHeight=1000
    FinisherOffset=150
    FinisherDudeJumpTime=1.93
    FinisherBitchJumpTime=0.93

    FinisherAerialLoops=4
    FinisherAerialSlashDamage=6
    FinisherAerialTime=0.68

    FinisherDownwardSlashDamage=30
    FinisherDownardSlashVelocity=500
    FinisherDownwardSlashTime=2.03

    FinisherFallTime=0.03
    FinisherLandTime=1.8

    FinisherUpwardSlashAnim=(Anim="FinisherUppercut",AnimTime=1.53)
    FinisherJumpAnim=(Anim="FinisherAirJump",AnimTime=0.93)
    FinisherAerialAnim=(Anim="FinisherFlurrySlice",AnimTime=1.36)
    FinisherDownSlashAnim=(Anim="FinisherDownSlice",AnimTime=2.03)
    FinisherFallAnim=(Anim="FinisherFall",AnimTime=0.03)
    FinisherLandAnim=(Anim="DiveKickEnd",AnimTime=1.8)

    //--------------------------------------------------------------------------
    // Flashbang Blinding

    ReblindDelay=1

    BlindStartTime=2.7
    BlindTime=2
    BlindEndTime=1.03

    BlindFallTime=1.6
    BlindGetUpTime=1.5

    BlindStartAnim=(Anim="pl_blindreaction_in",AnimTime=2.7)
    BlindAnim=(Anim="pl_blindreaction_loop",Rate=1,AnimTime=2.36)
    BlindEndAnim=(Anim="pl_blindreaction_out",AnimTime=1.03)
    BlindFallAnim=(Anim="GrabFallDown",AnimTime=1.6)
    BlindGetUpAnim=(Anim="GrabGetUp",AnimTime=1.5)

    //--------------------------------------------------------------------------
    // Peaceful Takedown

    CakesForTakedown=4

    CakeReactions(0)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-6BeautifulFigure'
    CakeReactions(1)=Sound'PL-Dialog.WednesdayBitchBoss.Bitch-6DeliciousAndMoist'
    CakeReactions(2)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-6DeliciousCalories'
    CakeReactions(3)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-6StraightToMyThighs'

    //--------------------------------------------------------------------------
    // Victory Taunt Gestures

    GestureAnims(0)=(Anim="s_gesture1",AnimTime=2.13)
    GestureAnims(1)=(Anim="s_gesture2",AnimTime=1.63)
    GestureAnims(2)=(Anim="s_gesture3",AnimTime=1.36)

    //--------------------------------------------------------------------------
    // Dance

    DanceAnimBlendTime=0.1
    DanceAnims(0)=(Anim="s_dance1",Rate=1,AnimTime=6.4)
    DanceAnims(1)=(Anim="s_dance2",Rate=1,AnimTime=3.4)
    DanceAnims(2)=(Anim="s_dance3",Rate=1,AnimTime=3.03)

    //--------------------------------------------------------------------------
    // Attack sounds

    SwordSwingSounds(0)=sound'AWSoundFX.Machete.macheteswingmiss'
    SwordSwingSounds(1)=sound'AWSoundFX.Machete.machetethrowin'
    SwordSwingSounds(2)=sound'AWSoundFX.Machete.machetethrowloop'

    SwordHitSounds(0)=sound'AWSoundFX.Machete.macheteslice'
    SwordHitSounds(1)=sound'AWSoundFX.Machete.machetelimbhit'

    //--------------------------------------------------------------------------
    // Dialog

    CombatTaunts(0)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-3AlwaysHatedYou'
    CombatTaunts(1)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-3LazyBastard'
    CombatTaunts(2)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-3LazyGoodForNothing'
    CombatTaunts(3)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-3LazyPieceOfShit'
    CombatTaunts(4)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-3LazySOB'
    CombatTaunts(5)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-3ListenedToMother'
    CombatTaunts(6)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-3UngratefulJerk'
    CombatTaunts(7)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-3WantedToDoThis'

    BansheeScreamSounds(0)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-4BansheeLaugh1'
    BansheeScreamSounds(1)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-4BansheeLaugh2'
    BansheeScreamSounds(2)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-4BansheeScream1'
    BansheeScreamSounds(3)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-4BansheeScream2'

    PainSounds(0)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-5NeverAGentlemen'
    PainSounds(1)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-5OwMyBeaver'
    PainSounds(2)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-5Pain1'
    PainSounds(3)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-5Pain2'
    PainSounds(4)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-5Pain3'
    PainSounds(5)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-5Pain4'
    PainSounds(6)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-5Pain5'
    PainSounds(7)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-5ThatHurt'
    PainSounds(8)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-5YoureGonnaPay'

    VictoryTaunts(0)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-7MotherWasRight'
    VictoryTaunts(1)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-7PatheticInBed'
    VictoryTaunts(2)=sound'PL-Dialog.WednesdayBitchBoss.Bitch-7ThatllTeachYou'
	
	PrebattleWaitTime=1.5
}
