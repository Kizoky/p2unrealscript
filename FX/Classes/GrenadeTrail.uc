///////////////////////////////////////////////////////////////////////////////
// GrenadeTrail
// 
// Smoke trail for rockets (fire is seperate)
///////////////////////////////////////////////////////////////////////////////
class GrenadeTrail extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter50
		SecondsBeforeInactive=0.0
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        MaxParticles=10
		FadeOut=true
		FadeOutStartTime=-3.5
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=2.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=8.000000,Max=10.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.softwhitedot'
        LifetimeRange=(Min=0.600000,Max=0.600000)
        Name="SpriteEmitter50"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter50'
    bTrailerSameRotation=True
    Physics=PHYS_Trailer
    AutoDestroy=true
	bReplicateMovement=true
	Lifespan=15
}