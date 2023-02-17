///////////////////////////////////////////////////////////////////////////////
// PLHabibController
// Copyright 2014 RWS, Inc.  All Rights Reserved.
//
// Controller for Habib at the survival shop
///////////////////////////////////////////////////////////////////////////////
class PLHabibController extends FFCashierController;

var bool bSawDude;	// True if we talked to the dude already. Don't repeat the conversation.

///////////////////////////////////////////////////////////////////////////////
// Make him get mad and attack, because we're walking back where we
// aren't supposed to be and we haven't paid
// Skip the bPlayerIsFriend check in this one. If he's trying to rob me
// then we want to attack.
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	// Special handling for cops in the police station during They Hate Me or greater.
	if (MyPawn.IsA('AuthorityFigure'))
	{
		//log(self@"triggered by"@other@eventinstigator@"and i'm a cop");
		PoliceTrigger(Other, EventInstigator);
		return;
	}

	MyPawn.bIgnoresSenses=false;
	MyPawn.bIgnoresHearing=false;

	if(MyPawn.bHasViolentWeapon)
	{
		if(!MyPawn.bNoTriggerAttackPlayer)
		{
			SetToAttackPlayer(FPSPawn(Other));
			GotoNextState();
		}
	}
	else
	{
		SetAttacker(FPSPawn(EventInstigator));
		if (FPSPawn(EventInstigator) != None)
			InterestPawn = FPSPawn(EventInstigator);

		// run far, far away from this location
		DangerPos = Location;
		UseSafeRangeMin = 32000;
		GotoStateSave('FleeFromDanger');
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

	// cashier says hi
	TalkSome(MyPawn.myDialog.lGreeting,,true);
	PrintDialogue("Greeting");
	Sleep(SayTime);

	// dude says hi
	// If he talked to Habib already just say hi, don't ask for the cap again
	PrintDialogue(InterestPawn$" greeting ");
	if (!bSawDude)
		TalkSome(CustomerPawn.myDialog.lDude_WantsBlastingCap, CustomerPawn,true);
	else
		TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
	Sleep(SayTime);
	bSawDude = true;

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
	TalkSome(CustomerPawn.myDialog.lDude_GottaBeKidding, CustomerPawn);
	Sleep(SayTime);

	// Wait on dude to pay you for the thing
}

defaultproperties
{
	HowAreYouFreq=0.0
}