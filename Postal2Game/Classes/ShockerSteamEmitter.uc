///////////////////////////////////////////////////////////////////////////////
// ShockerSteamEmitter. 
//
// Steam rising from thing you've just Shocked, like a cat or person.
///////////////////////////////////////////////////////////////////////////////
class ShockerSteamEmitter extends TimedEmitter;

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter11
		SecondsBeforeInactive=0.0
        FadeOut=True
        MaxParticles=15
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=0.750000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=30.000000,Max=50.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.500000,Max=2.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=20.000000,Max=40.000000))
        Name="SuperSpriteEmitter11"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter11'

	PlayTime=2.0
	FinishUpTime=2.0
}
