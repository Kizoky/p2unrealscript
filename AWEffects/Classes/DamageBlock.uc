///////////////////////////////////////////////////////////////////////////////
// DamageBlock
// 
///////////////////////////////////////////////////////////////////////////////
class DamageBlock extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter96
         UseColorScale=True
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
         FadeOut=True
         MaxParticles=3
         RespawnDeadParticles=False
         SpinParticles=True
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.300000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=40.000000,Max=50.000000))
         UniformSize=True
         Texture=Texture'nathans.Skins.bigfluidripple'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000))
         Name="SpriteEmitter96"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter96'
     AutoDestroy=True
}
