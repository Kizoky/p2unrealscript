//=============================================================================
// UBrowserGSpyBanner
//=============================================================================
class UBrowserGSpyBanner extends UWindowWindow;

var Texture GameSpyBanner;
var float BannerWidth;
var float BannerHeight;

function Created()
{
	Super.Created();
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float Scale;

	Super.BeforePaint(C, X, Y);

	// Adjust banner size
	BannerHeight = WinHeight * 0.90;
	Scale = BannerHeight / GameSpyBanner.VSize;
	BannerWidth = GameSpyBanner.USize * Scale;
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	DrawStretchedTexture(C, (WinWidth-BannerWidth)/2, (WinHeight-BannerHeight)/2, BannerWidth, BannerHeight, GameSpyBanner);
}

defaultproperties
{
	GameSpyBanner=Texture'Mp_Misc.PoweredByGameSpy'
}
