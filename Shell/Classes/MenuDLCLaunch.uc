///////////////////////////////////////////////////////////////////////////////
// MenuDLCLaunch
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Menu for launching DLC items.
///////////////////////////////////////////////////////////////////////////////
class MenuDLCLaunch extends ShellMenuCW;

var int AppID;			// AppID of this DLC

var ShellMenuChoice LaunchAndCreateShortcutChoice;		// Launch DLC and create direct shortcut on desktop.
var localized string LaunchAndCreateShortcutText;
var localized string LaunchAndCreateShortcutHelp;

var localized string LaunchFailedTitle;
var localized string LaunchFailedMessage;

var localized string TitleText;

var ShellMenuChoice	LaunchOnlyChoice;					// Launch DLC only, no shortcut.

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	TitleFont = F_FancyL;
	TitleAlign = TA_Center;
	AddTitle(TitleText, TitleFont, TitleAlign);

	ItemFont = F_FancyL;
	ItemAlign = TA_Center;
	LaunchAndCreateShortcutChoice = AddChoice(LaunchAndCreateShortcutText, LaunchAndCreateShortcutHelp, ItemFont, ItemAlign);
	LaunchOnlyChoice = AddChoice(YesText, "", ItemFont, ItemAlign);
	BackChoice       = AddChoice(NoText,    "",			ItemFont, ItemAlign, true);
}

///////////////////////////////////////////////////////////////////////////////
// Display performance warning.
// 01/25/03 JMI Started.
///////////////////////////////////////////////////////////////////////////////
function LaunchFailed()
{
	MessageBox(LaunchFailedTitle, LaunchFailedMessage, MB_OK, MR_OK, MR_OK);
}

///////////////////////////////////////////////////////////////////////////////
// Attempts to launch DLC
///////////////////////////////////////////////////////////////////////////////
function LaunchDLC(bool bCreateShortcut)
{
	local bool bResult;
	
	bResult = GetPlayerOwner().Player.InteractionMaster.LaunchDLC(AppID, bCreateShortcut);
	
	// If result is true, nothing else needs to be done. The game will exit and the DLC will launch.
	// If result is false, display an error message.
	if (!bResult)
		LaunchFailed();
}

///////////////////////////////////////////////////////////////////////////////
// Callback for when control has changed
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local int i;
	local P2GameInfoSingle usegame;
	
	Super.Notify(C, E);
	
	switch (E)
	{
		case DE_Click:
			switch (C)
			{
				case LaunchAndCreateShortcutChoice:
					LaunchDLC(true);
					break;
				case LaunchOnlyChoice:
					LaunchDLC(false);
					break;
				case BackChoice:
					GoBack();
					break;
			}
			break;
	}
}

defaultproperties
{
	LaunchAndCreateShortcutText="Yes + Create Shortcut"
	LaunchAndCreateShortcutHelp="Creates a shortcut on the desktop to play this content directly."	
	LaunchFailedTitle="Launch Failed"
	LaunchFailedMessage="Error launching content. Verify your installation and try again."
	TitleText="Exit POSTAL 2 and launch this content?"
	MenuWidth	= 800
	MenuHeight	= 200
}
