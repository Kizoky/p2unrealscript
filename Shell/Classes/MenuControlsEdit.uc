///////////////////////////////////////////////////////////////////////////////
// MenuControlsEdit.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The controls editing menu work class.
//
///////////////////////////////////////////////////////////////////////////////
//
// This is the base class for the input editing classes.  This class performs
// the editing interaction based on the set of inputs provided by the derived
// class.
//
// It's tempting to create a single class that has n arrays of inputs.  When
// creating the class, one would specify which set of inputs to edit; however,
// in the spirit of Unreal, I'll try to stick with the program.
//
// TODO:
//		Make new setup work properly on any resolution - K
//
///////////////////////////////////////////////////////////////////////////////
class MenuControlsEdit extends ShellMenuCW;
/*
	config(user);	// 01/15/03 JMI Indicates that this class' config values are
					//				store in DefUser/User.ini (as opposed to 
					//				Default/Postal2.ini).
*/

///////////////////////////////////////////////////////////////////////////////
// Typedefs.
///////////////////////////////////////////////////////////////////////////////

// This is the type returned from the derived classes indicating the controls
// to be edited on this menu instance.
struct Control
{
	var string				strAlias;	// The alias used to invoke the input.
	
	//ErikFOV Change: for localization
	//var localized string	strLabel;	// The label for the user to reference the input in
	//end
										// the menu system.										
	var bool				bNoClear;	// If true, won't unbind this input automatically. (GameOverRestart etc.)
	var bool				bIsAxis;	// If true, this is an "axis" binding and will match anything that starts with this binding
};

// Type for initialization of default keys from INI.
struct Default
{
	var string				alias;	// The alias used to invoke the input.
	var string				key;	// The name of the key that is the default.  Mapped back to input value at runtime.
	var string				cat;	// The category the key belongs to (e.g., "WADS", "Mouse", "Joystick").
};


// This is where the type binding info is stored in while editing bindings.
struct Binding
{
	var	Control				ctrl;		// The control alias and label (e.g., MoveLeft & Move Left)
	var	array<int>			aiKeys;		// The keys mapped to this control (parallel with astrKeys).
	var	array<string>		astrKeys;	// The names of the keys mapped to this control (parallel with aiKeys).
	var ShellInputControl	win;		// The window corresponding to this binding info.
};

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

const c_NumKeys = 255;
const c_strActivelyAcquiringText = "? ? ?";

var array<Binding>		aBindings;	// The binding info with controls and key names.
var array<string>		aBaselines;	// Indexed by key.  Values for keys that this instance
									// of the menu does not understand and therefore must
									// be maintained.  For example, bWantsToSkip isn't on
									// any menu and would, otherwise, get clobbered by any 
									// menu if someone used the space key for another input.
var ShellInputControl	winFocused;	// Widget, if any, receiving key input.

var /*config*/ array<Default>	Defaults;		// Array of default keys to be initialized from INI.
var /*config*/ array<string>	Categories;	// Array of categories for default keys to be initialized from INI.

// 11/28/02 JMI Made help prefix text for inputs localizable.
var localized string InputHelpPrefix;
var localized string InputHelpPostfix;

// 02/01/03 JMI Changed to actually having all these arrays available in the base
//				class.  GetControls still returns the one we're working on in the
//				current menu, though.  Having them all here is mostly just so we
//				can identify all mappable controls.

//ErikFOV Change: for localization
var localized array<String>	aActionControlsLabel;
var localized array<String>	aDisplayControlsLabel;
var localized array<String>	aInvControlsLabel;
var localized array<String>	aMiscControlsLabel;
var localized array<String>	aMultiControlsLabel;
var localized array<String>	aMovementControlsLabel;
var localized array<String>	aWeaponControlsLabel;
var localized array<String>	aWeaponControls2Label;
var localized array<String>	aSayControlsLabel;
var localized array<String>	aTeamSayControlsLabel;
var localized array<String>	aGamepadControlsLabel;
var localized array<String>	aGamepadControls2Label;
//end
	
var array<Control>	aActionControls;
var array<Control>	aDisplayControls;
var array<Control>	aInvControls;
var array<Control>	aMiscControls;
var array<Control>	aMultiControls;
var array<Control>	aMovementControls;
var array<Control>	aWeaponControls;
var array<Control>	aWeaponControls2;
var array<Control>	aSayControls;
var array<Control>	aTeamSayControls;
var array<Control>	aGamepadControls;
var array<Control>	aGamepadControls2;

// Workaround for "holding the button down" glitch (controllers only)
var EInputKey HoldingButton;

var Texture Blank;

var bool bRejectNextInput;	// Hack to block binding certain keys
var localized string MultiBindWarningTitle, MultiBindWarningText;	// Warn user if they bind something to a menu navigation key


///////////////////////////////////////////////////////////////////////////////
// Functions.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Add an keypress widget to the menu
///////////////////////////////////////////////////////////////////////////////
function ShellInputControl AddKeyWidget(String strText, String strHelp, int Font, int iBindIndex)
	{
	local ShellInputControl ctl;

	ctl = ShellInputControl(CreateControl(class'ShellInputControl', GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, ItemHeight));
	ctl.SetFont(Font);
	ctl.SetInputFont(-1, Font);	// 11/17/02 JMI Override so we can fit many keys.
	ctl.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.SetInputTextColor(-1, ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.SetInputTextAlign(-1, TA_Center);	// 02/02/03 JMI Added ability to center text in editboxes.
	ctl.SetText(strText);
	ctl.TextY = ItemHeight/2 - 8;
	ctl.SetHelpText(strHelp);
	ctl.Align = TA_Left;
	ctl.iBindIndex = iBindIndex;
	AddItem(ctl, ItemHeight + ItemSpacingY);
	return ctl;
	}

///////////////////////////////////////////////////////////////////////////////
// Create the actual menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local array<Control>			aControls;
	//ErikFOV Change: for localization
	local array<String>			aControlsLabel;
	//end
	local int						iIter;
	local ShellInputControl			ctl;
	local ShellMenuChoice			chHeader;
	
	Super.CreateMenuContents();

	TitleAlign = TA_Center;

	// 01/19/03 JMI Set the font even smaller b/c the Weapons menu has too many 
	//				items and some descriptions are wide.
	// 11/24/02 JMI This menu could be huge..use a smaller font than was set by
	//				the base class.
	ItemFont	= F_FancyS;

	// Be sure we start clean.
	aBindings.Length = 0;

	//ErikFOV Change: for localization
	//aControls = GetControls();
	GetControls(aControls,aControlsLabel);
	//end
	
	for (iIter = 0; iIter < aControls.Length; iIter++)
	{
		// Note that eventually we'll have another array or member that indicates
		// the type of control each input control needs to be edited with.
		// For now, a simple edit field will do.  This will probably be a ctrl
		// dervied from an edit field in the long run that can grab a key and,
		// perhaps even, list and store up to two key names.
		aBindings.Length		= aBindings.Length + 1;
		//aBindings[iIter].icon	= ShellBitmap(CreateWindow(class'ShellBitmap',GetNextItemPosX(),GetNextItemPosY(),32,32));
		
		//ErikFOV Change: for localization
		//aBindings[iIter].win	= AddKeyWidget(aControls[iIter].strLabel, InputHelpPrefix$aControls[iIter].strLabel$InputHelpPostfix, F_FancyS, iIter);
		aBindings[iIter].win	= AddKeyWidget(aControlsLabel[iIter], InputHelpPrefix$aControlsLabel[iIter]$InputHelpPostfix, F_FancyS, iIter);
		//end
		
		//Log("Iter:"@iIter@"Control:"@aControls[iIter].strAlias@aControls[iIter].strLabel);
	}

	// 02/02/03 JMI Add column headers.  Now that we solved the editbox height problem, we have more vertical room.
	if (aControls.Length > 0 && aBindings[0].win != none)
	{
		for (iIter = 0; iIter < aBindings[0].win.aInputs.Length; iIter++)
		{
			chHeader = ShellMenuChoice(CreateWindow(
				class'ShellMenuChoice', 
				aBindings[0].win.WinLeft + aBindings[0].win./*aInputs*/aIcons[iIter].WinLeft,	
				aBindings[0].win.WinTop  + aBindings[0].win./*aInputs*/aIcons[iIter].WinTop - (20/*ItemHeight*/ + ItemSpacingY), 
				/*aBindings[0].win.aInputs[iIter].WinWidth +*/ aBindings[0].win.aIcons[iIter].WinWidth,	16/*aBindings[0].win.aInputs[iIter].WinHeight*/) );
			
			chHeader.Align = TA_Center;
			chHeader.SetFont(ItemFont);
			chHeader.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
			chHeader.SetText("Input"@(iIter + 1) );
			chHeader.bActive = false;
		}
	}

	// Load the values into the menu items.
	LoadValues();

	RestoreChoice	= AddChoice(RestoreText,	RestoreHelp,	ItemFont, ItemAlign);
	BackChoice		= AddChoice(BackText,		"",				ItemFont, ItemAlign, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Trim the specified character from the ends of the string.
///////////////////////////////////////////////////////////////////////////////
function string Trim(string strSrc, string strRemove)
{
	local int iPos;
	local int iRemLen;

	iRemLen = Len(strRemove);

	// Pull occurences at beginning.
	while (Left(strSrc, iRemLen) == strRemove)
	{
		// Trim.
		strSrc = Right(strSrc, Len(strSrc) - iRemLen);
	}
	
	// Pull occurences at end.
	while (Right(strSrc, iRemLen) == strRemove)
	{
		// Trim.
		strSrc = Left(strSrc, Len(strSrc) - iRemLen);
	}

	return strSrc;
}

///////////////////////////////////////////////////////////////////////////////
// Split a string at a particular delimiter.
///////////////////////////////////////////////////////////////////////////////
function array<string> Split(string strSplit, string strDelimiter)
{
	local int iNext;
	local int iLen;
	local int iIter;
	local int iDelimLen;
	local array<string> astr;

	iNext = 0;
	iIter = 0;
	iDelimLen = Len(strDelimiter);
	do 
	{
		// Find next delimiter.
		iNext = InStr(strSplit, strDelimiter);
		if (iNext > -1) 
			iLen = iNext;
		else
			iLen = Len(strSplit);
		// Copy up to that spot into a new entry in the array.
		astr.Length = iIter + 1;
		astr[iIter] = Trim(Left(strSplit, iLen), " ");
		iIter = astr.Length;
		// Pull out that string + the delim.
		strSplit = Right(strSplit, Len(strSplit) - iLen - iDelimLen);
	} until (iNext == -1);

	return astr;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if string matches, taking bIsAxis into account
///////////////////////////////////////////////////////////////////////////////
function bool IsBinding(string CheckBind, Control CheckCtrl)
{
	if (CheckCtrl.bIsAxis)
		return (Instr(Caps(CheckBind),"AXIS"@Caps(CheckCtrl.strAlias)) >= 0);
	else
		return (CheckBind ~= CheckCtrl.strAlias);
}

///////////////////////////////////////////////////////////////////////////////
// Remove all known inputs from the specified string.  This allows us to keep
// a base line set of unknown inputs that we can be sure to maintain while
// changing key mappings.
///////////////////////////////////////////////////////////////////////////////
function string RemoveKnownInputs(string strInputs, out array<Control> aControls)
{
	local int			iInput;
	local int			iCtrl;
	local bool			bFound;
	local array<string> astrInputs;

	astrInputs = Split(strInputs, "|");

	strInputs = "";	// Reset the string.

	// Reconstruct the string with only the ones we do -not- recognize.
	for (iInput = 0; iInput < astrInputs.Length; iInput++)
	{
		bFound = false;
		for (iCtrl = 0; iCtrl < aControls.Length && !bFound; iCtrl++)
		{
			if (!aControls[iCtrl].bNoClear)
				bFound = IsBinding(astrInputs[iInput], aControls[iCtrl]);
		}

		// If not found, keep it.
		if (!bFound)
		{
			// If there's already something there, use a delimiter.
			if (Len(strInputs) > 0)
				strInputs = strInputs $ " | ";
			strInputs = strInputs $ astrInputs[iInput];
		}
	}

	return strInputs;
}

// Remove specified input from binding
function RemoveThisInput(string strkey, Control ctrl)
{
	local int			iInput;
	local int			iCtrl;
	local bool			bFound;
	local string		strInputs;
	local array<string> astrInputs;

	strInputs = GetPlayerOwner().ConsoleCommand("KEYBINDING"@StrKey);

	astrInputs = Split(strInputs, "|");

	strInputs = "";	// Reset the string.

	// Reconstruct the string without the stated binding
	for (iInput = 0; iInput < astrInputs.Length; iInput++)
	{
		bFound = IsBinding(astrInputs[iInput], Ctrl);

		// If not found, keep it.
		if (!bFound)
		{
			// If there's already something there, use a delimiter.
			if (Len(strInputs) > 0)
				strInputs = strInputs $ " | ";
			strInputs = strInputs $ astrInputs[iInput];
		}
	}

	//log("removethisinput: set input"@StrKey@StrInputs);
	GetPlayerOwner().ConsoleCommand("SET Input"@strKey@strInputs);
}

///////////////////////////////////////////////////////////////////////////////
// Add/Set a key to the specified binding.
///////////////////////////////////////////////////////////////////////////////
function SetKey(out Binding bind, int iKey, int iColumn)	// iColumn = -1 to add
{
	local int iCur;

	if (iColumn == -1)
	{
		// Get current number of elements.
		iCur					= bind.aiKeys.Length;
		// 01/15/03 JMI It seems that indexing an array with a value greater than
		//				its Length as a lhs automagically increases the size and,
		//				therefore, it seems the below length adjustments are not
		//				necessary.
		// Adjust arrays' lengths.
		// bind.aiKeys.Length	= iCur + 1;
		// bind.astrKeys.Length	= bind.aiKeys.Length;
	}
	else
		iCur					= iColumn;

	// Store bindings.
	bind.aiKeys[iCur]		= iKey;
	bind.astrKeys[iCur]		= GetKeyName(iKey);
}

///////////////////////////////////////////////////////////////////////////////
// Unload value.
///////////////////////////////////////////////////////////////////////////////
function UnloadValue(out Binding bind)
{
	bind.aiKeys.Length = 0;
	bind.astrKeys.Length = 0;
}

///////////////////////////////////////////////////////////////////////////////
// Unload all values.
///////////////////////////////////////////////////////////////////////////////
function UnloadValues()
{
	local int iIter;
	for (iIter = 0; iIter < aBindings.Length; iIter++)
	{
		UnloadValue(aBindings[iIter] );
	}
}

///////////////////////////////////////////////////////////////////////////////
// Load a value from ini file
///////////////////////////////////////////////////////////////////////////////
function LoadValue(Control ctrl, out Binding bind)
{
	local int		iIter;
	local int		iKey;
	local int i;
	
	// Start each element clean.
	UnloadValue(bind);

	// Store the control alias.
	bind.ctrl = ctrl;
	
	// For each command, we ask for the key mapped to the command passing an enumerator
	// until the function returns 0.
	iIter = 0;
	//while( GetCommandKey( ctrl.strAlias, key, strKey, iIter ) ) 

	// If this is an axis, we have to approach it in a different fashion.
	if (ctrl.bIsAxis)
	{
		do
		{
			iKey = int(GetPlayerOwner().ConsoleCommand("FINDAXIS"@ctrl.strAlias@iIter));
			if (iKey != 0)
				SetKey(bind, iKey, -1);
			iIter++;
		} until (iKey == 0);
	}
	else
	{
		do
		{
			iKey = int(GetPlayerOwner().ConsoleCommand("BINDING2KEYVAL \""$ctrl.strAlias$"\""@iIter) );
			if (iKey != 0)
			{
				SetKey(bind, iKey, -1);
			}
			
			iIter++;
		} until (iKey == 0);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Load the binding info into existing menu items.
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
{
	local array<Control>			aControls;
	//ErikFOV Change: for localization
	local array<String>			aControlsLabel;
	//end
	local int						iIter;
	local int						iKey;
	
	//ErikFOV Change: for localization
	//aControls = GetControls();
	GetControls(aControls,aControlsLabel);
	//end
	
	aBaselines.Length = c_NumKeys;
	// Remember input values that we do not understand for each key they are mapped to.
	for (iIter = 0; iIter < aBaselines.Length; iIter++)
	{
		aBaselines[iIter] = GetPlayerOwner().ConsoleCommand("KEYBINDING"@GetKeyName(iIter) );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aActionControls  );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aDisplayControls );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aInvControls     );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aMiscControls    );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aMultiControls   );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aMovementControls);
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aWeaponControls  );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aWeaponControls2 );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aSayControls     );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aTeamSayControls );
		aBaselines[iIter] = RemoveKnownInputs(aBaselines[iIter], aGamePadControls );
	}

	for (iIter = 0; iIter < aControls.Length; iIter++)
	{
		LoadValue(aControls[iIter], aBindings[iIter] );
		// 01/22/03 JMI Sort keys in order by defaults so they appear in a more
		//				intelligible order with respect to other keys in the
		//				same variation (they'll be aligned in columns).
		SortKeysByDefaults(aBindings[iIter] );

		ShowKeyStrs(aBindings[iIter] );
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to defaults.
// NOTE: aBaselines should already be setup.  Cannot see how that could not 
// happen but just in case.
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
{
	local int iIter;
	local int iDef;
	//log("SetDefaultValues()");
	for (iIter = 0; iIter < aBindings.Length; iIter++)
	{
		//log("Processing"@aBindings[iIter].Ctrl.strLabel);
		// Clear the existing values.
		ClearValue(aBindings[iIter] );
		// Unload them.
		UnloadValue(aBindings[iIter] );
		//log("Bindings cleared and unloaded");

		// Load new ones from defaults.
		for (iDef = 0; iDef < Defaults.Length; iDef++)
		{
			// If this matches this binding, add it.
			if (IsBinding(Defaults[iDef].alias, aBindings[iIter].ctrl))
			//if (Defaults[iDef].alias == aBindings[iIter].ctrl.strAlias)
				SetKey(aBindings[iIter], GetKey(Defaults[iDef].key), -1);
		}

		// Set these values as they're otherwise never reflected in the INI since there's
		// no final OK or Done.
		SetValue(aBindings[iIter] );
		// 01/22/03 JMI Sort keys in order by defaults so they appear in a more
		//				intelligible order with respect to other keys in the
		//				same variation (they'll be aligned in columns).
		SortKeysByDefaults(aBindings[iIter] );

		ShowKeyStrs(aBindings[iIter] );
	}

	// Play big sound when done so we know it finished.
	LookAndFeel.PlayBigSound(self);
}

///////////////////////////////////////////////////////////////////////////////
// Find the specified key in the given array.
///////////////////////////////////////////////////////////////////////////////
function int FindStr(out array<string> astrs, string str)
{
	local int iIter;
	for (iIter = 0; iIter < astrs.Length; iIter++)
	{
		if (astrs[iIter] == str)
			return iIter;
	}
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// Sort the key strings in the order the defaults are presented.  This helps
// to show the various schemes in common columns making them more recognizable.
// 01/22/03 JMI Started.
///////////////////////////////////////////////////////////////////////////////
function SortKeysByDefaults(out Binding bind)
{
	local int iCatPos;
	local int iDef;
	local int iKeyPos;
	local int iKeyTemp;

	// If there are no categories, this would probably be pointless.
	if (Categories.Length > 0)
	{
		// First, find the defaults for this input.
		for (iDef = 0; iDef < Defaults.Length; iDef++)
		{
			// If this matches this binding . . .
			if (Defaults[iDef].alias == bind.ctrl.strAlias)
			{
				// If we have this key mapped . . .
				iKeyPos = FindStr(bind.astrKeys, Defaults[iDef].key);
				if (iKeyPos >= 0)
				{
					// 02/05/03 JMI Now find the position of the category for this key.
					iCatPos = FindStr(Categories, Defaults[iDef].cat);
					if (iCatPos >= 0)
					{
						// Move the key from its current position to the position of this default relative to
						// other deafults for this same alias.
						iKeyTemp	= bind.aiKeys[iKeyPos];

						// Note that we already know that iKeyPos is less than the array length b/c we found
						// this key in that array.
						if (bind.astrKeys.Length <= iCatPos)
						{
							// No swapping necessary but let's keep it simple and just increase the size
							// and perform the normal code.
							bind.astrKeys.Length = iCatPos + 1;
							bind.aiKeys.Length   = iCatPos + 1;
						}
						
						bind.astrKeys[iKeyPos]	= bind.astrKeys[iCatPos];
						bind.aiKeys[iKeyPos]	= bind.aiKeys[iCatPos];
						
						bind.astrKeys[iCatPos]	= Defaults[iDef].key;
						bind.aiKeys[iCatPos]	= iKeyTemp;
					}
					//else
						//Log(self@"discovered default whose category, \""$Defaults[iDef].cat$"\", is not in the array of categories.");
				}
			}
		}
	}
	//else
		//Log(self@"discovered there are no entries in the array of categories.");
}

///////////////////////////////////////////////////////////////////////////////
// Set key string into the corresponding control. 
// 01/14/03 JMI Changed to set the value in the specified input control.
///////////////////////////////////////////////////////////////////////////////
function ShowKeyStr(Binding bind, int iInput)
{
	local string strKey;
	if (iInput >= 0 && iInput < bind.astrKeys.Length)
	{
		strKey = bind.astrKeys[iInput];
		bind.win.SetValue(iInput, strKey, FPSHUD(GetPlayerOwner().MyHud).MyButtons.GetIcon(bind.aiKeys[iInput]));
	}
	else
		bind.win.SetValue(iInput, strKey, Blank);
	
	/*
	// overlay control icon for testing	
	bind.icon.bStretch = true;	// This value can be overridden by the extender.
	bind.icon.bAlpha   = true;	// This value can be overridden by the extender.
	bind.icon.bFit	   = false;	// This value can be overridden by the extender.
	bind.icon.bCenter  = false;	// This value can be overridden by the extender.
	if (bind.aiKeys[iInput] == 0)
		bind.icon.T = None;
	else
		bind.icon.T = FPSHUD(GetPlayerOwner().MyHud).MyButtons.GetIcon(bind.aiKeys[iInput]);
	bind.icon.R.X = 0;
	bind.icon.R.Y = 0;
	bind.icon.R.W = bind.icon.T.USize;
	bind.icon.R.H = bind.icon.T.VSize;
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Set key strings into each corresponding control. 
// 01/14/03 JMI Changed to update a set number of fields rather than just the
// number of inputs.
///////////////////////////////////////////////////////////////////////////////
function ShowKeyStrs(out Binding bind)
{
	local int iIter;

	for (iIter = 0; iIter < bind.win.c_iNumInputsPerControl; iIter++)
	{
		ShowKeyStr(bind, iIter);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make a group of bound keys into a string.
///////////////////////////////////////////////////////////////////////////////
function string MakeKeyStr(Binding bind)
{
	local int iIter;
	local string str;
	for (iIter = 0; iIter < bind.astrKeys.Length; iIter++)
	{
		if (iIter > 0)
		{
			if (iIter < bind.astrKeys.Length - 1)
				str = str $ ", ";
			else
				str = str $ " or ";
		}

		str = str $ bind.astrKeys[iIter];
		// 12/05/02 JMI If there's another mapping outside this menu, show it.  
		// This might be weird.  Added it for debugging and thought it was a nice
		// thing for the user to be aware of--it's just not obvious what this 
		// means so it might be confusing to the user.
		if (Len(aBaseLines[bind.aiKeys[iIter] ] ) > 0)
			str = str@"("$aBaselines[bind.aiKeys[iIter] ]$")";
	}
	return str;
} 

///////////////////////////////////////////////////////////////////////////////
// Set the stored value.
///////////////////////////////////////////////////////////////////////////////
function SetValue(out Binding bind)
{
	local string strAliases;
	local int	 iIter, i;
	local array<String> aStrAliases;	
	local bool bFound;
	local bool bMultipleBindWarning;
	
	for (iIter = 0; iIter < bind.astrKeys.Length; iIter++)
	{
		if (Len(bind.astrKeys[iIter] ) > 0)
		{
			// Start with baseline (keys we don't know about in this menu), if any.
			strAliases = aBaselines[bind.aiKeys[iIter] ];
			
			// If a "no clear" binding, start with ENTIRE keybind
			if (bind.ctrl.bNoClear)
				strAliases = GetPlayerOwner().ConsoleCommand("KEYBINDING"@bind.aStrKeys[iIter]);
			
			// Ignore if already bound somehow.
			aStrAliases = Split(strAliases, "|");
			bFound = false;
			for (i = 0; i < aStrAliases.Length; i++)
				if (IsBinding(aStrAliases[i], bind.ctrl))
					bFound = true;

			if (!bFound)
			{
				// If there's anything so far, use a delimiter.
				if (Len(strAliases) > 0)
					strAliases = strAliases $ " | ";
				strAliases = strAliases $ bind.ctrl.strAlias;

				//log("setvalue: set input"@bind.aStrKeys[iIter]@StrAliases);
				GetPlayerOwner().ConsoleCommand("SET Input"@bind.astrKeys[iIter]@strAliases);
				if (Len(strAliases) > 0 && (
					InStr(strAliases, "MenuUpButton") > -1 ||
					InStr(strAliases, "MenuDownButton") > -1 ||
					InStr(strAliases, "MenuLeftButton") > -1 ||
					InStr(strAliases, "MenuRightButton") > -1
					))
					bMultipleBindWarning = true;
			}
		}
	}
	
	if (bMultipleBindWarning)
		MessageBox(MultiBindWarningTitle, MultiBindWarningText, MB_OK, MR_OK, MR_OK);
}

///////////////////////////////////////////////////////////////////////////////
// Clear the stored value for this key.
///////////////////////////////////////////////////////////////////////////////
function ClearKey(string strKey, int iKey)
{
	// 01/15/03 JMI Addition of use of -1 to indicate a no-key state (instead
	//				removing entries) was causing an array-out-of-bounds here.
	//				Added check.
	//log("ClearKey"@strKey@iKey);
	if (iKey >= 0)
	{
		//log("clearkey: set input"@strKey@aBaselines[iKey]);
		GetPlayerOwner().ConsoleCommand("SET Input"@strKey@aBaseLines[iKey] );
	}
}

///////////////////////////////////////////////////////////////////////////////
// Clear the stored keys for this input.
///////////////////////////////////////////////////////////////////////////////
function ClearValue(out Binding bind)
{
	local int iIter;
	//log("ClearValue for"@bind.ctrl.strLabel@"length"@bind.aStrKeys.Length);
	if (bind.ctrl.bNoClear)
	{
		//log("NoClear is true - NOT clearing value!");
		return;
	}
	for (iIter = 0; iIter < bind.astrKeys.Length; iIter++)
	{	
		ClearKey(bind.astrKeys[iIter], bind.aiKeys[iIter] );
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set the stored values.
///////////////////////////////////////////////////////////////////////////////
function SetValues()
{
	local int						iIter;
	for (iIter = 0; iIter < aBindings.Length; iIter++)
	{
		SetValue(aBindings[iIter]);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Remove the key from the specified binding.
// 01/14/03 JMI Changed to simply replace the specified key with nothing rather
//				than reduce the size of the array.
///////////////////////////////////////////////////////////////////////////////
function RemoveBinding(out Binding bind, EInputKey key)
{
	local int			iKey;
	local bool			bChanged;

	bChanged = false;
	for (iKey = 0; iKey < bind.aiKeys.Length; iKey++)
	{
		// If this is the key we want to remove, blank it out.
		if (bind.aiKeys[iKey] == key)
		{
			// Clear the corresponding key.
			ClearKey(bind.astrKeys[iKey], bind.aiKeys[iKey] );
			SetKey(bind, -1, iKey);
			bChanged = true;
		}
	}

	// If we made any changes, update the UI.
	if (bChanged)
		// Update UI.
		ShowKeyStrs(bind);
}

///////////////////////////////////////////////////////////////////////////////
// Remove the key from all existing bindings.
///////////////////////////////////////////////////////////////////////////////
function RemoveBindings(EInputKey key)
{
	local int		iBinding;
	// Check for existing instances of this value.
	for (iBinding = 0; iBinding < aBindings.Length; iBinding++)
	{
		RemoveBinding(aBindings[iBinding], key);
	}

}

///////////////////////////////////////////////////////////////////////////////
// Get the name of the specified key.
///////////////////////////////////////////////////////////////////////////////
function string GetKeyName(int iKey)
{
	return GetPlayerOwner().ConsoleCommand("KEYNAME"@iKey);
}

///////////////////////////////////////////////////////////////////////////////
// Find a key from a name.  This is not fast but is only done for the number
// of inputs on this menu and when "Restore" is chosen.
///////////////////////////////////////////////////////////////////////////////
function int GetKey(string strKey)
{
	local int iKey;

	for (iKey = 0; iKey < 255; iKey++)
	{
		if (GetKeyName(iKey) == strKey)
			return iKey;
	}

	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// Add a key to the specified binding.
///////////////////////////////////////////////////////////////////////////////
function SetBinding(int iBindIndex, EInputKey key, int iColumn)	// iColumn = -1 to add
{
	local Binding	bind;
	local int		iIter;
	if (iBindIndex >= aBindings.Length)
		return ;
	
	// Alias for convenience.
	bind	     = aBindings[iBindIndex];
	
	// Check for existing instance of this value.
	for (iIter = 0; iIter < bind.aiKeys.Length; iIter++)
	{
		// This key is already there.
		if (bind.aiKeys[iIter] == key)
			return ;
	}
	
	// Remove this key from all its existing bindings.
	// But only if it's not a "no clear" binding (some bindings like GameOverRestart can be bound to an already-used key/button)
	if (!bind.Ctrl.bNoClear)
		RemoveBindings(key);

	// Clear the existing key in this slot.
	if (iColumn >= 0 && iColumn < bind.astrKeys.Length && !bind.Ctrl.bNoClear)	// -1 indicates an add so we aren't overwriting any keys.
	{
		// 02/01/03 JMI Added clearing of existing key.  Although, we were removing it from our structures
		//				we were not actually clearing the value in the Engine/INI so the key would remain.
		//				We are doing this in RemoveBindingForWidget so not sure why I missed this case.
		ClearKey(bind.astrKeys[iColumn], bind.aiKeys[iColumn] );
	}

	// Set the key.
	SetKey(bind, key, iColumn);

	// Update UI.
	ShowKeyStrs(bind);

	// Update global.  Yeah, this is ridiculous.
	aBindings[iBindIndex] = bind;

	// Update binding right away.  Normally, we'd wait until the menu exits 
	// but I cannot see how we hook that--we used to have an OnChoice but I
	// cannot find that.  This could be fine but it means no canceling.
	SetValue(bind);
}

///////////////////////////////////////////////////////////////////////////////
// Activate a control to scan for input.
///////////////////////////////////////////////////////////////////////////////
function SetNewBindingTarget(ShellInputControl ctrl)
{
	// If there's an existing ctrl, tell it to exit the mode.
	if (winFocused != none)
	{
		winFocused.SetTargetStatus(winFocused.iCurCtrl, false);
		winFocused.Select(winFocused.iCurCtrl, false);
		// Take the focus away.
		BackChoice.FocusWindow();
		// Make sure to show the key.
		ShowKeyStrs(aBindings[winFocused.iBindIndex] );
	}

	// Set new target, if any.
	winFocused = ctrl;
	
	// If there's a new ctrl, tell it to enter the mode.
	if (winFocused != none)
	{
		winFocused.SetTargetStatus(winFocused.iCurCtrl, true);
		winFocused.SetValue(ctrl.iCurCtrl, c_strActivelyAcquiringText);
		// 12/03/02 JMI Changed to using bAllSelected directly (instead of SelectAll() )
		//				b/c we changed the fields to non-editable.
		winFocused.Select(ctrl.iCurCtrl, true);	
	}

}

///////////////////////////////////////////////////////////////////////////////
// Remove all bindings from the input controlled by the specified
// binding/control index.
///////////////////////////////////////////////////////////////////////////////
function RemoveAllBindingsForInput(int iBindIndex)
{
	if (iBindIndex >= aBindings.Length)
		return;

	// Clear the stored value.
	ClearValue(aBindings[iBindIndex] );

	// Just empty the arrays and update the fields.
	aBindings[iBindIndex].aiKeys.Length		= 0;
	aBindings[iBindIndex].astrKeys.Length	= 0;
	
	// Update UI.
	ShowKeyStrs(aBindings[iBindIndex] );
}

///////////////////////////////////////////////////////////////////////////////
// Remove all bindings from the input referred to by the specified widget.
///////////////////////////////////////////////////////////////////////////////
function RemoveAllBindingsForWidget(ShellInputControl ctrl)
{
	if (ctrl == none)
		return;

	RemoveAllBindingsForInput(ctrl.iBindIndex);
}

function RemoveBindingForWidget(ShellInputControl ctrl)
{
	local int iBindIndex;
	local int iCurCtrl;
	if (ctrl == none)
		return;

	iBindIndex	= ctrl.iBindIndex;
	iCurCtrl	= ctrl.iCurCtrl;
	if (iCurCtrl >= 0 && iCurCtrl < aBindings[iBindIndex].aiKeys.Length )
	{
		// Clear the corresponding key.
		//ClearKey(aBindings[iBindIndex].astrKeys[iCurCtrl], aBindings[iBindIndex].aiKeys[iCurCtrl] );
		RemoveThisInput(aBindings[iBindIndex].astrKeys[iCurCtrl], aBindings[iBindIndex].ctrl);
		// Clear the corresponding entries in our arrays.
		// An alternative here would be to clear the values but keep them in the array so we could
		// have an empty entry that might be more intuitive to the user.
		// 01/14/03 JMI Changed to simply change the key to an empty value.
		aBindings[iBindIndex].aiKeys[iCurCtrl]		= -1;
		aBindings[iBindIndex].astrKeys[iCurCtrl]	= "";
		
		// Update UI.
		ShowKeyStrs(aBindings[iBindIndex] );

		// Audible feedback.
		LookAndFeel.PlaySmallSound(self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Hack to detect when joystick button released
///////////////////////////////////////////////////////////////////////////////
function Tick(float Delta)
{
	local bool bHolding;
	
	// Test if the player is still holding this button/key.
	if (HoldingButton != IK_None)
	{
		bHolding = bool(GetPlayerOwner().ConsoleCommand("ISKEYDOWN"@HoldingButton));
		if (!bHolding)
			HoldingButton = IK_None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle a key event
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local bool bRes;
	local string strKey;
	
	bRes = false;
	
	strKey = GetPlayerOwner().ConsoleCommand("KEYNAME"@Key);
	//if (WinFocused != None)
		//Log("MenuEditControl:KeyEvent(): Check key"@Key@"named"@strKey@"on action"@Action@"delta"@Delta);
		
	// Skip it
	if (Action == IST_Release && bRejectNextInput)
	{
		//log("Rejected input");
		bRejectNextInput = false;
		return Super.KeyEvent(Key, Action, Delta);
	}
	
	if (Action == IST_Release 
	// NPF--terrible hack to make joysticks work. I hate,hate,hate joysticks for use with
	// an FPS, so I figured it was a good fit. If someone else wants to dress this up all nice--be my guest.
	// Basically buttons don't say 'release'--they only say 'press'. That's what this does.
		// axis checking was pretty straightforward on the 360 gamepad, because it only reports axes that exist.
		// DirectInput devices report all axes even if they don't exist, and the ones that don't exist are always a delta of -0.50, so ignore those values.
		|| ( (Action == IST_Press || (Action == IST_Axis && abs(Delta) >= 0.25 && abs(Delta) < 0.50))
			&& ((Key >=IK_Joy1 && Key <=IK_Joy16)
				|| (Key >=IK_JoyU && Key <=IK_JoySlider2)
				|| (Key >=IK_JoyX && Key <=IK_JoyR))))
	{
		if (HoldingButton == Key)
			return Super.KeyEvent(Key, Action, Delta);
		else
			HoldingButton = Key;
			
		if (winFocused != none)
		{
			switch (Key)
			{
			case IK_Escape:
				// Just cancel the mode and play a sound.
				LookAndFeel.PlaySmallSound(self);
				break;
			default:
				LookAndFeel.PlayBigSound(self);
				SetBinding(winFocused.iBindIndex, Key, winFocused.iCurCtrl);
				break;
			}

			bRes = true;				// Absorb key.
			SetNewBindingTarget(none);	// End this mode.

			//Log("MenuEditControl:KeyEvent(): Absorbed key"@Key@"named"@strKey@"on action"@Action@"delta"@Delta);
		}
	}

	// If we don't want the key, our Super might.
	if (bRes == false)
		bRes = Super.KeyEvent(Key, Action, Delta);

	return bRes;
}

///////////////////////////////////////////////////////////////////////////////
// Handle rebinding via controller
///////////////////////////////////////////////////////////////////////////////
function execConfirmButton()
{
	// Ignore menu buttons when rebinding controls.
	if (WinFocused != None)
		return;
		
	// Confirm: re-bind an input.
	if (ShellInputBox(Root.MouseWindow) != None)
	{
		ShellInputBox(Root.MouseWindow).Notify(DE_Click);
		bRejectNextInput = true;
	}
	else
		Super.execConfirmButton();
}
function execMenuButton()
{
	// Ignore menu buttons when rebinding controls.
	if (WinFocused != None)
		return;
		
	// Menu: erase input.
	if (ShellInputBox(Root.MouseWindow) != None)
		ShellInputBox(Root.MouseWindow).Notify(DE_RClick);
	else
		Super.execMenuButton();
}
function execMenuLeftButton()
{
	// Ignore menu buttons when rebinding controls.
	if (WinFocused != None)
		return;
	
	Super.execMenuLeftButton();
}
function execMenuRightButton()
{
	// Ignore menu buttons when rebinding controls.
	if (WinFocused != None)
		return;

	Super.execMenuRightButton();
}
function execMenuUpButton()
{
	// Ignore menu buttons when rebinding controls.
	if (WinFocused != None)
		return;

	Super.execMenuUpButton();
}
function execMenuDownButton()
{
	// Ignore menu buttons when rebinding controls.
	if (WinFocused != None)
		return;

	Super.execMenuDownButton();
}
function execBackButton()
{
	// Ignore menu buttons when rebinding controls.
	if (WinFocused != None)
		return;
	
	Super.execBackButton();
}
///////////////////////////////////////////////////////////////////////////////
// Highlight specific key bindings.
///////////////////////////////////////////////////////////////////////////////
function CycleMenuItem(int Offset)
{
	local UWindowWindow CurrentWindow;
	local UWindowWindow NextWindow;
	local ShellInputControl BaseInput;
	local float f, MouseX, MouseY, XAlign, YAlign;
	local int i, IntMouseX, IntMouseY;
	
	// Ignore if no menu.
	if (!bWindowVisible)
		return;

	CurrentWindow = Root.MouseWindow;
	
	// Try to find next/previous input box in the line.
	if (ShellInputControl(CurrentWindow) != None)
	{
		if (Offset < 0)
			i = Offset;
		else
			i = Offset - 1;
		while (i < 0)
			i += ShellInputControl(CurrentWindow).aInputs.Length;
		while (i >= ShellInputControl(CurrentWindow).aInputs.Length)
			i -= ShellInputControl(CurrentWindow).aInputs.Length;
		NextWindow = ShellInputControl(CurrentWindow).aInputs[i];
	}
	else if (ShellInputBox(CurrentWindow) != None)
	{
		BaseInput = ShellInputBox(CurrentWindow).NotifyControl;
		for (i = 0; i < BaseInput.aInputs.Length; i++)
			if (BaseInput.aInputs[i] == CurrentWindow)
				break;
				
		i += Offset;
		while (i < 0)
			i += BaseInput.aInputs.Length;
		while (i >= BaseInput.aInputs.Length)
			i -= BaseInput.aInputs.Length;
		NextWindow = BaseInput.aInputs[i];
	}
	else
	{
		// Can't find anything - send it to super
		Super.CycleMenuItem(Offset);
		return;
	}
		
	// Select current window. Try to align based on choice alignment
	if (UWindowDialogControl(NextWindow) != None)
	{
		YAlign = 2.0 / 3.0;
		switch (UWindowDialogControl(NextWindow).Align)
		{
			case TA_Left:
				XAlign = 1.0 / 8.0;
				break;
			case TA_Right:
				XAlign = 7.0 / 8.0;
				break;
			default:
				XAlign = 1.0 / 2.0;
				break;
		}
	}
	else
	{
		XAlign = 1.0 / 8.0;
		YAlign = 2.0 / 3.0;
	}
	NextWindow.WindowToGlobal(NextWindow.WinWidth * XAlign, NextWindow.WinHeight * YAlign, MouseX, MouseY);
	
	// Position mouse
	IntMouseX = MouseX;
	IntMouseY = MouseY;
	Root.MoveMouse(MouseX,MouseY);
	GetPlayerOwner().ConsoleCommand("SETMOUSE"@IntMouseX@IntMouseY);	
}
///////////////////////////////////////////////////////////////////////////////
// Handle up/down from individual input boxes.
///////////////////////////////////////////////////////////////////////////////
function NextMenuItem(int Offset)
{
	local float MouseX, MouseY, XAlign, YAlign;
	local int i, idx, IntMouseX, IntMouseY;
	local UWindowWindow CurrentWindow, NextWindow;
	local ShellInputControl BaseInput;
	
	// Ignore if no menu.
	if (!bWindowVisible)
		return;

	CurrentWindow = Root.MouseWindow;
	
	// Send to super if not on an input box
	if (ShellInputBox(CurrentWindow) == None)
	{
		Super.NextMenuItem(Offset);
		return;
	}

	// Find current index
	BaseInput = ShellInputBox(CurrentWindow).NotifyControl;
	for (idx = 0; idx < BaseInput.aInputs.Length; idx++)
		if (BaseInput.aInputs[idx] == CurrentWindow)
			break;
	
	// Find current window #, if any.
	for (i = 0; i < MenuItems.Length; i++)
	{
		if (MenuItems[i].Window == BaseInput)
			break;
	}
	// Advance by offset.
	i += Offset;
	
	// Fix boundary wrapping
	if (i < 0)
		i = MenuItems.Length - 1;
	else if (i >= MenuItems.Length)
		i = 0;
		
	NextWindow = MenuItems[i].Window;
		
	// If we advance to another input box, align the cursor properly
	if (ShellInputControl(NextWindow) != None)
		NextWindow = ShellInputControl(NextWindow).aInputs[idx];
		
	// Select current window. Try to align based on choice alignment
	if (UWindowDialogControl(NextWindow) != None)
	{
		YAlign = 2.0 / 3.0;
		switch (UWindowDialogControl(NextWindow).Align)
		{
			case TA_Left:
				XAlign = 1.0 / 8.0;
				break;
			case TA_Right:
				XAlign = 7.0 / 8.0;
				break;
			default:
				XAlign = 1.0 / 2.0;
				break;
		}
	}
	else
	{
		XAlign = 1.0 / 8.0;
		YAlign = 2.0 / 3.0;
	}
	NextWindow.WindowToGlobal(NextWindow.WinWidth * XAlign, NextWindow.WinHeight * YAlign, MouseX, MouseY);
	
	// Position mouse
	IntMouseX = MouseX;
	IntMouseY = MouseY;
	Root.MoveMouse(MouseX,MouseY);
	GetPlayerOwner().ConsoleCommand("SETMOUSE"@IntMouseX@IntMouseY);
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);
	switch (E)
		{
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				case RestoreChoice:
					SetDefaultValues();
					break;
				default:
					SetNewBindingTarget(ShellInputControl(C) );
					break;
				}
			break;
		case DE_RClick:
			// 11/27/02 JMI Remove the binding with a right click.
			if (winFocused == none)
			{
				// Note that here we set the new target and relinquish it in
				// one swoop for both feedback and functionality.  There's
				// focus handling in here that gets us free management and
				// I was hoping the text would select and appear to flash
				// before going away to help the user see what happened.
				SetNewBindingTarget(ShellInputControl(C) );
				SetNewBindingTarget(none);
				// Actually remove the binding.
				RemoveBindingForWidget(ShellInputControl(C) );
			}
			break;
		case DE_MouseLeave:
			switch (C)
				{
				case BackChoice:
				case RestoreChoice:
					break;
				default:
					// 11/27/02 JMI I noticed that The Army Game ends the input acquistion
					//				mode if the mouse leaves the area.  Not sure if I think
					//				that's useful.
					SetNewBindingTarget(none);	// End this mode.
					break;
				}
			break;
		case DE_MouseEnter:
			// 12/03/02 JMI Guess we should consider entering another GUI the same as exiting.
			if (C != winFocused)
				SetNewBindingTarget(none);	// End this mode.
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Get the controls to be edited.  Defined by derived class.
///////////////////////////////////////////////////////////////////////////////
//ErikFOV Change: for localization
//function array<Control> GetControls();
function GetControls(out array<Control> Controls, out array<String> Labels);
//end


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// Need more room given the edit control.
	ItemHeight	 = 48;
	ItemSpacingY = 2;
	// Need more width for items.
	MenuWidth	= 640;	// 01/15/03 JMI Increased to try to make 3 inputs fit.
	HintLines	= 3;
	BorderLeft	= 5;	// 01/19/03 JMI Override for more room.
	BorderRight = 5;	// 01/19/03 JMI Override for more room.
	// 02/02/03 JMI More room between the title and the text for col headers.
	TitleSpacingY = 21;	// The size of the col headers plus spacing.

	bBlockConsole=true

	InputHelpPrefix = "Inputs mapped to ";
	InputHelpPostfix = ".  Left Mouse/Confirm to add an input; Right Mouse/Menu to clear.";

//ErikFOV Change: for localization

	// Action Controls //
	//aActionControls[0] = (strLabel="Empty Hands",strAlias="ToggleToHands")
    //aActionControls[1] = (strLabel="Crouch",strAlias="Duck")
    //aActionControls[2] = (strLabel="Jump",strAlias="Jump")
	//aActionControls[3] = (strLabel="Kick",strAlias="DoKick")	// 01/15/03 JMI Changed Kick to DoKick.
	//aActionControls[4] = (strLabel="Unzip/Zip Pants",strAlias="UseZipper")
	//aActionControls[5] = (strLabel="Commit Suicide",strAlias="Suicide")
	//aActionControls[6] = (strLabel="Yell 'Get Down'",strAlias="GetDown")
		 //aActionControls[7] = (strLabel="Use Object",strAlias="Use")
	
	aActionControls[0]=(strAlias="ToggleToHands")
    aActionControls[1]=(strAlias="Duck")
    aActionControls[2]=(strAlias="Jump")
	aActionControls[3]=(strAlias="DoKick")  // 01/15/03 JMI Changed Kick to DoKick.
	aActionControls[4]=(strAlias="UseZipper")
	aActionControls[5]=(strAlias="Suicide")
	aActionControls[6]=(strAlias="GetDown")
	
	aActionControlsLabel[0]="Empty Hands"
    aActionControlsLabel[1]="Crouch"
    aActionControlsLabel[2]="Jump"
	aActionControlsLabel[3]="Kick"
	aActionControlsLabel[4]="Unzip/Zip Pants"
	aActionControlsLabel[5]="Commit Suicide"
	aActionControlsLabel[6]="Yell 'Get Down'"

	
	// Display Controls //
	//aDisplayControls[0] = (strLabel="Gamma",strAlias="GammaUp")			// 01/15/03 JMI Changed "GammaChange" to "GammaUp".
	//aDisplayControls[1] = (strLabel="Brightness",strAlias="BrightnessUp")	// 01/15/03 JMI Changed "BrightnessChange" to "BrightnessUp".
	//aDisplayControls[2] = (strLabel="More HUD",strAlias="GrowHUD")			// 01/15/03 JMI Capitalized "HUD".
	//aDisplayControls[3] = (strLabel="Less HUD",strAlias="ShrinkHUD")		// 01/15/03 JMI Capitalized "HUD".
	//aDisplayControls[4] = (strLabel="Toggle Weapon/Inv Hints",strAlias="ToggleInvHints")
	
	aDisplayControls[0]=(strAlias="GammaUp")			// 01/15/03 JMI Changed "GammaChange" to "GammaUp".
	aDisplayControls[1]=(strAlias="BrightnessUp")	// 01/15/03 JMI Changed "BrightnessChange" to "BrightnessUp".
	aDisplayControls[2]=(strAlias="GrowHUD")			// 01/15/03 JMI Capitalized "HUD".
	aDisplayControls[3]=(strAlias="ShrinkHUD")		// 01/15/03 JMI Capitalized "HUD".
	aDisplayControls[4]=(strAlias="ToggleInvHints")

	aDisplayControlsLabel[0]="Gamma"
	aDisplayControlsLabel[1]="Brightness"
	aDisplayControlsLabel[2]="More HUD"
	aDisplayControlsLabel[3]="Less HUD"		
	aDisplayControlsLabel[4]="Toggle Weapon/Inv Hints"
	
	// Inventory Controls //
	//aInvControls[0] = (strLabel="Use Item",strAlias="InventoryActivate")
	//aInvControls[1] = (strLabel="Drop Item",strAlias="ThrowPowerup")
	//aInvControls[2] = (strLabel="Next Item",strAlias="InventoryNext")
	//aInvControls[3] = (strLabel="Previous Item",strAlias="InventoryPrevious")
	//aInvControls[4] = (strLabel="Show Map",strAlias="QuickUseMap")
	//aInvControls[5] = (strLabel="Quick Health",strAlias="QuickHealth")
	//aInvControls[6] = (strLabel="Inventory Menu",strAlias="InventoryMenu")
	
	aInvControls[0]=(strAlias="InventoryActivate")
	aInvControls[1]=(strAlias="ThrowPowerup")
	aInvControls[2]=(strAlias="InventoryNext")
	aInvControls[3]=(strAlias="InventoryPrevious")
	aInvControls[4]=(strAlias="QuickUseMap")
	aInvControls[5]=(strAlias="QuickHealth")
	aInvControls[6]=(strAlias="InventoryMenu")
	
	aInvControlsLabel[0]="Use Item"
	aInvControlsLabel[1]="Drop Item"
	aInvControlsLabel[2]="Next Item"
	aInvControlsLabel[3]="Previous Item"
	aInvControlsLabel[4]="Show Map"
	aInvControlsLabel[5]="Quick Health"
	aInvControlsLabel[6]="Inventory Menu"
	
	// Misc Controls //
	//aMiscControls[0] = (strLabel="Quick Save",strAlias="QuickSave")
	//aMiscControls[1] = (strLabel="Quick Load",strAlias="QuickLoad")
	//aMiscControls[2] = (strLabel="Skip Cutscene",strAlias="WantsToSkip",bNoClear=true)
	//aMiscControls[3] = (strLabel="Restart",strAlias="GameOverRestart",bNoClear=true)
	//aMiscControls[4] = (strLabel="Pause",strAlias="Pause")
	//aMiscControls[5] = (strLabel="Shrink HUD",strAlias="ShrinkHUD")
	//aMiscControls[6] = (strLabel="Grow HUD",strAlias="GrowHUD")
	//aMiscControls[7] = (strLabel="Console Command",strAlias="Type")
	//aMiscControls[8] = (strLabel="Dev Console",strAlias="ConsoleToggle")
	
	aMiscControls[0]=(strAlias="QuickSave")
	aMiscControls[1]=(strAlias="QuickLoad")
	aMiscControls[2]=(strAlias="WantsToSkip",bNoClear=true)
	aMiscControls[3]=(strAlias="GameOverRestart",bNoClear=true)
	aMiscControls[4]=(strAlias="Pause")
	aMiscControls[5]=(strAlias="ShrinkHUD")
	aMiscControls[6]=(strAlias="GrowHUD")
	aMiscControls[7]=(strAlias="Type")
	aMiscControls[8]=(strAlias="ConsoleToggle")
	
	aMiscControlsLabel[0]="Quick Save"
	aMiscControlsLabel[1]="Quick Load"
	aMiscControlsLabel[2]="Skip Cutscene"
	aMiscControlsLabel[3]="Restart"
	aMiscControlsLabel[4]="Pause"
	aMiscControlsLabel[5]="Shrink HUD"
	aMiscControlsLabel[6]="Grow HUD"
	aMiscControlsLabel[7]="Console Command"
	aMiscControlsLabel[8]="Dev Console"
	
	// Multiplayer Controls //
	//aMultiControls[0] = (strLabel="Talk (Say)",strAlias="Talk")
	//aMultiControls[1] = (strLabel="Team Talk (Team Say)",strAlias="TeamTalk")
	//aMultiControls[2] = (strLabel="Scoreboard",strAlias="ShowScores")
	
	aMultiControls[0]=(strAlias="Talk")
	aMultiControls[1]=(strAlias="TeamTalk")
	aMultiControls[2]=(strAlias="ShowScores")
	
	aMultiControlsLabel[0]="Talk (Say)"
	aMultiControlsLabel[1]="Team Talk (Team Say)"
	aMultiControlsLabel[2]="Scoreboard"
	
	// Movement Controls //
    //aMovementControls[0]  = (strLabel="Forward",strAlias="MoveForward")
    //aMovementControls[1]  = (strLabel="Backward",strAlias="MoveBackward")
    //aMovementControls[2]  = (strLabel="Strafe Left",strAlias="StrafeLeft")
    //aMovementControls[3]  = (strLabel="Strafe Right",strAlias="StrafeRight")
    //aMovementControls[4]  = (strLabel="Walk",strAlias="Walking")
    //aMovementControls[5]  = (strLabel="Strafe Toggle",strAlias="Strafe")
    //aMovementControls[6]  = (strLabel="Turn Right",strAlias="TurnRight")
    //aMovementControls[7]  = (strLabel="Turn Left",strAlias="TurnLeft")
    //aMovementControls[8]  = (strLabel="Look Up",strAlias="LookUp")
    //aMovementControls[9]  = (strLabel="Look Down",strAlias="LookDown")
    //aMovementControls[10] = (strLabel="Center View",strAlias="CenterView")
	
	aMovementControls[0]=(strAlias="MoveForward")
    aMovementControls[1]=(strAlias="MoveBackward")
    aMovementControls[2]=(strAlias="StrafeLeft")
    aMovementControls[3]=(strAlias="StrafeRight")
    aMovementControls[4]=(strAlias="Walking")
    aMovementControls[5]=(strAlias="Strafe")
    aMovementControls[6]=(strAlias="TurnRight")
    aMovementControls[7]=(strAlias="TurnLeft")
    aMovementControls[8]=(strAlias="LookUp")
    aMovementControls[9]=(strAlias="LookDown")
    aMovementControls[10]=(strAlias="CenterView")
	
	aMovementControlsLabel[0]="Forward"
    aMovementControlsLabel[1]="Backward"
    aMovementControlsLabel[2]="Strafe Left"
    aMovementControlsLabel[3]="Strafe Right"
    aMovementControlsLabel[4]="Walk"
    aMovementControlsLabel[5]="Strafe Toggle"
    aMovementControlsLabel[6]="Turn Right"
    aMovementControlsLabel[7]="Turn Left"
    aMovementControlsLabel[8]="Look Up"
    aMovementControlsLabel[9]="Look Down"
    aMovementControlsLabel[10]="Center View"
	
	// Weapon Controls //
	//aWeaponControls[0] = (strLabel="Primary Fire",strAlias="Fire")
	//aWeaponControls[1] = (strLabel="Secondary Fire",strAlias="AltFire")
	//aWeaponControls[2] = (strLabel="Previous Weapon",strAlias="PrevWeapon")
	//aWeaponControls[3] = (strLabel="Next Weapon",strAlias="NextWeapon")
	//aWeaponControls[4] = (strLabel="Drop Weapon",strAlias="ThrowWeapon")
	//aWeaponControls[5] = (strLabel="Rifle Zoom In",strAlias="WeaponZoomIn",bNoClear=True)
	//aWeaponControls[6] = (strLabel="Rifle Zoom Out",strAlias="WeaponZoomOut",bNoClear=True)
	
	aWeaponControls[0]=(strAlias="Fire")
	aWeaponControls[1]=(strAlias="AltFire")
	aWeaponControls[2]=(strAlias="PrevWeapon")
	aWeaponControls[3]=(strAlias="NextWeapon")
	aWeaponControls[4]=(strAlias="ThrowWeapon")
	aWeaponControls[5]=(strAlias="WeaponZoomIn",bNoClear=True)
	aWeaponControls[6]=(strAlias="WeaponZoomOut",bNoClear=True)
	
	aWeaponControlsLabel[0]="Primary Fire"
	aWeaponControlsLabel[1]="Secondary Fire"
	aWeaponControlsLabel[2]="Previous Weapon"
	aWeaponControlsLabel[3]="Next Weapon"
	aWeaponControlsLabel[4]="Drop Weapon"
	aWeaponControlsLabel[5]="Rifle Zoom In"
	aWeaponControlsLabel[6]="Rifle Zoom Out"
	
	// Weapon Groups //
	//aWeaponControls2[0] = (strLabel="Melee Weapons",strAlias="SwitchWeapon 1")
	//aWeaponControls2[1] = (strLabel="Pistols",strAlias="SwitchWeapon 2")
	//aWeaponControls2[2] = (strLabel="Shotguns",strAlias="SwitchWeapon 3")
	//aWeaponControls2[3] = (strLabel="Small Rifles",strAlias="SwitchWeapon 4")
	//aWeaponControls2[4] = (strLabel="Gas & Fire",strAlias="SwitchWeapon 5")
	//aWeaponControls2[5] = (strLabel="Throwables",strAlias="SwitchWeapon 6")
	//aWeaponControls2[6] = (strLabel="Large Throwables",strAlias="SwitchWeapon 7")
	//aWeaponControls2[7] = (strLabel="Large Rifles",strAlias="SwitchWeapon 8")
	//aWeaponControls2[8] = (strLabel="Launchers",strAlias="SwitchWeapon 9")
	//aWeaponControls2[9] = (strLabel="Napalm",strAlias="SwitchWeapon 10")
	
	aWeaponControls2[0]=(strAlias="SwitchWeapon 1")
	aWeaponControls2[1]=(strAlias="SwitchWeapon 2")
	aWeaponControls2[2]=(strAlias="SwitchWeapon 3")
	aWeaponControls2[3]=(strAlias="SwitchWeapon 4")
	aWeaponControls2[4]=(strAlias="SwitchWeapon 5")
	aWeaponControls2[5]=(strAlias="SwitchWeapon 6")
	aWeaponControls2[6]=(strAlias="SwitchWeapon 7")
	aWeaponControls2[7]=(strAlias="SwitchWeapon 8")
	aWeaponControls2[8]=(strAlias="SwitchWeapon 9")
	aWeaponControls2[9]=(strAlias="SwitchWeapon 10")

	aWeaponControls2Label[0]="Melee Weapons"
	aWeaponControls2Label[1]="Pistols"
	aWeaponControls2Label[2]="Shotguns"
	aWeaponControls2Label[3]="Small Rifles"
	aWeaponControls2Label[4]="Gas & Fire"
	aWeaponControls2Label[5]="Throwables"
	aWeaponControls2Label[6]="Large Throwables"
	aWeaponControls2Label[7]="Large Rifles"
	aWeaponControls2Label[8]="Launchers"
	aWeaponControls2Label[9]="Napalm"
	
	// Advanced Say Controls //
	//aSayControls[0] = (strLabel="Pre-set Say 1",strAlias="ExtraSay 1")
	//aSayControls[1] = (strLabel="Pre-set Say 2",strAlias="ExtraSay 2")
	//aSayControls[2] = (strLabel="Pre-set Say 3",strAlias="ExtraSay 3")
	//aSayControls[3] = (strLabel="Pre-set Say 4",strAlias="ExtraSay 4")
	//aSayControls[4] = (strLabel="Pre-set Say 5",strAlias="ExtraSay 5")
	//aSayControls[5] = (strLabel="Pre-set Say 6",strAlias="ExtraSay 6")
	//aSayControls[6] = (strLabel="Pre-set Say 7",strAlias="ExtraSay 7")
	//aSayControls[7] = (strLabel="Pre-set Say 8",strAlias="ExtraSay 8")

	aSayControls[0]=(strAlias="ExtraSay 1")
	aSayControls[1]=(strAlias="ExtraSay 2")
	aSayControls[2]=(strAlias="ExtraSay 3")
	aSayControls[3]=(strAlias="ExtraSay 4")
	aSayControls[4]=(strAlias="ExtraSay 5")
	aSayControls[5]=(strAlias="ExtraSay 6")
	aSayControls[6]=(strAlias="ExtraSay 7")
	aSayControls[7]=(strAlias="ExtraSay 8")

	aSayControlsLabel[0]="Pre-set Say 1"
	aSayControlsLabel[1]="Pre-set Say 2"
	aSayControlsLabel[2]="Pre-set Say 3"
	aSayControlsLabel[3]="Pre-set Say 4"
	aSayControlsLabel[4]="Pre-set Say 5"
	aSayControlsLabel[5]="Pre-set Say 6"
	aSayControlsLabel[6]="Pre-set Say 7"
	aSayControlsLabel[7]="Pre-set Say 8"
	
	
	// Advanced TeamSay Controls //
	//aTeamSayControls[0] = (strLabel="Pre-set TeamSay 1",strAlias="ExtraTeamSay 1")
	//aTeamSayControls[1] = (strLabel="Pre-set TeamSay 2",strAlias="ExtraTeamSay 2")
	//aTeamSayControls[2] = (strLabel="Pre-set TeamSay 3",strAlias="ExtraTeamSay 3")
	//aTeamSayControls[3] = (strLabel="Pre-set TeamSay 4",strAlias="ExtraTeamSay 4")
	//aTeamSayControls[4] = (strLabel="Pre-set TeamSay 5",strAlias="ExtraTeamSay 5")
	//aTeamSayControls[5] = (strLabel="Pre-set TeamSay 6",strAlias="ExtraTeamSay 6")
	//aTeamSayControls[6] = (strLabel="Pre-set TeamSay 7",strAlias="ExtraTeamSay 7")
	//aTeamSayControls[7] = (strLabel="Pre-set TeamSay 8",strAlias="ExtraTeamSay 8")

	aTeamSayControls[0]=(strAlias="ExtraTeamSay 1")
	aTeamSayControls[1]=(strAlias="ExtraTeamSay 2")
	aTeamSayControls[2]=(strAlias="ExtraTeamSay 3")
	aTeamSayControls[3]=(strAlias="ExtraTeamSay 4")
	aTeamSayControls[4]=(strAlias="ExtraTeamSay 5")
	aTeamSayControls[5]=(strAlias="ExtraTeamSay 6")
	aTeamSayControls[6]=(strAlias="ExtraTeamSay 7")
	aTeamSayControls[7]=(strAlias="ExtraTeamSay 8")

	aTeamSayControlsLabel[0]="Pre-set TeamSay 1"
	aTeamSayControlsLabel[1]="Pre-set TeamSay 2"
	aTeamSayControlsLabel[2]="Pre-set TeamSay 3"
	aTeamSayControlsLabel[3]="Pre-set TeamSay 4"
	aTeamSayControlsLabel[4]="Pre-set TeamSay 5"
	aTeamSayControlsLabel[5]="Pre-set TeamSay 6"
	aTeamSayControlsLabel[6]="Pre-set TeamSay 7"
	aTeamSayControlsLabel[7]="Pre-set TeamSay 8"
		
	
	// GamePad Controls //
	//aGamePadControls[0] = (strLabel="Show Menu",strAlias="MenuButton",bNoClear=True)
	//aGamePadControls[1] = (strLabel="Confirm",strAlias="ConfirmButton",bNoClear=True)
	//aGamePadControls[2] = (strLabel="Back",strAlias="BackButton",bNoClear=True)
	//aGamePadControls[3] = (strLabel="Menu Up",strAlias="MenuUpButton",bNoClear=True)
	//aGamePadControls[4] = (strLabel="Menu Down",strAlias="MenuDownButton",bNoClear=True)
	//aGamePadControls[5] = (strLabel="Menu Left",strAlias="MenuLeftButton",bNoClear=True)
	//aGamePadControls[6] = (strLabel="Menu Right",strAlias="MenuRightButton",bNoClear=True)
	   // These two are technically axes, but they're not handled by the normal axis input handler, so bIsAxis stays false.
	//aGamePadControls[7] = (strLabel="Cursor Up/Down",strAlias="MenuMouseY",bNoClear=True)
	//aGamePadControls[8] = (strLabel="Cursor Left/Right",strAlias="MenuMouseX",bNoClear=True)
	
	
	aGamePadControls[0]=(strAlias="MenuButton",bNoClear=True)
	aGamePadControls[1]=(strAlias="ConfirmButton",bNoClear=True)
	aGamePadControls[2]=(strAlias="BackButton",bNoClear=True)
	aGamePadControls[3]=(strAlias="MenuUpButton",bNoClear=True)
	aGamePadControls[4]=(strAlias="MenuDownButton",bNoClear=True)
	aGamePadControls[5]=(strAlias="MenuLeftButton",bNoClear=True)
	aGamePadControls[6]=(strAlias="MenuRightButton",bNoClear=True)
	aGamePadControls[7]=(strAlias="MenuMouseY",bNoClear=True)
	aGamePadControls[8]=(strAlias="MenuMouseX",bNoClear=True)
	
	aGamePadControlsLabel[0]="Show Menu"
	aGamePadControlsLabel[1]="Confirm"
	aGamePadControlsLabel[2]="Back"
	aGamePadControlsLabel[3]="Menu Up"
	aGamePadControlsLabel[4]="Menu Down"
	aGamePadControlsLabel[5]="Menu Left"
	aGamePadControlsLabel[6]="Menu Right"
	aGamePadControlsLabel[7]="Cursor Up/Down"
	aGamePadControlsLabel[8]="Cursor Left/Right"
	
	// GamePad Controls 2 //
	//aGamePadControls2[0] = (strLabel="Move Forward/Back",strAlias="aBaseY",bIsAxis=True)
	//aGamePadControls2[1] = (strLabel="Strafe Left/Right",strAlias="aStrafe",bIsAxis=True)
	//aGamePadControls2[2] = (strLabel="Look Up/Down",strAlias="aLookUp",bIsAxis=True)
	//aGamePadControls2[3] = (strLabel="Look Left/Right",strAlias="aBaseX",bIsAxis=True)

	aGamePadControls2[0]=(strAlias="aBaseY",bIsAxis=True)
	aGamePadControls2[1]=(strAlias="aStrafe",bIsAxis=True)
	aGamePadControls2[2]=(strAlias="aLookUp",bIsAxis=True)
	aGamePadControls2[3]=(strAlias="aBaseX",bIsAxis=True)
	
	aGamePadControls2Label[0]="Move Forward/Back"
	aGamePadControls2Label[1]="Strafe Left/Right"
	aGamePadControls2Label[2]="Look Up/Down"
	aGamePadControls2Label[3]="Look Left/Right"
	
//end

	Blank=Texture'ButtonIcons.blank'	
	
	// DEFAULT CONTROLS //
	Categories[0]="Keys"
	Categories[1]="Pad"
	Categories[2]="Old"
	Defaults[00]=(alias="Fire",key="LeftMouse",cat="Keys")
	Defaults[01]=(alias="AltFire",key="RightMouse",cat="Keys")
	Defaults[02]=(alias="PrevWeapon",key="MouseWheelDown",cat="Keys")
	Defaults[03]=(alias="WeaponZoomOut",key="MouseWheelDown",cat="Keys")
	Defaults[04]=(alias="NextWeapon",key="MouseWheelUp",cat="Keys")
	Defaults[05]=(alias="WeaponZoomIn",key="MouseWheelUp",cat="Keys")
	Defaults[06]=(alias="ShowScores",key="F1",cat="Keys")
	Defaults[07]=(alias="QuickSave",key="F5",cat="Keys")
	Defaults[08]=(alias="QuickLoad",key="F8",cat="Keys")
	Defaults[09]=(alias="SwitchWeapon 10",key="0",cat="Keys")
	Defaults[10]=(alias="SwitchWeapon 9",key="9",cat="Keys")
	Defaults[11]=(alias="SwitchWeapon 8",key="8",cat="Keys")
	Defaults[12]=(alias="SwitchWeapon 7",key="7",cat="Keys")
	Defaults[13]=(alias="SwitchWeapon 6",key="6",cat="Keys")
	Defaults[14]=(alias="SwitchWeapon 5",key="5",cat="Keys")
	Defaults[15]=(alias="SwitchWeapon 4",key="4",cat="Keys")
	Defaults[16]=(alias="SwitchWeapon 3",key="3",cat="Keys")
	Defaults[17]=(alias="SwitchWeapon 2",key="2",cat="Keys")
	Defaults[18]=(alias="SwitchWeapon 1",key="1",cat="Keys")
	Defaults[19]=(alias="StrafeLeft",key="A",cat="Keys")
	Defaults[20]=(alias="Talk",key="B",cat="Keys")
	Defaults[21]=(alias="Duck",key="C",cat="Keys")
	Defaults[22]=(alias="StrafeRight",key="D",cat="Keys")
	Defaults[23]=(alias="InventoryActivate",key="E",cat="Keys")
	Defaults[24]=(alias="ToggleToHands",key="F",cat="Keys")
	Defaults[25]=(alias="GetDown",key="G",cat="Keys")
	Defaults[26]=(alias="Suicide",key="K",cat="Keys")
	Defaults[27]=(alias="QuickUseMap",key="M",cat="Keys")
	Defaults[28]=(alias="DoKick",key="Q",cat="Keys")
	Defaults[29]=(alias="UseZipper",key="R",cat="Keys")
	Defaults[30]=(alias="MoveBackward",key="S",cat="Keys")
	Defaults[31]=(alias="QuickHealth",key="T",cat="Keys")
	Defaults[32]=(alias="MoveForward",key="W",cat="Keys")
	Defaults[33]=(alias="ThrowPowerup",key="X",cat="Keys")
	Defaults[34]=(alias="ThrowWeapon",key="Z",cat="Keys")
	Defaults[35]=(alias="Duck",key="Ctrl",cat="Old")
	Defaults[36]=(alias="InventoryActivate",key="Enter",cat="Old")
	Defaults[37]=(alias="WantsToSkip",key="Enter",cat="Old")
	Defaults[38]=(alias="InventoryPrevious",key="LeftBracket",cat="Keys")
	Defaults[39]=(alias="Pause",key="Pause",cat="Keys")
	Defaults[40]=(alias="InventoryNext",key="RightBracket",cat="Keys")
	Defaults[41]=(alias="Walking",key="Shift",cat="Keys")
	Defaults[42]=(alias="Jump",key="Space",cat="Keys")
	Defaults[43]=(alias="GameOverRestart",key="Space",cat="Keys")
	Defaults[44]=(alias="WantsToSkip",key="Space",cat="Keys")
	Defaults[45]=(alias="ConsoleToggle",key="Tilde",cat="Keys")
	Defaults[46]=(alias="ToggleToHands",key="Joy16",cat="Pad")
	Defaults[47]=(alias="InventoryActivate",key="Joy15",cat="Pad")
	Defaults[48]=(alias="UseZipper",key="Joy14",cat="Pad")
	Defaults[49]=(alias="BackButton",key="Joy14",cat="Pad")
	Defaults[50]=(alias="ConfirmButton",key="Joy13",cat="Pad")
	Defaults[51]=(alias="GameOverRestart",key="Joy13",cat="Pad")
	Defaults[52]=(alias="WantsToSkip",key="Joy13",cat="Pad")
	Defaults[53]=(alias="Jump",key="Joy13",cat="Pad")
	Defaults[54]=(alias="AltFire",key="Joy11",cat="Pad")
	Defaults[55]=(alias="Fire",key="Joy12",cat="Pad")
	Defaults[56]=(alias="NextWeapon",key="Joy10",cat="Pad")
	Defaults[57]=(alias="WeaponZoomOut",key="Joy10",cat="Pad")
	Defaults[58]=(alias="WeaponZoomIn",key="Joy9",cat="Pad")
	Defaults[59]=(alias="PrevWeapon",key="Joy9",cat="Pad")
	Defaults[60]=(alias="DoKick",key="Joy8",cat="Pad")
	Defaults[61]=(alias="Duck",key="Joy7",cat="Pad")
	Defaults[62]=(alias="QuickUseMap",key="Joy6",cat="Pad")
	Defaults[63]=(alias="MenuButton",key="Joy5",cat="Pad")
	Defaults[64]=(alias="InventoryMenu",key="Joy4",cat="Pad")
	Defaults[65]=(alias="MenuRightButton",key="Joy4",cat="Pad")
	Defaults[66]=(alias="InventoryMenu",key="Joy3",cat="Pad")
	Defaults[67]=(alias="MenuLeftButton",key="Joy3",cat="Pad")
	Defaults[68]=(alias="ThrowWeapon",key="Joy2",cat="Pad")
	Defaults[69]=(alias="MenuDownButton",key="Joy2",cat="Pad")
	Defaults[70]=(alias="ThrowPowerup",key="Joy1",cat="Pad")
	Defaults[71]=(alias="MenuUpButton",key="Joy1",cat="Pad")
	Defaults[72]=(alias="MenuMouseX",key="JoyX",cat="Pad")
	Defaults[73]=(alias="MenuMouseY",key="JoyY",cat="Pad")
	Defaults[74]=(alias="AXIS aStrafe SPEEDBASE=4.00 DEADZONE=0.10",key="JoyX",cat="Pad")
	Defaults[75]=(alias="AXIS aBaseY SPEEDBASE=4.00 DEADZONE=0.10",key="JoyY",cat="Pad")
	Defaults[76]=(alias="AXIS aBaseX SPEEDBASE=5.00 DEADZONE=0.10",key="JoyU",cat="Pad")
	Defaults[77]=(alias="AXIS aLookUp SPEEDBASE=4.00 DEADZONE=0.10",key="JoyV",cat="Pad")
	Defaults[78]=(alias="InventoryMenu",key="Tab",cat="Keys")
	Defaults[79]=(alias="ConfirmButton",key="Enter",cat="Keys")
	Defaults[80]=(alias="BackButton",key="Backspace",cat="Keys")
	Defaults[81]=(alias="MenuUpButton",key="Up",cat="Keys")
	Defaults[82]=(alias="MenuDownButton",key="Down",cat="Keys")
	Defaults[83]=(alias="MenuLeftButton",key="Left",cat="Keys")
	Defaults[84]=(alias="MenuRightButton",key="Right",cat="Keys")
	MultiBindWarningTitle="Information"
	MultiBindWarningText="You've bound a menu navigation key to another function. You will be unable to use this function while the weapon selector is visible."
}
