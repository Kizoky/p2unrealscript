///////////////////////////////////////////////////////////////////////////////
// FPSConsoleExt.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Multi-line console.
//
///////////////////////////////////////////////////////////////////////////////
class FPSConsoleExt extends FPSConsole;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var globalconfig int			MaxScrollbackSize;

var array<string>				Scrollback;
var int							SBHead;
var int							SBPos;
var bool						bCtrl;
var bool						bConsoleKey;

const TEAMSAY_CMD_STR		= "TEAMSAY";
const SAY_CMD_STR			= "SAY";
// This has to match the same string in fpshud, except for the space at the beginning
// of this one 
// This HAS to match FPSPlayer's also!
const TEAM_STR_LOCK			= " (-*Team..)";
// This HAS to match FPSPlayer's also!


///////////////////////////////////////////////////////////////////////////////
// Open, close and toggle the console
///////////////////////////////////////////////////////////////////////////////
exec function ConsoleOpen()
{
	if (IsConsoleAllowed())
	{
		TypedStr = "";
		GotoState('ConsoleVisible');
	}
}

exec function ConsoleClose()
{
	TypedStr="";
	if( GetStateName() == 'ConsoleVisible' )
		GotoState( '' );
}

exec function ConsoleToggle()
{
	if( GetStateName() == 'ConsoleVisible' )
		ConsoleClose();
	else
		ConsoleOpen();
}

///////////////////////////////////////////////////////////////////////////////
// Clear the screen (console)
///////////////////////////////////////////////////////////////////////////////
exec function CLS()
{
	SBHead = 0;
	ScrollBack.Remove(0,ScrollBack.Length);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostRender( canvas Canvas );	// Subclassed in state

///////////////////////////////////////////////////////////////////////////////
// Add messages to buffer
///////////////////////////////////////////////////////////////////////////////
event Message( coerce string Msg, float MsgLife)
{
	if (ScrollBack.Length==MaxScrollBackSize)	// if full, Remove Entry 0
	{
		ScrollBack.Remove(0,1);
		SBHead = MaxScrollBackSize-1;
	}
	else
		SBHead++;
	
	ScrollBack.Length = ScrollBack.Length + 1;
	
	Scrollback[SBHead] = Msg;
	Super.Message(Msg,MsgLife);
}

///////////////////////////////////////////////////////////////////////////////
// State for when console is visible
///////////////////////////////////////////////////////////////////////////////
state ConsoleVisible
{
	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		local PlayerController PC;
		
		if (bIgnoreKeys || bConsoleKey)
			return true;
		
		if (ViewportOwner != none)
			PC = ViewportOwner.Actor;
		
		if (bCtrl && PC != none)
		{
			if (Key == 3) //copy
			{
				PC.CopyToClipboard(TypedStr);
				return true;
			}
			else if (Key == 22) //paste
			{
				TypedStr = TypedStr$PC.PasteFromClipboard();
				return true;
			}
			else if (Key == 24) // cut
			{
				PC.CopyToClipboard(TypedStr);
				TypedStr="";
				return true;
			}
		}
		
		if( Key>=0x20 )
		{
			if( Unicode != "" )
				TypedStr = TypedStr $ Unicode;
			else
				TypedStr = TypedStr $ Chr(Key);
			return( true );
		}
		
		return( true );
	}
	
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;
		
		if (!bGotKeyBindings)
			UpdateKeyBinding();

		if( Key==IK_Ctrl )
		{
			if (Action == IST_Press)
				bCtrl = true;
			else if (Action == IST_Release)
				bCtrl = false;
		}
		
		if (Action== IST_PRess)
		{
			bIgnoreKeys = false;
		}
		
		if(Key == ConsoleKey)
		{
			if(Action == IST_Press)
				bConsoleKey = true;
			else if(Action == IST_Release && bConsoleKey)
				ConsoleClose();
			return true;
		}
		else if (Key==IK_Escape)
		{
			if (Action==IST_Release)
			{
				if (TypedStr!="")
				{
					TypedStr="";
					HistoryCur = HistoryTop;
				}
				else
				{
					ConsoleClose();
					return true;
				}
			}
			return true;
		}
		else if( Action != IST_Press )
			return( true );
		
		else if( Key==IK_Enter )
		{
			if( TypedStr!="" )
			{
				// Print to console.
				
				History[HistoryTop] = TypedStr;
				HistoryTop = (HistoryTop+1) % ArrayCount(History);
				
				if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
					HistoryBot = (HistoryBot+1) % ArrayCount(History);
				
				HistoryCur = HistoryTop;
				
				// Make a local copy of the string.
				Temp=TypedStr;
				TypedStr="";
				
				if( !ConsoleCommand( Temp ) )
					Message( Localize("Errors","Exec","Core"), 6.0 );
				
				Message( "", 6.0 );
			}
			
			return( true );
		}
		else if( Key==IK_Up )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryBot)
					HistoryCur = HistoryTop;
				else
				{
					HistoryCur--;
					if (HistoryCur<0)
						HistoryCur = ArrayCount(History)-1;
				}
				
				TypedStr = History[HistoryCur];
			}
			return( true );
		}
		else if( Key==IK_Down )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryTop)
					HistoryCur = HistoryBot;
				else
					HistoryCur = (HistoryCur+1) % ArrayCount(History);
				
				TypedStr = History[HistoryCur];
			}
			
		}
		else if( Key==IK_Backspace || Key==IK_Left )
		{
			if( Len(TypedStr)>0 )
				TypedStr = Left(TypedStr,Len(TypedStr)-1);
			return( true );
		}
		
		else if ( Key==IK_PageUp || key==IK_MouseWheelUp )
		{
			if (SBPos<ScrollBack.Length-1)
			{
				if (bCtrl)
					SBPos+=5;
				else
					SBPos++;
				
				if (SBPos>=ScrollBack.Length)
					SBPos = ScrollBack.Length-1;
			}
			
			return true;
		}
		else if ( Key==IK_PageDown || key==IK_MouseWheelDown)
		{
			if (SBPos>0)
			{
				if (bCtrl)
					SBPos-=5;
				else
					SBPos--;
				
				if (SBPos<0)
					SBPos = 0;
			}
		}
		
		return( true );
	}

	function BeginState()
	{
		SBPos = 0;
		bVisible= true;
		bIgnoreKeys = true;
		bConsoleKey = false;
		HistoryCur = HistoryTop;
		bCtrl = false;
	}
	function EndState()
	{
		bVisible = false;
		bCtrl = false;
		bConsoleKey = false;
	}

	function PostRender( canvas Canvas )
	{
		
		local float fw,fh;
		local float yclip,y;
		local int idx;
		
		Canvas.Style = 5;	// STY_Alpha
		Canvas.Font	 = font'ConsoleFont';
		Canvas.bCenter = False;
		yclip = canvas.ClipY*0.5;
		Canvas.StrLen("X",fw,fh);
		
		Canvas.SetPos(0,0);
		Canvas.SetDrawColor(255,255,255,100);
		Canvas.DrawTile(texture 'ConsoleBk',Canvas.ClipX,yClip,0,0,32,32);
		
		Canvas.SetPos(0,yclip-1);
		Canvas.SetDrawColor(220,0,0,100);
		Canvas.DrawTile(texture 'ConsoleBdr',Canvas.ClipX,1,0,0,32,32);
		
		Canvas.Style = 1;	// STY_Normal
		Canvas.SetPos(0,yclip-5-fh);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawText(">"@TypedStr$"_");
		
		idx = SBHead - SBPos;
		y = yClip-y-5-(fh*2);
		
		if (ScrollBack.Length==0)
			return;
		
		while (y>fh && idx>=0)
		{
			Canvas.SetPos(0,y);
			Canvas.DrawText(Scrollback[idx],false);
			idx--;
			y-=fh;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Same KeyEvent as our parent, but we've added a parse for TeamSay. 
// This is for version 1409 and beyond. We're dealing with a bug in PlayerController
// in the TeamSay there. It should pass 'TeamSay' as the type, then the 
// FPSHud could take the type and change the color, and add 'team' to the message
// for more ease of use. Instead, because that's inside an exec function which
// are very tricky, which we can't extend or modify, we have to work around it.
// That's the purpose of this extension. To intercept team messages, and
// before the send, add a string inside it for the FPSHud to decode, then do
// all the pretty things to it to make team messages easier to recoginze and use. 
///////////////////////////////////////////////////////////////////////////////
state Typing
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string tstr, Temp;
		local FPSPlayer fplayer;
		local bool bSendNothing;
		
		if( Key==IK_Enter )
		{
				if( TypedStr!="" )
				{
					History[HistoryTop] = TypedStr;
					HistoryTop = (HistoryTop+1) % ArrayCount(History);
					
					if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
						HistoryBot = (HistoryBot+1) % ArrayCount(History);

					HistoryCur = HistoryTop;

					// For normal Say messages, check here (because we can't override the exec 
					// and simply check there) if the person typed nothing. If so, look to
					// add their default empty string instead.
					tstr = Caps(Left(TypedStr, Len(SAY_CMD_STR)));
					if(tstr == SAY_CMD_STR)
					{
						tstr = Mid(TypedStr, Len(SAY_CMD_STR), Len(TypedStr));
						// It's an empty string (the space is the space that's right after Say
						// which has to be there in order for teamsay to come in
						if(tstr == " ")
						{
							fplayer = FPSPlayer(Master.BaseMenu.ViewportOwner.Actor);
							if(fplayer != None)
							{
								// When the player hits Enter on an empty string, they've
								// specified for nothing to get sent, so mark it as such
								if(fplayer.DefEmptySay == "")
									bSendNothing=true;
								else	// They want their default empty string to go ahead
									TypedStr = SAY_CMD_STR$" "$fplayer.DefEmptySay;
							}
						}
					}
					else
					{
						// On a TeamSay message, it inserts a string after
						// the TeamSay command that we decode in fpshud for formatting.
						tstr = Caps(Left(TypedStr, Len(TEAMSAY_CMD_STR)));
						if(tstr == TEAMSAY_CMD_STR)
						{
							tstr = Mid(TypedStr, Len(TEAMSAY_CMD_STR), Len(TypedStr));
							// It's an empty string (the space is the space that's right after TeamSay
							// which has to be there in order for teamsay to come in
							if(tstr == " ")
							{
								fplayer = FPSPlayer(Master.BaseMenu.ViewportOwner.Actor);
								if(fplayer != None)
								{
									// When the player hits Enter on an empty string, they've
									// specified for nothing to get sent, so mark it as such
									if(fplayer.DefEmptyTeamSay == "")
										bSendNothing=true;
									else	// They want their default empty string to go ahead
										TypedStr = TEAMSAY_CMD_STR$" "$fplayer.DefEmptyTeamSay;
								}
							}

							// If we're still sending a string, go for it now
							if(!bSendNothing)
							{
								// Continue converting the strings to team saying
								tstr = Mid(TypedStr, Len(TEAMSAY_CMD_STR), Len(TypedStr));
								// Add in the original teamsay part, and your new message
								TypedStr = TEAMSAY_CMD_STR$TEAM_STR_LOCK$tstr;
							}
						}
					}

					// Make a local copy of the string.
					Temp=TypedStr;
					TypedStr="";
					
					// The console command call is where the thing is actually evaluated, so
					// So things like Say and TeamSay are actually sent in there. 
					if( !bSendNothing
						&& !ConsoleCommand( Temp ) )
						Message( Localize("Errors","Exec","Core"), 6.0 );
						
					Message( "", 6.0 );
				}

				TypingClose();
					
				return true;
			}
		else
			return Super.KeyEvent(Key, Action, Delta);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MaxScrollbackSize=128
}