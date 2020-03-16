class UMenuTeamBannerWindow extends UWindowDialogClientWindow;

var Texture Banner;

function SetBanner(Texture newBanner)
{
	Banner = newBanner;
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	Banner = None;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y, W, H;

	//DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	if(Banner != None)
	{		
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.DrawColor.A = 255;

		W = WinWidth;
		H = WinHeight;

		DrawStretchedTexture(C, 0, 0, W, H, Banner);
	}
}
