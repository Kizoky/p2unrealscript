/**
 * LabMonkeyController
 * Copyright 2014, Running With Scissors, Inc.
 *
 * AI Controller that dictates all the homicidal tendencies. Unexpectedly,
 * since we have can have multiple monkeys following the player at once, we
 * also need to implement formation code as well so we don
 *
 * NOTE TO SELF: Decided to still use separate but closely identical states for
 * movement so I can dictate different behaviors while moving. Might come up
 * with better system later.
 *
 * @author Gordon Cheng
 */
class LabMonkeyController extends P2EAIController;

/** Radius from the Dude when we should run and when we should walk */
var float MoveReachedRadius, MoveWalkRadius, ExitRadius;

/** Variables for when the monkeys get stuck on something */
var int PathNotFoundCount;
var int PathNotFoundMax;
var float TeleportRadius, TeleportMinRadiusFromDude, OutOfSightAngle;

/** Intervals of time when the lab monkey should think again */
var float IdleThinkInterval, MoveThinkInterval, AttackThinkInterval;
var float PathWaitTime;

/** Firing behavior variables */
var bool bCanFirePistol;
var float FiringRadius;

var float FiringFOV, EnemyAbandonRadius;
var range FiringInterval, EnemyFiringRange;

/** Dialog variables */
var range IdleDialogInterval;
var float SpotSoundChance;
var array<sound> IdleSounds, SpotSounds, PainSounds, DeathSounds;

/** References to various objects we'll need to function */
var bool bReleasedFromPostalDude;

var PathNode PistolRackNode, ExitPathNode, ClosestPathNode;

var LabMonkey LabMonkey;

var Pawn PostalDude;

var PLFormationManager FormationManager;
var PLFormationAnchor FormationAnchor;

/** Overriden to we shoot cats since they're point blank */
function bool IsInFacingAngle(Actor Other, float Angle) {
    if (CatPawn(Other) != none)
        return true;
    else
        return super.IsInFacingAngle(Other, Angle);
}

/**
 * Returns whether or not we should run or walk
 *
 * @return - TRUE if we should walk; FALSE otherwise
 */
function bool ShouldWalkToPostalDude() {

    if (FormationAnchor == none)
        return false;

    return VSize(FormationAnchor.Location - Pawn.Location) < MoveWalkRadius;
}

/**
 * Returns whether or not we should move toward the Postal Dude
 *
 * @return - TRUE if we should move towards the Postal Dude; FALSE otherwise
 */
function bool ShouldMoveToPostalDude() {

    if (FormationAnchor == none)
        return false;

    return VSize(FormationAnchor.Location - Pawn.Location) > MoveReachedRadius;
}

/**
 * Returns whether or not we should move closer to our Enemy
 *
 * @return - TRUE if we should move closer to our target; FALSE otherwise
 */
function bool ShouldMoveToEnemy() {

    if (Enemy == none)
        return false;

    return VSize(Enemy.Location - Pawn.Location) > FiringRadius;
}

/**
 * Returns whether or not the enemy should be abandoned. This is important as
 * while we should attack enemies, if they're just gonna run away, we should
 * stop shooting at them and go back and focus more on protecting the Postal
 * Dude
 *
 * @return TRUE if the enemy has run out of range and we're gonna abandon chase
 *         FALSE otherwise
 */
function bool ShouldAbandonEnemy() {

    // If we have no enemy, abandone chase by default
    if (Enemy == none)
        return true;

    // If the Postal Dude is dead or gone, continue fighting the enemy
    if (PostalDude == none)
        return false;

    return VSize(Enemy.Location - PostalDude.Location) > EnemyAbandonRadius;
}

/**
 * Returns whether or not we should just teleport over to the Dude if we've
 * fallen behind way too much or if we got stuck
 *
 * @param TRUE if we should teleport to the Dude; FALSE otherwise
 */
function bool ShouldTeleportToDude() {

    if (PostalDude == none)
        return false;

    return (PathNotFoundCount >= PathNotFoundMax &&
            //VSize(PostalDude.Location - Pawn.Location) > TeleportRadius &&
            !IsPawnFacingActor(PostalDude, Pawn, OutOfSightAngle));
}

/**
 * Returns whether or not we've reached the Postal Dude
 *
 * @return TRUE if we're close enough to be considered reaching the Postal Dude
 *         FALSE otherwise
 */
function bool HasReachedPostalDude() {

    if (FormationAnchor == none)
        return false;

    return VSize(FormationAnchor.Location - Pawn.Location) < MoveReachedRadius;
}

/**
 * Returns whether or not we've reached the Pistol rack
 *
 * @return TRUE if we've reached the pistol rack; FALSE otherwise
 */
function bool HasReachedPistolRack() {

    if (PistolRackNode == none)
        return false;

    return VSize(PistolRackNode.Location - Pawn.Location) < MoveReachedRadius;
}

/**
 * Returns whether or not we've reached the exit node
 *
 * @return TRUE if we've reached the exit path node; FALSE otherwise
 */
function bool HasReachedExitNode() {

    if (ExitPathNode == none)
        return false;

    return VSize(ExitPathNode.Location - Pawn.Location) < ExitRadius;
}

/**
 * Returns whether or not we've reached the closest PathNode
 *
 * @return TRUE if we've reached the closest PathNode; FALSE otherwise
 */
function bool HasReachedClosestNode() {

    if (ClosestPathNode == none)
        return false;

    return VSize(ClosestPathNode.Location - Pawn.Location) < ExitRadius;
}

/**
 * Returns whether or not we've come close enough to our enemy that we can fire
 *
 * @return TRUE if we've reached our enemy; FALSE otherwise
 */
function bool HasReachedEnemy() {

    if (Enemy == none)
        return false;

    return VSize(Enemy.Location - Pawn.Location) < FiringRadius;
}

/**
 * Returns whether or not we have a line of sight to our enemy. Here we use the
 * simpler FastTrace to check for geometry in the way, we don't care if an
 * innocent bystander is in the way
 *
 * @return TRUE if we have a line of sight; FALSE otherwise
 */
function bool HasLineOfSightToEnemy() {

    if (Enemy == none)
        return false;

    return FastTrace(Enemy.Location, Pawn.Location);
}

/**
 * Returns a path node that's close to the Dude, but doesn't collide with him
 * which would essentially make for
 */
function PathNode GetTeleportNode() {

    local float Distance, ShortestDist;
    local PathNode TempNode, TeleportNode;

    if (PostalDude == none)
        return none;

    ShortestDist = 3.4028e38;

    foreach AllActors(class'PathNode', TempNode) {

        Distance = VSize(TempNode.Location - PostalDude.Location);

        // Prune off solutions that are clearly not ideal
        if (Distance > ShortestDist || Distance < TeleportMinRadiusFromDude)
            continue;

        // Perform a not-in-line-of-sight check if it appears to be better
        if (!IsPawnFacingActor(PostalDude, TempNode, OutOfSightAngle)) {

            ShortestDist = Distance;
            TeleportNode = TempNode;
        }
    }

    return TeleportNode;
}

/** Overriden so we can perform initial setups */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    LabMonkey = LabMonkey(aPawn);

    if (LabMonkey == none)
        LogDebug("ERROR: LabMonkey Pawn not found");

    if (LabMonkey != none) {
        foreach AllActors(class'PathNode', PistolRackNode,
            LabMonkey.PistolRackNodeTag)
            if (PistolRackNode != none)
                break;

        LabMonkey.SetPhysics(PHYS_Falling);
        LabMonkey.LabMonkeyController = self;
    }

    if (PistolRackNode == none)
        LogDebug("ERROR: PistolRackNode not found");

    AddTimer(RandRange(IdleDialogInterval.Min, IdleDialogInterval.Max),
        'PlayIdleSound', true);

    // Kinda half assed, but wait a tenth of a second to find the Dude
    SetTimer(0.1, false);
}

/** Find the Postal Dude now that he has been completely setup */
function Timer() {

    foreach DynamicActors(class'Pawn', PostalDude)
        if (PlayerController(PostalDude.Controller) != none)
            break;

    foreach DynamicActors(class'PLFormationManager', FormationManager)
        if (FormationManager != none)
            break;

    if (FormationManager == none)
        FormationManager = Spawn(class'LabMonkeyFormationManager');

    if (FormationManager == none) {
        LogDebug("ERROR: Formation Manager not found");
        return;
    }

    if (PostalDude == none) {
        LogDebug("ERROR: Postal Dude not found");
        return;
    }

    if (FormationManager != none && PostalDude != none && LabMonkey != none)
        FormationAnchor = FormationManager.GetFormationAnchor(LabMonkey, PostalDude);

    GotoState('Idle');
}

/**
 * For some reason the animations that are normally saved, but that doesn't
 * matter too much as we can easily determine what animation we should be
 * playing from our state
 */
event PostLoadGame() {
    super.PostLoadGame();

    if (LabMonkey == none) {
        LogDebug("ERROR: LabMonkey reference is null");
        return;
    }

    switch (GetStateName()) {
        case 'Idle':
        case 'AttackEnemy':
            LabMonkey.PlayWaiting();
            break;

        case 'MoveToGunRack':
        case 'MoveToPostalDude':
        case 'MoveToEnemy':
            LabMonkey.PlayMoving();
            break;
    }
}

/**
 * Overriden to implement Multi-Timer functionality, plus it's nice to have
 * it independent from the update timers
 */
function TimerFinished(name ID) {
    switch (ID) {
        case 'AllowPistolRefire':
            bCanFirePistol = true;
            break;

        case 'PlayIdleSound':
            PlayIdleSound();
            break;

        case 'UnpauseIdleSoundTimer':
            SetTimerPauseByID('PlayIdleSound', false);
            break;
    }
}

/** Play a random idle sound */
function PlayIdleSound() {
    local sound IdleSound;

    IdleSound = IdleSounds[Rand(IdleSounds.length)];

    if (IdleSound != none) {

        Pawn.PlaySound(IdleSound, SLOT_Talk, 1, false, 300);

        SetTimerPauseByID('PlayIdleSound', true);

        AddTimer(GetSoundDuration(IdleSound), 'UnpauseIdleSoundTimer', false);
    }
}

/** Play a pain sound, ouch! */
function PlayPainSound() {
    local sound PainSound;

    PainSound = PainSounds[Rand(PainSounds.length)];

    if (PainSound != none) {

        Pawn.PlaySound(PainSound, SLOT_Talk, 1, false, 300);

        SetTimerPauseByID('PlayIdleSound', true);

        AddTimer(GetSoundDuration(PainSound), 'UnpauseIdleSoundTimer', false);
    }
}

/** Play an enemy spotted sound */
function PlaySpotSound() {
    local sound SpotSound;

    if (FRand() > SpotSoundChance)
        return;

    SpotSound = SpotSounds[Rand(SpotSounds.length)];

    if (SpotSound != none)
        Pawn.PlaySound(SpotSound, SLOT_Talk, 1, false, 300);
}

/** Play our last dying breath*/
function PlayDeathSound() {
    local sound DeathSound;

    DeathSound = DeathSounds[Rand(DeathSounds.length)];

    if (DeathSound != none)
        Pawn.PlaySound(DeathSound, SLOT_Talk, 1, false, 300);
}

/** Tells our Lab Monkey to fire his pistol */
function FirePistol() {

    if (LabMonkey != none && Enemy != none) {
        LabMonkey.FirePistol(Enemy);
        bCanFirePistol = false;
    }
}

/** Notification from our Pawn that our lock has been broken */
function NotifyLockBreak() {

    if (LabMonkey != none) {

        if (!LabMonkey.bMonkeyAlreadyHasPistol && PistolRackNode != none)
            GotoState('MoveToGunRack');
        else {
            LabMonkey.EquipPistol();
            SetTimer(IdleThinkInterval, true);
        }

        LabMonkey.bMonkeyLockedUp = false;
    }
}

/**
 * Notification from our Pawn that the Monkeys are now free to escape
 *
 * @param ExitNode - Path node to set our ExitPathNode to
 */
function NotifyReleaseFromPostalDude(PathNode ExitNode) {
    bReleasedFromPostalDude = true;
    ExitPathNode = ExitNode;

    if (ExitPathNode != none)
        GotoState('MoveToExit');
    else
        GotoState('Idle');
}

/** Notification from our Pawn that we were just hit */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    PlayPainSound();

    if (AnimalPawn(InstigatedBy) != none && LabMonkey(InstigatedBy) == none &&
        Enemy == none) {

        Enemy = InstigatedBy;

        SetupToAttackEnemy();
    }
}

/** Notification from our Pawn that our little monkey died */
function NotifyPawnDied() {
    PlayDeathSound();

    if (FormationManager != none && FormationAnchor != none)
        FormationManager.RemoveAnchor(FormationAnchor);

    Destroy();
}

/** Overriden so we can do find potential targets */
function PawnSeen(Pawn Other) {

    // Ignore other animals, unless they attack us
    if (Enemy != none || AnimalPawn(Other) != none)
        return;

    if (Other != none && Other != PostalDude && Other.Health > 0 &&
        Other != Pawn && LabMonkey(Other) == none &&
       (PostalDude == none ||
        VSize(Other.Location - PostalDude.Location) < EnemyAbandonRadius)) {

        Enemy = Other;
    }

    if (Enemy != none)
        SetupToAttackEnemy();
}

/** Perform various things in preparation to attack an enemy */
function SetupToAttackEnemy() {
    PlaySpotSound();

    FiringRadius = RandRange(EnemyFiringRange.Min, EnemyFiringRange.Max);

    if (FormationAnchor != none && Enemy != none)
        FormationAnchor.SetTarget(Enemy);

    if (ShouldMoveToEnemy() || !HasLineOfSightToEnemy())
        GotoState('MoveToEnemy');
    else
        GotoState('AttackEnemy');
}

/** Determines whether we should be walking or running */
function UpdateMovementSpeed() {

    if (LabMonkey != none)
        LabMonkey.SetWalking(ShouldWalkToPostalDude());
}

/** Teleports our monkey to the Postal Dude if we got stuck somewhere */
function TeleportToPostalDude() {

    local PathNode TeleportNode;

    if (PostalDude == none)
        return;

    TeleportNode = GetTeleportNode();

    if (TeleportNode != none) {

        Pawn.SetLocation(TeleportNode.Location);
        Pawn.SetPhysics(PHYS_Falling);

        PathNotFoundCount = 0;
    }
}

/** Sad Monkey is sad sitting inside his cage, or we're free so yay! */
state Idle
{
    function BeginState() {
        LogDebug("Entered Idle state...");

        Enemy = none;

        FocalPoint = Pawn.Location + vector(Pawn.GetViewRotation()) * 256;

        if (FormationAnchor != none && PostalDude != none)
            FormationAnchor.SetTarget(PostalDude);

        // Only initiate the think timer if we're free
        if (LabMonkey != none && !LabMonkey.bMonkeyLockedUp && !bReleasedFromPostalDude)
            SetTimer(IdleThinkInterval, true);
        else // Otherwise cancel the timer
            SetTimer(0.0, false);

        SetTimerPauseByID('PlayIdleSound', false);
        SetTimerPauseByID('UnpauseIdleSoundTimer', false);
    }

    function Timer() {
        CheckSurroundingPawns();

        if (ShouldMoveToPostalDude())
            GotoState('MoveToPostalDude');
    }

Begin:
    StopMoving();

    Sleep(0.1);

    if (LabMonkey != none)
        LabMonkey.PlayWaiting();
}

/**
 * We can't find a path to the Postal Dude, so wait we're gonna wait a second
 * before we try looking for a path again
 */
state WaitForPathToDude
{

    function BeginState() {
        LogDebug("Entered WaitForPathToDude state...");

        // We only want to consider teleporting if we're too far from the Dude
        PathNotFoundCount++;

        if (ShouldTeleportToDude())
            TeleportToPostalDude();

        SetTimer(PathWaitTime, false);
    }

    function Timer() {
        GotoState('MoveToPostalDude');
    }

Begin:
    StopMoving();

    Sleep(0.1);

    if (LabMonkey != none)
        LabMonkey.PlayWaiting();
}

/**
 * We can't find a path to the enemy, so wait we're gonna wait a second
 * before just abandoning the enemy and returning to the Dude
 *
 * NOTE: I may revisit this and add some more advanced pathfinding logic for
 * enemies that can't be reached
 */
state WaitForPathToEnemy
{

    function BeginState() {
        LogDebug("Entered WaitForPathToEnemy state...");

        SetTimer(PathWaitTime, false);
    }

    function Timer() {
        GotoState('Idle');
    }

Begin:
    StopMoving();

    Sleep(0.1);

    if (LabMonkey != none)
        LabMonkey.PlayWaiting();
}

/** Now that we're out, we should go and find a pistol */
state MoveToGunRack
{
    function BeginState() {
        LogDebug("Entered MoveToGunRack state...");

        SetTimer(MoveThinkInterval, true);

        SetTimerPauseByID('PlayIdleSound', false);
        SetTimerPauseByID('UnpauseIdleSoundTimer', false);
    }

    function Timer() {

        if (HasReachedPistolRack() && LabMonkey != none) {
            LabMonkey.EquipPistol();
            GotoState('Idle');
        }
    }

Begin:
    if (LabMonkey != none) {
        LabMonkey.SetWalking(false);
        LabMonkey.PlayMoving();
    }

    while (!HasReachedPistolRack()) {
        if (ActorReachable(PistolRackNode))
            MoveToward(PistolRackNode);
		else {
			MoveTarget = FindPathToward(PistolRackNode);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else // Go back to idle state and wait to see if we can find a path
                GotoState('Idle');
		}
    }
}

/**
 * Follow the hairless one so we may serve him. For following the Dude on the
 * go, our formation doesn't really matter as much.
 */
state MoveToPostalDude
{
    function BeginState() {
        LogDebug("Entered FollowPlayer state...");

        Enemy = none;

        SetTimer(MoveThinkInterval, true);

        SetTimerPauseByID('PlayIdleSound', false);
        SetTimerPauseByID('UnpauseIdleSoundTimer', false);
    }

    function Timer() {
        CheckSurroundingPawns();

        UpdateMovementSpeed();

        if (HasReachedPostalDude())
            GotoState('Idle');
    }

Begin:
    if (LabMonkey != none)
        LabMonkey.PlayMoving();

    if (FormationAnchor != none && PostalDude != none)
        FormationAnchor.SetTarget(PostalDude);

    while (!HasReachedPostalDude()) {
        if (ActorReachable(FormationAnchor)) {

            // Reset our teleport tolerance if we can move
            PathNotFoundCount = 0;

            MoveToward(FormationAnchor);
        }
		else {
			MoveTarget = FindPathToward(FormationAnchor);

            if (MoveTarget != none) {

                // Reset our teleport tolerance if we can move
                PathNotFoundCount = 0;

                MoveToward(MoveTarget);
            }
            else
                GotoState('WaitForPathToDude');
		}
    }
}

/**
 * Move toward our enemy if we're out of range or if we don't have a line of
 * sight in which we can shoot'em. Formation doesn't matter as much when we're
 * chasing after an enemy on the move
 */
state MoveToEnemy
{
    function BeginState() {
        LogDebug("Entered MoveToEnemy state...");

        SetTimer(MoveThinkInterval, true);

        SetTimerPauseByID('PlayIdleSound', true);
        SetTimerPauseByID('UnpauseIdleSoundTimer', true);
    }

    function Timer() {

        if ((Enemy != none && Enemy.Health <= 0) || Enemy == none ||
             ShouldAbandonEnemy())
             GotoState('Idle');
        else if (HasReachedEnemy() && HasLineOfSightToEnemy())
            GotoState('AttackEnemy');
    }

Begin:
    if (LabMonkey != none) {
        LabMonkey.SetWalking(false);
        LabMonkey.PlayMoving();
    }

    while (!HasReachedEnemy() || !HasLineOfSightToEnemy()) {
        if (ActorReachable(FormationAnchor))
            MoveToward(FormationAnchor);
		else {
			MoveTarget = FindPathToward(FormationAnchor);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                GotoState('WaitForPathToEnemy');
		}
    }
}

/** Now that we've broken out of the ACC, make a mad dash toward the exit */
state MoveToExit
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        if (LabMonkey != none)
            LabMonkey.DropPistol();
			
		// Tell the gameinfo we lived
		PLBaseGameInfo(Level.Game).MonkeySurvived(Pawn);

        SetTimer(MoveThinkInterval, true);
    }

    function Timer() {
        if (HasReachedExitNode()) {
            if (FormationManager != none && FormationAnchor != none)
                FormationManager.RemoveAnchor(FormationAnchor);

            Pawn.Destroy();
            Destroy();
        }
    }

Begin:
    if (LabMonkey != none) {
        LabMonkey.SetWalking(false);
        LabMonkey.PlayMoving();
    }

    while (!HasReachedExitNode()) {
        if (ActorReachable(ExitPathNode))
            MoveToward(ExitPathNode);
		else {
			MoveTarget = FindPathToward(ExitPathNode);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else {
                ClosestPathNode = GetClosestPathNode(Pawn, true);

                Sleep(0.5);

                if (ClosestPathNode != none)
                    GotoState('MoveToClosest');
            }
		}
    }

    if (FormationManager != none && FormationAnchor != none)
        FormationManager.RemoveAnchor(FormationAnchor);

    Pawn.Destroy();
    Destroy();
}

/** See if moving to the closest PathNode will fix the pathing error */
state MoveToClosest
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        SetTimer(MoveThinkInterval, true);
    }

    function Timer() {
        if (HasReachedClosestNode())
            GotoState('MoveToExit');
    }

Begin:
    while (!HasReachedClosestNode()) {
        if (ActorReachable(ClosestPathNode))
            MoveToward(ClosestPathNode);
		else {
			MoveTarget = FindPathToward(ClosestPathNode);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                GotoState('Idle');
		}
    }

    GotoState('MoveToExit');
}

/** Shoot our captors, thanks to them, I forgot how to throw poop! */
state AttackEnemy
{
    function BeginState() {
        LogDebug("Entered AttackEnemy state...");

        Focus = Enemy;

        SetTimer(AttackThinkInterval, true);

        SetTimerPauseByID('PlayIdleSound', true);
        SetTimerPauseByID('UnpauseIdleSoundTimer', true);
    }

    function Timer() {
        local float PistolRefireTime;

        if (ShouldMoveToEnemy() || !HasLineOfSightToEnemy())
            GotoState('MoveToEnemy');
        else if (Enemy == none || ShouldAbandonEnemy())
            GotoState('Idle');
        else if (Enemy != none) {
            if (Enemy.Health <= 0)
                GotoState('Idle');
            else if (IsInFacingAngle(Enemy, FiringFOV) && bCanFirePistol) {

                PistolRefireTime = RandRange(FiringInterval.Min,
                    FiringInterval.Max);

                AddTimer(PistolRefireTime, 'AllowPistolRefire', false);

                FirePistol();
            }
        }
    }

Begin:
    StopMoving();

    Sleep(0.1);

    if (LabMonkey != none)
        LabMonkey.PlayWaiting();
}

defaultproperties
{
    bLogDebug=false

    bCanFirePistol=true

    MoveReachedRadius=64
    MoveWalkRadius=192
    ExitRadius=128

    IdleThinkInterval=0.2
    MoveThinkInterval=0.1
    AttackThinkInterval=0.1

    PathWaitTime=2

    FiringFOV=30
    FiringInterval=(Min=1,Max=2)

    EnemyAbandonRadius=1536
    EnemyFiringRange=(Min=512,Max=1024)

    IdleDialogInterval=(Min=5,Max=10)

    SpotSoundChance=0.25

    PathNotFoundMax=3

    TeleportRadius=1536
    TeleportMinRadiusFromDude=128
    OutOfSightAngle=180

    IdleSounds(0)=sound'LabMonkeyDialog.LabMonkey-IDLE1'
    IdleSounds(1)=sound'LabMonkeyDialog.LabMonkey-IDLE2'
    IdleSounds(2)=sound'LabMonkeyDialog.LabMonkey-IDLE3'
    IdleSounds(3)=sound'LabMonkeyDialog.LabMonkey-IDLE4'

    SpotSounds(0)=sound'LabMonkeyDialog.LabMonkey-SPOT1'
    SpotSounds(1)=sound'LabMonkeyDialog.LabMonkey-SPOT2'
    SpotSounds(2)=sound'LabMonkeyDialog.LabMonkey-SPOT3'

    PainSounds(0)=sound'LabMonkeyDialog.LabMonkey-PAIN1'
    PainSounds(1)=sound'LabMonkeyDialog.LabMonkey-PAIN2'
    PainSounds(2)=sound'LabMonkeyDialog.LabMonkey-PAIN3'

    DeathSounds(0)=sound'LabMonkeyDialog.LabMonkey-DEATH1'
    DeathSounds(1)=sound'LabMonkeyDialog.LabMonkey-DEATH2'
    DeathSounds(2)=sound'LabMonkeyDialog.LabMonkey-DEATH3'

    VisionFOV=360
    VisionRange=1024
}