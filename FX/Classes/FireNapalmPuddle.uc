//=============================================================================
// NapalmPuddle.
//=============================================================================
class FireNapalmPuddle extends FirePuddle;

defaultproperties
{
	 DamageDistMag=80
	 BurstClass = None

     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter8
		SecondsBeforeInactive=0.0
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=80
         RespawnDeadParticles=False
         StartLocationOffset=(Z=-15.000000)
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=40.000000,Max=80.000000))
         ParticlesPerSecond=50.000000
         InitialParticlesPerSecond=50.000000
         AutomaticInitialSpawning=False
         Texture=Texture'nathans.Skins.firenapalm'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.50000,Max=0.600000)
         StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=300.000000,Max=600.000000))
         Name="SuperSpriteEmitter8"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter8'
     LifeSpan=10.000000
	 DefCollRadius=50
	 DefCollHeight=0
	 bCollideActors=true
	 CollisionHeight=200
	 CollisionRadius=1
	 MyDamageType=class'NapalmDamage'
	 AutoDestroy=true
}
