/**
 * SkeletonMaceController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Here we define the character specific stuff for Mace Skeleton. It includes
 * unique stuff such as his swing attack damages, whether or not he walks or
 * runs, and his animations and their properties
 *
 * @author Gordon Cheng
 */
class SkeletonMaceController extends SkeletonMeleeController;

/** Emitter to spawn when the Mace hits the ground */
var class<P2Emitter> MeleeGroundHitEmitterClass;

/** Various object(s) we should keep track of */
var SkeletonMace MaceSkeleton;

/** Overriden so we can initialize various stuff */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    MaceSkeleton = SkeletonMace(aPawn);
}

/** Overriden so we can implement the mace impact AOE */
function NotifyVerticalSwing() {
    local float SwingDamage;
    local Actor RadiusActor;

    super.NotifyVerticalSwing();

    foreach Pawn.VisibleCollidingActors(class'Actor', RadiusActor, MeleeRange) {
        if (AWZombie(RadiusActor) == none) {
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

                if (MaceSkeleton != none)
                    MaceSkeleton.PlayGroundHitSound();
            }
        }
    }
}

defaultproperties
{
    bWalksTowardEnemy=true

    HSwingDamage=50
    HSwingMomentum=120000
    HSwingFlyVel=500
    HSwingAngle=90
    HSwingTime=2.03

    VSwingDamage=25
    VSwingMomentum=60000
    VSwingFlyVel=250
    VSwingAngle=30
    VSwingTime=2.03

    HSwingStopMovePct=0.53
    VSwingStopMovePct=0.58

    MeleeSwingMoveSpeed=112
    MeleeSwingRange=92
    MeleeRange=128

    SkeletonIdleAnim=(Anim="s_mace_idle",Rate=1,AnimTime=4.03)
    SkeletonWalkAnim=(Anim="s_mace_walk",Rate=1,AnimTime=1.03)
    SkeletonRunAnim=(Anim="s_mace_walk",Rate=2.85,AnimTime=1.03)

    HSwingAnim=(Anim="s_mace_horizontal_swing",AnimTime=2.03)
    VSwingAnim=(Anim="s_mace_overhead_swing",AnimTime=2.03)
}