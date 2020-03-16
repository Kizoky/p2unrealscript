//=============================================================================
// BabeExplosion
// 
// Effect to accompany arrival of postal babes in MP when they dance around 
// the winner.
//=============================================================================
class BabeExplosion extends P2Emitter;

var Sound ExplodingSound;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
Begin:
	PlaySound(ExplodingSound,,1.0,,,,true);
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter21
		SecondsBeforeInactive=0.0
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        MaxParticles=12
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=60.000000,Max=90.000000))
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.500000,Max=2.500000)
        StartVelocityRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-60.000000,Max=60.000000))
        VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
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
        MaxParticles=25
        RespawnDeadParticles=False
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=10.000000,Max=50.000000)
        StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=20.000000,Max=30.000000))
        InitialParticlesPerSecond=350.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.softwhitedot'
        LifetimeRange=(Min=1.500000,Max=2.000000)
        StartVelocityRadialRange=(Min=-30.000000,Max=-300.000000)
        VelocityLossRange=(X=(Min=1.00000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        Name="SpriteEmitter31"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter31'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter64
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        FadeOutStartTime=2.000000
        FadeOut=True
        FadeInEndTime=1.000000
        FadeIn=True
        MaxParticles=30
        RespawnDeadParticles=False
        StartLocationOffset=(Z=-50.000000)
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=40.000000,Max=60.000000))
        InitialParticlesPerSecond=400.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.500000,Max=3.000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=20.000000,Max=250.000000))
        VelocityLossRange=(Z=(Min=1.000000,Max=1.000000))
        Name="SpriteEmitter64"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter64'
     AutoDestroy=true
	 LifeSpan=6.0
    ExplodingSound=Sound'WeaponSounds.rocket_explode'
}
