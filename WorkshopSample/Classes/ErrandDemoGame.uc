///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Game Info
//
// This is a sample Workshop GameInfo based off of GameSinglePlayer.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This is an example of how to set up an errand, using the classic "get milk"
// errand from the POSTAL 2 Demo.
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
class ErrandDemoGame extends SampleWorkshopGameInfo;

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
	// if he hasn't gotten his paycheck/gotten fired yet. That errand doesn't exist in this game (just the get milk errand)
	// but the game will still see it as being an unfinished errand, so we simply look for all the RWS guys
	// and make them think they've told the Dude to go see Vince already, so they won't keep bothering him.
	foreach DynamicActors(class'RWSController', R)
		R.bToldPlayer = true;
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

		//log(self$" PrepPlayerStartup "$p2p$" first "$TheGameState.bFirstLevelOfDay);
		if(p2p != None
			&& TheGameState.bFirstLevelOfDay)
		{
			//log(self$" requesting map ");
			p2p.ForceMapUp();
		}
		
		Super.PrepPlayerStartup();
	}
}

defaultproperties
{
	// To build a custom game, you need to define your own Days and Errands.
	// Here is a very simple errand from the game: get some milk!
	// Get Milk
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetMilk
		// There are several ways to complete an errand, see MoreGame for all the various ErrandGoals.
		// This goal is to grab a pickup, which is defined by the PickupTag.
		// Then in the map, you place the desired pickup in the map and set its tag accordingly.
		TriggerOnCompletionTag="MilkErrand_Completed"
		PickupTag="MilkPickup"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBaseGetMilk
		// This defines the actual errand. Some errands have multiple ways to finish them
		// (for example, on Wednesday you can confess your sins or just kill the priest)
		UniqueName="GetMilk"
		NameTex="p2misc.map.GetMilk_text"
		// All this fancy location stuff just tells the game where to draw the
		// markers on the pop-up map.
		LocationTex="p2misc.map.GetMilk_here"
		LocationX=728
		LocationY=428
		LocationCrossTex="p2misc.map.hint_cross_3"
		LocationCrossX=730
		LocationCrossY=458
		// Dude commentary on the errand.
		DudeStartComment="DudeDialog.dude_map_getmilk"
		DudeWhereComment="DudeDialog.Dude_map_loc4"
		DudeFoundComment="DudeDialog.Dude_map_found1"
		DudeCompletedComment="DudeDialog.dude_map_tooeasy"
		// The actual goals are defined here. Completing any one of these goals completes the errand.
		Goals(0)=ErrandGoalGetPickup'ErrandGoalGetMilk'
	End Object

	// Now that we have our errand, we need to define a day for that errand!
	Begin Object Class=DayBase Name=DayBaseErrandDemo
		// Give the day a description. This is displayed on the save/load screen.
		Description="Monday"
		// The day's Unique Name is used for mapping purposes. In the base game, there are five
		// unique names: DAY_A, DAY_B, DAY_C, DAY_D, and DAY_E, which are used for Monday thru
		// Friday respectively. When loading, the game will look for actors in the map that match
		// with these groups. This allows you to use the same map for several different days
		// and have it look different each day.
		// Because our game only uses DAY_A, we have to manually exclude DAY_B through DAY_E,
		// because the game won't bother to look for them otherwise.
		// You won't normally have to do this if you're doing a single-day game, but our test
		// map is a mashup of two maps from the base game, and I was too lazy to change all the group names and whatnot.
		UniqueName="DAY_A"
		ExcludeDays[0]="DEMO"
		ExcludeDays[1]="DAY_B"
		ExcludeDays[2]="DAY_C"
		ExcludeDays[3]="DAY_D"
		ExcludeDays[4]="DAY_E"
		// Define the day's errands here. We just have the one.
		Errands(0)=ErrandBase'ErrandBaseGetMilk'
		// This defines the map screen for the day. In the base game, the Dude is restricted to a few areas
		// and as the week progresses more areas open up to him. For our purposes we'll just use the
		// demo Monday map.
        MapTex="p2misc.Map.map_demo"
		// Defines the newspaper texture for the day. We'll just use Monday's.
        NewsTex="p2misc.newspaper_day_1"
		DudeNewsComment="DudeDialog.dude_news_monday"
		// Loading screen for the day.
		LoadTex="p2misc_full.Load.loading1"
		DudeStartComment="DudeDialog.dude_map_exit1"

		// Each day you can define various inventory items to give the player at the start of that day.
		// For instance, on Tuesday in the base game, we give him a ClipboardWeapon so that he can
		// use it to collect signatures.
		// Use NeededAmount if you need to give the player a bunch of an item, such as money.
		// (NeededAmount does not work with weapons or ammo)
		// If you set bEnhancedOnly to true, the dude is only given that item in the Enhanced Game.
		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=20)
		PlayerInvList(1)=(InvClassName="Inventory.MapInv")
		PlayerInvList(2)=(InvClassName="Inventory.CopClothesInv",bEnhancedOnly=true)
		PlayerInvList(3)=(InvClassName="Inventory.StatInv")

		// The following items are taken from the dude at the END of the day.
		// Useful for getting rid of inventory items that aren't needed for the rest of the week
		// (such as the clipboard or other errand items)
		TakeFromPlayerList(0)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.GimpClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(3)=(InvClassName="Inventory.MilkInv")
		TakeFromPlayerList(4)=(InvClassName="Inventory.PaycheckInv")
	End Object

	// Game Definition
	// This is where you put together the days you've assembled to form a full week.
	// We just have the one day, so define it here.
	Days(0)=DayBase'DayBaseErrandDemo'
	
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
	StartFirstDayURL	= "ws-ErrandDemo"
	
	// This is the map the dude gets sent to when starting any other day of the week.
	// In POSTAL 2 and the first five days of AWP, this is Suburbs-3, which loads up an intro cinematic that
	// shows the dude the errands he has to complete for the day.
	// If you don't have multiple days in your game, or if your game doesn't use the days for progression,
	// then this can be left blank.
	StartNextDayURL		= "ws-ErrandDemo"
	
	// This is the map the dude will get redirected to once he's finished all his errands.
	// After buying the milk, attempting to leave the map or return to the trailer will load this map.
	// The map we've put here is a simple map that runs the credits sequence and ends the game.
	FinishedDayURL		= "rollcredits"
	
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
	DefaultPlayerClassName="GameTypes.AWPostalDude"
	
	// You can override the player's HUD here.
	HUDType="GameTypes.AchievementHUD"
	
	// Game Name displayed in the Workshop Browser.
	GameName="Errand Demo"
	// Game Name displayed in the Save/Load Game Menu.
	GameNameshort="Errand Demo"
	// Game Description displayed in the Workshop Browser.
	GameDescription="A demo game showing off the 'Grab Milk' errand."
}
