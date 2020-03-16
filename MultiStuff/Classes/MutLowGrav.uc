class MutLowGrav extends Mutator;

var float GravityZ;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	// RWS FIXME: No equivalent to this in 927 -- what to do?
	//Level.DefaultGravity = GravityZ;
}

function bool MutatorIsAllowed()
{
	return true;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local PhysicsVolume PV;
    local vector XYDir;
    local float ZDiff,Time;
    local JumpPad J;
    
    PV = PhysicsVolume(Other);
    
	if ( PV != None )
		PV.Gravity.Z = FMax(PV.Gravity.Z,GravityZ);

/* RWS FIXME: Fix this if we end up using jump pads
	J = JumpPad(Other);
	if ( J != None )
	{
		XYDir = J.JumpTarget.Location - J.Location;
		ZDiff = XYDir.Z;
		Time = 2.5f * J.JumpZModifier * Sqrt(Abs(ZDiff/GravityZ));
		J.JumpVelocity = XYDir/Time; 
		J.JumpVelocity.Z = ZDiff/Time - 0.5f * GravityZ * Time;
	}*/
	return true;
}

defaultproperties
{
	GravityZ=-300.0

	GroupName="Gravity"
	FriendlyName="Low Gravity"
	Description="Turns on low gravity so you can jump real high.  Kind of fun in a gay sort of way.  Also lets you get to all sorts of places you shouldn't get to, so don't complain when you fall out of the world."
}