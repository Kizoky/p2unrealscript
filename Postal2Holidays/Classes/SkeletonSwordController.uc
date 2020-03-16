/**
 * SkeletonMaceController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Here we define the character specific stuff for Sword Skeleton. It includes
 * unique stuff such as his swing attack damages, whether or not he walks or
 * runs, and his animations and their properties
 *
 * @author Gordon Cheng
 */
class SkeletonSwordController extends SkeletonMeleeController;

defaultproperties
{
    bWalksTowardEnemy=false

    HSwingDamage=20
    HSwingMomentum=60000
    HSwingFlyVel=250
    HSwingAngle=90
    HSwingTime=0.63

    VSwingDamage=20
    VSwingMomentum=60000
    VSwingFlyVel=125
    VSwingAngle=30
    VSwingTime=0.63

    HSwingStopMovePct=0.9
    VSwingStopMovePct=0.9

    MeleeSwingMoveSpeed=450
    MeleeSwingRange=128
    MeleeRange=128
    MeleePlayerDamageMult=3

    SkeletonIdleAnim=(Anim="s_sword_idle",Rate=1,AnimTime=10)
    SkeletonWalkAnim=(Anim="s_sword_run",Rate=0.35,AnimTime=0.63)
    SkeletonRunAnim=(Anim="s_sword_run",Rate=1,AnimTime=0.63)

    HSwingAnim=(Anim="s_sword_horizontal_swing",AnimTime=0.63)
    VSwingAnim=(Anim="s_sword_vertical_swing",AnimTime=0.63)

    MeleeDamageType=class'MacheteDamage'
}