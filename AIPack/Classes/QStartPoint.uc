///////////////////////////////////////////////////////////////////////////////
// This is a queue for people to stand in, like in a grocery awaiting checkout
///////////////////////////////////////////////////////////////////////////////
class QStartPoint extends QPoint
	placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var	array<CashierController> MyOperators; // People who use me (supports delivery to multiple lines)
var bool bPlayerValidEntry;		// If true, the player got in the back of the line like he's
								// supposed to.
var int  PlayerPointInLine;

///////////////////////////////////////////////////////////////////////////////
// CONSTS

// Times for monitoring the line
const UPDATE_PEOPLE_IN_LINE=3.0;
const UPDATE_WAITING_FOR_PEOPLE=7.0;

// Multiplier for collision radius of point
const CLOSE_ENOUGH_MOD = 2.0;

const TURN_AROUND_POINT = 1;

///////////////////////////////////////////////////////////////////////////////
// Check various things (like it's class) to see if it's even allowed to use this
///////////////////////////////////////////////////////////////////////////////
function bool CheckToAllow(Actor Other, P2Pawn thispawn, PersonController Personc)
{
	// Disallow if cashier is dead
	if (!ValidOperators())
		return false;
	else
		return Super.CheckToAllow(Other, ThisPawn, PersonC);
}

///////////////////////////////////////////////////////////////////////////////
// Called by a user of interest point to check the next one to see if he should
// go there or not. Most things want you to not use it, if it already has
// too many people.
// We're slightly different--we don't check if we're active or not to 
// send new people to us.
///////////////////////////////////////////////////////////////////////////////
function bool LinkNewUserHere()
{
	return (CurrentUserNum < MaxAllowed);
}

///////////////////////////////////////////////////////////////////////////////
// This Q could be pointing to other cashiers, so link with a funciton
///////////////////////////////////////////////////////////////////////////////
function int AddOperator(CashierController AddCashOp)
{
	local int i;
	local bool bDoAdd;

	//log("adding an operator");
	bDoAdd=true;

	// Check to see if it's already in there, so as not to duplicate it
	for(i=0; i < MyOperators.Length; i++)
	{
		if(MyOperators[i] == AddCashOp)
		{
			warn(" trying to duplicate operator "$AddCashOp$" already at spot "$i);
			bDoAdd=false;
		}
	}
	// Check if it's valid
	if(bDoAdd)
	{
		i = MyOperators.Length;
		MyOperators.Insert(i, 1);
		MyOperators[i] = AddCashOp;
		//log(AddCashOp$" was added succesfully to "$self$" at spot "$i);
	}
	else
		i=-1;

	return i;
}

///////////////////////////////////////////////////////////////////////////////
// This operator is dead or something, so remove them and update
///////////////////////////////////////////////////////////////////////////////
function RemoveOperator(CashierController thisone)
{
	local int i;
	local CashierController currentone;

	// Save our current operator
	if(MyOperators.Length > 0)
		currentone = MyOperators[CurrentOperatorI];

	// locate it
	while(i < MyOperators.Length
		&& thisone != MyOperators[i])
	{
		i++;
	}
	
	// remove it
	if(i < MyOperators.Length)
	{
		if(thisone == MyOperators[i])
		{
			MyOperators.remove(i, 1);
		}
	}
	else
	{
		warn(" couldn't find "$thisone$" thought it was "$i$" place, in a list "$MyOperators.Length$" long");
	}
	// Refind our current operator in this mess
	if(currentone != None)
	{
		CurrentOperatorI=0;

		if(MyOperators.Length > 0)
		{
			while(CurrentOperatorI < MyOperators.Length
				&& currentone != MyOperators[CurrentOperatorI])
			{
				CurrentOperatorI++;
			}

	//		if(CurrentOperatorI >= MyOperators.Length)
	//			CurrentOperatorI=0;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Are there any valid operators?
///////////////////////////////////////////////////////////////////////////////
function bool ValidOperators()
{
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
}

///////////////////////////////////////////////////////////////////////////////
// Pick out a random cashier from the list
///////////////////////////////////////////////////////////////////////////////
function Actor PickRandomOperator()
{
	local int i;

	i = Rand(MyOperators.Length);
	if(MyOperators.Length <= 0)
		return None;
	else
		return MyOperators[i].Pawn;
}

///////////////////////////////////////////////////////////////////////////////
// Try for the next non-busy operator
///////////////////////////////////////////////////////////////////////////////
function FindNextOperator()
{
	CurrentOperatorI++;
	if(CurrentOperatorI == MyOperators.Length)
		CurrentOperatorI=0;
	//log("my next operator to use is "$CurrentOperatorI);
}

///////////////////////////////////////////////////////////////////////////////
// Count up on the spot, how many people are in line
///////////////////////////////////////////////////////////////////////////////
function int CountPeopleInLine(P2Pawn CurrentGuy)
{
	local vector HitLocation, HitNormal;
	local P2Pawn HitActor;
	local int i;

	// Don't count the current guy
	foreach TraceActors( class 'P2Pawn', HitActor, HitLocation, HitNormal, EndLoc, StartLoc, UseExtent)
	{
		if(CurrentGuy != HitActor
			&& HitActor != None)
		{
			i++;
			//log(self$" hit "$i$" HitActor "$HitActor);
		}
	}
	return i;
}

///////////////////////////////////////////////////////////////////////////////
// This person is exchanging with the cashier or on their way
// And is not a cashier themselves
///////////////////////////////////////////////////////////////////////////////
function bool PersonExchangingWithCashier(LambController lambc)
{
	local bool breturn;
	 breturn = (lambc.ExchangingAtCashRegister() &&
		CashierController(lambc) == None);

//	 log(lambc.Pawn$" exchanging with cashier? "$breturn);
	 return breturn;
}

///////////////////////////////////////////////////////////////////////////////
// Tell all the operators about this cutter
///////////////////////////////////////////////////////////////////////////////
function ReportCutter(FPSPawn Cutter)
{
	local int i;
	if(Cutter != None
		&& Cutter.Health > 0
		&& Cutter.bPlayer)
	{
		for(i=0; i < MyOperators.Length; i++)
		{
			MyOperators[i].bPlayerCutInLine=true;
			//log(self$" %%%%%%%%%%%%%%%%%%%%%%%%%%%%player cut in line !");
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// The player has gone to the back of the line
///////////////////////////////////////////////////////////////////////////////
function ClearCutter(FPSPawn Cutter, optional bool bNoOneInLine)
{
	local int i;
	if((Cutter != None
		&& Cutter.Health > 0
		&& Cutter.bPlayer)
		|| bNoOneInLine)
	{
		for(i=0; i < MyOperators.Length; i++)
		{
			MyOperators[i].bPlayerCutInLine=false;
			//log(self$" %%%%%%%%%%%%%%%%%%%%%%%%%%%%player CLEARED of cutting");
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to see if the person is within a certain range of the line
///////////////////////////////////////////////////////////////////////////////
function bool CloseEnoughToLine(FPSPawn CheckMe)
{
	local vector v1, v2;
	local float disttoline;

	v1 = CheckMe.Location;

	v2 = ProjectPointOntoQLine(v1);

	disttoline = VSize(v1 - v2);

	//log(self$" dist to line "$disttoline);

	if(disttoline < CLOSE_ENOUGH_MOD*CollisionRadius)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Look just from me forward and determine who I should try to get behind.
// Project my position onto the line and check from their forward, to the
// start of the line.
// The trace is backwards here (End to Start) because the q goes from the
// qpoint to the qpathpoint, and we want to check from the back end forward.
// Then check our operator and if they're secretly dealing with someone,
// then push us back some, to outside the qpoint, along the path of the line.
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
			// we just need the first one
			break;
		}
	}

	if(CheckA == None)
	{
		if(CurrentOperatorI < MyOperators.Length
			&& MyOperators[CurrentOperatorI].InterestPawn != None
			&& Other != MyOperators[CurrentOperatorI].InterestPawn)
		{
			CheckA = MyOperators[CurrentOperatorI].InterestPawn;
			lastpoint = Location + (CollisionRadius + CheckA.CollisionRadius)*LineDirection;
		}
		else
			lastpoint = Location;
	}
	else
	{
		lastpoint = CheckA.Location;
	}
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
		local int i, j;

		if(MyOperators.Length > 1)
		{
			for(i=0; i<MyOperators.Length; i++)
			{
				for(j=i+1; j<MyOperators.Length; j++)
				{
					if(MyOperators[i].CustomerStand == 
						MyOperators[j].CustomerStand)
						warn("multiple cashiers using same customer stand "$MyOperators[i]$" and "$MyOperators[j]$" are sharing "$MyOperators[i].CustomerStand);
				}
			}
		}
	}
Begin:
	Sleep(0.05);

	CheckForSameStandPoints();

	MyPlayer = GetPlayer();

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
		local vector HitLocation, HitNormal;
		local P2Pawn HitActor;
		local P2Pawn CheckA, PrevA, FirstInLine, TouchingP;
		local LambController lambc;
		local P2Player aplayer;
		local vector startp;
		local float dist, reqdist;
		local int usercount;
		local bool bBeingHelped, bNoOneInLine;
		local int TempPlayerPointInLine;
		
		TempPlayerPointInLine=-1;
		usercount=0;

		//log(self$" CheckLineForGaps");
		if(CurrentOperatorI < MyOperators.Length)
		{
			HitActor = P2Pawn(MyOperators[CurrentOperatorI].InterestPawn);

			if(HitActor != None
				&& VSize(HitActor.Location - Location) <= CollisionRadius)
			{
				FirstInLine = HitActor;
				CheckA = FirstInLine;
				if(MyOperators[CurrentOperatorI].Attacker == None)
				{
					if(UsingMeAsStand > -1)
						MyOperators[CurrentOperatorI].HandleThisPerson(CheckA);
					else
						MyOperators[CurrentOperatorI].HandleNextPerson(CheckA);
				}
			}
			//log(self$" first in line "$firstinline$" while interest is "$MyOperators[CurrentOperatorI].InterestPawn);
		}

		// Check like normal, from start to back. This ensures to pull people closer to
		// the cashier.
		foreach TraceActors( class 'P2Pawn', HitActor, HitLocation, HitNormal, EndLoc, StartLoc, UseExtent)
		{
			if(HitActor != None
				&& HitActor != CheckA
				&& (HitActor.bPlayer
					|| (PersonController(HitActor.Controller) != None
						&& PersonController(HitActor.Controller).CurrentInterestPoint == self)))
			{
				PrevA = CheckA;	// closer to Location
				CheckA = HitActor;	// farther down the line

				// this one is first in line
				if(FirstInLine == None)
					FirstInLine = CheckA;

				lambc = LambController(CheckA.Controller);
				aplayer = P2Player(CheckA.Controller);
			
				//log(self$" trace CheckLineForGaps in q, next is "$CheckA);
				
				usercount++;
				if(aplayer != None)
				{
					TempPlayerPointInLine=usercount;
					//log(self$" player!---- marked as being in line "$CheckA$" point "$usercount);
				}

				// Check to ignore line if you're a lamb controller and
				// your using a different interest point
				// or you're busy with a cashier
				if(lambc == None
					|| (lambc.CurrentInterestPoint == self
					&& !PersonExchangingWithCashier(lambc)
					&& CheckA.MyBodyFire == None))
				{

					if(lambc != None)
					{
						lambc.NoticePersonBeforeYouInLine(PrevA, usercount);
						// Uses a saved, randomized distance from the person
						// in front of us
						reqdist = lambc.PersonalSpace;
						//log("-----------------------------reqdist "$reqdist);
					}
					else 
						reqdist = 3*CheckA.CollisionRadius;

					// Check the distance between the two and decide to move the back one (CheckA)
					// more forward.
					if(CheckA == FirstInLine)
					{
						// go to front of the line
						startp = Location;
						reqdist = EndMarker.CollisionRadius;
						
						// Tell cashier
						// Check to see if it's the player and if they are holding
						// up the line
//						if(aplayer != None
//							&& aplayer.InterestPawn != None
//							&& CashierController(aplayer.InterestPawn.Controller) != None)

						/*
						if(MyOperators[CurrentOperatorI].InterestPawn != None
							&& P2Player(MyOperators[CurrentOperatorI].InterestPawn.Controller) != None
							&& P2Player(MyOperators[CurrentOperatorI].InterestPawn.Controller).InterestPawn == None
							&& !MyOperators[CurrentOperatorI].CashierBusy())
						{
							//CashierController(aplayer.InterestPawn.Controller).PersonHoldingUpLine(CheckA);
							MyOperators[CurrentOperatorI].PersonHoldingUpLine(CheckA);
							FindNextOperator();
						}
						else 
							*/
						if(MyOperators.Length > 0)
						{
							// Check for an open operator
							if(!MyOperators[CurrentOperatorI].CashierBusy())
							{
//								if(MyOperators[CurrentOperatorI].InterestPawn != FirstInLine)
//									MyOperators[CurrentOperatorI].ResetInterests();
								foreach TouchingActors(class'P2Pawn', TouchingP)
								{
									//log(self$" before handlenextperson touching pawns "$TouchingP);
									CheckA = TouchingP;
									break;
								}

								bBeingHelped = MyOperators[CurrentOperatorI].HandleNextPerson(CheckA);
							}
							else
							{
								FindNextOperator();
								//bBeingHelped=true;
							}
						}
					}
					else
					{
						bBeingHelped = (CheckA.IsInState('TalkingWithSomeoneMaster')
										|| CheckA.IsInState('WalkToCounter')
										|| CheckA.IsInState('WalkToCustomerStand'));
//							'ExchangeGoodsAndServices');

						// go behind a person in front of you
						startp = ProjectPointOntoQLine(PrevA.Location)
								+ reqdist*LineDirection;
						reqdist = EndMarker.CollisionRadius;
					}

					if(!bBeingHelped)
					{
						dist = VSize(startp - CheckA.Location);
						// Check to see if you're close enough to the spot in front of you
						if(dist > reqdist + CheckA.CollisionRadius)
						{
							if(lambc != None)
							{				
								// Cinch up the line by moving CheckA closer to PrevA
								// Set up next state
								lambc.SetEndPoint(startp, reqdist);

								if(lambc.IsInState('LegMotionToTarget'))
									lambc.bPreserveMotionValues=true;
								//log(self$" tell this guy to move up "$lambc.Pawn);

								if(!lambc.CheckToMoveUpInLine())
									lambc.QPointSaysMoveUpInLine();
							}
						}
					}// only complete this is you're not already being helped.
					else
					{
						// This operator is now occupied, so go to the next one
						FindNextOperator();
					}
				}// if a valid lambc or just something else
			}
		}

		// If the last person in line was the player, then clear his cutter status, if he had one at all
		if(usercount == 0)
			bNoOneInLine=true;
		ClearCutter(CheckA, bNoOneInLine);

		// Save number in line
		CurrentUserNum = usercount;

		//log(self$" player point "$TempPlayerPointInLine$" num "$CurrentUserNum);

		// If the player has yet to properly enter the line, check to make sure
		// he's in the very back of it.
		if(!bPlayerValidEntry)
		{
			// If he's in the back, the mark him as properly entering the line
			if(TempPlayerPointInLine > 0
				&& TempPlayerPointInLine >= CurrentUserNum)
			{
				bPlayerValidEntry=true;
				PlayerPointInLine=TempPlayerPointInLine;
				//log(self$" VALID PLAYER!---- marked as being in line "$CheckA$" point "$usercount);
			}
		}
		else	// If we've properly entered the line, now check to make sure 
				// we're still in the line somehow. We can't just store the two bystanders
				// in front and behind us, because they have a tendency to cut, or just leave
				// suddenly and it would be very difficult to determine when that happened and update
				// it so we don't not cut, but it tells us we did cut.
		{
			// If we weren't in the line at all and our position from before
			// was greater than TURN_AROUND_POINT, then clear us from being in the line properly
			if(TempPlayerPointInLine < TURN_AROUND_POINT)
			{
				bPlayerValidEntry=false;
				PlayerPointInLine=-1;
				//log(self$" RESETTING player!---- marked as being in line "$CheckA$" point "$usercount);
			}
			// Update his position
			else if(TempPlayerPointInLine >= TURN_AROUND_POINT)
			{
				PlayerPointInLine=TempPlayerPointInLine;
			}
		}

		// Modify update time
		if(CurrentUserNum > 0)
			// update more often, since there's someone around
			UpdateTime = UPDATE_PEOPLE_IN_LINE;
		else
		{
			if(CurrentOperatorI < MyOperators.Length)
				MyOperators[CurrentOperatorI].ResetInterests();
			UpdateTime = UPDATE_WAITING_FOR_PEOPLE;
		}

//		log("user count now "$CurrentUserNum);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Tell cashier to get off her butt, if somone is using me
	///////////////////////////////////////////////////////////////////////////////
	function Touch(Actor Other)
	{
		local P2Pawn p2p;
		// Turn it on
		if(UsingMeAsStand > -1)
		{
			p2p = P2Pawn(Other);

			//log(self$" touch by "$Other);

			if(p2p != None
				&& (p2p.bPlayer
					|| (PersonController(p2p.Controller) != None
						&& PersonController(p2p.Controller).CurrentInterestPoint == self))
				&& MyOperators.Length > 0)
			{
				SetActive(true);
				if(MyOperators[CurrentOperatorI].Attacker == None)
					MyOperators[CurrentOperatorI].HandleThisPerson(P2Pawn(Other));
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Tell cashier to get off her butt, if somone is using me
	///////////////////////////////////////////////////////////////////////////////
	function UnTouch(Actor Other)
	{
		if(UsingMeAsStand > -1)
		{
			if(P2Pawn(Other) != None
				&& MyOperators.Length > 0)
			{
				//log(self$" UNtouch by "$Other);
				if(MyOperators[CurrentOperatorI].Attacker == None)
					MyOperators[CurrentOperatorI].ThisPersonLeftYouWhileHandling(P2Pawn(Other));
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// If not already active, test to become active
	// made possible by the postal dude's presence
	///////////////////////////////////////////////////////////////////////////////
	function CheckToBeActive()
	{
		//PlayerCanSeeMe
		if(MyPlayer != None
			&& MyPlayer.Pawn != None
			&& MyPlayer.Pawn.Health > 0)
		{
			if(VSize(MyPlayer.Pawn.Location - Location) <= DistToActive)
			{
				// If we're technically close enough, see if we have a straight
				// shot to the line from the dude's top, to the line top (hopefully)
				// there won't be a lot of stuff in the way, this high up.
				if(FastTrace(MyPlayer.Pawn.Location, Location))
					SetActive(true);
			}
		}
	}

Begin:
	if(bActive)
	{
		CheckLineForGaps();
		
		Sleep(UpdateTime);
	}
	else
	{
		// If not already active, test to become active
		// made possible by the postal dude's presence
		CheckToBeActive();

		Sleep(UpdateTime);
	}
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Don't do anything
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InStasis
{
Begin:
	//log(self$" InStasis");
}

defaultproperties
{
	bActive=false
	PlayerPointInLine=-1
	Texture=Texture'PostEd.Icons_256.QStartPoint'
	DrawScale=0.25
}
