///////////////////////////////////////////////////////////////////////////////
// GasBodyDrip
// 
//	Area of gasoline drips on the body of a person
//
///////////////////////////////////////////////////////////////////////////////
class GasBodyDrip extends PartDrip;


defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter35
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-300.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=192,G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,R=128))
        MaxParticles=12
        StartLocationRange=(X=(Min=20.000000,Max=40.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Max=55.000000))
        UseRegularSizeScale=False
        StartSizeRange=(X=(Min=1.000000,Max=1.300000))
        CoordinateSystem=PTCS_Relative
        UniformSize=True
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.drip1'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        Name="SpriteEmitter35"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter35'
    LifeSpan=50.000000
	MyType=FLUID_TYPE_Gas
    AutoDestroy=true
}
