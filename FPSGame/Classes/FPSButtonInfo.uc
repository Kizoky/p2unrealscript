///////////////////////////////////////////////////////////////////////////////
// ButtonInfo
// Copyright 2014 Running With Scissors, Inc
// All Rights Reserved
//
// Actor class for turning keyboard/button input names into icons
///////////////////////////////////////////////////////////////////////////////
class FPSButtonInfo extends Info
//	config(JoyButtons)
    config(User)
	notplaceable;
	
///////////////////////////////////////////////////////////////////////////////
// Consts, enums, variables, etc.
///////////////////////////////////////////////////////////////////////////////
const MAX_JOYSTICK_TYPES = 7;
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
    JT_SteamDeck    // Steam Deck controller
};

struct SJoyIcon
{
	var config EJoystickType Type;
	var config Interactions.EInputKey Key;
	var config String Icon;
};

var bool bTestLoad;								// If true, logs all errors when loading textures

var config int JoystickType;							// Defines the currently-used input scheme
var array<SJoyIcon> JoyIcons;					// Defines all button icons
var localized string JoystickName[MAX_JOYSTICK_TYPES];	// Defines names of input schemes
var Texture MissingButton;								// Placeholder for missing buttons
var Texture MissingBinding;								// Indicates no binding for this input

var Texture ButtonIcons[MAX_BUTTONS];					// Icons for currently-loaded input scheme
var FPSHud MyHUD;										// Pointer back to our HUD
var config bool bSteamDeckFirstRun;

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
// Populate all icons for our current joystick type
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
    // Load Steam Deck icons
    if (PlatformIsSteamDeck() && !bSteamDeckFirstRun) {
        bSteamDeckFirstRun = true;
        JoystickType = 6;
        SaveConfig();
        StaticSaveConfig();
    }

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
            else if (bTestLoad)
                log("Loaded texture "@ButtonIcons[JoyIcons[i].Key]);
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
            else if (bTestLoad)
                log("Loaded texture "@ButtonIcons[JoyIcons[i].Key]);
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
    JoystickName[6]="Steam Deck"
	
	MissingButton=Texture'ButtonIcons.blank'
	MissingBinding=Texture'ButtonIcons.blank'
    
    bSteamDeckFirstRun = false;

    JoyIcons[00]=(Type=JT_Generic,Key=IK_None,Icon="")
    JoyIcons[01]=(Type=JT_Generic,Key=IK_LeftMouse,Icon="ButtonIcons.Keyboard_White_Mouse_Left")
    JoyIcons[02]=(Type=JT_Generic,Key=IK_RightMouse,Icon="ButtonIcons.Keyboard_White_Mouse_Right")
    JoyIcons[03]=(Type=JT_Generic,Key=IK_Cancel,Icon="")
    JoyIcons[04]=(Type=JT_Generic,Key=IK_MiddleMouse,Icon="ButtonIcons.Keyboard_White_Mouse_Middle")
    JoyIcons[05]=(Type=JT_Generic,Key=IK_Unknown05,Icon="")
    JoyIcons[06]=(Type=JT_Generic,Key=IK_Unknown06,Icon="")
    JoyIcons[07]=(Type=JT_Generic,Key=IK_Unknown07,Icon="")
    JoyIcons[08]=(Type=JT_Generic,Key=IK_Backspace,Icon="ButtonIcons.Keyboard_White_Backspace")
    JoyIcons[09]=(Type=JT_Generic,Key=IK_Tab,Icon="ButtonIcons.Keyboard_White_Tab")
    JoyIcons[10]=(Type=JT_Generic,Key=IK_Unknown0A,Icon="")
    JoyIcons[11]=(Type=JT_Generic,Key=IK_Unknown0B,Icon="")
    JoyIcons[12]=(Type=JT_Generic,Key=IK_Unknown0C,Icon="ButtonIcons.Keyboard_Black_5")
    JoyIcons[13]=(Type=JT_Generic,Key=IK_Enter,Icon="ButtonIcons.Keyboard_White_Enter")
    JoyIcons[14]=(Type=JT_Generic,Key=IK_Unknown0E,Icon="")
    JoyIcons[15]=(Type=JT_Generic,Key=IK_Unknown0F,Icon="")
    JoyIcons[16]=(Type=JT_Generic,Key=IK_Shift,Icon="ButtonIcons.Keyboard_White_Shift")
    JoyIcons[17]=(Type=JT_Generic,Key=IK_Ctrl,Icon="ButtonIcons.Keyboard_White_Ctrl")
    JoyIcons[18]=(Type=JT_Generic,Key=IK_Alt,Icon="ButtonIcons.Keyboard_White_Alt")
    JoyIcons[19]=(Type=JT_Generic,Key=IK_Pause,Icon="ButtonIcons.Keyboard_White_Pause")
    JoyIcons[20]=(Type=JT_Generic,Key=IK_CapsLock,Icon="ButtonIcons.Keyboard_White_Caps_Lock")
    JoyIcons[21]=(Type=JT_Generic,Key=IK_Unknown15,Icon="")
    JoyIcons[22]=(Type=JT_Generic,Key=IK_Unknown16,Icon="")
    JoyIcons[23]=(Type=JT_Generic,Key=IK_Unknown17,Icon="")
    JoyIcons[24]=(Type=JT_Generic,Key=IK_Unknown18,Icon="")
    JoyIcons[25]=(Type=JT_Generic,Key=IK_Unknown19,Icon="")
    JoyIcons[26]=(Type=JT_Generic,Key=IK_Unknown1A,Icon="")
    JoyIcons[27]=(Type=JT_Generic,Key=IK_Escape,Icon="ButtonIcons.Keyboard_White_Esc")
    JoyIcons[28]=(Type=JT_Generic,Key=IK_Unknown1C,Icon="")
    JoyIcons[29]=(Type=JT_Generic,Key=IK_Unknown1D,Icon="")
    JoyIcons[30]=(Type=JT_Generic,Key=IK_Unknown1E,Icon="")
    JoyIcons[31]=(Type=JT_Generic,Key=IK_Unknown1F,Icon="")
    JoyIcons[32]=(Type=JT_Generic,Key=IK_Space,Icon="ButtonIcons.Keyboard_White_Space")
    JoyIcons[33]=(Type=JT_Generic,Key=IK_PageUp,Icon="ButtonIcons.Keyboard_White_Page_Up")
    JoyIcons[34]=(Type=JT_Generic,Key=IK_PageDown,Icon="ButtonIcons.Keyboard_White_Page_Down")
    JoyIcons[35]=(Type=JT_Generic,Key=IK_End,Icon="ButtonIcons.Keyboard_White_End")
    JoyIcons[36]=(Type=JT_Generic,Key=IK_Home,Icon="ButtonIcons.Keyboard_White_Home")
    JoyIcons[37]=(Type=JT_Generic,Key=IK_Left,Icon="ButtonIcons.Keyboard_White_Arrow_Left")
    JoyIcons[38]=(Type=JT_Generic,Key=IK_Up,Icon="ButtonIcons.Keyboard_White_Arrow_Up")
    JoyIcons[39]=(Type=JT_Generic,Key=IK_Right,Icon="ButtonIcons.Keyboard_White_Arrow_Right")
    JoyIcons[40]=(Type=JT_Generic,Key=IK_Down,Icon="ButtonIcons.Keyboard_White_Arrow_Down")
    JoyIcons[41]=(Type=JT_Generic,Key=IK_Select,Icon="")
    JoyIcons[42]=(Type=JT_Generic,Key=IK_Print,Icon="")
    JoyIcons[43]=(Type=JT_Generic,Key=IK_Execute,Icon="")
    JoyIcons[44]=(Type=JT_Generic,Key=IK_PrintScrn,Icon="ButtonIcons.Keyboard_White_Print_Screen")
    JoyIcons[45]=(Type=JT_Generic,Key=IK_Insert,Icon="ButtonIcons.Keyboard_White_Insert")
    JoyIcons[46]=(Type=JT_Generic,Key=IK_Delete,Icon="ButtonIcons.Keyboard_White_Del")
    JoyIcons[47]=(Type=JT_Generic,Key=IK_Help,Icon="")
    JoyIcons[48]=(Type=JT_Generic,Key=IK_0,Icon="ButtonIcons.Keyboard_White_0")
    JoyIcons[49]=(Type=JT_Generic,Key=IK_1,Icon="ButtonIcons.Keyboard_White_1")
    JoyIcons[50]=(Type=JT_Generic,Key=IK_2,Icon="ButtonIcons.Keyboard_White_2")
    JoyIcons[51]=(Type=JT_Generic,Key=IK_3,Icon="ButtonIcons.Keyboard_White_3")
    JoyIcons[52]=(Type=JT_Generic,Key=IK_4,Icon="ButtonIcons.Keyboard_White_4")
    JoyIcons[53]=(Type=JT_Generic,Key=IK_5,Icon="ButtonIcons.Keyboard_White_5")
    JoyIcons[54]=(Type=JT_Generic,Key=IK_6,Icon="ButtonIcons.Keyboard_White_6")
    JoyIcons[55]=(Type=JT_Generic,Key=IK_7,Icon="ButtonIcons.Keyboard_White_7")
    JoyIcons[56]=(Type=JT_Generic,Key=IK_8,Icon="ButtonIcons.Keyboard_White_8")
    JoyIcons[57]=(Type=JT_Generic,Key=IK_9,Icon="ButtonIcons.Keyboard_White_9")
    JoyIcons[58]=(Type=JT_Generic,Key=IK_Unknown3A,Icon="")
    JoyIcons[59]=(Type=JT_Generic,Key=IK_Unknown3B,Icon="")
    JoyIcons[60]=(Type=JT_Generic,Key=IK_Unknown3C,Icon="")
    JoyIcons[61]=(Type=JT_Generic,Key=IK_Unknown3D,Icon="")
    JoyIcons[62]=(Type=JT_Generic,Key=IK_Unknown3E,Icon="")
    JoyIcons[63]=(Type=JT_Generic,Key=IK_Unknown3F,Icon="")
    JoyIcons[64]=(Type=JT_Generic,Key=IK_Unknown40,Icon="")
    JoyIcons[65]=(Type=JT_Generic,Key=IK_A,Icon="ButtonIcons.Keyboard_White_A")
    JoyIcons[66]=(Type=JT_Generic,Key=IK_B,Icon="ButtonIcons.Keyboard_White_B")
    JoyIcons[67]=(Type=JT_Generic,Key=IK_C,Icon="ButtonIcons.Keyboard_White_C")
    JoyIcons[68]=(Type=JT_Generic,Key=IK_D,Icon="ButtonIcons.Keyboard_White_D")
    JoyIcons[69]=(Type=JT_Generic,Key=IK_E,Icon="ButtonIcons.Keyboard_White_E")
    JoyIcons[70]=(Type=JT_Generic,Key=IK_F,Icon="ButtonIcons.Keyboard_White_F")
    JoyIcons[71]=(Type=JT_Generic,Key=IK_G,Icon="ButtonIcons.Keyboard_White_G")
    JoyIcons[72]=(Type=JT_Generic,Key=IK_H,Icon="ButtonIcons.Keyboard_White_H")
    JoyIcons[73]=(Type=JT_Generic,Key=IK_I,Icon="ButtonIcons.Keyboard_White_I")
    JoyIcons[74]=(Type=JT_Generic,Key=IK_J,Icon="ButtonIcons.Keyboard_White_J")
    JoyIcons[75]=(Type=JT_Generic,Key=IK_K,Icon="ButtonIcons.Keyboard_White_K")
    JoyIcons[76]=(Type=JT_Generic,Key=IK_L,Icon="ButtonIcons.Keyboard_White_L")
    JoyIcons[77]=(Type=JT_Generic,Key=IK_M,Icon="ButtonIcons.Keyboard_White_M")
    JoyIcons[78]=(Type=JT_Generic,Key=IK_N,Icon="ButtonIcons.Keyboard_White_N")
    JoyIcons[79]=(Type=JT_Generic,Key=IK_O,Icon="ButtonIcons.Keyboard_White_O")
    JoyIcons[80]=(Type=JT_Generic,Key=IK_P,Icon="ButtonIcons.Keyboard_White_P")
    JoyIcons[81]=(Type=JT_Generic,Key=IK_Q,Icon="ButtonIcons.Keyboard_White_Q")
    JoyIcons[82]=(Type=JT_Generic,Key=IK_R,Icon="ButtonIcons.Keyboard_White_R")
    JoyIcons[83]=(Type=JT_Generic,Key=IK_S,Icon="ButtonIcons.Keyboard_White_S")
    JoyIcons[84]=(Type=JT_Generic,Key=IK_T,Icon="ButtonIcons.Keyboard_White_T")
    JoyIcons[85]=(Type=JT_Generic,Key=IK_U,Icon="ButtonIcons.Keyboard_White_U")
    JoyIcons[86]=(Type=JT_Generic,Key=IK_V,Icon="ButtonIcons.Keyboard_White_V")
    JoyIcons[87]=(Type=JT_Generic,Key=IK_W,Icon="ButtonIcons.Keyboard_White_W")
    JoyIcons[88]=(Type=JT_Generic,Key=IK_X,Icon="ButtonIcons.Keyboard_White_X")
    JoyIcons[89]=(Type=JT_Generic,Key=IK_Y,Icon="ButtonIcons.Keyboard_White_Y")
    JoyIcons[90]=(Type=JT_Generic,Key=IK_Z,Icon="ButtonIcons.Keyboard_White_Z")
    JoyIcons[91]=(Type=JT_Generic,Key=IK_Unknown5B,Icon="ButtonIcons.Keyboard_White_Win")
    JoyIcons[92]=(Type=JT_Generic,Key=IK_Unknown5C,Icon="")
    JoyIcons[93]=(Type=JT_Generic,Key=IK_Unknown5D,Icon="ButtonIcons.Keyboard_White_5D")
    JoyIcons[94]=(Type=JT_Generic,Key=IK_Unknown5E,Icon="")
    JoyIcons[95]=(Type=JT_Generic,Key=IK_Unknown5F,Icon="")
    JoyIcons[96]=(Type=JT_Generic,Key=IK_NumPad0,Icon="ButtonIcons.Keyboard_Black_0")
    JoyIcons[97]=(Type=JT_Generic,Key=IK_NumPad1,Icon="ButtonIcons.Keyboard_Black_1")
    JoyIcons[98]=(Type=JT_Generic,Key=IK_NumPad2,Icon="ButtonIcons.Keyboard_Black_2")
    JoyIcons[99]=(Type=JT_Generic,Key=IK_NumPad3,Icon="ButtonIcons.Keyboard_Black_3")
    JoyIcons[100]=(Type=JT_Generic,Key=IK_NumPad4,Icon="ButtonIcons.Keyboard_Black_4")
    JoyIcons[101]=(Type=JT_Generic,Key=IK_NumPad5,Icon="ButtonIcons.Keyboard_Black_5")
    JoyIcons[102]=(Type=JT_Generic,Key=IK_NumPad6,Icon="ButtonIcons.Keyboard_Black_6")
    JoyIcons[103]=(Type=JT_Generic,Key=IK_NumPad7,Icon="ButtonIcons.Keyboard_Black_7")
    JoyIcons[104]=(Type=JT_Generic,Key=IK_NumPad8,Icon="ButtonIcons.Keyboard_Black_8")
    JoyIcons[105]=(Type=JT_Generic,Key=IK_NumPad9,Icon="ButtonIcons.Keyboard_Black_9")
    JoyIcons[106]=(Type=JT_Generic,Key=IK_GreyStar,Icon="ButtonIcons.Keyboard_Black_Asterisk")
    JoyIcons[107]=(Type=JT_Generic,Key=IK_GreyPlus,Icon="ButtonIcons.Keyboard_Black_Plus_Tall")
    JoyIcons[108]=(Type=JT_Generic,Key=IK_Separator,Icon="")
    JoyIcons[109]=(Type=JT_Generic,Key=IK_GreyMinus,Icon="ButtonIcons.Keyboard_Black_Minus")
    JoyIcons[110]=(Type=JT_Generic,Key=IK_NumPadPeriod,Icon="ButtonIcons.Keyboard_Black_Del")
    JoyIcons[111]=(Type=JT_Generic,Key=IK_GreySlash,Icon="ButtonIcons.Keyboard_Black_ForwardSlash")
    JoyIcons[112]=(Type=JT_Generic,Key=IK_F1,Icon="ButtonIcons.Keyboard_White_F1")
    JoyIcons[113]=(Type=JT_Generic,Key=IK_F2,Icon="ButtonIcons.Keyboard_White_F2")
    JoyIcons[114]=(Type=JT_Generic,Key=IK_F3,Icon="ButtonIcons.Keyboard_White_F3")
    JoyIcons[115]=(Type=JT_Generic,Key=IK_F4,Icon="ButtonIcons.Keyboard_White_F4")
    JoyIcons[116]=(Type=JT_Generic,Key=IK_F5,Icon="ButtonIcons.Keyboard_White_F5")
    JoyIcons[117]=(Type=JT_Generic,Key=IK_F6,Icon="ButtonIcons.Keyboard_White_F6")
    JoyIcons[118]=(Type=JT_Generic,Key=IK_F7,Icon="ButtonIcons.Keyboard_White_F7")
    JoyIcons[119]=(Type=JT_Generic,Key=IK_F8,Icon="ButtonIcons.Keyboard_White_F8")
    JoyIcons[120]=(Type=JT_Generic,Key=IK_F9,Icon="ButtonIcons.Keyboard_White_F9")
    JoyIcons[121]=(Type=JT_Generic,Key=IK_F10,Icon="ButtonIcons.Keyboard_White_F10")
    JoyIcons[122]=(Type=JT_Generic,Key=IK_F11,Icon="ButtonIcons.Keyboard_White_F11")
    JoyIcons[123]=(Type=JT_Generic,Key=IK_F12,Icon="ButtonIcons.Keyboard_White_F12")
    JoyIcons[124]=(Type=JT_Generic,Key=IK_F13,Icon="")
    JoyIcons[125]=(Type=JT_Generic,Key=IK_F14,Icon="")
    JoyIcons[126]=(Type=JT_Generic,Key=IK_F15,Icon="")
    JoyIcons[127]=(Type=JT_Generic,Key=IK_F16,Icon="")
    JoyIcons[128]=(Type=JT_Generic,Key=IK_F17,Icon="")
    JoyIcons[129]=(Type=JT_Generic,Key=IK_F18,Icon="")
    JoyIcons[130]=(Type=JT_Generic,Key=IK_F19,Icon="")
    JoyIcons[131]=(Type=JT_Generic,Key=IK_F20,Icon="")
    JoyIcons[132]=(Type=JT_Generic,Key=IK_F21,Icon="")
    JoyIcons[133]=(Type=JT_Generic,Key=IK_F22,Icon="")
    JoyIcons[134]=(Type=JT_Generic,Key=IK_F23,Icon="")
    JoyIcons[135]=(Type=JT_Generic,Key=IK_F24,Icon="")
    JoyIcons[136]=(Type=JT_Generic,Key=IK_Unknown88,Icon="")
    JoyIcons[137]=(Type=JT_Generic,Key=IK_Unknown89,Icon="")
    JoyIcons[138]=(Type=JT_Generic,Key=IK_Unknown8A,Icon="")
    JoyIcons[139]=(Type=JT_Generic,Key=IK_Unknown8B,Icon="")
    JoyIcons[140]=(Type=JT_Generic,Key=IK_Unknown8C,Icon="")
    JoyIcons[141]=(Type=JT_Generic,Key=IK_Unknown8D,Icon="")
    JoyIcons[142]=(Type=JT_Generic,Key=IK_Unknown8E,Icon="")
    JoyIcons[143]=(Type=JT_Generic,Key=IK_Unknown8F,Icon="")
    JoyIcons[144]=(Type=JT_Generic,Key=IK_NumLock,Icon="ButtonIcons.Keyboard_Black_Num_Lock")
    JoyIcons[145]=(Type=JT_Generic,Key=IK_ScrollLock,Icon="ButtonIcons.Keyboard_White_ScrollLock")
    JoyIcons[146]=(Type=JT_Generic,Key=IK_Unknown92,Icon="")
    JoyIcons[147]=(Type=JT_Generic,Key=IK_Unknown93,Icon="")
    JoyIcons[148]=(Type=JT_Generic,Key=IK_Unknown94,Icon="")
    JoyIcons[149]=(Type=JT_Generic,Key=IK_Unknown95,Icon="")
    JoyIcons[150]=(Type=JT_Generic,Key=IK_Unknown96,Icon="")
    JoyIcons[151]=(Type=JT_Generic,Key=IK_Unknown97,Icon="")
    JoyIcons[152]=(Type=JT_Generic,Key=IK_Unknown98,Icon="")
    JoyIcons[153]=(Type=JT_Generic,Key=IK_Unknown99,Icon="")
    JoyIcons[154]=(Type=JT_Generic,Key=IK_Unknown9A,Icon="")
    JoyIcons[155]=(Type=JT_Generic,Key=IK_Unknown9B,Icon="")
    JoyIcons[156]=(Type=JT_Generic,Key=IK_Unknown9C,Icon="")
    JoyIcons[157]=(Type=JT_Generic,Key=IK_Unknown9D,Icon="")
    JoyIcons[158]=(Type=JT_Generic,Key=IK_Unknown9E,Icon="")
    JoyIcons[159]=(Type=JT_Generic,Key=IK_Unknown9F,Icon="")
    JoyIcons[160]=(Type=JT_Generic,Key=IK_LShift,Icon="ButtonIcons.Keyboard_White_Shift_Left")
    JoyIcons[161]=(Type=JT_Generic,Key=IK_RShift,Icon="ButtonIcons.Keyboard_White_Shift_Right")
    JoyIcons[162]=(Type=JT_Generic,Key=IK_LControl,Icon="ButtonIcons.Keyboard_White_Ctrl_Left")
    JoyIcons[163]=(Type=JT_Generic,Key=IK_RControl,Icon="ButtonIcons.Keyboard_White_Ctrl_Right")
    JoyIcons[164]=(Type=JT_Generic,Key=IK_UnknownA4,Icon="")
    JoyIcons[165]=(Type=JT_Generic,Key=IK_UnknownA5,Icon="")
    JoyIcons[166]=(Type=JT_Generic,Key=IK_UnknownA6,Icon="")
    JoyIcons[167]=(Type=JT_Generic,Key=IK_UnknownA7,Icon="")
    JoyIcons[168]=(Type=JT_Generic,Key=IK_UnknownA8,Icon="")
    JoyIcons[169]=(Type=JT_Generic,Key=IK_UnknownA9,Icon="")
    JoyIcons[170]=(Type=JT_Generic,Key=IK_UnknownAA,Icon="")
    JoyIcons[171]=(Type=JT_Generic,Key=IK_UnknownAB,Icon="")
    JoyIcons[172]=(Type=JT_Generic,Key=IK_UnknownAC,Icon="")
    JoyIcons[173]=(Type=JT_Generic,Key=IK_UnknownAD,Icon="")
    JoyIcons[174]=(Type=JT_Generic,Key=IK_UnknownAE,Icon="")
    JoyIcons[175]=(Type=JT_Generic,Key=IK_UnknownAF,Icon="")
    JoyIcons[176]=(Type=JT_Generic,Key=IK_UnknownB0,Icon="")
    JoyIcons[177]=(Type=JT_Generic,Key=IK_UnknownB1,Icon="")
    JoyIcons[178]=(Type=JT_Generic,Key=IK_UnknownB2,Icon="")
    JoyIcons[179]=(Type=JT_Generic,Key=IK_UnknownB3,Icon="")
    JoyIcons[180]=(Type=JT_Generic,Key=IK_UnknownB4,Icon="")
    JoyIcons[181]=(Type=JT_Generic,Key=IK_UnknownB5,Icon="")
    JoyIcons[182]=(Type=JT_Generic,Key=IK_UnknownB6,Icon="")
    JoyIcons[183]=(Type=JT_Generic,Key=IK_UnknownB7,Icon="")
    JoyIcons[184]=(Type=JT_Generic,Key=IK_UnknownB8,Icon="")
    JoyIcons[185]=(Type=JT_Generic,Key=IK_Unicode,Icon="")
    JoyIcons[186]=(Type=JT_Generic,Key=IK_Semicolon,Icon="ButtonIcons.Keyboard_White_Semicolon")
    JoyIcons[187]=(Type=JT_Generic,Key=IK_Equals,Icon="ButtonIcons.Keyboard_White_Equals")
    JoyIcons[188]=(Type=JT_Generic,Key=IK_Comma,Icon="ButtonIcons.Keyboard_White_Comma")
    JoyIcons[189]=(Type=JT_Generic,Key=IK_Minus,Icon="ButtonIcons.Keyboard_White_Minus")
    JoyIcons[190]=(Type=JT_Generic,Key=IK_Period,Icon="ButtonIcons.Keyboard_White_Period")
    JoyIcons[191]=(Type=JT_Generic,Key=IK_Slash,Icon="ButtonIcons.Keyboard_White_ForwardSlash")
    JoyIcons[192]=(Type=JT_Generic,Key=IK_Tilde,Icon="ButtonIcons.Keyboard_White_Tilda")
    JoyIcons[193]=(Type=JT_Generic,Key=IK_Mouse4,Icon="")
    JoyIcons[194]=(Type=JT_Generic,Key=IK_Mouse5,Icon="")
    JoyIcons[195]=(Type=JT_Generic,Key=IK_Mouse6,Icon="")
    JoyIcons[196]=(Type=JT_Generic,Key=IK_Mouse7,Icon="")
    JoyIcons[197]=(Type=JT_Generic,Key=IK_Mouse8,Icon="")
    JoyIcons[198]=(Type=JT_Generic,Key=IK_UnknownC6,Icon="")
    JoyIcons[199]=(Type=JT_Generic,Key=IK_UnknownC7,Icon="")
    JoyIcons[200]=(Type=JT_Generic,Key=IK_Joy1,Icon="ButtonIcons.Generic_1")
    JoyIcons[201]=(Type=JT_Generic,Key=IK_Joy2,Icon="ButtonIcons.Generic_2")
    JoyIcons[202]=(Type=JT_Generic,Key=IK_Joy3,Icon="ButtonIcons.Generic_3")
    JoyIcons[203]=(Type=JT_Generic,Key=IK_Joy4,Icon="ButtonIcons.Generic_4")
    JoyIcons[204]=(Type=JT_Generic,Key=IK_Joy5,Icon="ButtonIcons.Generic_5")
    JoyIcons[205]=(Type=JT_Generic,Key=IK_Joy6,Icon="ButtonIcons.Generic_6")
    JoyIcons[206]=(Type=JT_Generic,Key=IK_Joy7,Icon="ButtonIcons.Generic_7")
    JoyIcons[207]=(Type=JT_Generic,Key=IK_Joy8,Icon="ButtonIcons.Generic_8")
    JoyIcons[208]=(Type=JT_Generic,Key=IK_Joy9,Icon="ButtonIcons.Generic_9")
    JoyIcons[209]=(Type=JT_Generic,Key=IK_Joy10,Icon="ButtonIcons.Generic_10")
    JoyIcons[210]=(Type=JT_Generic,Key=IK_Joy11,Icon="ButtonIcons.Generic_11")
    JoyIcons[211]=(Type=JT_Generic,Key=IK_Joy12,Icon="ButtonIcons.Generic_12")
    JoyIcons[212]=(Type=JT_Generic,Key=IK_Joy13,Icon="ButtonIcons.Generic_13")
    JoyIcons[213]=(Type=JT_Generic,Key=IK_Joy14,Icon="ButtonIcons.Generic_14")
    JoyIcons[214]=(Type=JT_Generic,Key=IK_Joy15,Icon="ButtonIcons.Generic_15")
    JoyIcons[215]=(Type=JT_Generic,Key=IK_Joy16,Icon="ButtonIcons.Generic_16")
    JoyIcons[216]=(Type=JT_Generic,Key=IK_UnknownD8,Icon="")
    JoyIcons[217]=(Type=JT_Generic,Key=IK_UnknownD9,Icon="")
    JoyIcons[218]=(Type=JT_Generic,Key=IK_UnknownDA,Icon="")
    JoyIcons[219]=(Type=JT_Generic,Key=IK_LeftBracket,Icon="ButtonIcons.Keyboard_White_Bracket_Left")
    JoyIcons[220]=(Type=JT_Generic,Key=IK_Backslash,Icon="ButtonIcons.Keyboard_White_Slash")
    JoyIcons[221]=(Type=JT_Generic,Key=IK_RightBracket,Icon="ButtonIcons.Keyboard_White_Bracket_Right")
    JoyIcons[222]=(Type=JT_Generic,Key=IK_SingleQuote,Icon="ButtonIcons.Keyboard_White_SingleQuote")
    JoyIcons[223]=(Type=JT_Generic,Key=IK_UnknownDF,Icon="")
    JoyIcons[224]=(Type=JT_Generic,Key=IK_UnknownE0,Icon="")
    JoyIcons[225]=(Type=JT_Generic,Key=IK_UnknownE1,Icon="")
    JoyIcons[226]=(Type=JT_Generic,Key=IK_UnknownE2,Icon="")
    JoyIcons[227]=(Type=JT_Generic,Key=IK_UnknownE3,Icon="")
    JoyIcons[228]=(Type=JT_Generic,Key=IK_MouseX,Icon="ButtonIcons.Keyboard_White_Mouse_Simple")
    JoyIcons[229]=(Type=JT_Generic,Key=IK_MouseY,Icon="ButtonIcons.Keyboard_White_Mouse_Simple")
    JoyIcons[230]=(Type=JT_Generic,Key=IK_MouseZ,Icon="ButtonIcons.Keyboard_White_Mouse_Simple")
    JoyIcons[231]=(Type=JT_Generic,Key=IK_MouseW,Icon="ButtonIcons.Keyboard_White_Mouse_Simple")
    JoyIcons[232]=(Type=JT_Generic,Key=IK_JoyU,Icon="ButtonIcons.Generic_Axis_U")
    JoyIcons[233]=(Type=JT_Generic,Key=IK_JoyV,Icon="ButtonIcons.Generic_Axis_V")
    JoyIcons[234]=(Type=JT_Generic,Key=IK_JoySlider1,Icon="ButtonIcons.Generic_Axis_1")
    JoyIcons[235]=(Type=JT_Generic,Key=IK_JoySlider2,Icon="ButtonIcons.Generic_Axis_2")
    JoyIcons[236]=(Type=JT_Generic,Key=IK_MouseWheelUp,Icon="ButtonIcons.Keyboard_White_Mouse_WheelUp")
    JoyIcons[237]=(Type=JT_Generic,Key=IK_MouseWheelDown,Icon="ButtonIcons.Keyboard_White_Mouse_WheelDown")
    JoyIcons[238]=(Type=JT_Generic,Key=IK_Unknown10E,Icon="")
    JoyIcons[239]=(Type=JT_Generic,Key=IK_None,Icon="")
    JoyIcons[240]=(Type=JT_Generic,Key=IK_JoyX,Icon="ButtonIcons.Generic_Axis_X")
    JoyIcons[241]=(Type=JT_Generic,Key=IK_JoyY,Icon="ButtonIcons.Generic_Axis_Y")
    JoyIcons[242]=(Type=JT_Generic,Key=IK_JoyZ,Icon="ButtonIcons.Generic_Axis_Z")
    JoyIcons[243]=(Type=JT_Generic,Key=IK_JoyR,Icon="ButtonIcons.Generic_Axis_R")
    JoyIcons[244]=(Type=JT_Generic,Key=IK_UnknownF4,Icon="")
    JoyIcons[245]=(Type=JT_Generic,Key=IK_UnknownF5,Icon="")
    JoyIcons[246]=(Type=JT_Generic,Key=IK_Attn,Icon="")
    JoyIcons[247]=(Type=JT_Generic,Key=IK_CrSel,Icon="")
    JoyIcons[248]=(Type=JT_Generic,Key=IK_ExSel,Icon="")
    JoyIcons[249]=(Type=JT_Generic,Key=IK_ErEof,Icon="")
    JoyIcons[250]=(Type=JT_Generic,Key=IK_Play,Icon="")
    JoyIcons[251]=(Type=JT_Generic,Key=IK_Zoom,Icon="")
    JoyIcons[252]=(Type=JT_Generic,Key=IK_NoName,Icon="")
    JoyIcons[253]=(Type=JT_Generic,Key=IK_PA1,Icon="")
    JoyIcons[254]=(Type=JT_Generic,Key=IK_OEMClear,Icon="")
    JoyIcons[255]=(Type=JT_Xbox360,Key=IK_Joy1,Icon="ButtonIcons.360_Dpad_Up")
    JoyIcons[256]=(Type=JT_Xbox360,Key=IK_Joy2,Icon="ButtonIcons.360_Dpad_Down")
    JoyIcons[257]=(Type=JT_Xbox360,Key=IK_Joy3,Icon="ButtonIcons.360_Dpad_Left")
    JoyIcons[258]=(Type=JT_Xbox360,Key=IK_Joy4,Icon="ButtonIcons.360_Dpad_Right")
    JoyIcons[259]=(Type=JT_Xbox360,Key=IK_Joy5,Icon="ButtonIcons.360_Start_Alt")
    JoyIcons[260]=(Type=JT_Xbox360,Key=IK_Joy6,Icon="ButtonIcons.360_Back_Alt")
    JoyIcons[261]=(Type=JT_Xbox360,Key=IK_Joy7,Icon="ButtonIcons.360_Left_Stick")
    JoyIcons[262]=(Type=JT_Xbox360,Key=IK_Joy8,Icon="ButtonIcons.360_Right_Stick")
    JoyIcons[263]=(Type=JT_Xbox360,Key=IK_Joy9,Icon="ButtonIcons.360_LB")
    JoyIcons[264]=(Type=JT_Xbox360,Key=IK_Joy10,Icon="ButtonIcons.360_RB")
    JoyIcons[265]=(Type=JT_Xbox360,Key=IK_Joy11,Icon="ButtonIcons.360_LT")
    JoyIcons[266]=(Type=JT_Xbox360,Key=IK_Joy12,Icon="ButtonIcons.360_RT")
    JoyIcons[267]=(Type=JT_Xbox360,Key=IK_Joy13,Icon="ButtonIcons.360_A")
    JoyIcons[268]=(Type=JT_Xbox360,Key=IK_Joy14,Icon="ButtonIcons.360_B")
    JoyIcons[269]=(Type=JT_Xbox360,Key=IK_Joy15,Icon="ButtonIcons.360_X")
    JoyIcons[270]=(Type=JT_Xbox360,Key=IK_Joy16,Icon="ButtonIcons.360_Y")
    JoyIcons[271]=(Type=JT_Xbox360,Key=IK_JoyX,Icon="ButtonIcons.360_Left_Stick_Horizontal")
    JoyIcons[272]=(Type=JT_Xbox360,Key=IK_JoyY,Icon="ButtonIcons.360_Left_Stick_Vertical")
    JoyIcons[273]=(Type=JT_Xbox360,Key=IK_JoyU,Icon="ButtonIcons.360_Right_Stick_Horizontal")
    JoyIcons[274]=(Type=JT_Xbox360,Key=IK_JoyV,Icon="ButtonIcons.360_Right_Stick_Vertical")
    JoyIcons[275]=(Type=JT_Xbox360,Key=IK_JoySlider1,Icon="ButtonIcons.360_LT")
    JoyIcons[276]=(Type=JT_Xbox360,Key=IK_JoySlider2,Icon="ButtonIcons.360_RT")
    JoyIcons[277]=(Type=JT_XboxOne,Key=IK_Joy1,Icon="ButtonIcons.XboxOne_Dpad_Up")
    JoyIcons[278]=(Type=JT_XboxOne,Key=IK_Joy2,Icon="ButtonIcons.XboxOne_Dpad_Down")
    JoyIcons[279]=(Type=JT_XboxOne,Key=IK_Joy3,Icon="ButtonIcons.XboxOne_Dpad_Left")
    JoyIcons[280]=(Type=JT_XboxOne,Key=IK_Joy4,Icon="ButtonIcons.XboxOne_Dpad_Right")
    JoyIcons[281]=(Type=JT_XboxOne,Key=IK_Joy5,Icon="ButtonIcons.XboxOne_Menu")
    JoyIcons[282]=(Type=JT_XboxOne,Key=IK_Joy6,Icon="ButtonIcons.XboxOne_Windows")
    JoyIcons[283]=(Type=JT_XboxOne,Key=IK_Joy7,Icon="ButtonIcons.XboxOne_Left_Stick")
    JoyIcons[284]=(Type=JT_XboxOne,Key=IK_Joy8,Icon="ButtonIcons.XboxOne_Right_Stick")
    JoyIcons[285]=(Type=JT_XboxOne,Key=IK_Joy9,Icon="ButtonIcons.XboxOne_LB")
    JoyIcons[286]=(Type=JT_XboxOne,Key=IK_Joy10,Icon="ButtonIcons.XboxOne_RB")
    JoyIcons[287]=(Type=JT_XboxOne,Key=IK_Joy11,Icon="ButtonIcons.XboxOne_LT")
    JoyIcons[288]=(Type=JT_XboxOne,Key=IK_Joy12,Icon="ButtonIcons.XboxOne_RT")
    JoyIcons[289]=(Type=JT_XboxOne,Key=IK_Joy13,Icon="ButtonIcons.XboxOne_A")
    JoyIcons[290]=(Type=JT_XboxOne,Key=IK_Joy14,Icon="ButtonIcons.XboxOne_B")
    JoyIcons[291]=(Type=JT_XboxOne,Key=IK_Joy15,Icon="ButtonIcons.XboxOne_X")
    JoyIcons[292]=(Type=JT_XboxOne,Key=IK_Joy16,Icon="ButtonIcons.XboxOne_Y")
    JoyIcons[293]=(Type=JT_XboxOne,Key=IK_JoyX,Icon="ButtonIcons.XboxOne_Left_Stick_Horizontal")
    JoyIcons[294]=(Type=JT_XboxOne,Key=IK_JoyY,Icon="ButtonIcons.XboxOne_Left_Stick_Vertical")
    JoyIcons[295]=(Type=JT_XboxOne,Key=IK_JoyU,Icon="ButtonIcons.XboxOne_Right_Stick_Horizontal")
    JoyIcons[296]=(Type=JT_XboxOne,Key=IK_JoyV,Icon="ButtonIcons.XboxOne_Right_Stick_Vertical")
    JoyIcons[297]=(Type=JT_XboxOne,Key=IK_JoySlider1,Icon="ButtonIcons.XboxOne_LT")
    JoyIcons[298]=(Type=JT_XboxOne,Key=IK_JoySlider2,Icon="ButtonIcons.XboxOne_RT")
    JoyIcons[299]=(Type=JT_PS3,Key=IK_Joy1,Icon="ButtonIcons.PS3_Dpad_Up")
    JoyIcons[300]=(Type=JT_PS3,Key=IK_Joy2,Icon="ButtonIcons.PS3_Dpad_Down")
    JoyIcons[301]=(Type=JT_PS3,Key=IK_Joy3,Icon="ButtonIcons.PS3_Dpad_Left")
    JoyIcons[302]=(Type=JT_PS3,Key=IK_Joy4,Icon="ButtonIcons.PS3_Dpad_Right")
    JoyIcons[303]=(Type=JT_PS3,Key=IK_Joy5,Icon="ButtonIcons.PS3_Start")
    JoyIcons[304]=(Type=JT_PS3,Key=IK_Joy6,Icon="ButtonIcons.PS3_Select")
    JoyIcons[305]=(Type=JT_PS3,Key=IK_Joy7,Icon="ButtonIcons.PS3_Left_Stick")
    JoyIcons[306]=(Type=JT_PS3,Key=IK_Joy8,Icon="ButtonIcons.PS3_Right_Stick")
    JoyIcons[307]=(Type=JT_PS3,Key=IK_Joy9,Icon="ButtonIcons.PS3_L1")
    JoyIcons[308]=(Type=JT_PS3,Key=IK_Joy10,Icon="ButtonIcons.PS3_R1")
    JoyIcons[309]=(Type=JT_PS3,Key=IK_Joy11,Icon="ButtonIcons.PS3_L2")
    JoyIcons[310]=(Type=JT_PS3,Key=IK_Joy12,Icon="ButtonIcons.PS3_R2")
    JoyIcons[311]=(Type=JT_PS3,Key=IK_Joy13,Icon="ButtonIcons.PS3_Cross")
    JoyIcons[312]=(Type=JT_PS3,Key=IK_Joy14,Icon="ButtonIcons.PS3_Circle")
    JoyIcons[313]=(Type=JT_PS3,Key=IK_Joy15,Icon="ButtonIcons.PS3_Square")
    JoyIcons[314]=(Type=JT_PS3,Key=IK_Joy16,Icon="ButtonIcons.PS3_Triangle")
    JoyIcons[315]=(Type=JT_PS3,Key=IK_JoyX,Icon="ButtonIcons.PS3_Left_Stick_Horizontal")
    JoyIcons[316]=(Type=JT_PS3,Key=IK_JoyY,Icon="ButtonIcons.PS3_Left_Stick_Vertical")
    JoyIcons[317]=(Type=JT_PS3,Key=IK_JoyU,Icon="ButtonIcons.PS3_Right_Stick_Horizontal")
    JoyIcons[318]=(Type=JT_PS3,Key=IK_JoyV,Icon="ButtonIcons.PS3_Right_Stick_Vertical")
    JoyIcons[319]=(Type=JT_PS3,Key=IK_JoySlider1,Icon="")
    JoyIcons[320]=(Type=JT_PS3,Key=IK_JoySlider2,Icon="")
    JoyIcons[321]=(Type=JT_PS4,Key=IK_Joy1,Icon="ButtonIcons.PS4_Dpad_Up")
    JoyIcons[322]=(Type=JT_PS4,Key=IK_Joy2,Icon="ButtonIcons.PS4_Dpad_Down")
    JoyIcons[323]=(Type=JT_PS4,Key=IK_Joy3,Icon="ButtonIcons.PS4_Dpad_Left")
    JoyIcons[324]=(Type=JT_PS4,Key=IK_Joy4,Icon="ButtonIcons.PS4_Dpad_Right")
    JoyIcons[325]=(Type=JT_PS4,Key=IK_Joy5,Icon="ButtonIcons.PS4_Options")
    JoyIcons[326]=(Type=JT_PS4,Key=IK_Joy6,Icon="ButtonIcons.PS4_Share")
    JoyIcons[327]=(Type=JT_PS4,Key=IK_Joy7,Icon="ButtonIcons.PS4_Left_Stick")
    JoyIcons[328]=(Type=JT_PS4,Key=IK_Joy8,Icon="ButtonIcons.PS4_Right_Stick")
    JoyIcons[329]=(Type=JT_PS4,Key=IK_Joy9,Icon="ButtonIcons.PS4_L1")
    JoyIcons[330]=(Type=JT_PS4,Key=IK_Joy10,Icon="ButtonIcons.PS4_R1")
    JoyIcons[331]=(Type=JT_PS4,Key=IK_Joy11,Icon="ButtonIcons.PS4_L2")
    JoyIcons[332]=(Type=JT_PS4,Key=IK_Joy12,Icon="ButtonIcons.PS4_R2")
    JoyIcons[333]=(Type=JT_PS4,Key=IK_Joy13,Icon="ButtonIcons.PS4_Cross")
    JoyIcons[334]=(Type=JT_PS4,Key=IK_Joy14,Icon="ButtonIcons.PS4_Circle")
    JoyIcons[335]=(Type=JT_PS4,Key=IK_Joy15,Icon="ButtonIcons.PS4_Square")
    JoyIcons[336]=(Type=JT_PS4,Key=IK_Joy16,Icon="ButtonIcons.PS4_Triangle")
    JoyIcons[337]=(Type=JT_PS4,Key=IK_JoyX,Icon="ButtonIcons.PS4_Left_Stick_Horizontal")
    JoyIcons[338]=(Type=JT_PS4,Key=IK_JoyY,Icon="ButtonIcons.PS4_Left_Stick_Vertical")
    JoyIcons[339]=(Type=JT_PS4,Key=IK_JoyU,Icon="ButtonIcons.PS4_Right_Stick_Horizontal")
    JoyIcons[340]=(Type=JT_PS4,Key=IK_JoyV,Icon="ButtonIcons.PS4_Right_Stick_Vertical")
    JoyIcons[341]=(Type=JT_PS4,Key=IK_JoySlider1,Icon="")
    JoyIcons[342]=(Type=JT_PS4,Key=IK_JoySlider2,Icon="")
    JoyIcons[343]=(Type=JT_Wii,Key=IK_Joy1,Icon="ButtonIcons.WiiU_Dpad_Up")
    JoyIcons[344]=(Type=JT_Wii,Key=IK_Joy2,Icon="ButtonIcons.WiiU_Dpad_Down")
    JoyIcons[345]=(Type=JT_Wii,Key=IK_Joy3,Icon="ButtonIcons.WiiU_Dpad_Left")
    JoyIcons[346]=(Type=JT_Wii,Key=IK_Joy4,Icon="ButtonIcons.WiiU_Dpad_Right")
    JoyIcons[347]=(Type=JT_Wii,Key=IK_Joy5,Icon="ButtonIcons.WiiU_Plus")
    JoyIcons[348]=(Type=JT_Wii,Key=IK_Joy6,Icon="ButtonIcons.WiiU_Minus")
    JoyIcons[349]=(Type=JT_Wii,Key=IK_Joy7,Icon="ButtonIcons.WiiU_Left_Stick")
    JoyIcons[350]=(Type=JT_Wii,Key=IK_Joy8,Icon="ButtonIcons.WiiU_Right_Stick")
    JoyIcons[351]=(Type=JT_Wii,Key=IK_Joy9,Icon="ButtonIcons.WiiU_L")
    JoyIcons[352]=(Type=JT_Wii,Key=IK_Joy10,Icon="ButtonIcons.WiiU_R")
    JoyIcons[353]=(Type=JT_Wii,Key=IK_Joy11,Icon="ButtonIcons.WiiU_ZL")
    JoyIcons[354]=(Type=JT_Wii,Key=IK_Joy12,Icon="ButtonIcons.WiiU_ZR")
    JoyIcons[355]=(Type=JT_Wii,Key=IK_Joy13,Icon="ButtonIcons.WiiU_B")
    JoyIcons[356]=(Type=JT_Wii,Key=IK_Joy14,Icon="ButtonIcons.WiiU_A")
    JoyIcons[357]=(Type=JT_Wii,Key=IK_Joy15,Icon="ButtonIcons.WiiU_Y")
    JoyIcons[358]=(Type=JT_Wii,Key=IK_Joy16,Icon="ButtonIcons.WiiU_X")
    JoyIcons[359]=(Type=JT_Wii,Key=IK_JoyX,Icon="ButtonIcons.WiiU_Left_Stick_Horizontal")
    JoyIcons[360]=(Type=JT_Wii,Key=IK_JoyY,Icon="ButtonIcons.WiiU_Left_Stick_Vertical")
    JoyIcons[361]=(Type=JT_Wii,Key=IK_JoyU,Icon="ButtonIcons.WiiU_Right_Stick_Horizontal")
    JoyIcons[362]=(Type=JT_Wii,Key=IK_JoyV,Icon="ButtonIcons.WiiU_Right_Stick_Vertical")
    JoyIcons[363]=(Type=JT_Wii,Key=IK_JoySlider1,Icon="")
    JoyIcons[364]=(Type=JT_Wii,Key=IK_JoySlider2,Icon="")
    JoyIcons[365]=(Type=JT_SteamDeck,Key=IK_Joy1,Icon="ButtonIcons.SteamDeck_DPad_Up")
    JoyIcons[366]=(Type=JT_SteamDeck,Key=IK_Joy2,Icon="ButtonIcons.SteamDeck_DPad_Down")
    JoyIcons[367]=(Type=JT_SteamDeck,Key=IK_Joy3,Icon="ButtonIcons.SteamDeck_DPad_Left")
    JoyIcons[368]=(Type=JT_SteamDeck,Key=IK_Joy4,Icon="ButtonIcons.SteamDeck_DPad_Right")
    JoyIcons[369]=(Type=JT_SteamDeck,Key=IK_Joy5,Icon="ButtonIcons.SteamDeck_Start")
    JoyIcons[370]=(Type=JT_SteamDeck,Key=IK_Joy6,Icon="ButtonIcons.SteamDeck_Select")
    JoyIcons[371]=(Type=JT_SteamDeck,Key=IK_Joy7,Icon="ButtonIcons.SteamDeck_Left_Stick_L3")
    JoyIcons[372]=(Type=JT_SteamDeck,Key=IK_Joy8,Icon="ButtonIcons.SteamDeck_Right_Stick_R3")
    JoyIcons[373]=(Type=JT_SteamDeck,Key=IK_Joy9,Icon="ButtonIcons.SteamDeck_L1")
    JoyIcons[374]=(Type=JT_SteamDeck,Key=IK_Joy10,Icon="ButtonIcons.SteamDeck_R1")
    JoyIcons[375]=(Type=JT_SteamDeck,Key=IK_Joy11,Icon="ButtonIcons.SteamDeck_L2")
    JoyIcons[376]=(Type=JT_SteamDeck,Key=IK_Joy12,Icon="ButtonIcons.SteamDeck_R2")
    JoyIcons[377]=(Type=JT_SteamDeck,Key=IK_Joy13,Icon="ButtonIcons.SteamDeck_A")
    JoyIcons[378]=(Type=JT_SteamDeck,Key=IK_Joy14,Icon="ButtonIcons.SteamDeck_B")
    JoyIcons[379]=(Type=JT_SteamDeck,Key=IK_Joy15,Icon="ButtonIcons.SteamDeck_X")
    JoyIcons[380]=(Type=JT_SteamDeck,Key=IK_Joy16,Icon="ButtonIcons.SteamDeck_Y")
    JoyIcons[381]=(Type=JT_SteamDeck,Key=IK_Joy17,Icon="ButtonIcons.SteamDeck_L4")
    JoyIcons[382]=(Type=JT_SteamDeck,Key=IK_Joy18,Icon="ButtonIcons.SteamDeck_R4")
    JoyIcons[383]=(Type=JT_SteamDeck,Key=IK_Joy19,Icon="ButtonIcons.SteamDeck_L5")
    JoyIcons[384]=(Type=JT_SteamDeck,Key=IK_Joy20,Icon="ButtonIcons.SteamDeck_R5")
    JoyIcons[385]=(Type=JT_SteamDeck,Key=IK_JoyX,Icon="ButtonIcons.SteamDeck_Left_Stick_Horizontal")
    JoyIcons[386]=(Type=JT_SteamDeck,Key=IK_JoyY,Icon="ButtonIcons.SteamDeck_Left_Stick_Vertical")
    JoyIcons[387]=(Type=JT_SteamDeck,Key=IK_JoyU,Icon="ButtonIcons.SteamDeck_Right_Stick_Horizontal")
    JoyIcons[388]=(Type=JT_SteamDeck,Key=IK_JoyV,Icon="ButtonIcons.SteamDeck_Right_Stick_Vertical")
    JoyIcons[389]=(Type=JT_SteamDeck,Key=IK_JoyZ,Icon="ButtonIcons.SteamDeck_Left_Touchpad_Horizontal")
    JoyIcons[390]=(Type=JT_SteamDeck,Key=IK_JoyR,Icon="ButtonIcons.SteamDeck_Left_Touchpad_Vertical")
    JoyIcons[391]=(Type=JT_SteamDeck,Key=IK_JoyH,Icon="ButtonIcons.SteamDeck_Right_Touchpad_Horizontal ")
    JoyIcons[392]=(Type=JT_SteamDeck,Key=IK_JoyB,Icon="ButtonIcons.SteamDeck_Right_Touchpad_Vertical")
    JoyIcons[393]=(Type=JT_SteamDeck,Key=IK_JoySlider1,Icon="")
    JoyIcons[394]=(Type=JT_SteamDeck,Key=IK_JoySlider2,Icon="")
    JoyIcons[395]=(Type=JT_SteamDeck,Key=IK_Tab,Icon="ButtonIcons.SteamDeck_L4")
    JoyIcons[397]=(Type=JT_SteamDeck,Key=IK_K,Icon="ButtonIcons.SteamDeck_R4")
    JoyIcons[398]=(Type=JT_SteamDeck,Key=IK_T,Icon="ButtonIcons.SteamDeck_L5")
    JoyIcons[399]=(Type=JT_SteamDeck,Key=IK_Y,Icon="ButtonIcons.SteamDeck_R5")
    JoyIcons[400]=(Type=JT_SteamDeck,Key=IK_LeftBracket,Icon="ButtonIcons.SteamDeck_DPad_Left")
    JoyIcons[401]=(Type=JT_SteamDeck,Key=IK_RightBracket,Icon="ButtonIcons.SteamDeck_DPad_Right")
    
    bTestLoad=true
}
