///////////////////////////////////////////////////////////////////////////////
// MenuAdminGameType.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The Admin menu for switching game types.
//
// History:
//	10/17/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuAdminGameType extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string	GameTypeTitle;

var UWindowComboControl	GameTypeCombo;
var localized string	GameTypeText;
var localized string	GameTypeHelp;

var UWindowComboControl	MapCombo;
var localized string	MapText;
var localized string	MapHelp;

var ShellMenuChoice		ApplyChoice;
var localized string	ApplyText;
var localized string	ApplyHelp;

var bool				bInitialized;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super.CreateMenuContents();
	
	AddTitle(GameTypeTitle, TitleFont, TA_Center);

	GameTypeCombo	= AddComboBox(GameTypeText, GameTypeHelp,	ItemFont);
	MapCombo		= AddComboBox(MapText,		MapHelp,		ItemFont);
	ApplyChoice		= AddChoice(ApplyText,		ApplyHelp,		ItemFont, TA_Center);

	BackChoice		= AddChoice(BackText,		"", ItemFont, TA_Center, true);

	LoadValues();
	bInitialized = true;
}

function LoadValues()
{
	GameTypeCombo.SetButtons(true);
	GameTypeCombo.EditBoxWidth += 80;
	MapCombo.EditBoxWidth += 80;
	LoadGameTypes();
	LoadMaps(GameTypeCombo.GetValue2());
}

function LoadGameTypes()
{
	local class<GameInfo>	TempClass;
	local String 			NextGame;
	local int				i;
	local String			CurrentGame;
	local bool				bHasCurrentGame;

	CurrentGame = GetPlayerOwner().GameReplicationInfo.GameName;

	// reinitialize list if needed
	GameTypeCombo.Clear();
	
	// Compile a list of all gametypes.
	NextGame = GetPlayerOwner().GetNextInt("MultiBase.MpGameInfo", 0); 
	while (NextGame != "")
	{
		TempClass = class<GameInfo>(DynamicLoadObject(NextGame, class'Class'));

		GameTypeCombo.AddItem(TempClass.Default.GameName, NextGame);

		if(CurrentGame ~= TempClass.Default.GameName)
		{
			GameTypeCombo.SetSelectedIndex(i);
			bHasCurrentGame = true;
		}

		NextGame = GetPlayerOwner().GetNextInt("MultiBase.MpGameInfo", ++i);
	}

	if(!bHasCurrentGame)
		GameTypeCombo.SetSelectedIndex(0);
}

function LoadMaps(String GameType)
{
	local class<GameInfo> GameClass;
	local class<MapList> MapListClass;
	local int i;
	local string LevelName, CleanLevelName, CurrentLevel;
	local bool bHasCurrentMap;

	MapCombo.Clear();

	CurrentLevel = ShellRootWindow(Root).ParseLevelName(Root.GetLevel().GetLocalURL());
	CurrentLevel = class'MultiBase.MpGameInfo'.static.CleanMapName(CurrentLevel);

	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
	if (GameClass != None && GameClass.Default.MapListType != "")
	{
        MapListClass = class<MapList>(DynamicLoadObject(GameClass.Default.MapListType, class'Class'));
		if (MapListClass != None)
		{
			for (i=0; i<ArrayCount(MapListClass.Default.Maps) && MapListClass.Default.Maps[i] != ""; i++)
			{
				// Add the map.
				LevelName = MapListClass.Default.Maps[i];
				CleanLevelName = class'MultiBase.MpGameInfo'.static.CleanMapName(LevelName);
				MapCombo.AddItem(CleanLevelName, LevelName);

				if(CurrentLevel ~= CleanLevelName)
				{
					MapCombo.SetSelectedIndex(i);
					bHasCurrentMap = true;
				}
			}
		}
	}

	if(!bHasCurrentMap)
		MapCombo.SetSelectedIndex(0);
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if(!bInitialized)
		return;

	switch(E)
	{
		case DE_Change:
			if (C != None)
				switch (C)
				{
					case GameTypeCombo:
						LoadMaps(GameTypeCombo.GetValue2());
						break;
					case MapCombo:
						break;
				}
		case DE_Click:
			if (C != None)
				switch (C)
				{
					case ApplyChoice:
						GetPlayerOwner().ConsoleCommand("admin" @ "switch" @ MapCombo.GetValue2() $ "?Game=" $ GameTypeCombo.GetValue2());
						break;
					case BackChoice:
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
	MenuWidth	= 450
	GameTypeTitle= "Change Game Types"
	GameTypeText= "Game Type"
	GameTypeHelp= "Select which game type to switch to"
	MapText		= "Map"
	MapHelp		= "Select which map to switch to"
	ApplyText	= "Apply"
	ApplyHelp	= "Switch to the currently selected game type and map"
}
