class UBrowserPageWindow extends UWindowPageWindow;

var UWindowLabelControl			PageHeader;
var localized string			PageHeaderText;

var MenuWrappedTextControl		helparea;
var float						HelpHeight;
var bool						bHelpArea;
var Color						HelpColor;

var float						ControlWidthPercent;
var float						ControlWidth;
var float						ControlLeft;
var float						EditWidth;
var float						CheckWidth;
var int							ControlFont;

var const float					ControlHeight;
var float						ControlOffset;
var float						BodyTop;
var float						BodyHeight;
var float						BodyLeft;
var float						BodyWidth;
var Color						TC;
var const float					BodyBorderLeftRight;

var const float					SmallEditBoxWidth;


function Created()
{
	local int S;

	Super.Created();

	TC.R = 0;
	TC.G = 0;
	TC.B = 0;
	TC.A = 255;

	ControlFont = F_SmallBold;

	ControlWidth = WinWidth * ControlWidthPercent;
	ControlLeft = (WinWidth - ControlWidth)/2;

	ControlOffset = 4;
	if (PageHeaderText != "")
	{
		PageHeader = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 0, ControlOffset, WinWidth, ControlHeight));
		PageHeader.SetText(PageHeaderText);
		PageHeader.SetFont(F_SmallBold);
		PageHeader.bActive = false;
//		PageHeader.bShadow = false;
		ControlOffset += ControlHeight;
	}

	HelpColor.R = 180;
	HelpColor.G = 40;
	HelpColor.B = 40;
	HelpColor.A = 255;

	BodyTop = ControlOffset;
	BodyHeight = WinHeight - ControlOffset;

	BodyLeft = BodyBorderLeftRight;
	BodyWidth = WinWidth - BodyBorderLeftRight*2;
}

function AfterCreate()
{
	Super.AfterCreate();

	// Make Help Text Area
	if (bHelpArea)
	{
		helparea = MenuWrappedTextControl(CreateControl(class'MenuWrappedTextControl', 0, 0, ControlWidth, 100));
		helparea.SetFont(F_SmallBold);
		helparea.SetTextColor(HelpColor);
		helparea.bActive = false;
		helparea.bShadow = false;
		helparea.bCenterVertical = true;
	}
}

function Resized()
{
	Super.Resized();

	BodyHeight = WinHeight - BodyTop;
	BodyWidth = WinWidth - BodyBorderLeftRight*2;

	if (bHelpArea)
		BodyHeight -= HelpHeight;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth * ControlWidthPercent;
	ControlLeft = (WinWidth - ControlWidth)/2;

	EditWidth = ControlWidth/2;
	CheckWidth = ControlWidth - EditWidth + 13;

	if(PageHeader != None)
	{
		C.Font = Root.Fonts[PageHeader.Font];
		TextSize(C, PageHeaderText, W, H);
		PageHeader.SetSize(W, H);
		PageHeader.WinLeft = (WinWidth - PageHeader.WinWidth) / 2;
	}

	BodyHeight = WinHeight - BodyTop;
	BodyWidth = WinWidth - BodyBorderLeftRight*2;

	if (bHelpArea)
	{
		if(!helparea.WindowIsVisible())
			helparea.ShowWindow();
		helparea.SetSize(WinWidth-20, HelpHeight);
		helparea.WinTop = WinHeight - HelpHeight;
		helparea.WinLeft = 10;
		BodyHeight -= HelpHeight;
	}
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	if (bHelpArea)
		DrawUpBevel(C, 0, helparea.WinTop, WinWidth, helparea.WinHeight, GetLookAndFeelTexture());
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if(E == DE_MouseMove)
	{
		if(helparea != None)
			helparea.SetText(C.HelpText);
	}

	if(E == DE_MouseLeave)
	{
		if(helparea != None)
			helparea.SetText("");
	}
}

function SetHelpText(string HelpText)
{
	if (helparea != None)
		helparea.SetText(HelpText);
}

defaultproperties
{
	ControlWidthPercent=0.75
	ControlHeight=22
	BodyBorderLeftRight=3
	HelpHeight=34
	bHelpArea=true
	SmallEditBoxWidth=35
}
