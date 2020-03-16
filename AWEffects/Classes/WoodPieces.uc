//=============================================================================
// WoodPieces.
//=============================================================================
class WoodPieces extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter57
         UseDirectionAs=PTDU_Right
         Acceleration=(Z=-800.000000)
         UseCollision=True
         DampingFactorRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.400000,Max=0.400000))
         FadeOutStartTime=1.000000
         FadeOut=True
         MaxParticles=8
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=-25.000000,Max=25.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         StartSizeRange=(X=(Min=5.000000,Max=25.000000),Y=(Min=5.000000,Max=25.000000))
         InitialParticlesPerSecond=50.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW_Textures.plywoodparts_AW'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.800000,Max=1.200000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-60.000000,Max=-30.000000))
         Name="SpriteEmitter57"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter57'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter110
         UseColorScale=True
         ColorScale(0)=(Color=(B=175,G=199,R=209))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=56,G=102,R=122))
         FadeOut=True
         MaxParticles=8
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=80.000000,Max=90.000000))
         InitialParticlesPerSecond=50.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.wispsmoke'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=5.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=10.000000))
         Name="SpriteEmitter110"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter110'
     AutoDestroy=True
}
