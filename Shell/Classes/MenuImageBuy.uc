///////////////////////////////////////////////////////////////////////////////
// MenuImageBuy.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The Buy menu.
//
///////////////////////////////////////////////////////////////////////////////
class MenuImageBuy extends MenuImage;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string strExitText;
var localized string strBuyText;
var localized string strBuyLink;

var ShellMenuChoice BuyChoice;
var ShellMenuChoice	ExitChoice;

var transient int	SongHandle;

var name BuyImageName[3];
var int BuyNum;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();

	BuyNum = 0;
	TextureImageName = BuyImageName[BuyNum];

	SongHandle = GetGameSingle().PlayMusicExt("endmusic.ogg", 0.1);

	ItemAlign  = TA_Center;
	BuyChoice  = AddChoice(strBuyText,	"", ItemFont, ItemAlign, false);
	ExitChoice = AddChoice(strExitText,	"", ItemFont, ItemAlign, false);
	}

function AfterCreate()
{
	BuyChoice.HideWindow();
	ExitChoice.HideWindow();
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			switch (C)
				{
				case BuyChoice:
					GetPlayerOwner().ConsoleCommand("start" @ strBuyLink);
					// Intentional fall through to exit game.
				case ExitChoice:
					if (SongHandle != 0)
						{
						GetGameSingle().StopMusicExt(SongHandle, 0.1);
						SongHandle = 0;
						}
					ShellRootWindow(Root).ExitApp();
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Called when user clicks on the image
///////////////////////////////////////////////////////////////////////////////
function ImageClick(float X, float Y)
{
	local Texture tex;

	if (BuyNum < 2)
	{
		BuyNum++;
		ImageArea.T = Texture(DynamicLoadObject(String(BuyImageName[BuyNum]), class'Texture'));
	}
	if (BuyNum == 2)
	{
		BuyChoice.ShowWindow();
		ExitChoice.ShowWindow();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	BuyImageName[0]="buyscreen.STP-buynow1"
	BuyImageName[1]="buyscreen.STP-buynow2"
	BuyImageName[2]="buyscreen.STP-buynow3"

	strBuyText = "MORE INFO"
	strExitText = "EXIT"
	strBuyLink = "http://www.gopostal.com/Postal2DemoBuy/"

	aregButtons[0]=(X=490,Y=150,W=150,H=30)
	aregButtons[1]=(X=490,Y=190,W=150,H=30)
	}
