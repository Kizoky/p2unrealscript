///////////////////////////////////////////////////////////////////////////////
// ScytheWake
// 
// Blurry effect of particles behind the spinning scythe
//
///////////////////////////////////////////////////////////////////////////////
class ScytheWake extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter118
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(Y=0.300000)
         FadeOut=True
         SpinParticles=True
		 MaxParticles=5
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=1.500000,Max=1.500000))
         StartSizeRange=(X=(Min=60.000000,Max=60.000000),Y=(Min=60.000000,Max=60.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'circleswish'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
         Name="SpriteEmitter118"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter118'
     AutoDestroy=True
     RemoteRole=ROLE_None
}
