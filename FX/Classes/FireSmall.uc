//=============================================================================
// FireSmall.
//=============================================================================
class FireSmall extends FireEmitter;

const FADE_IN_TIME=2.0;

function PostBeginPlay()
{
	Emitters[0].Disabled=true;	// turn off at first (wait to start)
	Super.PostBeginPlay();
}

auto state Expanding
{
	simulated function Timer()
	{
		// turn back on (effectively start)
		Emitters[0].Disabled=false;
		GotoState('Burning');
	}
	function BeginState()
	{
		SetTimer(FADE_IN_TIME, false);
	}
}

state Burning
{
	simulated function Timer()
	{
		GotoState('Fading');
	}
	function BeginState()
	{
		SetTimer(OrigLifeSpan-FADE_IN_TIME, false);
	}
}

defaultproperties
{
	 DamageDistMag=60;

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
		SecondsBeforeInactive=0.0
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=15
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=0.000000,Max=0.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=20.000000,Max=45.000000))
         ParticlesPerSecond=15.000000
         InitialParticlesPerSecond=15.000000
         AutomaticInitialSpawning=False
         Texture=Texture'nathans.Skins.firegroup2'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.500000,Max=0.700000)
         StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=150.000000,Max=250.000000))
         Name="SpriteEmitter8"
     End Object
     Emitters(0)=SpriteEmitter'Fx.SpriteEmitter8'
     bDynamicLight=True
	 CollisionRadius=60
	 CollisionHeight=100
     Physics=PHYS_Trailer
     LifeSpan=13.000000
	 AutoDestroy=true
}
