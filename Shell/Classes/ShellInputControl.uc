///////////////////////////////////////////////////////////////////////////////
// ShellInputControl.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A control specifically for acquiring and displaying an input.
//
// History:
//	01/14/03 JMI	Now displays each of a limited number of values in a separate
//					edit field.  The number and the space occuppied by the edit 
//					fields is tunable via consts.
//
//	11/27/02 JMI	Now notifies owner of left and right mouse clicks.  Wanted
//					this so user could activate the input control by clicking
//					on the label portion.  Changed width of child editbox to
//					4/9 instead of 1/2 to give more room for label (particularly
//					weapon controls menu).
//
//	11/26/02 JMI	Added iBindIndex to map back to binding and now closes 
//					EditBox created by Super class.
//
//	11/25/02 JMI	Started.
//
///////////////////////////////////////////////////////////////////////////////
// A specialized control for displaying and acquiring a number of keys, 
// buttons, etc. for a game input.
//
// Future changes:
// - Could move a couple spots into ShellLookAndFeel.  Seems like over kill,
// though, unless we use this other than just for inputs or we have multiple
// color look-and-feels.
///////////////////////////////////////////////////////////////////////////////
class ShellInputControl extends UWindowDialogControl;

///////////////////////////////////////////////////////////////////////////////
// Typedefs
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Vars & consts
///////////////////////////////////////////////////////////////////////////////

var int iBindIndex;	// Map back to the binding this represents.
var int iCurCtrl;	// Control that last notified us of an important event.

const c_fInputsArea				= 0.67;	// 0.0-1.0
const c_iSpaceBetweenInputs		= 40;	// Screen units.
const c_iNumInputsPerControl	= 3;

var array<ShellInputBox>	aInputs;
var array<ShellInputIcon>	aIcons;

var Texture Blank;	// Blank icon
var Color HighlightColor;
var Color DefaultColor;

///////////////////////////////////////////////////////////////////////////////
// ***Push this into Look and Feel??***
// Compute basic space required per input box.
///////////////////////////////////////////////////////////////////////////////
function int GetInputDivision()
{
	// Divide area for inputs by number of inputs.
	return (WinWidth * c_fInputsArea) / c_iNumInputsPerControl;
}

///////////////////////////////////////////////////////////////////////////////
// **Push this into Look and Feel??
// Compute size of all input boxes.
///////////////////////////////////////////////////////////////////////////////
function int GetInputWidth()
{
	local int B;
	B = LookAndFeel.EditBoxBevel;
	// Divide area for inputs by number of inputs and leave room for space between.
	return GetInputDivision() - c_iSpaceBetweenInputs - (LookAndFeel.MiscBevelL[B].W + LookAndFeel.MiscBevelR[B].W);
}

///////////////////////////////////////////////////////////////////////////////
// **Push this into Look and Feel??
// Compute position of a particular input box.
///////////////////////////////////////////////////////////////////////////////
function int GetInputPosX(int iInput)
{
	local float fFirstCtrl;
	// Start at edge of non-input area and go out iInput division.
	fFirstCtrl = (1.0 - c_fInputsArea) * WinWidth;
	return fFirstCtrl + GetInputDivision() * iInput;
}

///////////////////////////////////////////////////////////////////////////////
// Initialize our UI aspects and create children.
///////////////////////////////////////////////////////////////////////////////
function Created()
{
	local int iIter;
	local int InputPos, InputWidth;
	local int yOffset;
	Super.Created();

	iCurCtrl = -1;
	yOffset = -(WinHeight / 2);

	for (iIter = 0; iIter < c_iNumInputsPerControl; iIter++)
	{
		aInputs.Length = iIter + 1;
		InputPos = GetInputPosX(iIter);
		InputWidth = GetInputWidth();
		
		//aIcons[iIter] = ShellInputIcon(CreateWindow(class'ShellInputIcon',GetInputPosX(iIter),0,class'MenuControlsEdit'.Default.ItemHeight,WinHeight));
		aIcons[iIter] = ShellInputIcon(CreateWindow(class'ShellInputIcon',GetInputPosX(iIter),0,GetInputWidth(),WinHeight));
		aIcons[iIter].bStretch = false;	// This value can be overridden by the extender.
		aIcons[iIter].bAlpha   = true;	// This value can be overridden by the extender.
		aIcons[iIter].bFit	   = true;	// This value can be overridden by the extender.
		aIcons[iIter].bCenter  = true;	// This value can be overridden by the extender.
		aIcons[iIter].NotifyOwner = Self;
		aIcons[iIter].NotifyControl = Self;

		//aInputs[iIter] = ShellInputBox(CreateWindow(class'ShellInputBox', GetInputPosX(iIter) + class'MenuControlsEdit'.Default.ItemHeight + 2, 0, GetInputWidth() - (class'MenuControlsEdit'.Default.ItemHeight + 2), WinHeight)); 
		aInputs[iIter] = ShellInputBox(CreateWindow(class'ShellInputBox', GetInputPosX(iIter),0,GetInputWidth(),WinHeight)); 
		aInputs[iIter].NotifyOwner = Self;
		aInputs[iIter].NotifyControl = Self;
		aInputs[iIter].bSelectOnFocus = False;	// 12/03/02 JMI Changed to no select on focus.
		aInputs[iIter].SetEditable(False);		// 12/03/02 JMI Made non-editable.
		
		// Set target status to initially update colors.
		SetTargetStatus(iIter, false);
		
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the value in a particular input box.
///////////////////////////////////////////////////////////////////////////////
function string GetValue(int iInput)
{
	if (iInput >= 0 && iInput < aInputs.Length)
		return aInputs[iInput].GetValue();
	return "";	// Return error string so we notice or just ""?
}

///////////////////////////////////////////////////////////////////////////////
// Set the value in a particular input box.
///////////////////////////////////////////////////////////////////////////////
function SetValue(int iInput, string NewValue, optional Texture Icon)
{
	if (iInput >= 0 && iInput < aInputs.Length)
	{
		if (Icon != None)	
		{
			// Icon exists; display it and hide text field.
			aInputs[iInput].SetValue("");
			aIcons[iInput].T = Icon;
			aIcons[iInput].R.X = 0;
			aIcons[iInput].R.Y = 0;
			aIcons[iInput].R.W = aIcons[iInput].T.USize;
			aIcons[iInput].R.H = aIcons[iInput].T.VSize;
		}
		else
		{
			// Icon is missing. Hide it and instead show text field.
			aInputs[iInput].SetValue(NewValue);	
			aIcons[iInput].T = Blank;
			aIcons[iInput].R.X = 0;
			aIcons[iInput].R.Y = 0;
			aIcons[iInput].R.W = aIcons[iInput].T.USize;
			aIcons[iInput].R.H = aIcons[iInput].T.VSize;
		}
	}		
}

///////////////////////////////////////////////////////////////////////////////
// Clear the value in a particular input box.
///////////////////////////////////////////////////////////////////////////////
function Clear(int iInput)
{
	if (iInput >= 0 && iInput < aInputs.Length)
		aInputs[iInput].Clear();
}

///////////////////////////////////////////////////////////////////////////////
// Select the specified input box.
///////////////////////////////////////////////////////////////////////////////
function Select(int iInput, bool bSel)
{
	if (iInput >= 0 && iInput < aInputs.Length)
		aInputs[iInput].bAllSelected = bSel;
}

///////////////////////////////////////////////////////////////////////////////
// Set font for all or a specified input box.
///////////////////////////////////////////////////////////////////////////////
function SetInputFont(int iInput, int iFont)
{
	local int iIter;
	if (iInput == -1)
	{
		for (iIter = 0; iIter < aInputs.Length; iIter++)
		{
			aInputs[iIter].SetFont(iFont);
		}
	}
	else if (iInput >= 0 && iInput < aInputs.Length)
		aInputs[iInput].SetFont(iFont);
}

///////////////////////////////////////////////////////////////////////////////
// Set text color for all or a specified input box.
///////////////////////////////////////////////////////////////////////////////
function SetInputTextColor(int iInput, Color NewColor)
{
	local int iIter;
	if (iInput == -1)
	{
		for (iIter = 0; iIter < aInputs.Length; iIter++)
		{
			aInputs[iIter].SetTextColor(NewColor);
		}
	}
	else if (iInput >= 0 && iInput < aInputs.Length)
		aInputs[iInput].SetTextColor(NewColor);
}

///////////////////////////////////////////////////////////////////////////////
// Set the background color for all or a specified input box.
///////////////////////////////////////////////////////////////////////////////
function SetInputBackColor(int iInput, Color NewColor)
{
	local int iIter;
	if (iInput == -1)
	{
		for (iIter = 0; iIter < aInputs.Length; iIter++)
		{
			aInputs[iIter].SetBackColor(NewColor);
		}
	}
	else if (iInput >= 0 && iInput < aInputs.Length)
		aInputs[iInput].SetBackColor(NewColor);
}

///////////////////////////////////////////////////////////////////////////////
// Set alignment for all or a specified input box.
///////////////////////////////////////////////////////////////////////////////
function SetInputTextAlign(int iInput, TextAlign align)
{
	local int iIter;
	if (iInput == -1)
	{
		for (iIter = 0; iIter < aInputs.Length; iIter++)
		{
			aInputs[iIter].Align = align;
		}
	}
	else if (iInput >= 0 && iInput < aInputs.Length)
		aInputs[iInput].Align = align;
}

///////////////////////////////////////////////////////////////////////////////
// Set the highlight status for a specified input box.
///////////////////////////////////////////////////////////////////////////////
function SetTargetStatus(int iInput, bool bTarget)
{
	local Color				clr;
	local ShellLookAndFeel	laf;
	laf = ShellLookAndFeel(LookAndFeel);

	if (laf != none)
	{
		if (bTarget)
		{
			//SetInputBackColor(iInput, laf.NormalTextColor);
			SetInputBackColor(iInput, laf.HighlightBackgroundColor);
			SetInputTextColor(iInput, laf.HighlightTextColor);
		}
		else
		{
			clr.R = 255;
			clr.G = 255;
			clr.B = 255;
			clr.A = 255;
			//SetInputBackColor(iInput, clr);
			SetInputBackColor(iInput, laf.NormalBackgroundColor);
			SetInputTextColor(iInput, laf.NormalTextColor);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// ***Push this into Look and Feel??***
// Draw an input box.
///////////////////////////////////////////////////////////////////////////////
function Inputbox_Draw(ShellInputBox box, Canvas C)
{
	local int B;
	B = LookAndFeel.EditBoxBevel;

	// Use background color to differentiate the input target.
	C.SetDrawColor(box.clrBack.R, box.clrBack.G, box.clrBack.B, box.clrBack.A);

	Self.DrawMiscBevel(	// Note that we don't worry about the height since the text is centered
						// but if we used too large a font I suppose it might look weird but then
						// again that'd look weird anyway.
		C, 
		box.WinLeft - LookAndFeel.MiscBevelL[B].W, 
		box.WinTop, 
		box.WinWidth + (LookAndFeel.MiscBevelL[B].W + LookAndFeel.MiscBevelR[B].W), 
		box.WinHeight, 
		LookAndFeel.Misc, LookAndFeel.EditBoxBevel);
	
	// Restore color.
	C.SetDrawColor(255, 255, 255, 255);
}

///////////////////////////////////////////////////////////////////////////////
// Perform paint operation.
///////////////////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y)
{
	local int iIter;
	// Seems like children should be drawn after the parent but they're drawn
	// first in UWindowEditControl so let's do it that way.
	for (iIter = 0; iIter < aInputs.Length; iIter++)
	{
		// I don't understand why the inputbox itself shouldn't make this call but
		// let's stick with the program.
		Inputbox_Draw(aInputs[iIter], C);
	}

	LookAndFeel.Control_DrawText(self, C);

	Super.Paint(C, X, Y);
}

///////////////////////////////////////////////////////////////////////////////
// Get a control index from a control.
///////////////////////////////////////////////////////////////////////////////
function int GetIconIndex(ShellInputIcon C)
{
	local int iIter;
	for (iIter = 0; iIter < aIcons.Length; iIter++)
	{
		if (aIcons[iIter] == C)
			return iIter;
	}

	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// Get a control index from a control.
///////////////////////////////////////////////////////////////////////////////
function int GetControlIndex(UWindowDialogControl C)
{
	local int iIter;
	for (iIter = 0; iIter < aInputs.Length; iIter++)
	{
		if (aInputs[iIter] == C)
			return iIter;
	}

	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from input boxes
///////////////////////////////////////////////////////////////////////////////
function NotifyInput(UWindowDialogControl C, byte E)
{
    local int i;
	switch (E)
	{
	case DE_RClick:
	case DE_Click:
		// Identify the control.
		iCurCtrl = GetControlIndex(C);
		break;
    case DE_MouseLeave:
        i = GetControlIndex(C);
        SetTargetStatus(i, false);
        break;
    case DE_MouseEnter:
        i = GetControlIndex(C);
        SetTargetStatus(i, true);
        break;            
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from input icon
///////////////////////////////////////////////////////////////////////////////
function NotifyIcon(ShellInputIcon C, byte E)
{
	iCurCtrl = GetIconIndex(C);
	Notify(E);
}

defaultproperties
{
	Blank=Texture'ButtonIcons.Blank'
}