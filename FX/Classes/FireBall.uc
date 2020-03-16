///////////////////////////////////////////////////////////////////////////////
// FireBall
// 
// Connects to firepillar
//
///////////////////////////////////////////////////////////////////////////////
class FireBall extends P2Emitter;

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter13
		SecondsBeforeInactive=0.0
        LocationShapeExtend=PTLSE_Circle
        UseColorScale=False
        ColorScale(1)=(RelativeTime=0.000000,Color=(B=180,G=240,R=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(G=41,R=137))
        Acceleration=(Z=60.000000)
        FadeOut=True
        MaxParticles=15
        RespawnDeadParticles=False
        SphereRadiusRange=(Max=10.000000)
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=0.30000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=120.000000,Max=180.000000))
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.firegroup2'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=4.000000,Max=5.000000)
        StartVelocityRange=(Z=(Min=150.000000,Max=200.000000))
        StartVelocityRadialRange=(Min=-150.000000,Max=-150.000000)
        VelocityLossRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=1.000000,Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        Name="SuperSpriteEmitter13"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter13'
	AutoDestroy=true
}
