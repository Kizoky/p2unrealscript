//=============================================================================
// Gasoline trail that moves down slopes automatically
//=============================================================================
class GasFlowTrail extends FluidFlowTrail;

defaultproperties
{
   Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        FadeOutStartTime=55.000000
        FadeOut=True
        MaxParticles=20
        RespawnDeadParticles=False
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.010000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=10.000000,Max=15.000000),Y=(Min=10.000000,Max=15.000000))
        ParticlesPerSecond=0.000000
        InitialParticlesPerSecond=0.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.gassplat1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=60.000000,Max=60.000000)
        Name="SuperSpriteEmitter6"
   End Object
   Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter6'
   DripTrailClass=Class'Fx.GasDripTrail'
   MyType=FLUID_TYPE_Gas
   CollisionRadius=100.000000
   CollisionHeight=100.000000
   UseColRadius=90
   bCanBeDamaged=true
   bCollideActors=true
   LifeSpan=60.000000
   AutoDestroy=true
   Health=50
}