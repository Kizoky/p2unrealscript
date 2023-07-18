class WorkshopGameMapListPage extends UBrowserPageWindow;

// Map List
var WorkshopGameMapListCW MapWindow;
var float MapWindowWidth;

// Map screenshot
var WorkshopScreenshotCW ScreenshotWindow;
var float ScreenshotSize;

// Load Button
var WorkshopGameMapListLoadButton LoadButton;
var float ButtonWidth, ButtonHeight;

function Created()
{
	Super.Created();

	MapWindow = WorkshopGameMapListCW(CreateWindow(class'WorkshopGameMapListCW', 0, 0, 0, 0));
	ScreenshotWindow = WorkshopScreenshotCW(CreateWindow(class'WorkshopScreenshotCW', 0, 0, 0, 0));
	LoadButton = WorkshopGameMapListLoadButton(CreateControl(class'WorkshopGameMapListLoadButton', 0, 0, 0, 0));
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	ScreenshotSize = ((BodyHeight - (ControlOffset - BodyTop)) * 0.60) - 6;
	MapWindowWidth = BodyWidth - ScreenshotSize;

	MapWindow.SetSize(MapWindowWidth, BodyHeight);
	MapWindow.WinLeft = BodyLeft + ScreenshotWindow.WinWidth;
	MapWindow.WinTop = ControlOffset;

	ScreenshotWindow.SetSize(ScreenshotSize, ScreenshotSize);
	ScreenshotWindow.WinLeft = BodyLeft;
	ScreenshotWindow.WinTop = ControlOffset;

	LoadButton.SetSize(ButtonWidth, ButtonHeight);
	LoadButton.WinLeft = BodyLeft + (ScreenshotSize - ButtonWidth) / 2;
	LoadButton.WinTop = ControlOffset + ScreenshotSize + 24;
}

function SetMap(string MapName)
{
	local int i;
	local LevelSummary L;

//	log("###MapName:"$MapName);
	i = InStr(Caps(MapName), ".FUK");
	if(i != -1)
		MapName = Left(MapName, i);

//	log("###MapName2:"$MapName);
	L = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary'));

//	log("###L:"$L);
	if(L != None)
		ScreenshotWindow.SetMap(L);
}

function LoadButtonClicked()
{
	local string MapName, URL;

	if (MapWindow.MapListBox.SelectedItem != None)
	{
		URL = ""$UMenuMapList(MapWindow.MapListBox.SelectedItem).MapName;
		P2GameInfoSingle(Root.GetLevel().Game).SendPlayerTo(GetPlayerOwner(), URL);
	}
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	if (Msg==WM_KeyDown)
	{
		if (Key==236)
			MapWindow.MapListBox.VertSB.Scroll(-1);
		else if (Key==237)
			MapWindow.MapListBox.VertSB.Scroll(1);
		return;
	}

	Super.WindowEvent(MSg,C,X,Y,Key);
}

defaultproperties
{
	PageHeaderText="Select the map you wish to play."
	ButtonWidth = 68
	ButtonHeight = 28
	ControlWidthPercent=1.0
	BodyBorderLeftRight=10
}
