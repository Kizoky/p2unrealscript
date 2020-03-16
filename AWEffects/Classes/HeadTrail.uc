///////////////////////////////////////////////////////////////////////////////
// HeadTrail
// 
///////////////////////////////////////////////////////////////////////////////
class HeadTrail extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter51
         UseColorScale=True
         ColorScale(0)=(Color=(G=220,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
         FadeOutStartTime=-0.500000
         FadeOut=True
         MaxParticles=15
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=8.000000,Max=10.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.softwhitedot'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         Name="SpriteEmitter51"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter51'
     AutoDestroy=True
     bTrailerSameRotation=True
     bReplicateMovement=True
     Physics=PHYS_Trailer
}
