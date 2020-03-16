/**
 * SkeletonMelee
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Base for Skeletons that use melee weapons and attacks. Here we implement the
 * overriding of of animations as well as sending notifications to our AI
 * Controller
 *
 * @author Gordon Cheng
 */
class SkeletonMelee extends SkeletonBase;

/** Various skeleton and weapon swing sounds */
var array<sound> MeleeSwingSounds, MeleeHitSounds;

/** Various objects that we should keep track of */
var SkeletonMeleeController MeleeController;

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType) {
    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

    Say(myDialog.lgothit, true);
}

/** Play our grunting sound as well as our swing sound */
function PlayStartSwingSounds() {
    Say(myDialog.lWhileFighting, true);
    PlaySound(MeleeSwingSounds[Rand(MeleeSwingSounds.length)], SLOT_Misc, 1, false, 300);
}

/** Play our body hit sounds
 * @param Other - Object to play the body hit sound
 */
function PlayBodyHitSound(Actor Other) {
    Other.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)], SLOT_Misc, 1, false, 300);
}

/** Notification from our SkeletalMesh that we should play our swing sound */
function NotifyStartSwing() {
    PlayStartSwingSounds();
}

/** Pass on the horizontal attack notification over to our AI Controller */
function NotifyHorizontalSwing() {
    if (MeleeController != none)
        MeleeController.NotifyHorizontalSwing();
}

/** Pass on the vertical attack notification over to our AI Controller */
function NotifyVerticalSwing() {
    if (MeleeController != none)
        MeleeController.NotifyVerticalSwing();
}

defaultproperties
{
    CoreMeshAnim=MeshAnimation'Halloweeen_Anims.animSkeleton'
}
