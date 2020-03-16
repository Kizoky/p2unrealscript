///////////////////////////////////////////////////////////////////////////////
// RocketTrail
//
// Smoke trail for rockets (fire is seperate)
///////////////////////////////////////////////////////////////////////////////
class NukeTrail extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter22
         UseColorScale=True
         ColorScale(0)=(RelativeTime=0.300000,Color=(B=150,G=150,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
         MaxParticles=20
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=70.000000,Max=110.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.smoke5'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
         Name="SpriteEmitter22"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter22'
     AutoDestroy=True
     bTrailerSameRotation=True
     bReplicateMovement=True
     Physics=PHYS_Trailer
     RelativeLocation=(X=100.000000)
}
