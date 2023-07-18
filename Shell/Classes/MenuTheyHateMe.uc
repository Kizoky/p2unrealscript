///////////////////////////////////////////////////////////////////////////////
// MenuTheyHateMe.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Menu to explain TheyHateMe difficulty. This is extra hard and has most 
// people attacking the dude on sight.
//
///////////////////////////////////////////////////////////////////////////////
class MenuTheyHateMe extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string		HateTitleText;

var localized string		Msg[7];

var ShellMenuChoice			StartChoice;

var bool bUpdate;

var MenuStart MyMenuStart;

var Color MsgColor;
var int MsgHeight;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local int i;
	local array<string> Msg2;
	local ShellWrappedTextControl ctl;

	// Dynamic arrays don't localize properly, so copy static array to dynamic array
	Msg2.insert(0, ArrayCount(Msg));
	for (i = 0; i < Msg2.length; i++)
		Msg2[i] = Msg[i];

	Super.CreateMenuContents();
	
	AddTitle(HateTitleText, F_FancyL, TA_Left);

	// xPatch: Changed font to be easier to read (was F_FancyS)
	ctl = AddWrappedTextItem(Msg2, MsgHeight, F_Bold, TA_Left);
	ctl.SetTextColor(MsgColor);

	ItemFont = F_FancyL;
	ItemAlign = TA_Left;
	StartChoice	= AddChoice(StartText,	"", ItemFont, ItemAlign);
	BackChoice  = AddChoice(BackText,   "", ItemFont, ItemAlign, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Resume playing game
///////////////////////////////////////////////////////////////////////////////
function ResumeGame()
	{
	HideMenu();
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
			switch (C)
				{
				case BackChoice:					
					if (MyMenuStart != None)
						// Roll back the difficulty level and send them back.
						GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyNumberPath@"0");
					GoBack();
					break;
				case StartChoice:
						/*
						// Normal game start
						if(!ShellRootWindow(Root).bFixSave)
						{
							// Start the enhanced game, they know about the keys
							if(ShellRootWindow(Root).bVerified
								&& ShellRootWindow(Root).bVerifiedPicked)
								GetGameSingle().StartGame(true);
							else if (!PlatformIsSteamDeck()) // Normal game, tell them about the keys
								GotoMenu(class'MenuImageKeys');
                            else
                                GotoMenu(class'MenuImageKeys_SteamDeck');
						}
						else // Just return back to the game you were dealing with
							// But save the difficulty and the game first
						{
							ResumeGameSaveDifficulty();
						}
						*/
					// Otherwise, send them back without changing the difficulty.
					GoBack();
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
	MenuWidth  = 600
	MenuHeight = 450

	HateTitleText = "They Hate Me"
	StartText = "I can take it!"
	BackText = "I'm scared!"

	Msg[0] = "You have selected a challenging difficulty level.\\n"
	Msg[1] = "\\n"
	Msg[2] = "Anyone in the game that has a weapon will now hate you and "
	Msg[3] = "attack on sight! Cops will not arrest you anymore, they'll just try to kill "
    Msg[4] = "you and even RWS employees will be after you.\\n"
	Msg[5] = "It's a much higher difficulty than the other settings and drastically "
    Msg[6] = "changes the dynamics of interaction in the game--be ready for some pain!\\n"	
	
	MsgColor=(R=245,G=245,B=245,A=245)
	MsgHeight=230
	}
