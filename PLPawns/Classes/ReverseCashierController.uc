///////////////////////////////////////////////////////////////////////////////
// ReverseCashierController
// Copyright 2014, Running With Scissors, Inc.
//
// In Soviet Russia, cashier buys YOUR items!
//
// Seriously though, this is basically the reverse of the cashier controller.
// Instead of selling items to bystanders and the dude, this guy buys them
// for cash.
//
// Set up the CashRegPoint like you would normally, and assign the operator
// a ReverseCashierController. They will pay the maximum price listed on the
// cashregpoint for each item the player has.
///////////////////////////////////////////////////////////////////////////////
class ReverseCashierController extends FFCashierController;

var int pricecount;
var int bucks;
var float AmountTakenFromDude;	// Amount of stuff taken from the dude

///////////////////////////////////////////////////////////////////////////////
// Give them the item they paid for
// This works for any p2pawn dude or NPC
///////////////////////////////////////////////////////////////////////////////
function Inventory GiveCustomerItem()
{
	local Inventory thisinv;
	local P2PowerupInv pinv;
	local P2Weapon weapinv;
	local P2AmmoInv ainv;
	local int AmmoGive, GiveAmount;
	local byte CreatedNow;

	thisinv = InterestPawn.CreateInventoryByClass(class'MoneyInv', CreatedNow);

	if(thisinv != None)
	{
		// If we just created this, add in any more we got from this thing
		if (InterestPawn.Controller.bIsPlayer)
		{
			// Handle the dude differently, they might have given us multiples.
			if(CreatedNow == 1)
				GiveAmount = AmountTakenFromDude * MyCashReg.ItemCostMax - 1;
			else	// If we didn't just make it, add them all in
				GiveAmount = AmountTakenFromDude * MyCashReg.ItemCostMax;
			log("We took"@AmountTakenFromDude@"and the cost is"@MyCashReg.ItemCostMax@"final give amount"@GiveAmount);
		}
		else
		{
			if(CreatedNow == 1)
				GiveAmount = MyCashReg.ItemCostMax - 1;
			else	// If we didn't just make it, add them all in
				GiveAmount = MyCashReg.ItemCostMax;
		}

		if(GiveAmount > 0)
		{
			pinv = P2PowerupInv(thisinv);
			weapinv = P2Weapon(thisinv);
			ainv = P2AmmoInv(thisinv);

			// We get one already when adding a powerup..only add the remaining ones
			if(pinv != None
				&& MyCashReg.MaxNumberOfItemsGiven > 0)
			{
				pinv.AddAmount(/*class<P2PowerupPickup>(pinv.PickupClass).default.AmountToAdd**/GiveAmount);
				// set it as your item
				if(InterestPawn != None)
					InterestPawn.SelectedItem = pinv;
			}
			// If they already have this weapon, then add in more ammo to it, otherwise,
			// if their just getting this weapon now, the ammo will be added in, in the
			// CreateInventory function above
			else if(weapinv != None)
			{
				if(weapinv != None)
					weapinv.bJustMade=true;

				thisinv.GiveTo(InterestPawn);

				// Adds in how much of each powerup to give to the inventory
				// do this by spawning a pickup, getting the number, then destroying it
				if(weapinv != None)
				{
					if(thisinv.PickupClass != None)
						AmmoGive=class<P2WeaponPickup>(thisinv.PickupClass).default.AmmoGiveCount;

					weapinv.GiveAmmoFromPickup(InterestPawn, GiveAmount*AmmoGive);
				}

				thisinv.PickupFunction(InterestPawn);

				// Check to see if someone has given us a violent weapon
				if(weapinv != None
					&& weapinv.ViolenceRank > 0)
					P2Pawn(InterestPawn).bHasViolentWeapon = true;

				if(weapinv != None)
					weapinv.bJustMade=false;
			}
			else if(ainv != None)
			{
				ainv.AddAmmo(class<P2AmmoPickup>(ainv.PickupClass).default.AmmoAmount*GiveAmount);
			}
		}

		// Show the pickup message for whatever you were just sold
		if(P2Player(InterestPawn.Controller) != None)
			P2Player(InterestPawn.Controller).HandlePickupClass(thisinv.PickupClass);
	}

	//log(InterestPawn$" money is now "$pinv$" at "$pinv.Amount);
	return thisinv;
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
	
	// Cashier hmms as they add up the items value
	PrintDialogue(InterestPawn$" Hmmmm...");
	SayTime = Say(MyPawn.myDialog.lHmm) + FRand();
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = DecideCustomerMoney();
	PrintDialogue("For that, I'll give you...");
	SayTime = Say(MyPawn.myDialog.lCashier_ForThatIllGive);
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

	// Customer accepts sale

	// Show customer handing over item
	PersonController(CustomerPawn.Controller).InterestInventoryClass = MyCashReg.ItemGiven;
	InterestInventoryClass = MyCashReg.ItemGiven;
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

	// Show cashier handing over money
	PersonController(CustomerPawn.Controller).InterestInventoryClass = class'MoneyInv';
	InterestInventoryClass = class'MoneyInv';
	MyPawn.PlayGiveGesture();
	Sleep(1.0);
	// Show the customer grabbing the item
	CustomerPawn.PlayTakeGesture();
	GiveCustomerItem();

	// Customer says thanks
	PrintDialogue(InterestPawn$" thanks!");
	TalkSome(CustomerPawn.myDialog.lThanks, CustomerPawn);
	Sleep(2*SayTime);

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
	// Setup dude to deal with the cashier
	///////////////////////////////////////////////////////////////////////////////
	function SetupCustomer()
	{
		// Switch to the desired inventory item
		InterestInventoryClass = MyCashReg.ItemGiven;
		// Setup the dude
		SetupDudeCustomer();
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

	// With these cashiers, you don't have to bring the product to them, you go to them
	// and ask for it. They give the product and you give them the money.
	bResetInterests=false;
	// Check if you have enough money or not
	if(P2Pawn(InterestPawn).HowMuchInventory(MyCashReg.ItemGiven) <= 0)
	{
		GotoState('DudeHasNoItem');
	}
	else
	{
		GotoState('WaitOnDudeToPay');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Since CheckP isn't bringing us the item, we're supplying that, we'll just
// check the price on it, in our cash register point.
// This really only works for powerups right now. Weapons and ammo can't
// be sold back with this controller yet.
///////////////////////////////////////////////////////////////////////////////
function float GetTotalCostOfYourProducts(P2Pawn CheckP, P2Pawn OrigOwner)
{
//	log("total cost is "$MyCashReg.ItemCostMax);
	local P2PowerupInv UseInv;
	UseInv = P2PowerupInv(CheckP.FindInventoryType(MyCashReg.ItemGiven));

	return MyCashReg.ItemCostMax * UseInv.Amount;
}

///////////////////////////////////////////////////////////////////////////////
// Cashiers only, usually
///////////////////////////////////////////////////////////////////////////////
function bool AcceptItem(P2Pawn Payer, Inventory thisitem, 
						 out float AmountTaken, float FullAmount)
{
	local float TotalCost;
	TotalCost = FullAmount;	// take all of them

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
		AmountTakenFromDude = AmountTaken;
		if(MoneyInv(thisitem) != None)
			RecordMoneySpent(Payer, TotalCost);
		// If the dude hands over one or more cats, tell the game about it
		if (CatInv(thisitem) != None && PlayerController(Payer.Controller) != None)
		{
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(Payer.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Payer.Controller), 'PLCatsSold', int(FullAmount), true);
		}
		// Take money and thank them
		GotoState('TakePaymentFromDude');
		return true;
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

	// Cashier hmms as they add up the items value
	PrintDialogue(InterestPawn$" Hmmmm...");
	SayTime = Say(MyPawn.myDialog.lHmm) + FRand();
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	PrintDialogue("For that, I'll give you...");
	SayTime = Say(MyPawn.myDialog.lCashier_ForThatIllGive, bImportantDialog);
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

	// Wait on dude to pay you for the thing
	//log("waiting on the money");
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
	// Give dude his item. Money has already been exchanged becuase this
	// state is intiated by the dude giving the cashier money
	///////////////////////////////////////////////////////////////////////////////
	function FinishTransaction()
	{
		if(LastSoldItem == None)
			LastSoldItem = GiveCustomerItem();
	}
Begin:
	// Show cashier grabbing
	MyPawn.PlayTakeGesture();
	// cashier says thanks
	TalkSome(MyPawn.myDialog.lSellingItem);
	Sleep(SayTime);
	PrintDialogue("Thanks for the payment");

	// Show cashier handing over item
	InterestInventoryClass = class'MoneyInv';
	MyPawn.PlayGiveGesture();

	//FinishTransaction();

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
	bSwitchToMoney=false
}