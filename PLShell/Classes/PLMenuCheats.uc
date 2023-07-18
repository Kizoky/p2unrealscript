///////////////////////////////////////////////////////////////////////////////
// MenuCheats.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The Cheats menu.
//
///////////////////////////////////////////////////////////////////////////////
class PLMenuCheats extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string CheatsTitleText;
var localized string CheatsExplainText;
var localized string CheatsExplainText2;
var ShellMenuChoice	 CheatsExplainChoice;
var ShellMenuChoice	 CheatsExplainChoice2;

var ShellMenuChoice	 NextChoice;

const CHEATS_MAX	    		  =22;	//MAKE THIS match the numbers below please!
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
				case NextChoice:
					GotoMenu(class'PLMenuCheatsMore');
					break;
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
					
	CheatsTitleText		= "Cheats"
	CheatsExplainText	= "Click below to get the cheat,"
	CheatsExplainText2	= "then resume the game to use it."

	CheatsText[0]	= "PacknHeat"
	CheatsHelp[0]	= "Gives you lots of weapons"
	
	CheatsText[1]	= "Payload"
	CheatsHelp[1]	= "Gives you lots of ammunition"
	
	CheatsText[2]	= "PiggyTreats"
	CheatsHelp[2]	= "Gives you lots of donuts"
	
	CheatsText[3]	= "Domino"
	CheatsHelp[3]	= "Gives you lots of pizza"
	
	CheatsText[4]	= "JerkInYourBox"
	CheatsHelp[4]	= "Gives you lots of fast food bags"
	
	CheatsText[5]	= "AmazingAquaCura"
	CheatsHelp[5]	= "Gives you lots of water bottles"
	
	CheatsText[6]	= "BullHonkey"
	CheatsHelp[6]	= "Gives you lots of energy drinks"
	
	CheatsText[7]	= "JewsForJesus"
	CheatsHelp[7]	= "Gives you lots of money"
	
	CheatsText[8]	= "Jones"
	CheatsHelp[8]	= "Gives you lots of 'health' pipes"
	
	CheatsText[9]	= "SwimWithFishes"
	CheatsHelp[9]	= "Gives you a fish radar and related goodies"
	
	CheatsText[10]	= "IAmTheOne"
	CheatsHelp[10]	= "Gives you lots of catnip"
	
	CheatsText[11]	= "LotsaPussy"
	CheatsHelp[11]	= "Cats, that is."
	
	CheatsText[12]	= "CatNado"
	CheatsHelp[12]	= "Gives you lots of experimental test cats"
	
	CheatsText[13]	= "BlockMyAss"
	CheatsHelp[13]	= "Gives you a set of body armor"
	
	CheatsText[14]	= "IAmTheLaw"
	CheatsHelp[14]	= "Gives you a Lawman disguise"
	
	CheatsText[15]	= "BoyAndHisDog"
	CheatsHelp[15]	= "Gives you lots of doggy treats"
	
	CheatsText[16]	= "DogLover"
	CheatsHelp[16]	= "Gives you a loyal canine companion. It's no Champ, but it's close."
	
	CheatsText[17]	= "BeastLove"
	CheatsHelp[17]	= "For when you need a companion a bit more beastly than the regular dogs"
	
	CheatsText[18]	= "DudesBestFriend"
	CheatsHelp[18]	= "Thanks to the latest in cloning technology, a clone of Champ can assist you in your hunt for the real one!"
	
	CheatsText[19]	= "FunzerkingKicksAss"
	CheatsHelp[19]	= "Two guns, bitches!"
	
	CheatsText[20]	= "FireInYourHole"
	CheatsHelp[20]	= "Holy crap! A camera for my rockets! (Toggle)"

	CheatsText[21]	= "CoverMyAss"
	CheatsHelp[21]	= "Gives you your very own AI partner and a radio you can use to boss them around!"	
}
