///////////////////////////////////////////////////////////////////////////////
// ShellWrappedTextControl.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The Main menu.
//
//	History:
//	01/30/03 JMI	Added options to utilize new WrapCenterClipText function.
//					Added optional shadow.
//
//	01/19/03 JMI	Started from MenuMessage to use for displaying text in a
//					limited area.
//
///////////////////////////////////////////////////////////////////////////////
// A basic class to display word wrapped text.
//
///////////////////////////////////////////////////////////////////////////////
class ShellWrappedTextControl extends UWindowDialogControl;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var bool	bHCenter;			// True to use horizontally centered text.
var Region	regCenter;			// Where to draw the text when centering.
var bool	bShadow;			// True to use shadowing.s
var float	fTextBorder;		// Text border for automatic text placement.
								// This should be at least as big as the 
								// shadow offset used.

///////////////////////////////////////////////////////////////////////////////
// Functions.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Creation notice.
///////////////////////////////////////////////////////////////////////////////
function Created()
{
	super.Created();

	TextX = fTextBorder;
	TextY = fTextBorder;

	regCenter.X = fTextBorder;
	regCenter.Y = fTextBorder;
	regCenter.W = WinWidth	- fTextBorder * 2;
	regCenter.H = WinHeight - fTextBorder * 2;
}

///////////////////////////////////////////////////////////////////////////////
// Resize just occurred.
///////////////////////////////////////////////////////////////////////////////
function Resized()
{
	// Do we automaticlaly update the width?  What if the caller wants their
	// region size to stay regardless of resizing of the control?
	regCenter.W = WinWidth	- fTextBorder * 2;
	regCenter.H = WinHeight - fTextBorder * 2;
}

///////////////////////////////////////////////////////////////////////////////
// Draw the text with the specified offsets.
///////////////////////////////////////////////////////////////////////////////
function DrawText(Canvas C, float fOffX, float fOffY)
{
	local region reg;
	if (bHCenter == false)
		WrapClipText(C, TextX + fOffX, TextY + fOffY, Text);
	else
	{
		reg.X = regCenter.X + fOffX;
		reg.Y = regCenter.Y + fOffY;
		reg.W = regCenter.W;
		reg.H = regCenter.H;

		WrapCenterClipText(C, reg, Text);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Paint this thing.
///////////////////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y )
{
	local ShellLookAndFeel laf;
	local Color OldColor;

	OldColor = C.DrawColor;

	C.Font = Root.Fonts[Font];

	if (bShadow)
	{
		laf = ShellLookAndFeel(LookAndFeel);
		if (laf != none)
		{
			C.DrawColor = laf.ShadowTextColor;
			C.DrawColor.A = OldColor.A;
			DrawText(C, laf.ShadowOffsetX[Font], laf.ShadowOffsetY[Font] );
		}
	}
	
	C.DrawColor = TextColor;
	C.DrawColor.A = OldColor.A;

	DrawText(C, 0, 0);

	C.DrawColor = OldColor;
}

defaultproperties
{
	fTextBorder = 2;
	bShadow		= true;
}
