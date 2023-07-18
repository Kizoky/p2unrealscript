///////////////////////////////////////////////////////////////////////////////
// ShellMapListFrame.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
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
