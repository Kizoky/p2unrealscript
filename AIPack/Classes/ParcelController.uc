///////////////////////////////////////////////////////////////////////////////
// ParcelController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// This is really a handler for the clerk at the post office, but Parcel is
// easier to search for given this game's name. 
//
// She talks to you, if you give her the money, the errand is complete,
// then she gets your package.
//
///////////////////////////////////////////////////////////////////////////////
class ParcelController extends NapalmController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Make her get mad and call the police, because we're walking back where we
// aren't supposed to be and we haven't paid
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	Super(BystanderController).Trigger(Other, EventInstigator);
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

	// dude says hi
	PrintDialogue(InterestPawn$" greeting ");
	TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
	Sleep(SayTime);

	// cashier says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// dude says he wants his parcel
	PrintDialogue(InterestPawn$" i want my package");
	TalkSome(CustomerPawn.myDialog.lDude_GetPackage, CustomerPawn);
	Sleep(SayTime);

	// cashier says you have some postage due
	TalkSome(MyPawn.myDialog.lPostalReception_GotPackage1,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// dude says something negative
	PrintDialogue(InterestPawn$" something negative ");
	TalkSome(CustomerPawn.myDialog.lNegativeResponseCashier, CustomerPawn);
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

	// cashier ays hmmm
	PrintDialogue("hmmm");
	TalkSome(MyPawn.myDialog.lHmm);
	Sleep(SayTime);

	// say something mean
	PrintDialogue("Insufficient funds, buy something!");
	TalkSome(MyPawn.myDialog.lLackOfMoney);
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
	PrintDialogue("Greeting");
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	Sleep(SayTime);

	// dude says he wants his parcel
	PrintDialogue(InterestPawn$" i want my package");
	TalkSome(CustomerPawn.myDialog.lDude_GetPackage, CustomerPawn);
	Sleep(SayTime);

	// cashier says you have some postage due
	TalkSome(MyPawn.myDialog.lPostalReception_GotPackage1,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// dude says something negative
	PrintDialogue(InterestPawn$" something negative ");
	TalkSome(CustomerPawn.myDialog.lNegativeResponseCashier, CustomerPawn);
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
// This is different becuase you 'buy' the thing you're getting first, then
// she goes and gets it. But because it will blow up, we check off the
// errand as soon as you pay.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakePaymentFromDude
{
	function EndState()
	{
		EndErrand();
		Super.EndState();
	}
Begin:
	FinishTransaction();

	// cashier says thanks
	PrintDialogue("parcel is just back here");
	TalkSome(MyPawn.myDialog.lPostalReception_GotPackage2);
	Sleep(SayTime);

	// dude sort of says you're welcome
	PrintDialogue(InterestPawn$"dude okay");
	SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lPositiveResponse);
	Sleep(SayTime + FRand());

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

defaultproperties
{
}