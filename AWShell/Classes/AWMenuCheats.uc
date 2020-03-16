///////////////////////////////////////////////////////////////////////////////
// AWMenuCheats.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// The AW Cheats menu.
//
///////////////////////////////////////////////////////////////////////////////
class AWMenuCheats extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string CheatsTitleText;
var localized string CheatsExplainText;
var localized string CheatsExplainText2;
var ShellMenuChoice	 CheatsExplainChoice;
var ShellMenuChoice	 CheatsExplainChoice2;

var string BlankText;

var ShellMenuChoice	 NextChoice;

var class<ShellMenuCW> MenuMoreCheatsClass;

const CHEATS_MAX	    		  =10;	//MAKE THIS match the numbers below please!
var ShellMenuChoice	  CheatsChoice[10]; // Don't change this without changing the above
var			  string    CheatsText[10]; // Don't change this without changing the above 
// - DON'T LOCALIZE THE CHEATSTEXT!!
// If you localize these, they won't work with the game to make the cheats work.
var localized string    CheatsHelp[10]; // Don't change this without changing the above

var int				  CustomMapWidth;
var int				  CustomMapHeight;
const BLANK1 = 4;
const BLANK1A= 5;
const BLANK2 = 2;
const BLANK3 = 3;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local int i;
	local AWGameSP useinfo;

	Super.CreateMenuContents();
	
	ItemFont	= F_FancyM;
	ItemAlign = TA_Center;
	AddTitle(CheatsTitleText, TitleFont, TitleAlign);
	CheatsExplainChoice=AddChoice(CheatsExplainText, "", ItemFont, TitleAlign);
	CheatsExplainChoice.bActive=false;
	CheatsExplainChoice2=AddChoice(CheatsExplainText2, "", ItemFont, TitleAlign);
	CheatsExplainChoice2.bActive=false;

	useinfo = AWGameSP(GetGameSingle());
	if(!useinfo.DoMP1())
	{

		CheatsText[BLANK1] = BlankText;
		CheatsHelp[BLANK1] = BlankText;
		CheatsText[BLANK1A] = BlankText;
		CheatsHelp[BLANK1A] = BlankText;
	}
	if(!useinfo.DoMP2())
	{
		CheatsText[BLANK2] = BlankText;
		CheatsHelp[BLANK2] = BlankText;
	}
	if(!useinfo.DoMP3())
	{
		CheatsText[BLANK3] = BlankText;
		CheatsHelp[BLANK3] = BlankText;
	}
	for(i=0; i<CHEATS_MAX; i++)
	{
		CheatsChoice[i]		= AddChoice(CheatsText[i],	CheatsHelp[i],	ItemFont, ItemAlign);
	}
	if(!useinfo.DoMP1())
	{
		CheatsChoice[BLANK1].bActive=false;
		CheatsChoice[BLANK1A].bActive=false;
	}
	if(!useinfo.DoMP2())
		CheatsChoice[BLANK2].bActive=false;
	if(!useinfo.DoMP3())
		CheatsChoice[BLANK3].bActive=false;
	NextChoice			= AddChoice(NextText, "", ItemFont, TitleAlign);
	BackChoice			= AddChoice(BackText, "", ItemFont, TitleAlign, true);

	// If you start up this menu, make sure to enable cheats for you
	GetPlayerOwner().ConsoleCommand("ForceSissy");
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
					case NextChoice:
						GotoMenu(MenuMoreCheatsClass);
						break;
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
					}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     CheatsTitleText="Cheats"
     CheatsExplainText="Click below to get the cheat,"
     CheatsExplainText2="then resume the game to use it."
     BlankText="? ? ? ? ?"
     MenuMoreCheatsClass=Class'AWShell.AWMenuCheatsMore'
     CheatsText(0)="GunRack"
     CheatsText(1)="BlastaCap"
     CheatsText(2)="ReaperOfLove"
     CheatsText(3)="Bladey"
     CheatsText(4)="HulkSmash"
     CheatsText(5)="LimbSnapper"
     CheatsText(6)="CatFancy"
     CheatsText(7)="FireInYourHole"
     CheatsText(8)="IAmTheOne"
     CheatsText(9)="HeadShop"
     CheatsHelp(0)="Gives you all weapons"
     CheatsHelp(1)="Gives you lots of ammo"
     CheatsHelp(2)="Throw lots of scythes"
     CheatsHelp(3)="Throw lots of machetes"
     CheatsHelp(4)="Throw lots of sledges"
     CheatsHelp(5)="Hit a guy head on with the flying sledge for silly slomo!"
     CheatsHelp(6)="Lots of dervish cats--throw them for fun!"
     CheatsHelp(7)="Holy crap--a camera for my rockets! (Toggles)"
     CheatsHelp(8)="Gives you lots of catnip"
     CheatsHelp(9)="Tons of 'health' pipes."
     MenuWidth=500.000000
     ItemHeight=25.000000
     astrTextureDetailNames(0)="UltraLow"
     astrTextureDetailNames(1)="Low"
     astrTextureDetailNames(2)="Medium"
     astrTextureDetailNames(3)="High"
}
