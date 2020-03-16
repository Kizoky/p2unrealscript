///////////////////////////////////////////////////////////////////////////////
// MenuReticle.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The credits menu.
//
//	History:
//	01/26/03 JMI	Started from MenuImageCredits.
//
///////////////////////////////////////////////////////////////////////////////
// This class describes the reticle picking screen.
//
// Future enhancements:
//
///////////////////////////////////////////////////////////////////////////////
class MenuReticle extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

const c_fReticleMaxWidth		= 100;
const c_fReticleMaxHeight		= 100;
const c_fReticleMaxAlpha		= 128.0;
const c_fReticleMaxAlphaSlider	= 10.0;


var UWindowBitmap ImageReticle;

var localized string TitleText;

const c_strReticleTypePath = "Postal2Game.P2Player ReticleNum";
var UWindowHSliderControl ReticleTypeSlider;
var localized string ReticleTypeText;
var localized string ReticleTypeHelp;

const c_strReticleAlphaPath = "Postal2Game.P2Player ReticleAlpha";
var UWindowHSliderControl ReticleAlphaSlider;
var localized string ReticleAlphaText;
var localized string ReticleAlphaHelp;

const c_strReticleEnabledPath = "Postal2Game.P2Player bEnableReticle";
var UWindowCheckbox ReticleEnabledCheckbox;
var localized string ReticleEnabledText;
var localized string ReticleEnabledHelp;

var bool			bUpdate;	// Notifications of changes will be ignored when this is false.
var bool			bDrag;		// true if dragging the reticle.

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	
	// 02/16/03 JMI Removed title so we have more room and menu won't intercept crosshair.
	// AddTitle(TitleText, TitleFont, TitleAlign);
	
	ReticleEnabledCheckbox	= AddCheckbox(	ReticleEnabledText,	ReticleEnabledHelp,	ItemFont);
	ReticleTypeSlider		= AddSlider(	ReticleTypeText,	ReticleTypeHelp,	ItemFont, 0, ArrayCount(P2Player(GetPlayerOwner()).Reticles) - 1);	// -1 for inclusive
	ReticleAlphaSlider		= AddSlider(	ReticleAlphaText,	ReticleAlphaHelp,	ItemFont, 1, c_fReticleMaxAlphaSlider);
	RestoreChoice			= AddChoice(	RestoreText,		RestoreHelp,		ItemFont, ItemAlign);
	BackChoice				= AddChoice(	BackText,			"",					ItemFont, ItemAlign, true);
	
	ReticleTypeSlider.bDisplayVal		= false;
	ReticleTypeSlider.bNoSlidingNotify	= false;
	ReticleAlphaSlider.bNoSlidingNotify = false;
	
	// Don't LoadValues here--do it in Created after ImageReticle is created.
	}

///////////////////////////////////////////////////////////////////////////////
// Appears to be a post-creation event for adding children and stuff.
///////////////////////////////////////////////////////////////////////////////
function Created()
	{
	super.Created();
	
	ImageReticle = UWindowBitmap(CreateWindow(
		class'UWindowBitmap',
		(GetMenuWidth() - c_fReticleMaxWidth) / 2, 
		(GetMenuHeight() - c_fReticleMaxHeight) / 2, 
		c_fReticleMaxWidth, 
		c_fReticleMaxHeight) );
	
	ImageReticle.bStretch = false;	
	ImageReticle.bAlpha   = true;	
	ImageReticle.bFit	  = false;	
	ImageReticle.bCenter  = true;	
	
	LoadValues();
	}

///////////////////////////////////////////////////////////////////////////////
// Post resize.
///////////////////////////////////////////////////////////////////////////////
function Resized()
	{
	Super.Resized();
	// Center on window
	//	ImageReticle.WinLeft = (WinWidth - c_fReticleMaxWidth ) / 2;
	//	ImageReticle.WinTop  = ReticleAlphaSlider.WinTop - (ItemSpacingY + c_fReticleMaxHeight) / 2;
	}

///////////////////////////////////////////////////////////////////////////////
// Update the image displayed to the current reticle.
///////////////////////////////////////////////////////////////////////////////
function UpdateReticleImage()
	{
	local Texture texReticle;
	texReticle = P2Player(GetPlayerOwner()).GetReticleTexture();
	if (texReticle != none)
		{
		ImageReticle.T = texReticle;
		ImageReticle.R.X = 0;
		ImageReticle.R.Y = 0;
		ImageReticle.R.W = ImageReticle.T.USize;
		ImageReticle.R.H = ImageReticle.T.VSize;
		ImageReticle.DrawColor = P2Player(GetPlayerOwner()).GetReticleColor();
		
		ImageReticle.ShowWindow();
		}
	else
		ImageReticle.HideWindow();
	
	// Update all the weapons with the new settings.
	class'Postal2Game.P2Weapon'.static.ReticleUpdated(P2Player(GetPlayerOwner()));
	}

///////////////////////////////////////////////////////////////////////////////
// Set all values to defaults
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
	{
	ReticleTypeSlider.SetValue(2);
	ReticleAlphaSlider.SetValue(7);
	ReticleEnabledCheckbox.SetValue(true);
	}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
	{
	local int	iVal;
	local bool	bVal;
	
	bUpdate = false;
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get"@c_strReticleTypePath) );
	ReticleTypeSlider.SetValue(iVal);
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get"@c_strReticleAlphaPath) );
	iVal = iVal * c_fReticleMaxAlphaSlider / c_fReticleMaxAlpha;
	ReticleAlphaSlider.SetValue(iVal);
	
	bVal = bool(GetPlayerOwner().ConsoleCommand("get"@c_strReticleEnabledPath) );
	ReticleEnabledCheckbox.SetValue(bVal);
	
	bUpdate = true;
	}

///////////////////////////////////////////////////////////////////////////////
// Notification of mouse moves.
///////////////////////////////////////////////////////////////////////////////
function MouseMove(float X, float Y)
	{
	Super.MouseMove(X, Y);
	
	if (bDrag)
		{
		ImageReticle.WinLeft = X - ImageReticle.WinWidth / 2;
		ImageReticle.WinTop  = Y - ImageReticle.WinHeight / 2;
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
		case DE_LMouseDown:
			//		if (C == ImageReticle)
			bDrag = true;
			break;
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				case RestoreChoice:
					SetDefaultValues();
					break;
				}
			break;
		case DE_Change:
			switch (C)
				{
				case ReticleTypeSlider:
					ReticleTypeSliderChanged();
					break;
				case ReticleAlphaSlider:
					ReticleAlphaSliderChanged();
					break;
				case ReticleEnabledCheckbox:
					ReticleEnabledCheckboxChanged();
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Notification from the slider that its value has changed.
///////////////////////////////////////////////////////////////////////////////
function ReticleTypeSliderChanged()
	{
	if (bUpdate)
		{
		//GetPlayerOwner().ConsoleCommand("set"@c_strReticleTypePath@ReticleTypeSlider.GetValue() );
		P2Player(GetPlayerOwner()).Default.ReticleNum = ReticleTypeSlider.GetValue();
		P2Player(GetPlayerOwner()).ReticleNum = ReticleTypeSlider.GetValue();
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	
	UpdateReticleImage();
	}

///////////////////////////////////////////////////////////////////////////////
// Notification from the slider that its value has changed.
///////////////////////////////////////////////////////////////////////////////
function ReticleAlphaSliderChanged()
	{
	if (bUpdate)
		{
		//GetPlayerOwner().ConsoleCommand("set" @ c_strReticleAlphaPath @ (ReticleAlphaSlider.GetValue() * c_fReticleMaxAlpha / c_fReticleMaxAlphaSlider) );
		P2Player(GetPlayerOwner()).Default.ReticleAlpha = (ReticleAlphaSlider.GetValue() * c_fReticleMaxAlpha / c_fReticleMaxAlphaSlider);
		P2Player(GetPlayerOwner()).ReticleAlpha = (ReticleAlphaSlider.GetValue() * c_fReticleMaxAlpha / c_fReticleMaxAlphaSlider);
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	
	UpdateReticleImage();
	}

///////////////////////////////////////////////////////////////////////////////
// Notification from the slider that its value has changed.
///////////////////////////////////////////////////////////////////////////////
function ReticleEnabledCheckboxChanged()
	{
	if (bUpdate)
		{
		//GetPlayerOwner().ConsoleCommand("set" @ c_strReticleEnabledPath @ ReticleEnabledCheckbox.GetValue() );
		P2Player(GetPlayerOwner()).Default.bEnableReticle = ReticleEnabledCheckbox.GetValue();
		P2Player(GetPlayerOwner()).bEnableReticle = ReticleEnabledCheckbox.GetValue();
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	
	UpdateReticleImage();
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	MenuWidth  = 640
	MenuHeight = 480
	BorderTop = 0
	BorderBottom = 150

	TitleText			= "Crosshair Settings";
	// 02/16/03 JMI Removed title so we have more room and menu won't intercept crosshair.
	TitleHeight			= 0;
	TitleSpacingY		= 0;

	ReticleTypeText		= "Crosshair Type"
	ReticleTypeHelp		= "Choose the crosshair to use in the game"
	ReticleAlphaText	= "Crosshair Intensity"
	ReticleAlphaHelp	= "Adjust the intensity of the crosshair"
	ReticleEnabledText	= "Enable Crosshair"
	ReticleEnabledHelp	= "Turn crosshair on or off"
	}
