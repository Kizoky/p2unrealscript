///////////////////////////////////////////////////////////////////////////////
// ShellMapListFrame.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// List box that shows maps.
//
///////////////////////////////////////////////////////////////////////////////
class ShellMapListBox extends UWindowListBox;

function BeforePaint(Canvas C, float MouseX, float MouseY)
	{
	local Font SaveFont;
	local float TW, TH;
	
	SaveFont = C.Font;
	C.Font = Root.Fonts[F_Normal];
	
	TextSize(C, "Testing", TW, TH);
	ItemHeight = TH;
	
	C.Font = SaveFont;
	Super.BeforePaint(C, MouseX, MouseY);
	}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
	{
	if(ShellMapListItem(Item).bSelected)
		{
		C.SetDrawColor(128,0,0);
		DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture');
		C.SetDrawColor(255,255,255);
		}
	else
		{
		C.SetDrawColor(0,0,0);
		}
	
	C.Font = Root.Fonts[F_Normal];
	ClipText(C, X, Y, ShellMapListItem(Item).DisplayName);
	}

defaultproperties
	{
	ListClass=class'ShellMapListItem'
	}
