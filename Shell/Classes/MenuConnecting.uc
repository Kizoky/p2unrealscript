///////////////////////////////////////////////////////////////////////////////
// MenuConnecting.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The window for connecting to a server, can cancel out, too.
//
// History:
//	09/08/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuConnecting extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var string Msg1, Msg2;
var localized string ConnectingText;

var ShellTextControl Message1;
var ShellTextControl Message2;

var ShellMenuChoice CancelChoice;

var string InitialLevel;

var bool bReceivingFile;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super.CreateMenuContents();

	TitleAlign = TA_Center;
	ItemAlign = TA_Center;
	AddTitle(ConnectingText, TitleFont, TitleAlign);
	Message1 = AddTextItem(Msg1, "", F_FancyM);
	Message1.bActive = false;
	Message1.Align = TA_Center;
	Message1.ValueAlign = TA_Center;
	Message2 = AddTextItem(Msg2, "", F_FancyM);
	Message2.bActive = false;
	Message2.Align = TA_Center;
	Message2.ValueAlign = TA_Center;
	CancelChoice = AddChoice(CancelText, "", ItemFont, ItemAlign, true);

	//BackChoice = AddChoice(BackText, "", ItemFont, ItemAlign, true);

	GetPlayerOwner().ClearProgressMessages();
	ShellRootWindow(Root).bLaunchedMultiplayer = true;

	InitialLevel = ShellRootWindow(Root).ParseLevelName(Root.GetLevel().GetLocalURL());
	if(Right(InitialLevel, 4) ~= ".fuk")
		InitialLevel = Left(InitialLevel, Len(InitialLevel) - 4);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	local string CurrentLevel;

	Super.BeforePaint(C, X, Y);

	P2RootWindow(Root).DisableMenu();

	CurrentLevel = ShellRootWindow(Root).ParseLevelName(Root.GetLevel().GetLocalURL());
	if(Right(CurrentLevel, 4) ~= ".fuk")
		CurrentLevel = Left(CurrentLevel, Len(CurrentLevel) - 4);
	
	if(Caps(CurrentLevel) != Caps(InitialLevel))
	{
		if(CurrentLevel ~= "Entry")
			InitialLevel = CurrentLevel;
		else
		{
			Super.GoBack();
			HideMenu();
		}
	}
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
	local ShellMenuChoice choice;
	local int i;
	
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				//Log(Self $ " ESC Pressed, Cancelling");
				GetPlayerOwner().ConsoleCommand("MenuCancel");
			}
		}
	
	return Super.KeyEvent(Key, Action, Delta);
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
		case DE_Click:
			switch (C)
			{
				case CancelChoice:
					//Log(Self $ " Cancel Pressed, Cancelling");
					GetPlayerOwner().ConsoleCommand("MenuCancel");
					GoBack();
					break;
			}
			break;
	}
}

// Take user back to startup level
function GoBack()
{
	local string CurrentLevel, GamePath;

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

function SetStatus(string M1, string M2, bool bDownloading)
{
	local string Server, Map;
	local int i;

	if(bDownloading)
		bReceivingFile = true;

	if(!bReceivingFile || (bDownloading && bReceivingFile))
	{
		Msg1 = M1;
		Msg2 = M2;
		if(bDownloading)	// Receiving a file, keep messages the same
		{
			Message1.SetText(Msg1);
			Message2.SetText(Msg2);
		}
		else				// Connecting to server, separate out the address and map
		{
			Server = Msg2;
			if(InStr(Caps(Server), Caps("postal2://")) != -1)
				Server = Right(Server, Len(Server) - 10);
			Map = Right(Server, Len(Server) - InStr(Server, "/") - 1);
			Map = class'MultiBase.MpGameInfo'.static.CleanMapName(Map);
			Server = Left(Server, InStr(Server, "/"));
			Message1.SetText(Server);
			// if our map name got set to index or entry, just grab shell root's real name of what map we're going to
			if((Map ~= "Index" || Map ~= "Entry") && ShellRootWindow(Root).LoadingTexture != ShellRootWindow(Root).Default.LoadingTexture)
			{
				i = InStr(ShellRootWindow(Root).LoadingTexture, ".");
				Map = Left(ShellRootWindow(Root).LoadingTexture, i);
				Map = class'MultiBase.MpGameInfo'.static.CleanMapName(Map);
			}
			Message2.SetText(Map);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuWidth = 640
	ConnectingText = "Connecting"
	bDoJitter=false
}

