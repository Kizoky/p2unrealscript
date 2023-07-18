class xWeaponListBox extends UWindowListBox;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if(xWeaponList(Item).bSelected)
	{
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 128;
		DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture');
		C.DrawColor.r = 255;
		C.DrawColor.g = 255;
		C.DrawColor.b = 255;
	}
	else
	{
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 0;
	}

	C.Font = Root.Fonts[F_SmallBold];

	ClipText(C, X+2, Y, xWeaponList(Item).WeaponName);
}

defaultproperties
{
	ListClass=class'xWeaponList'
	ItemHeight=13
}
