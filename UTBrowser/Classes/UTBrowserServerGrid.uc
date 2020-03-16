class UTBrowserServerGrid extends UBrowserServerGrid;

var UWindowGridColumn ngStats;
var UWindowGridColumn Ver;
var UWindowGridColumn Password;

var localized string ngStatsName;
var localized string VersionName;
var localized string PasswordName;
var localized string EnabledText;
var UBrowserServerList ConnectToServer;

//var UWindowMessageBox AskNgStats;
//var localized string AskNgStatsTitle;
//var localized string AskNgStatsText;

var localized string ActiveText;
var localized string InactiveText;

var bool bReallyJoinAdmin;
var string ReallyJoinStatsPass;
var bool bGotStatsPass;

var UBrowserMainClientWindow MainWindow;

// sort types--tried to make them enums, but had problems getting them out of the ini like that
const ST_Server		= 0;
const ST_Ping		= 1;	
const ST_MapName	= 2;
const ST_Players	= 3;
const ST_Stats		= 4;
const ST_Version	= 5;
const ST_Password	= 6;
const ST_GameType	= 7;
// Save what group the player wants to sort by
var globalconfig int SortTypeSave;
const SortTypePath		= "UTBrowser.UTBrowserServerGrid SortTypeSave";

var globalconfig int SortDescendSave;
const SortDescendPath	= "UTBrowser.UTBrowserServerGrid SortDescendSave";


function Created()
{
	Super.Created();

	MainWindow = UBrowserMainClientWindow(GetParent(class'UBrowserMainClientWindow'));
}

function CreateColumns()
{
	Super.CreateColumns();

	ngStats	= AddColumn(ngStatsName, 80);
	Password = AddColumn(PasswordName, 40);
	Ver	= AddColumn(VersionName, 50);

	// Get preferences
	SortTypeSave = int(GetPlayerOwner().ConsoleCommand("get" @ SortTypePath));
	SortDescendSave = int(GetPlayerOwner().ConsoleCommand("get" @ SortDescendPath));
	if(SortDescendSave == 0)
		bSortDescending=false;
	else
		bSortDescending=true;

	// Pick column to sort by
	if(SortTypeSave == ST_Server)
		SortByColumn = Server;
	else if(SortTypeSave == ST_Ping)
		SortByColumn = Ping;
	else if(SortTypeSave == ST_MapName)
		SortByColumn = MapName;
	else if(SortTypeSave == ST_Players)
		SortByColumn = Players;
	else if(SortTypeSave == ST_Stats)
		SortByColumn = ngStats;
	else if(SortTypeSave == ST_Version)
		SortByColumn = Ver;
	else if(SortTypeSave == ST_Password)
		SortByColumn = Password;
	else if(SortTypeSave == ST_GameType)
		SortByColumn = GameType;
}

function SortColumn(UWindowGridColumn Column)
{
	Super.SortColumn(Column);

	if(bSortDescending)
		SortDescendSave=1;
	else
		SortDescendSave=0;
	// save it
	GetPlayerOwner().ConsoleCommand("set" @ SortDescendPath @ SortDescendSave);

	// Save the sorting type to the ini
	if(Column == Server)
		SortTypeSave=ST_Server;
	else if(Column == Ping)
		SortTypeSave=ST_Ping;
	else if(Column == MapName)
		SortTypeSave=ST_MapName;
	else if(Column == Players)
		SortTypeSave=ST_Players;
	else if(Column == ngStats)
		SortTypeSave=ST_Stats;
	else if(Column == Ver)
		SortTypeSave=ST_Version;
	else if(Column == Password)
		SortTypeSave=ST_Password;
	else if(Column == GameType)
		SortTypeSave=ST_GameType;
	// Save it
	GetPlayerOwner().ConsoleCommand("set" @ SortTypePath @ SortTypeSave);

	UBrowserServerListWindow(GetParent(class'UBrowserServerListWindow')).PingedList.Sort();	
}

function Resized()
{
	local float W;
	Super.Resized();

	W = WinWidth - VertSB.WinWidth;
	ngStats.WinWidth = W*0.06 - 1;
	Password.WinWidth= W*0.1 - 1;
	Ver.WinWidth	 = W*0.08 - 1;
}

function DrawCell(Canvas C, float X, float Y, UWindowGridColumn Column, UBrowserServerList List)
{
	switch(Column)
	{
	case Ver:
		Column.ClipText( C, X, Y, string(List.GameVer) );
		break;
	case ngStats:
		if( UTBrowserServerList(List).bNGWorldStats )
		{
			if( UTBrowserServerList(List).bNGWorldStatsActive )
				Column.ClipText( C, X, Y, ActiveText );
			else
				Column.ClipText( C, X, Y, InactiveText );
		}
		else if(UTBrowserServerList(List).bNGWorldStatsActive)
			Column.ClipText( C, X, Y, EnabledText );
		break;
	case Password:
		if(UTBrowserServerList(List).PasswordRequired != "")
			Column.ClipText( C, X, Y, UTBrowserServerList(List).PasswordRequired);
		break;
	default:
		Super.DrawCell(C, X, Y, Column, List);
		break;
	}
}

function int Compare(UBrowserServerList T, UBrowserServerList B)
{
	switch(SortByColumn)
	{
	case Ver:
		if( T.GameVer == B.GameVer )
			return ByName(T, B);

		if( T.GameVer >= B.GameVer )
		{
			if(bSortDescending)
				return 1;
			else
				return -1;
		}
		else
		{
			if(bSortDescending)
				return -1;
			else
				return 1;
		}
		
		break;
	case ngStats:
		if( UTBrowserServerList(T).bNGWorldStatsActive == UTBrowserServerList(B).bNGWorldStatsActive )
		{
			if( UTBrowserServerList(T).bNGWorldStats == UTBrowserServerList(B).bNGWorldStats )
				return ByName(T, B);

			if( UTBrowserServerList(T).bNGWorldStats )
			{
				if(bSortDescending)
					return 1;
				else
					return -1;
			}
			else
			{
				if(bSortDescending)
					return -1;
				else
					return 1;
			}
		}
		if(UTBrowserServerList(T).bNGWorldStatsActive)
		{
			if(bSortDescending)
				return 1;
			else
				return -1;
		}
		else
		{
			if(bSortDescending)
				return -1;
			else
				return 1;
		}
		break;
	case Password:
		if( UTBrowserServerList(T).PasswordRequired ~= UTBrowserServerList(B).PasswordRequired )
			return Byname(T, B);

		if(UTBrowserServerList(B).PasswordRequired ~= "")
		{
			if(bSortDescending)
				return 1;
			else
				return -1;
		}
		
		if(UTBrowserServerList(T).PasswordRequired ~= "")
		{
			if(bSortDescending)
				return -1;
			else
				return 1;
		}

		if(UTBrowserServerList(B).PasswordRequired ~= "?")
		{
			if(bSortDescending)
				return 1;
			else
				return -1;
		}
		else
		{
			if(bSortDescending)
				return -1;
			else
				return 1;
		}
		break;
	default:
		return Super.Compare(T, B);
		break;
	}
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
/*	if(W == AskNgStats)
	{
		AskNgStats = None;
		if(Result == MR_Cancel)
			return;
		else
		if(Result == MR_Yes)
		{
			ShowModal(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject("UTBrowser.ngWorldSecretWindow", class'Class')), 100, 100, 200, 200, Root, True));
			bWaitingForNgStats = True;
		}
		else
		{
			GetPlayerOwner().ngSecretSet = True;
			GetPlayerOwner().SaveConfig();
			ReallyJoinServer(ConnectToServer, false, false);
		}
	}*/
}

function JoinServer(UBrowserServerList Server, bool bPlayAsSpectator, bool bAdmin )
{
	if(Server != None && Server.GamePort != 0) 
	{
		// RWS CHANGE: We always players for a stats password if the server has stats enabled
		if(!bPlayAsSpectator && (UTBrowserServerList(Server).bNGWorldStats || UTBrowserServerList(Server).bNGWorldStatsActive))
		{
			ConnectToServer = Server;
			bReallyJoinAdmin = bAdmin;
			bGotStatsPass = false;
			MainWindow.ShowModal(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject("UTBrowser.ngWorldSecretWindow", class'Class')), 100, 100, 200, 200, self));
		}
/*		if(!GetPlayerOwner().ngSecretSet && (UTBrowserServerList(Server).bNGWorldStats || UTBrowserServerList(Server).bNGWorldStatsActive) )
		{
			ConnectToServer = Server;
			AskNgStats = MessageBox(AskNgStatsTitle, AskNgStatsText, MB_YesNoCancel, MR_Yes);
		}*/
		else
			ReallyJoinServer(Server, bPlayAsSpectator, bAdmin);
	}
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
		ReallyJoinServer(ConnectToServer, false, bReallyJoinAdmin);
	}
}

function ReallyJoinServer(UBrowserServerList Server, bool bPlayAsSpectator, bool bAdmin )
{
	local string specstring;
	local string joinstring;
	local string JoinAddress;

	Root.GoToConnectingWindow(Localize("Progress", "ConnectingText", "Engine"), "postal2://"$Server.IP$"/"$Server.MapName, false);

	if(bPlayAsSpectator)
		specstring = "?SpectatorOnly=true";
	if (JoinPassword != "")
		joinstring="?Password="$JoinPassword;
	JoinAddress = "postal2://"$Server.IP$":"$Server.GamePort$UBrowserServerListWindow(GetParent(class'UBrowserServerListWindow')).URLAppend$specstring;
	
	if(ReallyJoinStatsPass != "" && (UTBrowserServerList(Server).bNGWorldStats || UTBrowserServerList(Server).bNGWorldStatsActive))
		joinstring = joinstring$"?StatsPass="$ReallyJoinStatsPass;

	if(bAdmin)
		P2RootWindow(Root).GoToPasswordWindow(JoinAddress);
	else
		GetPlayerOwner().ClientTravel(JoinAddress$joinstring, TRAVEL_Absolute, false);
	//GetParent(class'UWindowFramedWindow').Close();
	Root.ConsoleClose();
}

defaultproperties
{
	ngStatsName="Stats"
	VersionName="Version"
	PasswordName="Password"
	EnabledText="Enabled"
	ActiveText="Yes"
	InactiveText="No"
	SortTypeSave=3
//	AskNgStatsTitle="Use Game Stats?"
//	AskNgStatsText="The server you are joining is collecting game stats.\\n\\nIf you want to be included in the stats you'll need to enter a stats password.\\n\\nDo you want to enter a stats password?"
}