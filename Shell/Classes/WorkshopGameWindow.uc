class WorkshopGameWindow extends UWindowFramedWindow;

function Created() 
{
	bStatusBar = False;
	bSizable = False;

	Super.Created();

	SetSizePos();
}

function Close(optional bool bByParent) 
{
	if(Root != None)
	{
		Root.GoBack();
		ShellRootWindow(Root).HideMenu();
	}

	Super.Close(bByParent);
}

function WindowShown()
{
	Super.WindowShown();
	if(WinLeft < 0 || WinTop < 16 || WinLeft + WinWidth > Root.WinWidth || WinTop + WinHeight > Root.WinHeight)
		SetSizePos();
}

function SetSizePos()
{
	if(Root.WinHeight < 599)
		SetSize(500, 468);
	else
		SetSize(630, 580);
	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

// Prevent Moving this Window
function MouseMove(float X, float Y)
{
	bMoving = false;
	Super.MouseMove(X, Y);
}

defaultproperties
{
	WindowTitle="Workshop Game"
	ClientClass=class'WorkshopGameCW'
}
