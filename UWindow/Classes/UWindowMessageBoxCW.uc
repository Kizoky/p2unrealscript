class UWindowMessageBoxCW extends UWindowDialogClientWindow;

var MessageBoxButtons Buttons;

var MessageBoxResult EnterResult;
var UWindowSmallButton YesButton, NoButton, OKButton, CancelButton;
var localized string YesText, NoText, OKText, CancelText;
var UWindowMessageBoxArea MessageArea;

var float MB_BorderW;				// How much space to add on left and right sides of client area
var float MB_BorderH;				// How much space to add above and below client area
var float MB_ButtonWidth;			// Button width
var float MB_ButtonHeight;			// Button height
var float MB_ButtonBorderW;			// Extra space around buttons
var float MB_ButtonBorderH;			// Extra space around buttons

var float MB_ButtonAreaHeight;			// Calculated at runtime -- height of button area
var float MB_ButtonDistFromFrameBottom;	// Calculated at runtime -- distance of buttons from bottom of frame window

var string DefaultKeyText, CancelKeyText;

function Created()
{
	Super.Created();
	SetAcceptsFocus();

	MB_ButtonAreaHeight = MB_ButtonHeight + MB_ButtonBorderH * 2;
	MB_ButtonDistFromFrameBottom = MB_ButtonHeight + ((MB_ButtonAreaHeight - MB_ButtonHeight) / 2);

	MessageArea = UWindowMessageBoxArea(CreateWindow(class'UWindowMessageBoxArea', MB_BorderW, MB_BorderH, WinWidth - MB_BorderW*2, WinHeight - MB_BorderH*2 - MB_ButtonAreaHeight));
}

function KeyDown(int Key, float X, float Y)
{
	local UWindowMessageBox P;

	P = UWindowMessageBox(ParentWindow);

	if(Key == GetPlayerOwner().Player.Console.EInputKey.IK_Enter && EnterResult != MR_None)
	{
		P = UWindowMessageBox(ParentWindow);
		P.Result = EnterResult;
		P.Close();
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	MessageArea.SetSize(WinWidth - MB_BorderW*2, WinHeight - MB_BorderH*2 - MB_ButtonAreaHeight);

	switch(Buttons)
	{
	case MB_YesNoCancel:
		CancelButton.WinLeft = WinWidth - (MB_ButtonWidth + MB_ButtonBorderW);
		CancelButton.WinTop = WinHeight - MB_ButtonDistFromFrameBottom;
		NoButton.WinLeft = WinWidth - (MB_ButtonWidth + MB_ButtonBorderW) * 2;
		NoButton.WinTop = WinHeight - MB_ButtonDistFromFrameBottom;
		YesButton.WinLeft = WinWidth - (MB_ButtonWidth + MB_ButtonBorderW) * 3;
		YesButton.WinTop = WinHeight - MB_ButtonDistFromFrameBottom;
		break;
	case MB_YesNo:
		NoButton.WinLeft = WinWidth - (MB_ButtonWidth + MB_ButtonBorderW);
		NoButton.WinTop = WinHeight - MB_ButtonDistFromFrameBottom;
		YesButton.WinLeft = WinWidth - (MB_ButtonWidth + MB_ButtonBorderW) * 2;
		YesButton.WinTop = WinHeight - MB_ButtonDistFromFrameBottom;
		break;
	case MB_OKCancel:
		CancelButton.WinLeft = WinWidth - (MB_ButtonWidth + MB_ButtonBorderW);
		CancelButton.WinTop = WinHeight - MB_ButtonDistFromFrameBottom;
		OKButton.WinLeft = WinWidth - (MB_ButtonWidth + MB_ButtonBorderW) * 2;
		OKButton.WinTop = WinHeight - MB_ButtonDistFromFrameBottom;
		break;
	case MB_OK:
		OKButton.WinLeft = WinWidth - (MB_ButtonWidth + MB_ButtonBorderW);
		OKButton.WinTop = WinHeight - MB_ButtonDistFromFrameBottom;
		break;
	}
}

function Resized()
{
	Super.Resized();
	MessageArea.SetSize(WinWidth - MB_BorderW*2, WinHeight - MB_BorderH*2 - MB_ButtonAreaHeight);
}

function float GetHeight(Canvas C)
{
	return MB_BorderH*2 + MB_ButtonAreaHeight + MessageArea.GetHeight(C);
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;
	Super.Paint(C, X, Y);
	T = GetLookAndFeelTexture();
	// This big thing across the bottom of the window looks stupid
//	DrawUpBevel( C, 0, WinHeight-MB_ButtonAreaHeight, WinWidth, MB_ButtonAreaHeight, T);
}

function SetupMessageBoxClient(string InMessage, MessageBoxButtons InButtons, MessageBoxResult InEnterResult)
{
	local float UseMouseX, UseMouseY;
	local float MouseX, MouseY;
	local int IntMouseX, IntMouseY;
	local UWindowButton DefaultButton;
	local UWindowButton UseButton;
	local UWindowMessageBox P;

	P = UWindowMessageBox(ParentWindow);
	
	MessageArea.Message = InMessage;
	Buttons = InButtons;
	EnterResult = InEnterResult;

	// Create buttons
	switch(Buttons)
	{
	case MB_YesNoCancel:
		CancelButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - (MB_ButtonWidth + MB_ButtonBorderW), WinHeight - MB_ButtonDistFromFrameBottom, MB_ButtonWidth, MB_ButtonHeight));
		CancelButton.SetText(CancelText);
		CancelButton.WinHeight = MB_ButtonHeight;
		CancelButton.SetFont(F_Normal);
		if(EnterResult == MR_Cancel)
		{
			DefaultButton = CancelButton;
			CancelButton.SetText(CancelText @ DefaultKeyText);
		}
		if (P.Result == MR_Cancel)
			CancelButton.SetText(CancelText @ CancelKeyText);
		NoButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - (MB_ButtonWidth + MB_ButtonBorderW)*2, WinHeight - MB_ButtonDistFromFrameBottom, MB_ButtonWidth, MB_ButtonHeight));
		NoButton.SetText(NoText);
		NoButton.WinHeight = MB_ButtonHeight;
		if(EnterResult == MR_No)
		{
			DefaultButton = NoButton;
			NoButton.SetText(NoText @ DefaultKeyText);
		}
		NoButton.SetFont(F_Normal);
		if (P.Result == MR_No)
			NoButton.SetText(NoText @ CancelKeyText);
		YesButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - (MB_ButtonWidth + MB_ButtonBorderW)*3, WinHeight - MB_ButtonDistFromFrameBottom, MB_ButtonWidth, MB_ButtonHeight));
		YesButton.SetText(YesText);
		YesButton.WinHeight = MB_ButtonHeight;
		if(EnterResult == MR_Yes)
		{
			DefaultButton = YesButton;
			YesButton.SetText(YesText @ DefaultKeyText);			
		}
		if (P.Result == MR_Yes)
			YesButton.SetText(YesText @ CancelKeyText);
		YesButton.SetFont(F_Normal);
		break;
	case MB_YesNo:
		NoButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - (MB_ButtonWidth + MB_ButtonBorderW), WinHeight - MB_ButtonDistFromFrameBottom, MB_ButtonWidth, MB_ButtonHeight));
		NoButton.SetText(NoText);
		NoButton.WinHeight = MB_ButtonHeight;
		if(EnterResult == MR_No)
		{
			DefaultButton = NoButton;
			NoButton.SetText(NoText @ DefaultKeyText);
		}
		if (P.Result == MR_No)
			NoButton.SetText(NoText @ CancelKeyText);
		NoButton.SetFont(F_Normal);
		YesButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - (MB_ButtonWidth + MB_ButtonBorderW)*2, WinHeight - MB_ButtonDistFromFrameBottom, MB_ButtonWidth, MB_ButtonHeight));
		YesButton.SetText(YesText);
		YesButton.WinHeight = MB_ButtonHeight;
		if(EnterResult == MR_Yes)
		{
			DefaultButton = YesButton;
			YesButton.SetText(YesText @ DefaultKeyText);			
		}
		if (P.Result == MR_Yes)
			YesButton.SetText(YesText @ CancelKeyText);
		YesButton.SetFont(F_Normal);
		break;
	case MB_OKCancel:
		CancelButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - (MB_ButtonWidth + MB_ButtonBorderW), WinHeight - MB_ButtonDistFromFrameBottom, MB_ButtonWidth, MB_ButtonHeight));
		CancelButton.SetText(CancelText);
		CancelButton.WinHeight = MB_ButtonHeight;
		if(EnterResult == MR_Cancel)
		{
			DefaultButton = CancelButton;
			CancelButton.SetText(CancelText @ DefaultKeyText);
		}
		if (P.Result == MR_Cancel)
			CancelButton.SetText(CancelText @ CancelKeyText);
		CancelButton.SetFont(F_Normal);
		OKButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - (MB_ButtonWidth + MB_ButtonBorderW)*2, WinHeight - MB_ButtonDistFromFrameBottom, MB_ButtonWidth, MB_ButtonHeight));
		OKButton.SetText(OKText);
		OKButton.WinHeight = MB_ButtonHeight;
		if(EnterResult == MR_OK)
		{
			DefaultButton = OKButton;
			OKButton.SetText(OKText @ DefaultKeyText);
		}
		if (P.Result == MR_OK)
			OKButton.SetText(OKText @ CancelKeyText);
		OKButton.SetFont(F_Normal);
		break;
	case MB_OK:
		OKButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - (MB_ButtonWidth + MB_ButtonBorderW), WinHeight - MB_ButtonDistFromFrameBottom, MB_ButtonWidth, MB_ButtonHeight));
		OKButton.SetText(OKText);
		OKButton.WinHeight = MB_ButtonHeight;
		if(EnterResult == MR_OK)
		{
			DefaultButton = OKButton;
			OKButton.SetText(OKText @ DefaultKeyText);
		}
		if (P.Result == MR_OK)
			OKButton.SetText(OKText @ CancelKeyText);
		OKButton.SetFont(F_Normal);
		break;
	}

	if (DefaultButton != None)
		DefaultButton.SetFont(F_Bold);

	if (Root.bUsingJoystick)
	{
		//MouseX = Root.RealWidth / 2;
		//MouseY = Root.RealHeight / 2;
		
		// Find a button to put the cursor on
		if (DefaultButton != None)
			UseButton = DefaultButton;
		else if (OKButton != None)
			UseButton = OKButton;
		else if (YesButton != None)
			UseButton = YesButton;
		else if (CancelButton != None)
			UseButton = CancelButton;
		else if (NoButton != None)
			UseButton = NoButton;
		else
			warn("NO BUTTON FOUND TO PUT MOUSE CURSOR ON!!!");
			
		if (UseButton != None)
		{
			//!! FIXME can't seem to pull the actual window coordinates from here
			MouseX = Root.RealWidth / 2;
			MouseY = Root.RealHeight / 2;
			IntMouseX = MouseX;
			IntMouseY = MouseY;
			Root.MoveMouse(MouseX, MouseY);
			if (PlatformIsWindows())	// not needed in SDL
				GetPlayerOwner().ConsoleCommand("SETMOUSE"@IntMouseX@IntMouseY);
			//log("MODAL moved root mouse to"@MouseX@MouseY);
		}
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	local UWindowMessageBox P;

	P = UWindowMessageBox(ParentWindow);

	if(E == DE_Click)
	{
		switch(C)
		{
		case YesButton:
			P.Result = MR_Yes;
			P.Close();			
			break;
		case NoButton:
			P.Result = MR_No;
			P.Close();
			break;
		case OKButton:
			P.Result = MR_OK;
			P.Close();
			break;
		case CancelButton:
			P.Result = MR_Cancel;
			P.Close();
			break;
		}
	}
}

defaultproperties
{
	DefaultKeyText="%KEY_ConfirmButton%"
	CancelKeyText="%KEY_BackButton%"
	YesText="Yes"
	NoText="No"
	OKText="OK"
	CancelText="Cancel"
	MB_ButtonWidth = 82//68	// was 48
	MB_ButtonHeight = 34//28
	MB_ButtonBorderW = 6
	MB_ButtonBorderH = 6
	MB_BorderW = 16
	MB_BorderH = 20
	}