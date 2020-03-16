///////////////////////////////////////////////////////////////////////////
// Feeder that attaches to other objects to be poured out (like a gas tank)
//
// MP only
//
// Uses Pawn's bSteadyFiring to know when all remote clients are peeing.
//
///////////////////////////////////////////////////////////////////////////
class UrinePourFeederMP extends UrinePourFeeder;

///////////////////////////////////////////////////////////////////////////
// Make the visual component for *each* client (remotes and local that's pissing)
// and connect it
///////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	local UrineStreamMP ustm;

	Super.PostNetBeginPlay();

	// Say it's flowing, for use in MP
	if(Pawn(Owner) != None)
	{
		// Tells the visuals on all the clients to say alive and not die yet. 
		Pawn(Owner).bSteadyFiring=true;

		// Only attach the visual version on the clients/listenserver
		if(NotDedOnServer())
		{
			// Check first to make sure it doesn't already have one with this same owner
			foreach DynamicActors(class'UrineStreamMP', ustm);
			if(ustm == None)
			{
				ustm = spawn(class'UrineStreamMP',Owner);
				ustm.SetBase(Owner);
			}
		}
	}
	else
		Destroyed();
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	// Tells the visuals of the pissing on all the clients to die now.
	if(Pawn(Owner) != None)
		Pawn(Owner).bSteadyFiring=false;
	Super.Destroyed();
}

defaultproperties
{
    Begin Object Class=StripEmitter Name=StripEmitter0
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-2000.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255,R=255))
        FadeInEndTime=0.300000
        FadeIn=True
	    FadeOut=True
        MaxParticles=17
		Disabled=true
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScaleRepeats=3.000000
        StartSizeRange=(X=(Min=0.500000,Max=2.500000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.pour1'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=-1000.000000,Max=-1000.000000),Z=(Min=300.000000,Max=300.000000))
		//ZTest=false
		//ZWrite=true
        Name="StripEmitter0"
    End Object
    Emitters(0)=StripEmitter'StripEmitter0'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-1800.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255,R=255))
        FadeOutStartTime=1.100000
        FadeOut=True
        MaxParticles=25
		Disabled=true
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.600000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=0.800000,Max=1.800000),Y=(Min=0.800000,Max=1.800000))
        InitialParticlesPerSecond=0.000000
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.drips1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.300000,Max=1.600000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
		//ZTest=false
		//ZWrite=true
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'
    MyType=FLUID_TYPE_Urine
	SplashClass = class'UrineSplashEmitter'
	TrailClass = class'UrineTrail'
	TrailStarterClass = class'UrineTrailStarter'
	PuddleClass = class'UrinePuddle'
	bCollideActors=true
	QuantityPerHit=10
	SpawnDripTime=0.15
	bCanHitActors=true
	MomentumTransfer=1.0
	InitialPourSpeed=600
	InitialSpeedZPlus=500
	SpeedVariance=15
	Quantity=40
	MyDamageType=class'UrineDamage'
    AutoDestroy=true
	ArcMax=8
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}
