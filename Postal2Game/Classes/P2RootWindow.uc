///////////////////////////////////////////////////////////////////////////////
// P2RootWindow.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Root window for our menu systems.  Really just a simple buffer class so
// we can add a few features.
//
///////////////////////////////////////////////////////////////////////////////
class P2RootWindow extends FPSRootWindow
	abstract;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that a game is starting.
///////////////////////////////////////////////////////////////////////////////
function StartingGame();

///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that a game is ending.
///////////////////////////////////////////////////////////////////////////////
function EndingGame();

///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that demo has been beaten.
///////////////////////////////////////////////////////////////////////////////
function BeatDemo();
///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that demo has timed out
///////////////////////////////////////////////////////////////////////////////
function TimedOutDemo();
///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that the player has been arrested in the demo.
///////////////////////////////////////////////////////////////////////////////
function ArrestedDemo();
///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system when and Old save needs it's difficulty patched.
///////////////////////////////////////////////////////////////////////////////
function DifficultyPatch();

///////////////////////////////////////////////////////////////////////////////
// Tell the menu system to hide all it's windows
///////////////////////////////////////////////////////////////////////////////
function HideMenu();

///////////////////////////////////////////////////////////////////////////////
// Call this to toggle between main and game menus (intended as a cheat)
///////////////////////////////////////////////////////////////////////////////
function MenuMode();

///////////////////////////////////////////////////////////////////////////////
// Call this to disable the menu for level transitions
///////////////////////////////////////////////////////////////////////////////
function DisableMenu();

function EnableMenu();

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
