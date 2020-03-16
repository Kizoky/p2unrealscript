///////////////////////////////////////////////////////////////////////////////
// GaryController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for Gary Coleman!
//
///////////////////////////////////////////////////////////////////////////////
class GaryController extends FFCashierController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var bool bDecidedToFight;		// Has made comments about deciding to fight
var Sound WritingSound;			// Sound for when he signs thing

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const ITEM_GRAB_TIME	=	2.6;
const SEE_GARY_ANGLE	=	0.75;


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

	// gary says hi
	PrintDialogue("hello");
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	Sleep(SayTime);

	// Customer looks down
	CustomerPawn.PlayTurnHeadDownAnim(1.0, SEE_GARY_ANGLE);
	// customer asks for autograph
	TalkSome(CustomerPawn.myDialog.lGaryAutograph, CustomerPawn,true);
	PrintDialogue(InterestPawn$" can i have your autograph? i love you.");
	Sleep(SayTime);

	// play writing noise, as he signs the book
	PlaySound(WritingSound);
	Sleep(GetSoundDuration(WritingSound));
	
	// gary signs book
	PrintDialogue("here's my autograph and book");
	TalkSome(MyPawn.myDialog.lGary_GivingAutograph);
	Sleep(SayTime);

	GiveCustomerItem();

	// Decide here to accept the thing or not
	// customer refuses book
	if(FRand() <= CustomerDoesntBuy)
	{
		// Customer looks down
		CustomerPawn.PlayTurnHeadDownAnim(1.0, SEE_GARY_ANGLE);
		// customer confused and mad
		TalkSome(CustomerPawn.myDialog.lWhatThe, CustomerPawn);
		PrintDialogue(InterestPawn$" what the...");
		Sleep(SayTime);
		// customer complains about money
		PrintDialogue(InterestPawn$" you suck!");
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lDefiant);
		// now gesture
		P2MoCapPawn(InterestPawn).PlayTellOffAnim();
		// sleep the rest
		Sleep(SayTime);

/*
		// customer throws out book and leaves
		P2MoCapPawn(CustomerPawn).PlayTalkingGesture(1.0);
		Sleep(1.0);	//pause before throwing
		log(MyPawn$" toss this out "$CustomerPawn.SelectedItem);
		CustomerPawn.TossThisInventory(PersonController(CustomerPawn.Controller).GenTossVel(), CustomerPawn.SelectedItem);
		Sleep(1.0);	//pause as throwing
*/
		// gary gets mad too
		PrintDialogue("well screw you then!");
		TalkSome(MyPawn.myDialog.lGary_ResponseToIdiots);
		Sleep(SayTime);
	}
	else
		// Customer accepts book
	{
		// Customer looks down
		CustomerPawn.PlayTurnHeadDownAnim(1.0, SEE_GARY_ANGLE);
		// Show cashier handing over item
		PersonController(CustomerPawn.Controller).InterestInventoryClass = MyCashReg.ItemGiven;
		InterestInventoryClass = MyCashReg.ItemGiven;
		MyPawn.PlayGiveGesture();
		Sleep(1.0);
		
		// Show the customer grabbing the item
		CustomerPawn.PlayTakeGesture();
		GiveCustomerItem();

		// customer says thanks
		PrintDialogue(InterestPawn$" Thanks!");
		TalkSome(CustomerPawn.myDialog.lThanks, CustomerPawn);
		Sleep(ITEM_GRAB_TIME);	// Wait for them to end the grabbing item motion--Use AnimEnd sometime instead
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
	// Just talk to the dude, like normal
	GotoState('TakePaymentFromDude');
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
	// gary says hi
	PrintDialogue("hello");
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	Sleep(SayTime);

	// dude says hi to gary
	PrintDialogue(InterestPawn$" dude hi gary ");
	TalkSome(CustomerPawn.myDialog.lDude_GaryTalk1, CustomerPawn,true);
	Sleep(SayTime);

	// play writing noise, as he signs the book
	PlaySound(WritingSound);
	Sleep(pawn.GetSoundDuration(WritingSound));
	
	// gary signs book
	PrintDialogue("here's my autograph and book");
	TalkSome(MyPawn.myDialog.lGary_GivingAutograph);
	Sleep(SayTime);

	// Show cashier handing over item
	InterestInventoryClass = MyCashReg.ItemGiven;
	MyPawn.PlayGiveGesture();
	Sleep(1.0);

	FinishTransaction();

	// Dude says thanks for the book
	PrintDialogue(InterestPawn$" dude it's for my mom ");
	TalkSome(CustomerPawn.myDialog.lDude_GaryTalk2, CustomerPawn,false);
	Sleep(SayTime);

	// gary signs book
	PrintDialogue("yeah sure it is");
	TalkSome(MyPawn.myDialog.lGary_GivingAutographToDude);
	Sleep(SayTime);

	// gary makes wise-crack
	PrintDialogue("you need some sun!");
	TalkSome(MyPawn.myDialog.lGary_NonViolent);
	Sleep(SayTime);

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AssessAttacker
// Let out war cry
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AssessAttacker
{
	function BeginState()
	{
		Super.BeginState();

		if(!bDecidedToFight)
		{
			SayTime = Say(MyPawn.myDialog.lDecideToFight, bImportantDialog);
			bDecidedToFight=true;
		}
		else
			SayTime = Say(MyPawn.myDialog.lWhileFighting, bImportantDialog);
		MyPawn.StopAcc();
	}

Begin:
	Sleep(SayTime);

	// CHECK HERE to see if we should run for cover first or not

	if(!bSaidGetDown 
		&& FRand() <= MyPawn.WarnPeople)
	{
		//log("anger "$MyPawn.Anger);
		//if(FRand() > MyPawn.Anger)
		//{
			if(SetupShoutGetDown())
			// wait for them to get down
				Sleep(SayTime + MyPawn.Patience);
		//}
		//else
		//	log("i wanted to yell GET DOWN but was too angry");
	}
	GotoStateSave('ShootAtAttacker');
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
	// Say various things during a fight
	///////////////////////////////////////////////////////////////////////////////
	function FightTalk()
	{
		if(FRand() <= MyPawn.TalkWhileFighting)
		{
			// Cop smack talk
			if(Attacker.IsA('Police'))
				SayTime = Say(MyPawn.myDialog.lGary_ToCops, bImportantDialog);
			else // normal smack talk
				SayTime = Say(MyPawn.myDialog.lWhileFighting, bImportantDialog);
		}
		else
			SayTime=0;
	}

}

defaultproperties
{
	WritingSound=Sound'MiscSounds.Map.CheckMark'
	CustomerDoesntBuy=0.1
//	GameHint=""
}