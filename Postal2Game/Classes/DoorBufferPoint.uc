///////////////////////////////////////////////////////////////////////////////
// Buffers a doormover so too many people don't use the door
///////////////////////////////////////////////////////////////////////////////
class DoorBufferPoint extends Keypoint
	notplaceable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
// External variables

// Internal variables
var int MaxAllowed;		// How many people can enter this before they are turned away
var int NumberTouching;	// Number of actors touching me currently
var array<P2Pawn> PeopleWaiting;	// people waiting to use the door only P2Pawn's
									// with PersonControllers are added
var DoorMover MyDoor;	// Door I'm linked to
var P2Pawn CurrentUser;		// current user of door


const WAIT_TO_CLEAR_USER	=	4.0;


///////////////////////////////////////////////////////////////////////////////
// Link to your door mover
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	MyDoor = DoorMover(Owner);
}

///////////////////////////////////////////////////////////////////////////////
// Check if this is the same one
///////////////////////////////////////////////////////////////////////////////
function bool AlreadyInList(P2Pawn checkpawn)
{
	local int i;

	while(i < PeopleWaiting.Length)
	{
		if(checkpawn != PeopleWaiting[i])
			i++;
		else
			return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// This person gave up waiting
///////////////////////////////////////////////////////////////////////////////
function RemoveMe(P2Pawn checkpawn)
{
	local int i;

	//log(self$" remove me "$checkpawn$" current length is "$PeopleWaiting.Length);
	while(i < PeopleWaiting.Length)
	{
		if(checkpawn != PeopleWaiting[i])
			i++;
		else
		{
			//log(self$" properly removed ");
			PeopleWaiting.Remove(i, 1);
		}
	}
	if(CurrentUser == checkpawn)
		CurrentUser=None;
	//log(self$" new length is "$PeopleWaiting.Length);

	// If the door is not open, but we still have people, then send someone
	if(MyDoor.bClosed)
		TellNextPersonToGo();
}

///////////////////////////////////////////////////////////////////////////////
// Look at the our list and advise movement
///////////////////////////////////////////////////////////////////////////////
function bool TellNextPersonToGo()
{
	local P2Pawn checkpawn;
	local PersonController cont;
	local int i;
	local byte StateChange;

	if(CurrentUser != None)
	{
		if(CurrentUser.Health > 0
			&& !CurrentUser.bIsDeathCrawling)
			return true;
		else
			CurrentUser = None;	// We had an invalid user--clearing him
	}
	// Look through the touching list for a lamb controller ready to go through
	//log(self$" TellNextPersonToGo, check to send someone, len "$PeopleWaiting.Length);
	while(i < PeopleWaiting.Length)
	{
		//log("check him "$PeopleWaiting[i]);
		checkpawn = PeopleWaiting[i];

		cont = PersonController(checkpawn.Controller);

		// Remove dead people and stop list this time through
		if(cont == None
			|| checkpawn.Health <= 0
			|| checkpawn.bIsDeathCrawling)
		{
			UnTouch(checkpawn);
			return false;
		}
		StateChange = 0;
		// See if this live person can use the door
		cont.CheckToUseDoor(StateChange);

		if(StateChange == 1)
		{
			//log(self$" sending him !"$checkpawn);
			CurrentUser = checkpawn;
			// Finally remove someone from the waiting list
			PeopleWaiting.Remove(i, 1);
			//log(self$" now the user is !"$CurrentUser);
			//log(self$" TellNextPersonToGo new length is "$PeopleWaiting.Length);

			// Check to set a timer if this guy is outside your current area
			if(VSize(CurrentUser.Location - Location) > CollisionRadius)
			{
				//log(self$" will clear user");
				SetTimer(WAIT_TO_CLEAR_USER, false);
			}

			if(PeopleWaiting.Length > 0)
				return true;
			else
				return false;
		}

		i++;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Simply returns true if there are people in the waiting list
///////////////////////////////////////////////////////////////////////////////
function bool StillHavePeopleWaiting()
{
	if(PeopleWaiting.Length > 0)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Send another
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	//log(self$" timer, user "$CurrentUser$" cont "$PersonController(CurrentUser.Controller)$" door "$PersonController(CurrentUser.Controller).CheckDoor$" in wait "$(PersonController(CurrentUser.Controller).IsInState('WaitAroundDoor')));
	if(CurrentUser != None
		&& PersonController(CurrentUser.Controller) != None
		&& PersonController(CurrentUser.Controller).CheckDoor == self
		&& PersonController(CurrentUser.Controller).IsInState('WaitAroundDoor'))
	{
		PersonController(CurrentUser.Controller).GotoStateSave('Thinking');
		PersonController(CurrentUser.Controller).CheckDoor = None;
		//log(self$" user was screwing around");
	}
	//log(self$" Timer, current user cleared --------------------------");
	RemoveMe(CurrentUser);
}

///////////////////////////////////////////////////////////////////////////////
// Something has activated me
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	local P2Pawn checkpawn;
	local PersonController cont;
	local byte StateChange;
	local int ct;

	// Make sure our door is there
	if(MyDoor == None)
		return;

	// Make sure they have a clear shot to the door (and this thing isn't reaching through
	// walls or something)
	if(!MyDoor.ClearShotToDoor(Other.Location))
		return;

	checkpawn = P2Pawn(Other);

	if(checkpawn != None)
	{
		// Wake up
		bStasis=false;

		// if so, try to force someone to leave
		cont = PersonController(checkpawn.Controller);

		if(cont != None)
		{
			if(!cont.CheckForNormalDoorUse())
				return;

			if(PeopleWaiting.Length > MaxAllowed)
			{
				//log(self$" turning someone away ---------------------- "$checkpawn);
				cont.TryToSendAway();
				return;
			}

			//log(self$" door inst "$MyDoor.Instigator$" people length "$PeopleWaiting.Length$" checking "$checkpawn$" currentuser "$CurrentUser);
			if((CurrentUser != None
					|| PeopleWaiting.Length > 0)
				&& CurrentUser != checkpawn)
//			if((MyDoor.Instigator != None
//				|| PeopleWaiting.Length > 0)
//				&& CurrentUser != None
//				&& CurrentUser != checkpawn)
			{
				if(cont.PrepToWaitOnDoor(self))
				{
					// Check to make sure you're not already there
					if(!AlreadyInList(checkpawn))
					{
						// Add someone to the waiting list
						//log(self$" adding him !"$checkpawn$" length "$PeopleWaiting.Length);
						ct = PeopleWaiting.Length;
						PeopleWaiting.Insert(ct, 1);
						PeopleWaiting[ct] = checkpawn;
						//log(self$" new length is "$PeopleWaiting.Length);
					}
					//else
					//	log(self$"already in list !");
				}
				//else
				//	log(self$" cant do PrepToWaitOnDoor");
			}
			else if(checkpawn != CurrentUser)
			{
				CurrentUser = checkpawn;
				cont.CheckToUseDoor(StateChange);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Something has activated me
///////////////////////////////////////////////////////////////////////////////
function UnTouch(Actor Other)
{
	local P2Pawn checkpawn;
	local PersonController cont;

	checkpawn = P2Pawn(Other);
	if(checkpawn != None)
	{
		if(checkpawn == CurrentUser)
		{
			CurrentUser = None;
			//log(self$" UnTouch, current user cleared --------------------------");
			// If the door is not open, but we still have people, then send someone
			if(MyDoor.bClosed)
				TellNextPersonToGo();
		}
		// Go back to sleep if we have nothing to do
		if(PeopleWaiting.Length == 0
			&& CurrentUser == None)
			bStasis=true;
	}
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
		//  Go through and heavily weight all the points around the
		// door
		local Actor CheckA;

		//log("radius check on "$self);
		foreach RadiusActors( class 'Actor', CheckA, CollisionRadius)
		{
			if(NavigationPoint(CheckA) != None)
			{
				//log(self$" hit this one "$CheckA);
				NavigationPoint(CheckA).Cost = 500;
			}
		}
	}

Begin:
	GotoState('');
}

defaultproperties
{
	 bStatic=False
     bCollideActors=True
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
	 CollisionRadius=256
	 CollisionHeight=128
	 MaxAllowed=2
	 bStasis=true
}
