///////////////////////////////////////////////////////////////////////////////
// Marks the start of things like possible business interest or sign to 
// look at or chair to sit in.
///////////////////////////////////////////////////////////////////////////////
class InterestPoint extends Keypoint
	hidecategories(Force,Karma,LightColor,Lighting,Shadow,Sound);

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
struct IBoltOn
	{
	var() Name bone;								// Name of bone to attach to
	var() Mesh mesh;								// Mesh to use
	var() StaticMesh staticmesh;					// Static mesh to use
	var() Material skin;								// Skin to use (leave blank to use default skin)
	var() bool bAttachToHead;						// Whether or not this attaches to the head or the body
	var() float DrawScale;
	};
// External variables

// What you can do at the interest points
// WARNING: Make sure you add new types to the end, so you don't screw the
// previously made levels. These are just numbers ya now and we'll be saved
// as such. No magic to move them along if you add a new type in the middle of
// the list one day.
var() enum EActionType
{
	IDT_StopAndWait,	// Just stare in the direction you already were
						// staring for the given amount of time, before
						// head to your next or return to thinking(if no next)
	IDT_LookAt,			// Just stare at the interest the given amount of time, before
						// head to your next or return to thinking(if no next)
	IDT_Laugh,			// laugh at the interest actor
	IDT_Clap,			// clap at the interest actor
	IDT_Smoke,			// find a spot and start smoking
	IDT_AccostInterest,	// Person who touches the interest point yells at the interest
	IDT_InterestAccostsYou,	// Your interest yell at person who touches the interest point
	IDT_Puke,			// puke at your interest actor
	IDT_Dance,			// Dance in this spot and face a random direction
	IDT_PlayArcadeGame,	// Play an arcade game that is your interest actor
	IDT_KeyboardType,	// Type at the point that is your interest actor
	IDT_PlayGuitar,		// Plays guitar
	IDT_Piss,			// Take a piss
	IDT_Custom,			// Perform custom animation action
}ActionType;			// What actors do when they hit this point

// What we want to do with our link types.
// Link Actors are only used AFTER we're done with our current interest
var() enum ELinkType
{
	LT_WalkTo,			// We'll walk to our link
	LT_RunTo,			// We'll run to our link
	LT_WalkToIgnoreIPs,	// We'll walk to our link but not use it
	LT_RunToIgnoreIPs,	// We'll walk to our link but not use it
	LT_ForceUse,		// We'll stay where we are and use the link now
}LinkType;				// What we do with the LinkActor

var	()Name	InterestTag;	// tag of interest actor (used to find/link up to MyInterest)
var	()Name	LinkToTag;		// Tag of the actor you will walk to when this interest is over
var ()class	ConcernedClasses;// Actor class we're concerned about. This is used to restrict
							// or allow pawns of this type when they touch this point.
var ()class ConcernedBaseClass;	// Below this nothing is even considered allowed to use this point
var ()bool	bExcludes;		// Defaults to false, so it allows only the type of pawns in ConcernedPawns
							// If true, then it excludes only ConcernedPawns and allows all others.
var ()bool	bAllowConsecutiveReturns;	// Doesn't matter if the same actor hits this several times in a row
var ()int	MaxAllowed;		// Maximum number of actors simultaneously allowed to use this point.
var ()int	WaitTimeMax;	// Maximum time to sleep before you do the next action
var ()int	WaitTimeMin;	// Minimum time to sleep before you do the next action
var ()float	InterestLevel;	// (1-0) how interesting this thing is
var ()int	TotalUsersLimit;// How many successful users we can have till this is destroyed. 
							// 0 means an infinite number (default).
var() name	GuitarMusicTag;	// Tag of guitar music to trigger
var() name	StandHereTag;	// Tag of place to stand or sit while performing interest, if any. We cheat by warping them here, so make sure the target actor won't block them.					
var/*()*/  vector StandHereOffset;	// Offset from StandHereTag to teleport to
var() IBoltOn Bolton;		// Bolton assigned to pawn while performing interest
var/*()*/ deprecated name	CustomAnim;		// Name of custom anim to play (IDT_Custom)
var() export editinline CustomAnimAction	CustomAnims;	// Sequence of custom anims to play (IDT_Custom)

//var ()class GiftClass;	// What's given to the actor that hits this (usually) a bolt-on

// Internal variables
var int CurrentUserNum;		// How many actors are currently 'using' this point
var int	TotalUsers;			// How many actors have ever used this successfully
var Actor	MyInterest;		// Actor that this point concerns. Linked after startup
var Actor	LinkToActor;	// Next actor you will walk to (works best if this is also an interest point)
var bool	bActive;		// If it's on or not
var array<Actor> UserList;	// Who's currently using it

///////////////////////////////////////////////////////////////////////////////
// Turn it on or off
// Off won't allow things to instigate new actions (though pending actions can finish)
///////////////////////////////////////////////////////////////////////////////
function SetActive(bool bNewActive)
{
	if(bNewActive != bActive)
	{
		if(bNewActive == false)
		{
			// Invalidate us.
			// Don't destroy us, or some people linking to us
			// (Persons link to us with the check us state)
			// will have a hard time
			// So we remove ourselves from the collision system
			SetCollision(false, false, false);
		}
		else
		{
			//log(self$" was Off in this state: "$GetStateName()$" now turning On ");
			SetCollision(true);
		}
		bActive=bNewActive;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Toggle the active state
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	SetActive(!bActive);
}

///////////////////////////////////////////////////////////////////////////////
// match this tag to its actor
///////////////////////////////////////////////////////////////////////////////
function UseTagToActor(Name UseTag, out Actor UseActor)
{
	local Actor CheckA;

	if(UseTag != 'None')
	{
		UseActor = None;

		ForEach AllActors(class'Actor', CheckA, UseTag)
		{
			if(!CheckA.bDeleteMe)
			{
				UseActor = CheckA;
				break;
			}
		}
		if(UseActor == None)
			log(self@"ERROR: could not match with tag "$UseTag);
		if(UseActor == self)
		{
			log(self@"ERROR: can't link to self");
			// wipe it
			UseActor = None;
		}
	}
	else
		UseActor = None;	// just to make sure
}

///////////////////////////////////////////////////////////////////////////////
// match this tag to its actor
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
			log(self@"ERROR: could not match with tag "$UseTag);
		//else
		//	log(self$" linking to nearest "$UseActor$" at "$keepdist$" with tag "$UseActor.Tag);
	}
	else
		UseActor = None;	// just to make sure
}

///////////////////////////////////////////////////////////////////////////////
// Get the wait time, may be a range
///////////////////////////////////////////////////////////////////////////////
function float GetWaitTime()
{
	local float usetime;

	usetime = (FRand()*(WaitTimeMax - WaitTimeMin) + WaitTimeMin);

	return usetime;
}

///////////////////////////////////////////////////////////////////////////////
// Check various things (like it's class) to see if it's even allowed to use this
///////////////////////////////////////////////////////////////////////////////
function bool CheckToAllow(Actor Other, P2Pawn thispawn, PersonController Personc)
{
	/*
	// Don't allow use of another point while you're using this one
	if(Personc.CurrentInterestPoint != None)
	{
		log("Already using "$Personc.CurrentInterestPoint);
		return false;
	}
*/
	// If there's too many using it already, make them leave early/not even try
	//log("current num "$CurrentUserNum$", max allowed "$MaxAllowed);
	if(CurrentUserNum >= MaxAllowed)
	{
		//log("Too many users");
		return false;
	}
	
	// If we're holding a briefcase or shopping bag, don't wait in line -- anims look weird
	if (P2MoCapPawn(ThisPawn) != None
		&& P2MoCapPawn(ThisPawn).bNoExtendedAnims)
		return false;

	// If we're currently in a line, don't allow usage of other interest points
	if(Personc != None
		&& QPoint(Personc.CurrentInterestPoint) != None)
	{
		//log("I'm in a line right now "$Personc.CurrentInterestPoint);
		return false;
	}

	// If we don't want it to constantly come back, then check to see if we
	// just came back
	if(!bAllowConsecutiveReturns
		&& Personc != None)
	{
		if(Personc.LastInterestPoint == self)
		{
			//log("No consecutive returns, "$Personc.LastInterestPoint$" was the same as self");
			return false;
		}
		if (VisitedThisPoint(Personc))
		{
			//log("No consecutive returns, "$Personc$" has us in their visited array");
			return false;
		}
	}
/*
	// Don't allow players (at least not yet)
	if(thispawn != None
		&& PlayerController(thispawn.Controller) != None)
	{
		log("Was the player ");
		return false;
	}
*/
	// We *exclude* the group of concerned classes
	// and this one is of that type
	if(!Other.ClassIsChildOf(Other.class, ConcernedBaseClass))
	{
		//log("Before base class, sorry!");
		return false;
	}
	// Check to see who's allowed to use this
	if(!bExcludes)
	{
		// We allow the group of Concerned classes (default)
		// and this one is not of that type
		if(!Other.ClassIsChildOf(Other.class, ConcernedClasses))
		{
			//log("Specifically exluded class ");
			return false;
		}
	}
	else
	{
		// We *exclude* the group of concerned classes
		// and this one is of that type
		if(Other.ClassIsChildOf(Other.class, ConcernedClasses))
		{
			//log("Specifically exluded class ");
			return false;
		}
	}
	
	// Check to see who can take a leak
	if (ActionType == IDT_Piss
		&& P2MocapPawn(ThisPawn).MyGender == Gender_Female)
	{
		// I'm a girl, so I don't piss standing up
		return false;
	}
	
	// Cigarette smokers can't smoke twice
	if (ActionType == IDT_Smoke
		&& P2MoCapPawn(ThisPawn).HoldingCigarette == 1)
		return false;

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Check to see if this grabs our interest
///////////////////////////////////////////////////////////////////////////////
function bool CheckInterested(Actor Other)
{
	if(FRand() <= InterestLevel)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// If we need to dynamically find the walk actor, do it here
// otherwise, it's done in the PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function Actor FindLinkActor(PersonController Personc)
{
	return LinkToActor;
}

///////////////////////////////////////////////////////////////////////////////
// If we need to dynamically find the interest actor, do it here
// otherwise, it's done in the PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function Actor FindInterestActor(PersonController Personc)
{
	return MyInterest;
}

///////////////////////////////////////////////////////////////////////////////
// Prep the Person controller to come back here for it's next state
///////////////////////////////////////////////////////////////////////////////
function SetupPersonReturnState(PersonController Personc)
{
	if(Personc.IsInState('LegMotionToTarget'))
		Personc.bPreserveMotionValues=true;

	if(LinkToActor != None)
	{
		Personc.SetNextState('CheckInterestForCommand');
	}
	else
		Personc.SetNextState('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
// Called by a user of interest point to check the next one to see if he should
// go there or not. Most things want you to not use it, if it already has
// too many people.
///////////////////////////////////////////////////////////////////////////////
function bool LinkNewUserHere()
{
	return (CurrentUserNum < MaxAllowed
			&& bActive);
}

///////////////////////////////////////////////////////////////////////////////
// Set this actor's next action
// The actor has finished the primary point of this interest point (even if it
// was nothing) now he's ready to move on
// This is a required callback--it unhooks this point from Other
///////////////////////////////////////////////////////////////////////////////
function SetActorsNextAction(Actor Other)
{
	local P2Pawn p2p;
	local PersonController Personc;
	local InterestPoint nextpoint;
	local QPoint CheckQ;
	local Actor NextA;
	local bool bAllowNextUse;

	p2p = P2Pawn(Other);
	Personc = PersonController(p2p.Controller);

	//log("back in interest, checking to walk");

	LinkToActor = FindLinkActor(Personc);
	//log("found this link "$LinkToActor);

	if(Personc != None)
	{
		// Save what we just did
		if(Personc.CurrentInterestPoint != None)
			Personc.LastInterestPoint = Personc.CurrentInterestPoint;

		// Check if it's an interest point, if not, allow a link anyway. If it
		// is an interest point, it's possible it could block you from going there
		nextpoint = InterestPoint(LinkToActor);
		if(nextpoint != None)
		{
			// Check to walk to the next one, if it's an interest point
			// and it has too many people already there, then don't go
			// just go back to thinking

			//log("next current num "$nextpoint.CurrentUserNum);
			//log("next max allowed "$nextpoint.MaxAllowed);

			if(!nextpoint.LinkNewUserHere())
			{
				//log(nextpoint$" has too many people, sent back to thinking");
				// blank what we're doing
				Personc.CurrentInterestPoint = None;
			}
			else
			{
				bAllowNextUse=true;
				// setup our next interest point
				Personc.CurrentInterestPoint = nextpoint;
			}
		}
		else if(LinkToActor != None)
		{
			// blank what we're doing
			Personc.CurrentInterestPoint = None;
			bAllowNextUse=true;
		}

		if(bAllowNextUse)
		{
			CheckQ = QPoint(LinkToActor);

			if(CheckQ != None)
			{
//				if(CheckQ.ValidOperators())
//				{
					// Point him to the entry point for the qpoint
					CheckQ.PrepForEntry(Personc, Other);
//				}
				/*
				else
				{
					log(self$" cashier dead or not there, thinking"$Personc);
					Personc.GotoStateSave('Thinking');
					return;
				}
				*/
			}
			else 
			{
				// Set new destination
				Personc.SetEndGoal(LinkToActor, LinkToActor.CollisionRadius);

				if(Personc.IsInState('LegMotionToTarget'))
					Personc.bPreserveMotionValues=true;

				Personc.SetNextState('Thinking');
			}

			switch(LinkType)
			{
				case LT_WalkTo:
					Personc.GotoStateSave('WalkToInterest');
					break;
				case LT_RunTo:
					Personc.GotoStateSave('RunToInterest');
					break;
				case LT_WalkToIgnoreIPs:
					Personc.GotoStateSave('WalkToTarget');
					break;
				case LT_RunToIgnoreIPs:
					Personc.GotoStateSave('RunToTarget');
					break;
				default:
					log(self$" ERROR: InterestPoint Link type not implemented-->Tried this one: "$LinkType);
			}
		}
		else
		{
			Personc.GotoStateSave('Thinking');
			return;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// This actor started a level and was commanded to go to this interest point
// It's really used for setting up people to immediately go to a queue.
// For use with PawnInitialStates.
// This should use GotoState/Save, it should only use SetMyNextState.
///////////////////////////////////////////////////////////////////////////////
function PrepStartupActorsToUseMe(Actor Other, ELinkType UseLinkType)
{
	local P2Pawn p2p;
	local PersonController Personc;

	p2p = P2Pawn(Other);
	Personc = PersonController(p2p.Controller);

	if(Personc != None)
	{
		// Save what we just did
		if(Personc.CurrentInterestPoint != None)
			Personc.LastInterestPoint = Personc.CurrentInterestPoint;

			Personc.CurrentInterestPoint = self;
			Personc.SetNextState('EnterQPointStatic');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Perform the various actions of interest
///////////////////////////////////////////////////////////////////////////////
function PerformActions(PersonController Personc, Actor Other)
{
	local byte AllowFlow;
	local Actor A;

	// First, determine our interest
	MyInterest = FindInterestActor(Personc);
	//log("found this interest "$MyInterest);
	
	// Custom anim: turn off static mesh collision before sitting the pawn down
	if (ActionType == IDT_Custom
		&& CustomAnims.CollidingStaticMeshTag != '')
	{
		foreach AllActors(class'Actor', A, CustomAnims.CollidingStaticMeshTag)
			A.Setcollision(False, False, False);
	}

	// Warp pawn to stand/sit tag if applicable
	if (StandHereTag != '')
	{
		foreach AllActors(class'Actor', A, StandHereTag)
			break;
		// Does not attempt to ignore collision. Make sure target actor will not block the pawn
		if (A != None)
		{
			log("attempting to move"@Personc.MyPawn@"from"@Personc.MyPawn.Location@"to"@A.Location);
			Personc.MyPawn.SetLocation(A.Location + StandHereOffset, true);
			log("location is now"@Personc.MyPawn.Location);
		}
	}
	// Can't use P2MocapPawn.Bolton directly for some reason, even though we could in BoltonDef... stupid compiler.
	Personc.MyPawn.TempBolton.bone = Bolton.bone;
	Personc.MyPawn.TempBolton.Mesh = Bolton.Mesh;
	Personc.MyPawn.TempBolton.StaticMesh = Bolton.StaticMesh;
	Personc.MyPawn.TempBolton.Skin = Bolton.Skin;
	Personc.MyPawn.TempBolton.bCanDrop = True;
	Personc.MyPawn.TempBolton.bAttachToHead = Bolton.bAttachToHead;
	Personc.MyPawn.TempBolton.DrawScale = Bolton.DrawScale;

	// Try to perform the action specified now that we're allowed to use this point
	switch(ActionType)
	{
/*		case IDT_RunTo:
		case IDT_LinkTo:
			if(Personc != None)
			{
				// We'll walk to our interest
				if(MyInterest == None)
					log("ERROR: No interest actor for "$self$"!!");

				log("move to "$MyInterest);
				Personc.SetEndGoal(MyInterest, MyInterest.CollisionRadius);
				if(Personc.IsInState('LegMotionToTarget'))
					Personc.bPreserveMotionValues=true;
				Personc.SetNextState('Thinking');
				if(ActionType == IDT_LinkTo)
					Personc.GotoStateSave('LinkToTarget');
				else
					Personc.GotoStateSave('RunToInterest');
			}
			break;
			*/
		case IDT_StopAndWait:
			if(Personc != None)
			{
				// We'll look at whatever we were already looking at
				// after wait time
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.GotoStateSave('StareAtSomething');
			}
			break;
		case IDT_LookAt:
			if(Personc != None)
			{
				// We'll look towards the interest dully and then get bored
				// after wait time
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.GotoStateSave('StareAtSomething');
			}
			break;
		case IDT_Laugh:
			if(Personc != None)
			{
				// We'll look towards the interest as specified and laugh
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				SetupPersonReturnState(Personc);
				Personc.GotoStateSave('LaughAtSomething');
			}
			break;
		case IDT_Clap:
			if(Personc != None)
			{
				// We'll look towards the interest as specified and laugh
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				SetupPersonReturnState(Personc);
				Personc.GotoStateSave('ClapAtSomething');
			}
			break;
		case IDT_Smoke:
			if(Personc != None)
			{
				// We'll look towards the interest as specified and smoke
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.GotoStateSave('SmokeHere');
			}
			break;
		case IDT_AccostInterest:
			if(Personc != None
				&& MyInterest != Personc.MyPawn)
				// Don't try to accost yourself
			{
				// Our interest accosts us in some fashion
				Personc.Focus = MyInterest;
				SetupPersonReturnState(Personc);
				Personc.GotoStateSave('AccostFocus');
			}
			break;
		case IDT_InterestAccostsYou:
			Personc = PersonController(Pawn(MyInterest).Controller);

			if(Personc != None
				&& Other != Personc.MyPawn)
				// Don't try to accost yourself
			{
				// He might be too busy to accost us, let's see
				AllowFlow=0;

				Personc.PerformInterestAction(self, AllowFlow);
				if(AllowFlow == 1)
				{
					// Nope! he was able to ablige us
					// Our interest accosts us in some fashion
					Personc.Focus = Other;
					SetupPersonReturnState(Personc);
					Personc.GotoStateSave('AccostFocus');
				}
			}
			break;
		case IDT_Puke:
			if(Personc != None)
			{
				// We'll look towards the interest as specified and throwup
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.GotoState('DoPukingInterestPoint');
			}
			break;
		case IDT_Dance:
			if(Personc != None)
			{
				// We'll look towards the interest as specified and dance some
				Personc.Focus = None;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.GotoStateSave('DanceHereInterestPoint');
			}
			break;
		case IDT_PlayArcadeGame:
			if(Personc != None)
			{
				// We'll look towards the interest as specified and play an arcade game some
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.GotoStateSave('PlayArcadeGameInterestPoint');
			}
			break;
		case IDT_KeyboardType:
			if(Personc != None)
			{
				// We'll look towards the interest as specified and play an arcade game some
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.GotoStateSave('KeyboardTypeInterestPoint');
			}
			break;
		case IDT_PlayGuitar:
			if (Personc != None)
			{
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.MyPawn.GuitarMusicTag = GuitarMusicTag;
				Personc.GotoStateSave('PlayGuitarInterest');
			}
			break;
		case IDT_Piss:
			if (PersonC != None)
			{
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.MyPawn.GuitarMusicTag = GuitarMusicTag;
				Personc.GotoStateSave('TakeALeak');
			}
			break;
		case IDT_Custom:
			if (Personc != None)
			{
				Personc.Focus = MyInterest;
				Personc.InterestPawn = None;
				Personc.Attacker = None;
				Personc.CurrentFloat = GetWaitTime();
				SetupPersonReturnState(Personc);
				Personc.MyPawn.GuitarMusicTag = GuitarMusicTag;
				//Personc.MyPawn.CustomAnimLoop = CustomAnim;
				Personc.MyPawn.CopyAnimActionFrom(CustomAnims);
				Personc.GotoStateSave('PlayCustomInterest');
			}
			break;
		default:
			log(self@"ERROR: InterestPoint Action type not implemented");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Other activated this interest point.
// This is the entry function for interest points
///////////////////////////////////////////////////////////////////////////////
function UseThis(Actor Other)
{
	local P2Pawn thispawn;
	local PersonController Personc;
	local byte AllowFlow;
	local int i;

	// prep some local variables
	thispawn = P2Pawn(Other);
	if(thispawn != None)
	{
		Personc = PersonController(thispawn.Controller);
	}
	// see if this actor will use this point
	if(!CheckToAllow(Other, thispawn, Personc))
	{
		//log("REJECTED: "$Other);
		return;
	}

	if(!CheckInterested(Other))
	{
		//log("NO THANKS!: "$Other);
		return;
	}

	// go ahead and try to get a p2pawn out of it
	if(Personc != None)
	{
		// Force the pawn to say YES to allowing this. If he
		// doesn't we know he's preoccupied.
		AllowFlow=0;

		Personc.PerformInterestAction(self, AllowFlow);

		if(AllowFlow == 0)
		{
			//log(thispawn$" didn't perform this action "$ActionType$" for this point "$self);
			return;
		}

		// Save last one
		if(Personc.CurrentInterestPoint != None)
			Personc.LastInterestPoint = Personc.CurrentInterestPoint;
		// Add to list
		AddToVisited(Personc);
		// Assign this interest point to it
		// By setting this, the user num knows to be incremented
		Personc.CurrentInterestPoint = self;
		// He's going to use this, so count him
		CurrentUserNum++;
		//log("user list length "$UserList.Length);
		i = UserList.Length;
		UserList.Insert(i, 1);
		UserList[i] = Other;
		//log("adding "$Other$", num now "$CurrentUserNum);
		
		//log("Info: type "$ActionType$", my interest "$MyInterest$", walk to target "$LinkToActor);

		PerformActions(Personc, Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Something has activated me
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	UseThis(Other);
}

///////////////////////////////////////////////////////////////////////////////
// Remove from user list
///////////////////////////////////////////////////////////////////////////////
function bool RemoveActor(Actor Other)
{
	local int i;

	i=0;
	while(i<UserList.Length && UserList[i] != Other)
	{
		//log("checking "$UserList[i]);
		i++;
	}

	if(i<UserList.Length)
	{
		UserList.Remove(i, 1);
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// If we recorded a thing successfully using us, then we need to release it
///////////////////////////////////////////////////////////////////////////////
function UnTouch(Actor Other)
{
	local P2Pawn thispawn;
	local PersonController Personc;
	local bool bRemovedIt;

	//log(self$" was UNtouched by "$Other);

	// Find the actor and delete it, and continue if it was there
	bRemovedIt = RemoveActor(Other);
	//log("user list length "$UserList.Length);

	thispawn = P2Pawn(Other);
	if(thispawn != None
		&& bRemovedIt)
	{
		Personc = PersonController(thispawn.Controller);
		if(Personc != None)
		{
			// Unhook this one
//			if(Personc.CurrentInterestPoint == self)
//				Personc.CurrentInterestPoint = None;

			// Note that this actor has left and is not using us any more
			CurrentUserNum--;
			//log("releasing "$Other$", num now "$CurrentUserNum);
			// Record this as a completed user
			TotalUsers++;
			//log("total users now: "$TotalUsers);

			// Check to remove this interest point, if it's been 'used up'
			if(TotalUsersLimit > 0
				&& TotalUsers == TotalUsersLimit)
			{
				//log("Total user limit hit "$TotalUsersLimit$" destroying this "$self);
				// We've hit our limit, turn us off
				SetActive(false);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if we're in the list of interest points this person has
// visited before.
///////////////////////////////////////////////////////////////////////////////
function bool VisitedThisPoint(PersonController Other)
{
	local int i;
	
	for (i = 0; i < Other.InterestPointsVisited.Length; i++)
		if (Other.InterestPointsVisited[i] == Self)
			return true;
			
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Add us to the list of interest points this person has visited before.
///////////////////////////////////////////////////////////////////////////////
function AddToVisited(PersonController Other)
{
	// Sanity check, don't add if we're already in the list.
	// (Shouldn't be possible to get this far but check anyway)
	if (VisitedThisPoint(Other))
		return;
		
	Other.InterestPointsVisited.Insert(0,1);
	Other.InterestPointsVisited[0] = Self;	
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
		//log("interest point instance-------------: "$self);

		if(WaitTimeMin > WaitTimeMax)
			log(self$"ERROR: wait time min is greater than the max");

		UseTagToNearestActor(InterestTag, MyInterest, 1.0, false);
		UseTagToNearestActor(LinkToTag, LinkToActor, 1.0, false);

		//log("my tag "$Tag);
		//log("concerned classes name "$ConcernedClasses.Name);
		//log("concerned base class"$ConcernedBaseClass.Name);
		//log("interest tag "$InterestTag);
		//log("interest actor "$MyInterest);
		//log("walk tag "$LinkToTag);
		//log("link actor "$LinktoActor);
	}

Begin:
	GotoState('');
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.InterestPoint'
	bStatic=False
	bCollideActors=True
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
	CollisionRadius=256
	CollisionHeight=70
	MaxAllowed=1
	ConcernedClasses=class'P2Pawn'
	ConcernedBaseClass=class'P2Pawn'
	InterestLevel=1.0
	bActive=true
	DrawScale=0.25
}
