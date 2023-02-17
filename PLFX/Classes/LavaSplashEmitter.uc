///////////////////////////////////////////////////////////////////////////////
// FIXME this isn't lava at all, it's actually a scaled-up gas emitter
///////////////////////////////////////////////////////////////////////////////
class LavaSplashEmitter extends P2Emitter;

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter57
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-150.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(G=255))
        FadeOut=True
        MaxParticles=20
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=60.000000)
        StartSizeRange=(X=(Min=10.000000,Max=14.000000),Y=(Min=25.000000,Max=35.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.gassplash'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.400000,Max=0.600000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=40.000000,Max=80.000000))
        Name="SuperSpriteEmitter57"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter57'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter58
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        ColorScale(0)=(Color=(R=255))
        FadeOut=True
        MaxParticles=3
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-7.000000,Max=7.000000),Y=(Min=-7.000000,Max=7.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=50.000000)
        StartSizeRange=(X=(Min=25.000000,Max=30.000000),Y=(Min=25.000000,Max=30.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.fluidripple'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.500000,Max=0.800000)
        Name="SuperSpriteEmitter58"
    End Object
    Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter58'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter84
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        ColorScale(0)=(Color=(R=255))
        FadeOut=True
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=50.000000)
        StartSizeRange=(X=(Min=35.000000,Max=40.000000),Y=(Min=35.000000,Max=40.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.gassplash'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.600000,Max=1.500000)
        StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000))
        VelocityLossRange=(X=(Min=3.000000,Max=4.000000),Y=(Min=3.000000,Max=4.000000))
        WarmupTicksPerSecond=0.100000
        RelativeWarmupTime=1.000000
        Name="SpriteEmitter84"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter84'
}