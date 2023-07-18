//=============================================================================
// FireMatchFPS.
// 
// Fire effect for a lit match in first-person view.
//
// Changed by Man Chrzan: xPatch 2.0	
//=============================================================================
class FireMatchFPS extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(B=255))
        ColorScale(1)=(RelativeTime=0.300000,Color=(G=128,R=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(R=255))
        //FadeOutStartTime=0.500000
		FadeOutStartTime=0.350000
        FadeOut=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=6
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.050000))
        UseSizeScale=True
        UseRegularSizeScale=False	
		//SizeScale(0)=(RelativeSize=0.350000)
		//SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
		//SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.200000)
		//StartSizeRange=(X=(Min=0.250000,Max=0.400000),Y=(Min=0.250000,Max=0.400000))
		SizeScale(0)=(RelativeSize=1.050000)
        SizeScale(1)=(RelativeTime=0.350000,RelativeSize=1.700000)
        SizeScale(2)=(RelativeTime=0.750000,RelativeSize=0.900000)
        StartSizeRange=(X=(Min=0.950000,Max=1.100000),Y=(Min=0.950000,Max=1.100000))		
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.FireMatch'
        LifetimeRange=(Min=0.700000,Max=0.700000)
        //StartVelocityRange=(X=(Min=-0.250000,Max=0.250000),Y=(Min=-0.250000,Max=0.250000),Z=(Min=0.400000,Max=0.800000))
		StartVelocityRange=(X=(Min=-0.300000,Max=0.300000),Y=(Min=-0.300000,Max=0.300000),Z=(Min=0.250000,Max=3.500000))
        Name="SpriteEmitter14"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter14'
	 AutoDestroy=true
	 LifeSpan=20
}
