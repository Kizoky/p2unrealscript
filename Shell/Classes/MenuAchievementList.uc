///////////////////////////////////////////////////////////////////////////////
// MenuAchievementList
// Copyright 2013 Running With Scissors, Inc.  All Rights Reserved.
//
// Achievement menu in-game
// Placeholder for Steam achievements
//
///////////////////////////////////////////////////////////////////////////////
class MenuAchievementList extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

const ACH_TEX_SIZE = 128;
const ICON_GRID_X = 4;
//const ICON_GRID_Y = 18;
var int ICON_GRID_Y;
const GRID_SCROLL_AMT = 30;
var int IconRowsDisplayed;
var int IconRowsLeftover;

var localized string AchTitleText, PrevText, AchScrollHelp;

var ShellMenuChoice	 NextChoice;
var ShellMenuChoice  PrevChoice;

//const ACH_MAX	    		 	= 69;
var int ACH_MAX;
//var ShellMenuChoice				AchChoice[ACH_MAX];
var array<ShellBitmapAchievementIcon>	AchIcon;
//var localized array<string>			AchText;
//var localized string			AchHelp[ACH_MAX];

var config int AchIndex;	// Index of first achievement item
var int AchIndexMax; // Max achievements
// GetPlayerOwner()

var Color LockedColor;
var Texture GenericLockedTex;
var bool bUseGenericLockedTex;
var UWindowWindow IconContainer;

var int ScrollWindowPos;
var int IconSpacingX;
var int IconSpacingY;

// Init bitmaps
function InitIcons()
{
	local int i,j,k;
	local int ImageTopEdge, ImageLeftEdge, DefaultLeftEdge;
	local int UsableWidth, UsableHeight;
	local string CurrentRes;
	local int ScreenHeight, ScreenWidth;	
	//local int IconSpacingX, IconSpacingY;
	local int Leftover;
	
	// Init Achievement Icon list
	ACH_MAX = P2AchievementManager(GetPlayerOwner().GetEntryLevel().GetAchievementManager()).NumAchievements();
	AchIcon.Length = ACH_MAX;
	ICON_GRID_Y = ACH_MAX/4;
	if (ICON_GRID_Y * 4 < ACH_MAX)
		ICON_GRID_Y++;
		
	// Squish window to fit on lower resolutions
	CurrentRes = GetPlayerOwner().ConsoleCommand("GETCURRENTRES");
	ScreenHeight = int(Right(CurrentRes, Len(CurrentRes) - InStr(CurrentRes, "x") - 1));
	ScreenWidth = int(Left(CurrentRes, InStr(CurrentRes, "x")));
	if (ScreenHeight <= 480)
		MenuHeight = 380;		
	else if (ScreenHeight <= 768)
		MenuHeight = 550;
	else if (ScreenHeight <= 800)
		MenuHeight = 700;
	else
		MenuHeight = Default.MenuHeight;	
		
	if (ScreenWidth < 800)
		MenuWidth = 600;
	else
		MenuWidth = Default.MenuWidth;
	
	ImageLeftEdge = BorderLeft;
	ImageTopEdge = BorderTop + TitleHeight + TitleSpacingY;
	
	UsableWidth = MenuWidth - BorderLeft - BorderRight;
	// Leave room for the Next, Back, and Help items.
	UsableHeight = MenuHeight - BorderTop - TitleHeight - TitleSpacingY - BorderBottom - 1*ItemHeight;
	
	// Figure out how many rows of icons we can display
	IconRowsDisplayed = UsableHeight / ACH_TEX_SIZE;	
	IconRowsLeftover = UsableHeight - (IconRowsDisplayed * ACH_TEX_SIZE);
	if (IconRowsLeftover > 0)
		IconRowsDisplayed--;
	//log("total rows"@IconRowsDisplayed@"leftover"@IconRowsLeftover);
	
	IconContainer = CreateWindow(
		class'UWindowWindow',
		ImageLeftEdge,
		ImageTopEdge,
		UsableWidth,
		UsableHeight);
		
	ImageLeftEdge = 0;
	ImageTopEdge = 0;
	UsableHeight = ACH_TEX_SIZE * (ICON_GRID_Y + ItemSpacingY);
	
	// Determine icon spacing.
	IconSpacingX = (UsableWidth - ICON_GRID_X * ACH_TEX_SIZE) / (ICON_GRID_X - 1);
	IconSpacingY = (UsableHeight - ICON_GRID_Y * ACH_TEX_SIZE) / (ICON_GRID_Y - 1);
	
	// Make spacing even.
	if (IconSpacingX > IconSpacingY)
	{
		Leftover = ICON_GRID_X * (IconSpacingX - IconSpacingY);
		IconSpacingX = IconSpacingY;
		ImageLeftEdge += Leftover/2;
		UsableWidth -= Leftover/2;
	}
	if (IconSpacingY > IconSpacingX)
	{
		Leftover = ICON_GRID_Y * (IconSpacingY - IconSpacingX);
		IconSpacingY = IconSpacingX;
		ImageTopEdge += Leftover/2;
		UsableHeight -= Leftover/2;
	}
	
	DefaultLeftEdge = ImageLeftEdge;
	
	// Draw achievement icons.
	for (i=0; i<ICON_GRID_Y; i++)
	{
		for (j=0; j<ICON_GRID_X; j++)
		{
			if (k < ACH_MAX)
			{
				AchIcon[k] = ShellBitmapAchievementIcon(IconContainer.CreateWindow(
					class'ShellBitmapAchievementIcon',  
					ImageLeftEdge, 
					ImageTopEdge, 
					ACH_TEX_SIZE, 
					ACH_TEX_SIZE ) );
				//AchIcon[k].MyMenu = self;
				AchIcon[k].bStretch = true;	// This value can be overridden by the extender.
				AchIcon[k].bAlpha   = false;	// This value can be overridden by the extender.
				AchIcon[k].bFit	   = true;	// This value can be overridden by the extender.
				AchIcon[k].bCenter  = false;	// This value can be overridden by the extender.
				AchIcon[k].T = GenericLockedTex;
				AchIcon[k].R.X = 0;
				AchIcon[k].R.Y = 0;
				AchIcon[k].R.W = AchIcon[k].T.USize;
				AchIcon[k].R.H = AchIcon[k].T.VSize;
				//AchIcon[k].SendToBack();	// Make sure this is behind the buttons.
				//AchIcon[k].bAlwaysBehind = true;
				AchIcon[k].MyMenu = Self;
				k++;
			}
			ImageLeftEdge += ACH_TEX_SIZE + IconSpacingX;
		}
		ImageLeftEdge = DefaultLeftEdge;
		ImageTopEdge += ACH_TEX_SIZE + IconSpacingY;
	}
}

// Force ShellMenuCW to add the "Next", "Back" and Help items at the bottom of the achievement grid.
function float GetNextItemPosY()
	{
	if (MenuItems.Length == 0)
		return MenuHeight - 3*ItemHeight;
	return MenuItems[MenuItems.Length-1].PosY + MenuItems[MenuItems.Length-1].Height;
	}

// RebuildMenu
// We're going to make this a single menu that "flips" back and forth between
// the various achievements. So, make a dealie here that resets the menu and
// rebuilds it
function RebuildMenu()
{
	local int i, j, AchNum;
	local int PageNo, PageMax;
	local PlayerController P;
	local P2AchievementManager AM;
	local string AchName, Description, UnlockProgress;
	
	MenuItems.Length = 0;	// Wipe all existing menu items and rebuild them.
	P = GetPlayerOwner();	// Get player controller so we can get achievement manager etc
	AM = P2AchievementManager(P.GetEntryLevel().GetAchievementManager());
	AchIndexMax = AM.NumAchievements();

	ItemFont	= F_FancyM;
	ItemAlign = TA_Center;

	AchNum = AchIndex;
	//log("Begin drawing menu AchNum"@AchNum,'Debug');
	
	PageMax = AchIndexMax / ACH_MAX;
	if (ACH_MAX * PageMax < AchIndexMax)
		PageMax++;
	PageNo = (AchNum / ACH_MAX) + 1;
	
	//AchTitleText = Default.AchTitleText @ "(" $ PageNo $ "/" $ PageMax $ ")";

	AddTitle(AchTitleText, TitleFont, TitleAlign);
	AddTextItem(AchScrollHelp,"",0);

	for(i=0; i<ACH_MAX; i++)
	{
		AchName = "";
		while (AchName == "" && AchNum <= AchIndexMax)
		{
			AchName = AM.GetAchievementName(AchNum);
			if (AchName != "")
			{
				Description = AM.GetAchievementDescription(AchNum);
				UnlockProgress = AM.GetAchievementProgress(AchNum);
				//AchChoice[i]		= AddChoice(UnlockProgress@AchName,	Description, ItemFont, ItemAlign);
				AchIcon[i].HelpText = AchName $ "\\n" $ Description;
				if (UnlockProgress != "")
				{
					//AchChoice[i].SetTextColor(LockedColor);
					if (bUseGenericLockedTex)
						AchIcon[i].T = GenericLockedTex;
					else
						AchIcon[i].T = AM.GetAchievementIcon(AchNum);
				}
				else
				{
					AchIcon[i].T = AM.GetAchievementIcon(AchNum);
				}

				//AchChoice[i].bActive = False;
				//log("Drew achievement"@AchName@"at index"@AchNum,'Debug');
			}
			//else
				//log("Skipping unused achievement at index"@AchNum,'Debug');
			AchNum++;
		}
		// Blank out unused boxes
		if (AchNum > AchIndexMax)
		{
			AchIcon[i].T = None;
			AchIcon[i].HelpText = "";
		}
	}

	//NextChoice			= AddChoice(NextText, "", ItemFont, TitleAlign);
	//PrevChoice			= AddChoice(PrevText, "", ItemFont, TitleAlign);
	BackChoice			= AddChoice(BackText, "", ItemFont, TitleAlign, true);
}

///////////////////////////////////////////////////////////////////////////////
// Show or unshow the help.  Override to block or change.
// This version just accepts a text string instead of a control.
///////////////////////////////////////////////////////////////////////////////
function ShowHelp2(bool bShow, string Help)
	{
	local int iLines;
	if (HintItem != none)
		{
		// 12/19/02 JMI Changed to clear the hint always.
		if (bShow && Help != "")
			{
			HintItem.SetText(Help);
			HintItem.ShowWindow();
			}
		else
			{
			HintItem.SetText("");
			HintItem.HideWindow();
			}
		}
	}

// MouseEnter/MouseLeave events from achievement icons.	
function IconMouseEnter(ShellBitmapAchievementIcon Icon)
{
	ShowHelp2(True, Icon.HelpText);
}
function IconMouseLeave(ShellBitmapAchievementIcon Icon)
{
	ShowHelp2(False, "");
}

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	
	// Initialize AchIndex
	AchIndex = 0;
	InitIcons();
	RebuildMenu();
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
			if (C != None)
				switch (C)
					{
					case NextChoice:
						if (AchIndex + ACH_Max < AchIndexMax)
						{
							AchIndex += ACH_MAX;
							SaveConfig();
						}
						GotoMenu(class'MenuAchievementList');
						break;
					case PrevChoice:
						if (AchIndex <= 0)
							GotoMenu(class'MenuGame');	// Can't use "GoBack" because it might just pull up the Achievement List again.
						else
						{
							AchIndex = AchIndex - ACH_MAX;
							if (AchIndex <= 0)
								AchIndex = 0;
							SaveConfig();
							GotoMenu(class'MenuAchievementList');
						}
						break;
					case BackChoice:
						GotoMenu(class'MenuGame');
						break;
					}
			break;
		}
	}

// Scroll achievement icons up or down
function ScrollBy(int Value)
{	
	local int i;
	
	if (ScrollWindowPos <= -1 * (ICON_GRID_Y - IconRowsDisplayed) * (ACH_TEX_SIZE + IconSpacingY) + IconRowsLeftover
		&& Value < 0)
		return;
	if (ScrollWindowPos >= 0
		&& Value > 0)
		return;
	
	//for (i = 0; i < MenuItems.Length; i++)
	//	MenuItems[i].Window.WinTop += Value;
		
	for (i = 0; i < ACH_MAX; i++)	
		AchIcon[i].WinTop += Value;
	ScrollWindowPos += Value;
		
	//HintItem.WinTop += Value;
	
	//WinTop += Value;
}

///////////////////////////////////////////////////////////////////////////////
// Hit escape at any time to exit the achievement list entirely.
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				GotoMenu(class'MenuGame');
				return true;
			//case IK_UP:
			case IK_MOUSEWHEELUP:
				ScrollBy(GRID_SCROLL_AMT);
				return true;
			//case IK_DOWN:
			case IK_MOUSEWHEELDOWN:
				ScrollBy(-GRID_SCROLL_AMT);
				return true;
			}
		}
	
	if (Action == IST_Press
		|| Action == IST_Hold)
		{
			switch (Key)
			{
			case IK_UP:
				ScrollBy(GRID_SCROLL_AMT);
				return true;
			case IK_DOWN:
				ScrollBy(-GRID_SCROLL_AMT);
				return true;
			}
		}
		
	// Scroll achievement list
	// FIXME IST_Hold does not work for joysticks
	if (Action == IST_Press || Action == IST_Hold)
	{
		if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_UP_BUTTON) == "1")
		{
			ScrollBy(4*GRID_SCROLL_AMT);
			return true;
		}
		if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_DOWN_BUTTON) == "1")
		{
			ScrollBy(-4*GRID_SCROLL_AMT);
			return true;
		}
	}
		
	Super.KeyEvent(Key, Action, Delta);
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Joystick support.
///////////////////////////////////////////////////////////////////////////////
function execMenuUpButton()
{
	ScrollBy(GRID_SCROLL_AMT);
}
function execMenuDownButton()
{
	ScrollBy(-GRID_SCROLL_AMT);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ItemHeight	 = 25
	MenuWidth	= 700
	MenuHeight = 800
	HintLines	= 3
	BackText = "Back"
	PrevText = "Prev"
					
	AchTitleText = "Achievements"
	AchScrollHelp="Scroll with mouse wheel, arrow keys, or Menu Up/Down. ESC/Back to exit."
	
	LockedColor=(R=64,G=64,B=64,A=255)
	
	GenericLockedTex=Texture'AchievementIcons.Locked-512.Generic-Locked-512'
	bUseGenericLockedTex=False
