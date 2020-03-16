///////////////////////////////////////////////////////////////////////////////
// BystanderController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// Gimp controller just makes sure people laugh at 
// him all the time
//
///////////////////////////////////////////////////////////////////////////////
class GimpController extends BystanderController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const REPORT_LOOKS_FREQ	=	0.33;

///////////////////////////////////////////////////////////////////////////////
// Called by the interest points to see if we're interested in doing this
///////////////////////////////////////////////////////////////////////////////
function PerformInterestAction(InterestPoint IPoint, out byte AllowFlow)
{
	// Gimp never does interest point stuff
}

///////////////////////////////////////////////////////////////////////////////
// Don't talk at anyone (also keeps him from laughing at Dude gimp)
///////////////////////////////////////////////////////////////////////////////
function TryToGreetPasserby(FPSPawn PasserBy, bool bIsGimp, bool bIsCop, optional out byte StateChange)
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LegMotionToTarget
// Pretty much everything you do makes people laugh at you
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LegMotionToTarget
{
	function BeginState()
	{
		Super.BeginState();

		MyPawn.ReportPersonalLooksToOthers();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToTarget
// Pretty much everything you do makes people laugh at you
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTarget
{

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();

		if(FRand() < REPORT_LOOKS_FREQ)
			MyPawn.ReportPersonalLooksToOthers();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Do things after you reach a crappy goal, not your end goal
	///////////////////////////////////////////////////////////////////////////////
	function IntermediateGoalReached()
	{
		MyPawn.ReportPersonalLooksToOthers();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PerformIdle
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PerformIdle
{
	function BeginState()
	{
		Super.BeginState();

		MyPawn.ReportPersonalLooksToOthers();
	}
}

defaultproperties
{
}