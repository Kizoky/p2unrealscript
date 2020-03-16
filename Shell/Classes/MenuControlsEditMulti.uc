///////////////////////////////////////////////////////////////////////////////
// MenuControlsEditMisc.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
//	02/01/03 JMI	Moved all control definitions into the base class.  The idea
//					is to be able to know all the mappable controls from all the
//					menus.  GetControls() still returns the controls this menu
//					will edit.
//
// 12/17/02 NPF Renamed from Other to Misc
//
///////////////////////////////////////////////////////////////////////////////
class MenuControlsEditMulti extends MenuControlsEdit;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string ControlsTitleText;

var ShellMenuChoice		AdvSayChoice;
var localized string	AdvSayText;
var localized string	AdvSayHelp;

var ShellMenuChoice		AdvTeamSayChoice;
var localized string	AdvTeamSayText;
var localized string	AdvTeamSayHelp;

// Only here to bump the line down a notch.
var ShellMenuChoice		EmptyChoice;
var localized string	EmptyText;
var localized string	EmptyHelp;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	AddTitle(ControlsTitleText, TitleFont, TitleAlign);

	ItemFont	= F_FancyS;

	AdvSayChoice			= AddChoice(AdvSayText,			AdvSayHelp,    ItemFont, ItemAlign);
	AdvTeamSayChoice		= AddChoice(AdvTeamSayText,		AdvTeamSayHelp,ItemFont, ItemAlign);
	// Only here to bump the line down a notch! Ugly! Sorry!
	// It lines up with the top of the Input 1, Input 2, Input 3 without moving down a notch.
	EmptyChoice				= AddChoice(EmptyText,			EmptyHelp,	   ItemFont, ItemAlign);

	Super.CreateMenuContents();
	}

///////////////////////////////////////////////////////////////////////////////
// Get the controls to be edited.  Tells the base class what to edit.
///////////////////////////////////////////////////////////////////////////////

//ErikFOV Change: for localization
/*function array<Control> GetControls()
{
	return aMultiControls;
}*/

function GetControls(out array<Control> Controls, out array<String> Labels)
{
	Controls = aMultiControls;
	Labels = aMultiControlsLabel;
	return;
}
//end


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
					case AdvSayChoice:
						GoToMenu(class'MenuControlsEditAdvSay');
						break;
					case AdvTeamSayChoice:
						GoToMenu(class'MenuControlsEditAdvTeamSay');
						break;
					}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Clean up
///////////////////////////////////////////////////////////////////////////////
function OnCleanUp()
{
	if (Console(GetPlayerOwner().Player.Console) != None)
		Console(GetPlayerOwner().Player.Console).UpdateKeyBinding();
	Super.OnCleanUp();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ControlsTitleText = "Multiplayer Communication"

	AdvSayText	= "Preset Say Messages..."
	AdvSayHelp	= "Set keys for preset Say. To set, open console, type SetSay 1 blahblah. Change number for each SetSay 1-8."

	AdvTeamSayText	= "Preset TeamSay Messages..."
	AdvTeamSayHelp	= "Set keys for preset TeamSay. To set, open console, type SetTeamSay 1 blahblah. Change number for each SetTeamSay 1-8."

	EmptyText=""
	EmptyHelp=""
	}											
