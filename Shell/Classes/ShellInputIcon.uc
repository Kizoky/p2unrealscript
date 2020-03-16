///////////////////////////////////////////////////////////////////////////////
// ShellInputIcon
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Subclass of ShellBitmap for our joystick/keyboard button icons
// Pretty much the same as ShellInputBox in that it passes any input received
// to MenuControlsEdit
///////////////////////////////////////////////////////////////////////////////
class ShellInputIcon extends ShellBitmap;

///////////////////////////////////////////////////////////////////////////////
// Typedefs
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Vars & consts
///////////////////////////////////////////////////////////////////////////////
var ShellInputControl	NotifyControl;
var UWindowDialogControl	NotifyOwner;
var Color				clrBack;

///////////////////////////////////////////////////////////////////////////////
// Notify owner of right clicks.
///////////////////////////////////////////////////////////////////////////////
function RClick(float X, float Y) 
{
	Notify(DE_RClick);
}
function Click(float X, float Y) 
{
	Notify(DE_Click);
}

///////////////////////////////////////////////////////////////////////////////
// Notify input control.
///////////////////////////////////////////////////////////////////////////////
function Notify(byte E)
{
	if (NotifyControl != None)
		NotifyControl.NotifyIcon(Self, E);

	if (ShellInputControl(NotifyOwner) != none)
		ShellInputControl(NotifyOwner).NotifyIcon(Self, E);
}

function KeyDown(int Key, float X, float Y)
{
	if(NotifyOwner != None)
		NotifyOwner.KeyDown(Key, X, Y);
	else
		Super.KeyDown(Key, X, Y);
}

function FocusOtherWindow(UWindowWindow W)
{
	if(NotifyOwner != None)
		NotifyOwner.FocusOtherWindow(W);
	else
		Super.FocusOtherWindow(W);
}

function MouseMove(float X, float Y)
{
	Super.MouseMove(X, Y);
	Notify(DE_MouseMove);
}

function MouseEnter()
{
	Super.MouseEnter();
	Notify(DE_MouseEnter);
}

function MouseLeave()
{
	Super.MouseLeave();
	Notify(DE_MouseLeave);
}
