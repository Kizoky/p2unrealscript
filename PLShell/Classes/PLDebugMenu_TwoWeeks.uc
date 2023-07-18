///////////////////////////////////////////////////////////////////////////////
// MenuCheats.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The Cheats menu.
//
///////////////////////////////////////////////////////////////////////////////
class PLDebugMenu_TwoWeeks extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string TitleText;

var ShellMenuChoice ResetCopsChoice;
var localized string ResetCopsText, ResetCopsHelp;

var ShellMenuChoice WarpChoice;
var localized string WarpText, WarpHelp;

var ShellMenuChoice MondayChoice, TuesdayChoice, WednesdayChoice, ThursdayChoice, FridayChoice, SaturdayChoice, SundayChoice, DisableDebugChoice;
var localized string MondayText, TuesdayText, WednesdayText, ThursdayText, FridayText, SaturdayText, SundayText, DisableDebugText;
var localized string MondayHelp, TuesdayHelp, WednesdayHelp, ThursdayHelp, FridayHelp, SaturdayHelp, SundayHelp, DisableDebugHelp;

var ShellMenuChoice MondayChoice2, TuesdayChoice2, WednesdayChoice2, ThursdayChoice2, FridayChoice2, ApocalypseChoice2, ShowdownChoice2;
var localized string MondayText2, TuesdayText2, WednesdayText2, ThursdayText2, FridayText2, ApocalypseText2, ShowdownText2;
var localized string MondayHelp2, TuesdayHelp2, WednesdayHelp2, ThursdayHelp2, FridayHelp2, ApocalypseHelp2, ShowdownHelp2;

var ShellMenuChoice CompleteTodaysErrandsChoice;
var localized string CompleteTodaysErrandsText, CompleteTodaysErrandsHelp;

var ShellMenuChoice RestartChoice;
var localized string RestartText, RestartHelp;

var ShellMenuChoice LoadoutChoice;
var localized string LoadoutText, LoadoutHelp;

var int					CustomMapWidth;
var int					CustomMapHeight;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	local int i;

	Super.CreateMenuContents();
	
	ItemFont	= F_FancyM;
	ItemAlign = TA_Center;
	AddTitle(TitleText, TitleFont, TitleAlign);

	MondayChoice=AddChoice(MondayText, MondayHelp, ItemFont, ItemAlign);
	TuesdayChoice=AddChoice(TuesdayText, TuesdayHelp, ItemFont, ItemAlign);
	WednesdayChoice=AddChoice(WednesdayText, WednesdayHelp, ItemFont, ItemAlign);
	ThursdayChoice=AddChoice(ThursdayText, ThursdayHelp, ItemFont, ItemAlign);
	FridayChoice=AddChoice(FridayText, FridayHelp, ItemFont, ItemAlign);
	SaturdayChoice=AddChoice(SaturdayText, SaturdayHelp, ItemFont, ItemAlign);
	SundayChoice=AddChoice(SundayText, SundayHelp, ItemFont, ItemAlign);
	MondayChoice2=AddChoice(MondayText2, MondayHelp2, ItemFont, ItemAlign);
	TuesdayChoice2=AddChoice(TuesdayText2, TuesdayHelp2, ItemFont, ItemAlign);
	WednesdayChoice2=AddChoice(WednesdayText2, WednesdayHelp2, ItemFont, ItemAlign);
	ThursdayChoice2=AddChoice(ThursdayText2, ThursdayHelp2, ItemFont, ItemAlign);
	FridayChoice2=AddChoice(FridayText2, FridayHelp2, ItemFont, ItemAlign);
	ShowdownChoice2=AddChoice(ShowdownText2, ShowdownHelp2, ItemFont, ItemAlign);
	ApocalypseChoice2=AddChoice(ApocalypseText2, ApocalypseHelp2, ItemFont, ItemAlign);
	
	WarpChoice = AddChoice(WarpText, WarpHelp, ItemFont, ItemAlign);
	CompleteTodaysErrandsChoice = AddChoice(CompleteTodaysErrandsText, CompleteTodaysErrandsHelp, ItemFont, ItemAlign);
	ResetCopsChoice = AddChoice(ResetCopsText, ResetCopsHelp, ItemFont, ItemAlign);
	LoadoutChoice = AddChoice(LoadoutText, LoadoutHelp, ItemFont, ItemAlign);
	DisableDebugChoice = AddChoice(DisableDebugText, DisableDebugHelp, ItemFont, ItemAlign);
	BackChoice			= AddChoice(BackText, "", ItemFont, TitleAlign, true);

	// If you start up this menu, make sure to enable cheats for you
	FPSPlayer(GetPlayerOwner()).ForceDebugMenu();
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
	{
		case DE_Click:
			if (C != None)
				switch (C)
				{
					case ResetCopsChoice:
						GetPlayerOwner().ConsoleCommand("ResetCops");
						GoBack();
						HideMenu();
						break;
					case CompleteTodaysErrandsChoice:
						GetPlayerOwner().ConsoleCommand("SetTodaysErrandsComplete");
						GoBack();
						HideMenu();
						break;
					case MondayChoice:
						GoBack();
						HideMenu();
						StartDay(0);
						break;
					case TuesdayChoice:
						GoBack();
						HideMenu();
						StartDay(1);
						break;
					case WednesdayChoice:
						GoBack();
						HideMenu();
						StartDay(2);
						break;
					case ThursdayChoice:
						GoBack();
						HideMenu();
						StartDay(3);
						break;
					case FridayChoice:
						GoBack();
						HideMenu();
						StartDay(4);
						break;
					case SaturdayChoice:
						GoBack();
						HideMenu();
						StartDay(5);
						break;
					case SundayChoice:
						GoBack();
						HideMenu();
						StartDay(6);
						break;
					case MondayChoice2:
						GoBack();
						HideMenu();
						StartDay(7);
						break;
					case TuesdayChoice2:
						GoBack();
						HideMenu();
						StartDay(8);
						break;
					case WednesdayChoice2:
						GoBack();
						HideMenu();
						StartDay(9);
						break;
					case ThursdayChoice2:
						GoBack();
						HideMenu();
						StartDay(10);
						break;
					case FridayChoice2:
						GoBack();
						HideMenu();
						StartDay(11);
						break;
					case ShowdownChoice2:
						GoBack();
						HideMenu();
						StartDay(12);
						break;
					case ApocalypseChoice2:
						GoBack();
						HideMenu();
						StartDay(13);
						break;
					case LoadoutChoice:
						GoBack();
						HideMenu();
						GetPlayerOwner().ConsoleCommand("loadout");
						break;
					case WarpChoice:
						Root.ShowModal(Root.CreateWindow(class'PLShellMapListFrame',
										(Root.WinWidth - CustomMapWidth) /2, 
										(Root.WinHeight - CustomMapHeight) /2, 
										CustomMapWidth, CustomMapHeight, self));
						break;
					case DisableDebugChoice:
						GoBack();
						HideMenu();
						GetPlayerOwner().ConsoleCommand("enabledebugmenu");
						break;
					case BackChoice:
						GoBack();
						break;
				}
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Functions to start various days, including intro movies
///////////////////////////////////////////////////////////////////////////////
function StartDay(int dayno)
{
	local P2GameInfoSingle psg;
	local string URL;
	local int i;
	
	psg = P2GameInfoSingle(GetPlayerOwner().Level.Game);
	if (psg == None)
		return;
		
	switch (dayno)
	{
		case 0:
			URL = psg.StartFirstDayURL;			
			break;
		default:
			URL = psg.Days[dayno].StartDayURL;
			if (URL == "")
				URL = psg.StartNextDayURL;
			break;
	}
	
	psg.SetDay(dayno + 1, URL);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ItemHeight	= 20
	MenuWidth	= 500
					
	TitleText = "Debug Menu"
	
	ResetCopsText = "Reset Wanted Meter"
	ResetCopsHelp = "Zeroes wanted meter"
	
	WarpText = "Warp to Map..."
	WarpHelp = "Warps to a map of your choice."
	
//	DayText = "Change Day..."
//	DayHelp = "Changes to another day in the week, completing any errands along the way."
	
	CompleteTodaysErrandsText = "Finish Today's Errands"
	CompleteTodaysErrandsHelp = "Marks all of today's errands complete. The next map transition will bring you to the end-of-day movie."
	
	RestartText = "Restart Current Map"
	RestartHelp = "Reloads current map."
	
	MondayText = "Start Monday"
	TuesdayText = "Start Tuesday"
	WednesdayText = "Start Wednesday"
	ThursdayText = "Start Thursday"
	FridayText = "Start Friday"
	SaturdayText = "Start Saturday"
	SundayText = "Start Sunday"
	MondayText2 = "Start Monday (PL)"
	TuesdayText2 = "Start Tuesday (PL)"
	WednesdayText2 = "Start Wednesday (PL)"
	ThursdayText2 = "Start Thursday (PL)"
	FridayText2 = "Start Friday (PL)"
	ShowdownText2 = "Start Showdown (PL)"
	ApocalypseText2 = "Start Apocalypse (PL)"
	
	MondayHelp = "Starts Monday from the beginning of the day, including intro movie."
	TuesdayHelp = "Starts Tuesday from the beginning of the day, including intro movie."
	WednesdayHelp = "Starts Wednesday from the beginning of the day, including intro movie."
	ThursdayHelp = "Starts Thursday from the beginning of the day, including intro movie."
	FridayHelp = "Starts Friday from the beginning of the day, including intro movie."
	SaturdayHelp = "Starts Saturday from the beginning, including intro movie."
	SundayHelp = "Starts Sunday from the beginning, including intro movie."

	MondayHelp2 = "Starts Monday from the beginning of the day, including intro movie."
	TuesdayHelp2 = "Starts Tuesday from the beginning of the day, including intro movie."
	WednesdayHelp2 = "Starts Wednesday from the beginning of the day, including intro movie."
	ThursdayHelp2 = "Starts Thursday from the beginning of the day, including intro movie."
	FridayHelp2 = "Starts Friday from the beginning of the day, including intro movie."
	ShowdownHelp2 = "Starts the Showdown from the beginning, including intro movie."
	ApocalypseHelp2 = "Starts the Apocalypse the beginning, including intro movie."
	
	LoadoutText = "Get some gear"
	LoadoutHelp = "Gives you some weapons and powerups about equivalent to what you'd normally find for the day you're playing."
	
	DisableDebugText = "DISABLE DEBUG MENU"
	DisableDebugHelp = "Turns off the debug menu."

	CustomMapWidth	= 350
	CustomMapHeight	= 250
}
