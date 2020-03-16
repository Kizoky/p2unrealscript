///////////////////////////////////////////////////////////////////////////////
// MilkExplosion
// 
// Explosion for a milk projectile from cowboss
///////////////////////////////////////////////////////////////////////////////
class MilkExplosion extends P2Explosion;

///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
function float GetRandPitch()
{
	return (0.94 + FRand()*0.08);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
Begin:
	PlaySound(ExplodingSound,,1.0,,,GetRandPitch(),true);
	Sleep(DelayToHurtTime);

	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
		CheckHurtRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, ForceLocation);
	else
		CheckHurtRadius(ExplosionDamageMP, ExplosionRadiusMP, MyDamageType, ExplosionMagMP, ForceLocation);

	Sleep(DelayToNotifyTime);
	NotifyPawns();
}

defaultproperties
{
     ExplodingSound=Sound'levelsoundstrois.weather.Splash2'
     ExplosionMag=5000.000000
     ExplosionDamage=40.000000
     ExplosionRadius=180.000000
     MyDamageType=Class'AcidMilkDamage'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter63
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=164,G=255,R=164))
         FadeOut=True
         MaxParticles=15
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
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=50.000000,Max=200.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         Name="SpriteEmitter63"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter63'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter64
         Acceleration=(Z=-500.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=187,G=255,R=189))
         FadeOut=True
         MaxParticles=20
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
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=100.000000,Max=300.000000))
         Name="SpriteEmitter64"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter64'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter65
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
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Max=20.000000))
         Name="SpriteEmitter65"
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter65'
     AutoDestroy=True
     LifeSpan=5.000000
     TransientSoundRadius=200.000000
}
