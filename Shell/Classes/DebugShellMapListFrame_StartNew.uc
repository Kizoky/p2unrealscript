///////////////////////////////////////////////////////////////////////////////
// ShellMapListFrame.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Frame window for the map list box.
//
///////////////////////////////////////////////////////////////////////////////
class DebugShellMapListFrame_StartNew extends UWindowFramedWindow;

function SetGameType(string GameType)
{
	if (DebugShellMapListCW_StartNew(ClientArea) != None)
		DebugShellMapListCW_StartNew(ClientArea).SetGameType(GameType);
}

defaultproperties
	{
	WindowTitle="Load Map..."
	ClientClass=class'DebugShellMapListCW_StartNew'
	}
