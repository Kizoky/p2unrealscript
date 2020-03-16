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
class MenuControlsEditGamepad2 extends MenuControlsEdit;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string ControlsTitleText;

var UWindowHSliderControl MoveSenseSlider, StrafeSpeedSlider, MoveSpeedSlider, LookXSpeedSlider, LookYSpeedSlider, StrafeDeadZoneSlider, MoveDeadZoneSlider, LookXDeadZoneSlider, LookYDeadZoneSlider, ResponsivenessSliderX, ResponsivenessSliderY;
var localized string MoveSenseText, StrafeSpeedText, MoveSpeedText, LookXSpeedText, LookYSpeedText, StrafeDeadZoneText, MoveDeadZoneText, LookXDeadZoneText, LookYDeadZoneText, ResponsivenessTextX, ResponsivenessTextY;
var localized string MoveSenseHelp, StrafeSpeedHelp, MoveSpeedHelp, LookXSpeedHelp, LookYSpeedHelp, StrafeDeadZoneHelp, MoveDeadZoneHelp, LookXDeadZoneHelp, LookYDeadZoneHelp, ResponsivenessHelpX, ResponsivenessHelpY;

var UWindowCheckbox StrafeInvertCheckbox, MoveInvertCheckbox, LookXInvertCheckbox, LookYInvertCheckbox;
var localized string StrafeInvertText, MoveInvertText, LookXInvertText, LookYInvertText;
var localized string StrafeInvertHelp, MoveInvertHelp, LookXInvertHelp, LookYInvertHelp;

var bool bUpdate;

const SensitivityPath = "Postal2Game.P2Player JoySensitivity";
const ResponsivenessPathX = "Postal2Game.P2Player LookSensitivityX";
const ResponsivenessPathY = "Postal2Game.P2Player LookSensitivityY";

var float DefJoySensitivity, DefLookSensitivityX, DefLookSensitivityY, DefSpeedBase, DefDeadZone;

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
	
	MoveSenseSlider = AddSlider(MoveSenseText, MoveSenseHelp, ItemFont, 1, 10);

	MoveSpeedSlider = AddSlider(MoveSpeedText, MoveSpeedHelp, ItemFont, 0, 10);
	MoveDeadZoneSlider = AddSlider(MoveDeadZoneText, MoveDeadZoneHelp, ItemFont, 0, 10);
	MoveInvertCheckbox = AddCheckbox(MoveInvertText, MoveInvertHelp, ItemFont);

	StrafeSpeedSlider = AddSlider(StrafeSpeedText, StrafeSpeedHelp, ItemFont, 0, 10);
	StrafeDeadZoneSlider = AddSlider(StrafeDeadZoneText, StrafeDeadZoneHelp, ItemFont, 0, 10);
	StrafeInvertCheckbox = AddCheckbox(StrafeInvertText, StrafeInvertHelp, ItemFont);

	ResponsivenessSliderY = AddSlider(ResponsivenessTextY, ResponsivenessHelpY, ItemFont, 1, 10);
	LookYSpeedSlider = AddSlider(LookYSpeedText, LookYSpeedHelp, ItemFont, 0, 10);
	LookYDeadZoneSlider = AddSlider(LookYDeadZoneText, LookYDeadZoneHelp, ItemFont, 0, 10);
	LookYInvertCheckbox = AddCheckbox(LookYInvertText, LookYInvertHelp, ItemFont);

	ResponsivenessSliderX = AddSlider(ResponsivenessTextX, ResponsivenessHelpX, ItemFont, 1, 10);
	LookXSpeedSlider = AddSlider(LookXSpeedText, LookXSpeedHelp, ItemFont, 0, 10);
	LookXDeadZoneSlider = AddSlider(LookXDeadZoneText, LookXDeadZoneHelp, ItemFont, 0, 10);
	LookXInvertCheckbox = AddCheckbox(LookXInvertText, LookXInvertHelp, ItemFont);

	ItemHeight = Default.ItemHeight;

	// Load the values into the menu items.
	LoadValues();

	RestoreChoice	= AddChoice(RestoreText,	RestoreHelp,	ItemFont, ItemAlign);
	BackChoice		= AddChoice(BackText,		"",				ItemFont, ItemAlign, true);
	
	bUpdate = true;
}

///////////////////////////////////////////////////////////////////////////////
// extract Speed and DeadZone values
///////////////////////////////////////////////////////////////////////////////
function GetSliderValues(string Binding, out float SpeedBase, out float DeadZone, out int Invert)
{
	local array<String> Args, Values;
	local int i, j;
	
	// Default to sane values
	SpeedBase = 4.0;
	DeadZone = 0.20;
	Invert = 1;
	
	Args = Split(Binding," ");
	for (i = 0; i < Args.Length; i++)
	{
		if (Caps(Left(Args[i],10)) == "SPEEDBASE=")
			SpeedBase = Float(Right(Args[i], Len(Args[i]) - 10));
		if (Caps(Left(Args[i],9)) == "DEADZONE=")
			DeadZone = Float(Right(Args[i], Len(Args[i]) - 9));
		if (Caps(Left(Args[i],7)) == "INVERT=")
			Invert = Int(Right(Args[i], Len(Args[i]) - 7));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Load slider data
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
{
	local string useKey;
	local string useBinding;
	local float SpeedBase, DeadZone, Sensitivity, ResponsivenessX, ResponsivenessY;
	local int Invert, SensitivitySlider;
	
	Super.LoadValues();
	
	// Sensitivity
	Sensitivity = Float(GetPlayerOwner().ConsoleCommand("GET"@SensitivityPath));
	SensitivitySlider = 11 - Clamp(Int(Sensitivity * 5.0), 1, 10);
	MoveSenseSlider.SetValue(SensitivitySlider, true);
	
	ResponsivenessX = Float(GetPlayerOwner().ConsoleCommand("GET"@ResponsivenessPathX));
	ResponsivenessSliderX.SetValue(FClamp((ResponsivenessX - 1.0) * 10.0, 1.0, 10.0));
	ResponsivenessY = Float(GetPlayerOwner().ConsoleCommand("GET"@ResponsivenessPathY));
	ResponsivenessSliderY.SetValue(FClamp((ResponsivenessY - 1.0) * 10.0, 1.0, 10.0));
	//log("get responsiveness"@((ResponsivenessX - 1.0) * 10.0)@((ResponsivenessY - 1.0) * 10.0));
	
	// Movement
	useKey = aBindings[0].aStrKeys[0];
	useBinding = GetPlayerOwner().ConsoleCommand("KEYBINDING"@useKey);
	GetSliderValues(useBinding, SpeedBase, DeadZone, Invert);
	MoveSpeedSlider.SetValue(SpeedBase, true);
	MoveDeadZoneSlider.SetValue(DeadZone * 10, true);
	MoveInvertCheckbox.SetValue(Invert == -1);	
	
	// Strafe
	useKey = aBindings[1].aStrKeys[0];
	useBinding = GetPlayerOwner().ConsoleCommand("KEYBINDING"@useKey);
	GetSliderValues(useBinding, SpeedBase, DeadZone, Invert);
	StrafeSpeedSlider.SetValue(SpeedBase, true);
	StrafeDeadZoneSlider.SetValue(DeadZone * 10, true);
	StrafeInvertCheckbox.SetValue(Invert == -1);
	
	// Look Up/Down
	useKey = aBindings[2].aStrKeys[0];
	useBinding = GetPlayerOwner().ConsoleCommand("KEYBINDING"@useKey);
	GetSliderValues(useBinding, SpeedBase, DeadZone, Invert);
	LookYSpeedSlider.SetValue(SpeedBase, true);
	LookYDeadZoneSlider.SetValue(DeadZone * 10, true);
	LookYInvertCheckbox.SetValue(Invert == -1);

	// Look Left/Right
	useKey = aBindings[3].aStrKeys[0];
	useBinding = GetPlayerOwner().ConsoleCommand("KEYBINDING"@useKey);
	GetSliderValues(useBinding, SpeedBase, DeadZone, Invert);
	LookXSpeedSlider.SetValue(SpeedBase, true);
	LookXDeadZoneSlider.SetValue(DeadZone * 10, true);
	LookXInvertCheckbox.SetValue(Invert == -1);
}

///////////////////////////////////////////////////////////////////////////////
// Set the stored value.
///////////////////////////////////////////////////////////////////////////////
function SetValue(out Binding bind)
{
	local string strAliases;
	local int	 iIter, i;
	local array<String> aStrAliases;	
	local bool bFound;
	local string useAlias;
	
	for (iIter = 0; iIter < bind.astrKeys.Length; iIter++)
	{
		if (Len(bind.astrKeys[iIter] ) > 0)
		{
			// Start with baseline (keys we don't know about in this menu), if any.
			strAliases = aBaselines[bind.aiKeys[iIter] ];
			
			// If a "no clear" binding, start with ENTIRE keybind
			if (bind.ctrl.bNoClear)
				strAliases = GetPlayerOwner().ConsoleCommand("KEYBINDING"@bind.aStrKeys[iIter]);
			
			// Remove previous bindings of this type.
			aStrAliases = Split(strAliases, "|");
			strAliases = ""; // reset
			bFound = false;
			for (i = 0; i < aStrAliases.Length; i++)
				if (!IsBinding(aStrAliases[i], bind.ctrl))
				{
					if (!bFound)
						bFound = true;
					else
						strAliases = strAliases $ " | ";
					strAliases = strAliases $ aStrAliases[i];						
				}

			// If there's anything so far, use a delimiter.
			if (Len(strAliases) > 0)
				strAliases = strAliases $ " | ";

			// put together our alias
			useAlias = "AXIS" @ bind.ctrl.strAlias;
			
			// Movement
			if (bind == aBindings[0])
			{
				useAlias = useAlias @ "SPEEDBASE=" $ string(MoveSpeedSlider.GetValue());
				useAlias = useAlias @ "DEADZONE=" $ string(MoveDeadZoneSlider.GetValue() / 10.0);
				if (MoveInvertCheckbox.GetValue())
					useAlias = useAlias @ "INVERT=-1";
			}
			// Strafe
			if (bind == aBindings[1])
			{
				useAlias = useAlias @ "SPEEDBASE=" $ string(StrafeSpeedSlider.GetValue());
				useAlias = useAlias @ "DEADZONE=" $ string(StrafeDeadZoneSlider.GetValue() / 10.0);
				if (StrafeInvertCheckbox.GetValue())
					useAlias = useAlias @ "INVERT=-1";
			}
			// LookUp
			if (bind == aBindings[2])
			{
				useAlias = useAlias @ "SPEEDBASE=" $ string(LookYSpeedSlider.GetValue());
				useAlias = useAlias @ "DEADZONE=" $ string(LookYDeadZoneSlider.GetValue() / 10.0);
				if (LookYInvertCheckbox.GetValue())
					useAlias = useAlias @ "INVERT=-1";
			}
			// Look
			if (bind == aBindings[3])
			{
				useAlias = useAlias @ "SPEEDBASE=" $ string(LookXSpeedSlider.GetValue());
				useAlias = useAlias @ "DEADZONE=" $ string(LookXDeadZoneSlider.GetValue() / 10.0);
				if (LookXInvertCheckbox.GetValue())
					useAlias = useAlias @ "INVERT=-1";
			}
			
			strAliases = strAliases $ useAlias;
			//log("set input"@bind.astrkeys[iIter]@strAliases);
			GetPlayerOwner().ConsoleCommand("SET Input"@bind.astrKeys[iIter]@strAliases);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the controls to be edited.  Tells the base class what to edit.
///////////////////////////////////////////////////////////////////////////////

//ErikFOV Change: for localization
/*function array<Control> GetControls()
{
	return aGamepadControls2;
}*/

function GetControls(out array<Control> Controls, out array<String> Labels)
{
	Controls = aGamepadControls2;
	Labels = aGamepadControls2Label;
	return;
}
//end

///////////////////////////////////////////////////////////////////////////////
// Handle changes
///////////////////////////////////////////////////////////////////////////////
function SliderChanged(int bindingNo)
{
	local int i;
	local float f;
	/*
	for (i = 0; i < aBindings[bindingNo].aiKeys.Length; i++)
	{
		// wipe baseline to fool SetValue
		aBaselines[aBindings[bindingNo].aiKeys[i] ] = "";
	}
	*/
	// now re-set them with the updated slider values
	SetValue(aBindings[bindingNo]);
	
	// Movement speed slider uses a different set value
	if (bindingNo == 0)
	{
		i = 11 - MoveSenseSlider.GetValue();
		// Get actual JoySensitivity value from slider.
		f = i / 5.0;
		GetPlayerOwner().ConsoleCommand("SET"@SensitivityPath@f);
	}
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
				case MoveSpeedSlider:
				case MoveSenseSlider:
				case MoveDeadZoneSlider:
				case MoveInvertCheckbox:
					SliderChanged(0);
					break;
					
				case StrafeSpeedSlider:
				case StrafeDeadZoneSlider:
				case StrafeInvertCheckbox:
					SliderChanged(1);
					break;

				case LookYSpeedSlider:
				case LookYDeadZoneSlider:
				case LookYInvertCheckbox:
					SliderChanged(2);
					break;

				case LookXSpeedSlider:
				case LookXDeadZoneSlider:
				case LookXInvertCheckbox:
					SliderChanged(3);
					break;
					
				case ResponsivenessSliderX:
				case ResponsivenessSliderY:
					ResponsivenessSliderChanged();
					break;
			}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ResponsivenessSliderChanged()
{
	local float ResponsivenessX, ResponsivenessY;
	
	if (bUpdate)
	{
		ResponsivenessX = 1.0 + (ResponsivenessSliderX.GetValue()) / 10.0;
		ResponsivenessY = 1.0 + (ResponsivenessSliderY.GetValue()) / 10.0;
		//log("set responsiveness"@ResponsivenessX@ResponsivenessY);
		
		GetPlayerOwner().ConsoleCommand("SET"@ResponsivenessPathX@ResponsivenessX);
		GetPlayerOwner().ConsoleCommand("SET"@ResponsivenessPathY@ResponsivenessY);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to defaults.
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
{
	local string useKey;
	local string useBinding;
	local float SpeedBase, DeadZone, Sensitivity, ResponsivenessX, ResponsivenessY;
	local int Invert, SensitivitySlider;

	// Set defaults for keybinds
	Super.SetDefaultValues();

	// Sensitivity
	Sensitivity = DefJoySensitivity;
	SensitivitySlider = 11 - Clamp(Int(Sensitivity * 5.0), 1, 10);
	MoveSenseSlider.SetValue(SensitivitySlider, true);
	
	ResponsivenessX = DefLookSensitivityX;
	ResponsivenessSliderX.SetValue(FClamp((ResponsivenessX - 1.0) * 10.0, 1.0, 10.0));
	ResponsivenessY = DefLookSensitivityY;
	ResponsivenessSliderY.SetValue(FClamp((ResponsivenessY - 1.0) * 10.0, 1.0, 10.0));
//	log("get responsiveness"@((ResponsivenessX - 1.0) * 10.0)@((ResponsivenessY - 1.0) * 10.0));
	
	SpeedBase = DefSpeedBase;
	DeadZone = DefDeadZone;
	Invert = 0;
	// Movement	
	MoveSpeedSlider.SetValue(SpeedBase, true);
	MoveDeadZoneSlider.SetValue(DeadZone * 10, true);
	MoveInvertCheckbox.SetValue(Invert == -1);	
	
	// Strafe
	StrafeSpeedSlider.SetValue(SpeedBase, true);
	StrafeDeadZoneSlider.SetValue(DeadZone * 10, true);
	StrafeInvertCheckbox.SetValue(Invert == -1);
	
	// Look Up/Down
	LookYSpeedSlider.SetValue(SpeedBase, true);
	LookYDeadZoneSlider.SetValue(DeadZone * 10, true);
	LookYInvertCheckbox.SetValue(Invert == -1);

	// Look Left/Right
	LookXSpeedSlider.SetValue(SpeedBase + 1, true);
	LookXDeadZoneSlider.SetValue(DeadZone * 10, true);
	LookXInvertCheckbox.SetValue(Invert == -1);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ControlsTitleText = "Gamepad Movement"
	StrafeSpeedText = "Strafe Speed"
	StrafeSpeedHelp = "Adjusts speed of strafe left/right input."
	StrafeInvertText = "Strafe Invert"
	StrafeInvertHelp = "Inverts left/right strafe axis."
	MoveSenseText = "Movement Sensitivity"
	MoveSenseHelp = "Adjusts sensitivity of movement input (all directions)."
	MoveSpeedText = "Movement Speed"
	MoveSpeedHelp = "Adjusts speed of forward/backward input."
	MoveInvertText = "Forward/Backward Invert"
	MoveInvertHelp = "Inverts forward/backward movement axis."
	LookXSpeedText = "Look Left/Right Speed"
	LookXSpeedHelp = "Adjusts speed of left/right look input."
	LookXInvertText = "Look Left/Right Invert"
	LookXInvertHelp = "Inverts look left/right axis."
	LookYSpeedText = "Look Up/Down Speed"
	LookYSpeedHelp = "Adjusts speed of up/down look input."
	LookYInvertText = "Look Up/Down Invert"
	LookYInvertHelp = "Inverts look up/down axis."
	StrafeDeadZoneText = "Strafe Dead Zone"
	StrafeDeadZoneHelp = "Adjusts dead zone of strafe left/right input."
	MoveDeadZoneText = "Movement Dead Zone"
	MoveDeadZoneHelp = "Adjusts dead zone of forward/backward movement input."
	LookXDeadZoneText = "Look Left/Right Dead Zone"
	LookXDeadZoneHelp = "Adjusts dead zone of left/right look input."
	ResponsivenessTextX = "Look Left/Right Responsiveness"
	ResponsivenessHelpX = "Adjusts the responsiveness of the left/right look axis. The higher the number, the quicker your look speed will accelerate to the stick position."
	LookYDeadZoneText = "Look Up/Down Dead Zone"
	LookYDeadZoneHelp = "Adjusts dead zone of up/down look input."
	ResponsivenessTextY = "Look Up/Down Responsiveness"
	ResponsivenessHelpY = "Adjusts the responsiveness of the left/right look axis. The higher the number, the quicker your look speed will accelerate to the stick position."
	DefJoySensitivity=1.4
	DefLookSensitivityX=1.4
	DefLookSensitivityY=1.5
	DefSpeedBase=4.00
	DefDeadZone=0.10
}
