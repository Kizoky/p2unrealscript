///////////////////////////////////////////////////////////////////////////////
// MenuCustomMap.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
class DebugShellMapListCW extends ShellMapListCW;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function LoadButtonClicked()
	{
	local string MapName, URL;

	if (MapListBox.SelectedItem != None)
		{
		URL = ""$ShellMapListItem(MapListBox.SelectedItem).MapName;

		//log("Goto"@URL);
		ShellRootWindow(Root).GoBack();
		ShellRootWindow(Root).HideMenu();
		P2GameInfoSingle(Root.GetLevel().Game).Goto(URL);
		}
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function LoadMapList()
	{
	local string FirstMap, NextMap, TestMap, MapName;
	local int i, IncludeCount;
	local ShellMapListItem Item;
	
	FirstMap = GetPlayerOwner().GetMapName("", "", 0);
	NextMap = FirstMap;
	while (!(FirstMap ~= TestMap))
		{
		Item = ShellMapListItem(MapListBox.Items.Append(class'ShellMapListItem'));
		Item.MapName = NextMap;
		if(Right(NextMap, 4) ~= ".fuk")
			Item.DisplayName = Left(NextMap, Len(NextMap) - 4);
		else
			Item.DisplayName = NextMap;
		NextMap = GetPlayerOwner().GetMapName("", NextMap, 1);
		TestMap = NextMap;
		}
	
	MapListBox.Sort();
	}
