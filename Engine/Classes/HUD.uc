//=============================================================================
// HUD: Superclass of the heads-up display.
//=============================================================================
class HUD extends Actor
	native
	config(user);

//=============================================================================
// Variables.

#exec Texture Import File=Textures\Border.pcx

#exec new TrueTypeFontFactory PACKAGE="Engine" Name=MediumFont FontName="Arial Bold" Height=16 AntiAlias=1 CharactersPerPage=128
#exec new TrueTypeFontFactory PACKAGE="Engine" Name=SmallFont FontName="Terminal" Height=10 AntiAlias=0 CharactersPerPage=256

// Stock fonts.
var font SmallFont;          // Small system font.
var font MedFont;            // Medium system font.
var font BigFont;            // Big system font.
var font LargeFont;            // Largest system font.

var string HUDConfigWindowType;
var HUD nextHUD;	// list of huds which render to the canvas
var PlayerController PlayerOwner; // always the actual owner
var bool bCinematicView;

var ScoreBoard Scoreboard;
var bool	bShowScores;
var bool	bShowDebugInfo;				// if true, show properties of current ViewTarget
var bool	bHideCenterMessages;		// don't draw centered messages (screen center being used)
var bool    bBadConnectionAlert;	// display warning about bad connection
var() config bool bMessageBeep;

var localized string LoadingMessage;
var localized string SavingMessage;
var localized string ConnectingMessage;
var localized string PausedMessage;
var localized string PrecachingMessage;

// Added by Demiurge Studios (Movie)
var const transient Movie Movie;
var int MoviePosX;
var int MoviePosY;
var float TexMovieTop;
var float TexMovieLeft;
var float TexMovieBottom;
var float TexMovieRight;
var bool TexMovieTranslucent;
var transient MovieTexture TextureMovie;
// End Demiurge Studios (Movie)

var bool bHideHUD;		// Should the hud display itself.

struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI;
	var Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var color DrawColor;
	var font StringFont;
	var float XL, YL;
	var float YPos;
};
var string TextMessages[4];
var float MessageLife[4];



/* Draw3DLine()
draw line in world space. Should be used when engine calls RenderWorldOverlays() event.
*/
native final function Draw3DLine(vector Start, vector End, color LineColor);

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayerOwner = PlayerController(Owner);
}

// RWS CHANGE: Merged updated function from UT2003
simulated function SetScoreBoardClass (class<Scoreboard> ScoreBoardClass)
{
    if (ScoreBoard != None )
        ScoreBoard.Destroy();

    if (ScoreBoardClass == None)
        ScoreBoard = None;
    else
    {
        ScoreBoard = Spawn (ScoreBoardClass, Owner);

		// NPF, removed this. It's not needed, check Playercontroller(Owner).myhud instead.
		// It could be causing a crash from the scoreboard, also
//		ScoreBoard.OwnerHUD = self;					// RWS CHANGE: 927 Scoreboard needs OwnerHUD to be set

        if (ScoreBoard == None)
            warn ("Hud::SetScoreBoardClass(): Could not spawn a scoreboard of class "$ScoreBoardClass);
    }
}
//function SpawnScoreBoard(class<Scoreboard> ScoringType)
//{
//	if ( ScoringType != None )
//	{
//		Scoreboard = Spawn(ScoringType, PlayerOwner);
//		Scoreboard.OwnerHUD = self;
//	}
//}

simulated event Destroyed()
{
	// RWS Change, now setting to none, after ut2199
    if( ScoreBoard != None )
    {
        ScoreBoard.Destroy();
        ScoreBoard = None;
    }

	Super.Destroyed();
}

//=============================================================================
// Execs

/* toggles displaying scoreboard
*/
exec function ShowScores()
{
	bShowScores = !bShowScores;
}

/* toggles displaying properties of player's current viewtarget
*/
exec function ShowDebug()
{
	bShowDebugInfo = !bShowDebugInfo;
}

/* ShowUpgradeMenu()
Event called when the engine version is less than the MinNetVer of the server you are trying
to connect with.
*/
event ShowUpgradeMenu();

function PlayStartupMessage(byte Stage);

//=============================================================================
// Message manipulation

function ClearMessage(out HUDLocalizedMessage M)
{
	M.Message = None;
	M.Switch = 0;
	M.RelatedPRI = None;
	M.OptionalObject = None;
	M.EndOfLife = 0;
	M.StringMessage = "";
	M.DrawColor = class'Canvas'.Static.MakeColor(255,255,255);
	M.XL = 0;
	M.bDrawing = false;
}

function CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2)
{
	M1.Message = M2.Message;
	M1.Switch = M2.Switch;
	M1.RelatedPRI = M2.RelatedPRI;
	M1.OptionalObject = M2.OptionalObject;
	M1.EndOfLife = M2.EndOfLife;
	M1.StringMessage = M2.StringMessage;
	M1.DrawColor = M2.DrawColor;
	M1.XL = M2.XL;
	M1.YL = M2.YL;
	M1.YPos = M2.YPos;
	M1.bDrawing = M2.bDrawing;
	M1.LifeTime = M2.LifeTime;
	M1.numLines = M2.numLines;
}

//=============================================================================
// Status drawing.

simulated event WorldSpaceOverlays()
{
	if ( bShowDebugInfo && Pawn(PlayerOwner.ViewTarget) != None )
		DrawRoute();
}

simulated event PostRender( canvas Canvas )
{
	local HUD H;
	local float YL,YPos,offsetX,OffsetY;
	local Pawn P;
	local bool ws;
	local float X1,Y1,X2,Y2,MovieAspect;

	ws = bool(ConsoleCommand("get Postal2Game.P2GameInfo bWidescreenStretch"));

	if ( !PlayerOwner.bBehindView )
	{
		P = Pawn(PlayerOwner.ViewTarget);
		if ( (P != None) && (P.Weapon != None) )
			P.Weapon.RenderOverlays(Canvas);
	}

//FIXMEJOE
/*
	if ( PlayerConsole.bNoDrawWorld )
	{
		Canvas.SetPos(0,0);
		Canvas.DrawPattern( Texture'Border', Canvas.ClipX, Canvas.ClipY, 1.0 );
	}
*/
	DisplayMessages(Canvas);

	bHideCenterMessages = DrawLevelAction(Canvas);

	if ( !bHideCenterMessages && (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) )
		DisplayProgressMessage(Canvas);

	if ( bBadConnectionAlert )
		DisplayBadConnectionAlert();

	if ( bShowDebugInfo )
	{
		YPos = 5;
		UseSmallFont(Canvas);
		PlayerOwner.ViewTarget.DisplayDebug(Canvas,YL,YPos);
	}
	else for ( H=self; H!=None; H=H.NextHUD )
		H.DrawHUD(Canvas);

	// Added by Demiurge Studios (Movie)
	if(TextureMovie != NONE && TextureMovie.Movie != NONE && TextureMovie.Movie.IsPlaying())
	{
		if(TexMovieTranslucent)
			canvas.Style = ERenderStyle.STY_Translucent;
		else
			canvas.Style = ERenderStyle.STY_Normal;
		canvas.SetDrawColor(255,255,255);

		// (TexMovieLeft*canvas.SizeX, TexMovieTop*canvas.SizeY) - ((TexMovieRight-TexMovieLeft)*canvas.SizeX, (TexMovieBottom-TexMovieTop)*canvas.SizeY)
        X1 = 0;
		Y1 = 0;
		//MovieAspect = TextureMovie.Movie.GetWidth() / TextureMovie.Movie.GetHeight();
		// Movie does not report correct aspect ratio. Go by file name for now
		//log("Movie texture"@TextureMovie.MovieFilename);
		if (TextureMovie.MovieFilename ~= "pigeons.roq")
			MovieAspect = 1.333333;
		else
			MovieAspect = 1.777777;
		if (MovieAspect > PlayerOwner.GetAspectRatio())
		{
			X2 = Canvas.SizeX;
			Y1 = (Canvas.SizeY - (Canvas.SizeX / MovieAspect)) / 2.0;
			Y2 = Canvas.SizeY - Y1;
		}
		else
		{
			Y2 = Canvas.SizeY;
			X1 = (Canvas.SizeX - (MovieAspect * Y2)) / 2.0;
			X2 = Canvas.SizeX - X1;
		}
		canvas.SetPos( X1, Y1 );
		canvas.DrawTile(TextureMovie, (X2 - X1), (Y2 - Y1), 0, 0, TextureMovie.Movie.GetWidth(), TextureMovie.Movie.GetHeight());
	}
	// End Demiurge Studios (Movie)
	
	// JWB: Moved Cinematic view from C++
	if(bCinematicView)
	{
        canvas.Style = 1; //ERenderStyle.STY_Normal;
        canvas.SetDrawColor(0, 0, 0);
        canvas.SetPos(0,0);
        canvas.DrawRect( Texture'engine.WhiteSquareTexture', canvas.ClipX, canvas.ClipY * 0.10 );
        
        canvas.SetPos(0,canvas.ClipY * 0.90);
        canvas.DrawRect( Texture'engine.WhiteSquareTexture', canvas.ClipX, canvas.ClipY * 0.10 );
	}
}

simulated function DrawRoute()
{
	local int i;
	local Controller C;
	local vector Start, End, RealStart;;
	local bool bPath;

	C = Pawn(PlayerOwner.ViewTarget).Controller;
	if ( C == None )
		return;
	if ( C.CurrentPath != None )
		Start = C.CurrentPath.Start.Location;
	else
		Start = PlayerOwner.ViewTarget.Location;
	RealStart = Start;

	if ( C.bAdjusting )
	{
		Draw3DLine(C.Pawn.Location, C.AdjustLoc, class'Canvas'.Static.MakeColor(255,0,255));
		Start = C.AdjustLoc;
	}

	// show where pawn is going
	if ( (C == PlayerOwner)
		|| (C.MoveTarget == C.RouteCache[0]) && (C.MoveTarget != None) )
	{
		if ( (C == PlayerOwner) && (C.Destination != vect(0,0,0)) )
		{
			if ( C.PointReachable(C.Destination) )
			{
				Draw3DLine(C.Pawn.Location, C.Destination, class'Canvas'.Static.MakeColor(255,255,255));
				return;
			}
			C.FindPathTo(C.Destination);
		}
		for ( i=0; i<16; i++ )
		{
			if ( C.RouteCache[i] == None )
				break;
			bPath = true;
			Draw3DLine(Start,C.RouteCache[i].Location,class'Canvas'.Static.MakeColor(0,255,0));
			Start = C.RouteCache[i].Location;
		}
		if ( bPath )
			Draw3DLine(RealStart,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));
	}
	else if ( PlayerOwner.ViewTarget.Velocity != vect(0,0,0) )
		Draw3DLine(RealStart,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));

	if ( C == PlayerOwner )
		return;

	// show where pawn is looking
	if ( C.Focus != None )
		End = C.Focus.Location;
	else
		End = C.FocalPoint;
	Draw3DLine(PlayerOwner.ViewTarget.Location + Pawn(PlayerOwner.ViewTarget).BaseEyeHeight * vect(0,0,1),End,class'Canvas'.Static.MakeColor(255,0,0));
}

/* DrawHUD() Draw HUD elements on canvas.
*/
function DrawHUD(canvas Canvas);

/*  Print a centered level action message with a drop shadow.
*/
function PrintActionMessage( Canvas C, string BigMessage )
{
	local float XL, YL;

	if ( Len(BigMessage) > 10 )
		UseLargeFont(C);
	else
		UseHugeFont(C);
	C.bCenter = false;
	C.StrLen( BigMessage, XL, YL );
	C.SetPos(0.5 * (C.ClipX - XL) + 1, 0.66 * C.ClipY - YL * 0.5 + 1);
	C.SetDrawColor(0,0,0);
	C.DrawText( BigMessage, false );
	C.SetPos(0.5 * (C.ClipX - XL), 0.66 * C.ClipY - YL * 0.5);
	C.SetDrawColor(0,0,255);;
	C.DrawText( BigMessage, false );
}

/* Display Progress Messages
display progress messages in center of screen
*/
simulated function DisplayProgressMessage( canvas Canvas )
{
	local int i;
	local float XL, YL, YOffset;
	local GameReplicationInfo GRI;

	PlayerOwner.ProgressTimeOut = FMin(PlayerOwner.ProgressTimeOut, Level.TimeSeconds + 8);
	Canvas.Style = ERenderStyle.STY_Normal;
	UseLargeFont(Canvas);
	YOffset = 0.3 * Canvas.ClipY;

	for (i=0; i<4; i++)
	{
		Canvas.DrawColor = PlayerOwner.ProgressColor[i];
		Canvas.StrLen(PlayerOwner.ProgressMessage[i], XL, YL);
		Canvas.SetPos(0.5 * (Canvas.ClipX - XL), YOffset);
		Canvas.DrawText(PlayerOwner.ProgressMessage[i], false);
		YOffset += YL + 1;
	}
	Canvas.SetDrawColor(255,255,255);
}

/* Draw the Level Action
*/
function bool DrawLevelAction( canvas C )
{
	local string BigMessage;

	if (Level.LevelAction == LEVACT_None )
	{
		if ( (Level.Pauser != None) && (Level.TimeSeconds > Level.PauseDelay + 0.2) )
			BigMessage = PausedMessage; // Add pauser name?
		else
		{
			BigMessage = "";
			return false;
		}
	}
	// RWS CHANGE: Don't have the root HUD draw messages about the level action
/*	else if ( Level.LevelAction == LEVACT_Loading )
		BigMessage = LoadingMessage;
	else if ( Level.LevelAction == LEVACT_Saving )
		BigMessage = SavingMessage;
	else if ( Level.LevelAction == LEVACT_Connecting )
		BigMessage = ConnectingMessage;
	else if ( Level.LevelAction == LEVACT_Precaching )
		BigMessage = PrecachingMessage;
*/
	if ( BigMessage != "" )
	{
		C.Style = ERenderStyle.STY_Normal;
		UseLargeFont(C);
		PrintActionMessage(C, BigMessage);
		return true;
	}
	return false;
}

/* DisplayBadConnectionAlert()
Warn user that net connection is bad
*/
function DisplayBadConnectionAlert();

// Added by Demiurge Studios (Movie)
function PlayMovieDirect(String MovieFilename, int XPos, int YPos, bool UseSound, bool LoopMovie)
{
	StopMovie();

	MoviePosX = XPos;
	MoviePosY = YPos;
	Movie.Play(MovieFilename, UseSound, LoopMovie);
}


function PlayMovieScaled(MovieTexture InMovie, string MovieFileName, float Left, float Top, float Right, float Bottom, bool UseSound, bool LoopMovie, optional bool Translucent)
{
    local int width;
	StopMovie();

	if(Top < 0)
		Top = 0;
	if(Top > 1)
		Top = 1;

	if(Left < 0)
		Left = 0;
	if(Left > 1)
		Left = 1;

	if(Bottom < 0)
		Bottom = 0;
	if(Bottom > 1)
		Bottom = 1;

	if(Right < 0)
		Right = 0;
	if(Right > 1)
		Right = 1;

	TexMovieTop = Top;
	TexMovieLeft = Left;
	TexMovieBottom = Bottom;
	TexMovieRight = Right;
	TexMovieTranslucent = Translucent;

	if (MovieFileName == "")
		MovieFileName = TextureMovie.MovieFilename;

	TextureMovie = InMovie;
	TextureMovie.InitializeMovie();
	TextureMovie.Movie.Play(MovieFileName, UseSound, LoopMovie);
	TextureMovie.MovieFileName = MovieFilename;
}

function bool IsMoviePlaying()
{
	return Movie.IsPlaying() || TextureMovie.Movie.IsPlaying();
}


function PauseMovie(bool Pause)
{
	Movie.Pause(Pause);
	TextureMovie.Movie.Pause(Pause);
}


function bool IsMoviePaused()
{
	if(Movie.IsPlaying())
		return Movie.IsPaused();

	if(TextureMovie.Movie.IsPlaying())
		return TextureMovie.Movie.IsPaused();

	return false;
}


function StopMovie()
{
	Movie.StopNow();
	TextureMovie.Movie.StopNow();
}
// End Demiurge Studios (Movie)




//=============================================================================
// Messaging.

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	if ( bMessageBeep )
		PlayerOwner.PlayBeepSound();
	if ( (MsgType == 'Say') || (MsgType == 'TeamSay') )
		Msg = PRI.PlayerName$": "$Msg;
	AddTextMessage(Msg,class'LocalMessage');
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString );

simulated function PlayReceivedMessage( string S, string PName, ZoneInfo PZone )
{
	PlayerOwner.ClientMessage(S);
	if ( bMessageBeep )
		PlayerOwner.PlayBeepSound();
}

function bool ProcessKeyEvent( int Key, int Action, FLOAT Delta )
{
	if ( NextHud != None )
		return NextHud.ProcessKeyEvent(Key,Action,Delta);
	return false;
}

/* DisplayMessages() - display current messages
*/
function DisplayMessages(canvas Canvas)
{
	local int i, j, YPos;
	local float XL, YL;

	// first, clean up messages
	for ( i=0; i<4; i++ )
	{
		if ( TextMessages[i] == "" )
			break;
		else if ( MessageLife[i] < Level.TimeSeconds )
		{
			TextMessages[i] = "";
			if ( i < 3 )
			{
				for ( j=i; j<3; j++ )
				{
					TextMessages[j] = TextMessages[j+1];
					MessageLife[j] = MessageLife[j+1];
				}
			}
			TextMessages[3] = "";
			break;
		}
	}

	YPos = 0;
	UseSmallFont(Canvas);
	Canvas.SetDrawColor(0,255,255);
	for ( i=0; i<4; i++ )
	{
		if ( TextMessages[i] == "" )
			break;
		else
		{
			Canvas.StrLen( TextMessages[i], XL, YL );
			Canvas.SetPos(4, YPos);
			Canvas.DrawText( TextMessages[i], false );
			YPos += YL * (1 + int(XL/Canvas.ClipX));
		}
	}
}

function AddTextMessage(string M, class<LocalMessage> MessageClass)
{
	local int i;

	// RWS CHANGE: Using this function is a mistake, see alternative in our hud class
	//Warn("Don't use this function -- see alternative in our HUD class!");

	// look for empty spot
	for ( i=0; i<4; i++ )
		if ( TextMessages[i] == "" )
		{
			TextMessages[i] = M;
			MessageLife[i] = Level.TimeSeconds + MessageClass.Default.LifeTime;
			return;
		}

	// force add message
	for ( i=0; i<3; i++ )
	{
		TextMessages[i] = TextMessages[i+1];
		MessageLife[i] = MessageLife[i+1];
	}

	TextMessages[3] = M;
	MessageLife[3] = Level.TimeSeconds + MessageClass.Default.LifeTime;
}

//=============================================================================
// Font Selection.

function UseSmallFont(Canvas Canvas)
{
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = SmallFont;
	else
		Canvas.Font = MedFont;
}

function UseMediumFont(Canvas Canvas)
{
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = MedFont;
	else
		Canvas.Font = BigFont;
}

function UseLargeFont(Canvas Canvas)
{
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = BigFont;
	else
		Canvas.Font = LargeFont;
}

function UseHugeFont(Canvas Canvas)
{
	Canvas.Font = LargeFont;
}

function ClipText(Canvas Canvas, coerce string Str, optional bool bCheckHotkey);

defaultproperties
{
	bMessageBeep=true
	bHidden=True
	RemoteRole=ROLE_None
	LoadingMessage="LOADING"
	SavingMessage="SAVING"
	ConnectingMessage="CONNECTING"
	PausedMessage="PAUSED"
	PrecachingMessage=""
     SmallFont=Font'Engine.SmallFont'
     MedFont=Font'Engine.SmallFont'
     BigFont=Font'Engine.SmallFont'
     LargeFont=Font'Engine.SmallFont'
	// Added by Demiurge Studios (Movie)
	MoviePosX=100
	MoviePosY=100
	TexMovieTop=0.0
	TexMovieLeft=0.0
	TexMovieBottom=1.0
	TexMovieRight=1.0
	// End Demiurge Studios (Movie)
	bCinematicView=false
}
