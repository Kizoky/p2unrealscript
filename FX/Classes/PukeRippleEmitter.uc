//=============================================================================
// Fluid ripples for things pouring into puddles
//=============================================================================
class PukeRippleEmitter extends FluidRippleEmitter;

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter10
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(A=255,R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255,G=255,B=255))
        FadeOut=True
        MaxParticles=20
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
        StartLocationOffset=(Z=5.000000)
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=15.000000,Max=20.000000),Y=(Min=15.000000,Max=20.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.pukesplat'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=3.000000,Max=3.000000)
        Name="SuperSpriteEmitter10"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter10'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter11
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(A=255,R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255,G=255,B=255))
        MaxParticles=20
        StartSizeRange=(X=(Min=0.700000,Max=2.000000),Y=(Min=0.700000,Max=2.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.pukesplat'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=1.500000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=3.000000,Max=5.000000))
        Name="SuperSpriteEmitter11"
    End Object
    Emitters(1)=SuperSpriteEmitter'Fx.SuperSpriteEmitter11'
    AutoDestroy=true
} 
