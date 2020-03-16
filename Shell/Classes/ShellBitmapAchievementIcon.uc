// Achievement icon class.
// Needs to be subclassed so we can tell our menu if the mouse is hovering over us.
class ShellBitmapAchievementIcon extends UWindowBitmap;

var MenuAchievementList MyMenu;
var string HelpText;

function MouseEnter()
{
	Super.MouseEnter();
	MyMenu.IconMouseEnter(Self);
}

function MouseLeave()
{
	Super.MouseLeave();
	MyMenu.IconMouseLeave(Self);
}
