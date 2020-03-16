///////////////////////////////////////////////////////////////////////////////
// MenuPerformanceWizard.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The Configuration Wizard.
//
// History:
//	02/23/03 JMI	Changed strMessage string to astrMessage array allowing us
//					to specify more than a single line- and length-limited string
//					in defaultproperties.
//
//	02/11/03 JMI	Changed to simply display a message and invoke a console
//					command that will re-evaluate the user's hardware.  This
//					is followed by a message indicating a restart is required
//					and an explicit quit.
//
//	01/19/03 JMI	Now has an Apply Changes choice.  No changes are made
//					until/unless the this new option is chosen.  When this is
//					chosen, a confirmation menu is displayed which returns to
//					this one.
//
//	01/13/03 JMI	Added strHelp parameter to AddChoice() allowing us to pass
//					in many help strings that had been created but were not 
//					being used for standard menu choices.  Added generic 
//					RestoreHelp for menus sporting a Restore option.
//
//	01/12/03 JMI	Changed bDontAsk to bAsk.
//
//	01/12/03 JMI	Added intermediate menu introducing Wizard and Advanced
//					performance menus so took out link to Advanced menu here.
//
//	12/18/02 JMI	Per Mike's suggestion, reversed the order of the menus.
//					The old Performance menu became the Advanced menu and the
//					Performance Wizard became the Performance menu.
//					Also changed to using n categories of configurations (as
//					opposed to having a single list of configurations).  Each
//					category has a combo listing the configs.
//
//	12/01/02 JMI	Started.
//
///////////////////////////////////////////////////////////////////////////////
// This class defines a menu that allows the user to issue a command to re-
// evaluate their hardware and set the performance settings accordingly.
///////////////////////////////////////////////////////////////////////////////
class MenuPerformanceWizard extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var ShellMenuChoice		YesChoice;

var localized string    TitleText;

var localized string	Msg[14];

var localized string    OptionsUpdatedTitle;
var localized string    OptionsUpdatedText;
var UWindowMessageBox	OptionsUpdatedBox;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local int i;
	local array<string> Msg2;
	local string str;
	local ShellWrappedTextControl TextItem;

	// Dynamic arrays don't localize properly, so copy static array to dynamic array
	Msg2.insert(0, ArrayCount(Msg));
	for (i = 0; i < Msg2.length; i++)
		Msg2[i] = Msg[i];

	Super.CreateMenuContents();
	
	AddTitle(TitleText, F_FancyM, TA_Left);

	ItemAlign = TA_Left;
	TextItem = AddWrappedTextItem(Msg2, 340, F_FancyS, ItemAlign);
	TextItem.SetTextColor(HintColor);

	YesChoice	= AddChoice(YesText,	"", F_FancyM, ItemAlign);
	BackChoice  = AddChoice(NoText,		"", F_FancyM, ItemAlign, true);
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
				case YesChoice:
					GetPlayerOwner().ConsoleCommand("ResetFirstRun");
					OptionsUpdatedBox = MessageBox(OptionsUpdatedTitle, OptionsUpdatedText, MB_OK, MR_OK, MR_OK);
					break;
				case BackChoice:
					GoBack();
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Callback for when message box is done
///////////////////////////////////////////////////////////////////////////////
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	// There's currently only one of these but just in case another message ends
	// up here or one just hangs out from a bug or notification, let's check.
	switch (W)
	{
	case OptionsUpdatedBox:
		GoBack();
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	MenuWidth  = 540
	MenuHeight = 480
	TitleHeight = 30
	TitleSpacingY = 4
	
	TitleText	= "Performance Wizard";

	Msg[ 0] = "The Performance Wizard evaluates your computer's processor, ";
    Msg[ 1] = "memory, video and audio capabilities to determine settings for ";
    Msg[ 2] = "performance-related options.\\n"; 
	Msg[ 3] = "\\n";
    Msg[ 4] = "The Performance Wizard was automatically used the first time ";
    Msg[ 5] = "you started this game.  You do not have to use it again unless ";
    Msg[ 6] = "you have added or removed hardware from your computer, or ";
    Msg[ 7] = "you want to restore your performance options to the settings ";
    Msg[ 8] = "recommended by the Performance Wizard.\\n";
	Msg[ 9] = "\\n";
    Msg[10] = "If you choose to use the Performance Wizard the new settings will ";
    Msg[11] = "only take effect if you exit the game and then start it again.\\n";
	Msg[12] = "\\n";
    Msg[13] = "Would you like to run the Performance Wizard now?";
				
	OptionsUpdatedTitle = "Restart Required";
	OptionsUpdatedText  = "You must exit the game for the new settings to take effect.";
	}
