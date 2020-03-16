class DLCMainWindow extends UMenuStartGameWindow;

function SaveConfigs()
{
	ClientArea.SaveConfig();
//	GetPlayerOwner().SaveConfig();
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
		SetSize(700, 600);
	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
	WindowTitle="POSTAL 2 DLC Microtransaction $tore"
	ClientClass=class'DLCMainCW'
}
