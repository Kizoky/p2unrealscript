///////////////////////////////////////////////////////////////////////////////
// MenuPerformance.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The Performance menu.
//
// History:
//	01/13/03 JMI	Added strHelp parameter to AddChoice() allowing us to pass
//					in many help strings that had been created but were not 
//					being used for standard menu choices.  Added generic 
//					RestoreHelp for menus sporting a Restore option.
//
//	01/12/03 JMI	Started.
//
///////////////////////////////////////////////////////////////////////////////
//
// This menu displays the two ways of adjusting performance.
//
///////////////////////////////////////////////////////////////////////////////
class MenuPerformance extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized String PerformanceTitleText;

var ShellMenuChoice		WizardChoice;
var localized string	WizardText;
var localized string	WizardHelp;

var ShellMenuChoice		AdvancedChoice;
var localized string	AdvancedText;
var localized string	AdvancedHelp;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	AddTitle(PerformanceTitleText, TitleFont, TitleAlign);

	WizardChoice	= AddChoice(WizardText,		WizardHelp,		ItemFont, ItemAlign);
	AdvancedChoice	= AddChoice(AdvancedText,	AdvancedHelp,	ItemFont, ItemAlign);
	BackChoice		= AddChoice(BackText,		"",				ItemFont, ItemAlign, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Callback for when control has changed
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);
	
	switch (E)
		{
		case DE_Click:
			switch (C)
				{
				case WizardChoice:
					GotoMenu(class'MenuPerformanceWizard');
					break;
				case AdvancedChoice:
					GotoMenu(class'MenuPerformanceAdvanced');
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
	MenuWidth = 400	// 01/26/03 JMI Made this menu thinner as it was unnecessarily wide.

	PerformanceTitleText = "Performance"

	WizardText = "Use Performance Wizard..."
	WizardHelp = "Wizard to automatically adjust performance via hardware detection";
	
	AdvancedText = "Adjust Settings Manually..."
	AdvancedHelp = "A menu to fine tune detailed performance options for advanced users";
	}
