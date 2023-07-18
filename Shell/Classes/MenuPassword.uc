///////////////////////////////////////////////////////////////////////////////
// MenuPassword.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The password menu for joining a server.
//
// History:
//	08/12/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuPassword extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var string URL;
var localized string PWTitleText;

var UWindowEditControl PW;
var localized string PWText;
var localized string PWHelp;

var ShellMenuChoice Join;

var bool bDontCancel;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();

	TitleAlign = TA_Center;
	ItemAlign = TA_Left;
	AddTitle(PWTitleText, TitleFont, TitleAlign);
	PW = AddEditBox(PWText, PWHelp, ItemFont);
	Join = AddChoice(JoinText, "", ItemFont, ItemAlign);

	BackChoice = AddChoice(BackText, "", ItemFont, ItemAlign, true);

	GetPlayerOwner().ClearProgressMessages();
	}

function AfterCreate()
{
	Super.AfterCreate();

	PW.BringToFront();
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local class<UMenuStartGameWindow> StartGameClass;

	Super.Notify(C, E);

	switch(E)
		{
		case DE_EnterPressed:
			switch (C)
				{
				case PW:
					Connect();
					break;
				}
			break;
		case DE_Click:
			switch (C)
				{
				case Join:
					Connect();
					break;
				case BackChoice:
					GoBack();
					break;
				}
			break;
		}
	}

function Connect()
{
	local int i;
	local string P;

	P = PW.GetValue();
/*	if(P == "")
	{
		PW.BringToFront();
		return;
	}
	i = InStr( P, " " );
	if( i != -1 )
		P = Left(P, i);

	GetPlayerOwner().ClearProgressMessages();
	bDontCancel = true;

	if(P == "")
		GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
	else
	{
*/		GetPlayerOwner().ClientTravel(URL$"?password="$P, TRAVEL_Absolute, false);
		Root.ConsoleClose();
		Super.GoBack();
		P2RootWindow(Root).HideMenu();
//	}
}

function GoBack()
{
	local string CurrentLevel, GamePath;

	if(!bDontCancel)
	{
		//Log(Self $ " Closing and Cancelling");
		GetPlayerOwner().ConsoleCommand("MenuCancel");
	}

	CurrentLevel = ShellRootWindow(Root).ParseLevelName(Root.GetLevel().GetLocalURL());
	if(Right(CurrentLevel, 4) ~= ".fuk")
		CurrentLevel = Left(CurrentLevel, Len(CurrentLevel) - 4);

	if(GetGameSingle() != None && Caps(CurrentLevel) != Caps(ShellRootWindow(Root).GetStartupMap()))	// SINGLEPLAYER
		GetGameSingle().QuitGame();
	else																	// MULTIPLAYER
		{
		if(CurrentLevel ~= "Entry")
			{
			GetPlayerOwner().ConsoleCommand("disconnect");
			P2RootWindow(Root).HideMenu();
			// RWS FIXME: Read the game type value from ini
			GamePath = "GameTypes.GameSinglePlayer";
			GetPlayerOwner().ClientTravel(ShellRootWindow(Root).GetStartupMap()$".fuk?Mutator=?Workshop=0?Game=" $ GamePath, TRAVEL_Absolute, false);
			}
		}
	P2RootWindow(Root).EnableMenu();
	Super.GoBack();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	MenuWidth = 600
	ItemBorder = 110

	PWTitleText = "Game Password Required"
	PWText = "Password"
	PWHelp = "This game requires a password to join."
	}

