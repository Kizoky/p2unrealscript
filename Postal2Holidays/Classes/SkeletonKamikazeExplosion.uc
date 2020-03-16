/**
 * SkeletonKamikazeExplosion
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Explosion for a suicide bomber skeleton Taliban
 *
 * @author Gordon Cheng
 */
class SkeletonKamikazeExplosion extends P2Explosion;

const BLOOD_INDEX = 2;

replication
{
	unreliable if(Role==ROLE_Authority)
		CheckForHitType;
}

/** Copied from RocketExplosion */
simulated function CheckForHitType(Actor Other) {
	// Make bloody explosion, but only if it hit a person and we allow blood
	if (Pawn(Other) != None && class'P2Player'.static.BloodMode())
		Emitters[BLOOD_INDEX].Disabled=false;
}

defaultproperties
{
	ExplosionMag=100000
	ExplosionRadius=750
	ExplosionDamage=60

    Begin Object Class=SpriteEmitter Name=SpriteEmitter21
		SecondsBeforeInactive=0.0
        MaxParticles=10
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=-80.000000,Max=80.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.000000)
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=150.000000,Max=200.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=3.00000,Max=3.500000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-100.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
        Name="SpriteEmitter21"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter21'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter31
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        FadeOutStartTime=0.500000
        FadeOut=True
        FadeInEndTime=0.500000
        FadeIn=True
        MaxParticles=20
        RespawnDeadParticles=False
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=100.000000,Max=300.000000)
        StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=10.000000,Max=30.000000))
        InitialParticlesPerSecond=200.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.softwhitedot'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRadialRange=(Min=900.000000,Max=1000.000000)
        VelocityLossRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000),Z=(Min=1.500000,Max=1.500000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        Name="SpriteEmitter31"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter31'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter15
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-600.000000)
        MaxParticles=25
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=2.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
		Disabled=true
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=5.000000,Max=35.000000))
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodchunks1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=500.000000))
        Name="SpriteEmitter15"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter15'
	LifeSpan=3.0
    ExplodingSound=Sound'WeaponSounds.rocket_explode'
    AutoDestroy=true
	MyDamageType = class'GrenadeDamage'
}