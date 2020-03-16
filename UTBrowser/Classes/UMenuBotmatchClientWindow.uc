class UMenuBotmatchClientWindow extends UWindowDialogClientWindow;

// Game Information
var config string Map;
var config string GameType;
var class<GameInfo> GameClass;
var config string AdminPassword;

var bool bNetworkGame;

// Window
var UMenuPageControl Pages;
var UWindowSmallButton CloseButton;
var UWindowSmallButton StartButton;

var UWindowMessageBox MessageBoxWindow;

var localized string StartMatchTab, RulesTab, SettingsTab, BotConfigTab, MutatorTab, TeamTab, RosterTab;
var localized string StartText;
var localized string BackText;

var config string MutatorList;
var config bool bKeepMutators;

function Created()
{
	if(!bKeepMutators)
		MutatorList = "";

	CreatePages();

	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 16));
	CloseButton.SetText(BackText);
	StartButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-106, WinHeight-24, 48, 16));
	StartButton.SetText(StartText);

	Super.Created();
}

function CreatePages()	// OBSOLETE - not called!
{
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);
	Pages.AddPage(StartMatchTab, class'UMenuStartMatchScrollClient');

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(RulesTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(SettingsTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(BotConfigTab, PageClass);
}

function Resized()
{
	Pages.WinWidth = WinWidth;
	Pages.Winheight = WinHeight - 24;

	CloseButton.WinLeft = WinWidth-52;
	CloseButton.WinTop = WinHeight-20;
	StartButton.WinLeft = WinWidth-102;
	StartButton.WinTop = WinHeight-20;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight-LookAndFeel.TabUnselectedM.H, T);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
		case StartButton:
			StartPressed();
			break;
		case CloseButton:
			UWindowFramedWindow(GetParent(class'UWindowFramedWindow')).Close();
			break;
		}
	}
}

function StartPressed()
{
	local string URL;
	local GameInfo NewGame;

	// Reset the game class.
	// RWS Change: how to reset a game?
	//GameClass.Static.ResetGame();

	URL = Map $ "?Game="$GameType$"?Mutator="$MutatorList;

	ParentWindow.Close();
	// RWS Change: closeuwindow
	//Root.Console.CloseUWindow();
//	P2RootWindow(Root).StartingGame();
	GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}

function GameChanged()
{
	local UWindowPageControlPage RulesPage, SettingsPage, BotConfigPage, TeamPage;
	local class<UWindowPageWindow> PageClass;

	// Change out the rules page...
	if(GameClass.Default.RulesMenuType != "")
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
		RulesPage = Pages.GetPage(RulesTab);
		if(PageClass != None)
			Pages.InsertPage(RulesPage, RulesTab, PageClass);
		Pages.DeletePage(RulesPage);
	}
	// Change out the settings page...
	if(GameClass.Default.SettingsMenuType != "")
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
		SettingsPage = Pages.GetPage(SettingsTab);
		if(PageClass != None)
			Pages.InsertPage(SettingsPage, SettingsTab, PageClass);
		Pages.DeletePage(SettingsPage);
	}
	// Change out the bots page...
/*	if(GameClass.Default.BotMenuType != "")
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
		BotConfigPage = Pages.GetPage(BotConfigTab);
		if(PageClass != None)
			Pages.InsertPage(BotConfigPage, BotConfigTab, PageClass);
		Pages.DeletePage(BotConfigPage);
	}
*/
	// Change out the Teams/Rosters page
	TeamPage = Pages.GetPage(TeamTab);
	if (TeamPage == None)
		TeamPage = Pages.GetPage(RosterTab);
	if(class<TeamGame>(GameClass) != None)
		Pages.InsertPage(TeamPage, TeamTab, class'UMenuTeamsCW');
	else
		Pages.InsertPage(TeamPage, RosterTab, class'UMenuRosterCW');
	if(TeamPage != None)
		Pages.DeletePage(TeamPage);

	// Bot Menu Page
	BotConfigPage = Pages.GetPage(BotConfigTab);
	Pages.InsertPage(BotConfigPage, BotConfigTab, class'UTBotConfigSClient');
	Pages.DeletePage(BotConfigPage);
}

function SaveConfigs()
{
	if (GameClass != None)
		GameClass.Static.StaticSaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
	GameType="MultiGame.xDeathMatch"
	StartText="Start"
	BackText="Back"
	StartMatchTab="General"
	RulesTab="Rules"
	SettingsTab="Settings"
	BotConfigTab="Morons"
	MutatorTab="Modifiers"
	TeamTab="Teams"
	RosterTab="Roster"
	bKeepMutators=False
}