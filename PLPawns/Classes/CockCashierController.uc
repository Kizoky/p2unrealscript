///////////////////////////////////////////////////////////////////////////////
// CockCashierController
// Copyright 2014 RWS, Inc.  All Rights Reserved.
//
// Cock Asian fast food cashier controller.
//
///////////////////////////////////////////////////////////////////////////////
class CockCashierController extends CashierDialogController;

///////////////////////////////////////////////////////////////////////////////
// ExchangeGoodsAndServices
///////////////////////////////////////////////////////////////////////////////
state ExchangeGoodsAndServices
{
	///////////////////////////////////////////////////////////////////////////////
	// The customer picks a meal deal
	///////////////////////////////////////////////////////////////////////////////
	function int PickDealNumber()
	{
		return MyPawn.MyDialog.GetValidNumber(,MyCashReg.DealNumberMax);
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

	// NICETIES exchange
	// We can potentially get into a lengthy and boring exchange of back and forth niceties
	// COCK ASIAN: Higher chance of niceties
	if(FRand() <= 0.66)
	{
		// cashier says hi
		TalkSome(MyPawn.myDialog.lGreeting,,true);
		PrintDialogue("Greeting");
		Sleep(SayTime);

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
	else
	{
		// COCK ASIAN: cashier says wf_helloandwelcome
		TalkSome(MyPawn.myDialog.lCockAsianWelcome,,true);
		PrintDialogue("Greeting");
		Sleep(SayTime);
	}

	// Customer hmmms while trying to decide
	PrintDialogue(InterestPawn$" Hmmmm...");
	TalkSome(CustomerPawn.myDialog.lHmm, CustomerPawn);
	Sleep(SayTime+FRand());

	// customer requests what number meal deal they want
	statecount = PickDealNumber();
	PrintDialogue(InterestPawn$" i'll take a number...");
	TalkSome(CustomerPawn.myDialog.lilltakenumber, CustomerPawn);
	Sleep(SayTime);
	SayTime = CustomerPawn.SayThisNumber(statecount, true);
	PrintDialogue(InterestPawn$""$statecount);
	Sleep(SayTime + FRand());

	// COCK ASIAN: cashier says wf_mayilargifythat
	TalkSome(MyPawn.myDialog.lCockAsianLargify,,true);
	PrintDialogue("Largify question");
	Sleep(SayTime);

	// COCK ASIAN: customer thinks about whether or not to largify
	if(FRand() <= 0.5)
	{
		PrintDialogue(InterestPawn$" Do I want to largify that?");
		TalkSome(CustomerPawn.myDialog.lHmm, CustomerPawn);
		Sleep(SayTime+FRand());
	}

	// COCK ASIAN: customer decides to largify or not
	if(FRand() <= 0.5)
	{
		PrintDialogue(InterestPawn$" Yes, I'll largify that");
		TalkSome(CustomerPawn.myDialog.lyes, CustomerPawn);
		Sleep(SayTime+FRand());
	}
	else
	{
		PrintDialogue(InterestPawn$" No, I won't largify that");
		TalkSome(CustomerPawn.myDialog.lno, CustomerPawn);
		Sleep(SayTime);

		// COCK ASIAN: cashier apologizes due to customer not accepting largification
		TalkSome(MyPawn.myDialog.lApologize,,true);
		PrintDialogue("Sorry about not largifying");
		Sleep(SayTime+FRand());
	}

	// COCK ASIAN: cashier says wf_pleasehelpyourself
	TalkSome(MyPawn.myDialog.lCockAsianCondiments,,true);
	PrintDialogue("Offers condiments");
	Sleep(SayTime);

	// COCK ASIAN: customer thinks about condiments because he's a jackass
	if(FRand() <= 0.33)
	{
		PrintDialogue(InterestPawn$" Do I want to largify that?");
		TalkSome(CustomerPawn.myDialog.lHmm, CustomerPawn);
		Sleep(SayTime+FRand());
	}

	// COCK ASIAN: customer responds positively or negatively to condiments
	if(FRand() <= 0.66)
	{
		PrintDialogue(InterestPawn$" Thanks for the condiments");
		TalkSome(CustomerPawn.myDialog.lThatsGreat, CustomerPawn);
		Sleep(SayTime+FRand());
	}
	else
	{
		PrintDialogue(InterestPawn$" No, I don't want free condiments");
		TalkSome(CustomerPawn.myDialog.lno, CustomerPawn);
		Sleep(SayTime);

		// COCK ASIAN: cashier apologizes due to customer not accepting condiments
		TalkSome(MyPawn.myDialog.lApologize,,true);
		PrintDialogue("Sorry about not taking condiments");
		Sleep(SayTime+FRand());
	}

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
	// COCK ASIAN: Slightly higher chance of customer rejecting sale
	if(FRand() <= 0.33)
	{
		// customer complains about money
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

		// customer gives them the money
		PrintDialogue(InterestPawn$" screw you!");
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lDefiant);
		// now gesture
		P2MoCapPawn(InterestPawn).PlayTellOffAnim();
		Sleep(SayTime+FRand());

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
		// COCK ASIAN: cashier says to enjoy meal wf_hereyouareenjoy
		PersonController(CustomerPawn.Controller).InterestInventoryClass = MyCashReg.ItemGiven;
		InterestInventoryClass = MyCashReg.ItemGiven;
		MyPawn.PlayGiveGesture();
		PrintDialogue("here's your food");
		SayTime = Say(MyPawn.myDialog.lCockAsianEnjoyMeal);
		Sleep(SayTime);
		// Show the customer grabbing the item
		CustomerPawn.PlayTakeGesture();
		// STUB do not actually give them the fast food, have them eat it on the spot
		//GiveCustomerItem();

		// Customer says thanks
		PrintDialogue(InterestPawn$" thanks!");
		TalkSome(CustomerPawn.myDialog.lThanks, CustomerPawn);
		Sleep(SayTime);

		// COCK ASIAN: cashier invites customer to have a nice day and come again
		PrintDialogue("have a nice day!");
		SayTime = Say(MyPawn.myDialog.lCockAsianHAND);
		Sleep(SayTime + FRand());
	}

	// return to handling the cash register
	Cleanup();
	GotoStateSave('WaitForCustomers');
}

defaultproperties
{
	DudePaidWaitTime=1.0
}
