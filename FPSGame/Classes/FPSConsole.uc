///////////////////////////////////////////////////////////////////////////////
// FPSConsole.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Simple, one-line console used for typing, talking, and team talking.
//
///////////////////////////////////////////////////////////////////////////////
class FPSConsole extends Console;
	

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var float			SlideUp;


///////////////////////////////////////////////////////////////////////////////
// Returns true if the console is allowed to come up at this time
///////////////////////////////////////////////////////////////////////////////
function bool IsConsoleAllowed()
{
	return !(FPSRootWindow(Master.BaseMenu) != None && FPSRootWindow(Master.BaseMenu).MenuBlocksConsole());
}

///////////////////////////////////////////////////////////////////////////////
// Typing state
///////////////////////////////////////////////////////////////////////////////
state Typing
	{
	function PostRender(Canvas Canvas)
		{
		local float xl,yl;
		local string OutStr;
		local float height;
		
		Canvas.Font	 = font'ConsoleFont';
		OutStr = ">"@TypedStr$"_";
		Canvas.Strlen(OutStr,xl,yl);
		
		height = yl + 6;
		if (SlideUp < height)
			SlideUp += 2;
		
		Canvas.Style = 5;	// STY_Alpha
		Canvas.SetDrawColor(0,0,0,100);
		Canvas.SetPos(0,Canvas.ClipY-SlideUp);
		Canvas.DrawTile( texture 'ConsoleBk', Canvas.ClipX, SlideUp,0,0,32,32);
		
		Canvas.Style = 5;	// STY_Alpha
		Canvas.SetDrawColor(220,0,0,100);
		Canvas.SetPos(0,Canvas.ClipY-SlideUp-1);
		Canvas.DrawTile( texture 'ConsoleBdr', Canvas.ClipX, 1,0,0,32,32);
		
		Canvas.Style = 1;	// STY_Normal
		Canvas.SetDrawColor(220,220,220);
		Canvas.SetPos(10,Canvas.ClipY-SlideUp+3);
		Canvas.bCenter = False;
		Canvas.DrawText( OutStr, false );
		}
	
	function BeginState()
		{
		Super.BeginState();
		SlideUp = 0;
		}
	}

event ConnectFailure( string FailCode, string URL )
{
	local FPSRootWindow Root;

	if(FailCode == "NEEDPW" || FailCode == "WRONGPW")
	{		
		Root = FPSRootWindow(Master.BaseMenu);
		Root.GotoPasswordWindow(URL);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
