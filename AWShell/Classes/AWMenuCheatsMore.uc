///////////////////////////////////////////////////////////////////////////////
// AWMenuCheatsMore.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// The More Cheats menu for AW.
//
///////////////////////////////////////////////////////////////////////////////
class AWMenuCheatsMore extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string CheatsTitleText;
var localized string CheatsExplainText;
var localized string CheatsExplainText2;
var ShellMenuChoice	 CheatsExplainChoice;
var ShellMenuChoice	 CheatsExplainChoice2;

const CHEATS_MAX	    		  =6;	//MAKE THIS match the numbers below please!
var ShellMenuChoice	  CheatsChoice[6]; // Don't change this without changing the above
var			  string	CheatsText[6]; // Don't change this without changing the above
// - DON'T LOCALIZE THE CHEATSTEXT!!
// If you localize these, they won't work with the game to make the cheats work.
var localized string	CheatsHelp[6]; // Don't change this without changing the above

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
					}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     CheatsTitleText="More Cheats"
     CheatsExplainText="Click below to get the cheat,"
     CheatsExplainText2="then resume the game to use it."
     CheatsText(0)="BlockMyAss"
     CheatsText(1)="RockinCats"
     CheatsText(2)="DokkinCats"
     CheatsText(3)="BoppinCats"
     CheatsText(4)="SplodinCats"
     CheatsText(5)="HeadShots"
     CheatsHelp(0)="Grants you body armor"
     CheatsHelp(1)="Shoot cats from gun--turns ON"
     CheatsHelp(2)="Shoot cats from gun--turns OFF"
     CheatsHelp(3)="Flying cats bounce off walls--turns ON"
     CheatsHelp(4)="Flying cats bounce off walls--turns OFF"
     CheatsHelp(5)="People die with one bullet to the head (Toggles)"
     MenuWidth=500.000000
     ItemHeight=25.000000
     astrTextureDetailNames(0)="UltraLow"
     astrTextureDetailNames(1)="Low"
     astrTextureDetailNames(2)="Medium"
     astrTextureDetailNames(3)="High"
}
