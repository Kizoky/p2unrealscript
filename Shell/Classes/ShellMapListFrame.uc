///////////////////////////////////////////////////////////////////////////////
// ShellMapListFrame.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Frame window for the map list box.
//
///////////////////////////////////////////////////////////////////////////////
class ShellMapListFrame extends UWindowFramedWindow;

defaultproperties
	{
	WindowTitle="Load Custom Map..."
	ClientClass=class'ShellMapListCW'
	}
