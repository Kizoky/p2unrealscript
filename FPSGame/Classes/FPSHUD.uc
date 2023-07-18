///////////////////////////////////////////////////////////////////////////////
// Copyright 2002 Running With Scissors.  All Rights Reserved.
//
// Our base HUD which deals mostly with messages.
//
///////////////////////////////////////////////////////////////////////////////
class FPSHUD extends HUD;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var string						FontInfoClass;
var FontInfo					MyFont;
var string						ButtonInfoClass;
var FPSButtonInfo				MyButtons;

enum TextHorzAlign
{
	THA_Left,
	THA_Center,
	THA_Right
};

enum TextVertAlign
{
	TVA_Top,
	TVA_Center,
	TVA_Bottom
};

enum TextStack
{
	TS_None,
	TS_Up,
	TS_Down
};

struct MessageFormat
{
	var float						XP;
	var float						YP;
	var TextHorzAlign				HAlign;
	var TextVertAlign				VAlign;
	var TextStack					Stack;
	var int							FontSize;
	var bool						bPlainFont;
	var bool						bAlwaysUseColor;
	var Color						Color;
};

struct NewHUDLocalizedMessage
{
	var Class<LocalMessage>			Message;
	var int							Switch;
	var PlayerReplicationInfo		RelatedPRI_1;
	var PlayerReplicationInfo		RelatedPRI_2;
	var Object						OptionalObject;
	var string						StringMessage;
	var float						EndOfLife;
	var float						LifeTime;
	var bool						bDrawn;
	var Color						DrawColor;
};

var NewHUDLocalizedMessage		LocalMessages[8];

var MessageFormat				CategoryFormats[5];	// 0 is reserved for use by console text messages

var const float					CriticalMessageYP;
var const float					PickupMessageXP;
var const float					PickupMessageYP;
var const float					DefaultMessageXP;
var const float					DefaultMessageYP;

var float						CanvasWidth;
var float						CanvasHeight;

var color						TextMessageColors[4];	// Allow special text messages to have colors
var color						SayColor;			// Color of people talking
var color						TeamSayColor;	// team talking

// This next string has to match the one in FPSConsoleExt, except for this one *doesn't* have a string
// at the beginning.
const TEAM_STR_KEY	= "(-*Team..)";
const SPACE_AND_COLON_LEN					= 2;

var globalconfig bool bSteamDeckInit;

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	MyFont = FontInfo(spawn(Class<Actor>(DynamicLoadObject(FontInfoClass, class'Class'))));
	MyButtons = FPSButtonInfo(spawn(Class<Actor>(DynamicLoadObject(ButtonInfoClass, class'Class'))));
	
	if (MyFont != None)
		MyFont.MyHUD = Self;
	if (MyButtons != None)
		MyButtons.MyHUD = Self;
        
    if (!bSteamDeckInit && PlatformIsSteamDeck()) {
        MyButtons.SetJoystickType(6);
        bSteamDeckInit = true;
        SaveConfig();
    }
}

///////////////////////////////////////////////////////////////////////////////
// Setup stuff
///////////////////////////////////////////////////////////////////////////////
simulated function HUDSetup(canvas canvas)
{
	// Save full width and height.  This is necessary because the clipping area
	// may get changed during the course of drawing various parts of the hud.
	CanvasWidth = Canvas.ClipX;
	CanvasHeight = Canvas.ClipY;
}

///////////////////////////////////////////////////////////////////////////////
// Execs for showing and hiding scoreboard
///////////////////////////////////////////////////////////////////////////////
exec function ShowScoreboard()
{
	bShowScores = true;
}

exec function HideScoreboard()
{
	bShowScores = false;
}

///////////////////////////////////////////////////////////////////////////////
// Send console message
///////////////////////////////////////////////////////////////////////////////
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local int i;
	local Class<LocalMessage> MessageClass;
	
	switch (MsgType)
	{
	case 'Say':
		Msg = PRI.PlayerName$": "$Msg;
		MessageClass = class'SayMessagePlus';
		break;
	case 'TeamSay':
		Msg = PRI.PlayerName$"("$PRI.GetLocationName()$"): "$Msg;
		MessageClass = class'TeamSayMessagePlus';
		break;
	case 'CriticalEvent':
		// Convert to localized message
		MessageClass = class'CriticalEventPlus';
		LocalizedMessage( MessageClass, 0, None, None, None, Msg );
		return;
	default:
		MessageClass = class'StringMessagePlus';
		break;
	}

	AddTextMessageEx(Msg, MessageClass.Default.LifeTime, MessageClass);
}

///////////////////////////////////////////////////////////////////////////////
// Add console message with a specific life
///////////////////////////////////////////////////////////////////////////////
function AddTextMessageEx(string M, float MsgLife, class<LocalMessage> MessageClass)
{
	local int i, tstart;
	local string revisedteamstr, savedname;
	
	if( bMessageBeep && MessageClass.default.bBeep )
	{
		PlayerOwner.PlayBeepSound();
	}

	// look for empty spot
	for (i = 0; i < ArrayCount(TextMessages); i++)
	{
		if ( TextMessages[i] == "" )
			break;
	}
	
	if (i == ArrayCount(TextMessages))
	{
		// move everything up to make room
		for (i = 0; i < ArrayCount(TextMessages)-1; i++)
		{
			TextMessages[i] = TextMessages[i+1];
			MessageLife[i] = MessageLife[i+1];
			TextMessageColors[i]=TextMessageColors[i+1];
		}
	}
	
	TextMessages[i] = M;
	MessageLife[i] = Level.TimeSeconds + MsgLife;
	tstart = InStr(M, TEAM_STR_KEY);
	// Make player typed messages stand out from everything else with a different color
	if(ClassIsChildOf(MessageClass, class'TeamSayMessagePlus')
		|| (tstart > 0))
	{
		TextMessageColors[i]=TeamSayColor;
		revisedteamstr = Right(M, (Len(M) - tstart-Len(TEAM_STR_KEY)) );
		// Back up two notches to get the space and then the colon
		savedname = Left(M, tstart-SPACE_AND_COLON_LEN);
		// Extract the "(Team)" part and add it on the other side of the colon just
		// to make it look nicer
		M = savedname$" (Team): "$revisedteamstr;
		TextMessages[i] = M;
	}
	// If not a team say, then set the color as a normal say to distinguish them
	else if(ClassIsChildOf(class'SayMessagePlus', MessageClass))
		TextMessageColors[i]=SayColor;
	else // default color of other text, like death messages
		TextMessageColors[i]=CategoryFormats[0].Color;
}

///////////////////////////////////////////////////////////////////////////////
// Clear all console messages
///////////////////////////////////////////////////////////////////////////////
function ClearTextMessages()
{
	local int i;
	
	for (i = 0; i < ArrayCount(TextMessages); i++)
		TextMessages[i] = "";
}

///////////////////////////////////////////////////////////////////////////////
// Display console messages
///////////////////////////////////////////////////////////////////////////////
function DisplayMessages(canvas Canvas)
{
	local int i, j;
	local float X, Y, XL, YL;

	// Clean out old messages
	for (i = 0; i < ArrayCount(TextMessages); i++)
	{
		if ( TextMessages[i] == "" )
			break;
		else if ( MessageLife[i] < Level.TimeSeconds )
		{
			TextMessages[i] = "";
			if (i < ArrayCount(TextMessages)-1)
			{
				for (j = i; j < ArrayCount(TextMessages)-1; j++)
				{
					TextMessages[j] = TextMessages[j+1];
					MessageLife[j] = MessageLife[j+1];
					TextMessageColors[j]=TextMessageColors[j+1];
				}
			}
			TextMessages[ArrayCount(TextMessages)-1] = "";
			break;
		}
	}
	
	// Draw messages
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.Font = MyFont.GetFont(CategoryFormats[0].FontSize, CategoryFormats[0].bPlainFont, CanvasWidth);
	Canvas.bCenter = false;
	for (i = 0; i < ArrayCount(TextMessages); i++)
	{
		if (TextMessages[i] != "")
		{
			// Set the color for each message, in case one is a player typing
			Canvas.DrawColor = TextMessageColors[i];
			Canvas.StrLen(TextMessages[i], XL, YL);
			PositionLocalMessage(Canvas, 0, i, XL, YL, X, Y);
			Canvas.SetPos(X, Y);
			MyFont.DrawText(Canvas, TextMessages[i], 1.0);
		}
		else
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Receive a localized message.
///////////////////////////////////////////////////////////////////////////////
simulated function LocalizedMessage(class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString)
{
	local int i;
	local int GameIndex;
	
    if( Message == None )
        return;

	if ( CriticalString == "" )
		CriticalString = Message.static.GetString(PlayerOwner, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	
	if ( bMessageBeep && Message.default.bBeep )
		PlayerOwner.PlayBeepSound();
	
	// If not special then simply add to console messages
	if ( !Message.Default.bIsSpecial )
	{
		AddTextMessageEx(CriticalString, Message.default.LifeTime, Message);
		return;
	}
	
	i = ArrayCount(LocalMessages);
	
	if ( Message.Default.bIsUnique )
	{
		// If there's another message of the same class then update the existing message
		for( i = 0; i < ArrayCount(LocalMessages); i++ )
		{
			if( LocalMessages[i].Message != None &&
				LocalMessages[i].Message == Message )
                break;
		}
	}
	else if ( Message.default.bIsPartiallyUnique)
	{
		// If there's another message of the same class and switch then update the existing message
		for( i = 0; i < ArrayCount(LocalMessages); i++ )
		{
		    if( LocalMessages[i].Message != None &&
				LocalMessages[i].Message == Message &&
				LocalMessages[i].Switch == Switch )
                break;
        }
	}

	if( i == ArrayCount(LocalMessages) )
	{
		for( i = 0; i < ArrayCount(LocalMessages); i++ )
		{
			if( LocalMessages[i].Message == None )
				break;
		}
	}
	
	if( i == ArrayCount(LocalMessages) )
	{
		for( i = 0; i < ArrayCount(LocalMessages) - 1; i++ )
			LocalMessages[i] = LocalMessages[i+1];
	}
	
	// GameIndex will be 0 for singleplayer, 1 for multiplayer
	if (!((Level.NetMode == NM_StandAlone) && FPSGameInfo(Level.Game).bIsSingleplayer))
		GameIndex = 1;

	ClearLocalMessage(LocalMessages[i]);
	
	LocalMessages[i].Message        = Message;
	LocalMessages[i].Switch         = Switch;
	LocalMessages[i].RelatedPRI_1   = RelatedPRI_1;
	LocalMessages[i].RelatedPRI_2   = RelatedPRI_2;
	LocalMessages[i].OptionalObject = OptionalObject;
	LocalMessages[i].StringMessage  = CriticalString;
	LocalMessages[i].LifeTime       = LocalMessages[i].Message.Default.Lifetime;
	LocalMessages[i].EndOfLife      = LocalMessages[i].Message.Default.Lifetime + Level.TimeSeconds;
	LocalMessages[i].DrawColor      = LocalMessages[i].Message.static.GetColor(Switch, GameIndex, RelatedPRI_1, RelatedPRI_2);
}

///////////////////////////////////////////////////////////////////////////////
// Draw messages
///////////////////////////////////////////////////////////////////////////////
simulated function DrawLocalMessages(canvas Canvas)
{
	local int i, j;
	local int Category;
	local int CatItem;

	//DebugLocalMessages(Canvas);

	CleanLocalMessages();

	for (i = 0; i < ArrayCount(LocalMessages); i++)
	{
		if (LocalMessages[i].Message != None)
		{
			Category = LocalMessages[i].Message.default.MessageCategory;
			if (Category >= ArrayCount(CategoryFormats))
				Category = 0;
			CatItem = 0;
			for(j = i; j < ArrayCount(LocalMessages); j++)
			{
				if( LocalMessages[j].Message != None &&
					LocalMessages[j].Message.default.MessageCategory == Category &&
					!LocalMessages[j].bDrawn)
				{
					DrawLocalMessage(Canvas, Category, CatItem, j);
					CatItem++;
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// For debugging, show the list of messages in the middle of the screen
///////////////////////////////////////////////////////////////////////////////
simulated function DebugLocalMessages(Canvas Canvas)
{
	local float XL, YL;
	local String str;
	local int i;

	for (i = 0; i < ArrayCount(LocalMessages); i++)
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetDrawColor(255, 255, 255, 255);
		Canvas.Font = MyFont.GetFont(1, true, CanvasWidth);
		if (LocalMessages[i].Message != None)
			str = LocalMessages[i].StringMessage;
		else
			str = "-empty-";
		Canvas.StrLen(str, XL, YL);
		Canvas.SetPos((CanvasWidth - XL) / 2, (CanvasHeight - YL * ArrayCount(LocalMessages))/2 + i * YL);
		Canvas.DrawText(str);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw a local message
///////////////////////////////////////////////////////////////////////////////
function DrawLocalMessage(Canvas Canvas, int Category, int CatItem, int i)
{
	local float XL, YL, X, Y;
	local float FadeOut;

	Canvas.bCenter = false;

	if (CategoryFormats[Category].bAlwaysUseColor)
		Canvas.DrawColor = CategoryFormats[Category].Color;
	else
		Canvas.DrawColor = LocalMessages[i].DrawColor;

	if (LocalMessages[i].Message.Default.bFadeMessage)
	{
		Canvas.Style = ERenderStyle.STY_Translucent;
		FadeOut = (LocalMessages[i].EndOfLife - Level.TimeSeconds) / LocalMessages[i].LifeTime;
	}
	else
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		FadeOut = 1.0;
	}
	
	Canvas.DrawColor = Canvas.DrawColor * FadeOut;
	Canvas.Font = MyFont.GetFont(CategoryFormats[Category].FontSize, CategoryFormats[Category].bPlainFont, CanvasWidth);
	Canvas.StrLen(LocalMessages[i].StringMessage, XL, YL);
	PositionLocalMessage(Canvas, Category, CatItem, XL, YL, X, Y);
	Canvas.SetPos(X, Y);

	if (!LocalMessages[i].Message.default.bComplexString)
		MyFont.DrawText(Canvas, LocalMessages[i].StringMessage, FadeOut);
	else
		LocalMessages[i].Message.static.RenderComplexMessage(Canvas, XL, YL, LocalMessages[i].StringMessage, LocalMessages[i].Switch, LocalMessages[i].RelatedPRI_1, LocalMessages[i].RelatedPRI_2, LocalMessages[i].OptionalObject);

	LocalMessages[i].bDrawn = true;
}

///////////////////////////////////////////////////////////////////////////////
// Position a local message.
// This can be overridden by other HUD classes to change the message layouts.
///////////////////////////////////////////////////////////////////////////////
function PositionLocalMessage(Canvas Canvas, int Category, int CatItem, float XL, float YL, out float OutX, out float OutY)
{
	switch(CategoryFormats[Category].HAlign)
	{
	case THA_Left:
		OutX = CategoryFormats[Category].XP * CanvasWidth;
		break;

	case THA_Center:
		OutX = (CanvasWidth - XL) / 2;
		break;

	case THA_Right:
		OutX = CategoryFormats[Category].XP * CanvasWidth - XL;
		break;
	}

	switch(CategoryFormats[Category].VAlign)
	{
	case TVA_Top:
		OutY = CategoryFormats[Category].YP * CanvasHeight;
		break;

	case TVA_Center:
		OutY = (CanvasHeight - YL) / 2;
		break;

	case TVA_Bottom:
		OutY = CategoryFormats[Category].YP * CanvasHeight - YL;
		break;
	}

	switch(CategoryFormats[Category].Stack)
	{
	case TS_None:
		break;

	case TS_Up:
		OutY -= YL * CatItem;
		break;

	case TS_Down:
		OutY += YL * CatItem;
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// After loading a game
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Super.PostLoadGame();
	
	// Erase all "client messages" (aka "hint text message") after a load because
	// they don't tend to make sense right after a load (especially the ones
	// that tell you that you just saved a game).
	ClearTextMessages();
}

///////////////////////////////////////////////////////////////////////////////
// Clean up the local message list
///////////////////////////////////////////////////////////////////////////////
simulated function CleanLocalMessages()
{
	local int i, j, Count;

	Count = ArrayCount(LocalMessages);
	for (i = 0; i < Count; i++)
	{
		LocalMessages[i].bDrawn = false;

		// Clear "dead" messages and empty messages from the list
		if ((LocalMessages[i].Message != None && Level.TimeSeconds >= LocalMessages[i].EndOfLife) ||
			(LocalMessages[i].Message == None))
		{
			// Shift up all the other messages to take it's place
			for (j = i; j < ArrayCount(LocalMessages)-1; j++)
				LocalMessages[j] = LocalMessages[j+1];

			// Clear last message, which makes one less we need to check
			ClearLocalMessage(LocalMessages[j]);
			Count--;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Clear specified message
///////////////////////////////////////////////////////////////////////////////
simulated function ClearLocalMessage(out NewHUDLocalizedMessage M)
{
	M.Message = None;
}

function ClipText(Canvas Canvas, coerce string Str, optional bool bCheckHotkey)
{
	MyFont.ClipText(Canvas, Str, bCheckHotkey);
}

function string GetButtonParsedText(Canvas Canvas, coerce string Str)
{
	return MyFont.GetButtonParsedText(Canvas, Str);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
//	bMessageBeep=true

	CanvasWidth=640		// Reasonable default in case this is used prior to hud being fully setup
	CanvasHeight=480	// Reasonable default in case this is used prior to hud being fully setup

	FontInfoClass="FPSGame.FontInfo"
	ButtonInfoClass="FPSGame.FPSButtonInfo"

	// Console messages -- top left corner
	CategoryFormats[0]=(XP=0.2,YP=0.2,HAlign=THA_Left,VAlign=TVA_Top,Stack=TS_Down,FontSize=1,bPlainFont=false,bAlwaysUseColor=true,Color=(R=180,G=10,B=10,A=255))
	SayColor=(R=211,G=199,B=156,A=255)
	TeamSayColor=(R=111,G=199,B=111,A=255)
}
