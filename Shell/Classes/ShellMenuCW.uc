///////////////////////////////////////////////////////////////////////////////
// ShellMenuCW.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Client area for menus.
//
///////////////////////////////////////////////////////////////////////////////
//
// Base class for menus.
//
// Each menu overrides CreateMenuContents() to add items to the menu.  The
// menu is basically a dialog window and the items added to it are all dialog
// controls.
//
// Only a small subset of UWindow controls have been modified to conform to
// our "look and feel", although all of them should work.  The only thing
// required to add them is to create an AddXXX() function similar to the
// existing versions, such as AddCheckbox() and AddComboBox().
//
// To conform a control to our look and feel will most likely require some
// changes to the source, although in some cases a control will already be
// calling functions that we already have control over in ShellLookAndFeel.
// Generally, the required steps are:
// (1) don't let it shrink its height to the font height, instead keep
// whatever height was assigned on creation,
// (2) call the appropriate ShellLookAndFeel functions when the mouse enters
// and leaves the control and when the mouse is clicked in the control
// (3) draw the text using the appropriate ShellLookAndFeel function (which
// uses shadows, highlights and so on).
//
// Each menu must supply its own Notify() to handle notifications from it's
// controls.
//
// This class implements a common behavior for the Cancel key (currently
// <ESC>).  When the key is pressed, it looks for a ShellMenuChoice item that
// is set to respond to the Cancel key, and if one is found it automatically
// goes to the previous menu (using the standard GoBack() function).
//
// If a menu needs different behavior for the Cancel key, or any other
// key for that matter, it must supply it's own KeyEvent() to handle key input.
//
///////////////////////////////////////////////////////////////////////////////
class ShellMenuCW extends UWindowDialogClientWindow
	abstract;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() float					MenuWidth;			// Menu width
var() float					MenuHeight;			// Menu height (0 = auto height)

var() float					BorderLeft;			// Unused area on left
var() float					BorderRight;		// Unused area on right
var() float					BorderTop;			// Unused area on top
var() float					BorderBottom;		// Unused area on bottom

var() float					TitleHeight;		// Height of title
var() float					TitleSpacingY;		// Space between title and first item
var() int					TitleFont;
var() TextAlign				TitleAlign;

var() float					ItemBorder;			// How far items are indented from left/right border
var() float					ItemHeight;			// Height of item
var() int					ItemFont;
var() TextAlign				ItemAlign;
var float					ItemMaxWidth;		// Max item width

var() float					ItemSpacingY;		// Space between items

// Common menu items (shared by more than one menu)
var ShellMenuChoice			OptionsChoice;
var localized string		OptionsText;		// Text for "options" choice on menus

var ShellMenuChoice			GameChoice;			// Game options
var localized string		GameOptionsText;
var localized string		GameOptionsHelp;

var ShellMenuChoice			ControlsChoice;		// Game Controls options
var localized string		ControlOptionsText;
var localized string		ControlOptionsHelp;

var ShellMenuChoice			VideoChoice;		// Video Options
var localized string		VideoOptionsText;
var localized string		VideoOptionsHelp;

var ShellMenuChoice			AudioChoice;		// Audio Options
var localized string		AudioOptionsText;
var localized string		AudioOptionsHelp;

var ShellMenuChoice			PerformanceChoice;	// Performance Options
var localized string		PerformanceText;
var localized string		PerformanceHelp;

var ShellMenuChoice			ReticleChoice;		// Reticle Options
var localized string		ReticleText;
var localized string		ReticleHelp;


var ShellMenuChoice			RestoreChoice;
var localized string		RestoreText;		// Text for "restore" choice on menus
var localized string		RestoreHelp;

var localized string		StartText;			// Text for "start" choice on menus

var localized string		NextText;			// Text for "start" choice on menus that continue onwards

var localized string		LoadGameText;		// Text for "load" choice on menus

var ShellMenuChoice			BackChoice;
var localized string		BackText;			// Text for "back" choice on menus

var localized string		YesText;
var localized string		NoText;

var localized string		MultiTitleText;		// Text for multiplayer menu
var localized string		JoinText;			// Text for joining a multiplayer game
var localized string		JoinHelp;
var localized string		OpenText;			// Text for Opening an ip address for an mp game
var localized string		OpenHelp;
var localized string		PlayerSetupText;	// Text for Player Setup Menu
var localized string		PlayerSetupHelp;
var localized string		PlayerChangeText;	// Text for Player Change Menu
var localized string		PlayerChangeHelp;

var localized string		AdminMenuText;		// Text for Admin Menu
var localized string		AdminMessageText;	// Text for Admin Message
var localized string		AdminLoginText;		// Text for logging in as an administrator

var localized string		UpgradeText;		// Text for "Upgrade"
var localized string		LeaveGameText;

var localized string		ErrorText;			// Text for "Error" title on error menus
var localized string		CancelText;			// Text for "Cancel"

var localized string		SlotDefaultText;

var localized string		PerformanceWarningTitle;
var localized string		PerformanceWarningText;

var localized string		OptionUnavailableInDemoHelpText;	// 01/23/03 JMI Generic option not available in demo text.

const c_strDifficultyPath = "Postal2Game.P2GameInfo GameDifficulty";
const c_strDifficultyNumberPath = "Postal2Game.P2GameInfo GameDifficultyNumber";
const LieberPath = "Postal2Game.P2GameInfo bLieberMode";
const HestonPath = "Postal2Game.P2GameInfo bHestonMode";
const TheyHateMePath = "Postal2Game.P2GameInfo bTheyHateMeMode";
const InsaneoPath = "Postal2Game.P2GameInfo bInsaneoMode";
const ExpertPath = "Postal2Game.P2GameInfo bExpertMode";
const LudicrousPath = "Postal2Game.P2GameInfo bLudicrousMode";
const MasochistPath = "Postal2Game.P2GameInfo bMasochistMode";
const VeteranPath = "Postal2Game.P2GameInfo bVeteranMode";
const MeleePath = "Postal2Game.P2GameInfo bMeeleMode";
const HardLieberPath = "Postal2Game.P2GameInfo bHardLieberMode";
const NukeModePath = "Postal2Game.P2GameInfo bNukeMode";
const CustomPath = "Postal2Game.P2GameInfo bCustomMode";
const ContraPath = "Postal2Game.P2GameInfoSingle bContraMode";

const EnhancedPath = "Shell.ShellMenuCW bShowedEnhancedMode";
var globalconfig bool bShowedEnhancedMode;

var globalconfig bool bShowedXPatch;	// xPatch

var UWindowComboControl DifficultyCombo;
var localized string DifficultyText;
var localized string DifficultyHelp;


var ShellWrappedTextControl	HintItem;			// Hint area for items with help text.
var Color					HintColor;
var int						HintLines;
var float					HintExtra;			// Extra area required to support hints.  We track this 
												// to avoid considering it while centering vertically.

var float					fCommonCtlArea;		// 01/15/03 JMI Make control sizes consistent and overridable.
												// 01/22/03 JMI Now represents the area for the control from 0.0 to 1.0.

var Color					SliderValColor;		// Color for text indicating slider values.

// Array of items on this menu
struct MenuItem
	{
	var UWindowWindow		Window;
	var float				PosY;
	var float				Height;
	};
var array<MenuItem>			MenuItems;

var array<string>           astrTextureDetailNames;	// 01/20/03 JMI Added these for detail names for stored texture settings.
													// This array -MUST- -NOT- be localized.
var int					    c_iTextureIndexForInvalidVal;	// 01/20/03 JMI Not actually a const b/c I want to initalize it right next to astrTextureDetailNames.

var /*config*/	bool			bDefaultsStored;		// 03/03/03 JMI Used to detect if defaults have been stored for the derived menu.
var			array<string>	aDefaultPaths;			// 03/03/03 JMI Add paths to defaults that should be restored.
var /*config*/	array<string>	aDefaultValues;

var bool					bDarkenBackground;		// Darken the background so the text is more readable.

var bool					bBlockConsole;

var bool					bDoJitter;
var float					JitterDuration;
var float					JitterStartTime;
var float					JitterPercent;
var bool					bJitterRestored;
var bool					bJittering;
var float					JitterMaxOffset;

const BACKTEXT_ALPHA	=	128;

var config float			LastX, LastY;	// Last mouse/joystick position

///////////////////////////////////////////////////////////////////////////////
// Seekrit code functionality
// Can add secret codes to menus
// RWS NOTE 5/18/15: This feature is deprecated by controller support,
// but can still be used to create keyboard-only secret codes.
///////////////////////////////////////////////////////////////////////////////
var array<byte> SeekritKode;
var int KodeEntered;
var sound KeyAccepted, KodeAccepted, KodeWrong;

///////////////////////////////////////////////////////////////////////////////
// Seekrit code allowed?
// Defaults to false, must override if your menu has a seekrit code.
///////////////////////////////////////////////////////////////////////////////
function bool SeekritCodeAllowed()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Seekrit code entered
// Triggered when the seekrit code is entered in full.
///////////////////////////////////////////////////////////////////////////////
function SeekritKodeEntered()
{
	// STUB, to be filled out in target menu.
}

///////////////////////////////////////////////////////////////////////////////
// Handle input to seekrit code
///////////////////////////////////////////////////////////////////////////////
function HandleSeekritCode(int KeyIn)
{
	if (SeekritCodeAllowed()
		&& KodeEntered < SeekritKode.Length)
	{
		if (KeyIn == SeekritKode[KodeEntered])
		{
			KodeEntered++;
			if (KodeEntered >= SeekritKode.Length)			
			{
				if (KodeAccepted != None)
					ShellLookAndFeel(LookAndFeel).PlayThisLocalSound(Self, KodeAccepted, 1.0);				
				SeekritKodeEntered();
			}
			else if (KeyAccepted != None)
				ShellLookAndFeel(LookAndFeel).PlayThisLocalSound(Self, KeyAccepted, 1.0);
		}
		else
		{		
			if (KodeEntered > 0 && KodeWrong != None)
				ShellLookAndFeel(LookAndFeel).PlayThisLocalSound(Self, KodeWrong, 1.0);
			KodeEntered = 0;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Store default values.
///////////////////////////////////////////////////////////////////////////////
function StoreDefaultValues()
	{
	/*
	local int iIter;
	if (bDefaultsStored == false)
		{
		for (iIter = 0; iIter < aDefaultPaths.Length; iIter++)
			{
			aDefaultValues[iIter] = GetPlayerOwner().ConsoleCommand("get"@aDefaultPaths[iIter] );
			}

		// Stored them.
		bDefaultsStored = true;

		SaveConfig();
		}
	*/
	}

///////////////////////////////////////////////////////////////////////////////
// Restore default values.
///////////////////////////////////////////////////////////////////////////////
function RestoreDefaultValues()
	{
	local int iIter;
	if (bDefaultsStored == true)
		{
		for (iIter = 0; iIter < aDefaultPaths.Length; iIter++)
			{
			log("set"@aDefaultPaths[iIter]@aDefaultValues[iIter] );
			GetPlayerOwner().ConsoleCommand("set"@aDefaultPaths[iIter]@aDefaultValues[iIter] );
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Appears to be a post-creation event for adding children and stuff.
///////////////////////////////////////////////////////////////////////////////
function Created()
	{
	local float MouseX, MouseY;
	local int IntMouseX, IntMouseY;
	local int i;
	
	// 01/23/03 JMI Keep this text clear if not in a demo.
	if (!GetLevel().IsDemoBuild())
		OptionUnavailableInDemoHelpText = "";
	
	Super.Created();
	
	ItemMaxWidth = GetMenuWidth() - BorderLeft - BorderRight - (ItemBorder * 2);
	
	// 01/20/03 JMI Moved these here b/c there was no opportunity to change these
	//				for an extended class of an extended class if the extended
	//				class also set them.
	// Set defaults for when extended class calls CreateMenuContents
	TitleFont = F_FancyXL;
	TitleAlign = TA_Left;
	ItemFont = F_FancyL;
	ItemAlign = TA_Left;
	
	// Let extended class put stuff in the menu
	CreateMenuContents();
	
	// Throw in help item.  I imagine this should be done before calculating the 
	// menu height.
	HintItem = AddHelpItem();
	
	// If menu height wasn't set explicitly then calculate it now
	if (MenuHeight == 0)
		// Note that we don't consider help height in here so we only center on
		// the content portion of the menu.
		MenuHeight = GetNextItemPosY() + BorderBottom;
	
	// If not enough room for the hints, add in some more but remember how much
	// so we can take that into account when centering the menu.  We don't want to
	// center based on the hint area.
	if (HintItem != none)
		{
		HintExtra = (HintItem.WinTop + HintItem.WinHeight) - MenuHeight;
		if (HintExtra > 0)
			// Add just enough to fit it.
			MenuHeight += HintExtra;
		else
			HintExtra = 0;
		}
	
	SetSize(GetMenuWidth(), GetMenuHeight());
	
	// If player is using gamepad to navigate, helpfully snap the cursor to the first menu option
	if (Root.bUsingJoystick)
	{
		i = 0;
		while (ShellWrappedTextControl(MenuItems[i].Window) != None)
			i++;
			
		SnapCursorTo(MenuItems[i].Window);
	}
	
	}

///////////////////////////////////////////////////////////////////////////////
// Create menu contents.
// Extended classes use this to put things in the menu.
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	}

///////////////////////////////////////////////////////////////////////////////
// Called after menu was created
///////////////////////////////////////////////////////////////////////////////
function AfterCreate()
{
	local UWindowWindow Child;
	local int i;

	Super.AfterCreate();

	if (bDoJitter)
	{
		JitterStartTime = Root.GetLevel().TimeSecondsAlways;

		Child = FirstChildWindow;
		while(Child != None)
		{
			Child.SavedWinLeft = Child.WinLeft;
			Child.SavedWinTop = Child.WinTop;
			Child = Child.NextSiblingWindow;
			i++;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add title to menu
///////////////////////////////////////////////////////////////////////////////
function AddTitle(String strText, int Font, TextAlign Align)
	{
	local ShellMenuChoice ctl;
	
	if (strText != "")
		{
		ctl = ShellMenuChoice(CreateWindow(class'ShellMenuChoice', BorderLeft, BorderTop, GetMenuWidth() - BorderLeft - BorderRight, TitleHeight));
		ctl.SetFont(Font);
		ctl.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
		ctl.SetText(strText);
		ctl.bActive = false;
		ctl.Align = Align;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Add title bitmap
///////////////////////////////////////////////////////////////////////////////
function AddTitleBitmap(Texture tex)
	{
	local UWindowBitmap ctl;
	
	if (tex != None)
		{
		ctl = UWindowBitmap(CreateWindow(class'UWindowBitmap',  BorderLeft, BorderTop, GetMenuWidth() - BorderLeft - BorderRight, TitleHeight));
		ctl.bFit = true;
		ctl.bAlpha = true;
		ctl.T = tex;
		ctl.R.X = 0;
		ctl.R.Y = 0;
		ctl.R.W = ctl.T.USize;
		ctl.R.H = ctl.T.VSize;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Add a choice to the menu
///////////////////////////////////////////////////////////////////////////////
function ShellMenuChoice AddChoice(String strText, String strHelp, int Font, TextAlign Align, optional bool bRespondToCancel)
	{
	local ShellMenuChoice ctl;
	
	ctl = ShellMenuChoice(CreateControl(class'ShellMenuChoice',  GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, ItemHeight));
	ctl.SetFont(Font);
	ctl.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.SetText(strText);
	ctl.SetHelpText(strHelp);
	ctl.Align = Align;
	ctl.bCancel = bRespondToCancel;
	AddItem(ctl, ItemHeight + ItemSpacingY);
	return ctl;
	}

///////////////////////////////////////////////////////////////////////////////
// Add a slider to the menu
///////////////////////////////////////////////////////////////////////////////
function UWindowHSliderControl AddSlider(String strText, String strHelp, int Font, int MinVal, int MaxVal)
	{
	local UWindowHSliderControl ctl;
	
	ctl = UWindowHSliderControl(CreateControl(class'ShellSliderControl', GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, ItemHeight));
	ctl.SetFont(Font);
	ctl.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.SetText(strText);
	ctl.SetHelpText(strHelp);
	ctl.bNoSlidingNotify = True;
	ctl.SetRange(MinVal, MaxVal, 1);
	ctl.Align = TA_Left;
	ctl.SliderWidth = ctl.WinWidth * fCommonCtlArea;
	ctl.bDisplayVal = true;
	ctl.SetValColor(SliderValColor);//ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.fTickLen = 2.0;
	AddItem(ctl, ItemHeight + ItemSpacingY);
	return ctl;
	}

///////////////////////////////////////////////////////////////////////////////
// Add a checkbox to the menu
///////////////////////////////////////////////////////////////////////////////
function UWindowCheckbox AddCheckbox(String strText, String strHelp, int Font)
	{
	local UWindowCheckbox ctl;
	
	ctl = UWindowCheckbox(CreateControl(class'UWindowCheckbox', GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, ItemHeight));
	ctl.bChecked = true;
	ctl.SetFont(Font);
	ctl.SetText(strText);
	ctl.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.SetHelpText(strHelp);
	ctl.Align = TA_Custom;
	// 01/15/03 JMI Added CheckBoxAreaW to help LookAndFeel position the actual check images.
	ctl.CheckBoxAreaW = ctl.WinWidth * fCommonCtlArea;
	AddItem(ctl, ItemHeight + ItemSpacingY);
	return ctl;
	}

///////////////////////////////////////////////////////////////////////////////
// Add a combobox to the menu
///////////////////////////////////////////////////////////////////////////////
function UWindowComboControl AddComboBox(String strText, String strHelp, int Font)
	{
	local ShellComboControl ctl;
	
	ctl = ShellComboControl(CreateControl(class'ShellComboControl', GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, ItemHeight));
	ctl.SetFont(Font);
	//	ctl.SetControlsFont(ctl.List.Font);	// *** Use font in ListBox member?...it's hard coded in UWindowComboList.
	ctl.SetControlsFont(F_Bold);	// *** TEMP hard coding of font to this looks nicer than the one in UWindowComboList.
	ctl.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.SetText(strText);
	ctl.SetHelpText(strHelp);
	ctl.SetEditable(False);
	ctl.Align = TA_Left;
	ctl.EditBoxWidth = ctl.WinWidth * fCommonCtlArea;
	AddItem(ctl, ItemHeight + ItemSpacingY);
	return ctl;
	}

///////////////////////////////////////////////////////////////////////////////
// Add an editbox to the menu
///////////////////////////////////////////////////////////////////////////////
function UWindowEditControl AddEditBox(String strText, String strHelp, int Font)
	{
	local UWindowEditControl ctl;
	
	ctl = UWindowEditControl(CreateControl(class'UWindowEditControl', GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, ItemHeight));
	ctl.SetFont(Font);
	ctl.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.SetText(strText);
	ctl.SetHelpText(strHelp);
	ctl.EditBox.SetHelpText(strHelp);
	ctl.Align = TA_Left;
	// 02/01/03 JMI Well this explains why it wasn't working when I was setting fCommonCtlArea for the load/save
	//				menus.  I should've just done it instead of commenting about it below--duh.  Added.
	// 01/15/03 JMI Editbox is the only control that doesn't do a ctl.EditBoxWidth = ctl.WinWidth * fCommonCtlArea
	// which is likely only due to the relatively low use of this field.
	ctl.EditBoxWidth = ctl.WinWidth * fCommonCtlArea;
	AddItem(ctl, ItemHeight + ItemSpacingY);
	return ctl;
	}

///////////////////////////////////////////////////////////////////////////////
// Add a text item to the menu
///////////////////////////////////////////////////////////////////////////////
function ShellTextControl AddTextItem(String strText, String strHelp, int Font)
	{
	local ShellTextControl ctl;
	
	ctl = ShellTextControl(CreateControl(class'ShellTextControl', GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, ItemHeight));
	ctl.SetFont(Font);
	ctl.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.SetText(strText);
	ctl.SetHelpText(strHelp);
	ctl.Align = TA_Left;
	ctl.ValueAlign = TA_Left;
	ctl.TextItemWidth = ctl.WinWidth * fCommonCtlArea;
	AddItem(ctl, ItemHeight + ItemSpacingY);
	return ctl;
	}

///////////////////////////////////////////////////////////////////////////////
// Add multi-line text message item
///////////////////////////////////////////////////////////////////////////////
function ShellWrappedTextControl AddWrappedTextItem(array<string> Text, float Height, int Font, TextAlign Align)
	{
	local ShellWrappedTextControl ctl;
	local int i;

	// Add a child window for the message.
	ctl = ShellWrappedTextControl(CreateWindow(class'ShellWrappedTextControl', GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, Height));
	for (i = 0; i < Text.Length; i++)
		ctl.Text = ctl.Text $ Text[i];
	if (Align == TA_Center)
		ctl.bHCenter = true;
	else
		ctl.bHCenter = false;
	ctl.SetFont(Font);
	ctl.Font = Font;
	ctl.TextColor = ShellLookAndFeel(LookAndFeel).NormalTextColor;
//	ctl.SetTextColor(HintColor);
	AddItem(ctl, Height + ItemSpacingY);
	return ctl;
	}

///////////////////////////////////////////////////////////////////////////////
// Add character display item
///////////////////////////////////////////////////////////////////////////////
function CharacterWindow AddCharacterWindow(float Height)
	{
	local CharacterWindow cw;
	local int i;

	// Add a child window for the message.
	cw = CharacterWindow(CreateWindow(class'CharacterWindow', GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, Height));

	AddItem(cw, Height + ItemSpacingY);
	return cw;
	}

///////////////////////////////////////////////////////////////////////////////
// Add an item to the menu
///////////////////////////////////////////////////////////////////////////////
function AddItem(UWindowWindow Window, float Height)
	{
	local int i;
	local float PosY;
	
	PosY = GetNextItemPosY();

	i = MenuItems.Length;
	MenuItems.Insert(i, 1);
	MenuItems[i].Window = Window;
	MenuItems[i].PosY = PosY;
	MenuItems[i].Height = Height;
	}

///////////////////////////////////////////////////////////////////////////////
// Get the next available menu item position
///////////////////////////////////////////////////////////////////////////////
function float GetNextItemPosX()
	{
	return GetItemPosX(MenuItems.Length);
	}

function float GetNextItemPosY()
	{
	if (MenuItems.Length == 0)
		return BorderTop + TitleHeight + TitleSpacingY;
	return MenuItems[MenuItems.Length-1].PosY + MenuItems[MenuItems.Length-1].Height;
	}

///////////////////////////////////////////////////////////////////////////////
// Get the position for the specified menu item
///////////////////////////////////////////////////////////////////////////////
function float GetItemPosX(int Item)
	{
	return BorderLeft + ItemBorder;
	}

function float GetItemPosY(int Item)
	{
	return MenuItems[Item].PosY;
	}

///////////////////////////////////////////////////////////////////////////////
// Add the help item to the menu.  This can be altered or eliminated by 
// overriding this function.	You could also or alternatively override 
// ShowHelp().
// 11/28/02 JMI Started to make a way to show the help info.  Was unsure as to 
//				whether to use ShellMenuChoice or UWindowDialogControl for the
//				type--it could go either way.
///////////////////////////////////////////////////////////////////////////////
function ShellWrappedTextControl AddHelpItem()
	{
	local ShellWrappedTextControl	ctl;
	local int						HintFont;
	
	// 12/22/02 JMI Just base the hint font upon the font used for the menu items.
	HintFont = GetHintFont();
	
	// 01/27/03 JMI Help item now uses entire menu width.
	ctl = ShellWrappedTextControl(CreateControl(class'ShellWrappedTextControl',  0, GetNextItemPosY(), GetMenuWidth(), (ItemHeight + ItemSpacingY) * HintLines));
	ctl.SetFont(HintFont);	// Vivid font for clear help text.  Otherwise, we could look at the menu 
	// contents and use the most commonly used font or simply the 
	// first item's font.
	// Note that the UWindowTextAreaControl declares its own Font member so its base class' 
	// SetFont does not set the right "Font" var so we have to set it directly.  This seems like
	// a blatant bug where it used to have its own and then a base class member was added without
	// removing the one in UWindowTextCAreaontrol.
	ctl.Font = HintFont;
	
	ctl.SetTextColor(HintColor);
	ctl.bActive	= false;	// Don't respond to the user..just informational.
	ctl.bShadow = false;	// 01/30/03 JMI Wrapped control now has a shadow by default.
	
	// Go ahead and return this item rather than just setting it into the member
	// as a way of the derived class being able to further customize this object
	// when overriding.
	return ctl;
	}

///////////////////////////////////////////////////////////////////////////////
// Get the hint font.
// 12/22/02 JMI Started to base the hint font size automagically upon the items'
//				size assuming the first item is representative of the menu overall.
///////////////////////////////////////////////////////////////////////////////
function int GetHintFont()
	{
	local int					iFont;
	local UWindowDialogControl	ctl;
	
	iFont = F_Normal;
	if (MenuItems.Length > 0)
		{
		ctl = UWindowDialogControl(MenuItems[0].Window);
		if (ctl != none)
			{
			/*			switch (ctl.Font)
			{
			case F_FancyS :
			iFont = F_Normal;	// 01/17/03 JMI Changed equivalent now that fonts match sizes.
			break;
			case F_FancyM :
			iFont = F_Bold;		// 01/17/03 JMI Changed equivalent now that fonts match sizes.
			break;
			case F_FancyL :
			iFont = F_Large;
			break;
			case F_FancyXL:
			iFont = F_LargeBold;
			break;
			default:
			*/				iFont = F_Bold;	   // 01/17/03 JMI Changed to always using this to get consistency.
			//				break;
			//			}
			}
		}
	
	return iFont;
	}

///////////////////////////////////////////////////////////////////////////////
// Post resize.
///////////////////////////////////////////////////////////////////////////////
function Resized()
	{
	// Center on root
	WinLeft = Root.WinLeft + (Root.WinWidth - WinWidth) / 2;
	WinTop  = Root.WinTop + (Root.WinHeight - GetContentHeight() ) / 2;
	
	// Reposition items to accomodate new size...??
	}

///////////////////////////////////////////////////////////////////////////////
// Before drawing onto the canvas.
///////////////////////////////////////////////////////////////////////////////
function BeforePaint(Canvas canvas, float X, float Y)
	{
	local Texture T;
	local float Elapsed;
	local float NewX, NewY;
	local UWindowWindow Child;
	local int i;

	if(bDarkenBackground)
		{
		canvas.Style = 5; //ERenderStyle.STY_Alpha;
		canvas.SetDrawColor(255, 255, 255, BACKTEXT_ALPHA);
		canvas.SetPos(0, 0);
		canvas.DrawTile(Texture'BlackTexture', canvas.SizeX, canvas.SizeY, 
						0, 0, Texture'BlackTexture'.USize, Texture'BlackTexture'.VSize);
		}

	if (bDoJitter)
	{
		// catnip fix
		if (P2GameInfoSingle(GetLevel().Game) != None
			&& P2GameInfoSingle(GetLevel().Game).GetPlayer() != None
			&& P2GameInfoSingle(GetLevel().Game).GetPlayer().CatnipUseTime != 0)
			JitterDuration = Default.JitterDuration / 10;
		else
			JitterDuration = Default.JitterDuration;
		Elapsed = Root.GetLevel().TimeSecondsAlways - JitterStartTime;
		if (Elapsed < JitterDuration || !bJitterRestored)
		{
			JitterPercent = Elapsed / JitterDuration;
			if (JitterPercent < 0.0)
				JitterPercent = 0.0;
			if (JitterPercent > 1.0)
			{
				JitterPercent = 1.0;
				bJitterRestored = true;
			}

			Child = FirstChildWindow;
			while(Child != None)
			{
				NewX = Child.SavedWinLeft;
				NewY = Child.SavedWinTop;
				if (JitterPercent < 1.0)
				{
					NewX += frand() * JitterMaxOffset * (1.0 - JitterPercent);
					NewY += frand() * JitterMaxOffset * (1.0 - JitterPercent);
				}
				Child.WinLeft = NewX;
				Child.WinTop  = NewY;
				Child = Child.NextSiblingWindow;
				i++;
			}

			bJittering = !bJitterRestored;
		}
	}

	Super.BeforePaint(canvas, X, Y);
	}

function BeforeChildPaint(Canvas C)
{
	Super.BeforeChildPaint(C);
	if (bJittering)
	{
		C.Style = GetPlayerOwner().ERenderStyle.STY_Alpha;
		C.SetDrawColor(255,255,255);
		C.DrawColor.A = 255 * JitterPercent;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw onto the canvas.
///////////////////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y)
	{
	local Texture T;
	
	Super.Paint(C, X, Y);
	}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);
	switch(E)
		{
		case DE_MouseEnter:
			ShowHelp(true, C);
			break;
		case DE_MouseLeave:
			ShowHelp(false, C);
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Handle a key event
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
	local ShellMenuChoice choice;
	local int i;
	
	if (HandleJoystick(Key, Action, Delta))
		return true;

	// Handle seekrit code.
	if (Action == IST_Press)
		HandleSeekritCode(Key);
	
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				if(ShellRootWindow(Root) != None && ShellRootWindow(Root).openWindow != None)
				{
					ShellRootWindow(Root).openWindow.Close();
					//GoBack();
					return true;
				}

				for (i = 0; i < MenuItems.length; i++)
					{
					choice = ShellMenuChoice(MenuItems[i].Window);
					if (choice != None)
						{
						if (choice.bCancel)
							GoBack();
						}
					}
				return true;
			}
		}
	
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Get menu size
///////////////////////////////////////////////////////////////////////////////
function float GetMenuWidth()
	{
	return MenuWidth;
	}

function float GetMenuHeight()
	{
	return MenuHeight;
	}

function float GetContentHeight()
	{
	// Compensate for extra hint space needed so we don't center based on it.
	return MenuHeight - HintExtra;
	}

///////////////////////////////////////////////////////////////////////////////
// Call this when we think we're leaving this menu.  To hook this functionality,
// override OnCleanUp().  This function shouldn't be overriden b/c of the amount
// of checking that needs to be done before deciding to clean up.
// 01/25/03 JMI Started because, when a menu was exited with Escape, combo
//				lists that were visible would stay visible on the next menu
//				until someone clicked somewhere (on or off the combo).
///////////////////////////////////////////////////////////////////////////////
function CleanUp()
	{
	// If we got the new menu, clean this one up.
	if (ShellRootWindow(Root).MyMenu != none && ShellRootWindow(Root).MyMenu != Self)
		OnCleanUp();
	}

///////////////////////////////////////////////////////////////////////////////
// Although this is not guaranteed to be called, we try to call it whenever
// possible so some clean up can occur.
// 01/25/03 JMI Started because, when a menu was exited with Escape, combo
//				lists that were visible would stay visible on the next menu
//				until someone clicked somewhere (on or off the combo).
///////////////////////////////////////////////////////////////////////////////
function OnCleanUp()
	{
	local int iIter;
	local UWindowComboControl combo;
	// 01/25/03 JMI Go through all combos and hide their lists.  This is for
	//				the case where a menu is exited with escape and the combos'
	//				lists were staying up even on the next menu.
	for (iIter = 0; iIter < MenuItems.Length; iIter++)
		{
		// If it's a combo . . .
		combo = UWindowComboControl(MenuItems[iIter].Window);
		if (combo != none)
			{
			// Make sure its list is hidden.
			combo.CloseUp();
			}
		}
	}
	
function RestoreMousePos()
{
	local int IntMouseX, IntMouseY;
	
	IntMouseX = LastX;
	IntMouseY = LastY;
	Root.MoveMouse(LastX,LastY);
	if (PlatformIsWindows())	// not needed in SDL
		GetPlayerOwner().ConsoleCommand("SETMOUSE"@IntMouseX@IntMouseY);
	
}

///////////////////////////////////////////////////////////////////////////////
// Jump to specified menu
///////////////////////////////////////////////////////////////////////////////
function ShellMenuCW GoToMenu(class<ShellMenuCW> clsMenu)
	{
	local ShellRootWindow shRoot;
	shRoot = ShellRootWindow(Root);
	if (shRoot != None)
		{
		LastX = Root.MouseX;
		LastY = Root.MouseY;
		SaveConfig();
		LookAndFeel.PlayBigSound(self);
		shRoot.GoToMenu(self.class, clsMenu);
		
		OnCleanUp();
		
		return shRoot.MyMenu;
		}
	
	return None;
	}

function GoToWindow(UWindowWindow newWindow)
{
	local ShellRootWindow shRoot;
	shRoot = ShellRootWindow(Root);
	if (shRoot != None)
	{
		LastX = Root.MouseX;
		LastY = Root.MouseY;
		SaveConfig();
		shRoot.GoToWindow(newWindow);
	}
	
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Go to the new menu without updating GoBack
///////////////////////////////////////////////////////////////////////////////
function ShellMenuCW JumpToMenu(class<ShellMenuCW> MenuClass, optional class<ShellMenuCW> GoBackMenu)
	{
	local ShellRootWindow shRoot;
	shRoot = ShellRootWindow(Root);
	if (shRoot != None)
		{
		LastX = Root.MouseX;
		LastY = Root.MouseY;
		SaveConfig();
		LookAndFeel.PlayBigSound(self);
		shRoot.GoToMenu(GoBackMenu, MenuClass);
		
		OnCleanUp();
		
		return shRoot.MyMenu;
		}
	
	return None;
	}

///////////////////////////////////////////////////////////////////////////////
// Jump to previous menu
///////////////////////////////////////////////////////////////////////////////
function GoBack()
	{
	if (ShellRootWindow(Root) != None)
		{
		LookAndFeel.PlayBigSound(self);
		ShellRootWindow(Root).GoBack();
		
		OnCleanUp();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Update values when controls have changed.
// - if bUpdate is false then don't update the real value
// - if bAsk is false then skip any user confirmations
///////////////////////////////////////////////////////////////////////////////
function SetDiff()
{
	local string diffname;
	local int val, diffnum;
	local P2GameInfoSingle psg;
	local bool bLieberMode, bHestonMode, bTheyHateMeMode, bInsaneoMode, bExpertMode, bMasochistMode, bVeteranMode, bLudicrousMode;
	//local bool bTheyHateMeWarning, bPOSTALWarning, bImpossibleWarning, bLudicrousWarning;
	//local ShellMenuCW WarningMenu;

		psg = P2GameInfoSingle(GetPlayerOwner().Level.Game);

		diffname = DifficultyCombo.GetValue();
		//log(self$" DiffChanged diffname after change "$diffname,'Debug');
		
		// Lieber Mode
		if(diffname == psg.DifficultyNames[0])
		{
			val = 0;
			diffnum = 0;
			bLieberMode = True;
		}
		else if(diffname == psg.DifficultyNames[1])
		{
			val = 1;
			diffnum = 1;
		}
		else if(diffname == psg.DifficultyNames[2])
		{
			val = 2;
			diffnum = 2;
		}
		else if(diffname == psg.DifficultyNames[3])
		{
			val = 3;
			diffnum = 3;
		}
		else if(diffname == psg.DifficultyNames[4])
		{
			val = 4;
			diffnum = 4;
		}
		else if(diffname == psg.DifficultyNames[5])
		{
			val = 5;
			diffnum = 5;
		}
		else if(diffname == psg.DifficultyNames[6])
		{
			val = 6;
			diffnum = 6;
		}
		else if(diffname == psg.DifficultyNames[7])
		{		
			val = 7;
			diffnum = 7;
		}
		else if(diffname == psg.DifficultyNames[8])
		{
			val = 8;
			diffnum = 8;
		}
		else if(diffname == psg.DifficultyNames[9])
		{
			val = 9;
			diffnum = 9;
		}
		// Heston Mode
		else if(diffname == psg.DifficultyNames[10])
		{
			val = 10;
			diffnum = 10;
			bHestonMode = True;
		}
		// Insaneo Mode
		// Game doesn't get any more difficult past this point in terms of AI --
		// just various bullshit things we throw at the player like NPC's with big guns.
		// Otherwise, POSTAL and Impossible mode would truly be impossible.
		else if(diffname == psg.DifficultyNames[11])
		{
			val = 10;
			diffnum = 11;
			bInsaneoMode = True;
		}
		// They Hate Me Mode
		else if(diffname == psg.DifficultyNames[12])
		{
			val = 10;
			diffnum = 12;
			bTheyHateMeMode = True;
			//bTheyHateMeWarning = True;
		}
		// POSTAL mode - turns on Hestonworld, They Hate Me, and Expert
		else if(diffname == psg.DifficultyNames[13])
		{
			val = 10;
			diffnum = 13;
			bHestonMode = True;
			bTheyHateMeMode = True;
			bExpertMode = True;
			//bPOSTALWarning = True;
		}
		// Impossible Mode - turns on Insaneo, They Hate Me, and Expert
		else if(diffname == psg.DifficultyNames[14])
		{
			val = 10;
			diffnum = 14;
			bInsaneoMode = True;
			bTheyHateMeMode = True;
			bExpertMode = True;
			//bImpossibleWarning = True;
		}
		// Ludicrous Mode - turns on Masochist, They Hate Me, and Expert... EVERYTHING!
		else if(diffname == psg.DifficultyNames[15])
		{
			val = 15;
			diffnum = 15;
			bVeteranMode = True;
			bMasochistMode = True;
			bLudicrousMode = True;
			bTheyHateMeMode = True;
			bExpertMode = True;
			//bLudicrousWarning = True;
		}
		// Custom mode - reset to Average difficulty
		else
		{
			val = 5;
			diffnum = 5;
		}
		//log(self$" DiffChanged diff value "$val@"diff num"@diffnum@"Lieber Heston Hate Insane Expert"@bLieberMode@bHestonMode@bTheyHateMeMode@bInsaneoMode@bExpertMode,'Debug');
		// set diff
        
		GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyPath@val);
		GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyNumberPath@diffnum);
		GetPlayerOwner().ConsoleCommand("set"@LieberPath@bLieberMode);
		GetPlayerOwner().ConsoleCommand("set"@HestonPath@bHestonMode);
		GetPlayerOwner().ConsoleCommand("set"@TheyHateMePath@bTheyHateMeMode);
		GetPlayerOwner().ConsoleCommand("set"@InsaneoPath@bInsaneoMode);
		GetPlayerOwner().ConsoleCommand("set"@ExpertPath@bExpertMode);
		GetPlayerOwner().ConsoleCommand("set"@VeteranPath@bVeteranMode);
		GetPlayerOwner().ConsoleCommand("set"@MasochistPath@bMasochistMode);
		GetPlayerOwner().ConsoleCommand("set"@LudicrousPath@bLudicrousMode);
		GetPlayerOwner().ConsoleCommand("set"@CustomPath@"false");
		GetPlayerOwner().ConsoleCommand("set"@MeleePath@"false");
		GetPlayerOwner().ConsoleCommand("set"@HardLieberPath@"false");
		GetPlayerOwner().ConsoleCommand("set"@NukeModePath@"false");
		psg.GameDifficulty = val;
		// Update the gamestate here, also, if we have one
		if(psg.TheGameState != None)
			psg.TheGameState.GameDifficulty = val;	
}

///////////////////////////////////////////////////////////////////////////////
// Update values when controls have changed.
// - if bUpdate is false then don't update the real value
// - if bAsk is false then skip any user confirmations
///////////////////////////////////////////////////////////////////////////////
function DiffChanged(bool bUpdate, optional bool bSkipExplanation)
{
	local string diffname;
	local int i, diffnum;
	local P2GameInfoSingle psg;
	//local bool bLieberMode, bHestonMode, bTheyHateMeMode, bInsaneoMode, bExpertMode, bMasochistMode, bVeteranMode, bLudicrousMode;
	local bool bTheyHateMeWarning, bPOSTALWarning, bImpossibleWarning, bLudicrousWarning;
	local ShellMenuCW WarningMenu;
	
	// Actual difficulty change moved to SetDiff due to lag spike
	// Now we only handle DifficultyNumber and Warnings here.

	if (bUpdate)
	{
		psg = P2GameInfoSingle(GetPlayerOwner().Level.Game);
		diffname = DifficultyCombo.GetValue();
		//log(self$" DiffChanged diffname after change "$diffname,'Debug');
		
		// They Hate Me Mode
		if(diffname == psg.DifficultyNames[12])
		{
			diffnum = 12;
			bTheyHateMeWarning = True;
		}
		// POSTAL mode
		else if(diffname == psg.DifficultyNames[13])
		{
			diffnum = 13;
			bPOSTALWarning = True;
		}
		// Impossible Mode
		else if(diffname == psg.DifficultyNames[14])
		{
			diffnum = 14;
			bImpossibleWarning = True;
		}
		// Ludicrous Mode
		else if(diffname == psg.DifficultyNames[15])
		{
			diffnum = 15;
			bLudicrousWarning = True;
		}
		else
		{
			for (i=0; i<ArrayCount(psg.DifficultyNames); i++)
			{
				if (diffname == psg.DifficultyNames[i])	
					diffnum = i;
			}
		}
		
		GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyNumberPath@diffnum);
		
		// Disable custom mode as we change difficulty
		if(psg.InCustomMode())
		{
			psg.TheGameState.bCustomMode = False;
			psg.bCustomMode = False;
		}
		
		if(!bSkipExplanation)
		{
			if (bTheyHateMeWarning)
				WarningMenu = GotoMenu(class'MenuTheyHateMe');
			if (bPOSTALWarning)
				WarningMenu = GotoMenu(class'MenuNightmare');
			if (bImpossibleWarning)
				WarningMenu = GotoMenu(class'MenuImpossible');
			if(bLudicrousWarning)
				WarningMenu = GotoMenu(class'MenuLudicrous');
				
			if (WarningMenu != None && MenuTheyHateMe(WarningMenu) != None)
				MenuTheyHateMe(WarningMenu).MyMenuStart = MenuStart(Self);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Call to hide the current menu
///////////////////////////////////////////////////////////////////////////////
function HideMenu()
	{
	ShellRootWindow(Root).HideMenu();
	}

///////////////////////////////////////////////////////////////////////////////
// Returns true if in the game menu.
// 01/20/03 JMI Moved this into a function of ShellMenuCW from direct usage in
//				MenuGameSettings so more menus can utilize it.
///////////////////////////////////////////////////////////////////////////////
function bool IsGameMenu()
	{
	return ShellRootWindow(Root).IsGameMenu();
	}

///////////////////////////////////////////////////////////////////////////////
// Get the single player info.
// 02/10/03 JMI Started to macroify this which we seem to be doing commonly
//				lately. 
///////////////////////////////////////////////////////////////////////////////
function P2GameInfoSingle GetGameSingle()
	{
	return P2GameInfoSingle(Root.GetLevel().Game);
	}

///////////////////////////////////////////////////////////////////////////////
// This simply informs the user that the latest change could reduce their
// performance and waits for them to click on the OK button.
///////////////////////////////////////////////////////////////////////////////
function ShowPerformanceWarning()
	{
	MessageBox(PerformanceWarningTitle, PerformanceWarningText, MB_OK, MR_OK, MR_OK);
	}

///////////////////////////////////////////////////////////////////////////////
// Show or unshow the help.  Override to block or change.
///////////////////////////////////////////////////////////////////////////////
function ShowHelp(bool bShow, UWindowDialogControl ctl)
	{
	local int iLines;
	if (HintItem != none)
		{
		// 12/19/02 JMI Changed to clear the hint always.
		if (bShow && ctl != none)
			{
			HintItem.SetText(ctl.HelpText);
			HintItem.ShowWindow();
			}
		else
			{
			HintItem.SetText("");
			HintItem.HideWindow();
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Replaces text arguments ~0..9 in the strFormat with the astrArgs[0..9]
// and returns the resulting string.
// 01/20/03 JMI Moved this here from ShellHSliderControl.
///////////////////////////////////////////////////////////////////////////////
function string Sprintf(string strFormat, array<string> astrArgs) 
	{
	local int	 iTokenPos;
	local int	 iTokenLen;
	local int    iArg;
	const c_strValTokenPrefix = "~";
	// Find the token.
	iTokenPos = InStr(strFormat, c_strValTokenPrefix);
	while (iTokenPos > -1)
		{
		iTokenLen	= Len(c_strValTokenPrefix);
		iArg		= int(Mid(strFormat, iTokenPos, 1) );
		iTokenLen   = iTokenLen + 1;	// Add one for digit.
		if (iArg >= 0 && iArg < astrArgs.Length)	// iArg must be >= 0 b/c we only look at 1 character but just for clarity.
			strFormat	= Left(strFormat, iTokenPos) $ astrArgs[iArg] $ Right(strFormat, Len(strFormat) - (iTokenPos + iTokenLen) );
		else
			strFormat = "Invalid argument"@iArg;
		
		// Next.
		iTokenPos = InStr(strFormat, c_strValTokenPrefix);
		}
	
	return strFormat;
	}

///////////////////////////////////////////////////////////////////////////////
// Functions to convert detail names to values and back again.
// 01/20/03 JMI Changed DetailVal/Name functions to use an array.  Note that 
// they can NOT share the same values that are being displayed to the user b/c
// this array -MUST- -NOT- be localized.
///////////////////////////////////////////////////////////////////////////////
function int DetailNameToVal(String strName)
	{
	local int iIter;
	for (iIter = 0; iIter < astrTextureDetailNames.Length; iIter++)
		{
		if (strName ~= astrTextureDetailNames[iIter] )
			return iIter;
		}
	Warn("DetailNameToVal(): unrecognized name: "$strName);
	return c_iTextureIndexForInvalidVal;
	}

function String DetailValToName(int val)
	{
	if (val >= 0 && val <= astrTextureDetailNames.Length)
		return astrTextureDetailNames[val];
	Warn("DetailValToName(): invalid value: "$val);
	return astrTextureDetailNames[c_iTextureIndexForInvalidVal];
	}

///////////////////////////////////////////////////////////////////////////////
// Resume playing game and save the newly set difficulty (only for old saves)
///////////////////////////////////////////////////////////////////////////////
function ResumeGameSaveDifficulty()
	{
	local P2GameInfoSingle psg;

	psg = P2GameInfoSingle(GetPlayerOwner().Level.Game);

	HideMenu();

	// Record the new difficulty in the game state
	psg.SetupDifficultyOnce();

	// Fix all the weapons for every living, non-player person before we save
	psg.FixDifficultyInventories();

	// Save the game into the same spot to record the new difficulty
	psg.SaveGame(psg.MostRecentGameSlot, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Confirm button: issue mouse click
///////////////////////////////////////////////////////////////////////////////
function execConfirmButton()
{
	local UWindowWindow CurrentWindow;
	local float MouseX, MouseY;
	
	CurrentWindow = Root.MouseWindow;
	//log(self@"hit confirm on"@CurrentWindow@"open window is"@ShellRootWindow(Root).OpenWindow);
	
	// Ignore if no menu.
	if (!bWindowVisible && ShellRootWindow(Root).OpenWindow == None)
		return;
		
	// convert global root coordinates to window coordinates
	CurrentWindow.GlobalToWindow(Root.MouseX, Root.MouseY, MouseX, MouseY);
	
	// FIXME Prevent clicking on combo dropdowns
	if (UWindowEditBox(CurrentWindow) != None
		|| UWindowComboButton(CurrentWindow) != None)
		return;

	// Some controls respond better to Click, others to LMouseDown+LMouseUp
	if (ShellMenuChoice(CurrentWindow) != None)
		CurrentWindow.Click(MouseX, MouseY);
	// Select/de-select mutators
	else if (UMenuMutatorListBox(CurrentWindow) != None)
	{
		// Must select first, then double-click
		UWindowListBox(CurrentWindow).SetSelected(MouseX, MouseY);
		CurrentWindow.DoubleClick(MouseX, MouseY);
		ShellRootWindow(Root).bHandledConfirm = true;
	}
	// Prevent listboxes from stealing focus	
	else if (UWindowListBox(CurrentWindow) != None)
	{
		UWindowListBox(CurrentWindow).SetSelected(MouseX, MouseY);
		ShellRootWindow(Root).bHandledConfirm = true;
	}
	else
	{
		CurrentWindow.LMouseDown(MouseX, MouseY);
		CurrentWindow.LMouseUp(MouseX, MouseY);
		ShellRootWindow(Root).bHandledConfirm = true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Back button: hit Escape
///////////////////////////////////////////////////////////////////////////////
function execBackButton()
{
	local EInputKey key;
	local EInputAction action;
	local int i;
	
	//log(self@"hit back on"@Root.MouseWindow@"open window is"@ShellRootWindow(Root).OpenWindow);
	
	// Ignore if no menu.
	if (!bWindowVisible && ShellRootWindow(Root).OpenWindow == None)
		return;
		
	key = IK_Escape;
	action = IST_Release;
	KeyEvent(key, action, 0);
}

///////////////////////////////////////////////////////////////////////////////
// Left/right: cycle through slider/combo
///////////////////////////////////////////////////////////////////////////////
function execMenuLeftButton()
{
	CycleMenuItem(-1);
}
function execMenuRightButton()
{
	CycleMenuItem(1);
}
function CycleMenuItem(int Offset)
{
	local UWindowWindow CurrentWindow;
	local int i;
	local float f;
	
	// Ignore if no menu.
	if (!bWindowVisible && ShellRootWindow(Root).OpenWindow == None)
		return;
		
	//log("MENU: cycle menu item"@Offset);

	CurrentWindow = Root.MouseWindow;
	
	// If this is an edit box belonging to a combo control, pass control to the combo control itself
	if (UWindowEditBox(CurrentWindow) != None
		&& UWindowComboControl(UWindowEditBox(CurrentWindow).NotifyOwner) != None)
		CurrentWindow = UWindowComboControl(UWindowEditBox(CurrentWindow).NotifyOwner);
	
	if (UWindowComboControl(CurrentWindow) != None)
	{
		// Pick next or previous item in list.
		i = UWindowComboControl(CurrentWindow).GetSelectedIndex() + Offset;
		if (i < 0)
			i = UWindowComboControl(CurrentWindow).List.Items.CountShown() - 1;
		else if (i > UWindowComboControl(CurrentWindow).List.Items.CountShown() - 1)
			i = 0;
		UWindowComboControl(CurrentWindow).SetSelectedIndex(i);		
	}
	else if (UWindowHSliderControl(CurrentWindow) != None)
	{
		f = UWindowHSliderControl(CurrentWindow).Value + Offset;
		if (f < UWindowHSliderControl(CurrentWindow).MinValue)
			f = UWindowHSliderControl(CurrentWindow).MinValue;
		else if (f > UWindowHSliderControl(CurrentWindow).MaxValue)
			f = UWindowHSliderControl(CurrentWindow).MaxValue;
		UWindowHSliderControl(CurrentWindow).SetValue(f);
	}
	else if (UWindowListBox(CurrentWindow) != None)
	{
		if (Offset == -1)
		{
			If (UWindowListBox(CurrentWindow).SelectedItem.Prev.Prev!=None)
				UWindowListBox(CurrentWindow).SetSelectedItem(UWindowListBoxItem(UWindowListBox(CurrentWindow).SelectedItem.Prev));
		}
		else
		{
			If (UWindowListBox(CurrentWindow).SelectedItem.Next!=None)
				UWindowListBox(CurrentWindow).SetSelectedItem(UWindowListBoxItem(UWindowListBox(CurrentWindow).SelectedItem.Next));
		}
		UWindowListBox(CurrentWindow).MakeSelectedVisible();
	}
}


///////////////////////////////////////////////////////////////////////////////
// Up and down: select menu items
///////////////////////////////////////////////////////////////////////////////
function execMenuUpButton()
{
	NextMenuItem(-1);
}
function execMenuDownButton()
{
	NextMenuItem(1);
}
function SnapCursorTo(UWindowWindow SnapTo)
{
	local float MouseX, MouseY, XAlign, YAlign;
	local int IntMouseX, IntMouseY;

	// Select current window. Try to align based on choice alignment
	if (UWindowDialogControl(SnapTo) != None)
	{
		YAlign = 2.0 / 3.0;
		switch (UWindowDialogControl(SnapTo).Align)
		{
			case TA_Left:
				XAlign = 1.0 / 8.0;
				break;
			case TA_Right:
				XAlign = 7.0 / 8.0;
				break;
			default:
				XAlign = 1.0 / 2.0;
				break;
		}
	}
	else
	{
		XAlign = 1.0 / 8.0;
		YAlign = 2.0 / 3.0;
	}
	SnapTo.WindowToGlobal(SnapTo.WinWidth * XAlign, SnapTo.WinHeight * YAlign, MouseX, MouseY);
	
	// Position mouse
	IntMouseX = MouseX;
	IntMouseY = MouseY;
	Root.MoveMouse(MouseX,MouseY);
	if (PlatformIsWindows())	// not needed in SDL
		GetPlayerOwner().ConsoleCommand("SETMOUSE"@IntMouseX@IntMouseY);
}
function NextMenuItem(int Offset)
{
	local UWindowWindow CurrentWindow;
	local int i;
	
	// Ignore if no menu.
	if (!bWindowVisible)
		return;

	CurrentWindow = Root.MouseWindow;
	
	// Find current window #, if any.
	for (i = 0; i < MenuItems.Length; i++)
	{
		if (MenuItems[i].Window == CurrentWindow)
			break;
	}

	// Skip wrapped text controls
	while (i < 0 || i >= MenuItems.Length || MenuItems[i].Window == CurrentWindow || ShellWrappedTextControl(MenuItems[i].Window) != None)
	{
		// Advance by offset.
		i += Offset;
		
		// Fix boundary wrapping
		if (i < 0)
			i = MenuItems.Length - 1;
		else if (i >= MenuItems.Length)
			i = 0;
	}
		
	SnapCursorTo(MenuItems[i].Window);
}

///////////////////////////////////////////////////////////////////////////////
// Man Chrzan: xPatch - Turns out I need it in more than one menu...
///////////////////////////////////////////////////////////////////////////////
function string GetColorAsString(color TheColor)
{
	local string TheColorStr;
	local int R, G, B, A;
	local color TempColor;
	
	TempColor = TheColor;
	R = TempColor.R;
	G = TempColor.G;
	B = TempColor.B;
	A = TempColor.A;
	TheColorStr = "(R="$R$",G="$G$",B="$B$",A="$A$")";
	
	return TheColorStr;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bNoClientBorder = true
//	ClientBg = Texture'P2Misc.MenuSkin'
//	bClientStretchBg = true
//	ClientAlpha = 100

	MenuWidth = 450

	BorderLeft = 35
	BorderRight = 35	// 01/15/03 JMI Changed BorderRight to 35 (from 50) to match BorderLeft so menus are centered.
	BorderTop = 20
	BorderBottom = 50
	
	TitleHeight = 40
	TitleSpacingY = 11

	ItemBorder = 0
	ItemHeight = 32
	ItemSpacingY = 2

	GameOptionsText = "Game"
	GameOptionsHelp = "Change things like blood settings, hints, etc"
	
	ControlOptionsText = "Controls"
	ControlOptionsHelp = "Edit controls of the game"
	
	VideoOptionsText = "Video"
	VideoOptionsHelp = "Configure resolution, color depth, etc"
	
	AudioOptionsText = "Audio"
	AudioOptionsHelp = "Change volumes, etc"
	
	PerformanceText = "Performance"
	PerformanceHelp = "Reduce texture detail, fire effects, fog range, etc. to speed up game"

	ReticleText		= "Crosshair Settings...";
	ReticleHelp		= "Select crosshairs and adjust settings";

	OptionsText = "Options"
	RestoreText = "Restore Defaults"
	RestoreHelp = "Restore default settings for options on this menu."
	YesText		= "Yes"
	NoText		= "No"
	StartText	= "Start"
	NextText	= "Next"
	LoadGameText = "Load Game"
	BackText = "Back"
	SlotDefaultText = "Slot"

	MultiTitleText = "Multiplayer"
	JoinText = "Join Game"
	JoinHelp = "Join a multiplayer game on your LAN or on the internet"
	OpenText = "Direct IP"
	OpenHelp = "Connect to a server using its IP Address or postal2:// URL"
	PlayerSetupText = "Player Setup"
	PlayerSetupHelp = "Set your player name, character, team..."
	PlayerChangeText = "Player Change"
	PlayerChangeHelp = "Change your player name, character, team..."

	AdminMenuText	= "Admin Menu"
	AdminMessageText= "Admin Message"
	AdminLoginText	= "Admin Login"

	LeaveGameText = "Leave Game"
	UpgradeText = "Upgrade"
	ErrorText = "Error"
	CancelText = "Cancel"

	PerformanceWarningTitle = "Performance Warning"
	PerformanceWarningText = "The change you made may adversely affect your performance."

	HintColor=(R=192,G=192,B=192,A=255)	// Try not to be overpowering but we want to notice it.
	HintLines=2

	fCommonCtlArea = 0.33	// 01/15/03 JMI Make control sizes consistent and overridable.

	SliderValColor=(R=160,G=160,B=160,A=255)	// 01/19/03 JMI Changed slider value color to match slider.

	// 01/20/03 JMI Added these for detail names for stored texture settings.
	// This array -MUST- -NOT- be localized.                                 
	astrTextureDetailNames[0] = "UltraLow"
	astrTextureDetailNames[1] = "Low"
	astrTextureDetailNames[2] = "Medium"
	astrTextureDetailNames[3] = "High"

	c_iTextureIndexForInvalidVal = 3	// 01/20/03 JMI Not actually a const b/c I want to initalize it right next to astrTextureDetailNames.

	OptionUnavailableInDemoHelpText = "Only available in full version of game";

	DifficultyText="Difficulty"
	DifficultyHelp="Sets game difficulty.  Cannot be changed after game begins."

	bBlockConsole=true

	bDoJitter=true
	JitterDuration=0.75
	JitterMaxOffset=5
	bShowedEnhancedMode=false
	}
