///////////////////////////////////////////////////////////////////////////////
// FFCashierController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for cashiers of fast food controllers.
//
// The difference with these, is, they take money and give you a 
// certain item.
//
// A normal cashier needs to be brought the item that you're giving them
// money for.
// 
// These are thought of as Fast Food cashier controllers. Thus the 'FF'.
//
///////////////////////////////////////////////////////////////////////////////
class FFCashierController extends CashierController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var Inventory LastSoldItem;	// Last thing you sold the player

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////

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

	thisinv = InterestPawn.CreateInventoryByClass(MyCashReg.ItemGiven, CreatedNow);

	if(thisinv != None)
	{
		// If we just created this, add in any more we got from this thing
		if(CreatedNow == 1)
			GiveAmount = MyCashReg.MaxNumberOfItemsGiven - 1;
		else	// If we didn't just make it, add them all in
			GiveAmount = MyCashReg.MaxNumberOfItemsGiven;

		if(GiveAmount > 0)
		{
			pinv = P2PowerupInv(thisinv);
			weapinv = P2Weapon(thisinv);
			ainv = P2AmmoInv(thisinv);

			// We get one already when adding a powerup..only add the remaining ones
			if(pinv != None
				&& MyCashReg.MaxNumberOfItemsGiven > 0)
			{
				pinv.AddAmount(class<P2PowerupPickup>(pinv.PickupClass).default.AmountToAdd*GiveAmount);
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
		// Switch to our money always
		InterestInventoryClass = class'MoneyInv';
		// Setup the dude
		Super.SetupCustomer();
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
	///////////////////////////////////////////////////////////////////////////////
	// Remove a thing you've gotten in your hand
	// But if it's anything other than money, then give it to the player
	///////////////////////////////////////////////////////////////////////////////
	function NotifyHandRemoveItem()
	{
		Super.NotifyHandRemoveItem();

		FinishTransaction();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Check for an errand end and clear the thing you sold me.
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(Attacker == None)
		{
			FinishTransaction(); // Get the thing no matter what

			EndErrand(LastSoldItem);
		}

		Super.EndState();
		
		LastSoldItem = None;
	}
Begin:
	// Show cashier grabbing
	MyPawn.PlayTakeGesture();
	// cashier says thanks
	TalkSome(MyPawn.myDialog.lSellingItem);
	Sleep(SayTime);
	PrintDialogue("Thanks for the payment");

	// Show cashier handing over item
	InterestInventoryClass = MyCashReg.ItemGiven;
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
	DudePaidWaitTime=4.0
}