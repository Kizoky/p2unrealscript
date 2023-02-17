/**
 * MutantChampFlamethrowerEmitter
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Mutant Champ has a serious case of doggy breath. So beware, or else it'll
 * melt your face off!
 *
 * @author Gordon Cheng
 */
class MutantChampFlamethrower extends FlamethrowerEmitter;

defaultproperties
{
	Range=1000
    Angle=10
    DamageRate=50

    FireRingInterval=0.2
    FireRingMinDistance=100
    FireRingFlatGround=0.8

    AmbientSound=Sound'LevelSoundsToo.Napalm.napalmFlameBurst'
	SoundRadius=600
	SoundVolume=128
}
