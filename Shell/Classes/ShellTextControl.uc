///////////////////////////////////////////////////////////////////////////////
// ShellTextControl.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// A simple text control.
//
//	History:
//	02/10/03 JMI	Changed to simply faking the subcontrol and removed the
//					actual subcontrol which was more of a pain than it was
//					worth.
// 
//	02/10/03 JMI	Started from ShellMenuWrappedTextControl.
//
///////////////////////////////////////////////////////////////////////////////
// A basic class to display word wrapped text.
//
///////////////////////////////////////////////////////////////////////////////
class ShellTextControl extends UWindowDialogControl;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var float				ValueX;
var float				ValueY;
var TextAlign			ValueAlign;
var string				ValueText;
var float				TextItemWidth;

///////////////////////////////////////////////////////////////////////////////
// Functions.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Mouse entered our area...say...
///////////////////////////////////////////////////////////////////////////////
function MouseEnter()
	{
	Super.MouseEnter();
	if (bActive)
		LookAndFeel.Control_MouseEnter(self);
	}

///////////////////////////////////////////////////////////////////////////////
// Mouse left our area.
///////////////////////////////////////////////////////////////////////////////
function MouseLeave()
	{
	Super.MouseLeave();
	if (bActive)
		LookAndFeel.Control_MouseLeave(self);
	}

///////////////////////////////////////////////////////////////////////////////
// Mouse released in our area.
///////////////////////////////////////////////////////////////////////////////
function Click(float X, float Y)
	{
	if (bActive)
		{
		LookAndFeel.Control_Click(self);
		Notify(DE_Click);
		}

	Super.Click(X,Y);
	}

///////////////////////////////////////////////////////////////////////////////
// Mouse released in our area.
///////////////////////////////////////////////////////////////////////////////
function RClick(float X, float Y)
	{
	if (bActive)
		{
		LookAndFeel.Control_Click(self);
		Notify(DE_RClick);
		}

	Super.RClick(X,Y);
	}

///////////////////////////////////////////////////////////////////////////////
// Creation notice.
///////////////////////////////////////////////////////////////////////////////
function Created()
{
	super.Created();

	TextItemWidth = WinWidth / 2;
}

///////////////////////////////////////////////////////////////////////////////
// Get the value from the text item.
///////////////////////////////////////////////////////////////////////////////
function string GetValue()
{
	return ValueText;
}

///////////////////////////////////////////////////////////////////////////////
// Set the value for the text item.
///////////////////////////////////////////////////////////////////////////////
function SetValue(string NewValue)
{
	ValueText = NewValue;
}

///////////////////////////////////////////////////////////////////////////////
// Size this thing.
///////////////////////////////////////////////////////////////////////////////
function BeforePaint(Canvas C, float X, float Y)
{
	local ShellLookAndFeel laf;
	Super.BeforePaint(C, X, Y);
	
	laf = ShellLookAndFeel(LookAndFeel);
	if (laf != none)
		laf.TextItem_SetupSizes(Self, C);
}

///////////////////////////////////////////////////////////////////////////////
// Paint this thing.
///////////////////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y )
{
	local ShellLookAndFeel laf;
	Super.BeforePaint(C, X, Y);
	
	laf = ShellLookAndFeel(LookAndFeel);
	if (laf != none)
		laf.TextItem_Draw(Self, C);
}

defaultproperties
{
}
