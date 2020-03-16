///////////////////////////////////////////////////////////////////////////////
// InputTrackerInteraction
// Copyright 2014 Running With Scissors, Inc. All Rights Reserved
//
// This class has one job and one job only: track whether the last input
// made by the player was from the JOYSTICK or KEYBOARD AND MOUSE.
///////////////////////////////////////////////////////////////////////////////
class InputTrackerInteraction extends Interaction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc
///////////////////////////////////////////////////////////////////////////////
var bool bUsingJoystick;		// The one-and-only thing this class tracks

///////////////////////////////////////////////////////////////////////////////
// KeyEvent - receives input and if it was from the joystick, sets
// bUsingJoystick to true so we can display the proper icons.
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	// If input key is a joystick button or axis, say we're using the joystick.
	if ((Key >= IK_Joy1 && Key <= IK_Joy16)
		|| (Key >= IK_JoyU && Key <= IK_JoySlider2)
		|| (Key >= IK_JoyX && Key <= IK_JoyR))
	{
		// If axis movement, make sure it's a definitive movement and not deadzone crap going on
		if (Action == IST_Axis && abs(Delta) < 0.2)
			return false;
		bUsingJoystick = true;
	}
	else // Otherwise, don't
		bUsingJoystick = false;
		
	// This class does nothing else, so say we didn't handle the input.
	return false;
}
