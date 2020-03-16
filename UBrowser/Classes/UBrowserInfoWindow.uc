//=============================================================================
// UBrowserInfoWindow
//=============================================================================
class UBrowserInfoWindow extends UWindowFramedWindow;

var UBrowserInfoMenu Menu;

function Created()
{
	bSizable = True;
	bStatusBar = True;

	Menu = UBrowserInfoMenu(Root.CreateWindow(class'UBrowserInfoMenu', 0, 0, 100, 100));
	Menu.Info = Self;
	Menu.HideWindow();

	Super.Created();
}

function ResolutionChanged(float W, float H)
{
	Super.ResolutionChanged(W, H);
	Resized();
}

defaultproperties
{
	ClientClass=class'UBrowserInfoClientWindow'
}
