//=============================================================================
// Puke trail that moves down slopes automatically
//=============================================================================
class PukeFlowTrail extends FluidFlowTrail;

defaultproperties
{
   Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(A=255,R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255,G=255,B=255))
        FadeOutStartTime=25.000000
        FadeOut=True
        MaxParticles=30
        RespawnDeadParticles=False
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.008000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=5.000000,Max=8.000000),Y=(Min=5.000000,Max=8.000000))
        ParticlesPerSecond=0.000000
        InitialParticlesPerSecond=0.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.pukesplat'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=30.000000,Max=30.000000)
        Name="SuperSpriteEmitter6"
   End Object
   Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter6'
   DripTrailClass=Class'Fx.PukeDripTrail'
   MyType=FLUID_TYPE_Puke
   CollisionRadius=600.000000
   CollisionHeight=600.000000
   UseColRadius=40
   bCollideActors=true;
   LifeSpan=30.000000
   AutoDestroy=true
}