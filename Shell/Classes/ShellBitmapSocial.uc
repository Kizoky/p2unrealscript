class ShellBitmapSocial extends UWindowBitmap;

var MenuMain MyMenu;

function LMouseDown(float X, float Y)
{
	super.LMouseDown(X, Y);

	if (MyMenu != None)
		MyMenu.SocialIconNotify(Self, DE_Click);
}

function MouseEnter()
{
	Super.MouseEnter();
	if (MyMenu != None)
		MyMenu.SocialIconNotify(Self, DE_MouseEnter);
}

function MouseLeave()
{
	Super.MouseEnter();
	if (MyMenu != None)
		MyMenu.SocialIconNotify(Self, DE_MouseLeave);
}
