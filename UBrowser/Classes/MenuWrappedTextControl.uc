///////////////////////////////////////////////////////////////////////////////
// MenuWrappedTextControl.uc
///////////////////////////////////////////////////////////////////////////////
class MenuWrappedTextControl extends UWindowDialogControl;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var bool	bHCenter;			// True to use horizontally centered text.
var Region	regCenter;			// Where to draw the text when centering.
var bool	bShadow;			// True to use shadowing.s
var float	fTextBorder;		// Text border for automatic text placement.
								// This should be at least as big as the 
								// shadow offset used.
var bool	bCenterVertical;	// True to center vertically
var float	TextOffsetY;

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
	Super.Resized();
	// Do we automaticlaly update the width?  What if the caller wants their
	// region size to stay regardless of resizing of the control?
	regCenter.X = fTextBorder;
	regCenter.Y = fTextBorder;
	regCenter.W = WinWidth	- fTextBorder * 2;
	regCenter.H = WinHeight - fTextBorder * 2;
}

///////////////////////////////////////////////////////////////////////////////
// Draw the text with the specified offsets.
///////////////////////////////////////////////////////////////////////////////
function int DrawText(Canvas C, float OffsetX, float OffsetY, optional bool bNoDraw)
{
	local region reg;
	local int Lines;

	if (!bHCenter)
		Lines = WrapClipText(C, 0 + OffsetX, 0 + OffsetY, Text, , , , bNoDraw);
	else
	{
		reg.X = regCenter.X + OffsetX;
		reg.Y = regCenter.Y + OffsetY;
		reg.W = regCenter.W;
		reg.H = regCenter.H;
		Lines = WrapCenterClipText(C, reg, Text, , bNoDraw);
	}

	return Lines;
}

///////////////////////////////////////////////////////////////////////////////
// Calculate size before paint
///////////////////////////////////////////////////////////////////////////////
function BeforePaint(Canvas C, float X, float Y )
{
	local float XL, YL;
	local int Lines;

	Super.BeforePaint(C, X, Y);

	if(bCenterVertical && (Text != ""))
	{
		C.Font = Root.Fonts[Font];
		C.StrLen("Try", XL, YL);
		Lines = DrawText(C, 0, 0, true);
		TextOffsetY = (WinHeight - (Lines * YL)) / 2;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Paint this thing.
///////////////////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y )
{
	local Color OldColor;

	Super.Paint(C, X, Y);

	if(Text != "")
	{
		C.Font = Root.Fonts[Font];

		if (bShadow)
		{
			C.SetDrawColor(0,0,0,255);
			DrawText(C, 1, TextOffsetY + 1);
		}
		
		C.DrawColor = TextColor;
		DrawText(C, 0, TextOffsetY + 0);

		C.DrawColor = OldColor;
	}
}

defaultproperties
{
	fTextBorder = 2;
	bShadow		= true;
}
