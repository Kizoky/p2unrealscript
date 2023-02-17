/**
 * UrineExplosion
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Resulting "explosion" from a urine projectile hitting something
 *
 * @author Gordon Cheng
 */
class UrineExplosion extends P2Explosion;

var array<sound> SplashSounds;

function float GetRandPitch() {
	return (0.94 + FRand()*0.08);
}

auto state Exploding
{

Begin:
	PlaySound(SplashSounds[Rand(SplashSounds.length)],, 1.0,,, GetRandPitch(), true);
	Sleep(DelayToHurtTime);

    CheckHurtRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, ForceLocation);

	Sleep(DelayToNotifyTime);
	NotifyPawns();
}

defaultproperties
{
     SplashSounds(0)=sound'PissTrap-Movement.PissTrap-RangedSplash1'
     SplashSounds(1)=sound'PissTrap-Movement.PissTrap-RangedSplash2'
     SplashSounds(2)=sound'PissTrap-Movement.PissTrap-RangedSplash3'

     MyDamageType=class'UrineGlobDamage'

     ExplosionMag=5000
     ExplosionDamage=9
     ExplosionRadius=128

     Begin Object class=SpriteEmitter name=SpriteEmitter0
         UseDirectionAs=PTDU_Up
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0,Color=(R=255,G=255,B=128))
         ColorScale(1)=(RelativeTime=1,Color=(R=255,G=255,B=128))
         FadeOut=true
         MaxParticles=15
         RespawnDeadParticles=false
         SpinsPerSecondRange=(X=(Max=0.1))
         UseSizeScale=true
         UseRegularSizeScale=false
         SizeScale(0)=(RelativeSize=0.2)
         SizeScale(1)=(RelativeTime=1,RelativeSize=1)
         StartSizeRange=(X=(Min=10,Max=30),Y=(Min=70,Max=120))
         InitialParticlesPerSecond=300
         AutomaticInitialSpawning=false
         DrawStyle=PTDS_Brighten
         Texture=Texture'Zo_Smeg.Particles.zo_falls'
         SecondsBeforeInactive=0
         LifetimeRange=(Min=0.5,Max=1)
         StartVelocityRange=(X=(Min=-200,Max=200),Y=(Min=-200,Max=200),Z=(Min=50,Max=200))
         VelocityLossRange=(X=(Min=3,Max=3),Y=(Min=3,Max=3),Z=(Min=3,Max=3))
         Name="SpriteEmitter0"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter0'

     Begin Object class=SpriteEmitter name=SpriteEmitter1
         Acceleration=(Z=-500)
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0,Color=(R=255,G=255,B=128))
         ColorScale(1)=(RelativeTime=1,Color=(R=255,G=255,B=128))
         FadeOut=true
         MaxParticles=20
         RespawnDeadParticles=false
         StartLocationRange=(X=(Min=-15,Max=15),Y=(Min=-15,Max=15),Z=(Max=15))
         SpinParticles=true
         SpinsPerSecondRange=(X=(Max=1))
         StartSpinRange=(X=(Max=1))
         UseSizeScale=true
         UseRegularSizeScale=false
         SizeScale(0)=(RelativeSize=0.2)
         SizeScale(1)=(RelativeTime=1,RelativeSize=1)
         StartSizeRange=(X=(Min=10,Max=30))
         InitialParticlesPerSecond=300
         AutomaticInitialSpawning=false
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=true
         SecondsBeforeInactive=0
         LifetimeRange=(Min=0.5,Max=0.7)
         StartVelocityRange=(X=(Min=-100,Max=100),Y=(Min=-100,Max=100),Z=(Min=100,Max=300))
         Name="SpriteEmitter1"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter1'

     Begin Object class=SpriteEmitter name=SpriteEmitter2
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0,Color=(R=255,G=255,B=128))
         ColorScale(1)=(RelativeTime=1,Color=(R=255,G=255,B=128))
         FadeOut=true
         MaxParticles=8
         RespawnDeadParticles=false
         StartLocationRange=(X=(Min=-20,Max=20),Y=(Min=-20,Max=20),Z=(Max=20))
         SpinParticles=true
         SpinsPerSecondRange=(X=(Max=0.2))
         StartSpinRange=(X=(Max=1))
         SizeScale(0)=(RelativeSize=0.3)
         SizeScale(1)=(RelativeTime=1,RelativeSize=1)
         StartSizeRange=(X=(Min=50,Max=60))
         InitialParticlesPerSecond=300
         AutomaticInitialSpawning=false
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.wispsmoke'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=true
         SecondsBeforeInactive=0
         LifetimeRange=(Min=2,Max=3)
         StartVelocityRange=(X=(Min=-20,Max=20),Y=(Min=-20,Max=20),Z=(Max=20))
         Name="SpriteEmitter2"
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter2'

     AutoDestroy=true
     LifeSpan=5
     TransientSoundRadius=200
}