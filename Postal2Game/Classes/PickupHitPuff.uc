//=============================================================================
// PickupHitPuff.
//=============================================================================
class PickupHitPuff extends P2Emitter;

defaultproperties
{
 	 Begin Object Class=SpriteEmitter Name=SpriteEmitter10
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(B=58,G=84,R=126))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=61,G=100,R=182))
		MaxParticles=3
        RespawnDeadParticles=False
		SpinParticles=True
		SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
		UseSizeScale=True
		UseRegularSizeScale=False
		SizeScale(0)=(RelativeSize=0.300000)
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
		StartSizeRange=(X=(Min=25.000000,Max=40.000000))
        InitialParticlesPerSecond=5.000000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
		BlendBetweenSubdivisions=True
		LifetimeRange=(Min=1.000000,Max=1.500000)
		StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Max=5.000000),)
		Name="SpriteEmitter10"
	 End Object
	 Emitters(0)=SpriteEmitter'SpriteEmitter10'
    AutoDestroy=true
}
