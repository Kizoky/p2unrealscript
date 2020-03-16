///////////////////////////////////////////////////////////////////////////////
// MolotovWickFire
// 
// Fire for the cloth wick on a molotov cocktail
//
///////////////////////////////////////////////////////////////////////////////
class MolotovWickFire extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-100.000000)
        UseColorScale=False
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=98))
        CoordinateSystem=PTCS_Relative
        FadeOut=True
        MaxParticles=10
        StartLocationOffset=(X=5.0,Z=15.0)
        StartLocationRange=(X=(Min=-3.0,Max=3.0),Y=(Min=-1.0,Max=1.0))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.100000,Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=8.000000,Max=13.000000))
        UniformSize=True
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.firegroup'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.500000,Max=0.600000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=100.000000))
        Name="SpriteEmitter5"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter5'
	LifeSpan=20
    bTrailerSameRotation=True
    Physics=PHYS_Trailer
    AutoDestroy=true
	bReplicateMovement=true
}
