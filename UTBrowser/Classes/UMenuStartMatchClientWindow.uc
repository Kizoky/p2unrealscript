class UMenuStartMatchClientWindow extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized, InGameChanged;

// Game Type
var UWindowComboControl GameCombo;
var localized string GameTypeText;
var localized string GameTypeHelp;
var string Games[256];
var int MaxGames;

// Map List
var UMenuMapListCW MapWindow;
var float MapWindowHeight;
var string MapTitle;

// Map screenshot
var UMenuScreenshotCW ScreenshotWindow;
var float ScreenshotSize;

// Map summary
var UWindowDynamicTextArea SummaryWindow;
var localized string MapDescriptionMissingText;
var localized string MapTitleMissingText;

function Created()
{
	local int Selection;

	Super.Created();

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log(self @ "Error: Missing UMenuBotmatchClientWindow parent.");

	// Game Type
	GameCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	GameCombo.SetButtons(True);
	GameCombo.SetText(GameTypeText);
	GameCombo.SetHelpText(GameTypeHelp);
	GameCombo.SetFont(ControlFont);
	GameCombo.SetEditable(False);
	ControlOffset += (ControlHeight * 1.5);

	// Summary Window
	SummaryWindow = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	SummaryWindow.bAutoScrollbar = true;
	SummaryWindow.bScrollOnResize = false;
	SummaryWindow.bTopCentric = true;

	// Screenshot Window
	ScreenshotWindow = UMenuScreenshotCW(CreateWindow(class'UMenuScreenshotCW', 0, 0, 100, 100));

	Selection = FillInGameCombo();
	BotmatchParent.GameType = Games[Selection];
	BotmatchParent.GameClass = Class<GameInfo>(DynamicLoadObject(BotmatchParent.GameType, class'Class'));
	GameCombo.SetSelectedIndex(Selection);
	GameCombo.EditBoxWidth = 170;
}

function AfterCreate()
{
	Super.AfterCreate();

	// Map List Window (must create after GameCombo has been created and filled in)
	MapWindow = UMenuMapListCW(CreateWindow(class'UMenuMapListCW', BodyLeft, ControlOffset, 100, MapWindowHeight, BotmatchParent));
	MapWindow.HelpArea = helparea;

	Initialized = true;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int lines, SummarySpace;
	local float XL, YL;
	local Font oldFont;
	
	Super.BeforePaint(C, X, Y);

	MapWindowHeight = (BodyHeight - (ControlOffset - BodyTop)) * 0.40;
	ScreenshotSize = ((BodyHeight - (ControlOffset - BodyTop)) * 0.60) - 6;
	
	oldFont = C.Font;
	C.Font = root.Fonts[GameCombo.EditBox.Font];
	C.StrLen(GameTypeText, XL, YL);
	GameCombo.SetSize(XL + 15 + GameCombo.EditBoxWidth, ControlHeight);
	GameCombo.WinLeft = BodyLeft + (BodyWidth - GameCombo.WinWidth) / 2;
	GameCombo.SetTextColor(TC);
	C.Font = oldFont;

	MapWindow.SetSize(BodyWidth - 6, MapWindowHeight);
	MapWindow.WinLeft = BodyLeft + 3;

	ScreenshotWindow.SetSize(ScreenshotSize, ScreenshotSize);
	ScreenshotWindow.WinLeft = BodyLeft + BodyWidth - ScreenshotSize - 3;
	ScreenshotWindow.WinTop = ControlOffset + MapWindowHeight + 3;

	oldFont = C.Font;
	C.Font = root.Fonts[SummaryWindow.Font];
	C.StrLen("Try", XL, YL);
	SummarySpace = ScreenshotSize - YL;
	for(lines = 0; lines * YL < SummarySpace; lines++);
	SummaryWindow.SetSize(BodyWidth - (ScreenshotSize + 6), (lines-1)*YL);
	SummaryWindow.WinLeft = BodyLeft;
	SummaryWindow.WinTop = ScreenshotWindow.WinTop + YL;
	C.Font = oldFont;
}

function Paint(Canvas C, float X, float Y)
{
	local float XL, YL;
	local string str;

	Super.Paint(C, X, Y);

	C.Font = Root.Fonts[F_SmallBold];
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	// Draw map title
	str = MapTitle;
	C.StrLen(str, XL, YL);
	ClipText(C, BodyLeft + (SummaryWindow.WinWidth - XL)/2, ScreenshotWindow.WinTop, str, True);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case GameCombo:
			GameChanged();
			break;
		}
		break;
	case DE_Click:
		switch(C)
		{
		}
		break;
	}
}

function GameChanged()
{
	local int CurrentGame, i;

	if (!Initialized || InGameChanged)
		return;

	CurrentGame = GameCombo.GetSelectedIndex();
	if(BotmatchParent.GameType == Games[CurrentGame])
		return;

	MapWindow.SaveConfigs();
	Initialized = false;
	InGameChanged = True;

	BotmatchParent.GameType = Games[CurrentGame];
	if(BotmatchParent.GameClass != None)
		BotmatchParent.GameClass.static.StaticSaveConfig();

	BotmatchParent.GameClass = Class<GameInfo>(DynamicLoadObject(BotmatchParent.GameType, class'Class'));
	if ( BotmatchParent.GameClass == None )
	{
		MaxGames--;
		if ( MaxGames > CurrentGame )
		{
			for ( i=CurrentGame; i<MaxGames; i++ )
				Games[i] = Games[i+1];
		}
		else if ( CurrentGame > 0 )
			CurrentGame--;
		GameCombo.SetSelectedIndex(CurrentGame);
		InGameChanged = False;
		return;
	}

	Initialized = true;
	BotmatchParent.GameChanged();
	InGameChanged = False;

	MapWindow.LoadMapList();
}

function MapChanged()
{
	if (!Initialized)
		return;
}

function int FillInGameCombo()
{
	local int i, Selection;
	local class<GameInfo> TempClass;
	local string NextGame, NextCategory;
	local string TempGames[256];
	local bool bFoundSavedGameClass, bAlreadyHave;

	// Compile a list of all gametypes.
	i=0;
	TempClass = class'MpGameInfo';
	GetPlayerOwner().GetNextIntDesc("MpGameInfo", 0, NextGame, NextCategory);
	while (NextGame != "")
	{
		TempGames[i] = NextGame;
		i++;
		if(i == 256)
		{
			Log("More than 256 gameinfos listed in int files");
			break;
		}
		GetPlayerOwner().GetNextIntDesc("MpGameInfo", i, NextGame, NextCategory);
	}

	// Fill the control.
	for (i=0; i<256; i++)
	{
		if (TempGames[i] != "")
		{
			Games[MaxGames] = TempGames[i];
			if ( !bFoundSavedGameClass && (Games[MaxGames] ~= BotmatchParent.GameType) )
			{
				bFoundSavedGameClass = true;
				Selection = MaxGames;
			}
			TempClass = Class<GameInfo>(DynamicLoadObject(Games[MaxGames], class'Class'));
			GameCombo.AddItem(TempClass.Default.GameName);
			MaxGames++;
		}
	}

	return Selection;
}

function SetMap(string MapName)
{
	local int i;
	local LevelSummary L;

	i = InStr(Caps(MapName), ".FUK");
	if(i != -1)
		MapName = Left(MapName, i);

	L = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary'));

	SummaryWindow.Clear();
	MapTitle = "";
	if(L != None)
	{
		ScreenshotWindow.SetMap(L);

		if(L.Description != "")
			SummaryWindow.AddText(L.Description);
		else
			SummaryWindow.AddText(MapDescriptionMissingText);

		if (L.Title != "")
			MapTitle = L.Title;
		else
			MapTitle = MapTitleMissingText;
	}
}

defaultproperties
{
	PageHeaderText="Choose the type of game and a list of maps you want to play"
	GameTypeText="Game Type"
	GameTypeHelp="Pick the type of game you want to play."
	MapDescriptionMissingText="No description."
	MapTitleMissingText="Untitled"
}
