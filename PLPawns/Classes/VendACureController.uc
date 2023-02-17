/**
 * VendACureController
 * Copyright 2014, Running With Scissors, Inc.
 *
 * Greetings adventurer! I am CRP-TP, but the locals call me Craptrap!
 *
 * @author Gordon Cheng
 */
class VendACureController extends P2EAIController;

/** Think intervals determines the time in seconds before they think again */
var float IdleThinkInterval, MoveThinkInterval;
var float IdleWaitTime, RangedTargetWaitTime;

/** Attack definitions, which includes their animation, damage, etc. */
var float RangedAttackBias;

var int MeleeAttack;
var float RangedAttackSwitchTime;
var range MeleeAttackRange;
var array<AttackInfo> MeleeAttacks;
var sound MeleeHitSound;

var bool bLeadTarget;
var int UrineProjectileSpread;
var float UrineProjectileSpeed;
var AttackInfo RangedAttack;
var vector UrineFireOffset;
var class<P2Projectile> UrineProjectileClass;

/** Bodily fluid stuffs */
var float UrineAmount, SavedDeltaTime;
var float UnrineDazeBreakTime, UrineHitAngle, DeactivateUrineAmount;

/** Stuff for dialog */
var range IdleDialogIntervals;
var range CombatTauntIntervals;
var range PainSoundInterval;

/** Initiating a ignored conversation between Bystanders */
var float TalkAbandonTime, TalkAbandonRadius;
var array<Pawn> TalkedToPawns;

var array<sound> GreetingSounds;
var array<sound> IdleSounds;
var array<sound> UrineReactionSounds;
var array<sound> ThankSounds;
var array<sound> CombatTauntSounds;
var array<sound> PainSounds;
var array<sound> DeactivationSounds;
var array<sound> DeathScreamSounds;

/** Various movement settings */
var float MoveReachedRadius, InterestReachedRadius;
var int PathNotFoundThreshold, PathNotFoundCnt;

var bool bPlayPainSound;

/** Various objects in the world we need to keep track of */
var bool bPatrolDownList;
var int PatrolNodePtr;
var array<PathNode> PatrolNodes;

var VendACurePawn VendACure;
var Pawn InterestPawn;
var PathNode DestinationNode;

/** Returns whether or not our enemy is in melee range
 * @return TRUE if the enemy is still in melee range; FALSE otherwise
 */
function bool IsEnemyInMeleeRange() {
    if (Enemy == none || MeleeAttack < 0 || MeleeAttack >= MeleeAttacks.length)
        return false;

    return VSize(Enemy.Location - Pawn.Location) <
        MeleeAttacks[MeleeAttack].Range;
}

/** Returns whether or not we can hit our enemy with a urine glob. In order to
 * find this out, we do a quick physics test along with a line of sight check
 * @return TRUE if we can possible hit our enemy with urine
 */
function bool IsEnemyInFiringRange() {
    local vector ProjStart;

    if (Enemy == none)
        return false;

    ProjStart = Pawn.Location + class'P2EMath'.static.GetOffset(Pawn.Rotation,
        UrineFireOffset);

    return (class'P2EMath'.static.CanHitTarget(ProjStart, Enemy.Location,
        UrineProjectileSpeed, Pawn.PhysicsVolume.Gravity.Z) &&
        FastTrace(Enemy.Location, ProjStart));
}

/** Returns whether or not the given Pawn is closer than our enemy
 * @param Other - Pawn to check if he or she is closer than our enemy
 * @return TRUE if the given Pawn is closer than our enemy; FALSE otherwise
 */
function bool IsCloserThanEnemy(Pawn Other) {
    if (Enemy == none)
        return false;

    return VSize(Other.Location - Pawn.Location) < VSize(Enemy.Location - Pawn.Location);
}

/** Returns whether or not we've reached out enemy
 * @return TRUE if we've reached our enemy; FALSE otherwise
 */
function bool HasReachedEnemy() {
    if (Enemy == none)
        return true;

    return VSize(Enemy.Location - Pawn.Location) < MeleeAttackRange.Min;
}

/** Returns whether or not we've reached the Pawn we're interested in
 * interacting with
 * @return TRUE if we've reached our interest pawn; FALSE otherwise
 */
function bool HasReachedInterestPawn() {
    if (InterestPawn == none)
        return true;

    return VSize(InterestPawn.Location - Pawn.Location) < InterestReachedRadius;
}

/** Returns whether or not we've reached our Destination PathNode
 * @return TRUE if we've reached our destination; FALSE otherwise
 */
function bool HasReachedDestination() {
    if (DestinationNode == none)
        return true;

    return VSize(DestinationNode.Location - Pawn.Location) < MoveReachedRadius;
}

/** Returns whether or not we've already talked to the specified Pawn
 * @param Other - Pawn to check whether or not we've already talked to
 * @return TRUE if we've already talked to him or her; FALSE otherwise
 */
function bool HasTalkedTo(Pawn Other) {
    local int i;

    for (i=0;i<TalkedToPawns.length;i++)
        if (Other == TalkedToPawns[i])
            return true;

    return false;
}

/** Returns whether or not we should move closer to our enemy
 * @return TRUE if we're out of range for a melee attack; FALSE otherwise
 */
function bool ShouldMoveToEnemy() {
    if (Enemy == none)
        return false;

    return VSize(Enemy.Location - Pawn.Location) > MeleeAttackRange.Max;
}

/** Returns whether or not we should just stop trying to talk to someone
 * @return TRUE if they're too far away and we're clearly being ignored; FALSE otherwise
 */
function bool ShouldAbandonInterestPawn() {
    if (InterestPawn == none)
        return true;

    return VSize(InterestPawn.Location - Pawn.Location) > TalkAbandonRadius;
}

/** Iterates through the Pawns in the map and returns the Player Pawn
 * @return Pawn object the player is currently using
 */
function Pawn GetPlayer() {
    local Pawn Player;

    foreach DynamicActors(class'Pawn', Player)
        if (Player.Controller != none && Player.Controller.bIsPlayer)
            return Player;

    return none;
}

/** Takes a range and returns a value between the specified min and max values
 * @param r - A range value consisting of a minimum and maximum value
 * @return A value in between the specified min and max
 */
function float GetRangeValue(range r) {
    return r.Min + (r.Max - r.Min) * FRand();
}

/** Sends the Pawn into the appropriate initial attack state */
function GotoAttackState() {
    if (FRand() < RangedAttackBias) {
        if (IsEnemyInFiringRange())
            GotoState('UrineAttack');
        else {
            DestinationNode = GetClosestPathnode(Enemy, true);

            if (DestinationNode != none)
                GotoState('MoveToRangedEnemy');
        }
    }
    else if (ShouldMoveToEnemy())
        GotoState('MoveToEnemy');
    else
        GotoState('AttackEnemy');
}

/** Sends Craptrap to talk with someone
 * @param Other - Bystander that Craptrap will move to and conversate with
 */
function GotoTalkState(Pawn Other) {
    local bool bOtherIsPlayer;

    bOtherIsPlayer = (Other.Controller != none && Other.Controller.bIsPlayer);

    InterestPawn = Other;
    AddPawnToTalkedTo(Other);

    GotoState('MoveToInterestPawn');
}

/** Adds a Pawn to the list of Pawns we've already talked to
 * @param TalkedTo - Pawn that we've already talked to and has ignored us
 */
function AddPawnToTalkedTo(Pawn TalkedTo) {
    TalkedToPawns.Insert(TalkedToPawns.length, 1);
    TalkedToPawns[TalkedToPawns.length-1] = TalkedTo;
}

/** Automatically designate the player as an enemy and attack him */
function InitialStateAttackPlayer() {
    if (VendACure == none)
        return;

    VendACure.bPlayerIsFriend = false;
    VendACure.bPlayerIsEnemy = true;

    Enemy = GetPlayer();

    if (Enemy != none)
        GotoAttackState();
    else
        GotoState('Idle');
}

/** Automatically find a tagged Pawn and attack him */
function InitialStateAttackTag() {
    local Pawn AttackPawn;

    if (VendACure == none)
        return;

    foreach DynamicActors(class'Pawn', AttackPawn, VendACure.AttackTag)
        if (AttackPawn != none)
            break;

    if (AttackPawn != none) {
        Enemy = AttackPawn;
        GotoAttackState();
    }
    else
        GotoState('Idle');
}

/** Overriden so we can perform some initial setup */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    if (VendACurePawn(aPawn) != none)
        VendACure = VendACurePawn(aPawn);

    PopulatePatrolNodeList();

    if (VendACure != none) {
        VendACure.SetPhysics(PHYS_Falling);
        VendACure.VendACureController = self;

        switch (VendACure.PawnInitialState) {
            case EP_AttackPlayer:
                AddTimer(0.1, 'InitialStateAttackPlayer', false);
                break;

            case EP_Turret:
            case EP_HoldPosition:
                GotoState('HoldPosition');
                break;

            case EP_WatchPlayer:
                AddTimer(0.1, 'WatchPlayer', false);
                break;

            case EP_AttackTag:
                AddTimer(0.1, 'InitialStateAttackTag', false);
                break;

            default:
                GotoState('Idle');
        }
    }
    else
        LogDebug("ERROR: VendACurePawn not found");
}

/** Overriden to implement multi-timer functionality */
function TimerFinished(name ID) {
    switch (ID) {
        case 'InitialStateAttackPlayer':
            InitialStateAttackPlayer();
            break;

        case 'InitialStateAttackTag':
            InitialStateAttackTag();
            break;

        case 'WatchPlayer':
            GotoState('WatchPlayer');
            break;

        case 'IdleWaitFinished':
            IdleWaitFinished();
            break;

        case 'SwitchToRanged':
            SwitchToRanged();
            break;

        case 'RangedTargetWaitFinished':
            RangedTargetWaitFinished();
            break;

        case 'PlayIdleSound':
            PlayIdleSound();
            break;

        case 'PlayCombatTauntSound':
            PlayCombatTauntSound();
            break;

        case 'ExitDazedState':
            ExitDazedState();
            break;

        case 'CraptrapGotIgnored':
            IdleWaitFinished();
            break;

        case 'EnablePainSound':
            bPlayPainSound = true;
            break;
    }
}

/** After we waited a little after going Idle, decide what to do next */
function IdleWaitFinished() {
    // If we have more than one patrol node, go through our patrol points
    if (PatrolNodes.length > 1) {
        if (bPatrolDownList) {
            if (PatrolNodePtr < PatrolNodes.length - 1)
                PatrolNodePtr++;
            else {
                bPatrolDownList = false;
                PatrolNodePtr--;
            }
        }
        else {
            if (PatrolNodePtr > 0)
                PatrolNodePtr--;
            else {
                bPatrolDownList = true;
                PatrolNodePtr++;
            }
        }

        DestinationNode = PatrolNodes[PatrolNodePtr];
    }
    else
        DestinationNode = GetRandomPathNode(false);

    if (DestinationNode != none)
        GotoState('MoveToDestination');
    else
        LogDebug("ERROR: Unable to determine DestinationNode");
}

/** After some time chasing the Dude, and being unable to hit him, switch to a
 * ranged attack instead
 */
function SwitchToRanged() {
    if (IsEnemyInFiringRange())
        GotoState('UrineAttack');
}

/** Eh, our ranged target is not coming back, just go back to Idle */
function RangedTargetWaitFinished() {
    Enemy = none;
    GotoState('Idle');
}

/** Exit our urine induced dazed state and back to combat or idle. Here we
 * prioritize melee attacks as the Dude is pissing or melee range
 */
function ExitDazedState() {
    if (Enemy != none)
        GotoAttackState();
    else
        GotoState('Idle');
}

/** Play one of our greeting sounds */
function PlayGreetingSound() {
    local sound GreetingDialog;

    GreetingDialog = GreetingSounds[Rand(GreetingSounds.length)];
    Pawn.PlaySound(GreetingDialog, SLOT_Talk, 1, false, 300);
}

/** Play one of our idle sounds */
function PlayIdleSound() {
    local float SoundDuration;
    local sound IdleDialog;

    IdleDialog = IdleSounds[Rand(IdleSounds.length)];

    SoundDuration = GetSoundDuration(IdleDialog);
    Pawn.PlaySound(IdleDialog, SLOT_Talk, 1, false, 300);
    AddTimer(SoundDuration + GetRangeValue(IdleDialogIntervals), 'PlayIdleSound', false);
}

/** Play one of our reactions to being hit with urine sounds */
function PlayUrineReactionSound() {
    local sound UrineReactionDialog;

    UrineReactionDialog = UrineReactionSounds[Rand(UrineReactionSounds.length)];
    Pawn.PlaySound(UrineReactionDialog, SLOT_Talk, 1, false, 300);
}

/** Play one of our thanking sounds */
function PlayThanksSound() {
    local sound ThankDialog;

    ThankDialog = ThankSounds[Rand(ThankSounds.length)];
    Pawn.PlaySound(ThankDialog, SLOT_Talk, 1, false, 300);
}

/** Play one of our taunt sounds for combat */
function PlayCombatTauntSound() {
    local sound CombatTauntDialog;

    CombatTauntDialog = CombatTauntSounds[Rand(CombatTauntSounds.length)];
    Pawn.PlaySound(CombatTauntDialog, SLOT_Talk, 1, false, 300);
    AddTimer(GetRangeValue(CombatTauntIntervals), 'PlayCombatTauntSound', false);
}

/** Play one of our pain sounds */
function PlayPainSound() {
    local sound PainDialog;

    PainDialog = PainSounds[Rand(PainSounds.length)];
    Pawn.PlaySound(PainDialog, SLOT_Talk, 1, false, 300);

    bPlayPainSound = false;
    AddTimer(GetRangeValue(PainSoundInterval), 'EnablePainSound', false);
}

/** Play one of our urine deactivation sounds */
function PlayDeactivationSound() {
    local sound DeactivationDialog;

    DeactivationDialog = DeactivationSounds[Rand(DeactivationSounds.length)];
    Pawn.PlaySound(DeactivationDialog, SLOT_Talk, 1, false, 300);
}

/** Play one of our death scream sounds */
function PlayDeathScreamSound() {
    local sound DeathScreamDialog;

    DeathScreamDialog = DeathScreamSounds[Rand(DeathScreamSounds.length)];
    Pawn.PlaySound(DeathScreamDialog, SLOT_Talk, 1, false, 300);
}

/** Populates our PatrolNodes list */
function PopulatePatrolNodeList() {
    local int i;
    local PathNode TempNode;

    if (VendACure == none)
        return;

    for (i=0;i<VendACure.PatrolNodeTags.length;i++) {
        TempNode = none;

        foreach AllActors(class'PathNode', TempNode, VendACure.PatrolNodeTags[i])
            if (TempNode != none)
                AddPatrolNode(TempNode);
    }
}

/** Adds the given PathNode into our PatrolNodes list
 * @param Node - PathNode object to add to our list
 */
function AddPatrolNode(PathNode Node) {
    PatrolNodes.Insert(PatrolNodes.length, 1);
    PatrolNodes[PatrolNodes.length-1] = Node;
}

/** Overriden to implement seeing people and doing stuff in response */
function PawnSeen(Pawn Other) {
    local bool bOtherIsPlayer, bAttackOther;

    if (VendACure == none || VendACurePawn(Other) != none || Other.Health <= 0)
        return;

    bAttackOther = false;
    bOtherIsPlayer = (Other.Controller != none && Other.Controller.bIsPlayer);

    if (VendACure.bRiotMode)
        bAttackOther = true;

    if (VendACure.bPlayerIsEnemy && bOtherIsPlayer)
        bAttackOther = true;

    if (VendACure.bPlayerIsFriend && bOtherIsPlayer)
        bAttackOther = false;

    if (bAttackOther && (Enemy == none || IsCloserThanEnemy(Other))) {
        Enemy = Other;

        if (VendACure.PawnInitialState == EP_Turret)
            GotoState('WatchEnemy');
        else
            GotoAttackState();
    }

    // If we currently have an enemy, ignore conversating with others
    if (Enemy != none)
        return;

    if (InterestPawn == none && !HasTalkedTo(Other) && VSize(Other.Location - Pawn.Location) < TalkAbandonRadius)
        GotoTalkState(Other);
}

/** Notification from our Pawn that it performed a melee attack */
function NotifyMeleeAttack() {
    if (IsEnemyInMeleeRange()) {
        Enemy.TakeDamage(MeleeAttacks[MeleeAttack].Damage, Pawn, Enemy.Location,
            vect(0,0,0), MeleeAttacks[MeleeAttack].DamageType);

        if (MeleeHitSound != none)
            Enemy.PlaySound(MeleeHitSound, SLOT_Pain, 1, false, 300);
    }
}

/** Notification from our Pawn that it performed a ranged attack */
function NotifyRangedAttack() {
    local vector ProjStart;
    local rotator ProjRot;
    local P2Projectile UrineProj;

    if (UrineProjectileClass != none) {
        ProjStart = Pawn.Location +
            class'P2EMath'.static.GetOffset(Pawn.Rotation, UrineFireOffset);

        ProjRot = class'P2EMath'.static.GetProjectileTrajectory(ProjStart,
            Enemy.Location, UrineProjectileSpeed, Enemy.Velocity,
            UrineProjectileSpread, Pawn.PhysicsVolume.Gravity.Z, bLeadTarget);

        UrineProj = Spawn(UrineProjectileClass,,, ProjStart, ProjRot);

        if (UrineProj != none) {
            if (VomitProjectile(UrineProj) != none)
                VomitProjectile(UrineProj).PrepVelocity(vector(ProjRot) *
                    UrineProjectileSpeed);
            else
                UrineProj.Velocity = vector(ProjRot) *
                    UrineProjectileSpeed;
        }
    }
}

/** Notification from our Pawn that we've been hit with fluids */
function HitWithFluid(Fluid.FluidTypeEnum ftype, vector HitLocation) {
    if (Pawn == none) return;

    if (ftype == FLUID_TYPE_Urine && UrineAmount < DeactivateUrineAmount &&
        IsLocationInFacingAngle(HitLocation, UrineHitAngle)) {
        UrineAmount = FMin(UrineAmount + SavedDeltaTime, DeactivateUrineAmount);

        ResetTimer('ExitDazedState');

        if (!IsInState('Dazed'))
            GotoState('Dazed');

        if (UrineAmount == DeactivateUrineAmount)
            GotoState('Deactivate');
	}
}

/** Notification from our Pawn that we were just hit */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    if (bPlayPainSound)
        PlayPainSound();

    if (VendACurePawn(InstigatedBy) == none && InstigatedBy.Health > 0 && Enemy == none) {
        Enemy = InstigatedBy;

        if (VendACure.PawnInitialState == EP_Turret)
            GotoState('WatchEnemy');
        else
            GotoAttackState();
    }
}

/** Called whenver we can't find a path to our wander destination */
function CantFindPathToDestination() {
    GotoState('Idle');
}

/** Called whenever we can't find a path to the Pawn we're interested in */
function CantFindPathToInterest() {
    InterestPawn = none;

    GotoState('Idle');
}

/** Called whenever we can't find a path to our enemy */
function CantFindPathToEnemy() {
    if (IsEnemyInFiringRange())
        GotoState('UrineAttack');
    else {
        DestinationNode = GetClosestPathnode(Enemy, false);

        if (DestinationNode != none)
            GotoState('MoveToRangedEnemy');
        else {
            Enemy = none;
            GotoState('Idle');
        }
    }
}

/** Overriden so we have the DeltaTime available for the HitWithFluid method so
 * we can add up the amount of fluids dispelled
 */
function Tick(float DeltaTime) {
    super.Tick(DeltaTime);

    SavedDeltaTime = DeltaTime;
}

/** Decide what to do next, either after attacking or reaching a destination */
state Idle
{
    function BeginState() {
        LogDebug("Entered Idle state...");

        Enemy = none;
        InterestPawn = none;

        VendACure.SetMood(MOOD_Normal, 1.0);

        FaceForward();

        SetTimer(IdleThinkInterval, true);

        AddTimer(IdleWaitTime, 'IdleWaitFinished', false);
        AddTimer(GetRangeValue(IdleDialogIntervals), 'PlayIdleSound', false);
    }

    function EndState() {
        RemoveTimerByID('IdleWaitFinished');
        RemoveTimerByID('PlayIdleSound');
    }

    function Timer() {
        CheckSurroundingPawns();
    }

Begin:
    StopMoving();
}

/** Trap state for now in which Craptrap does nothing but stand there */
state HoldPosition
{
    function BeginState() {
        LogDebug("Entered HoldPosition state...");

        VendACure.SetMood(MOOD_Normal, 1.0);

        FaceForward();

        SetTimer(IdleThinkInterval, true);
    }

    function Timer() {
        CheckSurroundingPawns();
    }

Begin:
    StopMoving();
}

/** Trap state in which Craptrap does nothing but watch the player */
state WatchPlayer
{
    function BeginState() {
        LogDebug("Entered WatchPlayer state...");

        VendACure.SetMood(MOOD_Normal, 1.0);

        Focus = GetPlayer();
    }

Begin:
    StopMoving();
}

/** Craptrap is in turret mode so he'll watch the enemy until he gets a line
 * of sight again in which he can shoot urine globs again
 */
state WatchEnemy
{
    function BeginState() {
        LogDebug("Entered WatchEnemy state...");

        VendACure.SetMood(MOOD_Normal, 1.0);

        Enemy = GetPlayer();

        if (Enemy != none && Enemy.Health > 0)
            SetTimer(MoveThinkInterval, true);
        else
            FaceForward();
    }

    function Timer() {
        CheckSurroundingPawns();

        if (FastTrace(Enemy.Location, Pawn.Location))
            GotoState('UrineAttack');
        else
            FocalPoint = Enemy.Location;
    }

Begin:
    StopMoving();
}

/** We lost our ranged target, so just stare at his last position for a few
 * seconds before declaring the target lost
 */
state RangedTargetLost
{
    function BeginState() {
        LogDebug("Entered RangedTargetLost state...");

        Enemy = none;

        VendACure.SetMood(MOOD_Normal, 1.0);

        Focus = none;
        FocalPoint = Enemy.Location;

        SetTimer(IdleThinkInterval, true);

        AddTimer(RangedTargetWaitTime, 'RangedTargetWaitFinished', false);
    }

    function EndState() {
        RemoveTimerByID('RangedTargetWaitFinished');
    }

    function Timer() {
        CheckSurroundingPawns();
    }

Begin:
    StopMoving();
}

/** Face the person we're talking to and ask them to give us a golden shower */
state TalkToInterestPawn
{
    function BeginState() {
        LogDebug("Entered TalkToInterestPawn state...");

        Focus = InterestPawn;

        VendACure.SetMood(MOOD_Normal, 1.0);
        VendACure.PlayTalkingGesture(1.0);

        PlayGreetingSound();

        SetTimer(IdleThinkInterval, true);
        AddTimer(TalkAbandonTime, 'CraptrapGotIgnored', false);
    }

    function EndState() {
        RemoveTimerByID('CraptrapGotIgnored');
    }

    function Timer() {
        if (ShouldAbandonInterestPawn())
            GotoState('Idle');
    }

Begin:
    StopMoving();
}

/** Move to destination and return the idle, used mainly for random walking
 * either when patrolling a certain area, or wandering around randomly
 */
state MoveToDestination
{
    function BeginState() {
        LogDebug("Entered MoveToDestination: " $ DestinationNode $ " state...");

        Enemy = none;
        InterestPawn = none;

        VendACure.SetPawnWalking(true);

        SetTimer(MoveThinkInterval, true);

        AddTimer(GetRangeValue(IdleDialogIntervals), 'PlayIdleSound', false);
    }

    function EndState() {
        RemoveTimerByID('PlayIdleSound');
    }

    function Timer() {
        CheckSurroundingPawns();

        if (HasReachedDestination())
            GotoState('Idle');
    }

Begin:
    while (!HasReachedDestination()) {
        if (ActorReachable(DestinationNode)) {
            PathNotFoundCnt = 0;
            MoveToward(DestinationNode);
        }
		else {
			MoveTarget = FindPathToward(DestinationNode);

            if (MoveTarget != none) {
                PathNotFoundCnt = 0;
				MoveToward(MoveTarget);
            }
            else {
                PathNotFoundCnt++;
                Sleep(0.1);

                if (PathNotFoundCnt == PathNotFoundThreshold)
                    CantFindPathToDestination();
            }
		}
    }

    GotoState('Idle');
}

/** Walk over to someone and ask them if can perform a golden shower */
state MoveToInterestPawn
{
    function BeginState() {
        LogDebug("Entered MoveToInterestPawn state...");

        VendACure.SetMood(MOOD_Normal, 1.0);
        VendACure.SetPawnWalking(true);

        SetTimer(MoveThinkInterval, true);
    }

    function Timer() {
        if (ShouldAbandonInterestPawn())
            GotoState('Idle');
        else if (HasReachedInterestPawn())
            GotoState('TalkToInterestPawn');
    }

Begin:
    while (!HasReachedInterestPawn()) {
        if (ActorReachable(InterestPawn)) {
            PathNotFoundCnt = 0;
            MoveToward(InterestPawn);
        }
		else {
			MoveTarget = FindPathToward(InterestPawn);

            if (MoveTarget != none) {
                PathNotFoundCnt = 0;
				MoveToward(MoveTarget);
            }
            else {
                PathNotFoundCnt++;
                Sleep(0.1);

                if (PathNotFoundCnt == PathNotFoundThreshold)
                    CantFindPathToInterest();
            }
		}
    }

    GotoState('TalkToInterestPawn');
}

/** Roll over to our enemy */
state MoveToEnemy
{
    function BeginState() {
        LogDebug("Entered MoveToEnemy state...");

        VendACure.SetMood(MOOD_Combat, 1.0);
        VendACure.SetPawnWalking(false);

        SetTimer(MoveThinkInterval, true);

        AddTimer(RangedAttackSwitchTime, 'SwitchToRanged', false);
        AddTimer(GetRangeValue(CombatTauntIntervals), 'PlayCombatTauntSound', false);
    }

    function EndState() {
        RemoveTimerByID('SwitchToRanged');
        RemoveTimerByID('PlayCombatTauntSound');
    }

    function Timer() {
        CheckSurroundingPawns();

        if (Enemy == none || Enemy.Health <= 0) {
            Enemy = none;
            GotoState('Idle');
        }

        if (HasReachedEnemy())
            GotoState('AttackEnemy');
    }

Begin:
    while (!HasReachedEnemy()) {
        if (ActorReachable(Enemy)) {
            PathNotFoundCnt = 0;
            MoveToward(Enemy);
        }
		else {
			MoveTarget = FindPathToward(Enemy);

            if (MoveTarget != none) {
                PathNotFoundCnt = 0;
				MoveToward(MoveTarget);
            }
            else {
                PathNotFoundCnt++;
                Sleep(0.1);

                if (PathNotFoundCnt == PathNotFoundThreshold)
                    CantFindPathToEnemy();
            }
		}
    }

    GotoState('AttackEnemy');
}

/** Since the enemy can't be reached, move to a PathNode that's closest to our
 * enemy instead and when we can hit our enemy, stop and hit them with our
 * ranged attack
 */
state MoveToRangedEnemy
{
    function BeginState() {
        LogDebug("Entered MoveToRangedEnemy state...");

        VendACure.SetMood(MOOD_Combat, 1.0);
        VendACure.SetPawnWalking(false);

        SetTimer(MoveThinkInterval, true);
    }

    function Timer() {
        CheckSurroundingPawns();

        if (Enemy == none || Enemy.Health <= 0)
            GotoState('Idle');
        else if (IsEnemyInFiringRange())
            GotoState('UrineAttack');
    }

Begin:
    while (!HasReachedDestination()) {
        if (ActorReachable(DestinationNode)) {
            PathNotFoundCnt = 0;
            MoveToward(DestinationNode);
        }
		else {
			MoveTarget = FindPathToward(DestinationNode);

            if (MoveTarget != none) {
                PathNotFoundCnt = 0;
				MoveToward(MoveTarget);
            }
            else {
                PathNotFoundCnt++;
                Sleep(0.1);

                if (PathNotFoundCnt == PathNotFoundThreshold)
                    CantFindPathToDestination();
            }
		}
    }

    // If we've arrived at our destination and we still can't attack, wait there
    GotoState('RangedTargetLost');
}

/** Beat the crap our of the enemy with our robot hands */
state AttackEnemy
{
    function BeginState() {
        LogDebug("Entered AttackEnemy state...");

        VendACure.SetMood(MOOD_Combat, 1.0);

        PerformAttack();
    }

    function PerformAttack() {
        MeleeAttack = Rand(MeleeAttacks.length);
		
		if (MeleeAttack == 0)
			VendACure.PlayMelee1Sound();
		else
			VendACure.PlayMelee2Sound();

        PlayAnimByDuration(MeleeAttacks[MeleeAttack].Anim,
            MeleeAttacks[MeleeAttack].Duration);

        SetTimer(MeleeAttacks[MeleeAttack].Duration, false);
    }

    function Timer() {
        if (Enemy == none || Enemy.Health <= 0)
            GotoState('Idle');
        else if (ShouldMoveToEnemy())
            GotoState('MoveToEnemy');
        else
            PerformAttack();
    }

Begin:
    StopMoving();
}

/** Shoot out a glob of urine to attack enemies */
state UrineAttack
{
    function BeginState() {
        LogDebug("Entered RangedAttack state...");

        Focus = Enemy;

        VendACure.SetMood(MOOD_Combat, 1.0);

        PerformAttack();
    }

    function PerformAttack() {
		VendACure.PlayRangedSound();
        PlayAnimByDuration(RangedAttack.Anim, RangedAttack.Duration);
        SetTimer(RangedAttack.Duration, false);
    }

    function Timer() {
        // Boolean is kinda ass, but whatever
        if (VendACure.PawnInitialState == EP_Turret) {
            if (Enemy == none || Enemy.Health <= 0)
                GotoState('HoldPosition');
            else if (FastTrace(Enemy.Location, Pawn.Location) && IsEnemyInFiringRange())
                PerformAttack();
            else
                GotoState('WatchEnemy');
        }
        else if (Enemy == none || Enemy.Health <= 0)
            GotoState('Idle');
        else if (IsEnemyInMeleeRange())
            GotoState('AttackEnemy');
        else if (FastTrace(Enemy.Location, Pawn.Location) && IsEnemyInFiringRange())
            PerformAttack();
        else
            GotoState('MoveToEnemy');
    }

Begin:
    StopMoving();
}

/** This is so messy... yet it feels so good... its like, its like..
 * eating a damn fine burger!
 */
state Dazed
{
    function BeginState() {
        LogDebug("Entered GettingPissedOn state...");

        Focus = none;
        FocalPoint = Pawn.Location + vector(Pawn.GetViewRotation()) * 256;

        VendACure.SetMood(MOOD_Happy, 1.0);
		VendACure.PlayUrineHit();

		if (Enemy != none)
            PlayUrineReactionSound();

        AddTimer(UnrineDazeBreakTime, 'ExitDazedState', false);
    }
	event AnimEnd(int Channel)
	{
		VendACure.PlayUrineHit();
	}

    function EndState() {
        // Note to self, need this in case this Timer is not responsible for
        // exiting this state
        RemoveTimerByID('ExitDazedState');
    }

Begin:
    StopMoving();
}

/** Now that our urine tank is full, we'll analyze what's wrong with the Dude,
 * physically, and give him something to fix what ails him... bullets...
 */
state Deactivate
{
    function BeginState() {
        LogDebug("Entered Deactivate state...");

        Focus = none;
        FocalPoint = Pawn.Location + vector(Pawn.GetViewRotation()) * 256;

        VendACure.SetMood(MOOD_Happy, 1.0);
        VendACure.GotoState('Shutdown');

        if (Enemy != none)
            PlayDeactivationSound();
        else
            PlayThanksSound();

        Pawn.TriggerEvent(Pawn.Event, Pawn, Pawn);
    }

Begin:
    StopMoving();
}

defaultproperties
{
    bLogDebug=false

    bPatrolDownList=true

    PatrolNodePtr=-1

    IdleThinkInterval=0.1
    MoveThinkInterval=0.1

    IdleWaitTime=2
    RangedTargetWaitTime=10

    bPlayPainSound=true

    IdleDialogIntervals=(Min=10,Max=15)
    CombatTauntIntervals=(Min=10,Max=15)
    PainSoundInterval=(Min=5,Max=10)

    TalkAbandonTime=10
    TalkAbandonRadius=500

    RangedAttackBias=0.25

    RangedAttackSwitchTime=5

    MeleeAttackRange=(Min=96,Max=128)

    MeleeAttacks(0)=(Duration=1,Range=128,Damage=5,DamageType=class'PisstrapMeleeDamage',Anim=(Anim="Melee1",AnimTime=0.7))
    MeleeAttacks(1)=(Duration=1,Range=128,Damage=5,DamageType=class'PisstrapMeleeDamage',Anim=(Anim="Melee2",AnimTime=0.7))

    bLeadTarget=false
    UrineProjectileSpeed=1280
    UrineProjectileSpread=1024

    RangedAttack(0)=(Duration=1,Anim=(Anim="Ranged",AnimTime=1.7))

    UnrineDazeBreakTime=5
    UrineHitAngle=67.5

    DeactivateUrineAmount=1

    MeleeHitSound=sound'WeaponSounds.foot_kickhead'

    GreetingSounds(0)=sound'PisstrapDialog.Greetings.PissTrap-AdjustAimingReticule'
    GreetingSounds(1)=sound'PisstrapDialog.Greetings.PissTrap-CallMePissTrap'
    GreetingSounds(2)=sound'PisstrapDialog.Greetings.PissTrap-PeeBuddy'
    GreetingSounds(3)=sound'PisstrapDialog.Greetings.PissTrap-ProperMaintenance'
    GreetingSounds(4)=sound'PisstrapDialog.Greetings.PissTrap-WouldYouLikeHelp'

    IdleSounds(0)=sound'PisstrapDialog.Idle.PissTrap-BeautifulDay'
    IdleSounds(1)=sound'PisstrapDialog.Idle.PissTrap-DaisyDaisy'
    IdleSounds(2)=sound'PisstrapDialog.Idle.PissTrap-DontWhizOn'
    IdleSounds(3)=sound'PisstrapDialog.Idle.PissTrap-FartboxTime'
    IdleSounds(4)=sound'PisstrapDialog.Idle.PissTrap-HateMyLife'
    IdleSounds(5)=sound'PisstrapDialog.Idle.PissTrap-Humming'
    IdleSounds(6)=sound'PisstrapDialog.Idle.PissTrap-MoreToLife'
    IdleSounds(7)=sound'PisstrapDialog.Idle.PissTrap-WonderWhatItsLike'

    UrineReactionSounds(0)=sound'PisstrapDialog.UrineReactions.PissTrap-BetYouEnjoyedThat'
    UrineReactionSounds(1)=sound'PisstrapDialog.UrineReactions.PissTrap-EatingAsparagus'
    UrineReactionSounds(2)=sound'PisstrapDialog.UrineReactions.PissTrap-HopeIDontRust'
    UrineReactionSounds(3)=sound'PisstrapDialog.UrineReactions.PissTrap-MotherboardWet'
    UrineReactionSounds(4)=sound'PisstrapDialog.UrineReactions.PissTrap-PeeInMyMouth'
    UrineReactionSounds(5)=sound'PisstrapDialog.UrineReactions.PissTrap-PissInYourWifesMouth'
    UrineReactionSounds(6)=sound'PisstrapDialog.UrineReactions.PissTrap-WordForThatTaste'

    ThankSounds(0)=sound'PisstrapDialog.Thanks.PissTrap-AppreciateThePee'
    ThankSounds(1)=sound'PisstrapDialog.Thanks.PissTrap-PissAgain'
    ThankSounds(2)=sound'PisstrapDialog.Thanks.PissTrap-ThanksForPatronage'
    ThankSounds(3)=sound'PisstrapDialog.Thanks.PissTrap-ThanksForUrine'

    CombatTauntSounds(0)=sound'PisstrapDialog.CombatTaunts.PissTrap-FloppyDrive'
    CombatTauntSounds(1)=sound'PisstrapDialog.CombatTaunts.PissTrap-IntoWatersports'
    CombatTauntSounds(2)=sound'PisstrapDialog.CombatTaunts.PissTrap-MotherFlusher'
    CombatTauntSounds(3)=sound'PisstrapDialog.CombatTaunts.PissTrap-PissedOffRobotMode'
    CombatTauntSounds(4)=sound'PisstrapDialog.CombatTaunts.PissTrap-SuckItDown'
    CombatTauntSounds(5)=sound'PisstrapDialog.CombatTaunts.PissTrap-TearThisMeatbag'
    CombatTauntSounds(6)=sound'PisstrapDialog.CombatTaunts.PissTrap-URINATE'
    CombatTauntSounds(7)=sound'PisstrapDialog.CombatTaunts.PissTrap-YourOwnMedicine'

    PainSounds(0)=sound'PisstrapDialog.Pain.PissTrap-LeaveADent'
    PainSounds(1)=sound'PisstrapDialog.Pain.PissTrap-NotInTheDrain'
    PainSounds(2)=sound'PisstrapDialog.Pain.PissTrap-OwMyRam'
    PainSounds(3)=sound'PisstrapDialog.Pain.PissTrap-PainAck'
    PainSounds(4)=sound'PisstrapDialog.Pain.PissTrap-PainAiee'
    PainSounds(5)=sound'PisstrapDialog.Pain.PissTrap-PainArgh'
    PainSounds(6)=sound'PisstrapDialog.Pain.PissTrap-PainAugh'
    PainSounds(7)=sound'PisstrapDialog.Pain.PissTrap-PainOw'
    PainSounds(8)=sound'PisstrapDialog.Pain.PissTrap-PainOwie'
    PainSounds(9)=sound'PisstrapDialog.Pain.PissTrap-PainSensoryUnit'
    PainSounds(10)=sound'PisstrapDialog.Pain.PissTrap-PissedMeOff'
    PainSounds(11)=sound'PisstrapDialog.Pain.PissTrap-WannaPlayRough'
    PainSounds(12)=sound'PisstrapDialog.Pain.PissTrap-WhyWasIProgrammed'

    DeactivationSounds(0)=sound'PisstrapDialog.Deactivation.PissTrap-CollectionComplete'
    DeactivationSounds(1)=sound'PisstrapDialog.Deactivation.PissTrap-DyingDaisy'
    DeactivationSounds(2)=sound'PisstrapDialog.Deactivation.PissTrap-SystemShuttingDown'
    DeactivationSounds(3)=sound'PisstrapDialog.Deactivation.PissTrap-TellMyWife'
    DeactivationSounds(4)=sound'PisstrapDialog.Deactivation.PissTrap-WhatAWorld'

    DeathScreamSounds(0)=sound'PisstrapDialog.DeathScream.PissTrap-DeathScream'

    UrineFireOffset=(X=24,Z=16)
    UrineProjectileClass=class'VendACureProjectile'

    MoveReachedRadius=128
    InterestReachedRadius=200

    PathNotFoundThreshold=10

    VisionFOV=360
    VisionRange=2000
}
