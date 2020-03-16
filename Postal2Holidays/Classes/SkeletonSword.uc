/**
 * SkeletonSword
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * This skeleton carries a sword into combat with him and is capable of running
 * toward enemies and performing quick swings. These guys are sorta a threat
 * to the Dude, but not too big as long as the player pays attention
 *
 * @author Gordon Cheng
 */
class SkeletonSword extends SkeletonMelee
    placeable;

defaultproperties
{
    ControllerClass=class'SkeletonSwordController'

    MeleeSwingSounds(0)=sound'AWSoundFX.Machete.macheteswingmiss'
    MeleeSwingSounds(1)=sound'AWSoundFX.Machete.machetethrowin'
    MeleeSwingSounds(2)=sound'AWSoundFX.Machete.machetethrowloop'

    MeleeHitSounds(0)=sound'AWSoundFX.Machete.macheteslice'
    MeleeHitSounds(1)=sound'AWSoundFX.Machete.machetelimbhit'

    Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'MRT_Holidays.helmet_horned',bAttachToHead=true,bCanDrop=false)
    Boltons(1)=(Bone="MALE01 r hand",StaticMesh=StaticMesh'MRT_Holidays.sword_bolton',bCanDrop=false)

    HealthMax=150
}
