///////////////////////////////////////////////////////////////////////////////
// PLGameInfo
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Final game info for Paradise Lost.
//
// HATE GROUPS
//		Monday: Cock Asian Butchers (but only if the Dude steals the food)
//		Tuesday: PU Games Employees
//		Wednesday: Farcii (if the Dude steals Zack's money)
//		Thursday: Bandits
//		Friday: Survivalists
///////////////////////////////////////////////////////////////////////////////
class PLGameInfo extends PLBaseGameInfo;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, enums, etc.
///////////////////////////////////////////////////////////////////////////////

// HACK: ErrandGoals to swap out depending on the order the Dude does Monday's errands.
var ErrandGoal KennelGoalDefault;
var ErrandGoal KennelGoalAfterWiseWang;
var ErrandGoal WiseWangGoalDefault;
var ErrandGoal WiseWangGoalAfterKennel;

var float NewCatTime;	// When we'll make a new cat
var float CatRainTime;	// When we'll start raining again
var bool  bCurrentMapOkForCats;			// Set this once in RunningApocalypse so we don't have to check constantly.
var bool  bRainingCats;
var() class<DogPawn> SuperChampClass;	// Class of SuperChamp that follows the Dude around from map to map

const NEW_CAT_BASE_TIME	= 1;
const NEW_CAT_RAND_TIME	= 6;
const RAIN_BASE_TIME	= 25;
const RAIN_RAND_TIME	= 50;
const CAT_MAKE_RANGE_DIST=4000;
const CAT_MAKE_RANGE_XY = 1500;
const CAT_MAKE_BASE_DIST= 200;
const CAT_MAKE_Z		= 3000;
const CAT_RAIN_SPEED	= 100;
const CAT_RAIN_ACC		= -1200;
const KENNEL_HACK_DAY = 0;
const KENNEL_HACK_ERRAND = 1;
const WANG_HACK_DAY = 0;
const WANG_HACK_ERRAND = 3;

const APOCALYPSE_DAY = 6;
const PREAPOCALYPSE_DAY = 4;
const DUDE_UNBANDAGED_DAY = 4;

// C4 errand hotfix
const C4_VAR = 'C4Done';
const C4_ERRAND = "GetC4";
const C4_DAY = 4;
const C4_MAP_TITLE = "Survivalist Encampment";
const C4_ESCAPE_URL = "PL-underhub#pod2forest";

///////////////////////////////////////////////////////////////////////////////
// Called to send the player to a new level.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerTo(
	PlayerController player,
	String URL,
	optional bool bMaybePawnless)
{
	// Skip showing haters during the Apocalypse (everyone hates you anyway)
	if (TheGameState.CurrentDay == APOCALYPSE_DAY)
		bShowHatersDuringLoad = false;
		
	Super.SendPlayerTo(Player, URL, bMaybePawnless);
}

///////////////////////////////////////////////////////////////////////////////
// This is called to indicate the GameInfo has become valid.
///////////////////////////////////////////////////////////////////////////////
function GameInfoIsNowValid()
{
	local P2Pawn P;
	
	Super.GameInfoIsNowValid();

	// BLAH	
	if (!IsApocalypse())
		return;
	foreach DynamicActors(class'P2Pawn', P)
	{
		if (P.IsA('PLRWSStaff') || P.IsA('PLRWSFollower'))
		{
			if (IsErrandCompleted("KillVince"))
			{
				P.bPlayerIsEnemy=false;
				P.bPlayerIsFriend=true;
				if (P.HealthMax / 4 > P.FriendDamageThreshold)
					P.FriendDamageThreshold = P.HealthMax / 4;
			}
			else
			{
				P.bPlayerIsEnemy=true;
				P.bPlayerIsFriend=false;
			}
		}
		if (P.IsA('PLZombie'))
		{
			if (IsErrandCompleted("KillMikeJ"))
			{
				P.bPlayerIsEnemy=false;
				P.bPlayerIsFriend=true;
				if (P.HealthMax / 4 > P.FriendDamageThreshold)
					P.FriendDamageThreshold = P.HealthMax / 4;
			}
			else
			{
				P.bPlayerIsEnemy=true;
				P.bPlayerIsFriend=false;
			}
		}
		if (P.IsA('Farcii'))
		{
			if (IsErrandCompleted("KillZack"))
			{
				P.bPlayerIsEnemy=false;
				P.bPlayerIsFriend=true;
				if (P.HealthMax / 4 > P.FriendDamageThreshold)
					P.FriendDamageThreshold = P.HealthMax / 4;
			}
			else
			{
				P.bPlayerIsEnemy=true;
				P.bPlayerIsFriend=false;
			}
		}
		if (P.IsA('ColeMen'))
		{
			if (IsErrandCompleted("KillGary"))
			{
				P.bPlayerIsEnemy=false;
				P.bPlayerIsFriend=true;
				if (P.HealthMax / 4 > P.FriendDamageThreshold)
					P.FriendDamageThreshold = P.HealthMax / 4;
			}
			else
			{
				P.bPlayerIsEnemy=true;
				P.bPlayerIsFriend=false;
			}
		}
		if (P.IsA('PLFanatics') || P.IsA('PLKumquat'))
		{
			if (IsErrandCompleted("KillOsama"))
			{
				P.bPlayerIsEnemy=false;
				P.bPlayerIsFriend=true;
				if (P.HealthMax / 4 > P.FriendDamageThreshold)
					P.FriendDamageThreshold = P.HealthMax / 4;
			}
			else
			{
				P.bPlayerIsEnemy=true;
				P.bPlayerIsFriend=false;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Make all cats crazy like in AW since PL events take place after it.
// One plot-hole less, and one more super-cool mechanic back!
// Undone: Dervish cats are set on a per-pawn basis.
///////////////////////////////////////////////////////////////////////////////
/*
function bool CrazyCats()
{
	return True;
}
*/

///////////////////////////////////////////////////////////////////////////////
// Returns true if the Dude should no longer be wearing his AW head wound wrap.
///////////////////////////////////////////////////////////////////////////////
function bool DudeShouldBeBandaged()
{
	//log(self@"should dude be bandaged?"@TheGameState.CurrentDay@"vs"@DUDE_UNBANDAGED_DAY);
	if (TheGameState != None && TheGameState.CurrentDay < DUDE_UNBANDAGED_DAY)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check to swap out the postal dude's bandaged head skin.
///////////////////////////////////////////////////////////////////////////////
function CheckDudeHeadSkin()
{
	local PLPostalDude TheDude;

	//log(self@"CheckDudeHeadSkin");
	foreach DynamicActors(class'PLPostalDude', TheDude)
		TheDude.DudeCheckHeadSkin();
}

function C4ErrandFix()
{
	local int i;
	local bool bC4Done;
	local PLGameState plgs;
	local C4Pickup pick;
	
	//log("Attempting C4 errand hotfix.");
	plgs = PLGameState(TheGameState);
	if (plgs == None)
	{
		//log("No PLGameState - aborted.");
		return;
	}
	
	// PATCH to fix broken saves where the players collected C4 early.
	for (i = 0; i < plgs.GameStateVariables.Length; i++)
	{
		//log("checking vars - "@plgs.GameStateVariables[i].VarName@plgs.GameStateVariables[i].Value);
		if (plgs.GameStateVariables[i].VarName == C4_VAR && plgs.GameStateVariables[i].Value == 1)
		{
			bC4Done = true;
			break;
		}
	}
	
	if (bC4Done)
		foreach DynamicActors(class'C4Pickup', pick)
			break;
			
	if (pick != None)
		bC4Done = false;
		
	if (bC4Done && !IsErrandCompleted(C4_ERRAND))
	{
		//log("broken save detected, looking for C4 errand.");
		for (i = 0; i < Days[C4_DAY].Errands.Length; i++)
		{
			//log("day"@c4_day@"errand"@i@"name"@Days[C4_DAY].Errands[i].UniqueName);
			if (Days[C4_DAY].Errands[i].UniqueName == C4_ERRAND)
			{
				//log("forced completion.");
				Days[C4_DAY].Errands[i].ForceCompletion(TheGameState, GetPlayer());
				SaveCompletedErrand(C4_DAY, i);
				if (C4_DAY == TheGameState.CurrentDay)
					TheGameState.ErrandsCompletedToday++;
				GetPlayer().ClientMessage("Broken game save detected - 'Get C4' errand has been marked as completed for you.");				
				if (Level.Title == C4_MAP_TITLE)
					GotoState('C4BrokenState');
				break;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// As soon as we have a valid game state, check for the dude's bandaged head
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Super.PostLoadGame();
	CheckDudeHeadSkin();
	C4ErrandFix();	
}

event PostTravel(P2Pawn PlayerPawn)
	{
	local Inventory InvAdd;
	local P2PowerupInv ppinv;
	local ClothesPickup clothes;

	const NIGHTMARE_RADAR_MIN = 2000;

	// TODO: In They Hate Me mode, take away any errands that require non-violent NPC interaction
	// Champ photo errand I think is the only one
	if (TheyHateMeMode())
		Days[0] = DayBase'PLMondayHate';
	
	// If the player is on an easy difficulty, don't let them become Apocalypse Conqueror
	if (GetDifficultyOffset() < 0)
		Days[6] = DayBase'PLApocalypseNoConqueror';	

	Super.PostTravel(PlayerPawn);

	// Check for the dude's bandaged head
	CheckDudeHeadSkin();
}

///////////////////////////////////////////////////////////////////////////////
// This checks the current day to see if it's the Apocalypse.
// This does not necessarily mean the game is in the Apocalypse mode yet though
///////////////////////////////////////////////////////////////////////////////
function bool IsApocalypse()
{
	if (TheGameState.CurrentDay == APOCALYPSE_DAY)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Restore day and its errands using the info stored in the GameState.
//
// DayBase and ErrandBase are Objects (not Actors) so they are not destroyed
// or affected in any way by traveling between levels or by loading saved
// games.  This leads to situations where the information in those objects
// does not match the information in the GameState.  For instance, you save
// just before you complete an errand.  Then you complete the errand, so it's
// marked "complete" in the ErrandBase and it's also recorded in the GmeState.
// Now you load the game you saved just before completing the errand.  The
// GameState will say the errand is NOT complete (which is correct) while the
// ErrandBase will still say the errand is complete (which is incorrect).  A
// similar situation can occur when traveling between levels.
//
// Calling this function updates the current DayBase and all of it's
// ErrandBase objects to match the information in the GameState.
///////////////////////////////////////////////////////////////////////////////
function RestoreDayAndErrands()
{
	Super.RestoreDayAndErrands();
	
	// DON'T DO THIS IN HATE ME MODE - it reorders the errands and the Wise Wang errand is disabled anyway.
	if (InNightmareMode() || TheyHateMeMode())
		return;
	
	// If the GameState is marked off that we did the Wise Wang errand before
	// the Kennel errand (or vice versa), swap the errand goals here.
	if (PLGameState(TheGameState).bKennelHack)
		// Rig up the changed errand goal
		Days[KENNEL_HACK_DAY].Errands[KENNEL_HACK_ERRAND].Goals[0] = KennelGoalAfterWiseWang;
	else
		// Set goal back to default - changed goal could still be in place from a previous save etc.
		Days[KENNEL_HACK_DAY].Errands[KENNEL_HACK_ERRAND].Goals[0] = KennelGoalDefault;
	log("GameState kennel hack"@PLGameState(TheGameState).bKennelHack$", errand goal is now"@Days[KENNEL_HACK_DAY].Errands[KENNEL_HACK_ERRAND].Goals[0]);
	
	if (PLGameState(TheGameState).bWiseWangHack)
		// Rig up the changed errand goal
		Days[WANG_HACK_DAY].Errands[WANG_HACK_ERRAND].Goals[0] = WiseWangGoalAfterKennel;
	else
		// Set goal back to default - changed goal could still be in place from a previous save etc.
		Days[WANG_HACK_DAY].Errands[WANG_HACK_ERRAND].Goals[0] = WiseWangGoalDefault;
	log("GameState WiseWang hack"@PLGameState(TheGameState).bWiseWangHack$", errand goal is now"@Days[WANG_HACK_DAY].Errands[WANG_HACK_ERRAND].Goals[0]);
}


///////////////////////////////////////////////////////////////////////////////
// This is *THE* function for checking whether an errand has been completed.
//
// Is is called by various locations in the code where an errand could possibly
// be completed due to a particular action or pickup or whatever else might
// complete an errand.
//
// If an errand is completed by the action/pickup/whatever, then the errand
// is marked as completed and the map screen is brought up to cross it off.
///////////////////////////////////////////////////////////////////////////////
function bool CheckForErrandCompletion(
	Actor Other,
	Actor Another,
	Pawn ActionPawn,
	P2Player ThisPlayer,
	bool bPremature,
	optional string SendToURL)
{
	local bool bCompleted;
	local int Errand;
	local name CompletionTrigger;
	local name HateClass;
	local name HateDesTex;
	local name HatePicTex;
	local string SendPlayerURL;

	if(TheGameState == None)
		return false;

	// Check if the specified stuff has completed an errand.  Note that
	// this function will actually mark the errand as completed, so it's
	// a one-shot thing (it will return "true" once and then will return
	// "false" if called again with the same parameters).
	bCompleted = Days[TheGameState.CurrentDay].CheckForErrandCompletion(
		Other,
		Another,
		ActionPawn,
		bPremature,
		TheGameState,
		Errand,				// OUT: which errand was completed
		CompletionTrigger,	// OUT: name of trigger that must occur
		SendPlayerURL);		// OUT: URL to send player to
		
	// If the errand specified a send-to URL and we're not overriding it, set it now
	if (SendtoURL == "" && SendPlayerURL != "")
		SendToURL = SendPlayerURL;
		
	// HACK: swap out errand goals based on which errand we completed first.
	// If we completed the Kennel errand, change out the Wise Wang goal so the Dude
	// DOESN'T make a smarmy remark.
	if (TheGameState.CurrentDay == KENNEL_HACK_DAY
		&& Errand == KENNEL_HACK_ERRAND)
	{
		PLGameState(TheGameState).bWiseWangHack = true;	// Mark it in the game state
		Days[WANG_HACK_DAY].Errands[WANG_HACK_ERRAND].Goals[0] = WiseWangGoalAfterKennel;	// Swap out the goal
	}
	// If we completed the Wise Wang errand, change out the Kennel goal so the Dude
	// DOES make a smarmy remark.
	if (TheGameState.CurrentDay == WANG_HACK_DAY
		&& Errand == WANG_HACK_ERRAND)
	{
		PLGameState(TheGameState).bKennelHack = true;	// Mark it in the game state
		Days[KENNEL_HACK_DAY].Errands[KENNEL_HACK_ERRAND].Goals[0] = KennelGoalAfterWiseWang;
	}

	if(bCompleted)
	{
		TheGameState.ErrandsCompletedToday++;
		SaveCompletedErrand(TheGameState.CurrentDay, Errand);

		// Make sure to have a player when bringing up the map.
		if(ThisPlayer == None)
			ThisPlayer = GetPlayer();
			
		// Display the map to cross out the errand
		// Don't allow map display on weekend
		if (!IsWeekend())
		{
			// SendToURL requires some special handling
			if (SendToURL != "")
			{
				bCrossOutErrandDuringLoad = true;
				ErrandCompletedDuringLoad = Errand;
				SendPlayerTo(ThisPlayer, SendToURL);
			}
			else
				ThisPlayer.DisplayMapCrossOut(Errand, CompletionTrigger);
		}

		// Check to see if this completes any errands
		CheckForErrandCompletion(ThisPlayer, ThisPlayer, ThisPlayer.Pawn, ThisPlayer, False);
	}

	return bCompleted;
}

// No longer needed - covered in PSG
/*
///////////////////////////////////////////////////////////////////////////////
// Called from P2Player.TravelPostAccept(), which is after the player pawn
// has traveled to (or been created in) a new level.
//
// This ultimately gets called in three basic situations, shown here along
// with how to differentiate them:
//
//  Loaded game: TheGameState != None
//	New game:    TheGameState == None and player's inventory does NOT contain GameState
//  New level:   TheGameState == None and player's inventory contains GameState
//
///////////////////////////////////////////////////////////////////////////////
event PostTravel(P2Pawn PlayerPawn)
{
	Super.PostTravel(PlayerPawn);
	// If it's the first level of the day, ask the GameState if it wants to
	// remove any temporary variables.
	if (TheGameState.bFirstLevelOfDay)
		PLGameState(TheGameState).ClearDailyDynamicVariables();
}
*/

///////////////////////////////////////////////////////////////////////////////
// Keep certain things during the Apocalypse.
///////////////////////////////////////////////////////////////////////////////
function NeededForThisDay(Actor CheckA, out byte Needed, out byte SpecifiedDay)
{
	local byte NeededFriday, NeededApocalypse;
	local byte PreApocalypseDay;
	local String GroupString;
	
	if (TheGameState.CurrentDay == APOCALYPSE_DAY)
	{
		// If it showed up on Friday, say we need it here too.
		// DON'T DO DAYBLOCKERS THOUGH, THEY BREAK THE APOCALYPSE
		GroupString = Caps(CheckA.Group);
		if (DayBlocker(CheckA) == None && InStr(GroupString, Days[PREAPOCALYPSE_DAY].UniqueName) >= 0)
			NeededFriday = 1;
		
		// See if we want it for the actual Apocalypse
		Super.NeededForThisDay(CheckA, NeededApocalypse, SpecifiedDay);
		
		Needed = NeededFriday | NeededApocalypse;
		
		// If it's a weapon or ammo pickup, we want it no matter what
		if (P2WeaponPickup(CheckA) != None || P2AmmoPickup(CheckA) != None)
			Needed = 1;
	}
	else
		Super.NeededForThisDay(CheckA, Needed, SpecifiedDay);
}

///////////////////////////////////////////////////////////////////////////////
// The player has watched the last movie in the game and successfully beaten
// the game! Put up the stats screen as we load the main menu.
///////////////////////////////////////////////////////////////////////////////
function EndOfGame(P2Player player)
	{
	P2RootWindow(player.Player.InteractionMaster.BaseMenu).EndingGame();

	// If we haven't called time yet, do so now
	TheGameState.TimeStop = Level.GetMillisecondsNow();

	// Set that you want the stats
	bShowStatsDuringLoad=true;

	// Only save sequence 'time' if beaten at average difficulty or higher
	// (Or if we've already unlocked it, give it to them again)
	if(GetDifficultyOffset() >= 0
		|| TheGameState.bEGameStart)
		InfoSeqTime = GetSeqTime();
	ConsoleCommand("set "@InfoSeqPath@InfoSeqTime);
	RecordEnding();
	log(self$" GameRefVal new InfoSeqTime "$InfoSeqTime$" GameRefVal "$GameRefVal$" fover "$FOver);

	// xPatch: Must be played from the first day to get these achievement		
	if(TheGameState.StartDay == 0)	
	{
		// Grant achievement if we beat Paradise Lost
		if (FinallyOver())
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'PLFridayComplete');
		}

		// Grant achievements for beating the game in certain ways

		// Speedrun ending
		if (TheGameState.TimeElapsed <= PLGameState(TheGameState).SPEEDRUN_ACHIEVEMENT
			&& !VerifySeqTime())				// Can't be in Enhanced
			{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'PLSpeedRun',true);
			}
		// Jesus ending
		if (TheGameState.PeopleKilled + PLGameState(TheGameState).AnimalKills == 0)
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'PLJesusRun',true);
		}
		// Gone Wild ending
		if (InNightmareMode())		// Beat the game in nightmare mode
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'PLPOSTALRun',true);
		}
	}
		
	// Shut off the apocalypse
	bQuitting = true;

	// Send player to main menu (set flag to indicate that pawn might be none)
	SendPlayerTo(GetPlayer(), MainMenuURL, true);
	}
	
///////////////////////////////////////////////////////////////////////////////
// Set up for the Apocalypse.
///////////////////////////////////////////////////////////////////////////////
function PrepDifficulty()
{
	Super.PrepDifficulty();
	
	if(TheGameState != None)
	{
		// Set the gamestate flag to true, startup will handle the rest.
		if (IsApocalypse())
			TheGameState.bIsApocalypse = true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if we can rain cats on this map. (False for indoor maps)
///////////////////////////////////////////////////////////////////////////////
function bool MapOkForCats(String MapName)
{
	if (MapName ~= "pl-bandithideout"
		|| MapName ~= "pl-brewery"
		|| MapName ~= "pl-colemancave"
		|| MapName ~= "pl-eastmall"
		|| MapName ~= "pl-finalboss"
		|| MapName ~= "pl-hell_part1"
		|| MapName ~= "pl-hell_part2"
		|| MapName ~= "pl-library1"
		|| MapName ~= "pl-library2"
		|| MapName ~= "pl-robofact"
		|| MapName ~= "pl-saloon"
		|| MapName ~= "pl-slaughterhouse"
		|| MapName ~= "pl-torabora"
		|| MapName ~= "pl-underhub"
		|| MapName ~= "pl-westmall"
		|| MapName ~= "pl-winterwonderland"
		|| MapName ~= "pl-credits"
		|| MapName ~= "pl-outro"
		|| MapName ~= "pl-outro-ac")
		return false;
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Check to rain cats during the apocalypse
///////////////////////////////////////////////////////////////////////////////
function CheckCatRain(float DeltaTime)
{
	local P2Player p2p;
	local CatRocket catr;
	local vector dir, StartLoc;
	local float tempf;

	CatRainTime -= DeltaTime;

	// Check to toggle rain
	if(CatRainTime <= 0)
	{
		bRainingCats = !bRainingCats;
		if(bRainingCats)
			CatRainTime = RAIN_BASE_TIME + Rand(RAIN_RAND_TIME);
		else
			CatRainTime = Rand(RAIN_BASE_TIME);
	}

	if(bRainingCats && bCurrentMapOkForCats)
	{
		NewCatTime -= DeltaTime;
		if(NewCatTime <= 0)
		{
			p2p = GetPlayer();
			if(p2p != None
				&& p2p.MyPawn != None)
			{
				NewCatTime = NEW_CAT_BASE_TIME + Rand(NEW_CAT_RAND_TIME);
				// Make it generally in front of the player
				// Move it in front of him
				StartLoc = vector(p2p.MyPawn.Rotation);
				StartLoc.z = 0;
				StartLoc = (FRand()*CAT_MAKE_RANGE_DIST + CAT_MAKE_BASE_DIST) * StartLoc;
				// Vaguely center the rain if he's dead
				if(p2p.MyPawn.Health <= 0)
				{
					tempf = 0.5*(CAT_MAKE_RANGE_DIST + CAT_MAKE_BASE_DIST);
					StartLoc.x += tempf;
					StartLoc.y += tempf;
				}
				// Now create a range around that point
				tempf = (0.5*CAT_MAKE_RANGE_XY);
				StartLoc.x = StartLoc.x + (FRand()*CAT_MAKE_RANGE_XY - tempf);
				StartLoc.y = StartLoc.y + (FRand()*CAT_MAKE_RANGE_XY - tempf);
				// Move it above him
				StartLoc.z += CAT_MAKE_Z;
				StartLoc = StartLoc + p2p.MyPawn.Location;
				dir = VRand();
				dir.z=-1;
				if (FRand() < 0.1)
					catr = spawn(class'CowRocket',,,StartLoc,Rotator(dir));
				else
					catr = spawn(class'CatRocket',,,StartLoc,Rotator(dir));
				if(catr != None)
				{
					catr.AmbientGlow=255;	// make them pulse so they're easier to see.
					// modify speed for a gentle rain
					Dir = vector(catr.Rotation);
					catr.Velocity = CAT_RAIN_SPEED * Dir;
					catr.Acceleration.z = CAT_RAIN_ACC;
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add a controller to our newly spawned cat
///////////////////////////////////////////////////////////////////////////////
function AddController(FPSPawn newcat)
{
	if ( newcat.Controller == None
		&& newcat.Health > 0 )
	{
		if ( (newcat.ControllerClass != None))
			newcat.Controller = spawn(newcat.ControllerClass);
		if ( newcat.Controller != None )
			newcat.Controller.Possess(newcat);
		// Check for AI Script
		newcat.CheckForAIScript();
	}
}

///////////////////////////////////////////////////////////////////////////////
// See if we got a super champ to travel with the Dude, if not then make a
// new one.
///////////////////////////////////////////////////////////////////////////////
function CheckForSuperChamp()
{
	local DogPawn Doge;
	local DogController Dogc;
	local FPSPawn DudePawn;
	
	DudePawn = FPSPawn(GetPlayer().Pawn);
	if (DudePawn == None)
		return;
		
	foreach DynamicActors(class'DogPawn', Doge)
		if (Doge.Class == SuperChampClass)
			break;	// Found it			
			
	// Didn't find it, make a new one.
	if (Doge == None || Doge.Class != SuperChampClass)
	{
		Doge=spawn(SuperchampClass,,,DudePawn.Location,DudePawn.Rotation);
		if (Doge == None)
			return;
		AddController(Doge);
	}
	
	// Take the existing, or new one, and make damn sure they love us
	DogC=DogController(Doge.Controller);
	DogC.HookHero(DudePawn); // the player is our hero
	DogC.ChangeHeroLove(DogC.HERO_LOVE_MAX,0);
	DogC.GoToHero();	
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Monitor things in the game, and rain cats
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunningApocalypse
{
	function BeginState()
	{
		Super.BeginState();
		// Init new cat time, the first time the level starts
		NewCatTime = NEW_CAT_BASE_TIME + Rand(NEW_CAT_RAND_TIME);
		CheckForSuperChamp();
		bCurrentMapOkForCats = MapOkForCats(class'P2EUtils'.Static.GetCurrentMapFileName(GetPlayer()));
		if (!bCurrentMapOkForCats)
			bRainingCats = false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// StartUp
// Do things at the absolute last moment before the game starts
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state StartUp
{
	///////////////////////////////////////////////////////////////////////////////
	// The gameinfo has everything ready so now we tell the player controller
	// to prepare itself for a save.
	// In this game, we don't have an intro to bring up the map for the player,
	// so we force the map up before they save.
	///////////////////////////////////////////////////////////////////////////////
	function PrepPlayerStartup()
	{
		local P2Player p2p;

		p2p = GetPlayer();

		if(p2p != None && TheGameState.bFirstLevelOfDay && !bTesting && p2p.GetCurrentSceneManager() == None)
			p2p.ForceMapUp();

		// Check for the C4 errand hotfix.
		if (p2p != None && TheGameState.bFirstLevelOfDay && TheGameState.CurrentDay == C4_DAY)
			C4ErrandFix();
		
		Super.PrepPlayerStartup();
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// C4BrokenState
// Player has loaded a sequence-broken save and is stuck in the Forest.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state C4BrokenState
{
Begin:
	Sleep(5.0);
	GetPlayer().ClientMessage("I see you're stuck in the Survivalist Encampment! Please stand by for a free ride outta here.");
	Sleep(5.0);
	SendPlayerTo(GetPlayer(), C4_ESCAPE_URL);
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Update Main Menu depending on the time of week.
///////////////////////////////////////////////////////////////////////////////
function UpdateMainMenu()
{
	local string NewMenuURL;
	
	if(ParseLevelName(Level.GetLocalURL()) != MainMenuURL)
	{
		if(IsApocalypse())
			NewMenuURL = DynamicMainMenuURL[1];
		else
			NewMenuURL = DynamicMainMenuURL[0];
		
		default.MainMenuURL = NewMenuURL;
		MainMenuURL = NewMenuURL;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	///////////////////////////////////////////////////////////////////////////////
	// MONDAY ERRANDS
	///////////////////////////////////////////////////////////////////////////////
	
	// Ask about Champ.
	Begin Object Class=ErrandGoalGetAmmoMax Name=ErrandGoalAskAboutChamp
		TriggerOnCompletionTag="ChampErrand_Completed"
		InvClassName="ClipboardWeapon"
		ActivateErrandName="TalkToKrotchy"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseAskAboutChamp
		UniqueName="AskAboutChamp"
		NameTex="PLHud.Map.AskAboutChamp_text"
		// takes place everywhere so no location is used
		DudeStartComment="PL-Dialog.MapScreen.Dude-AskAbout1"
		DudeFoundComment="PL-Dialog.MapScreen.Dude-AskAbout2"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-AskAbout3"
		Goals(0)=ErrandGoal'ErrandGoalAskAboutChamp'
	End Object
	
	// Check animal control center.
	Begin Object Class=ErrandGoalTag Name=ErrandGoalCheckKennels
		UniqueTag="KennelsChecked"
		TriggerOnCompletionTag="proteststorm"
	End Object
	Begin Object Class=ErrandGoalTag Name=ErrandGoalCheckKennelsAfterWang
		// Errand goal changes if dude finishes the Wise Wang Errand first.
		UniqueTag="KennelsChecked"
		TriggerOnCompletionTag="proteststorm"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-BallSackWasRight"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseCheckKennels
		UniqueName="CheckKennels"
		NameTex="PLHud.Map.AnimalControl_text"
		LocationTex="PLHud.Map.AnimalControl_here"
		LocationX=556.000000
		LocationY=291.000000
		LocationCrossTex="PLHud.Map.AnimalControl_cross"
		LocationCrossX=555.000000
		LocationCrossY=355.000000
		DudeStartComment="PL-Dialog.MapScreen.Dude-ChampAnimal1"
		DudeWhereComment="PL-Dialog.MapScreen.Dude-1LetsSee"
		DudeFoundComment="PL-Dialog.MapScreen.Dude-2NeedToGoHere"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-ChampAnimal2"
		Goals(0)=ErrandGoal'ErrandGoalCheckKennels'
	End Object
	KennelGoalDefault=ErrandGoal'ErrandGoalCheckKennels'
	KennelGoalAfterWiseWang=ErrandGoal'ErrandGoalCheckKennelsAfterWang'
	
	// Eat
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalStealFastFood
		// Steal the fast food by jumping the counter.
		PickupClassName="FastFoodPickup"
		TriggerOnCompletionTag="MutantDogAttack"
		HateClass="CockButchers"
		HatePicTex="PLHud.Map.Hate_Group1Pic"
		HateComment="PL-Dialog.MapScreen.Dude-HateGroup3"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3TooEasy"
	End Object
	Begin Object Class=ErrandGoalGetInvClassFromPerson Name=ErrandGoalBuyFastFood
		// Buy fast food.
		InvClassName="FastFoodInv"
		TalkToMeTag="CockAsianCashier"
		TriggerOnCompletionTag="MutantDogAttack"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3AndDone"
		// EDIT: skip the hate class if they complete the errand lawfully
		//HateClass="CockButchers"
		//HateDesTex="p2misc.map.Hate_Group4Name"
		//HatePicTex="P2Misc.Map.Hate_Group4Pic"
		//HateComment="DudeDialog.dude_map_hate3"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetFastFood
		UniqueName="Eat"
		NameTex="PLHud.Map.EatSomething_text"
		LocationTex="PLHud.Map.EatSomething_here"
		LocationX=486.000000
		LocationY=359.000000
		LocationCrossTex="p2misc.map.hint_cross_2"
		LocationCrossX=486.000000
		LocationCrossY=358.000000
		DudeStartComment="PL-Dialog.MapScreen.Dude-Eat1"
		DudeWhereComment="PL-Dialog.MapScreen.Dude-1Hmm"
		DudeFoundComment="PL-Dialog.MapScreen.Dude-Eat2"
		//DudeCompletedComment="DudeDialog.dude_map_tooeasy"
		Goals(0)=ErrandGoal'ErrandGoalStealFastFood'
		Goals(1)=ErrandGoal'ErrandGoalBuyFastFood'
	End Object
	
	// Talk to the Wise Wang
	Begin Object Class=ErrandGoalTag Name=ErrandGoalTalkToWiseWang
		// Talk to Krotchy
		UniqueTag="WiseWangComplete"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-HowMuchFaith-BetterCheck"
	End Object
	Begin Object Class=ErrandGoalTag Name=ErrandGoalTalkToWiseWangAfterKennels
		// Talk to Krotchy
		UniqueTag="WiseWangComplete"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseTalkToWiseWang
		bInitiallyActive=false	// Activates when finishing the Ask About Champ errand
		UniqueName="TalkToKrotchy"
		NameTex="PLHud.Map.FindWiseMan_text"
		LocationTex="PLHud.Map.FindWiseMan_here"
		LocationX=636.000000
		LocationY=209.000000
		LocationCrossTex="PLHud.Map.FindWiseMan_cross"
		LocationCrossX=666.000000
		LocationCrossY=211.000000
		DudeStartComment="PL-Dialog.MapScreen.Dude-SpeakToWise1"
		DudeWhereComment="PL-Dialog.MapScreen.Dude-1WhereIsThat"
		DudeFoundComment="PL-Dialog.MapScreen.Dude-2LooksLikeThePlace"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-SpeaktoWise2"
		Goals(0)=ErrandGoal'ErrandGoalTalkToWiseWang'
	End Object
	WiseWangGoalDefault=ErrandGoal'ErrandGoalTalkToWiseWang'
	WiseWangGoalAfterKennel=ErrandGoal'ErrandGoalTalkToWiseWangAfterKennels'
	
	///////////////////////////////////////////////////////////////////////////////
	// TUESDAY ERRANDS
	///////////////////////////////////////////////////////////////////////////////	
	
	// Get Toilet Paper
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalStealToiletPaper
		// Steal toilet paper
		PickupClassName="ToiletPaperPickup"
		TriggerOnCompletionTag="WHLawmenAttack"
	End Object
	Begin Object Class=ErrandGoalGetInvClassFromPerson Name=ErrandGoalBuyToiletPaper
		// Buy the toilet paper
		InvClassName="ToiletPaperInv"
		TalkToMeTag="WipeHouseCashier"
		TriggerOnCompletionTag="WHLawmenAttack"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetToiletPaper
		UniqueName="ToiletPaper"
		NameTex="PLHud.Map.GetTP_text"
		LocationTex="PLHud.Map.GetTP_here"
		LocationX=360.000000
		LocationY=362.000000
		LocationCrossTex="p2misc.map.hint_cross_2"
		LocationCrossX=365.000000
		LocationCrossY=369.000000
		DudeStartComment="PL-Dialog.MapScreen.Vince-BuyARoll"
		DudeFoundComment="PL-Dialog.MapScreen.Vince-StoresRightHere"
		DudeWhereComment=""
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3MissionAccomplished01"
		Goals(0)=ErrandGoal'ErrandGoalBuyToiletPaper'
		Goals(1)=ErrandGoal'ErrandGoalStealToiletPaper'
	End Object
	
	// Deliver Motherboard
	Begin Object Class=ErrandGoalTag Name=ErrandGoalGiveWeapons
		// Trade weapons to Yeland in exchange for getting the motherboards installed.
		UniqueTag="WeaponsGiven"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3BitesTheDust"
	End Object
	Begin Object Class=ErrandGoalUseUpInventory Name=ErrandGoalInstallMotherboards
		// Forcibly install motherboards without Yeland's permission.
		InvClassName="PLInventory.MotherboardInv"
		TriggerOnCompletionTag="YelandShowdown"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3CloseEnough"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseDeliverMotherboard
		UniqueName="DeliverMotherboard"
		NameTex="PLHud.Map.DeliverMotherboard_text"
		LocationTex="PLHud.Map.DeliverMotherboard_here"
		LocationX=528.000000
		LocationY=295.000000
		LocationCrossTex="PLHud.Map.DeliverMotherboard_cross"
		LocationCrossX=527.000000
		LocationCrossY=299.000000
		DudeStartComment="PL-Dialog.MapScreen.Vince-HotNewGame"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog.MapScreen.Vince-TheresTheArcade"
		//DudeCompletedComment="DudeDialog.dude_map_closeenough"
		Goals(0)=ErrandGoal'ErrandGoalGiveWeapons'
		Goals(1)=ErrandGoal'ErrandGoalInstallMotherboards'
	End Object
	
	// Wreck Competition's Equipment
	Begin Object Class=ErrandGoalTag Name=ErrandGoalWreckEquipment
		// Kick/destroy/wreck the karma objects in the BO building
		UniqueTag="EquipmentDestroyed"
		TriggerOnCompletionTag="BOLawmenAttack"
		HateClass="PUGamesEmployee"
		HatePicTex="PLHud.Map.Hate_Group2Pic"
		HateComment="PL-Dialog.MapScreen.Dude-HateGroup2"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseWreckCompetition
		UniqueName="WreckCompetition"
		NameTex="PLHud.Map.WreckCompetition_text"
		LocationTex="PLHud.Map.WreckCompetition_here"
		LocationX=475.000000
		LocationY=575.000000
		LocationCrossTex="PLHud.Map.WreckCompetition_cross"
		LocationCrossX=463.000000
		LocationCrossY=613.000000
		DudeStartComment="PL-Dialog.MapScreen.Vince-TurnsOutSomeScumbag"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog.MapScreen.Vince-ThoseAssHolesAreOverThere"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3MissionAccomplished02"
		Goals(0)=ErrandGoal'ErrandGoalWreckEquipment'
	End Object

	///////////////////////////////////////////////////////////////////////////////
	// WEDNESDAY ERRANDS
	///////////////////////////////////////////////////////////////////////////////	

	// Collect money for charity.
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalStealZacksMoney
		PickupTag="MoneySack"
		TriggerOnCompletionTag="GingerAttack"
		HateClass="Farcii"
		HatePicTex="PLHud.Map.Hate_Group3Pic"
		HateComment="PL-Dialog.MapScreen.Dude-HateGroup5"
	End Object
	Begin Object Class=ErrandGoalGetAmmoMax Name=ErrandGoalCollectCharityMoney
		InvClassName="CanWeapon"
		DudeCompletedComment="PL-Dialog.WednesdayA.Dude-9GeeWhatAnExcitingLife"
		UnlockAchievement="PLCollectMoney"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseCollectCharityMoney
		UniqueName="CollectCharityMoney"
		DudeStartComment="PL-Dialog.MapScreen.MikeJ-1IRequireMoneyAskYokel"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3AndDone"
		// FIXME put in proper location and texture
		DudeWhereComment="PL-Dialog.WednesdayA.Dude-7ZackWardsCompound-A"
		DudeFoundComment="PL-Dialog.WednesdayA.Dude-7ZackWardsCompound-B"
		bLocationTexActive=false
		NameTex="PLHud.Map.CharityMoney_text"
		LocationTex="PLHud.Map.ZackWard_here"
		LocationX=681.000000
		LocationY=560.000000
		LocationCrossTex="PLHud.Map.AnimalControl_cross"
		LocationCrossX=675.000000
		LocationCrossY=554.000000
		Goals(0)=ErrandGoal'ErrandGoalStealZacksMoney'
		Goals(1)=ErrandGoal'ErrandGoalCollectCharityMoney'
		IgnoreTag="CoreyDudeSuggestionTrigger"
		bIgnoreAfterCompletion=True
	End Object
	
	// Get Breast Pump
	Begin Object Class=ErrandGoalTag Name=ErrandGoalGetBreastPump
		UniqueTag="MilkingGameComplete"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetBreastPump
		UniqueName="GetBreastPump"
		NameTex="PLHud.Map.GetBreastPump_text"
		LocationTex="PLHud.Map.BreastPump_here"
		LocationX=735.000000
		LocationY=184.000000
		LocationCrossTex="PLHud.Map.FindWiseMan_cross"
		LocationCrossX=728.000000
		LocationCrossY=192.000000
		DudeStartComment="PL-Dialog.MapScreen.MikeJ-3BringMeABreastPump"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog.MapScreen.MikeJ-4LocalOldCootsFarm"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3PieceOfCake"
		Goals(0)=ErrandGoal'ErrandGoalGetBreastPump'
	End Object
	
	// Get A/C Parts
	Begin Object Class=ErrandGoalCompleteSuberrands Name=ErrandGoalGetACParts
		SuberrandName(0)="GetACPart1"
		SuberrandName(1)="GetACPart2"
		SuberrandName(2)="GetACPart3"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetACParts
		UniqueName="GetACParts"
		NameTex="PLHud.Map.GetACParts_text"
		// No location data for this errand, only in the suberrands
		DudeStartComment="PL-Dialog.MapScreen.MikeJ-5SpendOurHoneymoon"
		DudeWhereComment=""
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3BitesTheDust"
		Goals(0)=ErrandGoal'ErrandGoalGetACParts'
	End Object
	// AC Part 1 - junkyard
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetACPart1
		PickupTag="JunkyardACPart"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetACPart1
		UniqueName="GetACPart1"
		// No name tex or starting comment, just use the errand for the location scribble.
		DudeFoundComment="PL-Dialog.MapScreen.MikeJ-6OnePartInThisTrash"
		DudeCompletedComment="DudeDialog.dude_map_next"
		LocationTex="PLHud.Map.ACParts_Junkyard_here"
		LocationX=368.000000
		LocationY=591.000000
		LocationCrossTex="p2misc.map.hint_cross_4"
		LocationCrossX=373.000000
		LocationCrossY=665.000000
		Goals(0)=ErrandGoal'ErrandGoalGetACPart1'
	End Object
	// AC Part 2 - junk market
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalStealACPart2
		PickupTag="MarketACPart"
		TriggerOnCompletionTag="StoleACPart"
	End Object
	Begin Object Class=ErrandGoalGetInvClassFromPerson Name=ErrandGoalBuyACPart2
		InvClassName="ACPartInv"
		TalkToMeTag="ACPartSeller"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetACPart2
		UniqueName="GetACPart2"
		// No name tex or starting comment, just use the errand for the location scribble.
		DudeFoundComment="PL-Dialog.MapScreen.MikeJ-7CheckTheMarket"
		DudeCompletedComment="DudeDialog.dude_map_next"
		LocationTex="PLHud.Map.ACParts_Trainyard_here"
		LocationX=446.000000
		LocationY=191.000000
		LocationCrossTex="PLHud.Map.DeliverMotherboard_cross"
		LocationCrossX=465.000000
		LocationCrossY=203.000000
		Goals(0)=ErrandGoal'ErrandGoalStealACPart2'
		Goals(1)=ErrandGoal'ErrandGoalBuyACPart2'
		IgnoreTag="MarketACPart"
		bIgnoreAfterCompletion=True
	End Object
	// AC Part 3 - asylum
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalStealACPart3
		PickupTag="AsylumACPart"
		TriggerOnCompletionTag="derp"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetACPart3
		UniqueName="GetACPart3"
		// No name tex or starting comment, just use the errand for the location scribble.
		DudeFoundComment="PL-Dialog.MapScreen.MikeJ-8CraziesAtTheLooneyBin"
		DudeCompletedComment="PL-Dialog.WednesdayC.Dude-6GuessTheyWereRight"
		LocationTex="PLHud.Map.ACParts_Asylum_here"
		LocationX=468.000000
		LocationY=664.000000
		LocationCrossTex="PLHud.Map.ACParts_Asylum_cross"
		LocationCrossX=470.000000
		LocationCrossY=705.000000
		Goals(0)=ErrandGoal'ErrandGoalStealACPart3'
	End Object
	
	///////////////////////////////////////////////////////////////////////////////
	// THURSDAY ERRANDS
	///////////////////////////////////////////////////////////////////////////////
	// Get Ensmallen Cure chemicals
	Begin Object Class=ErrandGoalGetInvClassFromPerson Name=ErrandGoalGetCureChemical
		// Buy cure chemicals for the low, low price of $1,000
		TalkToMeTag="ChemCashier"
		InvClassName="CureInv"		
		TriggerOnCompletionTag="GetRobbed"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3MissionAccomplished01"
	End Object
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalStealCureChemical
		// Steal cure chemical from the Rednecks
		PickupClassName="CurePickup"
		// FIXME this won't be needed in the final, but is here for picking up the debug pickup in the chemical plant lobby
		TriggerOnCompletionTag="GetRobbed"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3MissionAccomplished02"
	End Object	
	Begin Object Class=ErrandBase Name=ErrandBaseGetCureChemical
		UniqueName="GetCureChemical"
		NameTex="PLHud.Map.GetCureChemical_text"
		LocationTex="PLHud.Map.GetCureChemical_here"
		LocationX=425.000000
		LocationY=322.000000
		LocationCrossTex="p2misc.map.hint_cross_1"
		LocationCrossX=428.000000
		LocationCrossY=366.000000
		DudeStartComment="PL-Dialog2.BigMcWillis-01BringChemicals"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog2.BigMcWillis-01GetChemicalsHere"
		DudeCompletedComment=""
		Goals(0)=ErrandGoal'ErrandGoalGetCureChemical'
		Goals(1)=ErrandGoal'ErrandGoalStealCureChemical'
	End Object
	
	// Get Stilts
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetStilts
		PickupClassName="StiltsPickup"
		TriggerOnCompletionTag="CraptrapAttack"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetStilts
		UniqueName="GetStilts"
		NameTex="PLHud.Map.GetStilts_text"
		LocationTex="PLHud.Map.GetStilts_here"
		LocationX=286.000000
		LocationY=446.000000
		LocationCrossTex="p2misc.map.hint_cross_4"
		LocationCrossX=288.000000
		LocationCrossY=473.000000
		DudeStartComment="PL-Dialog2.BigMcWillis-02WeNeedMechanicalStilts"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog2.BigMcWillis-02GetPrototypePair"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3AndDone"
		Goals(0)=ErrandGoal'ErrandGoalGetStilts'		
	End Object
	
	// Sabotage Karaoke Bar
	Begin Object Class=ErrandGoalTag Name=ErrandGoalEmptyKaraokeBar
		// This is the errand goal for when the Dude sings the entire playlist and
		// makes the entirety of the bar patrons leave in disgust.
		UniqueTag="BarEmptied"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3TooEasy"
	End Object	
	Begin Object Class=ErrandGoalTag Name=ErrandGoalEmptyKaraokeBar_LeftEarly
		// This is the errand goal for if the Dude just sings one or two songs and then leaves.
		// The errand is still counted as complete, but he makes a remark about half-assing it.
		UniqueTag="LeftKaraokeEarly"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3CloseEnough"
	End Object		
	Begin Object Class=ErrandGoalTag Name=ErrandGoalWreckKaraokeBar
		// This goal is for the violent path where the Dude just shoots up the place.
		UniqueTag="WreckedKaraoke"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3PieceOfCake"
		TriggerOnCompletionTag="SurvivalistsAttackStart"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseSabotageKaraoke
		UniqueName="SabotageKaraoke"
		NameTex="PLHud.Map.SabotageKaraoke_text"
		LocationTex="PLHud.Map.SabotageKaraoke_here"
		LocationX=753.000000
		LocationY=373.000000
		LocationCrossTex="PLHud.Map.DeliverMotherboard_cross"
		LocationCrossX=803.000000
		LocationCrossY=383.000000
		DudeStartComment="PL-Dialog2.BigMcWillis-03StrikeGreatBlow"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog2.BigMcWillis-03CrushTheirKaraoke"
		DudeCompletedComment="DudeDialog.dude_map_anddone"
		Goals(0)=ErrandGoal'ErrandGoalEmptyKaraokeBar'
		Goals(1)=ErrandGoal'ErrandGoalEmptyKaraokeBar_LeftEarly'
		Goals(2)=ErrandGoal'ErrandGoalWreckKaraokeBar'
	End Object
	
	// Recover Cure
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalRecoverCureChemical
		// Steal cure chemical from the Bandits
		PickupClassName="CurePickup"
		HateClass="Bandits"
		HatePicTex="PLHud.Map.Hate_Group4Pic"
		HateComment="PL-Dialog.MapScreen.Dude-HateGroup1"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseRecoverCure
		UniqueName="RecoverCure"
		bInitiallyActive=false
		NameTex="PLHud.Map.RecoverCure_text"
		LocationTex="PLHud.Map.RecoverCure_here"
		LocationX=783.000000
		LocationY=714.000000
		LocationCrossTex="p2misc.map.hint_cross_2"
		LocationCrossX=771.000000
		LocationCrossY=710.000000
		DudeStartComment="PL-Dialog2.ThursdayPostErrandACutscene.Dude-4GetThatSyringe"
		DudeWhereComment="PL-Dialog.MapScreen.Dude-1LetsSee"
		DudeFoundComment="PL-Dialog2.ThursdayPostErrandACutscene.Dude-4ThisIsTheHideout"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3BitesTheDust"
		Goals(0)=ErrandGoal'ErrandGoalRecoverCureChemical'
	End Object	

	///////////////////////////////////////////////////////////////////////////////
	// FRIDAY ERRANDS
	///////////////////////////////////////////////////////////////////////////////	
	// Get C4
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalStealC4
		PickupClassName="C4Pickup"
		TriggerOnCompletionTag="SurvivalistEscapeSequence"
		HateClass="Survivalist"
		HatePicTex="PLHud.Map.Hate_Group5Pic"
		HateComment="PL-Dialog.MapScreen.Dude-HateGroup4"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetC4
		UniqueName="GetC4"
		NameTex="PLHud.Map.GetC4_text"
		LocationTex="PLHud.Map.GetC4_here"
		LocationX=691.000000
		LocationY=809.000000
		LocationCrossTex="p2misc.map.hint_cross_4"
		LocationCrossX=689.000000
		LocationCrossY=884.000000
		DudeStartComment="PL-Dialog.MapScreen.Osama-1CreateTheBomb"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog.MapScreen.Osama-1FindTheirEncampment"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3MissionAccomplished02"
		Goals(0)=ErrandGoal'ErrandGoalStealC4'
	End Object
	
	// Get Blasting Cap
	Begin Object Class=ErrandGoalGetInvClassFromPerson Name=ErrandGoalBuyBlastingCap
		TalkToMeTag="Habib"
		InvClassName="BlastingCapInv"
		TriggerOnCompletionTag="GimpVaultScene"
	End Object
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalStealBlastingCap
		PickupClassName="BlastingCapPickup"
		TriggerOnCompletionTag="GimpVaultScene"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetBlastingCap
		UniqueName="GetBlastingCap"
		NameTex="PLHud.Map.GetBlastingCap_text"
		LocationTex="PLHud.Map.GetBlastingCap_here"
		LocationX=654.000000
		LocationY=320.000000
		LocationCrossTex="PLHud.Map.GetBlastingCap_cross"
		LocationCrossX=743.000000
		LocationCrossY=334.000000
		DudeStartComment="PL-Dialog.MapScreen.Osama-2BlastingCap"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog.MapScreen.Osama-2FindTheStoreHere"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3TooEasy"
		Goals(0)=ErrandGoal'ErrandGoalBuyBlastingCap'
		Goals(1)=ErrandGoal'ErrandGoalStealBlastingCap'
	End Object
	
	// Prune Herbs
	Begin Object Class=ErrandGoalTag Name=ErrandGoalPruneHerbs
		UniqueTag="HerbsPruned"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBasePruneHerbs
		UniqueName="PruneHerbs"
		NameTex="PLHud.Map.PruneHerbs_text"
		LocationTex="PLHud.Map.PruneHerbs_here"
		LocationX=518.000000
		LocationY=84.000000
		LocationCrossTex="PLHud.Map.WreckCompetition_cross"
		LocationCrossX=619.000000
		LocationCrossY=76.000000
		DudeStartComment="PL-Dialog.MapScreen.Osama-3PersonalFavor"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog.MapScreen.Osama-3CompoundIsHere"
		DudeCompletedComment="PL-Dialog.MapScreen.Dude-3AndDone"
		Goals(0)=ErrandGoal'ErrandGoalPruneHerbs'
	End Object		
	
	///////////////////////////////////////////////////////////////////////////////
	// SHOWDOWN ERRANDS
	///////////////////////////////////////////////////////////////////////////////
	Begin Object Class=ErrandGoalTag Name=ErrandGoalDummy
		UniqueTag="Dummy"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseDummy
		UniqueName="DummyErrandDontCompleteMe"
		Goals(0)=ErrandGoal'ErrandGoalDummy'
	End Object
	
	///////////////////////////////////////////////////////////////////////////////
	// APOCALYPSE ERRANDS
	///////////////////////////////////////////////////////////////////////////////
	
	// Escape Town
	// NOTE: This errand is never actually completed, it serves only as a map marker
	// for the player, so they know where they need to get to in order to escape.
	// When the player reaches the escape point, the ending cinematic will play
	// and the game will end.
	Begin Object Class=ErrandGoalTag Name=ErrandGoalEscapeTown
		UniqueTag="TownEscaped_DontActuallyActivateMe"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseEscapeTown
		UniqueName="EscapeTown"
		NameTex="PLHud.Map.EscapeTown_text"
		LocationTex="PLHud.Map.EscapeTown_here"
		LocationX=410.000000
		LocationY=109.000000
		// FIXME If we cut the Apocalypse Conqueror path, swap this line out for PL-Dialog2.FridayShowdownPostApocalypse.Dude-6TheBestChoice
		DudeStartComment="PL-Dialog2.FridayShowdownPostApocalypse.Dude-5OrGetOutOfHere"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog2.FridayShowdownPostApocalypse.Dude-7LeaveThisShitHole"
		DudeCompletedComment=""
		Goals(0)=ErrandGoal'ErrandGoalEscapeTown'
	End Object
	// This is the "no Apocalypse Conqueror" version of the escape errand.
	Begin Object Class=ErrandBase Name=ErrandBaseMustEscapeTown
		UniqueName="EscapeTown"
		NameTex="PLHud.Map.EscapeTownOnly_text"
		LocationTex="PLHud.Map.EscapeTown_here"
		LocationX=410.000000
		LocationY=109.000000
		DudeStartComment="PL-Dialog2.FridayShowdownPostApocalypse.Dude-6TheBestChoice"
		DudeWhereComment=""
		DudeFoundComment="PL-Dialog2.FridayShowdownPostApocalypse.Dude-7LeaveThisShitHole"
		DudeCompletedComment=""
		Goals(0)=ErrandGoal'ErrandGoalEscapeTown'
	End Object
	
	// Revisit Factions
	// For the optional Apocalypse Conqueror Ending, the player can revisit all the factions
	// and kill their respective leaders to take over Paradise.
	// FIXME: As the Dude kills off the leaders, that faction should become friendly to the Dude
	Begin Object Class=ErrandGoalCompleteSuberrands Name=ErrandGoalConquerParadise
		SuberrandName(0)="KillVince"
		SuberrandName(1)="KillMikeJ"
		SuberrandName(2)="KillZack"
		SuberrandName(3)="KillGary"
		SuberrandName(4)="KillOsama"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseConquerParadise
		UniqueName="ConquerParadise"
		NameTex="PLHud.Map.DropByEveryFaction_text"
		// No location data for this errand, only in the suberrands
		DudeStartComment="PL-Dialog2.Dude-4DropByEveryFaction"
		DudeWhereComment=""
		DudeCompletedComment=""
		Goals(0)=ErrandGoal'ErrandGoalConquerParadise'
		SendPlayerURL="PL-Outro-AC"
	End Object
	// Kill Vince
	Begin Object Class=ErrandGoalTag Name=ErrandGoalKillVince
		UniqueTag="VinceKilled"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseKillVince
		UniqueName="KillVince"
		// No name tex or starting comment, just use the errand for the location scribble.
		// FIXME FIXME FIXME
		DudeFoundComment=""
		DudeCompletedComment=""
		LocationTex="PLHud.Map.KillVince_here"
		LocationX=285.000000
		LocationY=262.000000
		LocationCrossTex="p2misc.map.hint_cross_2"
		LocationCrossX=285.000000
		LocationCrossY=281.000000
		Goals(0)=ErrandGoal'ErrandGoalKillVince'
	End Object
	// Kill Mike J
	// FIXME may need a different class of ErrandGoal because the AW Cowboss isn't a regular pawn
	Begin Object Class=ErrandGoalTag Name=ErrandGoalKillMikeJ
		UniqueTag="MikeJKilled"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseKillMikeJ
		UniqueName="KillMikeJ"
		// No name tex or starting comment, just use the errand for the location scribble.
		// FIXME FIXME FIXME
		DudeFoundComment=""
		DudeCompletedComment=""
		LocationTex="PLHud.Map.KillMikeJ_here"
		LocationX=390.000000
		LocationY=576.000000
		LocationCrossTex="PLHud.Map.DeliverMotherboard_cross"
		LocationCrossX=383.000000
		LocationCrossY=660.000000
		Goals(0)=ErrandGoal'ErrandGoalKillMikeJ'
	End Object
	// Kill Zack
	Begin Object Class=ErrandGoalTag Name=ErrandGoalKillZack
		UniqueTag="ZackKilled"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseKillZack
		UniqueName="KillZack"
		// No name tex or starting comment, just use the errand for the location scribble.
		// FIXME FIXME FIXME
		DudeFoundComment=""
		DudeCompletedComment=""
		LocationTex="PLHud.Map.KillZack_here"
		LocationX=687.000000
		LocationY=541.000000
		LocationCrossTex="PLHud.Map.AnimalControl_cross"
		LocationCrossX=682.000000
		LocationCrossY=542.000000
		Goals(0)=ErrandGoal'ErrandGoalKillZack'
	End Object
	// Kill Gary
	Begin Object Class=ErrandGoalTag Name=ErrandGoalKillGary
		UniqueTag="GaryKilled"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseKillGary
		UniqueName="KillGary"
		// No name tex or starting comment, just use the errand for the location scribble.
		// FIXME FIXME FIXME
		DudeFoundComment=""
		DudeCompletedComment=""
		LocationTex="PLHud.Map.KillGary_here"
		LocationX=555.000000
		LocationY=447.000000
		LocationCrossTex="p2misc.map.hint_cross_1"
		LocationCrossX=582.000000
		LocationCrossY=458.000000
		Goals(0)=ErrandGoal'ErrandGoalKillGary'
	End Object
	// Kill Osama
	Begin Object Class=ErrandGoalTag Name=ErrandGoalKillOsama
		UniqueTag="OsamaKilled"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseKillOsama
		UniqueName="KillOsama"
		// No name tex or starting comment, just use the errand for the location scribble.
		DudeFoundComment=""
		DudeCompletedComment=""
		LocationTex="PLHud.Map.KillOsama_here"
		LocationX=494.000000
		LocationY=177.000000
		LocationCrossTex="PLHud.Map.KillOsama_cross"
		LocationCrossX=523.000000
		LocationCrossY=172.000000
		Goals(0)=ErrandGoal'ErrandGoalKillOsama'
	End Object	
	
	///////////////////////////////////////////////////////////////////////////////
	// DAY DEFINITIONS
	///////////////////////////////////////////////////////////////////////////////
	
	// Monday
	Begin Object Class=DayBase Name=PLMonday
		Description="Monday"
		UniqueName="DAY_A"
		StartDayURL	= "PL-intro"	// for Two Weeks In Paradise
        LoadTex="p2misc_full.loading1"
        MapTex="PLHud.Map.map_day1"
		Errands(0)=ErrandBase'ErrandBaseAskAboutChamp'
		Errands(1)=ErrandBase'ErrandBaseCheckKennels'
		Errands(2)=ErrandBase'ErrandBaseGetFastFood'
		Errands(3)=ErrandBase'ErrandBaseTalkToWiseWang'
		EndOfDayComment="PL-Dialog.MapScreen.Dude-NoLuck"
		FinishedDayURL="PL-EndOfMonday.fuk"
		NewsTex="PLHud.Newspapers.Paper_1_Mon"
		DudeNewsComment="PL-Dialog3.DudeNewspaper.Newspaper01-Mon"

		// Starting inventory (FIXME adjust later, tweak money amount and possibly remove the pistol, change cop clothes to lawmen chaps etc.)
		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=20)
		PlayerInvList(1)=(InvClassName="PLInventory.PLMapInv")
		PlayerInvList(2)=(InvClassName="PLInventory.LawmanClothesInv",bEnhancedOnly=true)
		PlayerInvList(3)=(InvClassName="Inventory.StatInv")
		PlayerInvList(4)=(InvClassName="PLInventory.PhotoWeapon")
		
		// Items taken from player at the end of the day
		TakeFromPlayerList(0)=(InvClassName="PLInventory.PhotoWeapon")
		TakeFromPlayerList(1)=(InvClassName="PLInventory.LawmanClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(3)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(4)=(InvClassName="PLInventory.PLNewspaperInv")
	End Object
	
	// Monday - They Hate Me Mode
	// In They Hate Me mode, the dude can't go around asking for Champ.
	// We also skip the Wise Wang errand, because the player doesn't need to sit through it again
	// and there's no logical way to actually get there without finishing the champ photo errand.
	Begin Object Class=DayBase Name=PLMondayHate
		Description="Monday"
		UniqueName="DAY_A"
		StartDayURL	= "PL-intro"	// for Two Weeks In Paradise
        LoadTex="p2misc_full.loading1"
        MapTex="PLHud.Map.map_day1"
		Errands(0)=ErrandBase'ErrandBaseCheckKennels'
		Errands(1)=ErrandBase'ErrandBaseGetFastFood'
		EndOfDayComment="PL-Dialog.MapScreen.Dude-NoLuck"
		FinishedDayURL="PL-EndOfMonday.fuk"
		NewsTex="PLHud.Newspapers.Paper_1_Mon"
		DudeNewsComment="PL-Dialog3.DudeNewspaper.Newspaper01-Mon"

		// Starting inventory (FIXME adjust later, tweak money amount and possibly remove the pistol, change cop clothes to lawmen chaps etc.)
		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=20)
		PlayerInvList(1)=(InvClassName="PLInventory.PLMapInv")
		PlayerInvList(2)=(InvClassName="PLInventory.LawmanClothesInv",bEnhancedOnly=true)
		PlayerInvList(3)=(InvClassName="Inventory.StatInv")
		
		// Items taken from player at the end of the day
		TakeFromPlayerList(0)=(InvClassName="PLInventory.LawmanClothesInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(3)=(InvClassName="PLInventory.PLNewspaperInv")
	End Object
	
	// Tuesday
	Begin Object Class=DayBase Name=PLTuesday
		Description="Tuesday"
		UniqueName="DAY_B"
		StartDayURL="PL-Church"
        LoadTex="p2misc_full.loading2"
        MapTex="PLHud.Map.map_day2"
		Errands(0)=ErrandBase'ErrandBaseGetToiletPaper'
		Errands(1)=ErrandBase'ErrandBaseDeliverMotherboard'
		Errands(2)=ErrandBase'ErrandBaseWreckCompetition'
		EndOfDayComment="PL-Dialog.MapScreen.Dude-ReturnToChurch"
		DudeStartComment="PL-Dialog.TuesdayIntro.Vince-GetYourAssOutThere"
		FinishedDayURL="PL-Church.fuk#EndOfTuesdayTelepad?peer"
		NewsTex="PLHud.Newspapers.Paper_2_TUE"
		DudeNewsComment="PL-Dialog3.DudeNewspaper.Newspaper02-Tue"
		
		// Items given at the start of the day
		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=20)		// Give some money again, in case the dude is broke. He'll need it for the TP.
		PlayerInvList(1)=(InvClassName="PLInventory.MotherboardInv",NeededAmount=4)	// For the Yeland errand
		PlayerInvList(2)=(InvClassName="PLInventory.DualWieldInv",NeededAmount=5,bEnhancedOnly=true)
		
		// Items taken from player at the end of the day
		TakeFromPlayerList(0)=(InvClassName="PLInventory.MotherboardInv")
		TakeFromPlayerList(1)=(InvClassName="PLInventory.LawmanClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(3)=(InvClassName="PLInventory.ToiletPaperInv")
		TakeFromPlayerList(4)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(5)=(InvClassName="PLInventory.PLNewspaperInv")
	End Object
	
	// Wednesday
	Begin Object Class=DayBase Name=PLWednesday
		Description="Wednesday"
		UniqueName="DAY_C"
		StartDayURL="PL-Junkyard#Junkyardstart"
		FinishedDayURL="PL-JunkyardArena"
        LoadTex="p2misc_full.loading3"
        MapTex="PLHud.Map.map_day3"
		Errands(0)=ErrandBase'ErrandBaseCollectCharityMoney'
		Errands(1)=ErrandBase'ErrandBaseGetBreastPump'
		Errands(2)=ErrandBase'ErrandBaseGetACParts'
		Errands(3)=ErrandBase'ErrandBaseGetACPart1'
		Errands(4)=ErrandBase'ErrandBaseGetACPart2'
		Errands(5)=ErrandBase'ErrandBaseGetACPart3'
		DudeStartComment="PL-Dialog.MapScreen.MikeJ-9FinishTheseTasks"
		EndOfDayComment="PL-Dialog.MapScreen.Dude-BetterCheckOnJunkYard"
		NewsTex="PLHud.Newspapers.Paper_3_WED"
		DudeNewsComment="PL-Dialog3.DudeNewspaper.Newspaper03-Wed"

		// Items given at the start of the day
		PlayerInvList(0)=(InvClassName="PLInventory.CanWeapon")						// Collection can weapon
		PlayerInvList(1)=(InvClassName="Inventory.CatnipInv",NeededAmount=5,bEnhancedOnly=true)
		
		// Items taken from player at the end of the day
		TakeFromPlayerList(0)=(InvClassName="PLInventory.CanWeapon")
		TakeFromPlayerList(1)=(InvClassName="PLInventory.ACPartInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(3)=(InvClassName="PLInventory.PLNewspaperInv")
		//TakeFromPlayerList(2)=(InvClassName="PLInventory.BreastPumpInv")
	End Object
	
	// Thursday
	Begin Object Class=DayBase Name=PLThursday
		Description="Thursday"
		UniqueName="DAY_D"
		StartDayURL="PL-ColemanCave"
		FinishedDayURL="PL-ColemanCave#EndOfThursdayTelePad"
        LoadTex="p2misc_full.loading4"
        MapTex="PLHud.Map.map_day4"
		Errands(0)=ErrandBase'ErrandBaseGetCureChemical'
		Errands(1)=ErrandBase'ErrandBaseGetStilts'
		Errands(2)=ErrandBase'ErrandBaseSabotageKaraoke'
		Errands(3)=ErrandBase'ErrandBaseRecoverCure'
		DudeStartComment="PL-Dialog2.BigMcWillis-04NowHeadForth"
		EndOfDayComment="PL-Dialog.MapScreen.Dude-GuessImDone"
		NewsTex="PLHud.Newspapers.Paper_4_THUR"
		DudeNewsComment="PL-Dialog3.DudeNewspaper.Newspaper04-Thur"
		
		// Items given at the start of the day
		PlayerInvList(0)=(InvClassName="Inventory.RocketCamInv",bEnhancedOnly=true)
		
		// Items taken at the end of the day
		TakeFromPlayerList(0)=(InvClassName="PLInventory.CureInv")
		TakeFromPlayerList(1)=(InvClassName="PLInventory.StiltsInv")
		TakeFromPlayerList(2)=(InvClassName="PLInventory.EnsmallenWeapon")
		TakeFromPlayerList(3)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(4)=(InvClassName="PLInventory.PLNewspaperInv")
	End Object
	
	// Friday
	Begin Object Class=DayBase Name=PLFriday
		Description="Friday"
		UniqueName="DAY_E"
		StartDayURL="PL-ToraBora"
		FinishedDayURL="PL-ToraBora#EndOfFridayTelepad"
        LoadTex="p2misc_full.loading5"
        MapTex="PLHud.Map.map_day4"
		Errands(0)=ErrandBase'ErrandBaseGetC4'
		Errands(1)=ErrandBase'ErrandBaseGetBlastingCap'
		Errands(2)=ErrandBase'ErrandBasePruneHerbs'
		DudeStartComment="PL-Dialog.MapScreen.Osama-4GoodLuckBrother"
		EndOfDayComment="PL-Dialog.MapScreen.Dude-HeadBackNow"
		NewsTex="PLHud.Newspapers.Paper_5_FRI"
		DudeNewsComment="PL-Dialog3.DudeNewspaper.Newspaper05-Fri"
		
		// Items given at the start of the day
		PlayerInvList(0)=(InvClassName="PLInventory.EnsmallenWeapon",bEnhancedOnly=true)
		
		// Items taken at the end of the day
		TakeFromPlayerList(0)=(InvClassName="PLInventory.C4Inv")
		TakeFromPlayerList(1)=(InvClassName="PLInventory.BlastingCapInv")
		// Map taken when the player finishes the day and enters the HellHole.
		TakeFromPlayerList(2)=(InvClassName="PLInventory.PLMapInv")
		//TakeFromPlayerList(3)=(InvClassName="PLInventory.EnsmallenWeapon")
		TakeFromPlayerList(3)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(4)=(InvClassName="PLInventory.PLNewspaperInv")
	End Object
	
	// Showdown Day
	// For when the Dude enters the Hell Hole to do battle with the game's final bosses.
	Begin Object Class=DayBase Name=PLShowdown
		Description="The Showdown"
		UniqueName="DAY_F"
		StartDayURL="PL-Hell_ent"
		LoadTex="p2misc_full.loading5"
        MapTex="PLHud.Map.map_day4"
		Errands(0)=ErrandBase'ErrandBaseDummy'
		
		// Items given at the start of the day
		PlayerInvList(0)=(InvClassName="PLInventory.DualWieldInv",NeededAmount=5,bEnhancedOnly=true)
		PlayerInvList(1)=(InvClassName="Inventory.CatnipInv",NeededAmount=5,bEnhancedOnly=true)
		PlayerInvList(2)=(InvClassName="Inventory.FastFoodInv",NeededAmount=5,bEnhancedOnly=true)

		// Items taken at the end of the day
		TakeFromPlayerList(0)=(InvClassName="PLInventory.PLMapInv")		
	End Object
	
	// Apocalypse Day
	// Technically consists of two parts: the Showdown, and the Apocalypse itself.
	// As the player enters the Hell Hole for the Showdown, they have no need for the map so it is removed.
	// After the Showdown and when the player returns to town for the Apocalypse, the map is returned
	// and the "errands" are revealed.
	Begin Object Class=DayBase Name=PLApocalypse
		// FIXME maybe have different days/loading screens for the Apocalypse and Showdown even?
		Description="The Apocalypse"
		UniqueName="DAY_G"
		StartDayURL="pl-suburbs-3#ApocPad?peer"
        LoadTex="p2misc_full.loading5"
        MapTex="PLHud.Map.map_day4"
		// Apocalypse Conqueror ending only
		// FIXME This path should be hidden if the player is on a nonviolent run
		Errands(0)=ErrandBase'ErrandBaseConquerParadise'
		Errands(1)=ErrandBase'ErrandBaseKillVince'
		Errands(2)=ErrandBase'ErrandBaseKillMikeJ'
		Errands(3)=ErrandBase'ErrandBaseKillZack'
		Errands(4)=ErrandBase'ErrandBaseKillGary'
		Errands(5)=ErrandBase'ErrandBaseKillOsama'
		Errands(6)=ErrandBase'ErrandBaseEscapeTown'
		NewsTex="PLHud.Newspapers.Paper_6_Apoc"
		DudeNewsComment="PL-Dialog3.DudeNewspaper.Newspaper06-Apoc"
		
		// Items given at the start of the day
		PlayerInvList(0)=(InvClassName="PLInventory.DualWieldInv",NeededAmount=5,bEnhancedOnly=true)
		PlayerInvList(1)=(InvClassName="Inventory.CatnipInv",NeededAmount=5,bEnhancedOnly=true)
		PlayerInvList(2)=(InvClassName="Inventory.FastFoodInv",NeededAmount=5,bEnhancedOnly=true)
		PlayerInvList(3)=(InvClassName="PLInventory.PLMapInv")
		
		// Items taken at the end of the day
	End Object
	
	// Apocalypse Day - Easy Mode
	// During easy mode, the player cannot become the Apocalypse Conqueror.
	Begin Object Class=DayBase Name=PLApocalypseNoConqueror
		// FIXME maybe have different days/loading screens for the Apocalypse and Showdown even?
		Description="The Apocalypse"
		UniqueName="DAY_G"
		StartDayURL="pl-suburbs-3"
        LoadTex="p2misc_full.loading5"
        MapTex="PLHud.Map.map_day4"
		Errands(0)=ErrandBase'ErrandBaseMustEscapeTown'
		
		// Items given at the start of the day
		PlayerInvList(0)=(InvClassName="PLInventory.DualWieldInv",NeededAmount=5,bEnhancedOnly=true)
		PlayerInvList(1)=(InvClassName="Inventory.CatnipInv",NeededAmount=5,bEnhancedOnly=true)
		PlayerInvList(2)=(InvClassName="Inventory.FastFoodInv",NeededAmount=5,bEnhancedOnly=true)
		PlayerInvList(3)=(InvClassName="PLInventory.PLMapInv")
		
		// Items taken at the end of the day
	End Object
		
	
	///////////////////////////////////////////////////////////////////////////////
	// GAME PROPERTIES
	///////////////////////////////////////////////////////////////////////////////
	// Game Definition
	Days(0)=DayBase'PLMonday'
	Days(1)=DayBase'PLTuesday'
	Days(2)=DayBase'PLWednesday'
	Days(3)=DayBase'PLThursday'
	Days(4)=DayBase'PLFriday'
	Days(5)=DayBase'PLShowdown'
	Days(6)=DayBase'PLApocalypse'

	MutatorClass="PLGame.PLGameMod"
	DefaultPlayerName="TheDude"
	PlayerControllerClassName="PLGame.PLDudePlayer"
	IntroURL			= "PL-intro"
	// FIXME: we'll probably need separate StartDayURLs for each day in the week due to how the game is laid out.
	StartFirstDayURL	= "PL-highlands.fuk#PlayerStart"
	StartNextDayURL		= "PL-highlands"
	FinishedDayURL		= "PL-StartNextDay"
	JailURL				= "PL-Saloon.fuk#cell"
	GameStateClass=Class'PLGameState'
	ApocalypseTex="PLHud.Newspapers.Paper_6_Apoc"
	ApocalypseComment="PL-Dialog3.DudeNewspaper.Newspaper06-Apoc"
	ChameleonClass=class'ChameleonPlus'
	DefaultPlayerClassName="PLGame.PLPostalDude"
	HUDType="PLGame.PLHud"
	GameName="POSTAL 2: Paradise Lost"
	GameNameshort="Paradise Lost"
	GameDescription="An unfortunate sequence of events finds the Postal Dude in a mysterious town after awakening from an eleven-year radiation-induced coma."
	MenuTitleTex="PL_Product.PL_title"
	MainMenuName="PLShell.PLMenuMain"
	StartMenuName="PLShell.PLMenuMain"
	GameMenuName="PLShell.PLMenuGame"
	StatsScreenClassName="PLGame.PLStatsScreen"
	MapScreenClassName="PLGame.PLMapScreen"
	SuperChampClass=class'PLPawns.PLSuperChamp'
	
	// xPatch
	LoadoutDays[0]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=50),(Item=class'RevolverWeapon',Amount=50),(Item=class'GrenadeWeapon',Amount=5),(Item=class'PizzaInv',Amount=5),(Item=class'CrackInv'),(Item=class'MachineGunWeapon',Amount=100),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=50)))
	LoadoutDays[1]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=100),(Item=class'RevolverWeapon',Amount=100),(Item=class'GSelectWeapon',Amount=50),(Item=class'GrenadeWeapon',Amount=10),(Item=class'FGrenadeWeapon',Amount=10),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv'),(Item=class'LeverActionShotgunWeapon',Amount=30),(Item=class'ShotgunWeapon',Amount=30),(Item=class'FastFoodInv',Amount=5),(Item=class'MachineGunWeapon',Amount=100),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[2]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=150),(Item=class'RevolverWeapon',Amount=150),(Item=class'GSelectWeapon',Amount=100),(Item=class'GrenadeWeapon',Amount=15),(Item=class'FGrenadeWeapon',Amount=15),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=2),(Item=class'LeverActionShotgunWeapon',Amount=60),(Item=class'ShotgunWeapon',Amount=60),(Item=class'FastFoodInv',Amount=5),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=100),(Item=class'MachineGunWeapon',Amount=100),(Item=class'KevlarInv'),(Item=class'CatnipInv'),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=10)))
	LoadoutDays[3]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=200),(Item=class'RevolverWeapon',Amount=200),(Item=class'GSelectWeapon',Amount=150),(Item=class'GrenadeWeapon',Amount=20),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=90),(Item=class'ShotgunWeapon',Amount=90),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=150),(Item=class'MachineGunWeapon',Amount=150),(Item=class'KevlarInv'),(Item=class'CatnipInv'),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv'),(Item=class'MacheteWeapon'),(Item=class'GasCanWeapon',Amount=10)))
	LoadoutDays[4]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'RevolverWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=120),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv',Amount=2),(Item=class'MacheteWeapon'),(Item=class'WeedWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[5]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'RevolverWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=120),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv',Amount=2),(Item=class'MacheteWeapon'),(Item=class'WeedWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[6]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'RevolverWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=120),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv',Amount=2),(Item=class'MacheteWeapon'),(Item=class'WeedWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
}
