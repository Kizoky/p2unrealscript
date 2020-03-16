///////////////////////////////////////////////////////////////////////////////
// PickScreen.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The pick-a-dude screen.
//
//	History:
//		07/12/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class PickScreen extends P2Screen;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() Texture Cursor;
var() Sound PickedEvilSound;
var() Sound PickedGoodSound;
var() float PrePickDelay;
var() float FadeOutAllTime;

var bool bEndAfterActualTravel;

var bool bOnLeft;
var bool bOnRight;


///////////////////////////////////////////////////////////////////////////////
// Call this to bring up the screen
///////////////////////////////////////////////////////////////////////////////
function Show()
	{
	// Set our first state and start it up
	AfterFadeInScreen = 'PrePick';
	Super.Start();
	}

///////////////////////////////////////////////////////////////////////////////
// Called before player travels to a new level
///////////////////////////////////////////////////////////////////////////////
function PreTravel()
	{
	Super.PreTravel();

	// Get rid of all actors because they'll be invalid in the new level (not
	// doing this will lead to intermittent crashes!)
	}

///////////////////////////////////////////////////////////////////////////////
// Manipulate the lights in the level
///////////////////////////////////////////////////////////////////////////////
function UpdateLights(bool bLeftSide)
	{
	local Name OffTag;
	local Name OnTag;

	if (bLeftSide)
		{
		OffTag = 'Right';
		bOnRight = false;
		OnTag = 'Left';
		bOnLeft = true;
		}
	else
		{
		OffTag = 'Left';
		bOnLeft = false;
		OnTag = 'Right';
		bOnRight = true;
		}
	TurnLightsOff(OffTag);
	TurnLightsOn(OnTag);
	}

function TurnLightsOff(Name TheTag)
	{
	local Actor a;
	// This is reversed because the lights start "on" by default,
	// which in Epic's mind means you Trigger them to turn them off.
	foreach ViewportOwner.Actor.AllActors(class'Actor', a, TheTag)
		a.Trigger(ViewportOwner.Actor, None);
	}

function TurnLightsOn(Name TheTag)
	{
	local Actor a;
	// This is reversed because the lights start "on" by default,
	// which in Epic's mind means you UnTrigger them to turn them on.
	foreach ViewportOwner.Actor.AllActors(class'Actor', a, TheTag)
		a.UnTrigger(ViewportOwner.Actor, None);
	}

///////////////////////////////////////////////////////////////////////////////
// Default tick function.
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
	{
	Super.Tick(DeltaTime);

	if (bEndNow)
		GotoState('Shutdown');
	}

///////////////////////////////////////////////////////////////////////////////
// Wait a little while before allowing player to pick
///////////////////////////////////////////////////////////////////////////////
state PrePick extends ShowScreen
	{
	function BeginState()
		{
		MaybeLog("PickScreen.PrePick.BeginState()");
		DelayedGotoState(PrePickDelay, 'WaitForPick');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Wait for player to pick a dude.  As the player moves his cursor around we
// turn on and off the lights to highlight one of the two dudes, depending
// on which one his cusor is closest to.
///////////////////////////////////////////////////////////////////////////////
state WaitForPick extends ShowScreen
	{
	function BeginState()
		{
		MaybeLog("PickScreen.WaitForPick.BeginState()");
		}

	function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
		{
		local bool bHandled;

		if (Action == IST_Press)
			{
			if (Key == IK_RightMouse || Key == IK_LeftMouse)
				{
				GotoState('GotPick');
				bHandled = true;
				}
			}

		return bHandled;
		}

	function RenderScreen(canvas Canvas)
		{
		Super.RenderScreen(Canvas);

		if (ViewportOwner.WindowsMouseX < Canvas.ClipX / 2)
			{
			if (!bOnLeft)
				UpdateLights(true);
			}
		else
			{
			if (!bOnRight)
				UpdateLights(false);
			}

		// Draw text descriptions of current choice
		Canvas.Font = Canvas.SmallFont;
		Canvas.Style = 1; //ERenderStyle.STY_Normal;
		Canvas.SetDrawColor(255,0,0);

		// Draw cursor
		DrawScaled(canvas, Cursor, ViewportOwner.WindowsMouseX/ScaleX, ViewportOwner.WindowsMouseY/ScaleY, true);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Got a pick
///////////////////////////////////////////////////////////////////////////////
state GotPick extends ShowScreen
	{
	function BeginState()
		{
		local float Duration;
		local Sound snd;

		MaybeLog("PickScreen.GotPick.BeginState()");

		if (bOnLeft)
			snd = PickedEvilSound;
		else
			snd = PickedGoodSound;

		Duration = GetSoundDuration(snd);
		GetSoundActor().PlaySound(snd, SLOT_Talk);
		DelayedGotoState(Duration, 'FadeOutAll');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Turn off lights and fade out
///////////////////////////////////////////////////////////////////////////////
state FadeOutAll extends ShowScreen
	{
	function BeginState()
		{
		MaybeLog("PickScreen.FadeOutAll.BeginState()");
		TurnLightsOff('Left');
		TurnLightsOff('Right');
		SetFadeOut(FadeOutAllTime, true);
		DelayedGotoState(FadeOutAllTime, 'StartFirstDay');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Start first day
///////////////////////////////////////////////////////////////////////////////
state StartFirstDay extends ShowScreen
	{
	function BeginState()
		{
		MaybeLog("PickScreen.StartFirstDay.BeginState()");
		GetGameSingle().SendPlayerToFirstDay(ViewportOwner.Actor); //, bOnRight);
		GotoState('Shutdown');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     PrePickDelay=4.500000
     FadeOutAllTime=1.000000
     bDontPauseGame=True
     bWantInputEvents=True
     bFadeGameInOut=False
     FadeInGameTime=0.000000
     FadeOutGameTime=0.000000
     bFadeScreenInOut=False
     FadeInScreenTime=0.000000
     FadeOutScreenTime=0.000000
}
