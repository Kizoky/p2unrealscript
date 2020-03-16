class UTBrowserMainWindow extends UBrowserMainWindow;

function BeginPlay()
{
	Super.BeginPlay();

	ClientClass = class'UTBrowserMainClientWindow';
}

defaultproperties
{
	WindowTitleString="Join Multiplayer Game"
}