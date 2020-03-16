///////////////////////////////////////////////////////////////////////////////
// A standing puddle of blood
///////////////////////////////////////////////////////////////////////////////
class BloodPuddle extends FluidPuddle;


var float LifeLeft;		// how much time till i'm dissolved slowly

const MIN_KEEP_RADIUS = 20;
const MAX_LIFE_SPAN	=	60;
const MIN_LIFE_SPAN	=	20;

const RAD_RAND	=	20;
const RAD_BASE	=	30;

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
   Begin Object Class=SpriteEmitter Name=SpriteEmitter7
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        FadeOutStartTime=0.500000
        FadeOut=True
        FadeInEndTime=0.200000
        FadeIn=True
        MaxParticles=3
        DrawStyle=PTDS_AlphaBlend
        StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000))
        Texture=Texture'nathans.Skins.Bloodpuddle1'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        Name="SpriteEmitter7"
   End Object
   Emitters(0)=SpriteEmitter'Fx.SpriteEmitter7'
   MyType=FLUID_TYPE_Blood
   UseColRadius=20
   RadMax = 375
   TrailStarterClass = Class'BloodTrailStarter'
   DripFeederClass = Class'BloodDripFeeder'
   RippleClass = None
   bCollideActors=true;
   AutoDestroy=true
   Lifespan=60
}