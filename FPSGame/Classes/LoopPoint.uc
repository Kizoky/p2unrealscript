///////////////////////////////////////////////////////////////////////////////
// LoopPoint
//
// Use it to make loops for parades and protestors
///////////////////////////////////////////////////////////////////////////////
class LoopPoint extends KeyPoint;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
// External variables
var ()Name	NextPointTag;		// Tag for the next point in this line
var ()float WalkToReductionPct;	// Percentage of the pawn's normal speed used when
								// walking *toward* this point.
								// This determines how much slower we will walk as we move towards this point
								// It should be 1.0 on straight aways, and less for the group that's tighest
								// in a turn. 

// Internal variables
var LoopPoint NextPoint;		// Actual next loop point


///////////////////////////////////////////////////////////////////////////////
auto state Init
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Actor FindByTag(Name thistag)
	{
		local Actor CheckA;

		ForEach AllActors(class'Actor', CheckA, thistag)
		{
			return CheckA;
		}
		return None;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find actor link to next point
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		NextPoint = LoopPoint(FindByTag(NextPointTag));
		if(NextPoint == None)
			warn(self$" ERROR: loop point tag not found "$NextPointTag);

		//log(Tag$" tag,  next point tag: "$NextPoint.Tag);
	}

Begin:
	bStasis=true;
	GotoState('');
}

defaultproperties
{
	WalkToReductionPct=1.0
	CollisionHeight = 100
	CollisionRadius = 100
	Texture=Texture'PostEd.Icons_256.LoopPoint'
	DrawScale=0.25
}
