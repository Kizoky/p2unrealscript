///////////////////////////////////////////////////////////////////////////////
// ShellMapListFrame.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
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
