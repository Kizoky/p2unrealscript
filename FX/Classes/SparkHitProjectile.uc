//=============================================================================
// SparkHitProjectile.
//
// Most smaller projectiles should use this for hits
//=============================================================================
class SparkHitProjectile extends SparkHit;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter12
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        DampingFactorRange=(Z=(Min=0.500000))
        UseColorScale=True
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
		MaxParticles=3
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=10.000000,Max=25.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.softwhitedot'
        LifetimeRange=(Min=0.700000,Max=1.000000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-300.000000,Max=300.000000))
        VelocityLossRange=(X=(Min=4.000000,Max=4.000000),Y=(Min=4.000000,Max=4.000000),Z=(Min=4.000000,Max=4.000000))
        Name="SpriteEmitter12"
    End Object
    Emitters(0)=SpriteEmitter'Fx.SpriteEmitter12'

	velmax=350
    AutoDestroy=true
}
