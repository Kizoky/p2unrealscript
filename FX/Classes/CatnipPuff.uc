///////////////////////////////////////////////////////////////////////////////
// CatnipPuff
// 
// green smoke coming out of an open tin of catnip
//
///////////////////////////////////////////////////////////////////////////////
class CatnipPuff extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter49
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-10.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        FadeInEndTime=1.000000
        FadeIn=True
        MaxParticles=4
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=-10.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=20.000000,Max=25.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=20.000000,Max=25.000000))
        Name="SpriteEmitter49"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter49'
	AutoDestroy=true

	// Change by NickP: MP fix
	RemoteRole=ROLE_SimulatedProxy
	// End
}
