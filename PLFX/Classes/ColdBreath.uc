///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class ColdBreath extends PipeSmokeFPS;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter93
        Acceleration=(Z=1.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.500000
        FadeOut=True
        MaxParticles=8
        StartLocationRange=(X=(Min=-2.000000,Max=1.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.010000)
        SizeScale(1)=(RelativeTime=0.125000,RelativeSize=0.175000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=10.000000,Max=12.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'PLFXSkins.Particles.ColdBreath'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=2.600000)
		GetVelocityDirectionFrom=PTVD_OwnerAndStartPosition
        StartVelocityRange=(X=(Min=15.000000,Max=25.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-10.000000,Max=-2.000000))
        VelocityLossRange=(X=(Min=0.850000,Max=1.150000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        Name="SpriteEmitter93"
		AutoReset=True
		AutoDestroy=False
		RespawnDeadParticles=True
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter93'
    DrawScale=0.150000
	CullDistance=500
}
