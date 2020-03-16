//=============================================================================
// Feeder to be dripping off of roofs and ledges where a stream led up to.
//=============================================================================
class BloodDripFeeder extends FluidDripFeeder;

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter5
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-550.000000)
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(A=255,R=140,G=130,B=130))
        ColorScale(1)=(RelativeTime=0.400000,Color=(A=255,R=120,G=120,B=190))
        ColorScaleRepeats=2.000000
        FadeOutStartTime=0.700000
        FadeOut=True
        MaxParticles=10
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.300000)
        SizeScaleRepeats=2.000000
        StartSizeRange=(X=(Min=0.300000,Max=0.600000),Y=(Min=20.000000,Max=30.000000))
        InitialParticlesPerSecond=0.000000
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.bloodpour'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.800000,Max=2.200000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
        Name="SuperSpriteEmitter5"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter5'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-200.000000)
        UseDirectionAs=PTDU_Up
        FadeInEndTime=0.100000
        FadeIn=True
        FadeOutStartTime=0.150000
        FadeOut=True
        MaxParticles=4
        StartLocationRange=(X=(Min=-7.000000,Max=7.000000),Y=(Min=-7.000000,Max=7.000000),Z=(Max=10.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.000000)
        StartSizeRange=(X=(Min=8.000000,Max=12.000000),Y=(Min=22.000000,Max=32.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.bloodsplat'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.800000,Max=1.200000)
        StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=20.000000,Max=40.000000))
        Name="SuperSpriteEmitter6"
    End Object
    Emitters(1)=SuperSpriteEmitter'Fx.SuperSpriteEmitter6'
    MyType=FLUID_TYPE_Blood
	SpawnDripTime=0.4
	QuantityPerHit=8
	Quantity=20
	SplashClass = Class'BloodSplashEmitter'
	TrailClass = Class'BloodTrail'
	TrailStarterClass = Class'BloodTrailStarter'
	PuddleClass = Class'BloodPuddle'
	bCollideActors=true;
	AutoDestroy=true
}
