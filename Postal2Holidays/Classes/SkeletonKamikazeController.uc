/**
 * SkeletonKamikazeController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Wander around, find someone, blow yourself up. If we can't find a path...
 * uh oh... our timer on our vest just ran out
 *
 * @author Gordon Cheng
 */
class SkeletonKamikazeController extends SkeletonController;

var int CantFindPathLimit;
var float BombBeepInterval;
var AnimInfo FinalWordsAnim;

var int CantFindPathCount;
var SkeletonKamikaze SkeletonKamikaze;

/** Returns whether or not the given Pawn is a suitable for bombing
 * @param Other - Pawn object to verify if it is a suitable bombing target
 * @return TRUE if the given Pawn is suitable; FALSE otherwise
 */
function bool IsValidSuicideBombTarget(Pawn Other) {
    // Crawling enemies are kinda hard to hit, so ignore them
    if (P2MoCapPawn(Other) != none && P2MoCapPawn(Other).bIsDeathCrawling)
        return false;

    return (Enemy == none && AWZombie(Other) == none &&
        AnimalPawn(Other) == none && GaryGhost(Other) == none &&
        Other.Health > 0 && !IsPlayerInCutscene(Other));
}

/** Returns whether or not the given Pawn is a player Pawn and is in a cutscene
 * @return TRUE if our Enemy is the player and is in a cutscene; FALSE otherwise
 */
function bool IsPlayerInCutscene(Pawn Other) {
    return ((Dude(Other) != none || AWDude(Other) != none) && Other.Health > 0 &&
        (Other.Controller == none || ScriptedController(Other.Controller) != none));
}

/** Simply sets the Enemy variable and changes state to run after the target
 * @param Other - Pawn to set as our target and move toward
 */
function SetSuicideBombTarget(Pawn Other) {
    Enemy = Other;
    GotoState('MoveToEnemy');
}

/** Resets the enemy variable and goes back to Idle */
function ResetAttackTarget() {
    Enemy = none;
    GotoState('Idle');
}

/** Overriden so we can initalize various stuff */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    SkeletonKamikaze = SkeletonKamikaze(aPawn);
}

/** Overriden so we can implement multi-timer functionality */
function TimerFinished(name ID) {
    super.TimerFinished(ID);

    switch(ID) {
        case 'PlayBeepSound':
            PlayBeepSound();;
            break;
    }
}

/** Play a bomb beeping sound to warn players and others */
function PlayBeepSound() {
    if (SkeletonKamikaze != none)
        SkeletonKamikaze.PlayBombBeepSound();
}

/** Overriden so we can implement finding and reacting to other Pawns */
function PawnSeen(Pawn Other) {
    // Make sure the Pawn we saw is alive, not an animal, and not a fellow undead
    if (IsValidSuicideBombTarget(Other))
        SetSuicideBombTarget(Other);
}

/** Called whenver the Pawn takes damage */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    // Make sure the Pawn we saw is alive, not an animal, and not a fellow undead
    if (IsValidSuicideBombTarget(InstigatedBy))
        SetSuicideBombTarget(InstigatedBy);
}

/** We saw an infidel, now let's run over to him and blow up in his face */
state MoveToEnemy
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        SetPawnWalking(false);

        PlayAnimInfo(SkeletonRunAnim, AnimBlendTime);
        AddTimer(GetAnimDefaultDuration(SkeletonRunAnim), 'LoopRunningAnimation', true);

        if (SkeletonKamikaze != none)
            SkeletonKamikaze.PlaySuicideSound();

        SetTimer(ThinkInterval, true);

        AddTimer(BombBeepInterval, 'PlayBeepSound', true);
    }

    function EndState() {
        RemoveTimerByID('LoopRunningAnimation');
    }

    function Timer() {
        if (IsPlayerInCutscene(Enemy))
            ResetAttackTarget();
        else if (HasReachedEnemy() && SkeletonKamikaze != none)
            SkeletonKamikaze.DetonateExplosives();
    }

Begin:
    while (!HasReachedEnemy()) {
        if (ActorReachable(Enemy)) {
            MoveToward(Enemy);
            CantFindPathCount = 0;
        }
		else {
			MoveTarget = FindPathToward(Enemy);

            if (MoveTarget != none) {
				MoveToward(MoveTarget);
				CantFindPathCount = 0;
            }
            else {
                Sleep(0.1);
                CantFindPathCount++;

                if (CantFindPathCount == CantFindPathLimit)
                    GotoState('FinalWords');
            }
		}
    }

    // Ensure we exit this state in case something happens
    if (SkeletonKamikaze != none)
        SkeletonKamikaze.DetonateExplosives();
}

/** We couldn't find a path to our target, so say our final words */
state FinalWords
{
    function BeginState() {
        local float FinalWordsTime;

        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = Enemy;

        if (SkeletonKamikaze != none) {
            FinalWordsTime = SkeletonKamikaze.PlayOutOfTimeSound();
            PlayAnimByDuration(FinalWordsAnim, FinalWordsTime * 2, 0.1);
            SetTimer(FinalWordsTime, false);
        }
    }

    function Timer() {
        if (SkeletonKamikaze != none)
            SkeletonKamikaze.DetonateExplosives();
    }

Begin:
    StopMoving();
}

defaultproperties
{
    VisionFOV=180

    SkeletonIdleAnim=(Anim="z_idle_stand",Rate=1,AnimTime=1.93)
    SkeletonWalkAnim=(Anim="z_walk2",Rate=1,AnimTime=1.93)
    SkeletonRunAnim=(Anim="z_charge",Rate=1,AnimTime=1.66)

    CantFindPathLimit=10

    MoveReachedRadius=128
    BombBeepInterval=0.5
    FinalWordsAnim=(Anim="s_midfinger",AnimTime=2.13)
}
