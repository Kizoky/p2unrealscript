///////////////////////////////////////////////////////////////////////////////
// ChemBall
// 
// Connects to chempillar
//
///////////////////////////////////////////////////////////////////////////////
class ChemBall extends FireBall;

	//	DrawStyle=PTDS_Brighten
    //    Texture=Texture'nathans.Skins.wispsmoke'
  //      TextureUSubdivisions=2
//        TextureVSubdivisions=4


defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter13
		SecondsBeforeInactive=0.0
        LocationShapeExtend=PTLSE_Circle
        UseColorScale=true
        ColorScale(0)=(RelativeTime=0.000000,Color=(B=50,G=200,R=150))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
        Acceleration=(Z=60.000000)
        FadeOut=True
        MaxParticles=5
        RespawnDeadParticles=False
        StartLocationRange=(Z=(Min=0.000000,Max=50.000000))
        SphereRadiusRange=(Max=20.000000)
        SpinParticles=True
        StartSpinRange=(X=(Max=1.000000))
        SpinsPerSecondRange=(X=(Max=0.0500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=0.40000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=160.000000,Max=210.000000))
        InitialParticlesPerSecond=30.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=3.00000,Max=5.000000)
        StartVelocityRange=(Z=(Min=0.000000,Max=20.000000))
        StartVelocityRadialRange=(Min=-90.000000,Max=-140.000000)
        VelocityLossRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=1.000000,Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        Name="SuperSpriteEmitter13"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter13'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter14
		SecondsBeforeInactive=0.0
        LocationShapeExtend=PTLSE_Circle
        UseColorScale=true
        ColorScale(0)=(RelativeTime=0.000000,Color=(B=50,G=200,R=150))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
        Acceleration=(Z=60.000000)
        FadeOut=True
        MaxParticles=10
        RespawnDeadParticles=False
        SphereRadiusRange=(Max=40.000000)
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        SizeScaleRepeats=3.000000
        StartSizeRange=(X=(Min=3.000000,Max=5.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.bubbles'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=6.000000,Max=8.000000)
        StartVelocityRange=(Z=(Min=0.000000,Max=20.000000))
        StartVelocityRadialRange=(Min=-50.000000,Max=-150.000000)
        VelocityLossRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=1.000000,Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        Name="SuperSpriteEmitter14"
    End Object
    Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter14'
	AutoDestroy=true
}
