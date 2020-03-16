/**
 * SkeletonController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * All our Skeletons will be various undead warriors of terrorists. As a result
 * each of them will automatically climb out of the ground and wander around
 * which we will implement here.
 *
 * We will then specialize behavior in the subclasses
 *
 * @author Gordon Cheng
 */
class SkeletonController extends P2EAIController;

/** Miscellaneous AI values */
var float AnimBlendTime, ThinkInterval;

/** Idle variables */
var range IdleWaitTime;
var AnimInfo SkeletonIdleAnim;

/** Movement variables */
var bool bSkeletonIsWalking;
var float MoveReachedRadius;
var AnimInfo SkeletonWalkAnim, SkeletonRunAnim;

/** Rising from our graves properties */
var float RiseFromGraveTime;
var AnimInfo RiseFromGraveAnim;

/** Various objects we should keep track of */
var Actor Destination;
var SkeletonBase Skeleton;

const FALLINGCHANNEL = 1;

/** Returns whether or not we've reached our destination
 * @return TRUE if we're close enough that we've reached out destination;
 *         FALSE otherwise
 */
function bool HasReachedDestination() {
    if (Destination == none)
        return true;

    return VSize(Destination.Location - Pawn.Location) <= MoveReachedRadius;
}

/** Returns whether or not we've reached our enemy
 * @return TRUE if we're close enough that we've reached our enemy;
 *         FALSE otherwise
 */
function bool HasReachedEnemy() {
    if (Enemy == none)
        return true;

    return VSize(Enemy.Location - Pawn.Location) <= MoveReachedRadius;
}

/** Takes a range and returns a value between the specified min and max values
 * @param r - A range value consisting of a minimum and maximum value
 * @return A value in between the specified min and max
 */
function float GetRangeValue(range r) {
    return r.Min + (r.Max - r.Min) * FRand();
}

/** Changes the Pawn's movement speed so it */
function SetPawnWalking(bool bNewIsWalking) {
    bSkeletonIsWalking = bNewIsWalking;

    if (bNewIsWalking)
        Pawn.GroundSpeed = Pawn.default.GroundSpeed * Pawn.WalkingPct;
    else
        Pawn.GroundSpeed = Pawn.default.GroundSpeed;
}

/** Overriden so we can initialize various stuff */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    aPawn.SetPhysics(PHYS_Falling);

    Skeleton = SkeletonBase(aPawn);

    GotoState('RiseFromGrave');
}

/** Overriden so we can implement multi-timer functionality */
function TimerFinished(name ID) {
    switch(ID) {
        case 'IdleWaitTimer':
            IdleWaitTimer();
            break;

        case 'LoopIdleAnimation':
            LoopIdleAnimation();
            break;

        case 'LoopWalkingAnimation':
            LoopWalkingAnimation();
            break;

        case 'LoopRunningAnimation':
            LoopRunningAnimation();
            break;
    }
}

/** Called whenever the IdleWait time has elapsed */
function IdleWaitTimer() {
    Destination = GetRandomPathNode(true);

    if (Destination != none)
        GotoState('MoveToDestination');
}

function LoopIdleAnimation() {
    PlayAnimInfo(SkeletonIdleAnim);
}

function LoopWalkingAnimation() {
    Pawn.AnimBlendToAlpha(FALLINGCHANNEL, 0, 0);
    PlayAnimInfo(SkeletonWalkAnim);
}

function LoopRunningAnimation() {
    Pawn.AnimBlendToAlpha(FALLINGCHANNEL, 0, 0);
    PlayAnimInfo(SkeletonRunAnim);
}

/** Overriden so we can implement finding and reacting to other Pawns */
function PawnSeen(Pawn Other) {
    // TODO: Implement the changing of states when we find an enemy in subclass
}

/** Called whenver the Pawn takes damage */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    // TODO: We don't normally target zombies, but if they hit us, target them
}

/** Called whenever the Skeleton can't find a path to our destination */
function CantFindPathToDestination() {
    GotoState('Idle');
}

/** Called whenever we can't find a path to our enemy */
function CantFindPathToEnemy() {
    GotoState('Idle');
}

/** Pull ourselves out of the ground for a pretty sweet entrance */
state RiseFromGrave
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        PlayAnimByDuration(RiseFromGraveAnim, RiseFromGraveTime);
        SetTimer(RiseFromGraveTime, false);
    }

    function Timer() {
        GotoState('Idle');
    }

Begin:
    StopMoving();
}

/** Just takin' a break from wandering around, or killin' people */
state Idle
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        SetTimer(ThinkInterval, true);

        PlayAnimInfo(SkeletonIdleAnim, AnimBlendTime);
        AddTimer(GetAnimDefaultDuration(SkeletonIdleAnim), 'LoopIdleAnimation', true);

        AddTimer(GetRangeValue(IdleWaitTime), 'IdleWaitTimer', true);
    }

    function Timer() {
        CheckSurroundingPawns();
    }

    function EndState() {
        RemoveTimerByID('IdleWaitTimer');
        RemoveTimerByID('LoopIdleAnimation');
    }

Begin:
    StopMoving();
}

/** Wander around, lookin' for stuff to kill */
state MoveToDestination
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        SetPawnWalking(true);

        PlayAnimInfo(SkeletonWalkAnim, AnimBlendTime);
        AddTimer(GetAnimDefaultDuration(SkeletonWalkAnim), 'LoopWalkingAnimation', true);

        SetTimer(ThinkInterval, true);
    }

    function EndState() {
        RemoveTimerByID('LoopWalkingAnimation');
    }

    function Timer() {
        CheckSurroundingPawns();

        if (HasReachedDestination())
            GotoState('Idle');
    }

Begin:
    while (!HasReachedDestination()) {
        if (ActorReachable(Destination))
            MoveToward(Destination);
		else {
			MoveTarget = FindPathToward(Destination);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                CantFindPathToDestination();
		}
    }

    // Ensure we exit this state in case something happens
    GotoState('Idle');
}

defaultproperties
{
    bControlAnimations=true

    AnimBlendTime=0.1

    VisionFOV=360
    VisionRange=2048

    IdleWaitTime=(Min=2,Max=3)
    ThinkInterval=0.1
    MoveReachedRadius=64

    RiseFromGraveTime=3
    RiseFromGraveAnim=(Anim="s_getsummon",AnimTime=2.36)
}