class UMenuGameSettingsBase extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;

// Frag Limit
var UWindowEditControl FragEdit;
var localized string FragText;
var localized string FragHelp;
var bool bFragEditEnabled;

// Time Limit
var UWindowEditControl TimeEdit;
var localized string TimeText;
var localized string TimeHelp;

/*// Weapons Stay
var UWindowCheckbox WeaponsCheck;
var localized string WeaponsText;
var localized string WeaponsHelp;*/

/*// Allow behind view
var UWindowCheckBox BehindViewCheck;
var localized string BehindViewText;
var localized string BehindViewHelp;*/

/*// Game Speed
var UWindowHSliderControl SpeedSlider;
var localized string SpeedText;
var localized string SpeedHelp;*/


function Created()
{
	local int S;

	Super.Created();

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log(self @ "Error: Missing UMenuBotmatchClientWindow parent.");

	SetupMapOptions();

	SetupNetworkOptions();

/*	// WeaponsStay
	WeaponsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	WeaponsCheck.SetText(WeaponsText);
	WeaponsCheck.SetHelpText(WeaponsHelp);
	WeaponsCheck.SetFont(F_SmallBold);
	WeaponsCheck.bChecked = BotmatchParent.GameClass.Default.bWeaponStay;
	ControlOffset += ControlHeight; */

/*	// Behind View
	BehindViewCheck = UWindowCheckBox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	BehindViewCheck.SetText(BehindViewText);
	BehindViewCheck.SetHelpText(BehindViewHelp);
	BehindViewCheck.SetFont(F_SmallBold);
	BehindViewCheck.bChecked = BotmatchParent.GameClass.Default.bAllowBehindView;
	ControlOffset += ControlHeight; */

/*	// Game Speed
	SpeedSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	SpeedSlider.SetRange(50, 200, 5);
	SpeedSlider.SetHelpText(SpeedHelp);
	SpeedSlider.SetFont(F_SmallBold);
	ControlOffset += ControlHeight; */
}

function AfterCreate()
{
	Super.AfterCreate();

	LoadCurrentValues();
	Initialized = True;
}

function SetupMapOptions()
{
	// Frag Limit
	if (bFragEditEnableD)
	{
		FragEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
		FragEdit.SetText(FragText);
		FragEdit.SetHelpText(FragHelp);
		FragEdit.SetFont(F_SmallBold);
		FragEdit.SetNumericOnly(True);
		FragEdit.SetMaxLength(3);
		ControlOffset += ControlHeight;
	}

	// Time Limit
	TimeEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	TimeEdit.SetText(TimeText);
	TimeEdit.SetHelpText(TimeHelp);
	TimeEdit.SetFont(F_SmallBold);
	TimeEdit.SetNumericOnly(True);
	TimeEdit.SetMaxLength(3);
	ControlOffset += ControlHeight;
}

function SetupNetworkOptions()
{
}

function LoadCurrentValues()
{
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	ControlLeft = (WinWidth - ControlWidth*2/3)/2;

	if (bFragEditEnabled)
	{
		FragEdit.SetSize(ControlWidth-EditWidth+SmallEditBoxWidth, ControlHeight);
		FragEdit.WinLeft = ControlLeft;
		FragEdit.EditBoxWidth = SmallEditBoxWidth;
		FragEdit.SetTextColor(TC);
	}

	TimeEdit.SetSize(ControlWidth-EditWidth+SmallEditBoxWidth, ControlHeight);
	TimeEdit.WinLeft = ControlLeft;
	TimeEdit.EditBoxWidth = SmallEditBoxWidth;
	TimeEdit.SetTextColor(TC);

/*	if(WeaponsCheck != None)
	{
		WeaponsCheck.SetSize(CheckWidth, ControlHeight);
		WeaponsCheck.WinLeft = ControlLeft;
	}*/

/*	if(BehindViewCheck != None)
	{
		BehindViewCheck.SetSize(CheckWidth, ControlHeight);
		BehindViewCheck.WinLeft = ControlLeft;
	}*/

/*	SpeedSlider.SetSize(WinWidth-26, ControlHeight);
	SpeedSlider.SliderWidth = 90;
	SpeedSlider.WinLeft = 14;
	SpeedSlider.SetTextColor(TC); */
}

function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
			case FragEdit:
				if (bFragEditEnabled)
					FragChanged();
				break;
			case TimeEdit:
				TimeChanged();
				break;
/*			case WeaponsCheck:
				WeaponsChecked();
				break;*/
/*			case BehindViewCheck:
				BehindViewChanged();
				break;*/
/*			case SpeedSlider:
				SpeedChanged();
				break;*/
		}
		break;
	}
}

function FragChanged()
{
}

function TimeChanged()
{
}

function MaxPlayersChanged()
{
}

function MaxSpectatorsChanged()
{
}

/*function WeaponsChecked()
{
}*/

/*function BehindViewChanged()
{
}*/

/*function SpeedChanged()
{
}*/

defaultproperties
{
	PageHeaderText="These settings control basic aspects of the game."
	PageHeaderText="Change these settings to control how the game works."
	FragText="Score Limit"
	FragHelp="The game will end if a player reaches this score. Use 0 for no score limit."
	bFragEditEnabled=true
	TimeText="Time Limit"
	TimeHelp="The game will end after this many minutes. Use 0 for no time limit."
//	WeaponsText="Weapons Stay"
//	WeaponsHelp="When selected, weapons will stay at their pickup location after being picked up, instead of respawning."
//	BehindViewText="Allow Behind View"
//	BehindViewHelp="Allows players to use the 'behindview 1' console command."
//	SpeedText="Game Speed"
//	SpeedHelp="Adjust the speed of the game."
}