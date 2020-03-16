/**
 * SkeletonMace
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * A slow, but strong skeleton wielding a heavy mace. Like Habib the Dead
 * Terrorist, the Mace Skeleton is too slow to be a threat to the Postal Dude,
 * but he's great at wreacking havoc among Bystanders
 *
 * @author Gordon Cheng
 */
class SkeletonMace extends SkeletonMelee
    placeable;

var array<sound> MeleeGroundHit;

/** Play our body hit sounds */
function PlayGroundHitSound() {
    PlaySound(MeleeGroundHit[Rand(MeleeGroundHit.length)], SLOT_Ambient, 1, false, 300);
}

defaultproperties
{
    ControllerClass=class'SkeletonMaceController'

    MeleeSwingSounds(0)=sound'AWSoundFX.Sledge.hammerswingmiss'
    //MeleeSwingSounds(1)=sound'AWSoundFX.Sledge.hammerthrowin'
    //MeleeSwingSounds(2)=sound'AWSoundFX.Sledge.hammerthrowloop'

    MeleeHitSounds(0)=sound'AWSoundFX.Sledge.hammersmashbody'

    MeleeGroundHit(0)=sound'AWSoundFX.Sledge.hammerhitwall_1'
    MeleeGroundHit(1)=sound'AWSoundFX.Sledge.hammerhitwall_2'

    Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'MRT_Holidays.helmet_horned',bAttachToHead=true,bCanDrop=false)
    Boltons(1)=(Bone="MALE01 r hand",StaticMesh=StaticMesh'MRT_Holidays.Halloween.mace_bolton',bCanDrop=false)

    HealthMax=300
}
