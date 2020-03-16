///////////////////////////////////////////////////////////////////////////////
// A standing puddle of Puke
///////////////////////////////////////////////////////////////////////////////
class PukePuddle extends FluidPuddle;


var float LifeLeft;		// how much time till i'm dissolved slowly

const MIN_KEEP_RADIUS = 20;
const MAX_LIFE_SPAN	=	60;
const MIN_LIFE_SPAN	=	20;
const TIME_TO_MAKE_PUDDLE = 0.2;

const RAD_RAND	=	30;
const RAD_BASE	=	60;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	RadMax = RAD_BASE + FRand()*RAD_RAND;
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool CheckForKeepRadius()
{
	if(UseColRadius < MIN_KEEP_RADIUS
		&& !IsLeaking)
	{
		SlowlyDestroy();
		return false;
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function AddQuantity(float MoreQ, vector InputPoint, Fluid InputFluid)
{
	UpdateCollisionFromNewQuantity(MoreQ, InputPoint, InputFluid);

	// update visuals
	Emitters[0].StartSizeRange.X.Min = UseColRadius/3;
	Emitters[0].StartSizeRange.X.Max = UseColRadius/3+1;
	Emitters[0].StartSizeRange.Y.Min = UseColRadius/3;
	Emitters[0].StartSizeRange.Y.Max = UseColRadius/3+1;
	// update particle motion
    Emitters[0].StartVelocityRange.X.Max=UseColRadius;
	Emitters[0].StartVelocityRange.X.Min=-UseColRadius;
    Emitters[0].StartVelocityRange.Y.Max=UseColRadius;
	Emitters[0].StartVelocityRange.Y.Min=-UseColRadius;
	// emit more
	Emitters[0].SpawnParticle(1);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Waiting to die
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitingToDie
{
	function bool CalcDieTime(out float DieTime)
	{
		if(!IsLeaking)
		{
			DieTime = UseColRadius/6;

			if(DieTime < MIN_LIFE_SPAN)
				DieTime = MIN_LIFE_SPAN;
			if(DieTime > MAX_LIFE_SPAN)
				DieTime = MAX_LIFE_SPAN;

			return true;
		}
		return false;
	}
Begin:
	if(CalcDieTime(LifeLeft))
	{
		Sleep(LifeLeft);
		SlowlyDestroy();
	}
}

defaultproperties
{
   Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter8
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(A=255,R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255,G=255,B=255))
        FadeOut=True
        MaxParticles=40
        RespawnDeadParticles=False
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.01000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=9.000000,Max=13.000000))
        ParticlesPerSecond=0.000000
        InitialParticlesPerSecond=0.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.pukesplat'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=30.000000,Max=30.000000)
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000))
        Name="SuperSpriteEmitter8"
   End Object
   Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter8'
   MyType=FLUID_TYPE_Puke
   UseColRadius=35
   RadMax = 375
   TrailStarterClass = Class'PukeTrailStarter'
   DripFeederClass = Class'PukeDripFeeder'
   RippleClass = Class'PukeRippleEmitter'
   bCollideActors=true;
   AutoDestroy=true
}