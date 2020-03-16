///////////////////////////////////////////////////////////////////////////////
// MenuCheatsMore.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The More Cheats menu.
//
///////////////////////////////////////////////////////////////////////////////
class MenuCheatsMore extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string CheatsTitleText;
var localized string CheatsExplainText;
var localized string CheatsExplainText2;
var ShellMenuChoice	 CheatsExplainChoice;
var ShellMenuChoice	 CheatsExplainChoice2;

const CHEATS_MAX	    		  =18;	//MAKE THIS match the numbers below please!
var ShellMenuChoice	  CheatsChoice[CHEATS_MAX]; // Don't change this without changing the above
var localized string	CheatsText[CHEATS_MAX]; // Don't change this without changing the above
var localized string	CheatsHelp[CHEATS_MAX]; // Don't change this without changing the above

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
	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					case BackChoice:
						GoBack();
						break;
					case CheatsChoice[0]:
						GetPlayerOwner().ConsoleCommand(CheatsText[0]);
						break;
					case CheatsChoice[1]:
						GetPlayerOwner().ConsoleCommand(CheatsText[1]);
						break;
					case CheatsChoice[2]:
						GetPlayerOwner().ConsoleCommand(CheatsText[2]);
						break;
					case CheatsChoice[3]:
						GetPlayerOwner().ConsoleCommand(CheatsText[3]);
						break;
					case CheatsChoice[4]:
						GetPlayerOwner().ConsoleCommand(CheatsText[4]);
						break;
					case CheatsChoice[5]:
						GetPlayerOwner().ConsoleCommand(CheatsText[5]);
						break;
					case CheatsChoice[6]:
						GetPlayerOwner().ConsoleCommand(CheatsText[6]);
						break;
					case CheatsChoice[7]:
						GetPlayerOwner().ConsoleCommand(CheatsText[7]);
						break;
					case CheatsChoice[8]:
						GetPlayerOwner().ConsoleCommand(CheatsText[8]);
						break;
					case CheatsChoice[9]:
						GetPlayerOwner().ConsoleCommand(CheatsText[9]);
						break;
					case CheatsChoice[10]:
						GetPlayerOwner().ConsoleCommand(CheatsText[10]);
						break;
					case CheatsChoice[11]:
						GetPlayerOwner().ConsoleCommand(CheatsText[11]);
						break;
					case CheatsChoice[12]:
						GetPlayerOwner().ConsoleCommand(CheatsText[12]);
						break;
					case CheatsChoice[13]:
						GetPlayerOwner().ConsoleCommand(CheatsText[13]);
						break;
					case CheatsChoice[14]:
						GetPlayerOwner().ConsoleCommand(CheatsText[14]);
						break;
					case CheatsChoice[15]:
						GetPlayerOwner().ConsoleCommand(CheatsText[15]);
						break;
					case CheatsChoice[16]:
						GetPlayerOwner().ConsoleCommand(CheatsText[16]);
						break;
					case CheatsChoice[17]:
						GetPlayerOwner().ConsoleCommand(CheatsText[17]);
						break;
					}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ItemHeight	 = 20;
	MenuWidth	= 500
	HintLines	= 2
					
	CheatsTitleText = "More Cheats"
	CheatsExplainText= "Click below to get the cheat,"
	CheatsExplainText2= "then resume the game to use it."

	CheatsText[0]	=	"Bladey"
	CheatsHelp[0]	=	"Powers up your boomerang machete"

	CheatsText[1]	=	"HulkSmash"
	CheatsHelp[1]	=	"Powers up your sledgehammer"

	CheatsText[2]	=	"LimbSnapper"
	CheatsHelp[2]	=	"Throw the sledgehammer head-on into a bystander for a surprise"

	CheatsText[3]	=	"ReaperOfLove"
	CheatsHelp[3]	=	"Powers up your scythe"

	CheatsText[4]	=	"MightyFoot"
	CheatsHelp[4]	=	"Gives you a mighty foot (toggle)"

	CheatsText[5]	=	"DogLover"
	CheatsHelp[5]	=	"Gives you a free dog helper"

	CheatsText[6]	=	"GonorrheaChaChaCha"
	CheatsHelp[6]	=	"Gives you gonorrhea (toggle)"

	CheatsText[7]	=	"SuperMario"
	CheatsHelp[7]	=	"Makes you jump really high (toggle)"

	CheatsText[8]	=	"SonicSpeed"
	CheatsHelp[8]	=	"Makes you run really fast (toggle)"

	CheatsText[9]	=	"Domino"
	CheatsHelp[9]	=	"Gives you lots of pizza"

	CheatsText[10]	=	"JerkInYourBox"
	CheatsHelp[10]	=	"Gives you lots of fast food"
	
	CheatsText[11]	=	"CatNado"
	CheatsHelp[11]	=	"Gives you experimental test cats"

	CheatsText[12]	=	"MoonMan"
	CheatsHelp[12]	=	"Toggles Low Gravity"

	CheatsText[13]	=	"TheQuick"
	CheatsHelp[13]	=	"Makes your weapons fire really fast -- Turns ON"
	
	CheatsText[14]	=	"UnQuick"
	CheatsHelp[14]	=	"Makes your weapons fire really fast -- Turns OFF"
	
	CheatsText[15] = "KrotchatizeMe"
	CheatsHelp[15] = "Turns all bystanders into Krotchys"
	
	CheatsText[16] = "EgoBoost"
	CheatsHelp[16] = "Gives everyone a huge head"
	
	CheatsText[17] = "WitchDoctor"
	CheatsHelp[17] = "Shrinks everyone's heads"
	
	}
