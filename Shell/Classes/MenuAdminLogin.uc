///////////////////////////////////////////////////////////////////////////////
// MenuAdminLogin.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The Admin Login Menu to become an administrator during the game.
//
// History:
//	10/22/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuAdminLogin extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var UWindowEditControl	PasswordControl;
var localized string	PasswordText;

var ShellMenuChoice		LoginChoice;
var localized string	LoginText;

var float				Timer;
var bool				bWaiting;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super.CreateMenuContents();
	
	TitleAlign = TA_Center;
	ItemAlign = TA_Center;
	AddTitle(AdminLoginText, TitleFont, TitleAlign);

	PasswordControl		= AddEditBox(PasswordText,	"", ItemFont);
	PasswordControl.EditBoxWidth += 80;
	//PasswordControl.WinLeft = (WinWidth - PasswordControl.WinWidth + PasswordControl.EditBoxWidth - 30)/2;
	LoginChoice			= AddChoice(LoginText,		"", ItemFont, ItemAlign);

	BackChoice			= AddChoice(BackText,		"", ItemFont, ItemAlign, true);
}

function AfterCreate()
{
	Super.AfterCreate();

	PasswordControl.BringToFront();
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
	{
		case DE_EnterPressed:
			switch (C)
			{
				case PasswordControl:
					Login();
					break;
			}
			break;
		case DE_Click:
			if (C != None)
				switch (C)
				{
					case LoginChoice:
						Login();
						break;
					case BackChoice:
						GoBack();
						break;
				}
			break;
	}
}

function Login()
{
	if(PasswordControl.GetValue() != "")
	{
		GetPlayerOwner().ConsoleCommand("adminlogin" @ PasswordControl.GetValue());
		// Wait half a second before going back to give time to do the login
		Timer = Root.GetLevel().TimeSeconds + 0.5;
		bWaiting = true;
	}
}

function Tick(float Delta)
{
	Super.Tick(Delta);
	if(bWaiting && Root.GetLevel().TimeSeconds > Timer)
	{
		bWaiting = false;
		GoBack();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuWidth	= 400
	PasswordText= "Password"
	LoginText	= "Login"
}
