///////////////////////////////////////////////////////////////////////////////
// CashierController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for bystander cashiers.
//
// 
// Here was I problem I was seeing near the end of the game: 
// Basically I noticed every once in a while, a person would hang up in the front of the line, 
// not animating at all, and not moving. They would face the direction they wanted to go, but never move. 
// If you bumped them, they would spin towards you, but never move. The line would be stuck. 
// Of course, this is very bad. So basically, what was happening is, the thing they were walking to, 
// made them duck, the fall, but not really. They were never landing, for whatever reason, so they were 'falling', 
// thus they couldn't move from that spot. I tried lots of in code fixes, but it turns out the one thing 
// that fixed it was to turn off the collision on the gary table static mesh they were walking to.
// That doesn't sound great, but generally the little table piece in between could have a larger
// collision radius, but use static mesh collision. Well somehow that is telling the pawn to crouch
// sometimes, and I think the physics gets screwed up from that point. Turning off the physics
// one way or another ended up fixing the problem.
//
// 
// General other placement points with these include: place the cash-reg point as close to the
// other side of the counter as possible. Place the Qstartpoint close enough to the customer
// side of the counter, that the collision radius just touches the counter. Make sure the cashreg
// point is low enough that the counter *blocks* a direct line of sight from the cashreg point
// to the Qstartpoint.
//
//////////////////////////////////////////////////////////////////////////////
class CashierController extends BystanderController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var Name	QPointTag;				// QPoint I get people from

var P2MocapPawn		CustomerPawn;	// Interest pawn as P2Pawn for talking (say is defined in p2pawn, interestpawn
									// is an FPSPawn)
var P2MocapPawn		PossibleCutter;	// Guy we think may be cutting
var P2MocapPawn		PossibleCustomer; // If I'm dealing with another guy and someone (probaby the player)
									// butts up close to the person I'm dealing with, then they will trigger the
									// QStartPoint, but it can't take them yet, so they'll be lost if they move
									// up right afterwards. Save them in this, to check later.
var P2MocapPawn     LastNPCCustomer;// The last NPC customer we had. We don't take them again right after
									// having taken them, no matter what
var CashRegPoint	MyCashReg;		// The cash register I operate
var QStartPoint		MyQPoint;		// The queue I take customers from
var KeyPoint		CustomerStand;	// Where I expect customers to stand
var P2PowerupInv	PayerMoney;		// Payer's money inventory item (usually the dude's)
var bool			bResetInterests;// If you should reset you interestpawn
var bool bStolenFrom;				// someone stole from me!
var bool bSwitchToMoney;			// Even though we might have a different interest class, we 
									// still want to switch to money when the player shows up, if this
									// is true.
var bool bPlayerCutInLine;			// If this is true, and the player tries to get handled, then
									// send him to the back of the line

var float CustomerDoesntBuy;		// If likelihood that the customer gets mad and doesn't
									// buy the thing.
var float DudeGetsMad;				// How likely the dude is to get mad with this person
var float HowAreYouFreq;			// How like they are to exchange a string of niceties
var float DudePaidWaitTime;			// We wait around kindly for the dude to leave the line

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Possess the pawn
///////////////////////////////////////////////////////////////////////////////
function Possess(Pawn aPawn)
{
	local FPSPawn usepawn;

	// Cashiers should never be allowed to be controlled by the pawn slider.
	usepawn = FPSPawn(aPawn);
	if(usepawn != None)
		usepawn.bUsePawnSlider=false;

	Super.Possess(aPawn);
}

///////////////////////////////////////////////////////////////////////////////
// When they die, remove me from my q
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	// remove myself from the queue list
	if(MyQPoint != None)
		MyQPoint.RemoveOperator(self);

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Try to go into a stasis
// If we're going into stasis, take everything with us
// Cashregpoint, qstartpoint
///////////////////////////////////////////////////////////////////////////////
function GoIntoStasis(optional name StasisName)
{
	if(MyQPoint != None)
		MyQPoint.GotoState('InStasis'); 
	Super.GoIntoStasis(StasisName);
}

///////////////////////////////////////////////////////////////////////////////
// Exit a stasis
// Wake up all your other stuff
// Cashregpoint, qstartpoint
///////////////////////////////////////////////////////////////////////////////
event ComeOutOfStasis(bool bDontRenew)
{
	if(MyQPoint != None)
		MyQPoint.GotoState('MonitorLine'); 
	Super.ComeOutOfStasis(bDontRenew);
}

///////////////////////////////////////////////////////////////////////////////
// Say the errand is complete
// Generally used for TalkingToDudeMaster, but we need to extend it
// later and can't safely extend a base state and it's child states later,
// so we'll make the function global to cashiers.
// It's used to check errand completion after you're done talking to 
// someone.
///////////////////////////////////////////////////////////////////////////////
function bool EndErrand(optional Actor CheckActor, optional bool bPremature)
{
	local P2GameInfoSingle checkg;
	local P2Player p2p;

	checkg = P2GameInfoSingle(Level.Game);
	if(InterestPawn != None)
		p2p = P2Player(InterestPawn.Controller);

	if(checkg != None
		&& p2p != None)
	{
//			if(bPremature)
//			{
//				p2p.ErrandIsCloseEnough();
//			}
		// Dude has completed the errand.. has talked to this guy
		return checkg.CheckForErrandCompletion(CheckActor, None, MyPawn, p2p, bPremature);
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Make this person go to the outskirts of the q point, along the line of the queue
///////////////////////////////////////////////////////////////////////////////
function SendToLineStart(PersonController per)
{
	local QPoint qp;
	local vector endpt;

	qp = QPoint(per.CurrentInterestPoint);
	if(per.Attacker == None)
	{
		if(qp != None)
		{
			endpt = qp.Location + (qp.CollisionRadius + MyPawn.CollisionRadius + TIGHT_END_RADIUS)*qp.LineDirection;
			per.SetEndPoint(endpt, TIGHT_END_RADIUS);
			per.SetNextState('WaitInQ');
			per.GotoStateSave('WalkInQ');
		}
		else if(per.GetStateName() != 'CheckInterestForCommand')
			per.GotoStateSave('CheckInterestForCommand');
	}
}

///////////////////////////////////////////////////////////////////////////////
// setup dude to deal with the cashier
///////////////////////////////////////////////////////////////////////////////
function SetupDudeCustomer()
{
	local P2Player aplayer;

	aplayer = P2Player(InterestPawn.Controller);

	if(aplayer != None)
	{
		CustomerPawn = P2MoCapPawn(InterestPawn);

		// link to the cashier who called you over
		aplayer.InterestPawn = MyPawn;
		aplayer.bDealingWithCashier=true;

		// Switch you over to showing your money in your item list
		if(!bSwitchToMoney)
		{
			aplayer.SwitchToThisPowerup(InterestInventoryClass.default.InventoryGroup,
										InterestInventoryClass.default.GroupOffset);
		}
		else // Or if you want, just switch to money
		{
			aplayer.SwitchToThisPowerup(class'MoneyInv'.default.InventoryGroup,
										class'MoneyInv'.default.GroupOffset);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// You're buddy just showed up to work
///////////////////////////////////////////////////////////////////////////////
function NextWorkerIsReady(P2Pawn NextGuy)
{
	MyCashReg.NextGuyWaiting=NextGuy;
}

///////////////////////////////////////////////////////////////////////////////
// I'll take the next person in line, please
///////////////////////////////////////////////////////////////////////////////
function bool HandleNextPerson(P2Pawn CheckA)
{
	/*
	local PersonController per;
	// send unhandled entries to this back to thinking
	if(CheckA != None)
	{
		per = PersonController(CheckA.Controller);
		if(per != None)
		{
			per.GotoStateSave('Thinking');
			return true;
		}
	}
	*/
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check if the dude is standing in the way of the current transaction--mark
// him as a cutter, if so
///////////////////////////////////////////////////////////////////////////////
function CheckForUpFrontCutter(P2Pawn CheckA)
{
	if(CheckA != None)
	{
		// Save if the player may be cutting
		if(CheckA.bPlayer)
			PossibleCutter = P2MocapPawn(CheckA);
		//log(MyPawn$" possible cutter "$PossibleCutter);

		// If i'm dealing with someone, and this possible cutter is closer to me
		// than the current customer is, then call him a cutter.
		if(InterestPawn != None
			&& InterestPawn != CheckA
			&& ExchangingAtCashRegister()
			&& VSize(CheckA.Location - MyPawn.Location) < VSize(InterestPawn.Location - MyPawn.Location))
		{
			//log(MyPawn$" CheckForUpFrontCutter reporting that "$CheckA$" is closer than "$InterestPawn);
			MyQPoint.ReportCutter(CheckA);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Similar to 'up front cutter', this is someone who jumps in in between transactions
///////////////////////////////////////////////////////////////////////////////
function CheckForJumpInCutter(P2Pawn CheckA)
{
	if(CheckA != None)
	{
		// Make sure the player never got in line before and there's other people
		// in line, then he'll be flagged as cutting.
		if(CheckA.bPlayer)
		{
			// Save if the player may be cutting
			PossibleCutter = P2MocapPawn(CheckA);
			if(!MyQPoint.bPlayerValidEntry
				&& MyQPoint.CurrentUserNum > 0)
			{
				//log(MyPawn$" CheckForJumpInCutter reporting that "$CheckA$" jumped to the front of the line");
				MyQPoint.ReportCutter(CheckA);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Someone is in front of me, trying to get my attention
///////////////////////////////////////////////////////////////////////////////
function HandleThisPerson(P2Pawn CheckA)
{
	local PersonController per;

	// Don't talk to your attacker
	if(CheckA == Attacker)
		return;

	//log(self$" global HandleThisPerson "$CheckA);
	// send unhandled entries to this back to thinking
	if(CheckA != None
		&& LastNPCCustomer != CheckA)
	{
		per = PersonController(CheckA.Controller);
		if(per != None
			&& per.Attacker == None
			&& (per.IsInState('WalkToTarget')
			|| per.IsInState('WalkInQ')
			|| per.IsInState('WaitInQ')
			|| per.IsInState('WalkToCustomerStand')))
		{
			if(per.CurrentInterestPoint != None)
			{
				if(per.GetStateName() != 'CheckInterestForCommand')
					per.GotoStateSave('CheckInterestForCommand');
			}
			//else // This was bad.. it sometimes sent them into a constant loop
			// of walking away, but getting put back into thinking
			//	per.GotoStateSave('Thinking');
		}
		else
			CheckForUpFrontCutter(CheckA);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Someone is in front of me, trying to get my attention
///////////////////////////////////////////////////////////////////////////////
function ThisPersonLeftYouWhileHandling(P2Pawn CheckA)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Check for someone standing close enough to buy something
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCustomerStandTouch(FPSPawn CheckMe)
{
	local float dist;

	if(CheckMe != None
		&& CustomerStand != None)
	{
		dist = VSize(CustomerStand.Location - CheckMe.Location);
		//log(MyPawn$" customer stand touch "$dist$" needed radius "$CustomerStand.CollisionRadius);// + 2*CheckMe.CollisionRadius);
		return dist <= CustomerStand.CollisionRadius;// + 2*CheckMe.CollisionRadius;
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// People are busy doing deals
///////////////////////////////////////////////////////////////////////////////
function bool ExchangingAtCashRegister()
{
	// I'm doing business or the person is walking to me
	if(IsInState('TalkingWithSomeoneMaster')
		|| IsInState('NextCustomerWalkingToMe')
		|| IsInState('NextCustomerWalkingToCounter')
		|| IsInState('HandleCutter'))
	{
		return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Either with someone or walking around doing something else
///////////////////////////////////////////////////////////////////////////////
function bool CashierBusy()
{
	if(Attacker != None
		|| ExchangingAtCashRegister()
		|| IsInState('BotheringCustomers')
		|| 
		(
		InterestPawn != None && 
		(InterestPawn.Controller == None
		|| 
		(InterestPawn.Controller != None
		&& (//InterestPawn.Controller.bIsPlayer
		//|| 
		InterestPawn.Controller.IsInState('TalkingWithSomeoneMaster'))))
		)
		)
	{
		return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// There's some idiot holding up the front of the line
///////////////////////////////////////////////////////////////////////////////
function PersonHoldingUpLine(P2Pawn CheckP)
{
//	PrintDialogue("Please move forward."$CheckP);
//	SayTime = Say(MyPawn.myDialog.lPleaseMoveForward);
}
/*
///////////////////////////////////////////////////////////////////////////////
// Return the hint you want to display for this item
///////////////////////////////////////////////////////////////////////////////
function GetInvHint(Inventory checkme, out String str1)
{
	if(MoneyInv(checkme) != None)
	{
		str1 = GameHint;
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// Record the amount of money spent
///////////////////////////////////////////////////////////////////////////////
function RecordMoneySpent(P2Pawn Spender, int moneyused)
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Spender != None
		&& Spender.bPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.MoneySpent+=moneyused;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Cashiers only, usually
///////////////////////////////////////////////////////////////////////////////
function bool AcceptItem(P2Pawn Payer, Inventory thisitem, 
						 out float AmountTaken, float FullAmount)
{
	local float TotalCost;
	TotalCost = GetTotalCostOfYourProducts(Payer, MyPawn);

	// if no item, or not the right type
	if(thisitem == None
		|| thisitem.class != InterestInventoryClass)
		return false;

	// If you're stuff doesn't cost anything, then don't change states with this
	if(TotalCost <= 0)
		return false;

	if(FullAmount < TotalCost)
	{
		//log("you need this much "$TotalCost);
		AmountTaken = 0;
		// No payment to accept!
		// The deal's off!
		GotoState('DudeHasInsufficientFunds');
		return false;
	}
	else
	{
		//log("you PAID this much "$TotalCost);
		AmountTaken = TotalCost;
		if(MoneyInv(thisitem) != None)
			RecordMoneySpent(Payer, TotalCost);
		// Take money and thank them
		GotoState('TakePaymentFromDude');
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////
// Find where to wait before you go to work
///////////////////////////////////////////////////////////////////////////
function FindWaitPoint()
{
	if(MyCashReg != None)
	{
		SetEndGoal(MyCashReg.NextOperatorStand, MyCashReg.NextOperatorStand.CollisionRadius);
	}
	//log(MyPawn$" my wait point is "$MyCashReg.NextOperatorStand$" size "$MyCashReg.NextOperatorStand.CollisionRadius$" pawn loc "$MyPawn.Location$" point loc "$MyCashReg.NextOperatorStand.Location);
}
///////////////////////////////////////////////////////////////////////////
// Find my cash register
///////////////////////////////////////////////////////////////////////////
function FindCashRegister()
{
	if(MyCashReg != None)
		SetEndGoal(MyCashReg, MyCashReg.CollisionRadius);

	//log(MyPawn$" my cash register "$MyCashReg);
}

///////////////////////////////////////////////////////////////////////////////
// reset your interests
///////////////////////////////////////////////////////////////////////////////
function ResetInterests()
{
	// STUB used in wait for customers
}

///////////////////////////////////////////////////////////////////////////////
// Try to match the cpp version of FPSPawn.cpp ReachedDestinationWithRadius of distance check
///////////////////////////////////////////////////////////////////////////////
function bool CloseEnoughTo(Actor CheckMe)
{
	local vector dir;
	dir = CheckMe.Location - MyPawn.Location;
	dir.z=0;

	if(VSize(dir) <= CheckMe.CollisionRadius)
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do next
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	ignores DonateSetup, InterestIsAnnoyingUs, GetHitByDeadThing, CheckDesiredThing, FreeToSeekPlayer;

Begin:
	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

TryAgain:
	Sleep(FRand()*0.5 + 0.5);

	if(!MyPawn.bCanEnterHomes
		&& MyCashReg != None)
	{
		// walk to some random place I can see (not through walls)
		SetNextState('WaitForCustomers');
		FindCashRegister();
		GotoStateSave('WalkToTarget');
	}
	else
	{
		// walk to some random place I can see (not through walls)
		SetNextState('Thinking');
		if(!PickRandomDest())
			Goto('TryAgain');	// Didn't find a valid point, try again
		GotoStateSave('WalkToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Try to go to my HomeTag and maybe do things along the way
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GoToMyHome
{
	ignores DonateSetup, InterestIsAnnoyingUs, GetHitByDeadThing, CheckDesiredThing;
	///////////////////////////////////////////////////////////////////////////////
	// unhook from the cash register if we're at one
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
//		if(MyCashReg != None)
//			MyCashReg.RemoveCurrentOperator();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Try to go my workplace
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GoToWork
{
	ignores DonateSetup, InterestIsAnnoyingUs, GetHitByDeadThing, CheckDesiredThing;
	///////////////////////////////////////////////////////////////////////////////
	// unhook from the cash register if we're at one
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// Don't let them go into stasis mode
		DisallowStasis();
		MyPawn.bCanEnterHomes=false;
	}

CheckIfThere:
	if(MyCashReg != None)
	{
		// If we're close enough, then to go to before work prep
		if(CloseEnoughTo(MyCashReg.NextOperatorStand))
			GotoStateSave('CheckForWorkerChangeOver');
	}
	else
		GotoStateSave('CheckForWorkerChangeOver');

Begin:
/*
	set up delux find work, make them keep coming back till they find it

		also don't make setup operator happen till they get to work

*/
	// walk to some random place I can see (not through walls)
	SetNextState('GoToWork', 'CheckIfThere');
	FindWaitPoint();
	GotoStateSave('WalkToWork');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're switching shifts, unless your the first one there
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CheckForWorkerChangeOver
{
	ignores DonateSetup, InterestIsAnnoyingUs, GetHitByDeadThing, CheckDesiredThing, TryToGreetPasserby;

	function BeginState()
	{
		PrintThisState();
	}

Begin:
	// if we're the first one there, then go straight to work
	if(MyCashReg.CashOp == None)
	{
		MyCashReg.SetupCurrentOperator();
		GotoStateSave('Thinking');
	}

OneGuyWaiting:
	// Guy waiting looks at guy currently working
	InterestPawn = P2Pawn(MyCashReg.CashOp.Pawn);
	Focus = InterestPawn;
	// He then tells him he's here and links them
	MyCashReg.CashOp.NextWorkerIsReady(MyPawn);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Switching shifts
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShiftChangeWorkerComing extends TalkingWithSomeoneMaster
{
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	// waits first then says hi
	Sleep(3.0);

	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("coming Greeting");
	Sleep(SayTime);

	// I go to work
	MyCashReg.OperatorIndex = MyCashReg.GetNextOperatorIndex();
	//log(MyCashReg$"setting him as index "$MyCashReg.OperatorIndex);
	MyCashReg.SetupCurrentOperator();
	GotoStateSave('Thinking');
}
///////////////////////////////////////////////////////////////////////////////
state ShiftChangeWorkerGoing extends TalkingWithSomeoneMaster
{
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	// Set up the coming worker first
	LambController(InterestPawn.Controller).GotoStateSave('ShiftChangeWorkerComing');
	// says hi first
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("going Greeting");
	Sleep(SayTime);

	Sleep(3.0);

	// going home now
	DisallowStasis();
	if(MyCashReg != None)
		MyCashReg.RemoveCurrentOperator(self);
	GotoStateSave('GoToMyHome');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Check out people in line
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitForCustomers
{
	ignores TryToGreetPasserby, PerformInterestAction, DonateSetup, InterestIsAnnoyingUs, GetHitByDeadThing, 
		CheckDesiredThing, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// You're buddy just showed up to work
	// And since we're not in the middle of a transaction, we can quit
	///////////////////////////////////////////////////////////////////////////////
	function NextWorkerIsReady(P2Pawn NextGuy)
	{
		//  link to the waiting guy
		InterestPawn = NextGuy;
		Focus = InterestPawn;
		// Link waiting guy to us
		InterestPawn.Controller.Focus = MyPawn;
		// go over to where he is
		SetNextState('ShiftChangeWorkerGoing');
		SetEndGoal(InterestPawn, TALK_TO_SOMEONE_RADIUS);
		GotoStateSave('WalkToTarget');
		// Don't get hung up along the way
		DisallowStasis();
		// wipe this
		MyCashReg.NextGuyWaiting=None;
	}

	///////////////////////////////////////////////////////////////////////////////
	// I'll take the next person in line, please
	// True if he'll handle this person now
	///////////////////////////////////////////////////////////////////////////////
	function bool HandleNextPerson(P2Pawn CheckA)
	{
		local float dist, EndRad;
		local PersonController Personc;
		local P2Player p2p;

		//log(MyPawn$" handle next "$CheckA$" interest is "$InterestPawn$" interest 2 "$InterestPawn2);
		InterestPawn = CheckA;

		if(LastNPCCustomer != CheckA)
		{
			// Not busy right now
			// or the dude is standing there for two sessions.
			if((InterestPawn == None
				|| InterestPawn == CheckA)
				&& CheckA != None
				&& InterestPawn2 != InterestPawn)
				//&& p2p == None)
			{
				InterestPawn2 = None;

				// Check how close they are to the qpoint spot
				dist = VSize(MyQPoint.Location - CheckA.Location);

				Focus = InterestPawn;

				// He's close enough to the start of the line to intiate
				// an operation
				// Send him to handle me
				Personc = PersonController(InterestPawn.Controller);
				if(Personc != None)
				{
					if(Personc.Attacker == None)
					{
						// Tell the customer where to walk to
						Personc.InterestPawn = MyPawn;
						EndRad = CustomerStand.CollisionRadius/2;
						if(EndRad < TIGHT_END_RADIUS)
							EndRad = TIGHT_END_RADIUS;
						Personc.SetEndPoint(CustomerStand.Location, EndRad);
						if(Personc.IsInState('LegMotionToTarget'))
							Personc.bPreserveMotionValues=true;
						Personc.SetNextState('WaitInQ');
						Personc.GotoStateSave('WalkToCustomerStand');

						GotoStateSave('NextCustomerWalkingToMe');
						return true;
					}
					else
						return false;
				}
				else if(CheckForCustomerStandTouch(InterestPawn))
					//dist < MyQPoint.CollisionRadius + CheckA.CollisionRadius)
				{
	//				{
						GotoStateSave('NextCustomerWalkingToMe');
						return true;
	//				}
				}
				else
				{
					GotoStateSave('WaitForCustomers', 'WaitForNextPerson');
					return false;
				}
			}
			/*
			else
			{	
				// sometimes just ignore the same idiot constantly returning
				if(InterestPawn2 == CheckA && FRand() <= 0.5)
					return false;

				// somone else is butting in
				Focus = CheckA;
				//log("this cut 2");
				GotoStateSave('HandleCutter');
			}
	*/
		}

		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Someone is in front of me, trying to get my attention
	///////////////////////////////////////////////////////////////////////////////
	function HandleThisPerson(P2Pawn CheckA)
	{
		local P2Player p2p;
		local PersonController personc;

		// Don't talk to your attacker
		if(CheckA == Attacker)
			return;

		//log(MyPawn$" handle THIS in Waitforcustomers "$CheckA$" interest "$InterestPawn$" interest 2 "$InterestPawn2$" player cut: "$bPlayerCutInLine$" line num "$MyQPoint.CurrentUserNum);
		if(CheckA.bPlayer)
		{
			// Don't let him deal with a cashier if the player says he's not ready
			if(P2Player(CheckA.Controller) == None
				|| !P2Player(CheckA.Controller).ReadyForCashier())
				return;

			CheckForJumpInCutter(CheckA);

			if(bPlayerCutInLine)
			{
				// Update that he wasn't cutting at this point, and continue to handle him
				if(MyQPoint.CurrentUserNum == 0)
					bPlayerCutInLine=false;
				else
				{
					// Someone else is butting in
					Focus = CheckA;
					InterestPawn = None;
					GotoStateSave('HandleCutter');
					return;
				}
			}
		}
		
		personc = PersonController(CheckA.Controller);
		// If it's the last guy we just had, turn him away
		if(LastNPCCustomer == CheckA)
		{
			if(Personc != None)
			{
				if(InterestPawn == CheckA)
					InterestPawn = None;
				log(self$" TURNING AWAY guy here from earlier "$LastNPCCustomer);
				/*
				if(Personc.Attacker == None
					&& !Personc.IsInState('Thinking')
					&& Personc.GetStateName() == 'Walking')
					Personc.GotoStateSave('Thinking');
					*/
				return;
			}
		}

		// If we don't have an interest, or if we do, but someone other than
		// the dude came in, then handle them.
		if((InterestPawn == None
				|| (InterestPawn != CheckA
					&& !CheckA.bPlayer))
			&& (InterestPawn2 != CheckA
				|| CheckA.bPlayer))
			InterestPawn = CheckA;

		// Check to make sure the guy you're dealing with isn't standing there
		// for two times in a row, when there's a line of people
		if(InterestPawn == CheckA
			&& CheckA != None
			&& (InterestPawn2 != InterestPawn
				|| MyQPoint.CountPeopleInLine(P2Pawn(InterestPawn)) == 0))
		{
			InterestPawn2= None;

			personc = PersonController(InterestPawn.Controller);
			// He's close enough to the start of the line to intiate
			// an operation
			// Send him to handle me
			if(Personc != None)
			{		
				if(Personc.Attacker != None)
					return;

				//log(MyPawn$" dist to counter front "$VSize(InterestPawn.Location - MyQPoint.CounterFront)$" needs to "$TIGHT_END_RADIUS+DEST_BUFFER);
				// Check if you're close enough to the counter front
				if(VSize(InterestPawn.Location - MyQPoint.CounterFront) > TIGHT_END_RADIUS+DEST_BUFFER)// + InterestPawn.CollisionRadius))
				{
					// Find point to walk to for the customer
					Personc.SetEndPoint(MyQPoint.CounterFront, TIGHT_END_RADIUS);
					if(Personc.IsInState('LegMotionToTarget'))
						Personc.bPreserveMotionValues=true;
					Personc.SetNextState('Thinking');	// Only a fall back, you'll tell them your ready
					// through another call to this function, and hopefully, you'll be close enough.
					Personc.InterestPawn = MyPawn;
					// He walks up to the counter
					Personc.GotoStateSave('WalkToCounter');
					// Clear this when we get the possible customer
					if(CheckA == PossibleCustomer)
						PossibleCustomer = None;
					// I wait on him.
					GotoStateSave('NextCustomerWalkingToCounter');
					return;
				}
				else
				{
					// Clear this when we get the possible customer
					if(CheckA == PossibleCustomer)
						PossibleCustomer = None;
					// set up me handling the customer
					GotoStateSave('ExchangeGoodsAndServices');
					return;
				}
			}
			else
			{
				// Clear this when we get the possible customer
				if(CheckA == PossibleCustomer)
					PossibleCustomer = None;
				GotoStateSave('ExchangeWithDude');
				return;
			}
		}
		else if(!CheckA.bPlayer)
		{	
			// somone else is butting in
			Focus = CheckA;
			// Only clear our interest if it's the player
			if(InterestPawn.bPlayer)
				InterestPawn = None;
			GotoStateSave('HandleCutter');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// reset your interests
	///////////////////////////////////////////////////////////////////////////////
	function ResetInterests()
	{
		local PersonController perc;

		//log(MyPawn$" reset interests");

		if(InterestPawn != None)
			perc = PersonController(InterestPawn.Controller);

		// If not a npc, or he's not already walking to line head, then clear them
		if(perc == None
			|| !perc.IsInState('WalkToCustomerStand'))
		{
			Focus = MyQPoint;

			// clear my customer
			InterestPawn = None;
			//InterestPawn2 = None;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Save my interests
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		if(bResetInterests)
		{
			//Focus = MyQPoint;
			//InterestPawn = None;
			ResetInterests();
		}
		bResetInterests=true;
	}

WaitForNextPerson:
	if(MyCashReg.NextGuyWaiting != None)
		NextWorkerIsReady(MyCashReg.NextGuyWaiting);

	// Check to make sure the guy you're interested in, is still vaguely
	// standing around the line and not walking off somewhere.
	if(InterestPawn != None
		&& !MyQPoint.CloseEnoughToLine(InterestPawn))
		ResetInterests();

	if(!CheckForCustomerStandTouch(InterestPawn)
		&& InterestPawn != None)
	{
		//log(MyPawn$" waiting, player cut: "$bPlayerCutInLine);

		if(MyQPoint.CurrentUserNum > 1)
		{
			GotoStateSave('AskForNextCustomer', 'ManyCustomers');
		}
		else if(MyQPoint.CurrentUserNum == 1)
		{
			GotoStateSave('AskForNextCustomer', 'OneCustomer');
		}
		else
		{
			Sleep(4.0);
			// finally clear second interest
			InterestPawn2 = None;
		}
	}

	HandleNextPerson(P2Pawn(InterestPawn));

Begin:
	Sleep(4.0);
	// Finally clear second interest
	InterestPawn2 = None;

	if(MyCashReg.bCanUseStasis)
	{
		// Try to go into stasis
		ReallowStasis();
		MyPawn.TryToWaitForStasis();
TryingForStasis:
		if(CheckForCustomerStandTouch(PossibleCustomer))
			HandleThisPerson(PossibleCustomer);

		HandleStasisChange();
		Sleep(5.0);
		Goto('TryingForStasis');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Get someone to come to me
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AskForNextCustomer extends WaitForCustomers
{
	ignores HandleNextPerson, HandleStasisChange;

	///////////////////////////////////////////////////////////////////////////////
	// Override the super beginstate, because we want to preserve our interestpawns
	// and other variables it might clear
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		bResetInterests=false;

		// Gesture for them to come forward
		MyPawn.PlayHelloGesture(1.0);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Clear important dialog
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		bImportantDialog=false;
	}

Begin:
	if(InterestPawn.bPlayer)
		bImportantDialog=true;

SameCustomer:
	Sleep(FRand());
	PrintDialogue("Please move forward."$InterestPawn);
	SayTime = Say(MyPawn.myDialog.lPleaseMoveForward, bImportantDialog);
	Sleep(SayTime + FRand()*4*SayTime + 1.0);
	GotoStateSave('WaitForCustomers', 'WaitForNextPerson');

OneCustomer:
	Sleep(FRand());
	SayTime = Say(MyPawn.myDialog.lHelpYouOverHere, bImportantDialog);
	PrintDialogue("I can help you over here..."$InterestPawn);
	Sleep(SayTime + FRand()*4*SayTime + 1.0);
	GotoStateSave('WaitForCustomers', 'WaitForNextPerson');

ManyCustomers:
	Sleep(FRand());
	SayTime = Say(MyPawn.myDialog.lNextInLine, bImportantDialog);
	PrintDialogue("I'll take the next person in line..."$InterestPawn);
	Sleep(SayTime + FRand()*4*SayTime + 1.0);
	GotoStateSave('WaitForCustomers', 'WaitForNextPerson');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// I've asked someone to walk over to me, so I'm waiting on them
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NextCustomerWalkingToMe extends WaitForCustomers
{
	ignores HandleStasisChange;

	///////////////////////////////////////////////////////////////////////////////
	// There's some idiot holding up the front of the line
	///////////////////////////////////////////////////////////////////////////////
	function PersonHoldingUpLine(P2Pawn CheckP)
	{
		local bool bImportant;
		if(CheckP.bPlayer)
			bImportant=true;

		PrintDialogue("Please move forward."$CheckP);
		SayTime = Say(MyPawn.myDialog.lPleaseMoveForward, bImportant);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Override the super beginstate, because we want to preserve our interestpawns
	// and other variables it might clear
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		bResetInterests=false;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Clear important dialog
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		bImportantDialog=false;
	}

Begin:
	if(CheckForCustomerStandTouch(InterestPawn))
		HandleThisPerson(P2Pawn(InterestPawn));

	// Gesture for them to come forward
	MyPawn.PlayHelloGesture(1.0);

	if(InterestPawn.bPlayer)
		bImportantDialog=true;

	SayTime = Say(MyPawn.myDialog.lHelpYouOverHere, bImportantDialog);
	Sleep(SayTime + 1.0);
	PrintDialogue("I can help you over here "$Focus);
	//log("current line num "$MyQPoint.CurrentUserNum);
	//MyPawn.DoJump(true);	// just for a current visual

	GotoStateSave('WaitForCustomers', 'WaitForNextPerson');

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// They're very close, but need to walk as close to the counter as possible
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NextCustomerWalkingToCounter extends WaitForCustomers
{
	ignores HandleStasisChange;
Begin:
	Sleep(2.0);
	if(CheckForCustomerStandTouch(InterestPawn))
		HandleThisPerson(P2Pawn(InterestPawn));
	Sleep(5.0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Handle someone butting in
// Expects the focus to be set to the cutter in question
// and the interestpawn to be set to who we care about currently
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HandleCutter extends WaitForCustomers
{
	ignores HandleNextPerson, HandleStasisChange;

	///////////////////////////////////////////////////////////////////////////////
	// Check for legitimate customers
	///////////////////////////////////////////////////////////////////////////////
	function HandleThisPerson(P2Pawn CheckA)
	{
		// Don't talk to your attacker
		if(CheckA == Attacker)
			return;

		//log(MyPawn$" HandleThisPerson focus "$Focus$" hit "$CheckA$" interest "$InterestPawn);
		// Not the one we're yelling at, then possibly help them
		if(CheckA != None
			&& Focus != CheckA
			&& InterestPawn == None
			&& LastNPCCustomer != CheckA)
		{
			InterestPawn = CheckA;
			//log(MyPawn$" picking him "$InterestPawn);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Override the super beginstate, because we want to preserve our interestpawns
	// and other variables it might clear
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		//log(self$" interest "$InterestPawn);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Clear important dialog
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		bImportantDialog=false;
	}
Begin:
	// Gesture angry
	MyPawn.PlayPointThatWayAnim();

	if(FPSPawn(Focus).bPlayer)
		bImportantDialog=true;
	PrintDialogue("I'm sorry, but you'll to go the back of the line."$Focus);
	SayTime = Say(MyPawn.myDialog.lSomeoneCuts, bImportantDialog);
	Sleep(SayTime + FRand());

	// Set it back to our interest because we can't help him
	if(InterestPawn != None)
	{
		Focus = InterestPawn;
		if(!InterestPawn.bPlayer)
			GotoState('ExchangeGoodsAndServices');
		else
			GotoState('ExchangeWithDude');
	}
	else
		Focus = None;
		GotoState('WaitForCustomers');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ExchangeGoodsAndServices
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ExchangeGoodsAndServices
{
	ignores WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Say something and also possibly gesture
	///////////////////////////////////////////////////////////////////////////////
	function TalkSome(out P2Dialog.SLine line, optional P2Pawn Speaker, 
						optional bool bIsGreeting,
						optional bool bIsGiving,
						optional bool bIsTaking)
	{
		// Constantly check to make sure the player isn't trying to cut while you're
		// dealing with someone else
		CheckForUpFrontCutter(PossibleCutter);

		Super.TalkSome(line, Speaker, bIsGreeting, bIsGiving, bIsTaking);
	}

	///////////////////////////////////////////////////////////////////////////////
	// I'll take the next person in line, please
	// Turn away ai characters when talking
	///////////////////////////////////////////////////////////////////////////////
	function bool HandleNextPerson(P2Pawn CheckA)
	{
		local PersonController per;
		
		//log(MyPawn$" handle next in exchange "$CheckA$" interest "$InterestPawn);
		// send unhandled entries to this back to thinking
		if(CheckA != None
			&& CheckA != InterestPawn)
		{
			per = PersonController(CheckA.Controller);
			if(per != None
				&& per.Attacker == None)
			{
				if(per.CurrentInterestPoint != None)
				{
					if(per.GetStateName() != 'CheckInterestForCommand')
						per.GotoStateSave('CheckInterestForCommand');
				}
				//else // This was bad.. it sometimes sent them into a constant loop
				// of walking away, but getting put back into thinking
				//	per.GotoStateSave('Thinking');
				return true;
			}
		}
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Someone is in front of me, trying to get my attention
	// Turn away ai characters when talking
	///////////////////////////////////////////////////////////////////////////////
	function HandleThisPerson(P2Pawn CheckA)
	{
		local PersonController per;

		//log(MyPawn$" handle THIS in exchange "$CheckA$" interest "$InterestPawn);
		// Don't talk to your attacker
		if(CheckA == Attacker)
			return;

		// send unhandled entries to this back to thinking
		if(CheckA != None
			&& CheckA != InterestPawn
			&& LastNPCCustomer != CheckA)
		{
			per = PersonController(CheckA.Controller);
			if(per != None
				&& per.Attacker == None)
			{
				if(per.CurrentInterestPoint != None)
				{
					SendToLineStart(per);
					return;
				}
				else
				{
					per.GotoStateSave('Thinking');
					return;
				}
			}
			else
			{
				CheckForUpFrontCutter(CheckA);
				if(!bPlayerCutInLine)
				{
					PossibleCustomer = P2MocapPawn(CheckA);
					//log(self$" possible customer set "$CheckA);
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// The customer doesn't decide how much to withdrawal or deposit, we secretly do
	// using values set in the cash register point
	///////////////////////////////////////////////////////////////////////////////
	function int DecideCustomerMoney()
	{
		return MyPawn.MyDialog.GetValidNumber(MyCashReg.ItemCostMin,MyCashReg.ItemCostMax);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Get the customer ready for business
	///////////////////////////////////////////////////////////////////////////////
	function SetupCustomer()
	{
		local bool bReadyToBuy;

		if(PersonController(InterestPawn.Controller) != None
			&& CashierController(InterestPawn.Controller) == None
			&& InterestPawn.Health > 0)
		{
			//CheckForCustomerProx();
			//if(statecount == 2) // he's still around and ready to buy things
				bReadyToBuy=true;
		}

		if(bReadyToBuy)
		{
			// Customer looks at cashier
			CustomerPawn = P2MoCapPawn(InterestPawn);
			if(PersonController(InterestPawn.Controller).Attacker == None)
			{
				PersonController(InterestPawn.Controller).InterestPawn = MyPawn;
				PersonController(InterestPawn.Controller).GotoStateSave('TalkingWithSomeoneSlave');
			}
			// Make them not mad, if they were
			InterestPawn.SetMood(MOOD_Normal, 1.0);
		}
		else	// he's left or something, so give up now
		{
			GotoStateSave('WaitForCustomers');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for someone standing close enough to buy something
	// or he's close enough to possibly buy something, or if he's too far
	// away so we start waiting on other customers
	///////////////////////////////////////////////////////////////////////////////
	function CheckForCustomerProx()
	{
		local float dist;
/*		
		if(InterestPawn == None)
		{
			// he's too far away, so just wait on other customers
			statecount = 1;
			return;
		}
*/
		dist = VSize(CustomerStand.Location - InterestPawn.Location);
		//log(MyPawn$" customer prox "$dist$" needed radius "$2*CustomerStand.CollisionRadius$" interest "$InterestPawn);
		
		if(dist <= CustomerStand.CollisionRadius + InterestPawn.CollisionRadius)
			statecount = 2; // he's ready to buy things again
		else if(dist < 2*CustomerStand.CollisionRadius)// + 2*InterestPawn.CollisionRadius)
			statecount = 0; // he might come back so wait some
		else 
			// he's too far away, so just wait on other customers
			statecount = 1;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Dude walked away or something
	///////////////////////////////////////////////////////////////////////////////
	function ThisPersonLeftYouWhileHandling(P2Pawn CheckA)
	{
		if(InterestPawn == CheckA)
			GotoState(GetStateName(), 'WatchForCustomerReturn');
			//GotoStateSave('WaitForCustomers');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Disconnect the person talking to us
	///////////////////////////////////////////////////////////////////////////////
	function Cleanup()
	{
		local LambController lambc; 

		if(InterestPawn != None
			&& CashierController(InterestPawn.Controller) == None
			&& InterestPawn.Controller.IsInState('TalkingWithSomeoneMaster'))
		{
			InterestPawn2 = InterestPawn;

			lambc = LambController(InterestPawn.Controller);

			if(lambc.Attacker == None)
			{
				if(lambc.CurrentInterestPoint != None)
				{
					if(lambc.GetStateName() != 'CheckInterestForCommand')
						lambc.GotoStateSave('CheckInterestForCommand');
				}
				else
					lambc.GotoStateSave('Thinking');
			}
		}
	}

	function EndState()
	{
		Super.EndState();
		InterestInventoryClass = default.InterestInventoryClass;
	}
	function BeginState()
	{
		bResetInterests=true;
		PossibleCutter=None;
		LastNPCCustomer=P2MocapPawn(InterestPawn);
		Super.BeginState();
		//log(MyPawn$" trying to talk to "$InterestPawn);
	}

WatchForCustomerReturn:
	// assigns statecount, we can't change states in a function that returns a variable
	CheckForCustomerProx();
	if(statecount == 2)
		Goto('Begin'); // he's ready to buy things again
	else if(statecount == 1)
	{
		Cleanup();
		GotoStateSave('WaitForCustomers');// he's too far away, so just wait on other customers
	}

	Sleep(1.0);
	Goto('WatchForCustomerReturn');

Begin:
	SetupCustomer();

	// customer says hi
	TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
	PrintDialogue(InterestPawn$" Greeting");
	Sleep(SayTime);

	// cashier says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// NICETIES exchange
	// We can potentially get into a lengthy and boring exchange of back and forth niceties
	if(FRand() <= HowAreYouFreq)
	{
		if(FRand() <= 0.5)
		{
			// customer asks how the cashier is doing
			TalkSome(CustomerPawn.myDialog.lGreetingquestions, CustomerPawn);
			PrintDialogue(InterestPawn$" how are you?");
			Sleep(SayTime);

			// cashier responds greeting
			TalkSome(MyPawn.myDialog.lRespondToGreeting);
			PrintDialogue("fine thanks.");
			Sleep(SayTime);

			// customer says that's good to hear
			TalkSome(CustomerPawn.myDialog.lRespondtoGreetingResponse, CustomerPawn);
			PrintDialogue(InterestPawn$" That's good to hear");
			Sleep(SayTime);
		}
		else
		{
			// cashier asks the customer how he's doing
			TalkSome(MyPawn.myDialog.lGreetingquestions);
			PrintDialogue("So, how are you?");
			Sleep(SayTime);

			// customer responds greeting
			TalkSome(CustomerPawn.myDialog.lRespondToGreeting, CustomerPawn);
			PrintDialogue(InterestPawn$" fine thanks");
			Sleep(SayTime);

			// cashier says that's good to hear
			TalkSome(MyPawn.myDialog.lRespondtoGreetingResponse);
			PrintDialogue(" well that's good to hear.");
			Sleep(SayTime);
		}
	}


	// cashier asks if this is all
	PrintDialogue("Is this everything?");
	TalkSome(MyPawn.myDialog.lIsThisEverything);
	Sleep(SayTime);

	// customer says yes
	PrintDialogue(InterestPawn$" yes");
	TalkSome(CustomerPawn.myDialog.lYes, CustomerPawn);
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = DecideCustomerMoney();
	PrintDialogue("that'll be...");
	SayTime = Say(MyPawn.myDialog.lNumbers_Thatllbe);
	Sleep(SayTime);
	SayTime = SayThisNumber(statecount);
	PrintDialogue(statecount$" bucks");
	Sleep(SayTime + 0.1);
	if(statecount > 1)
		SayTime = Say(MyPawn.myDialog.lNumbers_Dollars);
	else

		SayTime = Say(MyPawn.myDialog.lNumbers_SingleDollar);
	Sleep(SayTime + FRand());


	// Decide here to buy the thing or not

	// customer refuses sale
	if(FRand() <=  CustomerDoesntBuy)
	{
		// Customer complains about money
		// Make them mad
		InterestPawn.SetMood(MOOD_Angry, 1.0);
		PrintDialogue(InterestPawn$" no way!");
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lContestStoreTransaction);
		// now gesture
		P2MoCapPawn(InterestPawn).PlayTellOffAnim();
		// sleep the rest
		Sleep(SayTime);

		// cashier tries to calm them down
		PrintDialogue("calm down");
		SayTime = Say(MyPawn.myDialog.lRowdyCustomer);
		Sleep(SayTime + FRand());

		// customer gets mad
		PrintDialogue(InterestPawn$" screw you!");
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lDefiant);
		// now gesture
		P2MoCapPawn(InterestPawn).PlayTellOffAnim();
		Sleep(SayTime+FRand());

		// if you have a weapon, start fighting
//		if(
	}
	else
		// Customer accepts sale
	{
		// Show customer handing over money
		PersonController(CustomerPawn.Controller).InterestInventoryClass = class'MoneyInv';
		InterestInventoryClass = class'MoneyInv';
		CustomerPawn.PlayGiveGesture();
		// customer gives them the money
		PrintDialogue(InterestPawn$" here's the money");
		TalkSome(CustomerPawn.myDialog.lConsumerBuy, CustomerPawn);
		Sleep(1.0);
		// Show cashier grabbing
		MyPawn.PlayTakeGesture();
		Sleep(SayTime - 1.0);

		// cashier says thanks
		PrintDialogue("Thanks for the payment");
		TalkSome(MyPawn.myDialog.lSellingItem);
		Sleep(SayTime);

		// Show cashier handing over item
		PersonController(CustomerPawn.Controller).InterestInventoryClass = MyCashReg.ItemGiven;
		InterestInventoryClass = MyCashReg.ItemGiven;
		MyPawn.PlayGiveGesture();
		Sleep(1.0);
		CustomerPawn.PlayTakeGesture();
		//GiveCustomerItem();

		// customer gives them the money
		PrintDialogue(InterestPawn$" thanks!");
		TalkSome(CustomerPawn.myDialog.lThanks, CustomerPawn);
		Sleep(2*SayTime);
	}

	// return to handling the cash register
	Cleanup();
	GotoStateSave('WaitForCustomers');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ExchangeWithDude
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ExchangeWithDude
{
	ignores TryToGreetPasserby, PerformInterestAction, CheckDesiredThing, DonateSetup,
		WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// I'll take the next person in line, please
	// Turn away ai characters when talking
	///////////////////////////////////////////////////////////////////////////////
	function bool HandleNextPerson(P2Pawn CheckA)
	{
		local PersonController per;
		// send unhandled entries to this back to thinking
		if(CheckA != None)
		{
			per = PersonController(CheckA.Controller);
			if(per != None
				&& per.Attacker == None)
			{
				if(per.CurrentInterestPoint != None)
				{
					if(per.GetStateName() != 'CheckInterestForCommand')
						per.GotoStateSave('CheckInterestForCommand');
				}
				//else // This was bad.. it sometimes sent them into a constant loop
				// of walking away, but getting put back into thinking
				//	per.GotoStateSave('Thinking');
				return true;
			}
		}
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Someone is in front of me, trying to get my attention
	// Turn away ai characters when talking
	///////////////////////////////////////////////////////////////////////////////
	function HandleThisPerson(P2Pawn CheckA)
	{
		local PersonController per;
		
		// Don't talk to your attacker
		if(CheckA == Attacker)
			return;

		//log(self$" ExchangeWithDude HandleThisPerson "$CheckA);
		// send unhandled entries to this back to thinking
		if(CheckA != None
			&& LastNPCCustomer != CheckA)
		{
			per = PersonController(CheckA.Controller);
			if(per != None
				&& per.Attacker == None)
			{
				if(per.CurrentInterestPoint != None)
				{
					if(per.GetStateName() != 'CheckInterestForCommand')
						per.GotoStateSave('CheckInterestForCommand');
				}
				//else // This was bad.. it sometimes sent them into a constant loop
				// of walking away, but getting put back into thinking
				//	per.GotoStateSave('Thinking');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// setup dude to deal with the cashier
	///////////////////////////////////////////////////////////////////////////////
	function SetupCustomer()
	{
		SetupDudeCustomer();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for someone standing close enough to buy something
	// or he's close enough to possibly buy something, or if he's too far
	// away so we start waiting on other customers
	///////////////////////////////////////////////////////////////////////////////
	function CheckForCustomerProx()
	{
		local float dist;
/*		
		if(InterestPawn == None)
		{
			// he's too far away, so just wait on other customers
			statecount = 1;
			return;
		}
*/
		dist = VSize(CustomerStand.Location - InterestPawn.Location);
		
		if(dist <= CustomerStand.CollisionRadius)
			statecount = 2; // he's ready to buy things again
		else if(dist < CustomerStand.CollisionRadius + 2*MyPawn.CollisionRadius)
			statecount = 0; // he might come back so wait some
		else 
			// he's too far away, so just wait on other customers
			statecount = 1;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Dude walked away or something
	///////////////////////////////////////////////////////////////////////////////
	function ThisPersonLeftYouWhileHandling(P2Pawn CheckA)
	{
		if(InterestPawn == CheckA)
		{
			GotoState(GetStateName(), 'WatchForCustomerReturn');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();
		Focus = InterestPawn;
		bResetInterests=true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// // Unhook me from the dude controller
	///////////////////////////////////////////////////////////////////////////////
	function Cleanup()
	{
		local P2Player aplayer;

		aplayer = P2Player(InterestPawn.Controller);

		// Unhook me from the dude controller
		aplayer.InterestPawn = None;
		aplayer.bDealingWithCashier=false;

		MyQPoint.ClearCutter(InterestPawn);
	}

WatchForCustomerReturn:
	// assigns statecount, we can't change states in a function that returns a variable
	CheckForCustomerProx();
	if(statecount == 2)
		Goto('Begin'); // he's ready to buy things again
	else if(statecount == 1)
	{
		Cleanup();
		GotoStateSave('WaitForCustomers');// he's too far away, so just wait on other customers
	}
	Sleep(1.0);
	Goto('WatchForCustomerReturn');

Begin:
	SetupCustomer();

	// if he doesn't have your product
	if(HasYourProduct(P2Pawn(InterestPawn), MyPawn) == None)
	{
		bResetInterests=false;
		GotoState('DudeHasNoItem');
	}
	else // he does, then check him for cash!
	{
		bResetInterests=false;
		// Check if you have enough money or not
		if(P2Pawn(InterestPawn).HowMuchInventory(class'MoneyInv') <= 0)
		{
			GotoState('DudeHasNoFunds');
		}
		else
		{
			GotoState('WaitOnDudeToPay');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TalkingToDudeMaster
// You talk to the dude and drive the conversation
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TalkingToDudeMaster extends TalkingWithSomeoneMaster
{
	ignores WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Only giggle at dude if he's wearing the Gimp outfit
	///////////////////////////////////////////////////////////////////////////////
	function bool CheckToGiggle()
	{
		if(InterestPawn != None
			&& PersonDressedAsGimp(InterestPawn))
		{
			// cashier giggles at you
			TalkSome(MyPawn.myDialog.lSnickering);
			PrintDialogue("giggling");
			return true;
		}
		else
			return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// I'll take the next person in line, please
	// Turn away ai characters when talking
	///////////////////////////////////////////////////////////////////////////////
	function bool HandleNextPerson(P2Pawn CheckA)
	{
		//log(self$" TalkingToDudeMaster HandleNextPerson "$CheckA);
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Someone is in front of me, trying to get my attention
	// Turn away ai characters when talking
	///////////////////////////////////////////////////////////////////////////////
	function HandleThisPerson(P2Pawn CheckA)
	{
		local PersonController per;
		//log(self$" TalkingToDudeMaster HandleThisPerson "$CheckA);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Dude walked away or something
	///////////////////////////////////////////////////////////////////////////////
	function ThisPersonLeftYouWhileHandling(P2Pawn CheckA)
	{
		if(InterestPawn == CheckA)
		{
			// Trigger events
			if (MyCashReg != None)
			{
				TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
				TriggerEvent(MyCashReg.TriggerAfterDudeDoesntPay, MyPawn, InterestPawn);
			}
			GotoState('WaitForCustomers');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Unhook me from the dude controller
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		local P2Player aplayer;

		Super.EndState();

		//log(MyPawn$" told me it's over "$InterestPawn);
		if(InterestPawn != None)
		{
			InterestPawn2 = InterestPawn;

			aplayer = P2Player(InterestPawn.Controller);
			if(aplayer != None)
			{
				// Unhook me from the dude controller
				aplayer.InterestPawn = None;
				aplayer.bDealingWithCashier=false;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DudeHasNoItem
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DudeHasNoItem extends TalkingToDudeMaster
{
	ignores AcceptItem;

Begin:
	if(CheckToGiggle())
		Sleep(SayTime);

	// cashier says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// dude says hi
	PrintDialogue(InterestPawn$" greeting ");
	TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
	Sleep(SayTime);

	// Comment that you don't have anything to do a deal with yet
	// cashier says hmmm
	PrintDialogue("hmmm");
	SayTime = Say(MyPawn.myDialog.lHmm, bImportantDialog);
	Sleep(SayTime + FRand());

	// Teller asks how she can help you
	PrintDialogue("can i help you? you don't have anything to buy");
	TalkSome(MyPawn.myDialog.lCanIHelpYou);
	Sleep(SayTime);

	// Dude apologizes for showing up without anything
	PrintDialogue(InterestPawn$" dude sorry");
	TalkSome(CustomerPawn.myDialog.lApologize, CustomerPawn);
	Sleep(SayTime);

	// Trigger events
	if (MyCashReg != None)
	{
		TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
		TriggerEvent(MyCashReg.TriggerAfterDudeDoesntPay, MyPawn, InterestPawn);
	}

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitOnDudeToPay
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitOnDudeToPay extends TalkingToDudeMaster
{
	///////////////////////////////////////////////////////////////////////////////
	// Dude walked away or something
	///////////////////////////////////////////////////////////////////////////////
	function ThisPersonLeftYouWhileHandling(P2Pawn CheckA)
	{
		if(InterestPawn == CheckA)
			GotoState('ExchangeWithDude', 'WatchForCustomerReturn');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Unhook me from the dude controller and update their inventory item
	// Make sure you DON'T unhook our interestpawn from this guy just yet
	// or the order won't update the inventory item correctly.
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		if(InterestPawn != None
			&& P2Player(InterestPawn.Controller) != None)
			P2Player(InterestPawn.Controller).UpdateHudInvHints();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Tell the user how to use his item
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		if(InterestPawn != None
			&& P2Player(InterestPawn.Controller) != None)
			P2Player(InterestPawn.Controller).UpdateHudInvHints();
	}
Begin:
	if(CheckToGiggle())
		Sleep(SayTime);
		
	// Trigger events
	if (MyCashReg != None)
		TriggerEvent(MyCashReg.TriggerBeforeDudeUse, MyPawn, InterestPawn);

	// cashier says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// dude says hi
	PrintDialogue(InterestPawn$" greeting ");
	TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
	Sleep(SayTime);

	// cashier asks how to help you
	PrintDialogue("Is this everything?");
	TalkSome(MyPawn.myDialog.lIsThisEverything);
	Sleep(SayTime);

	// dude says yes
	PrintDialogue(InterestPawn$" dude yes");
	TalkSome(CustomerPawn.myDialog.lYes, CustomerPawn);
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	PrintDialogue("that'll be...");
	SayTime = Say(MyPawn.myDialog.lNumbers_Thatllbe, bImportantDialog);
	Sleep(SayTime);
	statecount = MyPawn.MyDialog.GetValidNumber(statecount,statecount);
	SayTime = SayThisNumber(statecount,,bImportantDialog);
	PrintDialogue(statecount$" bucks");
	Sleep(SayTime + 0.1);
	if(statecount > 1)
		SayTime = Say(MyPawn.myDialog.lNumbers_Dollars, bImportantDialog);
	else

		SayTime = Say(MyPawn.myDialog.lNumbers_SingleDollar, bImportantDialog);
	Sleep(SayTime + FRand());

	// Wait on dude to pay you for the thing
	//log("waiting on the money");
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DudeHasInsufficientFunds
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DudeHasInsufficientFunds extends TalkingToDudeMaster
{
	ignores AcceptItem;

Begin:
	if(CheckToGiggle())
		Sleep(SayTime);

	// cashier ays hmmm
	PrintDialogue("hmmm");
	SayTime = Say(MyPawn.myDialog.lHmm, bImportantDialog);
	Sleep(SayTime + FRand());

	// tell them they lack the money
	TalkSome(MyPawn.myDialog.lLackOfMoney);
	Sleep(SayTime);
	PrintDialogue("Insufficient funds!");

	// Dude apologizes for showing up without anything
	PrintDialogue(InterestPawn$" dude sorry or mad");
	if(FRand() > DudeGetsMad)
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lApologize, bImportantDialog);
	else
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lNegativeResponseCashier, bImportantDialog);
	Sleep(SayTime + FRand());

	// Trigger events
	if (MyCashReg != None)
	{
		TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
		TriggerEvent(MyCashReg.TriggerAfterDudeDoesntPay, MyPawn, InterestPawn);
	}
	//lLackOfMoney

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DudeHasNoFunds
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DudeHasNoFunds extends TalkingToDudeMaster
{
Begin:
	if(CheckToGiggle())
		Sleep(SayTime);

	// cashier says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// dude says hi
	PrintDialogue(InterestPawn$" greeting ");
	TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	PrintDialogue("that'll be...");
	SayTime = Say(MyPawn.myDialog.lNumbers_Thatllbe, bImportantDialog);
	Sleep(SayTime);
	SayTime = SayThisNumber(statecount,,bImportantDialog);
	PrintDialogue(statecount$" bucks");
	Sleep(SayTime + 0.1);
	if(statecount > 1)
		SayTime = Say(MyPawn.myDialog.lNumbers_Dollars, bImportantDialog);
	else

		SayTime = Say(MyPawn.myDialog.lNumbers_SingleDollar, bImportantDialog);
	Sleep(SayTime + FRand());

	// cashier ays hmmm
	PrintDialogue("hmmm");
	SayTime = Say(MyPawn.myDialog.lHmm, bImportantDialog);
	Sleep(SayTime + FRand());

	// say something mean
	TalkSome(MyPawn.myDialog.lLackOfMoney);
	Sleep(SayTime);
	PrintDialogue("Insufficient funds, buy something!");

	// Dude apologizes
	PrintDialogue(InterestPawn$" dude sorry");
	TalkSome(CustomerPawn.myDialog.lApologize, CustomerPawn);
	Sleep(SayTime);

	// Dude needs more money
	PrintDialogue(InterestPawn$" i need more money");
	TalkSome(CustomerPawn.myDialog.lLackOfMoney, CustomerPawn);
	Sleep(SayTime);

	// Trigger events
	if (MyCashReg != None)
	{
		TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
		TriggerEvent(MyCashReg.TriggerAfterDudeDoesntPay, MyPawn, InterestPawn);
	}

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TakePaymentFromDude
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakePaymentFromDude extends TalkingToDudeMaster
{
	ignores ForceGetDown, AcceptItem;

	///////////////////////////////////////////////////////////////////////////////
	// Check to make the item he has paid for
	///////////////////////////////////////////////////////////////////////////////
	function FinishTransaction()
	{
		local OwnedInv owninv;

		owninv = OwnedInv(HasYourProduct(P2Pawn(InterestPawn), MyPawn));

		if(owninv != None)
		{
			// set it to paid for
			owninv.BuyIt(P2Pawn(InterestPawn));
		}
	}
Begin:
	FinishTransaction();
	// Show cashier grabbing
	MyPawn.PlayTakeGesture();
	// cashier says thanks
	TalkSome(MyPawn.myDialog.lSellingItem);
	Sleep(SayTime);
	PrintDialogue("Thanks for the payment");

	// dude sort of says you're welcome
	if(FRand() <= 0.5)
	{
		PrintDialogue(InterestPawn$"dude you're welcome");
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lPositiveResponse);
		Sleep(SayTime + FRand());
	}

	Sleep(DudePaidWaitTime);

	// Trigger events
	if (MyCashReg != None)
	{
		TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
		TriggerEvent(MyCashReg.TriggerAfterDudePays, MyPawn, InterestPawn);
	}

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

defaultproperties
{
	SwitchWeaponFreq=0.0
	bResetInterests=true
	CustomerDoesntBuy=0.1
	HowAreYouFreq=0.25
	DudeGetsMad=0.5
	DudePaidWaitTime=2.0
}