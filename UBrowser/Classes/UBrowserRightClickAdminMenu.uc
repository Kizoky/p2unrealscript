class UBrowserRightClickAdminMenu extends UWindowRightClickMenu;

var UWindowPulldownMenuItem Play;
var localized string PlayName;

var UWindowPulldownMenuItem Spec;
var localized string SpecName;

function ExecuteItem(UWindowPulldownMenuItem I) 
{
	local UBrowserRightClickMenu W;

	W = UBrowserRightClickMenu(OwnerWindow);

	switch(I)
	{
	case Play:
		W.Grid.JoinServer(W.List, false, true);
		break;
	case Spec:
		W.Grid.JoinServer(W.List, true, true);
		break;
	}
	Super.ExecuteItem(I);
}

function ShowWindow()
{
	Super.ShowWindow();
	Clear();
	Play = AddMenuItem(PlayName, None);
	Spec = AddMenuItem(SpecName, None);
}

defaultproperties
{
	PlayName="Join as Admin"
	SpecName="Spectate as Admin"
}