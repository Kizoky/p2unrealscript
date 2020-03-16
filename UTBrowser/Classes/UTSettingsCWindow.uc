class UTSettingsCWindow extends UMenuGameSettingsBase;

// Tournament Mode - Max number of players must join before match will start
//var UWindowCheckbox TourneyCheck;
//var localized string TourneyText;
//var localized string TourneyHelp;

// Players Must Be Ready
var UWindowCheckBox ReadyCheck;
var localized string ReadyText;
var localized string ReadyHelp;

// Force Players to Respawn Automatically
var UWindowCheckbox ForceRespawnCheck;
var localized string ForceRespawnText;
var localized string ForceRespawnHelp;

var localized string MaxLivesText;
var localized string MaxLivesHelp;

function Created()
{
	Super.Created();
/*
	// Tournament Mode
	TourneyCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	TourneyCheck.SetText(TourneyText);
	TourneyCheck.SetHelpText(TourneyHelp);
	TourneyCheck.SetFont(ControlFont);
	ControlOffset += ControlHeight;
*/
	// Players Must Be Ready
	ReadyCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ReadyCheck.SetText(ReadyText);
	ReadyCheck.SetHelpText(ReadyHelp);
	ReadyCheck.SetFont(ControlFont);
	ControlOffset += ControlHeight;
}

function SetupNetworkOptions()
{
	Super.SetupNetworkOptions();

	if(BotmatchParent.bNetworkGame)
	{
		ForceRespawnCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
		ForceRespawnCheck.SetText(ForceRespawnText);
		ForceRespawnCheck.SetHelpText(ForceRespawnHelp);
		ForceRespawnCheck.SetFont(ControlFont);
		ControlOffset += ControlHeight;
	}
}

function LoadCurrentValues()
{
	local int S;

	if (bFragEditEnabled)
		FragEdit.SetValue(string(Class<DeathMatch>(BotmatchParent.GameClass).Default.GoalScore));

	TimeEdit.SetValue(string(Class<DeathMatch>(BotmatchParent.GameClass).Default.TimeLimit));

//	if(WeaponsCheck != None)
//		WeaponsCheck.bChecked = Class<DeathMatch>(BotmatchParent.GameClass).Default.bWeaponStay;

//	if(BehindViewCheck != None)
//		BehindViewCheck.bChecked = Class<DeathMatch>(BotmatchParent.GameClass).Default.bAllowBehindView;

//	TourneyCheck.bChecked = Class<DeathMatch>(BotmatchParent.GameClass).Default.bTournament;

	if(ReadyCheck != None)
		ReadyCheck.bChecked = Class<DeathMatch>(BotmatchParent.GameClass).Default.bPlayersMustBeReady;

	if(ForceRespawnCheck != None)
		ForceRespawnCheck.bChecked = Class<DeathMatch>(BotmatchParent.GameClass).Default.bForceRespawn;

//	S = Class<DeathMatch>(BotmatchParent.GameClass).Default.GameSpeed * 100.0;
//	SpeedSlider.SetValue(S);
//	SpeedSlider.SetText(SpeedText$" ["$S$"%]:");
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

//	TourneyCheck.SetSize(ControlWidth, ControlHeight);
//	TourneyCheck.WinLeft = ControlLeft;

	ReadyCheck.SetSize(CheckWidth, ControlHeight);
	ReadyCheck.WinLeft = ControlLeft;

	if(ForceRespawnCheck != None)
	{
		ForceRespawnCheck.SetSize(CheckWidth, ControlHeight);
		ForceRespawnCheck.WinLeft = ControlLeft;
	}
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
//		case TourneyCheck:
//			TourneyChanged();
//			break;
		case ReadyCheck:
			ReadyChanged();
			break;
		case ForceRespawnCheck:
			ForceRespawnChanged();
			break;
		}
		break;
	}
}

/*function TourneyChanged()
{
	Class<DeathMatch>(BotmatchParent.GameClass).Default.bTournament = TourneyCheck.bChecked;
}*/

function ReadyChanged()
{
	Class<DeathMatch>(BotmatchParent.GameClass).Default.bPlayersMustBeReady = ReadyCheck.bChecked;
}

function ForceRespawnChanged()
{
	Class<DeathMatch>(BotmatchParent.GameClass).Default.bForceRespawn = ForceRespawnCheck.bChecked;
}

function FragChanged()
{
	if (bFragEditEnabled)
		Class<DeathMatch>(BotmatchParent.GameClass).Default.GoalScore = int(FragEdit.GetValue());
}

singular function TimeChanged()
{
	local int newtime;

	newtime = int(TimeEdit.GetValue());
	if (newtime == 1)
		newtime = 2;
	Class<DeathMatch>(BotmatchParent.GameClass).Default.TimeLimit = newtime;
}

/*function WeaponsChecked()
{
	Class<DeathMatch>(BotmatchParent.GameClass).Default.bWeaponStay = WeaponsCheck.bChecked;
}*/

/*function BehindViewChanged()
{
	Class<DeathMatch>(BotmatchParent.GameClass).Default.bAllowBehindView = BehindViewCheck.bChecked;
}*/

/*function SpeedChanged()
{
	local int S;

	S = SpeedSlider.GetValue();
	SpeedSlider.SetText(SpeedText$" ["$S$"%]:");
	Class<DeathMatch>(BotmatchParent.GameClass).Default.GameSpeed = float(S) / 100.0;
}*/

function SaveConfigs()
{
	Super.SaveConfigs();
	BotmatchParent.GameClass.static.StaticSaveConfig();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
//	TourneyText="Tournament Mode"
//	TourneyHelp="The match will only start when the maximum number of players have joined the game."
	ReadyText="Players Must Be Ready"
	ReadyHelp="Waits for all players to say they are ready before starting the match."
	ForceRespawnText="Auto Restart"
	ForceRespawnHelp="Automatically restarts players when they die instead of waiting for them to press FIRE."
	MaxLivesText="Max Lives"
	MaxLivesHelp="Players are limited to this many lives.  Use 0 for unlimited lives."
}