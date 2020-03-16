//=============================================================================
// UBrowserBannerAd
//=============================================================================
class UBrowserBannerAd extends UWindowWindow;

#exec TEXTURE IMPORT NAME=BannerAd FILE=Textures\logo3.pcx GROUP="Icons" FLAGS=2 MIPS=OFF

var string URL;

function Created()
{
	// RWS CHANGE: Changed to our site
	URL = "http://www.postal2.com";
	Cursor = Root.HandCursor;
}

function Paint(Canvas C, float X, float Y)
{
	DrawClippedTexture(C, 0, 0, Texture'BannerAd');
}

function Click(float X, float Y)
{
	// RWS CHANGE: Updated for 927
//	Root.Console.ViewPort.Actor.ConsoleCommand("start "$URL);
	GetPlayerOwner().ConsoleCommand("start "$URL);
}

function MouseLeave()
{
	Super.MouseLeave();
	ToolTip("");
}

function MouseEnter()
{
	Super.MouseEnter();
	ToolTip(URL);
}

