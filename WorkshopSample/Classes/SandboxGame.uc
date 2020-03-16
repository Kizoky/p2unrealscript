///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Game Info
//
// This is a sample Workshop GameInfo based off of GameSinglePlayer.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This is an Sandbox Game which turns off the errand system, allowing the
// player to roam about freely with no obligations.
//
// There are many, many functions in P2GameInfoSingle and its parent classes
// that are not covered here, which you can use to gain even more control
// over how the game works. For details, see their respective classes
// in the source code:
//		Postal2Game.P2GameInfoSingle
//		Postal2Game.P2GameInfo
//		FPSGame.FPSGameInfo
//		Engine.GameInfo
///////////////////////////////////////////////////////////////////////////////
class SandboxGame extends SampleWorkshopGameInfo;

///////////////////////////////////////////////////////////////////////////////
// Vars (internal)
///////////////////////////////////////////////////////////////////////////////
var bool bStartingApocalypse;			// Internal flag to start the apocalypse only if the player wants
										// to do so via cheat. Otherwise, ignores StartApocalypse.
										// We need this flag or else the apocalypse will start on its own
										// when the Dude runs over any TriggerApocalypse.
var float NewCatTime;	// When we'll make a new cat
var float CatRainTime;	// When we'll start raining again
var bool  bRainingCats;

///////////////////////////////////////////////////////////////////////////////
// Consts
///////////////////////////////////////////////////////////////////////////////
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

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
// We don't use newspaper pickups, so remove them.
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	local NewspaperPickup News;
	
	foreach DynamicActors(class'NewspaperPickup', News)
		News.Destroy();

	Super.PostBeginPlay();
}

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
	local RWSController R;
	
	// Call Super first
	Super.PostTravel(PlayerPawn);
	
	// One important thing we need to do: RWS guys are programmed to find the Dude and tell him to go see Vince
	// if he hasn't gotten his paycheck/gotten fired yet. That errand doesn't exist in the sandbox but
	// the game will still see it as being an unfinished errand, so we simply look for all the RWS guys
	// and make them think they've told the Dude to go see Vince already, so they won't keep bothering him.
	foreach DynamicActors(class'RWSController', R)
		R.bToldPlayer = true;
}

///////////////////////////////////////////////////////////////////////////////
// In the main game, the player gets diverted home after finishing the day's
// errands. We don't want that to happen in our sandbox game, because there
// are no errands to finish.
///////////////////////////////////////////////////////////////////////////////
function bool WillPlayerBeDivertedHome(String URL, bool bRealLevelExit)
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Same as above, except this stops the game from ending as the dude steps
// away from his trailer.
///////////////////////////////////////////////////////////////////////////////
function AtPlayerHouse(P2Player p2p, optional bool bForce)
{
	// STUB - do not attempt to do anything here. Let the dude go about his business.
}

///////////////////////////////////////////////////////////////////////////////
// Begin end sequence for single player game.
// * Set Gamestate to know Apocalypse is soooooo on!
// * Grant dude new Apocalypse newspaper and make him view it (to understand
// what's happening.
// * Go through level and make everyone guncrazy, give them a weapon and start
// the fun!
///////////////////////////////////////////////////////////////////////////////
function StartApocalypse()
{
	// In the game, there are TriggerApocalypse triggers laid out throughout the maps
	// near locations where the dude completes Friday errands. The game checks to see
	// if all the errands for the day are complete, and if so, it runs the Apocalypse
	// that the dude has to escape. Since we have no errands and we've put the game
	// into a permanent state that is more or less Friday, all of these are going to
	// trigger the Apocalypse if the dude touches them...
	// But we also want to add a cheat where the dude can turn on the apocalypse
	// with a console command. So we check for this boolean flag that we set ONLY
	// in ApocalypseNow. If it's not set, then don't start the apocalypse.
	if (bStartingApocalypse)
		Super.StartApocalypse();
}

///////////////////////////////////////////////////////////////////////////////
// ApocalypseNow
// This is an "exec" function that the player can call via console.
// They're more commonly known as cheat codes :)
// Most cheat codes are contained in the CheatManager, but since we're
// not making a new player controller or cheat manager, it's safe
// to put it here.
///////////////////////////////////////////////////////////////////////////////
exec function ApocalypseNow()
{
	bStartingApocalypse = true;	// Tell the game we're okay to go into apocalypse mode
	StartApocalypse();			// Actually puts the game into apocalypse mode
}

///////////////////////////////////////////////////////////////////////////////
// Apocalypse stuff
// Our game doesn't extend from GameSinglePlayer (it extends from P2GameInfoSingle
// instead) so we need to copy over the cat rain stuff from GameSinglePlayer.
// Otherwise it won't rain cats during our apocalypse cheat.
///////////////////////////////////////////////////////////////////////////////

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

	if(bRainingCats)
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
	}
}

defaultproperties
{
	// Blank Day
	// This is a DayBase object with no errands defined and a minimal starting inventory.
	Begin Object Class=DayBase Name=SandboxDay
		Description="Sandbox"
		LoadTex="p2misc_full.Load.loading-screen"
		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=100)
		PlayerInvList(1)=(InvClassName="Inventory.StatInv")
		// Because of how the day-by-day group code works for spawning daily actors,
		// we need to set the UniqueName of this day to DAY_E, and then specifically
		// destroy actors belonging to DAY_A, DAY_B, DAY_C, DAY_D, or DEMO.
		// This will essentially make the game think it's Friday... mostly
		UniqueName="DAY_E"
		ExcludeDays[0]="DAY_A"
		ExcludeDays[1]="DAY_B"
		ExcludeDays[2]="DAY_C"
		ExcludeDays[3]="DAY_D"
		ExcludeDays[4]="DEMO"
	End Object
	
	// Game Definition
	// This is where you put together the days you've assembled to form a full week.
	Days(0)=DayBase'SandboxDay'
	
	// This is the class for the PlayerController.
	// It shouldn't be messed with unless you're making your own PlayerController.
	PlayerControllerClassName="GameTypes.DudePlayer"
	
	// This is the very first map that gets loaded when you start the game.
	// For POSTAL 2, Apocalypse Weekend, and AWP, these all point to intro movies with cinematic sequences.
	// When done, the cinematic sends the player to the actual first level of the game.
	// LEAVE THIS BLANK IF YOUR GAME HAS NO INTRO. Fill in the "StartFirstDayURL" with your first map.
	IntroURL			= ""
	
	// This is the map the dude gets sent to when starting the first day, AFTER the intro map.
	// If you used a cinematic intro then you can send the dude here with the ACTION_SendPlayer scripted action.
	// If no IntroURL is defined, the game will just dump you here.
	StartFirstDayURL	= "suburbs-3"
	
	// This is the map the dude gets sent to when starting any other day of the week.
	// In POSTAL 2 and the first five days of AWP, this is Suburbs-3, which loads up an intro cinematic that
	// shows the dude the errands he has to complete for the day.
	// If you don't have multiple days in your game, or if your game doesn't use the days for progression,
	// then this can be left blank.
	StartNextDayURL		= "suburbs-3"
	
	// This is the map the dude will get redirected to once he's finished all his errands.
	// This is called by Telepad when the dude steps on it and all his errands are done.
	// If you don't want to use the errand system, consider overriding the SendPlayerLevelTransition() function
	// (see SandboxGameInfo for an example of this)
	FinishedDayURL		= "homeatnight"
	
	// This is where the dude will get sent if he gets arrested by a cop.
	// The cell number keeps increasing each time he gets arrested (see the Police.fuk map to see how this works)
	// If this is left blank, getting arrested will end the game, forcing the player to reload from the previous save
	// or quit to the main menu.
	JailURL				= ""
	
	// This defines an image to be displayed if the player gets arrested and there is no jail defined.
	// If your game uses a jail you can leave this alone.
	ArrestedScreenTex	= "P2Misc.Backgrounds.menu_busted"

	// This is the game state class.
	// You don't want to mess with this unless you need to track specific information not already included, in which
	// case you'll want to subclass AWGameState.
	GameStateClass=Class'AWGameState'
	
	// This is the class of the "Chameleon" actor that determines the appearance of pawns.
	// You don't want to mess with this unless you know exactly what you're doing.
	ChameleonClass=class'ChameleonPlus'
	
	// You can override the player's Pawn here.
	DefaultPlayerClassName="WorkshopSample.SandboxPostalDude"
	
	// You can override the player's HUD here.
	HUDType="GameTypes.AchievementHUD"
	
	// Game Name displayed in the Workshop Browser.
	GameName="Sandbox Game"
	// Game Name displayed in the Save/Load Game Menu.
	GameNameShort="Sandbox"
	// Game Description displayed in the Workshop Browser.
	GameDescription="Sandbox game with no errands or obligations. Just you and the setting of your choice."
}
