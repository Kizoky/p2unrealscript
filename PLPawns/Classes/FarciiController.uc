///////////////////////////////////////////////////////////////////////////////
// FarciiController
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// Same as a regular bystander, but they refuse to donate to the dude.
///////////////////////////////////////////////////////////////////////////////
class FarciiController extends BystanderController;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CheckToDonate
// See if you want to donate money
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CheckToDonate
{
Begin:
	if(FPSPawn(Focus) != None
		&& P2Player(FPSPawn(Focus).Controller) != None)
		Sleep(P2Player(FPSPawn(Focus).Controller).SayTime + 0.3);
	else
		Sleep(1.0);

	// Check to see if I hate you first
	if(FPSPawn(Focus) != None)
		ActOnPawnLooks(FPSPawn(Focus));

	CheckTalkerAttention();

	// reduce the time to wait
	CurrentFloat = CurrentFloat - ((2.0 - UseReactivity) + MyPawn.Rebel);
	
	// If it's the Champ photo, run in terror
	// FIXME: have them say something else on the 9th attempt
	if (Pawn(Focus).Weapon.IsA('PhotoWeapon'))
	{
		// tell the dude (but not if we've already reacted to the photo)
		if (PhotoBothered == 0)
		{
			// If this is the last person the Dude needs, activate the "wise wang" errand
			if (Pawn(Focus).Weapon.AmmoType.AmmoAmount >= Pawn(Focus).Weapon.AmmoType.MaxAmmo - 1)
			{
				DonatedBotherCount=-2;
				// Make him scared
				MyPawn.SetMood(MOOD_Scared, 1.0);
				// Wait a tiny bit
				Sleep(CurrentFloat);
				// Then activate the errand
				GotoState('DealWithPhoto');				
			}			
			else
			{
				PhotoBothered = 1;
				if (P2Player(Pawn(Focus).Controller) != None)
					P2Player(Pawn(Focus).Controller).GrabMoneyPutInCan(1);
			}
		}
		// Just set this as a dangerous location and scream and/or run the fuck away
		MyPawn.SetMood(MOOD_Scared, 1.0);
		SayTime = Say(MyPawn.myDialog.lChampPhotoReaction, true);
		Sleep(SayTime);
		DangerPos = InterestPawn.Location;
		GotoStateSave('FleeForever');
		/*
		if (FRand() <= SCREAMING_STILL_FREQ)
			GotoStateSave('ScreamingStill');
		else
			GotoStateSave('FleeFromDanger');
		*/
	}
	else
	{
		// Already signed, stop bothering me!
		if(DonatedBotherCount < 0)
			Goto('BuzzOff');

		// Hasn't signed, so change him
		DonatedBotherCount++;

		// Final bother is violent, so handle it differently
		if(DonatedBotherCount >= MAX_DONATE_BOTHER)
		{
			// You've officially been bothered beyond the point of caring
			DonatedBotherCount=-1;
			if(MyPawn.bHasViolentWeapon)
				HandleMeanTalker(FPSPawn(Focus));
			else // No gun to defend themselves after you threaten them
				Goto('SetupScrewYou');
		}
		else
		{
	SetupScrewYou:
				// Wait a little while till you get tired, then continue on
				MyPawn.SetMood(MOOD_Angry, 1.0);
				Sleep(CurrentFloat*FRand());
				Goto('ScrewYou');
		}

	ScrewYou:
		// Kamek 5-1
		// Record that we didn't sign it -- this can turn to false later if the dude is persistent
		bRefusedToDonate = true;
		//log("RefusedToDonate"@bRefusedToDonate,'Debug');

		// Flip them off
		MyPawn.SetMood(MOOD_Angry, 1.0);
		MyPawn.PlayTellOffAnim();
		PrintDialogue("no way! you're crazy");
		//SayTime = Say(MyPawn.myDialog.lDefiant);
		SayTime = Say(MyPawn.myDialog.lDontSignPetition, true);
		Sleep(SayTime);
		// Kamek 5-1: Give them an achievement for begging a cop
		if (MyPawn.IsA('Police'))
		{
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(Pawn(Focus).Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Pawn(Focus).Controller),'NoWayPinko');	
		}
		UnhookFocus(true);
		DecideNextState();

	BuzzOff:
		// Flip them off
		MyPawn.SetMood(MOOD_Angry, 1.0);
		MyPawn.PlayTellOffAnim();
		PrintDialogue("buzz off!");
		SayTime = Say(MyPawn.myDialog.lPetitionBother, true);
		Sleep(SayTime);
		UnhookFocus(true);
		DecideNextState();
	}
}
