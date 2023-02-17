///////////////////////////////////////////////////////////////////////////////
// ChemicalCashierController
// Copyright 2014, Running With Scissors, Inc.
//
// This is a more specialized version of the Waiting Room Cashier, for the
// Panther Pilsner chemical errand.
///////////////////////////////////////////////////////////////////////////////
class ChemicalCashierController extends WaitingRoomCashierController;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DudeHasNoTicket
// Wave them over to the ticket machine
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DudeHasNoTicket
{
Begin:
	// Unlike super, the Dude pipes up first before the cashier waves them away.

	// Dude says he needs the chemicals
	PrintDialogue(InterestPawn$" I need ensmallen cure chemicals");
	TalkSome(CustomerPawn.myDialog.lDude_WantsChems, CustomerPawn,true);
	Sleep(SayTime);

	// Gesture angry
	MyPawn.PlayPointThatWayAnim();

	if(FPSPawn(Focus).bPlayer)
		bImportantDialog=true;
	PrintDialogue("You don't have a ticket, go away"$Focus);
	SayTime = Say(MyPawn.myDialog.lCashier_PleaseTakeATicket, bImportantDialog);
	Sleep(SayTime + FRand());
	
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

	// Dude says he needs the chemicals
	PrintDialogue(InterestPawn$" Can I finally buy those chems now");
	TalkSome(CustomerPawn.myDialog.lDude_FinallyBuy, CustomerPawn,true);
	Sleep(SayTime);

	// cashier states how much it will be
	PrintDialogue("that'll be a thousand dollars");
	SayTime = Say(MyPawn.myDialog.lChemCashier_ThatllBe, bImportantDialog);
	Sleep(SayTime + Frand());
	
	// Dude balks
	PrintDialogue(InterestPawn$" That's crazy");
	TalkSome(CustomerPawn.myDialog.lDude_ThatsOutrageous, CustomerPawn,true);
	Sleep(SayTime);
	
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
	// Show cashier grabbing
	MyPawn.PlayTakeGesture();
	// cashier says thanks
	TalkSome(MyPawn.myDialog.lChemCashier_ThankYou);
	Sleep(SayTime);
	PrintDialogue("Thanks for the payment");

	// Show cashier handing over item
	InterestInventoryClass = MyCashReg.ItemGiven;
	MyPawn.PlayGiveGesture();

	//FinishTransaction();

	// dude is pretty angry
	if(FRand() <= 0.5)
	{
		PrintDialogue(InterestPawn$"dude fuck you");
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lNegativeResponse);
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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Now Serving - Announce that it's the dude's turn to pay
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NowServing
{
Begin:
	// Gesture for them to come forward
	bAnnouncedNumber=true;
	MyPawn.PlayHelloGesture(1.0);
	SayTime = Say(MyPawn.myDialog.lCashier_NowServing, bImportantDialog);
	PrintDialogue("I can help you over here..."$InterestPawn);
	Sleep(SayTime + FRand()*4*SayTime + 1.0);
	GotoState('WaitForCustomers');	
}

defaultproperties
{
	DudeGetsMad=1.0
	DudePaidWaitTime=1.0
}