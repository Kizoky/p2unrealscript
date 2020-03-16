///////////////////////////////////////////////////////////////////////////////
// MilkExplosionAir
// 
// Explosion for a milk projectile from cowboss, in the air
///////////////////////////////////////////////////////////////////////////////
class MilkExplosionAir extends MilkExplosion;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter39
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=164,G=255,R=164))
         FadeOut=True
         MaxParticles=30
         RespawnDeadParticles=False
         SpinsPerSecondRange=(X=(Max=0.100000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=30.000000),Y=(Min=70.000000,Max=120.000000))
         InitialParticlesPerSecond=150.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'Zo_Smeg.Particles.zo_falls'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=1.000000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         Name="SpriteEmitter39"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter39'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter106
         Acceleration=(Z=-500.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=187,G=255,R=189))
         FadeOut=True
         MaxParticles=25
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Max=15.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=150.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.700000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=300.000000))
         Name="SpriteEmitter106"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter106'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter107
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=185,G=255,R=185))
         FadeOut=True
         MaxParticles=8
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Max=20.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=60.000000))
         InitialParticlesPerSecond=150.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.wispsmoke'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         Name="SpriteEmitter107"
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter107'
}
