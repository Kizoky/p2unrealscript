class UMenuServerSetupPage extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool bInitialized;

var UWindowCheckBox DedicatedCheck;
var localized string DedicatedText;
var localized string DedicatedHelp;
var config bool bDedicated;

var localized string DedicatedWarningTitle;
var localized string DedicatedWarningText;

var UWindowEditControl AdminEMailEdit;
var localized string AdminEMailText;
var localized string AdminEMailHelp;

var UWindowEditControl AdminNameEdit;
var localized string AdminNameText;
var localized string AdminNameHelp;

/* RWS CHANGE: No MOTD
var UWindowEditControl MOTDLine1Edit;
var localized string MOTDLine1Text;

var UWindowEditControl MOTDLine2Edit;
var localized string MOTDLine2Text;

var UWindowEditControl MOTDLine3Edit;
var localized string MOTDLine3Text;

var UWindowEditControl MOTDLine4Edit;
var localized string MOTDLine4Text;

var localized string MOTDHelp;
*/
var UWindowEditControl ServerNameEdit;
var localized string ServerNameText;
var localized string ServerNameHelp;

var UWindowCheckbox DoUplinkCheck;
var localized string DoUplinkText;
var localized string DoUplinkHelp;

var UWindowCheckbox ngWorldStatsCheck;
var localized string ngWorldStatsText;
var localized string ngWorldStatsHelp;

//var UWindowCheckbox LanPlayCheck;
//var localized string LanPlayText;
//var localized string LanPlayHelp;

// Max Players
var UWindowEditControl MaxPlayersEdit;
var localized string MaxPlayersText;
var localized string MaxPlayersHelp;

// Max Spectators
var UWindowEditControl MaxSpectatorsEdit;
var localized string MaxSpectatorsText;
var localized string MaxSpectatorsHelp;

var config bool bLanPlay;
var Class IpServerClass;

function Created()
{
	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));

	bInitialized = False;

	Super.Created();

	DedicatedCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	DedicatedCheck.SetText(DedicatedText);
	DedicatedCheck.SetHelpText(DedicatedHelp);
	DedicatedCheck.SetFont(ControlFont);
	DedicatedCheck.SetValue(bDedicated);
	ControlOffset += (ControlHeight * 0.75);

	DoUplinkCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	DoUplinkCheck.SetText(DoUplinkText);
	DoUplinkCheck.SetHelpText(DoUplinkHelp);
	DoUplinkCheck.SetFont(ControlFont);
	// Force IPServer to load!!!
	IPServerClass = Class(DynamicLoadObject("IpDrv.UdpServerUplink", class'Class'));
	DoUplinkCheck.bChecked = GetPlayerOwner().ConsoleCommand("get IpDrv.UdpServerUplink DoUplink") ~= "True";
	ControlOffset += (ControlHeight * 0.75);

	ngWorldStatsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ngWorldStatsCheck.SetText(ngWorldStatsText);
	ngWorldStatsCheck.SetHelpText(ngWorldStatsHelp);
	ngWorldStatsCheck.SetFont(ControlFont);
	if (GetLevel().Game != None)
		ngWorldStatsCheck.bChecked = GetLevel().Game.Default.bEnableStatLogging;
	else
		ngWorldStatsCheck.bDisabled = True;
	ControlOffset += (ControlHeight * 0.75);

	ControlOffset += ControlHeight * 0.5;

	if(BotmatchParent.bNetworkGame)
	{
		// Max Players
		MaxPlayersEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
		MaxPlayersEdit.SetText(MaxPlayersText);
		MaxPlayersEdit.SetHelpText(MaxPlayersHelp);
		MaxPlayersEdit.SetFont(F_SmallBold);
		MaxPlayersEdit.SetNumericOnly(True);
		MaxPlayersEdit.SetMaxLength(2);
		MaxPlayersEdit.SetDelayedNotify(True);
		ControlOffset += ControlHeight;

		// Max Spectators
		MaxSpectatorsEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
		MaxSpectatorsEdit.SetText(MaxSpectatorsText);
		MaxSpectatorsEdit.SetHelpText(MaxSpectatorsHelp);
		MaxSpectatorsEdit.SetFont(F_SmallBold);
		MaxSpectatorsEdit.SetNumericOnly(True);
		MaxSpectatorsEdit.SetMaxLength(2);
		MaxSpectatorsEdit.SetDelayedNotify(True);
		ControlOffset += ControlHeight;
	}

	ControlOffset += ControlHeight * 0.5;

	// RWS CHANGE: Optimise for LAN doesn't work
/*	LanPlayCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	LanPlayCheck.SetText(LanPlayText);
	LanPlayCheck.SetHelpText(LanPlayHelp);
	LanPlayCheck.SetFont(ControlFont);
	LanPlayCheck.Align = TA_Left;
	LanPlayCheck.bChecked = bLanPlay;
	ControlOffset += ControlHeight;
*/
	ServerNameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ServerNameEdit.SetText(ServerNameText);
	ServerNameEdit.SetHelpText(ServerNameHelp);
	ServerNameEdit.SetFont(ControlFont);
	ServerNameEdit.SetNumericOnly(False);
	ServerNameEdit.SetMaxLength(205);
	ServerNameEdit.SetDelayedNotify(True);
	ServerNameEdit.SetValue(class'Engine.GameReplicationInfo'.default.ServerName);
	ControlOffset += ControlHeight;

	AdminNameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	AdminNameEdit.SetText(AdminNameText);
	AdminNameEdit.SetHelpText(AdminNameHelp);
	AdminNameEdit.SetFont(ControlFont);
	AdminNameEdit.SetNumericOnly(False);
	AdminNameEdit.SetMaxLength(205);
	AdminNameEdit.SetDelayedNotify(True);
	AdminNameEdit.SetValue(class'Engine.GameReplicationInfo'.default.AdminName);
	ControlOffset += ControlHeight;
	
	AdminEmailEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	AdminEmailEdit.SetText(AdminEmailText);
	AdminEmailEdit.SetHelpText(AdminEmailHelp);
	AdminEmailEdit.SetFont(ControlFont);
	AdminEmailEdit.SetNumericOnly(False);
	AdminEmailEdit.SetMaxLength(205);
	AdminEmailEdit.SetDelayedNotify(True);
	AdminEmailEdit.SetValue(class'Engine.GameReplicationInfo'.default.AdminEmail);
	ControlOffset += ControlHeight;
/*
	MOTDLine1Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	MOTDLine1Edit.SetText(MOTDLine1Text);
	MOTDLine1Edit.SetHelpText(MOTDHelp);
	MOTDLine1Edit.SetFont(ControlFont);
	MOTDLine1Edit.SetNumericOnly(False);
	MOTDLine1Edit.SetMaxLength(205);
	MOTDLine1Edit.SetDelayedNotify(True);
	MOTDLine1Edit.SetValue(class'Engine.GameReplicationInfo'.default.MOTDLine1);
	ControlOffset += ControlHeight;

	MOTDLine2Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	MOTDLine2Edit.SetText(MOTDLine2Text);
	MOTDLine2Edit.SetHelpText(MOTDHelp);
	MOTDLine2Edit.SetFont(ControlFont);
	MOTDLine2Edit.SetNumericOnly(False);
	MOTDLine2Edit.SetMaxLength(205);
	MOTDLine2Edit.SetDelayedNotify(True);
	MOTDLine2Edit.SetValue(class'Engine.GameReplicationInfo'.default.MOTDLine2);
	ControlOffset += ControlHeight;

	MOTDLine3Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	MOTDLine3Edit.SetText(MOTDLine3Text);
	MOTDLine3Edit.SetHelpText(MOTDHelp);
	MOTDLine3Edit.SetFont(ControlFont);
	MOTDLine3Edit.SetNumericOnly(False);
	MOTDLine3Edit.SetMaxLength(205);
	MOTDLine3Edit.SetDelayedNotify(True);
	MOTDLine3Edit.SetValue(class'Engine.GameReplicationInfo'.default.MOTDLine3);
	ControlOffset += ControlHeight;

	MOTDLine4Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	MOTDLine4Edit.SetText(MOTDLine4Text);
	MOTDLine4Edit.SetHelpText(MOTDHelp);
	MOTDLine4Edit.SetFont(ControlFont);
	MOTDLine4Edit.SetNumericOnly(False);
	MOTDLine4Edit.SetMaxLength(205);
	MOTDLine4Edit.SetDelayedNotify(True);
	MOTDLine4Edit.SetValue(class'Engine.GameReplicationInfo'.default.MOTDLine4);
	ControlOffset += ControlHeight;*/
}

function LoadCurrentValues()
{
	if(MaxPlayersEdit != None)
		MaxPlayersEdit.SetValue(string(Class<DeathMatch>(BotmatchParent.GameClass).Default.MaxPlayers));

	if(MaxSpectatorsEdit != None)
		MaxSpectatorsEdit.SetValue(string(Class<DeathMatch>(BotmatchParent.GameClass).Default.MaxSpectators));
}

function Notify(UWindowDialogControl C, byte E)
{
	if(bInitialized)
	{
		switch(E)
		{
		case DE_Change:
			switch(C)
			{
			case DedicatedCheck:
				bDedicated = DedicatedCheck.bChecked;
				SaveConfigs();
				if(bDedicated)
					BotmatchParent.MessageBoxWindow = MessageBox(DedicatedWarningTitle, DedicatedWarningText, MB_OK, MR_OK);
				break;
			case MaxPlayersEdit:
				MaxPlayersChanged();
				break;
			case MaxSpectatorsEdit:
				MaxSpectatorsChanged();
				break;
			case AdminEMailEdit:
				class'Engine.GameReplicationInfo'.default.AdminEmail = AdminEmailEdit.GetValue();
				break;
			case AdminNameEdit:
				class'Engine.GameReplicationInfo'.default.AdminName = AdminNameEdit.GetValue();
				break;
/*			case MOTDLine1Edit:
				class'Engine.GameReplicationInfo'.default.MOTDLine1 = MOTDLine1Edit.GetValue();
				break;
			case MOTDLine2Edit:
				class'Engine.GameReplicationInfo'.default.MOTDLine2 = MOTDLine2Edit.GetValue();
				break;
			case MOTDLine3Edit:
				class'Engine.GameReplicationInfo'.default.MOTDLine3 = MOTDLine3Edit.GetValue();
				break;
			case MOTDLine4Edit:
				class'Engine.GameReplicationInfo'.default.MOTDLine4 = MOTDLine4Edit.GetValue();
				break;*/
			case ServerNameEdit:
				class'Engine.GameReplicationInfo'.default.ServerName = ServerNameEdit.GetValue();
				break;
			case DoUplinkCheck:
				if(DoUplinkCheck.bChecked)
					GetPlayerOwner().ConsoleCommand("set IpDrv.UdpServerUplink DoUplink True");
				else
					GetPlayerOwner().ConsoleCommand("set IpDrv.UdpServerUplink DoUplink False");
				IPServerClass.Static.StaticSaveConfig();
				break;
			case ngWorldStatsCheck:
				if (GetLevel().Game != None)
				{
					GetLevel().Game.bEnableStatLogging = ngWorldStatsCheck.bChecked;
					GetLevel().Game.SaveConfig();
				}
				break;
			break;
			}
		}
	}
	Super.Notify(C, E);
}

function SaveConfigs()
{
	SaveConfig();
	Super.SaveConfigs();
	class'Engine.GameReplicationInfo'.static.StaticSaveConfig();
}

function AfterCreate()
{
	Super.AfterCreate();

	LoadCurrentValues();
	bInitialized = True;
}

function MaxPlayersChanged()
{
	if(int(MaxPlayersEdit.GetValue()) > 16)
		MaxPlayersEdit.SetValue("16");
	if(int(MaxPlayersEdit.GetValue()) < 1)
		MaxPlayersEdit.SetValue("1");

	Class<DeathMatch>(BotmatchParent.GameClass).Default.MaxPlayers = int(MaxPlayersEdit.GetValue());
}

function MaxSpectatorsChanged()
{
	if(int(MaxSpectatorsEdit.GetValue()) > 16)
		MaxSpectatorsEdit.SetValue("16");
	
	if(int(MaxSpectatorsEdit.GetValue()) < 0)
		MaxSpectatorsEdit.SetValue("0");

	Class<DeathMatch>(BotmatchParent.GameClass).Default.MaxSpectators = int(MaxSpectatorsEdit.GetValue());
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	DedicatedCheck.SetSize(CheckWidth, ControlHeight);
	DedicatedCheck.WinLeft = ControlLeft;

	if(MaxPlayersEdit != None)
	{
		MaxPlayersEdit.SetSize(ControlWidth-EditWidth+SmallEditBoxWidth, ControlHeight);
		MaxPlayersEdit.WinLeft = ControlLeft;
		MaxPlayersEdit.EditBoxWidth = SmallEditBoxWidth;
		MaxPlayersEdit.SetTextColor(TC);
	}

	if(MaxSpectatorsEdit != None)
	{
		MaxSpectatorsEdit.SetSize(ControlWidth-EditWidth+SmallEditBoxWidth, ControlHeight);
		MaxSpectatorsEdit.WinLeft = ControlLeft;
		MaxSpectatorsEdit.EditBoxWidth = SmallEditBoxWidth;
		MaxSpectatorsEdit.SetTextColor(TC);
	}

	ServerNameEdit.SetSize(ControlWidth, ControlHeight);
	ServerNameEdit.WinLeft = ControlLeft;
	ServerNameEdit.EditBoxWidth = EditWidth;

	AdminNameEdit.SetSize(ControlWidth, ControlHeight);
	AdminNameEdit.WinLeft = ControlLeft;
	AdminNameEdit.EditBoxWidth = EditWidth;

	AdminEmailEdit.SetSize(ControlWidth, ControlHeight);
	AdminEmailEdit.WinLeft = ControlLeft;
	AdminEmailEdit.EditBoxWidth = EditWidth;

/*	MOTDLine1Edit.SetSize(ControlWidth, ControlHeight);
	MOTDLine1Edit.WinLeft = ControlLeft;
	MOTDLine1Edit.EditBoxWidth = EditWidth;

	MOTDLine2Edit.SetSize(ControlWidth, ControlHeight);
	MOTDLine2Edit.WinLeft = ControlLeft;
	MOTDLine2Edit.EditBoxWidth = EditWidth;
	
	MOTDLine3Edit.SetSize(ControlWidth, ControlHeight);
	MOTDLine3Edit.WinLeft = ControlLeft;
	MOTDLine3Edit.EditBoxWidth = EditWidth;

	MOTDLine4Edit.SetSize(ControlWidth, ControlHeight);
	MOTDLine4Edit.WinLeft = ControlLeft;
	MOTDLine4Edit.EditBoxWidth = EditWidth;
*/
	DoUplinkCheck.SetSize(CheckWidth, ControlHeight);
	DoUplinkCheck.WinLeft = ControlLeft;

	ngWorldStatsCheck.SetSize(CheckWidth, ControlHeight);
	ngWorldStatsCheck.WinLeft = ControlLeft;

	//LanPlayCheck.SetSize(CheckWidth, ControlHeight);
	//LanPlayCheck.WinLeft = ControlLeft;

	// Keep all the text black
	DedicatedCheck.SetTextColor(TC);
	ServerNameEdit.SetTextColor(TC);
	AdminNameEdit.SetTextColor(TC);
	AdminEmailEdit.SetTextColor(TC);
/*	MOTDLine1Edit.SetTextColor(TC);
	MOTDLine2Edit.SetTextColor(TC);
	MOTDLine3Edit.SetTextColor(TC);
	MOTDLine4Edit.SetTextColor(TC);
	DoUplinkCheck.SetTextColor(TC);*/
	
//	LanPlayCheck.SetTextColor(TC);
}

defaultproperties
{
	PageHeaderText="Your computer will be acting as a server to host the game."
	ControlWidthPercent=0.66
	bDedicated=false
	DedicatedText="Dedicated Server"
	DedicatedHelp="A dedicated server gives better performance but you won't be able to join the game using this computer."
	DedicatedWarningTitle="Dedicated Server"
	DedicatedWarningText="You have enabled Dedicated Server mode.\\n\\nIf you press START now, the server will appear as a small icon near the clock on your task bar.  You can right-click on the icon to control the server.\\n\\nRunning the game again while a Dedicated Server is already running will result in poor performance.  If you want to play and host a game at the same time then you should turn off the Dedicated Server option."
	AdminEMailText="Admin Email"
	AdminEMailHelp="Email address where players can contact you about your server.  Leave blank if you don't want any email from players."
	AdminNameText="Admin Name"
	AdminNameHelp="Administrator name for your server."
	//MOTDLine1Text="MOTD Line 1"
	//MOTDLine2Text="MOTD Line 2"
	//MOTDLine3Text="MOTD Line 3"
	//MOTDLine4Text="MOTD Line 4"
	//MOTDHelp="Enter a message of the day which will be presented to users upon joining your server."
	ServerNameText="Server Name"
	ServerNameHelp="The name that will be listed when people are looking for games to join."
	DoUplinkText="Public Listing"
	DoUplinkHelp="Allows internet players to see your server when they are looking for games to join."
	ngWorldStatsText="Collect Game Stats"
	ngWorldStatsHelp="Allows your server to collect statistics about games and players, such as kills, deaths, and so on."
	//LanPlayText="Optimize for LAN"
	//LanPlayHelp="If checked, a dedicated server started will be optimized for play on a LAN."
	MaxPlayersText="Maximum Players"
	MaxPlayersHelp="The most players allowed to join your server.  Too many players can result in very poor server performance."
	MaxSpectatorsText="Maximum Spectators"
	MaxSpectatorsHelp="The most spectators allowed to join your server.  Too many spectators can result in poor server performance."
}
