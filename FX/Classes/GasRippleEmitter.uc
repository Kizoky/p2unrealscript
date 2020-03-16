//=============================================================================
// Fluid ripples for things pouring into puddles
//=============================================================================
class GasRippleEmitter extends FluidRippleEmitter;

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter18
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        MaxParticles=8
        StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000))
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=30.000000,Max=40.000000),Y=(Min=30.000000,Max=40.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.waterblobs'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        UseRandomSubdivision=True
        LifetimeRange=(Min=0.700000,Max=1.000000)
        Name="SuperSpriteEmitter18"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter18'
	AutoDestroy=true
} 
