//=============================================================================
// Wind.
//=============================================================================
class Wind extends Info
	placeable;

// external
var() int UpdateFreqTime;
var() int MagMax;
var() int MagMin;
var() int StartAngle;
var() int AngleChangeMax;
var() int AngleChangeMin;

// internal
var float Angle;
var vector Acc; // acceleration applied by the wind
var vector OldAcc;
var int UseMag;

const DEG_360 				= 6.28;
const CONVERT_360_TO_2PI 	= 0.01746;

///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	SetTimer(UpdateFreqTime, true);
	Angle=Rand(DEG_360);
	OldAcc.x=0;
	OldAcc.y=0;
	// convert angle value from 360 degree (for user) to useful 2PI range
	Angle = StartAngle*CONVERT_360_TO_2PI;
	Super.PostBeginPlay();
}

// Generate the new acceleration the wind will use based
// off the angle and it's magnitude. First slightly modify
// the angle and magnitude
function GenAcc()
{
	local float AngDelta;

	// save the old acceleration
	OldAcc = Acc;
	// calculate the new angle
	AngDelta = (Rand(AngleChangeMax - AngleChangeMin) + AngleChangeMin)*CONVERT_360_TO_2PI;
	if(Rand(2) == 1)
		Angle += AngDelta;
	else
		Angle -= AngDelta;

//	Angle += ((Rand(10) - 5)*0.1);
	if(Angle > DEG_360)
		Angle-=DEG_360;
	else if(Angle < 0)
		Angle+= DEG_360;

	// calculate the new wind magnitude
	UseMag = Rand(MagMax - MagMin) + MagMin;

	Acc.x = UseMag*Cos(Angle);
	Acc.y = UseMag*Sin(Angle);
}

function Timer()
{
	local Wemitter e;
	local int num;
	// Each time generate a new acceleration for the
	// wind and then remove the old one you've given to the
	// emitters and apply the new one.
	GenAcc();
	foreach AllActors(class 'Wemitter', e)
	{
		e.ApplyWindEffects(Acc, OldAcc);
	}
}

defaultproperties
{
     UpdateFreqTime=4
     MagMax=250
     MagMin=150
     AngleChangeMax=40
     AngleChangeMin=20
}
