///////////////////////////////////////////////////////////////////////////////
// ShellLookAndFeel.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Creates the look and feel we want.
//
//	History:
//		01/19/03 JMI	Changed Combo_Draw to use Control_DrawText for combo
//						control's -label- text.
//
//		08/31/02 MJR	Properly renamed textures to use the ones in P2LookAndFeel.
//						Moved code here to draw client area using skin texture.
//						Moved text colors here.
//
//		05/13/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class ShellLookAndFeel extends UWindowLookAndFeel;

#exec OBJ LOAD FILE=..\Textures\P2LookAndFeel.utx

var() Color		NormalTextColor;	// Normal text
var() Color		HighlightTextColor;	// Highlighted text
var() Color		ShadowTextColor;	// Shadow behind text
var() Color		SaveTextColor;		// xPatch
var() Color     NormalBackgroundColor;
var() Color     HighlightBackgroundColor;

// Arrays correspond to the Font[10] array in UWindowRootWindow
var() float		ShadowOffsetX[10];	// pixel offset
var() float		ShadowOffsetY[10];	// pixel offset
var() float		HoverOffsetX[10];	// pixel offset
var() float		HoverOffsetY[10];	// pixel offset

var() Sound		MouseEnterSound;
var() float		MouseEnterVolume;
var int			MouseEnterIndex;
var() Sound		MouseLeaveSound;
var() float		MouseLeaveVolume;
var() Sound		ClickSound;
var() float		ClickVolume;
var() Sound		BigSound;
var() float		BigVolume;
var() Sound		SmallSound;
var() float		SmallVolume;
var int			SmallSoundIndex;
var int			NextSoundSlot;
var() Sound		OverSound;
var() float		OverVolume;
var() Sound		DownSound;
var() float		DownVolume;

var() Region	SBUpUp;
var() Region	SBUpDown;
var() Region	SBUpDisabled;

var() Region	SBDownUp;
var() Region	SBDownDown;
var() Region	SBDownDisabled;

var() Region	SBLeftUp;
var() Region	SBLeftDown;
var() Region	SBLeftDisabled;

var() Region	SBRightUp;
var() Region	SBRightDown;
var() Region	SBRightDisabled;

var() Region	SBBackground;

var() Region	FrameSBL;
var() Region	FrameSB;
var() Region	FrameSBR;

// 02/04/03 JMI Added separate regions for locations in textures.  The reason I was having so many problems
//				changing these ridiculously hard coded values was b/c they were mapped directly to the texture
//				and the screen positions.  Separated them by adding additional values.
var() Region	TexFrameTL;
var() Region	TexFrameT;
var() Region	TexFrameTR;
           
var() Region	TexFrameL;
var() Region	TexFrameR;
           
var() Region	TexFrameBL;
var() Region	TexFrameB;
var() Region	TexFrameBR;
           
var() Region	TexFrameSBL;
var() Region	TexFrameSB;
var() Region	TexFrameSBR;

var() Region	CloseBoxUp;
var() Region	CloseBoxDown;
var() int		CloseBoxOffsetX;
var() int		CloseBoxOffsetY;

const SIZEBORDER = 3;
const BRSIZEBORDER = 15;

var float LastSoundTime;


function Control_MouseEnter(UWindowDialogControl ctl)
	{
	// xPatch: if it has custom color, keep it.
	if(ctl.TextColor != NormalTextColor)
		SaveTextColor = ctl.TextColor;
	else 
		SaveTextColor = NormalTextColor;

	// and check if it has custom highlight color to use
	if(ctl.HighlightTextColor != ctl.default.HighlightTextColor)
		ctl.SetTextColor(ctl.HighlightTextColor);
	else // xPatch: End
		ctl.SetTextColor(HighlightTextColor);
		
	PlayEnterSound(ctl);
	}

function Control_MouseLeave(UWindowDialogControl ctl)
	{
	// xPatch: Restore previous color.
	//ctl.SetTextColor(NormalTextColor);
	ctl.SetTextColor(SaveTextColor);
	if (MouseLeaveSound != None)
		PlayThisLocalSound(ctl, MouseLeaveSound, MouseLeaveVolume);
	}

function Control_Click(UWindowDialogControl ctl)
	{
	if (ClickSound != None)
		PlayThisLocalSound(ctl, ClickSound, ClickVolume);
	}

function Control_DrawText(UWindowDialogControl ctl, Canvas C)
	{
	local float HoverX, HoverY;
	local color OldColor;

	if (ctl.Text != "")
		{
		// If item is being hovered then use proper height
		HoverX = 0;
		HoverY = 0;
		if (ctl.TextColor == HighlightTextColor)
			{
			HoverX = HoverOffsetX[ctl.Font];
			HoverY = HoverOffsetY[ctl.Font];
			}

		OldColor = C.DrawColor;

		// Draw outline of window for debugging
		//C.SetDrawColor(0, 0, 0, 255);
		//C.SetPos(0, 0);
		//C.DrawBox(C, ctl.WinWidth, ctl.WinHeight);
		//C.SetDrawColor(255, 255, 255, 255);

		// Draw shadow
		C.DrawColor = ShadowTextColor;
		C.DrawColor.A = OldColor.A;
		ctl.ClipText(C, ctl.TextX + ShadowOffsetX[ctl.Font], ctl.TextY + ShadowOffsetY[ctl.Font], ctl.Text);
		
		// Draw text (if item is being hovered, the text will appear to move "up")
		C.DrawColor = ctl.TextColor;
		C.DrawColor.A = OldColor.A;
		ctl.ClipText(C, ctl.TextX + HoverX, ctl.TextY + HoverY, ctl.Text);
		
		C.DrawColor = OldColor;
		}
	}

/* Framed Window Drawing Functions */
function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C)
{
	local Texture T;
	local Region rSrc, rDst, Temp;

	C.SetDrawColor(255,255,255);
	
	T = W.GetLookAndFeelTexture();

	rSrc = TexFrameTL;
	rDst = FrameTL;
	W.DrawStretchedTextureSegment( C, 0,      0,      rDst.W, rDst.H, 
									  rSrc.X, rSrc.Y, rSrc.W, rSrc.H, T );

	rSrc = TexFrameT;
	rDst = FrameT;
	W.DrawStretchedTextureSegment( C, FrameTL.W, 0, 
									W.WinWidth - FrameTL.W - FrameTR.W, rDst.H, 
									rSrc.X, rSrc.Y, rSrc.W, rSrc.H, T );

	rSrc = TexFrameTR;
	rDst = FrameTR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - rDst.W, 0, rDst.W, rDst.H, 
									  rSrc.X, rSrc.Y, rSrc.W, rSrc.H, T );
	

	if(W.bStatusBar)
		Temp = FrameSBL;
	else
		Temp = FrameBL;
	

	rSrc = TexFrameL;
	rDst = FrameL;
	W.DrawStretchedTextureSegment( C, 0, FrameTL.H, 
									rDst.W, W.WinHeight - FrameTL.H - Temp.H,
									rSrc.X, rSrc.Y, rSrc.W, rSrc.H, T );

	rSrc = TexFrameR;
	rDst = FrameR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - rDst.W, FrameTL.H,
									rDst.W, W.WinHeight - FrameTL.H - Temp.H,
									rSrc.X, rSrc.Y, rSrc.W, rSrc.H, T );
	if(W.bStatusBar)
	{
		rSrc = TexFrameSBL;
		rDst = FrameSBL;
	}
	else
	{
		rSrc = TexFrameBL;
		rDst = FrameBL;
	}

	W.DrawStretchedTextureSegment( C, 0, W.WinHeight - rDst.H, rDst.W, rDst.H, rSrc.X, rSrc.Y, rSrc.W, rSrc.H, T );

	if(W.bStatusBar)
	{
		rSrc = TexFrameSB;
		rDst = FrameSB;
		W.DrawStretchedTextureSegment(	C, FrameBL.W, W.WinHeight - rDst.H, 
										W.WinWidth - FrameSBL.W - FrameSBR.W, rDst.H, 
										rSrc.X, rSrc.Y, rSrc.W, rSrc.H, T );
	}
	else
	{
		rSrc = TexFrameB;
		rDst = FrameB;
		W.DrawStretchedTextureSegment( C, FrameBL.W, W.WinHeight - rDst.H, 
										W.WinWidth - FrameBL.W - FrameBR.W, rDst.H, 
										rSrc.X, rSrc.Y, rSrc.W, rSrc.H, T );
	}

	if(W.bStatusBar)
	{
		rSrc = TexFrameSBR;
		rDst = FrameSBR;
	}
	else
	{
		rSrc = TexFrameBR;
		rDst = FrameBR;
	}
	W.DrawStretchedTextureSegment(	C, W.WinWidth - rDst.W, W.WinHeight - rDst.H, rDst.W, rDst.H, 
									rSrc.X, rSrc.Y, rSrc.W, rSrc.H, T );

	FW_SetupWindowTitle(W, C);

	W.ClipTextWidth(C, FrameTitleX, FrameTitleY, 
					W.WindowTitle, W.WinWidth - 22);

	if(W.bStatusBar) 
	{
		C.Font = W.Root.Fonts[W.F_Small];
		C.SetDrawColor(0,0,0);

		W.ClipTextWidth(C, 6, W.WinHeight - 13, W.StatusBarText, W.WinWidth - 22);

		C.SetDrawColor(255,255,255);
	}
}

// RWS CHANGE: Broke out as separate func
function FW_SetupWindowTitle(UWindowFramedWindow W, Canvas C)
{
	if(W.ParentWindow.ActiveWindow == W)
	{
		C.DrawColor = FrameActiveTitleColor;
		C.Font = W.Root.Fonts[W.F_Bold];
	}
	else
	{
		C.DrawColor = FrameInactiveTitleColor;
		C.Font = W.Root.Fonts[W.F_Normal];
	}
}

function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C)
{
	local Texture T;
	local float CloseBoxSize;

	CloseBoxSize =  18;	// use this for width and height

	T = W.GetLookAndFeelTexture();

	W.CloseBox.WinLeft = W.WinWidth - CloseBoxOffsetX - CloseBoxSize;
	W.CloseBox.WinTop = CloseBoxOffsetY;

	W.CloseBox.SetSize(CloseBoxSize, CloseBoxSize);
	W.CloseBox.bUseRegion = True;

	W.CloseBox.UpTexture = T;
	W.CloseBox.DownTexture = T;
	W.CloseBox.OverTexture = T;
	W.CloseBox.DisabledTexture = T;

	W.CloseBox.UpRegion = CloseBoxUp;
	W.CloseBox.DownRegion = CloseBoxDown;
	W.CloseBox.OverRegion = CloseBoxUp;
	W.CloseBox.DisabledRegion = CloseBoxUp;
}

function Region FW_GetClientArea(UWindowFramedWindow W)
{
	local Region R;

	R.X = FrameL.W;
	R.Y	= FrameT.H;
	R.W = W.WinWidth - (FrameL.W + FrameR.W);
	if(W.bStatusBar) 
		R.H = W.WinHeight - (FrameT.H + FrameSB.H);
	else
		R.H = W.WinHeight - (FrameT.H + FrameB.H);

	return R;
}


function FrameHitTest FW_HitTest(UWindowFramedWindow W, float X, float Y)
{
	if((X >= 3) && (X <= W.WinWidth-3) && (Y >= 3) && (Y <= (FrameT.H - 2) ))	// 02/04/03 JMI Changed to take into account actual title bar height.
		return HT_TitleBar;
	if((X < BRSIZEBORDER && Y < SIZEBORDER) || (X < SIZEBORDER && Y < BRSIZEBORDER)) 
		return HT_NW;
	if((X > W.WinWidth - SIZEBORDER && Y < BRSIZEBORDER) || (X > W.WinWidth - BRSIZEBORDER && Y < SIZEBORDER))
		return HT_NE;
	if((X < BRSIZEBORDER && Y > W.WinHeight - SIZEBORDER)|| (X < SIZEBORDER && Y > W.WinHeight - BRSIZEBORDER)) 
		return HT_SW;
	if((X > W.WinWidth - BRSIZEBORDER) && (Y > W.WinHeight - BRSIZEBORDER))
		return HT_SE;
	if(Y < SIZEBORDER)
		return HT_N;
	if(Y > W.WinHeight - SIZEBORDER)
		return HT_S;
	if(X < SIZEBORDER)
		return HT_W;
	if(X > W.WinWidth - SIZEBORDER)	
		return HT_E;

	return HT_None;	
}

/* Client Area Drawing Functions */
function DrawClientArea(UWindowClientWindow W, Canvas C)
	{
	local Color OldColor;

	if (W.ClientAlpha != 0)
		{
		OldColor = C.DrawColor;
		C.Style = 5; //ERenderStyle.STY_Alpha;
		C.SetDrawColor(255, 255, 255, W.ClientAlpha);
		}

	if (!W.bNoClientBorder)
		{

		W.DrawClippedTexture(C, 0, 0, Texture'P2LookAndFeel.b_MenuTL');
		W.DrawStretchedTexture(C, 2, 0, W.WinWidth-4, 2, Texture'P2LookAndFeel.b_MenuT');
		W.DrawClippedTexture(C, W.WinWidth-2, 0, Texture'P2LookAndFeel.b_MenuTR');

		W.DrawClippedTexture(C, 0, W.WinHeight-2, Texture'P2LookAndFeel.b_MenuBL');
		W.DrawStretchedTexture(C, 2, W.WinHeight-2, W.WinWidth-4, 2, Texture'P2LookAndFeel.b_MenuB');
		W.DrawClippedTexture(C, W.WinWidth-2, W.WinHeight-2, Texture'P2LookAndFeel.b_MenuBR');

		W.DrawStretchedTexture(C, 0, 2, 2, W.WinHeight-4, Texture'P2LookAndFeel.b_MenuL');
		W.DrawStretchedTexture(C, W.WinWidth-2, 2, 2, W.WinHeight-4, Texture'P2LookAndFeel.b_MenuR');

		W.DrawStretchedTexture(C, 2, 2, W.WinWidth-4, W.WinHeight-4, Texture'P2LookAndFeel.b_ClientArea');
		}

	if (W.ClientBg != None)
		{
		if (W.bClientStretchBg)
			W.DrawStretchedTexture(C, 0, 0, W.WinWidth, W.WinHeight, W.ClientBg);
		else
			W.DrawClippedTexture(C, 0, 0, W.ClientBg);
		}

	if (W.ClientAlpha != 0)
		{
		C.Style = 1; //ERenderStyle.STY_Normal;
		C.DrawColor = OldColor;
		C.DrawColor.A = 255;
		}
	}


/* Combo Drawing Functions */

// RWS CHANGE: This whole function was heavily changed to just a few
// hundred percent more sensible.
function Combo_SetupSizes(UWindowComboControl W, Canvas C)
{
	local float TW, TH;

	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, TW, TH);
	
	switch(W.Align)
	{
	case TA_Left:
		W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
		W.TextX = 0;
		break;
	case TA_Right:
		W.EditAreaDrawX = 0;	
		W.TextX = W.WinWidth - TW;
		break;
	case TA_Center:
		W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth) / 2;
		W.TextX = (W.WinWidth - TW) / 2;
		break;
	}

	W.EditAreaDrawY = (W.EditBoxHeightReduction / 2) + 1;

	W.TextY = (W.WinHeight - TH) / 2;

	// EditBox window is the area INSIDE the bevel
	W.EditBox.WinWidth = W.EditBoxWidth - MiscBevelL[2].W - MiscBevelR[2].W - W.ButtonWidth;
	W.EditBox.WinHeight = W.WinHeight - W.EditBoxHeightReduction - MiscBevelT[2].H - MiscBevelB[2].H;
	W.EditBox.WinLeft = W.EditAreaDrawX + MiscBevelL[2].W;
	W.EditBox.WinTop = (W.EditBoxHeightReduction/2+1) + MiscBevelT[2].H;

	// This is the drop-down button that goes inside 
	W.Button.WinTop = W.EditBox.WinTop;
	W.Button.WinLeft = W.WinWidth - W.ButtonWidth - MiscBevelR[2].W;
	W.Button.WinHeight = W.EditBox.WinHeight;

	if(W.bButtons)
	{
		W.EditBox.WinWidth -= SBLeftUp.W + SBRightUp.W;
		W.Button.WinLeft -= SBLeftUp.W + SBRightUp.W;

		// RWS CHANGE: Made left + right buttons size right
		W.Button.WinLeft = W.WinWidth - ComboBtnUp.W - MiscBevelR[2].W - SBLeftUp.W - SBRightUp.W - 10;

		W.LeftButton.WinLeft = W.WinWidth - MiscBevelR[2].W - SBLeftUp.W - SBRightUp.W - 6;
		W.LeftButton.WinTop = W.EditBox.WinTop;
		W.RightButton.WinLeft = W.WinWidth - MiscBevelR[2].W - SBRightUp.W - 3;
		W.RightButton.WinTop = W.EditBox.WinTop;

		W.LeftButton.WinWidth = SBLeftUp.W+3;
		//W.LeftButton.WinHeight = SBLeftUp.H;
		W.LeftButton.WinHeight = W.EditBox.WinHeight;
		W.RightButton.WinWidth = SBRightUp.W+3;
		//W.RightButton.WinHeight = SBRightUp.H;
		W.RightButton.WinHeight = W.EditBox.WinHeight;
	}
}

function Combo_Draw(UWindowComboControl W, Canvas C)
{
	// RWS CHANGE: Made this use sensible values
	W.DrawMiscBevel(C, W.EditAreaDrawX, W.EditAreaDrawY, W.EditBoxWidth, W.EditBoxHeight, Misc, 2);

	// 01/19/03 JMI Changed to letting the common control text drawing routine do this work.
	Control_DrawText(W, C);
}

function ComboList_DrawBackground(UWindowComboList W, Canvas C)
{
	W.DrawClippedTexture(C, 0, 0, Texture'P2LookAndFeel.b_MenuTL');
	W.DrawStretchedTexture(C, 4, 0, W.WinWidth-8, 4, Texture'P2LookAndFeel.b_MenuT');
	W.DrawClippedTexture(C, W.WinWidth-4, 0, Texture'P2LookAndFeel.b_MenuTR');

	W.DrawClippedTexture(C, 0, W.WinHeight-4, Texture'P2LookAndFeel.b_MenuBL');
	W.DrawStretchedTexture(C, 4, W.WinHeight-4, W.WinWidth-8, 4, Texture'P2LookAndFeel.b_MenuB');
	W.DrawClippedTexture(C, W.WinWidth-4, W.WinHeight-4, Texture'P2LookAndFeel.b_MenuBR');

	W.DrawStretchedTexture(C, 0, 4, 4, W.WinHeight-8, Texture'P2LookAndFeel.b_MenuL');
	W.DrawStretchedTexture(C, W.WinWidth-4, 4, 4, W.WinHeight-8, Texture'P2LookAndFeel.b_MenuR');

	W.DrawStretchedTexture(C, 4, 4, W.WinWidth-8, W.WinHeight-8, Texture'P2LookAndFeel.b_MenuArea');
}

function ComboList_DrawItem(UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected)
{
	local float TW, TH;
	C.SetDrawColor(255,255,255);

	if(bSelected)
	{
		// 01/19/03 JMI Changed to take into account the actual item height in effect in the combo box.
		Combo.DrawStretchedTexture(C, X,		 Y, 4,		Combo.ItemHeight + 1, Texture'P2LookAndFeel.b_MenuHL');
		Combo.DrawStretchedTexture(C, X + 4,	 Y, W - 8,	Combo.ItemHeight + 1, Texture'P2LookAndFeel.b_MenuHM');
		Combo.DrawStretchedTexture(C, X + W - 4, Y, 4,		Combo.ItemHeight + 1, Texture'P2LookAndFeel.b_MenuHR');
		C.SetDrawColor(0,0,0); 
	}
	else
	{
		C.SetDrawColor(0,0,0);
	}

	// 02/04/03 JMI Changed to center the txt vertically within the item height.
	Combo.TextSize(C, "A", TW, TH);
	Combo.ClipText(C, X + Combo.TextBorder + 2, Y + (Combo.ItemHeight - TH) / 2, Text);
}

function Checkbox_SetupSizes(UWindowCheckbox W, Canvas C)
{
	local float TW, TH;

	W.TextSize(C, W.Text, TW, TH);
// RWS CHANGE - don't change window height (screws up our menu item spacing)
//	W.WinHeight = Max(TH+1, 16);
	
	switch(W.Align)
	{
		// RWS Change: CRK - Restore TA_Left to default and added Custom case
	case TA_Left:
		//W.ImageX = W.WinWidth - 16;
		W.ImageX = W.WinWidth - 13;
		W.TextX = 0;
		break;
	case TA_Right:
		W.ImageX = 0;	
		W.TextX = W.WinWidth - TW;
		break;
	case TA_Center:
		W.ImageX = (W.WinWidth - 16) / 2;
		W.TextX = (W.WinWidth - TW) / 2;
		break;
		// 01/15/03 JMI Changed this to put the check on the left edge of the right side of the
		//				control to match where the other controls start at a controllable distance.
		//				Not sure how this should affect the other two alignments.
	case TA_Custom:
		W.ImageX = W.WinWidth - W.CheckBoxAreaW;
		W.TextX = 0;
		break;
	case TA_LeftOfText:
		W.ImageX = 0;	
		W.TextX = 18;
		break;
	}

	W.ImageY = (W.WinHeight - 16) / 2;
	W.TextY = (W.WinHeight - TH) / 2;

	if(W.bChecked) 
	{
		W.UpTexture = Texture'P2LookAndFeel.b_masked_ChkChecked';
		W.DownTexture = Texture'P2LookAndFeel.b_masked_ChkChecked';
		W.OverTexture = Texture'P2LookAndFeel.b_masked_ChkChecked';
		W.DisabledTexture = Texture'P2LookAndFeel.b_masked_ChkCheckedDisabled';
	}
	else 
	{
		W.UpTexture = Texture'P2LookAndFeel.b_masked_ChkUnchecked';
		W.DownTexture = Texture'P2LookAndFeel.b_masked_ChkUnchecked';
		W.OverTexture = Texture'P2LookAndFeel.b_masked_ChkUnchecked';
		W.DisabledTexture = Texture'P2LookAndFeel.b_masked_ChkUncheckedDisabled';
	}
}

function RadioButton_SetupSizes(UWindowRadioButton W, Canvas C)
{
	local float TW, TH;

	W.TextSize(C, W.Text, TW, TH);
//	W.WinHeight = Max(TH+1, 16);
	
	switch(W.Align)
	{
	case TA_Left:
		W.ImageX = W.WinWidth - 13;
		W.TextX = 0;
		break;
	case TA_Right:
		W.ImageX = 0;	
		W.TextX = W.WinWidth - TW;
		break;
	case TA_Center:
		W.ImageX = (W.WinWidth - 16) / 2;
		W.TextX = (W.WinWidth - TW) / 2;
		break;
	case TA_LeftOfText:
		W.ImageX = 0;	
		W.TextX = 18;
		break;
	}

	W.ImageY = (W.WinHeight - 16) / 2;
	W.TextY = (W.WinHeight - TH) / 2;

	if(W.bSelected)
	{
		W.UpTexture = Texture'b_masked_RadioSel';
		W.DownTexture = Texture'b_masked_RadioSel';
		W.OverTexture = Texture'b_masked_RadioSel';
		W.DisabledTexture = Texture'b_masked_RadioSelDisabled';
	}
	else 
	{
		W.UpTexture = Texture'b_masked_RadioUnSel';
		W.DownTexture = Texture'b_masked_RadioUnSel';
		W.OverTexture = Texture'b_masked_RadioUnSel';
		W.DisabledTexture = Texture'b_masked_RadioUnSelDisabled';
	}
}

function Combo_GetButtonBitmaps(UWindowComboButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();
	
	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = ComboBtnUp;
	W.DownRegion = ComboBtnDown;
	W.OverRegion = ComboBtnUp;
	W.DisabledRegion = ComboBtnDisabled;
}

function Combo_SetupLeftButton(UWindowComboLeftButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
}

function Combo_SetupRightButton(UWindowComboRightButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
}



function Editbox_SetupSizes(UWindowEditControl W, Canvas C)
{
	local float TW, TH;
	local int B;

	B = EditBoxBevel;
		
	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, TW, TH);
	
	// RWS CHANGE: 02/01/03 JMI Who the fuck hard codes the size of a field
	//							overriding its actual size??  Who the -fuck-?!
	//							Remove this crappy ass code!
	// W.WinHeight = 12 + MiscBevelT[B].H + MiscBevelB[B].H;
	
	switch(W.Align)
	{
	case TA_Left:
		W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
		W.TextX = 0;
		break;
	case TA_Right:
		W.EditAreaDrawX = 0;	
		W.TextX = W.WinWidth - TW;
		break;
	case TA_Center:
		W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth) / 2;
		W.TextX = (W.WinWidth - TW) / 2;
		break;
	}

	W.EditAreaDrawY = (W.WinHeight - 2) / 2;
	W.TextY = (W.WinHeight - TH) / 2;

	W.EditBox.WinLeft = W.EditAreaDrawX + MiscBevelL[B].W;
	W.EditBox.WinTop = MiscBevelT[B].H;
	W.EditBox.WinWidth = W.EditBoxWidth - MiscBevelL[B].W - MiscBevelR[B].W;
	W.EditBox.WinHeight = W.WinHeight - MiscBevelT[B].H - MiscBevelB[B].H;
}

function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0, W.EditBoxWidth, W.WinHeight, Misc, EditBoxBevel);

	if(W.Text != "")
	{
		//C.DrawColor = W.TextColor;
		//W.ClipText(C, W.TextX, W.TextY, W.Text);
		//C.SetDrawColor(255,255,255);

		// CRK: Added to draw shadows on Edit Boxes
		Control_DrawText(W,C);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Configure a text item.
// 02/10/03 JMI Started from EditBox_SetupSizes.
///////////////////////////////////////////////////////////////////////////////
function TextItem_SetupSizes(ShellTextControl W, Canvas C)
{
	local float TW, TH;
	local int B;

	C.Font = W.Root.Fonts[W.Font];
	
	// Label //
	W.TextSize(C, W.Text, TW, TH);
	
	switch(W.Align)
	{
	case TA_Left:
		W.ValueX	= W.WinWidth - W.TextItemWidth;
		W.TextX		= 0;
		break;
	case TA_Right:
		W.ValueX	= 0;	
		W.TextX		= W.WinWidth - TW;
		break;
	case TA_Center:
		W.ValueX = (W.WinWidth - W.TextItemWidth) / 2;
		W.TextX	 = (W.WinWidth - TW) / 2;
		break;
	}

	W.TextY  = (W.WinHeight - TH) / 2;

	// Value //
	W.TextSize(C, W.ValueText, TW, TH);

	switch (W.ValueAlign)
	{
	case TA_Left:
		W.ValueX	= W.ValueX;
		break;
	case TA_Right:
		W.ValueX	= W.ValueX + W.TextItemWidth - TW;	
		break;
	case TA_Center:
		W.ValueX = W.ValueX + (W.TextItemWidth - TW) / 2;
		break;
	}

	W.ValueY = (W.WinHeight - TH) / 2;
}

///////////////////////////////////////////////////////////////////////////////
// Draw a text item.
// 02/10/03 JMI Started from EditBox_SetupSizes.
///////////////////////////////////////////////////////////////////////////////
function TextItem_Draw(ShellTextControl W, Canvas C)
{
	local string strTemp;

	Control_DrawText(W, C);

	strTemp = W.Text;
	W.Text	= W.ValueText;
	W.TextX = W.ValueX;
	W.TextY = W.ValueY;
	Control_DrawText(W, C);
	// Restore text--yeah this is cheezy but I don't want to duplicate Control_DrawText
	// just for this.
	W.Text	= strTemp;
}

function ControlFrame_SetupSizes(UWindowControlFrame W, Canvas C)
{
	local int B;

	B = EditBoxBevel;
		
	W.Framed.WinLeft = MiscBevelL[B].W;
	W.Framed.WinTop = MiscBevelT[B].H;
	W.Framed.SetSize(W.WinWidth - MiscBevelL[B].W - MiscBevelR[B].W, W.WinHeight - MiscBevelT[B].H - MiscBevelB[B].H);
}

function ControlFrame_Draw(UWindowControlFrame W, Canvas C)
{
	C.SetDrawColor(255,255,255);
	
	W.DrawStretchedTexture(C, 0, 0, W.WinWidth, W.WinHeight, Texture'WhiteTexture');
	W.DrawMiscBevel(C, 0, 0, W.WinWidth, W.WinHeight, Misc, EditBoxBevel);
}

function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText)
{
	local Region R;
	local Texture T;
	local float TW, TH;

	C.SetDrawColor(255,255,255);
	
	T = Tab.GetLookAndFeelTexture();
	
	if(bActiveTab)
	{
		R = TabSelectedL;
		Tab.DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

		R = TabSelectedM;
		Tab.DrawStretchedTextureSegment( C, X+TabSelectedL.W, Y, 
										W - TabSelectedL.W
										- TabSelectedR.W,
										R.H, R.X, R.Y, R.W, R.H, T );

		R = TabSelectedR;
		Tab.DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

		C.Font = Tab.Root.Fonts[Tab.F_SmallBold];
		C.SetDrawColor(0,0,0);

		if(bShowText)
		{
			Tab.TextSize(C, Text, TW, TH);
			Tab.ClipText(C, X + (W-TW)/2, Y + 3, Text, True);
		}
	}
	else
	{
		R = TabUnselectedL;
		Tab.DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

		R = TabUnselectedM;
		Tab.DrawStretchedTextureSegment( C, X+TabUnselectedL.W, Y, 
										W - TabUnselectedL.W
										- TabUnselectedR.W,
										R.H, R.X, R.Y, R.W, R.H, T );

		R = TabUnselectedR;
		Tab.DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

		C.Font = Tab.Root.Fonts[Tab.F_Small];
		C.SetDrawColor(0,0,0);

		if(bShowText)
		{
			Tab.TextSize(C, Text, TW, TH);
			Tab.ClipText(C, X + (W-TW)/2, Y + 4, Text, True);
		}
	}
}

function SB_SetupUpButton(UWindowSBUpButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBUpUp;
	W.DownRegion = SBUpDown;
	W.OverRegion = SBUpUp;
	W.DisabledRegion = SBUpDisabled;
}

function SB_SetupDownButton(UWindowSBDownButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBDownUp;
	W.DownRegion = SBDownDown;
	W.OverRegion = SBDownUp;
	W.DisabledRegion = SBDownDisabled;
}



function SB_SetupLeftButton(UWindowSBLeftButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
}

function SB_SetupRightButton(UWindowSBRightButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
}

function SB_VDraw(UWindowVScrollbar W, Canvas C)
{
	local Region R;
	local Texture T;

	T = W.GetLookAndFeelTexture();

	R = SBBackground;
	W.DrawStretchedTextureSegment( C, 0, 0, W.WinWidth, W.WinHeight, R.X, R.Y, R.W, R.H, T);
	
	if(!W.bDisabled)
	{
		W.DrawUpBevel( C, 0, W.ThumbStart, Size_ScrollbarWidth,	W.ThumbHeight, T);
	}
}

function SB_HDraw(UWindowHScrollbar W, Canvas C)
{
	local Region R;
	local Texture T;

	T = W.GetLookAndFeelTexture();

	R = SBBackground;
	W.DrawStretchedTextureSegment( C, 0, 0, W.WinWidth, W.WinHeight, R.X, R.Y, R.W, R.H, T);
	
	if(!W.bDisabled) 
	{
		W.DrawUpBevel( C, W.ThumbStart, 0, W.ThumbWidth, Size_ScrollbarWidth, T);
	}
}

function Tab_SetupLeftButton(UWindowTabControlLeftButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();


	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	W.WinTop = Size_TabAreaHeight - W.WinHeight;
	W.WinLeft = W.ParentWindow.WinWidth - 2*W.WinWidth;

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
}

function Tab_SetupRightButton(UWindowTabControlRightButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	W.WinTop = Size_TabAreaHeight - W.WinHeight;
	W.WinLeft = W.ParentWindow.WinWidth - W.WinWidth;

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
}

function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P)
{
	P.WinLeft = 2;
	P.WinTop = W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H) + 3;
	P.SetSize(W.WinWidth - 4, W.WinHeight-(W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H)) - 6);
}

function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P)
{
	W.DrawUpBevel( C, 0, W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H), W.WinWidth, W.WinHeight-(W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H)), W.GetLookAndFeelTexture());
}

function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H)
{
	local float TW, TH;

	C.Font = Tab.Root.Fonts[Tab.F_Bold];

	Tab.TextSize( C, Text, TW, TH );
	W = TW + Size_TabSpacing;
	H = Size_TabAreaHeight;
}

function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C)
{
	W.DrawClippedTexture(C, 0, 0, Texture'P2LookAndFeel.b_BarL');
	W.DrawStretchedTexture( C, 16, 0, W.WinWidth - 32, 16, Texture'P2LookAndFeel.b_BarTile');
	W.DrawClippedTexture(C, W.WinWidth - 16, 0, Texture'P2LookAndFeel.b_BarWin');
}

function Menu_DrawMenuBarItem(UWindowMenuBar B, UWindowMenuBarItem I, float X, float Y, float W, float H, Canvas C)
{
	if(B.Selected == I)
	{
		B.DrawClippedTexture(C, X, 0, Texture'P2LookAndFeel.b_BarInL');
		B.DrawClippedTexture(C, X+W-1, 0, Texture'P2LookAndFeel.b_BarInR');
		B.DrawStretchedTexture(C, X+1, 0, W-2, 16, Texture'P2LookAndFeel.b_BarInM');
	}
	else
	if (B.Over == I)
	{
		B.DrawClippedTexture(C, X, 0, Texture'P2LookAndFeel.b_BarOutL');
		B.DrawClippedTexture(C, X+W-1, 0, Texture'P2LookAndFeel.b_BarOutR');
		B.DrawStretchedTexture(C, X+1, 0, W-2, 16, Texture'P2LookAndFeel.b_BarOutM');
	}

	C.Font = B.Root.Fonts[F_Small];
	C.SetDrawColor(0,0,0);

	B.ClipText(C, X + B.SPACING / 2, 3, I.Caption, True);
}

function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C)
{
	W.DrawClippedTexture(C, 0, 0, Texture'P2LookAndFeel.b_MenuTL');
	W.DrawStretchedTexture(C, 4, 0, W.WinWidth-8, 4, Texture'P2LookAndFeel.b_MenuT');
	W.DrawClippedTexture(C, W.WinWidth-4, 0, Texture'P2LookAndFeel.b_MenuTR');

	W.DrawClippedTexture(C, 0, W.WinHeight-4, Texture'P2LookAndFeel.b_MenuBL');
	W.DrawStretchedTexture(C, 4, W.WinHeight-4, W.WinWidth-8, 4, Texture'P2LookAndFeel.b_MenuB');
	W.DrawClippedTexture(C, W.WinWidth-4, W.WinHeight-4, Texture'P2LookAndFeel.b_MenuBR');

	W.DrawStretchedTexture(C, 0, 4, 4, W.WinHeight-8, Texture'P2LookAndFeel.b_MenuL');
	W.DrawStretchedTexture(C, W.WinWidth-4, 4, 4, W.WinHeight-8, Texture'P2LookAndFeel.b_MenuR');
	W.DrawStretchedTexture(C, 4, 4, W.WinWidth-8, W.WinHeight-8, Texture'P2LookAndFeel.b_MenuArea');
}

function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected)
{
	C.SetDrawColor(255,255,255);
	Item.ItemTop = Y + M.WinTop;

	if(Item.Caption == "-")
	{
		M.DrawStretchedTexture(C, X, Y+ (H - 2)/2, W, 2, Texture'P2LookAndFeel.b_MenuLine');
		return;
	}

	C.Font = M.Root.Fonts[F_Normal];

	if(bSelected)
	{
		M.DrawClippedTexture(C, X, Y+2, Texture'P2LookAndFeel.b_MenuHL');
		M.DrawStretchedTexture(C, X + 4, Y+2, W - 8, 20, Texture'P2LookAndFeel.b_MenuHM');
		M.DrawClippedTexture(C, X + W - 4, Y+2, Texture'P2LookAndFeel.b_MenuHR');
	}

	if(Item.bDisabled) 
	{
		// Black Shadow
		C.SetDrawColor(96,96,96);
	}
	else
	{
		C.SetDrawColor(0,0,0);
	}

	// DrawColor will render the tick black white or gray.
	if(Item.bChecked)
		M.DrawClippedTexture(C, X + 1, Y + (H - Texture'MenuTick'.VSize)/2, Texture'MenuTick');

	if(Item.SubMenu != None)
		M.DrawClippedTexture(C, X + W - 9, Y + (H - Texture'MenuSubArrow'.VSize)/2, Texture'MenuSubArrow');

	M.ClipText(C, X + M.TextBorder + 2, Y + 3, Item.Caption, True);	
}

function Button_DrawSmallButton(UWindowSmallButton B, Canvas C)
{
	local float Y;

	if(B.bDisabled)
		Y = 34;
	else
	if(B.bMouseDown)
		Y = 17;
	else
		Y = 0;

	B.DrawStretchedTextureSegment(C, 0,              0, 3,            B.WinHeight, 0,  Y, 3,  16, Texture'P2LookAndFeel.b_SmallButton');
	B.DrawStretchedTextureSegment(C, B.WinWidth - 3, 0, 3,            B.WinHeight, 45, Y, 3,  16, Texture'P2LookAndFeel.b_SmallButton');
	B.DrawStretchedTextureSegment(C, 3,              0, B.WinWidth-6, B.WinHeight, 3,  Y, 42, 16, Texture'P2LookAndFeel.b_SmallButton');
}

function PlayBigSound(UWindowWindow W)
{
	PlayThisLocalSound(W, BigSound, BigVolume);
}

function PlaySmallSound(UWindowWindow W)
{
	PlayThisLocalSound(W, SmallSound, SmallVolume);
}

function PlayEnterSound(UWindowWindow W)
{
	local float Now;
	
	// all this just to get the damn time... - K
	Now = W.Root.ViewportOwner.Actor.Level.TimeSecondsAlways;
	if (Now < LastSoundTime)
		LastSoundTime = 0;
		
	if (Now - LastSoundTime > 0.05)
	{
		PlayThisLocalSound(W, MouseEnterSound, MouseEnterVolume);
		LastSoundTime = Now;
	}
}

simulated function PlayMenuSound(UWindowWindow W, MenuSound S)
{
	switch(S)
	{
	case MS_MenuPullDown:
//		PlayThisLocalSound(W, sound'WindowOpen', 1.0);
		break;
	case MS_MenuCloseUp:
		break;
	case MS_MenuItem:
//		PlayThisLocalSound(W, sound'LittleSelect', 1.0);
		break;
	case MS_WindowOpen:
//		PlayThisLocalSound(W, sound'BigSelect', 1.0);
		break;
	case MS_WindowClose:
		break;
	case MS_ChangeTab:
//		PlayThisLocalSound(W, sound'LittleSelect', 1.0);
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Separate simulated function actually plays the sounds.  This makes it so
// when a listenserver plays a sound, not everyone hears it.  This also allows
// us to manage the slots to avoid clipping when multiple sounds are played
// quickly in succession.
///////////////////////////////////////////////////////////////////////////////
simulated function PlayThisLocalSound(UWindowWindow W, Sound UseSound, float UseVolume)
{
	local Actor.ESoundSlot Slot;

	if (W.root.UseLookAndFeelSounds() && (UseSound != None) && (UseVolume != 0.0))
	{
		NextSoundSlot++;
		if (NextSoundSlot == 0)
			slot = SLOT_None;
		else if (NextSoundSlot == 1)
			slot = SLOT_Misc;
		else if (NextSoundSlot == 2)
			slot = SLOT_Pain;
		else if (NextSoundSlot == 3)
			slot = SLOT_Interact;
	//	else if (NextSoundSlot == 4)
	//		slot = SLOT_Ambient;
		else if (NextSoundSlot == 4)
			slot = SLOT_Talk;
		else if (NextSoundSlot >= 5)
		{
			slot = SLOT_Interface;
			NextSoundSlot = -1;
		}

		W.GetSoundActor().PlaySound(UseSound, Slot, UseVolume,,,,false);
	}
}

function DrawFrame(UWindowWindow W, Canvas C, float X, float Y, float Width, float Height)
{
	C.SetDrawColor(255,255,255);
	W.DrawMiscBevel(C, X, Y, Width, Height, Misc, EditBoxBevel);
}


defaultproperties 
{
//	NormalTextColor = (R=160,G=10,B=10,A=150)	// Based on P2HUD.DefaultFontColor
//	ShadowTextColor = (R=60,G=10,B=10,A=150)	// Based on P2HUD.DefaultFontShadow
	NormalTextColor = (R=160,G=10,B=10,A=255)	// Based on P2HUD.DefaultFontColor
	ShadowTextColor = (R=10,G=10,B=10,A=255)	// Based on P2HUD.DefaultFontShadow
	HighlightTextColor = (R=255,G=75,B=75,A=255)

	ShadowOffsetX(0) = 1
	ShadowOffsetY(0) = 1
	HoverOffsetX(0) = -1
	HoverOffsetY(0) = -1

	ShadowOffsetX(1) = 1
	ShadowOffsetY(1) = 1
	HoverOffsetX(1) = -1
	HoverOffsetY(1) = -1

	ShadowOffsetX(2) = 1
	ShadowOffsetY(2) = 1
	HoverOffsetX(2) = -1
	HoverOffsetY(2) = -1

	ShadowOffsetX(3) = 1
	ShadowOffsetY(3) = 1
	HoverOffsetX(3) = -1
	HoverOffsetY(3) = -1

	ShadowOffsetX(4) = 1
	ShadowOffsetY(4) = 1
	HoverOffsetX(4) = -1
	HoverOffsetY(4) = -1

	ShadowOffsetX(5) = 1
	ShadowOffsetY(5) = 1
	HoverOffsetX(5) = -1
	HoverOffsetY(5) = -1
	
	ShadowOffsetX(6) = 1.5
	ShadowOffsetY(6) = 1.5
	HoverOffsetX(6) = -1
	HoverOffsetY(6) = -1
	
	ShadowOffsetX(7) = 2
	ShadowOffsetY(7) = 2
	HoverOffsetX(7) = -1
	HoverOffsetY(7) = -1

	MouseEnterSound = Sound'MpSounds.MenuBeat'
	MouseEnterVolume = 0.5
	ClickSound = Sound'MpSounds.MenuStab'
	ClickVolume = 1.0
	BigSound = Sound'MpSounds.MenuSquirt'
	BigVolume = 1.0
	SmallSound = Sound'MpSounds.MenuBeat'
	SmallVolume = 1.0

	Active=Texture'P2LookAndFeel.b_masked_ActiveFrame'
	Inactive=Texture'P2LookAndFeel.b_masked_InactiveFrame'
	ActiveS=Texture'P2LookAndFeel.b_masked_ActiveFrameS'
	InactiveS=Texture'P2LookAndFeel.b_masked_InactiveFrameS'
	Misc=Texture'P2LookAndFeel.b_Misc';

	// 02/04/03 JMI Found that the regions here for the dialog box (and I'm sure others) are hard coded not
	//				only to the output drawing size but also to the texture size.  This meant a change in
	//				the desired, say, title bar height would require a change to the texture containing
	//				the title bar and repositioning of all the rest of these values since they are set here
	//				as non relative and the new title bar size would offset the rest of the image attributes.
	//				To avoid this, I created separate TexFrame* regions so these values could remain the same
	//				while we customized the other dialog attributes to our fonts.
	//				Additionally, since the title bar contained a black line at the bottom and we're now
	//				stretching the texture (as a result of diverging the regions), I had to reduce the
	//				height use in pulling from the texture b/c, once stretched, the line became too thick and
	//				did not look right.
	TexFrameTL=(X=0,Y=0,W=2,H=14)
	TexFrameT=(X=32,Y=0,W=1,H=14)
	TexFrameTR=(X=126,Y=0,W=2,H=14)

	TexFrameL=(X=0,Y=32,W=2,H=1)
	TexFrameR=(X=126,Y=32,W=2,H=1)

	TexFrameBL=(X=0,Y=125,W=2,H=3)
	TexFrameB=(X=32,Y=125,W=1,H=3)
	TexFrameBR=(X=126,Y=125,W=2,H=3)

	TexFrameSBL=(X=0,Y=112,W=2,H=16)
	TexFrameSB=(X=32,Y=112,W=1,H=16)
	TexFrameSBR=(X=112,Y=112,W=16,H=16)

	FrameTL=(X=0,Y=0,W=2,H=32)
	FrameT=(X=32,Y=0,W=1,H=32)
	FrameTR=(X=126,Y=0,W=2,H=32)

	FrameL=(X=0,Y=32,W=2,H=1)
	FrameR=(X=126,Y=32,W=2,H=1)

	FrameBL=(X=0,Y=125,W=2,H=3)
	FrameB=(X=32,Y=125,W=1,H=3)
	FrameBR=(X=126,Y=125,W=2,H=3)

	FrameSBL=(X=0,Y=112,W=2,H=16)
	FrameSB=(X=32,Y=112,W=1,H=16)
	FrameSBR=(X=112,Y=112,W=16,H=16)

	FrameActiveTitleColor=(R=0,G=0,B=0,A=255)
	FrameInactiveTitleColor=(R=255,G=255,B=255,A=255)

	HeadingActiveTitleColor=(R=0,G=0,B=0,A=255)
	HeadingInActiveTitleColor=(R=255,G=255,B=255,A=255)

	FrameTitleX=8
	FrameTitleY=5

	CloseBoxOffsetX=4;
	CloseBoxOffsetY=8;
	CloseBoxUp=(X=4,Y=32,W=11,H=11)
	CloseBoxDown=(X=4,Y=43,W=11,H=11)

	MiscBevelTL(0)=(X=0,Y=17,W=3,H=3)
	MiscBevelT(0)=(X=3,Y=17,W=116,H=3)
	MiscBevelTR(0)=(X=119,Y=17,W=3,H=3)
	MiscBevelL(0)=(X=0,Y=20,W=3,H=10)
	MiscBevelR(0)=(X=119,Y=20,W=3,H=10)
	MiscBevelBL(0)=(X=0,Y=30,W=3,H=3)
	MiscBevelB(0)=(X=3,Y=30,W=116,H=3)
	MiscBevelBR(0)=(X=119,Y=30,W=3,H=3)
	MiscBevelArea(0)=(X=3,Y=20,W=116,H=10)


	MiscBevelTL(1)=(X=0,Y=0,W=3,H=3)
	MiscBevelT(1)=(X=3,Y=0,W=116,H=3)
	MiscBevelTR(1)=(X=119,Y=0,W=3,H=3)
	MiscBevelL(1)=(X=0,Y=3,W=3,H=10)
	MiscBevelR(1)=(X=119,Y=3,W=3,H=10)
	MiscBevelBL(1)=(X=0,Y=14,W=3,H=3)
	MiscBevelB(1)=(X=3,Y=14,W=116,H=3)
	MiscBevelBR(1)=(X=119,Y=14,W=3,H=3)
	MiscBevelArea(1)=(X=3,Y=3,W=116,H=10)


	MiscBevelTL(2)=(X=0,Y=33,W=2,H=2)
	MiscBevelT(2)=(X=2,Y=33,W=1,H=2)
	MiscBevelTR(2)=(X=11,Y=33,W=2,H=2)
	MiscBevelL(2)=(X=0,Y=36,W=2,H=1)
	MiscBevelR(2)=(X=11,Y=36,W=2,H=1)
	MiscBevelBL(2)=(X=0,Y=44,W=2,H=2)
	MiscBevelB(2)=(X=2,Y=44,W=1,H=2)
	MiscBevelBR(2)=(X=11,Y=44,W=2,H=2)
	MiscBevelArea(2)=(X=2,Y=35,W=9,H=9)

	ComboBtnUp=(X=20,Y=60,W=12,H=12)
	ComboBtnDown=(X=32,Y=60,W=12,H=12)
	ComboBtnDisabled=(X=44,Y=60,W=12,H=12)

	EditBoxBevel=2
	EditBoxTextColor=(R=0,G=0,B=0,A=255)

	TabSelectedL=(X=4,Y=80,W=3,H=17)
	TabSelectedM=(X=7,Y=80,W=1,H=17)
	TabSelectedR=(X=54,Y=80,W=3,H=17)

	//TabBackground=(X=7,Y=81,W=48,H=15)
	//TabBackground=(X=10,Y=16,W=1,H=1)
	TabBackground=(X=4,Y=79,W=1,H=1)

	// defaults from Win95 LF
	SBUpUp=(X=20,Y=16,W=12,H=10)
	SBUpDown=(X=32,Y=16,W=12,H=10)
	SBUpDisabled=(X=44,Y=16,W=12,H=10)

	SBDownUp=(X=20,Y=26,W=12,H=10)
	SBDownDown=(X=32,Y=26,W=12,H=10)
	SBDownDisabled=(X=44,Y=26,W=12,H=10)

	SBLeftUp=(X=20,Y=48,W=10,H=12)
	SBLeftDown=(X=30,Y=48,W=10,H=12)
	SBLeftDisabled=(X=40,Y=48,W=10,H=12)

	SBRightUp=(X=20,Y=36,W=10,H=12)
	SBRightDown=(X=30,Y=36,W=10,H=12)
	SBRightDisabled=(X=40,Y=36,W=10,H=12)

	SBBackground=(X=4,Y=79,W=1,H=1)

	BevelUpTL=(X=4,Y=16,W=2,H=2)
	BevelUpT=(X=10,Y=16,W=1,H=2)
	BevelUpTR=(X=18,Y=16,W=2,H=2)

	BevelUpL=(X=4,Y=20,W=2,H=1)
	BevelUpR=(X=18,Y=20,W=2,H=1)
	
	BevelUpBL=(X=4,Y=30,W=2,H=2)
	BevelUpB=(X=10,Y=30,W=1,H=2)
	BevelUpBR=(X=18,Y=30,W=2,H=2)

	BevelUpArea=(X=8,Y=20,W=1,H=1)

	HLine=(X=5,Y=78,W=1,H=2)

	TabUnselectedL=(X=57,Y=80,W=3,H=15)
	TabUnselectedM=(X=60,Y=80,W=1,H=15)
	TabUnselectedR=(X=108,Y=80,W=3,H=15)

	Size_ScrollbarWidth=12
	Size_ScrollbarButtonHeight=10
	Size_MinScrollbarHeight=6

	Size_TabAreaHeight=15
	Size_TabAreaOverhangHeight=2
	Size_TabSpacing=5
	Size_TabXOffset=1

	Pulldown_ItemHeight=20
	Pulldown_VBorder=4
	Pulldown_HBorder=3
	Pulldown_TextBorder=9

	ColumnHeadingHeight=13
    
    NormalBackgroundColor=(R=255,G=255,B=255)
    HighlightBackgroundColor=(R=255)
}
