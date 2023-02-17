/**
 * MountedWeaponBulletHitPack
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * All the bullet effects for the Mounted weapons that fire bullets
 *
 * @author Gordon Cheng
 */
class MountedWeaponBulletHitPack extends PLWeaponBulletHitPack;

defaultproperties
{
    DecalClass=none

    SmokeEmitterClass=class'MountedWeaponHitSmoke'
    SparkEmitterClass=class'MountedWeaponHitSpark'
    DirtEmitterClass=class'MountedWeaponHitDirtClods'

    DirtChance=1
    SparkChance=1

    RicochetSoundChance=0
    WallHitSoundChance=0
}