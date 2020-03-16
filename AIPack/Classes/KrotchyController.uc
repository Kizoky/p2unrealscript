///////////////////////////////////////////////////////////////////////////////
// KrotchyController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// Krotchy mascot--guy in suit.
//
// The dude on close proximity will tell krotchy he needs a toy. Krotchy says
// they are all out. 
// When you talk to him, Krotchy will try to switch your inventory to either show
// your gary coleman book or your money. 
// If you activate either of those around him, you'll tempt him into a bribe.
// You can either give him the money he wants or the book you have. If you do,
// he'll give you a toy he has.
//
///////////////////////////////////////////////////////////////////////////////
class KrotchyController extends FFCashierController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// Internal vars
var class<Inventory> InterestInventoryClass2;	// other class we care about
var int	BribeStatusMoney;						// if we started to bribe, or have completed a bribe
var int	BribeStatusBook;
var bool bGreetedDude;							// We've already introduced each other
var float NonDamageTaken;						// Amount of 'non-damage' from bullets we've not
												// taken. Record how much and when it reaches a threshold
												// laugh at the player
var float NonDamageMax;							// Max before we laugh again

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const CHECK_FOR_PEOPLE_FREQ	=   2.0;
const PEOPLE_CHECK_RADIUS	=	700;
const BRIBE_MONEY_PRIMED	=	1;
const BRIBE_MONEY_DONE		=	2;
const BRIBE_BOOK_PRIMED		=	1;
const BRIBE_BOOK_DONE		=	2;

///////////////////////////////////////////////////////////////////////////////
// Record damage
// Negative damage represents damage we fulled blocked, but we will know
// how bad he would have hurt us. Use this to eventually laugh at him for 
// shooting us with bullets.
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	if ( instigatedBy != pawn)
	{
		if(Damage > 0)
			damageAttitudeTo(instigatedBy, Damage);
		else
		{
			if(ClassIsChildOf(damageType, class'BulletDamage'))
			{
				// Subtract because the damage sent in is negative
				NonDamageTaken -=Damage;
			}
			// Make sure to attack him
			if(Attacker == None)
			{
				SetAttacker(FPSPawn(InstigatedBy));
				SaveAttackerData();
				Say(MyPawn.myDialog.lGotHit);		// cry out
				GotoStateSave('ReactToAttack');
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Stub out the regular version of this, so people don't try to use krotchy
// when he's not looking for them.
///////////////////////////////////////////////////////////////////////////////
function HandleThisPerson(P2Pawn CheckA)
{
}

///////////////////////////////////////////////////////////////////////////////
// Check for someone standing close enough to buy something
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCustomerStandTouch(FPSPawn CheckMe)
{
	local float dist;

	if(CheckMe != None
		&& CustomerStand != None)
	{
		dist = VSize(CustomerStand.Location - CheckMe.Location);
		//log(MyPawn$" customer stand touch "$dist$" needed radius "$CustomerStand.CollisionRadius+2*CheckMe.CollisionRadius);
		return dist <= CustomerStand.CollisionRadius+2*CheckMe.CollisionRadius;
	}
	else
		return false;
}

/*
// Changed! Doesn't do this anymore because we want the movie to make him seek
// you out, so now he acts like a normal bystander--he gets triggered to
// hate you and starts off after you.

///////////////////////////////////////////////////////////////////////////////
// This is to be used only for when the player finds the Krotchy toy back in
// the warehouse. So you get it, trigger krotchy, and now he hates you on sight.
// He doesn't seek you out, he just hates you on sight, ie, will attack you then.
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	// make hate player
	MyPawn.bPlayerIsEnemy=true;
}
*/

///////////////////////////////////////////////////////////////////////////////
// Cashiers only, usually
// If you activate your money/gary coleman book around krotchy, you get the dude
// to try to bribe him into giving you the toy.
///////////////////////////////////////////////////////////////////////////////
function bool AcceptItem(P2Pawn Payer, Inventory thisitem, 
						 out float AmountTaken, float FullAmount)
{
	// if he's been bribed fully in anyway, don't take anything more
	if(BribeStatusMoney == BRIBE_MONEY_DONE
		|| BribeStatusBook == BRIBE_BOOK_DONE)
		return false;

	// if no item, or not the right type
	if(thisitem == None)
		return false;

	if(thisitem.class == InterestInventoryClass)
	{
		// handle money type bribes
		if(BribeStatusMoney == 0)
		{
			PayerMoney = P2PowerupInv(thisitem);
			GotoState('SetupBribeMoney');
			return true;
		}
		else if(BribeStatusMoney == BRIBE_MONEY_PRIMED)
		{
			GotoState('TakeBribeMoney');
			return true;
		}
	}
	else if(thisitem.class == InterestInventoryClass2)
	{
		// handle book type bribes
		if(BribeStatusBook == 0)
		{
			PayerMoney = P2PowerupInv(thisitem);
			GotoState('SetupBribeBook');
			return true;
		}
		else if(BribeStatusBook == BRIBE_BOOK_PRIMED)
		{
			GotoState('TakeBribeBook');
			return true;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do next
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	ignores FreeToSeekPlayer;

Begin:
	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

TryAgain:
	Sleep(FRand()*0.5 + 0.5);

	if(!MyPawn.bCanEnterHomes
		&& MyCashReg != None)
	{
		// walk to some random place I can see (not through walls)
		SetNextState('LookForPeople');
		FindCashRegister();
		GotoStateSave('WalkToTarget');
	}
	else
	{
		// walk to some random place I can see (not through walls)
		SetNextState('Thinking');
		if(!PickRandomDest())
			Goto('TryAgain');	// Didn't find a valid point, try again
		GotoStateSave('WalkToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LookForPeople
// look for someone to talk to
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LookForPeople
{
	ignores TryToGreetPasserBy;

	///////////////////////////////////////////////////////////////////////////////
	// Someone is in front of me, trying to get my attention
	///////////////////////////////////////////////////////////////////////////////
	function HandleThisPerson(P2Pawn CheckA)
	{
		local PersonController per;
		local P2Player p2p;

		// send unhandled entries to this back to thinking
		if(CheckA != None)
		{
			per = PersonController(CheckA.Controller);
			if(per != None
				&& InterestPawn2 != CheckA)
			{
				Focus = CheckA;
				GotoState('TalkToPeople');
			}
			else
			{
				p2p = P2Player(CheckA.Controller);
				if(p2p != None)
				{
					Focus = CheckA;
					GotoState('GreetDude');
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function bool PersonIsAround(float checkrad)
	{
		local P2Pawn CheckP;
		local PersonController pers;

		ForEach VisibleCollidingActors(class'P2Pawn', CheckP, checkrad, MyPawn.Location)
		{
			pers = PersonController(CheckP.Controller);
			// if not me, and not through a wall or something, recognize person
			if(CheckP != MyPawn 
				&& CheckP != InterestPawn2
				&& FastTrace(MyPawn.Location, CheckP.Location)
				&& CheckP.Health > 0
				&& pers != None
				&& (pers.IsInState('WalkToTarget')
				|| pers.IsInState('Thinking')))
			{
				Focus = CheckP;
				return true;
			}
		}
		return false;
	}
	
	///////////////////////////////////////////////////////////////////////////////
	// pick some random direction around you and look there
	///////////////////////////////////////////////////////////////////////////////
	function LookInNewDir()
	{
		local float randang;

		randang = FRand()*2*pi;

		FocalPoint.x = cos(randang);
		FocalPoint.y = sin(randang);
		FocalPoint.z = 0;
		//log(MyPawn$" new focal point "$FocalPoint$" loc "$MyPawn.Location);
		FocalPoint = MyPawn.Location + PEOPLE_CHECK_RADIUS*FocalPoint;
		//log(MyPawn$" after focal point "$FocalPoint);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		CurrentFloat = CHECK_FOR_PEOPLE_FREQ;
		Focus = None; // not looking at anyone
		InterestPawn2 = InterestPawn;	// save who we just talked to, so we don't shout at them again
		InterestPawn = None;
		CustomerPawn = None;
		PayerMoney = None;
	}

Begin:
	Sleep(CurrentFloat + FRand()*CurrentFloat);

	// Randomly, and not very often, check if you want to do an idle
	if(FRand() <= DO_IDLE_FREQ)
		GotoStateSave('PerformIdle');

	if(PersonIsAround(PEOPLE_CHECK_RADIUS))
		GotoState('TalkToPeople');

	// Look in some other direction around you
	LookInNewDir();

	Goto('Begin');
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
// TalkToPeople
// Tell people they should love the toy
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TalkToPeople extends TalkingWithSomeoneMaster
{
	///////////////////////////////////////////////////////////////////////////////
	// Someone is in front of me, trying to get my attention
	// This allows the dude to interrupt other people talking
	///////////////////////////////////////////////////////////////////////////////
	function HandleThisPerson(P2Pawn CheckA)
	{
		local P2Player p2p;

		if(CheckA != None)
		{
			p2p = P2Player(CheckA.Controller);
			if(p2p != None)
			{
				Focus = CheckA;
				GotoState('GreetDude');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Get the customer ready for business
	///////////////////////////////////////////////////////////////////////////////
	function SetupTalker()
	{
		if(PersonController(InterestPawn.Controller).Attacker == None)
		{
			PersonController(InterestPawn.Controller).InterestPawn = MyPawn;
			PersonController(InterestPawn.Controller).GotoStateSave('TalkingWithSomeoneSlave');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Unhook them
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		// check to make sure they didn't die or something.
		if(PersonController(InterestPawn.Controller) != None
			&& PersonController(InterestPawn.Controller).Attacker == None)
		{
			PersonController(InterestPawn.Controller).InterestPawn = None;
			PersonController(InterestPawn.Controller).GotoStateSave('Thinking');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Look at him
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		CustomerPawn = P2MoCapPawn(Focus);
		InterestPawn = FPSPawn(Focus);
		FocalPoint = InterestPawn.Location;
		CurrentFloat = FRand();
	}
Begin:
	SetupTalker();

	// krotchy bothers people
	if(CurrentFloat < 0.5)
		TalkSome(MyPawn.myDialog.lKrotchy_HaveANiceDay);
	else
		TalkSome(MyPawn.myDialog.lKrotchy_HeyKids);
	PrintDialogue("buy a krotchy.");
	Sleep(SayTime);

	CurrentFloat = FRand();
	// They don't ask about the product but comment somehow
	if(CurrentFloat <  CustomerDoesntBuy)
	{
		if(FRand() <= CustomerPawn.Compassion)
		{
			// customer says that's nice
			PrintDialogue(InterestPawn$" thanks!");
			TalkSome(CustomerPawn.myDialog.lThanks, CustomerPawn);
			Sleep(SayTime);
		}
		else	// Say something funny
		{
			PrintDialogue(InterestPawn$" you don't look like a good krotchy");
			TalkSome(CustomerPawn.myDialog.lKrotchyCustomerComment, CustomerPawn);
			Sleep(SayTime+FRand());
		}
	}
	else // ask about a toy.. that he doesn't have
	{
		// customer wants his toy
		PrintDialogue(InterestPawn$" i need you're toy!");
		TalkSome(CustomerPawn.myDialog.lKrotchyCustomerWant, CustomerPawn);
		Sleep(SayTime+FRand());

		// krotchy says we're all sold out
		PrintDialogue("we're all sold out");
		TalkSome(MyPawn.myDialog.lKrotchy_SoldOut1);
		Sleep(SayTime+FRand());
	}

	GotoStateSave('LookForPeople');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TalkToDude
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TalkToDude extends TalkingWithSomeoneMaster
{
	ignores HandleThisPerson;

	///////////////////////////////////////////////////////////////////////////////
	// If the player left while you were talking to him
	///////////////////////////////////////////////////////////////////////////////
	function ThisPersonLeftYouWhileHandling(P2Pawn CheckA)
	{
		if(CheckA.bPlayer)
			GotoStateSave('LookForPeople');
	}
	///////////////////////////////////////////////////////////////////////////////
	// setup dude to deal with the cashier
	///////////////////////////////////////////////////////////////////////////////
	function SetupDude()
	{
		local P2Player aplayer;

		aplayer = P2Player(InterestPawn.Controller);

		if(aplayer != None
			&& CheckForCustomerStandTouch(InterestPawn))
		{
			// link to the cashier who called you over
			aplayer.InterestPawn = MyPawn;
			aplayer.bDealingWithCashier=true;

			// To make the bribing more hidden, we're not switching to the
			// money or book when you talk to him. We could add this
			// back in easily if we want.
/*
			// If the player is already on one of the two classes
			// we care about, then don't switch anything.
			if(InterestPawn.SelectedItem == None
				|| (InterestPawn.SelectedItem != None
				&& InterestPawn.SelectedItem.class != InterestInventoryClass
				&& InterestPawn.SelectedItem.class != InterestInventoryClass2))
			{
				// Switch you over to showing your money in your item list
				// We have two classes, so try them both if one fails.
				aplayer.SwitchToThisPowerup(InterestInventoryClass.default.InventoryGroup,
										InterestInventoryClass.default.GroupOffset);
				// first one failed, try the other now
				if(InterestPawn.SelectedItem != None
					&& InterestPawn.SelectedItem.class != InterestInventoryClass)
				{
					log(InterestPawn$" my inv "$InterestPawn.SelectedItem.class);
					aplayer.SwitchToThisPowerup(InterestInventoryClass2.default.InventoryGroup,
											InterestInventoryClass2.default.GroupOffset);
				}
				log(InterestPawn$" final inv "$InterestPawn.SelectedItem.class);
			}
			*/
		}
		else
			GotoStateSave('LookForPeople');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Unhook me from the dude controller
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		local P2Player aplayer;

		log(MyPawn$" told me it's over "$InterestPawn);

		if(InterestPawn != None)
		{
			InterestPawn2 = InterestPawn;

			aplayer = P2Player(InterestPawn.Controller);
			if(aplayer != None)
			{
				// Unhook me from the dude controller
				aplayer.InterestPawn = None;
				aplayer.bDealingWithCashier=false;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look at him
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		CustomerPawn = P2MoCapPawn(Focus);
		InterestPawn = FPSPawn(Focus);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GreetDude
// They first talk, krotchy says there are no more toys
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GreetDude extends TalkToDude
{
Begin:
	SetupDude();

	if(!bGreetedDude)
	{
		// dude tells krotchy he needs a toy
		PrintDialogue(InterestPawn$" hey i need a toy");
		TalkSome(CustomerPawn.myDialog.lDude_TalkToKrotchy, CustomerPawn);
		Sleep(SayTime);

		// krotchy says we're all sold out
		PrintDialogue("we're all sold out");
		TalkSome(MyPawn.myDialog.lKrotchy_SoldOut1);
		Sleep(SayTime);

		// dude says something negative
		PrintDialogue(InterestPawn$" something negative ");
		TalkSome(CustomerPawn.myDialog.lNegativeResponseCashier, CustomerPawn);
		Sleep(SayTime);

		// krotchy says we're all sold out
		PrintDialogue("buy a larry the crab");
		TalkSome(MyPawn.myDialog.lKrotchy_SoldOut2);

		// Wait till here to make sure the dude heard you.
		bGreetedDude=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SetupBribeMoney
// Dude tells him he's got enough money for a krotchy.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SetupBribeMoney extends TalkToDude
{
	function BeginState()
	{
		Super.BeginState();
		BribeStatusMoney = BRIBE_MONEY_PRIMED;
	}
Begin:
	SetupDude();

	// dude tells krotchy he needs a toy
	PrintDialogue(InterestPawn$" hey i need a toy for money");
	TalkSome(CustomerPawn.myDialog.lDude_BribeKrotchyMoney, CustomerPawn);
	Sleep(SayTime + 1.0);

	// krotchy takes the money
	PrintDialogue("good deal");
	TalkSome(MyPawn.myDialog.lKrotchy_TakesBribe);
	Sleep(SayTime + 1.0);

	GotoState('TakeBribeMoney');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SetupBribeBook
// Dude tells him he's got enough money for a krotchy.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SetupBribeBook extends TalkToDude
{
	ignores AcceptItem;

	function BeginState()
	{
		Super.BeginState();
		BribeStatusBook = BRIBE_BOOK_PRIMED;
	}
Begin:
	SetupDude();

	// dude tells krotchy he needs a toy
	PrintDialogue(InterestPawn$" hey i need a toy");
	TalkSome(CustomerPawn.myDialog.lDude_BribeKrotchyBook, CustomerPawn);
	Sleep(SayTime + 1.0);
	
	// krotchy takes the book
	PrintDialogue("good deal");
	TalkSome(MyPawn.myDialog.lKrotchy_TakesBribe);
	Sleep(SayTime + 1.0);

	GotoState('TakeBribeBook');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TakeBribeMoney
// Dude gives krotchy money for his last toy
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakeBribeMoney extends TalkToDude
{
	ignores AcceptItem;

	///////////////////////////////////////////////////////////////////////////////
	// Get how much money this character has
	///////////////////////////////////////////////////////////////////////////////
	function int AllPawnsMoney(P2Pawn CheckPawn)
	{
		local P2PowerupInv ppinv;

		ppinv = P2PowerupInv(CheckPawn.FindInventoryType(class'MoneyInv'));
		return ppinv.Amount;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Toy for money
	///////////////////////////////////////////////////////////////////////////////
	function TradeItems()
	{
		local int price;

		// trade him your money
		if(PayerMoney != None)
		{
			price = AllPawnsMoney(CustomerPawn);
			RecordMoneySpent(CustomerPawn, price);
			PayerMoney.ReduceAmount(price);
		}
		LastSoldItem = GiveCustomerItem();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to complete the errand after the bribe
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(LastSoldItem != None)
		{
			EndErrand(LastSoldItem);
			// If you completed the errand, then don't make him greet you anymore
			bGreetedDude=true;
		}

		Super.EndState();
		
		LastSoldItem = None;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		BribeStatusMoney = BRIBE_MONEY_DONE;
	}
Begin:
	SetupDude();

	// trade him the toy for the money
	TradeItems();

	// dude says thanks
	PrintDialogue(InterestPawn$" thanks");
	TalkSome(CustomerPawn.myDialog.lThanks, CustomerPawn);
	Sleep(SayTime);

	// krotchy takes the money
	PrintDialogue("have a nice day");
	TalkSome(MyPawn.myDialog.lKrotchy_HaveANiceDay);
	Sleep(SayTime);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TakeBribeBook
// Dude gives krotchy money for his last toy
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakeBribeBook extends TalkToDude
{
	ignores AcceptItem;

	///////////////////////////////////////////////////////////////////////////////
	// Toy for money
	// Payermoney is really the book item here. (the gary coleman autobiography)
	///////////////////////////////////////////////////////////////////////////////
	function TradeItems()
	{
		local OwnedInv toyitem;

		// trade him your item
		if(PayerMoney != None)
			// you only took one book
			PayerMoney.ReduceAmount(1);

		// for his toy
		LastSoldItem = GiveCustomerItem();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Check to complete the errand after the bribe
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(LastSoldItem != None)
		{
			EndErrand(LastSoldItem);
			// If you completed the errand, then don't make him greet you anymore
			bGreetedDude=true;
		}

		Super.EndState();
		
		LastSoldItem = None;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		BribeStatusBook = BRIBE_BOOK_DONE;
	}
Begin:
	SetupDude();

	// trade him the toy for the book
	TradeItems();

	// dude says thanks
	PrintDialogue(InterestPawn$" thanks");
	TalkSome(CustomerPawn.myDialog.lThanks, CustomerPawn);
	Sleep(SayTime);

	// krotchy takes the book
	PrintDialogue("have a nice day");
	TalkSome(MyPawn.myDialog.lKrotchy_HaveANiceDay);
	Sleep(SayTime);

	GotoStateSave('LookForPeople');
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LaughAtAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LaughAtAttacker extends LaughAtSomething
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, 
		RespondToTalker, RatOutAttacker, PerformInterestAction, MarkerIsHere, 
		RespondToQuestionNegatively, ActOnPawnLooks,
		RespondToCopBother, DecideToListen, PersonStoleSomething, NotifyTakeHit;
	
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		Say(MyPawn.myDialog.lDecideToFight, bImportantDialog);
		Super.DecideNextState();
	}
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
	// In addition to picking the best weapon, if you've been shot too much and they
	// haven't hurt you with the bullets, then laugh at them
	///////////////////////////////////////////////////////////////////////////////
	function EvaluateAttacker()
	{
		SwitchToBestWeapon();

		// Laugh at you for trying to shoot him, if you've shot him too much
		if(NonDamageTaken >= NonDamageMax)
		{
			 // Clear this now
			NonDamageTaken = 0;
			// Bump this up so it'll be a while before he laughs again at you
			// for you using your normal bullets
			NonDamageMax = 3*NonDamageMax;
			// Focus forward
			FocalPoint = MyPawn.Location + 100*vector(MyPawn.Rotation);
			Focus = None;
			// Start laughing at him
			SetNextState('ShootAtAttacker');
			GotoStateSave('LaughAtAttacker');
		}
	}
}


defaultproperties
{
	InterestInventoryClass=class'MoneyInv'
	InterestInventoryClass2=class'GaryBookInv'
	CustomerDoesntBuy=0.3
	NonDamageMax=25
//	GameHint=""
}