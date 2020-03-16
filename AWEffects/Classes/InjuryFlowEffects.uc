///////////////////////////////////////////////////////////////////////////////
// seeing stars
///////////////////////////////////////////////////////////////////////////////
class InjuryFlowEffects extends P2Emitter;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Flowing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Flowing
{
	function Timer()
	{
		local byte oldb;

		// cycle the colors on the particles every once in a while
		if(Emitters.Length > 0)
		{
			oldb = Emitters[0].ColorScale[1].Color.R;
			Emitters[0].ColorScale[1].Color.R = Emitters[0].ColorScale[1].Color.G;
			Emitters[0].ColorScale[1].Color.G = Emitters[0].ColorScale[1].Color.B;
			Emitters[0].ColorScale[1].Color.B = oldb;
		}
	}
Begin:
	SetTimer(10.0, true);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter112
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=50,G=100,R=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=1.000000,Max=3.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'Zo_Smeg.Special_Brushes.zo_corona2'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=5.000000,Max=15.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=150.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         Name="SpriteEmitter112"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter112'
     AutoDestroy=True
}
