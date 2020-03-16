///////////////////////////////////////////////////////////////////////////////
// FoodCrumbs.
//
// Food crumbs made when some pawn eats something.
//
///////////////////////////////////////////////////////////////////////////////
class FoodCrumbs extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-600.000000)
        UseCollision=True
        DampingFactorRange=(Z=(Min=0.400000,Max=0.500000))
        UseMaxCollisions=True
        MaxCollisions=(Min=3.000000,Max=3.000000)
        MaxParticles=8
        RespawnDeadParticles=false
        UseColorScale=True
        ColorScale(0)=(Color=(B=164,G=185,R=208))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=164,G=185,R=208))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000))
        StartSpinRange=(X=(Max=1.000000))
        DampRotation=True
        RotationDampingFactorRange=(X=(Min=0.500000,Max=0.800000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=10.000000,Max=30.000000))
        InitialParticlesPerSecond=7.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'nathans.Skins.concrete1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Max=100.000000))
        Name="SpriteEmitter9"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter9'
	Lifespan=10
}
