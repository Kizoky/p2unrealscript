///////////////////////////////////////////////////////////////////////////////
// FlameProjectileFire
// By: Dopamine, Kamek
// For: Eternal Damnation
//
// Flaming effect for the flame projectile.
///////////////////////////////////////////////////////////////////////////////

class FlameProjectileFire extends P2Emitter;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=FProjEmitter
        Acceleration=(Z=-100.000000)
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=98))
        FadeOut=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=25
        ResetAfterChange=True
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-1.000000,Max=1.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.100000,Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
        StartSizeRange=(X=(Min=8.000000,Max=13.000000))
        UniformSize=True
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.fireball1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        SecondsBeforeInactive=0.000000
        //LifetimeRange=(Min=0.500000,Max=0.600000)
		LifetimeRange=(Min=1,Max=1)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=100.000000))
        Name="SpriteEmitter29"
    End Object
    Emitters(0)=SpriteEmitter'FProjEmitter'
    bTrailerSameRotation=True
    Physics=PHYS_Trailer
	bReplicateMovement=true
	AutoDestroy=True
}

