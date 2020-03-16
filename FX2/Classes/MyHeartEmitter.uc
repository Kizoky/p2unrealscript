//MrD - LOVEly emitter.
class MyHeartEmitter extends P2Emitter;

//#exec Texture Import File=Textures\Heart.dds Name=Heart Mips=Off MASKED=1

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=HeartsFX
         Acceleration=(X=1.000000,Y=1.000000,Z=200.000000)
         FadeOut=True
         FadeIn=True
         StartLocationRange=(X=(Min=-70.000000,Max=70.000000),Y=(Min=-70.000000,Max=70.000000),Z=(Min=-5.000000,Max=15.000000))
         SphereRadiusRange=(Min=12.000000,Max=555.000000)
         UseRotationFrom=PTRS_Normal
         SpinParticles=True
         SpinCCWorCW=(X=5.000000,Y=5.000000,Z=5.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=1.000000,Max=1.000000),Z=(Min=-5.000000,Max=1.000000))
         StartSpinRange=(X=(Min=1.000000,Max=3.000000),Y=(Min=1.000000,Max=3.000000),Z=(Min=1.000000,Max=3.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.180000)
         SizeScale(1)=(RelativeTime=0.000000,RelativeSize=0.080000)
         StartSizeRange=(X=(Min=5.000000,Max=6.000000),Y=(Min=5.000000,Max=6.000000),Z=(Min=6.000000,Max=6.500000))
         UniformSize=True
         ParticlesPerSecond=5.000000
         InitialParticlesPerSecond=5.000000
         AutomaticInitialSpawning=False
         Texture=Texture'P2R_Tex_D.Env.heart'
         LifetimeRange=(Min=6.000000,Max=0.900000)
         StartVelocityRange=(X=(Min=-110.000000,Max=122.000000),Y=(Min=-110.000000,Max=150.000000),Z=(Min=40.000000,Max=2.000000))
         StartVelocityRadialRange=(Min=-5.000000,Max=5.000000)
         VelocityLossRange=(X=(Min=-1.000000))
         AddVelocityMultiplierRange=(Z=(Min=-9.000000,Max=-1.000000))
		RespawnDeadParticles=false
         Name="HeartsFX"
     End Object
     Emitters(0)=SpriteEmitter'FX2.HeartsFX'
}
