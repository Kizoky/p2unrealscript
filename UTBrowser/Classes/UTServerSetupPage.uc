class UTServerSetupPage extends UMenuServerSetupPage;

var UWindowEditControl GamePasswordEdit;
var localized string GamePasswordText;
var localized string GamePasswordHelp;

var UWindowEditControl AdminPasswordEdit;
var localized string AdminPasswordText;
var localized string AdminPasswordHelp;

var UWindowCheckbox EnableWebserverCheck;
var localized string EnableWebserverText;
var localized string EnableWebserverHelp;

var UWindowEditControl WebAdminUsernameEdit;
var localized string WebAdminUsernameText;
var localized string WebAdminUsernameHelp;

var UWindowEditControl WebAdminPasswordEdit;
var localized string WebAdminPasswordText;
var localized string WebAdminPasswordHelp;

var UWindowEditControl ListenPortEdit;
var localized string ListenPortText;
var localized string ListenPortHelp;

var bool bInitialized;

const GAME_PASSWORD_LOCATION = "Engine.AccessControl";

function Created()
{
	bInitialized = False;

	Super.Created();

	GamePasswordEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	GamePasswordEdit.SetText(GamePasswordText);
	GamePasswordEdit.SetHelpText(GamePasswordHelp);
	GamePasswordEdit.SetFont(ControlFont);
	GamePasswordEdit.SetNumericOnly(False);
	GamePasswordEdit.SetMaxLength(16);
	GamePasswordEdit.SetDelayedNotify(True);
	GamePasswordEdit.SetValue(GetPlayerOwner().ConsoleCommand("get" @ GAME_PASSWORD_LOCATION @ "GamePassword"));
	ControlOffset += ControlHeight;

	AdminPasswordEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	AdminPasswordEdit.SetText(AdminPasswordText);
	AdminPasswordEdit.SetHelpText(AdminPasswordHelp);
	AdminPasswordEdit.SetFont(ControlFont);
	AdminPasswordEdit.SetNumericOnly(False);
	AdminPasswordEdit.SetMaxLength(16);
	AdminPasswordEdit.SetDelayedNotify(True);
	//AdminPasswordEdit.SetValue(GetPlayerOwner().ConsoleCommand("get" @ GAME_PASSWORD_LOCATION @ "AdminPassword"));
	AdminPasswordEdit.SetValue(class'UMenuBotmatchClientWindow'.default.AdminPassword);
	ControlOffset += (ControlHeight * 1.5);

	EnableWebserverCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	EnableWebserverCheck.SetText(EnableWebserverText);
	EnableWebserverCheck.SetHelpText(EnableWebserverHelp);
	EnableWebserverCheck.SetFont(ControlFont);
	EnableWebserverCheck.Align = TA_Left;
	EnableWebserverCheck.bChecked = class'WebServer'.default.bEnabled;
	ControlOffset += ControlHeight;

	WebAdminUsernameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	WebAdminUsernameEdit.SetText(WebAdminUsernameText);
	WebAdminUsernameEdit.SetHelpText(WebAdminUsernameHelp);
	WebAdminUsernameEdit.SetFont(ControlFont);
	WebAdminUsernameEdit.SetNumericOnly(False);
	WebAdminUsernameEdit.SetMaxLength(16);
	WebAdminUsernameEdit.SetDelayedNotify(True);
	WebAdminUsernameEdit.SetValue(class'UTServerAdmin'.default.AdminUsername);
	ControlOffset += ControlHeight;

	WebAdminPasswordEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	WebAdminPasswordEdit.SetText(WebAdminPasswordText);
	WebAdminPasswordEdit.SetHelpText(WebAdminPasswordHelp);
	WebAdminPasswordEdit.SetFont(ControlFont);
	WebAdminPasswordEdit.SetNumericOnly(False);
	WebAdminPasswordEdit.SetMaxLength(16);
	WebAdminPasswordEdit.SetDelayedNotify(True);
	WebAdminPasswordEdit.SetValue(class'UTServerAdmin'.default.AdminPassword);
	ControlOffset += ControlHeight;

	ListenPortEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ListenPortEdit.SetText(ListenPortText);
	ListenPortEdit.SetHelpText(ListenPortHelp);
	ListenPortEdit.SetFont(ControlFont);
	ListenPortEdit.SetNumericOnly(True);
	ListenPortEdit.SetMaxLength(16);
	ListenPortEdit.SetDelayedNotify(True);
	ListenPortEdit.SetValue(string(class'WebServer'.default.ListenPort));
	ControlOffset += ControlHeight;

	ShowOrHideWebAdminOptions();

	bInitialized = True;
}

function ShowOrHideWebAdminOptions()
{
	if (EnableWebserverCheck.bChecked)
	{
		WebAdminUsernameEdit.ShowWindow();
		WebAdminPasswordEdit.ShowWindow();
		ListenPortEdit.ShowWindow();
	}
	else
	{
		WebAdminUsernameEdit.HideWindow();
		WebAdminPasswordEdit.HideWindow();
		ListenPortEdit.HideWindow();
	}
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
			case GamePasswordEdit:
				GetPlayerOwner().ConsoleCommand("set" @ GAME_PASSWORD_LOCATION @ "GamePassword "$GamePasswordEdit.GetValue());
				break;
			case AdminPasswordEdit:
				//GetPlayerOwner().ConsoleCommand("set" @ GAME_PASSWORD_LOCATION @ "AdminPassword "$AdminPasswordEdit.GetValue());
				class'UMenuBotmatchClientWindow'.default.AdminPassword = AdminPasswordEdit.GetValue();
				class'UMenuBotmatchClientWindow'.static.StaticSaveConfig();
				break;
			case EnableWebserverCheck:
				class'WebServer'.default.bEnabled = EnableWebserverCheck.bChecked;
				class'WebServer'.static.StaticSaveConfig();
				ShowOrHideWebAdminOptions();
				break;
			case WebAdminUsernameEdit:
				class'UTServerAdmin'.default.AdminUsername = WebAdminUsernameEdit.GetValue();
				class'UTServerAdmin'.static.StaticSaveConfig();
				break;
			case WebAdminPasswordEdit:
				class'UTServerAdmin'.default.AdminPassword = WebAdminPasswordEdit.GetValue();
				class'UTServerAdmin'.static.StaticSaveConfig();
				break;
			case ListenPortEdit:
				class'WebServer'.default.ListenPort = Int(ListenPortEdit.GetValue());
				class'WebServer'.static.StaticSaveConfig();
				break;
			}
			break;
		}
	}
	Super.Notify(C, E);
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	GamePasswordEdit.SetSize(ControlWidth, ControlHeight);
	GamePasswordEdit.WinLeft = ControlLeft;
	GamePasswordEdit.EditBoxWidth = EditWidth;

	AdminPasswordEdit.SetSize(ControlWidth, ControlHeight);
	AdminPasswordEdit.WinLeft = ControlLeft;
	AdminPasswordEdit.EditBoxWidth = EditWidth;

	WebAdminPasswordEdit.SetSize(ControlWidth, ControlHeight);
	WebAdminPasswordEdit.WinLeft = ControlLeft;
	WebAdminPasswordEdit.EditBoxWidth = EditWidth;

	WebAdminUsernameEdit.SetSize(ControlWidth, ControlHeight);
	WebAdminUsernameEdit.WinLeft = ControlLeft;
	WebAdminUsernameEdit.EditBoxWidth = EditWidth;

	EnableWebserverCheck.SetSize(CheckWidth, ControlHeight);
	EnableWebserverCheck.WinLeft = ControlLeft;

	ListenPortEdit.SetSize(ControlWidth-EditWidth+SmallEditBoxWidth, ControlHeight);
	ListenPortEdit.WinLeft = ControlLeft;
	ListenPortEdit.EditBoxWidth = SmallEditBoxWidth;

	// Keep all the text black
	GamePasswordEdit.SetTextColor(TC);
	AdminPasswordEdit.SetTextColor(TC);
	WebAdminPasswordEdit.SetTextColor(TC);
	WebAdminUsernameEdit.SetTextColor(TC);
	EnableWebserverCheck.SetTextColor(TC);
	ListenPortEdit.SetTextColor(TC);
}

defaultproperties
{
	GamePasswordText="Game Password"
	GamePasswordHelp="If a game password is set then only players who know it will be able to join the game."
	AdminPasswordText="Admin Password"
	AdminPasswordHelp="If an admin password is set then any player who knows it can use admin commands during the game."
	EnableWebserverText="Enable Web Admin"
	EnableWebserverHelp="Enables the use of a web browser to remotely administer this server (change game types, maps, kicking, banning, etc)"
	WebAdminUsernameText="Web Admin Username"
	WebAdminUsernameHelp="The username for logging in to the Web Admin interface."
	WebAdminPasswordText="Web Admin Password"
	WebAdminPasswordHelp="The password for logging in to the Web Admin interface."
	ListenPortText="Web Admin Port"
	ListenPortHelp="The port number to be used by the Web Admin interface."
}
