///////////////////////////////////////////////////////////////////////////////
// MenuControlsEditAdvSay.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Advanced Say controls, pre-set say options for MP
//
///////////////////////////////////////////////////////////////////////////////
class MenuControlsEditAdvTeamSay extends MenuControlsEdit;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string ControlsTitleText;

var localized string	Msg[6];

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

	AddTitle(ControlsTitleText, TitleFont, TitleAlign);

	ItemFont	= F_FancyS;

	TextItem = AddWrappedTextItem(Msg2, 145, ItemFont, TitleAlign);

	Super.CreateMenuContents();
	}

///////////////////////////////////////////////////////////////////////////////
// Get the controls to be edited.  Tells the base class what to edit.
///////////////////////////////////////////////////////////////////////////////

//ErikFOV Change: for localization
/*function array<Control> GetControls()
{
	return aTeamSayControls;
}*/

function GetControls(out array<Control> Controls, out array<String> Labels)
{
	Controls = aTeamSayControls;
	Labels = aTeamSayControlsLabel;
	return;
}
//end

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
	ControlsTitleText = "Pre-set Multiplayer TeamSay Controls"

	Msg[ 0] = "To set what is said, first open the console (Press the Tidle key(default)).\\n"
    Msg[ 1] = "Next, type SetTeamSay, then the number, then your message.\\n"
    Msg[ 2] = "For example: SetTeamSay 2 Meet in our base!\\n"
    Msg[ 3] = "That makes your second pre-set TeamSay: Meet in our base!\\n"
    Msg[ 4] = "Open the console now and try it! (Or do it during a game.)\\n"
    Msg[ 5] = "(The grid below sets the keys not the actual message.)\\n"

	bBlockConsole=false
	}											
