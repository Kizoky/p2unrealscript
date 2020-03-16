//=============================================================================
// SmokeHitPuffSledge.
//=============================================================================
class SmokeHitPuffSledge extends SmokeHitPuff;

defaultproperties
{
     VelMax=60.000000
     velloss=1.000000
     timeminratio=0.800000
     Begin Object Class=SpriteEmitter Name=SpriteEmitter75
         UseColorScale=True
         ColorScale(0)=(Color=(B=58,G=84,R=126))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=61,G=100,R=182))
         MaxParticles=6
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=25.000000,Max=40.000000))
         InitialParticlesPerSecond=50.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.smoke5'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-20.000000,Max=20.000000))
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
         Name="SpriteEmitter75"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter75'
     AutoDestroy=True
}
