//=============================================================================
// GrindLimbBlood.
//=============================================================================
class GrindLimbBlood extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter69
         UseDirectionAs=PTDU_Up
         Acceleration=(Z=-200.000000)
         MaxParticles=10
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         SpinsPerSecondRange=(X=(Max=0.100000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000),Y=(Min=60.000000,Max=40.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodanim2'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=200.000000,Max=300.000000))
         Name="SpriteEmitter69"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter69'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter67
         UseDirectionAs=PTDU_Up
         Acceleration=(Z=-400.000000)
         MaxParticles=3
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=1.000000,Max=3.000000),Y=(Min=1.000000,Max=3.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.skullchunks'
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.500000,Max=1.000000)
         StartVelocityRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=150.000000,Max=300.000000))
         Name="SpriteEmitter67"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter67'
     AutoDestroy=True
}
