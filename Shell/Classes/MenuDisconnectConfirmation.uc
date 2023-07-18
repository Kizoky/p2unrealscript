///////////////////////////////////////////////////////////////////////////////
// MenuDisconnectConfirmation.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The confirmation menu for disconnecting from a multiplayer game.
//
// History:
//	07/23/03 CRK	Started.
//
///////////////////////////////////////////////////////////////////////////////
// This class defines a menu that merely displays a confirmation regarding
// quiting or exiting and, if yes is chosen, performs the action.  If no is
// chosen, it executes a GoBack.
//
///////////////////////////////////////////////////////////////////////////////
class MenuDisconnectConfirmation extends ShellMenuCW;

var localized string		LeaveGameVerifyText;
var localized string		EndGameExplainText;
var ShellMenuChoice			YesChoice;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local array<string> tmparray;
	local Color TC;
	local ShellWrappedTextControl VerifyLeaveControl;

	TitleFont = F_FancyL;
	TitleAlign = TA_Center;
	ItemFont = F_FancyL;
	ItemAlign = TA_Center;

	AddTitle(LeaveGameText, TitleFont, TitleAlign);

	if(GetPlayerOwner().Level.NetMode == NM_ListenServer)
	{
		VerifyLeaveControl = AddWrappedTextItem(tmparray, 150, F_Bold, ItemAlign);
		VerifyLeaveControl.Text = EndGameExplainText;
	}
	else
	{
		VerifyLeaveControl = AddWrappedTextItem(tmparray, 70, F_Bold, ItemAlign);
		VerifyLeaveControl.Text = LeaveGameVerifyText;
	}

	TC.R = 155;
	TC.G = 155;
	TC.B = 155;
	TC.A = 255;
	VerifyLeaveControl.SetTextColor(TC);
	VerifyLeaveControl.bShadow = true;

	YesChoice  = AddChoice(YesText,	"", ItemFont, ItemAlign, false);
	BackChoice = AddChoice(NoText,	"", ItemFont, ItemAlign, true);
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
					GoBack();
					break;
				case YesChoice:
					ShellRootWindow(root).QuitCurrentGame();
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
	LeaveGameVerifyText = "Are you sure you you want to leave this game?"
	EndGameExplainText = "You are hosting a game.  Ending this game will affect all players that joined it.\\n\\nAre you sure you want to end this game?"

	MenuWidth	= 620
	MenuHeight	= 350
	ItemBorder = 100

	bBlockConsole = false;
	}
