///////////////////////////////////////////////////////////////////////////////
// CitationController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// Cop cashier that let's you pay them for your traffic citation
//
///////////////////////////////////////////////////////////////////////////////
class CitationController extends CashierController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars

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
// Cashiers only, usually
// Look for his interest item, if he has one, then call the accept item and 
// cash, if he does
//////////////////////////////////////////////////////////////////////////////
function bool AcceptItem(P2Pawn Payer, Inventory thisitem, 
						 out float AmountTaken, float FullAmount)
{
	local Inventory OtherItem;
	// if it's money
	if(thisitem.class == class'MoneyInv')
	{
		// then find what we're looking for
		OtherItem = Payer.FindInventoryType(InterestInventoryClass);
	}

	// We DO have money and the item, like normal, so handle him
	// as usual
	if(OtherItem != None)
	{
		AcceptItemAndCash(Payer, OtherItem, P2PowerupInv(thisitem), AmountTaken, FullAmount);
		return false;	// return false here becuase money started this, and true will make
		// it reduce itself by AmountTaken. We want to do that later, in FinishTransaction
		// near the bottom. 
	}
	else	// no item
	{
		GotoState('DudeHasNoItem');
		return false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// He needs an item AND money
///////////////////////////////////////////////////////////////////////////////
function bool AcceptItemAndCash(P2Pawn Payer, Inventory thisitem, 
						 P2PowerupInv cash,
						 out float AmountTaken, float FullAmount)
{
	local float TotalRequired;
	local float TotalCost;

	// if no item, or not the right type
	if(thisitem == None
		|| cash == None
		|| thisitem.class != InterestInventoryClass)
		return false;

	TotalRequired = 1;
	TotalCost = GetTotalCostOfYourProducts(Payer, MyPawn);

	// If you're stuff doesn't cost anything, then don't change states with this
	if(TotalCost <= 0)
		return false;

	if(FullAmount < TotalRequired)
	{
		log("you need this much "$TotalRequired);
		AmountTaken = 0;
		// No item to accept!
		// The deal's off!
		GotoState('DudeHasNoItem');
		return false;
	}
	// if no money or not enough
	else if(cash == None
		|| cash.Amount < TotalCost)
	{
		log("you need this much "$TotalRequired);
		AmountTaken = 0;
		// Not enough money
		// The deal's off!
		GotoState('DudeHasInsufficientFunds');
		return false;
	}
	else
	{
		PayerMoney = cash;
		log("you PAID this much "$TotalRequired);
		AmountTaken = TotalRequired;

		// Take money and thank them
		GotoState('TakePaymentFromDude');
		return true;
	}
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

	// dude says he's here to pay ticket
	PrintDialogue(InterestPawn$" i'm here to pay for this ticket ");
	TalkSome(CustomerPawn.myDialog.lDude_PayTraffic, CustomerPawn);
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

	// say something mean
	TalkSome(MyPawn.myDialog.lLackOfMoney);
	Sleep(SayTime);
	PrintDialogue("Insufficient funds, buy something!");

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

	// dude says he's here to pay ticket
	PrintDialogue(InterestPawn$" i'm here to pay for this ticket ");
	TalkSome(CustomerPawn.myDialog.lDude_PayTraffic, CustomerPawn);
	Sleep(SayTime);

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	// something's wrong, he doesn't have his item any more
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

	// cashier apologizes
	TalkSome(MyPawn.myDialog.lApologize);
	PrintDialogue("i'm sorry");
	Sleep(SayTime);

	log("waiting on the money and citation");
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
	// Check after the money, to take the book
	///////////////////////////////////////////////////////////////////////////////
	function FinishTransaction()
	{
		local OwnedInv owninv;
		local MoneyPickup givemoney;
		local float TotalMoneyToGive, TotalItemsToTake;
		local P2GameInfoSingle checkg;

		owninv = OwnedInv(HasYourProduct(P2Pawn(InterestPawn), MyPawn));

		if(owninv != None)
		{	
			// See if this item is in an uncompleted errand
			checkg = P2GameInfoSingle(Level.Game);
			if(checkg != None)
			{
				// InterestPawn is giving MyPawn the owninv.
				checkg.CheckForErrandCompletion(owninv, None, MyPawn, P2Player(InterestPawn.Controller), false);
			}

			//log("taking this from you're inv "$owninv$" and this much money "$owninv.Price);

			// Take his money
			if(PayerMoney != None)
			{
				RecordMoneySpent(CustomerPawn, owninv.Price);
				PayerMoney.ReduceAmount(owninv.Price);
			}

			// take his item
			owninv.ReduceAmount(1);
		}
	}
Begin:
	TalkSome(MyPawn.myDialog.lCityWorker);
	PrintDialogue("Thanks for the citation and the money");
	Sleep(SayTime);
/*
	// dude says something negative
	PrintDialogue(InterestPawn$" something negative ");
	TalkSome(CustomerPawn.myDialog.lNegativeResponseCashier, CustomerPawn);
	Sleep(SayTime);
*/
	FinishTransaction();

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootAtAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAtAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Somebody squirted on me while I was fighting
	///////////////////////////////////////////////////////////////////////////////
	function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
	{
		if(!MyPawn.IsTalking())
			MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);

		if(bPuke)
			// Definitely throw up from puke on me
			CheckToPuke(, true);

		// Check to wipe it off
		if(FRand() < 0.05)
			CheckWipeFace();
	}

	///////////////////////////////////////////////////////////////////////////////
	// During a fight, decide to stop fighting, if he sort of surrenders.
	///////////////////////////////////////////////////////////////////////////////
	function HandleSurrender(FPSPawn LookAtMe, out byte StateChange)
	{
		// If he's got nothing out, 
		// OR if he's got a melee weapon, but too far away to use it
		// then try to arrest him again, possibly
		if(P2Pawn(Attacker) != None
			&& Attacker == LookAtMe
			&& (Attacker.ViolentWeaponNotEquipped()
				|| (Attacker.Weapon != None
					&& Attacker.Weapon.bMeleeWeapon
					&& !TooCloseWithWeapon(Attacker, true)
					&& !Attacker.Weapon.IsFiring())))
		{
			// If he has his pants down, but is not actively pissing then give him 
			// a break
			if(!Attacker.HasPantsDown()
				|| (!Attacker.Weapon.IsFiring()
					&& (firecount == 0
						|| !MyPawn.Weapon.bMeleeWeapon)))
			{
				Enemy = None;
				firecount=0;
				StateChange=1;
				GotoStateSave('WatchThreateningPawn');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// We see our attacker, check his weapons
	///////////////////////////////////////////////////////////////////////////////
	function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
	{
		local byte WasOurGuy;

		HandleSurrender(LookAtMe, WasOurGuy);
		StateChange=WasOurGuy;

		// Continue on, if we didn't change states
		if(WasOurGuy == 0
			&& !FriendWithMe(LookAtMe))
			Super.ActOnPawnLooks(LookAtMe, StateChange);
	}
}

defaultproperties
{
	InterestInventoryClass=class'CitationInv';
	bSwitchToMoney=true
	DudeGetsMad=1.0
}