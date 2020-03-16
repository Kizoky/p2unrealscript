class UMenuRosterCW extends UMenuPageWindow
	config(user);

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;
var bool bUserChange;

// Roster mode radio buttons/group
var UWindowRadioGroup RosterRadioGroup;
var UWindowRadioButton MapRosterRadio;
var localized string MapRosterText;
var localized string MapRosterHelp;
var UWindowRadioButton PickRosterRadio;
var localized string PickRosterText;
var localized string PickRosterHelp;

// Roster
var UWindowLabelControl RosterLabel;
var localized string RosterText;
var localized string RosterHelp;
var UWindowComboControl RosterCombo;

// Roster Banner
var UMenuTeamBannerWindow RosterBanner;

// Roster Description
var UWindowDynamicTextArea RosterDescription;

var float RadioWidth;
var float RadioLeft;
var float RadioHeight;
var float ComboHeight;
var float LabelHeight;

function Created()
{
	Super.Created();

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuRosterCW without UMenuBotmatchClientWindow parent.");

	bUserChange = false;

	// Create radio button group and the buttons that are part of it
	RosterRadioGroup = UWindowRadioGroup(CreateControl(class'UWindowRadioGroup', 0, 0, 0, 0));

	MapRosterRadio = UWindowRadioButton(CreateControl(class'UWindowRadioButton', RadioLeft, ControlOffset, RadioWidth, RadioHeight));
	MapRosterRadio.SetText(MapRosterText);
	MapRosterRadio.SetHelpText(MapRosterHelp);
	MapRosterRadio.SetFont(ControlFont);
	MapRosterRadio.SetGroup(RosterRadioGroup);
	ControlOffset += RadioHeight;

	PickRosterRadio = UWindowRadioButton(CreateControl(class'UWindowRadioButton', RadioLeft, ControlOffset, RadioWidth, RadioHeight));
	PickRosterRadio.SetText(PickRosterText);
	PickRosterRadio.SetHelpText(PickRosterHelp);
	PickRosterRadio.SetFont(ControlFont);
	PickRosterRadio.SetGroup(RosterRadioGroup);
	ControlOffset += RadioHeight;

	if (Class<DeathMatch>(BotmatchParent.GameClass).Default.bUsePickedRoster)
		RosterRadioGroup.SetSelectedButton(PickRosterRadio);
	else
		RosterRadioGroup.SetSelectedButton(MapRosterRadio);

	ControlOffset += 10;

	// Roster
	RosterLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 0, ControlOffset, 0, LabelHeight));
	RosterLabel.SetText(RosterText);
	RosterLabel.SetFont(ControlFont);
	ControlOffset += LabelHeight;
	
	RosterCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 0, ControlOffset, 0, ComboHeight));
	RosterCombo.SetHelpText(RosterHelp);
	RosterCombo.SetFont(ControlFont);
	RosterCombo.SetButtons(true);
	RosterCombo.SetEditable(false);
	class'MpTeamInfo'.static.FillComboWithCompatibleTeams(GetPlayerOwner(), RosterCombo, "", false);
	SetComboSelection(RosterCombo, class<DeathMatch>(BotmatchParent.GameClass).Default.PickedRoster);
	ControlOffset += ComboHeight + 10;

	// Banner
	RosterBanner = UMenuTeamBannerWindow(CreateWindow(class'UMenuTeamBannerWindow', 0, ControlOffset, 0, 0));

	RosterDescription = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	RosterDescription.bAutoScrollbar = true;
	RosterDescription.bScrollOnResize = false;
	RosterDescription.bTopCentric = true;

	UpdateRosterPickingControls();
	UpdateRoster();

	ControlOffset += LabelHeight + ComboHeight;

	bUserChange = true;
}

function AfterCreate()
{
	Super.AfterCreate();

	LoadCurrentValues();
	Initialized = True;
}

function LoadCurrentValues()
{
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, W2;

	Super.BeforePaint(C, X, Y);

	RadioWidth = WinWidth * 0.8;	// give it almost the full width
	RadioLeft = WinWidth * 0.1;		// slight offset from left edge

	MapRosterRadio.SetSize(RadioWidth, RadioHeight);
	MapRosterRadio.WinLeft = RadioLeft;

	PickRosterRadio.SetSize(RadioWidth, RadioHeight);
	PickRosterRadio.WinLeft = RadioLeft;
	
	C.StrLen(RosterText, W, H);
	RosterLabel.SetSize(W, LabelHeight);
	RosterLabel.WinLeft = (WinWidth - RosterLabel.WinWidth) / 2;

	RosterCombo.SetSize(WinWidth/2 - 20, ComboHeight);
	RosterCombo.WinLeft = (WinWidth - RosterCombo.WinWidth) / 2;
	RosterCombo.EditBoxWidth = RosterCombo.WinWidth;

	W2 = RosterCombo.WinWidth;
	RosterBanner.SetSize(W2, W2/2);
	RosterBanner.WinLeft = (WinWidth - RosterBanner.WinWidth) / 2;

	C.Font = Root.Fonts[RosterDescription.Font];
	C.StrLen("TEST", W, H);
	if(Root.WinHeight < 599)
		RosterDescription.SetSize(W2, H*6);
	else
		RosterDescription.SetSize(W2, H*11);
	RosterDescription.WinLeft = (WinWidth - RosterDescription.WinWidth) / 2;
	RosterDescription.WinTop = RosterBanner.WinTop + RosterBanner.WinHeight + 10;
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
		case RosterRadioGroup:
			RosterRadioGroupChanged();
			break;
		case RosterCombo:
			RosterComboChanged();
			break;
		}
		break;
	}
}

function RosterRadioGroupChanged()
{
	UpdateRosterPickingControls();
	UpdateRoster();
}

function RosterComboChanged()
{
	UpdateRoster();
}

function SetComboSelection(UWindowComboControl Combo, string TeamClassName)
{
	local int i;

	i = Combo.FindItemIndex2(TeamClassName, true);
	if (i != -1)
		Combo.SetSelectedIndex(i);
	else
		Combo.SetSelectedIndex(0);
}

function UpdateRoster()
{
	local class<MpTeamInfo> TeamClass;

	if (RosterRadioGroup.GetSelectedButton() == PickRosterRadio)
	{
		class<DeathMatch>(BotmatchParent.GameClass).Default.bUsePickedRoster = true;
		class<DeathMatch>(BotmatchParent.GameClass).Default.PickedRoster = RosterCombo.GetValue2();
	}
	else
	{
		class<DeathMatch>(BotmatchParent.GameClass).Default.bUsePickedRoster = false;
	}

	// Set the new roster banner and description
	RosterDescription.Clear();
	TeamClass = class<MpTeamInfo>(DynamicLoadObject(RosterCombo.GetValue2(), class'class'));
	if(TeamClass != None)
	{
		if(TeamClass.Default.TeamTextureNoMips != None)
			RosterBanner.SetBanner(TeamClass.Default.TeamTextureNoMips);
		else
			RosterBanner.SetBanner(None);
		if(TeamClass.Default.TeamDescription != "")
			RosterDescription.AddText(TeamClass.Default.TeamDescription);
	}
	else
		RosterBanner.SetBanner(None);

}

function UpdateRosterPickingControls()
{
	// Make sure these controls already exist
	if (RosterLabel != None)
	{
		if (RosterRadioGroup.GetSelectedButton() == PickRosterRadio)
		{
			RosterLabel.ShowWindow();
			RosterCombo.ShowWindow();
			RosterBanner.ShowWindow();
			RosterDescription.ShowWindow();
		}
		else
		{
			RosterLabel.HideWindow();
			RosterCombo.HideWindow();
			RosterBanner.HideWindow();
			RosterDescription.HideWindow();
		}
	}
}

defaultproperties
{
	PageHeaderText="The roster determines which characters are used in the game."

	MapRosterText="Use roster specified by map designer"
	MapRosterHelp="This uses the rosters specified by each map's designer."

	PickRosterText="Choose your own roster"
	PickRosterHelp="This lets you to pick the roster you want."

	RosterText="Roster"
	RosterHelp="Pick whatever roster you want."

	RadioHeight=18
	ComboHeight=25
	LabelHeight=18
}
