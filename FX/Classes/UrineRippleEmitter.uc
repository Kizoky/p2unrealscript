//=============================================================================
// Fluid ripples for things pouring into puddles
//=============================================================================
class UrineRippleEmitter extends FluidRippleEmitter;

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter10
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255,G=255,B=255))
        FadeOut=True
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
        StartLocationOffset=(Z=5.000000)
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=15.000000,Max=20.000000),Y=(Min=15.000000,Max=20.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.fluidripple'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        Name="SuperSpriteEmitter10"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter10'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter18
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255,G=255,B=255))
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
        StartLocationOffset=(Z=5.000000)
        MaxParticles=20
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.300000)
        StartSizeRange=(X=(Min=4.000000,Max=6.000000),Y=(Min=4.000000,Max=6.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.bubbles'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.500000,Max=3.000000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=3.000000,Max=3.00000),Y=(Min=3.000000,Max=3.000000))
        Name="SuperSpriteEmitter18"
    End Object
    Emitters(1)=SuperSpriteEmitter'Fx.SuperSpriteEmitter18'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter11
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255,G=255,B=255))
        MaxParticles=20
        StartSizeRange=(X=(Min=0.700000,Max=2.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.Bubble'
        LifetimeRange=(Min=1.000000,Max=1.500000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=3.000000,Max=5.000000))
        Name="SuperSpriteEmitter11"
    End Object
    Emitters(2)=SuperSpriteEmitter'Fx.SuperSpriteEmitter11'
    AutoDestroy=true
} 
