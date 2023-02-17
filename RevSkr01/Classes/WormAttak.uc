//=============================================================================
// WormAttak.
//=============================================================================
class WormAttak extends Wormrun;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter64
         Acceleration=(Z=-1500.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=23,G=55,R=70))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=20,G=57,R=90))
         MaxParticles=40
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         StartSizeRange=(X=(Min=25.000000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
         Texture=Texture'nathans.Skins.pour2'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=10.000000,Max=800.000000))
         Name="SpriteEmitter64"
     End Object
	 Emitters(0)=SpriteEmitter'SpriteEmitter64'
     AmbientSound=None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
