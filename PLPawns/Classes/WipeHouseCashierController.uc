///////////////////////////////////////////////////////////////////////////////
// WipeHouseCashierController
// Copyright 2014, Running With Scissors, Inc.
//
// Cashier controller for the Wipe House cashier.
// The Wipe House prices are a ripoff so everyone gets mad with them
///////////////////////////////////////////////////////////////////////////////
class WipeHouseCashierController extends VariablePriceCashierController;

var int pricecount;
var int bucks;
const PRICE_HIKE_COUNT = 'WipeHouse_Pricehikes';

///////////////////////////////////////////////////////////////////////////////
// Get price hike count
///////////////////////////////////////////////////////////////////////////////
function int GetPriceHikeCount()
{
	local GameState usegs;
	local int i;
	
	if (P2GameInfoSingle(Level.Game) != None)		
		usegs = P2GameInfoSingle(Level.Game).TheGameState;
		
	// Dig up the price hike count out of the game state
	if (usegs != None)
	{
		for (i = 0; i < usegs.GameStateVariables.Length; i++)
			if (usegs.GameStateVariables[i].VarName == PRICE_HIKE_COUNT)
				return int(usegs.GameStateVariables[i].Value);
	}
	
	// Fail
	return -1;
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
	///////////////////////////////////////////////////////////////////////////
	// Returns true if the dude is short on cash
	// (as he should be if the price hikes are working!)
	///////////////////////////////////////////////////////////////////////////
	function bool DudeHasNoMoney(Pawn CheckP, int CheckMoney)	
	{
		local Inventory Inv;
		for (Inv = CheckP.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if (MoneyInv(Inv) != None
				&& P2PowerupInv(Inv).Amount >= CheckMoney)
				return false;
		}
		return true;
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

	// Branches off here based on how many times we've had a price hike.
	if (GetPriceHikeCount() <= 1)
	{		
		// First interaction only: Corey dude pipes up
		PrintDialogue(InterestPawn$" <Corey> I'll have some asswipes");
		TalkSome(CustomerPawn.myDialog.lDude_WipeHouse, CustomerPawn,true);
		Sleep(SayTime);
	}

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	PrintDialogue("that'll be...");
	SayTime = Say(MyPawn.myDialog.lNumbers_Thatllbe, bImportantDialog);
	Sleep(SayTime);
	// BEGIN Expanded number support
	bucks = 0;
	// Hundreds
	if (statecount >= 100)
	{
		pricecount = statecount / 100;	// integer division
		pricecount *= 100;
		SayTime = SayThisNumber(MyPawn.MyDialog.GetValidNumber(pricecount, pricecount),,bImportantDialog);
		Sleep(SayTime);
		statecount -= pricecount;
		bucks = 2;
	}
	// Teens
	if (statecount >= 11 && statecount <= 19)
	{
		SayTime = SayThisNumber(MyPawn.MyDialog.GetValidNumber(statecount, statecount),,bImportantDialog);
		Sleep(SayTime);
		statecount = 0;
		bucks = 2;
	}
	// Tens
	if (statecount >= 10)
	{
		pricecount = statecount / 10;	// integer division
		pricecount *= 10;
		SayTime = SayThisNumber(MyPawn.Mydialog.GetValidNumber(pricecount, pricecount),,bImportantDialog);
		Sleep(SayTime);
		statecount -= pricecount;
		bucks = 2;
	}
	// Ones
	if (statecount >= 1)
	{
		SayTime = SayThisNumber(MyPawn.Mydialog.GetValidNumber(statecount, statecount),,bImportantDialog);
		Sleep(SayTime);
		if (bucks == 0)
			bucks = statecount;
	}
	PrintDialogue(statecount$" bucks");
	Sleep(0.1);
	if(bucks > 1)
		SayTime = Say(MyPawn.myDialog.lNumbers_Dollars, bImportantDialog);
	else
		SayTime = Say(MyPawn.myDialog.lNumbers_SingleDollar, bImportantDialog);
	Sleep(SayTime + Frand());
	// END expanded number support
	
	// If the dude is low on funds, short-circuit immediately to the insufficient funds dialog, don't wait for him to hand it over.
	if (DudeHasNoMoney(InterestPawn, GetTotalCostOfYourProducts(CustomerPawn, MyPawn)))
		GotoState('DudeHasInsufficientFunds');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DudeHasInsufficientFunds
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DudeHasInsufficientFunds
{
Begin:
	if(CheckToGiggle())
		Sleep(SayTime);

	// cashier ays hmmm
	PrintDialogue("hmmm");
	SayTime = Say(MyPawn.myDialog.lHmm, bImportantDialog);
	Sleep(SayTime);

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
	Sleep(SayTime);
	
	// Cashier suggests going to the Cash 4 Cats Vendor
	PrintDialogue("Why not try Cash 4 Cats?");
	if (GetPriceHikeCount() <= 1)
	{
		TalkSome(MyPawn.MyDialog.lWipeHouse_PriceHike1);
		Sleep(SayTime);

		PrintDialogue(InterestPawn$" sure why not ");
		TalkSome(CustomerPawn.myDialog.lPositiveResponse, CustomerPawn,true);
		Sleep(SayTime);
	}
	else
	{
		TalkSome(MyPawn.MyDialog.lWipeHouse_PriceHike2);		
		Sleep(SayTime);
		
		PrintDialogue(InterestPawn$" gotta be fucking kidding ");
		TalkSome(CustomerPawn.myDialog.lDude_GottaBeKidding, CustomerPawn,true);
		Sleep(SayTime);
	}

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
// ExchangeGoodsAndServices
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
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
	
	// Edit: if there's only one meal deal available, go with the cashiercontroller "is this everything" dialog instead.
	// Mainly for the wipe house errand, but could be used in other places.
	if (MyCashReg.DealNumberMax == 1)
	{
		// cashier asks if this is all
		PrintDialogue("Is this everything?");
		TalkSome(MyPawn.myDialog.lIsThisEverything);
		Sleep(SayTime);

		// customer says yes
		PrintDialogue(InterestPawn$" yes");
		TalkSome(CustomerPawn.myDialog.lYes, CustomerPawn);
		Sleep(SayTime);
	}
	else
	{
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
	}

	// cashier states how much it will be
	statecount = DecideCustomerMoney();
	PrintDialogue("that'll be...");
	SayTime = Say(MyPawn.myDialog.lNumbers_Thatllbe);
	Sleep(SayTime);
	// BEGIN Expanded number support
	bucks = 0;
	// Hundreds
	if (statecount >= 100)
	{
		pricecount = statecount / 100;	// integer division
		pricecount *= 100;
		SayTime = SayThisNumber(MyPawn.MyDialog.GetValidNumber(pricecount, pricecount),,bImportantDialog);
		Sleep(SayTime);
		statecount -= pricecount;
		bucks = 2;
	}
	// Teens
	if (statecount >= 11 && statecount <= 19)
	{
		SayTime = SayThisNumber(MyPawn.MyDialog.GetValidNumber(statecount, statecount),,bImportantDialog);
		Sleep(SayTime);
		statecount = 0;
		bucks = 2;
	}
	// Tens
	if (statecount >= 10)
	{
		pricecount = statecount / 10;	// integer division
		pricecount *= 10;
		SayTime = SayThisNumber(MyPawn.Mydialog.GetValidNumber(pricecount, pricecount),,bImportantDialog);
		Sleep(SayTime);
		statecount -= pricecount;
		bucks = 2;
	}
	// Ones
	if (statecount >= 1)
	{
		SayTime = SayThisNumber(MyPawn.Mydialog.GetValidNumber(statecount, statecount),,bImportantDialog);
		Sleep(SayTime);
		if (bucks == 0)
			bucks = statecount;
	}
	PrintDialogue(statecount$" bucks");
	Sleep(0.1);
	if(bucks > 1)
		SayTime = Say(MyPawn.myDialog.lNumbers_Dollars, bImportantDialog);
	else
		SayTime = Say(MyPawn.myDialog.lNumbers_SingleDollar, bImportantDialog);
	Sleep(SayTime + Frand());
	// END expanded number support

	// Decide here to buy the thing or not
	// customer refuses sale
	if(FRand() <= CustomerDoesntBuy)
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
		// Show the customer grabbing the item
		CustomerPawn.PlayTakeGesture();
		GiveCustomerItem();

		// Customer says thanks
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
defaultproperties
{
	CustomerDoesntBuy=1.0
	HowAreYouFreq=0.25
	DudeGetsMad=1.0
	DudePaidWaitTime=1.0
}
