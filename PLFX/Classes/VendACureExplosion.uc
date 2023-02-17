/**
 * VendACureExplosion
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * An explosion of Craptraps hopes and dreams and urine
 *
 * @author Gordon Cheng
 */
class VendACureExplosion extends P2Explosion;

defaultproperties
{
     MyDamageType=class'UrineGlobDamage'

     ExplodingSound=sound'WeaponSounds.Grenade_ExplodeAir'

     ExplosionMag=5000
     ExplosionDamage=0
     ExplosionRadius=0

     Begin Object class=SpriteEmitter name=SpriteEmitter0
         UseDirectionAs=PTDU_Up
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0,Color=(R=255,G=255,B=128))
         ColorScale(1)=(RelativeTime=1,Color=(R=255,G=255,B=128))
         FadeOut=true
         MaxParticles=30
         RespawnDeadParticles=false
         SpinsPerSecondRange=(X=(Max=0.1))
         UseSizeScale=true
         UseRegularSizeScale=false
         SizeScale(0)=(RelativeSize=0.2)
         SizeScale(1)=(RelativeTime=1,RelativeSize=1)
         StartSizeRange=(X=(Min=20,Max=60),Y=(Min=140,Max=240))
         InitialParticlesPerSecond=300
         AutomaticInitialSpawning=false
         DrawStyle=PTDS_Brighten
         Texture=Texture'Zo_Smeg.Particles.zo_falls'
         SecondsBeforeInactive=0
         LifetimeRange=(Min=0.5,Max=1)
         StartVelocityRange=(X=(Min=-400,Max=400),Y=(Min=-400,Max=400),Z=(Min=100,Max=400))
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
         MaxParticles=40
         RespawnDeadParticles=false
         StartLocationRange=(X=(Min=-15,Max=15),Y=(Min=-15,Max=15),Z=(Max=15))
         SpinParticles=true
         SpinsPerSecondRange=(X=(Max=1))
         StartSpinRange=(X=(Max=1))
         UseSizeScale=true
         UseRegularSizeScale=false
         SizeScale(0)=(RelativeSize=0.2)
         SizeScale(1)=(RelativeTime=1,RelativeSize=1)
         StartSizeRange=(X=(Min=20,Max=60))
         InitialParticlesPerSecond=300
         AutomaticInitialSpawning=false
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=true
         SecondsBeforeInactive=0
         LifetimeRange=(Min=0.5,Max=0.7)
         StartVelocityRange=(X=(Min=-200,Max=200),Y=(Min=-200,Max=200),Z=(Min=200,Max=600))
         Name="SpriteEmitter1"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter1'

     Begin Object class=SpriteEmitter name=SpriteEmitter2
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0,Color=(R=255,G=255,B=128))
         ColorScale(1)=(RelativeTime=1,Color=(R=255,G=255,B=128))
         FadeOut=true
         MaxParticles=16
         RespawnDeadParticles=false
         StartLocationRange=(X=(Min=-20,Max=20),Y=(Min=-20,Max=20),Z=(Max=20))
         SpinParticles=true
         SpinsPerSecondRange=(X=(Max=0.2))
         StartSpinRange=(X=(Max=1))
         SizeScale(0)=(RelativeSize=0.3)
         SizeScale(1)=(RelativeTime=1,RelativeSize=1)
         StartSizeRange=(X=(Min=100,Max=120))
         InitialParticlesPerSecond=300
         AutomaticInitialSpawning=false
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.wispsmoke'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=true
         SecondsBeforeInactive=0
         LifetimeRange=(Min=2,Max=3)
         StartVelocityRange=(X=(Min=-40,Max=40),Y=(Min=-40,Max=40),Z=(Max=40))
         Name="SpriteEmitter2"
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter2'

     Begin Object class=SpriteEmitter name=SpriteEmitter3
		SecondsBeforeInactive=0
        MaxParticles=7
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-30,Max=30),Y=(Min=-30,Max=30),Z=(Min=-30,Max=30))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=0.1))
        StartSpinRange=(X=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeTime=0,RelativeSize=0)
        SizeScale(1)=(RelativeTime=0.1,RelativeSize=0.7)
        SizeScale(2)=(RelativeTime=1,RelativeSize=1)
        StartSizeRange=(X=(Min=85,Max=110))
        InitialParticlesPerSecond=100
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        LifetimeRange=(Min=2.,Max=2.5)
        StartVelocityRange=(X=(Min=-150,Max=150),Y=(Min=-150,Max=150),Z=(Min=-50,Max=50))
        VelocityLossRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        Name="SpriteEmitter3"
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter3'

    Begin Object class=SpriteEmitter name=SpriteEmitter4
		SecondsBeforeInactive=0
        Acceleration=(Z=-600)
        MaxParticles=20
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-30,Max=30),Y=(Min=-30,Max=30),Z=(Min=-30,Max=30))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=2))
        StartSpinRange=(X=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=2.5,Max=7.5))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=true
        LifetimeRange=(Min=1,Max=1.5)
        StartVelocityRange=(X=(Min=-300,Max=300),Y=(Min=-300,Max=300),Z=(Max=250))
        Name="SpriteEmitter4"
    End Object
    Emitters(4)=SpriteEmitter'SpriteEmitter4'

    Begin Object class=SpriteEmitter name=SpriteEmitter5
		SecondsBeforeInactive=0
        Acceleration=(Z=-1)
        UseDirectionAs=PTDU_Up
        UseColorScale=true
        ColorScale(0)=(Color=(B=100,G=120,R=160))
        ColorScale(1)=(RelativeTime=0.2,Color=(B=100,G=100,R=128))
        ColorScale(2)=(RelativeTime=1,Color=(B=100,G=100,R=128))
        FadeOut=true
        MaxParticles=12
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-20,Max=20),Y=(Min=-20,Max=20),Z=(Min=-50,Max=-20))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeTime=0,RelativeSize=0)
        SizeScale(1)=(RelativeTime=0.3,RelativeSize=0.7)
        SizeScale(2)=(RelativeTime=1,RelativeSize=1)
        StartSizeRange=(X=(Max=100),Y=(Min=100,Max=200))
        InitialParticlesPerSecond=3000
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'nathans.Skins.pour2'
        LifetimeRange=(Min=2.2,Max=2.7)
        StartVelocityRange=(X=(Min=-200,Max=200),Y=(Min=-200,Max=200),Z=(Min=110,Max=160))
        VelocityLossRange=(X=(Min=1.5,Max=1.5),Y=(Min=1.5,Max=1.5),Z=(Min=1.5,Max=1.5))
        Name="SpriteEmitter5"
    End Object
    Emitters(5)=SpriteEmitter'SpriteEmitter5'

     AutoDestroy=true
     LifeSpan=5
     TransientSoundRadius=200
}