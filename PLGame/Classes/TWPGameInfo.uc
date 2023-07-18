///////////////////////////////////////////////////////////////////////////////
// Basically a PLGameInfo copy that extends AWPGameInfo
// This way we can get a Two Ass-long Weeks Game Mode
// Needs some extra code to get it to work together.
//
// Made by Piotr "Man Chrzan" Sztukowski
// For xPatch 3.0 and official P2 update (probably).
///////////////////////////////////////////////////////////////////////////////
class TWPGameInfo extends AWPGameInfo;

//=============================================================================
//=============================================================================
// Vars, consts, structs, enums, etc. 
//=============================================================================
//=============================================================================

///////////////////////////////////////////////////////////////////////////////
// Paradise Lost
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
const KENNEL_HACK_DAY = 0;			// NOTE: REPLACED BY DAY_PLMONDAY IN CODE
const KENNEL_HACK_ERRAND = 1;
const WANG_HACK_DAY = 0;			// NOTE: REPLACED BY DAY_PLMONDAY IN CODE
const WANG_HACK_ERRAND = 3;

const APOCALYPSE_DAY = 13; 		//6;
const PREAPOCALYPSE_DAY = 11; 	//4;
const DUDE_UNBANDAGED_DAY = 11; //4;

// C4 errand hotfix
const C4_VAR = 'C4Done';
const C4_ERRAND = "GetC4";
const C4_DAY = 4;
const C4_MAP_TITLE = "Survivalist Encampment";
const C4_ESCAPE_URL = "PL-underhub#pod2forest";

///////////////////////////////////////////////////////////////////////////////
// Two Weeks In Paradise
///////////////////////////////////////////////////////////////////////////////
const DAY_PLMONDAY = 7; 							// First day of the 2nd week
var() name		PLApocalypseTex;					// Newspaper texture for the Apocalypse (independent of day)
var() name		PLApocalypseComment;				// Dude comment for the Apocalypse (independent of day)
var() name 		PLJailURL;

const TWPGamePath = "PLGame.TWPGameInfo";
var globalconfig bool bIsSecondWeek;
var bool bSequencesHackDone;

//=============================================================================
//=============================================================================
// Paradise Lost's GameInfo Functions Copy
//=============================================================================
//=============================================================================

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
	
	if(!IsSecondWeek())
		return;

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
// xPatch: Make cats crazy after friday (Edit: Excludes PL) or if it's Ludicrous difficulty
///////////////////////////////////////////////////////////////////////////////
function bool CrazyCats()
{
	return (IsWeekend() || InLudicrousMode());
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the Dude should no longer be wearing his AW head wound wrap.
///////////////////////////////////////////////////////////////////////////////
function bool DudeShouldBeBandaged()
{
	//log(self@"should dude be bandaged?"@TheGameState.CurrentDay@"vs"@DUDE_UNBANDAGED_DAY);
	if (TheGameState != None 
		&& TheGameState.CurrentDay >= DAY_SATURDAY
		&& TheGameState.CurrentDay < DUDE_UNBANDAGED_DAY)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check to swap out the postal dude's bandaged head skin.
///////////////////////////////////////////////////////////////////////////////
function CheckDudeHeadSkin()
{
	local TWPPostalDude TheDude;

	//log(self@"CheckDudeHeadSkin");
	foreach DynamicActors(class'TWPPostalDude', TheDude)
	{
		TheDude.DudeCheckHeadSkin();
		TheDude.SwapDudeTag(IsSecondWeek());
	}
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

	// TWP Changes:
	if(TheGameState != None && TheGameState.CurrentDay >= DAY_PLMONDAY)
		Default.bIsSecondWeek = True;
	else
		Default.bIsSecondWeek = False;
		
	HackScriptedSequences();
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
		Days[DAY_PLMONDAY] = DayBase'PLMondayHate';		// TWP Change: DAY_PLMONDAY
	
	// If the player is on an easy difficulty, don't let them become Apocalypse Conqueror
	if (GetDifficultyOffset() < 0)
		Days[APOCALYPSE_DAY] = DayBase'PLApocalypseNoConqueror';	

	Super.PostTravel(PlayerPawn);

	// Check for the dude's bandaged head
	CheckDudeHeadSkin();
	
// TWP CHANGES:
	// After super it should be here - even on new game / level, right?
	if (TheGameState != None)
	{
		// Check if we are starting a second week
		if (TheGameState.CurrentDay == DAY_PLMONDAY 
			&& TheGameState.bFirstLevelOfDay)
		{
			// we nuked all our previous haters haha
			TheGameState.CurrentHaters.length = 0;
		}
	}
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
	
	// TWP Change: DAY_PLMONDAY
	
	// DON'T DO THIS IN HATE ME MODE - it reorders the errands and the Wise Wang errand is disabled anyway.
	if (InNightmareMode() || TheyHateMeMode())
		return;
	
	// If the GameState is marked off that we did the Wise Wang errand before
	// the Kennel errand (or vice versa), swap the errand goals here.
	if (PLGameState(TheGameState).bKennelHack)
		// Rig up the changed errand goal
		Days[DAY_PLMONDAY].Errands[KENNEL_HACK_ERRAND].Goals[0] = KennelGoalAfterWiseWang;
	else
		// Set goal back to default - changed goal could still be in place from a previous save etc.
		Days[DAY_PLMONDAY].Errands[KENNEL_HACK_ERRAND].Goals[0] = KennelGoalDefault;
	log("GameState kennel hack"@PLGameState(TheGameState).bKennelHack$", errand goal is now"@Days[DAY_PLMONDAY].Errands[KENNEL_HACK_ERRAND].Goals[0]);
	
	if (PLGameState(TheGameState).bWiseWangHack)
		// Rig up the changed errand goal
		Days[DAY_PLMONDAY].Errands[WANG_HACK_ERRAND].Goals[0] = WiseWangGoalAfterKennel;
	else
		// Set goal back to default - changed goal could still be in place from a previous save etc.
		Days[DAY_PLMONDAY].Errands[WANG_HACK_ERRAND].Goals[0] = WiseWangGoalDefault;
	log("GameState WiseWang hack"@PLGameState(TheGameState).bWiseWangHack$", errand goal is now"@Days[DAY_PLMONDAY].Errands[WANG_HACK_ERRAND].Goals[0]);
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
		
	// TWP Change: DAY_PLMONDAY	
		
	// HACK: swap out errand goals based on which errand we completed first.
	// If we completed the Kennel errand, change out the Wise Wang goal so the Dude
	// DOESN'T make a smarmy remark.
	if (TheGameState.CurrentDay == DAY_PLMONDAY
		&& Errand == KENNEL_HACK_ERRAND)
	{
		PLGameState(TheGameState).bWiseWangHack = true;	// Mark it in the game state
		Days[DAY_PLMONDAY].Errands[WANG_HACK_ERRAND].Goals[0] = WiseWangGoalAfterKennel;	// Swap out the goal
	}
	// If we completed the Wise Wang errand, change out the Kennel goal so the Dude
	// DOES make a smarmy remark.
	if (TheGameState.CurrentDay == DAY_PLMONDAY
		&& Errand == WANG_HACK_ERRAND)
	{
		PLGameState(TheGameState).bKennelHack = true;	// Mark it in the game state
		Days[DAY_PLMONDAY].Errands[KENNEL_HACK_ERRAND].Goals[0] = KennelGoalAfterWiseWang;
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
		// Grant achievement if we beat Two Weeks In Paradise
		if (FinallyOver()
			&& GinallyOver())
		{
			if(Level.NetMode != NM_DedicatedServer )
			{
				Player.GetEntryLevel().EvaluateAchievement(Player,'GameComplete');
				Player.GetEntryLevel().EvaluateAchievement(Player,'PLFridayComplete');
			}
		}

		// Grant achievements for beating the game in certain ways

		// Speedrun ending
		// TWP Change: Take away first week time to grant the Achievement accordingly.
		//if (TheGameState.TimeElapsed <= PLGameState(TheGameState).SPEEDRUN_ACHIEVEMENT
		if (TheGameState.TimeElapsed - TWPGameState(TheGameState).FirstWeekTime <= TWPGameState(TheGameState).PL_SPEEDRUN_ACHIEVEMENT
			&& !VerifySeqTime())				// Can't be in Enhanced
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'PLSpeedRun',true);
		}	

		// Jesus ending
		if (TheGameState.PeopleKilled + TWPGameState(TheGameState).AnimalKills == 0)
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
	
		// TWP Change:
		if(TheGameState.CurrentDay >= DAY_PLMONDAY)
		{
			bIsSecondWeek = True; 				
			ConsoleCommand("set "@TWPGamePath@True); 
		}
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
	local AWCatPawn awpcat;
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
				if (FRand() < 0.1 && IsSecondWeek()) // TWP Change
					catr = spawn(class'CowRocket',,,StartLoc,Rotator(dir));
				else
					catr = spawn(class'CatRocket',,,StartLoc,Rotator(dir));
					//awpcat = spawn(ApocalypseCatClass,,, StartLoc, Rotator(Dir));
				if(catr != None || awpcat != None)
				{
					//if(awpcat != None)
					//AddController(awpcat);
					
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
	if (DudePawn == None || !IsSecondWeek())	// TWP Change
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

		if(IsSecondWeek())	// TWP Change: Paradise Lost forces the map, huh...
		{
			if(p2p != None && TheGameState.bFirstLevelOfDay && !bTesting && p2p.GetCurrentSceneManager() == None)
				p2p.ForceMapUp();
		}

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

//=============================================================================
//=============================================================================
// Two Weeks In Paradise's Functions
//=============================================================================
//=============================================================================

///////////////////////////////////////////////////////////////////////////////
// This function is called before any other scripts (including PreBeginPlay().
///////////////////////////////////////////////////////////////////////////////
event InitGame(out string Options, out string Error)
{
	Super.InitGame(Options, Error);
	bIsSecondWeek = class'TWPGameInfo'.Default.bIsSecondWeek;
	HackScriptedSequences();
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Okay so Paradise Lost levels use Day NUMBER checks for cutscenes, scripted sequences etc. 
// Obviously this game mode has different day numbers and now that stuff doesn't work.
//
// Here's a little trick to solve this issue quick and easy without editing 
// the levels and all these sequences to use day groups instead.
////////////////////////////////////////////////////////////////////////////////////////////////
function HackScriptedSequences()
{
	local int i, WeekDays, NewDayNumber, OldDayNumber; 
	local ScriptedSequence aScriptedSequence;
	local ScriptedTrigger aScriptedTrigger;
	
	log(self@"HackScriptedSequences("$IsSecondWeek()$"), bSequencesHackDone="$bSequencesHackDone);
	
	// Only for second week and once.
	if(!IsSecondWeek() || bSequencesHackDone)
		return;

	WeekDays = 7;

	log(self@"Hacking Scripted Triggers...");
	foreach AllActors(class'ScriptedTrigger', aScriptedTrigger)
	{
		if(aScriptedTrigger != None)
		{
			for (i = 0 ; i < aScriptedTrigger.Actions.Length ; i++)
			{
				if (ACTION_IfGameState(aScriptedTrigger.Actions[i]) != None
					&& ACTION_IfGameState(aScriptedTrigger.Actions[i]).test == 3)	// ET_CurrentDay_Number is 3rd enum
				{
					OldDayNumber = ACTION_IfGameState(aScriptedTrigger.Actions[i]).Number;
					if(OldDayNumber <= 7) // Extra safety check. We shouldn't have anything above 7 normally.
					{
						NewDayNumber = OldDayNumber + WeekDays;
						ACTION_IfGameState(aScriptedTrigger.Actions[i]).Number = NewDayNumber;
						log(aScriptedTrigger@"Hacked day number check from"@OldDayNumber@"to"@NewDayNumber);
					}
					else
						log(aScriptedTrigger@"day number is"@OldDayNumber@"!?");
				}
			}
		}
	}
	
	log(self@"Hacking Scripted Sequences...");
	foreach AllActors(class'ScriptedSequence', aScriptedSequence)
	{
		if(aScriptedSequence != None 
			&& ScriptedTrigger(aScriptedSequence) == None)	// NOT A TRIGGER
		{
			for (i = 0 ; i < aScriptedSequence.Actions.Length ; i++)
			{
				if (ACTION_IfGameState(aScriptedSequence.Actions[i]) != None
					&& ACTION_IfGameState(aScriptedSequence.Actions[i]).test == 3)	// ET_CurrentDay_Number is 3rd enum
				{
					OldDayNumber = ACTION_IfGameState(aScriptedSequence.Actions[i]).Number;
					if(OldDayNumber <= 7) // Extra safety check. We shouldn't have anything above 7 normally.
					{
						NewDayNumber = OldDayNumber + WeekDays;
						ACTION_IfGameState(aScriptedSequence.Actions[i]).Number = NewDayNumber;
						log(aScriptedSequence@"Hacked day number check from"@OldDayNumber@"to"@NewDayNumber);
					}
					else
						log(aScriptedSequence@"day number is"@OldDayNumber@"!?");
				}
			}
		}
	}
	
	bSequencesHackDone=True;
}

function bool TwoWeeksGame()
{
	return True;
}

function bool IsWeekend()
{
	return (TheGameState.CurrentDay == DAY_SATURDAY
			|| TheGameState.CurrentDay == DAY_SUNDAY);
}

function bool IsSecondWeek()
{
	if (TheGameState != None)
	{
		return (TheGameState.CurrentDay >= DAY_PLMONDAY);
	}
	else
	{
		return bIsSecondWeek;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the appropriate texture for the newspaper to fly to the screen for the
// appropriate day. Except for the apocalypse paper which takes a special
// one regardless of the day.
///////////////////////////////////////////////////////////////////////////////
function Texture GetNewsTexture()
{
	if(TheGameState.bIsApocalypse)
	{
		if(IsSecondWeek())
			return Texture(DynamicLoadObject(String(PLApocalypseTex), class'Texture'));
		else
			return Texture(DynamicLoadObject(String(ApocalypseTex), class'Texture'));
	}
	else
	{
		// Kamek 5-1
		// Tell the GameState that we read the news today
		// Apocalypse news is always shown, so don't count it toward the total.
		TheGameState.ReadNewsToday();

		return GetCurrentDayBase().GetNewsTexture();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the dude comment on this day's newspaper or the Apocalypse. Like above
// the texture.
///////////////////////////////////////////////////////////////////////////////
function Sound GetDudeNewsComment()
{
	if(TheGameState.bIsApocalypse)
	{
		if(IsSecondWeek())
			return Sound(DynamicLoadObject(String(PLApocalypseComment), class'Sound'));
		else
			return Sound(DynamicLoadObject(String(ApocalypseComment), class'Sound'));
	}
	else
		return GetCurrentDayBase().GetDudeNewsComment();
}

///////////////////////////////////////////////////////////////////////////////
// Change the sky based on the day, using a material trigger
///////////////////////////////////////////////////////////////////////////////
function ChangeSkyByDay()
{
	local MaterialTrigger mattrig;
	local int Day;
	
	// Fix for the skybox after 5th day.
	if(IsSecondWeek())
		Day = TheGameState.CurrentDay - 7;
	else if (IsWeekend())
		Day = TheGameState.CurrentDay - 5;
	else
		Day = TheGameState.CurrentDay;
		
	// Find the skybox trigger, and trigger it to the correct day
	foreach AllActors(class'MaterialTrigger', mattrig, SKY_BOX_TRIGGER)
		break;

	if(mattrig != None)
	{
		// If your in the normal week, just set the skybox by the day number
		if(!TheGameState.bIsApocalypse)
			mattrig.SetCurrentMaterialSwitch(Day);
		else// Apocalypse is expected to be one past the last day.
			mattrig.SetCurrentMaterialSwitch(Day+1);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called when the first week is completed.
///////////////////////////////////////////////////////////////////////////////
function EndOfFirstWeek(P2Player player)
{
	// xPatch: Must be played from the first day to get these achievement		
	if(TheGameState.StartDay == 0)	
	{
		// Grant achievement if we beat both AW and P2
		if (TheGameState.CurrentDay >= 6)
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'GameComplete');
		}

		// Grant achievements for beating the game in certain ways

		// Shovel ending
		if (!TheGameState.bShovelEndingDQ		// Used only the shovel to kill
			&& TheGameState.PeopleKilled >= 30)	// Must have killed at least 30 people
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'ShovelEnding',true);
		}
		// Speedrun ending
		TWPGameState(TheGameState).FirstWeekTime = TheGameState.TimeElapsed;
		if (TWPGameState(TheGameState).FirstWeekTime <= TWPGameState(TheGameState).P2_SPEEDRUN_ACHIEVEMENT
			&& !VerifySeqTime())					// Can't be in Enhanced
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'SpeedrunEnding',true);
		}
		// Hestonworld ending
		if (InHestonMode())
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'HestonworldEnding',true);
		}
		// Jesus/Anustart ending
		if (TheGameState.PeopleKilled + TheGameState.CatsKilled + TheGameState.ElephantsKilled + TheGameState.DogsKilled == 0)
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'JesusEnding',true);
		}
		// Scientology Level OT VIII ending
		if (InNightmareMode())		// Beat the game in nightmare mode
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'NightmareEnding',true);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Send player to jail.  Each time the player goes to jail, he's put in a
// different cell.  The jail map must contain a series of Telepads named
// "cell1" through "celln" where 'n' is LAST_JAIL_CELL_NUMBER.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerToJail(PlayerController player)
{
	local P2Pawn ppawn;

	// If there is no jail map defined, use the old "demo" jail method (Workshop support)
	if (JailURL == ""
		&& Days[TheGameState.CurrentDay].JailURL == "")
	{
		P2RootWindow(Player.Player.InteractionMaster.BaseMenu).ArrestedDemo();
		return;
	}

	// Keep using a higher jail cell number until we reach the last one
	if (TheGameState.JailCellNumber < TheGameState.LastJailCellNumber)
		TheGameState.JailCellNumber++;

	// This doesn't travel, but just say that the player is going to jail
	// for the SendPlayer function
	TheGameState.bSendingPlayerToJail=true;

	// Record that we were sent to jail
	TheGameState.TimesArrested++;

	// Mark his inventory to be taken on entry to the jail level
	TheGameState.bTakePlayerInventory=true;

	// Give him up to full health (not if he's already over 100%)
	ppawn = P2Pawn(Player.Pawn);
	if(ppawn != None
		&& ppawn.Health < ppawn.HealthMax)
		ppawn.Health = ppawn.HealthMax;

	// Reset the cop radio--you're not wanted anymore
	TheGameState.ResetCopRadioTime();

	//log(self$" cop radio time "$TheGameState.CopRadioTime);
	// Send player to the appropriate jail cell
	if (Days[TheGameState.CurrentDay].JailURL != "")
		SendPlayerTo(player, Days[TheGameState.CurrentDay].JailURL $ TheGameState.JailCellNumber $ "?peer");
	else
	{
		if(IsSecondWeek())
			SendPlayerTo(player, PLJailURL $ TheGameState.JailCellNumber $ "?peer");
		else
			SendPlayerTo(player, JailURL $ TheGameState.JailCellNumber $ "?peer");
	}
}


///////////////////////////////////////////////////////////////////////////////
// Get the localized day name
///////////////////////////////////////////////////////////////////////////////
function string GetDayName()
{
	local string DayDescription;
	local int i, strcheck;
	
	DayDescription = GetCurrentDayBase().Description;
	
	// For second week it doesn't need to match day description
	if(IsSecondWeek())
	{
		return DayNames[TheGameState.CurrentDay];
	}
	else
	{
		// Check if DayDescription matches our localized DayNames
		for (i=0; i<DayNames.Length; i++)
		{
			strcheck = InStr(DayDescription, default.DayNames[i]);
			if(strcheck >= 0 )
				return DayNames[i];
		}
	}
	
	// if it doesn't just return the description back
	return DayDescription;
}

// DEBUG: Check how things are in the game info and state.
exec function GetTWPInfo()
{
	GetPlayer().ClientMessage("GameInfo.bIsSecondWeek:"@bIsSecondWeek);
	
	if(TheGameState.CurrentDay >= DAY_PLMONDAY)
		GetPlayer().ClientMessage("GameState.CurrentDay"@">= DAY_PLMONDAY");
	else
		GetPlayer().ClientMessage("GameState.CurrentDay"@"< DAY_PLMONDAY");
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// NOTE: Errands which use ErrandGoalTag don't work unless copied here, huh.
	
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
	// DAYS
	///////////////////////////////////////////////////////////////////////////////
	Days(0)=DayBase'GameTypes.DayBase0'
	Days(1)=DayBase'GameTypes.DayBase1'
	Days(2)=DayBase'GameTypes.DayBase2'
	Days(3)=DayBase'GameTypes.DayBase3'
	Days(4)=DayBase'GameTypes.DayBase4'
	Days(5)=DayBase'GameTypes.DayBase8'
    Days(6)=DayBase'GameTypes.DayBase9'
	Days(7)=DayBase'PLGame.PLMonday'
	Days(8)=DayBase'PLGame.PLTuesday'
	Days(9)=DayBase'PLGame.PLWednesday'
	Days(10)=DayBase'PLGame.PLThursday'
	Days(11)=DayBase'PLGame.PLFriday'
	Days(12)=DayBase'PLGame.PLShowdown'
	Days(13)=DayBase'PLGame.PLApocalypse'

	MutatorClass="PLGame.PLGameMod"
	DefaultPlayerName="TheDude"
	GameStateClass=Class'PLGameState'
	ChameleonClass=class'ChameleonPlus'
	StatsScreenClassName="PLGame.PLStatsScreen"
	MapScreenClassName="PLGame.PLMapScreen"
	SuperChampClass=class'PLPawns.PLSuperChamp'
	
	///////////////////////////////////////////////////////////////////////////////
	// NEW PROPERTIES
	///////////////////////////////////////////////////////////////////////////////
	GameName="POSTAL 2: Two Weeks in Paradise"
	GameNameshort="Two Weeks in Paradise"
	GameDescription="POSTAL 2, Apocalypse Weekend and Paradise Lost combined together into one massive 14-days long campaign!"

	PlayerControllerClassName="PLGame.TWPDudePlayer"
	DefaultPlayerClassName="PLGame.TWPPostalDude"
	HUDType="PLGame.TWPHud"

	MenuTitleTex="PL_Product.PL_title"
	MainMenuName="PLShell.PLMenuMain"
	StartMenuName="PLShell.PLMenuMain"
	GameMenuName="PLShell.PLMenuGame"
	
	PLApocalypseTex="PLHud.Newspapers.Paper_6_Apoc"
	PLApocalypseComment="PL-Dialog3.DudeNewspaper.Newspaper06-Apoc"
	
	PLJailURL = "PL-Saloon.fuk#cell"
	
	DayNames[7]="2nd Monday"
	DayNames[8]="2nd Tuesday"
	DayNames[9]="2nd Wednesday"
	DayNames[10]="2nd Thursday"
	DayNames[11]="2nd Friday"
	DayNames[12]="The Showdown"
	DayNames[13]="The Apocalypse"
	
	// Loadout
	LoadoutDays[7]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=50),(Item=class'RevolverWeapon',Amount=50),(Item=class'GrenadeWeapon',Amount=5),(Item=class'PizzaInv',Amount=5),(Item=class'CrackInv'),(Item=class'MachineGunWeapon',Amount=100),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=50)))
	LoadoutDays[8]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=100),(Item=class'RevolverWeapon',Amount=100),(Item=class'GSelectWeapon',Amount=50),(Item=class'GrenadeWeapon',Amount=10),(Item=class'FGrenadeWeapon',Amount=10),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv'),(Item=class'LeverActionShotgunWeapon',Amount=30),(Item=class'ShotgunWeapon',Amount=30),(Item=class'FastFoodInv',Amount=5),(Item=class'MachineGunWeapon',Amount=100),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[9]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=150),(Item=class'RevolverWeapon',Amount=150),(Item=class'GSelectWeapon',Amount=100),(Item=class'GrenadeWeapon',Amount=15),(Item=class'FGrenadeWeapon',Amount=15),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=2),(Item=class'LeverActionShotgunWeapon',Amount=60),(Item=class'ShotgunWeapon',Amount=60),(Item=class'FastFoodInv',Amount=5),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=100),(Item=class'MachineGunWeapon',Amount=100),(Item=class'KevlarInv'),(Item=class'CatnipInv'),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=10)))
	LoadoutDays[10]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=200),(Item=class'RevolverWeapon',Amount=200),(Item=class'GSelectWeapon',Amount=150),(Item=class'GrenadeWeapon',Amount=20),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=90),(Item=class'ShotgunWeapon',Amount=90),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=150),(Item=class'MachineGunWeapon',Amount=150),(Item=class'KevlarInv'),(Item=class'CatnipInv'),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv'),(Item=class'MacheteWeapon'),(Item=class'GasCanWeapon',Amount=10)))
	LoadoutDays[11]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'RevolverWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=120),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv',Amount=2),(Item=class'MacheteWeapon'),(Item=class'WeedWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[12]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'RevolverWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=120),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv',Amount=2),(Item=class'MacheteWeapon'),(Item=class'WeedWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[13]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'RevolverWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=120),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv',Amount=2),(Item=class'MacheteWeapon'),(Item=class'WeedWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
}
