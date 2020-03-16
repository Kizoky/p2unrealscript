///////////////////////////////////////////////////////////////////////////////
// RocketFire
// 
// Fire on rocket as it flies
///////////////////////////////////////////////////////////////////////////////
class RocketFire extends P2Emitter;

defaultproperties
{
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
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=12.000000,Max=20.000000))
        UniformSize=True
        Texture=Texture'nathans.Skins.firegroup3'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=-200.000000,Max=-200.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
        Name="SpriteEmitter6"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter6'
    bTrailerSameRotation=true
	RelativeLocation=(X=100.000)
    AutoDestroy=true
	bReplicateMovement=true
}