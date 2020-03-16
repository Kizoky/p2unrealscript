class UTMenuBotmatchCW extends UMenuBotmatchClientWindow;

var UWindowPageControlPage StartTab;

function CreatePages()
{
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);

	// Match/GameType/MapList Tab
	StartTab = Pages.AddPage(StartMatchTab, class'UTMenuStartMatchSC');

	if(GameClass == None)
		return;

	if(GameClass.Default.RulesMenuType != "")
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
		if(PageClass != None)
			Pages.AddPage(RulesTab, PageClass);
	}

	// Level Settings/Rules Tab
	if(GameClass.Default.SettingsMenuType != "")
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
		if(PageClass != None)
			Pages.AddPage(SettingsTab, PageClass);
	}
/*
	// Bot Settings Tab
	if(GameClass.Default.BotMenuType != "")
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
		if(PageClass != None)
			Pages.AddPage(BotConfigTab, PageClass);
	}
*/
	// Mutator Settings Tab
	Pages.AddPage(MutatorTab, class'UMenuMutatorCW');

	// Teams/Rosters Tab
	if(class<TeamGame>(GameClass) != None)
		Pages.AddPage(TeamTab, class'UMenuTeamsCW');
	else
		Pages.AddPage(RosterTab, class'UMenuRosterCW');

	// Bot Tab
	Pages.AddPage(BotConfigTab, class'UTBotConfigSClient');
}
