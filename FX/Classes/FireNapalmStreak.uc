///////////////////////////////////////////////////////////////////////////////
// FireNapalmStreak. 
//
// Line of extra hot fire
///////////////////////////////////////////////////////////////////////////////
class FireNapalmStreak extends FireStreak;

defaultproperties
{
	 Damage=80
	 DamageDistMag=120
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter4
		SecondsBeforeInactive=0.0
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=25
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-5.000000))
         StartLocationOffset=(Z=-5.000000)
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=45.000000,Max=85.000000))
         ParticlesPerSecond=25.000000
         InitialParticlesPerSecond=25.000000
         AutomaticInitialSpawning=False
         Texture=Texture'nathans.Skins.firenapalm'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.40000,Max=0.600000)
         StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=200.000000,Max=300.000000))
         Name="SuperSpriteEmitter4"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter4'
     LifeSpan=5.00000
	 DistToParticleRatio=7.0
	 DefCollRadius=150
	 DefCollHeight=150
	 bCollideActors=true
	 MyDamageType=class'NapalmDamage'
	 AutoDestroy=true
}
