///////////////////////////////////////////////////////////////////////////////
// MenuEula.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The EULA menu.
//
//	History:
//	02/23/03 JMI	Changed strMessage string to Msg array allowing us
//					to specify more than a single line- and length-limited string
//					in defaultproperties.
//
//	01/30/03 JMI	Added some room for longer licensee names.  Changed title
//					and choices to centered.
//
//	01/26/03 JMI	Re-extended this time from MenuMessage.  Untested but what
//					could go wrong? :)
//
//	01/13/03 JMI	Added strHelp parameter to AddChoice() allowing us to pass
//					in many help strings that had been created but were not 
//					being used for standard menu choices.  Added generic 
//					RestoreHelp for menus sporting a Restore option.
//
//	06/09/02 MJR	Switched to UWindowWrappedTextArea to avoid ugly
//					blue scrollbar.  Moved string from here to root
//					window so it could be more easily accessed from outside
//					the shell package.
//
//	06/08/02 JMI	Added EULA text from lawyers and changed font to F_Bold
//					to make it more legible.
//
//	06/02/02 JMI	Added sizing optionally defined by each menu.  Started for
//					License Agreement.  Changed to use UWindowDynamicTextArea
//					and added sample text.  Also added Accept and Exit options
//					and ignoring of ChoiceBack.
//
//	06/01/02 JMI	Started from MenuStart.
//
///////////////////////////////////////////////////////////////////////////////
class MenuEula extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var ShellMenuChoice		AcceptChoice;
var ShellMenuChoice		ExitChoice;

var array<string> Msg;	// Don't localize this legal text


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local string str;
	local int    iEntry;
	local ShellWrappedTextControl TextItem;

	str = P2GameInfo(Root.GetLevel().Game).GetIssuedTo();
	Msg[iEntry++] = "This demo of the game \"Postal 2\" (the \"Game\") has been loaned to "$str;
// Don't include this unless user actually signed an NDA
//	Msg[iEntry++] = " subject to the terms of an executed Non-Disclosure Agreement and";
	Msg[iEntry++] = " solely for evaluation and/or testing purposes.  The Game is a trade secret of Running With ";
	Msg[iEntry++] = "Scissors (\"RWS\") and has been encoded with a unique serial number issued solely to "$str$".   Viewing and/or use of ";
	Msg[iEntry++] = "the Game should be limited to \"need to know\" employees who are subject to similar confidentiality obligations.  The ";
	Msg[iEntry++] = "Game can be copied to only one hard drive at a time and must be deleted immediately afterwards.  No additional copies of ";
	Msg[iEntry++] = "this Game may be made.   RWS will pursue any and all legal remedies available to RWS if this copy of the Game is leaked to ";
	Msg[iEntry++] = "the internet or made public by any other means.  Click ACCEPT if "$str$" accepts these terms or EXIT if "$str$" does not.";

	Super.CreateMenuContents();
	
	AddTitle(P2GameInfo(Root.GetLevel().Game).GetIssuedTo()$" Version", F_FancyL, TA_Center);

	ItemAlign = TA_Left;
	TextItem = AddWrappedTextItem(Msg, 300, F_FancyS, ItemAlign);
	TextItem.SetTextColor(HintColor);

	AcceptChoice = AddChoice("Accept",	"", F_FancyM, ItemAlign);
	ExitChoice   = AddChoice("Exit",	"", F_FancyM, ItemAlign);
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
				case AcceptChoice:
					GoToMenu(class'MenuMain');
					break;
				case ExitChoice:
					ShellRootWindow(root).ExitApp();
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
	MenuWidth  = 640
	MenuHeight = 450
	}
