//=============================================================================
// woodchips.
//=============================================================================
class woodchips extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
		SecondsBeforeInactive=0.0
         UseDirectionAs=PTDU_Forward
         Acceleration=(Z=-1000.000000)
         UseCollision=True
         DampingFactorRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.400000,Max=0.400000))
         MaxParticles=20
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
         UseRotationFrom=PTRS_Actor
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=10.000000,Max=25.000000),Y=(Min=10.000000,Max=25.000000))
         InitialParticlesPerSecond=50.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.plywoodparts'
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         UseRandomSubdivision=True
         LifetimeRange=(Min=2.500000,Max=3.000000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-50.000000,Max=-200.000000),Z=(Min=-100.000000,Max=100.000000))
         Name="SpriteEmitter1"
     End Object
     Emitters(0)=SpriteEmitter'Fx.SpriteEmitter1'
     LastRenderTime=445.640625
     Location=(X=-896.000000,Y=240.000000,Z=-184.000000)
     bSelected=True
     AutoDestroy=true
}
