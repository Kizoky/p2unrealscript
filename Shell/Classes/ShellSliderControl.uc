class ShellSliderControl extends UWindowHSliderControl;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var bool	bActive;				// Whether item is active

///////////////////////////////////////////////////////////////////////////////
// Mouse entered our area...say...
///////////////////////////////////////////////////////////////////////////////
function MouseEnter()
	{
	Super(UWindowDialogControl).MouseEnter();
	if (bActive)
		LookAndFeel.Control_MouseEnter(self);
	}

///////////////////////////////////////////////////////////////////////////////
// Mouse left our area.
///////////////////////////////////////////////////////////////////////////////
function MouseLeave()
	{
	Super(UWindowDialogControl).MouseLeave();
	if (bActive)
		LookAndFeel.Control_MouseLeave(self);
	}

function LMouseUp(float X, float Y)
{
	if (bActive)
		Super.LMouseUp(X, Y);
}

function LMouseDown(float X, float Y)
{
	if (bActive)
		Super.LMouseDown(X, Y);
}

function MouseMove(float X, float Y)
{
	if (bActive)
		Super.MouseMove(X, Y);
}

function KeyDown(int Key, float X, float Y)
{
	if (bActive)
		Super.KeyDown(Key, X, Y);
}

defaultproperties
{
	bActive=true
}