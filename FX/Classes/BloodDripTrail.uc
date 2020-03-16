///////////////////////////////////////////////////////////////////////////////
// BloodDripTrail. 
// 
// A dripping line that forms for a moment after you've sprayed a fluid along
// a 'ceiling' (anything with a negative in the normal.z. 
// This goes away pretty quickly
///////////////////////////////////////////////////////////////////////////////
class BloodDripTrail extends FluidDripTrail;

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter13
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-500.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(A=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255))
        MaxParticles=8
		LocationShapeExtend=PTLSE_Line
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.000000)
        StartSizeRange=(X=(Min=1.500000,Max=3.000000),Y=(Min=1.500000,Max=3.000000))
        ParticlesPerSecond=2.000000
        InitialParticlesPerSecond=2.000000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.drip1'
        LifetimeRange=(Min=1.000000,Max=2.000000)
        Name="SuperSpriteEmitter13"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter13'
     LifeSpan=8.000000
	 AutoDestroy=true
}
