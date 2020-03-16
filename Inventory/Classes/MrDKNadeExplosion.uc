//=============================================================================
// MrDTNadeExplosion.
//=============================================================================
class MrDKNadeExplosion extends GrenadeExplosion;

#exec AUDIO IMPORT NAME=boom FILE=Sounds/boom.wav

defaultproperties
{
     GrenadeExplodeAir=Sound'boom'
     GrenadeExplodeGround=Sound'boom'
     ExplosionMag=200000.000000
     ExplosionDamage=320.000000
     ExplosionRadius=1250.000000
     MyDamageType=Class'MrDKNadeDamage'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter239
         UseColorScale=True
         ColorScale(1)=(Color=(B=50,G=200,R=150))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
         MaxParticles=7
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=170.000000,Max=220.000000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.expl1color'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.500000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         Name="SpriteEmitter239"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter239'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter103
         Acceleration=(Z=-600.000000)
         MaxParticles=20
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=15.000000))
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.darkchunks'
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Max=500.000000))
         Name="SpriteEmitter103"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter103'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter104
         UseDirectionAs=PTDU_Up
         Acceleration=(Z=-1.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=100,G=120,R=160))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=100,G=100,R=128))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=100,G=100,R=128))
         FadeOut=True
         MaxParticles=12
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-50.000000,Max=-20.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Max=200.000000),Y=(Min=200.000000,Max=400.000000))
         InitialParticlesPerSecond=3000.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
         Texture=Texture'nathans.Skins.pour2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.200000,Max=2.700000)
         StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=220.000000,Max=320.000000))
         VelocityLossRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000),Z=(Min=1.500000,Max=1.500000))
         Name="SpriteEmitter104"
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter104'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter200
         Acceleration=(Z=-600.000000)
         MaxParticles=20
         RespawnDeadParticles=False
         Disabled=True
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=35.000000))
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodchunks1'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=500.000000))
         Name="SpriteEmitter200"
     End Object
     Emitters(3)=SpriteEmitter'SpriteEmitter200'
}
