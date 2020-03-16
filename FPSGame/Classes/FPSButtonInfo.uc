///////////////////////////////////////////////////////////////////////////////
// ButtonInfo
// Copyright 2014 Running With Scissors, Inc
// All Rights Reserved
//
// Actor class for turning keyboard/button input names into icons
///////////////////////////////////////////////////////////////////////////////
class FPSButtonInfo extends Info
	config(JoyButtons)
	notplaceable;
	
///////////////////////////////////////////////////////////////////////////////
// Consts, enums, variables, etc.
///////////////////////////////////////////////////////////////////////////////
const MAX_JOYSTICK_TYPES = 6;
const MAX_BUTTONS = 256;
	
enum EJoystickType
{
	JT_Generic,		// Generic joystick, uses button number prompts.
					// Also acts as a fallback if an icon is not found
					// for a control scheme (handles keyboard bindings)
	JT_Xbox360,		// Xbox 360 controller
	JT_XboxOne,		// Xbox One controller
	JT_PS3,			// Playstation 3 controller
	JT_PS4,			// Playstation 4 controller
	JT_Wii,			// Wii/Wii U controller
	JT_Steam		// Steam controller
};

struct SJoyIcon
{
	var config EJoystickType Type;
	var config Interactions.EInputKey Key;
	var config String Icon;
};

var config bool bTestLoad;								// If true, logs all errors when loading textures

var config int JoystickType;							// Defines the currently-used input scheme
var config array<SJoyIcon> JoyIcons;					// Defines all button icons
var localized string JoystickName[MAX_JOYSTICK_TYPES];	// Defines names of input schemes
var Texture MissingButton;								// Placeholder for missing buttons
var Texture MissingBinding;								// Indicates no binding for this input

var Texture ButtonIcons[MAX_BUTTONS];					// Icons for currently-loaded input scheme
var FPSHud MyHUD;										// Pointer back to our HUD

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
// Populate all icons for our current joystick type
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	LoadIcons(JoystickType);
}

///////////////////////////////////////////////////////////////////////////////
// GetJoystickName
///////////////////////////////////////////////////////////////////////////////
function string GetJoystickName(int UseJT)
{
	return JoystickName[UseJT];
}

///////////////////////////////////////////////////////////////////////////////
// GetJoystickCount
///////////////////////////////////////////////////////////////////////////////
function int GetJoystickCount()
{
	return MAX_JOYSTICK_TYPES;
}

///////////////////////////////////////////////////////////////////////////////
// GetJoystickType
///////////////////////////////////////////////////////////////////////////////
function int GetJoystickType()
{
	return JoystickType;
}

///////////////////////////////////////////////////////////////////////////////
// SetJoystickType
// Changes current input scheme
///////////////////////////////////////////////////////////////////////////////
function SetJoystickType(int NewJT)
{
	LoadIcons(NewJT);
	JoystickType = NewJT;
	SaveConfig();
}

///////////////////////////////////////////////////////////////////////////////
// LoadIcons
// Loads all icons for a specific control scheme
///////////////////////////////////////////////////////////////////////////////
function LoadIcons(int UseJT)
{
	local int i;
	
	if (bTestLoad)
		log(self@"======================== LOADING ALL BUTTON ICONS");
	
	// Null out existing references
	for (i = 0; i < MAX_BUTTONS; i++)
		ButtonIcons[i] = None;
		
	// Populate icons with JT_Generic first, as a fallback.
	for (i = 0; i < JoyIcons.Length; i++)
		if (JoyIcons[i].Type == JT_Generic
			&& JoyIcons[i].Icon != "")
		{
			ButtonIcons[JoyIcons[i].Key] = Texture(DynamicLoadObject(JoyIcons[i].Icon,class'Texture'));
			if (bTestLoad && ButtonIcons[JoyIcons[i].Key] == None)
				warn("FAILED to load texture:"@JoyIcons[i].Icon);
		}
	
	// Now load up the ones specific to our control scheme (if not JT_Generic)
	if (UseJT != 0)
		for (i = 0; i < JoyIcons.Length; i++)
			if (JoyIcons[i].Type == UseJT
				&& JoyIcons[i].Icon != "")
			{
				ButtonIcons[JoyIcons[i].Key] = Texture(DynamicLoadObject(JoyIcons[i].Icon,class'Texture'));
				if (bTestLoad && ButtonIcons[JoyIcons[i].Key] == None)
					warn("FAILED to load texture:"@JoyIcons[i].Icon);
			}

	if (bTestLoad)
		log(self@"======================== LOADED ALL BUTTON ICONS");
}

///////////////////////////////////////////////////////////////////////////////
// GetIcon
// Returns the button icon for the passed-in key
///////////////////////////////////////////////////////////////////////////////
function Texture GetIcon(int UseKey)
{
	if (ButtonIcons[UseKey] != None)
		return ButtonIcons[UseKey];		
	else if (UseKey > 0)
		return MissingButton;
	else
		return MissingBinding;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	JoystickType=JT_Generic
	JoystickName[0]="Generic/PC Gamepad"
	JoystickName[1]="XBox 360 Controller"
	JoystickName[2]="XBox One Controller"
	JoystickName[3]="PlayStation 3 Controller"
	JoystickName[4]="PlayStation 4 Controller"
	JoystickName[5]="Wii/Wii U Controller"
	
	MissingButton=Texture'ButtonIcons.blank'
	MissingBinding=Texture'ButtonIcons.blank'
}
