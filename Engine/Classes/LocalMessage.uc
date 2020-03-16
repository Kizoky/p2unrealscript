//=============================================================================
// LocalMessage
//
// LocalMessages are abstract classes which contain an array of localized text.  
// The PlayerController function ReceiveLocalizedMessage() is used to send messages 
// to a specific player by specifying the LocalMessage class and index.  This allows 
// the message to be localized on the client side, and saves network bandwidth since 
// the text is not sent.  Actors (such as the GameInfo) use one or more LocalMessage 
// classes to send messages.  The BroadcastHandler function BroadcastLocalizedMessage() 
// is used to broadcast localized messages to all the players.
//
//=============================================================================
class LocalMessage extends Info;

var bool	bComplexString;									// Indicates a multicolor string message class.
var bool	bIsSpecial;										// If true, don't add to normal queue.
var bool	bIsUnique;										// If true and special, only one can be in the HUD queue at a time.
// RWS CHANGE: Added new flag
var bool	bIsPartiallyUnique;								// If true and special, only one can be in the HUD queue with the same switch value
var bool	bIsConsoleMessage;								// If true, put a GetString on the console.
var bool	bFadeMessage;									// If true, use fade out effect on message.
var bool	bBeep;											// If true, beep!
// RWS CHANGE: No longer used
//var bool	bOffsetYPos;									// If the YPos indicated isn't where the message appears.
var int		Lifetime;										// # of seconds to stay in HUD message queue.

// RWS CHANGE: Added new vars (0 = singleplayer, 1 = multiplayer)
var Color	DrawColor[2];
var int		MessageCategory;								// Used by HUD to group and position messages (0 is reserved!)

// RWS CHANGE: No longer used
//var class<LocalMessage> ChildMessage;						// In some cases, we need to refer to a child message.

// RWS CHANGE: Removed a bunch of vars
// Canvas Variables
//var bool	bFromBottom;									// Subtract YPos.
//var color	DrawColor;										// Color to display message with.
//var float	XPos, YPos;										// Coordinates to print message at.
//var bool	bCenter;										// Whether or not to center the message.

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional String MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	);

static function string GetString(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( class<Actor>(OptionalObject) != None )
		return class<Actor>(OptionalObject).static.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
	return "";
}

static function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (P.myHUD != None)
		P.myHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

	if ( Default.bIsConsoleMessage && (P.Player != None) && (P.Player.Console != None) )
		P.Player.InteractionMaster.Process_Message( Static.GetString( P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject ), 6.0, P.Player.LocalInteractions);
}

// Return font color
static function color GetColor(
	optional int Switch,
	optional int GameIndex,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.DrawColor[GameIndex];
}

defaultproperties
{
	Lifetime=3
	MessageCategory=1	// 0 is reserved!
}