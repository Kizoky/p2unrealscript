///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Game Info
//
// This is a sample Workshop GameInfo based off of GameSinglePlayer.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This mod does not actually do anything, it only explains the functions.
// For example of a mod that actually does something, see the other mods in
// this folder.
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
class SampleWorkshopGameInfo extends EmptyGameInfo;

defaultproperties
{
	// Blank Day
	// This is a DayBase object with no errands defined and a minimal starting inventory.
	Begin Object Class=DayBase Name=SampleDay
		Description="Blank Day"
		LoadTex="p2misc_full.Load.loading-screen"
		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=20)
		PlayerInvList(1)=(InvClassName="Inventory.StatInv")
	End Object
	
	// Game Definition
	// This is where you put together the days you've assembled to form a full week.
	Days(0)=DayBase'SampleDay'
	
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
	// If you don't want to use the errand system, consider overriding the WillPlayerBeDivertedHome() function
	// (see UltimateSandboxGame for an example of this)
	FinishedDayURL		= "homeatnight"
	
	// This is where the dude will get sent if he gets arrested by a cop.
	// The cell number keeps increasing each time he gets arrested (see the Police.fuk map to see how this works)
	// If this is left blank, getting arrested will end the game, forcing the player to reload from the previous save
	// or quit to the main menu.
	JailURL				= "police.fuk#cell"
	
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
	DefaultPlayerClassName="GameTypes.AWPostalDude"
	
	// You can override the player's HUD here.
	HUDType="GameTypes.AchievementHUD"
	
	// Advanced users: define an alternate startup map, main menu, and game menu.
	// Can be used for "total conversion"-style games.
	// Don't mess with these unless you have a good working knowledge of the game's startup and menu system	
	
	// bShowStarrtupOnNewGame: if true, opens up the game's defined MainMenuURL when starting a new game, instead of StartFirstDayURL.
	// This should be a cinematic startup-style map, like POSTAL 2's Startup.fuk
	bShowStartupOnNewGame=false	
	// MainMenuURL: URL of map to load when bShowStartupOnNewGame is true
	// This map is also loaded when quitting the game, so it should have a scripted action to show the main menu.
	MainMenuURL="Startup"
	// MainMenuName: class of menu to load after quitting the game. Should be Shell.MenuMain unless you know exactly what you're doing
	MainMenuName="Shell.MenuMain"
	// StartMenuName: class of menu to load when starting a new game with bShowStartupOnNewGame=true
	// Typically this will have two options: "Start" and "Quit"
	// If you don't have a specialized start menu, bShowStartupOnNewGame MUST be set to FALSE.
	// If you don't want to code a specialized start menu, you can use Shell.ExpansionMenuStart
	StartMenuName="Shell.MenuMain"
	// GameMenuName: class of menu to use for the Escape menu in-game. Should be Shell.MenuGame unless you know exactly what you're doing
	GameMenuName="Shell.MenuGame"

	// Game logo to be displayed in game menus
	MenuTitleTex="RWSProductTex.Postal2Complete"
	
	// Game Name displayed in the Workshop Browser.
	GameName="Sample Workshop GameInfo"
	// Game Name displayed in the Save/Load Game Menu.
	GameNameshort="Sample Workshop GameInfo"
	// Game Description displayed in the Workshop Browser.
	GameDescription="An example of how to do various things with GameInfo."
}
