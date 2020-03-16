///////////////////////////////////////////////////////////////////////////
// BloodChunksDripping
// usually comes out of CatRocket.
///////////////////////////////////////////////////////////////////////////
class BloodChunksDripping extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter11
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-300.000000)
        MaxParticles=8
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=2.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=9.000000,Max=15.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodchunks1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        UseRandomSubdivision=True
        LifetimeRange=(Min=0.600000,Max=0.900000)
        StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        Name="SpriteEmitter11"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter11'
	AutoDestroy=true
}