class UTStartGameCW extends UTMenuBotmatchCW;

// Window
var localized string ServerText;

var UWindowMessageBox EmptyMap;
var localized string EmptyMapListTitle;
var localized string EmptyMapListText;

//var UWindowMessageBox ConfirmStart;
var string JoinStatsPass;
var bool bGotStatsPass;

var UWindowPageControlPage ServerTab;

function Created()
{
	Super.Created();

	CloseButton.SetFont(F_SmallBold);
	StartButton.SetFont(F_SmallBold);

	ServerTab = Pages.AddPage(ServerText, class'UTServerSetupSC');
}

function Notify(UWindowDialogControl C, byte E)
{
	local class<MapList> ML;

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
			case StartButton:
				UTMenuStartMatchCW(UTMenuStartMatchSC(StartTab.Page).ClientArea).MapWindow.SaveConfigs();
				ML = class<MapList>(DynamicLoadObject(GameClass.Default.MapListType, class'class'));
				if(ML.Default.Maps[0] == "")
				{
					EmptyMap = MessageBox(EmptyMapListTitle, EmptyMapListText, MB_OK, MR_OK, MR_OK);
					MessageBoxWindow = EmptyMap;
					return;
				}
				Map = ML.Default.Maps[0];
				if(UTServerSetupPage(UTServerSetupSC(ServerTab.Page).ClientArea).bDedicated)
					DedicatedPressed();
				else
				{
					// This is a listen server.  If stats are enabled then ask player for a stats password
					if ((GetLevel().Game != None) && (GetLevel().Game.Default.bEnableStatLogging))
						ShowModal(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject("UTBrowser.ngWorldSecretWindow", class'Class')), 100, 100, 200, 200, self));
					else
						StartPressed();
				}
				return;
			default:
				Super.Notify(C, E);
				return;
		}
	default:
		Super.Notify(C, E);
		return;
	}
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
/*	if(W == ConfirmStart)
	{
		switch(Result)
		{
		case MR_Yes:
			Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject("UTBrowser.ngWorldSecretWindow", class'Class')), 100, 100, 200, 200, Root, True);
			break;
		case MR_No:
			GetPlayerOwner().ngSecretSet = True;
			GetPlayerOwner().SaveConfig();
			StartPressed();
			break;
		}				
	}*/

	if(W == EmptyMap)
	{
		Pages.GotoTab(Pages.GetPage(StartMatchTab)); //StartMatchTab
	}
}

function DedicatedPressed()
{
	local string URL;
	local GameInfo NewGame;
	local string LanPlay;
	local string AdminPW;

	if(UTServerSetupPage(UTServerSetupSC(ServerTab.Page).ClientArea).bLanPlay)
		LanPlay = " -lanplay";

	URL = Map $ "?Game="$GameType$"?Mutator="$MutatorList;
	// RWS CHANGE: Add AdminPassword to URL like UT2003
	AdminPW = class'UMenuBotmatchClientWindow'.default.AdminPassword;
	if(AdminPW != "")
		URL = URL $ "?AdminPassword="$AdminPW;
	//URL = URL $ "?Listen";

	ParentWindow.Close();
	// RWS Change:
	//Root.Console.CloseUWindow();
	//GetPlayerOwner().ConsoleCommand("RELAUNCH "$URL$LanPlay$" -server log="$GameClass.Default.ServerLogName);
	GetPlayerOwner().ConsoleCommand("RELAUNCH "$URL$LanPlay$" -server -log=Server.log");
}

// Override botmatch's start behavior
function StartPressed()
{
	local string URL, Checksum;
	local GameInfo NewGame;
	local string LanPlay;
	local string AdminPW;

	// RWS Change: reset?
	//GameClass.Static.ResetGame();

	if(UTServerSetupPage(UTServerSetupSC(ServerTab.Page).ClientArea).bLanPlay)
		LanPlay = " -lanplay";

	URL = Map $ "?Game="$GameType$"?Mutator="$MutatorList;
	// RWS CHANGE: Add AdminPassword to URL like UT2003
	AdminPW = class'UMenuBotmatchClientWindow'.default.AdminPassword;
	if(AdminPW != "")
		URL = URL $ "?AdminPassword="$AdminPW;
	URL = URL $ "?Listen";
// RWS CHANGE: Removed stat-related checksum crap
//	class'StatLog'.Static.GetPlayerChecksum(GetPlayerOwner(), Checksum);
//	URL = URL $ "?Checksum="$Checksum;

	// Add stats password if necessary
	if ((GetLevel().Game != None) && (GetLevel().Game.Default.bEnableStatLogging) && JoinStatsPass != "")
		URL = URL $ "?StatsPass="$JoinStatsPass;

	// Set loading texture for the listen server player
	Root.SetLoadingTexture(Map);

	ParentWindow.Close();
	// RWS Change:
	//Root.Console.CloseUWindow();
//	P2RootWindow(Root).StartingGame();
	P2RootWindow(Root).HideMenu();
	GetPlayerOwner().ClientTravel(URL$LanPlay, TRAVEL_Absolute, false);
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	// RWS COMMENTARY: This is pretty fucked up right here, waiting on the BeforePaint() event
	// for a modal window to finish, but this is how they had it and I don't feel like
	// restructuring it only to discover that the entire engine stops working as a result.
	if(bGotStatsPass)
	{
		bGotStatsPass = false;
		StartPressed();
	}
}

function Close(optional bool bByParent) 
{
	if(Root != None)
		Root.GoBack();

	Super.Close(bByParent);
}

defaultproperties
{
	StartText="Start"
	ServerText="Server"
	bNetworkGame=True
	EmptyMapListTitle="Empty Map List"
	EmptyMapListText="You must have at least 1 map in the map list to start the game."
}

