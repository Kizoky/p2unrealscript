class WorkshopMapListCW extends UMenuMapListCW;

var localized string DefaultText;

const CUSTOM_MAP_PREFACE_WORKSHOP = "ws-";
const CUSTOM_MAP_PREFACE = "cus-";

function Created()
{
	Super(UMenuDialogClientWindow).Created();

	bNoClientBorder = true;
	
	BotmatchParent = UMenuBotmatchClientWindow(OwnerWindow);

	FrameExclude = UMenuMapListFrameCW(CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));
	//FrameInclude = UMenuMapListFrameCW(CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));

	Exclude = UMenuMapListExclude(CreateWindow(class'UMenuMapListExclude', 0, 0, 100, 100));
	FrameExclude.Frame.SetFrame(Exclude);
	//Include = UMenuMapListInclude(CreateWindow(class'UMenuMapListInclude', 0, 0, 100, 100));
	//FrameInclude.Frame.SetFrame(Include);

	Exclude.Register(Self);
	//Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	//Include.SetHelpText(IncludeHelp);

	//Include.DoubleClickList = Exclude;
	//Exclude.DoubleClickList = Include;
	
	LoadMapList();
	
	Exclude.SetSelected(0,0);
}

function Paint(Canvas C, float X, float Y)
{
	local float W, H, TextY;

	Super(UMenuDialogClientWindow).Paint(C, X, Y);

	// Draw labels over list boxes
	C.Font = Root.Fonts[F_SmallBold];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.DrawColor.A = 255;
	C.StrLen(ExcludeCaption, W, H);
	ClipText(C, (WinWidth/*/2*/ - W)/2, 2, ExcludeCaption, True);
	//C.StrLen(IncludeCaption, W, H);
	//ClipText(C, WinWidth/2 + (WinWidth/2 - W)/2, 2, IncludeCaption, True);

	/*
	// Draw arrows between lists
	TextY = (WinHeight - LIST_LABEL_HEIGHT - (BUTTON_HEIGHT * 2 + BUTTON_SPACEY)) / 2 + LIST_LABEL_HEIGHT;
	C.StrLen(MoveRightText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveRightText, true);
	TextY += BUTTON_HEIGHT + BUTTON_SPACEY;
	C.StrLen(MoveLeftText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveLeftText, true);
	*/
}

function Resized()
{
	local float ListWidth;

	Super(UMenuDialogClientWindow).Resized();

	//ListWidth = WinWidth/*/2*/ - (BUTTON_WIDTH + BUTTON_SPACEX)/2;
	ListWidth = WinWidth;
	FrameExclude.WinTop = LIST_LABEL_HEIGHT;
	FrameExclude.WinLeft = 0;
	FrameExclude.SetSize(ListWidth, WinHeight-LIST_LABEL_HEIGHT);
	//FrameInclude.WinTop = LIST_LABEL_HEIGHT;
	//FrameInclude.WinLeft = WinWidth - ListWidth;
	//FrameInclude.SetSize(ListWidth, WinHeight-LIST_LABEL_HEIGHT);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function LoadMapList()
	{
	local string FirstMap, NextMap, TestMap, MapName;
	local int i, IncludeCount;
	local UMenuMapList Item;
	local LevelSummary L;

	// Seed "default" map
	Item = UMenuMapList(Exclude.Items.Append(class'UMenuMapList'));
	Item.MapName = DefaultText;
	Item.DisplayName = DefaultText;
	
	FirstMap = GetPlayerOwner().GetMapName("", "", 0);
	NextMap = FirstMap;
	while (!(FirstMap ~= TestMap))
	{
		//log(self$" next map "$nextmap);
		if( Left(nextmap, 4) ~= CUSTOM_MAP_PREFACE 
			|| Left(nextmap, 3) ~= CUSTOM_MAP_PREFACE_WORKSHOP
			)
		{
			// Ensure the map is 'valid' and has all requisites (PL, etc) before adding to the list, otherwise player will get stuck falling in startup.fuk
			MapName = NextMap;
			i = InStr(Caps(MapName), ".FUK");
			if(i != -1)
				MapName = Left(MapName, i);
			L = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary'));
			if (L != None)
			{
				Item = UMenuMapList(Exclude.Items.Append(class'UMenuMapList'));
				Item.MapName = NextMap;
				if(Right(NextMap, 4) ~= ".fuk")
					Item.DisplayName = Left(NextMap, Len(NextMap) - 4);
				else
					Item.DisplayName = NextMap;
			}
		}
		NextMap = GetPlayerOwner().GetMapName("", NextMap, 1);
		TestMap = NextMap;
	}
	
	Exclude.Sort();
	}

function Notify(UWindowDialogControl C, byte E)
{
	Super(UMenuDialogClientWindow).Notify(C, E);

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
		}
		break;
	}
}

// Skip saving map info
function SaveConfigs()
{
	Super(UMenuDialogClientWindow).SaveConfigs();
}

defaultproperties
{
	ExcludeCaption="Available Maps"
	ExcludeHelp="Select the map you wish to play. Pick (default) to play the game mode's default map/game intro instead."
	DefaultText="(default)"
}	