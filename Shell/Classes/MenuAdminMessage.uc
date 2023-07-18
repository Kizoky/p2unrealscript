///////////////////////////////////////////////////////////////////////////////
// MenuAdminMessage.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The Admin Message Menu to say a message in a big font in the center of the screen.
//
// History:
//	10/20/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuAdminMessage extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var UWindowEditControl	MessageControl;

var ShellMenuChoice		SayChoice;
var localized string	SayText;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super.CreateMenuContents();
	
	TitleAlign = TA_Center;
	ItemAlign = TA_Center;
	AddTitle(AdminMessageText, TitleFont, TitleAlign);

	MessageControl		= AddEditBox("",			"", ItemFont);
	MessageControl.EditBoxWidth += 160;
	MessageControl.WinLeft = (WinWidth - MessageControl.WinWidth + MessageControl.EditBoxWidth - 30)/2;
	SayChoice			= AddChoice(SayText,		"", ItemFont, ItemAlign);

	BackChoice			= AddChoice(BackText,		"", ItemFont, ItemAlign, true);
}

function AfterCreate()
{
	Super.AfterCreate();

	MessageControl.BringToFront();
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
	{
		case DE_EnterPressed:
			switch (C)
			{
				case MessageControl:
					AdminSay();
					break;
			}
			break;
		case DE_Click:
			if (C != None)
				switch (C)
				{
					case SayChoice:
						AdminSay();
						break;
					case BackChoice:
						GoBack();
						break;
				}
			break;
	}
}

function AdminSay()
{
	if(MessageControl.GetValue() != "")
	{
		GetPlayerOwner().ConsoleCommand("admin" @ "say" @ "#" $ MessageControl.GetValue());
		HideMenu();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuWidth	= 400
	SayText		= "Say"
}
