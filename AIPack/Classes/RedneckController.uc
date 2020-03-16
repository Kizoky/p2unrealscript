///////////////////////////////////////////////////////////////////////////////
// RedneckController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// Rednecks hate/love the gimp
///////////////////////////////////////////////////////////////////////////////
class RedneckController extends BystanderController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// We've seen the pawn, now decide if we care
// Returns true if there state changes at some point
///////////////////////////////////////////////////////////////////////////////
function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
{
	local P2Weapon p2weap;
	local vector dir;
	local bool bcheck;
	local bool bIsGimp, bIsCop;
	local float dist;

	// If this guy doesn't care about things going on around him
	if(MyPawn.bIgnoresSenses)
		return;

	// If he's on fire, just watch him, if we're not already fighting
	if(Attacker == None
		&& LookAtMe.MyBodyFire != None)
	{
		GenSafeRangeMin();
		DangerPos = LookAtMe.Location;
		MakeMoreAlert();
		InterestPawn = LookAtMe;
		GotoStateSave('WatchGuyOnFire');
		StateChange = 1;
		return;
	}

	// if it's a crazy animal, run or fight it
	if(AnimalPawn(LookAtMe) != None)
	{
		// Animals very rarely send out look requests--usually only when they're deadly
		if(AnimalPawn(LookAtMe).bDangerous)
		{
			if(MyPawn.bHasViolentWeapon)
			{
				// Drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				SaveAttackerData(LookAtMe);
				GotoStateSave('RecognizeAttacker');
				StateChange=1;
			}
			else
			{
				GenSafeRangeMin();
				InterestPawn = LookAtMe;
				SetAttacker(InterestPawn);
				DangerPos = Attacker.Location;
				GotoStateSave('FleeFromAttacker');
				StateChange=1;
				return;
			}
		}
		return;
	}

	// If it's the dude, and I hate him, act now
	// unless he's not dressed like the dude, in which case, don't
	// recognize him
	if(LookAtMe.bPlayer
		&& (PersonDressedAsGimp(LookAtMe)
			|| (MyPawn.bPlayerIsEnemy 
				&& DudeDressedAsDude(LookAtMe))))
	{
		// decide to fight if you have a weapon, or run if you don't
		if(MyPawn.bHasViolentWeapon)
		{
			// if I'm not attacking anyone already--esp. not the dude
			// then decide to recognize him
			if(Attacker == None)
			{
				InterestPawn = LookAtMe;
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				GotoStateSave('SightedHatedGuy');
				StateChange=1;
			}
			else if(!IsInState('SightedHatedGuy'))
				// we already know we hate him (if we're not trying to decide already)
			{
				// Drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				SaveAttackerData(LookAtMe);
				GotoStateSave('RecognizeAttacker');
				StateChange=1;
			}
			return;
		}
		else
		{
			DangerPos = LookAtMe.Location;
			GenSafeRangeMin();
			InterestPawn = LookAtMe;
			GotoStateSave('ShyToSafeDistance');
			StateChange=1;
			return;
		}
	}

	// Check first (before we see the weapon) if he is possibly in your house
	// and not supposed to be, and you care about it
	CheckForIntruder(LookAtMe, StateChange);

	// Check to see if we care what he's doing or what he looks like
	p2weap = P2Weapon(LookAtMe.Weapon);
	if(p2weap != None)
	{
		// Gang AI
		// If this other pawn had his weapon out, see if he has
		// an attacker, if so, and we don't already have one, 
		// fight with him if he's in your gang
		if(SameGang(LookAtMe)
			&& ConcernedAboutWeapon(p2weap))
		{
			if(Attacker == None)
			{
				if(GainGangMemberKnowledge(PersonController(LookAtMe.Controller))
					&& MyPawn.bHasViolentWeapon)
				{
					GotoStateSave('AssessAttacker');
					StateChange=1;
					return;
				}
			}
			// Return regardless because it's a fellow buddy and we don't
			// care about his weapons
			return;
		}

		// See if they are pointing they're weapon at you, and they're
		// not a police or military that you hate.
		if(WeaponTurnedToUs(LookAtMe, MyPawn)
			&& !P2Pawn(LookAtMe).bAuthorityFigure)
		{
			dir = LookAtMe.Location - MyPawn.Location;
			dist = VSize(dir);

			// We're close enough to see what the weapon is, that he has
			if(dist < p2weap.RecognitionDist)
			{
				// We don't care if you're the gimp, cop, or dude, if you have your pants down, we're concerned
				if(MyPawn.bScaredOfPantsDown
					&& LookAtMe.HasPantsDown())
				{
					HandlePantsDown(LookAtMe, StateChange);
					if(StateChange == 1)
						return;
				}
				// If he's got a cowhead, stare at him
				else if(P2Weapon(LookAtMe.Weapon) != None
						&& P2Weapon(LookAtMe.Weapon).bWeaponIsGross
						&& FRand() < COWHEAD_COMMENT_FREQ)
				{
					InterestPawn = LookAtMe;
					GotoStateSave('WatchGuyWithCowhead');
					StateChange=1;
					return;
				}
				// Handle the dude being a cop
				else if(DudeDressedAsCop(LookAtMe))
				{
					if(ConcernedAboutCopWeapon(p2weap))
					{
						// Check to make sure you're not protesting, because we don't want protestors
						// to bother with the dude being a cop (unless he starts shooting)
						if(IsInState('ProtestToTarget'))
							return;	// don't let protestors/marchers react anymore
						else if(FRand() <= MyPawn.Curiosity)
						{
							InterestPawn = LookAtMe;
							GotoStateSave('WatchACop');
							StateChange = 1;
							return;
						}
					}
				}
				else if(ConcernedAboutWeapon(p2weap))
				{
					// Drop things if you had them in your hands
					MyPawn.DropBoltons(MyPawn.Velocity);

					// Check if you have the balls and a gun to attack
					// the bad guy, then pull out the gun and watch him
					// or if it's the dude, just attack him
					if(MyPawn.Cajones > FRand()
						&& MyPawn.bHasViolentWeapon)
					{
						// It's the dude--attack!
						// or, it's not and i'm just happy to shoot anyone
						if(FreakedAboutWeapon(p2weap)
							&& (LookAtMe.bPlayer
								|| MyPawn.bGunCrazy
								|| FriendIsEnemyTarget(P2Pawn(LookAtMe))))
						{
							SetAttacker(LookAtMe);
							MakeMoreAlert();
							SaveAttackerData(LookAtMe);
							GotoStateSave('RecognizeAttacker');
							StateChange=1;
							return;
						}
						else // Somebody other than the dude, or it's not a 
							// bad weapon, .. so just watch
						{
							GenSafeRangeMin();
							DangerPos = LookAtMe.Location;
							MakeMoreAlert();
							InterestPawn = LookAtMe;
							GotoStateSave('WatchThreateningPawn');
							StateChange = 1;
							return;
						}
					}
					else // Watch or run, you can't defend yourself
					{
						// Check to see if we should flee or if we're an okay distance away
						// Dist between attacker and me
						CurrentDist = dist;
						// pick how far away to stand around a guy
						UseSafeRangeMin = (p2weap.ViolenceRank*0.3)*(MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin);
						//log("use safe range for observe "$UseSafeRangeMin);

						// I'm scared of whatever this guy has out
						InterestPawn = LookAtMe;
						MakeMoreAlert();
						if(PickScreamingStill())
							GotoStateSave('ScreamingStill');
						else
							GotoStateSave('ShyToSafeDistance');
						StateChange=1;
						return;
					}
				}
			}
		}
	}

	bIsGimp = PersonDressedAsGimp(LookAtMe);

	if(MyPawn.Talkative > FRand()
		|| bIsGimp)
	// Consider talking to them
	{
		// If they don't have their pants down and have no weapon,
		// then check to talk to them
		if(p2weap == None
			|| (!ConcernedAboutWeapon(p2weap)
			&& !LookAtMe.HasPantsDown()))
		{
			TryToGreetPasserby(LookAtMe, bIsGimp, false);
		}
	}

	if(Attacker == LookAtMe)
	{
		// We know we can still see him here, so record his 
		SaveAttackerData();
	}
	return;
}


defaultproperties
{
}