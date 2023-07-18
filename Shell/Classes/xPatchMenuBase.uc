//=============================================================================
// xPatchMenuBase
// by Man Chrzan 
// 
// Base for xPatch Options 
//=============================================================================

class xPatchMenuBase extends MenuPerformanceAdvanced;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string TitleText;
var string CustomText;
var Color CustomColor;
var float CustomTextHeight;
var array<string> tmparray;
var ShellWrappedTextControl WrappedText;

var bool bAsk;
var bool bUpdate;
var bool HasLocalizedAudio;
var bool IsLocalized;
var bool RestoringDefaults;

// Some options depend on Game or xPatch version
//var bool bStandaloneVer;
var bool bParadiseLost;

// WARNINGS
var UWindowMessageBox	WarningBox;
var localized string WarningTitle, InfoTitle;
var localized string MapChangeText, LocalizationText, OverwriteDisText, 
HackInfoText, OldskoolCrapText, PerformanceText;

//////////////////////////////////////////////////////////////////////////////
// Prepare for creating menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	local string CountryCode;
	
	CountryCode = P2RootWindow(Root).GetCountryCode();
	
	// These are the only (offcial) versions with dub I think
	if(CountryCode == "RU"
	|| CountryCode == "ZH"	// Idk if it's a typo for CH but...
	|| CountryCode == "PL")
		HasLocalizedAudio=True;
	
	if(CountryCode != "US" && CountryCode != "None")
		IsLocalized=True;
		
	//bStandaloneVer = Class'xPatchManager'.static.IsStandaloneVersion();
	bParadiseLost = ShellRootWindow(Root).IsParadiseLost();
	
	// Do super to ShellMenuCW
	Super(ShellMenuCW).CreateMenuContents();
	
	// This base menu should never be opened, but just in case...
	if(Class == Class'xPatchMenuBase')
		BackChoice       	= AddChoice(BackText,    "",			ItemFont, ItemAlign, true);
}

///////////////////////////////////////////////////////////////////////////////
// Display warning.
///////////////////////////////////////////////////////////////////////////////
function ShowWarning(string strTitle, string strMsg)
{
	if(WarningBox == None)
		WarningBox = MessageBox(strTitle, strMsg, MB_OK, MR_OK, MR_OK);
}

///////////////////////////////////////////////////////////////////////////////
// Notification that the message box has finished.
///////////////////////////////////////////////////////////////////////////////
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	Super.MessageBoxDone(W, Result);
	
	if (W == WarningBox)
		WarningBox = None;		
}

///////////////////////////////////////////////////////////////////////////////
// Changed Checkbox
///////////////////////////////////////////////////////////////////////////////
function CheckboxChange(string ConfigPath, bool bValue,
						optional string WarnTitle, optional string WarnText, optional bool bShowWarning)
{
	// CheckboxChange(ConfigPath, bValue, WarnTitle, WarnText, bShowWarning);
	
	if (bUpdate)
	{
		GetPlayerOwner().ConsoleCommand("set" @ ConfigPath @ bValue);
			
		if(bShowWarning)
			ShowWarning(WarnTitle, WarnText);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Changed Slider
///////////////////////////////////////////////////////////////////////////////
function SliderChanged(string ConfigPath, float Value)
{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ ConfigPath @ Value);
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

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	 MenuWidth=550
     fCommonCtlArea=0.4
	 BorderLeft = 35
	 BorderRight = 35 
	 BorderTop = 20
	 BorderBottom = 50
	 TitleHeight = 40
	 TitleSpacingY = 11
	 ItemBorder = 0
	 ItemHeight = 32
	 ItemSpacingY = 2 
	 bBlockConsole=false
	
	CustomColor = (R=245,G=245,B=245,A=245)
	TitleText = "xPatch Options"
	
	WarningTitle = "WARNING"
	InfoTitle = "Information"
	MapChangeText = "Changes will take effect after the next level transition."
	OverwriteDisText = "Changes will only take effect when Override Properties is enabled."
	LocalizationText = "Are you sure? Using expanded dialogues in dubbed game version will end up with mixed languages."
	HackInfoText = "It will only affect Workshop games started after enabling this option."
	PerformanceText	 = "Enabling this option may adversely affect performance."
}