class UTServerAdmin extends WebApplication
	config;

var() class<UTServerAdminSpectator> SpectatorType;
var UTServerAdminSpectator Spectator;

var	ListItem GameTypeList;

var ListItem IncludeMaps;
var ListItem ExcludeMaps;

var ListItem IncludeMutators;
var ListItem ExcludeMutators;

var WebResponse		Resp;

var config string MenuPage;
var config string RootPage;

var config string CurrentPage;
var config string CurrentMenuPage;
var config string CurrentIndexPage;
var config string CurrentPlayersPage;
var config string CurrentGamePage;
var config string CurrentConsolePage;
var config string CurrentConsoleLogPage;
var config string CurrentConsoleSendPage;
var config string DefaultSendText;
var config string CurrentMutatorsPage;
var config string CurrentRestartPage;

var config string DefaultsPage;
var config string DefaultsMenuPage;
var config string DefaultsMapsPage;
var config string DefaultsRulesPage;
var config string DefaultsSettingsPage;
var config string DefaultsBotsPage;
var config string DefaultsServerPage;
var config string DefaultsIPPolicyPage;
var config string DefaultsRestartPage;

var config string MessagePage;

var config string DefaultBG;
var config string HighlightedBG;

var localized string WaitTitle;
var localized string MapChanging;

var localized string Error;
var localized string ErrorAuthenticating;

var config string AdminRealm;
var config string AdminUsername;
var config string AdminPassword;

var localized string ServerAdminSpectatorName;

var string htm;

const GAME_PASSWORD_LOCATION = "Engine.AccessControl";

event Init()
{
	Super.Init();
	
	if (SpectatorType != None)
		Spectator = Level.Spawn(SpectatorType);
	else
		Spectator = Level.Spawn(class'UTServerAdminSpectator');
	
	// RWS CHANGE: Merged from UT2003 2199
	if (Spectator != None)
	{
		// RWS CHANGE: Set the server admin spectator to only be a spectator!
		Spectator.PlayerReplicationInfo.bOnlySpectator = true;
		// RWS CHANGE: Change the name, too, so we can regognize it's the server admin spectator, if needed
		Spectator.PlayerReplicationInfo.PlayerName = ServerAdminSpectatorName;
		Spectator.Server = self;
	}

	// won't change as long as the server is up
	LoadGameTypes();	
	LoadMutators();

	// RWS CHANGE: Merged from UT2003 2199
	Log(class@"Initialized on Port"@WebServer.ListenPort);
}

function LoadGameTypes()
{
	local class<GameInfo>	TempClass;
	local String 			NextGame;
	local ListItem	TempItem;
	local int				i, Pos;

	// reinitialize list if needed
	GameTypeList = None;
	
	// Compile a list of all gametypes.
	TempClass = class'MultiBase.MpGameInfo';
	NextGame = Level.GetNextInt("MultiBase.MpGameInfo", 0); 
	while (NextGame != "")
	{
		Pos = InStr(NextGame, ".");
		TempClass = class<GameInfo>(DynamicLoadObject(NextGame, class'Class'));

		TempItem = new(None) class'ListItem';
		TempItem.Tag = TempClass.Default.GameName;
		TempItem.Data = NextGame;

		if (GameTypeList == None)
			GameTypeList = TempItem;
		else
			GameTypeList.AddElement(TempItem);

		NextGame = Level.GetNextInt("MultiBase.MpGameInfo", ++i);
	}
}	

function LoadMutators()
{
	local int NumMutatorClasses;
	local string NextMutator, NextDesc;
	local listitem TempItem;
	local Mutator M;
	local int j;
	local int k;

	ExcludeMutators = None;

	Level.GetNextIntDesc("Engine.Mutator", 0, NextMutator, NextDesc);
	while( (NextMutator != "") && (NumMutatorClasses < 50) )
	{
		TempItem = new(None) class'ListItem';
		
		k = InStr(NextDesc, ",");
		if (k == -1)
			TempItem.Tag = NextDesc;
		else
			TempItem.Tag = Left(NextDesc, k);

		TempItem.Data = NextMutator;

		if (ExcludeMutators == None)
			ExcludeMutators = TempItem;
		else
			ExcludeMutators.AddSortedElement(ExcludeMutators, TempItem);
		NumMutatorClasses++;
		Level.GetNextIntDesc("Engine.Mutator", NumMutatorClasses, NextMutator, NextDesc);
	}

	IncludeMutators = None;
	
	for (M = Level.Game.BaseMutator.NextMutator; M != None; M = M.NextMutator) {
		TempItem = ExcludeMutators.DeleteElement(ExcludeMutators, String(M.Class));
		
		if (TempItem != None) {
			if (IncludeMutators == None)
				IncludeMutators = TempItem;
			else
				IncludeMutators.AddElement(TempItem);
		}
		else
			log("Unknown Mutator in use: "@String(M.Class));
	}
}

function String UsedMutators()
{
	local ListItem TempItem;
	local String OutStr;
	
	if(IncludeMutators == None)
		return "";

	OutStr = IncludeMutators.Data;
	for (TempItem = IncludeMutators.Next; TempItem != None; TempItem = TempItem.Next)
	{
		OutStr = OutStr$","$TempItem.Data;
	}
	
	return OutStr;
}

function String GenerateMutatorListSelect(ListItem MutatorList)
{
	local ListItem TempItem;
	local String ResponseStr, SelectedStr;
	
	if (MutatorList == None)
		return "<option value=\"\">*** None ***</option>";
		
	for (TempItem = MutatorList; TempItem != None; TempItem = TempItem.Next) {
		SelectedStr = "";
		if (TempItem.bJustMoved) {
			SelectedStr = " selected";
			TempItem.bJustMoved=false;
		}
		ResponseStr = ResponseStr$"<option value=\""$TempItem.Data$"\""$SelectedStr$">"$TempItem.Tag$"</option>";
	}
	return ResponseStr;
}

function String PadLeft(String InStr, int Width, String PadStr)
{
	local String OutStr;
	
	if (Len(PadStr) == 0)
		PadStr = " ";
		
	for (OutStr=InStr; Len(OutStr) < Width; OutStr=PadStr$OutStr);
	
	return Right(OutStr, Width); // in case PadStr is more than one character
}

function ApplyMapList(out ListItem ExcludeMaps, out ListItem IncludeMaps, String GameType, String MapListType)
{
	local class<MapList> MapListClass;
	local ListItem TempItem;
	local int IncludeCount, i;
	
	MapListClass = Class<MapList>(DynamicLoadObject(MapListType, class'Class'));
	
	IncludeMaps = None;
	ReloadExcludeMaps(ExcludeMaps, GameType);
	
	IncludeCount = ArrayCount(MapListClass.Default.Maps);
	for(i=0;i<IncludeCount;i++)
	{
		if(MapListClass.Default.Maps[i] == "")
			break;
		if (ExcludeMaps != None)
		{
			TempItem = ExcludeMaps.DeleteElement(ExcludeMaps, MapListClass.Default.Maps[i]);
			
			if(TempItem != None)
			{
				if (IncludeMaps == None)
					IncludeMaps = TempItem;
				else
					IncludeMaps.AddElement(TempItem);
			}
			else
				Log("*** Unknown map in Map List: "$MapListClass.Default.Maps[i]);
		}
		else
			Log("*** Empty exclude list, i="$i);
	}
}

function ReloadExcludeMaps(out ListItem ExcludeMaps, String GameType)
{
	local class<MpGameInfo>	GameClass;
	local string FirstMap, NextMap, TestMap, MapName;
	local ListItem TempItem;
	local string GameCode;

	GameClass = class<MpGameInfo>(DynamicLoadObject(GameType, class'Class'));

	GameCode = GameClass.Default.MapNameGameCode;

	ExcludeMaps = None;
	FirstMap = class'FPSGame.FPSGameInfo'.static.GetGameMap(GameCode, "", 0);
	NextMap = FirstMap;
	while (!(FirstMap ~= TestMap) && FirstMap != "")
	{
		// Add the map.
		TempItem = new(None) class'ListItem';
		TempItem.Data = NextMap;
		TempItem.Tag = class'MultiBase.MpGameInfo'.static.CleanMapName(NextMap);

		if (ExcludeMaps == None)
			ExcludeMaps = TempItem;
		else
			ExcludeMaps.AddSortedElement(ExcludeMaps, TempItem);
		
		NextMap = class'FPSGame.FPSGameInfo'.static.GetGameMap(GameCode, NextMap, 1);
		TestMap = NextMap;
	}
}

function ReloadIncludeMaps(out ListItem ExcludeMaps, out ListItem IncludeMaps, String GameType)
{
	local class<GameInfo> GameClass;
	local class<MapList> MapListClass;
	local ListItem TempItem;
	local int i;

	// RWS CHANGE: If ExcludeMaps is none, return
	if(ExcludeMaps == None)
		return;

	// RWS CHANGE: In 927 MapListType is a string instead of a class, requiring a bunch of changes here
	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
	if (GameClass != None && GameClass.Default.MapListType != "")
	{
        MapListClass = class<MapList>(DynamicLoadObject(GameClass.Default.MapListType, class'Class'));
		if (MapListClass != None)
		{
			for (i=0; i<ArrayCount(MapListClass.Default.Maps) && MapListClass.Default.Maps[i] != ""; i++)
			{
				// Add the map.
				TempItem = ExcludeMaps.DeleteElement(ExcludeMaps, MapListClass.Default.Maps[i]);
				if (TempItem == None)
				{
					TempItem = new(None) class'ListItem';
					TempItem.Data = MapListClass.Default.Maps[i];
					TempItem.Tag = class'MultiBase.MpGameInfo'.static.CleanMapName(TempItem.Data);
				}			
				else
				{
					if (IncludeMaps == None)
						IncludeMaps = TempItem;
					else
						IncludeMaps.AddElement(TempItem);
				}
			}
		}
	}
}

function UpdateDefaultMaps(String GameType, ListItem TempItem)
{
	local class<GameInfo> GameClass;
	local class<MapList> MapListClass;
	local int i;

	// RWS CHANGE: In 927 MapListType is a string instead of a class, requiring a bunch of changes here
	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
	if (GameClass != None && GameClass.Default.MapListType != "")
	{
        MapListClass = class<MapList>(DynamicLoadObject(GameClass.Default.MapListType, class'Class'));
		if (MapListClass != None)
		{
			for (i=0; i<ArrayCount(MapListClass.Default.Maps); i++)
			{
				if (TempItem != None)
				{
					MapListClass.Default.Maps[i] = TempItem.Data;
					TempItem = TempItem.Next;
				}
				else
					MapListClass.Default.Maps[i] = "";
			}
	
			MapListClass.Static.StaticSaveConfig();
		}
	}
}

function String GenerateGameTypeOptions(String CurrentGameType)
{
	local ListItem TempItem;
	local String SelectedStr, OptionStr;

	for (TempItem = GameTypeList; TempItem != None; TempItem = TempItem.Next)
	{
		if (CurrentGameType ~= TempItem.Data)
			SelectedStr = " selected";
		else
			SelectedStr = "";
				
		OptionStr = OptionStr$"<option value=\""$TempItem.Data$"\""$SelectedStr$">"$TempItem.Tag$"</option>";
	}
	return OptionStr;
}

function String GenerateMapListOptions(String GameType, String MapListType)
{
	local class<GameInfo> GameClass;
	local String DefaultBaseClass, NextDefault, NextDesc, SelectedStr, OptionStr;
	local int NumDefaultClasses;
	
	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
	if(GameClass == None)
		return "";

	// RWS CHANGE: Removed unnecessary String() cast
	DefaultBaseClass = GameClass.Default.MapListType;

	if(DefaultBaseClass == "")
		return "";

	NextDefault = "Custom";
	NextDesc = "Custom";
	
	if(DynamicLoadObject(DefaultBaseClass, class'Class') == None)
		return "";
	while( (NextDefault != "") && (NumDefaultClasses < 50) )
	{
		if (MapListType ~= NextDefault)
			SelectedStr = " selected";
		else
			SelectedStr = "";
			
		OptionStr = OptionStr$"<option value=\""$NextDefault$"\""$SelectedStr$">"$NextDesc$"</option>";
			
		Level.GetNextIntDesc(DefaultBaseClass, NumDefaultClasses++, NextDefault, NextDesc);
	}				
	return OptionStr;
}

function String GenerateMapListSelect(ListItem MapList, optional string SelectedItem)
{
	local ListItem TempItem;
	local String ResponseStr, SelectedStr;
	
	if (MapList == None)
		return "<option value=\"\">*** None ***</option>";
		
	for (TempItem = MapList; TempItem != None; TempItem = TempItem.Next) {
		SelectedStr = "";
		if (TempItem.Data ~= SelectedItem || TempItem.bJustMoved)
			SelectedStr = " selected";
		ResponseStr = ResponseStr$"<option value=\""$TempItem.Data$"\""$SelectedStr$">"$TempItem.Tag$"</option>";
	}
	
	return ResponseStr;
}

// Replaces any occurences of '<' or '>' with '&lt;' and '&gt;'
function string HtmlEncode(string src)
{
local string Encoded;
local int p;

	// First, "<"
	Encoded = "";
	for (p=Instr(src, "<"); p != -1; p=Instr(src, "<"))
	{
		Encoded = Left(src, p) $ "&lt;";
		src = Mid(src, p + 1);
	}
	src = Encoded $ src;

	// Then, ">"
	Encoded = "";
	for (p=Instr(src, ">"); p != -1; p=Instr(src, ">"))
	{
		Encoded = Left(src, p) $ "&gt;";
		src = Mid(src, p + 1);
	}
	src = Encoded $ src;

	return src;
}

// RWS CHANGE: Merged PreQuery from UT2003 2199 because it looks like it could fix potential problems
event bool PreQuery(WebRequest Request, WebResponse Response)
{
	local int i;

	if (Level == None || Level.Game == None || Level.Game.AccessControl == None)
	{
		ShowMessage(Response, Error, ErrorAuthenticating);
		return false;
	}

	if (Spectator == None)
	{
		if (SpectatorType != None)
			Spectator = Level.Spawn(SpectatorType);
		else
			Spectator = Level.Spawn(class'UTServerAdminSpectator');

		if (Spectator != None)
			Spectator.Server = self;
	}
	if (Spectator == None)
	{
		ShowMessage(Response, Error, ErrorAuthenticating);
		return false;
	}

// RWS CHANGE: Switched to simpler 927 authentication
	if ((AdminUsername != "" && Caps(Request.Username) != Caps(AdminUsername)) || (AdminPassword != "" && Caps(Request.Password) != Caps(AdminPassword)))
	{
		Response.FailAuthentication(AdminRealm);
		return false;
	}
/* RWS CHANGE: Removed for 927
	// Check authentication:
	// TODO: Simply use Spectator.WebLogin() or something like that
	if (!Level.Game.AccessControl.AdminLogin(Spectator, Request.Username, Request.Password))
	{
		Response.FailAuthentication(AdminRealm);
		return false;
	}
	CurAdmin = Level.Game.AccessControl.GetLoggedAdmin(Spectator);
	if (CurAdmin == None)
	{
		ShowMessage(Response, Error, ErrorAuthenticating);
		Level.Game.AccessControl.AdminLogout(Spectator);
		return false;
	}
*/
	Resp = Response;

/* RWS CHANGE: Removed for 927
	for (i=0; i<QueryHandlers.Length; i++)
	{
		if (!QueryHandlers[i].PreQuery(Request, Response))
			return false;
	}
*/
	return true;
}

event PostQuery(WebRequest Request, WebResponse Response)
{
	local int i;

	Resp = None;
/* RWS CHANGE: Removed for 927
	CurAdmin = None;
	Level.Game.AccessControl.AdminLogout(Spectator);

	for (i=0; i<QueryHandlers.Length; i++)
    {
		if (!QueryHandlers[i].PostQuery(Request, Response))
			return;
    }
*/
}

//*****************************************************************************
event Query(WebRequest Request, WebResponse Response)
{
/* RWS CHANGE: This is now done in PreQuery
	// Check authentication:
	if ((AdminUsername != "" && Caps(Request.Username) != Caps(AdminUsername)) || (AdminPassword != "" && Caps(Request.Password) != Caps(AdminPassword))) {
		Response.FailAuthentication(AdminRealm);
		return;
	}
*/	
	// RWS CHANGE: Use our email address instead
//	Response.Subst("BugAddress", "utbugs"$Level.EngineVersion$"@epicgames.com");
	Response.Subst("BugAddress", "support@gopostal.com");

	// Match query function.  checks URI and calls appropriate input/output function
	switch (Mid(Request.URI, 1)) {
	case "":
	case RootPage:
		QueryRoot(Request, Response); break;
	case MenuPage:
		QueryMenu(Request, Response); break;
	case CurrentPage:
		QueryCurrent(Request, Response); break;
	case CurrentMenuPage:
		QueryCurrentMenu(Request, Response); break;
	case CurrentPlayersPage:
		QueryCurrentPlayers(Request, Response); break;
	case CurrentGamePage:
		QueryCurrentGame(Request, Response); break;
	case CurrentConsolePage:
		QueryCurrentConsole(Request, Response); break;
	case CurrentConsoleLogPage:
		QueryCurrentConsoleLog(Request, Response); break;
	case CurrentConsoleSendPage:
		QueryCurrentConsoleSend(Request, Response); break;
	case CurrentMutatorsPage:
		QueryCurrentMutators(Request, Response); break;
	case CurrentRestartPage:
	case DefaultsRestartPage:
		// RWS CHANGE: Merged check from UT2003 2199
		if (!MapIsChanging()) QueryRestartPage(Request, Response); break;
	case DefaultsPage:
		QueryDefaults(Request, Response); break;
	case DefaultsMenuPage:
		//QueryDefaultsMenu(Request, Response); break;
		QueryCurrentMenu(Request, Response); break;
	case DefaultsMapsPage:
		QueryDefaultsMaps(Request, Response); break;
	case DefaultsRulesPage:
		QueryDefaultsRules(Request, Response); break;
	case DefaultsSettingsPage:
		QueryDefaultsSettings(Request, Response); break;
	case DefaultsBotsPage:
		QueryDefaultsBots(Request, Response); break;
	case DefaultsServerPage:
		QueryDefaultsServer(Request, Response); break;
	case DefaultsIPPolicyPage:
		QueryDefaultsIPPolicy(Request, Response); break;
	default:
		Response.SendText("ERROR: Page not found or enabled ("$Request.URI$")");

	}		
}

//*****************************************************************************
function QueryRoot(WebRequest Request, WebResponse Response)
{
	local String GroupPage;
	
	GroupPage = Request.GetVariable("Group", CurrentPage);
	
	Response.Subst("ServerName", class'Engine.GameReplicationInfo'.Default.ServerName);
	Response.Subst("MenuURI", MenuPage$"?Group="$GroupPage);
	Response.Subst("MainURI", GroupPage);
	
	Response.IncludeUHTM("root"$htm);
}


function QueryMenu(WebRequest Request, WebResponse Response)
{
	Response.Subst("CurrentBG", 	DefaultBG);
	Response.Subst("DefaultsBG",	DefaultBG);
	
	
	switch(Request.GetVariable("Group", DefaultsPage)) {
	case CurrentPage:
		Response.Subst("CurrentBG", 	HighlightedBG); break;
	case DefaultsPage:
		Response.Subst("DefaultsBG",	HighlightedBG); break;
	}

	// Set URIs
	Response.Subst("CurrentURI", 	RootPage$"?Group="$CurrentPage);
	Response.Subst("DefaultsURI", 	RootPage$"?Group="$DefaultsPage);

	Response.IncludeUHTM(MenuPage$htm);
	Response.ClearSubst();	
	
}

//*****************************************************************************
function QueryCurrent(WebRequest Request, WebResponse Response)
{
	local String Page, GameType;
	
	// if no page specified, use the default
	Page = Request.GetVariable("Page", CurrentGamePage);
	GameType = Request.GetVariable("GameType", String(Level.Game.Class));

	Response.Subst("IndexURI", 	CurrentMenuPage$"?Page="$Page);
	Response.Subst("MainURI", 	Page$"?GameType="$GameType);
	
	Response.IncludeUHTM(CurrentPage$htm);
	Response.ClearSubst();
}

function QueryCurrentMenu(WebRequest Request, WebResponse Response)
{
	local String Page, GameType, TempStr;
	
	Page = Request.GetVariable("Page", CurrentGamePage);
	GameType = String(Level.Game.Class);

	// set background colors
	Response.Subst("DefaultBG", DefaultBG);	// for unused tabs

	Response.Subst("PlayersBG", DefaultBG);
	Response.Subst("GameBG", 	DefaultBG);
	Response.Subst("ConsoleBG",	DefaultBG);
	Response.Subst("MutatorsBG",DefaultBG);
	Response.Subst("RestartBG", DefaultBG);
	Response.Subst("MapsBG", 	DefaultBG);
	Response.Subst("RulesBG", 	DefaultBG);
	Response.Subst("SettingsBG",DefaultBG);
	Response.Subst("BotsBG",	DefaultBG);
	Response.Subst("ServerBG",	DefaultBG);
	Response.Subst("IPPolicyBG",DefaultBG);

	switch(Page) {
	case CurrentPlayersPage:
		Response.Subst("PlayersBG",	HighlightedBG); break;
	case CurrentGamePage:
		Response.Subst("GameBG", 	HighlightedBG); break;
	case CurrentConsolePage:
		Response.Subst("ConsoleBG",	HighlightedBG); break;
	case CurrentMutatorsPage:
		Response.Subst("MutatorsBG",HighlightedBG); break;
	case CurrentRestartPage:
		Response.Subst("RestartBG", HighlightedBG); break;
	case DefaultsMapsPage:
		Response.Subst("MapsBG", 	HighlightedBG); break;
	case DefaultsRulesPage:
		Response.Subst("RulesBG", 	HighlightedBG); break;
	case DefaultsSettingsPage:
		Response.Subst("SettingsBG",HighlightedBG); break;
	case DefaultsBotsPage:
		Response.Subst("BotsBG",	HighlightedBG); break;
	case DefaultsServerPage:
		Response.Subst("ServerBG",	HighlightedBG); break;
	case DefaultsIPPolicyPage:
		Response.Subst("IPPolicyBG",HighlightedBG); break;
	}

	// Set URIs
	Response.Subst("PlayersURI", 	CurrentPage$"?Page="$CurrentPlayersPage);
	Response.Subst("GameURI",		CurrentPage$"?Page="$CurrentGamePage);
	Response.Subst("ConsoleURI", 	CurrentPage$"?Page="$CurrentConsolePage);
	Response.Subst("MutatorsURI", 	CurrentPage$"?Page="$CurrentMutatorsPage);
	Response.Subst("RestartURI", 	CurrentPage$"?Page="$CurrentRestartPage);
	Response.Subst("MapsURI", 		CurrentPage$"?Page="$DefaultsMapsPage);
	Response.Subst("RulesURI", 		CurrentPage$"?Page="$DefaultsRulesPage);
	Response.Subst("SettingsURI", 	CurrentPage$"?Page="$DefaultsSettingsPage);
	Response.Subst("BotsURI", 		CurrentPage$"?Page="$DefaultsBotsPage);	
	Response.Subst("ServerURI", 	CurrentPage$"?Page="$DefaultsServerPage);	
	Response.Subst("IPPolicyURI", 	CurrentPage$"?Page="$DefaultsIPPolicyPage);

	Response.IncludeUHTM(CurrentMenuPage$htm);
	Response.ClearSubst();
}

function QueryCurrentPlayers(WebRequest Request, WebResponse Response)
{
	local string Sort, PlayerListSubst, TempStr, TempTeam;
	local ListItem PlayerList, TempItem;
	local Controller P;
	local int i, PawnCount, j;
	local string IP;
	
	Sort = Request.GetVariable("Sort", "Name");
	
	// RWS CHANGE: Updated to 927
	for (P=Level.ControllerList; P!=None; P=P.NextController)
	{
		// RWS CHANGE: Updated to 927
		if(!P.bDeleteMe &&
			P.bIsPlayer &&
			P.PlayerReplicationInfo != None &&
			PlayerController(P) != None &&
			NetConnection(PlayerController(P).Player) != None)
		{
			if(Request.GetVariable("BanPlayer"$string(P.PlayerReplicationInfo.PlayerID)) != "")
			{
/*				// RWS CHANGE: Updated to 927
				IP = PlayerController(P).GetPlayerNetworkAddress();
				// RWS CHANGE: Updated to 927
				if(Level.Game.AccessControl.CheckIPPolicy(IP))
				{
					IP = Left(IP, InStr(IP, ":"));
					Log("Adding IP Ban for: "$IP);
					for(j=0;j<50;j++)
						if(Level.Game.AccessControl.IPPolicies[j] == "")
							break;
					if(j < 50)
						Level.Game.AccessControl.IPPolicies[j] = "DENY,"$IP;
					Level.Game.SaveConfig();
				}
				P.Destroy();
*/
				// RWS CHANGE: Let Game handle kicking
				P.Level.Game.KickBan(P.PlayerReplicationInfo.PlayerName);
				P.bIsPlayer = false;
			}
			else
			{
				if(Request.GetVariable("KickPlayer"$string(P.PlayerReplicationInfo.PlayerID)) != "")
				{
					//P.Destroy();
					// RWS CHANGE: Let Game handle kicking
					P.Level.Game.Kick(P.PlayerReplicationInfo.PlayerName);
					P.bIsPlayer = false;
				}
			}
		}
		if(P == None)
			break;
	}
	if (Request.GetVariable("SetMinPlayers", "") != "")
	{
		MpGameInfo(Level.Game).MinPlayers = Min(Max(int(Request.GetVariable("MinPlayers", String(0))), 0), 8);
		Level.Game.SaveConfig();
	}
	// RWS CHANGE: Updated to 927
	for (P=Level.ControllerList; P!=None; P=P.NextController)
	{
		if (!P.bDeleteMe &&
			P.bIsPlayer &&
			UTServerAdminSpectator(P) == None)
		{
			PawnCount++;
			TempItem = new(None) class'ListItem';
			
			// RWS CHANGE: Updated to 927 var
			if (P.PlayerReplicationInfo.bBot)
			{
				TempItem.Data = "<tr><td width=\"1%\" colspan=2>&nbsp;</td>";
				TempStr = "&nbsp;(Bot)";
			}
			else
			{
				TempItem.Data = "<tr><td width=\"1%\"><div align=\"center\"><input type=\"checkbox\" name=\"KickPlayer"$P.PlayerReplicationInfo.PlayerID$"\" value=\"kick\"></div></td><td width=\"1%\"><div align=\"center\"><input type=\"checkbox\" name=\"BanPlayer"$P.PlayerReplicationInfo.PlayerID$"\" value=\"ban\"></div></td>";
				if (P.PlayerReplicationInfo.bIsSpectator)
					TempStr = "&nbsp;(Spectator)";
				else
					TempStr = "";
			}
			// RWS CHANGE: Updated to 927
			if(PlayerController(P) != None)
			{
				// RWS CHANGE: Updated to 927
				IP = PlayerController(P).GetPlayerNetworkAddress();
				IP = Left(IP, InStr(IP, ":"));
			}
			else
				IP = "";
			// RWS CHANGE: Fixed access none when team is none
			if(P.PlayerReplicationInfo.Team != None)
				TempTeam = P.PlayerReplicationInfo.Team.TeamName;
			else
				TempTeam = "";
			// RWS CHANGE: Updated to 927
			TempItem.Data = TempItem.Data$"<td><div align=\"left\">"$P.PlayerReplicationInfo.PlayerName$TempStr$"</div></td><td width=\"1%\"><div align=\"center\">"$TempTeam$"&nbsp;</div></td><td width=\"1%\"><div align=\"center\">"$P.PlayerReplicationInfo.Ping$"</div></td><td width=\"1%\"><div align=\"center\">"$int(P.PlayerReplicationInfo.Score)$"</div></td><td width=\"1%\"><div align=\"center\">"$IP$"</div></td></tr>";
			
			switch (Sort) {
			case "Name":
				TempItem.Tag = P.PlayerReplicationInfo.PlayerName; break;
			case "Team":
				// RWS CHANGE: Updated to 927
				TempItem.Tag = PadLeft(P.PlayerReplicationInfo.Team.TeamName, 2, "0"); break;
			case "Ping":
				TempItem.Tag = PadLeft(String(P.PlayerReplicationInfo.Ping), 4, "0"); break;
			default:
				TempItem.Tag = PadLeft(String(int(P.PlayerReplicationInfo.Score)), 3, "0"); break;
			}
			if (PlayerList == None)
				PlayerList = TempItem;
			else
				PlayerList.AddSortedElement(PlayerList, TempItem);
		}
	}

	if (PawnCount > 0)
	{
		if (Sort ~= "Score")
			for (TempItem=PlayerList; TempItem!=None; TempItem=TempItem.Next)
				PlayerListSubst = TempItem.Data$PlayerListSubst;
			
		else
			for (TempItem=PlayerList; TempItem!=None; TempItem=TempItem.Next)
				PlayerListSubst = PlayerListSubst$TempItem.Data;
	}
	else
		PlayerListSubst = "<tr align=\"center\"><td colspan=\"7\">** No Players Connected **</td></tr>";

	Response.Subst("PlayerList", PlayerListSubst);
	Response.Subst("CurrentGame", Level.Game.GameReplicationInfo.GameName$" in "$Level.Title);
	Response.Subst("PostAction", CurrentPlayersPage);
	Response.Subst("Sort", Sort);
	Response.Subst("MinPlayers", String(MpGameInfo(Level.Game).MinPlayers));
	Response.IncludeUHTM(CurrentPlayersPage$htm);
}

function QueryCurrentGame(WebRequest Request, WebResponse Response)
{
	local ListItem ExcludeMaps, IncludeMaps;
	local class<MpGameInfo> NewClass;
	local string NewGameType;
	
	if (Request.GetVariable("SwitchGameTypeAndMap", "") != "") {
		ServerChangeMap(Request, Response, Request.GetVariable("MapSelect"), Request.GetVariable("GameTypeSelect"));
	}
	else if (Request.GetVariable("SwitchGameType", "") != "") {
		NewGameType = Request.GetVariable("GameTypeSelect");
		NewClass = class<MpGameInfo>(DynamicLoadObject(NewGameType, class'Class'));

		ReloadExcludeMaps(ExcludeMaps, NewGameType);
		ReloadIncludeMaps(ExcludeMaps, IncludeMaps, NewGameType);

		Response.Subst("GameTypeButton", "");
		Response.Subst("MapButton", "<input type=\"submit\" name=\"SwitchGameTypeAndMap\" value=\"Switch\">");
		Response.Subst("GameTypeSelect", NewClass.default.GameName$"<input type=\"hidden\" name=\"GameTypeSelect\" value=\""$NewGameType$"\">");
		Response.Subst("MapSelect", GenerateMapListSelect(IncludeMaps));
		Response.Subst("PostAction", CurrentGamePage);
		Response.IncludeUHTM(CurrentGamePage$htm);
	}
	else if (Request.GetVariable("SwitchMap", "") != "") {
		ServerChangeMap(Request, Response, Request.GetVariable("MapSelect"), String(Level.Game.Class));
	}
	else {
		ReloadExcludeMaps(ExcludeMaps, String(Level.Game.Class));
		ReloadIncludeMaps(ExcludeMaps, IncludeMaps, String(Level.Game.Class));

		Response.Subst("GameTypeButton", "<input type=\"submit\" name=\"SwitchGameType\" value=\"Switch\">");
		Response.Subst("MapButton", "<input type=\"submit\" name=\"SwitchMap\" value=\"Switch\">");
		Response.Subst("GameTypeSelect", "<select name=\"GameTypeSelect\">"$GenerateGameTypeOptions(String(Level.Game.Class))$"</select>");
		// RWS Change: .unr -> .fuk
		Response.Subst("MapSelect", GenerateMapListSelect(IncludeMaps, Left(string(Level), InStr(string(Level), "."))$".fuk") );
		Response.Subst("PostAction", CurrentGamePage);
		Response.IncludeUHTM(CurrentGamePage$htm);
	}
}

function QueryCurrentConsole(WebRequest Request, WebResponse Response)
{
	local String SendStr, OutStr;

	SendStr = Request.GetVariable("SendText", "");
	if (SendStr != "") {
		if (Left(SendStr, 4) ~= "say ")
			Level.Game.Broadcast(Spectator, "Admin: "$Mid(SendStr, 4));
		else {
			OutStr = Level.ConsoleCommand(SendStr);
			if (OutStr != "")
				Spectator.AddMessage(None, OutStr, 'Console');
		}
	}
	
	Response.Subst("LogURI", CurrentConsoleLogPage);
	Response.Subst("SayURI", CurrentConsoleSendPage);
	Response.IncludeUHTM(CurrentConsolePage$htm);
}

function QueryCurrentConsoleLog(WebRequest Request, WebResponse Response)
{
	local ListItem TempItem;
	local String LogSubst, LogStr;
	local int i;

	// RWS CHANGE: Updated for 927 way of doing this
	i = Spectator.LastMessage();
	LogStr = HtmlEncode(Spectator.NextMessage(i));
	while (LogStr  != "")
	{
		LogSubst = LogSubst$"&gt; "$LogStr$"<br>";
		LogStr = HtmlEncode(Spectator.NextMessage(i));
	}
	
	Response.Subst("LogRefresh", WebServer.ServerURL$Path$"/"$CurrentConsoleLogPage$"#END");
	Response.Subst("LogText", LogSubst);
	Response.IncludeUHTM(CurrentConsoleLogPage$htm);
}

function QueryCurrentConsoleSend(WebRequest Request, WebResponse Response)
{
	Response.Subst("DefaultSendText", DefaultSendText);
	Response.Subst("PostAction", CurrentConsolePage);
	Response.IncludeUHTM(CurrentConsoleSendPage$htm);
}

function QueryRestartPage(WebRequest Request, WebResponse Response)
{
	ServerChangeMap(Request, Response, Level.GetURLMap(), String(Level.Game.Class));
}

function QueryCurrentMutators(WebRequest Request, WebResponse Response)
{
	local ListItem TempItem;
	local int Count, i;
	
	if (Request.GetVariable("AddMutator", "") != "") {
		Count = Request.GetVariableCount("ExcludeMutatorsSelect");
		for (i=0; i<Count; i++)
		{
			if (ExcludeMutators != None)
			{
				TempItem = ExcludeMutators.DeleteElement(ExcludeMutators, Request.GetVariableNumber("ExcludeMutatorsSelect", i));
				if (TempItem != None)
				{
					TempItem.bJustMoved = true;
					if (IncludeMutators == None)
						IncludeMutators = TempItem;
					else
						IncludeMutators.AddElement(TempItem);
				}
				else
					Log("Exclude mutator not found: "$Request.GetVariableNumber("ExcludeMutatorsSelect", i));
			}
		}
	}
	else if (Request.GetVariable("DelMutator", "") != "") {
		Count = Request.GetVariableCount("IncludeMutatorsSelect");
		for (i=0; i<Count; i++)
		{
			if (IncludeMutators != None)
			{
				TempItem = IncludeMutators.DeleteElement(IncludeMutators, Request.GetVariableNumber("IncludeMutatorsSelect", i));
				if (TempItem != None)
				{
					TempItem.bJustMoved = true;
					if (ExcludeMutators == None)
						ExcludeMutators = TempItem;
					else
						ExcludeMutators.AddSortedElement(ExcludeMutators, TempItem);
				}
				else
					Log("Include mutator not found: "$Request.GetVariableNumber("IncludeMutatorsSelect", i));
			}
		}
	}
	else if (Request.GetVariable("AddAllMutators", "") != "")
	{
		while (ExcludeMutators != None)
		{
			TempItem = ExcludeMutators.DeleteElement(ExcludeMutators);
			if (TempItem != None)
			{
				TempItem.bJustMoved = true;
				if (IncludeMutators == None)
					IncludeMutators = TempItem;
				else
					IncludeMutators.AddElement(TempItem);
			}
		}
	}
	else if (Request.GetVariable("DelAllMutators", "") != "")
	{
		while (IncludeMutators != None)
		{
			TempItem = IncludeMutators.DeleteElement(IncludeMutators);
			if (TempItem != None)
			{
				TempItem.bJustMoved = true;
				if (ExcludeMutators == None)
					ExcludeMutators = TempItem;
				else
					ExcludeMutators.AddSortedElement(ExcludeMutators, TempItem);
			}
		}
	}

	Response.Subst("ExcludeMutatorsOptions", GenerateMutatorListSelect(ExcludeMutators));
	Response.Subst("IncludeMutatorsOptions", GenerateMutatorListSelect(IncludeMutators));
	
	Response.Subst("PostAction", CurrentMutatorsPage);
	Response.IncludeUHTM(CurrentMutatorsPage$htm);
}

//*****************************************************************************
function QueryDefaults(WebRequest Request, WebResponse Response)
{
	local String GameType, PageStr;
	
	// if no gametype specified use the first one in the list
	GameType = Request.GetVariable("GameType", String(Level.Game.Class));
	
	// if no page specified, use the first one
	PageStr = Request.GetVariable("Page", DefaultsMapsPage);

	Response.Subst("IndexURI", 	DefaultsMenuPage$"?GameType="$GameType$"&Page="$PageStr);
	Response.Subst("MainURI", 	PageStr$"?GameType="$GameType);
	
	Response.IncludeUHTM(DefaultsPage$htm);
	Response.ClearSubst();
}

function QueryDefaultsMenu(WebRequest Request, WebResponse Response)
{
	local	String	GameType, Page, TempStr;
	
	GameType = Request.GetVariable("GameType");
	Page = Request.GetVariable("Page");
		
	if (GameType == "")
		GameType = String(Level.Game.Class);
	
	if (Request.GetVariable("GameTypeSet", "") != "")
	{	
		TempStr = Request.GetVariable("GameTypeSelect", GameType);
		if (!(TempStr ~= GameType))
			GameType = TempStr;
	}


	// set post action
	Response.Subst("PostAction", DefaultsPage);


	// set currently used gametype
	Response.Subst("GameType", GameType);

	// set currently active page
	Response.Subst("Page", Page);
	
	// Generate gametype options
	Response.Subst("GameTypeOptions", GenerateGameTypeOptions(GameType));

	// set background colors
	Response.Subst("DefaultBG", DefaultBG);	// for unused tabs

	Response.Subst("MapsBG", 	DefaultBG);
	Response.Subst("RulesBG", 	DefaultBG);
	Response.Subst("SettingsBG",DefaultBG);
	Response.Subst("BotsBG",	DefaultBG);
	Response.Subst("ServerBG",	DefaultBG);
	Response.Subst("IPPolicyBG",DefaultBG);
	Response.Subst("RestartBG", DefaultBG);
	
	switch(Page) {
	case DefaultsMapsPage:
		Response.Subst("MapsBG", 	HighlightedBG); break;
	case DefaultsRulesPage:
		Response.Subst("RulesBG", 	HighlightedBG); break;
	case DefaultsSettingsPage:
		Response.Subst("SettingsBG",HighlightedBG); break;
	case DefaultsBotsPage:
		Response.Subst("BotsBG",	HighlightedBG); break;
	case DefaultsServerPage:
		Response.Subst("ServerBG",	HighlightedBG); break;
	case DefaultsIPPolicyPage:
		Response.Subst("IPPolicyBG",HighlightedBG); break;
	case DefaultsRestartPage:
		Response.Subst("RestartBG", HighlightedBG); break;
	}

	// Set URIs
	Response.Subst("MapsURI", 		DefaultsPage$"?GameType="$GameType$"&Page="$DefaultsMapsPage);
	Response.Subst("RulesURI", 		DefaultsPage$"?GameType="$GameType$"&Page="$DefaultsRulesPage);
	Response.Subst("SettingsURI", 	DefaultsPage$"?GameType="$GameType$"&Page="$DefaultsSettingsPage);
	Response.Subst("BotsURI", 		DefaultsPage$"?GameType="$GameType$"&Page="$DefaultsBotsPage);	
	Response.Subst("ServerURI", 	DefaultsPage$"?GameType="$GameType$"&Page="$DefaultsServerPage);	
	Response.Subst("IPPolicyURI", 	DefaultsPage$"?GameType="$GameType$"&Page="$DefaultsIPPolicyPage);	
	Response.Subst("RestartURI", 	DefaultsPage$"?GameType="$GameType$"&Page="$DefaultsRestartPage);	

	Response.IncludeUHTM(DefaultsMenuPage$htm);
	Response.ClearSubst();
}

function QueryDefaultsMaps(WebRequest Request, WebResponse Response)
{
	local String GameType, MapListType;
	local ListItem ExcludeMaps, IncludeMaps, TempItem;
	local int i, Count, MoveCount;
	
	GameType = string(Level.Game.Class);	//Request.GetVariable("GameType");
	MapListType = Request.GetVariable("MapListType", "Custom");
	
	ReloadExcludeMaps(ExcludeMaps, GameType);
	ReloadIncludeMaps(ExcludeMaps, IncludeMaps, GameType);


	if (Request.GetVariable("MapListSet", "") != "") {
		MapListType = Request.GetVariable("MapListSelect", "Custom");
		if (MapListType != "Custom")
		{
			ApplyMapList(ExcludeMaps, IncludeMaps, GameType, MapListType);
			
			UpdateDefaultMaps(GameType, IncludeMaps);
		}
	}
	else if (Request.GetVariable("AddMap", "") != "") {
		Count = Request.GetVariableCount("ExcludeMapsSelect");
		for (i=0; i<Count; i++)
		{
			if (ExcludeMaps != None)
			{
				TempItem = ExcludeMaps.DeleteElement(ExcludeMaps, Request.GetVariableNumber("ExcludeMapsSelect", i));
				if (TempItem != None)
				{
					TempItem.bJustMoved = true;
					if (IncludeMaps == None)
						IncludeMaps = TempItem;
					else
						IncludeMaps.AddElement(TempItem);
				}
				else
					Log("Exclude map not found: "$Request.GetVariableNumber("ExcludeMapsSelect", i));
			}
		}
		MapListType = "Custom";
		UpdateDefaultMaps(GameType, IncludeMaps);
	}
	else if (Request.GetVariable("DelMap", "") != "" && Request.GetVariableCount("IncludeMapsSelect") > 0) {
		Count = Request.GetVariableCount("IncludeMapsSelect");
		for (i=0; i<Count; i++)
		{
			if (IncludeMaps != None)
			{
				TempItem = IncludeMaps.DeleteElement(IncludeMaps, Request.GetVariableNumber("IncludeMapsSelect", i));
				if (TempItem != None)
				{
					TempItem.bJustMoved = true;
					if (ExcludeMaps == None)
						ExcludeMaps = TempItem;
					else
						ExcludeMaps.AddSortedElement(ExcludeMaps, TempItem);
				}
				else
					Log("Include map not found: "$Request.GetVariableNumber("IncludeMapsSelect", i));
			}
		}
		MapListType = "Custom";
		UpdateDefaultMaps(GameType, IncludeMaps);
	}
	else if (Request.GetVariable("AddAllMap", "") != "") {
		while (ExcludeMaps != None)
		{
			TempItem = ExcludeMaps.DeleteElement(ExcludeMaps);
			if (TempItem != None)
			{
				TempItem.bJustMoved = true;
				if (IncludeMaps == None)
					IncludeMaps = TempItem;
				else
					IncludeMaps.AddElement(TempItem);
			}
		}
		MapListType = "Custom";
		UpdateDefaultMaps(GameType, IncludeMaps);
	}
	else if (Request.GetVariable("DelAllMap", "") != "") {
		while (IncludeMaps != None)
		{
			TempItem = IncludeMaps.DeleteElement(IncludeMaps);
			if (TempItem != None)
			{
				TempItem.bJustMoved = true;
				if (ExcludeMaps == None)
					ExcludeMaps = TempItem;
				else
					ExcludeMaps.AddSortedElement(ExcludeMaps, TempItem);
			}
		}
		MapListType = "Custom";
		UpdateDefaultMaps(GameType, IncludeMaps);	// IncludeMaps should be None now.
	}
	else if (Request.GetVariable("MoveMap", "") != "") {
		MoveCount = int(Abs(float(Request.GetVariable("MoveMapCount"))));
		if (MoveCount != 0) {
			Count = Request.GetVariableCount("IncludeMapsSelect");
			if (Request.GetVariable("MoveMap") ~= "Down") {
				for (TempItem = IncludeMaps; TempItem.Next != None; TempItem = TempItem.Next);
				for (TempItem = TempItem; TempItem != None; TempItem = TempItem.Prev) {
					for (i=0; i<Count; i++) {
						if (TempItem.Data ~= Request.GetVariableNumber("IncludeMapsSelect", i)) {
							TempItem.bJustMoved = true;
							IncludeMaps.MoveElementDown(IncludeMaps, TempItem, MoveCount);
							break;
						}
					}
				}
			}
			else {
				for (TempItem = IncludeMaps; TempItem != None; TempItem = TempItem.Next) {
					for (i=0; i<Count; i++) {
						if (TempItem.Data ~= Request.GetVariableNumber("IncludeMapsSelect", i)) {
							TempItem.bJustMoved = true;
							IncludeMaps.MoveElementUp(IncludeMaps, TempItem, MoveCount);
							break;
						}
					}
				}
			}
			
			UpdateDefaultMaps(GameType, IncludeMaps);
		}
	}
	
	// Start output here
	
	Response.Subst("MapListType", MapListType);
	
	// Generate maplist options
	Response.Subst("MapListOptions", GenerateMapListOptions(GameType, MapListType));

	// Generate map selects
	Response.Subst("ExcludeMapsOptions", GenerateMapListSelect(ExcludeMaps));
	Response.Subst("IncludeMapsOptions", GenerateMapListSelect(IncludeMaps));

	Response.Subst("PostAction", DefaultsMapsPage);
	Response.Subst("GameType", GameType);
	Response.IncludeUHTM(DefaultsMapsPage$htm);
	Response.ClearSubst();
}

function QueryDefaultsRules(WebRequest Request, WebResponse Response)
{
	local String GameType, FragName, FragLimit, TimeLimit, MaxTeams, FriendlyFire, PlayersBalanceTeams, ForceRespawn;
	local String MaxPlayers, MaxSpectators, WeaponsStay, Tournament;
	local class<GameInfo> GameClass;
	
	GameType = string(Level.Game.Class);	//Request.GetVariable("GameType", GameTypeList.Data);
	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));

	MaxPlayers = Request.GetVariable("MaxPlayers", String(class<MpGameInfo>(GameClass).Default.MaxPlayers));
	MaxPlayers = String(max(int(MaxPlayers), 0));
	class<MpGameInfo>(GameClass).Default.MaxPlayers = int(MaxPlayers);
	Response.Subst("MaxPlayers", MaxPlayers);
	
	MaxSpectators = Request.GetVariable("MaxSpectators", String(class<MpGameInfo>(GameClass).Default.MaxSpectators));
	MaxSpectators = String(max(int(MaxSpectators), 0));
	class<MpGameInfo>(GameClass).Default.MaxSpectators = int(MaxSpectators);
	Response.Subst("MaxSpectators", MaxSpectators);
	
	WeaponsStay = "false"; // RWS -- String(class<MpGameInfo>(GameClass).Default.bMultiWeaponStay);
	Tournament = "false"; // RWS -- String(class<MpGameInfo>(GameClass).Default.bTournament);
// RWS
/*	if(	class<TeamGamePlus>(GameClass) != None )
		PlayersBalanceTeams = String(class<TeamGamePlus>(GameClass).Default.bPlayersBalanceTeams);
	if(	class<LastManStanding>(GameClass) == None )
		ForceRespawn = String(class<MpGameInfo>(GameClass).Default.bForceRespawn);
*/	
			
	if (Request.GetVariable("Apply", "") != "") {		
// RWS
		if(	class<TeamGame>(GameClass) != None )
		{
			PlayersBalanceTeams = Request.GetVariable("PlayersBalanceTeams", "false");
			class<TeamGame>(GameClass).Default.bPlayersBalanceTeams = PlayersBalanceTeams ~= "true";
		}
/*
		if(	class<LastManStanding>(GameClass) == None )
		{
			ForceRespawn = Request.GetVariable("ForceRespawn", "false");
			class<MpGameInfo>(GameClass).Default.bForceRespawn = bool(ForceRespawn);
		}
*/
		WeaponsStay = Request.GetVariable("WeaponsStay", "false");
		// RWS -- class<MpGameInfo>(GameClass).Default.bMultiWeaponStay = bool(WeaponsStay);

		Tournament = Request.GetVariable("Tournament", "false");
		// RWS -- class<MpGameInfo>(GameClass).Default.bTournament = bool(Tournament);
	}

	if (WeaponsStay ~= "true") {
		Response.Subst("WeaponsStay", " checked");
	}
	if (Tournament ~= "true") {
		Response.Subst("Tournament", " checked");
	}
// RWS 
/*	if(	class<LastManStanding>(GameClass) == None )
	{
		if (ForceRespawn ~= "true")
			ForceRespawn = " checked";
		else
			ForceRespawn = "";
		Response.Subst("ForceRespawnSubst", "<tr><td>Force Respawn</td><td width=\"1%\"><input type=\"checkbox\" name=\"ForceRespawn\" value=\"true\""$ForceRespawn$"></td></tr>");
	}
*/
	if(	class<TeamGame>(GameClass) != None )
	{
		if (PlayersBalanceTeams ~= "true")
			PlayersBalanceTeams = " checked";
		else
			PlayersBalanceTeams = "";
		Response.Subst("BalanceSubst", "<tr><td>Force Balanced Teams</td><td width=\"1%\"><input type=\"checkbox\" name=\"PlayersBalanceTeams\" value=\"true\""$PlayersBalanceTeams$"></td></tr>");
	}
// RWS
/*	if (class<MpGameInfo>(GameClass) != None && class<Assault>(GameClass) == None) {
		if (class<TeamGamePlus>(GameClass) != None) {
    		FragLimit = Request.GetVariable("FragLimit", String(class<TeamGamePlus>(GameClass).Default.GoalTeamScore));
    		FragLimit = String(max(int(FragLimit), 0));
    		class<TeamGamePlus>(GameClass).Default.GoalTeamScore = float(FragLimit);
    		FragName = "Max Team Score";
    	}
    	else {
			FragLimit = Request.GetVariable("FragLimit", String(class<MpGameInfo>(GameClass).Default.FragLimit));
    		FragLimit = String(max(int(FragLimit), 0));
    		class<MpGameInfo>(GameClass).Default.FragLimit = float(FragLimit);
    		FragName = "Score Limit";
    	}
    	
    	Response.Subst("FragSubst", "<tr><td>"$FragName$"</td><td width=\"1%\"><input type=\"text\" name=\"FragLimit\" maxlength=\"3\" size=\"3\" value=\""$FragLimit$"\"></td></tr>");

		if(class<LastManStanding>(GameClass) == None)
		{
    		TimeLimit = Request.GetVariable("TimeLimit", String(class<MpGameInfo>(GameClass).Default.TimeLimit));
    		TimeLimit = String(max(int(TimeLimit), 0));
			Response.Subst("TimeLimitSubst", "<tr><td>Time Limit</td><td width=\"1%\"><input type=\"text\" name=\"TimeLimit\" maxlength=\"3\" size=\"3\" value=\""$TimeLimit$"\"></td></tr>");
			class<MpGameInfo>(GameClass).Default.TimeLimit = float(TimeLimit);
		}
	}
*/
	
// RWS
/*	if(	class<TeamGamePlus>(GameClass) != None &&
	    !ClassIsChildOf( GameClass, class'CTFGame' ) &&
		!ClassIsChildOf( GameClass, class'Assault' ) ) {
   		MaxTeams = Request.GetVariable("MaxTeams", String(class<TeamGamePlus>(GameClass).Default.MaxTeams));
   		MaxTeams = String(max(int(MaxTeams), 0));
   		class<TeamGamePlus>(GameClass).Default.MaxTeams = Min(Max(int(MaxTeams), 2), 4);
		Response.Subst("TeamSubst", "<tr><td>Max Teams</td><td width=\"1%\"><input type=\"text\" name=\"MaxTeams\" maxlength=\"2\" size=\"2\" value="$MaxTeams$"></td><td></tr>");
	}
	
	if (class<TeamGamePlus>(GameClass) != None) {
   		FriendlyFire = Request.GetVariable("FriendlyFire", String(class<TeamGamePlus>(GameClass).Default.FriendlyFireScale * 100));
		FriendlyFire = String(min(max(int(FriendlyFire), 0), 100));
   		class<TeamGamePlus>(GameClass).Default.FriendlyFireScale = float(FriendlyFire)/100.0;
		Response.Subst("FriendlyFireSubst", "<tr><td>Friendly Fire: [0-100]%</td><td width=\"1%\"><input type=\"text\" name=\"FriendlyFire\" maxlength=\"3\" size=\"3\" value=\""$FriendlyFire$"\"></td></tr>");
    }
*/    
    Response.Subst("PostAction", DefaultsRulesPage);
   	Response.Subst("GameType", GameType);
    Response.IncludeUHTM(DefaultsRulesPage$htm);
	Response.ClearSubst();
	
	GameClass.Static.StaticSaveConfig();
}

function QueryDefaultsSettings(WebRequest Request, WebResponse Response)
{
	local String GameType, FragName, FragLimit, TimeLimit, MaxTeams, FriendlyFire, PlayersBalanceTeams, 
		PlayersMustBeReady, ForceRespawn, MaxLives;
	local String MaxPlayers, MaxSpectators, UseMapDefaults;
	local class<GameInfo> GameClass;
	
	GameType = string(Level.Game.Class);	//Request.GetVariable("GameType", GameTypeList.Data);
	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));

	MaxPlayers = Request.GetVariable("MaxPlayers", String(class<MpGameInfo>(GameClass).Default.MaxPlayers));
	MaxPlayers = String(clamp(int(MaxPlayers), 0, 16));
	class<MpGameInfo>(GameClass).Default.MaxPlayers = int(MaxPlayers);
	Response.Subst("MaxPlayers", MaxPlayers);
	
	MaxSpectators = Request.GetVariable("MaxSpectators", String(class<MpGameInfo>(GameClass).Default.MaxSpectators));
	MaxSpectators = String(clamp(int(MaxSpectators), 0, 16));
	class<MpGameInfo>(GameClass).Default.MaxSpectators = int(MaxSpectators);
	Response.Subst("MaxSpectators", MaxSpectators);
/*
// RWS CHANGE: Temp hack to compile in 927 because these flags don't exist
//	if (class<MpGameInfo>(GameClass).Default.bMegaSpeed == true)
//		GameStyle=1;
//	if (class<MpGameInfo>(GameClass).Default.bHardCoreMode == true)
//		GameStyle+=1;
	
	switch (Request.GetVariable("GameStyle", String(GameStyle))) {
	case "0":
//		class<MpGameInfo>(GameClass).Default.bMegaSpeed = false;
//		class<MpGameInfo>(GameClass).Default.bHardCoreMode = false;
		Response.Subst("Normal", " selected"); break;
		break;
	case "1":
//		class<MpGameInfo>(GameClass).Default.bMegaSpeed = false;
//		class<MpGameInfo>(GameClass).Default.bHardCoreMode = true;
		Response.Subst("HardCore", " selected"); break;
	case "2":
//		class<MpGameInfo>(GameClass).Default.bMegaSpeed = true;
//		class<MpGameInfo>(GameClass).Default.bHardCoreMode = true;
		Response.Subst("Turbo", " selected"); break;
	}

	GameSpeed = class<MpGameInfo>(GameClass).Default.GameSpeed * 100.0;
// RWS CHANGE: Temp hack to compile in 927 because these flags don't exist
	AirControl = 0.0; //class<MpGameInfo>(GameClass).Default.AirControl * 100.0;
// RWS CHANGE: Temp hack to compile in 927 because these flags don't exist
	UseTranslocator = "false"; //String(class<MpGameInfo>(GameClass).Default.bUseTranslocator);
*/
	if (Request.GetVariable("Apply", "") != "") {
		if(	class<TeamGame>(GameClass) != None )
		{
			PlayersBalanceTeams = Request.GetVariable("PlayersBalanceTeams", "false");
			class<TeamGame>(GameClass).Default.bPlayersBalanceTeams = PlayersBalanceTeams ~= "true";
		}

		//UseMapDefaults = Request.GetVariable("UseMapDefaults", "false");
		//class<Deathmatch>(GameClass).Default.bUseMapDefaults = bool(UseMapDefaults);

		ForceRespawn = Request.GetVariable("ForceRespawn", "false");
		class<Deathmatch>(GameClass).Default.bForceRespawn = bool(ForceRespawn);

		PlayersMustBeReady = Request.GetVariable("PlayersMustBeReady", "false");
		class<DeathMatch>(GameClass).Default.bPlayersMustBeReady = bool(PlayersMustBeReady);
		
		//GameSpeed = min(max(int(Request.GetVariable("GameSpeed", String(GameSpeed))), 10), 200);
		//class<MpGameInfo>(GameClass).Default.GameSpeed = GameSpeed / 100.0;

		//AirControl = min(max(int(Request.GetVariable("AirControl", String(AirControl))), 0), 100);
		// RWS -- class<MpGameInfo>(GameClass).Default.AirControl = AirControl / 100.0;

		//UseTranslocator = Request.GetVariable("UseTranslocator", "false");
		// RWS -- class<MpGameInfo>(GameClass).Default.bUseTranslocator = bool(UseTranslocator);
	}
	
	if(	class<TeamGame>(GameClass) != None )
	{
		PlayersBalanceTeams = String(class<TeamGame>(GameClass).Default.bPlayersBalanceTeams);
		if (PlayersBalanceTeams ~= "true")
			PlayersBalanceTeams = " checked";
		else
			PlayersBalanceTeams = "";
		Response.Subst("BalanceSubst", "<tr><td>Force Balanced Teams</td><td width=\"1%\"><input type=\"checkbox\" name=\"PlayersBalanceTeams\" value=\"true\""$PlayersBalanceTeams$"></td></tr>");
	}
	
/*	UseMapDefaults = String(class<Deathmatch>(GameClass).Default.bUseMapDefaults);
	if (UseMapDefaults ~= "true")
		UseMapDefaults = " checked";
	else
		UseMapDefaults = "";
	Response.Subst("UseMapDefaultsSubst", "<tr><td>Use Map Defaults</td><td width=\"1%\"><input type=\"checkbox\" name=\"UseMapDefaults\" value=\"true\""$UseMapDefaults$"></td></tr>");
*/
//	if(	class<LastManStanding>(GameClass) == None )
//	{
		ForceRespawn = String(class<Deathmatch>(GameClass).Default.bForceRespawn);
		if (ForceRespawn ~= "true")
			ForceRespawn = " checked";
		else
			ForceRespawn = "";
		Response.Subst("ForceRespawnSubst", "<tr><td>Force Respawn</td><td width=\"1%\"><input type=\"checkbox\" name=\"ForceRespawn\" value=\"true\""$ForceRespawn$"></td></tr>");
//	}

	if (class<MpGameInfo>(GameClass) != None /* && class<Assault>(GameClass) == None */) {
/*		if (class<TeamGame>(GameClass) != None) {
    		FragLimit = Request.GetVariable("FragLimit", String(class<TeamGame>(GameClass).Default.GoalTeamScore));
    		FragLimit = String(max(int(FragLimit), 0));
    		class<TeamGame>(GameClass).Default.GoalTeamScore = float(FragLimit);
    		FragName = "Max Team Score";
    	}
    	else { */
			FragLimit = Request.GetVariable("FragLimit", String(class<MpGameInfo>(GameClass).Default.GoalScore));
    		FragLimit = String(max(int(FragLimit), 0));
			// Set Grab Bag FragLimit to always be the default - not allowed to change it
			if(class<GrabBagGame>(GameClass) != None)
				FragLimit = String(class<MpGameInfo>(GameClass).Default.GoalScore);
    		class<MpGameInfo>(GameClass).Default.GoalScore = float(FragLimit);
    		FragName = "Score Limit";
//    	}
    	
    	Response.Subst("FragSubst", "<tr><td>"$FragName$"</td><td width=\"1%\"><input type=\"text\" name=\"FragLimit\" maxlength=\"3\" size=\"3\" value=\""$FragLimit$"\"></td></tr>");

	//	if(class<LastManStanding>(GameClass) == None)
	//	{
    		TimeLimit = Request.GetVariable("TimeLimit", String(class<MpGameInfo>(GameClass).Default.TimeLimit));
    		TimeLimit = String(max(int(TimeLimit), 0));
			Response.Subst("TimeLimitSubst", "<tr><td>Time Limit</td><td width=\"1%\"><input type=\"text\" name=\"TimeLimit\" maxlength=\"3\" size=\"3\" value=\""$TimeLimit$"\"></td></tr>");
			class<MpGameInfo>(GameClass).Default.TimeLimit = float(TimeLimit);
	//	}

		PlayersMustBeReady = String(class<DeathMatch>(GameClass).Default.bPlayersMustBeReady);
		if(PlayersMustBeReady ~= "true")
			Response.Subst("PlayersMustBeReady", " checked");
		class<DeathMatch>(GameClass).Default.bPlayersMustBeReady = bool(PlayersMustBeReady);

		if(class<CTFGame>(GameClass) == None)
		{
			MaxLives = Request.GetVariable("MaxLives", String(class<Deathmatch>(GameClass).Default.MaxLives));
			MaxLives = String(max(int(MaxLives), 0));
			Response.Subst("MaxLivesSubst", "<tr><td>Max Lives</td><td><input type=\"text\" name=\"MaxLives\" maxlength=\"3\" size=\"3\" value=\""$MaxLives$"\"></td></tr>");
			class<Deathmatch>(GameClass).Default.MaxLives = int(MaxLives);
		}
	
		if (class<TeamGame>(GameClass) != None)
		{
   			FriendlyFire = Request.GetVariable("FriendlyFire", String(class<TeamGame>(GameClass).Default.FriendlyFireScale * 100));
			FriendlyFire = String(min(max(int(FriendlyFire), 0), 100));
   			class<TeamGame>(GameClass).Default.FriendlyFireScale = float(FriendlyFire)/100.0;
			Response.Subst("FriendlyFireSubst", "<tr><td>Friendly Fire: [0-100]%</td><td width=\"1%\"><input type=\"text\" name=\"FriendlyFire\" maxlength=\"3\" size=\"3\" value=\""$FriendlyFire$"\"></td></tr>");
		}	
	}

//	Response.Subst("GameSpeed", String(GameSpeed));
//	Response.Subst("AirControl", String(AirControl));
//	if (UseTranslocator ~= "true")
//		Response.Subst("UseTranslocator", " checked");
	
	Response.Subst("PostAction", DefaultsSettingsPage);
	Response.Subst("GameType", GameType);
	Response.IncludeUHTM(DefaultsSettingsPage$htm);
	Response.ClearSubst();
	
	GameClass.Static.StaticSaveConfig();
}


function QueryDefaultsBots(WebRequest Request, WebResponse Response)
{
	local String GameType, AutoFill, AutoAdjustSkill, RandomOrder, BalanceTeams, DumbDown;
	local class<GameInfo> GameClass;
// RWS CHANGE: Temp hack to get this to compile because the bot stuff isn't in 927
	//local class<ChallengeBotInfo> BotConfig;
	local int BotDifficulty, MinPlayers;
	
	GameType = Request.GetVariable("GameType", GameTypeList.Data);
	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
	//BotConfig = class<MpGameInfo>(GameClass).Default.BotConfigType;
		
	if (Request.GetVariable("Apply", "") != "") {
		AutoFill = Request.GetVariable("AutoFillBots", "false");
		class<DeathMatch>(GameClass).Default.bAutoFillBots = bool(AutoFill);

		BotDifficulty = int(Request.GetVariable("BotDifficulty", String(BotDifficulty)));
		//BotConfig.Default.Difficulty = BotDifficulty;
		class<MpGameInfo>(GameClass).Default.BotDifficulty = BotDifficulty;
		
		MinPlayers = min(max(int(Request.GetVariable("MinPlayers", String(MinPlayers))), 0), 8);
		class<MpGameInfo>(GameClass).Default.MinPlayers = MinPlayers;
		
		AutoAdjustSkill = Request.GetVariable("AutoAdjustSkill", "false");
		class<Deathmatch>(GameClass).Default.bAdjustSkill = bool(AutoAdjustSkill);

		//RandomOrder = Request.GetVariable("RandomOrder", "false");
		//BotConfig.Default.bRandomOrder = bool(RandomOrder);

		if (class<TeamGame>(GameClass) != None) {
			BalanceTeams = Request.GetVariable("BalanceTeams", "false");
			class<TeamGame>(GameClass).Default.bBalanceTeams = bool(BalanceTeams);

			//if (class<Domination>(GameClass) != None) {
			//	DumbDown = Request.GetVariable("DumbDown", "true");
			//	class<Domination>(GameClass).Default.bDumbDown = bool(Dumbdown);
			//}
		}
		//BotConfig.Static.StaticSaveConfig();
		GameClass.Static.StaticSaveConfig();
	}

	AutoFill = String(class<DeathMatch>(GameClass).Default.bAutoFillBots);
	BotDifficulty = class<MpGameInfo>(GameClass).Default.BotDifficulty;
	MinPlayers = class<MpGameInfo>(GameClass).Default.MinPlayers;
	AutoAdjustSkill = String(class<Deathmatch>(GameClass).Default.bAdjustSkill);
	//RandomOrder = String(BotConfig.Default.bRandomOrder);
	
	if(AutoFill ~= "true")
		Response.Subst("AutoFillBots", " checked");
	
	if (class<TeamGame>(GameClass) != None)
		BalanceTeams = String(class<TeamGame>(GameClass).Default.bBalanceTeams);

	//if (class<Domination>(GameClass) != None)
	//	DumbDown = String(class<Domination>(GameClass).Default.bDumbDown);

	Response.Subst("BotDifficulty"$BotDifficulty, " selected");
	Response.Subst("MinPlayers", String(MinPlayers));
	
	if (AutoAdjustSkill ~= "true")
		Response.Subst("AutoAdjustSkill", " checked");
	//if (RandomOrder ~= "true")
	//	Response.Subst("RandomOrder", " checked");

	if (class<TeamGame>(GameClass) != None) {
		if (BalanceTeams ~= "true")
			BalanceTeams = " checked";
		else
			BalanceTeams = "";
		Response.Subst("BalanceSubst", "<tr><td>Bots Balance Teams</td><td width=\"1%\"><input type=\"checkbox\" name=\"BalanceTeams\" value=\"true\""$BalanceTeams$"></td></tr>");

	/*	if (class<Domination>(GameClass) != None) {
			if (DumbDown ~= "false")
				DumbDown = " checked";
			else
				DumbDown = "";
			Response.Subst("DumbDownSubst", "<tr><td>Enhanced AI</td><td width=\"1%\"><input type=\"checkbox\" name=\"DumbDown\" value=\"false\""$DumbDown$"></td></tr>");
		}
	*/
	}

	Response.Subst("PostAction", DefaultsBotsPage);
	Response.Subst("GameType", GameType);
	Response.IncludeUHTM(DefaultsBotsPage$htm);
	Response.ClearSubst();
}

function QueryDefaultsServer(WebRequest Request, WebResponse Response)
{
	local String ServerName, AdminName, AdminEmail, MOTDLine1, MOTDLine2, MOTDLine3, MOTDLine4, GamePassword, AdminPassword;
	local bool bDoUplink, bWorldLog;
	
	ServerName = class'Engine.GameReplicationInfo'.default.ServerName;
	AdminName = class'Engine.GameReplicationInfo'.default.AdminName;
	AdminEmail = class'Engine.GameReplicationInfo'.default.AdminEmail;
	MOTDLine1 = class'Engine.GameReplicationInfo'.default.MOTDLine1;
	MOTDLine2 = class'Engine.GameReplicationInfo'.default.MOTDLine2;
	MOTDLine3 = class'Engine.GameReplicationInfo'.default.MOTDLine3;
	MOTDLine4 = class'Engine.GameReplicationInfo'.default.MOTDLine4;
	GamePassword = Level.ConsoleCommand("get" @ GAME_PASSWORD_LOCATION @ "GamePassword");
	//AdminPassword = Level.ConsoleCommand("get" @ GAME_PASSWORD_LOCATION @ "AdminPassword");

	bDoUplink = class'UdpServerUplink'.default.DoUplink;
	bWorldLog = Level.Game.Default.bEnableStatLogging;
	
	if (Request.GetVariable("Apply", "") != "")
	{
		ServerName = Request.GetVariable("ServerName", "");
		AdminName = Request.GetVariable("AdminName", "");
		AdminEmail = Request.GetVariable("AdminEmail", "");
		MOTDLine1 = Request.GetVariable("MOTDLine1", "");
		MOTDLine2 = Request.GetVariable("MOTDLine2", "");
		MOTDLine3 = Request.GetVariable("MOTDLine3", "");
		MOTDLine4 = Request.GetVariable("MOTDLine4", "");
		bDoUplink = bool(Request.GetVariable("DoUplink", "false"));
		bWorldLog = bool(Request.GetVariable("WorldLog", "false"));
		GamePassword = Request.GetVariable("GamePassword", "");
		//AdminPassword = Request.GetVariable("AdminPassword", "");
		
		class'Engine.GameReplicationInfo'.Default.ServerName = ServerName;
		class'Engine.GameReplicationInfo'.Default.AdminName = AdminName;
		class'Engine.GameReplicationInfo'.Default.AdminEmail = AdminEmail;
		class'Engine.GameReplicationInfo'.Default.MOTDline1 = MOTDLine1;
		class'Engine.GameReplicationInfo'.Default.MOTDline2 = MOTDLine2;
		class'Engine.GameReplicationInfo'.Default.MOTDline3 = MOTDLine3;
		class'Engine.GameReplicationInfo'.Default.MOTDline4 = MOTDLine4;
		class'Engine.GameReplicationInfo'.Static.StaticSaveConfig();

		class'UdpServerUplink'.default.DoUplink = bDoUplink;
		class'UdpServerUplink'.Static.StaticSaveConfig();
		
		Level.ConsoleCommand("set" @ GAME_PASSWORD_LOCATION @ "GamePassword "$GamePassword);
		//Level.ConsoleCommand("set" @ GAME_PASSWORD_LOCATION @ "AdminPassword "$AdminPassword);
		Level.Game.Default.bEnableStatLogging = bWorldLog;
		Level.Game.Static.StaticSaveConfig();

	}
	
	Response.Subst("ServerName", ServerName);
	Response.Subst("AdminName", AdminName);
	Response.Subst("AdminEmail", AdminEmail);
	Response.Subst("MOTDLine1", MOTDLine1);
	Response.Subst("MOTDLine2", MOTDLine2);
	Response.Subst("MOTDLine3", MOTDLine3);
	Response.Subst("MOTDLine4", MOTDLine4);
	Response.Subst("GamePassword", GamePassword);
	//Response.Subst("AdminPassword", AdminPassword);
	
	if (bDoUplink)
		Response.Subst("DoUplink", " checked");
	if (bWorldLog)
		Response.Subst("WorldLog", " checked");

	Response.Subst("PostAction", DefaultsServerPage);		
	Response.IncludeUHTM(DefaultsServerPage$htm);
}

function QueryDefaultsIPPolicy(WebRequest Request, WebResponse Response)
{
	local int i, j;

	if(Request.GetVariable("Update") != "")
	{
		i = int(Request.GetVariable("PolicyNo", "-1"));
		if(i == -1)
			for(i = 0; i<50 && Level.Game.AccessControl.IPPolicies[i] != ""; i++);
		if(i < 50)
			Level.Game.AccessControl.IPPolicies[i] = Request.GetVariable("AcceptDeny")$","$Request.GetVariable("IPMask");

		Level.Game.SaveConfig();
		Level.Game.AccessControl.SaveConfig();
	}

	if(Request.GetVariable("Delete") != "")
	{
		i = int(Request.GetVariable("PolicyNo", "-1"));
		
		if(i > 0)
		{
			for(i = i; i<49 && Level.Game.AccessControl.IPPolicies[i] != ""; i++)
				Level.Game.AccessControl.IPPolicies[i] = Level.Game.AccessControl.IPPolicies[i + 1];

			if(i == 49)
				Level.Game.AccessControl.IPPolicies[49] = "";

			Level.Game.SaveConfig();
			Level.Game.AccessControl.SaveConfig();
		}
	}

	Response.IncludeUHTM(DefaultsIPPolicyPage$"-h"$htm);
	for(i=0; i<50 && Level.Game.AccessControl.IPPolicies[i] != ""; i++)
	{
		j = InStr(Level.Game.AccessControl.IPPolicies[i], ",");
		if(Left(Level.Game.AccessControl.IPPolicies[i], j) ~= "DENY")
		{
			Response.Subst("AcceptCheck", "");
			Response.Subst("DenyCheck", "checked");
		}
		else
		{
			Response.Subst("AcceptCheck", "checked");
			Response.Subst("DenyCheck", "");
		}
		Response.Subst("IPMask", Mid(Level.Game.AccessControl.IPPolicies[i], j+1));
		Response.Subst("PostAction", DefaultsIPPolicyPage$"?PolicyNo="$string(i));
		Response.IncludeUHTM(DefaultsIPPolicyPage$"-d"$htm);
	}
	Response.Subst("PostAction", DefaultsIPPolicyPage);
	Response.IncludeUHTM(DefaultsIPPolicyPage$"-f"$htm);
}

// RWS CHANGE: Added helper similar to UT2003
function ServerChangeMap(WebRequest Request, WebResponse Response, string MapName, string GameType)
{
	if (Level.NextURL == "")
		Level.ServerTravel(MapName$"?game="$GameType$"?mutator="$UsedMutators(), false);

	ShowMessage(Response, WaitTitle, MapChanging);
}

// RWS CHANGE: Merged helper from UT2003 2199
function bool MapIsChanging()
{
	if (Level.NextURL != "")
	{
		ShowMessage(Resp, WaitTitle, MapChanging);
		return true;
	}
	return false;
}

// RWS CHANGE: Merged helper from UT2003 2199
function ShowMessage(WebResponse Response, string Title, string Message)
{
	Response.Subst("Title", Title);
	Response.Subst("Message", Message);
	Response.IncludeUHTM(MessagePage$htm);
}
    
defaultproperties
{   
	SpectatorType=class'UTServerAdminSpectator'

	MenuPage="menu"
	RootPage="root"

	CurrentPage="current"
	CurrentMenuPage="current_menu"
	CurrentIndexPage="current_index"
	CurrentPlayersPage="current_players"
	CurrentGamePage="current_game"
	CurrentConsolePage="current_console"
	CurrentConsoleLogPage="current_console_log"
	CurrentConsoleSendPage="current_console_send"
	CurrentMutatorsPage="current_mutators"
	CurrentRestartPage="current_restart"

	DefaultsPage="defaults"
	DefaultsMenuPage="defaults_menu"
	DefaultsMapsPage="defaults_maps"
	DefaultsRulesPage="defaults_rules"
	DefaultsSettingsPage="defaults_settings"
	DefaultsBotsPage="defaults_bots"
	DefaultsServerPage="defaults_server"
	DefaultsIPPolicyPage="defaults_ippolicy"
	DefaultsRestartPage="defaults_restart"

	MessagePage="message"

	DefaultBG="#aaaaaa"
	HighlightedBG="#ffffff"
	
	DefaultSendText="say "

	WaitTitle="Please Wait"
	MapChanging="The server is now switching maps.<br>Please allow 10 - 20 seconds while the server changes maps before making any changes."

	Error="Error"
	ErrorAuthenticating="Exception Occured During Authentication!"

	AdminRealm="POSTAL 2 Remote Admin Server"	// "UT Remote Admin Server"
	AdminUsername=""
	AdminPassword=""

	ServerAdminSpectatorName="Web Server Admin"

	htm=".htm"
}