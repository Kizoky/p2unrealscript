///////////////////////////////////////////////////////////////////////////////
// UrineSmallBodyDrip
// 
//	Area of urine drips on the body of a small (Gary) person
//
///////////////////////////////////////////////////////////////////////////////
class UrineSmallBodyDrip extends PartDrip;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter36
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-300.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=64,G=128,R=128))
        MaxParticles=6
        StartLocationRange=(X=(Min=10.000000,Max=30.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Max=35.000000))
        UseRegularSizeScale=False
        StartSizeRange=(X=(Min=0.800000,Max=1.200000))
        CoordinateSystem=PTCS_Relative
        UniformSize=True
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.drip1'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-30.000000,Max=10.000000))
        Name="SpriteEmitter36"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter36'
    LifeSpan=20.000000
	MyType=FLUID_TYPE_Urine
    AutoDestroy=true
}
