/**
 * MutantChampHomingProjectile
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Homing fireballs fired by Mutant Champ. They're essentially Gary Head
 * home projectiles only we took out the cackling sound and Gary Head mesh
 *
 * @author Gordon Cheng
 */
class MutantChampHomingProjectile extends GaryHeadHomingProjectile;

defaultproperties
{
    DrawType=DT_None
    AmbientSound=none

    CollisionRadius=40
    CollisionHeight=40

    explclass=class'MutantChampFireballExplosion'
    explflyclass=class'MutantChampFireballExplosion'
}
