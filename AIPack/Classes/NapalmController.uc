///////////////////////////////////////////////////////////////////////////////
// NapalmController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// Receptionist at napalm facility. She just takes the money. You must
// find the napalm pickup.
//
///////////////////////////////////////////////////////////////////////////////
class NapalmController extends CashierController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars
var bool bDudeHasPaid;	// If the dude has paid us or not

// Internal vars
var name ErrandEvent1;		// Event specific to this guy that he triggers 
							// after successfully taking money from the dude

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Make her get mad and call the police, because we're walking back where we
// aren't supposed to be and we haven't paid
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	if(!bDudeHasPaid)
	{
		SetToPanic();	
		GotoNextState();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Since CheckP isn't bringing us the item, we're supplying that, we'll just
// check the price on it, in our cash register point.
///////////////////////////////////////////////////////////////////////////////
function float GetTotalCostOfYourProducts(P2Pawn CheckP, P2Pawn OrigOwner)
{
//	log("total cost is "$MyCashReg.ItemCostMax);
	return MyCashReg.ItemCostMax;
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

	// Since no product is exchanged here, we always 'have the product', we just might
	// not have the money for the product that is picked up later
	// if he doesn't have your product
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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DudeHasInsufficientFunds
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DudeHasNoFunds
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

	// dude says he wants some napalm
	PrintDialogue(InterestPawn$" i want napalm");
	TalkSome(CustomerPawn.myDialog.lDude_BuyNapalm, CustomerPawn);
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

	// Wait on dude to pay you for the thing
	log("waiting on the money");

	// dude says something negative
	PrintDialogue(InterestPawn$" something negative ");
	TalkSome(CustomerPawn.myDialog.lNegativeResponseCashier, CustomerPawn);
	Sleep(SayTime);

	// cashier ays hmmm
	PrintDialogue("hmmm");
	TalkSome(MyPawn.myDialog.lHmm);
	Sleep(SayTime);

	// say something mean
	TalkSome(MyPawn.myDialog.lLackOfMoney);
	Sleep(SayTime);
	PrintDialogue("Insufficient funds, buy something!");

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
state WaitOnDudeToPay
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

	// dude says he wants some napalm
	PrintDialogue(InterestPawn$" i want napalm");
	TalkSome(CustomerPawn.myDialog.lDude_BuyNapalm, CustomerPawn);
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

	// Wait on dude to pay you for the thing
	log("waiting on the money");
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TakePaymentFromDude
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakePaymentFromDude
{
	///////////////////////////////////////////////////////////////////////////////
	// No matter what, he paid
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		bDudeHasPaid=true;
		
		// Trigger an event for cops to be turned off, since you correctly paid
		TriggerEvent(ErrandEvent1, InterestPawn, InterestPawn);

		Super.EndState();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Mark him early, with being paid, in case he wanders away, but close by,
	// which would keep her in this state (thus no above, EndState) but possibly
	// allowing him to cross a trigger making her mad if you haven't paid yet.
	///////////////////////////////////////////////////////////////////////////////
	function FinishTransaction()
	{
		Super.FinishTransaction();
		bDudeHasPaid=true;
	}
Begin:
	FinishTransaction();
	// cashier says thanks
	TalkSome(MyPawn.myDialog.lNapalm_Directions);
	Sleep(SayTime);
	PrintDialogue("napalm is down the hall");

	// dude sort of says you're welcome
	PrintDialogue(InterestPawn$"dude you're welcome");
	SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lPositiveResponse);
	Sleep(SayTime + FRand());

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

defaultproperties
{
	ErrandEvent1="NapalmPaidFor"
}