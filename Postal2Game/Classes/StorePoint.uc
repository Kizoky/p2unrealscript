///////////////////////////////////////////////////////////////////////////////
// Interest point that can link to multiple actors with the same tag
///////////////////////////////////////////////////////////////////////////////
class StorePoint extends InterestPoint;

/*


delete array ? 


  force link specify tag
  zoning?






*/
///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
// External variables

var() int MaxLinkActors;
var() int MaxInterestActors;

// Internal variables
struct LinkActorInfo
{
	var Actor LinkActor;
	var float dist;			// Possibly use this for tests to make it more desirable to pick,
							// instead of just having it random
};

var array<LinkActorInfo>	LinkActorList;	// List of possible walk actors all matching the LinkToTag
var array<LinkActorInfo>	InterestActorList;	// List of possible interest actors all matching the InterestTag

///////////////////////////////////////////////////////////////////////////////
// match this tag to its actor
///////////////////////////////////////////////////////////////////////////////
function BuildActorList(out array<LinkActorInfo> CheckList, 
						out Actor InitMe, 
						name UseTag, int MaxActors)
{
	local Actor CheckA;
	local float dist;
	local int i;

	//log("Building actor list "$UseTag);
	if(UseTag != 'None')
	{
		i = 0;

		ForEach AllActors(class'Actor', CheckA, UseTag)
		{
			// don't allow it to pick you, even if your tag is valid
			if(CheckA != self
				&& !CheckA.bDeleteMe)
			{
				if(i < MaxActors)
				{
					dist = VSize(CheckA.Location - Location);

					//log("adding to actor list "$CheckA$" with tag "$CheckA.Tag);
					//log("at this distance "$dist);

					CheckList.Insert(i, 1);
					CheckList[i].LinkActor = CheckA;
					CheckList[i].dist = dist;
					i++;
				}
				else
				{
					log(self$" ERROR: StorePoint: Tried to add too many actors to list");
					break;
				}
			}
		}

		if(i == 0)
			log(self$" ERROR: could not match with tag "$UseTag);

		if(CheckList.Length > 0)
			InitMe = CheckList[0].LinkActor;
	}
	else
		LinkToActor = None;	// just to make sure
	//log("length "$CheckList.Length);
}

///////////////////////////////////////////////////////////////////////////////
// We need to find this dynamically, so figure it out here
///////////////////////////////////////////////////////////////////////////////
function Actor GetActorFromList(PersonController Personc, out array<LinkActorInfo> CheckList)
{
	local int pickIndex, startIndex, count;
	local InterestPoint checkp;
	local bool bChoiceValid;

	// Randomly pick one of the actors out of the walk actor list
	startIndex=Rand(CheckList.Length);
	pickIndex=startIndex;
	count=0;
	// Check to see if we'll be allowed at that one, if it's an interest point
	if(Personc != None)
	{
		while(!bChoiceValid
			&& count < CheckList.Length)
		{
			// If it's an interest point, then it could fail, so we
			// want to check and see, first
			checkp = InterestPoint(CheckList[pickIndex].LinkActor);
			if(checkp != None)
			{
				if(!checkp.CheckToAllow(Personc.MyPawn, Personc.MyPawn, Personc))
				{
					// move along and check the next one
					pickIndex++;
					if(pickIndex >= CheckList.Length)
						pickIndex=0;
				}
				else
					bChoiceValid=true;
			}
			else	// if not an interest point, then it's always valid
				bChoiceValid=true;
			count++;
		}
	}

	if(bChoiceValid)
		return CheckList[pickIndex].LinkActor;
	else 
		return None;
}

///////////////////////////////////////////////////////////////////////////////
// If we need to dynamically find the walk actor, do it here
// otherwise, it's done in the PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function Actor FindLinkActor(PersonController Personc)
{
	return GetActorFromList(Personc, LinkActorList);
}

///////////////////////////////////////////////////////////////////////////////
// If we need to dynamically find the interest actor, do it here
// otherwise, it's done in the PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function Actor FindInterestActor(PersonController Personc)
{
	return GetActorFromList(Personc, InterestActorList);
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
		log("store point instance-------------: "$self);

		// Idito checks
		if(WaitTimeMin > WaitTimeMax)
			log(self$"ERROR: wait time min is greater than the max");

		//UseTagToNearestActor(InterestTag, MyInterest, 1.0, false);
//		BuildActorList(InterestActorList, LinkToActor, InterestTag, MaxInterestActors);
//		BuildActorList(LinkActorList, MyInterest, LinkToTag, MaxLinkActors);
		BuildActorList(InterestActorList, MyInterest, InterestTag, MaxInterestActors);
		BuildActorList(LinkActorList, LinkToActor, LinkToTag, MaxLinkActors);

		log("my tag "$Tag);
		log("concerned classes name "$ConcernedClasses.Name);
		log("interest tag "$InterestTag);
		log("interest actor "$MyInterest);
		log("walk tag "$LinkToTag);
		log("link actor "$LinktoActor);
	}
Begin:
	GotoState('');
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.StorePoint'
	MaxAllowed=12
	MaxLinkActors=16
	MaxInterestActors=4
	DrawScale=0.25
}
