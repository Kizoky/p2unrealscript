/**
 * SkeletonMeleeController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Base AI Controller for melee weapon wielding skeletons. The Mace Skeleton
 * and Sword Skeleton actually have a lot in common, the only difference
 * being the attributes of their attacks, so we're gonna setup basic target
 * acquisition, movement, and attacks here
 *
 * @author Gordon Cheng
 */
class SkeletonMeleeController extends SkeletonController;

/** General movement variables */
var bool bWalksTowardEnemy;
var float EnemyAbandonDistance;

/** General information on the different melee attacks */
var float HSwingDamage, HSwingMomentum, HSwingFlyVel, HSwingAngle, HSwingTime;
var float VSwingDamage, VSwingMomentum, VSwingFlyVel, VSwingAngle, VSwingTime;

/** Animations used for the horizontal and vertical swing animations */
var float HSwingStopMovePct, VSwingStopMovePct;
var AnimInfo HSwingAnim, VSwingAnim;

/** General common properties for melee attacks such as range and damage type */
var float MeleeSwingMoveSpeed;
var float MeleeRange, MeleeSwingRange, MeleePlayerDamageMult;
var class<DamageType> MeleeDamageType;
var class<TimedMarker> MeleeSwingMarker;

/** Various object(s) we should keep track of */
var SkeletonMelee MeleeSkeleton;

/** Function prototype, so we don't have any possible scope problems later */
function PerformAttack();

/** Returns whether or not the Pawn seen is a valid target
 * @param Other - Pawn object we're gonna check if it is a suitable target
 * @return TRUE if the given Pawn is a valid target; FALSE otherwise
 */
function bool IsValidTarget(Pawn Other) {
    // Crawling enemies are kinda hard to hit, so ignore them
    if (P2MoCapPawn(Other) != none && P2MoCapPawn(Other).bIsDeathCrawling)
        return false;

    return (AWZombie(Other) == none && AnimalPawn(Other) == none &&
        GaryGhost(Other) == none && Other.Health > 0 && !IsPlayerInCutscene(Other));
}

/** Returns whether or not the enemy is dead
 * @return TRUE if the Enemy has been gibbed or killed; FALSE otherwise
 */
function bool IsEnemyDead() {
    // If they're death crawling, they close enough to dead, so find someone else
    if (P2MoCapPawn(Enemy) != none && P2MoCapPawn(Enemy).bIsDeathCrawling)
        return true;

    return (Enemy == none || Enemy.Health <= 0 || IsPlayerInCutscene(Enemy));
}

/** Returns whether or not our enemy has ran away too far
 * @return TRUE if our Enemy has ran far away; FALSE otherwise
 */
function bool IsEnemyTooFar() {
    if (Enemy == none)
        return false;

    return VSize(Enemy.Location - Pawn.Location) > EnemyAbandonDistance;
}

/** Returns whether or not the given Pawn is a player Pawn and is in a cutscene
 * @return TRUE if our Enemy is the player and is in a cutscene; FALSE otherwise
 */
function bool IsPlayerInCutscene(Pawn Other) {
    return ((Dude(Other) != none || AWDude(Other) != none) && Other.Health > 0 &&
        (Other.Controller == none || ScriptedController(Other.Controller) != none));
}

/** Returns whether or not the given Pawn is closer than our current Enemy
 * @param Other - Pawn object we're gonna check if it is closer than our enemy
 * @return TRUE if the given Pawn is closer than our current enemy; FALSE otherwise
 */
function bool IsCloserThanCurrentEnemy(Pawn Other) {
    if (Enemy == none)
        return false;

    return VSize(Other.Location - Pawn.Location) < VSize(Enemy.Location - Pawn.Location);
}

/** Returns whether or not a given Pawn is holding a weapon
 * @param Other - Pawn object we're gonna check if it is holding a weapon
 * @return TRUE if the Pawn is currently holding a weapon; FALSE otherwise
 */
function bool IsHoldingWeapon(Pawn Other) {
    return (Other.Weapon != none && HandsWeapon(Other.Weapon) == none);
}

/** Returns whether or not the Pawn is close enough for our melee weapon to hit
 * @return TRUE if the given Pawn is close enough; FALSE otherwise
 */
function bool IsCloseEnoughToHit() {
    if (Enemy == none)
        return false;

    return VSize(Enemy.Location - Pawn.Location) <= MeleeRange;
}

/** Returns whether or not the given Pawn is close enough that we should start swinging
 * @return TRUE if the given Pawn is close enough; FALSE otherwise
 */
function bool IsCloseEnoughForSwing() {
    if (Enemy == none)
        return false;

    return VSize(Enemy.Location - Pawn.Location) <= MeleeSwingRange;
}

/** Simply sets the Enemy variable and changes state to run after the target
 * @param Other - Pawn object we're gonna set as our target and proceed to attack
 */
function SetToAttackTarget(Pawn Other) {
    Enemy = Other;

    if (IsCloseEnoughForSwing())
        GotoState('AttackEnemy');
    else
        GotoState('MoveToEnemy');
}

/** Resets the enemy variable and goes back to Idle */
function ResetAttackTarget() {
    Enemy = none;
    GotoState('Idle');
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

/** Overriden so we can initialize various stuff */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    MeleeSkeleton = SkeletonMelee(aPawn);

    if (MeleeSkeleton != none)
        MeleeSkeleton.MeleeController = self;
}

/** Overriden so we can implement multi-timer functionality */
function TimerFinished(name ID) {
    super.TimerFinished(ID);

    switch(ID) {
        case 'HSwingStop':
            NotifyStopMove(true);
            break;

        case 'VSwingStop':
            NotifyStopMove(false);
            break;
    }
}

/** Overriden so if we can't find a path to our enemy, reset things */
function CantFindPathToEnemy() {
    ResetAttackTarget();
}

/** Overriden so we can implement finding and reacting to other Pawns
 * TODO: Make a better boolean statement rather than this if-else mess, if I weren't so lazy
 */
function PawnSeen(Pawn Other) {
    // For our debug phase, let's ignore the player
    //if ((Other.Controller != none && Other.Controller.bIsPlayer))
    //    return;

    // If it is not a valid target, then ignore him
    if (!IsValidTarget(Other))
        return;

    // If the new person we saw is holding a weapon, and our current enemy
    // isn't then we prioritize the enemy with a weapon
    if (Enemy != none && IsHoldingWeapon(Other) && !IsHoldingWeapon(Enemy))
        SetToAttackTarget(Other);

    // If the new person is closer and unarmed, and the enemy is also unarmed
    // then we can go for the closer person instead
    else if (Enemy != none && IsCloserThanCurrentEnemy(Other) && !IsHoldingWeapon(Other) && !IsHoldingWeapon(Enemy))
        SetToAttackTarget(Other);

    // If they're both holding a weapon and the new person is closer
    else if (Enemy != none && IsCloserThanCurrentEnemy(Other) && IsHoldingWeapon(Other) && IsHoldingWeapon(Enemy))
        SetToAttackTarget(Other);

    // Otherwise if we don't have a target, and it's valid, set it
    else if (Enemy == none)
        SetToAttackTarget(Other);
}

/** Called whenver the Pawn takes damage */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    // Prioritize enemies that have a gun on us
    //if ((Enemy != none && IsCloserThanCurrentEnemy(InstigatedBy) && IsHoldingWeapon(InstigatedBy)) || Enemy == none)
    //    SetToAttackTarget(InstigatedBy);
}

/** Notification from our Pawn to perform a horizontal swing damage */
function NotifyHorizontalSwing() {
    local float SwingDamage;
    local Actor RadiusActor;

    foreach Pawn.VisibleCollidingActors(class'Actor', RadiusActor, MeleeRange) {
        if (AWZombie(RadiusActor) == none && IsInFacingAngle(RadiusActor, HSwingAngle)) {
            if (Pawn(RadiusActor) != none && Pawn(RadiusActor).Controller != none &&
                Pawn(RadiusActor).Controller.bIsPlayer)
                SwingDamage = HSwingDamage * MeleePlayerDamageMult;
            else
                SwingDamage = HSwingDamage;

            RadiusActor.TakeDamage(SwingDamage, Pawn, RadiusActor.Location,
                Normal(RadiusActor.Location - Pawn.Location) * HSwingMomentum,
                MeleeDamageType);

            if (Pawn(RadiusActor) != none) {
                SendPawnFlying(Pawn(RadiusActor), HSwingFlyVel);

                if (MeleeSkeleton != none)
                    MeleeSkeleton.PlayBodyHitSound(RadiusActor);
            }
        }
    }

    if (MeleeSwingMarker != none)
        MeleeSwingMarker.static.NotifyControllersStatic(Level, MeleeSwingMarker,
            FPSPawn(Pawn), Pawn, MeleeSwingMarker.default.CollisionRadius,
            Pawn.Location);
}

/** Notification from our Pawn to perform */
function NotifyVerticalSwing() {
    local float SwingDamage;
    local Actor RadiusActor;

    foreach Pawn.VisibleCollidingActors(class'Actor', RadiusActor, MeleeRange) {
        if (AWZombie(RadiusActor) == none && IsInFacingAngle(RadiusActor, VSwingAngle)) {
            if (Pawn(RadiusActor) != none && Pawn(RadiusActor).Controller != none &&
                Pawn(RadiusActor).Controller.bIsPlayer)
                SwingDamage = VSwingDamage * MeleePlayerDamageMult;
            else
                SwingDamage = VSwingDamage;

            RadiusActor.TakeDamage(SwingDamage, Pawn, RadiusActor.Location,
                Normal(RadiusActor.Location - Pawn.Location) * VSwingMomentum,
                MeleeDamageType);

            if (Pawn(RadiusActor) != none) {
                SendPawnFlying(Pawn(RadiusActor), VSwingFlyVel);

                if (MeleeSkeleton != none)
                    MeleeSkeleton.PlayBodyHitSound(RadiusActor);
            }
        }
    }

    if (MeleeSwingMarker != none)
        MeleeSwingMarker.static.NotifyControllersStatic(Level, MeleeSwingMarker,
            FPSPawn(Pawn), Pawn, MeleeSwingMarker.default.CollisionRadius,
            Pawn.Location);
}

/** Notification to slowly come to a stop after an attack */
function NotifyStopMove(bool bHorizontalSwing) {
    if (bHorizontalSwing)
        InterpolateSpeed(HSwingTime - (HSwingTime * HSwingStopMovePct), 0, INTERP_Linear);
    else
        InterpolateSpeed(VSwingTime - (VSwingTime * VSwingStopMovePct), 0, INTERP_Linear);
}

/** We saw a living human being; We're jealous of their skin, so kill them! */
state MoveToEnemy
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        SetPawnWalking(bWalksTowardEnemy);

        if (bWalksTowardEnemy) {
            PlayAnimInfo(SkeletonWalkAnim, AnimBlendTime);
            AddTimer(GetAnimDefaultDuration(SkeletonWalkAnim), 'LoopWalkingAnimation', true);
        }
        else {
            PlayAnimInfo(SkeletonRunAnim, AnimBlendTime);
            AddTimer(GetAnimDefaultDuration(SkeletonRunAnim), 'LoopRunningAnimation', true);
        }

        SetTimer(ThinkInterval, true);
    }

    function EndState() {
        if (bWalksTowardEnemy)
            RemoveTimerByID('LoopWalkingAnimation');
        else
            RemoveTimerByID('LoopRunningAnimation');
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

/** Gonna kill ya, bury ya, and in several years I'll have a new best friend! */
state AttackEnemy
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Pawn.GroundSpeed = MeleeSwingMoveSpeed;

        //FaceForward();
        Focus = Enemy;

        PerformAttack();
    }

    function EndState() {
        Pawn.GroundSpeed = Pawn.default.GroundSpeed;
    }

    function PerformAttack() {
        local bool bHorizontalSwing;

        bHorizontalSwing = (FRand() < 0.5);

        if (bHorizontalSwing) {
            PlayAnimByDuration(HSwingAnim, HSwingTime, AnimBlendTime);
            SetTimer(HSwingTime, false);
            AddTimer(HSwingTime * HSwingStopMovePct, 'HSwingStop', false);
        }
        else {
            PlayAnimByDuration(VSwingAnim, VSwingTime, AnimBlendTime);
            SetTimer(VSwingTime, false);
            AddTimer(VSwingTime * VSwingStopMovePct, 'VSwingStop', false);
        }
    }

    function Timer() {
        if (IsEnemyDead())
            ResetAttackTarget();
        else if (IsCloseEnoughForSwing())
            PerformAttack();
        else
            GotoState('MoveToEnemy');
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = vector(Pawn.Rotation) * Pawn.GroundSpeed;
    }

Begin:
    StopMoving();
}

defaultproperties
{
    EnemyAbandonDistance=3072

    MeleePlayerDamageMult=1
    MeleeDamageType=class'DamageType'
    MeleeSwingMarker=class'GunfireMarker'
}
