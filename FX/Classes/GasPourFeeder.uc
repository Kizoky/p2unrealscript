///////////////////////////////////////////////////////////////////////////
// Feeder that attaches to other objects to be poured out (like a gas tank)
///////////////////////////////////////////////////////////////////////////
class GasPourFeeder extends FluidPourFeederMP;//FluidPourFeeder;

///////////////////////////////////////////////////////////////////////////
// The fluid is hitting a pawn. 
///////////////////////////////////////////////////////////////////////////
function HittingPawn(FPSPawn fpawn, vector HitLocation)
{
	local LambController lambc;

	lambc = LambController(fpawn.Controller);

	// Only happens if guy is still alive
	if(lambc != None)
	{
		// Set me to dripping in gas
		lambc.HitWithFluid(MyType, HitLocation);
		// Tells them they're being splashed with gasoline
		lambc.GettingDousedInGas(P2Pawn(MyOwner));
	}

	// Sets them to flammable, dead or alive
	fpawn.bExtraFlammable = true;
}

///////////////////////////////////////////////////////////////////////////
// Feeder hit an actor other than a puddle
// Check to see if you hit some fire
///////////////////////////////////////////////////////////////////////////
function int FeederHitActor(Actor Other, vector HitLocation, vector HitNormal,
						vector FeederStart, vector FeederEnd, float DeltaTime)
{
	if(P2PowerupPickup(Other) != None)		// if it hits a pickup, then taint it
	{
		P2PowerupPickup(Other).Taint();
	}
	else if(PeoplePart(Other) != None)
	{
		PeoplePart(Other).HitByGas();
	}

	return 0;
}

///////////////////////////////////////////////////////////////////////////
// Manually check if you're hitting you're owner, since Trace won't let you
// and we can do it more cheaply. 
// Trace checks to not hit the owner, and besides, we don't need that
// sort of accurate collision for this
// Do this by checking direction of pouring
// This is merely for DETECTION of the collision, not for the splashing and all
///////////////////////////////////////////////////////////////////////////
function HittingOwner(vector Dir)
{
	local P2Player pplayer;
	local P2Pawn p2p;
	local vector toppos;

	p2p = P2Pawn(MyOwner);

	if(p2p != None)
	{
		// If it's getting poured/pushed upwards, then it's going to fall back
		// down and hit the owner
		if(Dir.z > UpwardsZMin)
		{
			toppos = p2p.Location;
			toppos.z += p2p.CollisionRadius;

			if(LambController(p2p.Controller) != None)
				HittingPawn(p2p, toppos);
			else
			{
				pplayer = P2Player(p2p.Controller);
				if(pplayer != None)
					pplayer.DousedHimselfInGas();
			}
		}
	}
}

defaultproperties
{
    Begin Object Class=StripEmitter Name=StripEmitter0
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-1500.000000)
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(R=80,G=20,B=30))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=220,G=100,B=255))
		FadeOutStartTime=0.300000
	    FadeOut=True
        MaxParticles=25
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.300000)
        StartSizeRange=(X=(Min=3.000000,Max=5.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.pour1'
        LifetimeRange=(Min=0.800000,Max=0.800000)
        StartVelocityRange=(X=(Min=-1000.000000,Max=-1000.000000),Z=(Min=300.000000,Max=300.000000))
        Name="StripEmitter0"
    End Object
    Emitters(0)=StripEmitter'StripEmitter0'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-1350.000000)
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(R=220,G=50,B=180))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=180,G=100,B=255))
		FadeInEndTime=0.550000
        FadeIn=True
		FadeOutStartTime=0.700000
        FadeOut=True
        MaxParticles=20
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=17.000000,Max=35.000000),Y=(Min=17.000000,Max=35.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.pourcircle1'
        LifetimeRange=(Min=0.800000,Max=1.4000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
        Name="SpriteEmitter2"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter2'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-1350.000000)
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(R=220,G=50,B=180))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=220,G=100,B=255))
		FadeInEndTime=0.750000
        FadeIn=True
		FadeOutStartTime=0.800000
        FadeOut=True
        MaxParticles=10
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=15.000000,Max=30.000000),Y=(Min=30.000000,Max=60.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.pour2'
        LifetimeRange=(Min=1.000000,Max=1.3000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
        Name="SpriteEmitter3"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter3'
    MyType=FLUID_TYPE_Gas
	SplashClass = Class'GasSplashEmitterMed'
	TrailClass = Class'GasTrail'
	TrailStarterClass = Class'GasTrailStarter'
	PuddleClass = Class'GasPuddle'
	bCollideActors=true
	bCanHitActors=true
	MomentumTransfer=0.3
	InitialPourSpeed=300
	InitialSpeedZPlus=100
	SpeedVariance=0
	Quantity=80
	AutoDestroy=true
}
