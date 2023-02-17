class PisstrapExplosion extends P2Explosion;

defaultproperties
{
     MyDamageType=class'UrineGlobDamage'

     ExplodingSound=sound'WeaponSounds.Grenade_ExplodeAir'

     ExplosionMag=5000
     ExplosionDamage=0
     ExplosionRadius=0
     AutoDestroy=true
     LifeSpan=5
     TransientSoundRadius=200
	 
    Begin Object Class=SpriteEmitter Name=SpriteEmitter92
        Acceleration=(Z=-1500.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=255,R=255))
        FadeOut=True
        MaxParticles=30
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Max=15.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Min=10.000000,Max=15.000000))
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.waterblobs'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.300000,Max=0.500000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=200.000000,Max=800.000000))
        RelativeWarmupTime=0.750000
        Name="SpriteEmitter92"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter92'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter93
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=255,R=255))
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
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Max=20.000000))
        RelativeWarmupTime=1.000000
        Name="SpriteEmitter93"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter93'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter101
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.075000),Y=(Max=0.075000))
        UseSizeScale=True
        UseRegularSizeScale=False
        StartSizeRange=(X=(Min=50.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.500000,Max=2.000000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-100.000000,Max=150.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
        Name="SpriteEmitter101"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter101'
    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'PL_tylermesh2.Mesh_Emitters.ME_bolt1'
        Acceleration=(Z=-980.000000)
        UseCollision=True
        DampingFactorRange=(Z=(Min=0.700000,Max=0.900000))
        UseMaxCollisions=True
        MaxCollisions=(Max=10.000000)
        FadeOutStartTime=1.000000
        FadeOut=True
        MaxParticles=1
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-40.000000,Max=40.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=10.000000,Max=350.000000))
        Name="MeshEmitter2"
    End Object
    Emitters(3)=MeshEmitter'MeshEmitter2'
    Begin Object Class=MeshEmitter Name=MeshEmitter9
        StaticMesh=StaticMesh'PL_tylermesh2.Mesh_Emitters.ME_circbrd1'
        Acceleration=(Z=-980.000000)
        UseCollision=True
        DampingFactorRange=(Z=(Min=0.500000,Max=0.500000))
        UseMaxCollisions=True
        MaxCollisions=(Max=10.000000)
        FadeOutStartTime=1.000000
        FadeOut=True
        MaxParticles=3
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-40.000000,Max=40.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Max=2.000000),Y=(Max=2.000000),Z=(Max=2.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=10.000000,Max=350.000000))
        Name="MeshEmitter9"
    End Object
    Emitters(4)=MeshEmitter'MeshEmitter9'
    Begin Object Class=MeshEmitter Name=MeshEmitter12
        StaticMesh=StaticMesh'PL_tylermesh2.Mesh_Emitters.ME_circbrd2'
        Acceleration=(Z=-980.000000)
        UseCollision=True
        DampingFactorRange=(Z=(Min=0.500000,Max=0.500000))
        UseMaxCollisions=True
        MaxCollisions=(Max=10.000000)
        FadeOutStartTime=1.000000
        FadeOut=True
        MaxParticles=1
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-40.000000,Max=40.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Max=2.000000),Y=(Max=2.000000),Z=(Max=2.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=10.000000,Max=350.000000))
        Name="MeshEmitter12"
    End Object
    Emitters(5)=MeshEmitter'MeshEmitter12'
    Begin Object Class=MeshEmitter Name=MeshEmitter13
        StaticMesh=StaticMesh'PL_tylermesh2.Mesh_Emitters.ME_Shrap1'
        Acceleration=(Z=-980.000000)
        UseCollision=True
        DampingFactorRange=(Z=(Min=0.700000,Max=0.900000))
        UseMaxCollisions=True
        MaxCollisions=(Max=10.000000)
        FadeOutStartTime=1.000000
        FadeOut=True
        MaxParticles=7
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-50.000000,Max=50.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=0.300000,Max=3.000000),Y=(Min=0.300000,Max=3.000000),Z=(Min=0.300000,Max=3.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=3.000000,Max=5.000000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=10.000000,Max=350.000000))
        Name="MeshEmitter13"
    End Object
    Emitters(6)=MeshEmitter'MeshEmitter13'
    Begin Object Class=MeshEmitter Name=MeshEmitter14
        StaticMesh=StaticMesh'PL_tylermesh2.Mesh_Emitters.ME_spring1'
        Acceleration=(Z=-980.000000)
        UseCollision=True
        DampingFactorRange=(Z=(Min=0.700000,Max=0.900000))
        UseMaxCollisions=True
        MaxCollisions=(Max=10.000000)
        FadeOutStartTime=1.000000
        FadeOut=True
        MaxParticles=1
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-40.000000,Max=40.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Max=5.000000),Y=(Max=5.000000),Z=(Max=5.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=10.000000,Max=350.000000))
        Name="MeshEmitter14"
    End Object
    Emitters(7)=MeshEmitter'MeshEmitter14'
    Begin Object Class=MeshEmitter Name=MeshEmitter15
        StaticMesh=StaticMesh'PL_tylermesh2.Mesh_Emitters.ME_spring2'
        Acceleration=(Z=-980.000000)
        UseCollision=True
        DampingFactorRange=(Z=(Min=0.700000,Max=0.900000))
        UseMaxCollisions=True
        MaxCollisions=(Max=10.000000)
        FadeOutStartTime=1.000000
        FadeOut=True
        MaxParticles=1
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-40.000000,Max=40.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=3.000000,Max=5.000000),Z=(Min=3.000000,Max=5.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=100.000000,Max=500.000000))
        Name="MeshEmitter15"
    End Object
    Emitters(8)=MeshEmitter'MeshEmitter15'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter100
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-333.000000)
        DampingFactorRange=(Z=(Min=0.500000))
        UseColorScale=True
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        MaxParticles=15
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=10.000000,Max=25.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.softwhitedot'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.700000,Max=1.000000)
        StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-50.000000,Max=500.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=4.000000),Y=(Min=2.000000,Max=4.000000),Z=(Min=2.000000,Max=4.000000))
        Name="SpriteEmitter100"
    End Object
    Emitters(9)=SpriteEmitter'SpriteEmitter100'	
}
