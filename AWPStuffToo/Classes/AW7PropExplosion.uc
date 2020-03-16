// PropExplosion
// Default prop explosion. Copied from RocketExplosion.
class AW7PropExplosion extends AW7PropExplosionBase;

defaultproperties
{
     MyExplosionMag=100000.000000
     MyExplosionDamage=180.000000
     MyExplosionRadius=750.000000
     Begin Object Class=SpriteEmitter Name=SpriteEmitter152
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=-80.000000,Max=80.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=150.000000,Max=200.000000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.expl1color'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=3.500000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         Name="SpriteEmitter152"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter152'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter153
         UseDirectionAs=PTDU_Up
         FadeOutStartTime=0.500000
         FadeOut=True
         FadeInEndTime=0.500000
         FadeIn=True
         MaxParticles=20
         RespawnDeadParticles=False
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=100.000000,Max=300.000000)
         StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=200.000000
         AutomaticInitialSpawning=False
         Texture=Texture'nathans.Skins.softwhitedot'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRadialRange=(Min=900.000000,Max=1000.000000)
         VelocityLossRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000),Z=(Min=1.500000,Max=1.500000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         Name="SpriteEmitter153"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter153'
     LifeSpan=3.000000
}
