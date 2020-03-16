//=============================================================================
// Console - A quick little command line console that accepts most commands.
//
// RWS CHANGE: Merged lots of stuff from UT2003
//=============================================================================
class Console extends Interaction;
	
#exec new TrueTypeFontFactory PACKAGE="Engine" Name=ConsoleFont FontName="Verdana" Height=10 AntiAlias=1 CharactersPerPage=256
#exec TEXTURE IMPORT NAME=ConsoleBK FILE=..\UWindow\TEXTURES\Black.PCX	
#exec TEXTURE IMPORT NAME=ConsoleBdr FILE=..\UWindow\TEXTURES\White.PCX	
	
// Variables

// RWS CHANGE: Don't get this from the ini, let it use key bindings like everything else
var /*globalconfig*/ byte ConsoleKey;			// Key used to bring up the main console
var byte TypingKey;								// Key used to bring up the typing console
var bool						bTypingKey;
var bool						bAlt;

var int HistoryTop, HistoryBot, HistoryCur;
var string TypedStr, History[16];		 	// Holds the current command, and the history
var bool bTyping;							// Turn when someone is typing on the console
var bool bIgnoreKeys;						// Ignore Key presses until a new KeyDown is received							
// RWS CHANGE: Make console use the key bindings like everything else does
var bool bGotKeyBindings;

//-----------------------------------------------------------------------------
// Exec functions accessible from the console and key bindings.

// Begin typing a command on the console.
exec function Type()
{
	local bool bAltDown;

	if (IsConsoleAllowed())
	{
		// Make sure the alt key isn't down (this avoids Alt-Tab bringing up the console)
		bAltDown = bool(Master.BaseMenu.ViewportOwner.Actor.ConsoleCommand("ISKEYDOWN 18"));	// 18 == IK_Alt
		if (!bAltDown)
		{
			TypedStr="";
			TypingOpen();
		}
	}
}

exec function Talk()
{
	if (IsConsoleAllowed())
	{
		TypedStr="Say ";
		TypingOpen();
	}
}

exec function TeamTalk()
{
	if (IsConsoleAllowed())
	{
		TypedStr="TeamSay ";
		TypingOpen();
	}
}

exec function ConsoleOpen();
exec function ConsoleClose();
exec function ConsoleToggle();

function bool IsConsoleAllowed()
{
	return true;
}

//-----------------------------------------------------------------------------
// Message - By default, the console ignores all output.
//-----------------------------------------------------------------------------

event Message( coerce string Msg, float MsgLife);

//-----------------------------------------------------------------------------
// Check for the console key.

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	local EInputKey tmp;

	if (!bGotKeyBindings)
		UpdateKeyBinding();

	if (IsConsoleAllowed() && Key==ConsoleKey && Action==IST_Release)
	{
		if (!bool(Master.BaseMenu.ViewportOwner.Actor.ConsoleCommand("ISKEYDOWN 18")))	// IK_Alt == 18
		{
			ConsoleOpen();
			return true;
		}
	}
	if (IsConsoleAllowed() && Key==TypingKey && Action==IST_Release)
	{
		Type();
		return true;
	}

	return false;
} 

// RWS CHANGE: Make console use the key bindings like everything else does
function UpdateKeyBinding()
{
	// RWS FIXME: This assumes only one key is bound to each function, we might want to make it an array of keys at some point
	ConsoleKey = int(Master.BaseMenu.ViewportOwner.Actor.ConsoleCommand("BINDING2KEYVAL \"ConsoleToggle\" 0"));
	TypingKey = int(Master.BaseMenu.ViewportOwner.Actor.ConsoleCommand("BINDING2KEYVAL \"Type\" 0"));
	bGotKeyBindings = true;
}

//-----------------------------------------------------------------------------
// State used while typing a command on the console.

function TypingOpen()
{
	bTyping = true;
	
	if( (ViewportOwner != None) && (ViewportOwner.Actor != None) )
		ViewportOwner.Actor.Typing( bTyping );
	
	GotoState('Typing');
}

function TypingClose()
{
	bTyping = false;
	
	if( (ViewportOwner != None) && (ViewportOwner.Actor != None) )
		ViewportOwner.Actor.Typing( bTyping );
	
	TypedStr="";
	
	if( GetStateName() == 'Typing' )
		GotoState( '' );
}

state Typing
{
	exec function Type()
	{
		TypedStr="";
        TypingClose();
	}
	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		if (bIgnoreKeys || bTypingKey)
			return true;
	
		if( Key>=0x20 )
		{
			if( Unicode != "" )
				TypedStr = TypedStr $ Unicode;
			else
				TypedStr = TypedStr $ Chr(Key);
		}
		return true;
	}

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;

		if (!bGotKeyBindings)
			UpdateKeyBinding();

		if (Action== IST_PRess)
		{
			bIgnoreKeys=false;
		}
	
		// RWS CHANGE: The TypingKey closes the console, too
		if (Key == TypingKey)
		{
			if(Action == IST_Press)
				bTypingKey = true;
			else if(Action == IST_Release && bTypingKey)
				TypingClose();
			return true;
		}
		// RWS CHANGE: Made the ESC key work the same as it does in the extended console
		// By only doing things on the release (not the press) it also solves a problem
		// where the old code was closing the console on press, leaving the release
		// unhandled, which screwed up other classes that were looking for the same key.
		else if( Key==IK_Escape )
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
					TypingClose();
				}
			}
			return true;
		}
		else if( Action != IST_Press )
		{
			return false;
		}
		else if( Key==IK_Enter )
		{
			if( TypedStr!="" )
			{
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

            TypingClose();
				
			return true;
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
			return True;
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
			return true;
		}
		return true;
	}
	
	function PostRender(Canvas Canvas)
	{
		local float xl,yl;
		local string OutStr;
		
		// Blank out a space

		Canvas.Style = 1;
		
		Canvas.Font	 = font'ConsoleFont';
		OutStr = "(>"@TypedStr$"_";
		Canvas.Strlen(OutStr,xl,yl);

		Canvas.SetPos(0,Canvas.ClipY-6-yl);
		Canvas.DrawTile( texture 'ConsoleBk', Canvas.ClipX, yl+6,0,0,32,32);

		Canvas.SetPos(0,Canvas.ClipY-8-yl);	
		Canvas.SetDrawColor(0,255,0);
		Canvas.DrawTile( texture 'ConsoleBdr', Canvas.ClipX, 2,0,0,32,32);

		Canvas.SetPos(0,Canvas.ClipY-3-yl);
		Canvas.bCenter = False;
		Canvas.DrawText( OutStr, false );
	}
	
	function BeginState()
	{
		bTyping = true;
		bVisible= true;
		bIgnoreKeys = true;
		bTypingKey = false;
		HistoryCur = HistoryTop;
	}
	function EndState()
	{
		ConsoleCommand("toggleime 0");
		bTyping = false;
		bVisible = false;
		bTypingKey = false;
	}
}


defaultproperties
{
	bActive=True
	bVisible=False
	bRequiresTick=True
	HistoryBot=-1
}