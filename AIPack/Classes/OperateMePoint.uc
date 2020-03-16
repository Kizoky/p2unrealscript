///////////////////////////////////////////////////////////////////////////////
// A point used to mark things pawns can operate (ex: cash register)
///////////////////////////////////////////////////////////////////////////////
class OperateMePoint extends KeyPoint
	hidecategories(Force,Karma,LightColor,Lighting,Shadow,Sound);

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
// External variables
var()export editinline array<Name>	OperatorTagList;// list of tags for who runs me
var() Name	InputTag;				// tag for operator to have input thing with


// Internal variables
var Actor MyOperator;				// who is currently running me
var Actor MyInput;					// operator might use this to do stuff with
var int   OperatorIndex;			// index into OperatorTagList for MyOperator

///////////////////////////////////////////////////////////////////////////////
// Match this tag to its actor
///////////////////////////////////////////////////////////////////////////////
function UseTagToNearestActor(Name UseTag, out Actor UseActor, float randval, 
							  optional bool bDoRand, optional bool bSearchPawns)
{
	local Actor CheckA, LastValid;
	local float dist, keepdist;
	local class<Actor> useclass;

	if(UseTag != 'None')
	{
		dist = 65535;
		keepdist = dist;
		UseActor = None;
		
		if(bSearchPawns)
			useclass = class'FPSPawn';
		else
			useclass = class'Actor';

		//log(self$" use class "$useclass);
		ForEach AllActors(useclass, CheckA, UseTag)
		{
			// don't allow it to pick you, even if your tag is valid
			if(CheckA != self
				&& !CheckA.bDeleteMe)
			{
				LastValid = CheckA;
				//log("checking "$CheckA);
				dist = VSize(CheckA.Location - Location);
				if(dist < keepdist
					&& (!bDoRand ||	FRand() <= randval))
				{
					keepdist = dist;
					UseActor = CheckA;
				}
			}
		}

		if(UseActor == None)
			UseActor = LastValid;

		if(UseActor == None)
			log("ERROR: could not match with tag "$UseTag);
		//else
		//log(self$" linking to nearest "$UseActor$" at "$keepdist$" with tag "$UseActor.Tag);
	}
	else
		UseActor = None;	// just to make sure
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function int GetNextOperatorIndex()
{
	local int i;

	i = OperatorIndex;

	i++;

	if(i >= OperatorTagList.Length)
		i = 0;

	return i;
}


defaultproperties
{
     bStatic=False
	 CollisionRadius=20
	 CollisionHeight=128
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
 	 bBlockZeroExtentTraces=False
 	 bBlockNonZeroExtentTraces=False
}
