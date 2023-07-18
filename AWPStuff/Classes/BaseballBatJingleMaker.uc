///////////////////////////////////////////////////////////////////////////////
// Jingle maker
// Silly actor that tells you how far you batted the head.
///////////////////////////////////////////////////////////////////////////////
class BaseballBatJingleMaker extends Info;

var() sound HomerunSound;

///////////////////////////////////////////////////////////////////////////////
// Internal vars
///////////////////////////////////////////////////////////////////////////////
var Head OurHead;
var bool bInitialized;
var vector StartLocation;
var vector BounceLocation;
var float CurrDist;

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const MIN_DELAY = 0.50;
const RAND_DELAY = 1.00;
const UU_TO_IN = 0.47;
const JINGLE_FREQ = 0.1;
const MIN_DIST_FOR_ANTHEM = 45;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetupFor(Actor Other)
{
	if (Head(Other) != None)
	{
		OurHead = Head(Other);
		StartLocation = OurHead.Location;
		bInitialized = True;
	}
	else // can't be used
	{
		warn("Can't use actor of class"@Other.Class);
		Destroy();
	}
	if (FRand() <= JINGLE_FREQ)
		SetTimer(1.00, false);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event Tick(float Delta)
{
	if (!bInitialized)
		return;

	BounceLocation = OurHead.Location;
	TellPlayer();
	
	if (OurHead.bBouncedOnce)
	{
		TellPlayerFinal();
		Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TellPlayer()
{
	local float Dist;
	local float Feet;

	Dist = VSize(StartLocation - BounceLocation);
	Feet = Dist * UU_TO_IN / 12;

	if (Int(Feet) > 45)
		PlayerController(Pawn(Owner).Controller).ReceiveLocalizedMessage(class'BaseballMessage', Int(Feet));
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TellPlayerFinal()
{
	local float Dist;
	local float Feet;

	Dist = VSize(StartLocation - BounceLocation);
	Feet = Dist * UU_TO_IN / 12;

//	if (Int(Feet) > 45)
//    	PlayerController(Pawn(Owner).Controller).ReceiveLocalizedMessage(class'BaseballRankMessage', Int(Feet));
}

event Timer()
{
	local float Dist;
	local float Feet;

	Dist = VSize(StartLocation - BounceLocation);
	Feet = Dist * UU_TO_IN / 12;

	if (Int(Feet) >= MIN_DIST_FOR_ANTHEM)
		PlayerController(Pawn(Owner).Controller).ViewTarget.PlaySound(Default.HomerunSound);
}

defaultproperties
{
}
