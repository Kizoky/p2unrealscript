class BloodImpactHeadShot extends P2Emitter;


defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter52
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        MaxParticles=3
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Max=30.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=15.000000,Max=25.000000),Y=(Min=60.0000,Max=80.000000))
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodanim2'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.700000,Max=1.00000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=40.000000,Max=100.000000))
        Name="SpriteEmitter52"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter52'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter17
		SecondsBeforeInactive=0.0
        FadeOut=True
        MaxParticles=3
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=11.000000,Max=19.000000))
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodimpacts'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.400000,Max=0.600000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
        Name="SpriteEmitter17"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter17'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter6
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Forward
        Acceleration=(Z=-600.000000)
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.000000,Max=0.300000))
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        MaxParticles=4
		DampRotation=True
        RotationDampingFactorRange=(X=(Min=0.100000,Max=0.300000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=1.500000,Max=2.500000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=4.000000,Max=7.000000))
        UniformSize=True
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.skullchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-120.000000,Max=120.000000),Y=(Min=-120.000000,Max=120.000000),Z=(Max=500.000000))
        Name="SpriteEmitter6"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter6'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-250.000000)
        MaxParticles=4
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=10.000000,Max=18.000000))
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodchunks1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.500000,Max=2.500000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Max=500.000000))
        Name="SpriteEmitter12"
     End Object
     Emitters(3)=SpriteEmitter'SpriteEmitter12'
     AutoDestroy=true
	bNetOptional=false
	RemoteRole=ROLE_None
}
