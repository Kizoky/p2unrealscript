///////////////////////////////////////////////////////////////////////////////
// MenuVideo.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The video menu.
//
// 11/05/12 JWB    Added Widescreen Stretch Option.
// 10/23/12 - MrD - Added Widescreen Support.
///////////////////////////////////////////////////////////////////////////////
class MenuVideo extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string VideoTitleText;

struct DisplayMode
	{
	var int	Width;
	var int Height;
	var int Ratio;
	var int Ratio2;
	};

var UWindowComboControl ResCombo;
var localized string ResText;
var localized string ResHelp;
var DisplayMode DisplayModes[20];

var localized string LowResWarningTitle;
var localized string LowResWarningText;

var UWindowMessageBox ConfirmRes;
var localized string ConfirmResTitle;
var localized string ConfirmResText;

var UWindowComboControl ColorCombo;
var localized string ColorText;
var localized string ColorHelp;
var localized string ColorSettings[2];
const ColorPath = "ini:Engine.Engine.RenderDevice Use16bit";

var localized string BadDepthTitle;
var localized string BadDepthText;

var localized string DesktopDepthTitle;
var localized string DesktopDepthText;

var localized string NoMirrorsText;

var UWindowMessageBox ConfirmDepth;
var UWindowMessageBox Confirm16bit;
var localized string ConfirmDepthTitle;
var localized string ConfirmDepthText;

var UWindowMessageBox ConfirmRestart16bit;	// FIXME -- eventually won't need this
var localized string Restart16bitTitle;
var localized string Restart16bitText;

const BrightnessPath	= "ini:Engine.Engine.ViewportManager Brightness";
var UWindowHSliderControl BrightnessSlider;
var localized string BrightnessText;
var localized string BrightnessHelp;

const ContrastPath		= "ini:Engine.Engine.ViewportManager Contrast";
var UWindowHSliderControl ContrastSlider;
var localized string ContrastText;
var localized string ContrastHelp;

const GammaPath			= "ini:Engine.Engine.ViewportManager Gamma";
var UWindowHSliderControl GammaSlider;
var localized string GammaText;
var localized string GammaHelp;

//const StartupFullScreenPath = "ini:Engine.Engine.ViewportManager StartupFullscreen";
var UWindowCheckbox FullScreenCheckbox;
var localized string FullScreenText;
var localized string FullScreenHelp;

var localized string FullScreenOnlyTitle;
var localized string FullScreenOnlyText;

var UWindowCheckbox BorderlessWindowCheckbox;
var localized string BorderlessWindowText, BorderlessWindowHelp;
const BorderlessWindowPath	= "ini:Engine.Engine.ViewportManager FullscreenWindowed";

var UWindowComboControl WindowModeCombo;	// Windowed, fullscreen, fullscreen windowed
var localized string WindowModeText, WindowModeHelp;
var localized string WindowModeSettings[3];
var localized string RestartRequiredTitle, RestartRequiredText;
enum EWindowModes
{
	WM_Windowed,
	WM_Fullscreen,
	WM_FullscreenWindowed
};

var UWindowHSliderControl DisplayNumberSlider;
var localized string DisplayNumberSliderText, DisplayNumberSliderHelp, DisplayNumberSliderHelpInactive;
const DisplayNumberPath = "ini:Engine.Engine.RenderDevice DisplayNumber";

//11/05/12 JWB Added Stretch when widescreen option
// Stick it in Gameinfo, hope it works!
const WidescreenStretchPath = "Postal2Game.P2GameInfo bWidescreenStretch";
var UWindowCheckbox WidescreenStretchCheckbox;
var localized string WidescreenStretchText;
var localized string WidescreenStretchHelp;

//12/09/12 JWB Added Vysnc option
const VSyncPath = "ini:Engine.Engine.RenderDevice UseVSync";
var UWindowCheckbox VSyncCheckbox;
var localized string VSyncText;
var localized string VSyncHelp;
var localized string VSyncRestartWarningTitle;
var localized string VSyncRestartWarningText;

// Rick F 2015-05-27 Added Triple Buffering (D3D only)
const TripleBufferPath = "D3DDrv.D3DRenderDevice UseTripleBuffering";
var UWindowCheckbox TripleBufferCheckbox;
var localized string TripleBufferText;
var localized string TripleBufferHelp;
var localized string TripleBufferRestartWarningTitle;
var localized string TripleBufferRestartWarningText;

// 10/05/13 JWB FOV controls, used on resolution change.
//var UWindowHSliderControl FOVSlider;
//var localized string FOVText;
//var localized string FOVHelp;
const FOVPath = "Engine.PlayerController DefaultFOV";

var UWindowCheckbox OpenGLCheckbox;
var localized string OpenGLText, OpenGLHelp;

var bool bUpdate;
var bool bAsk;

var string SafeRes;
var string SafeDepth;
var int SafeDisplayNo;
var string NewDepth;

var config string strDefaultRes;	// Res we originally ran with for Restore Defaults.

var localized string SliderUnavailableInWindowedMode;	// Error message for gamma sliders unavailable in windowed mode.

var ShellMenuChoice ApplyChoice;
var localized string ApplyText, ApplyHelp;
var localized string ConfirmChangesTitle, ConfirmChangesText, ConfirmChangesTextFullscreenWindowed;
var UWindowMessageBox AbandonChanges;
var localized string AbandonChangesTitle, AbandonChangesText;
var bool bResComboChanged;
var bool bBrightnessSliderChanged;
var bool bContrastSliderChanged;
var bool bGammaSliderChanged;
var bool bVSyncCheckboxChanged;
var bool bTripleBufferCheckboxChanged;
var bool bWidescreenStretchCheckboxChanged;
var bool bWindowModeComboChanged;
var bool bDisplayNumberSliderChanged;
var bool bShouldSetRes;	// instead of changing resolution in the above functions when applying settings, set a flag so we can do it all at once and get all the new settings

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	AddTitle(VideoTitleText, TitleFont, TitleAlign);

	ResCombo = AddComboBox(ResText, ResHelp, ItemFont);
	//ColorCombo = AddComboBox(ColorText, ColorHelp, ItemFont);
	//FullScreenCheckbox = AddCheckbox(FullScreenText, FullScreenHelp, ItemFont);
	//BorderlessWindowCheckbox = AddCheckbox(BorderlessWindowText, BorderlessWindowHelp, ItemFont);
	WindowModeCombo = AddComboBox(WindowModeText, WindowModeHelp, ItemFont);
	if (!PlatformIsWindows())
		DisplayNumberSlider = AddSlider(DisplayNumberSliderText, DisplayNumberSliderHelp, ItemFont, 0, 1);
	WidescreenStretchCheckbox = AddCheckbox(WidescreenStretchText, WidescreenStretchHelp, ItemFont);
    //VSyncCheckbox = AddCheckbox(VSyncText, VSyncHelp, ItemFont);
	if (PlatformIsWindows())
	{
		TripleBufferCheckbox = AddCheckbox(TripleBufferText, TripleBufferHelp, ItemFont);
		OpenGLCheckbox = AddCheckbox(OpenGLText, OpenGLHelp, ItemFont);
	}
	BrightnessSlider = AddSlider(BrightnessText, BrightnessHelp, ItemFont, 2, 10);
	ContrastSlider = AddSlider(ContrastText, ContrastHelp, ItemFont, 0, 20);
	GammaSlider = AddSlider(GammaText, GammaHelp, ItemFont, 5, 25);

	RestoreChoice	= AddChoice(RestoreText,	RestoreHelp,	ItemFont, ItemAlign);
	ApplyChoice		= AddChoice(ApplyText,		ApplyHelp,		ItemFont,	ItemAlign);
	BackChoice		= AddChoice(BackText,		"",				ItemFont, ItemAlign, true);

	LoadValues();
	}

///////////////////////////////////////////////////////////////////////////////
// Set all values to defaults
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
	{
	bAsk = false;

	// Restore the previous saved default values.
	RestoreDefaultValues();

	bAsk = true;

	// Now that we've restored the values, update the UI.
	LoadValues();

	bAsk = false;

	// Some values are not a simple INI read/update.
	ResCombo.SetValue(strDefaultRes);
	OpenGLCheckbox.SetValue(false);
	OpenGLCheckboxChanged();

	bAsk = true;
	}

///////////////////////////////////////////////////////////////////////////////
// Store default values.
///////////////////////////////////////////////////////////////////////////////
function StoreDefaultValues()
	{
	if (bDefaultsStored == false)
		{
		// Store the non-INI oriented defaults.
		//strDefaultRes = ShellRootWindow(Root).GetLowGameRes();
		if (strDefaultRes == "")
			strDefaultRes = GetPlayerOwner().ConsoleCommand("GetCurrentRes");
		}

	super.StoreDefaultValues();
	}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
	{
	local float val;
	local bool flag;
	local String str;
	local int    iDef;
	local int intval;

	// Store the values that need to be restored when the restore choice is chosen.
	// Note that we initialize the array here b/c the defaultproperties doesn't support
	// constants which is ridiculous.
	aDefaultPaths[iDef++] = BrightnessPath;
	aDefaultPaths[iDef++] = ContrastPath;
	aDefaultPaths[iDef++] = GammaPath;
	aDefaultPaths[iDef++] = ColorPath;
    aDefaultPaths[iDef++] = WidescreenStretchPath;
	aDefaultPaths[iDef++] = VSyncPath;
	aDefaultPaths[iDef++] = TripleBufferPath;
//	aDefaultPaths[iDef++] = StartupFullScreenPath;
	StoreDefaultValues();

	bUpdate = false;
	bAsk	= false;

	// 16/32 bit
	/*
	ColorCombo.Clear();
	ColorCombo.AddItem(ColorSettings[0]);
	ColorCombo.AddItem(ColorSettings[1]);
	if (GetPlayerOwner().ConsoleCommand("GetCurrentColorDepth") == "16")
		ColorCombo.SetValue(ColorSettings[0]);
	else
		ColorCombo.SetValue(ColorSettings[1]);
	*/
	
	WindowModeCombo.Clear();
	WindowModeCombo.AddItem(WindowModeSettings[0]);	// Window
	WindowModeCombo.AddItem(WindowModeSettings[1]); // Fullscreen
	//if (PlatformIsWindows())
		WindowModeCombo.AddItem(WindowModeSettings[2]); // Fullscreen window (not yet supported on mac/linux)

	// This gets the current fullscreen status instead of getting the value from the ini.
	// This was done because when users press <Alt+Enter> to toggle full screen mode, we
	// couldn't tell that the mode changed and this checkbox would be "wrong".  So now
	// we always get the current status and then if the checkbox is changed then we
	// toggle fullscreen and write the new value to the ini file.  The next time the game
	// starts it will be in whatever mode it was when it last exited.
	flag = bool(GetPlayerOwner().ConsoleCommand("GetFullScreen"));
	// SDL: These sliders DO affect windowed mode.
	//if (!PlatformIsWindows())
		//flag = true;
	if (flag)
	{
		WindowModeCombo.SetValue(WindowModeSettings[EWindowModes.WM_Fullscreen]);
		SetGammaSlidersEnabled(true);
	}
	else if (bool(GetPlayerOwner().ConsoleCommand("get" @ BorderlessWindowPath)))
	{
		WindowModeCombo.SetValue(WindowModeSettings[EWindowModes.WM_FullscreenWindowed]);
		SetGammaSlidersEnabled(false);
	}
	else
	{
		WindowModeCombo.SetValue(WindowModeSettings[EWindowModes.WM_Windowed]);
		SetGammaSlidersEnabled(false);
	}
	
	// Set up display slider
	if (DisplayNumberSlider != None)
	{
		intval = Max(0, int(GetPlayerOwner().ConsoleCommand("GetDisplayCount")) - 1);
		DisplayNumberSlider.SetRange(0, intval, 1);
		if (intval == 0)
		{
			DisplayNumberSlider.bActive = false;
			DisplayNumberSlider.SetHelpText(DisplayNumberSliderHelpInactive);
		}
		else
		{
			DisplayNumberSlider.bActive = true;
			DisplayNumberSlider.SetHelpText(DisplayNumberSliderHelp);
		}
	}
	
	//FullScreenCheckbox.SetValue(flag);
	//BorderlessWindowCheckbox.SetValue(bool(GetPlayerOwner().ConsoleCommand("get" @ BorderlessWindowPath)));

    // 12/09/12 JWB Added Vsync
    // Value is boolean.
	//VSyncCheckbox.SetValue(bool(GetPlayerOwner().ConsoleCommand("get" @ VSyncPath) ) );

    // Rick F 2015-05-27 Added Triple Buffering
    // Value is boolean.
	TripleBufferCheckbox.SetValue(bool(GetPlayerOwner().ConsoleCommand("get" @ TripleBufferPath) ) );
	
	OpenGLCheckbox.SetValue(bool(GetPlayerOwner().ConsoleCommand("GETRENDERDEVICEOGL")));

    // 11/05/12 JWB Added Widescreen Stretch
    // Value is boolean.
	WidescreenStretchCheckbox.SetValue(bool(GetPlayerOwner().ConsoleCommand("get" @ WidescreenStretchPath) ) );

	// Set available resolutions
	// MUST be after color and fullscreen controls are updated!
	ResCombo.Clear();
	UpdateAvailableResolutions();

	// If there's a low game res then show it, otherwise show the current res
	str = ShellRootWindow(Root).GetLowGameRes();
	if (str == "")
		str = GetPlayerOwner().ConsoleCommand("GetCurrentRes");
	ResCombo.SetValue(str);

	// Value 0.0 to 1.0
	val = int(float(GetPlayerOwner().ConsoleCommand("get"@BrightnessPath)) * 10);
	BrightnessSlider.SetValue(val);

	// Value 0.0 to 2.0
	val = int(float(GetPlayerOwner().ConsoleCommand("get"@ContrastPath)) * 10);
	ContrastSlider.SetValue(val);

	// Value 0.5 to 2.5
	val = int(float(GetPlayerOwner().ConsoleCommand("get"@GammaPath)) * 10);
	GammaSlider.SetValue(val);

	bUpdate = true;
	bAsk	= true;
	}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);

	switch (E)
		{
		case DE_Change:
			switch (C)
				{
				/*
				case ResCombo:
					ResComboChanged();
					break;
				//case ColorCombo:
				//	ColorComboChanged();
				//	break;

				case BrightnessSlider:
					BrightnessSliderChanged();
					break;
				case ContrastSlider:
					ContrastSliderChanged();
					break;
				case GammaSlider:
					GammaSliderChanged();
					break;
				//case FullScreenCheckbox:
					//FullScreenCheckboxChanged();
					//break;
				//case BorderlessWindowCheckbox:
					//BorderlessWindowCheckboxChanged();
					//break;
				//case VSyncCheckbox:
					//VSyncCheckboxChanged();
					//break;
				case TripleBufferCheckbox:
					TripleBufferCheckboxChanged();
					break;
				case OpenGLCheckbox:
					OpenGLCheckboxChanged();
					break;
                case WidescreenStretchCheckBox:
                    WidescreenStretchCheckboxChanged();
                    break;
				case WindowModeCombo:
					WindowModeComboChanged();
					break;
				*/
				case ResCombo:
					bResComboChanged = bUpdate;
					break;
				case BrightnessSlider:
					bBrightnessSliderChanged = bUpdate;
					break;
				case ContrastSlider:
					bContrastSliderChanged = bUpdate;
					break;
				case GammaSlider:
					bGammaSliderChanged = bUpdate;
					break;
				//case VSyncCheckbox:
					//bVSyncCheckboxChanged = bUpdate;
					//break;
				case TripleBufferCheckbox:
					bTripleBufferCheckboxChanged = bUpdate;
					break;
				case OpenGLCheckbox:
					OpenGLCheckboxChanged();
					break;
				case WidescreenStretchCheckbox:
					bWidescreenStretchCheckboxChanged = bUpdate;
					break;
				case WindowModeCombo:
					bWindowModeComboChanged = bUpdate;
					break;
				case DisplayNumberSlider:
					bDisplayNumberSliderChanged = bUpdate;
					break;
				}
			break;
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					MaybeGoBack();
					break;
				case RestoreChoice:
					SetDefaultValues();
					break;
				case ApplyChoice:
					ApplyChoiceSelected();
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Jump to previous menu
///////////////////////////////////////////////////////////////////////////////
function MaybeGoBack()
{
	local bool bChangesMade;
	
	bChangesMade = (bBrightnessSliderChanged || bContrastSliderChanged || bGammaSliderChanged || bVSyncCheckboxChanged || bTripleBufferCheckboxChanged || bWidescreenStretchCheckboxChanged || bWindowModeComboChanged || bResComboChanged);

	// If they changed anything, ask if they really want to quit
	if (bChangesMade)
		AbandonChanges = MessageBox(AbandonChangesTitle, AbandonChangesText, MB_YESNO, MR_YES, MR_YES);
	else
		GoBack();
}

// Applies all changes made.
function ApplyChoiceSelected()
{
	local String ResComboText;
	
	if (bResComboChanged)
		ResComboText = ResCombo.GetValue();
	else
		ResComboText = "";
	
	// Lazy mode to the max!
	if (bBrightnessSliderChanged)
		BrightnessSliderChanged();
	if (bContrastSliderChanged)
		ContrastSliderChanged();
	if (bGammaSliderChanged)
		GammaSliderChanged();
	if (bVSyncCheckboxChanged)
		VSyncCheckboxChanged();
	if (bTripleBufferCheckboxChanged)
		TripleBufferCheckboxChanged();
	if (bWidescreenStretchCheckboxChanged)
		WidescreenStretchCheckboxChanged();
	if (bWindowModeComboChanged)
		WindowModeComboChanged();
	if (bDisplayNumberSliderChanged)
		DisplayNumberSliderChanged();
	if (ResComboText != "")
	{
		// Hack to get the CORRECT resolution set - if WindowModeCombo is changed, Resolution resets itself and bResComboChanged gets turned off.
		bUpdate = false;
		ResCombo.SetValue(ResComboText);
		bUpdate = true;
		ResComboChanged();
	}
	bWindowModeComboChanged = false;
	bBrightnessSliderChanged = false;
	bContrastSliderChanged = false;
	bGammaSliderChanged = false;
	bVSyncCheckboxChanged = false;
	bTripleBufferCheckboxChanged = false;
	bWidescreenStretchCheckboxChanged = false;
	bResComboChanged = false;
	
	//if (bShouldSetRes)
		UpdateResolution();

	if (PlatformIsWindows() && WindowModeCombo.GetValue() == WindowModeSettings[EWindowModes.WM_FullscreenWindowed])
		ConfirmRes = MessageBox(ConfirmChangesTitle, ConfirmChangesTextFullscreenWindowed, MB_YESNO, MR_NO, MR_YES, 10);
	else
		ConfirmRes = MessageBox(ConfirmChangesTitle, ConfirmChangesText, MB_YESNO, MR_NO, MR_YES, 10);
}
	
///////////////////////////////////////////////////////////////////////////////
// Update values when controls have changed.
// - only update the real value if bUpdate is true
// - only ask for user confirmation if bAsk is true
///////////////////////////////////////////////////////////////////////////////
function DisplayNumberSliderChanged()
{
	if (bUpdate)
	{
		GetPlayerOwner().Consolecommand("set"@DisplayNumberPath@int(DisplayNumberSlider.GetValue()));
		bShouldSetRes = true;
	}
}

function BrightnessSliderChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$(BrightnessSlider.GetValue() / 10));
		GetPlayerOwner().ConsoleCommand("Brightness "$(BrightnessSlider.GetValue() / 10));
		GetPlayerOwner().ConsoleCommand("FLUSH");
		}
	}

function ContrastSliderChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager Contrast "$(ContrastSlider.GetValue() / 10));
		GetPlayerOwner().ConsoleCommand("Contrast "$(ContrastSlider.Value / 10));
		GetPlayerOwner().ConsoleCommand("FLUSH");
		}
	}

function GammaSliderChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager Gamma "$(GammaSlider.GetValue() / 10));
		GetPlayerOwner().ConsoleCommand("Gamma "$(GammaSlider.Value / 10));
		GetPlayerOwner().ConsoleCommand("FLUSH");
		}
	}
	
function UpdateResolution()
{
	local String NewRes;
	local float FOV;
	local bool bCurrentlyIsFullScreen;		// TRUE if we are CURRENTLY in fullscreen mode (NOT Fullscreen Windowed!)
	local bool bDesiredFullScreen;			// TRUE if we WANT fullscreen mode (NOT Fullscreen Windowed!)
	local String FullScreenFlag;			// "W" for windowed or "F" for fullscreen.
	local int CurrentDisplayNumber;			// Current display number
	
	// Check if new res is below the minimum menu res
	NewRes = ResCombo.GetValue();
	if (ShellRootWindow(Root).IsBelowMinRes(NewRes))
	{
		// The new res will not take affect until the user returns to the game.
		// Put up a dialog explaining this to the user.
		ShellRootWindow(Root).SetLowGameRes(NewRes);
		//MessageBox(LowResWarningTitle, LowResWarningText, MB_OK, MR_OK, MR_OK);
	}
	else
	{
		// The new resolution is NOT below the minimum.  In order to reduce the
		// complexity of what would have to happen if the user didn't confirm this
		// new resolution, I decided to throw out the possibility of returning to
		// a low game resolution by clearing it here.  This is a minor inconvenience
		// for the user and a major time-saver for me.
		ShellRootWindow(Root).ClearLowGameRes();

		// Check if the new res is different from the current one
		SafeRes = GetPlayerOwner().ConsoleCommand("GetCurrentRes");
		
		// Check fullscreen preference
		bCurrentlyIsFullScreen = bool(GetPlayerOwner().ConsoleCommand("GetFullScreen"));
		if (bCurrentlyIsFullScreen)
			SafeRes = SafeRes $ "xF";
		else
			SafeRes = SafeRes $ "xW";
		
		bDesiredFullScreen = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.ViewportManager StartupFullscreen"));
		if (bDesiredFullScreen)
			FullScreenFlag = "xF";
		else
			FullScreenFlag = "xW";
		
		if (!PlatformIsWindows())
			CurrentDisplayNumber = int(GetPlayerOwner().ConsoleCommand("GETCURRENTDISPLAYNUMBER"));
		else
			CurrentDisplayNumber = 0;
			
		SafeDisplayNo = CurrentDisplayNumber;
			
		if ((NewRes != SafeRes) || (bCurrentlyIsFullScreen != bDesiredFullScreen) || (DisplayNumberSlider.GetValue() != CurrentDisplayNumber))
		{
			// Switch to the new res
			GetPlayerOwner().ConsoleCommand("SetRes "$NewRes$FullScreenFlag);

			// Get the current FOV and reset it.
			// This will force the game to recalculate the aspect ratio
			//log("setting fov");
			FOV = float(GetPlayerOwner().ConsoleCommand("get" @ FOVPath));
			GetPlayerOwner().ConsoleCommand("fov" @ FOV);


			// Display messagebox with a time-out in case the new res is not valid
			// for the current monitor.  If the user doesn't click or clicks "no"
			// then we'll revert to the previous res.
			//if (bAsk)
				//ConfirmRes = MessageBox(ConfirmResTitle, ConfirmResText, MB_YESNO, MR_NO, MR_YES, 10);
		}
		
		bUpdate = false;
		UpdateAvailableResolutions();			
		bUpdate = true;
		
		bCurrentlyIsFullScreen = bool(GetPlayerOwner().ConsoleCommand("GetFullScreen"));
		
		if (bCurrentlyIsFullScreen)
			SetGammaSlidersEnabled(true);
		else if (PlatformIsWindows())
			SetGammaSlidersEnabled(false);
		else
			SetGammaSlidersEnabled(true);
	}	
}

function ResComboChanged()
	{
	local String NewRes;
	local float FOV;

	if (bUpdate)
		{
		bShouldSetRes = true;
		}
	}
	
function ColorComboChanged()
	{
	if (bUpdate)
		{
		SafeDepth = GetPlayerOwner().ConsoleCommand("GetCurrentColorDepth");
		if (ColorCombo.GetValue() == ColorSettings[0])
			NewDepth = "16";
		else
			NewDepth = "32";
		if(NewDepth != SafeDepth)
			{
			// If switching to 16-bit mode, warn about lack of mirrors
			if (NewDepth == "16" && bAsk)
				{}//Confirm16bit = MessageBox(BadDepthTitle, NoMirrorsText, MB_YESNO, MR_NO, MR_YES);
			else
				TryColorDepth(NewDepth);
			}
		}
	}

function WindowModeComboChanged()
{
	local bool bIsFullScreen;
	local string SetRes;

	if (bUpdate)
	{
		//log("Window mode combo changed, updating.");
		bShouldSetRes = true;
		
		bIsFullScreen = bool(GetPlayerOwner().ConsoleCommand("GetFullScreen"));
		
		// Windowed mode
		if (WindowModeCombo.GetValue() == WindowModeSettings[EWindowModes.WM_Windowed])
		{
			//log("Setting to windowed.");
			// Turn off fullscreen window
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager FullscreenWindowed false");
			GetPlayerOwner().ConsoleCommand("SetFullscreenWindowed");
			
			// Turn off fullscreen startup
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager StartupFullscreen false");			
		}
		// Fullscreen mode
		if (WindowModeCombo.GetValue() == WindowModeSettings[EWindowModes.WM_Fullscreen])
		{
			//log("Setting to fullscreen.");
			// Turn off fullscreen window
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager FullscreenWindowed false");
			GetPlayerOwner().ConsoleCommand("SetFullscreenWindowed");
			
			// Turn on fullscreen startup
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager StartupFullscreen true");
		}
		// Fullscreen window mode
		if (WindowModeCombo.GetValue() == WindowModeSettings[EWindowModes.WM_FullscreenWindowed])
		{
			//log("Setting to fullscreen window.");
			// Turn on fullscreen window
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager FullscreenWindowed true");
			GetPlayerOwner().ConsoleCommand("SetFullscreenWindowed");
			
			// Turn off fullscreen startup
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager StartupFullscreen false");
		}		
	}
}

/*
function BorderlessWindowCheckboxChanged()
{
	local string CurrentRes;
	local bool bIsFullScreen;
	
	if (bUpdate)
	{
		//log("Borderless checkbox clicked, updating");
		bIsFullScreen = bool(GetPlayerOwner().ConsoleCommand("GetFullScreen"));
		if (bIsFullScreen)
		{
			FullScreenCheckbox.bChecked = false;
			FullScreenCheckboxChanged();
		}
		
		bUpdate = false;
		CurrentRes = GetPlayerOwner().ConsoleCommand("GetCurrentRes");
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager FullscreenWindowed"@BorderlessWindowCheckbox.bChecked);
		GetPlayerOwner().ConsoleCommand("SetFullscreenWindowed");
		bUpdate = true;
		//log("Done updating...");
	}
}

function FullScreenCheckboxChanged()
	{
	local bool bIsFullScreen;
	if (bUpdate)
		{
		// The user can toggle fullscreen mode at any time by hitting <Alt+Enter> and we won't
		// know that it changed.  Furthermore, it's possible the user will do this while this
		// particular menu is running, in which case this checkbox will be "wrong".  So we look
		// for that situation here.  The reason we got here is that the checkbox has been
		// toggled.  So if the new value of the checkbox agrees with the current mode then we
		// don't want to toggle fullscreen.  If they don't agree, then we do toggle it.
		bIsFullScreen = bool(GetPlayerOwner().ConsoleCommand("GetFullScreen"));
		if (bIsFullScreen != FullScreenCheckbox.bChecked)
			{
			//log("Fullscreen checkbox changed! Toggling fullscreen");
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager StartupFullscreen"@FullScreenCheckbox.bChecked);
			GetPlayerOwner().ConsoleCommand("ToggleFullScreen");

			// Now check to see if we were able to go to non-fullscreen mode.  if the
			// user's desktop is not 32-bit (or 16-bit?) then it won't work, in which case
			// we'll put up a message telling them about it.
			bIsFullScreen = bool(GetPlayerOwner().ConsoleCommand("GetFullScreen"));
			if (bIsFullScreen && !FullScreenCheckbox.bChecked)
				{
				MessageBox(FullScreenOnlyTitle, FullScreenOnlyText, MB_OK, MR_OK, MR_OK);
				FullScreenCheckbox.SetValue(bIsFullScreen);
				UpdateAvailableResolutions();
				}
			}
		else
			{
			FullScreenCheckbox.SetValue(bIsFullScreen);
			UpdateAvailableResolutions();
			}
		}
	}
*/

// 12/09/12 JWB Added Widescreen Stretch
function VSyncCheckboxChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set" @ VSyncPath @ VSyncCheckbox.bChecked);
		//MessageBox(VSyncRestartWarningTitle, VSyncRestartWarningText, MB_OK, MR_OK, MR_OK);
	}
}

function TripleBufferCheckboxChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set" @ TripleBufferPath @ TripleBufferCheckbox.bChecked);
		//MessageBox(TripleBufferRestartWarningTitle, TripleBufferRestartWarningText, MB_OK, MR_OK, MR_OK);
	}
}

function OpenGLCheckboxChanged()
{
	if (OpenGLCheckbox.bChecked)
	{
		GetPlayerOwner().ConsoleCommand("SETRENDERDEVICEOGL 1");
	}
	else
	{
		GetPlayerOwner().ConsoleCommand("SETRENDERDEVICEOGL 0");
	}
}

// 11/05/12 JWB Added Widescreen Stretch
function WidescreenStretchCheckboxChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set" @ WidescreenStretchPath @ WidescreenStretchCheckbox.bChecked);
	}
}

// Set sliders to available/unavailable
function SetGammaSlidersEnabled(bool bEnabled)
{
	ShellSliderControl(BrightnessSlider).bActive = bEnabled;
	ShellSliderControl(ContrastSlider).bActive = bEnabled;
	ShellSliderControl(GammaSlider).bActive = bEnabled;
	
	if (bEnabled)
	{
		BrightnessSlider.SetHelpText(BrightnessHelp);
		ContrastSlider.SetHelpText(ContrastHelp);
		GammaSlider.SetHelpText(GammaHelp);
	}
	else
	{
		BrightnessSlider.SetHelpText(SliderUnavailableInWindowedMode);
		ContrastSlider.SetHelpText(SliderUnavailableInWindowedMode);
		GammaSlider.SetHelpText(SliderUnavailableInWindowedMode);
	}
}


///////////////////////////////////////////////////////////////////////////////
// Callback for when message box is done
///////////////////////////////////////////////////////////////////////////////
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
	{
	if (W == ConfirmRes)
		{
		ConfirmRes = None;
		if (Result != MR_Yes)
			{
			// Restore previous resolution
			GetPlayerOwner().ConsoleCommand("set"@DisplayNumberPath@SafeDisplayNo);
			GetPlayerOwner().ConsoleCommand("SetRes "$SafeRes);
			LoadValues();
			}
		}
	else if (W == Confirm16bit)
		{
		Confirm16bit = None;
		if (Result == MR_Yes)
			{
			// FIXME Couldn't switch to 16bit at runtime, so this hack asks player to restart game
			//TryColorDepth("16");
			ConfirmRestart16bit = MessageBox(Restart16bitTitle, Restart16bitText, MB_YESNO, MR_NO, MR_YES);
			}
		else
			{
			LoadValues();
			}
		}
	// FIXME Couldn't switch to 16bit at runtime, so this hack asks player to restart game
	else if (W == ConfirmRestart16bit)
		{
		if (Result == MR_Yes)
			{
			// Update ini value and then exit the game so 16-bit will take affect next time game starts
			UpdateColorPath("16");
			ShellRootWindow(root).ExitApp();
			}
		else
			{
			LoadValues();
			}
		}
	else if (W == ConfirmDepth)
		{
		ConfirmDepth = None;
		if (Result != MR_Yes)
			{
			// Restore previous depth
			UpdateColorPath(SafeDepth);
			GetPlayerOwner().ConsoleCommand("SetRes "$SafeRes);
			LoadValues();
			}
		else
			{
			LoadValues();
			}
		}
	else if (W == AbandonChanges)
		{
		if (Result == MR_Yes)
			GoBack();
		}
	}


///////////////////////////////////////////////////////////////////////////////
// Try specified color depth
///////////////////////////////////////////////////////////////////////////////
function TryColorDepth(String NewDepth)
	{
	local String CurrentRes;

	// Save the resolution and depth we'll return to if user clicks "no"
	CurrentRes = ResCombo.GetValue();
	SafeRes = CurrentRes$"x"$SafeDepth;

	// Switch to specified color depth.  The ini is only updated if user clicks "yes"
	UpdateColorPath(NewDepth);
	GetPlayerOwner().ConsoleCommand("SetRes" @ CurrentRes$"x"$NewDepth);
	if (bAsk)
		{
		// Check if the new color depth worked.  If so, put up a message asking
		// if user wants to keep it or not.  If not, put up message message explaining
		// that it isn't supported.
		if (GetPlayerOwner().ConsoleCommand("GetCurrentColorDepth") == NewDepth)
			ConfirmDepth = MessageBox(ConfirmDepthTitle, ConfirmDepthText, MB_YESNO, MR_NO, MR_YES, 10);
		else
			{
			if (bool(GetPlayerOwner().ConsoleCommand("GetFullScreen")))
				MessageBox(BadDepthTitle, BadDepthText, MB_OK, MR_OK, MR_OK);
			else
				MessageBox(DesktopDepthTitle, DesktopDepthText, MB_OK, MR_OK, MR_OK);
			// Reload the color combo.  This is only safe because we're inside
			// the "bAsk" condition, otherwise we'd have an infinite loop.
			LoadValues();
			}
		}
	}

function UpdateColorPath(string Depth)
	{
	local String Set;

	// Update ini to use specified depth
	if (Depth == "16")
		{
		Set = "set" @ ColorPath @ "true";
		//Log(self @ "UpdateColorPath(): doing "$Set);
		GetPlayerOwner().ConsoleCommand(Set);
		}
	else
		{
		Set = "set" @ ColorPath @ "false";
		//Log(self @ "UpdateColorPath(): doing "$Set);
		GetPlayerOwner().ConsoleCommand(Set);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// This is called when the resolution (and/or fullscreen mode) has changed.
///////////////////////////////////////////////////////////////////////////////
function ResolutionChanged(float W, float H)
	{
	Super.ResolutionChanged(W, H);

	// This gets called for two basic reasons: (1) we changed the display settings
	// via code, or (2) the user pressed <alt-tab> to toggle fullscreen mode, which
	// may also involve a resolution change.  In the case of #2, by changing the
	// display mode the user has taken things into his own hands, so we drop
	// any low-game res that might have existed.  This helps remove another
	// potential layer of complexity from things.
	ShellRootwindow(Root).ClearLowGameRes();

	LoadValues();
	}
	
///////////////////////////////////////////////////////////////////////////////
// quick and dirty function to find aspect ratio in integer
///////////////////////////////////////////////////////////////////////////////
function string AspectRatio(int Width, int Height)
{
	local int a, b, tmp;
	local string result;
	local float c;
	a = Width;
	b = Height;
	while (b != 0)
	{
		tmp = a;
		a = b;
		b = tmp % b;
	}
	b = Height / a;
	a = Width * b / Height;
	// If the aspect ratio isn't a specific value here, just return it as a decimal value
	result = a$":"$b;
	if (result != "5:4" && result != "4:3" && result != "3:2" && result != "16:10" && result != "5:3" && result != "16:9")
	{
		c = float(Width) / float(Height);
		result = String(c);		
		if (len(result) > 5)
			result = left(result, 5);
		result = result $ ":1";
	}
	return result;
}

///////////////////////////////////////////////////////////////////////////////
// Bubble sorts video resolutions
///////////////////////////////////////////////////////////////////////////////
function /*ErikFOV fix array<String> */ BubbleSortVideoResolutions(out array<String> Res)
{
	local string temp;
	local int i, j, k, Width1, Height1, Width2, Height2;
	local bool bDoSwap;
	
	for (i = 0; i < Res.Length; i++)
		for (j = 0; j < Res.Length; j++)
		{
			k = InStr(Res[i]," ");
			temp = Left(Res[i], k);
			k = InStr(temp, "x");
			Width1 = Int(Left(temp, k));
			Height1 = Int(Right(temp, len(temp) - k - 1));
			k = InStr(Res[j]," ");
			temp = Left(Res[j], k);
			k = InStr(temp, "x");
			Width2 = Int(Left(temp, k));
			Height2 = Int(Right(temp, len(temp) - k - 1));
			if (Width1 < Width2
				|| (Width1 == Width2 && Height1 < Height2))
			{
				temp = Res[i];
				Res[i] = Res[j];
				Res[j] = temp;
			}
		}
}

///////////////////////////////////////////////////////////////////////////////
// Update available resolutions
///////////////////////////////////////////////////////////////////////////////
function UpdateAvailableResolutions(optional bool bSetMax)
	{
	local int		Index;
	local int		BitDepth;
	local string	CurrentRes;
	local string	NextRes;
	local int i, j;
	local int Width,Height,RefRate,Depth;
	local bool bFound;
	local string UseEntry;
	local array<String> Resolutions;

	CurrentRes = ResCombo.GetValue();
	ResCombo.Clear();

	if(ColorCombo.GetValue() == ColorSettings[0])
		BitDepth = 16;
	else
		BitDepth = 32;

	/*
	for(Index = 0; Index < ArrayCount(DisplayModes); Index++)
		{
		if(!FullScreenCheckbox.bChecked ||
			GetPlayerOwner().ConsoleCommand("SupportedResolution"$" WIDTH="$DisplayModes[Index].Width$" HEIGHT="$DisplayModes[Index].Height$" Ratio="$DisplayModes[Index].Ratio$" Ratio="$DisplayModes[Index].Ratio$" BITDEPTH="$BitDepth) == "1")
			{
			ResCombo.AddItem(DisplayModes[Index].Width$"x"$DisplayModes[Index].Height$" - "$DisplayModes[Index].Ratio $":"$DisplayModes[Index].Ratio2);
			}
		}
	*/
	NextRes = GetPlayerOwner().ConsoleCommand("GETSUPPORTEDRESOLUTION INDEX=0");
	Index = 0;
	while (NextRes != "")
	{
		// Peel apart the result
		i = Instr(NextRes,"x");
		Width = int(Left(NextRes, i));
		NextRes = Right(NextRes, Len(NextRes) - i - 1);
		i = Instr(NextRes,"x");
		Height = int(Left(NextRes, i));
		NextRes = Right(NextRes, Len(NextRes) - i - 1);
		i = Instr(NextRes,"x");
		RefRate = int(Left(NextRes, i));
		NextRes = Right(NextRes, Len(NextRes) - i - 1);
		Depth = int(NextRes);
		//log(Width@Height@RefRate@Depth);
		
		// Throw out low-resolution options
		if (Width >= 1024 && Height >= 600)
		{		
			if (Depth == BitDepth)
			{
				UseEntry = Width$"x"$Height$" - "$AspectRatio(Width,Height);
				Resolutions.Insert(0,1);
				Resolutions[0] = UseEntry;
			}
		}
		Index++;
		NextRes = GetPlayerOwner().ConsoleCommand("GETSUPPORTEDRESOLUTION INDEX="$Index);
	}
	
	// Sort resolutions
	BubbleSortVideoResolutions(Resolutions);
	
	for (i = 0; i < Resolutions.Length; i++)
		// Skip duplicate entries
		if (ResCombo.FindItemIndex(Resolutions[i], false) == -1) 
			ResCombo.AddItem(Resolutions[i]);

	if (bSetMax)
	{
		CurrentRes = Resolutions[Resolutions.Length - 1];
		GetPlayerOwner().ConsoleCommand("SetRes "$CurrentRes);
	}
	ResCombo.SetValue(CurrentRes);
	}


///////////////////////////////////////////////////////////////////////////////
// Overridden to prompt a dialog box
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
	local bool bUseSuper;
	local int i;
	local ShellMenuChoice choice;
	
	bUseSuper = true;
	
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
							{
							MaybeGoBack();
							bUseSuper = false;
							}
						}
					}
				return true;
			}
		}
	
	if (bUseSuper)
		return Super.KeyEvent(Key, Action, Delta);
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	VideoTitleText="Video"
	ResText="Game Resolution"
	ResHelp="Controls the resolution at which the game is played"
	DisplayModes(0)=(Width=320,Height=240,ratio=16,Ratio2=9)
	DisplayModes(1)=(Width=512,Height=384,ratio=4,Ratio2=3)
	DisplayModes(2)=(Width=640,Height=480,ratio=4,Ratio2=3)
	DisplayModes(3)=(Width=800,Height=600,ratio=4,Ratio2=3)
	DisplayModes(4)=(Width=960,Height=600,ratio=16,Ratio2=10)
	DisplayModes(5)=(Width=1024,Height=768,ratio=4,Ratio2=3)
	DisplayModes(6)=(Width=1152,Height=864,ratio=4,Ratio2=3)
	DisplayModes(7)=(Width=1280,Height=720,ratio=16,Ratio2=9)
	DisplayModes(8)=(Width=1280,Height=768,ratio=16,Ratio2=9)
	DisplayModes(9)=(Width=1280,Height=800,ratio=16,Ratio2=10)
	DisplayModes(10)=(Width=1280,Height=960,ratio=4,Ratio2=3)
	DisplayModes(11)=(Width=1280,Height=1024,ratio=4,Ratio2=3)
	DisplayModes(12)=(Width=1360,Height=768,ratio=16,Ratio2=9)
	DisplayModes(13)=(Width=1440,Height=900,ratio=16,Ratio2=10)
	DisplayModes(14)=(Width=1600,Height=900,ratio=16,Ratio2=9)
	DisplayModes(15)=(Width=1600,Height=1024,ratio=16,Ratio2=10)
	DisplayModes(16)=(Width=1600,Height=1200,ratio=4,Ratio2=3)
	DisplayModes(17)=(Width=1680,Height=1050,ratio=16,Ratio2=10)
	DisplayModes(18)=(Width=1920,Height=1080,ratio=16,Ratio2=9)
	DisplayModes(19)=(Width=1920,Height=1200,ratio=16,Ratio2=10)
	// For Jake Testing!
	//DisplayModes(19)=(Width=3840,Height=720,ratio=16,Ratio2=3)
	LowResWarningTitle="Low Resolution"
	LowResWarningText="You have chosen a very low resolution.  This resolution will take effect during actual gameplay but not while the menu is displayed.  It may be difficult to read text in the game at this resolution."
	ConfirmResTitle="Confirm Resolution Change"
	ConfirmResText="Are you sure you wish to keep this new resolution?"
	ColorText="Color Quality"
	ColorHelp="Controls the color quality at which the game is played"
	ColorSettings(0)="Medium (16-bit)"
	ColorSettings(1)="Highest (32-bit)"
	BadDepthTitle="Color Quality"
	BadDepthText="Unable to change color quality.  The requested color quality is not supported by the current video card/driver."
	DesktopDepthTitle="Color Quality"
	DesktopDepthText="Unable to change color quality.  In window mode the color quality must match your desktop settings."
	NoMirrorsText="16-bit mode may be faster on older video cards.  However, mirrors will not show reflections in 16-bit mode."
	ConfirmDepthTitle="Confirm Color Quality"
	ConfirmDepthText="Are you sure you wish to keep this new color quality?"
	Restart16bitTitle="Restart Game for 16-bit Mode"
	Restart16bitText="To switch to 16-bit quality you must exit the game and start again. Click YES to exit now or NO to cancel."
	BrightnessText="Brightness"
	BrightnessHelp="Controls display brightness"
	ContrastText="Contrast"
	ContrastHelp="Controls display contrast"
	GammaText="Gamma"
	GammaHelp="Controls display gamma"
	FullScreenText="Full Screen"
	FullScreenHelp="Change from windowed to full screen mode"
	FullScreenOnlyTitle="Full Screen Only"
	FullScreenOnlyText="Unable to switch out of full screen mode.  Try changing your desktop color to 32-bit.  Some video cards/drivers may prevent this from working."
	WidescreenStretchText="Widescreen Stretch"
	WidescreenStretchHelp="If checked the map screen will stretch screen overlays for widescreen players."
	RestartRequiredTitle="Restart Required"
	RestartRequiredText="Your settings may not take effect until the game is restarted."
	VSyncText="Vertical Sync"
	VSyncHelp="Reduces screen tearing."
	strDefaultRes="1024x768"
	MenuWidth=600.000000
	fCommonCtlArea=0.400000
	astrTextureDetailNames(0)="UltraLow"
	astrTextureDetailNames(1)="Low"
	astrTextureDetailNames(2)="Medium"
	astrTextureDetailNames(3)="High"
	bDefaultsStored=True
	aDefaultValues(0)="0.500000"	// Brightness
	aDefaultValues(1)="0.500000"	// Contrast
	aDefaultValues(2)="0.100000"	// Gamma
	aDefaultValues(3)="False"		// 16Bit Color
	aDefaultValues(4)="False"		// Widescreen Stretch
	aDefaultValues(5)="True" 		// VSync
	aDefaultValues(6)="False"		// Triple Buffering
	VSyncRestartWarningTitle="Warning"
	VSyncRestartWarningText="Changes to VSync setting will not take effect until the game is restarted"
	BorderlessWindowText="Borderless Window"
	BorderlessWindowHelp="In windowed mode use a borderless maximized window (fullscreen windowed)"
	WindowModeText="Window Mode"
	WindowModeHelp="Play in a window, in fullscreen, or in a borderless fullscreen window."
	WindowModeSettings(0)="Windowed"
	WindowModeSettings(1)="Fullscreen"
	WindowModeSettings(2)="Fullscreen Windowed"
	SliderUnavailableInWindowedMode="This setting cannot be adjusted in Windowed or Fullscreen Windowed mode."
	TripleBufferText="Triple Buffering"
	TripleBufferHelp="May reduce tearing on some machines. Disable if performance drops. NOTE: Only effective on the DirectX renderer in Fullscreen mode."
	TripleBufferRestartWarningTitle="Warning"
	TripleBufferRestartWarningText="Changes to Triple Buffering setting will not take effect until the game is restarted"
	ApplyText="Apply Changes"
	ApplyHelp="Applies changes made on this page."
	ConfirmChangesTitle="Confirm Changes"
	ConfirmChangesText="Are you sure you wish to keep these new settings?"
	ConfirmChangesTextFullscreenWindowed="Are you sure you wish to keep these new settings? (The Fullscreen Windowed setting requires a restart.)"
	AbandonChangesTitle="Abandon Changes"
	AbandonChangesText="You have made changes on this menu, would you like to discard them?"
	DisplayNumberSliderText="Display Number"
	DisplayNumberSliderHelp="Choose which display you want to play the game on."
	DisplayNumberSliderHelpInactive="This setting is not available because only one display was detected."
	OpenGLText="Use OpenGL Renderer"
	OpenGLHelp="Enables the use of the OpenGL Renderer. Use only if you experience problems with the default DirectX Renderer. (Requires restart, does not support Fullscreen mode)"
}
