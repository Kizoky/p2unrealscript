//=============================================================================
// CigaretteSmoke.
//=============================================================================
class CigaretteSmoke extends P2Emitter;

#exec TEXTURE IMPORT File=Textures\CigGlow.dds
#exec TEXTURE IMPORT File=Textures\CigSmoke3.dds
/*
var float SizeChange;

auto state Rise
{
	function Tick(float DeltaTime)
	{
		Emitters[0].StartSizeRange.X.Max+=(SizeChange*DeltaTime);
		Emitters[0].StartSizeRange.X.Min+=(SizeChange*DeltaTime);
	}
	
	function BeginState()
	{
		SizeChange=-(2*Emitters[0].StartSizeRange.X.Max)/(LifeSpan+1);
	}
}
*/
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter62
        Acceleration=(Z=0.010000)
        FadeOutStartTime=1.000000
        FadeOut=True
        FadeInEndTime=0.500000
        FadeIn=True
        MaxParticles=35
        SpinParticles=True
        SpinCCWorCW=(X=1.000000,Y=1.000000,Z=1.000000)
        SpinsPerSecondRange=(X=(Min=0.075000,Max=0.075000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.005000)
        SizeScale(1)=(RelativeTime=0.150000,RelativeSize=0.020000)
        SizeScale(2)=(RelativeTime=0.600000,RelativeSize=0.030000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=0.025000)
        ParticlesPerSecond=4.000000
        InitialParticlesPerSecond=3.000000
        AutomaticInitialSpawning=False
        Texture=Texture'CigSmoke3'
        LifetimeRange=(Min=9.800000,Max=10.000000)
        StartVelocityRange=(X=(Min=-0.250000,Max=0.250000),Y=(Min=-0.250000,Max=0.250000),Z=(Min=2.500000,Max=2.750000))
        WarmupTicksPerSecond=1.000000
        RelativeWarmupTime=5.000000
        Name="SpriteEmitter62"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter62'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter63
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
		MaxParticles=1
        StartSizeRange=(X=(Min=1.200000,Max=1.200000))
        Texture=Texture'GenFX.LensFlar.softlens'
        LifetimeRange=(Min=0.100000,Max=0.100000)
        Name="SpriteEmitter63"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter63'
    DrawScale=0.025000
}
