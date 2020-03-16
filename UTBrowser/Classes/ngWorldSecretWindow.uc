class ngWorldSecretWindow extends UMenuFramedWindow;

function BeginPlay() 
{
	Super.BeginPlay();

	ClientClass = class'ngWorldSecretClient';
}

function Created() 
{
	bStatusBar = False;
	bSizable = False;

	Super.Created();

	SetSize(350, 300);

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
	WindowTitle="Game Stats Password";
}