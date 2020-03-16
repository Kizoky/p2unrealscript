class UBrowserIRCWindow extends UBrowserPageWindow;

var UWindowPageControl		PageControl;
var UBrowserIRCSystemPage	SystemPage;

var localized string SystemName;

function Created()
{
	Super.Created();

	PageControl = UWindowPageControl(CreateWindow(class'UWindowPageControl', BodyLeft, BodyTop, BodyWidth, BodyHeight));
	PageControl.SetMultiLine(True);
	PageControl.bSelectNearestTabOnRemove = True;
	SystemPage = UBrowserIRCSystemPage(PageControl.AddPage(SystemName, class'UBrowserIRCSystemPage').Page);
	SystemPage.PageParent = PageControl;
}

function Resized()
{
	Super.Resized();

	PageControl.SetSize(BodyWidth, BodyHeight);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local UBrowserMainWindow W;

	Super.BeforePaint(C, X, Y);

	W = UBrowserMainWindow(GetParent(class'UBrowserMainWindow'));
	W.DefaultStatusBarText("");
	SystemPage.IRCVisible();
}

function WindowHidden()
{
	Super.WindowHidden();
	SystemPage.IRCClosed();
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if(bByParent)
		SystemPage.IRCClosed();
}

defaultproperties
{
	PageHeaderText="Chat with other players and fans about Postal 2 multiplayer"
	SystemName="System"
}
