///////////////////////////////////////////////////////////////////////////////
// GrenadeHeadExplosion
// 
// explosion for a grenade when it's in the dude's mouth before a suicide
///////////////////////////////////////////////////////////////////////////////
class GrenadeHeadExplosion extends P2Explosion;

defaultproperties
{
	ExplosionMag=60000
	ExplosionRadius=800
	ExplosionDamage=1000
	TransientSoundRadius=900
	
	MyDamageType=class'DudeSuicideDamage'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter30
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(R=187))
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=192,G=192,R=192))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=192,G=192,R=192))
        MaxParticles=8
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000),Z=(Max=8.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.000000)
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=50.000000,Max=80.000000))
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.500000,Max=2.000000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-20.000000,Max=50.000000))
        VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        Name="SpriteEmitter30"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter30'
	LifeSpan=3.0
    AutoDestroy=true
}