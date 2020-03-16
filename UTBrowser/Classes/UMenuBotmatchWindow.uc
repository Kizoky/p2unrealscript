class UMenuBotmatchWindow extends UMenuFramedWindow;

function Created() 
{
	bStatusBar = False;
	bSizable = False;

	Super.Created();

	SetSizePos();
}

function Close(optional bool bByParent) 
{
	if (ClientArea != None && ClientArea.ModalWindow != None)
	{
		ClientArea.ModalWindow.Close();
		ClientArea.ModalWindow = None;
	}
	else if (UMenuBotmatchClientWindow(ClientArea) != None && UMenuBotmatchClientWindow(ClientArea).MessageBoxWindow != None)
	{
		UMenuBotmatchClientWindow(ClientArea).MessageBoxWindow.Close();
		UMenuBotmatchClientWindow(ClientArea).MessageBoxWindow = None;
	}
	else
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
//	if(Root.WinHeight < 290)
//		SetSize(Min(Root.WinWidth-10, 520) , 220);
//	else
//		SetSize(Min(Root.WinWidth-10, 520), 270);
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

function SaveConfigs()
{
	ClientArea.SaveConfig();
//	GetPlayerOwner().SaveConfig();
}

// Prevent Moving this Window
function MouseMove(float X, float Y)
{
	bMoving = false;
	Super.MouseMove(X, Y);
}

defaultproperties
{
	ClientClass=class'UMenuBotmatchClientWindow'
	WindowTitle="Botmatch"
}