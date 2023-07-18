class WorkshopGameCW extends UWindowDialogClientWindow;

// Window
var localized string MapsTabText;
var localized string ModsTabText;

var UWindowPageControl Pages;

function Created()
{
	Super.Created();

	Pages = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);

	// Map Tab
	Pages.AddPage(MapsTabText, class'WorkshopGameMapListPage');
	// Mods Tab
	Pages.AddPage(ModsTabText, class'WorkshopGameModsPage');
}

function Resized()
{
	Pages.WinWidth = WinWidth;
	Pages.Winheight = WinHeight;
}

defaultproperties
{
	MapsTabText="Maps"
	ModsTabText="Mods"
}
