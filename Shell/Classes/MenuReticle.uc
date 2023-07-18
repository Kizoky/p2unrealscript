///////////////////////////////////////////////////////////////////////////////
// MenuReticle.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The credits menu.
//
//	History:
//	01/26/03 JMI	Started from MenuImageCredits.
//  11/20/21 ManChrzan	Implemented color settings and new draw style.
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

// xPatch: More Options
const c_strReticleGroupPath = "Postal2Game.P2Player ReticleGroup";
var UWindowComboControl CrosshairGroupCombo;
var localized string 	CrosshairGroup[2];
var localized string	CrosshairGroupText;
var localized string 	CrosshairGroupHelp;

const c_strHUDRender = "Postal2Game.P2Player bHUDCrosshair";
var UWindowCheckbox HUDRenderCheckbox;
var localized string HUDRenderText;
var localized string HUDRenderHelp;

const c_strNoCustomReticles = "Postal2Game.P2Player bNoCustomCrosshairs";
var UWindowCheckbox NoCustomReticlesCheckbox;
var localized string NoCustomReticlesText;
var localized string NoCustomReticlesHelp;


const c_strReticleRedPath = "Postal2Game.P2Player ReticleRed";
const c_strReticleGreenPath = "Postal2Game.P2Player ReticleGreen";
const c_strReticleBluePath = "Postal2Game.P2Player ReticleBlue";
const c_strReticleSizePath = "Postal2Game.P2Player ReticleSize";
var UWindowHSliderControl ReticleRedSlider, ReticleGreenSlider, ReticleBlueSlider, ReticleSizeSlider;
var localized string ReticleRedText, ReticleGreenText, ReticleBlueText, ReticleSizeText;
var localized string ReticleSizeHelp, ReticleColorHelp, ExplainText;
const c_fReticleMaxColor		= 255.0;
const c_fReticleMaxColorSlider	= 15.0;
const c_fReticleMaxSize			= 2.0;
const c_fReticleMaxSizeSlider	= 8.0;
var int GroupVal;				// 0 Classic; 1 Updated
var bool CustomIsNotNone;		// Returns True if custom crosshair is set up.
// End

var bool			bUpdate;	// Notifications of changes will be ignored when this is false.
var bool			bDrag;		// true if dragging the reticle.

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	GroupVal = int(GetPlayerOwner().ConsoleCommand("get" @ c_strReticleGroupPath));	
	CustomIsNotNone = P2Player(GetPlayerOwner()).IsCustomReticle();
	
	Super.CreateMenuContents();
	
	// 02/16/03 JMI Removed title so we have more room and menu won't intercept crosshair.
	// AddTitle(TitleText, TitleFont, TitleAlign);
	
	ReticleEnabledCheckbox	= AddCheckbox(	ReticleEnabledText,		ReticleEnabledHelp,		ItemFont);
	HUDRenderCheckbox		= AddCheckbox(	HUDRenderText,			HUDRenderHelp,			ItemFont);
	NoCustomReticlesCheckbox	= AddCheckbox(	NoCustomReticlesText,		NoCustomReticlesHelp,		ItemFont);
	CrosshairGroupCombo		= AddComboBox(	CrosshairGroupText, 	CrosshairGroupHelp, 	ItemFont);
	
	//if(GroupVal == 2 && !CustomIsNotNone)
	//	EpicMessage();
	//else	
	//{
	//	if(GroupVal != 2)	// It's useless for custom crosshair
	//	{
			if(GroupVal == 0)
				ReticleTypeSlider		= AddSlider(	ReticleTypeText,	ReticleTypeHelp,	ItemFont, 0, ArrayCount(P2Player(GetPlayerOwner()).Reticles) - 1);	// -1 for inclusive
			else
				ReticleTypeSlider		= AddSlider(	ReticleTypeText,	ReticleTypeHelp,	ItemFont, 0, ArrayCount(P2Player(GetPlayerOwner()).NewReticles) - 1);	// -1 for inclusive
	//	}
		
		ReticleAlphaSlider		= AddSlider(	ReticleAlphaText,	ReticleAlphaHelp,	ItemFont, 1, c_fReticleMaxAlphaSlider);
		ReticleSizeSlider		= AddSlider(	ReticleSizeText,	ReticleSizeHelp,	ItemFont, 1, c_fReticleMaxSizeSlider);
		
		if(GroupVal > 0)
		{
			ReticleRedSlider		= AddSlider(	ReticleRedText,		ReticleColorHelp,	ItemFont, 1, c_fReticleMaxColorSlider);
			ReticleGreenSlider		= AddSlider(	ReticleGreenText,	ReticleColorHelp,	ItemFont, 1, c_fReticleMaxColorSlider);
			ReticleBlueSlider		= AddSlider(	ReticleBlueText,	ReticleColorHelp,	ItemFont, 1, c_fReticleMaxColorSlider);
		}
	//}
	
	RestoreChoice			= AddChoice(	RestoreText,		RestoreHelp,		ItemFont, ItemAlign);
	BackChoice				= AddChoice(	BackText,			"",					ItemFont, ItemAlign, true);
	
	ReticleTypeSlider.bDisplayVal		= false;
	ReticleTypeSlider.bNoSlidingNotify	= false;
	ReticleAlphaSlider.bNoSlidingNotify = false;
	ReticleSizeSlider.bNoSlidingNotify = false;
	ReticleRedSlider.bNoSlidingNotify = false;
	ReticleGreenSlider.bNoSlidingNotify = false;
	ReticleBlueSlider.bNoSlidingNotify = false;
	
	// Don't LoadValues here--do it in Created after ImageReticle is created.
	}

///////////////////////////////////////////////////////////////////////////////
// Appears to be a post-creation event for adding children and stuff.
///////////////////////////////////////////////////////////////////////////////
function Created()
	{
	super.Created();
	
	// xPatch: Shows crosshair accurately by using HUD
	P2Player(GetPlayerOwner()).bForceCrosshair=True;
/*	if(GroupVal == 0)
	{
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
	}	*/
	
	LoadValues();
	
	if(!HUDRenderCheckbox.GetValue())
		{
		NoCustomReticlesCheckbox.bDisabled = True;
		NoCustomReticlesCheckbox.bChecked = False;
		}
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
/*	local Texture texReticle;
	local string crossRender;
	texReticle = P2Player(GetPlayerOwner()).GetReticleTexture();
	crossRender = CrosshairGroupCombo.GetValue();
	if (texReticle != none)
		{
		ImageReticle.T = texReticle;
		ImageReticle.R.X = 0;
		ImageReticle.R.Y = 0;
		ImageReticle.R.W = ImageReticle.T.USize;
		ImageReticle.R.H = ImageReticle.T.VSize;
		
		if (crossRender == CrosshairGroup[0])
			ImageReticle.DrawColor = P2Player(GetPlayerOwner()).GetReticleColor();
		else
			ImageReticle.DrawColor = P2Player(GetPlayerOwner()).GetReticleColor2();
		
		ImageReticle.ShowWindow();
		}
	else
		ImageReticle.HideWindow();
	*/
	// Update all the weapons with the new settings.
		class'Postal2Game.P2Weapon'.static.ReticleUpdated(P2Player(GetPlayerOwner()));
	}

///////////////////////////////////////////////////////////////////////////////
// Set all values to defaults
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
	{
	local string GetRender;
	GetRender = CrosshairGroupCombo.GetValue();
	
	ReticleTypeSlider.SetValue(2);
	ReticleAlphaSlider.SetValue(7);
	ReticleEnabledCheckbox.SetValue(true);
	HUDRenderCheckbox.SetValue(true);
	NoCustomReticlesCheckbox.SetValue(false);
	
	if(GetRender == CrosshairGroup[1])
	{
		ReticleRedSlider.SetValue(8);
		ReticleGreenSlider.SetValue(15);
		ReticleBlueSlider.SetValue(8);
		ReticleSizeSlider.SetValue(4);
	}
	else
	{
		ReticleRedSlider.SetValue(15);
		ReticleGreenSlider.SetValue(15);
		ReticleBlueSlider.SetValue(15);
		ReticleSizeSlider.SetValue(4);
	}
	
	}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
	{
	local int	iVal;
	local float fVal;
	local bool	bVal;
	
	bUpdate = false;
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get"@c_strReticleTypePath) );
	ReticleTypeSlider.SetValue(iVal);
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get"@c_strReticleAlphaPath) );
	iVal = iVal * c_fReticleMaxAlphaSlider / c_fReticleMaxAlpha;
	ReticleAlphaSlider.SetValue(iVal);
	
	bVal = bool(GetPlayerOwner().ConsoleCommand("get"@c_strReticleEnabledPath) );
	ReticleEnabledCheckbox.SetValue(bVal);
	
	// New stuff below
	bVal = bool(GetPlayerOwner().ConsoleCommand("get"@c_strHUDRender) );
	HUDRenderCheckbox.SetValue(bVal);
	
	bVal = bool(GetPlayerOwner().ConsoleCommand("get"@c_strNoCustomReticles) );
	NoCustomReticlesCheckbox.SetValue(bVal);
	
	CrosshairGroupCombo.Clear();
	for (iVal = 0; iVal < ArrayCount(CrosshairGroup); iVal++)
		CrosshairGroupCombo.AddItem(CrosshairGroup[iVal]);
	
	CrosshairGroupCombo.SetValue(CrosshairGroup[GroupVal]);
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get"@c_strReticleRedPath) );
	iVal = iVal * c_fReticleMaxColorSlider / c_fReticleMaxColor;
	ReticleRedSlider.SetValue(iVal);
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get"@c_strReticleGreenPath) );
	iVal = iVal * c_fReticleMaxColorSlider / c_fReticleMaxColor;
	ReticleGreenSlider.SetValue(iVal);
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get"@c_strReticleBluePath) );
	iVal = iVal * c_fReticleMaxColorSlider / c_fReticleMaxColor;
	ReticleBlueSlider.SetValue(iVal);
	
	fVal = float(GetPlayerOwner().ConsoleCommand("get"@c_strReticleSizePath) );
	fVal = fVal * c_fReticleMaxSizeSlider / c_fReticleMaxSize;
	ReticleSizeSlider.SetValue(fVal);
	
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
				case CrosshairGroupCombo:
					bDrag = false;
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
				// New stuff
				case HUDRenderCheckbox:
					HUDRenderCheckboxChanged();
					break;
				case NoCustomReticlesCheckbox:
					NoCustomReticlesCheckboxChanged();
					break;
				case ReticleRedSlider:
					ReticleRedSliderChanged();
					break;			
				case ReticleGreenSlider:
					ReticleGreenSliderChanged();
					break;
				case ReticleBlueSlider:
					ReticleBlueSliderChanged();
					break;
				case ReticleSizeSlider:
					ReticleSizeSliderChanged();
					break;				
				case CrosshairGroupCombo:
					bDrag = false;
					CrosshairGroupChanged();
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
// xPatch: New Stuff...
///////////////////////////////////////////////////////////////////////////////
function HUDRenderCheckboxChanged()
	{
	if (bUpdate)
	{
		if(!HUDRenderCheckbox.bChecked)
		{
			NoCustomReticlesCheckbox.bDisabled = True;
			NoCustomReticlesCheckbox.bChecked = False;
		}
		else
		{
			NoCustomReticlesCheckbox.bDisabled = False;
			NoCustomReticlesCheckbox.bChecked = P2Player(GetPlayerOwner()).bNoCustomCrosshairs;
		}
		
		P2Player(GetPlayerOwner()).Default.bHUDCrosshair = HUDRenderCheckbox.GetValue();
		P2Player(GetPlayerOwner()).bHUDCrosshair = HUDRenderCheckbox.GetValue();
		GetPlayerOwner().Static.StaticSaveConfig();
	}
	
	UpdateReticleImage();
	}
	
function NoCustomReticlesCheckboxChanged()
	{
	if (bUpdate)
		{
		P2Player(GetPlayerOwner()).Default.bNoCustomCrosshairs = NoCustomReticlesCheckbox.GetValue();
		P2Player(GetPlayerOwner()).bNoCustomCrosshairs = NoCustomReticlesCheckbox.GetValue();
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	
	UpdateReticleImage();
	}

function CrosshairGroupChanged()
	{
	local String NewRender;

	if (bUpdate)
		{
			NewRender = CrosshairGroupCombo.GetValue();
			
			if (NewRender == CrosshairGroup[0])
				GetPlayerOwner().ConsoleCommand("set" @ c_strReticleGroupPath @ 0);
				
			if (NewRender == CrosshairGroup[1])
				GetPlayerOwner().ConsoleCommand("set" @ c_strReticleGroupPath @ 1 );

			//if (NewRender == CrosshairGroup[2])
			//	GetPlayerOwner().ConsoleCommand("set" @ c_strReticleGroupPath @ 2 );
				
			RefreshMenu();
		}
		
	UpdateReticleImage();
	}
	
///////////////////////////////////////////////////////////////////////////////
// Notification from the slider that its value has changed.
///////////////////////////////////////////////////////////////////////////////
function ReticleRedSliderChanged()
	{
	local int iVal;
	iVal = int(GetPlayerOwner().ConsoleCommand("get" @ c_strReticleGroupPath));	
	
	if (bUpdate && iVal > 0 )
		{
		P2Player(GetPlayerOwner()).Default.ReticleRed = (ReticleRedSlider.GetValue() * c_fReticleMaxColor / c_fReticleMaxColorSlider);
		P2Player(GetPlayerOwner()).ReticleRed = (ReticleRedSlider.GetValue() * c_fReticleMaxColor / c_fReticleMaxColorSlider);
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	
	UpdateReticleImage();
	}
	
///////////////////////////////////////////////////////////////////////////////
// Notification from the slider that its value has changed.
///////////////////////////////////////////////////////////////////////////////
function ReticleGreenSliderChanged()
	{
	local int iVal;
	iVal = int(GetPlayerOwner().ConsoleCommand("get" @ c_strReticleGroupPath));	
	
	if (bUpdate && iVal > 0 )
		{
		P2Player(GetPlayerOwner()).Default.ReticleGreen = (ReticleGreenSlider.GetValue() * c_fReticleMaxColor / c_fReticleMaxColorSlider);
		P2Player(GetPlayerOwner()).ReticleGreen = (ReticleGreenSlider.GetValue() * c_fReticleMaxColor / c_fReticleMaxColorSlider);
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	
	UpdateReticleImage();
	}
	
///////////////////////////////////////////////////////////////////////////////
// Notification from the slider that its value has changed.
///////////////////////////////////////////////////////////////////////////////
function ReticleBlueSliderChanged()
	{
	local int iVal;
	iVal = int(GetPlayerOwner().ConsoleCommand("get" @ c_strReticleGroupPath));	
	
	if (bUpdate && iVal > 0 )
		{
		P2Player(GetPlayerOwner()).Default.ReticleBlue = (ReticleBlueSlider.GetValue() * c_fReticleMaxColor / c_fReticleMaxColorSlider);
		P2Player(GetPlayerOwner()).ReticleBlue = (ReticleBlueSlider.GetValue() * c_fReticleMaxColor / c_fReticleMaxColorSlider);
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	
	UpdateReticleImage();
	}
	
///////////////////////////////////////////////////////////////////////////////
// Notification from the slider that its value has changed.
///////////////////////////////////////////////////////////////////////////////
function ReticleSizeSliderChanged()
	{
	local int iVal;
	
	if (bUpdate)
		{
		P2Player(GetPlayerOwner()).Default.ReticleSize = (ReticleSizeSlider.GetValue() * c_fReticleMaxSize / c_fReticleMaxSizeSlider);
		P2Player(GetPlayerOwner()).ReticleSize = (ReticleSizeSlider.GetValue() * c_fReticleMaxSize / c_fReticleMaxSizeSlider);
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	
	UpdateReticleImage();
	}	
	
	
///////////////////////////////////////////////////////////////////////////////
// Refresh it without updating GoBack
///////////////////////////////////////////////////////////////////////////////
function /*ShellMenuCW*/ RefreshMenu()
{
	//Close();
	//CreateMenuContents();
	local ShellRootWindow shRoot;
	shRoot = ShellRootWindow(Root);
	
	if (shRoot != None)
		{
		LastX = Root.MouseX;
		LastY = Root.MouseY;
		SaveConfig();
		LookAndFeel.PlayBigSound(self);
		shRoot.GoToMenu(None, self.class);
		
		Super.OnCleanUp();
		
		//return shRoot.MyMenu;
		}
	
	//return None;
}
	
// Epic message to help out setting up a custom crosshair
function EpicMessage()
{
		local ShellWrappedTextControl EpicText;
		local array<string> tmparray;
		local Color TC;
		
		EpicText = AddWrappedTextItem(tmparray, 160, F_Bold, ItemAlign);
		EpicText.Text = ExplainText;
		
		TC.R = 200;
		TC.G = 200;
		TC.B = 200;
		TC.A = 255;
		EpicText.SetTextColor(TC);
		EpicText.bShadow = true;
}

function OnCleanUp()
{
	P2Player(GetPlayerOwner()).bForceCrosshair=False;
	Super.OnCleanUp();
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
	HintLines=4

	TitleText			= "Crosshair Settings";
	// 02/16/03 JMI Removed title so we have more room and menu won't intercept crosshair.
	TitleHeight			= 0;
	TitleSpacingY		= 0;

	ReticleTypeText		= "Crosshair Type"
	ReticleTypeHelp		= "Choose the crosshair to use in the game"
	ReticleAlphaText	= "Crosshair Intensity"
	ReticleAlphaHelp	= "Adjust the intensity of the crosshair"
	ReticleEnabledText	= "Enable Crosshair"
	ReticleEnabledHelp	= "Turn crosshair on or off."
	
	HUDRenderText = "New Render Method"
	HUDRenderHelp = "Renders crosshair using the HUD instead of the old weapon overlay method. Only disable this in rare occurrence of a mod incompatibility issue."
	NoCustomReticlesText = "Force Crosshair"
	NoCustomReticlesHelp = "Forces current default crosshair to be shown for all weapons."
	
	CrosshairGroupText	= "Crosshairs Group"
	CrosshairGroupHelp	= "Classic - fixed color and size. \\nNew - color and size can be customized." // \\nCustom - Can be changed in 'User.ini' file under 'CustomReticle'."
	CrosshairGroup[0]	= "Classic"
	CrosshairGroup[1]	= "New"
//	CrosshairGroup[2]	= "Custom"
	
	ReticleRedText		= "Red"
	ReticleGreenText	= "Green"
	ReticleBlueText		= "Blue"
	ReticleColorHelp	= "Adjust the color of the crosshair."
	ReticleSizeText		= "Crosshair Scale"
	ReticleSizeHelp		= "Adjust the size of the crosshair."
	
	ExplainText = "\\nCustom crosshair is not set up. It can be changed in 'User.ini' file (System folder) under 'CustomReticle'.\\nExample of correctly defined crosshair texture path:  \\n\\nCustomReticle=Texture'xPatchTex.UniqueCrosshair'"
	}
