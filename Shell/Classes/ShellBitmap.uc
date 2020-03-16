class ShellBitmap extends UWindowBitmap;

var MenuImage MyMenu;

function LMouseDown(float X, float Y)
{
	super.LMouseDown(X, Y);

	if (MyMenu != None)
		MyMenu.ImageClick(X, Y);
}

