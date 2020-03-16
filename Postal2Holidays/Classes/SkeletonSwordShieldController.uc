/**
 * SkeletonSwordShieldController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * An extension of the regular Sword Skeleton in that this one knows
 * attempts to block incoming bullets using his old wooden shield
 *
 * @author Gordon Cheng
 */
class SkeletonSwordShieldController extends SkeletonSwordController;

var AnimInfo SkeletonShieldWalkAnim;

/** Overriden to we can implement the walking loop animation */
function TimerFinished(name ID) {
    super.TimerFinished(ID);

    switch(ID) {
        case 'LoopShieldWalkingAnimation':
            LoopShieldWalkingAnimation();
            break;
    }
}

/** Play our walking animation with the shield up */
function LoopShieldWalkingAnimation() {
    Pawn.AnimBlendToAlpha(FALLINGCHANNEL, 0, 0);
    PlayAnimInfo(SkeletonShieldWalkAnim);
}

/** When we're shot bring our shield up to help block some bullets */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    if (Enemy != none && IsInState('MoveToEnemy'))
        GotoState('MoveToEnemyShield');
}

/** Bullets and shovels may break my bones, but this shield will sorta protect me */
state MoveToEnemyShield
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        SetPawnWalking(true);

        PlayAnimInfo(SkeletonShieldWalkAnim, AnimBlendTime);
        AddTimer(GetAnimDefaultDuration(SkeletonShieldWalkAnim),
            'LoopShieldWalkingAnimation', true);

        SetTimer(ThinkInterval, true);
    }

    function EndState() {
        RemoveTimerByID('LoopShieldWalkingAnimation');
    }

    function Timer() {
        // Ensure we retain our moving speed when we move
        if (Pawn.GroundSpeed == 0)
            SetPawnWalking(bWalksTowardEnemy);

        // Even though we have an enemy, let's check for a better one
        CheckSurroundingPawns();

        if (IsEnemyDead() || IsEnemyTooFar())
            ResetAttackTarget();
        else if (IsCloseEnoughForSwing())
            GotoState('AttackEnemy');
    }

Begin:
    while (!HasReachedEnemy()) {
        if (ActorReachable(Enemy))
            MoveToward(Enemy);
		else {
			MoveTarget = FindPathToward(Enemy);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                CantFindPathToEnemy();
		}
    }

    GotoState('AttackEnemy');
}

defaultproperties
{
    SkeletonShieldWalkAnim=(Anim="s_walk_shield",Rate=1,AnimTime=1.03)
}
