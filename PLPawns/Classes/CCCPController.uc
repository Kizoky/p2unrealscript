///////////////////////////////////////////////////////////////////////////////
// CCCPController
// Copyright 2014, Running With Scissors, Inc.
//
// Controller for CCCP guy
// We're not actually a cashier, but we act a lot like one, so it extends
// from cashier.
//
// If the Q line attached to this guy takes any regular pawns, it will act
// like a cashier for those pawns but not for the Dude
///////////////////////////////////////////////////////////////////////////////
class CCCPController extends FFCashierController;

var bool bSawDude;	// True if we talked to the dude already. Don't repeat the conversation.
var int DudeStateCount;

///////////////////////////////////////////////////////////////////////////////
// Same as super, but don't switch to the dude's money.
// We're not selling him anything.
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
	}
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

	// With these cashiers, you don't have to bring the product to them, you go to them
	// and ask for it. They give the product and you give them the money.
	bResetInterests=false;
	// Just talk to the dude, like normal
	if (bSawDude)
		GotoState('RepeatDudeVisit');
	else
		GotoState('TakePaymentFromDude');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RepeatDudeVisit
// Dude came back, maybe remind him where he should go? It's not that hard.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RepeatDudeVisit extends TalkingToDudeMaster
{
Begin:
	// Guy suggests the kennels
	PrintDialogue("You should check the kennels");
	TalkSome(MyPawn.myDialog.lCCCP_CheckKennels,,true);
	Sleep(SayTime);
	
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
state TakePaymentFromDude
{
	// Don't hand over any items, we're not an actual cashier
	function FinishTransaction();
	
Begin:
	if (DudeStateCount == 0)
	{
		// Guy says hi
		PrintDialogue("Welcome to CCCP");
		TalkSome(MyPawn.myDialog.lCCCP_Cashier_Welcome,,true);
		Sleep(SayTime);
		DudeStateCount = 1;
	}
	
	if (DudeStateCount == 1)
	{
		// Corey Dude asks about ostriches
		PrintDialogue(InterestPawn$" <Corey Dude> I'm looking for ostriches ");
		TalkSome(CustomerPawn.myDialog.lCCCP_CoreyDude_Ostriches, CustomerPawn, true);
		Sleep(SayTime);
		DudeStateCount = 2;
	}

	if (DudeStateCount == 2)
	{
		// Dude interjects, asks about Champ
		PrintDialogue(InterestPawn$" <Dude> Actually I'm looking for my lost dog");
		TalkSome(CustomerPawn.myDialog.lCCCP_Dude_LostDog, CustomerPawn, true);
		Sleep(SayTime);
		DudeStateCount = 3;
	}

	if (DudeStateCount == 3)
	{
		// Guy suggests the kennels
		PrintDialogue("You should check the kennels");
		TalkSome(MyPawn.myDialog.lCCCP_CheckKennels,,true);
		Sleep(SayTime);
		DudeStateCount = 4;
	}
	
	if (DudeStateCount == 4)
	{
		// Dude says thank you
		PrintDialogue(InterestPawn$" <Dude> thanks");
		TalkSome(CustomerPawn.myDialog.lThanks, CustomerPawn, true);
		Sleep(SayTime);
		DudeStateCount = 5;
	}
	
	bSawDude = true;
	
	Sleep(DudePaidWaitTime);

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

defaultproperties
{
	DudePaidWaitTime=1.0
}