class UBrowserScreenshotCW extends UWindowClientWindow;

var Texture Screenshot;
var string MapName;
var string MapTitle;
var string MapAuthor;

var localized string AuthorByText;

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y, W, H;
	local int i;
	local string M;
	local UBrowserServerList L;
	local Object LevSumObject;
	local LevelSummary LevSum;

	L = UBrowserInfoClientWindow(GetParent(class'UBrowserInfoClientWindow')).Server;
	
	if( L != None )
	{
		M = L.MapName;
		if( M != MapName )
		{
			MapName = M;
			if( MapName == "" )
			{
				ScreenShot = None;
				MapTitle = "";
				MapAuthor = "";
			}
			else
			{
				// RWS Change:  .UNR -> .FUK
				i = InStr(Caps(MapName), ".FUK");
				if(i != -1)
					MapName = Left(MapName, i);

				//Screenshot = Texture(DynamicLoadObject(MapName$".Screenshot", class'Texture'));
				LevSumObject = DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary', true);
				if(LevSumObject != None && LevelSummary(LevSumObject) != None)
				{
					LevSum = LevelSummary(LevSumObject);

					MapTitle = LevSum.Title;
					MapAuthor = AuthorByText @ LevSum.Author;
					Screenshot = Texture(LevSum.Screenshot);
				}
				else
				{
					ScreenShot = None;
					MapTitle = "";
					MapAuthor = "";
				}
			}
		}
	}
	else
	{
		ScreenShot = None;
		MapName = "";
		MapTitle = "";
		MapAuthor = "";
	}

	Super.Paint(C, X, Y);
//	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');

	if(Screenshot != None)
	{
		W = Min(WinWidth, Screenshot.USize);
		H = Min(WinHeight, Screenshot.VSize);
		
		if(W > H)
			W = H;
		if(H > W)
			H = W;

		X = (WinWidth - W) / 2;
		Y = (WinHeight - H) / 2;
			
		DrawStretchedTexture(C, X, Y, W, H, Screenshot);
		
		C.Font = Root.Fonts[F_Normal];

		if(MapAuthor != "")
		{
			TextSize(C, MapAuthor, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*2;
			ClipText(C, X, Y, MapAuthor);
		}
		
		if(MapTitle != "")
		{		
			TextSize(C, MapTitle, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*3;
			ClipText(C, X, Y, MapTitle);
		}
	}	
}

defaultproperties
{
	AuthorByText="by"
}