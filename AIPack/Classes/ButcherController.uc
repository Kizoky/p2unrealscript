///////////////////////////////////////////////////////////////////////////////
// ButcherController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for cashier at Butchershop.
//
//
///////////////////////////////////////////////////////////////////////////////
class ButcherController extends FFCashierController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Make him get mad and attack, because we're walking back where we
// aren't supposed to be and we haven't paid
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	if(!MyPawn.bNoTriggerAttackPlayer)
	{
		SetToAttackPlayer(FPSPawn(Other));
		GotoNextState();
	}
}

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

	// Teller asks how she can help you
	PrintDialogue("can i help you?");
	TalkSome(MyPawn.myDialog.lCanIHelpYou);
	Sleep(SayTime);

	// dude says i'm here to buy some steaks
	PrintDialogue(InterestPawn$" dude i'd like to buy some steaks");
	TalkSome(CustomerPawn.myDialog.lDude_BuySteaks, CustomerPawn);
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	PrintDialogue("that'll be...");
	SayTime = Say(MyPawn.myDialog.lNumbers_Thatllbe, bImportantDialog);
	Sleep(SayTime);
	SayTime = SayThisNumber(statecount, ,bImportantDialog);
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

	// Teller asks how she can help you
	PrintDialogue("can i help you?");
	TalkSome(MyPawn.myDialog.lCanIHelpYou);
	Sleep(SayTime);

	// dude says i'm here to buy some steaks
	PrintDialogue(InterestPawn$" dude i'd like to buy some steaks");
	TalkSome(CustomerPawn.myDialog.lDude_BuySteaks, CustomerPawn);
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	PrintDialogue("that'll be...");
	SayTime = Say(MyPawn.myDialog.lNumbers_Thatllbe, bImportantDialog);
	Sleep(SayTime);
	SayTime = SayThisNumber(statecount, ,bImportantDialog);
	PrintDialogue(statecount$" bucks");
	Sleep(SayTime + 0.1);
	if(statecount > 1)
		SayTime = Say(MyPawn.myDialog.lNumbers_Dollars, bImportantDialog);
	else

		SayTime = Say(MyPawn.myDialog.lNumbers_SingleDollar, bImportantDialog);
	Sleep(SayTime + FRand());


	log("waiting on the money");
	// Wait on dude to pay you for the thing
}

defaultproperties
{
}