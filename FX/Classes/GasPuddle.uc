//=============================================================================
// A standing puddle of gasoline
//=============================================================================
class GasPuddle extends FluidPuddle;

defaultproperties
{
   Begin Object Class=SpriteEmitter Name=SpriteEmitter7
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        FadeOutStartTime=0.500000
        FadeOut=True
        FadeInEndTime=0.200000
        FadeIn=True
        MaxParticles=4
        DrawStyle=PTDS_AlphaBlend
        StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000))
        Texture=Texture'nathans.Skins.GasPuddle'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=1.000000)
        Name="SpriteEmitter7"
   End Object
   Emitters(0)=SpriteEmitter'Fx.SpriteEmitter7'
   MyType=FLUID_TYPE_Gas
   UseColRadius=20
   RadMax = 375
   TrailStarterClass = Class'GasTrailStarter'
   DripFeederClass = Class'GasDripFeeder'
   RippleClass = Class'GasRippleEmitter'
   bCanBeDamaged=true
   bCollideActors=true
   AutoDestroy=true
   CollisionRadius=100.000000
   CollisionHeight=50.000000
}
