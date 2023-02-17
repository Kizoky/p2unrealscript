//=============================================================================
// WormExplosion.
//=============================================================================
class WormExplosion extends PawnExplosion;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter47
         Acceleration=(Z=-600.000000)
         MaxParticles=20
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=25.000000,Max=145.000000))
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodchunks1'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=500.000000))
         Name="SpriteEmitter47"
     End Object
	 Emitters(0)=SpriteEmitter'SpriteEmitter47'
     Begin Object Class=MeshEmitter Name=MeshEmitter12
         StaticMesh=StaticMesh'Timb_mesh.fooo.nasty_deli2_timb'
         Acceleration=(Z=-800.000000)
         UseCollision=True
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         MaxParticles=50
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-30.000000,Max=30.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=0.700000,Max=5.000000),Y=(Min=0.400000,Max=4.000000),Z=(Min=0.700000,Max=4.000000))
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Min=-800.000000,Max=800.000000),Y=(Min=-800.000000,Max=800.000000),Z=(Max=1200.000000))
         Name="MeshEmitter12"
     End Object
	 Emitters(1)=SpriteEmitter'MeshEmitter12'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter48
         UseColorScale=True
         ColorScale(0)=(Color=(R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
         MaxParticles=8
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-30.000000,Max=30.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Max=450.000000))
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.smoke5'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Max=5.000000)
         Name="SpriteEmitter48"
     End Object
	 Emitters(2)=SpriteEmitter'SpriteEmitter48'
}
