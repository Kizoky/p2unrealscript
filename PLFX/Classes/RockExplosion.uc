class RockExplosion extends P2Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter9
         StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock02'
         Acceleration=(Z=-1000.000000)
         UseCollision=True
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         MaxParticles=40
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         UseSizeScale=True
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.300000)
         StartSizeRange=(X=(Min=0.300000,Max=1.500000),Y=(Min=0.300000,Max=1.500000),Z=(Min=0.800000,Max=1.500000))
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.500000)
         StartVelocityRange=(X=(Min=300.000000,Max=-300.000000),Y=(Min=300.000000,Max=-300.000000),Z=(Max=300.000000))
         Name="MeshEmitter9"
     End Object
	 Emitters(0)=MeshEmitter'PLFX.MeshEmitter9'
     Begin Object Class=MeshEmitter Name=MeshEmitter13
         StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock03'
         Acceleration=(Z=-975.000000)
         UseCollision=True
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000)
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.500000)
         StartVelocityRange=(X=(Min=300.000000,Max=-300.000000),Y=(Min=300.000000,Max=-300.000000),Z=(Max=300.000000))
         Name="MeshEmitter13"
     End Object
	 Emitters(1)=MeshEmitter'PLFX.MeshEmitter13'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter106
         UseColorScale=True
         ColorScale(0)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.900000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
         MaxParticles=15
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSizeRange=(X=(Min=120.000000,Max=250.000000),Y=(Min=250.000000,Max=250.000000),Z=(Min=250.000000,Max=250.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.smoke5'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.500000,Max=0.800000)
         Name="SpriteEmitter106"
     End Object
	 Emitters(2)=SpriteEmitter'PLFX.SpriteEmitter106'
	 AutoDestroy=True
}
