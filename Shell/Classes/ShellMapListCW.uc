///////////////////////////////////////////////////////////////////////////////
// MenuCustomMap.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ShellMapListCW extends UWindowDialogClientWindow;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

const CUSTOM_MAP_PREFACE	=	"cus";
var ShellMapListBox				MapListBox;
var UWindowSmallCloseButton		CloseButton;
var ShellMapListLoadButton		LoadButton;

var float						ButtonWidth;			// Button width
var float						ButtonHeight;			// Button height
var float						ButtonBorderW;			// Extra space around buttons
var float						ButtonBorderH;			// Extra space around buttons

var float						ButtonAreaHeight;			// Calculated at runtime -- height of button area
var float						ButtonDistFromFrameBottom;	// Calculated at runtime -- distance of buttons from bottom of frame window


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Created()
	{
	local int index;
	
	Super.Created();
	
	ButtonAreaHeight = ButtonHeight + ButtonBorderH * 2;
	ButtonDistFromFrameBottom = ButtonHeight + ((ButtonAreaHeight - ButtonHeight) / 2);

	MapListBox = ShellMapListBox(CreateWindow(class'ShellMapListBox', 0, 0, WinWidth, WinHeight - ButtonAreaHeight, Self));
	LoadMapList();
	
	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', 0, 0, ButtonWidth, ButtonHeight));
	CloseButton.WinHeight = ButtonHeight;
	CloseButton.WinLeft = WinWidth - (ButtonWidth + ButtonBorderW);
	CloseButton.WinTop = WinHeight - ButtonDistFromFrameBottom;

	LoadButton = ShellMapListLoadButton(CreateWindow(class'ShellMapListLoadButton', 0, 0, ButtonWidth, ButtonHeight));
	LoadButton.WinHeight = ButtonHeight;
	LoadButton.WinLeft = WinWidth - (ButtonWidth + ButtonBorderW) * 2;
	LoadButton.WinTop = WinHeight - ButtonDistFromFrameBottom;
	}

function Paint(Canvas C, float X, float Y)
	{
	local Texture T;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, WinHeight - ButtonAreaHeight, WinWidth, ButtonAreaHeight, T);
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function LoadButtonClicked()
	{
	local string MapName, URL;

	if (MapListBox.SelectedItem != None)
		{
		URL = ""$ShellMapListItem(MapListBox.SelectedItem).MapName;

		P2GameInfoSingle(Root.GetLevel().Game).LoadCustomMap(URL);
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
		//log(self$" next map "$nextmap);
		if( Left(nextmap, 3) ~= CUSTOM_MAP_PREFACE )
			{
			Item = ShellMapListItem(MapListBox.Items.Append(class'ShellMapListItem'));
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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Resized()
	{
	MapListBox.WinWidth = WinWidth;
	MapListBox.WinHeight = WinHeight - ButtonAreaHeight;
	
	MapListBox.VertSB.WinLeft = MapListBox.WinWidth-MapListBox.VertSB.WinWidth;
	MapListBox.VertSB.WinHeight=MapListBox.WinHeight;

	CloseButton.WinLeft = WinWidth - (ButtonWidth + ButtonBorderW);
	CloseButton.WinTop = WinHeight - ButtonDistFromFrameBottom;

	LoadButton.WinLeft = WinWidth - (ButtonWidth + ButtonBorderW) * 2;
	LoadButton.WinTop = WinHeight - ButtonDistFromFrameBottom;
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ButtonWidth = 68
	ButtonHeight = 28
	ButtonBorderW = 6
	ButtonBorderH = 6
	}