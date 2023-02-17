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
class SandboxGamePL extends EmptyGameInfo;

///////////////////////////////////////////////////////////////////////////////
// Vars (internal)
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Consts
///////////////////////////////////////////////////////////////////////////////

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
		ExcludeDays[5]="DAY_F"
		ExcludeDays[6]="DAY_G"
	End Object
	
	// Game Definition
	// This is where you put together the days you've assembled to form a full week.
	Days(0)=DayBase'SandboxDay'
	
	// This is the class for the PlayerController.
	// It shouldn't be messed with unless you're making your own PlayerController.
	PlayerControllerClassName="PLGame.PLDudePlayer"
	
	// This is the very first map that gets loaded when you start the game.
	// For POSTAL 2, Apocalypse Weekend, and AWP, these all point to intro movies with cinematic sequences.
	// When done, the cinematic sends the player to the actual first level of the game.
	// LEAVE THIS BLANK IF YOUR GAME HAS NO INTRO. Fill in the "StartFirstDayURL" with your first map.
	IntroURL			= ""
	
	// This is the map the dude gets sent to when starting the first day, AFTER the intro map.
	// If you used a cinematic intro then you can send the dude here with the ACTION_SendPlayer scripted action.
	// If no IntroURL is defined, the game will just dump you here.
	StartFirstDayURL	= "PL-Highlands"
	
	// This is the map the dude gets sent to when starting any other day of the week.
	// In POSTAL 2 and the first five days of AWP, this is Suburbs-3, which loads up an intro cinematic that
	// shows the dude the errands he has to complete for the day.
	// If you don't have multiple days in your game, or if your game doesn't use the days for progression,
	// then this can be left blank.
	StartNextDayURL		= "PL-Highlands"
	
	// This is the map the dude will get redirected to once he's finished all his errands.
	// This is called by Telepad when the dude steps on it and all his errands are done.
	// If you don't want to use the errand system, consider overriding the SendPlayerLevelTransition() function
	// (see SandboxGameInfo for an example of this)
	FinishedDayURL		= ""
	
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
	GameStateClass=Class'PLGameState'
	
	// This is the class of the "Chameleon" actor that determines the appearance of pawns.
	// You don't want to mess with this unless you know exactly what you're doing.
	ChameleonClass=class'ChameleonPlus'
	
	// You can override the player's Pawn here.
	DefaultPlayerClassName="Sandbox-PL.SandboxPostalDudePL"
	
	// You can override the player's HUD here.
	HUDType="PLGame.PLHUD"
	
	// Game Name displayed in the Workshop Browser.
	GameName="PL Sandbox Game"
	// Game Name displayed in the Save/Load Game Menu.
	GameNameShort="PL Sandbox"
	// Game Description displayed in the Workshop Browser.
	GameDescription="Sandbox game with no errands or obligations. Just you and the setting of your choice. (Paradise Lost version)"
	
	// PL-Highlands has an intro where the dude pulls out his map (even if he doesn't have one). We set the map screen to None so that the map screen is skipped.
	MapScreenClassName="None"
}
