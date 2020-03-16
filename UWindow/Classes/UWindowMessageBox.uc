class UWindowMessageBox extends UWindowFramedWindow;

var MessageBoxResult Result;
var float TimeOutTime;
var int TimeOut;
var bool bSetupSize;
var int FrameCount;
var float MessageBoxWidth;
var UWindowSmallButton TimerButton;
var string TimerButtonOrigText;
var bool bTimedOut;

function SetupMessageBox(string Title, string Message, MessageBoxButtons Buttons, MessageBoxResult InESCResult, optional MessageBoxResult InEnterResult, optional int InTimeOut)
{
	WindowTitle = Title;
	Result = InESCResult;
	UWindowMessageBoxCW(ClientArea).SetupMessageBoxClient(Message, Buttons, InEnterResult);

	// RWS CHANGE: If a timeout is specified, add the countdown to the end of the ESC button's text
	if (InTimeOut > 0)
	{
		switch(InESCResult)
		{
		case MR_None:
			break;
		case MR_Yes:
			TimerButton = UWindowMessageBoxCW(ClientArea).YesButton;
			break;
		case MR_No:
			TimerButton = UWindowMessageBoxCW(ClientArea).NoButton;
			break;
		case MR_OK:
			TimerButton = UWindowMessageBoxCW(ClientArea).OKButton;
			break;
		case MR_Cancel:
			TimerButton = UWindowMessageBoxCW(ClientArea).CancelButton;
			break;
		}
		if (TimerButton != None)
		{
			TimerButtonOrigText = TimerButton.Text;
			SetTimerButtonText(InTimeOut);
		}
	}

	TimeOutTime = 0;
	TimeOut = InTimeOut;
	FrameCount = 0;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local Region R;
	local float TW, TH;

	if(!bSetupSize)
	{
		// Get size of window title so we can make sure window is at least wide enough for the title
		LookAndFeel.FW_SetupWindowTitle(Self, C);
		TextSize(C, WindowTitle, TW, TH);

		MessageBoxWidth = Max(MessageBoxWidth, TW + 22 + 15);	// If you can't beat 'em, join 'em, hence their 22 and my own extra amount
		MessageBoxWidth = Min(MessageBoxWidth, C.ClipX);	// Don't exceed canvas width

		SetSize(MessageBoxWidth, WinHeight);		
		R = LookAndFeel.FW_GetClientArea(Self);
		SetSize(MessageBoxWidth, (WinHeight - R.H) + UWindowMessageBoxCW(ClientArea).GetHeight(C));
		WinLeft = int((Root.WinWidth - WinWidth) / 2);
		WinTop = int((Root.WinHeight - WinHeight) / 2);
		bSetupSize = True;
	}

	Super.BeforePaint(C, X, Y);
}

function AfterPaint(Canvas C, float X, float Y)
{
	Super.AfterPaint(C, X, Y);

	if(TimeOut != 0)
	{
		FrameCount++;
		
		if(FrameCount >= 5)
		{
			TimeOutTime = GetEntryLevel().TimeSeconds + TimeOut;
			TimeOut = 0;
		}
	}

	if(TimeOutTime != 0)
	{
		if (GetEntryLevel().TimeSeconds > TimeOutTime)
		{
			TimeOutTime = 0;
			bTimedOut = true;	// RWS CHANGE: Delayed closing of window
		}
		else
		{
			// RWS CHANGE: Update countdown timer in button text
			if (TimerButton != None)
				SetTimerButtonText(int(TimeOutTime - GetEntryLevel().TimeSeconds) + 1);
		}
	}
}

function Tick(float Delta)
{
	// RWS CHANGE: Moved the close out of the render and into here to avoid
	// problems when we try to issue console commands that change the video
	// mode, which crashes when we do it during the render phase.
	if (bTimedOut)
		Close();
}

function SetTimerButtonText(int Time)
{
	TimerButton.SetText(TimerButtonOrigText @ "("$Time$")");
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	OwnerWindow.MessageBoxDone(Self, Result);
}

defaultproperties
{
	ClientClass=class'UWindowMessageBoxCW'
	MessageBoxWidth=250
}