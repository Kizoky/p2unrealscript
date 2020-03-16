// MrD- PinkSmoke Emitter
class MyPinkEmitter extends P2Emitter;

defaultproperties
{
	 Begin Object Class=SpriteEmitter Name=PinkFX
        Acceleration=(Z=300.000000)
        UseCollision=True
        UseColorScale=True
        ColorScale(0)=(Color=(B=102,G=102,R=102,A=102))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=106,R=157))
        FadeOut=True
        FadeIn=True
        MaxParticles=8
        StartLocationOffset=(Z=-30.000000)
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000))
        StartMassRange=(Max=6.000000)
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.070000)
        SizeScale(1)=(RelativeTime=0.000000,RelativeSize=0.600000)
        StartSizeRange=(X=(Max=70.000000),Y=(Max=70.000000),Z=(Max=70.000000))
        ParticlesPerSecond=1.000000
        InitialParticlesPerSecond=3.000000
        Texture=Texture'GenFX.LensFlar.DotPink'
        LifetimeRange=(Min=2.000000)
        StartVelocityRange=(X=(Min=-250.000000,Max=250.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Min=90.000000,Max=200.000000))
		RespawnDeadParticles=false
        Name="PinkFX"
    End Object
    Emitters(0)=SpriteEmitter'FX2.PinkFX'
}
