///////////////////////////////////////////////////////////////////////////////
// MenuCheats.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The Cheats menu.
//
///////////////////////////////////////////////////////////////////////////////
class PLMenuCheatsMore extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string CheatsTitleText;
var localized string CheatsExplainText;
var localized string CheatsExplainText2;
var ShellMenuChoice	 CheatsExplainChoice;
var ShellMenuChoice	 CheatsExplainChoice2;

var ShellMenuChoice	 NextChoice;

const CHEATS_MAX	    		  =23;	//MAKE THIS match the numbers below please!
var ShellMenuChoice	  CheatsChoice[CHEATS_MAX]; // Don't change this without changing the above
var localized string  CheatsText[CHEATS_MAX]; // Don't change this without changing the above
var localized string  CheatsHelp[CHEATS_MAX]; // Don't change this without changing the above

var int				  CustomMapWidth;
var int				  CustomMapHeight;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local int i;

	Super.CreateMenuContents();
	
	ItemFont	= F_FancyM;
	ItemAlign = TA_Center;
	AddTitle(CheatsTitleText, TitleFont, TitleAlign);
	CheatsExplainChoice=AddChoice(CheatsExplainText, "", ItemFont, TitleAlign);
	CheatsExplainChoice.bActive=false;
	CheatsExplainChoice2=AddChoice(CheatsExplainText2, "", ItemFont, TitleAlign);
	CheatsExplainChoice2.bActive=false;

	for(i=0; i<CHEATS_MAX; i++)
	{
		CheatsChoice[i]		= AddChoice(CheatsText[i],	CheatsHelp[i],	ItemFont, ItemAlign);
	}

	BackChoice			= AddChoice(BackText, "", ItemFont, TitleAlign, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local int i;
	
	Super.Notify(C, E);	
	if (E == DE_Click)
	{
		if (C != None)
		{
			for (i = 0; i < CHEATS_MAX; i++)
				if (C == CheatsChoice[i])
				{
					GetPlayerOwner().ConsoleCommand(CheatsText[i]);
					break;
				}
			switch (C)
			{
				case BackChoice:
					GoBack();
					break;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ItemHeight	= 20;
	MenuWidth	= 500
	HintLines	= 2
					
	CheatsTitleText		= "More Cheats"
	CheatsExplainText	= "Click below to get the cheat,"
	CheatsExplainText2	= "then resume the game to use it."

	CheatsText[0]	= "RockinCats"
	CheatsHelp[0]	= "Shoots cats from machine gun and shotgun -- Turns ON"
	
	CheatsText[1]	= "DokkinCats"
	CheatsHelp[1]	= "Shoots cats from machine gun and shotgun -- Turns OFF"
	
	CheatsText[2]	= "BoppinCats"
	CheatsHelp[2]	= "Flying cats bounce off of walls -- Turns ON"
	
	CheatsText[3]	= "SplodinCats"
	CheatsHelp[3]	= "Flying cats bounce off of walls  -- Turns OFF"
	
	CheatsText[4]	= "GunForAnts"
	CheatsHelp[4]	= "What is this?! A gun that makes ants?"
	
	CheatsText[5]	= "HammerTime"
	CheatsHelp[5]	= "Gives you a hammer you can use to cave people's heads in"
	
	CheatsText[6]	= "TexasChainSawMassacre"
	CheatsHelp[6]	= "Gives you a chainsaw to go killin' with"
	
	CheatsText[7]	= "ThisIsMyBoomstick"
	CheatsHelp[7]	= "Shop smart... shop S-mart."
	
	CheatsText[8]	= "HeadShots"
	CheatsHelp[8]	= "Toggles one-shot pistol head shot kills"
	
	CheatsText[9]	= "Bladey"
	CheatsHelp[9]	= "Powers up your machete alt-fire"
	
	CheatsText[10]	= "HulkSmash"
	CheatsHelp[10]	= "Powers up your sledgehammer alt-fire"
	
	CheatsText[11]	= "LimbSnapper"
	CheatsHelp[11]	= "Throw your sledgehammer head-on at a bystander for a surprise"
	
	CheatsText[12]	= "ReaperOfLove"
	CheatsHelp[12]	= "Powers up your scythe alt-fire"
	
	CheatsText[13]	= "MightyFoot"
	CheatsHelp[13]	= "Gives you additional kicking power"
	
	CheatsText[14]	= "MoonMan"
	CheatsHelp[14]	= "We had to cut the orbital space station side mission, but you can have some low gravity"
	
	CheatsText[15]	= "TheQuick"
	CheatsHelp[15]	= "Rapid fire for all weapons -- Turns ON"
	
	CheatsText[16]	= "UnQuick"
	CheatsHelp[16]	= "Rapid fire for all weapons -- Turns OFF"
	
	CheatsText[17]	= "SuperMario"
	CheatsHelp[17]	= "Lets you jump really high"
	
	CheatsText[18]	= "SonicSpeed"
	CheatsHelp[18]	= "Lets you run really fast"
	
	CheatsText[19]	= "Osama"
	CheatsHelp[19]	= "Turns bystanders into peace-loving hippies"
	
	CheatsText[20]	= "Robolution"
	CheatsHelp[20]	= "Turns bystanders into pissed-off Pisstraps"
	
	CheatsText[21]	= "EgoBoost"
	CheatsHelp[21]	= "Gives everyone a really big head"
	
	CheatsText[22]	= "WitchDoctor"
	CheatsHelp[22]	= "Shrinks everyone's head"
}
