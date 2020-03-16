/**
 * EasterBunnyGroundImpact
 *
 * A puff of smoke and rocks coming out of the ground
 */
class EasterBunnyGroundImpact extends P2Explosion;

defaultproperties
{
    ExplosionDamage=0
    ExplosionRadius=0

    ExplodingSound=none

    Begin Object class=SpriteEmitter name=SpriteEmitter0
        UseColorScale=true
        ColorScale(0)=(Color=(B=175,G=199,R=209))
        ColorScale(1)=(RelativeTime=1,Color=(B=56,G=102,R=122))
        FadeOut=true
        MaxParticles=12
        RespawnDeadParticles=false
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1))
        StartSizeRange=(X=(Min=160,Max=180))
        InitialParticlesPerSecond=100
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        SecondsBeforeInactive=0
        LifetimeRange=(Min=5,Max=3)
        StartVelocityRange=(X=(Min=-240,Max=240),Y=(Min=-240,Max=240),Z=(Min=-240,Max=80))
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'
    Begin Object class=SpriteEmitter name=SpriteEmitter1
		SecondsBeforeInactive=0
        Acceleration=(Z=-600)
        MaxParticles=20
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-30,Max=30),Y=(Min=-30,Max=30),Z=(Min=-30,Max=30))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=2))
        StartSpinRange=(X=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=7,Max=15))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=true
        LifetimeRange=(Min=1,Max=1.500000)
        StartVelocityRange=(X=(Min=-600,Max=600),Y=(Min=-600,Max=600),Z=(Max=500))
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'
}