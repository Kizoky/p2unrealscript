///////////////////////////////////////////////////////////////////////////////
// PLDebugMenuMain
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// A very slimmed-down Debug Menu that simply allows starting a new game in
// any map.
///////////////////////////////////////////////////////////////////////////////
class PLDebugMenuMain extends PLDebugMenu;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	local int i;

	Super(ShellMenuCW).CreateMenuContents();
	
	ItemFont	= F_FancyM;
	ItemAlign = TA_Center;
	AddTitle(TitleText, TitleFont, TitleAlign);

	WarpChoice = AddChoice(WarpText, WarpHelp, ItemFont, ItemAlign);
	BackChoice			= AddChoice(BackText, "", ItemFont, TitleAlign, true);

	// If you start up this menu, make sure to enable cheats for you
	FPSPlayer(GetPlayerOwner()).ForceDebugMenu();
}
