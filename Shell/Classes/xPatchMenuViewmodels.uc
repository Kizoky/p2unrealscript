///////////////////////////////////////////////////////////////////////////////
// xPatchMenu.uc
//
// Settings menu for xPatch 2.0 
// by Man Chrzan 
///////////////////////////////////////////////////////////////////////////////
class xPatchMenuViewmodels extends xPatchMenuBase;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

// Overwrite Weapons Prop
var UWindowCheckbox		OverwriteCheckbox;
var localized string	OverwriteText;
var localized string	OverwriteHelp;
const OverwritePath = "Postal2Game.xPatchManager bOverwriteWeaponProperties";

const BobPath = "Postal2Game.xPatchManager fWeaponBob";
var UWindowHSliderControl WeaponBobSlider;
var localized string WeaponBobText, WeaponBobSliderHelp;
const WeaponBobMax		= 1.15;
const WeaponBobMin		= 1.00;
const WeaponBobIncrease	= 0.05;
const c_fWeaponBobMaxSlider	= 3.0;

const GlowPath = "Postal2Game.xPatchManager iWeaponBrightness";
var UWindowHSliderControl WeaponGlowSlider;
var localized string WeaponGlowText;
var localized string WeaponGlowHelp;
const WeaponGlowMax			= 128;
const WeaponGlowMaxSlider	= 8;

const WFOVPath = "Postal2Game.xPatchManager fWeaponFOV";
var UWindowHSliderControl WeaponFOVSlider;
var localized string WeaponFOVText;
var localized string WeaponFOVSliderHelp;
const WeaponFOVMax			= 25;
const WeaponFOVMaxSlider	= 25;
const WeaponFOVMinSlider	= -25;

const XOffsetPath = "Postal2Game.xPatchManager fWeaponXoffset";
const YOffsetPath = "Postal2Game.xPatchManager fWeaponYoffset";
const ZOffsetPath = "Postal2Game.xPatchManager fWeaponZoffset";
var UWindowHSliderControl WeaponOffsetSliderX, WeaponOffsetSliderY, WeaponOffsetSliderZ;
var localized string WeaponOffsetTextX, WeaponOffsetTextY, WeaponOffsetTextZ;
var localized string WeaponOffsetHelpX, WeaponOffsetHelpY, WeaponOffsetHelpZ;
const WeaponOffsetMax		= 15;
const WeaponOffsetMaxSlider	= 30;
const WeaponOffsetMinSlider	= -30;

//////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super(ShellMenuCW).CreateMenuContents();
	
	AddTitle(TitleText, TitleFont, TitleAlign);
	
	// NOTE: Fixed it
	//WrappedText = AddWrappedTextItem(tmparray, 100, F_Bold, ItemAlign);
	//WrappedText.Text = WarningText;
	//WrappedText.SetTextColor(CustomColor);
	//WrappedText.bShadow = true;
	
	OverwriteCheckbox   = AddCheckbox(OverwriteText, OverwriteHelp, ItemFont);
	WeaponBobSlider		= AddSlider(WeaponBobText,	WeaponBobSliderHelp,	ItemFont, 0, c_fWeaponBobMaxSlider);
	WeaponGlowSlider	= AddSlider(WeaponGlowText,	WeaponGlowHelp,			ItemFont, 0, WeaponGlowMaxSlider);
	WeaponFOVSlider		= AddSlider(WeaponFOVText,	WeaponFOVSliderHelp,	ItemFont, WeaponFOVMinSlider, WeaponFOVMaxSlider);
	WeaponOffsetSliderZ	= AddSlider(WeaponOffsetTextZ,	WeaponOffsetHelpZ,	ItemFont, WeaponOffsetMinSlider, WeaponOffsetMaxSlider);
	WeaponOffsetSliderX	= AddSlider(WeaponOffsetTextX,	WeaponOffsetHelpX,	ItemFont, WeaponOffsetMinSlider, WeaponOffsetMaxSlider);
	WeaponOffsetSliderY	= AddSlider(WeaponOffsetTextY,	WeaponOffsetHelpY,	ItemFont, WeaponOffsetMinSlider, WeaponOffsetMaxSlider);
	
	RestoreChoice    	= AddChoice(RestoreText, RestoreHelp,	ItemFont, ItemAlign);
	BackChoice       	= AddChoice(BackText,    "",			ItemFont, ItemAlign, true);
	
	WeaponGlowSlider.bNoSlidingNotify	= false;
	WeaponFOVSlider.bNoSlidingNotify = false;
	WeaponOffsetSliderZ.bNoSlidingNotify = false;
	WeaponOffsetSliderX.bNoSlidingNotify = false;
	WeaponOffsetSliderY.bNoSlidingNotify = false;
	
	// Shows viewmodel in menu
	P2Player(GetPlayerOwner()).bForceViewmodel=True;

	LoadValues();
	}

function OnCleanUp()
{
	// Hides viewmodel
	P2Player(GetPlayerOwner()).bForceViewmodel=False;
	Super.OnCleanUp();
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
				case OverwriteCheckbox:
					OverwriteCheckboxChanged();
					break;	
				case WeaponBobSlider:
					WeaponBobSliderChanged();
					break;	
				case WeaponGlowSlider:
					WeaponGlowSliderChanged();
					break;	
				case WeaponFOVSlider:
					WeaponFOVSliderChanged();
					break;
				case WeaponOffsetSliderX:
					WeaponOffsetSliderChanged('X');
					break;	
				case WeaponOffsetSliderY:
					WeaponOffsetSliderChanged('Y');
					break;	
				case WeaponOffsetSliderZ:
					WeaponOffsetSliderChanged('Z');
					break;
			}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
{
	local float fVal;
	local bool flag;
	
	bUpdate = false;

	///////////////////////////////////////////////////////////////////////////
	
	// Overwrite Weapon Properties
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@OverwritePath));
	OverwriteCheckbox.SetValue(flag);

	// Weapon Bob
	fVal = float(GetPlayerOwner().ConsoleCommand("get"@BobPath));
	fVal = ((fVal - WeaponBobMin) / WeaponBobIncrease);
	WeaponBobSlider.SetValue(fVal);
	
	// Weapon Brightness
	fVal = float(GetPlayerOwner().ConsoleCommand("get"@GlowPath) );
	fVal = fVal * WeaponGlowMaxSlider / WeaponGlowMax;
	WeaponGlowSlider.SetValue(fVal);
	
	// Weapon FOV
	fVal = float(GetPlayerOwner().ConsoleCommand("get"@WFOVPath) );
	fVal = fVal * WeaponFOVMaxSlider / WeaponFOVMax;
	WeaponFOVSlider.SetValue(fVal);
	
	// Weapon X
	fVal = float(GetPlayerOwner().ConsoleCommand("get"@XOffsetPath) );
	fVal = fVal * WeaponOffsetMaxSlider / WeaponOffsetMax;
	WeaponOffsetSliderX.SetValue(fVal);
	
	// Weapon Y
	fVal = float(GetPlayerOwner().ConsoleCommand("get"@YOffsetPath) );
	fVal = fVal * WeaponOffsetMaxSlider / WeaponOffsetMax;
	WeaponOffsetSliderY.SetValue(fVal);
	
	// Weapon Z
	fVal = float(GetPlayerOwner().ConsoleCommand("get"@ZOffsetPath) );
	fVal = fVal * WeaponOffsetMaxSlider / WeaponOffsetMax;
	WeaponOffsetSliderZ.SetValue(fVal);
	
	///////////////////////////////////////////////////////////////////////////

	bUpdate = true;
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to default
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
{
	RestoringDefaults = True;
	
	///////////////////////////////////////////////////////////////////////////
	
	//OverwriteCheckbox.SetValue(False);
	WeaponFOVSlider.SetValue(0);
	WeaponBobSlider.SetValue(2); 
	WeaponGlowSlider.SetValue(8);
	WeaponOffsetSliderX.SetValue(0);
	WeaponOffsetSliderY.SetValue(0);
	WeaponOffsetSliderZ.SetValue(0);
	
	///////////////////////////////////////////////////////////////////////////
	
	RestoringDefaults = False;
}

///////////////////////////////////////////////////////////////////////////////
// Changed Viewmodels
///////////////////////////////////////////////////////////////////////////////

function OverwriteCheckboxChanged()
{
	if (bUpdate)
	{
		GetPlayerOwner().ConsoleCommand("set" @ OverwritePath @ OverwriteCheckbox.GetValue());
		
		if(OverwriteCheckbox.bChecked) // Update all the weapons with the new settings.
			class'Postal2Game.P2Weapon'.static.ViewmodelSettingsUpdated(P2Player(GetPlayerOwner()), False);
		else // Restore default properties for all weapons.
			class'Postal2Game.P2Weapon'.static.ViewmodelSettingsUpdated(P2Player(GetPlayerOwner()), True);
			
		//GetPlayerOwner().ClientMessage("Weapon Setup - Defaults:"@ OverwriteCheckbox.GetValue());
	}
}

function WeaponBobSliderChanged()
{
	local float mafh;
	
	if (bUpdate)
	{
		mafh = (WeaponBobMin + (WeaponBobSlider.GetValue() * WeaponBobIncrease));
		
		GetPlayerOwner().ConsoleCommand("set" @ BobPath @ mafh);
		//GetPlayerOwner().ClientMessage("New Bob:"@ mafh);
		
		// Update all the weapons with the new settings.
		class'Postal2Game.P2Weapon'.static.ViewmodelSettingsUpdated(P2Player(GetPlayerOwner()), False);
		
		if(!OverwriteCheckbox.bChecked && !RestoringDefaults) // Not enabled!
			ShowWarning(InfoTitle, OverwriteDisText);
	}
}

function WeaponGlowSliderChanged()
{
	local float mafh;
	
	if (bUpdate)
	{
		mafh = (WeaponGlowSlider.GetValue() * WeaponGlowMax / WeaponGlowMaxSlider);
		
		GetPlayerOwner().ConsoleCommand("set" @ GlowPath @ mafh);
		//GetPlayerOwner().ClientMessage("New Brightness:"@ mafh);
		
		
		// Update all the weapons with the new settings.
		class'Postal2Game.P2Weapon'.static.ViewmodelSettingsUpdated(P2Player(GetPlayerOwner()), False);
		
		if(!OverwriteCheckbox.bChecked && !RestoringDefaults) // Not enabled!
			ShowWarning(InfoTitle, OverwriteDisText);
	}
}

function WeaponFOVSliderChanged()
{
	local float mafh;
	
	if (bUpdate)
	{
		mafh = (WeaponFOVSlider.GetValue() * WeaponFOVMax / WeaponFOVMaxSlider);
		
		GetPlayerOwner().ConsoleCommand("set" @ WFOVPath @ mafh);
		//GetPlayerOwner().ClientMessage("New FOV:"@ mafh);
		
		// Update all the weapons with the new settings.
		class'Postal2Game.P2Weapon'.static.ViewmodelSettingsUpdated(P2Player(GetPlayerOwner()), False);
		
		if(!OverwriteCheckbox.bChecked && !RestoringDefaults) // Not enabled!
			ShowWarning(InfoTitle, OverwriteDisText);
	}
}

function WeaponOffsetSliderChanged(name XYZ)
{
	local float mafh;
	local string pafh;
	
	if (bUpdate)
	{
		if(XYZ == 'X')
		{
			mafh = (WeaponOffsetSliderX.GetValue() * WeaponOffsetMax / WeaponOffsetMaxSlider);
			pafh = XOffsetPath;
		}
		else if(XYZ == 'Y')
		{
			mafh = (WeaponOffsetSliderY.GetValue() * WeaponOffsetMax / WeaponOffsetMaxSlider);
			pafh = YOffsetPath;
		}
		else if(XYZ == 'Z')
		{
			mafh = (WeaponOffsetSliderZ.GetValue() * WeaponOffsetMax / WeaponOffsetMaxSlider);
			pafh = ZOffsetPath;
		}
		
		GetPlayerOwner().ConsoleCommand("set" @ pafh @ mafh);
		//GetPlayerOwner().ClientMessage("New:"@ pafh @ mafh);
		
		// Update all the weapons with the new settings.
		class'Postal2Game.P2Weapon'.static.ViewmodelSettingsUpdated(P2Player(GetPlayerOwner()), False);
		
		if(!OverwriteCheckbox.bChecked && !RestoringDefaults) // Not enabled!
			ShowWarning(InfoTitle, OverwriteDisText);
	}
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	TitleText="Weapon Viewmodel Options"
	//WarningText = "WARNING: Messing around with FOV or Offset settings might (temporarily) alter your camera FOV. To fix this, type 'FOV 85' in the console, change it back in the performance settings, or go through a load zone."
	MenuWidth=650
	
	OverwriteText = "Override Properties"
	OverwriteHelp = "Enable for the below settings to work. Normally, these properties are already defined individually for every weapon. These options allow them to be overridden with with new global settings."
	
	WeaponBobText = "Weapon Bob"
	WeaponBobSliderHelp="Adjusts how much the weapon moves up and down as you walk."
	
	WeaponGlowText = "Brightness"
	WeaponGlowHelp = "Adjusts the 'AmbientGlow' value of all weapons."
	
	WeaponFOVText	= "Weapon FOV"
	WeaponFOVSliderHelp	= "Additional value to the default field of view of the weapon viewmodel.\\nNOTE: Camera FOV can be changed in performance options."
	
	WeaponOffsetTextX = "Depth Offset"
	WeaponOffsetHelpX = "Adjust viewmodel position (back to forward)."
	
	WeaponOffsetTextY = "Horizontal Offset"
	WeaponOffsetHelpY = "Adjust viewmodel position (left to right)."
	
	WeaponOffsetTextZ = "Vertical Offset"
	WeaponOffsetHelpZ = "Adjust viewmodel position (down to up)."
}
