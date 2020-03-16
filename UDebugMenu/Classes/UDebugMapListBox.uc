class UDebugMapListBox extends UWindowListBox;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if(UDebugMapList(Item).bSelected)
	{
		// make it RED--ASSHOLES (it was blue.. i hardcoded it red!! mahahhahahaaa...)
		C.SetDrawColor(128,0,0);
		DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture');
		C.SetDrawColor(255,255,255);
	}
	else
	{
		C.SetDrawColor(0,0,0);
	}

	C.Font = Root.Fonts[F_Normal];
	ClipText(C, X, Y, UDebugMapList(Item).DisplayName);
}



defaultproperties
{
	ListClass=class'UDebugMapList'
	ItemHeight=13
}
