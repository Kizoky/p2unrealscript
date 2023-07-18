class xPatchPageBase extends UBrowserPageWindow;

var bool bInitialized;

var UWindowMessageBox WarningBox;
var localized string WarningTitle;
var localized string InfoTitle;

var localized string MapChangeText;

var color TextColor;
var color LabelColor;

//////////////////////////////////////////////////////////////////////////////
// Create
//////////////////////////////////////////////////////////////////////////////
function Created()
{
	local int S;

	Super(UWindowPageWindow).Created();

	TC = LabelColor;
	ControlFont = F_SmallBold;

	ControlWidth = WinWidth * ControlWidthPercent;
	//ControlLeft = (WinWidth - ControlWidth)/2;
	ControlLeft = (WinWidth - ControlWidth*2/3)/2;	// display in the center

	ControlOffset = 4;
	if (PageHeaderText != "")
	{
		PageHeader = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 0, ControlOffset, WinWidth, ControlHeight));
		PageHeader.SetText(PageHeaderText);
		PageHeader.SetFont(F_SmallBold);
		PageHeader.bActive = false;
//		PageHeader.bShadow = false;
		ControlOffset += ControlHeight;
	}

	BodyTop = ControlOffset;
	BodyHeight = WinHeight - ControlOffset;

	BodyLeft = BodyBorderLeftRight;
	BodyWidth = WinWidth - BodyBorderLeftRight*2;
}

//////////////////////////////////////////////////////////////////////////////
// Functions to handle changing options
//////////////////////////////////////////////////////////////////////////////
function CheckboxChange(string ConfigPath, bool bValue,
						optional string WarnTitle, optional string WarnText, optional bool bShowWarning)
{
	// CheckboxChange(ConfigPath, bValue, WarnTitle, WarnText, bShowWarning);
	
	if (bInitialized)
	{
		GetPlayerOwner().ConsoleCommand("set" @ ConfigPath @ bValue);
			
		if(bShowWarning)
			ShowWarning(WarnTitle, WarnText);
	}
}

function SliderChanged(string ConfigPath, float Value)
{
	if (bInitialized)
		GetPlayerOwner().ConsoleCommand("set" @ ConfigPath @ Value);
}

//////////////////////////////////////////////////////////////////////////////
// Functions to handle adding options
///////////////////////////////////////////////////////////////////////////////

// Add a combobox to the menu
function UWindowComboControl AddComboBox(String strText, String strHelp, int Font)
{
	local UWindowComboControl ctl;
	
	ctl = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ctl.SetButtons(True);
	ctl.SetText(strText);
	ctl.SetHelpText(strHelp);
	ctl.SetFont(Font);
	ctl.SetEditable(False);
	ControlOffset += ControlHeight;

	return ctl;
}

// Add a slider to the menu
function UWindowHSliderControl AddSlider(String strText, String strHelp, int Font, int MinVal, int MaxVal)
{
	local UWindowHSliderControl ctl;
	
	ctl = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ctl.SetRange(MinVal, MaxVal, MinVal);
	ctl.SetText(strText); //$" ("$int(ctl.GetValue())$"%)");
	ctl.SetHelpText(strHelp);
	ctl.SetFont(Font);
	ControlOffset += (ControlHeight * 1.5);;
	return ctl;
}

// Add a checkbox to the menu
function UWindowCheckbox AddCheckbox(String strText, String strHelp, int Font)
{
	local UWindowCheckbox ctl;
	
	ctl = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ctl.SetText(strText);
	ctl.SetHelpText(strHelp);
	ctl.SetFont(Font);
	ControlOffset += ControlHeight;
	return ctl;
}

// Add a label to the menu
function UWindowLabelControl AddLabel(String strText, int Font, optional float nControlLeft, optional float nControlOffset, optional float nControlWidth, optional float nControlHeight)
{
	local UWindowLabelControl ctl;
	
	if(nControlLeft == 0 && nControlOffset == 0 && nControlWidth == 0 && nControlHeight == 0)
	{
		nControlLeft = ControlLeft;
		nControlOffset = ControlOffset;
		nControlWidth = ControlWidth;
		nControlHeight = ControlHeight;
	}
	
	ctl = UWindowLabelControl(CreateControl(class'UWindowLabelControl', nControlLeft, nControlOffset, nControlWidth, nControlHeight));
	ctl.SetText(strText);
	//ctl.SetHelpText(strHelp);
	ctl.SetFont(Font);
	ctl.bActive = false;
	//ctl.bShadow = false;
	ControlOffset += ControlHeight;
	return ctl;
}

// Display warning.
function ShowWarning(string strTitle, string strMsg)
{
	if(WarningBox == None)
		WarningBox = MessageBox(strTitle, strMsg, MB_OK, MR_OK, MR_OK);
}

// Notification that the message box has finished.
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	Super.MessageBoxDone(W, Result);
	
	if (W == WarningBox)
		WarningBox = None;		
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to default
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
{
	//ShowWarning(InfoTitle,"Default settings restored.");
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

defaultproperties
{
	WarningTitle="WARNING"
	InfoTitle="Information"
	
	MapChangeText = "Changes will take effect after level transition."
	
	TextColor=(R=0,G=0,B=0,A=255)
	LabelColor=(R=200,G=200,B=200,A=255)
	HelpColor=(R=225,G=40,B=40,A=255)
}

/*
	###Text=""
	###Help=""
*/