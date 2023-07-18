///////////////////////////////////////////////////////////////////////////////
// MenuControls.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The controls menu.
//
// History:
//	01/13/03 JMI	Added strHelp parameter to AddChoice() allowing us to pass
//					in many help strings that had been created but were not 
//					being used for standard menu choices.  Added generic 
//					RestoreHelp for menus sporting a Restore option.
//
//	12/17/02 NPF	Made entires fit those in the manual, ie, Character is now Actions, etc.
//	11/12/02 NPF	Filled out more options, changed some names
//
//	09/22/02 JMI	Filled in options.
//
//	08/31/02 MJR	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuControls extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string ControlsTitleText;

var ShellMenuChoice		MovementChoice;
var localized string	MovementControlsText;
var localized string	MovementControlsHelp;

var ShellMenuChoice		ActionsChoice;
var localized string	ActionsControlsText;
var localized string	ActionsControlsHelp;

var ShellMenuChoice		WeaponChoice;
var localized string	WeaponControlsText;
var localized string	WeaponControlsHelp;

var ShellMenuChoice		WeaponChoice2;
var localized string	WeaponControlsText2;
var localized string	WeaponControlsHelp2;

var ShellMenuChoice		InvChoice;
var localized string	InvControlsText;
var localized string	InvControlsHelp;

var ShellMenuChoice		MiscChoice;
var localized string	MiscControlsText;
var localized string	MiscControlsHelp;

var ShellMenuChoice		MultiChoice;
var localized string	MultiControlsText;
var localized string	MultiControlsHelp;

var ShellMenuChoice		DisplayChoice;
var localized string	DisplayControlsText;
var localized string	DisplayControlsHelp;

var ShellMenuChoice		GamepadChoice;
var localized string	GamepadControlsText;
var localized string	GamepadControlsHelp;

var ShellMenuChoice		GamepadChoice2;
var localized string	GamepadControlsText2;
var localized string	GamepadControlsHelp2;

var ShellMenuChoice		InputChoice;
var localized string	InputText;
var localized string	InputHelp;

var ShellMenuChoice		H2PChoice;
var localized string	H2PText;
var localized string	H2PHelp;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	AddTitle(ControlsTitleText, TitleFont, TitleAlign);

	MovementChoice		= AddChoice(MovementControlsText	, MovementControlsHelp,	ItemFont, ItemAlign);
	ActionsChoice		= AddChoice(ActionsControlsText		, ActionsControlsHelp,	ItemFont, ItemAlign);
	WeaponChoice		= AddChoice(WeaponControlsText		, WeaponControlsHelp,	ItemFont, ItemAlign);
	WeaponChoice2		= AddChoice(WeaponControlsText2		, WeaponControlsHelp2,	ItemFont, ItemAlign);
	InvChoice			= AddChoice(InvControlsText			, InvControlsHelp,		ItemFont, ItemAlign);
	MiscChoice			= AddChoice(MiscControlsText		, MiscControlsHelp,		ItemFont, ItemAlign);
	if (Class'MenuMain'.default.bShowMP)
		MultiChoice			= AddChoice(MultiControlsText		, MiscControlsHelp,		ItemFont, ItemAlign);
	GamepadChoice		= AddChoice(GamepadControlsText		, GamepadControlsHelp,	ItemFont, ItemAlign);
	GamepadChoice2		= AddChoice(GamepadControlsText2	, GamepadControlsHelp2,	ItemFont, ItemAlign);
	//DisplayChoice		= AddChoice(DisplayControlsText		, DisplayControlsHelp,	ItemFont, ItemAlign);
	InputChoice			= AddChoice(InputText				, InputHelp,			ItemFont, ItemAlign);
	H2PChoice			= AddChoice(H2PText				    , H2PHelp,			    ItemFont, ItemAlign);

	BackChoice			= AddChoice(BackText 				, "", ItemFont, ItemAlign, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local ShellMenuCW		mnuNext;

	Super.Notify(C, E);
	switch (E)
		{
		case DE_Change:
			switch (C)
				{
				}
			break;
		case DE_Click:
			switch (C)
				{
				case MovementChoice		:
					mnuNext = GoToMenu(class'MenuControlsEditMovement');
					break;
				case ActionsChoice			:
					mnuNext = GoToMenu(class'MenuControlsEditActions');
					break;
				case WeaponChoice		:
					mnuNext = GoToMenu(class'MenuControlsEditWeapons');
					break;
				case WeaponChoice2		:
					mnuNext = GoToMenu(class'MenuControlsEditWeapons2');
					break;
				case InvChoice		:
					mnuNext = GoToMenu(class'MenuControlsEditInv');
					break;
				case MiscChoice		:
					mnuNext = GoToMenu(class'MenuControlsEditMisc');
					break;
				case MultiChoice		:
					mnuNext = GoToMenu(class'MenuControlsEditMulti');
					break;
				case GamepadChoice		:
					mnuNext = GoToMenu(class'MenuControlsEditGamepad');
					break;
				case GamepadChoice2		:
					mnuNext = GoToMenu(class'MenuControlsEditGamepad2');
					break;
				case DisplayChoice		:
					mnuNext = GoToMenu(class'MenuControlsEditDisplay');
					break;
				case InputChoice		:
					mnuNext = GoToMenu(class'MenuInput');
					break;
				case H2PChoice		    :
                    if (PlatformIsSteamDeck())
                        mnuNext = GoToMenu(class'MenuImageH2P_SteamDeck');
                    else
                        mnuNext = GoToMenu(class'MenuImageH2P');
					break;
				case BackChoice:
					GoBack();
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	MenuWidth	= 325	// 02/01/03 JMI Decreased menu size for better centered
						//				appearance.
	HintLines	= 4		// 02/01/03 JMI Increased hint lines b/c we made this menu
						//				even thinner.

	ControlsTitleText			= "Controls"

	MovementControlsText		= "Movement"
	MovementControlsHelp		= "Edit controls for character movement"

	ActionsControlsText			= "Actions"
	ActionsControlsHelp			= "Edit controls for character actions"

	WeaponControlsText			= "Weapons"
	WeaponControlsHelp			= "Edit controls for using weapons"

	WeaponControlsText2			= "Weapon Groups"
	WeaponControlsHelp2			= "Edit controls for changing weapon groups"

	InvControlsText				= "Inventory"
	InvControlsHelp				= "Edit controls for changing and using inventory items"

	MiscControlsText			= "Miscellaneous"
	MiscControlsHelp			= "Edit controls for things like pause and taking screenshots"

	MultiControlsText			= "Multiplayer"
	MultiControlsHelp			= "Edit controls for multiplayer communications"

	DisplayControlsText			= "Display"
	DisplayControlsHelp			= "Edit controls for modifying the display"

	GamepadControlsText			= "Menu Navigation"
	GamepadControlsHelp			= "Edit controls for navigating menus"

	GamepadControlsText2		= "Gamepad Movement"
	GamepadControlsHelp2		= "Edit controls on your gamepad"

	InputText			= "Input Config"
	InputHelp			= "Edit your mouse and gamepad options"

	H2PText			= "How to Play"
	H2PHelp			= "Shows the default control layout."
	}
