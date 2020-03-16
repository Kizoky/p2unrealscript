/**
 * SkeletonKamikaze
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * In life this member of the Taliban had a premature detonation and ended up
 * with 72 sweaty video game nerds, now on Hallow's Eve, he's given a second
 * chance.
 *
 * @author Gordon Cheng
 */
class SkeletonKamikaze extends SkeletonBase
    placeable;

/** Various sounds we should play to signify us suicide bombing */
var sound SuicideSound;
var sound BombBeepSound;
var array<sound> OutOfTimeSounds;

var class<P2Emitter> ExplosionEmitterClass;

var class<TimedMarker> BombBeepMarker;

/** Overriden as we need to include the rise from grave animation */
simulated function LinkAnims() {
    local int i;

    super.LinkAnims();

    for (i=0;i<ExtraAnims.length;i++)
		LinkSkelAnim(ExtraAnims[i]);
}

/** Play our Taliban trill sound to signify we're going after someone */
function PlaySuicideSound() {
    if (SuicideSound != none)
        PlaySound(SuicideSound, SLOT_Talk, 1, false, 300);
}

/** Play our Taliban trill sound to signify we're going after someone */
function PlayBombBeepSound() {
    if (BombBeepSound != none)
        PlaySound(BombBeepSound, SLOT_Misc, 1, false, 300);

    if (BombBeepMarker != none)
        BombBeepMarker.static.NotifyControllersStatic(Level, BombBeepMarker,
            self, self, BombBeepMarker.default.CollisionRadius, Location);
}

/** Play our out of time sound, signifying we can't reach our target. We also
 * return the time it takes for the sound to finish playing so we can time our
 * explosion and animation
 * @return Time in seconds the sound will last
 */
function float PlayOutOfTimeSound() {
    local int i;

    i = Rand(OutOfTimeSounds.length);

    if (OutOfTimeSounds[i] != none) {
        PlaySound(OutOfTimeSounds[i], SLOT_Talk, 1, false, 300);
        return GetSoundDuration(OutOfTimeSounds[i]);
    }

    return 0;
}

/** Time to go bye bye */
function DetonateExplosives() {
    if (ExplosionEmitterClass != none)
        Spawn(ExplosionEmitterClass);

    if (Controller != none)
        Controller.Destroy();

    ChunkUp(0);
}

defaultproperties
{
    CoreMeshAnim=MeshAnimation'AWCharacters.animAvg_AW'

    ExtraAnims.Empty
    ExtraAnims(0)=MeshAnimation'Halloweeen_Anims.animSkeleton'
    ExtraAnims(1)=MeshAnimation'Characters.animAvg'

    ExplosionEmitterClass=class'SkeletonKamikazeExplosion'

    BombBeepMarker=class'GunfireMarker'

    SuicideSound=sound'HabibDialog.habib_ailili'

    //BombBeepSound=sound'MiscSounds.Bleep'

    OutOfTimeSounds(0)=sound'HabibDialog.habib_imreadyformy'
    //OutOfTimeSounds(1)=sound'HabibDialog.habib_ak'
    //OutOfTimeSounds(2)=sound'HabibDialog.habib_argh'
    OutOfTimeSounds(1)=sound'HabibDialog.habib_dying'

    Health=50

    ZWalkPct=0.15

    Boltons(0)=(Bone="MALE01 r hand",Mesh=SkeletalMesh'ED_Weapons.Dynamite3rdMesh',bCanDrop=false,DrawScale=2)
    Boltons(1)=(Bone="MALE01 l hand",Mesh=SkeletalMesh'ED_Weapons.Dynamite3rdMesh',bCanDrop=false,DrawScale=2)

    ControllerClass=class'SkeletonKamikazeController'
}