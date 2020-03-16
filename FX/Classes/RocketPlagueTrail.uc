///////////////////////////////////////////////////////////////////////////////
// RocketPlagueTrail
// 
// Dirty smoke trail for rockets along with fire
///////////////////////////////////////////////////////////////////////////////
class RocketPlagueTrail extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter22
		SecondsBeforeInactive=0.0
        MaxParticles=8
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=60.000000,Max=90.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
        Name="SpriteEmitter22"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter22'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter23
		SecondsBeforeInactive=0.0
        MaxParticles=10
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=90.000000,Max=130.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.300000,Max=1.300000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
        Name="SpriteEmitter23"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter23'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter6
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        CoordinateSystem=PTCS_Relative
        FadeOut=True
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        StartSpinRange=(X=(Max=1.000000))
        SpinsPerSecondRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.250000)
        SizeScale(1)=(RelativeTime=0.250000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=7.000000,Max=8.000000))
        UniformSize=True
        Texture=Texture'nathans.Skins.firegroup3'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.400000,Max=0.400000)
        StartVelocityRange=(X=(Min=-120.000000,Max=-120.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
        Name="SpriteEmitter6"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter6'
    bTrailerSameRotation=True
    Physics=PHYS_Trailer
	RelativeLocation=(X=100.000)
    AutoDestroy=true
}