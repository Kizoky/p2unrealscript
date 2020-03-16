//=============================================================================
// Temp, crap emitter.
//=============================================================================
class PopEmitter extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter11
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        Acceleration=(Z=-1000.000000)
        UseCollision=True
        DampingFactorRange=(X=(Min=0.300000,Max=0.800000),Y=(Min=0.300000,Max=0.800000),Z=(Min=0.300000,Max=0.800000))
        MaxParticles=25
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=25.000000,Max=35.000000),Y=(Min=25.000000,Max=35.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.glassshards'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=2.000000)
        StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=50.000000,Max=150.000000))
        Name="SpriteEmitter11"
    End Object
    Emitters(0)=SpriteEmitter'Fx.SpriteEmitter11'
    AutoDestroy=true
}
