class UTBotConfigCW extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;

// Auto Fill With Bots To MinPlayers - Play With Bots
var UWindowCheckBox AutoFillCheck;
var localized string AutoFillText;
var localized string AutoFillHelp;

// Min Players
var UWindowEditControl MinPlayersEdit;
var localized string MinPlayersText;
var localized string MinPlayersHelp;

// Bot's Base Skill Level
var UWindowComboControl SkillCombo;
var localized string SkillText;
var localized string SkillHelp;
var localized string IQNames[8];

// Auto Adjust Bot Skill Level
var UWindowCheckBox AutoSkillCheck;
var localized string AutoSkillText;
var localized string AutoSkillHelp;
/*
// Number of Bots
var UWindowEditControl NumBotsEdit;
var localized string NumBotsText;
var localized string NumBotsHelp;
*/
// Bots Balance Teams
var UWindowCheckbox BalanceCheck;
var localized string BalanceText;
var localized string BalanceHelp;

function Created()
{
	local int S;

	Super.Created();

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuBotConfigClientWindow without UMenuBotmatchClientWindow parent.");

	// Auto Fill Bots
	AutoFillCheck = UWindowCheckBox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	AutoFillCheck.SetText(AutoFillText);
	AutoFillCheck.SetHelpText(AutoFillHelp);
	AutoFillCheck.SetFont(F_SmallBold);
	AutoFillCheck.bChecked = Class<DeathMatch>(BotmatchParent.GameClass).Default.bAutoFillBots;
	ControlOffset += ControlHeight;

	// Min Players
	MinPlayersEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	MinPlayersEdit.SetText(MinPlayersText);
	MinPlayersEdit.SetHelpText(MinPlayersHelp);
	MinPlayersEdit.SetFont(F_SmallBold);
	MinPlayersEdit.SetNumericOnly(True);
	MinPlayersEdit.SetMaxLength(2);
	MinPlayersEdit.SetDelayedNotify(True);
	ControlOffset += ControlHeight;

	// Base Skill
	SkillCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight+3));
	SkillCombo.SetText(SkillText);
	SkillCombo.SetHelpText(SkillHelp);
	SkillCombo.SetFont(F_SmallBold);
	SkilLCombo.SetButtons(true);
	SkillCombo.SetEditable(false);
	ControlOffset += ControlHeight+3;
	
	// Auto Adjust Skill
	AutoSkillCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	AutoSkillCheck.SetText(AutoSkillText);
	AutoSkillCheck.SetHelpText(AutoSkillHelp);
	AutoSkillCheck.SetFont(F_SmallBold);
	AutoSkillCheck.bChecked = Class<DeathMatch>(BotmatchParent.GameClass).Default.bAdjustSkill;
	AutoSkillCheck.bActive = false;
	ControlOffset += ControlHeight;
/*
	// Number of Bots
	NumBotsEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	NumBotsEdit.SetText(NumBotsText);
	NumBotsEdit.SetHelpText(NumBotsHelp);
	NumBotsEdit.SetFont(F_SmallBold);
	NumBotsEdit.SetNumericOnly(True);
	NumBotsEdit.SetMaxLength(3);
	ControlOffset += ControlHeight;
*/
	// Bots Balance Teams
	BalanceCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	BalanceCheck.SetText(BalanceText);
	BalanceCheck.SetHelpText(BalanceHelp);
	BalanceCheck.SetFont(F_SmallBold);
	if(Class<TeamGame>(BotmatchParent.GameClass) != None)
		BalanceCheck.bChecked = Class<TeamGame>(BotmatchParent.GameClass).Default.bBalanceTeams;
	else
		BalanceCheck.HideWindow();
	ControlOffset += ControlHeight;
}

function AfterCreate()
{
	Super.AfterCreate();

	LoadCurrentValues();
	Initialized = true;
	AutoFillChanged();
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	Super.BeforePaint(C, X, Y);

	ControlLeft = (WinWidth - ControlWidth*2/3)/2;
	
	C.Font = Root.Fonts[F_SmallBold];

	if(MinPlayersEdit != None)
	{
		MinPlayersEdit.SetSize(ControlWidth-EditWidth+25, ControlHeight);
		MinPlayersEdit.WinLeft = ControlLeft;
		MinPlayersEdit.EditBoxWidth = 25;
		MinPlayersEdit.SetTextColor(TC);
	}

	SkillCombo.SetSize(ControlWidth-EditWidth+75, ControlHeight+3);
	//SkillCombo.EditBoxWidth = ControlWidth/2;
	SkillCombo.EditBoxWidth = 75;
	SkillCombo.WinLeft = ControlLeft;
	SkillCombo.SetTextColor(TC);

	AutoSkillCheck.SetSize(CheckWidth, ControlHeight);
	AutoSkillCheck.WinLeft = ControlLeft;

	AutoFillCheck.SetSize(CheckWidth, ControlHeight);
	AutoFillCheck.WinLeft = ControlLeft;
/*
	NumBotsEdit.SetSize(ControlWidth-EditWidth+37, ControlHeight);
	NumBotsEdit.WinLeft = ControlLeft;
	NumBotsEdit.EditBoxWidth = 37;
	NumBotsEdit.SetTextColor(TC);
*/
	BalanceCheck.SetSize(CheckWidth, ControlHeight);
	BalanceCheck.WinLeft = ControlLeft;
}

function LoadCurrentValues()
{
	local int i, val;

	if(MinPlayersEdit != None)
		MinPlayersEdit.SetValue(string(Class<DeathMatch>(BotmatchParent.GameClass).Default.MinPlayers));

	//Load Skill Levels
	for(i=0; i<ArrayCount(IQNames); i++)
		SkillCombo.AddItem(IQNames[i]);

	val = Class<DeathMatch>(BotmatchParent.GameClass).Default.BotDifficulty;

	if(val > 0)
		SkillCombo.SetValue(IQNames[val]);
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
			case MinPlayersEdit:
				MinPlayersChanged();
				break;
			case SkillCombo:
				SkillChanged();
				break;
			case AutoSkillCheck:
				AutoSkillChanged();
				break;
			case AutoFillCheck:
				AutoFillChanged();
				break;
/*			case NumBotsEdit:
				NumBotsChanged();
				break;
*/			case BalanceCheck:
				BalanceChanged();
				break;
		}
		break;
	}
}

function MinPlayersChanged()
{
	if(int(MinPlayersEdit.GetValue()) > 8)
		MinPlayersEdit.SetValue("8");
	if(int(MinPlayersEdit.GetValue()) < 0)
		MinPlayersEdit.SetValue("0");

	Class<DeathMatch>(BotmatchParent.GameClass).Default.MinPlayers = int(MinPlayersEdit.GetValue());
}

function SkillChanged()
{
	local string diffname;
	local int i, val;

	if (!Initialized)
		return;
	diffname = SkillCombo.GetValue();

	for(i=0; i<ArrayCount(IQNames); i++)
		if(diffname == IQNames[i])
			val = i;

	// set diff
	Class<DeathMatch>(BotmatchParent.GameClass).Default.BotDifficulty = val;
}

function AutoSkillChanged()
{
	Class<DeathMatch>(BotmatchParent.GameClass).Default.bAdjustSkill = AutoSkillCheck.bChecked;
}

function AutoFillChanged()
{
	Class<DeathMatch>(BotmatchParent.GameClass).Default.bAutoFillBots = AutoFillCheck.bChecked;

	if(AutoFillCheck.bChecked)
	{
		MinPlayersEdit.ShowWindow();
		SkillCombo.ShowWindow();
		AutoSkillCheck.ShowWindow();
		//NumBotsEdit.ShowWindow();
		if(Class<TeamGame>(BotmatchParent.GameClass) != None)
			BalanceCheck.ShowWindow();
	}
	else
	{
		MinPlayersEdit.HideWindow();
		SkillCombo.HideWindow();
		AutoSkillCheck.HideWindow();
		//NumBotsEdit.HideWindow();
		if(Class<TeamGame>(BotmatchParent.GameClass) != None)
			BalanceCheck.HideWindow();
	}
}
/*
function NumBotsChanged()
{
}
*/
function BalanceChanged()
{
	Class<TeamGame>(BotmatchParent.GameClass).Default.bBalanceTeams = BalanceCheck.bChecked;
}

defaultproperties
{
	PageHeaderText="Morons are good when real players aren't available."
	MinPlayersText="Number of Morons"
	MinPlayersHelp="Up to this number of morons can join but only if there's less than this number of real players."
	SkillText="Moron IQ"
	SkillHelp="The higher the number the less dumb they are.  Goes from Totally Idiotic (20) to Mildly Retarded (80)."
	AutoSkillText="Auto Adjust IQ"
	AutoSkillHelp="Automatically makes morons smarter if you kill them a lot or dumber if they kill you a lot."
	AutoFillText="Allow Morons"
	AutoFillHelp="Allows morons to join the game if there aren't enough real players."
//	NumBotsText="Number of Bots"
//	NumBotsHelp="Number of bots to play with."
	BalanceText="Morons Balance Teams"
	BalanceHelp="Turn on to consider morons when balancing teams or turn off to ignore them."
	IQNames[0]="20"
	IQNames[1]="30"
	IQNames[2]="40"
	IQNames[3]="50"
	IQNames[4]="60"
	IQNames[5]="70"
	IQNames[6]="75"
	IQNames[7]="80"
}