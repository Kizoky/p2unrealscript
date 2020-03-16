///////////////////////////////////////////////////////////////////////////////
// JoyMouseInteraction
// Copyright 2014, Running With Scissors Inc. All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
class JoyMouseInteraction extends Interaction
	config(User);
	
var config float XJoyMult, YJoyMult, XDeadZone, YDeadZone;

const MOUSE_X_AXIS = "MenuMouseX";
const MOUSE_Y_AXIS = "MenuMouseY";

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
static function StaticMoveMouse(PlayerController PlayerLocal, EInputKey Key, EInputAction Action, float Delta)
{
	local float MouseX, MouseY, NewMouseX, NewMouseY, DeltaTime;
	local float OldMouseX, OldMouseY, UseMouseX, UseMouseY, LastMouseTime;
	local int IntMouseX, IntMouseY;
	local UWindowRootWindow Root;
	
	if (Action == IST_Axis)
	{
		Root = UWindowRootWindow(PlayerLocal.Player.InteractionMaster.BaseMenu);
		if (Root.IsInState('MenuShowing')
			|| Root.bAllowJoyMouse)
		{
			OldMouseX = PlayerLocal.OldMouseX;
			OldMouseY = PlayerLocal.OldMouseY;
			UseMouseX = PlayerLocal.UseMouseX;
			UseMouseY = PlayerLocal.UseMouseY;

			MouseX = Root.MouseX;
			MouseY = Root.MouseY;
			NewMouseX = MouseX;
			NewMouseY = MouseY;
			
			if (PlayerLocal.ConsoleCommand("ISKEYBIND"@Key@MOUSE_X_AXIS) == "1")
			{
				DeltaTime = PlayerLocal.Level.TimeSecondsAlways - PlayerLocal.LastMouseTimeX;
				if (Abs(Delta) > Abs(UseMouseX))
				{
					if ((Delta < 0 && UseMouseX > 0)
						|| (Delta > 0 && UseMouseX < 0))
						UseMouseX = 0;
					else
						UseMouseX += DeltaTime * Default.XJoyMult * 1.5 * Delta;
				}
				else
					UseMouseX = Delta * Default.XJoyMult * 1.5;
				OldMouseX = Delta * Default.XJoyMult * 1.5;

				if (abs(Delta) * 10 <= Default.XDeadZone)
					UseMouseX = 0;

				if (Delta < 0)
					UseMouseX = FClamp(UseMouseX, Delta * Default.XJoyMult * 1.5, 0);
				else
					UseMouseX = FClamp(UseMouseX, 0, Delta * Default.XJoyMult * 1.5);
					
				NewMouseX = MouseX + UseMouseX;
				//log("X Axis"@Delta@DeltaTime@OldMouseX@UseMouseX@NewMouseX);
				PlayerLocal.LastMouseTimeX = PlayerLocal.Level.TimeSecondsAlways;
			}
			if (PlayerLocal.ConsoleCommand("ISKEYBIND"@Key@MOUSE_Y_AXIS) == "1")
			{
				DeltaTime = PlayerLocal.Level.TimeSecondsAlways - PlayerLocal.LastMouseTimeY;
				Delta = -Delta;
				if (Abs(Delta) > Abs(UseMouseY))
				{
					if ((Delta < 0 && UseMouseY > 0)
						|| (Delta > 0 && UseMouseY < 0))
						UseMouseY = 0;
					else
						UseMouseY += DeltaTime * Default.YJoyMult * 1.5 * Delta;
				}
				else
					UseMouseY = Delta * Default.YJoyMult * 1.5;
				OldMouseY = Delta * Default.YJoyMult * 1.5;

				if (abs(Delta) * 10 <= Default.YDeadZone)
					UseMouseY = 0;

				if (Delta < 0)
					UseMouseY = FClamp(UseMouseY, Delta * Default.YJoyMult * 1.5, 0);
				else
					UseMouseY = FClamp(UseMouseY, 0, Delta * Default.YJoyMult * 1.5);
					
				NewMouseY = MouseY + UseMouseY;
				//log("Y Axis"@Delta@DeltaTime@OldMouseY@UseMouseY@NewMouseY);
				PlayerLocal.LastMouseTimeY = PlayerLocal.Level.TimeSecondsAlways;
			}			

			if (MouseX != NewMouseX || MouseY != NewMouseY)
			{
				IntMouseX = NewMouseX;
				IntMouseY = NewMouseY;
				PlayerLocal.ConsoleCommand("SETMOUSE"@IntMouseX@IntMouseY);
				UWindowRootWindow(PlayerLocal.Player.InteractionMaster.BaseMenu).MoveMouse(NewMouseX, NewMouseY);
				//log(PlayerLocal.Player.InteractionMaster.BaseMenu@"SETMOUSE"@IntMouseX@IntMouseY);
			}

			PlayerLocal.OldMouseX = OldMouseX;
			PlayerLocal.OldMouseY = OldMouseY;
			PlayerLocal.UseMouseX = UseMouseX;
			PlayerLocal.UseMouseY = UseMouseY;
		}
	}	
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{	
	StaticMoveMouse(ViewportOwner.Actor, Key, Action, Delta);
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bRequiresTick = true
	XJoyMult = 5.0
	YJoyMult = 5.0
	XDeadZone = 1.0
	YDeadZone = 1.0
}
