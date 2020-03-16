class UBrowserUpdateServerWindow extends UBrowserPageWindow;

var UBrowserUpdateServerLink Link;
var UBrowserUpdateServerTextArea TextArea;

var localized string QueryText;
var localized string FailureText;
var class<UBrowserUpdateServerLink> LinkClass;
var class<UBrowserUpdateServerTextArea> TextAreaClass;
var bool bGotMOTD;
var string StatusBarText;
var bool bHadInitialQuery;
var int Tries;
var int NumTries;

var UBrowserGSpyBanner BannerWindow;
const BANNER_WINDOW_HEIGHT = 70;
const TEXTAREA_FRAME_SIZE = 3;

function Created()
{
	Super.Created();

	TextArea = UBrowserUpdateServerTextArea(CreateControl(TextAreaClass, 0, 0, 0, 0, Self));
	BannerWindow = UBrowserGSpyBanner(CreateWindow(class'UBrowserGSpyBanner', 0, 0, 0, 0));

	SetAcceptsFocus();
}

function Query()
{
	bHadInitialQuery = True;
	StatusBarText = QueryText;
	if(Link != None)
	{
		Link.UpdateWindow = None;
		Link.Destroy();
	}
	Link = GetEntryLevel().Spawn(LinkClass);
	Link.UpdateWindow = Self;
	Link.QueryUpdateServer();
	bGotMOTD = False;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local UBrowserMainWindow W;

	if(!bHadInitialQuery)
		Query();

	Super.BeforePaint(C, X, Y);

	TextArea.SetSize(BodyWidth- TEXTAREA_FRAME_SIZE*2, BodyHeight - TEXTAREA_FRAME_SIZE*2 - BANNER_WINDOW_HEIGHT);
	TextArea.WinTop = BodyTop + TEXTAREA_FRAME_SIZE;
	TextArea.WinLeft = BodyLeft + TEXTAREA_FRAME_SIZE;
	BannerWindow.SetSize(BodyWidth, BANNER_WINDOW_HEIGHT);
	BannerWindow.WinTop = TextArea.WinTop + TextArea.WinHeight;
	BannerWindow.WinLeft = BodyLeft;

	W = UBrowserMainWindow(GetParent(class'UBrowserMainWindow'));
	if(StatusBarText == "")
		W.DefaultStatusBarText(TextArea.StatusURL);
	else
		W.DefaultStatusBarText(StatusBarText);
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	LookAndFeel.DrawFrame(self, C, BodyLeft, BodyTop, BodyWidth, BodyHeight - BANNER_WINDOW_HEIGHT);
}

function SetMOTD(string MOTD)
{
	TextArea.SetHTML(MOTD);
}

function SetMasterServer(string Value)
{
	ReplaceText(Value, Chr(10), "");
	if(Value != "")
		UBrowserMainClientWindow(UBrowserMainWindow(GetParent(class'UBrowserMainWindow')).ClientArea).NewMasterServer(Value);
}

function SetIRCServer(string Value)
{
	StripCRLF(Value);

	if(Value != "")
		UBrowserMainClientWindow(UBrowserMainWindow(GetParent(class'UBrowserMainWindow')).ClientArea).NewIRCServer(Value);
}

function Failure()
{
	Link.UpdateWindow = None;
	Link.Destroy();
	Link = None;
	Tries++;
	if(Tries < NumTries)
	{
		Query();
		return;
	}

	StatusBarText = FailureText;
	Tries = 0;
}

function Success()
{
	StatusBarText = "";

	Link.UpdateWindow = None;
	Link.Destroy();
	Link = None;
	Tries = 0;
}

function KeyDown(int Key, float X, float Y) 
{
	switch(Key)
	{
	case 0x74: // IK_F5;
		TextArea.Clear();
		Query();
		break;
	}
}

defaultproperties
{
	PageHeaderText="The latest news and information about Postal 2 multiplayer."
	FailureText="The server did not respond."
	QueryText="Contacting server..."
	LinkClass=class'UBrowserUpdateServerLink'
	TextAreaClass=class'UBrowserUpdateServerTextArea'
	NumTries=3
	bHelpArea=false
}