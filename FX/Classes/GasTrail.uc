//=============================================================================
// a trail of gasoline fuel on a surface
//=============================================================================
class GasTrail extends FluidTrail;



///////////////////////////////////////////////////////////////////////////////
// Set whether or not you can be damaged or not
// Override base class so we can modify it, but say, urine won't
///////////////////////////////////////////////////////////////////////////////
function SetCanBeDamaged(bool bNewCan)
{
	bCanBeDamaged=bNewCan;
}

defaultproperties
{
   Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter8
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        MaxParticles=40
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=30.000000))
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.005000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=22.000000,Max=32.000000),Y=(Min=22.000000,Max=32.000000))
        ParticlesPerSecond=0.000000
        InitialParticlesPerSecond=0.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.gassplat1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        Name="SuperSpriteEmitter8"
   End Object
   Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter8'
   DripTrailClass=Class'Fx.GasDripTrail'
   MyType=FLUID_TYPE_Gas
   CollisionRadius=100.000000
   CollisionHeight=100.000000
   UseColRadius=50
   bCollideActors=true
   LifeSpan=40.000000
   AutoDestroy=true
   Health=75
}