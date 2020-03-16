class DLCTabCW extends UTMenuStartMatchCW;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized, InGameChanged;

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
var localized string DefaultMapTitleText;
var localized string DefaultMapDescriptionText;

// news
var UWindowDynamicTextArea NewsWindow;
var localized string NewsText;
var color NewsColor;

///////////////////////////////////////////////////////////////////////////////
// Get the single player info.
// 02/10/03 JMI Started to macroify this which we seem to be doing commonly
//				lately. 
///////////////////////////////////////////////////////////////////////////////
function P2GameInfoSingle GetGameSingle()
	{
	return P2GameInfoSingle(Root.GetLevel().Game);
	}

function Created()
{
	Super(UMenuPageWindow).Created();
	
	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		warn(self @ "Error: Missing UMenuBotmatchClientWindow parent.");

	// Summary Window
	SummaryWindow = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	SummaryWindow.bAutoScrollbar = true;
	SummaryWindow.bScrollOnResize = false;
	SummaryWindow.bTopCentric = true;

	// Screenshot Window
	ScreenshotWindow = UMenuScreenshotCW(CreateWindow(class'DLCScreenshotCW', 0, 0, 100, 100));	
	
	// Game Summary Window
	NewsWindow = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	NewsWindow.bAutoScrollbar = true;
	NewsWindow.bScrollOnResize = false;
	//NewsWindow.bTopCentric = true;
	NewsWindow.AddText(NewsText);
	NewsWindow.SetFont(F_SmallBold);
	//NewsWindow.bVCenter = true;
	//NewsWindow.bHCenter = true;
	//NewsWindow.TextColor = NewsColor;
}

function AfterCreate()
{
	Super(UMenuPageWindow).AfterCreate();

	// Map List Window (must create after GameCombo has been created and filled in)
	MapWindow = UMenuMapListCW(CreateWindow(class'DLCListCW', BodyLeft, ControlOffset, 100, MapWindowHeight, BotmatchParent));
	MapWindow.HelpArea = helparea;
	
	Initialized = true;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int lines, SummarySpace;
	local float XL, YL;
	local Font oldFont;
	
	Super(UMenuPageWindow).BeforePaint(C, X, Y);
	
	ControlOffset = Default.ControlOffset;
	
	/*
	oldFont = C.Font;
	C.Font = root.Fonts[GameCombo.EditBox.Font];
	C.StrLen(GameTypeText, XL, YL);
	GameCombo.SetSize(XL + 15 + GameCombo.EditBoxWidth, ControlHeight);
	GameCombo.WinLeft = BodyLeft + (BodyWidth - GameCombo.WinWidth) / 2;
	GameCombo.SetTextColor(TC);
	C.Font = oldFont;
	*/

	oldFont = C.Font;
	C.Font = root.Fonts[SummaryWindow.Font];
	C.StrLen("Try", XL, YL);
	NewsWindow.WinLeft = BodyLeft + 3;
	NewsWindow.SetSize(BodyWidth - 6, YL*2);
	ControlOffset = NewsWindow.WinHeight + 3;

	MapWindowHeight = (BodyHeight - (ControlOffset - BodyTop)) * 0.40;
	ScreenshotSize = ((BodyHeight - (ControlOffset - BodyTop)) * 0.60) - 6;
	
	MapWindow.SetSize(BodyWidth - 6, MapWindowHeight);
	MapWindow.WinLeft = BodyLeft + 3;
	MapWindow.WinTop = ControlOffset;

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

	/*
	oldFont = C.Font;
	C.Font = root.Fonts[GameSummaryWindow.Font];
	C.StrLen("Try", XL, YL);
	SummarySpace = ScreenshotSize - YL;
	lines = 3;
	GameSummaryWindow.SetSize(BodyWidth, (lines-1)*YL);
	GameSummaryWindow.WinLeft = BodyLeft;
	GameSummaryWindow.WinTop = GameCombo.WinTop + YL;
	C.Font = oldFont;
	*/
}

function Paint(Canvas C, float X, float Y)
{
	local float XL, YL;
	local string str;

	Super(UMenuPageWindow).Paint(C, X, Y);

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
	Super(UMenuPageWindow).Notify(C, E);
/*
	switch(E)
	{
	case DE_Change:
		switch(C)
		{		
		case GameCombo:
			GameChanged();
			break;
		case EnhancedCheck:
			WorkshopStartGameCW(BotmatchParent).bEnhanced = EnhancedCheck.bChecked;
			break;
		case DifficultyCombo:
			DiffChanged();
			break;
		}
		break;
	case DE_Click:
		switch(C)
		{
		}
		break;
	}
*/
}

function DiffChanged()
{
	// stub
}

function GameChanged()
{
	// stub
}

function MapChanged()
{
	// stub
}

function int FillInGameCombo()
{
	// stub
	return 0;
}

function SetDLC(LevelSummary L)
{
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
	NewsText="Welcome to the new POSTAL 2 Complete DLC Microtransaction $tore! Here, you can give us all your money for worthless in-game items. Pay up, you cheapskate!"
	PageHeaderText=""
	Newscolor=(R=0,G=0,B=0)
}
