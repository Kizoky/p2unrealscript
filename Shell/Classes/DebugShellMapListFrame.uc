///////////////////////////////////////////////////////////////////////////////
// ShellMapListFrame.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Frame window for the map list box.
//
///////////////////////////////////////////////////////////////////////////////
class DebugShellMapListFrame extends UWindowFramedWindow;

defaultproperties
	{
	WindowTitle="Load Map..."
	ClientClass=class'DebugShellMapListCW'
	}
