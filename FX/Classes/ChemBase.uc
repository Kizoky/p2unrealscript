///////////////////////////////////////////////////////////////////////////////
// ChemBase
// 
// explosion part of plague rocket
///////////////////////////////////////////////////////////////////////////////
class ChemBase extends P2Emitter;


defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter21
		SecondsBeforeInactive=0.0
        MaxParticles=5
        UseColorScale=true
        ColorScale(1)=(RelativeTime=0.000000,Color=(B=50,G=200,R=150))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.000000)
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=170.000000,Max=220.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.00000,Max=2.500000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-100.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
        Name="SpriteEmitter21"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter21'
	LifeSpan=5.0
    AutoDestroy=true
}