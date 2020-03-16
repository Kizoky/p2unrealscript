///////////////////////////////////////////////////////////////////////////////
// MenuPlayer.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The multiplayer player setup menu.
//
// History:
//	07/22/03 CRK	Added Team Selection
//	07/11/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuPlayer extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var UWindowComboControl		CharacterCombo;
var localized string		CharacterSetupText;
var localized string		CharacterSetupHelp;
var localized string		CharacterChangeText;
var localized string		CharacterChangeHelp;

var CharacterWindow			CharacterWindow;

var UWindowEditControl		NameBox;
var localized string		NameSetupText;
var localized string		NameSetupHelp;
var localized string		NameChangeText;
var localized string		NameChangeHelp;
var localized string		NameDefault;

var UWindowComboControl		TeamCombo;
var localized string		TeamSetupText;
var localized string		TeamSetupHelp;
var localized string		TeamChangeText;
var localized string		TeamChangeHelp;
var localized string		Teams[2];
var localized string		SwitchTeamWarning;
var int						CurrentTeam;

var UWindowComboControl		ConnectionCombo;
var localized string		ConnectionText;
var localized string		ConnectionHelp;
var localized string		ConnectionSpeeds[4];

var bool					bAllowChangedEvents;

var string					InitName;
var string					InitTeam;
var string					InitClass;

var UWindowMessageBox		ConfirmTeamChange;
var localized string		ConfirmTeamChangeTitle;
var localized string		ConfirmTeamChangeText;

const MultiPlayerNamePath = "Shell.MenuMulti MultiPlayerName";
const MultiPlayerClassPath = "Shell.MenuMulti MultiPlayerClass";


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	local string str;

	Super.CreateMenuContents();

	TitleAlign = TA_Center;
	ItemAlign = TA_Left;

	if (IsGameMenu())
		AddTitle(PlayerChangeText, TitleFont, TitleAlign);
	else
		AddTitle(PlayerSetupText, TitleFont, TitleAlign);

	if (IsGameMenu())
		NameBox = AddEditBox(NameChangeText, NameChangeHelp, ItemFont);
	else
		NameBox = AddEditBox(NameSetupText, NameSetupHelp, ItemFont);
	NameBox.EditBox.Font = F_Bold;

	if (IsGameMenu())
		CharacterCombo = AddComboBox(CharacterChangeText,	CharacterChangeHelp,	ItemFont);
	else
		CharacterCombo = AddComboBox(CharacterSetupText,	CharacterSetupHelp,		ItemFont);
	CharacterCombo.SetButtons(true);

	CharacterWindow = AddCharacterWindow(160);

	if (IsGameMenu())
	{
		if(GetPlayerOwner().GameReplicationInfo.bTeamGame)
			TeamCombo = AddComboBox(TeamChangeText, TeamChangeHelp, ItemFont);
	}
	else
		TeamCombo = AddComboBox(TeamSetupText, TeamSetupHelp, ItemFont);
	if (TeamCombo != None)
		TeamCombo.SetButtons(true);

	ConnectionCombo = AddComboBox(ConnectionText,	ConnectionHelp,	ItemFont);

	BackChoice = AddChoice(BackText, "", ItemFont, ItemAlign, true);

	// fill in space just so everything still lines up right during the game
	// otherwise the character's head goes behind the "Change Character" combo
	if (IsGameMenu())
	{
		if(!GetPlayerOwner().GameReplicationInfo.bTeamGame)
			AddItem(None, BackChoice.WinHeight);
		AddItem(None, BackChoice.WinHeight);
	}

	LoadValues();
	ResolutionChanged(Root.RealWidth, Root.RealHeight);
	bAllowChangedEvents = true;
}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
{
	local string CharacterClassName, DefaultClassName;
	local string CharacterDescription;
	local class<xMpPawn> CharacterClass;
	local PlayerController P;
	local int Num, CharacterIndex, DefaultTeam;
	local DMRoster DefaultRoster;
	local string CurrentLevel;
	local int i;

	P = GetPlayerOwner();

	CurrentLevel = ShellRootWindow(Root).ParseLevelName(Root.GetLevel().GetLocalURL());
	if(Right(CurrentLevel, 4) ~= ".fuk")
		CurrentLevel = Left(CurrentLevel, Len(CurrentLevel) - 4);

	// Set proper character class + team when joined to an mp game
	if(MpPlayer(P) != None && GetGameSingle() == None && Caps(CurrentLevel) != Caps(ShellRootWindow(Root).GetStartupMap()))
		MpPlayer(P).WriteTeam();

	CharacterIndex = 0;
	//DefaultTeam = Clamp(int(P.GetDefaultURL("Team")), 0, ArrayCount(Teams)-1); // PlayerReplicationInfo.Team ?
	DefaultTeam = int(P.GetDefaultURL("Team"));
	InitTeam = string(DefaultTeam);
	DefaultClassName =	P.ConsoleCommand("get" @ MultiPlayerClassPath);
						//P.GetDefaultURL("Class");	
						// string(P.PawnClass);
	InitClass = DefaultClassName;
	CharacterCombo.Clear();

	if(P.GameReplicationInfo.bTeamGame) //Teams[0] != None)	// We're in a team game - show players only on current team
	{
		LoadTeamCharacters(P.GameReplicationInfo.Teams[DefaultTeam], DefaultClassName);
		Teams[0] = P.GameReplicationInfo.Teams[0].TeamName;
		Teams[1] = P.GameReplicationInfo.Teams[1].TeamName;
	}
	else if(MpGameReplicationInfo(P.GameReplicationInfo) != None && MpGameReplicationInfo(P.GameReplicationInfo).DMRoster != None)
	{														// Non-team game - show single team roster players
		LoadTeamCharacters(MpGameReplicationInfo(P.GameReplicationInfo).DMRoster, DefaultClassName);
		//TeamCombo.HideWindow();
	}
	else													// No teams specified - show default dm roster
	{
		DefaultRoster = P.Spawn(class<DMRoster>(DynamicLoadObject("MultiGame.xDMRoster",class'Class')));
		LoadTeamCharacters(DefaultRoster, DefaultClassName);
	}
	CharacterWindow.SetCharacter(CharacterCombo.GetValue2());

	NameDefault = P.PlayerReplicationInfo.PlayerName;
	InitName = NameDefault;
	NameBox.SetValue(NameDefault);

	if(TeamCombo != None)
	{
		TeamCombo.AddItem(Teams[0], "0");
		TeamCombo.AddItem(Teams[1], "1");
		// If Team is 255, add "None" team option that gets removed if the team changes to 0 or 1
		if(DefaultTeam == 255)
			TeamCombo.SetValue("None", "255");
		else
			TeamCombo.SetSelectedIndex(DefaultTeam);
		CurrentTeam = int(TeamCombo.GetValue2());
	}

	ConnectionCombo.Clear();
	ConnectionCombo.AddItem(ConnectionSpeeds[0]);
	ConnectionCombo.AddItem(ConnectionSpeeds[1]);
	ConnectionCombo.AddItem(ConnectionSpeeds[2]);
	ConnectionCombo.AddItem(ConnectionSpeeds[3]);

	i = class'Player'.default.ConfiguredInternetSpeed;
	if (i<=2600)
		ConnectionCombo.SetSelectedIndex(0);
	else if (i<=5000)
		ConnectionCombo.SetSelectedIndex(1);
	else if (i<=10000)
		ConnectionCombo.SetSelectedIndex(2);
	else
		ConnectionCombo.SetSelectedIndex(3);
}

function LoadTeamCharacters(TeamInfo DefaultTeam, string DefaultClassName)
{
	local string InitialClass;
	local MpTeamInfo myTeamInfo;
	local class<MpPawn> PawnClass;
	local int CharacterIndex, Num, i;

	InitialClass = GetPlayerOwner().ConsoleCommand("get" @ MultiPlayerClassPath);	
	CharacterCombo.Clear();

	myTeamInfo = MpTeamInfo(DefaultTeam);
	PawnClass = myTeamInfo.AllowedTeamMembers[Num];
	while(PawnClass != None && i < 200)
	{
		CharacterCombo.AddItem(PawnClass.Default.MenuName, string(PawnClass));
		if(string(PawnClass) ~= DefaultClassName)
			CharacterIndex = Num;

		Num++;
		PawnClass = myTeamInfo.AllowedTeamMembers[Num];
		i++;
	}

	CharacterCombo.SetSelectedIndex(CharacterIndex);

	if(InitialClass != CharacterCombo.GetValue2())
		CharacterChanged();
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	if(!bAllowChangedEvents)
		return;

	Super.Notify(C, E);
	switch(E)
	{
		case DE_Change:
			switch (C)
			{
				case CharacterCombo:
					CharacterChanged();
					break;
				case NameBox:
					NameChanged();
					break;
				case TeamCombo:
					TeamChanged();
					break;
				case ConnectionCombo:
					ConnectionChanged();
					break;
			}
			break;
			
		case DE_Click:
			switch (C)
			{
				case BackChoice:
					GoBack();
					break;
			}
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Update values when controls have changed.
///////////////////////////////////////////////////////////////////////////////
function CharacterChanged()
{
	CharacterWindow.SetCharacter(CharacterCombo.GetValue2());

	GetPlayerOwner().UpdateURL("Class", CharacterCombo.GetValue2(), True);
	GetPlayerOwner().ConsoleCommand("set" @ MultiPlayerClassPath @ CharacterCombo.GetValue2());
}

function NameChanged()
{
	local string N;

	bAllowChangedEvents = false;
	N = NameBox.GetValue();
	if ( Len(N) > 20 )
		N = left(N,20);
	ReplaceText(N, " ", "_");
	NameBox.SetValue(N);
	bAllowChangedEvents = true;

	GetPlayerOwner().UpdateURL("Name", NameBox.GetValue(), True);
	GetPlayerOwner().ConsoleCommand("set" @ MultiPlayerNamePath @ NameBox.GetValue());
}

function TeamChanged()
{
	if(CurrentTeam != int(TeamCombo.GetValue2()))
	{
		if (IsGameMenu())
			ConfirmTeamChange = MessageBox(ConfirmTeamChangeTitle, ConfirmTeamChangeText, MB_YESNO, MR_NO, MR_YES);
		else
			ChangeTeamNow();
	}
}

function ChangeTeamNow()
{
	local PlayerController P;
	P = GetPlayerOwner();
	if(P.GameReplicationInfo.bTeamGame)
		LoadTeamCharacters(P.GameReplicationInfo.Teams[int(TeamCombo.GetValue2())], InitClass);	//P.GetDefaultURL("Class"));
	CurrentTeam = int(TeamCombo.GetValue2());
	P.UpdateURL("Team", TeamCombo.GetValue2(), True);
}
/*
function OnCleanUp()
{
	Super.OnCleanUp();
	SaveConfigs();
}
*/
function SaveConfigs()
{
	local PlayerController P;

	P = GetPlayerOwner();

	// Set Name, Team, and Character
	if(InitName != NameBox.GetValue())
		P.ChangeName(NameBox.GetValue());
	
	if(TeamCombo != None && InitTeam != TeamCombo.GetValue2())
		P.ChangeTeam(int(TeamCombo.GetValue2()));

	if(InitClass != P.ConsoleCommand("get" @ MultiPlayerClassPath))
		if(MpPlayer(P) != None)
			MpPlayer(P).ChangeLoadout(P.GetDefaultURL("Class"));

	Super.SaveConfigs();
	P.SaveConfig();
	P.PlayerReplicationInfo.SaveConfig();
}

function ResolutionChanged(float W, float H)
{
	local float GlobalScale;

	Super.ResolutionChanged(W, H);

	GlobalScale = 1.00;

	if(H > 1199)
		CharacterWindow.SetScale(0.010 * GlobalScale);
	else if(H > 1023)
		CharacterWindow.SetScale(0.013 * GlobalScale);
	else if(H > 959)
		CharacterWindow.SetScale(0.014 * GlobalScale);
	else if(H > 767)
		CharacterWindow.SetScale(0.017 * GlobalScale);
	else if(H > 599)
		CharacterWindow.SetScale(0.021 * GlobalScale);
	else if(H > 479)
		CharacterWindow.SetScale(0.025 * GlobalScale);
	else if(H > 383)
		CharacterWindow.SetScale(0.028 * GlobalScale);
	else //if(H > 239 && H < 241)
		CharacterWindow.SetScale(0.031 * GlobalScale);
}

function ConnectionChanged()
	{
	local int NewSpeed;

	switch(ConnectionCombo.GetSelectedIndex())
		{
		case 0:
			NewSpeed = 2600;
			break;
		case 1:
			NewSpeed = 5000;
			break;
		case 2:
			NewSpeed = 10000;
			break;
		case 3:
			NewSpeed = 20000;
			break;
		}
	GetPlayerOwner().ConsoleCommand("NETSPEED" @ NewSpeed);
	}

function GoBack()
{
	//SaveConfigs();
	Super.GoBack();
	Close();
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	CharacterWindow.Close(bByParent);
}

///////////////////////////////////////////////////////////////////////////////
// Callback for when message box is done
///////////////////////////////////////////////////////////////////////////////
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if (W == ConfirmTeamChange)
	{
		ConfirmTeamChange = None;
		if (Result == MR_Yes)
		{
			ChangeTeamNow();
		}
		else
		{
			bAllowChangedEvents = false;
			TeamCombo.SetSelectedIndex(CurrentTeam);
			bAllowChangedEvents = true;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuWidth = 500
	fCommonCtlArea = 0.42

	CharacterSetupText = "Character"
	CharacterSetupHelp  = "The character you want to play as.  This is ignored if you join a game with specific teams or rosters."
	CharacterChangeText = "Change Character"
	CharacterChangeHelp = "Change your character.  Your character won't change until the next time you die."

	NameSetupText = "Name"
	NameSetupHelp  = "The name you want to use in the game"
	NameChangeText = "Change Name"
	NameChangeHelp = "Change your name.  Your name will change immediately."
	NameDefault = "Player"

	TeamSetupText = "Team"
	TeamSetupHelp  = "The team you want to play on.  This is ignored if you join a game with 'team balancing' turned on."
	TeamChangeText = "Switch Teams"
	TeamChangeHelp = "Change the team you're on."
	Teams(0) = "Red"
	Teams(1) = "Blue"

	ConfirmTeamChangeTitle = "Switch Teams"
	ConfirmTeamChangeText = "Some games don't allow switching teams.\\n\\nIf this game allows switching and the game already started then your character will die and you'll lose one point.\\n\\nDo you want to switch teams?"

	ConnectionText = "Connection"
	ConnectionHelp = "Pick the closest match for your internet connection."
	ConnectionSpeeds(0) = "Modem (Dialup)"
	ConnectionSpeeds(1) = "ISDN"
	ConnectionSpeeds(2) = "Cable or DSL"
	ConnectionSpeeds(3) = "T1 or LAN"
}
