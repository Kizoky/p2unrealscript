///////////////////////////////////////////////////////////////////////////////
// A standing puddle of urine
///////////////////////////////////////////////////////////////////////////////
class UrinePuddle extends FluidPuddle;


var float LifeLeft;		// how much time till i'm dissolved slowly

const MIN_KEEP_RADIUS = 20;
const MAX_LIFE_SPAN	=	30;
const MIN_LIFE_SPAN	=	10;

///////////////////////////////////////////////////////////////////////////////
// skip ripples, and go back to original
///////////////////////////////////////////////////////////////////////////////
function SetFluidType(FluidTypeEnum newtype)
{
	SetFluidColors(newtype);

	// set it
	MyType = newtype;
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
//		if(!IsLeaking)
//		{
			DieTime = UseColRadius/12;

			if(DieTime < MIN_LIFE_SPAN)
				DieTime = MIN_LIFE_SPAN;
			if(DieTime > MAX_LIFE_SPAN)
				DieTime = MAX_LIFE_SPAN;

			return true;
//		}
//		return false;
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
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(A=255,R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255,G=255,B=255))
        FadeOutStartTime=0.500000
        FadeOut=True
        FadeInEndTime=0.200000
        FadeIn=True
        MaxParticles=3
        DrawStyle=PTDS_AlphaBlend
        StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000))
        Texture=Texture'nathans.Skins.urinepuddle'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        Name="SpriteEmitter7"
   End Object
   Emitters(0)=SpriteEmitter'Fx.SpriteEmitter7'
   MyType=FLUID_TYPE_Urine
   UseColRadius=20
   RadMax = 375
   TrailStarterClass = Class'UrineTrailStarter'
   DripFeederClass = Class'UrineDripFeeder'
   RippleClass = Class'UrineRippleEmitter'
   bCollideActors=true;
   AutoDestroy=true
}