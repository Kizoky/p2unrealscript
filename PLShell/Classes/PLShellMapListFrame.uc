///////////////////////////////////////////////////////////////////////////////
// ShellMapListFrame.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Frame window for the map list box.
//
///////////////////////////////////////////////////////////////////////////////
class PLShellMapListFrame extends UWindowFramedWindow;

defaultproperties
	{
	WindowTitle="Load Map..."
	ClientClass=class'PLShellMapListCW'
	}
