///////////////////////////////////////////////////////////////////////////////
// MenuControlsEditWeapons.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
//	02/01/03 JMI	Moved all control definitions into the base class.  The idea
//					is to be able to know all the mappable controls from all the
//					menus.  GetControls() still returns the controls this menu
//					will edit.
//
// 12/17/02 NPF Moved some new items here from Character (Actions) and made it
//				not just about hotkeys.
//
///////////////////////////////////////////////////////////////////////////////
class MenuControlsEditGamepad extends MenuControlsEdit;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string ControlsTitleText;

var UWindowHSliderControl MouseXSpeedSlider, MouseYSpeedSlider, MouseXDeadZoneSlider, MouseYDeadZoneSlider;
var localized string MouseXSpeedText, MouseYSpeedText, MouseXDeadZoneText, MouseYDeadZoneText;
var localized string MouseXSpeedHelp, MouseYSpeedHelp, MouseXDeadZoneHelp, MouseYDeadZoneHelp;

var UWindowCheckbox MouseXInvertCheckbox, MouseYInvertCheckbox;
var localized string MouseXInvertText, MouseYInvertText;
var localized string MouseXInvertHelp, MouseYInvertHelp;

const MOUSE_X_SPEED_PATH = "UWindow.JoyMouseInteraction XJoyMult";
const MOUSE_Y_SPEED_PATH = "UWindow.JoyMouseInteraction YJoyMult";
const MOUSE_X_DEADZONE_PATH = "UWindow.JoyMouseInteraction XDeadZone";
const MOUSE_Y_DEADZONE_PATH = "UWindow.JoyMouseInteraction YDeadZone";

var float DefXJoyMult, DefYJoyMult, DefXDeadZone, DefYDeadZone;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
// This one is "hard-coded" because of the way this menu works.
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	local array<Control>			aControls;

	//ErikFOV Change: for localization
	local array<String>			aControlsLabel;
	//end
	
	local int						iIter;
	local ShellInputControl			ctl;
	local ShellMenuChoice			chHeader;
	
	Super(ShellMenuCW).CreateMenuContents();

	TitleAlign = TA_Center;
	AddTitle(ControlsTitleText, TitleFont, TitleAlign);

	// 01/19/03 JMI Set the font even smaller b/c the Weapons menu has too many 
	//				items and some descriptions are wide.
	// 11/24/02 JMI This menu could be huge..use a smaller font than was set by
	//				the base class.
	ItemFont	= F_FancyS;

	// Be sure we start clean.
	aBindings.Length = 0;

	//ErikFOV Change: for localization
	//aControls = GetControls();
	GetControls(aControls,aControlsLabel);
	//end
	
	for (iIter = 0; iIter < aControls.Length; iIter++)
	{
		// Note that eventually we'll have another array or member that indicates
		// the type of control each input control needs to be edited with.
		// For now, a simple edit field will do.  This will probably be a ctrl
		// dervied from an edit field in the long run that can grab a key and,
		// perhaps even, list and store up to two key names.
		aBindings.Length		= aBindings.Length + 1;
		//aBindings[iIter].icon	= ShellBitmap(CreateWindow(class'ShellBitmap',GetNextItemPosX(),GetNextItemPosY(),32,32));
		
		//ErikFOV Change: for localization
		//aBindings[iIter].win	= AddKeyWidget(aControls[iIter].strLabel, InputHelpPrefix$aControls[iIter].strLabel$InputHelpPostfix, F_FancyS, iIter);
		aBindings[iIter].win	= AddKeyWidget(aControlsLabel[iIter], InputHelpPrefix$aControlsLabel[iIter]$InputHelpPostfix, F_FancyS, iIter);
		//end

//		Log("Iter:"@iIter@"Control:"@aControls[iIter].strAlias@aControls[iIter].strLabel);
	}

	// 02/02/03 JMI Add column headers.  Now that we solved the editbox height problem, we have more vertical room.
	if (aControls.Length > 0 && aBindings[0].win != none)
	{
		for (iIter = 0; iIter < aBindings[0].win.aInputs.Length; iIter++)
		{
			chHeader = ShellMenuChoice(CreateWindow(
				class'ShellMenuChoice', 
				aBindings[0].win.WinLeft + aBindings[0].win./*aInputs*/aIcons[iIter].WinLeft,	
				aBindings[0].win.WinTop  + aBindings[0].win./*aInputs*/aIcons[iIter].WinTop - (20/*ItemHeight*/ + ItemSpacingY), 
				/*aBindings[0].win.aInputs[iIter].WinWidth +*/ aBindings[0].win.aIcons[iIter].WinWidth,	16/*aBindings[0].win.aInputs[iIter].WinHeight*/) );
			
			chHeader.Align = TA_Center;
			chHeader.SetFont(ItemFont);
			chHeader.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
			chHeader.SetText("Input"@(iIter + 1) );
			chHeader.bActive = false;			
		}
	}

	ItemHeight = ItemHeight / 3;

	MouseYSpeedSlider = AddSlider(MouseYSpeedText, MouseYSpeedHelp, ItemFont, 0, 10);
	MouseYDeadZoneSlider = AddSlider(MouseYDeadZoneText, MouseYDeadZoneHelp, ItemFont, 0, 10);
	MouseYInvertCheckbox = AddCheckbox(MouseYInvertText, MouseYInvertHelp, ItemFont);

	MouseXSpeedSlider = AddSlider(MouseXSpeedText, MouseXSpeedHelp, ItemFont, 0, 10);
	MouseXDeadZoneSlider = AddSlider(MouseXDeadZoneText, MouseXDeadZoneHelp, ItemFont, 0, 10);
	MouseXInvertCheckbox = AddCheckbox(MouseXInvertText, MouseXInvertHelp, ItemFont);

	ItemHeight = Default.ItemHeight;

	// Load the values into the menu items.
	LoadValues();

	RestoreChoice	= AddChoice(RestoreText,	RestoreHelp,	ItemFont, ItemAlign);
	BackChoice		= AddChoice(BackText,		"",				ItemFont, ItemAlign, true);
}

///////////////////////////////////////////////////////////////////////////////
// Get the controls to be edited.  Tells the base class what to edit.
///////////////////////////////////////////////////////////////////////////////

//ErikFOV Change: for localization
/*function array<Control> GetControls()
{
	return aGamepadControls;
}*/

function GetControls(out array<Control> Controls, out array<String> Labels)
{
	Controls = aGamepadControls;
	Labels = aGamepadControlsLabel;
	return;
}
//end

///////////////////////////////////////////////////////////////////////////////
// Load slider data
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
{
	local float SpeedX, SpeedY, XDeadZone, YDeadZone;
	local bool bXInvert, bYInvert;
	
	Super.LoadValues();
	
	SpeedX = Float(GetPlayerOwner().ConsoleCommand("GET"@MOUSE_X_SPEED_PATH));
	SpeedY = Float(GetPlayerOwner().ConsoleCommand("GET"@MOUSE_Y_SPEED_PATH));
	XDeadZone = Float(GetPlayerOwner().ConsoleCommand("GET"@MOUSE_X_DEADZONE_PATH));
	YDeadZone = Float(GetPlayerOwner().ConsoleCommand("GET"@MOUSE_Y_DEADZONE_PATH));
	
	if (SpeedX < 0)
	{
		bXInvert = true;
		SpeedX = -SpeedX;
	}
	if (SpeedY < 0)
	{
		bYInvert = true;
		SpeedY = -SpeedY;
	}
	
	MouseYSpeedSlider.SetValue(SpeedY, true);
	MouseYDeadZoneSlider.SetValue(YDeadZone, true);
	MouseYInvertCheckbox.SetValue(bYInvert);
	MouseXSpeedSlider.SetValue(SpeedX, true);
	MouseXDeadZoneSlider.SetValue(XDeadZone, true);
	MouseXInvertCheckbox.SetValue(bXInvert);
}

///////////////////////////////////////////////////////////////////////////////
// Handle controls
///////////////////////////////////////////////////////////////////////////////
function MouseYSpeedSliderChanged()
{
	if (MouseYInvertCheckbox.GetValue())
		GetPlayerOwner().ConsoleCommand("SET"@MOUSE_Y_SPEED_PATH@(-1*MouseYSpeedSlider.GetValue()));
	else
		GetPlayerOwner().ConsoleCommand("SET"@MOUSE_Y_SPEED_PATH@MouseYSpeedSlider.GetValue());
}
function MouseYDeadZoneSliderChanged()
{
	GetPlayerOwner().ConsoleCommand("SET"@MOUSE_Y_DEADZONE_PATH@MouseYDeadZoneSlider.GetValue());
}
function MouseXSpeedSliderChanged()
{
	if (MouseXInvertCheckbox.GetValue())
		GetPlayerOwner().ConsoleCommand("SET"@MOUSE_X_SPEED_PATH@(-1*MouseXSpeedSlider.GetValue()));
	else
		GetPlayerOwner().ConsoleCommand("SET"@MOUSE_X_SPEED_PATH@MouseXSpeedSlider.GetValue());
}
function MouseXDeadZoneSliderChanged()
{
	GetPlayerOwner().ConsoleCommand("SET"@MOUSE_X_DEADZONE_PATH@MouseXDeadZoneSlider.GetValue());
}


///////////////////////////////////////////////////////////////////////////////
// Callback for when control has changed
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
		case DE_Change:
			switch (C)
			{
				// Speed and invert are linked, since one affects the other
				case MouseYSpeedSlider:
				case MouseYInvertCheckbox:
					MouseYSpeedSliderChanged();
					break;
				case MouseYDeadZoneSlider:
					MouseYDeadZoneSliderChanged();
					break;
				case MouseXSpeedSlider:
				case MouseXInvertCheckbox:
					MouseXSpeedSliderChanged();
					break;
				case MouseXDeadZoneSlider:
					MouseXDeadZoneSliderChanged();
					break;
			}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to defaults.
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
{
	local float SpeedX, SpeedY, XDeadZone, YDeadZone;
	local bool bXInvert, bYInvert;
	
	// Set defaults for keybinds
	Super.SetDefaultValues();
	
	SpeedX = DefXJoyMult;
	SpeedY = DefYJoyMult;
	XDeadZone = DefXDeadZone;
	YDeadZone = DefYDeadZone;
	
	if (SpeedX < 0)
	{
		bXInvert = true;
		SpeedX = -SpeedX;
	}
	if (SpeedY < 0)
	{
		bYInvert = true;
		SpeedY = -SpeedY;
	}
	
	MouseYSpeedSlider.SetValue(SpeedY, true);
	MouseYDeadZoneSlider.SetValue(YDeadZone, true);
	MouseYInvertCheckbox.SetValue(bYInvert);
	MouseXSpeedSlider.SetValue(SpeedX, true);
	MouseXDeadZoneSlider.SetValue(XDeadZone, true);
	MouseXInvertCheckbox.SetValue(bXInvert);
	
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ControlsTitleText = "Menu Navigation"
	MouseXSpeedText = "Cursor Left/Right Speed"
	MouseXSpeedHelp = "Adjusts speed of left/right cursor input."
	MouseXInvertText = "Cursor Left/Right Invert"
	MouseXInvertHelp = "Inverts cursor left/right axis."
	MouseYSpeedText = "Cursor Up/Down Speed"
	MouseYSpeedHelp = "Adjusts speed of up/down cursor input."
	MouseYInvertText = "Cursor Up/Down Invert"
	MouseYInvertHelp = "Inverts cursor up/down axis."
	MouseXDeadZoneText = "Cursor Left/Right Dead Zone"
	MouseXDeadZoneHelp = "Adjusts dead zone of left/right cursor input."
	MouseYDeadZoneText = "Cursor Up/Down Dead Zone"
	MouseYDeadZoneHelp = "Adjusts dead zone of up/down cursor input."
	DefXJoyMult=3.000000
	DefYJoyMult=3.000000
	DefXDeadZone=1.000000
	DefYDeadZone=1.000000
}
