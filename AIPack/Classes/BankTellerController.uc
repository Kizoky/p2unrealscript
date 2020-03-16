///////////////////////////////////////////////////////////////////////////////
// BankTellerController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for bystander bank tellers and their type.
///////////////////////////////////////////////////////////////////////////////
class BankTellerController extends CashierController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
/*
///////////////////////////////////////////////////////////////////////////////
// Return the hint you want to display for this item
///////////////////////////////////////////////////////////////////////////////
function GetInvHint(Inventory checkme, out String str1)
{
	if(PaycheckInv(checkme) == None)
	{
		str1 = GameHint;
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// Anyone who doesn't accept money, but needs a specific item
///////////////////////////////////////////////////////////////////////////////
function bool AcceptItem(P2Pawn Payer, Inventory thisitem, 
						 out float AmountTaken, float FullAmount)
{
	local float TotalRequired;

	// if no item, or not the right type
	if(thisitem == None
		|| thisitem.class != InterestInventoryClass)
		return false;

	TotalRequired = 1;

	if(FullAmount < TotalRequired)
	{
		log("you need this much "$TotalRequired);
		AmountTaken = 0;
		// No item to accept!
		// The deal's off!
		GotoState('DudeHasNoItem');
		return false;
	}
	else
	{
		log("you PAID this much "$TotalRequired);
		AmountTaken = 0; // hack to get the paycheck errand working again
		// Take money and thank them
		GotoState('TakePaymentFromDude');
		return true;
	}
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
	// Give them the money requested
	///////////////////////////////////////////////////////////////////////////////
	function GiveCustomerMoney(int AmountToGive)
	{
		local P2PowerupInv pinv;
		pinv = P2PowerupInv(InterestPawn.CreateInventoryByClass(class'Inventory.MoneyInv'));
		pinv.AddAmount(AmountToGive);
		//log(InterestPawn$" money is now "$pinv$" at "$pinv.Amount);
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

	// teller says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// Make a WITHDRAWAL
	if(Frand() < 0.5)
	{
		// customers states his business
		TalkSome(CustomerPawn.myDialog.lmakewithdrawal, CustomerPawn);
		PrintDialogue(InterestPawn$" i need to make a withdrawal");
		Sleep(SayTime);

		// teller asks him about businesss
		TalkSome(MyPawn.myDialog.lTeller_Withdrawal);
		PrintDialogue("would you like to make a withdrawal?");
		Sleep(SayTime);

		// guys says how much to withdrawal
		statecount = DecideCustomerMoney();
		SayTime = CustomerPawn.SayThisNumber(statecount);
		PrintDialogue(statecount$" bucks");
		Sleep(SayTime + 0.1);
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lNumbers_Dollars);
		Sleep(SayTime + FRand());

		//teller updates the account
		SayTime = Say(MyPawn.myDialog.lTeller_UpdateAccount);
		PrintDialogue(" updatting your account ");
		MyPawn.PlayKeyboardTypeAnim();
		Sleep(SayTime+FRand());

		// Show teller handing over money
		PersonController(CustomerPawn.Controller).InterestInventoryClass = class'MoneyInv';
		InterestInventoryClass = class'MoneyInv';
		// Show teller handing over the money
		MyPawn.PlayGiveGesture();
		Sleep(1.0);
		// Show customer grabbing money
		TalkSome(CustomerPawn.myDialog.lThanks,CustomerPawn,,,true);
		Sleep(SayTime+FRand());

		GiveCustomerMoney(statecount);

		// teller says you're welcome
		TalkSome(MyPawn.myDialog.lyourewelcome);
		PrintDialogue("you're welcome");
		Sleep(SayTime);
	}
	else // make a DEPOSIT
	{
		// customers states his business
		TalkSome(CustomerPawn.myDialog.lmakedeposit, CustomerPawn);
		PrintDialogue(InterestPawn$" i need to make a deposit");
		Sleep(SayTime);

		// teller asks him about business
		TalkSome(MyPawn.myDialog.lTeller_Deposit);
		PrintDialogue("would you like to make a deposit?");
		Sleep(SayTime);

		// guys says how much to deposit
		statecount = DecideCustomerMoney();
		SayTime = CustomerPawn.SayThisNumber(statecount);
		PrintDialogue(statecount$" bucks");
		Sleep(SayTime + 0.1);
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lNumbers_Dollars);
		Sleep(SayTime+FRand());

		// Show customer handing over money
		PersonController(CustomerPawn.Controller).InterestInventoryClass = class'MoneyInv';
		InterestInventoryClass = class'MoneyInv';
		CustomerPawn.PlayGiveGesture();
		// Show teller handing over the money
		Sleep(1.0);
		// Show customer grabbing money
		MyPawn.PlayTakeGesture();
		Sleep(2.0);

		//teller updates the account
		SayTime = Say(MyPawn.myDialog.lTeller_UpdateAccount);
		PrintDialogue(" updating your account ");
		MyPawn.PlayKeyboardTypeAnim();
		Sleep(SayTime+FRand());

		// customers thanks teller
		TalkSome(CustomerPawn.myDialog.lThanks, CustomerPawn);
		PrintDialogue(InterestPawn$" Thanks");
		Sleep(SayTime);

		// teller says you're welcome
		TalkSome(MyPawn.myDialog.lyourewelcome);
		PrintDialogue("you're welcome");
		Sleep(SayTime);
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
	///////////////////////////////////////////////////////////////////////////////
	// Setup dude to deal with teller, by switching to the item I care about
	///////////////////////////////////////////////////////////////////////////////
	function SetupCustomer()
	{
		local OwnedInv owninv;
		local P2Player aplayer;

		owninv = OwnedInv(HasYourProduct(P2Pawn(InterestPawn), MyPawn));

		aplayer = P2Player(InterestPawn.Controller);

		CustomerPawn = P2MoCapPawn(InterestPawn);

		if(aplayer != None
			&& owninv != None)
		{
			// Fix up our default
			InterestInventoryClass = default.InterestInventoryClass;
			// link to the cashier who called you over
			aplayer.InterestPawn = MyPawn;
			aplayer.bDealingWithCashier=true;

			// Switch you over to showing this powerup in your item list
			aplayer.SwitchToThisPowerup(owninv.default.InventoryGroup,
									owninv.default.GroupOffset);
		}
	}
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

	// teller says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// dude says hi
	PrintDialogue(InterestPawn$" greeting ");
	TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
	Sleep(SayTime);

	// teller asks how to help you
	PrintDialogue("how can i help you?");
	TalkSome(MyPawn.myDialog.lCanIHelpYou);
	Sleep(SayTime);

	// dude says he wants to cash his paycheck
	PrintDialogue(InterestPawn$"i need to cash  my paycheck");
	TalkSome(CustomerPawn.myDialog.lDude_CashingPaycheck, CustomerPawn);
	Sleep(SayTime);

	log("waiting on the money");
	// Wait on dude to pay you for the thing
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DudeHasNoItem
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DudeHasNoItem
{
Begin:
	if(CheckToGiggle())
		Sleep(SayTime);

	// Comment that you don't have anything to do a deal with yet
	// Says hmmm
	PrintDialogue("hmmm");
	TalkSome(MyPawn.myDialog.lHmm);
	Sleep(SayTime);

	// Teller asks how she can help you
	PrintDialogue("You need to get your paycheck before I can help you");
	TalkSome(MyPawn.myDialog.lCanIHelpYou);
	Sleep(SayTime);

	// Dude apologizes for showing up without anything
	PrintDialogue(InterestPawn$"dude sorry");
	TalkSome(CustomerPawn.myDialog.lApologize, CustomerPawn);
	Sleep(SayTime);

	// return to handling the cash register
	GotoState('WaitForCustomers');
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
	PrintDialogue("Insufficient funds, you have no item, or I have no money!!");
	// say something mean
	//SayTime = Say(MyPawn.myDialog.lHabib_Customer);
	//Sleep(SayTime);

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitOnDudeToPay
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitOnDudeToPay
{
	///////////////////////////////////////////////////////////////////////////////
	// Dude walked away or something
	///////////////////////////////////////////////////////////////////////////////
	function ThisPersonLeftYouWhileHandling(P2Pawn CheckA)
	{
		if(InterestPawn == CheckA)
			GotoState(GetStateName(), 'WatchForCustomerReturn');
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	SayTime = Say(MyPawn.myDialog.lGreeting);
	PrintDialogue("Greeting");
	Sleep(SayTime);
	log("waiting on the paycheck");
	// Wait on dude to give you the thing
}
*/
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
	// Dude just complete an errand, so you can go back to helping customers
	///////////////////////////////////////////////////////////////////////////////
	function DudeErrandComplete()
	{
		// return to handling the cash register
		GotoState('WaitForCustomers');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check, after taking the item out of the dude's inventory, and
	// now add money to the dude's inventory
	// Bank teller will take however many of this item (like 3 paychecks) and 
	// work with them all (return to you how much they're all worth together and
	// remove them from your inventory).
	///////////////////////////////////////////////////////////////////////////////
	function FinishTransaction()
	{
		local OwnedInv owninv;
		local MoneyInv givemoney;
		local float TotalMoneyToGive, TotalItemsToTake;
		local byte CreatedNow;
		local P2GameInfoSingle checkg;
		local bool bErrandComplete;

		// Fix up our default
		InterestInventoryClass = default.InterestInventoryClass;

		owninv = OwnedInv(HasYourProduct(P2Pawn(InterestPawn), MyPawn));

		if(owninv != None)
		{	
			// See if this item is in an uncompleted errand
			checkg = P2GameInfoSingle(Level.Game);
			if(checkg != None)
			{
				// InterestPawn is giving MyPawn the owninv.
				bErrandComplete = checkg.CheckForErrandCompletion(owninv, None, 
																MyPawn, 
																P2Player(InterestPawn.Controller),
																false);
			}

			TotalItemsToTake = owninv.Amount;
			TotalMoneyToGive = TotalItemsToTake*owninv.Price;
			if(TotalMoneyToGive > 0)
			{
				// Give money to the dude
				//log("took your paycheck took "$TotalItemsToTake$" and gave you "$TotalMoneyToGive$" dollars");
				givemoney = MoneyInv(InterestPawn.CreateInventoryByClass(class'MoneyInv', CreatedNow));
				if(givemoney != None)
				{
					// If we made it now, we've already added in the default amount, so don't
					// give him that much again
					if(CreatedNow == 1)
						givemoney.AddAmount(TotalMoneyToGive - class'MoneyPickup'.default.AmountToAdd);
					else // If he already had money, just give him how much he's owed.
						givemoney.AddAmount(TotalMoneyToGive);
					if(InterestPawn != None)
						InterestPawn.SelectedItem = givemoney;
				}
			}

			owninv.ReduceAmount(TotalItemsToTake);

			if(bErrandComplete)
				GotoState(GetStateName(), 'WaitForErrandWrapup');
		}

	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for an errand end and clear the thing you sold me.
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(Attacker == None)
		{
			FinishTransaction(); // Get the thing no matter what
			//EndErrand();
		}

		Super.EndState();
	}

Begin:
	SetupDudeCustomer();

	//teller updates the account
	SayTime = Say(MyPawn.myDialog.lTeller_UpdateAccount);
	PrintDialogue(" updating your account ");
	MyPawn.PlayKeyboardTypeAnim();
	Sleep(SayTime);

	// Show teller handing over money
	InterestInventoryClass = class'MoneyInv';
	MyPawn.PlayGiveGesture();
	// Show teller handing over the money
	TalkSome(CustomerPawn.myDialog.lThanks,CustomerPawn,,true);
	Sleep(1.0);
	FinishTransaction();

//	TalkSome(MyPawn.myDialog.lThanks);
//	PrintDialogue("Here's your money");
//	Sleep(SayTime);
//	FinishTransaction();

	// return to handling the cash register
	GotoState('WaitForCustomers');

WaitForErrandWrapup:
}

defaultproperties
{
	InterestInventoryClass=class'PaycheckInv'
//	GameHint="Switch to paycheck to cash it"
}