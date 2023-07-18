///////////////////////////////////////////////////////////////////////////////
// MenuCheatsEvenMore.uc
// Added by Man Chrzan: xPatch 2.0
//
// Even More Cheats menu.
//
///////////////////////////////////////////////////////////////////////////////
class MenuCheatsEvenMore extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string CheatsTitleText;
var localized string CheatsExplainText;
var localized string CheatsExplainText2;
var ShellMenuChoice	 CheatsExplainChoice;
var ShellMenuChoice	 CheatsExplainChoice2;

const CHEATS_MAX	    		  =14;	//MAKE THIS match the numbers below please!
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
					}
			break;
		}
	}
	
/*					
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
*/


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ItemHeight	 = 20;
	MenuWidth	= 500
	HintLines	= 7
					
	CheatsTitleText = "Even More Cheats"
	CheatsExplainText= "Click below to get the cheat,"
	CheatsExplainText2= "then resume the game to use it."

	CheatsText[0]	=	"GetTheJobDone"
	CheatsHelp[0]	=	"Gives you Eternal Damnation weapons"
	
	CheatsText[1]	=	"ParadiseIsLost"
	CheatsHelp[1]	=	"Gives you Paradise Lost weapons. \\n\\nNOTE: In order for this cheat to work you need to launch POSTAL 2 game mode via Paradise Lost game."
	
	CheatsText[2]	=	"HereKittyKitty"
	CheatsHelp[2]	=	"Gives you a Cat Launcher"
	
	CheatsText[3]	=	"SoThatsWhatItDoes"
	CheatsHelp[3]	=	"Gives you a Box Launcher"
	
	CheatsText[4]	=	"KarmaGun"
	CheatsHelp[4]	=	"Gives you a Karma Gun"
	
	CheatsText[5]	=	"PowerInfused"
	CheatsHelp[5]	=	"Gives you Power-Infused Gary Autobiography"

	CheatsText[6]	=	"ChugIt"
	CheatsHelp[6]	=	"Gives you Crackola!"
	
	CheatsText[7]	=	"DoubleTheGun"
	CheatsHelp[7]	=	"Toggles dual wielding"
	
	CheatsText[8]	=	"ApocalypseNow"
	CheatsHelp[8]	=	"Starts apocalypse"
	
	CheatsText[9]	=	"PeeAll"
	CheatsHelp[9]	=	"Everyone needs to take a piss"

	CheatsText[10]	=	"PukeAll"
	CheatsHelp[10]	=	"Makes Dude and bystanders puke"

	CheatsText[11]	=	"JewTown"
	CheatsHelp[11]	=	"Turns all bystanders to Mike J"

	CheatsText[12]	=	"Zombification"
	CheatsHelp[12]	=	"Turns all bystanders into Zombies"
	
	CheatsText[13]	=	"DudeVSDude"
	CheatsHelp[13]	=	"Turns all bystanders into Dudes"
	
	}
