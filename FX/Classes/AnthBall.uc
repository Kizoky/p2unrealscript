//=============================================================================
// Persitant, small cloud of deadly gas, that doesn't get blown away by wind
//=============================================================================
class AnthBall extends Anth;

state WaitAndFade
{
	ignores Timer, Tick;
	// Don't hurt stuff here, in this state
	simulated function BeginState()
	{
		local int i;
		for(i=0; i<Emitters.length; i++)
		{
			AutoDestroy=true;
			Emitters[i].ParticlesPerSecond=0;
			Emitters[i].RespawnDeadParticles=false;
		}
	}
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter12
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=100,R=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(G=16,R=128))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=8
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=0.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=60.000000,Max=90.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=3.000000,Max=4.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-20.000000,Max=20.000000))
		MaxAbsVelocity=(X=50,Y=50,Z=50);
        VelocityLossRange=(Z=(Min=0.200000,Max=0.200000))
        Name="SpriteEmitter12"
    End Object
    Emitters(0)=SpriteEmitter'Fx.SpriteEmitter12'
	LifeSpan=200.000000
	CollisionRadius=50
	CollisionHeight=50
	DamageDistMag=50
    bTrailerSameRotation=True
    Physics=PHYS_Trailer
    AutoDestroy=true
	bReplicateMovement=true
}