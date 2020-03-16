///////////////////////////////////////////////////////////////////////////////
// MenuCheats.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The Cheats menu.
//
///////////////////////////////////////////////////////////////////////////////
class P2DebugMenu_AWP extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string TitleText;

var ShellMenuChoice ResetCopsChoice;
var localized string ResetCopsText, ResetCopsHelp;

var ShellMenuChoice WarpChoice;
var localized string WarpText, WarpHelp;

var ShellMenuChoice MondayChoice, TuesdayChoice, WednesdayChoice, ThursdayChoice, FridayChoice, ApocalypseChoice, ShowdownChoice, DisableDebugChoice;
var localized string MondayText, TuesdayText, WednesdayText, ThursdayText, FridayText, ApocalypseText, ShowdownText, DisableDebugText;
var localized string MondayHelp, TuesdayHelp, WednesdayHelp, ThursdayHelp, FridayHelp, ApocalypseHelp, ShowdownHelp, DisableDebugHelp;
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
	ShowdownChoice=AddChoice(ShowdownText, ShowdownHelp, ItemFont, ItemAlign);
	ApocalypseChoice=AddChoice(ApocalypseText, ApocalypseHelp, ItemFont, ItemAlign);
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
						GetPlayerOwner().ConsoleCommand("setday 1");
						break;
					case TuesdayChoice:
						GoBack();
						HideMenu();
						GetPlayerOwner().ConsoleCommand("setday 2");
						break;
					case WednesdayChoice:
						GoBack();
						HideMenu();
						GetPlayerOwner().ConsoleCommand("setday 3");
						break;
					case ThursdayChoice:
						GoBack();
						HideMenu();
						GetPlayerOwner().ConsoleCommand("setday 4");
						break;
					case FridayChoice:
						GoBack();
						HideMenu();
						GetPlayerOwner().ConsoleCommand("setday 5");
						break;
					case ShowdownChoice:
						GoBack();
						HideMenu();
						GetPlayerOwner().ConsoleCommand("setday 6");
						break;
					case ApocalypseChoice:
						GoBack();
						HideMenu();
						GetPlayerOwner().ConsoleCommand("setday 7");
						break;
					case LoadoutChoice:
						GoBack();
						HideMenu();
						GetPlayerOwner().ConsoleCommand("loadout");
						break;
					case MondayChoice2:
						GoBack();
						HideMenu();
						StartDay(0);
						break;
					case TuesdayChoice2:
						GoBack();
						HideMenu();
						StartDay(1);
						break;
					case WednesdayChoice2:
						GoBack();
						HideMenu();
						StartDay(2);
						break;
					case ThursdayChoice2:
						GoBack();
						HideMenu();
						StartDay(3);
						break;
					case FridayChoice2:
						GoBack();
						HideMenu();
						StartDay(4);
						break;
					case ShowdownChoice2:
						GoBack();
						HideMenu();
						StartDay(5);
						break;
					case ApocalypseChoice2:
						GoBack();
						HideMenu();
						StartDay(6);
						break;
					case WarpChoice:
						Root.ShowModal(Root.CreateWindow(class'DebugShellMapListFrame',
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
		case 5:
			URL = "MovieIntro.fuk";
			break;
		case 6:
			URL = "VincesHouse.fuk";
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
	
	//DayText = "Change Day..."
	//DayHelp = "Changes to another day in the week, completing any errands along the way."
	
	CompleteTodaysErrandsText = "Finish Today's Errands"
	CompleteTodaysErrandsHelp = "Marks all of today's errands complete. The next map transition will bring you to the end-of-day movie."
	
	RestartText = "Restart Current Map"
	RestartHelp = "Reloads current map."
	
	MondayText = "Set Day to Monday"
	TuesdayText = "Set Day to Tuesday"
	WednesdayText = "Set Day to Wednesday"
	ThursdayText = "Set Day to Thursday"
	FridayText = "Set Day to Friday"
	ShowdownText = "Set Day to Saturday"
	ApocalypseText = "Set Day to Sunday"
	MondayText2 = "Start Monday"
	TuesdayText2 = "Start Tuesday"
	WednesdayText2 = "Start Wednesday"
	ThursdayText2 = "Start Thursday"
	FridayText2 = "Start Friday"
	ShowdownText2 = "Start Saturday"
	ApocalypseText2 = "Start Sunday"
	
	MondayHelp = "Sets current day to Monday but does not change map."
	TuesdayHelp = "Sets current day to Tuesday but does not change map."
	WednesdayHelp = "Sets current day to Wednesday but does not change map."
	ThursdayHelp = "Sets current day to Thursday but does not change map."
	FridayHelp = "Sets current day to Friday but does not change map."
	ShowdownHelp = "Sets current day to Saturday but does not change map."
	ApocalypseHelp = "Sets current day to Sunday but does not change map."

	MondayHelp2 = "Starts Monday from the beginning of the day, including intro movie."
	TuesdayHelp2 = "Starts Tuesday from the beginning of the day, including intro movie."
	WednesdayHelp2 = "Starts Wednesday from the beginning of the day, including intro movie."
	ThursdayHelp2 = "Starts Thursday from the beginning of the day, including intro movie."
	FridayHelp2 = "Starts Friday from the beginning of the day, including intro movie."
	ShowdownHelp2 = "Starts Saturday from the beginning, including intro movie."
	ApocalypseHelp2 = "Starts Sunday from the beginning, including intro movie."
	
	LoadoutText = "Get some gear"
	LoadoutHelp = "Gives you some weapons and powerups about equivalent to what you'd normally find for the day you're playing."
	
	DisableDebugText = "DISABLE DEBUG MENU"
	DisableDebugHelp = "Turns off the debug menu."

	CustomMapWidth	= 350
	CustomMapHeight	= 250
}
