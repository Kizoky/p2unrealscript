class MuzzleSmoke01 extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseColorScale=True
         ColorScale(0)=(Color=(G=12,R=66))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=180,G=180,R=180,A=128))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=136,G=136,R=136,A=128))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=120,G=120,R=120))
         MaxParticles=6
         RespawnDeadParticles=False
         StartLocationRange=(X=(Max=8.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         UseRotationFrom=PTRS_Actor
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=8.000000,Max=10.000000))
         UniformSize=True
         InitialParticlesPerSecond=50.000000
         AutomaticInitialSpawning=False
//       Textures(0)=(Texture=Texture'xPatchTex.FX.smoketest01',Weight=1.000000,DrawStyle=PTDS_AlphaBlend)
		 Texture=Texture'xPatchTex.FX.smoketest01' 
//		 Weight=1.000000
		 DrawStyle=PTDS_AlphaBlend
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.080000,Max=0.080000)
         StartVelocityRange=(X=(Min=10.000000,Max=40.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
//       bDoGravitation=True
         Name="SpriteEmitter4"
     End Object
     Emitters(0)=SpriteEmitter'FX2.SpriteEmitter4'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         UseColorScale=True
         ColorScale(0)=(Color=(G=5,R=21))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=176,G=180,R=196,A=128))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=157,G=157,R=157,A=64))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=115,G=115,R=115))
         MaxParticles=4
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=2.000000,Max=6.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         UseRotationFrom=PTRS_Actor
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=12.000000,Max=16.000000))
         UniformSize=True
         InitialParticlesPerSecond=200.000000
         AutomaticInitialSpawning=False
//       Textures(0)=(Texture=Texture'xPatchTex.FX.smoketest01',Weight=1.000000,DrawStyle=PTDS_AlphaBlend)
		 Texture=Texture'xPatchTex.FX.smoketest01' 
//		 Weight=1.000000
		 DrawStyle=PTDS_AlphaBlend
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.600000,Max=0.800000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(X=(Min=80.000000,Max=100.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
//       bDoGravitation=True
         Name="SpriteEmitter5"
     End Object
     Emitters(1)=SpriteEmitter'FX2.SpriteEmitter5'
     bDynamicLight=True
}
