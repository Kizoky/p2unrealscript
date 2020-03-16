/**
 * EasterBunnyGroundExplosion
 *
 * Harmless explosion to use as a visual effect
 */
class EasterBunnyGroundExplosion extends RocketExplosion;

defaultproperties
{
    ExplosionDamage=0
    ExplosionRadius=0

    ExplodingSound=sound'WeaponSounds.explosion_long'

    Begin Object class=SpriteEmitter name=SpriteEmitter0
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
        StartSizeRange=(X=(Min=7,Max=15))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=true
        LifetimeRange=(Min=1,Max=1.500000)
        StartVelocityRange=(X=(Min=-600,Max=600),Y=(Min=-600,Max=600),Z=(Max=500))
        Name="SpriteEmitter0"
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter0'
}