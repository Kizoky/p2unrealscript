///////////////////////////////////////////////////////////////////////////////
// P2Screen.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A basic game screen.
//
//	History:
//      11/12/12 JWB     Modified class for widescreen fix
//						 Directly grabs the user preference for WS Stretch
//						 Has a lovely little accessor for whether
//						 or not they want it stretched.
//
///////////////////////////////////////////////////////////////////////////////
class P2Screen extends Interaction
	config
	abstract;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() Name		AfterFadeInScreen;	// state to use after fading in screen
var() Name		AfterStartupState;	// state to use after startup

var() bool		bDontPauseGame;		// don't pause game while screen is running
var() bool		bWantInputEvents;	// true to get input events

var() bool		bFadeGameInOut;		// whether to fade game in/out
var() float		FadeInGameTime;		// time for fading in game
var() float		FadeOutGameTime;	// time for fading out game

var() bool		bFadeScreenInOut;	// whether to fade screen in/out
var() float		FadeInScreenTime;
var() float		FadeOutScreenTime;

var() float		FadeInSongTime;
var() float		FadeOutSongTime;

var() bool		bEndWhenTraveling;	// whether to end screen when player travels
var bool		bTraveling;			// whether screen was active during travel

var() localized String	Message;	// message
var() float		MsgX;				// message x position (% of screen width)
var() float		MsgY;				// message y position (% of screen height)
var() float		MsgFlashRate;		// message flag rate
var bool		bShowMsg;			// whether to show message

var() String	Song;				// name of song to play
var transient int	SongHandle;		// song handle

var() Sound		FadeInScreenSound;	// sound to play when screen fades in
var() Sound		FadeOutScreenSound;	// sound to play when screen fades out

var() name		BackgroundName;		// name of background texture
var() Texture	BackgroundTex;		// background texture (set directly or use BackgroundName for dynamic load)

// 11/08/12 JWB Finally finished bloody tiling texture for widescreen
// Now lets declare the thing, this will only be used if you're in a widescreen res.
var() name		TileName;			// name of tiling texture
var() Texture	TileTex;			// background tiling (set directly or use TileName for dynamic load)

var bool		bPlayerWantsToEnd;	// true if player wants to end

var float		ScaleX;				// scaling factor in X
var float		ScaleY;				// scaling factor in Y

var float		OldPlayerFOV;		// FOV player was using on way in (abnormal if he was in
									// sniper mode, for instance)

var float		FadeAlpha;			// current fade alpha

var globalconfig string MinRes;		// minimum resolution
var	string		SavedRes;			// saved resolution to restore after screen ends

// The following vars shouldn't generally be used by derived classes

var bool		bIsRunning;			// whether screen is showing
var bool		bEndNow;			// whether to end screen

var float		FadeStartTime;		// time at which fade was started
var float		FadeDuration;		// how long fade should take
var bool		bFadeIn;			// true for fade-in, false for fade-out
var bool		bFadeScreen;		// whether to fade the screen in/out
var Material	FadeScreenMat;		// material used to fade screen

var float		MsgFlashTime;		// message flag time
var bool		bMsgFlashOn;		// used to flash message on/off
var string		FontInfoClass;		// which FontInfo class to use
var FontInfo	MyFont;				// current FontInfo (various sizes, etc)

var bool		bDelayedGoto;		// whether a delayed goto is being used
var Name		DelayedState;		// the state to goto after the delay
var float		DelayTime;			// how long to delay the state

var bool		bWaitForEnd;		// whether waiting for end before going to state
var Name		WaitState;			// the state to goto afterwards

var bool		bTravelRenderMode;
var bool		bEnableRender;
var name		PostSendState;
var float		LastFrameTime;
var float		FirstFrameTime;
var int			ConsecGoodFrames;
var int			TravelRenderCount;

var string		SendPlayerURL;

// For debugging
var bool		bEnableLogging;

// 11/12/12 JWB
// Because fixing a bunch of screens isn't probably the best idea it's going to be a property
var bool 		bStretch;

//ErikFOV Change: Subtitle system
var bool 		bShowSubtitles;
//end
		
// 11/12/12 JWB
// Might cause some problems, but we need it to grab a few options.
var P2GameInfoSingle P2P;

const FOUR_BY_THREE_ASPECT_RATIO  = 1.33333333333;



///////////////////////////////////////////////////////////////////////////////
// Called after this object has been created
///////////////////////////////////////////////////////////////////////////////
event Initialized()
	{
	MaybeLog("P2Screen.Initialized()");

	if (MyFont == None)
		MyFont = FontInfo(ViewportOwner.Actor.spawn(Class<Actor>(DynamicLoadObject(FontInfoClass, class'Class'))));
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to start the screen.
///////////////////////////////////////////////////////////////////////////////
function Start()
	{
	MaybeLog("P2Screen.Start()");

	bIsRunning = true;
	bEndNow = false;
	bPlayerWantsToEnd = false;
	bTraveling = false;
	bEnableRender = true;
	bTravelRenderMode = false;

	// Get current game info
    P2P = GetGameSingle();

	// Get the user preference
    bStretch = P2P.GetWidescreenStretch();
	//Log("P2Screen.uc " @ bStretch);

	// Set song handle to invalid value
	SongHandle = 0;

	// Clear flag since screen just started
	ViewportOwner.Actor.bWantsToSkip = 0;

	bShowMsg = false;

	if (BackgroundTex == None && BackgroundName != 'None')
		BackgroundTex = Texture(DynamicLoadObject(String(BackgroundName), class'Texture'));

	if (TileTex == None && TileName != 'None')
		TileTex = Texture(DynamicLoadObject(String(TileName), class'Texture'));

	if (MyFont == None)
		MyFont = FontInfo(ViewportOwner.Actor.spawn(Class<Actor>(DynamicLoadObject(FontInfoClass, class'Class'))));

	GotoState('Startup');
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to end the screen.  Note that this merely gets the ball rolling
// and that due to fade outs and such it may take a while for the screen to
// be fully shutdown.
///////////////////////////////////////////////////////////////////////////////
function End()
	{
	MaybeLog("P2Screen.End()");

	bEndNow = true;
	}

///////////////////////////////////////////////////////////////////////////////
// This is called when this screen is about to shutdown.
// Derived classes can use this to do any required cleanup.
///////////////////////////////////////////////////////////////////////////////
function ShuttingDown()
	{
	}

///////////////////////////////////////////////////////////////////////////////
// Check if screen is running.  This will be true as long as the screen is
// active in any way, from the initial fade in through the final fade out.
///////////////////////////////////////////////////////////////////////////////
function bool IsRunning()
	{
	return bIsRunning;
	}

///////////////////////////////////////////////////////////////////////////////
// Check if screen is ending.  This indicates that the screen is in the
// process of ending.  Use IsRunning() to determine the actual screen status.
///////////////////////////////////////////////////////////////////////////////
function bool IsEnding()
	{
	return bEndNow;
	}

///////////////////////////////////////////////////////////////////////////////
// 11/12/12 JWB	Just an accessor for bStretch
///////////////////////////////////////////////////////////////////////////////
function bool isStretched()
	{
		return bStretch;
	}

///////////////////////////////////////////////////////////////////////////////
// Called before player travels to a new level
///////////////////////////////////////////////////////////////////////////////
function PreTravel()
	{
	MaybeLog("P2Screen.PreTravel(): bEndWhenTravling="$bEndWhenTraveling$" IsRunning()="$IsRunning());

	// If screen is running and should end when traveling then end it now
	if (bEndWhenTraveling && IsRunning())
		{
		MaybeLog("P2Screen.PreTravel(): ending screen now");
		End();
		}

	// Get rid of all actors because they'll be invalid in the new level (not
	// doing this will lead to intermittent crashes!)
	MyFont = None;
	}

///////////////////////////////////////////////////////////////////////////////
// Called after player traveled to a new level
///////////////////////////////////////////////////////////////////////////////
function PostTravel()
	{
	MaybeLog("P2Screen.PostTravel()");
	}

///////////////////////////////////////////////////////////////////////////////
// This is called by the HUD to see if it should draw itself
///////////////////////////////////////////////////////////////////////////////
function bool ShouldDrawHUD()
	{
	// The HUD's actors can interfere with actors drawn by the screen (for
	// instance, the first-person weapons can obscure a screen's actors, most
	// likely due to z-buffer conflicts).  So we leave the HUD active while
	// the game is fading in and out (so the player doesn't see the HUD blink
	// in and out) and then after that point we don't let the HUD draw.
	if(IsInState('FadeInGame')
		|| IsInState('FadeOutGame')
		|| IsInState('ShutDown')
		|| IsInState(Class.name))
		return true;
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Get player
///////////////////////////////////////////////////////////////////////////////
function P2Player GetPlayer()
	{
	return P2Player(ViewportOwner.Actor);
	}

///////////////////////////////////////////////////////////////////////////////
// Get gameinfo
///////////////////////////////////////////////////////////////////////////////
function P2GameInfoSingle GetGameSingle()
	{
	return P2GameInfoSingle(ViewportOwner.Actor.Level.Game);
	}

///////////////////////////////////////////////////////////////////////////////
// Play sound
///////////////////////////////////////////////////////////////////////////////
function Actor GetSoundActor()
	{
	local P2Player p2p;
	local Actor a;

	// Always try to play sound via the player's pawn.  Use MyPawn because it
	// will be valid more often thatn Pawn (for instance, during cinematics).
	// If all else fails, play sound via the player controller, although that
	// will sometimes sound weird if the controller isn't near the pawn/viewport.
	p2p = P2Player(ViewportOwner.Actor);
	if (p2p != None && p2p.MyPawn != None)
		a = p2p.MyPawn;
	else
		a = ViewportOwner.Actor;

	return a;
	}

///////////////////////////////////////////////////////////////////////////////
// Play sound
///////////////////////////////////////////////////////////////////////////////
function float GetSoundDuration(Sound snd)
	{
	return ViewportOwner.Actor.GetSoundDuration(snd);
	}

///////////////////////////////////////////////////////////////////////////////
// Show the message
///////////////////////////////////////////////////////////////////////////////
function ShowMsg()
	{
	bShowMsg = true;
	bMsgFlashOn = false;
	MsgFlashTime = 0;
	}

///////////////////////////////////////////////////////////////////////////////
// Setup fade-in effect so FadeAlpha goes from 1 to 255 in the specified time.
// Derived classes are free to use FadeAlpha for any purpose.
// Setting bScreen causes this class to fade in the full screen from black.
///////////////////////////////////////////////////////////////////////////////
function SetFadeIn(float time, optional bool bScreen)
	{
	FadeAlpha = 1; // start at 1 to avoid epic feature whereby SetDrawColor() converts an alpha of 0 to 255
	bFadeIn = true;
	FadeDuration = time;
	FadeStartTime = ViewportOwner.Actor.Level.TimeSecondsAlways;
	bFadeScreen = bScreen;
	}

///////////////////////////////////////////////////////////////////////////////
// Setup fade-out effect so FadeAlpha goes from 255 to 1 in the specified time.
// Derived classes are free to use FadeAlpha for any purpose.
// Setting bScreen causes this class to fade out the full screen to black.
///////////////////////////////////////////////////////////////////////////////
function SetFadeOut(float time, optional bool bScreen)
	{
	FadeAlpha = 255;
	bFadeIn = false;
	FadeDuration = time;
	FadeStartTime = ViewportOwner.Actor.Level.TimeSecondsAlways;
	bFadeScreen = bScreen;
	}

///////////////////////////////////////////////////////////////////////////////
// Tick the fade effect
///////////////////////////////////////////////////////////////////////////////
function TickFade()
	{
	local float Percent;

	if (FadeStartTime != 0)
		{
		if (FadeDuration <= 0)
			Percent = 1.0;
		else
			Percent = (ViewportOwner.Actor.Level.TimeSecondsAlways - FadeStartTime) / FadeDuration;
		if (Percent >= 1.0)
			{
			Percent = 1.0;
			FadeStartTime = 0;
			}

		// We go from 1 to 255 or vice-versa.  We avoid 0 because of epic "feature" that
		// whereby SetDrawColor() converts an alpha of 0 into 255.
		if (bFadeIn)
			FadeAlpha = 1.0 + (Percent * 254.0);
		else
			FadeAlpha = 255.0 - (Percent * 254.0);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Draw texture at specified position on the background texture.  The position
// and size of the texture is scaled to match the background scaling.
///////////////////////////////////////////////////////////////////////////////
function DrawScaled(
	Canvas canvas,
	Texture tex,
	float BackX,
	float BackY,
	optional bool bPositionByCenter,	// True to center texture around specified position
	optional bool bAlpha,				// Use specified alpha
	optional float Alpha)				// Alpha value (0 = transparent, 255 = opaque)
	{
	local float NearestFourByThree, OffsetX, NewScaleX;
	// Set draw style
	if (bAlpha)
		{
		Canvas.Style = 5; //ERenderStyle.STY_Alpha;
		Canvas.SetDrawColor(255, 255, 255, Alpha);
		}
	else
		{
		Canvas.Style = 1; //ERenderStyle.STY_Normal;
		Canvas.SetDrawColor(255,255,255, 255);
		}

    NearestFourByThree = GetPlayer().GetFourByThreeResolution(canvas);
	OffsetX = (canvas.ClipX - NearestFourByThree) /2;
	NewScaleX = NearestFourByThree / BackgroundTex.USize;

	// Check if positioning by center
	if (bPositionByCenter)
		{
		BackX = BackX - (tex.USize / 2);
		BackY = BackY - (tex.VSize / 2);
		}

	// Scale the position and size to match the background
	if (bEnableRender)
		{
		
		// Easy way out.
		if(!bPositionByCenter)
		  Canvas.SetPos(OffsetX + (BackX * NewScaleX), BackY * ScaleY);
		else
		  Canvas.SetPos((BackX * NewScaleX), BackY * ScaleY);
		//Canvas.SetPos(OffsetX + (BackX * NewScaleX), BackY * ScaleY);
		// Might break (unused) debug uses but fix for the chads out there who love voting.
		//Canvas.DrawTile(tex, tex.USize * NewScaleX, tex.VSize * ScaleY, 0, 0, tex.USize, tex.VSize);
		Canvas.DrawTile(tex, tex.USize * NewScaleX, tex.VSize * ScaleY, 0, 0, tex.USize, tex.VSize);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Render the fade effect
///////////////////////////////////////////////////////////////////////////////
function RenderFadeScreen(Canvas Canvas, float Alpha)
	{
	local Texture tex;

	// Alpha is used backwards here.  In order to "fade in the screen from black"
	// we actually "fade out the black so you can see the screen".
	if (bFadeScreen && Alpha < 255.0 && bEnableRender)
		{
		Canvas.Style = 5; //ERenderStyle.STY_Alpha;
		Canvas.SetDrawColor(255, 255, 255, 256-Alpha); // subtract from 256 so result is >= 1 because SetDrawColor() converts alpha of 0 to 255
		Canvas.SetPos(0, 0);
		tex = Texture(FadeScreenMat);
		Canvas.DrawTile(tex, Canvas.SizeX, Canvas.SizeY, 0, 0, tex.USize, tex.VSize);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Render your message. MapScreen shows more than one message
///////////////////////////////////////////////////////////////////////////////
function RenderMsgBody(Canvas canvas)
	{
	if (ViewportOwner.Actor.Level.TimeSecondsAlways > MsgFlashTime)
		{
		bMsgFlashOn = !bMsgFlashOn;
		MsgFlashTime = ViewportOwner.Actor.Level.TimeSecondsAlways + MsgFlashRate;
		}
	if (bMsgFlashOn && bEnableRender)
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, MsgX * Canvas.ClipX, MsgY * Canvas.ClipY, Message, 0, false, EJ_Center);
	}

///////////////////////////////////////////////////////////////////////////////
// Render the message (only if it's enabled and we're not ending)
///////////////////////////////////////////////////////////////////////////////
function RenderMsg(Canvas canvas)
	{
	if (bShowMsg && !IsEnding())
		{
		RenderMsgBody(canvas);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Render the tiling background.
// Derived classes can override or let this handle the tiling texture.
// This should be called before RenderScreen!!!
///////////////////////////////////////////////////////////////////////////////
function RenderTilingBackground(Canvas canvas)
	{
	// 11/08/12 JWB Render the tilling background before we do the main background.
	if(TileTex != none && bEnableRender)
        {
        Canvas.Style = 1; //ERenderStyle.STY_Normal;
        Canvas.SetDrawColor(255, 255, 255);
        Canvas.SetPos(0, 0);
        Canvas.DrawPattern(TileTex, Canvas.ClipX, Canvas.ClipY, 2);
        }

	}

///////////////////////////////////////////////////////////////////////////////
// Render the screen
// Derived classes can override or let this handle the background texture.
// 11/12/12 JWB	Added optional widescreen fix.
///////////////////////////////////////////////////////////////////////////////
function RenderScreen(Canvas canvas)
	{
	//MaybeLog("P2Screen.RenderScreen(): BackgroundTex="$BackgroundTex);

	// HELLO default PROPERTIES

	local float NearestFourByThree, OffsetX;


	if(BackgroundTex != none && bEnableRender)
		{
		// Orginally called from the derived class, Now an all-one-step.
		RenderTilingBackground(canvas);
		if(bStretch)  // They want it stretched
		{
			// Calculate scaling (background stretched out to full canvas)
			ScaleX = Canvas.ClipX / BackgroundTex.USize;
			ScaleY = Canvas.ClipY / BackgroundTex.VSize;

			Canvas.Style = 1; //ERenderStyle.STY_Normal;
			Canvas.SetDrawColor(255, 255, 255);
			Canvas.SetPos(0, 0);
			Canvas.DrawTile(BackgroundTex, Canvas.SizeX, Canvas.SizeY, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);
		}
		else	// If they don't want it stretched, then lets 4:3 it, and center!
		{
			//Grabs the nearest 4:3 resolution
			/*
			NearestFourByThree = ViewportOwner.Actor.GetFourByThreeResolution();

            OffsetX = (canvas.ClipX - NearestFourByThree) /2;
            */
            NearestFourByThree = FOUR_BY_THREE_ASPECT_RATIO *(Canvas.SizeY * 1);
            OffsetX = (canvas.ClipX - NearestFourByThree) /2;


            //Log(NearestFourByThree);
            //Log(OffsetX);

			// Calculate scaling (background stretched out to full canvas)
			ScaleX = Canvas.ClipX / BackgroundTex.USize;
			ScaleY = Canvas.ClipY / BackgroundTex.VSize;

			Canvas.Style = 1; //ERenderStyle.STY_Normal;
			Canvas.SetDrawColor(255, 255, 255);
			Canvas.SetPos(OffsetX, 0);
			Canvas.DrawTile(BackgroundTex, NearestFourByThree, Canvas.SizeY, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);
		}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default rendering function
///////////////////////////////////////////////////////////////////////////////
function PostRender(canvas Canvas)
	{
	Canvas.Reset();
	RenderFadeScreen(Canvas, FadeAlpha);
	}

function ShowScreenRender(canvas Canvas)
	{
	//ErikFOV Change: Subtitle system
	local P2HUD h;
	//end
	
	Canvas.Reset();
	RenderScreen(Canvas);
	RenderMsg(Canvas);
	RenderFadeScreen(Canvas, FadeAlpha);
	
		//ErikFOV Change: Subtitle system
		if(bShowSubtitles && ViewportOwner.Actor != None && ViewportOwner.Actor.myHUD != None && P2HUD(ViewportOwner.Actor.myHUD) != None )
		{
			h = P2HUD(ViewportOwner.Actor.myHUD);
						
			if (h.OurPlayer.bEnableSubtitles && h.SubBoxSize > 0 /*&& (!h.bHideHUD || h.OurPlayer.ViewTarget != h.OurPlayer.Pawn)*/)
			{
				h.DrawSubtitles(Canvas); //
			}
		}
		//end
		
	}

///////////////////////////////////////////////////////////////////////////////
// Default tick function.
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
	{
	// NOTE: The DeltaTime being passed in is not very accurate, especially
	// not for anything that needs to accumulate time.  Instead, use
	// ViewportOwner.Actor.Level.TimeSecondsAlways to get the current time
	// and compare it to a saved value to determine whether a certain amount
	// of time has elapsed.

	// Check player controller to see if player wants to skip this
	if (ViewportOwner.Actor.bWantsToSkip > 0)
		{
		ViewportOwner.Actor.bWantsToSkip = 0;
		bPlayerWantsToEnd = true;
		}

	TickFade();
	TickDelayedGoto();
	TickWaitGoto();
	}

///////////////////////////////////////////////////////////////////////////////
// Wait the specified time before going to the specified state
// If time is 0.0 then this is the same as using GotoState().
///////////////////////////////////////////////////////////////////////////////
function DelayedGotoState(float time, Name NextState)
	{
	if (time > 0.0)
		{
		bDelayedGoto = false;
		DelayTime = ViewportOwner.Actor.Level.TimeSecondsAlways + time;
		DelayedState = NextState;
		bDelayedGoto = true;
		}
	else
		GotoState(NextState);
	}

///////////////////////////////////////////////////////////////////////////////
// Change existing delay time.  This is useful if the player wants to end
// during a lengthy delay.  Instead of waiting helplessly for the delay to end,
// the delay can be shortened or set to 0 for near-instant (1 tick) response.
///////////////////////////////////////////////////////////////////////////////
function ChangeExistingDelay(float time)
	{
	if (bDelayedGoto)
		DelayTime = ViewportOwner.Actor.Level.TimeSecondsAlways + time;
	}

///////////////////////////////////////////////////////////////////////////////
// Tick delayed goto
///////////////////////////////////////////////////////////////////////////////
function TickDelayedGoto()
	{
	if (bDelayedGoto)
		{
		if (ViewportOwner.Actor.Level.TimeSecondsAlways >= DelayTime)
			{
			bDelayedGoto = false;
			GotoState(DelayedState);
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Wait for end-of-screen flag to be set (usually as a result of a key press)
// and then goto the specified state.
///////////////////////////////////////////////////////////////////////////////
function WaitForEndThenGotoState(Name NextState)
	{
	MaybeLog("P2Screen.WaitForEndThenGotoState: "$NextState);
	bWaitForEnd = true;
	WaitState = NextState;
	}

///////////////////////////////////////////////////////////////////////////////
// Tick wait-for-end goto
///////////////////////////////////////////////////////////////////////////////
function TickWaitGoto()
	{
	if (bWaitForEnd && bEndNow)
		{
		bWaitForEnd = false;
		GotoState(WaitState);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Log if enabled
///////////////////////////////////////////////////////////////////////////////
function MaybeLog(String str)
	{
	if (bEnableLogging)
		Log(self @ str);
	}

///////////////////////////////////////////////////////////////////////////////
// Startup screen
///////////////////////////////////////////////////////////////////////////////
state Startup
	{
	function BeginState()
		{
		local String CurrentRes;

		MaybeLog("P2Screen.Startup.BeginState()");

		if (bWantInputEvents)
			bActive = true;
		bVisible = true;
		bRequiresTick = true;

		SavedRes = "";
		CurrentRes = ViewportOwner.Actor.ConsoleCommand("GetCurrentRes");
		if (int(Left(CurrentRes, InStr(CurrentRes, "x"))) < int(Left(MinRes, InStr(MinRes, "x"))))
			{
			SavedRes = CurrentRes;
			ViewportOwner.Actor.ConsoleCommand("SetRes "$MinRes);
			}

		if (!bDontPauseGame)
			{
			ViewportOwner.bShowWindowsMouse = true;
			ViewportOwner.bSuspendPrecaching = true;

			// Pause game
			if (ViewportOwner.Actor.Level.NetMode == NM_Standalone)
				{
				ViewportOwner.Actor.SetPause(true);
				MaybeLog("P2Screen.Startup.BeginState(): pausing game");
				}
			}
		if (AfterStartupState == '' || AfterStartupState == 'None')
			AfterStartupState = 'FadeOutGame';
		GotoState(AfterStartupState);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Shutdown screen
///////////////////////////////////////////////////////////////////////////////
state Shutdown
	{
	function BeginState()
		{
		MaybeLog("P2Screen.Shutdown.BeginState()");

		ShuttingDown();

		// Restore saved resolution if necessary
		if (SavedRes != "")
			{
			ViewportOwner.Actor.ConsoleCommand("SetRes "$SavedRes);
			SavedRes = "";
			}

		bActive = false;
		bVisible = false;
		bRequiresTick = false;

		if (!bDontPauseGame)
			{
			ViewportOwner.bShowWindowsMouse = false;
			ViewportOwner.bSuspendPrecaching = false;

			// Resume game
			if (ViewportOwner.Actor.Level.NetMode == NM_Standalone)
				{
				ViewportOwner.Actor.SetPause(false);
				MaybeLog("P2Screen.Shutdown.BeginState(): unpausing game");
				}

			}

		if (SongHandle != 0)
			{
			GetGameSingle().StopMusicExt(SongHandle, 0.0);
			SongHandle = 0;
			}

		bIsRunning = false;
		GotoState('');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Fade out the game
///////////////////////////////////////////////////////////////////////////////
state FadeOutGame
	{
	function BeginState()
		{
		MaybeLog("P2Screen.FadeOutGame.BeginState()");

		if (bFadeGameInOut)
			SetFadeOut(FadeOutGameTime, true);


		DelayedGotoState(FadeOutGameTime, 'FadeInScreen');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Derived classes will generally extend this state for all their own states
///////////////////////////////////////////////////////////////////////////////
state ShowScreen
	{
	// Send the player to the specified URL.  When the player arrives in the
	// new level, the game will be paused and when the frame rate is stable
	// the screen will go to the specified state.
	function SendThePlayerTo(String URL, name NextState)
		{
		local float duration;

		SendPlayerURL = URL;
		PostSendState = NextState;

		// If there's music playing, fade it out prior to traveling
		if (SongHandle != 0)
			{
			GetGameSingle().StopMusicExt(SongHandle, FadeOutSongTime);
			SongHandle = 0;
			duration = FadeOutSongTime;
			}

		DelayedGotoState(duration, 'ShowScreenTravel');
		}

	function PostRender(canvas Canvas)
		{
		ShowScreenRender(Canvas);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Special state handles traveling while screen is showing.
///////////////////////////////////////////////////////////////////////////////
state ShowScreenTravel extends ShowScreen
	{
	function BeginState()
		{
		// Don't end this screen when traveling
		bEndWhenTraveling = false;

		// Switch to special render mode
		bTravelRenderMode = true;
		TravelRenderCount = 0;

		// Clean up (screens that stay active through the travel process need
		// this because they get started AFTER the normal call to this function.
		// This second call let's them clean up again in preparation for the
		// actual travel process.
		PreTravel();

		// Send player to specified URL (this returns right away and then
		// we'll keep running since we're an interaction that isn't tied
		// to any particular level.)
		GetGameSingle().SendPlayerEx(GetPlayer(), SendPlayerURL);
		}

	function PreRender(canvas Canvas)
		{
		// Log(self$" P2Screen.ShowScreen.PreRender() bTravelRenderMode="$bTravelRenderMode$" TravelRenderCount="$TravelRenderCount$" bEnableRender="$bEnableRender);
		// Once the travel process begins, 3 duplicate frames are drawn by UnGame.cpp
		// to force all potential frame buffers to be the same.  Then a 4th frame is
		// draw to give the HUD a chance to draw a message such as "loading" or whatever.
		// Unfortunately, our HUD is turned off at the time, so we draw that message here.
		// On the 5th frame, the special controller in the Entry map is enabled.  It is
		// at that point that the progres bar is drawn.  We want that bar to appear on
		// TOP of this screen, so on the 5th frame (count == 4) we draw this screen on
		// the PreRender() and we don't draw it on the PostRender().  And that concludes
		// the special travel rendering mode.  See PostRender() below for the rest of
		// the code that impelements what's described here.
		if (bTravelRenderMode && TravelRenderCount == 4)
			{
			ShowScreenRender(Canvas);
// This causes a crash, but I think only in fullscreen mode.  Not sure why.  It may have
// something to do with us trying to use an actor from the previous level after the
// level load process has started?  Not really sure, but there was no time to fix this
// so instead it was dropped -- no more text.
//			MyFont.DrawTextEx(
//				Canvas,
//				Canvas.ClipX,
//				Canvas.ClipX / 2,
//				Canvas.ClipY * class'P2Hud'.default.LoadingMessageY,
//				class'P2Hud'.default.LoadingMessage,
//				3, false, EJ_Center);
			}
		}

	function PostRender(canvas Canvas)
		{
		// Log(self$" P2Screen.ShowScreen.PostRender() bTravelRenderMode="$bTravelRenderMode$" TravelRenderCount="$TravelRenderCount$" bEnableRender="$bEnableRender);
		if (!bTravelRenderMode)
			ShowScreenRender(Canvas);
		else
			{
			if (TravelRenderCount < 4)
				{
				ShowScreenRender(Canvas);
				TravelRenderCount++;
				}
			else
				{
				bTravelRenderMode = false;
				bEnableRender = false;
				}
			}
		}

	function PostTravel()
		{
		// Call global version of this function to allow it to restore anything
		// that was done by PreTravel().
		Global.PostTravel();

		// The player has arrived in the new level.  Re-enable rendering so we'll
		// draw our stuff over anything that's happening as the level gets started.
		bEnableRender = true;
		GotoState('WaitForFrameRate');
		}
	}


///////////////////////////////////////////////////////////////////////////////
// Special state used after player has traveld to new level.
//
// The frame rate is often VERY sporadic after loading so this state waits for
// the frame rate to stabalize before continuing to the next state.  This way
// we can smoothly fade the screen (or whatever other effects we want) and it
// also keeps the player from trying to play with a horrible frame rate.
// This game is NOT paused during this time and we don't want too much gameplay
// to occur without the player being able to seeit, so we only wait for a few
// frames worth and there's also a maximum wait after which we move on.  These
// safeguards are for really slow machines which may never get a good frame rate.
///////////////////////////////////////////////////////////////////////////////
const FRAMERATE_GOOD_FRAME_TIME		= 0.5;	// hugely conservative
const FRAMERATE_MIN_GOOD_FRAMES		= 10;
const FRAMERATE_MAX_WAIT			= 5.0;

state WaitForFrameRate extends ShowScreen
	{
	function BeginState()
		{
		MaybeLog("P2Screen.WaitForFrameRate.BeginState()");
		LastFrameTime = ViewportOwner.Actor.Level.TimeSecondsAlways;
		ConsecGoodFrames = 0;
		FirstFrameTime = -1;
		}

	function EndState()
		{
		MaybeLog("P2Screen.WaitForFrameRate.EndState()");
		}

	function RenderScreen(canvas Canvas)
		{
		local float CurrentTime;
		local bool bDone;

		CurrentTime = ViewportOwner.Actor.Level.TimeSecondsAlways;
		if (FirstFrameTime == -1)
			{
			FirstFrameTime = CurrentTime;
			MaybeLog("P2Screen.WaitForFrameRate.RenderScreen(): First frame after "$CurrentTime - LastFrameTime$" sec travel, now waiting for stable frame rate");
			}
		else if (CurrentTime - LastFrameTime <= FRAMERATE_GOOD_FRAME_TIME)
			{
			ConsecGoodFrames++;
			//Log(self @ "P2Screen.WaitForFrameRate.RenderScreen(): Good frame #"$ConsecGoodFrames$" ("$CurrentTime - LastFrameTime$" sec)");
			}
		else
			{
			MaybeLog("P2Screen.WaitForFrameRate.RenderScreen(): Slow frame ("$CurrentTime - LastFrameTime$" sec) after "$ConsecGoodFrames$" good frames, resetting count");
			ConsecGoodFrames = 0;
			}
		LastFrameTime = CurrentTime;

		if (ConsecGoodFrames == FRAMERATE_MIN_GOOD_FRAMES)
			{
			MaybeLog("P2Screen.WaitForFrameRate.RenderScreen(): Frame rate is stable after "$CurrentTime - FirstFrameTime$" sec, going to state "$PostSendState);
			bDone = true;
			}
		if (CurrentTime - FirstFrameTime > FRAMERATE_MAX_WAIT)
			{
			MaybeLog("P2Screen.WaitForFrameRate.RenderScreen(): No stable frame rate after "$CurrentTime - FirstFrameTime$" sec, going to state "$PostSendState);
			bDone = true;
			}

		Global.RenderScreen(Canvas);

		if (bDone)
			GotoState(PostSendState);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Fade in screen
///////////////////////////////////////////////////////////////////////////////
state FadeInScreen extends ShowScreen
	{
	function BeginState()
		{
		MaybeLog("P2Screen.FadeInScreen.BeginState()");

		if (FadeInScreenSound != None)
			GetSoundActor().PlaySound(FadeInScreenSound,,,,,,,False);
		if (Song != "")
			SongHandle = GetGameSingle().PlayMusicExt(Song, FadeInSongTime,,false);
		if (bFadeScreenInOut)
			SetFadeIn(FadeInScreenTime, true);
		if (AfterFadeInScreen == '' || AfterFadeInScreen == 'None')
			AfterFadeInScreen = 'FadeOutScreen';

		// Save current FOV and reset it to default
		OldPlayerFOV  = ViewportOwner.Actor.DesiredFOV;
		ViewportOwner.Actor.ResetFOV();

		DelayedGotoState(FadeInScreenTime, AfterFadeInScreen);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Fade out screen
///////////////////////////////////////////////////////////////////////////////
state FadeOutScreen extends ShowScreen
	{
	function BeginState()
		{
		MaybeLog("P2Screen.FadeOutScreen.BeginState()");

		if (SongHandle != 0)
			{
			GetGameSingle().StopMusicExt(SongHandle, FadeOutSongTime);
			SongHandle = 0;
			}
		if (FadeOutScreenSound != None)
			GetSoundActor().PlaySound(FadeOutScreenSound, SLOT_Misc,,,,,,False);

		if (bFadeScreenInOut)
			SetFadeOut(FadeOutScreenTime, true);
		DelayedGotoState(FadeOutScreenTime, 'FadeInGame');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Fade in the game
///////////////////////////////////////////////////////////////////////////////
state FadeInGame
	{
	function BeginState()
		{
		MaybeLog("P2Screen.FadeInGame.BeginState()");

		if (bFadeGameInOut)
			SetFadeIn(FadeInGameTime, true);

		// Restore FOV to whatever it was when we started
		ViewportOwner.Actor.SetFOV(OldPlayerFOV);

		DelayedGotoState(FadeInGameTime, 'Shutdown');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     bFadeGameInOut=True
     FadeInGameTime=0.300000
     FadeOutGameTime=0.300000
     bFadeScreenInOut=True
     FadeInScreenTime=0.500000
     FadeOutScreenTime=0.500000
     FadeInSongTime=1.000000
     FadeOutSongTime=1.000000
     bEndWhenTraveling=True
     Message="Press %KEY_WantsToSkip% to continue."
     MsgX=0.500000
     MsgY=0.950000
     MsgFlashRate=0.500000
     MinRes="640x480"
     FadeScreenMat=Texture'nathans.Inventory.blackbox64'
     FontInfoClass="FPSGame.FontInfo"
     bActive=False
	 bStretch=True
}
