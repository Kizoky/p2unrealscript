class UMenuTeamsCW extends UMenuPageWindow
	config(user);

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;
var bool bUserChange;

// Team mode radio buttons/group
var UWindowRadioGroup TeamRadioGroup;
var UWindowRadioButton RandomTeamsRadio;
var localized string RandomTeamsText;
var localized string RandomTeamsHelp;
var UWindowRadioButton MapTeamsRadio;
var localized string MapTeamsText;
var localized string MapTeamsHelp;
var UWindowRadioButton PickTeamsRadio;
var localized string PickTeamsText;
var localized string PickTeamsHelp;

// Team 1
var UWindowLabelControl T1Label;
var localized string T1Text;
var localized string T1Help;
var UWindowComboControl T1Combo;
var UMenuTeamBannerWindow T1Banner;
var UWindowDynamicTextArea T1Description;

// Team 2
var UWindowLabelControl T2Label;
var localized string T2Text;
var localized string T2Help;
var UWindowComboControl T2Combo;
var UMenuTeamBannerWindow T2Banner;
var UWindowDynamicTextArea T2Description;

var float RadioWidth;
var float RadioLeft;
var float RadioHeight;
var float ComboHeight;
var float LabelHeight;
var float BannerHeight;

function Created()
{
	local float TeamsTop;

	Super.Created();

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuTeamsCW without UMenuBotmatchClientWindow parent.");

	bUserChange = false;

	// Create radio button group and the buttons that are part of it
	TeamRadioGroup = UWindowRadioGroup(CreateControl(class'UWindowRadioGroup', 0, 0, 0, 0));

	RandomTeamsRadio = UWindowRadioButton(CreateControl(class'UWindowRadioButton', RadioLeft, ControlOffset, RadioWidth, RadioHeight));
	RandomTeamsRadio.SetText(RandomTeamsText);
	RandomTeamsRadio.SetHelpText(RandomTeamsHelp);
	RandomTeamsRadio.SetFont(ControlFont);
	RandomTeamsRadio.SetGroup(TeamRadioGroup);
	ControlOffset += RadioHeight;

	MapTeamsRadio = UWindowRadioButton(CreateControl(class'UWindowRadioButton', RadioLeft, ControlOffset, RadioWidth, RadioHeight));
	MapTeamsRadio.SetText(MapTeamsText);
	MapTeamsRadio.SetHelpText(MapTeamsHelp);
	MapTeamsRadio.SetFont(ControlFont);
	MapTeamsRadio.SetGroup(TeamRadioGroup);
	ControlOffset += RadioHeight;

	PickTeamsRadio = UWindowRadioButton(CreateControl(class'UWindowRadioButton', RadioLeft, ControlOffset, RadioWidth, RadioHeight));
	PickTeamsRadio.SetText(PickTeamsText);
	PickTeamsRadio.SetHelpText(PickTeamsHelp);
	PickTeamsRadio.SetFont(ControlFont);
	PickTeamsRadio.SetGroup(TeamRadioGroup);
	ControlOffset += RadioHeight;

	if (Class<TeamGame>(BotmatchParent.GameClass).Default.TeamSelectionMode == 0)
		TeamRadioGroup.SetSelectedButton(RandomTeamsRadio);
	else if (Class<TeamGame>(BotmatchParent.GameClass).Default.TeamSelectionMode == 1)
		TeamRadioGroup.SetSelectedButton(PickTeamsRadio);
	else
		TeamRadioGroup.SetSelectedButton(MapTeamsRadio);

	ControlOffset += 10;
	TeamsTop = ControlOffset;

	// Team 1
	T1Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 0, ControlOffset, 0, LabelHeight));
	T1Label.SetText(T1Text);
	T1Label.SetFont(ControlFont);
	ControlOffset += LabelHeight;
	
	T1Combo = UWindowComboControl(CreateControl(class'UWindowComboControl', 0, ControlOffset, 0, ComboHeight));
	T1Combo.SetHelpText(T1Help);
	T1Combo.SetFont(ControlFont);
	T1Combo.SetButtons(true);
	T1Combo.SetEditable(false);
	class'MpTeamInfo'.static.FillComboWithCompatibleTeams(GetPlayerOwner(), T1Combo, "", true);
	SetComboSelection(T1Combo, class<TeamGame>(BotmatchParent.GameClass).Default.PickedRedTeam);
	ControlOffset += ComboHeight + 10;

	T1Banner = UMenuTeamBannerWindow(CreateWindow(class'UMenuTeamBannerWindow', 0, ControlOffset, 0, 0));

	T1Description = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	T1Description.bAutoScrollbar = true;
	T1Description.bScrollOnResize = false;
	T1Description.bTopCentric = true;

	ControlOffset = TeamsTop;

	// Team 2
	T2Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 0, ControlOffset, 0, LabelHeight));
	T2Label.SetText(T2Text);
	T2Label.SetFont(ControlFont);
	ControlOffset += LabelHeight;

	T2Combo = UWindowComboControl(CreateControl(class'UWindowComboControl', 0, ControlOffset, 0, ComboHeight));
	T2Combo.SetHelpText(T2Help);
	T2Combo.SetFont(ControlFont);
	T2Combo.SetButtons(true);
	T2Combo.SetEditable(false);
	class'MpTeamInfo'.static.FillComboWithCompatibleTeams(GetPlayerOwner(), T2Combo, T1Combo.GetValue2(), true);
	SetComboSelection(T2Combo, class<TeamGame>(BotmatchParent.GameClass).Default.PickedBlueTeam);
	ControlOffset += ComboHeight + 10;

	T2Banner = UMenuTeamBannerWindow(CreateWindow(class'UMenuTeamBannerWindow', 0, ControlOffset, 0, 0));

	T2Description = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	T2Description.bAutoScrollbar = true;
	T2Description.bScrollOnResize = false;
	T2Description.bTopCentric = true;

	UpdateTeamPickingControls();
	UpdateTeams();

	ControlOffset += LabelHeight + ComboHeight;

	bUserChange = true;
}

function AfterCreate()
{
	local Color HelpColor;

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

	RandomTeamsRadio.SetSize(RadioWidth, RadioHeight);
	RandomTeamsRadio.WinLeft = RadioLeft;

	MapTeamsRadio.SetSize(RadioWidth, RadioHeight);
	MapTeamsRadio.WinLeft = RadioLeft;

	PickTeamsRadio.SetSize(RadioWidth, RadioHeight);
	PickTeamsRadio.WinLeft = RadioLeft;
	
	C.Font = Root.Fonts[T1Label.Font];
	C.StrLen(T1Text, W, H);
	T1Label.SetSize(W, LabelHeight);
	T1Label.WinLeft = (WinWidth/2 - W)/2;

	C.StrLen(T2Text, W, H);
	T2Label.SetSize(W, LabelHeight);
	T2Label.WinLeft = (WinWidth + WinWidth/2 - W)/2;
	
	T1Combo.SetSize(WinWidth/2 - 20, ComboHeight);
	T1Combo.WinLeft = 10;
	T1Combo.EditBoxWidth = T1Combo.WinWidth;

	T2Combo.SetSize(WinWidth/2 - 20, ComboHeight);
	T2Combo.WinLeft = WinWidth/2 + 10;
	T2Combo.EditBoxWidth = T2Combo.WinWidth;

	W2 = WinWidth/2 - 20;
	T1Banner.SetSize(W2, W2/2);
	T1Banner.WinLeft = 10;

	T2Banner.SetSize(W2, W2/2);
	T2Banner.WinLeft = WinWidth/2 + 10;

	C.Font = Root.Fonts[T1Description.Font];
	C.StrLen("TEST", W, H);
	if(Root.WinHeight < 599)
		T1Description.SetSize(W2, H*4);
	else
		T1Description.SetSize(W2, H*8);
	T1Description.WinLeft = 10;
	T1Description.WinTop = T1Banner.WinTop + T1Banner.WinHeight + 10;

	C.Font = Root.Fonts[T2Description.Font];
	C.StrLen("TEST", W, H);
	if(Root.WinHeight < 599)
		T2Description.SetSize(W2, H*4);
	else
		T2Description.SetSize(W2, H*8);
	T2Description.WinLeft = WinWidth/2 + 10;
	T2Description.WinTop = T2Banner.WinTop + T2Banner.WinHeight + 10;
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
		case TeamRadioGroup:
			TeamRadioGroupChanged();
			break;
		case T1Combo:
			T1ComboChanged();
			break;
		case T2Combo:
			T2ComboChanged();
			break;
		}
		break;
	}
}

function TeamRadioGroupChanged()
{
	UpdateTeamPickingControls();
	UpdateTeams();
}

function T1ComboChanged()
{
	local string PrevTeamClassName;

	// Whenever team 1 changes we re-fill the team 2 combo with compatible teams.
	// If possible, we try to keep the same selection for team 2.
	PrevTeamClassName = T2Combo.GetValue2();
	class'MpTeamInfo'.static.FillComboWithCompatibleTeams(GetPlayerOwner(), T2Combo, T1Combo.GetValue2(), true);
	SetComboSelection(T2Combo, PrevTeamClassName);
	UpdateTeams();
}

function T2ComboChanged()
{
	UpdateTeams();
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

function UpdateTeams()
{
	local class<MpTeamInfo> TeamClass;

	if (TeamRadioGroup.GetSelectedButton() == RandomTeamsRadio)
	{
		class<TeamGame>(BotmatchParent.GameClass).Default.TeamSelectionMode = 0;
	}
	else if (TeamRadioGroup.GetSelectedButton() == PickTeamsRadio)
	{
		class<TeamGame>(BotmatchParent.GameClass).Default.TeamSelectionMode = 1;
		class<TeamGame>(BotmatchParent.GameClass).Default.PickedRedTeam = T1Combo.GetValue2();
		class<TeamGame>(BotmatchParent.GameClass).Default.PickedBlueTeam = T2Combo.GetValue2();
	}
	else
	{
		class<TeamGame>(BotmatchParent.GameClass).Default.TeamSelectionMode = 2;
	}

	// Set the new team banners and descriptions
	T1Description.Clear();
	T2Description.Clear();
	TeamClass = class<MpTeamInfo>(DynamicLoadObject(T1Combo.GetValue2(), class'class'));
	if(TeamClass != None)
	{
		if(TeamClass.Default.TeamTextureNoMips != None)
			T1Banner.SetBanner(TeamClass.Default.TeamTextureNoMips);
		else
			T1Banner.SetBanner(None);
		if(TeamClass.Default.TeamDescription != "")
			T1Description.AddText(TeamClass.Default.TeamDescription);
	}
	else
		T1Banner.SetBanner(None);

	TeamClass = class<MpTeamInfo>(DynamicLoadObject(T2Combo.GetValue2(), class'class'));
	if(TeamClass != None)
	{
		if(TeamClass.Default.TeamTextureNoMips != None)
			T2Banner.SetBanner(TeamClass.Default.TeamTextureNoMips);
		else
			T2Banner.SetBanner(None);
		if(TeamClass.Default.TeamDescription != "")
			T2Description.AddText(TeamClass.Default.TeamDescription);
	}
	else
		T2Banner.SetBanner(None);
}

function UpdateTeamPickingControls()
{
	// Make sure these controls already exist
	if (T1Label != None)
	{
		if (TeamRadioGroup.GetSelectedButton() == PickTeamsRadio)
		{
			T1Label.ShowWindow();
			T1Combo.ShowWindow();
			T1Banner.ShowWindow();
			T1Description.ShowWindow();
			T2Label.ShowWindow();
			T2Combo.ShowWindow();
			T2Banner.ShowWindow();
			T2Description.ShowWindow();
		}
		else
		{
			T1Label.HideWindow();
			T1Combo.HideWindow();
			T1Banner.HideWindow();
			T1Description.HideWindow();
			T2Label.HideWindow();
			T2Combo.HideWindow();
			T2Banner.HideWindow();
			T2Description.HideWindow();
		}
	}
}

defaultproperties
{
	PageHeaderText="The teams determine which characters are used in the game."

	RandomTeamsText="Use random teams for each match"
	RandomTeamsHelp="This randomly chooses two teams before each match."

	MapTeamsText="Use teams specified by maps"
	MapTeamsHelp="This uses the teams specified by each map's designer."

	PickTeamsText="Choose your own teams"
	PickTeamsHelp="This allows you to choose the teams you want."

	T1Text="Team 1"
	T2Text="Team 2"
	T1Help="Pick whatever team you want for Team 1."
	T2Help="Pick Team 2.  Only teams compatible with Team 1 are listed here."

	RadioHeight=18
	ComboHeight=25
	LabelHeight=18
}