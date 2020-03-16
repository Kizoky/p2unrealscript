///////////////////////////////////////////////////////////////////////////////
// RifleWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Rifle weapon (first and third person).
//
// Has powerful head shots. If you're zoomed in it has much better built-in aim.
//
// This uses by default, the mouse wheel to zoom in and out. Therefore, it turns
// off Next/Prev weapon when in zoomed mode. Two functions AllowNextWeapon and
// AllowPrevWeapon to determine if it can use the Next/PrevWeapon functions.
// Normally we would have used states to ignore these functions, but because
// we need to be in NormalFire state zoomed and normal, we went with two
// extra functions to say if he's zoomed or not, instead of making a 'IsZoomed'
// state. This also followed Epics original method or their zoom mode.
//
///////////////////////////////////////////////////////////////////////////////

class RifleWeapon extends P2Weapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var bool bZoomed;
var texture SniperReticleCorner;
var Texture SniperReticleCenter;
var Texture BlackBackground;
var float ZoomedTraceAccuracy;		// Better aim when you're zoomed in
var float BotTraceAccuracy;
var Sound SniperBreathing;	// breathing while in zoomed mode
var Sound SniperChangeZoomSound; // clicky noise as you zoom in and out
var Sound SniperFarting[2];
var float ZoomFOV;
var float FullScreenAlpha;
var float FadeSpeed;
var float WeaponSpeedZoom;
var bool  bChangedZoom;
var int BreathCount;
var int BreathMax;
var int SoundIndex;
var float BreathWait;
var travel bool bShowHint1;
var bool bBlockZoomIn;
var float TestTraceDist;
var P2Pawn MyTarget;
var float TargetTime;		// After every so often, reduce this again to 0. Use it to update
							// the client that they're still in range.


const SCALE_RAND =	0.3;
const OFFSET_X_BASE = 0.02;
const OFFSET_Y_BASE = 0.02;
const MAX_ZOOM_FOV		=	30;
const START_ZOOM_FOV	=	15;
const MIN_ZOOM_FOV		=	2;
const INC_ZOOM_FOV		=	1;
const BREATH_MAX		=	20;
const FADE_ZOOM_ENTRY_TIME=	1.4;
const CAN_SHOOT_FADE	=	100;
const BETWEEN_BREATH_WAIT= 1.0;
const BETWEEN_BREATH_WAIT_BEHIND= 5.0;

const MAX_TRACES	=	5;

const EXPECTED_START_RES_WIDTH_RIFLE	= 1024;

const WAIT_IDLE_TIME	=	0.2;

const TARGET_UPDATE_TIME	= 2.0;

///////////////////////////////////////////////////////////////////////////////
// Modify your speed based on your owners body speed
///////////////////////////////////////////////////////////////////////////////
function ChangeSpeed(float NewSpeed)
{
	Super.Changespeed(NewSpeed);
	WeaponSpeedZoom = default.WeaponSpeedZoom*NewSpeed;
}

///////////////////////////////////////////////////////////////////////////////
// Bots with a sniper rifle always use ZoomedTraceAccuracy
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Bots with a sniper rifle use a higher accuracy
	if(FPSPawn(Instigator) != None
		&& !FPSPawn(Instigator).bPlayer)
		TraceAccuracy = BotTraceAccuracy;
}

///////////////////////////////////////////////////////////////////////////////
// Allow hints again
///////////////////////////////////////////////////////////////////////////////
function RefreshHints()
{
	Super.RefreshHints();
	bShowHint1=true;
}

///////////////////////////////////////////////////////////////////////////////
// Fire the weapon
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
	{
	Super.PlayFiring();
	SetupMuzzleFlash();
	}

///////////////////////////////////////////////////////////////////////////////
// This will randomly change the color and the size of the dynamic
// light associate with the flash. Change in each weapon's file,
// but call each time you start up the flash again.
// This function is also used by the third-person muzzle flash, so the
// colors will look the same
///////////////////////////////////////////////////////////////////////////////
simulated function PickLightValues()
{
	LightBrightness=150;
	LightSaturation=150;
	LightHue=12+FRand()*15;
	LightRadius=12+FRand()*6;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the muzzle flash renders, and move it around some
///////////////////////////////////////////////////////////////////////////////
simulated function SetupMuzzleFlash()
{
	if(!IsZoomed())
	{
		bMuzzleFlash = true;
		bSetFlashTime = false;

		// Gets turned off in weapon, in RenderOverlays
		// Slightly change colors each time
		if(IsFirstPersonView()
			&& bDrawMuzzleFlash)
		{
			PickLightValues();
			bDynamicLight=bAllowDynamicLights;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
	local int i;
	local int X,Y;
	local Float CX,CY,Scale;
	local Rotator OldVR;
	local float ULength, VLength, UStart, VStart, FixedClipX, OffsetX;
	local PlayerController PlayerOwner;

	if ( Instigator == None )
		return;




	bNoHudReticle=false;

	if ( !bZoomed || IsInState('Zooming'))
		// draw the normal weapon and reticle
		Super.RenderOverlays(Canvas);
	else	// draw in our fancy sniping reticle
	{
        bNoHudReticle=true;
        PlayerOwner = PlayerController(Instigator.Controller);

		FixedClipX = PlayerOwner.GetFourByThreeResolution(Canvas);
        OffsetX = (Canvas.ClipX - FixedClipX) /2;

		scale = FixedClipX/EXPECTED_START_RES_WIDTH_RIFLE;
		Canvas.Style = ERenderStyle.STY_Normal;

		// Draw black bars on sides
		// +/- 10 fixes small visible line on both sides
        // where the bars meet the scope texture.
	    // Left Side
        Canvas.SetPos(0,0);
	    Canvas.DrawRect( BlackBackground, OffsetX+10, Canvas.ClipY );
        // Right Side
        Canvas.SetPos(FixedClipX+OffsetX-10,0);
	    Canvas.DrawRect( BlackBackground, OffsetX+10, Canvas.ClipY );

		ULength = SniperReticleCorner.USize;
		VLength = SniperReticleCorner.VSize;
		// Four corners curved pieces flipped around x and y axes to make
		// a full circle, centered around the center of the screen
		// upper left
		Canvas.SetPos(OffsetX, 0);
		Canvas.DrawTile(SniperReticleCorner, FixedClipX/2,
											Canvas.SizeY/2,
											0,
											0,
											-ULength,
											-VLength);
		// upper right
		Canvas.SetPos((Canvas.ClipX/2), 0);
		Canvas.DrawTile(SniperReticleCorner, FixedClipX/2,
											Canvas.SizeY/2,
											0,
											0,
											ULength,
											-VLength);
		// lower left
		Canvas.SetPos(OffsetX, Canvas.ClipY/2);
		Canvas.DrawTile(SniperReticleCorner, FixedClipX/2,
											Canvas.SizeY/2,
											0,
											0,
											-ULength,
											VLength);
		// lower right
		Canvas.SetPos((Canvas.ClipX/2), Canvas.ClipY/2);
		Canvas.DrawTile(SniperReticleCorner, FixedClipX/2,
											Canvas.SizeY/2,
											0,
											0,
											ULength,
											VLength);

		// Large cross-hairs that scretch over the whole screen
		ULength = SniperReticleCenter.USize;
		VLength = SniperReticleCenter.VSize;


		// TOTAL HACK--fix in the texture, so it's 0, 0
		Canvas.SetPos(OffsetX+(Scale*10), Scale*10);

		Canvas.DrawTile(SniperReticleCenter, FixedClipX,
											Canvas.SizeY,
											0,
											0,
											ULength,
											VLength);

		if(FullScreenAlpha > 0)
		{
			// Draw full screen fades for when you're switching between zoom modes
			Canvas.Style = ERenderStyle.STY_Alpha;
			Canvas.SetDrawColor(255,255,255,FullScreenAlpha);
			Canvas.SetPos(0, 0);
			Canvas.DrawTile(BlackBackground, Canvas.SizeX,
												Canvas.SizeY,
												0,
												0,
												1.0,
												1.0);
		}

		Canvas.Style = ERenderStyle.STY_Normal;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Don't allow them to shoot as the rifle is brightening up
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	if(FullScreenAlpha <= CAN_SHOOT_FADE)
		Super.Fire(Value);
}
simulated function AltFire( float Value )
{
	if(FullScreenAlpha <= CAN_SHOOT_FADE)
	{
		if(!bBlockZoomIn)
		{
			ServerAltFire();

			if ( Role < ROLE_Authority)
			{
				LocalAltFire();
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called on client's side to make the gun fire
// Check here to throw out danger markers to let people know the gun has gone
// off.
///////////////////////////////////////////////////////////////////////////////
simulated function LocalFire()
{
	local P2Player P;

	bPointing = true;

	// Same as the one in P2Weapon, but we don't do the camera shake here
	// We make it shake when he throws

	if ( Affector != None )
		Affector.FireEffect();
	PlayFiring();
	if(Role < ROLE_Authority)
		GotoState('ClientFiring');
}

///////////////////////////////////////////////////////////////////////////////
// Same as above.. we don't want the shake here
///////////////////////////////////////////////////////////////////////////////
simulated function LocalAltFire()
{
	Zoom();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
{
	Zoom();
}

///////////////////////////////////////////////////////////////////////////////
// Is zooming
///////////////////////////////////////////////////////////////////////////////
simulated function bool IsZoomed()
{
	return bZoomed;
}

///////////////////////////////////////////////////////////////////////////////
// Start the zoom
///////////////////////////////////////////////////////////////////////////////
simulated function Zoom()
{
	if(AmmoType.HasAmmo()
		&& Instigator.Physics == PHYS_Walking
		&& (P2Player(Instigator.Controller) == None
			|| P2Player(Instigator.Controller).IsInState('PlayerWalking')))
	{
		if ( !bZoomed )
		{
			GotoState('ZoomingIn');
		}
		else
		{
			GotoState('ZoomingOut');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Do the work in the FOV to change the zoom mode.
///////////////////////////////////////////////////////////////////////////////
simulated function EnterZoomMode()
{
	bShowHints=false;
	if(bShowHint1)
		bShowHint1=false;

	if(P2Player(Instigator.Controller) != None)
		P2Player(Instigator.Controller).EnterSnipingState();

	PlayAnim('StartZoom',WeaponSpeedZoom);
	bBlockZoomIn=true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ExitZoomMode()
{
	if(bZoomed)
	{
		bBlockZoomIn=true;
		bZoomed = false;

		if(P2Player(Instigator.Controller) != None)
		{
			PlayerController(Instigator.Controller).ResetFOV();
			P2Player(Instigator.Controller).ExitSnipingState();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function FinishZoomEntry()
{
	bBlockZoomIn=false;
	bZoomed=true;
	// Change over to second hint now
	bShowHints=true;
	UpdateHudHints();

	// Give it better accuracy when zoomed
	TraceAccuracy = ZoomedTraceAccuracy;

	ZoomFOV = START_ZOOM_FOV;
	if(PlayerController(Instigator.Controller) != None)
	{
		PlayerController(Instigator.Controller).SetFOV(ZoomFov);
		PlayerController(Instigator.Controller).ClientAdjustGlow(0.5,vect(0,255,0));
	}

	HandleZoomChange(255, FADE_ZOOM_ENTRY_TIME);

	// Setup the new sniper zone fog
	if(P2GameInfoSingle(Level.Game) != None)
		P2GameInfo(Level.Game).SetSniperZoneFog(Owner);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function FinishZoomExit()
{
	if(PlayerController(Instigator.Controller) != None)
		PlayerController(Instigator.Controller).ClientAdjustGlow(0,vect(0,0,0));

	// Reset the zone's general fog
	if(P2GameInfoSingle(Level.Game) != None)
		P2GameInfo(Level.Game).SetGeneralZoneFog(Owner);

	// Reset the accuracy
	// Bots with a sniper rifle use a higher accuracy
	if(FPSPawn(Instigator) != None
		&& !FPSPawn(Instigator).bPlayer)
		TraceAccuracy = BotTraceAccuracy;
	else
		TraceAccuracy = default.TraceAccuracy;
	bShowHints=false;
	UpdateHudHints();
}


///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bShowHints
		&& bAllowHints)
	{
		if(bShowHint1)
			str1=HudHint1;
		else
			str2=HudHint2;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure you're not zoomed
///////////////////////////////////////////////////////////////////////////////
simulated function bool ForceEndFire()
	{
	log(self$" sniper force end fire ");
	if(PlayerController(Instigator.Controller) != None)
		PlayerController(Instigator.Controller).ResetFOV();
	ExitZoomMode();
	FinishZoomExit();
	return Super.ForceEndFire();
	}

///////////////////////////////////////////////////////////////////////////////
// Send the rifle into a mode of fading the screen
///////////////////////////////////////////////////////////////////////////////
simulated function HandleZoomChange(float StartAlpha, float TimeSpent)
{
	FullScreenAlpha = StartAlpha;
	FadeSpeed = FullScreenAlpha/TimeSpent;
}

///////////////////////////////////////////////////////////////////////////////
// Next weapon like normal, unless you're in zoom mode then we don't want the
// player to use this
///////////////////////////////////////////////////////////////////////////////
simulated function bool AllowNextWeapon()
{
	if(IsZoomed())
		return false;
	else
		return Super.AllowNextWeapon();
}

///////////////////////////////////////////////////////////////////////////////
// Prev weapon like normal, unless you're in zoom mode then we don't want the
// player to use this
///////////////////////////////////////////////////////////////////////////////
simulated function bool AllowPrevWeapon()
{
	if(IsZoomed())
		return false;
	else
		return Super.AllowPrevWeapon();
}

///////////////////////////////////////////////////////////////////////////////
// Zooms scope in
///////////////////////////////////////////////////////////////////////////////
simulated function ZoomIn()
{
	if(IsZoomed())
	{
		if(ZoomFOV > MIN_ZOOM_FOV)
		{
			Instigator.PlaySound(SniperChangeZoomSound,SLOT_Misc);
			// FOV works seemingly backwards.. smaller it is, the more zoomed in you are
			ZoomFOV -= INC_ZOOM_FOV;
			if(ZoomFOV < MIN_ZOOM_FOV)
				ZoomFOV = MIN_ZOOM_FOV;
			if(PlayerController(Instigator.Controller) != None)
				PlayerController(Instigator.Controller).SetFOV(ZoomFov);
			// We've completed whatever it was that makes us not want to show hints anymore for this weapon
			TurnOffHint();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Zooms scope out
///////////////////////////////////////////////////////////////////////////////
simulated function ZoomOut()
{
	if(IsZoomed())
	{
		if(ZoomFOV < MAX_ZOOM_FOV)
		{
			Instigator.PlaySound(SniperChangeZoomSound,SLOT_Misc);
			// FOV works seemingly backwards.. smaller it is, the more zoomed in you are
			ZoomFOV += INC_ZOOM_FOV;
			if(ZoomFOV > MAX_ZOOM_FOV)
				ZoomFOV = MAX_ZOOM_FOV;
			if(PlayerController(Instigator.Controller) != None)
				PlayerController(Instigator.Controller).SetFOV(ZoomFov);
			// We've completed whatever it was that makes us not want to show hints anymore for this weapon
			TurnOffHint();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Normal projectile fire, plus check where to make the danger marker to
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function ProjectileFire()
{
	local vector markerpos, EndTrace;
	local vector StartTrace, X,Y,Z;

	// Moves like a projectile, but set up like a trace
	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
	EndTrace = StartTrace + (TraceAccuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (TraceAccuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (TraceDist * X);

	// Make it
	RifleAmmoInv(AmmoType).SpawnRifleProjectile(StartTrace,Normal(EndTrace - StartTrace));

	// Only make a new danger marker if the consecutive fires were as high
	// as the max
	if(ShotCount >= ShotCountMaxForNotify
		&& Instigator.Controller != None
		&& ShotMarkerMade != None)
	{
		// tell it we know this just happened, by recording it.
		ShotCount -= ShotCountMaxForNotify;

		// Records the first (gun fire)
		markerpos = Instigator.Location;

		// Primary (the gun shooting, making a loud noise)
		if(ShotMarkerMade != None)
		{
			ShotMarkerMade.static.NotifyControllersStatic(
				Level,
				ShotMarkerMade,
				FPSPawn(Instigator),
				None,
				ShotMarkerMade.default.CollisionRadius,
				markerpos);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	if(bZoomed)
	{
		ExitZoomMode();
		FinishZoomExit();
	}
	Super.DropFrom(StartLocation);
}

///////////////////////////////////////////////////////////////////////////////
// When necessary, handle the full screen alpha change
///////////////////////////////////////////////////////////////////////////////
simulated function FadeTick(float DeltaTime)
{
	if (Level.NetMode != NM_DedicatedServer )
	{
		if(FullScreenAlpha != 0)
		{
			FullScreenAlpha -= DeltaTime*FadeSpeed;

			if(FullScreenAlpha < 0)
			{
				FullScreenAlpha = 0;
			}
		}
	}
}

simulated function bool PutDown()
{
	bChangeWeapon = true;
	ExitZoomMode();
	FinishZoomExit();
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Make glare so he'll be easier to spot in MP games
///////////////////////////////////////////////////////////////////////////////
function MakeGlare()
{
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		P2Pawn(Instigator).MakeSniperGlare();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Zooming
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Zooming
{
	ignores ForceReload, NextWeapon, PrevWeapon,
		ZoomIn, ZoomOut, WeaponChange;

	simulated function Fire(float F)
	{
		if ( AmmoType == None
			|| !AmmoType.HasAmmo() )
		{
			ClientForceFinish();
			ServerForceFinish();
			return;
		}
	}

	simulated function AltFire(float F)
	{
		Fire(F);
	}

	simulated function bool IsZoomed()
	{
		return false;
	}

	simulated function bool PutDown()
	{
		bChangeWeapon = true;
		ExitZoomMode();
		FinishZoomExit();
		return True;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ZoomingIn/Out
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ZoomingIn extends Zooming
{
	simulated function AnimEnd(int Channel)
	{
		FinishZoomEntry();
		GotoState('Idle');
	}

	simulated function BeginState()
	{
		// START zoom mode
		EnterZoomMode();
	}
}

state ZoomingOut extends Zooming
{
	simulated function AnimEnd(int Channel)
	{
		FinishZoomExit();
		if(Level.NetMode == NM_Client)
			PlayIdleAnim();
		GotoState('Idle');
	}

	simulated function BeginState()
	{
		// END zoom mode
		ExitZoomMode();
		PlayAnim('EndZoom',WeaponSpeedZoom);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Idle
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
	ignores ClientIdleCheckFire;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Don't let them zoom in/out till this is called
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer()
	{
		bBlockZoomIn=false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// When necessary, handle the full screen alpha change
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
		local Actor TestTarget;

		FadeTick(DeltaTime);

		// If it's the client, or a normal, single player game
		if (P2GameInfoSingle(Level.Game) == None)
		{
			// The client can't check a trace/collision, only the server
			if(Level.NetMode != NM_Client)
			{
				// If you're zoomed and in an MP game, trace forward and see if you'll
				// hit a pawn or not. Then we can alert the person playing and tell them
				// they're in range to get shot in the head.
				if(bZoomed
					&& PlayerController(Instigator.Controller) != None)
				{
					GetAxes(Instigator.GetViewRotation(),X,Y,Z);
					StartTrace = Instigator.Location + Instigator.EyePosition();
					EndTrace = StartTrace + TestTraceDist*X;
					TestTarget = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

					// Undo view from last target, because we have a new/none target
					if(MyTarget != None
						&& TestTarget != MyTarget)
					{
						MyTarget.ClientSniperViewingMe(P2Pawn(Owner), false);
						MyTarget = None;
					}

					// Keep track of how long we've have this target.
					if(MyTarget != None)
						TargetTime+=DeltaTime;

					// Tell our new target he's in our sites!
					if(TestTarget != MyTarget
						&& P2Pawn(TestTarget) != None
						&& PlayerController(Pawn(TestTarget).Controller) != None)
					{
						MyTarget = P2Pawn(TestTarget);
						MyTarget.ClientSniperViewingMe(P2Pawn(Owner), true);
						TargetTime=DeltaTime;
					}
					else if(MyTarget != None
						&& TargetTime > TARGET_UPDATE_TIME)
						// We've got the same old target, just update him
					{
						TargetTime =0;
						MyTarget.ClientSniperViewingMe(P2Pawn(Owner), true);
					}
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// If we're zoomed, make sure to update the new zone's zone fog, and change
	// the old one's before you leave.
	///////////////////////////////////////////////////////////////////////////////
	event ZoneChange( ZoneInfo NewZone )
	{
		if(IsZoomed())
		{
			if(P2GameInfoSingle(Level.Game) != None)
			{
				// Reset old zone's fog
				P2GameInfo(Level.Game).SetGeneralZoneFog(Owner);
				// Set new one
				P2GameInfo(Level.Game).SetNewSniperZoneFog(NewZone);
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// If it's the dude and he farted, apologize
	///////////////////////////////////////////////////////////////////////////////
	function float DudeCommentsOnFarting()
	{
		if(P2Player(Instigator.Controller) != None)
			return P2Player(Instigator.Controller).CommentOnFarting();
		return 0.0;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check he's not talking or something
	///////////////////////////////////////////////////////////////////////////////
	function float DudeBreathes()
	{
		if(P2Player(Instigator.Controller) != None)
			return P2Player(Instigator.Controller).SniperBreathing();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Reset shot count if you're not still firing
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		// Always reset the count with each shot
		ShotCountReset();
		bBlockZoomIn=true;
		SetTimer(WAIT_IDLE_TIME, false);
		// Make sure to make a glare right off the bat
		if(IsZoomed())
		{
			MakeGlare();
		}
	}

	simulated function EndState()
	{
		bBlockZoomIn=false;
		// Undo view from last target because we're leaving this state
		if(MyTarget != None)
		{
			MyTarget.ClientSniperViewingMe(P2Pawn(Owner), false);
			MyTarget = None;
			TargetTime =0;
		}

		Instigator.PlaySound(SniperBreathing,SLOT_Interface,0.01);
		Super.EndState();
	}
Begin:
	bPointing=False;
	if ( NeedsToReload() && AmmoType.HasAmmo() )
		GotoState('Reloading');
	if ( !AmmoType.HasAmmo() )
		Instigator.Controller.SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Instigator.PressingFire() ) Fire(0.0);
	//if ( Instigator.PressingAltFire() ) AltFire(0.0);
	PlayIdleAnim();
	Sleep(WAIT_IDLE_TIME);	// Don't let them switch during this time

ZoomedBreathing:
	if(IsZoomed())
	{
		// Wait a second to start breathing (again)
		Sleep(1.5 + FRand());
		// Setup our counters
		BreathCount = 0;
		BreathMax = Rand(BREATH_MAX) + BREATH_MAX;

MakeSound:
		MakeGlare();

		// Breathes as he stares through scope (unless the
		// camera is viewing him in third-person)
		if(PlayerController(Instigator.Controller) != None
			&& !PlayerController(Instigator.Controller).bBehindView)
			BreathWait = DudeBreathes() + BETWEEN_BREATH_WAIT;
		else
			BreathWait = BETWEEN_BREATH_WAIT_BEHIND;

		if(BreathWait > 0)
			BreathCount++;
		else
			Goto('ZoomedBreathing');

		Sleep(BreathWait/2);
		MakeGlare();
		Sleep(BreathWait/2);

		// Every so often, fart
		if(BreathCount > BreathMax)
		{
			SoundIndex = Rand(ArrayCount(SniperFarting));
			Instigator.PlaySound(SniperFarting[SoundIndex],SLOT_Interface,1.0);
			Sleep(GetSoundDuration(SniperFarting[SoundIndex]) + 1.0 + FRand());
			// Apologize for it
			Sleep(DudeCommentsOnFarting() + 1.0);
			Goto('ZoomedBreathing');
		}
		Goto('MakeSound');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// NormalFire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	///////////////////////////////////////////////////////////////////////////////
	// When necessary, handle the full screen alpha change
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		FadeTick(DeltaTime);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ClientFiring
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ClientFiring
{
	///////////////////////////////////////////////////////////////////////////////
	// When necessary, handle the full screen alpha change
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		FadeTick(DeltaTime);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Downweapon
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DownWeapon
{
	ignores Zoom;

	simulated function BeginState()
	{
		Super.BeginState();
		ExitZoomMode();
		FinishZoomExit();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bUsesAltFire=true
	ItemName="Rifle"
	AmmoName=class'RifleAmmoInv'
	PickupClass=class'RiflePickup'
	AttachmentClass=class'RifleAttachment'

//	Mesh=Mesh'FP_Weapons.FP_Dude_Rifle'
	Mesh=Mesh'MP_Weapons.MP_LS_Rifle'

	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	FirstPersonMeshSuffix="Rifle"

	bSniping=true
    bDrawMuzzleFlash=false
	MuzzleScale=1.0
	FlashOffsetY=-0.09
	FlashOffsetX=0.095
	FlashLength=0.1
	MuzzleFlashSize=96
    MFTexture=Texture'Timb.muzzleflash.machine_gun_corona'

    //MuzzleFlashStyle=STY_Translucent
	MuzzleFlashStyle=STY_Normal
    //MuzzleFlashMesh=Mesh'Weapons.Shotgun3'
    MuzzleFlashScale=2.40000
    //MuzzleFlashTexture=Texture'MuzzyPulse'

	holdstyle=WEAPONHOLDSTYLE_Double
	switchstyle=WEAPONHOLDSTYLE_Double
	firingstyle=WEAPONHOLDSTYLE_Double

	//ShakeMag=1000.000000
	//ShakeRollRate=20000
	//ShakeOffsetTime=3.0
	//ShakeTime=0.500000
	//ShakeVert=(Z=5.0)
	ShakeOffsetMag=(X=20.0,Y=2.0,Z=2.0)
	ShakeOffsetRate=(X=800.0,Y=800.0,Z=800.0)
	ShakeOffsetTime=2.0
	ShakeRotMag=(X=450.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2.0

	SoundRadius=255
	FireSound=Sound'WeaponSounds.sniper_fire'
	SniperBreathing=Sound'WeaponSounds.sniper_zoombreathing'
	SniperChangeZoomSound = Sound'WeaponSounds.sniper_zoomclick'
	SniperFarting[0] = Sound'AmbientSounds.fart1'
	SniperFarting[1] = Sound'AmbientSounds.fart3'
	CombatRating=2.0
	AIRating=0.8
	AutoSwitchPriority=8
	InventoryGroup=8
	GroupOffset=1
	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.2
	TraceDist=1000
    TestTraceDist=10000.0
	ZoomedTraceAccuracy=0.0
	BotTraceAccuracy=0.5
	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	ShotCountMaxForNotify=1
	ViolenceRank=3

	WeaponSpeedIdle	   = 0.1
	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.5
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.15
	WeaponSpeedShoot2  = 1.0

	AimError=0

	MaxRange=4096
	MinRange=250
	RecognitionDist=1100

	SniperReticleCorner = Texture'JakeWS.Misc.Rifle_Sight_Corner'
	SniperReticleCenter  = Texture'P2Misc.Reticle.Rifle_Sight_Crosshairs'
	BlackBackground=Texture'nathans.Inventory.BlackBox64'

	HudHint1="%KEY_AltFire% brings up scope."
	HudHint2="Use %KEY_WeaponZoomIn%/%KEY_WeaponZoomOut% to zoom in and out."
	bAllowHints=true
	bShowHints=true
	bShowHint1=true
	WeaponSpeedZoom = 1.0
	PlayerViewOffset=(X=2,Y=0,Z=-7.75)
	}

