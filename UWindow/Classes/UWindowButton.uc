//=============================================================================
// UWindowButton - A button
//=============================================================================
class UWindowButton extends UWindowDialogControl;

var bool		bDisabled;
var bool		bStretched;
var texture		UpTexture, DownTexture, DisabledTexture, OverTexture;
var Region		UpRegion,  DownRegion,  DisabledRegion,  OverRegion;
var bool		bUseRegion;
var float		RegionScale;
var string		ToolTipString;
var float		ImageX, ImageY;

function Created()
{
	Super.Created();

	ImageX = 0;
	ImageY = 0;
	TextX = 0;
	TextY = 0;
	RegionScale = 1;
}

function BeforePaint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[Font];
}

function Paint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[Font];

	if(bDisabled) {
		if(DisabledTexture != None)
		{
			if(bUseRegion)
				DrawRegion( C, ImageX, ImageY, DisabledRegion, DisabledTexture );
			else if(bStretched)
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture );
			else
				DrawClippedTexture( C, ImageX, ImageY, DisabledTexture);
		}
	} else {
		if(bMouseDown)
		{
			if(DownTexture != None)
			{
				if(bUseRegion)
					DrawRegion( C, ImageX, ImageY, DownRegion, DownTexture );
				else if(bStretched)
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DownTexture );
				else
					DrawClippedTexture( C, ImageX, ImageY, DownTexture);
			}
		} else {
			if(MouseIsOver()) {
				if(OverTexture != None)
				{
					if(bUseRegion)
						DrawRegion( C, ImageX, ImageY, OverRegion, OverTexture );
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, OverTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, OverTexture);
				}
			} else {
				if(UpTexture != None)
				{
					if(bUseRegion)
						DrawRegion( C, ImageX, ImageY, UpRegion, UpTexture );
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, UpTexture);
				}
			}
		}
	}

	if(Text != "")
	{
// RWS CHANGE: Let the LookAndFeel draw the text
		LookAndFeel.Control_DrawText(self, C);
//		C.DrawColor=TextColor;
//		ClipText(C, TextX, TextY, Text, True);
//		C.SetDrawColor(255,255,255);
	}
}

// RWS CHANGE: Added ability to support bUseRegion combined with bStretched
function DrawRegion(Canvas C, float X, float Y, Region Reg, Texture Tex)
{
	if (bStretched)
		DrawStretchedTextureSegment( C, X, Y, WinWidth, WinHeight, Reg.X, Reg.Y, Reg.W, Reg.H, Tex);
	else
		DrawStretchedTextureSegment( C, X, Y, Reg.W * RegionScale, Reg.H * RegionScale, Reg.X, Reg.Y, Reg.W, Reg.H, Tex);
}

function MouseLeave()
{
	Super.MouseLeave();
	if(ToolTipString != "") ToolTip("");
}

simulated function MouseEnter()
{
	Super.MouseEnter();
	if(ToolTipString != "") ToolTip(ToolTipString);
	if (!bDisabled)
		LookAndFeel.PlayOverSound(self);	// RWS CHANGE: Let look and feel handle this
}

simulated function Click(float X, float Y) 
{
	Notify(DE_Click);
	if (!bDisabled)
		LookAndFeel.PlayDownSound(self);	// RWS CHANGE: Let look and feel handle this
}

function DoubleClick(float X, float Y) 
{
	Notify(DE_DoubleClick);
}

function RClick(float X, float Y) 
{
	Notify(DE_RClick);
}

function MClick(float X, float Y) 
{
	Notify(DE_MClick);
}

function KeyDown(int Key, float X, float Y)
{
	local PlayerController P;

	P = Root.GetPlayerOwner();

	switch (Key)
	{
	case P.Player.Console.EInputKey.IK_Space:
		LMouseDown(X, Y);
		LMouseUp(X, Y);
		break;
	default:
		Super.KeyDown(Key, X, Y);
		break;
	}
}

defaultproperties
{
	bIgnoreLDoubleClick=True
	bIgnoreMDoubleClick=True
	bIgnoreRDoubleClick=True
}