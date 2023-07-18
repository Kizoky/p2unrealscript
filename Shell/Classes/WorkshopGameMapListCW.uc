class WorkshopGameMapListCW extends ShellMapListCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var UMenuMapListBox MapListBox;
var UMenuMapListFrameCW MapListFrame;
var localized string MapListHelp;

const CUSTOM_MAP_PREFACE_WORKSHOP = "ws-";
const CUSTOM_MAP_PREFACE = "cus-";

function Created()
{
	Super.Created();

	MapListFrame = UMenuMapListFrameCW(CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));
	MapListBox = UMenuMapListBox(CreateWindow(class'UMenuMapListBox', 0, 0, 100, 100));
	MapListFrame.Frame.SetFrame(MapListBox);
	MapListBox.Register(Self);
	MapListBox.SetHelpText(MapListHelp);

	LoadMapList();
}

function Resized()
{
	Super.Resized();

	MapListFrame.WinTop = 0;
	MapListFrame.WinLeft = 0;
	MapListFrame.SetSize(WinWidth, WinHeight);

	MapListBox.SetSelected(0,0);
}

function LoadMapList()
{
	local string FirstMap, NextMap, TestMap, MapName;
	local UMenuMapList Item;

	FirstMap = GetPlayerOwner().GetMapName("", "", 0);
	NextMap = FirstMap;
	while (!(FirstMap ~= TestMap))
	{
//		log(self$" next map "$nextmap);
		if( Left(NextMap, 4) ~= CUSTOM_MAP_PREFACE 
			|| Left(NextMap, 3) ~= CUSTOM_MAP_PREFACE_WORKSHOP)
		{
			Item = UMenuMapList(MapListBox.Items.Append(class'UMenuMapList'));
			Item.MapName = NextMap;
			if(Right(NextMap, 4) ~= ".fuk")
				Item.DisplayName = Left(NextMap, Len(NextMap) - 4);
			else
				Item.DisplayName = NextMap;
		}
		NextMap = GetPlayerOwner().GetMapName("", NextMap, 1);
		TestMap = NextMap;
	}
	MapListBox.Sort();
}

function SetMap(string MapName)
{
	WorkshopGameMapListPage(ParentWindow).SetMap(MapName);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_MouseMove:
		if(WorkshopGameMapListPage(OwnerWindow).helparea != None)
			WorkshopGameMapListPage(OwnerWindow).helparea.SetText(C.HelpText);
		break;
	case DE_MouseLeave:
		if(WorkshopGameMapListPage(OwnerWindow).helparea != None)
			WorkshopGameMapListPage(OwnerWindow).helparea.SetText("");
		break;
	case DE_Click:
		switch(C)
		{
		case MapListBox:
			SetMap(UMenuMapList(MapListBox.SelectedItem).MapName);
			break;
		}
		break;
	}
}

defaultproperties
{
	MapListHelp="Select the map you wish to play."
}