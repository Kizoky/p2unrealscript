///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class PropExplosion extends P2Emitter;

var Sound ExplosionSound;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	PlaySound(ExplosionSound, , , , , GetRandPitch());
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ExplosionSound=Sound'PL-Ambience.RainyFoliage.atm-PUGames'
	
    Begin Object Class=SpriteEmitter Name=SpriteEmitter22
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-400.000000)
        UseCollision=True
        DampingFactorRange=(X=(Min=0.600000),Y=(Min=0.600000),Z=(Min=0.400000,Max=0.800000))
        UseColorScale=True
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
        MaxParticles=20
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        StartSpinRange=(X=(Max=1.000000))
        DampRotation=True
        RotationDampingFactorRange=(X=(Min=0.500000,Max=0.800000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=8.000000,Max=10.000000))
        InitialParticlesPerSecond=30.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.blast1'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        LifetimeRange=(Min=1.000000,Max=1.500000)
        StartVelocityRange=(X=(Min=-30.000000,Max=-100.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=20.000000,Max=80.000000))
        Name="SpriteEmitter22"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter22'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter8
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-400.000000)
        UseCollision=True
        DampingFactorRange=(X=(Min=0.600000),Y=(Min=0.600000),Z=(Min=0.400000,Max=0.800000))
        UseColorScale=True
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
        MaxParticles=20
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        StartSpinRange=(X=(Max=1.000000))
        DampRotation=True
        RotationDampingFactorRange=(X=(Min=0.500000,Max=0.800000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=8.000000,Max=10.000000))
        InitialParticlesPerSecond=30.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.blast1'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        LifetimeRange=(Min=1.000000,Max=1.500000)
        StartVelocityRange=(X=(Min=-30.000000,Max=-100.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=20.000000,Max=80.000000))
        Name="SpriteEmitter8"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter8'
}
