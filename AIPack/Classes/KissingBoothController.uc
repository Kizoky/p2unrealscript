///////////////////////////////////////////////////////////////////////////////
// KissingBoothController
// Controller for lipstick gimp manning the kissing booth.
///////////////////////////////////////////////////////////////////////////////
class KissingBoothController extends FFCashierController;

var() string DiscoMusic;	// Music to play when pissed on
var int MusicHandle;
var int TimesDanced;

const TIMES_DANCED_MAX = 5;

///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
// Used the cheesy bool bPuke so we wouldn't have another
// function to ignore in all the states
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	// Only none-turrets use this
	if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret)
	{
		InterestPawn=Other;

		if(bPuke)
		{
			// Definitely throw up from puke on me
			GetAngryFromDamage(PISS_FAKE_DAMAGE);
			MakeMoreAlert();
			CheckToPuke(, true);
		}
		else if (!IsInState('DanceWhenPissedOn'))
		{
			SetNextState(GetStateName());
			GotoStateSave('DanceWhenPissedOn');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Play dance animation and then try for your next state, if you have one
// if not, dance again
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DanceWhenPissedOn extends DanceHere
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event BeginState()
	{
		Super.BeginState();
		if (MusicHandle == 0)
			MusicHandle = FPSGameInfo(Level.Game).PlayMusicAttenuateExt(MyPawn, DiscoMusic, 0.0, 0.75, 100.0, 1.0);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	event EndState()
	{
		Super.EndState();
		if (MusicHandle != 0)
		{
			FPSGameInfo(Level.Game).StopMusicExt(MusicHandle, 0.0);
			MusicHandle = 0;
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		// Dance facing the same direction
		if(Frand() < DANCE_AGAIN
			&& TimesDanced < TIMES_DANCED_MAX)
		{
			TimesDanced++;
			GotoState(GetStateName(), 'DanceAgain');
		}
		// Go to my next state
		else if(MyNextState != 'None'
			&& MyNextState != '')
		{
			TimesDanced = 0;
			GotoNextState();
		}
		else 
		{
			TimesDanced = 0;
			GotoState('Thinking');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ExchangeGoodsAndServices
// Like super, but instead of goods, we exchange "services"
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ExchangeGoodsAndServices
{
// Most of the handling is in here, and we can't override just a single part of it, so I have to copy the whole mess.

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

	/*
	// cashier asks if this is all
	PrintDialogue("Is this everything?");
	TalkSome(MyPawn.myDialog.lIsThisEverything);
	Sleep(SayTime);

	// customer says yes
	PrintDialogue(InterestPawn$" yes");
	TalkSome(CustomerPawn.myDialog.lYes, CustomerPawn);
	Sleep(SayTime);
	*/

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
	if(FRand() <=  CustomerDoesntBuy)
	{
		// Customer complains about money
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

		// customer gets mad
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

		// Now kiss
		MyPawn.PlayKissGimp();
		CustomerPawn.PlayKissing();
		Sleep(1.0);
		Spawn(P2GameInfoSingle(Level.Game).KissEmitterClass,,,MyPawn.MyHead.Location);
		// Restore health too because why not
		CustomerPawn.Health = CustomerPawn.HealthMax;
		Sleep(1.0);

		// customer gives them the money
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
	TalkSome(MyPawn.myDialog.lSellingItem);
	Sleep(SayTime);
	PrintDialogue("Thanks for the payment");

	// dude sort of says you're welcome
	if(FRand() <= 0.5)
	{
		PrintDialogue(InterestPawn$"dude you're welcome");
		SayTime = CustomerPawn.Say(CustomerPawn.myDialog.lPositiveResponse);
		Sleep(SayTime + FRand());
	}

	// Now kiss
	MyPawn.PlayKissGimp();
	Sleep(1.0);
	Spawn(P2GameInfoSingle(Level.Game).KissEmitterClass,,,MyPawn.MyHead.Location);
	// Show lipstick decal on dude hud
	if (P2Player(CustomerPawn.Controller) != None)
		P2Player(CustomerPawn.Controller).HurtBarTime[5] = P2Player(CustomerPawn.Controller).HURT_BAR_FADE_TIME*5;
	// Restore health too because why not
	CustomerPawn.Health = CustomerPawn.HealthMax;
	//Sleep(1.0);	

	Sleep(DudePaidWaitTime);

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

	// cashier states how much it will be
	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	PrintDialogue("that'll be...");
	SayTime = Say(MyPawn.myDialog.lNumbers_Thatllbe, bImportantDialog);
	Sleep(SayTime);
	statecount = MyPawn.MyDialog.GetValidNumber(statecount,statecount);
	SayTime = SayThisNumber(statecount,,bImportantDialog);
	PrintDialogue(statecount$" bucks");
	Sleep(SayTime + 0.1);
	if(statecount > 1)
		SayTime = Say(MyPawn.myDialog.lNumbers_Dollars, bImportantDialog);
	else

		SayTime = Say(MyPawn.myDialog.lNumbers_SingleDollar, bImportantDialog);
	Sleep(SayTime + FRand());

	// Wait on dude to pay you for the thing
	//log("waiting on the money");
}

defaultproperties
{
	CustomerDoesntBuy=0.0
	DudeGetsMad=0.0
	DiscoMusic="gay_club.ogg"
}