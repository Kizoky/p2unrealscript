///////////////////////////////////////////////////////////////////////////////
// LaundryController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for cashier at laundramat.
//
//
///////////////////////////////////////////////////////////////////////////////
class LaundryController extends FFCashierController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DudeHasNoFunds
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DudeHasNoFunds
{
Begin:
	// dude says hi
	PrintDialogue(InterestPawn$" greeting ");
	TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
	Sleep(SayTime);

	if(CheckToGiggle())
		Sleep(SayTime);

	// cashier says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// Teller asks how she can help you
	PrintDialogue("can i help you?");
	TalkSome(MyPawn.myDialog.lCanIHelpYou);
	Sleep(SayTime);

	// dude says i'm here to get my clothes
	PrintDialogue(InterestPawn$" dude give me my clothes");
	TalkSome(CustomerPawn.myDialog.lDude_GetNormalClothes, CustomerPawn);
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	// if there's no money then something's wrong, he doesn't have his item any more
	if(statecount == 0)
		GotoState('DudeHasNoItem');

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

	// Dude needs more money
	PrintDialogue(InterestPawn$" i need more money");
	TalkSome(CustomerPawn.myDialog.lLackOfMoney, CustomerPawn);
	Sleep(SayTime);

	// say something mean
	TalkSome(MyPawn.myDialog.lLackOfMoney);
	Sleep(SayTime);
	PrintDialogue("Insufficient funds, buy something!");

	// Dude apologizes
	PrintDialogue(InterestPawn$" dude sorry");
	TalkSome(CustomerPawn.myDialog.lApologize, CustomerPawn);
	Sleep(SayTime);


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
	// dude says hi
	PrintDialogue(InterestPawn$" greeting ");
	TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
	Sleep(SayTime);

	if(CheckToGiggle())
		Sleep(SayTime);

	// cashier says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// Teller asks how she can help you
	PrintDialogue("can i help you?");
	TalkSome(MyPawn.myDialog.lCanIHelpYou);
	Sleep(SayTime);

	// dude says i'm here to get my clothes
	PrintDialogue(InterestPawn$" dude give me my clothes");
	TalkSome(CustomerPawn.myDialog.lDude_GetNormalClothes, CustomerPawn);
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	// if there's no money then something's wrong, he doesn't have his item any more
	if(statecount == 0)
		GotoState('DudeHasNoItem');

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

	// dude says something negative
	PrintDialogue(InterestPawn$" something negative ");
	TalkSome(CustomerPawn.myDialog.lNegativeResponseCashier, CustomerPawn);
	Sleep(SayTime);

	log("waiting on the money");
	// Wait on dude to pay you for the thing
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
Begin:
	FinishTransaction();

	// cashier says thanks
	TalkSome(MyPawn.myDialog.lSellingItem);
	Sleep(SayTime);
	PrintDialogue("Thanks for the payment");

	// cashier giggles again
	if(CheckToGiggle())
	{
		Sleep(SayTime);

		// Dude retorts
		PrintDialogue(InterestPawn$"dude how would you like it, if someone called you a lunatic");
		TalkSome(CustomerPawn.myDialog.lDude_RetortToNameCalling, CustomerPawn);
		Sleep(SayTime);

		// cashier calls you a freak
		TalkSome(MyPawn.myDialog.lApologize);
		Sleep(SayTime);
		PrintDialogue("i'm sorry...");
	}

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

defaultproperties
{
}