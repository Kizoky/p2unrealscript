///////////////////////////////////////////////////////////////////////////////
// SledgeWake
// 
// Blurry effect of particles behind the spinning sledgehammer
//
///////////////////////////////////////////////////////////////////////////////
class SledgeWake extends P2Emitter;

///////////////////////////////////////////////////////////////////////////////
// Set the projection normal that the particles fit to
///////////////////////////////////////////////////////////////////////////////
function ChangeDirection(vector NewNormal)
{
	if(Emitters.Length > 0)
		if(SpriteEmitter(Emitters[0]) != None)
			SpriteEmitter(Emitters[0]).ProjectionNormal=NewNormal;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter22
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=0.300000,Y=1.000000,Z=0.000000)
         FadeOut=True
         SpinParticles=True
		 MaxParticles=5
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=1.500000,Max=1.500000))
         StartSizeRange=(X=(Min=40.000000,Max=40.000000),Y=(Min=40.000000,Max=40.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'circleswish'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
         Name="SpriteEmitter22"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter22'
     AutoDestroy=True
     RemoteRole=ROLE_None
}
