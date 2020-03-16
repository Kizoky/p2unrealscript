//=============================================================================
// ShockerSparks
//
// Come from when the Shocker hits an enemy, the emit for as long as you
// hit the target, then begin to fade and die
//=============================================================================
class ShockerSparks extends TimedEmitter;


defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter25
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-100.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=166))
        FadeOut=True
        MaxParticles=15
        StartLocationRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=1.000000,Max=2.000000))
        Texture=Texture'nathans.Skins.softwhitedot'
        LifetimeRange=(Min=0.500000,Max=0.700000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=15.000000,Max=20.000000))
        Name="SuperSpriteEmitter25"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter25'

	PlayTime=0.5
	FinishUpTime=0.5
    AutoDestroy=true
}
