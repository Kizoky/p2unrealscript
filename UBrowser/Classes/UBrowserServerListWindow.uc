class UBrowserServerListWindow extends UBrowserPageWindow
	PerObjectConfig;

var config string				ServerListTitle;	// Non-localized page title
var config string				ListFactories[10];
var config string				URLAppend;
var config int					AutoRefreshTime;
var config bool					bNoAutoSort;
var config bool					bHidden;
var config bool					bFallbackFactories;
// RWS Change: Game Type column for all and lan
var config bool					bGameTypeCol;

var UBrowserMainClientWindow	MainWindow;

var string						ServerListClassName;
var class<UBrowserServerList>	ServerListClass;

var UBrowserServerList			PingedList;
var UBrowserServerList			UnpingedList;

var UBrowserServerListFactory	Factories[10];
var int							QueryDone[10];
var UBrowserServerGrid			Grid;
var string						GridClass;
var float						TimeElapsed;
var bool						bPingSuspend;
var bool						bPingResume;
var bool						bPingResumeIntial;
var bool						bNoSort;
var bool						bSuspendPingOnClose;
var UBrowserSubsetList			SubsetList;
var UBrowserSupersetList		SupersetList;
var class<UBrowserRightClickMenu>	RightClickMenuClass;
var bool						bShowFailedServers;
var bool						bHadInitialRefresh;
var int							FallbackFactory;

var UWindowCheckbox				ServerDetailsCheck;		// Show server info, player list, screenshot...
var localized string			ServerDetailsText;
var localized string			ServerDetailsHelp;

var UWindowSmallButton			RefreshList;
var localized string			RefreshListName;
var localized string			RefreshListHelp;

var UWindowSmallButton			PingAll;
var localized string			PingAllName;
var localized string			PingAllHelp;

var UWindowSmallButton			Join;
var localized string			JoinName;
var localized string			JoinHelp;

var UWindowVSplitter			VSplitter;
var UBrowserInfoWindow			InfoWindow;
var UBrowserInfoClientWindow	InfoClient;
var UBrowserServerList			InfoItem;
var localized string			InfoName;

var float						BevelTop;
var float						BevelHeight;
var float						ButtonTextPadding;
var float						ButtonSpacing;

const MinHeightForSplitter = 384;

var localized string			PlayerCountLeader;
var localized string			ServerCountLeader;


// Status info
enum EPingState
{
	PS_QueryServer,
	PS_QueryFailed,
	PS_Pinging,
	PS_RePinging,
	PS_Done
};

var localized string			PlayerCountName;
var localized string			ServerCountName;
var	localized string			QueryServerText;
var	localized string			QueryFailedText;
var	localized string			PingingText;
var	localized string			CompleteText;

var string						ErrorString;
var EPingState					PingState;

function WindowShown()
{
	local UBrowserSupersetList l;

	Super.WindowShown();

	ServerDetailsCheck.bChecked = MainWindow.bShowServerDetails;
	ShowInfoArea(ServerDetailsCheck.GetValue());

	if(VSplitter.bWindowVisible)
	{
		if(UWindowVSplitter(InfoClient.ParentWindow) != None)
			VSplitter.SplitPos = UWindowVSplitter(InfoClient.ParentWindow).SplitPos;

		InfoClient.SetParent(VSplitter);
	}

	InfoClient.Server = InfoItem;
	if(InfoItem != None)
		InfoWindow.WindowTitle = InfoName$" - "$InfoItem.HostName;
	else
		InfoWindow.WindowTitle = InfoName;

	ResumePinging();

	for(l = UBrowserSupersetList(SupersetList.Next); l != None; l = UBrowserSupersetList(l.Next))
		l.SuperSetWindow.ResumePinging();
}

function WindowHidden()
{
	local UBrowserSupersetList l;

	Super.WindowHidden();
	SuspendPinging();

	for(l = UBrowserSupersetList(SupersetList.Next); l != None; l = UBrowserSupersetList(l.Next))
		l.SuperSetWindow.SuspendPinging();
}

function SuspendPinging()
{
	if(bSuspendPingOnClose)
		bPingSuspend = True;
}

function ResumePinging()
{
	if(!bHadInitialRefresh)
		Refresh(False, True);	

	bPingSuspend = False;
	if(bPingResume)
	{
		bPingResume = False;
		UnpingedList.PingNext(bPingResumeIntial, bNoSort);
	}
}

function String GetItemName( string FullName )
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

function Created()
{
	local Class<UBrowserServerGrid> C;
	local string MyName;

	// Ugly hack.  The favorites stuff gets created a different way, so there end up being
	// multiple copies created, each with a different number at the end of its name.  This
	// basically strips out the number.  Yes, very ugly.
	MyName = GetItemName(string(self));
	if (InStr(MyName, "UTBrowserFavoriteServers") != -1)
		MyName = "UTBrowserFavoriteServers";

	PageHeaderText = Localize("ServerListPageHeaders", MyName, "MultiplayerInfo");
	
	Super.Created();

	MainWindow = UBrowserMainClientWindow(GetParent(class'UBrowserMainClientWindow'));

	// Bevel to contain some of the controls
	Beveltop = ControlOffset;
	ControlOffset += BevelHeight;

	// Server Details Check Box
	ServerDetailsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 0, 0, ControlWidth, ControlHeight));
	ServerDetailsCheck.SetText(ServerDetailsText);
	ServerDetailsCheck.SetHelpText(ServerDetailsHelp);
	ServerDetailsCheck.SetFont(ControlFont);
	ServerDetailsCheck.Align = TA_LeftOfText;
	ServerDetailsCheck.bChecked = MainWindow.bShowServerDetails;

	Join = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 0, 0, ControlWidth, ControlHeight));
	Join.SetText(JoinName);
	Join.SetHelpText(JoinHelp);
	Join.SetFont(ControlFont);

	PingAll = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 0, 0, ControlWidth, ControlHeight));
	PingAll.SetText(PingAllName);
	Pingall.SetHelpText(PingAllHelp);
	PingAll.SetFont(ControlFont);

	RefreshList = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 0, 0, ControlWidth, ControlHeight));
	RefreshList.SetText(RefreshListName);
	RefreshList.SetHelpText(RefreshListName);
	RefreshList.SetFont(ControlFont);

	BodyTop = ControlOffset;
	BodyHeight = WinHeight - ControlOffset;

	ServerListClass = class<UBrowserServerList>(DynamicLoadObject(ServerListClassName, class'Class'));
	C = class<UBrowserServerGrid>(DynamicLoadObject(GridClass, class'Class'));
	Grid = UBrowserServerGrid(CreateWindow(C, 0, 0, WinWidth, WinHeight));
	// RWS Change: Game Type column for all and lan
	Grid.bShowGameTypes = bGameTypeCol;
	Grid.SetAcceptsFocus();

	SubsetList = new class'UBrowserSubsetList';
	SubsetList.SetupSentinel();

	SupersetList = new class'UBrowserSupersetList';
	SupersetList.SetupSentinel();

	VSplitter = UWindowVSplitter(CreateWindow(class'UWindowVSplitter', BodyLeft, BodyTop, BodyWidth, BodyHeight));
	VSplitter.SetAcceptsFocus();
	VSplitter.MinWinHeight = 50;
	VSplitter.HideWindow();
	InfoWindow = MainWindow.InfoWindow;
	InfoClient = UBrowserInfoClientWindow(InfoWindow.ClientArea);

	if(Root.WinHeight >= MinHeightForSplitter)
		ShowInfoArea(True, False);
}

function Resized()
{
	Super.Resized();

	if(VSplitter.bWindowVisible)
	{
		VSplitter.SetSize(BodyWidth, BodyHeight);
		VSplitter.WinTop = BodyTop;
		VSplitter.OldWinHeight = VSplitter.WinHeight;
		VSplitter.SplitPos = VSplitter.WinHeight - Min(VSplitter.WinHeight * 0.6, 350);
	}
	else
	{
		Grid.WinTop = BodyTop;
		Grid.WinLeft = BodyLeft;
		Grid.SetSize(BodyWidth, BodyHeight);
	}

	UpdateBevel();
}

function ResolutionChanged(float W, float H)
{
	if(Root.WinHeight >= MinHeightForSplitter)
		ShowInfoArea(True, False);
	else
		ShowInfoArea(False, True);
	
	if(InfoWindow != None)
		InfoWindow.ResolutionChanged(W, H);

	Super.ResolutionChanged(W, H);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local UBrowserMainWindow W;
	local UBrowserSupersetList l;
	local EPingState P;
	local int PercentComplete;
	local int TotalReturnedServers;
	local string E;
	local int TotalServers;
	local int PingedServers;
	local int MyServers;
	local float TextW, TextH;

	Super.BeforePaint(C, X, Y);

	LayoutBevel(C);

	W = UBrowserMainWindow(GetParent(class'UBrowserMainWindow'));
	l = UBrowserSupersetList(SupersetList.Next);

	// Moved to BeforePaint from Tick - nobody calls this class' tick...
	if(PingedList.bNeedUpdateCount)
	{
		PingedList.UpdateServerCount();
		PingedList.bNeedUpdateCount = False;
	}

	if(l != None && PingState != PS_RePinging)
	{
		P = l.SupersetWindow.PingState;
		PingState = P;

		if(P == PS_QueryServer)
			TotalReturnedServers = l.SupersetWindow.UnpingedList.Count();

		PingedServers = l.SupersetWindow.PingedList.Count();
		TotalServers = l.SupersetWindow.UnpingedList.Count() + PingedServers;
		MyServers = PingedList.Count();
	
		E = l.SupersetWindow.ErrorString;
	}
	else
	{
		P = PingState;
		if(P == PS_QueryServer)
			TotalReturnedServers = UnpingedList.Count();

		PingedServers = PingedList.Count();
		TotalServers = UnpingedList.Count() + PingedServers;
		MyServers = PingedList.Count();

		E = ErrorString;
	}

	if(TotalServers > 0)
		PercentComplete = PingedServers*100.0/TotalServers;

	switch(P)
	{
	case PS_QueryServer:
		if(TotalReturnedServers > 0)
			W.DefaultStatusBarText(QueryServerText$" ("$ServerCountLeader$TotalReturnedServers$" "$ServerCountName$")");
		else
			W.DefaultStatusBarText(QueryServerText);
		break;
	case PS_QueryFailed:
		W.DefaultStatusBarText(QueryFailedText$E);
		break;
	case PS_Pinging:
	case PS_RePinging:
		W.DefaultStatusBarText(PingingText$" "$PercentComplete$"% "$CompleteText$". "$ServerCountLeader$MyServers$" "$ServerCountName$", "$PlayerCountLeader$PingedList.TotalPlayers$" "$PlayerCountName);
		break;
	case PS_Done:
		W.DefaultStatusBarText(ServerCountLeader$MyServers$" "$ServerCountName$", "$PlayerCountLeader$PingedList.TotalPlayers$" "$PlayerCountName);
		break;
	}
}

function LayoutBevel(Canvas C)
{
	local Font oldFont;
	local float XL, YL;

//	oldFont = C.Font;

	C.Font = Root.Fonts[ControlFont];

	TextSize(C, ServerDetailsText, XL, YL);
	ServerDetailsCheck.SetSize(XL + 20, ControlHeight);

	C.StrLen(JoinName, XL, YL);
	Join.SetSize(XL + ButtonTextPadding, ControlHeight);

	C.StrLen(PingAllName, XL, YL);
	PingAll.SetSize(XL + ButtonTextPadding, ControlHeight);

	C.StrLen(RefreshListName, XL, YL);
	RefreshList.SetSize(XL + ButtonTextPadding, ControlHeight);

//	C.Font = oldFont;

	UpdateBevel();
}

function UpdateBevel()
{
	Join.WinLeft = BodyLeft + 10;
	Join.WinTop = BevelTop + (BevelHeight - ServerDetailsCheck.WinHeight)/2;

	ServerDetailsCheck.WinLeft = BodyLeft + (BodyWidth - ServerDetailsCheck.WinWidth)/2;
	ServerDetailsCheck.WinTop = BevelTop + (BevelHeight - ServerDetailsCheck.WinHeight)/2;

	PingAll.WinLeft = (BodyLeft + BodyWidth) - ButtonSpacing - PingAll.WinWidth;
	PingAll.WinTop = BevelTop + (BevelHeight - ServerDetailsCheck.WinHeight)/2;
	RefreshList.WinLeft = PingAll.WinLeft - ButtonSpacing - RefreshList.WinWidth;
	RefreshList.WinTop = BevelTop + (BevelHeight - ServerDetailsCheck.WinHeight)/2;
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	DrawUpBevel( C, BodyLeft, BevelTop, BodyWidth, BevelHeight, GetLookAndFeelTexture());
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
	case DE_Click:
		switch(C)
		{
		case Join:
			if (Grid.SelectedServer != None)
				Grid.JoinServer(Grid.SelectedServer, false, false);
			break;
		case PingAll:
			Grid.RePing();
			break;
		case RefreshList:
			Grid.Refresh();
			break;
		}
		break;
	case DE_Change:
		switch(C)
		{
		case ServerDetailsCheck:
			MainWindow.bShowServerDetails = ServerDetailsCheck.GetValue();
			MainWindow.SaveConfigs();
			ShowInfoArea(ServerDetailsCheck.GetValue());
			break;
		}
		break;
	}
	Super.Notify(C, E);
}

function ShowInfoArea(bool bShow, optional bool bFloating, optional bool bNoActivate)
{
	if(bShow && ServerDetailsCheck.GetValue())
	{
		if(bFloating)
		{
			VSplitter.HideWindow();
			VSplitter.TopClientWindow = None;
			VSplitter.BottomClientWindow = None;
			InfoClient.SetParent(InfoWindow);
			Grid.SetParent(Self);
			Grid.SetSize(BodyWidth, BodyHeight);
			if(!InfoWindow.bWindowVisible)
				InfoWindow.ShowWindow();
			if(!bNoActivate)
				InfoWindow.BringToFront();
		}
		else
		{
			InfoWindow.HideWindow();
			VSplitter.ShowWindow();
			VSplitter.SetSize(BodyWidth, BodyHeight);
			Grid.SetParent(VSplitter);
			InfoClient.SetParent(VSplitter);
			VSplitter.TopClientWindow = Grid;
			VSplitter.BottomClientWindow = InfoClient;
			Grid.WinTop = 0;
			Grid.WinLeft = 0;
		}
	}
	else
	{
		InfoWindow.HideWindow();
		VSplitter.HideWindow();
		VSplitter.TopClientWindow = None;
		VSplitter.BottomClientWindow = None;
		InfoClient.SetParent(InfoWindow);
		Grid.SetParent(Self);
		Grid.SetSize(BodyWidth, BodyHeight);
		Grid.WinTop = BodyTop;
		Grid.WinLeft = BodyLeft;
	}
	Resized();
}

function AutoInfo(UBrowserServerList I)
{
	if(Root.WinHeight >= MinHeightForSplitter || InfoWindow.bWindowVisible)
		ShowInfo(I, True);
}

function ShowInfo(UBrowserServerList I, optional bool bAutoInfo)
{
	if(I == None) return;
	ShowInfoArea(True, Root.WinHeight < MinHeightForSplitter, bAutoInfo);

	InfoItem = I;
	InfoClient.Server = InfoItem;
	InfoWindow.WindowTitle = InfoName$" - "$InfoItem.HostName;
	I.ServerStatus();
}

function AddSubset(UBrowserSubsetFact Subset)
{
	local UBrowserSubsetList l;

	for(l = UBrowserSubsetList(SubsetList.Next); l != None; l = UBrowserSubsetList(l.Next))
		if(l.SubsetFactory == Subset)
			return;
	
	l = UBrowserSubsetList(SubsetList.Append(class'UBrowserSubsetList'));
	l.SubsetFactory = Subset;
}

function AddSuperSet(UBrowserServerListWindow Superset)
{
	local UBrowserSupersetList l;

	for(l = UBrowserSupersetList(SupersetList.Next); l != None; l = UBrowserSupersetList(l.Next))
		if(l.SupersetWindow == Superset)
			return;
	
	l = UBrowserSupersetList(SupersetList.Append(class'UBrowserSupersetList'));
	l.SupersetWindow = Superset;
}

function RemoveSubset(UBrowserSubsetFact Subset)
{
	local UBrowserSubsetList l;

	for(l = UBrowserSubsetList(SubsetList.Next); l != None; l = UBrowserSubsetList(l.Next))
		if(l.SubsetFactory == Subset)
			l.Remove();
}

function RemoveSuperset(UBrowserServerListWindow Superset)
{
	local UBrowserSupersetList l;

	for(l = UBrowserSupersetList(SupersetList.Next); l != None; l = UBrowserSupersetList(l.Next))
		if(l.SupersetWindow == Superset)
			l.Remove();
}

function UBrowserServerList AddFavorite(UBrowserServerList Server)
{
	return UBrowserServerListWindow(MainWindow.Favorites.Page).AddFavorite(Server);
}

function Refresh(optional bool bBySuperset, optional bool bInitial, optional bool bSaveExistingList, optional bool bInNoSort)
{
	bHadInitialRefresh = True;

	if(!bSaveExistingList)
	{
		InfoItem = None;
		InfoClient.Server = None;
	}

	if(!bSaveExistingList && PingedList != None)
	{
		PingedList.DestroyList();
		PingedList = None;
		Grid.SelectedServer = None;
	}

	if(PingedList == None)
	{
		PingedList=New ServerListClass;
		PingedList.Owner = Self;
		PingedList.SetupSentinel(True);
		PingedList.bSuspendableSort = True;
	}
	else
	{
		TagServersAsOld();
	}

	if(UnpingedList != None)
		UnpingedList.DestroyList();
	
	if(!bSaveExistingList)
	{
		UnpingedList = New ServerListClass;
		UnpingedList.Owner = Self;
		UnpingedList.SetupSentinel(False);
	}

	PingState = PS_QueryServer;
	ShutdownFactories(bBySuperset);
	CreateFactories(bSaveExistingList);
	Query(bBySuperset, bInitial, bInNoSort);

	if(!bInitial)
		RefreshSubsets();
}

function TagServersAsOld()
{
	local UBrowserServerList l;

	for(l = UBrowserServerList(PingedList.Next);l != None;l = UBrowserServerList(l.Next)) 
		l.bOldServer = True;
}

function RemoveOldServers()
{
	local UBrowserServerList l, n;

	l = UBrowserServerList(PingedList.Next);
	while(l != None) 
	{
		n = UBrowserServerList(l.Next);

		if(l.bOldServer)
		{
			if(Grid.SelectedServer == l)
				Grid.SelectedServer = n;

			l.Remove();
		}
		l = n;
	}
}

function RefreshSubsets()
{
	local UBrowserSubsetList l, NextSubset;

	for(l = UBrowserSubsetList(SubsetList.Next); l != None; l = UBrowserSubsetList(l.Next))
		l.bOldElement = True;

	l = UBrowserSubsetList(SubsetList.Next);
	while(l != None && l.bOldElement)
	{
		NextSubset = UBrowserSubsetList(l.Next);
		l.SubsetFactory.Owner.Owner.Refresh(True);
		l = NextSubset;
	}
}

function RePing()
{
	PingState = PS_RePinging;
	PingedList.InvalidatePings();
	PingedList.PingServers(True, False);
}

function QueryFinished(UBrowserServerListFactory Fact, bool bSuccess, optional string ErrorMsg)
{
	local int i;
	local bool bDone;

	bDone = True;
	for(i=0;i<10;i++)
	{
		if(Factories[i] != None)
		{
			if(Factories[i] == Fact)
				QueryDone[i] = 1;
			if(QueryDone[i] == 0)
				bDone = False;
		}
	}

	if(!bSuccess)
	{
		PingState = PS_QueryFailed;
		ErrorString = ErrorMsg;

		// don't ping and report success if we have no servers.
		if(bDone && UnpingedList.Count() == 0)
		{
			if( bFallbackFactories )
			{
				FallbackFactory++;
				if( ListFactories[FallbackFactory] != "" )
					Refresh();	// try the next fallback master server
				else
					FallbackFactory = 0;
			}
			return;
		}
	}
	else
		ErrorString = "";

	if(bDone)
	{
		RemoveOldServers();

		PingState = PS_Pinging;
		if(!bNoSort && !Fact.bIncrementalPing)
			PingedList.Sort();
		UnpingedList.PingServers(True, bNoSort || Fact.bIncrementalPing);
	}
}

function PingFinished()
{
	PingState = PS_Done;
}

function CreateFactories(bool bUsePingedList)
{
	local int i;

	for(i=0;i<10;i++)
	{
		if(ListFactories[i] == "")
			break;
		if(!bFallbackFactories || FallbackFactory == i)
		{
			Factories[i] = UBrowserServerListFactory(BuildObjectWithProperties(ListFactories[i]));
			
			Factories[i].PingedList = PingedList;
			Factories[i].UnpingedList = UnpingedList;
		
			if(bUsePingedList)
				Factories[i].Owner = PingedList;
			else
				Factories[i].Owner = UnpingedList;
		}
		QueryDone[i] = 0;
	}	
}

function ShutdownFactories(optional bool bBySuperset)
{
	local int i;

	for(i=0;i<10;i++)
	{
		if(Factories[i] != None) 
		{
			Factories[i].Shutdown(bBySuperset);
			Factories[i] = None;
		}
	}	
}

function Query(optional bool bBySuperset, optional bool bInitial, optional bool bInNoSort)
{
	local int i;

	bNoSort = bInNoSort;

	// Query all our factories
	for(i=0;i<10;i++)
	{
		if(Factories[i] != None)
			Factories[i].Query(bBySuperset, bInitial);
	}
}

function Tick(float Delta)
{
	PingedList.Tick(Delta);

	// AutoRefresh local servers
	if(AutoRefreshTime > 0)
	{
		TimeElapsed += Delta;
		
		if(TimeElapsed > AutoRefreshTime)
		{
			TimeElapsed = 0;
			Refresh(,,True, bNoAutoSort);
		}
	}	
}

defaultproperties
{
	GridClass="UBrowser.UBrowserServerGrid";
	bSuspendPingOnClose=True
	ServerListClassName="UBrowser.UBrowserServerList"
	RightClickMenuClass=class'UBrowserRightClickMenu'
	bShowFailedServers=False
	InfoName="Info"

	PlayerCountName="Players"
	PlayerCountLeader=""
	ServerCountName="Servers"
	ServerCountLeader=""
	QueryServerText="Querying master server (press F5 if nothing happens)"
	QueryFailedText="Master Server Failed: "
	PingingText="Pinging Servers"
	CompleteText="Complete"
	
	RefreshListName="Refresh List"
	RefreshListHelp"Updates the list of servers.  This is useful if you're waiting for a particular server to become available."
	PingAllName="Ping All"
	PingAllHelp="Ping all the servers in the list.  The servers with the lowest ping times will usually give you the best gameplay."
	JoinName="Join"
	JoinHelp="Select a server from the list below then click this button to join it."
	ServerDetailsText="Show Server Details"
	ServerDetailsHelp="Displays players, settings and a screenshot for the currently selected server."

	bFallbackFactories=False
	FallbackFactory=0
	BevelHeight=30
	ButtonTextPadding=12
	ButtonSpacing=8
}
