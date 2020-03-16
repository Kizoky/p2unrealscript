//=============================================================================
// UBrowserMainWindow - The main window
//=============================================================================
class UBrowserMainWindow extends UWindowFramedWindow;

var UBrowserBannerBar			BannerWindow;
var string						StatusBarDefaultText;
var bool						bStandaloneBrowser;
var localized string			WindowTitleString;

var UBrowserOpenWindow W;

function DefaultStatusBarText(string Text)
{
	StatusBarDefaultText = Text;
	StatusBarText = Text;
}

function BeginPlay()
{
	Super.BeginPlay();

	WindowTitle = WindowTitleString;
	ClientClass = class'UBrowserMainClientWindow';
}

function WindowShown()
{
	Super.WindowShown();
	if(WinLeft < 0 || WinTop < 16 || WinLeft + WinWidth > Root.WinWidth || WinTop + WinHeight > Root.WinHeight)
		SetSizePos();
}

function Created()
{
	bSizable = False;
	bStatusBar = True;

	MinWinWidth = 300;
	MinWinHeight = 300;
	ClientArea = CreateWindow(ClientClass, 4, 16, WinWidth - 8, WinHeight - 20, OwnerWindow);
	CloseBox = UWindowFrameCloseBox(CreateWindow(Class'UWindowFrameCloseBox', WinWidth-20, WinHeight-20, 11, 10));

	SetSizePos();
}

function BeforePaint(Canvas C, float X, float Y)
{
	if(StatusBarText == "")
		StatusBarText = StatusBarDefaultText;

	Super.BeforePaint(C, X, Y);
}

function Close(optional bool bByParent) 
{
	if (ClientArea != None && ClientArea.ModalWindow != None)
	{
		ClientArea.ModalWindow.Close();
		ClientArea.ModalWindow = None;
	}
	else
	{
		if(W != None)
			W.Close();
		
		if(Root != None)
			Root.GoBack();

		if(bStandaloneBrowser)
			Root.ConsoleClose();
		else
			Super.Close(bByParent);
	}
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function Resized()
{
	Super.Resized();
	SetSizePos();
}

function SetSizePos()
{
	if(Root.WinHeight < 600)
		SetSize(Root.WinWidth - 10, Root.WinHeight - 10);
	else
		SetSize(Min(800, Root.WinWidth) - 20, Min(600, Root.WinHeight) - 20);

	WinLeft = Int((Root.WinWidth - WinWidth) / 2);
	WinTop = Int((Root.WinHeight - WinHeight) / 2);
}

// External entry points
function ShowOpenWindow()
{
	W = UBrowserOpenWindow(Root.CreateWindow(class'UBrowserOpenWindow', 300, 80, 100, 100, Self, True));
	ShowModal(W);	
}

function OpenURL(string URL)
{
	if( Left(URL, 7) ~= "http://" )
	{
		GetPlayerOwner().ConsoleCommand("start "$URL);
		Close();
		return;
	}
	else
// RWS Change, changed from unreal to postal2
	if( Left(URL, 9) ~= "postal2://" )
	{
//		P2RootWindow(Root).StartingGame();
		GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
	}
	else
// RWS Change, changed from unreal to postal2
	{
//		P2RootWindow(Root).StartingGame();
		GetPlayerOwner().ClientTravel("postal2://"$URL, TRAVEL_Absolute, false);
	}

	Close();
	Root.ConsoleClose();
}

function SelectInternet()
{
	UBrowserMainClientWindow(ClientArea).SelectInternet();
}

function SelectLAN()
{
	UBrowserMainClientWindow(ClientArea).SelectLAN();
}

defaultproperties
{
	WindowTitleString="POSTAL 2 Server Browser"
}