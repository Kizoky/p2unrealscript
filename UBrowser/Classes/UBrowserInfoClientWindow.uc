//=============================================================================
// UBrowserInfoClientWindow - extra info on a specific server
//=============================================================================
class UBrowserInfoClientWindow extends UWindowClientWindow;

var UBrowserServerList Server;
var UWindowVSplitter VSplitter;
var UWindowHSplitter HSplitter;

var bool Initialized;

function Created()
{
	Initialized = false;
	Super.Created();
	
	HSplitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
	VSplitter = UWindowVSplitter(HSplitter.CreateWindow(class'UWindowVSplitter', 0, 0, WinWidth, WinHeight));

	HSplitter.LeftClientWindow = VSplitter;
	HSplitter.RightClientWindow = UBrowserScreenshotCW(HSplitter.CreateWindow(class'UBrowserScreenshotCW', 0, 0, WinWidth, WinHeight));
	HSplitter.bSizable = false;

	VSplitter.TopClientWindow = UBrowserPlayerGrid(VSplitter.CreateWindow(class'UBrowserPlayerGrid', 0, 0, WinWidth, WinHeight));
	VSplitter.BottomClientWindow = UBrowserRulesGrid(HSplitter.CreateWindow(class'UBrowserRulesGrid', 0, 0, WinWidth, WinHeight));;
}

function Resized()
{
	local UBrowserServerListWindow S;

	HSplitter.SetSize(WinWidth, WinHeight);
	HSplitter.OldWinWidth = WinWidth;
	HSplitter.SplitPos = WinWidth - 7 - (WinHeight);	// RWS CHANGE: Account for splitter size, we want screenshot area perfectly square

	VSplitter.SetSize(WinWidth-WinHeight, WinHeight);

	VSplitter.OldWinHeight = VSplitter.WinHeight;
	VSplitter.SplitPos = (WinHeight) / 2;

	S = UBrowserServerListWindow(GetParent(class'UBrowserServerListWindow'));
	if(!Initialized && S != None)
	{
		Initialized = true;
		S.Resized();
	}
}

