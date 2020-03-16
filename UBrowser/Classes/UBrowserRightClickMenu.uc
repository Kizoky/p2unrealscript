class UBrowserRightClickMenu extends UWindowRightClickMenu;

var UWindowPulldownMenuItem Play;
var UWindowPulldownMenuItem Spec;
var UWindowPulldownMenuItem Admin;
var UWindowPulldownMenuItem Copy;
var UWindowPulldownMenuItem RefreshServer;
var UWindowPulldownMenuItem Favorites;
//var UWindowPulldownMenuItem OpenLocation;

var localized string PlayName;
var localized string SpecName;
var localized string AdminName;
var localized string FavoritesName;
var localized string RefreshServerName;
//var localized string OpenLocationName;
var localized string CopyName;

var UBrowserServerGrid	Grid;
var UBrowserServerList	List;

function Created()
{
	Super.Created();
	
	Play = AddMenuItem(PlayName, None);
	Spec = AddMenuItem(SpecName, None);
	AddMenuItem("-", None);
	Admin = AddMenuItem(AdminName, None);
	Admin.CreateSubMenu(class'UBrowserRightClickAdminMenu', self);
	RefreshServer = AddMenuItem(RefreshServerName, None);
	Copy = AddMenuItem(CopyName, None);
	AddFavoriteItems();
	//AddMenuItem("-", None);
	//OpenLocation = AddMenuItem(OpenLocationName, None);
}

function AddFavoriteItems()
{
	Favorites = AddMenuItem(FavoritesName, None);
}

function ExecuteItem(UWindowPulldownMenuItem I) 
{
	switch(I)
	{
	case Play:
		Grid.JoinServer(List, false, false);
		break;
	case Spec:
		Grid.JoinServer(List, true, false);
		break;
	case Favorites:
		UBrowserServerListWindow(Grid.GetParent(class'UBrowserServerListWindow')).AddFavorite(List);
		break;
	case RefreshServer:
		Grid.RefreshServer();
		break;
	//case OpenLocation:
	//	UBrowserMainWindow(Grid.GetParent(class'UBrowserMainWindow')).ShowOpenWindow();
	//	break;
	case Copy:
		GetPlayerOwner().CopyToClipboard("postal2://"$List.IP$":"$string(List.GamePort));
		break;		
	}

	Super.ExecuteItem(I);
}

function ShowWindow()
{
	Play.bDisabled = List == None || List.GamePort == 0;
	Spec.bDisabled = List == None || List.GamePort == 0;
	Admin.bDisabled = List == None || List.GamePort == 0;
	Copy.bDisabled = List == None || List.GamePort == 0;

	Favorites.bDisabled = List == None;
	RefreshServer.bDisabled = List == None;
	Selected = None;

	Super.ShowWindow();
}

defaultproperties
{
	PlayName="Join"
	SpecName="Spectate"
	AdminName="Admin"
	RefreshServerName="Ping"
	FavoritesName="Add to Favorites"
	//OpenLocationName="Direct IP"
	CopyName="Copy to clipboard"
}
