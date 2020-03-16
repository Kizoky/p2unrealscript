class UTTeamSettingsCWindow extends UTSettingsCWindow;

// Team Score
//var UWindowEditControl TeamScoreEdit;
//var localized string TeamScoreText;
//var localized string TeamScoreHelp;

// Max Teams
//var UWindowEditControl MaxTeamsEdit;
//var localized string MaxTeamsText;
//var localized string MaxTeamsHelp;

// PlayersBalanceTeams
var UWindowCheckbox BalancePlayersCheck;
var localized string BalancePlayersText;
var localized string BalancePlayersHelp;

//var int MaxAllowedTeams;

// Friendly Fire Scale
var UWindowHSliderControl FFSlider;
var localized string FFText;
var localized string FFHelp;

function Created()
{
	local int FFS;

	Initialized = False;
/*
	// Team Score Limit
	TeamScoreEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	TeamScoreEdit.SetText(TeamScoreText);
	TeamScoreEdit.SetHelpText(TeamScoreHelp);
	TeamScoreEdit.SetFont(ControlFont);
	TeamScoreEdit.SetNumericOnly(True);
	TeamScoreEdit.SetMaxLength(3);
*/
	Super.Created();
/*
	if(MaxTeamsEdit != None)
		MaxTeamsEdit.SetValue(string(class<TeamGame>(BotmatchParent.GameClass).Default.MaxTeams));
	MaxAllowedTeams = class<TeamGame>(BotmatchParent.GameClass).Default.MaxAllowedTeams;
*/
//	DesiredWidth = 220;
//	DesiredHeight = 165;

	Initialized = False;

//	TeamScoreEdit.SetValue(string(int(Class<TeamGame>(BotmatchParent.GameClass).Default.GoalTeamScore)));

	// Friendly Fire Scale
	FFSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	FFSlider.SetRange(0, 10, 1);
	FFS = Class<TeamGame>(BotmatchParent.GameClass).Default.FriendlyFireScale * 10;
	FFSlider.SetValue(FFS);
	FFSlider.SetText(FFText$" ("$FFS*10$"%)");
	FFSlider.SetHelpText(FFHelp);
	FFSlider.SetFont(ControlFont);
	ControlOffset += ControlHeight;

	Initialized = True;
}

function SetupNetworkOptions()
{
	// don't call UTSettingsCWindow's version (force respawn)
	//Super(UMenuGameRulesBase).SetupNetworkOptions();
	Super.SetupNetworkOptions();

	if(BotmatchParent.bNetworkGame)
	{
		BalancePlayersCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
		BalancePlayersCheck.SetText(BalancePlayersText);
		BalancePlayersCheck.SetHelpText(BalancePlayersHelp);
		BalancePlayersCheck.SetFont(ControlFont);
		BalancePlayersCheck.bChecked = Class<TeamGame>(BotmatchParent.GameClass).Default.bPlayersBalanceTeams;
		ControlOffset += ControlHeight;
	}
/*
	if(
		!ClassIsChildOf( BotmatchParent.GameClass, class'CTFGame' ) &&
		!ClassIsChildOf( BotmatchParent.GameClass, class'Assault' )
	)
	{
		MaxTeamsEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));

		MaxTeamsEdit.SetText(MaxTeamsText);
		MaxTeamsEdit.SetHelpText(MaxTeamsHelp);
		MaxTeamsEdit.SetFont(ControlFont);
		MaxTeamsEdit.SetNumericOnly(True);
		MaxTeamsEdit.SetMaxLength(3);
		MaxTeamsEdit.Align = TA_Right;
		MaxTeamsEdit.SetDelayedNotify(True);
	}
	ControlOffset += 25;

	if(BotmatchParent.bNetworkGame)
	{
		if(ClassIsChildOf(BotmatchParent.GameClass, class'CTFGame'))
			ControlOffset -= 25;

		ForceRespawnCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
		ForceRespawnCheck.SetText(ForceRespawnText);
		ForceRespawnCheck.SetHelpText(ForceRespawnHelp);
		ForceRespawnCheck.SetFont(ControlFont);
		ForceRespawnCheck.Align = TA_Right;	
		ControlOffset += 25;
	}
*/
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	Super.BeforePaint(C, X, Y);

//	TeamScoreEdit.SetSize(ControlWidth, 1);
//	TeamScoreEdit.WinLeft = ControlLeft;
//	TeamScoreEdit.EditBoxWidth = 20;

	if( BalancePlayersCheck != None )
	{
		BalancePlayersCheck.SetSize(CheckWidth, ControlHeight);
		BalancePlayersCheck.WinLeft = ControlLeft;
	}
/*
	if(MaxTeamsEdit != None)
	{
		MaxTeamsEdit.SetSize(ControlWidth, 1);
		if( BalancePlayersCheck != None )
			MaxTeamsEdit.WinLeft = ControlRight;
		else
			MaxTeamsEdit.WinLeft = ControlLeft;
		MaxTeamsEdit.EditBoxWidth = 20;
	}

	//if(ForceRespawnCheck != None && ClassIsChildOf(BotmatchParent.GameClass, class'CTFGame'))
	//	ForceRespawnCheck.WinLeft = ControlRight;
*/
	FFSlider.SliderWidth = 90;
	//C.StrLen(FFText$" (100%)", W, H);
	FFSlider.SetSize(ControlWidth-EditWidth+95, ControlHeight);
	FFSlider.WinLeft = ControlLeft; //(WinWidth - W - FFSlider.SliderWidth) / 2;
	FFSlider.SetTextColor(TC);
}


function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch (C)
		{
			//case TeamScoreEdit:
			//	TeamScoreChanged();
			//	break;
			case FFSlider:
				FFChanged();
				break;
			//case MaxTeamsEdit:
			//	MaxTeamsChanged();
			//	break;
			case BalancePlayersCheck:
				BalancePlayersChanged();
				break;
		}
	}
}
/*
// override UTSettingsCWindow's FragLimit to make it edit TeamFragLimit
function FragChanged()
{
	Class<TeamGame>(BotmatchParent.GameClass).Default.GoalTeamScore = int(FragEdit.GetValue());
}
*/
function BalancePlayersChanged()
{
	Class<TeamGame>(BotmatchParent.GameClass).Default.bPlayersBalanceTeams = BalancePlayersCheck.bChecked;
}
/*
singular function MaxTeamsChanged()
{
	if(Int(MaxTeamsEdit.GetValue()) > MaxAllowedTeams)
		MaxTeamsEdit.SetValue(string(MaxAllowedTeams));
	if(Int(MaxTeamsEdit.GetValue()) < 2)
		MaxTeamsEdit.SetValue("2");

	Class<TeamGame>(BotmatchParent.GameClass).Default.MaxTeams = int(MaxTeamsEdit.GetValue());
}

function TeamScoreChanged()
{
	Class<TeamGame>(BotmatchParent.GameClass).Default.GoalTeamScore = int(TeamScoreEdit.GetValue());
}
*/
function FFChanged()
{
	Class<TeamGame>(BotmatchParent.GameClass).Default.FriendlyFireScale = FFSlider.GetValue() / 10;
	FFSlider.SetText(FFText$" ("$int(FFSlider.GetValue()*10)$"%)");
}

defaultproperties
{
//	TeamScoreText="Max Team Score"
//	TeamScoreHelp="When a team obtains this score, the game will end."
//	MaxTeamsText="Max Teams"
//	MaxTeamsHelp="The maximum number of different teams players are allowed to join, for this game."
	FFText="Friendly Fire"
	FFHelp="Sets how much damage teammates will take from friendly fire."
	BalancePlayersText="Balance Teams"
	BalancePlayersHelp="Balances teams by ignoring players' team choices and always putting them on the smallest team when they join."
	FragText="Team Score Limit"
	FragHelp="The game will end if a team reaches this many points. Use 0 for no score limit."
}