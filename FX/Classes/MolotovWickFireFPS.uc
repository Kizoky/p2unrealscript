///////////////////////////////////////////////////////////////////////////////
// MolotovWickFire
// 
// Fire for the cloth wick on a molotov cocktail in fps view
//
///////////////////////////////////////////////////////////////////////////////
class MolotovWickFireFPS extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter37
		SecondsBeforeInactive=0.0
        Acceleration=(Y=-20.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=21,G=203,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=41,R=98))
        FadeOut=True
        MaxParticles=10
        CoordinateSystem=PTCS_Relative
        StartLocationRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.40000))
        UseSizeScale=True
        UseRegularSizeScale=False	
// Changed by Man Chrzan: xPatch 2.0
//       SizeScale(0)=(RelativeSize=0.300000)
//       SizeScale(1)=(RelativeTime=0.250000,RelativeSize=1.000000)
//       SizeScale(2)=(RelativeTime=1.000000)
//       StartSizeRange=(X=(Min=1.00000,Max=1.750000))
        SizeScale(0)=(RelativeSize=1.800000) 
        SizeScale(1)=(RelativeTime=0.250000,RelativeSize=6.000000) 
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=1.000000,Max=1.75000))
// End		
        UniformSize=True
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.fireball1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.600000,Max=0.900000)
        StartVelocityRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-15.000000,Max=-20.000000),Z=(Min=-3.000000,Max=3.000000))
        Name="SpriteEmitter37"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter37'
    AutoDestroy=true
	LifeSpan=20
}
