///////////////////////////////////////////////////////////////////////////////
// MacheteWake
// 
// Blurry effect of particles behind the spinning machete
//
///////////////////////////////////////////////////////////////////////////////
class MacheteWake extends P2Emitter;

#exec TEXTURE IMPORT NAME=circleswish FILE=Textures\circleswish.dds MIPS=off

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter115
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(Y=0.300000)
         FadeOut=True
		 MaxParticles=4
         SpinParticles=True
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=1.500000,Max=1.500000))
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'circleswish'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
         Name="SpriteEmitter115"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter115'
     AutoDestroy=True
     RemoteRole=ROLE_None
}
