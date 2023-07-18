///////////////////////////////////////////////////////////////////////////////
// BaseMenuBig.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A simple class for all "big" menus to extend from.
//
// History:
//
//	09/04/02 MJR	Started,
//
///////////////////////////////////////////////////////////////////////////////
class BaseMenuBig extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var Texture TitleTexture;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	TitleTexture = Texture(DynamicLoadObject(String(GetGameSingle().MenuTitleTex), class'Texture'));
	if (TitleTexture == None)
		TitleTexture = Default.TitleTexture;
	Super.CreateMenuContents();
	ItemFont = F_FancyXL;
	ItemAlign = TA_Center;
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if (HandleJoystick(Key, Action, Delta))
		return true;

	return false;
}
/*
///////////////////////////////////////////////////////////////////////////////
// Confirm button: issue mouse click
///////////////////////////////////////////////////////////////////////////////
function execConfirmButton()
{
	if (ShellRootWindow(Root).MyMenu == Self)
		Root.MouseWindow.Click(Root.MouseX, Root.MouseY);
}

///////////////////////////////////////////////////////////////////////////////
// Back button: hit Escape
///////////////////////////////////////////////////////////////////////////////
function execBackButton()
{
	local EInputKey key;
	local EInputAction action;
	
	key = IK_Escape;
	action = IST_Release;
	KeyEvent(key, action, 0);
}
*/
///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	MenuWidth = 550

	TitleHeight = 100
	TitleSpacingY = 0
	TitleTexture = Texture'P2Misc.Logos.postal2underlined'

	ItemHeight = 50
	ItemSpacingY = 5
	}
