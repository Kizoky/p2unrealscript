class UMenuMapListCW extends UMenuDialogClientWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var UMenuMapListExclude Exclude;
var UMenuMapListInclude Include;

var UMenuMapListFrameCW FrameExclude;
var UMenuMapListFrameCW FrameInclude;

var localized string ExcludeCaption;
var localized string ExcludeHelp;
var localized string IncludeCaption;
var localized string IncludeHelp;

var string MoveLeftText;
var string MoveRightText;

var MenuWrappedTextControl		helparea;

const BUTTON_WIDTH  = 30;
const BUTTON_HEIGHT = 20;
const BUTTON_SPACEY = 4;
const BUTTON_SPACEX = 10;

const LIST_LABEL_HEIGHT = 18;

var bool bChangingDefault;

function Created()
{
	Super.Created();

	bNoClientBorder = true;
	
	BotmatchParent = UMenuBotmatchClientWindow(OwnerWindow);

	FrameExclude = UMenuMapListFrameCW(CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));
	FrameInclude = UMenuMapListFrameCW(CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));

	Exclude = UMenuMapListExclude(CreateWindow(class'UMenuMapListExclude', 0, 0, 100, 100));
	FrameExclude.Frame.SetFrame(Exclude);
	Include = UMenuMapListInclude(CreateWindow(class'UMenuMapListInclude', 0, 0, 100, 100));
	FrameInclude.Frame.SetFrame(Include);

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;
	
	LoadMapList();
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

//	MoveOneR.SetFont(F_SmallBold);
//	MoveOneL.SetFont(F_SmallBold);
}

function Paint(Canvas C, float X, float Y)
{
	local float W, H, TextY;

	Super.Paint(C, X, Y);

	// Draw labels over list boxes
	C.Font = Root.Fonts[F_SmallBold];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.DrawColor.A = 255;
	C.StrLen(ExcludeCaption, W, H);
	ClipText(C, (WinWidth/2 - W)/2, 2, ExcludeCaption, True);
	C.StrLen(IncludeCaption, W, H);
	ClipText(C, WinWidth/2 + (WinWidth/2 - W)/2, 2, IncludeCaption, True);

	// Draw arrows between lists
	TextY = (WinHeight - LIST_LABEL_HEIGHT - (BUTTON_HEIGHT * 2 + BUTTON_SPACEY)) / 2 + LIST_LABEL_HEIGHT;
	C.StrLen(MoveRightText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveRightText, true);
	TextY += BUTTON_HEIGHT + BUTTON_SPACEY;
	C.StrLen(MoveLeftText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveLeftText, true);
}

function Resized()
{
	local float ListWidth;

	Super.Resized();

	ListWidth = WinWidth/2 - (BUTTON_WIDTH + BUTTON_SPACEX)/2;
	FrameExclude.WinTop = LIST_LABEL_HEIGHT;
	FrameExclude.WinLeft = 0;
	FrameExclude.SetSize(ListWidth, WinHeight-LIST_LABEL_HEIGHT);
	FrameInclude.WinTop = LIST_LABEL_HEIGHT;
	FrameInclude.WinLeft = WinWidth - ListWidth;
	FrameInclude.SetSize(ListWidth, WinHeight-LIST_LABEL_HEIGHT);
}

function LoadMapList()
{
	local string FirstMap, NextMap, TestMap, MapName;
	local int i, IncludeCount;
	local UMenuMapList L;
	local class<MapList> MapListClass;
	local string GameCode;

	GameCode = class<MpGameInfo>(BotmatchParent.GameClass).Default.MapNameGameCode;

	Exclude.Items.Clear();
	FirstMap = class'FPSGame.FPSGameInfo'.static.GetGameMap(GameCode, "", 0);
	NextMap = FirstMap;
	while (!(FirstMap ~= TestMap))
	{
		// Add the map.
		L = UMenuMapList(Exclude.Items.Append(class'UMenuMapList'));
		L.MapName = NextMap;
		L.DisplayName = class'MultiBase.MpGameInfo'.static.CleanMapName(NextMap);

		NextMap = class'FPSGame.FPSGameInfo'.static.GetGameMap(GameCode, NextMap, 1);
		TestMap = NextMap;
	}

	// Now load the current maplist into Include, and remove them from Exclude.
	Include.Items.Clear();
	IncludeCount = ArrayCount(MapListClass.Default.Maps);
	MapListClass = class<MapList>(DynamicLoadObject(BotmatchParent.GameClass.Default.MapListType, class'class'));
	for(i=0;i<IncludeCount;i++)
	{
		MapName = MapListClass.Default.Maps[i];
		if(MapName == "")
			break;

		L = UMenuMapList(Exclude.Items).FindMap(MapName);

		if(L != None)
		{
			L.Remove();
			Include.Items.AppendItem(L);
		}
		else
			Log("Unknown map in Map List: "$MapName);
	}

	Exclude.Sort();

	// Start with the first item selected (this indirectly sets the current map, too)
	if (Include.Items.Next != None)
		Include.SetSelectedItem(UMenuMapList(Include.Items.Next));
	else if (Exclude.Items.Next != None)
		Exclude.SetSelectedItem(UMenuMapList(Exclude.Items.Next));
}

function SetMap(string MapName)
{
	UTMenuStartMatchCW(ParentWindow).SetMap(MapName);
}

function SaveConfigs()
{
	local int i, IncludeCount;
	local UMenuMapList L;
	local class<MapList> MapListClass;

	Super.SaveConfigs();

	L = UMenuMapList(Include.Items.Next);

	MapListClass = class<MapList>(DynamicLoadObject(BotmatchParent.GameClass.Default.MapListType, class'class'));

	IncludeCount = ArrayCount(MapListClass.Default.Maps);

	for(i=0;i<IncludeCount;i++)
	{
		if(L == None)
			MapListClass.Default.Maps[i] = "";
		else
		{
			MapListClass.Default.Maps[i] = L.MapName;
			L = UMenuMapList(L.Next);
		}
	}

	MapListClass.static.StaticSaveConfig();
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_MouseMove:
		if(helparea != None)
			helparea.SetText(C.HelpText);
		break;
	case DE_MouseLeave:
		if(helparea != None)
			helparea.SetText("");
		break;
	case DE_Click:
		switch(C)
		{
		case Exclude:
			SetMap(UMenuMapList(Exclude.SelectedItem).MapName);
			Include.ClearSelectedItem();
			break;
		case Include:
			SetMap(UMenuMapList(Include.SelectedItem).MapName);
			Exclude.ClearSelectedItem();
			break;
		}
		break;
	}
}

defaultproperties
{
	MoveLeftText="<--"
	MoveRightText="-->"
	ExcludeCaption="Available Maps"
	ExcludeHelp="Maps in this list will NOT be played.  Drag maps to the right list if you want to play them."
	IncludeCaption="Maps To Play"
	IncludeHelp="Maps in this list will be played.  Drag maps to the left list to remove them.  Drag maps up or down to change the order."
}