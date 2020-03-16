//=============================================================================
// MatchFireEffects
//=============================================================================
class MatchFireEffects extends P2Emitter;


defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
		SecondsBeforeInactive=0.0
        Acceleration=(Z=50.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=255))
        ColorScale(1)=(RelativeTime=0.300000,Color=(G=128,R=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(R=255))
        FadeOutStartTime=0.500000
        FadeOut=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=8
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.050000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.350000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.200000)
        StartSizeRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=8.000000,Max=8.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.FireMatch'
        LifetimeRange=(Min=0.800000,Max=0.800000)
        StartVelocityRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
        Name="SpriteEmitter14"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter14'
     AutoDestroy=true
}
