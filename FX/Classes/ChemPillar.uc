///////////////////////////////////////////////////////////////////////////////
// ChemPillar
// 
// Pillar of chemical gas
//
///////////////////////////////////////////////////////////////////////////////
class ChemPillar extends P2Emitter;

var bool bStopped;

const MOVE_TIME	=	0.3;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Active
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Active
{
	simulated function ProcessTouch(Actor Other, Vector HitLocation)
	{
		Stopping();
	}
	simulated function HitWall (vector HitNormal, actor Wall)
	{
		Stopping();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop the pillar, but also make the top ball
	///////////////////////////////////////////////////////////////////////////////
	function Stopping()
	{
		local FireBall fp;
		if(!bStopped)
		{
			bStopped=true;
			Velocity.Z=0;
			// Top chemball
			spawn(class'ChemBall',,,Location);
		}
	}
Begin:
	Sleep(MOVE_TIME);
	Stopping();
}

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter14
		SecondsBeforeInactive=0.0
        UseColorScale=true
        ColorScale(0)=(RelativeTime=0.000000,Color=(B=50,G=150,R=150))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
        MaxParticles=10
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
		StartLocationOffset=(Z=-20.0)
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.000000)
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Min=80.000000,Max=120.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=3.500000,Max=5.000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=5.000000,Max=30.000000))
        VelocityLossRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
        Name="SuperSpriteEmitter14"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter14'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter16
		SecondsBeforeInactive=0.0
        UseColorScale=true
        ColorScale(0)=(RelativeTime=0.000000,Color=(B=50,G=200,R=150))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
        MaxParticles=10
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
		StartLocationOffset=(Z=-20.0)
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.000000)
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Min=60.000000,Max=90.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=3.500000,Max=5.000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=5.000000,Max=30.000000))
        VelocityLossRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
        Name="SuperSpriteEmitter16"
    End Object
    Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter16'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter15
		SecondsBeforeInactive=0.0
        UseColorScale=true
        ColorScale(0)=(RelativeTime=0.000000,Color=(B=50,G=220,R=150))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
        FadeOut=True
        MaxParticles=15
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        SizeScaleRepeats=3.000000
        StartSizeRange=(X=(Min=3.000000,Max=5.000000))
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.bubbles'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=5.000000,Max=7.000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=10.000000,Max=30.000000))
        VelocityLossRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
        Name="SuperSpriteEmitter15"
    End Object
    Emitters(2)=SuperSpriteEmitter'SuperSpriteEmitter15'
	AutoDestroy=true
	Velocity=(Z=1000)
	Physics=PHYS_Projectile
	bBounce=true
    bCollideActors=true
    bCollideWorld=true
}
