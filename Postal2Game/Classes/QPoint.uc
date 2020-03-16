///////////////////////////////////////////////////////////////////////////////
// This is a queue for people to stand in, like in a grocery awaiting checkout
///////////////////////////////////////////////////////////////////////////////
class QPoint extends InterestPoint
	notplaceable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
// External variables
var ()Name	EndTag;		// Tag for key point that marks the end of the queue
var ()float	UpdateTime;	// How quickly the line moves--how often you update the line
var ()float DistToActive;// How close the player needs to be before I become active--if I wasn't already
						// active
var ()float CutterFrequency;// 0 to 1 for how often people try to just go straight to the front
							// of the line

//var ()Name	SenderTag;	// Tag for actor that sent us the pawn in the first place.

// Internal variables
var QPathPoint	EndMarker;	// Actor for EndTag.
//var Actor		SenderActor;// Actor that sent us the pawn in the first place. If this is
							// not None, then it means we require things sent to us 
							// from this link. Otherwise
var Actor		LastInLine;	// The last actor currently, validly in line.

var vector		StartLoc;	// Nearest to cashier. Includes fuzz distance from marker radii
var vector		EndLoc;		// Farthest from cashier. Includes fuzz distance from marker radii
var vector		LineDirection;	// direction from start loc to end loc
var vector		UseExtent;// Size inside with you consider people in this line
var vector		CounterFront;	// Front part of counter--as close as the customer can stand
//var	array<CashierController> MyOperators; // People who use me (supports delivery to multiple lines)
var int			CurrentOperatorI; // Index into MyOperators for the one I'm to use now.
var int			UsingMeAsStand;	// Index to the operator using me as a stand point
var PlayerController MyPlayer;		// Player we care about

///////////////////////////////////////////////////////////////////////////////
// CONSTS
const HUMAN_COLLISION_RADIUS=60;

///////////////////////////////////////////////////////////////////////////////
// Return the first player you find
///////////////////////////////////////////////////////////////////////////////
function PlayerController GetPlayer()
{
	local PlayerController pcont;

	foreach DynamicActors(class'PlayerController', pcont)
	{
		return pcont;
	}
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// Tell all the operators about this cutter
///////////////////////////////////////////////////////////////////////////////
function ReportCutter(FPSPawn Cutter)
{
	// STUB--handled in QStartPoint
}

///////////////////////////////////////////////////////////////////////////////
// The player has gone to the back of the line
///////////////////////////////////////////////////////////////////////////////
function ClearCutter(FPSPawn Cutter, optional bool bNoOneInLine)
{
	// STUB--handled in QStartPoint
}

///////////////////////////////////////////////////////////////////////////////
// Map this point to the line, so return another point, but it's the original
// point projected onto the line
///////////////////////////////////////////////////////////////////////////////
function vector ProjectPointOntoQLine(vector PPoint)
{
	local vector v1, v2;
	local vector keeppoint, usedir;
	local float dotcheck1, dotcheck2;

	v1 = PPoint - StartLoc;
	v2 = PPoint - EndLoc;
	usedir = LineDirection;

	dotcheck1 = (usedir dot v1);

	dotcheck2 = (usedir dot v2);

	//log(self$" hit v1="$v1$", v2="$v2$", dot1="$dotcheck1$", dot2="$dotcheck2$" people count "$CurrentUserNum);
	// We're way behind the line, or way before it, 
	// so default to picking the end to walk to.
	if(dotcheck2 > 0
		|| dotcheck1 < 0)
	{
		//log(self$" loc "$Location$" dist to start "$VSize(PPoint - StartLoc)$" dist to loc "$VSize(PPoint - Location)); 
		// If there's people in line and it's not active, walk to the back end.
		if(CurrentUserNum > 0
			&& !bActive)
			return EndLoc;
		else	// Otherwise, default to the front, if you're not in 
			return StartLoc;
	}

	// Otherwise, with dot1 > 0 and dot2 < 0 we're somewhere in the middle
	// of the line, so pick the appropriate place to walk to.
	keeppoint = usedir*dotcheck1 + StartLoc;

	//log("new point along line "$keeppoint);

	return keeppoint;
}

///////////////////////////////////////////////////////////////////////////////
// Return the start point
///////////////////////////////////////////////////////////////////////////////
function KeyPoint GetEnterPoint()
{
	return EndMarker;
}

///////////////////////////////////////////////////////////////////////////////
// By looking from the back to the front, determine the last person validly in
// line
// The trace is backwards here (End to Start) because the q goes from the
// qpoint to the qpathpoint, and we want to check from the back end forward.
///////////////////////////////////////////////////////////////////////////////
function Actor FindLastInLine(Actor Other)
{
	local vector HitLocation, HitNormal;
	local P2Pawn HitActor;
	local P2Pawn CheckA;

	// start at the back and move forward to the front (backwards from normal)
	foreach TraceActors( class 'P2Pawn', HitActor, HitLocation, HitNormal, StartLoc, EndLoc, UseExtent)
	{
		// There is someone validly in line.
		//if(HitActor.ClassIsChildOf(HitActor.class, ConcernedBaseClass))
		if(HitActor != None
			&& HitActor != Other)
		{
			CheckA = HitActor;
			// we just need the first one
			break;
		}
	}
	return CheckA;
}

///////////////////////////////////////////////////////////////////////////////
// Look just from me forward and determine who I should try to get behind.
// Project my position onto the line and check from their forward, to the
// start of the line.
// The trace is backwards here (End to Start) because the q goes from the
// qpoint to the qpathpoint, and we want to check from the back end forward.
///////////////////////////////////////////////////////////////////////////////
function FindNextBeforeMe(Actor Other, out Actor CheckA, out vector lastpoint)
{
	local vector HitLocation, HitNormal;
	local P2Pawn HitActor;
	local vector useend;

	useend = ProjectPointOntoQLine(Other.Location);

	// start at the back and move forward to the front (backwards from normal)
	foreach TraceActors( class 'P2Pawn', HitActor, HitLocation, HitNormal, StartLoc, useend, UseExtent)
	{
		// There is someone validly in line.
		//if(HitActor.ClassIsChildOf(HitActor.class, ConcernedBaseClass))
		if(HitActor != None
			&& HitActor != Other)
		{
			CheckA = HitActor;
			lastpoint = CheckA.Location;
			// we just need the first one
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the point on the end where you are to enter the queue behind the
// last person in line--if there is one so this is a dymnamic location
///////////////////////////////////////////////////////////////////////////////
function vector GetEndEntryPoint(LambController lambc, Actor Other)
{
	local vector lastpoint;//, dir;
	local float userad;
	local Actor LastBeforeMe;
	local PersonController perc;

	//FindNextBeforeMe(Other, LastBeforeMe, lastpoint);
	LastBeforeMe = FindLastInLine(Other);
	//log(self$" GetEndEntryPoint after FindLastInLine "$Other);

	if(LastBeforeMe != None)
	{
		//log(Other$" you're the one before me "$LastBeforeMe$" at "$LastBeforeMe.Location);
		lastpoint = ProjectPointOntoQLine(LastBeforeMe.Location);

		if(lambc != None)
			userad = lambc.PersonalSpace;
		else
			userad = (3*LastBeforeMe.CollisionRadius);

		perc = PersonController(lambc);
		// Randomly cut, or if you already are trying to cut, return his cutting position
		if(bActive
			&& (Frand() < CutterFrequency
				|| (perc != None
					&& perc.QLineStatus == perc.EQLineStatus.EQ_Cutting)))
		{
			// Try to butt your way right up to the front of the line
			lastpoint = Location
					+ userad*LineDirection;
			if(perc != None)
				perc.QLineStatus=perc.EQLineStatus.EQ_Cutting;
			//log(self$" this guy is trying to cut! "$perc$" pawn: "$perc.Pawn);
		}
		else
		{
			// Get in line like normal (at the end of the line)
			// Add some fuzz to the back end of this
			lastpoint = lastpoint
					+ userad*LineDirection;
		}
	}
	else
		lastpoint = ProjectPointOntoQLine(Other.Location);
	//log(Other$" entry point "$lastpoint);

	return lastpoint;
}

///////////////////////////////////////////////////////////////////////////////
// Are there any valid operators?
///////////////////////////////////////////////////////////////////////////////
function bool ValidOperators()
{
	/*
	local int i;
	local bool bValid;

	while(i < MyOperators.Length)
	{
		if(MyOperators[i].IsInState('WaitForCustomers'))
		{
			bValid=true;
			break;
		}
		i++;
	}

	return bValid;
	*/
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Pick out a random cashier from the list
///////////////////////////////////////////////////////////////////////////////
function Actor PickRandomOperator()
{
	// STUB
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// Ask queue where I should head to/what should I do now that I want to get in line
///////////////////////////////////////////////////////////////////////////////
function PrepForEntry(LambController lambc, Actor Other)
{
	local vector lastpoint;
	local Actor LastOne;

	lastpoint = GetEndEntryPoint(lambc, Other);

	// Setup last person in line
	lambc.SetLastInLine(Pawn(LastInLine));
	//lambc.InterestPawn2 = lambc.InterestPawn;
	// Set new destination
	if(EndMarker != None)
		lambc.SetEndPoint(lastpoint, EndMarker.CollisionRadius);
	else
		lambc.SetEndPoint(Location, CollisionRadius);

	// Set up next state
	if(lambc.IsInState('LegMotionToTarget'))
		lambc.bPreserveMotionValues=true;

	lambc.SetNextState('EnterQPoint');
}

///////////////////////////////////////////////////////////////////////////////
// Begin monitoring
///////////////////////////////////////////////////////////////////////////////
function StartMonitoring()
{
	GotoState('MonitorLine');
}

///////////////////////////////////////////////////////////////////////////////
// Try for the next non-busy operator
///////////////////////////////////////////////////////////////////////////////
function FindNextOperator()
{
//	CurrentOperatorI++;
//	if(CurrentOperatorI == MyOperators.Length)

		CurrentOperatorI=0;

	//log("my next operator to use is "$CurrentOperatorI);
}

///////////////////////////////////////////////////////////////////////////////
// Allows no direct contact with it. Must have things send actors to it.
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Aim from me to the cash register and hopefully find the closest point to it
// If we have a customer stand point, use that as our counter front.
///////////////////////////////////////////////////////////////////////////////
function FindCounterFront(vector CashRegPoint, KeyPoint CustomerStandPoint)
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, end1;

	if(CustomerStandPoint != None)
	{
		CounterFront = CustomerStandPoint.Location;
	}
	else
	{
		// Find where the counter starts in this line

		// We now have where the cash register is.. form a line from the start
		// to where the cash register is, but don't go any further than the
		// perimeter of the qpoint, in the direction of the cash register.
		end1 = CollisionRadius*Normal(CashRegPoint - StartLoc) + StartLoc;

	//	end1.z -= CollisionHeight;
	//	end1.x = end1.x - (CollisionRadius*LineDirection.x);
	//	end1.y = end1.y - (CollisionRadius*LineDirection.y);
		HitActor = Trace(HitLocation, HitNormal, end1, StartLoc, true);
		if(HitActor != None)
			CounterFront = HitLocation;
		else 
			CounterFront = end1;
		CounterFront.z = StartLoc.z;
	}
	//log(self$" FindCounterFront, location "$Location$" start "$StartLoc$" end "$end1);
	//log(self$" counter front "$CounterFront$", hit this: "$HitActor$" at "$HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Init things that require the game going first before we can depend on them
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Init
{
	function BeginState()
	{
		local Actor CheckA;

		Super.BeginState();

		//log("initting "$self);
		// link up the path for the queue
		UseTagToNearestActor(EndTag, CheckA, 1.0, false);
		EndMarker = QPathPoint(CheckA);
		if(EndMarker == None
			&& (EndTag != 'None'
			|| EndTag != ''))
			log(self$" ERROR: End Tag must be a q path point");

		//log(self$" end tag "$EndTag);
		//log(self$" end actor "$EndMarker);

		// Determine start and end locations. These include a radius so 
		// that when someone walks there and they stop a little ways again
		// we notice this also, and account for it. In case someone is a little
		// off the end of the line.
		StartLoc = Location;
		if(EndMarker != None)
			EndLoc = EndMarker.Location;
		else
			EndLoc = Location;

		LineDirection = Normal(EndLoc - StartLoc);

		// push these out from the center
//		StartLoc -= HUMAN_COLLISION_RADIUS*LineDirection;
//		EndLoc += HUMAN_COLLISION_RADIUS*LineDirection;

		//log("start "$StartLoc$" to end "$EndLoc);
/*
		// Now that we have the line along which we'll check for customers, 
		// let's examine the line and see if it's valid at all. If not, report an error
		// so the LD's no something's wrong
		foreach TraceActors( class 'Actor', CheckA, HitLocation, HitNormal, EndLoc, StartLoc, UseExtent)
		{
			if(CheckA.bStatic)
				log(self$" ERROR: line along which to check for customers is hitting something solid: "$CheckA$" at location "$HitLocation$" and normal "$HitNormal);
		}
		log(self$" after trace actors ");
*/
	}

Begin:
	GotoState('AwaitLinks');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Point out that if we are using the queue as our standing point
// then we can't have multiple cashiers
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AwaitLinks
{
	///////////////////////////////////////////////////////////////////////////////
	// Make sure the cashiers are using unique standing points for their customers
	///////////////////////////////////////////////////////////////////////////////
	function CheckForSameStandPoints()
	{
	}
Begin:
	Sleep(0.5);

	CheckForSameStandPoints();

	GotoState('MonitorLine');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// MonitorLine
// Look every once in a while for people out of line and all, and tell them
// to move forward. Do the tracing here, so each person in the line doesn't
// need to do it.
//
// This is always used but it updates more infrequently if no one is in the
// line than if there are people in line. 
// The reason we don't just turn this on and off based on if people have
// requested to use the line becuase they can get moved out of the line by the
// player (by various methods) and the cashier may not notice all this and
// go ahead like normal. So basically if it doesn't find anyone in the line
// on its trace, it decreases the update frequency but as soon it notices someone
// or if someone is in line, then it updates more often.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state MonitorLine
{
	ignores StartMonitoring;

	///////////////////////////////////////////////////////////////////////////////
	// Go down the line from the start (near the cashier) to the end, 
	// and look to pull up stragglers
	// Also count the number of people in it currently.
	///////////////////////////////////////////////////////////////////////////////
	function CheckLineForGaps()
	{
		// STUB
	}

	///////////////////////////////////////////////////////////////////////////////
	// Tell cashier to get off her butt, if somone is using me
	///////////////////////////////////////////////////////////////////////////////
	function Touch(Actor Other)
	{
	}

	///////////////////////////////////////////////////////////////////////////////
	// Count up how many are first in the line
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local vector HitLocation, HitNormal;
		local P2Pawn HitActor;

		CurrentUserNum=0;
		foreach TraceActors( class 'P2Pawn', HitActor, HitLocation, HitNormal, EndLoc, StartLoc, UseExtent)
		{
			//log(self$" checking "$HitActor);
			if(HitActor != None
				&& HitActor.Health > 0)
				CurrentUserNum++;
		}
		//log(self$" currentusernum "$CurrentUserNum);
	}

Begin:
	CheckLineForGaps();

	Sleep(UpdateTime);

	Goto('Begin');
}

defaultproperties
{
	MaxAllowed=9
	UpdateTime=2.0
	UseExtent=(X=60,Y=60,Z=60)
    bCollideActors=True
    bCollideWorld=False
    bBlockActors=False
    bBlockPlayers=False
	CollisionRadius=90
	CollisionHeight=70
	UsingMeAsStand=-1
	DistToActive=2048
	CutterFrequency=0.3
	Texture=Texture'PostEd.Icons_256.QPoint'
	DrawScale=0.25
}
