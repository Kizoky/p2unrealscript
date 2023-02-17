///////////////////////////////////////////////////////////////////////////////
// PLHud
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// PL-specific hud overlays etc.
///////////////////////////////////////////////////////////////////////////////
class PLHud extends AchievementHUD;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() CameraEffect FlashbangEffect;
var() Sound FlashbangRing;
var() Texture FlashbangFill;
var() Texture FlashbangOverlay;
var() Material FastForwardEffect;
var() Texture FastForwardIcon;

var float FlashbangStartTime;

const FLASHBANG_INITIAL_FLASH_DURATION = 1.0;
const FLASHBANG_FADE_DURATION = 1.0;
const FLASHBANG_DURATION = 7.5;

const FF_ICON_X = 0.05;
const FF_ICON_Y = 0.05;

///////////////////////////////////////////////////////////////////////////////
// Draw achievements over everything
///////////////////////////////////////////////////////////////////////////////
simulated event PostRender( canvas Canvas )
{
	local SceneManager SM;
	
	Super.PostRender(Canvas);

	// If there's an active screen, check to see if it wants the hud
	// If there's a root window running then never show the hud
	if ((OurPlayer.CurrentScreen == None || OurPlayer.CurrentScreen.ShouldDrawHUD()) && !AreAnyRootWindowsRunning())
	{
		if ( !PlayerOwner.bBehindView )
		{
			// Draw your foot in now
			if ( (PLPostalDude(PawnOwner) != None) && (PLPostalDude(PawnOwner).LeftHandBird != None) )
				PLPostalDude(PawnOwner).LeftHandBird.RenderOverlays(Canvas);
		}
	}
	
	// Draw Corey Dude overlays anyway
	if(StartActive != 0)
		DrawSwirl(canvas, startinjuries);
	if(WalkActive != 0)
		DrawSwirl(canvas, walkinjuries);
	if(StopActive != 0)
		DrawSwirl(canvas, stopinjuries);
		
	// If fast-forwarding, render a fast-forward effect
	SM = OurPlayer.GetCurrentSceneManager();
	if (SM != None && !SM.bLetPlayerSkip && SM.bLetPlayerFastForward && OurPlayer.bWantsToSkip == 1)
		DrawFastForwardFX(Canvas);
}

///////////////////////////////////////////////////////////////////////////////
// Player is fast-forwarding a matinee. Draw a fancy overlay
///////////////////////////////////////////////////////////////////////////////
function DrawFastForwardFX(Canvas Canvas)
{
	// Render VHS-style static fuzz
	Canvas.CurX = 0;
	Canvas.CurY = 0;
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.SetDrawColor(255,255,255);
	Canvas.DrawTile(FastForwardEffect, Canvas.SizeX, Canvas.SizeY, 0, 0, Canvas.SizeX, Canvas.SizeY);
	
	// Render FF>> icon
	Canvas.CurX = UltraWideOffsetX + FF_ICON_X * CanvasWidth;
	Canvas.CurY = FF_ICON_Y * CanvasHeight;
	Canvas.DrawIcon(FastForwardIcon, 1.0);
}

///////////////////////////////////////////////////////////////////////////////
// Dude is hit with a flashbang. Start up the ringing and overlays
///////////////////////////////////////////////////////////////////////////////
function HitByFlashBang()
{
	// If flashbang effect is already present, get rid of it before adding another
	if (FlashbangStartTime != 0)
		OurPlayer.RemoveCameraEffect(FlashbangEffect);
	
	// Start up our flashbang time and add in the blur effect.
	FlashbangStartTime = Level.TimeSeconds;
	OurPlayer.AddCameraEffect(FlashbangEffect);
	//PawnOwner.PlaySound(FlashbangRing);
	PlayFlashbangSound(FlashbangRing, FLASHBANG_DURATION);
}

///////////////////////////////////////////////////////////////////////////////
// Flashbang overlay.
///////////////////////////////////////////////////////////////////////////////
function DrawFlashbangOverlay(Canvas Canvas)
{
	local float FlashbangTime;
	local Color UseColor;
	
	FlashbangTime = Level.TimeSeconds - FlashbangStartTime;

	// 0.0 - 1.0 = draw a solid white block over the entire screen, fade it out gradually
	if (FlashbangTime < FLASHBANG_INITIAL_FLASH_DURATION)
	{
		Canvas.SetDrawColor(255, 255, 255, 256 - (255 * FlashbangTime / FLASHBANG_INITIAL_FLASH_DURATION));
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.SetPos(0,0);
		Canvas.DrawTile(FlashbangFill, Canvas.SizeX, Canvas.SizeY, 0, 0, FlashbangFill.USize, FlashbangFill.VSize);
	}
	
	// 0.0 - 6.5 = draw white overlay, allow mostly the center only
	if (FlashbangTime < FLASHBANG_DURATION - FLASHBANG_FADE_DURATION)
	{
		Canvas.SetDrawColor(255, 255, 255, 0);
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(0,0);
		Canvas.DrawTile(FlashbangOverlay, Canvas.SizeX, Canvas.SizeY, 0, 0, FlashbangOverlay.USize, FlashbangOverlay.VSize);
	}
	
	// 6.5 - 7.5 = fade out the overlay
	if (FlashbangTime >= FLASHBANG_DURATION - FLASHBANG_FADE_DURATION)
	{
		Canvas.SetDrawColor(255, 255, 255, 256 - (255 * (FlashbangTime - (FLASHBANG_DURATION - FLASHBANG_FADE_DURATION)) / FLASHBANG_FADE_DURATION));
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.SetPos(0,0);
		Canvas.DrawTile(FlashbangOverlay, Canvas.SizeX, Canvas.SizeY, 0, 0, FlashbangOverlay.USize, FlashbangOverlay.VSize);
	}
	
	// > 7.5 = reset flashbang time.
	if (FlashbangTime > FLASHBANG_DURATION)
	{
		FlashbangStartTime = 0;
		OurPlayer.RemoveCameraEffect(FlashbangEffect);
	}
	
	Canvas.Style = ERenderStyle.STY_Normal;
}

///////////////////////////////////////////////////////////////////////////////
// Draw all the player status stuff and return a flag indicating whether other
// hud elements should be displayed (true means they should be displayed).
//
// ONLY call this if player has already been determined not to be dead!
///////////////////////////////////////////////////////////////////////////////
simulated function bool DrawPlayerStatus(canvas Canvas, optional bool bCriticalInfoOnly)
{
	local bool bResult;
	
	bResult = Super.DrawPlayerStatus(Canvas, bCriticalInfoOnly);
	if (bResult)
	{
		// Draw flashbang overlays
		if (FlashbangStartTime > 0)
			DrawFlashbangOverlay(Canvas);
	}
	
	return bResult;
}

///////////////////////////////////////////////////////////////////////////////
// Head injury functions
///////////////////////////////////////////////////////////////////////////////
// If the Dude is dumbass enough to look directly at, or be in the hurt radius of, his flashbang
/*
function StartHeadInjury()
{
	local int i;

	PawnOwner.PlaySound(FlashbangRing);
	for(i=0; i<startinjuries.Length; i++)
		startinjuries[i] = default.startinjuries[i];
	StartActive=1;
	// Stop immediately after fading out
	StopSwirlOnAlpha(StartInjuries, true);
}
*/
function StopHeadInjury()
{
	local int i;

	//for(i=0; i<stopinjuries.Length; i++)
		//stopinjuries[i] = default.stopinjuries[i];
	// stop the others instantly
	//StartActive=0;
	StopActive=0;
	//StopSwirlOnAlpha(stopinjuries, true);
	StopSwirlOnAlpha(walkinjuries, true);
}

defaultproperties
{
	startinjuries(0)=(Tex=Texture'Zo_Smeg.Ground_Alphas.zo_grnd_alpha2',Scale=1.000000,MoveTimeDilation=1.000000,Red=255.000000,Green=255.000000,Blue=255.000000,Alpha=255.000000,alphachange=-30.000000,AlphaMax=255.000000,alphamin=1.000000,x=0,y=0,movespeed=0)
	startinjuries(1)=(Tex=Texture'Zo_Smeg.Ground_Alphas.zo_grnd_alpha2',Scale=1.000000,MoveTimeDilation=1.000000,Red=255.000000,Green=255.000000,Blue=255.000000,Alpha=255.000000,alphachange=-30.000000,AlphaMax=255.000000,alphamin=1.000000,x=0,y=0,movespeed=0)
	startinjuries(2)=(Tex=Texture'Zo_Smeg.Ground_Alphas.zo_grnd_alpha2',Scale=1.000000,MoveTimeDilation=1.000000,Red=255.000000,Green=255.000000,Blue=255.000000,Alpha=255.000000,alphachange=-30.000000,AlphaMax=255.000000,alphamin=1.000000,x=0,y=0,movespeed=0)
	stopinjuries(0)=(Tex=None)
	stopinjuries(1)=(Tex=None)
	walkinjuries(0)=(Tex=Texture'Zo_Smeg.Special_Brushes.zo_gravel',xoff=-0.500000,yoff=-0.500000,Scale=2.000000,MoveTimeDilation=0.600000,MoveSpeed=0.300000,Green=180.000000,Alpha=25.000000,greenchange=2.000000,bluechange=1.000000,alphachange=12.000000,greenmax=180.000000,bluemax=80.000000,AlphaMax=25.000000,greenmin=100.000000,bluemin=1.000000,alphamin=5.000000)
	walkinjuries(1)=(Tex=Texture'Zo_Smeg.Special_Brushes.zo_wash2_opaque',xoff=-0.500000,yoff=-0.500000,Scale=2.000000,MoveTimeDilation=0.700000,MoveSpeed=-0.150000,Red=50.000000,Green=100.000000,Blue=200.000000,Alpha=25.000000,greenchange=1.000000,bluechange=-4.000000,alphachange=14.000000,redmax=100.000000,greenmax=100.000000,bluemax=255.000000,AlphaMax=25.000000,redmin=50.000000,greenmin=20.000000,bluemin=200.000000,alphamin=5.000000)

	Begin Object Class=MotionBlur Name=MotionBlur0
		Alpha=1.0
		FinalEffect=False
		BlurAlpha=64
	End Object
	FlashbangEffect=MotionBlur'MotionBlur0'
	FlashbangRing=Sound'PL_FlashGrenadeSound.FlashGrenade_Ringing'
	FlashbangFill=Texture'PLHud.Misc.whitebox64'
	FlashbangOverlay=Texture'PLHud.Overlay.flashbang_overlay'
	FastForwardEffect=TexPanner'PLHud.Overlay.FastForwardFuzz_Pan'
	FastForwardIcon=Texture'PLHud.Overlay.FastForwardIcon'
}
