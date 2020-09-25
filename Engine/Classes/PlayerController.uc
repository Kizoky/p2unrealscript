//=============================================================================
// PlayerController
//
// PlayerControllers are used by human players to control pawns.
//
// This is a built-in Unreal class and it shouldn't be modified.
// for the change in Possess().
//=============================================================================
class PlayerController extends Controller
	config(user)
	native
	nativereplication;

// Player info.
var const player Player;

// player input control
var globalconfig	bool 	bLookUpStairs;	// look up/down stairs (player)
var globalconfig	bool	bSnapToLevel;	// Snap to level eyeheight when not mouselooking
var globalconfig	bool	bAlwaysMouseLook;
var globalconfig	bool	bKeyboardLook;	// no snapping when true
var bool					bCenterView;
// RWS CHANGE - added input flag for when user wants to skip over a screen/matinee/sequence/whatever
var input			byte	bWantsToSkip;	// wants to skip screen/matinee/sequence/whatever
var input			byte	bPrevWeapon;	// Controller button for Prev/NextWeapon
var input			byte	bNextWeapon;	// Controller button for Prev/NextWeapon

// Player control flags
var bool		bBehindView;    // Outside-the-player view.
var bool		bFrozen;		// set when game ends or player dies to temporarily prevent player from restarting (until cleared by timer)
var bool		bPressedJump;
var bool		bUpdatePosition;
var bool		bIsTyping;
var bool		bFixedCamera;	// used to fix camera in position (to view animations)
var bool		bJumpStatus;	// used in net games
var	bool		bUpdating;
var globalconfig bool	bNeverSwitchOnPickup;	// if true, don't automatically switch to picked up weapon
var globalconfig bool bNeverSwitchItemOnPickup;	// If true, don't automatically switch to picked up inventory

var bool		bZooming;
// RWS CHANGE: Moved to PlayerReplicationInfo as per UT2003
//var	bool		bOnlySpectator;	// This controller is not allowed to possess pawns

var globalconfig bool bAlwaysLevel;
var bool		bSetTurnRot;
var bool		bCheatFlying;	// instantly stop in flying mode
var bool		bFreeCamera;	// free camera when in behindview mode (for checking out player models and animations)
var	bool		bZeroRoll;
var	bool		bCameraPositionLocked;
var globalconfig bool ngSecretSet;
var bool		ReceivedSecretChecksum;

var float AimingHelp;
var float WaitDelay;			// Delay time until can restart

var input float
	aBaseX, aBaseY, aBaseZ,	aMouseX, aMouseY,
	aForward, aTurn, aStrafe, aUp, aLookUp;

var input byte
	bStrafe, bSnapLevel, bLook, bFreeLook, bTurn180, bTurnToNearest, bXAxis, bYAxis;

var EDoubleClickDir DoubleClickDir;		// direction of movement key double click (for special moves)

// Camera info.
var int ShowFlags;
var int Misc1,Misc2;
var int RendMap;
var float        OrthoZoom;     // Orthogonal/map view zoom factor.
var const actor ViewTarget;
var float CameraDist;		// multiplier for behindview camera dist
var transient array<CameraEffect> CameraEffects;	// A stack of camera effects.

var globalconfig float DesiredFOV;
var globalconfig float DefaultFOV;
var float		ZoomLevel;

// Screen flashes
var vector FlashScale, FlashFog;
var float DesiredFlashScale, ConstantGlowScale, InstantFlash;
var vector DesiredFlashFog, ConstantGlowFog, InstantFog;

// Remote Pawn ViewTargets
var rotator		TargetViewRotation;
var float		TargetEyeHeight;
var vector		TargetWeaponViewOffset;

var HUD	myHUD;	// heads up display info

var float LastPlaySound;
var globalconfig int AnnouncerVolume;

// Music info.
var string				Song;
var EMusicTransition	Transition;

// Move buffering for network games.  Clients save their un-acknowledged moves in order to replay them
// when they get position updates from the server.
var SavedMove SavedMoves;	// buffered moves pending position updates
var SavedMove FreeMoves;	// freed moves, available for buffering
var SavedMove PendingMove;
var float CurrentTimeStamp,LastUpdateTime,ServerTimeStamp,TimeMargin, ClientUpdateTime;
var globalconfig float MaxTimeMargin;
var Weapon OldClientWeapon;
var int WeaponUpdate;

// Progess Indicator - used by the engine to provide status messages (HUD is responsible for displaying these).
var string	ProgressMessage[4];
var color	ProgressColor[4];
var float	ProgressTimeOut;

// Localized strings
var localized string QuickSaveString;
var localized string NoPauseMessage;
var localized string ViewingFrom;
var localized string OwnCamera;
var localized string TravelFailTitle, TravelFailText;

// ReplicationInfo
var GameReplicationInfo GameReplicationInfo;

// ngWorldStats Logging
var globalconfig  string ngWorldSecret;

var class<LocalMessage> LocalMessageClass;

// view shaking (affects roll, and offsets camera position)
var float   MaxShakeRoll; // max magnitude to roll camera
var vector  MaxShakeOffset; // max magnitude to offset camera position
var float   ShakeRollRate;  // rate to change roll
var vector  ShakeOffsetRate;
var vector  ShakeOffset; //current magnitude to offset camera from shake
var float   ShakeRollTime; // how long to roll.  if value is < 1.0, then MaxShakeOffset gets damped by this, else if > 1 then its the number of times to repeat undamped
var vector  ShakeOffsetTime;
var vector  ShakeOffsetMax;
var vector  ShakeRotRate;
var vector  ShakeRotMax;
var rotator ShakeRot;
var vector  ShakeRotTime;

var Pawn		TurnTarget;
var config int	EnemyTurnSpeed;
var int			GroundPitch;
var rotator		TurnRot180;

var vector OldFloor;		// used by PlayerSpider mode - floor for which old rotation was based;

// Components ( inner classes )
// RWS CHANGE: Made CheatManager transient
var private transient CheatManager	CheatManager;	// Object within playercontroller that manages "cheat" commands
var class<CheatManager>		CheatClass;		// class of my CheatManager
var private transient PlayerInput	PlayerInput;	// Object within playercontroller that manages player input.
var class<PlayerInput>		InputClass;		// class of my PlayerInput
// RWS CHANGE: Merged AdminManager from UT2003
var private transient AdminBase		AdminManager;

// Demo recording view rotation
var int DemoViewPitch;
var int DemoViewYaw;
var int StartedFiring;
var int OldAmmo;
var int AddUp;
var int AddRot;

// RWS CHANGE: Merged new ping calculation from UT2003
var float LastPingUpdate;
var float ExactPing;
var float OldPing;

const FOUR_BY_THREE_ASPECT_RATIO  = 1.33333333333;
const SIXTEEN_BY_TEN_ASPECT_RATIO = 1.6;

// For mouse menu joystick interaction thingamajigger
var float OldMouseX, OldMouseY, UseMouseX, UseMouseY, LastMouseTimeX, LastMouseTimeY;	// Holding vars for mouse interaction

//ErikFOV Change: Subtitle system
var SubtitleManager SubtitleManager;
var globalconfig int SubtitleLangIndex;
//

// Change by NickP: FOV fix
var globalconfig float HackedFOV;
// End

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
		//ViewTarget,	// RWS Change, 09/09/03 merge from 2199 to set view target only through functions
		GameReplicationInfo;
	unreliable if ( bNetOwner && Role==ROLE_Authority && (ViewTarget != Pawn) && (Pawn(ViewTarget) != None) )
		TargetViewRotation, TargetEyeHeight, TargetWeaponViewOffset;
	reliable if( bDemoRecording && Role==ROLE_Authority )
		DemoViewPitch, DemoViewYaw;

	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		ClientSetHUD,ClientReliablePlaySound, FOV, StartZoom,
		ToggleZoom, StopZoom, EndZoom, ClientSetMusic, ClientRestart,
		ClientAdjustGlow,
		ClientSetBehindView, ClientSetFixedCamera, ClearProgressMessages,
		SetProgressMessage, SetProgressTime, ProgressCommand,
		GivePawn, ClientGotoState,
		// RWS Change from 2141, MP
        ClientSetViewTarget,
		// RWS CHANGE: Merged admin functions from UT2003
		AdminReply;
	reliable if ( (Role == ROLE_Authority) && (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) )
		ClientMessage, TeamMessage, ReceiveLocalizedMessage;
	unreliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientPlaySound;
	reliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientTravel;
	unreliable if( Role==ROLE_Authority )
		SetFOVAngle, ClientShake, ClientFlash, ClientInstantFlash, ClientSetFlash,
		// RWS CHANGE: Removed epic's workaround for not replicating FlagHolder
		//ClientUpdateFlagHolder,
		ClientAdjustPosition, ShortClientAdjustPosition, VeryShortClientAdjustPosition, LongClientAdjustPosition;
	unreliable if( (!bDemoRecording || bClientDemoRecording && bClientDemoNetFunc) && Role==ROLE_Authority )
		ClientHearSound;

	// Functions client can call.
	unreliable if( Role<ROLE_Authority )
		ServerUpdatePing, ShortServerMove, ServerMove, Say, TeamSay, ServerSetHandedness, ServerViewNextPlayer, ServerViewSelf,ServerUse;
	reliable if( Role<ROLE_Authority )
		Speech, Pause, SetPause,
		ServerPrevItem, ActivateItem, ServerReStartGame, AskForPawn,
		ChangeName, ChangeTeam, Suicide,
		// RWS Change from 2141, MP
		BehindView, Typing,
		ServerThrowWeapon,
		ServerVerifyViewTarget;

	// RWS CHANGE: Merged admin functions from UT2003
	// Server Admin replicated functions
	reliable if( Role<ROLE_Authority )
		Admin, AdminCommand, AdminLogin, AdminLogout;
}

native final function string GetPlayerNetworkAddress();
native function string ConsoleCommand( string Command );
native final function LevelInfo GetEntryLevel();
native(544) final function ResetKeyboard();
native final function SetViewTarget(Actor NewViewTarget);
native event ClientTravel( string URL, ETravelType TravelType, bool bItems );
native(546) final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);
native final function string GetDefaultURL(string Option);
// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
native function CopyToClipboard( string Text );
native function string PasteFromClipboard();

/* FindStairRotation()
returns an integer to use as a pitch to orient player view along current ground (flat, up, or down)
*/
native(524) final function int FindStairRotation(float DeltaTime);

native event ClientHearSound (
	actor Actor,
	int Id,
	sound S,
	vector SoundLocation,
	vector Parameters,
	bool Attenuate,
	bool bAllowPause,
	bool bMaxPriority
);

event PostBeginPlay()
{
	local UnEDLine a;
	
	Super.PostBeginPlay();
	SpawnDefaultHUD();
	if (Level.LevelEnterText != "" )
		ClientMessage(Level.LevelEnterText);

	// Change by NickP: FOV fix
	if( HackedFOV != 0 )
		DefaultFOV = HackedFOV;
	// End
    DesiredFOV = DefaultFOV;

	//log("PlayerController::PostBeginPlay - FOV(DesiredFOV)");
    FOV(DesiredFOV);

	SetViewTarget(self);  // MUST have a view target!
	if ( Level.NetMode == NM_Standalone )
		AddCheats();
		
	//ErikFOV Change: Subtitle system
	GetSubtitleManager(SubtitleManager);
	//end
}

//ErikFOV Change: Subtitle system
function GetSubtitleManager(out SubtitleManager s)
{
	local SubtitleManager a;

	// Change by NickP: MP fix
	if( Level.NetMode == NM_DedicatedServer )
	{
		s = None;
		return;
	}
	// End

	foreach AllActors(class'SubtitleManager',a)
	{
		if(a != none)
		{		
			s = a;
			return;
		}
	}
	
	s = spawn(class'SubtitleManager',,,location,rotation);
	return;
}
//end

function PendingStasis()
{
	bStasis = true;
	Pawn = None;
	GotoState('Scripting');
}

function AddCheats()
{
	if ( CheatManager == None && (Level.NetMode == NM_Standalone)
		// RWS Change 02/10/03, added check
		&& CheatClass != None)
		CheatManager = new(self) CheatClass;
}

function MakeAdmin()
{
	if ( AdminManager == None && Level != None && Level.Game != None && Level.Game.AccessControl != None)
	  if (Level.Game.AccessControl.AdminClass == None)
		Log("AdminClass is None");
	  else
		AdminManager = new Level.Game.AccessControl.AdminClass;
}

function ClientSetViewTarget( Actor A )
{
	if ( A == None )
		ServerVerifyViewTarget();
    SetViewTarget( A );
}

function ServerVerifyViewTarget()
{
	if ( ViewTarget == self )
		return;

	ClientSetViewTarget(ViewTarget);
}

/* SpawnDefaultHUD()
Spawn a HUD (make sure that PlayerController always has valid HUD, even if \
ClientSetHUD() hasn't been called\
*/
function SpawnDefaultHUD()
{
	myHUD = spawn(class'HUD',self);
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	PawnDied(Pawn);
	Super.Reset();
	SetViewTarget(self);
	bBehindView = false;
	WaitDelay = Level.TimeSeconds + 2;
    // RWS CHANGE: Merged spectator check from UT2003
    if ( !PlayerReplicationInfo.bOnlySpectator )
		GotoState('PlayerWaiting');
}

// RWS CHANGE: Merged from UT2003 so it can be called from lots of places
function CleanOutSavedMoves()
{
    local SavedMove Next;

	// clean out saved moves
	while ( SavedMoves != None )
	{
		Next = SavedMoves.NextMove;
		SavedMoves.Destroy();
		SavedMoves = Next;
	}
	if ( PendingMove != None )
	{
		PendingMove.Destroy();
		PendingMove = None;
	}
}

// RWS CHANGE: Added this to clear 'within' classes which cause problems when loading saved games
event PreSaveGame()
{
	Super.PreSaveGame();
	PlayerInput = None;
	CheatManager = None;
}

// RWS CHANGE: Added this to restore what was done in PreSaveGame()
event PostSaveGame()
{
	Super.PostSaveGame();
	if ( PlayerInput == None )
		InitInputSystem();
	if ( Level.NetMode == NM_Standalone )
		AddCheats();
}

// RWS CHANGE: Added this to restore 'within' classes which cause problems when loading saved games
event PostLoadGame()
{
	Super.PostLoadGame();

	// No need to restore PlayerInput because it automatically gets done by the engine
	// when it calls InitInputSystem().

	// Restore cheat manager but only for single player games
	if ( Level.NetMode == NM_Standalone )
		AddCheats();
}

/* InitInputSystem()
Spawn the appropriate class of PlayerInput
Only called for playercontrollers that belong to local players
*/
event InitInputSystem()
{
	PlayerInput = new(self) InputClass;
}

/* ClientGotoState()
server uses this to force client into NewState
*/
function ClientGotoState(name NewState, name NewLabel)
{
	GotoState(NewState,NewLabel);
}

// RWS CHANGE: Merged new version from UT2003, this one checks for GameEnded state before it hands out a new pawn
function AskForPawn()
{
	if ( IsInState('GameEnded') )
		ClientGotoState('GameEnded', 'Begin');
	else if ( Pawn != None )
		GivePawn(Pawn);
	else
	{
		bFrozen = false;
		ServerRestartPlayer();
	}
}

function GivePawn(Pawn NewPawn)
{
	if ( NewPawn == None )
		return;
	Pawn = NewPawn;
	NewPawn.Controller = self;
	ClientRestart();
}

/* GetFacingDirection()
returns direction faced relative to movement dir
0 = forward
16384 = right
32768 = back
49152 = left
*/
function int GetFacingDirection()
{
	local vector X,Y,Z, Dir;

	GetAxes(Pawn.Rotation, X,Y,Z);
	Dir = Normal(Pawn.Acceleration);
	if ( Y Dot Dir > 0 )
		return ( 49152 + 16384 * (X Dot Dir) );
	else
		return ( 16384 - 16384 * (X Dot Dir) );
}

// Possess a pawn
function Possess(Pawn aPawn)
{
    if ( PlayerReplicationInfo.bOnlySpectator )
		return;

	SetRotation(aPawn.Rotation);
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	Pawn.bStasis = false;
    // RWS CHANGE: Merged cleaning of moves from UT2003
	CleanOutSavedMoves();  // don't replay moves previous to possession
	PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
	ServerSetHandedness(Handedness);
	Restart();
}

// unpossessed a pawn (not because pawn was killed)
function UnPossess()
{
	if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		Pawn.UnPossessed();
		// RWS CHANGE: Merged cleaning of moves from UT2003
		CleanOutSavedMoves();  // don't replay moves previous to unpossession
		if ( Viewtarget == Pawn )
			SetViewTarget(self);
	}
	Pawn = None;
	GotoState('Spectating');
}

// unpossessed a pawn (because pawn was killed)
function PawnDied(Pawn P)
{
	if ( P != Pawn )
		return;
	EndZoom();
	if ( Pawn != None )
		Pawn.RemoteRole = ROLE_SimulatedProxy;
	if ( ViewTarget == Pawn )
		bBehindView = true;

	Super.PawnDied(P);
}

/* RWS CHANGE: Removed epic's workaround for not replicating FlagHolder
simulated function ClientUpdateFlagHolder(PlayerReplicationInfo PRI, int i)
{
	if ( (Role == ROLE_Authority) || (GameReplicationInfo == None) )
		return;
	GameReplicationInfo.FlagHolder[i] = PRI;
}
*/

// RWS CHANGE: Merged udpated function from UT2003
simulated function ClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass )
{
    if ( myHUD != None )
        myHUD.Destroy();

    if (newHUDClass == None)
        myHUD = None;
    else
    {
        myHUD = spawn (newHUDClass, self);

        if (myHUD == None)
            log ("PlayerController::ClientSetHUD(): Could not spawn a HUD of class "$newHUDClass, 'Error');
        else
            myHUD.SetScoreBoardClass( newScoringClass );
    }
}

function HandlePickup(Pickup pick)
{
	ReceiveLocalizedMessage( pick.MessageClass, 0, None, None, pick.Class );
}


function ViewFlash(float DeltaTime)
{
	local vector goalFog;
	local float goalscale, delta;

	delta = FMin(0.1, DeltaTime);
	goalScale = 1 + DesiredFlashScale + ConstantGlowScale;
	goalFog = DesiredFlashFog + ConstantGlowFog;

	if ( Pawn != None )
	{
		goalScale += Pawn.HeadVolume.ViewFlash.X;
		goalFog += Pawn.HeadVolume.ViewFog;
	}

	DesiredFlashScale -= DesiredFlashScale * 2 * delta;
	DesiredFlashFog -= DesiredFlashFog * 2 * delta;
	FlashScale.X += (goalScale - FlashScale.X + InstantFlash) * 10 * delta;
	FlashFog += (goalFog - FlashFog + InstantFog) * 10 * delta;
	InstantFlash = 0;
	InstantFog = vect(0,0,0);

	if ( FlashScale.X > 0.981 )
		FlashScale.X = 1;
	FlashScale = FlashScale.X * vect(1,1,1);

	if ( FlashFog.X < 0.019 )
		FlashFog.X = 0;
	if ( FlashFog.Y < 0.019 )
		FlashFog.Y = 0;
	if ( FlashFog.Z < 0.019 )
		FlashFog.Z = 0;
}

simulated event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	// RWS CHANGE: Merged from UT2003
	if ( Message.default.bIsConsoleMessage && (Player != None) && (Player.Console != None) )
		Player.Console.Message(Message.Static.GetString(self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject),0 );
}

event ClientMessage( coerce string S, optional Name Type )
{
	if (Type == '')
		Type = 'Event';
	TeamMessage(PlayerReplicationInfo, S, Type);
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type  )
{
	// RWS CHANGE: Merged check for none from UT2003
	if ( myHUD != None )
		myHUD.Message( PRI, S, Type );

	// RWS CHANGE: Merged check for none from UT2003
    if ( ((Type == 'Say') || (Type == 'TeamSay')) && (PRI != None) )
		S = PRI.PlayerName$": "$S;

	// RWS CHANGE: Merged check before calling message from UT2003
	if ( (Player != None) && (Player.Console != None) )
		Player.Console.Message( S, 6.0 );
	if(Player != None)
		Player.InteractionMaster.Process_Message( S,6.0, Player.LocalInteractions);
}

simulated function PlayBeepSound();

//Play a sound client side (so only client will hear it
simulated function ClientPlaySound(sound ASound, optional bool bVolumeControl )
{
	ViewTarget.PlaySound(ASound, SLOT_None, 1,,,,false);
	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bVolumeControl )
{
	ClientPlaySound(ASound, bVolumeControl);
}

simulated event Destroyed()
{
	local SavedMove Next;

	// RWS CHANGE: Merged from UT2003
	// cheatmanager, adminmanager, and playerinput cleaned up in C++ PostScriptDestroyed()

	// RWS CHANGE: Merged from UT2003
	if (AdminManager != None)
		AdminManager.DoLogout();

	if ( Pawn != None )
	{
		Pawn.Health = 0;
		Pawn.Died( self, class'Suicided', Pawn.Location );
	}
	myHud.Destroy();
	myHud = None;

	//ErikFOV Change:Subtitle system
	SubtitleManager = none;
	//end
	
	while ( FreeMoves != None )
	{
		Next = FreeMoves.NextMove;
		FreeMoves.Destroy();
		FreeMoves = Next;
	}
	while ( SavedMoves != None )
	{
		Next = SavedMoves.NextMove;
		SavedMoves.Destroy();
		SavedMoves = Next;
	}
	// RWS CHANGE: Safer at end of function
	Super.Destroyed();
}

function ClientSetMusic( string NewSong, EMusicTransition NewTransition )
{
	StopAllMusic( 0.0 );
	PlayMusic( NewSong, 3.0 );
	Song        = NewSong;
	Transition  = NewTransition;
}

// ------------------------------------------------------------------------
// Zooming/FOV change functions

function ToggleZoom()
{
	if ( DefaultFOV != DesiredFOV )
		EndZoom();
	else
		StartZoom();
}

function StartZoom()
{
	ZoomLevel = 0.0;
	bZooming = true;
}

function StopZoom()
{
	bZooming = false;
}

function EndZoom()
{
	bZooming = false;
    /*
	log("EndZoom()");
	log(DefaultFOV);
	log(DesiredFOV);
    */
    DesiredFOV = DefaultFOV;
}

function FixFOV()
{
    /*
    log("FixFOV()");
    log(Default.DefaultFOV);
    log(FOVAngle);
    log(DesiredFOV);
    log(DefaultFOV);
    */
    FOVAngle = Default.DefaultFOV;
	DesiredFOV = Default.DefaultFOV;
	DefaultFOV = Default.DefaultFOV;
}

function SetFOV(float NewFOV)
{
    /*
    log("SetFOV( float"@NewFOV@")");
    log(DesiredFOV);
    log(FOVAngle);
    */
	DesiredFOV = NewFOV;
	FOVAngle = NewFOV;
}

function ResetFOV()
{
    /*
    log("ResetFOV()");
    log(DesiredFOV);
    log(FOVAngle);
    */
	DesiredFOV = DefaultFOV;
	FOVAngle = DefaultFOV;
}

// RWS CHANGE: Update player FOV when resolution changes
// We might be able to do other cool stuff with this new event...
event ChangedResolution(int NewX, int NewY, bool bFullscreen)
{
	//log("PlayerController::ChangedResolution - FOV(Default.DesiredFOV)");
	FOV(Default.DesiredFOV);
}

exec function FOV(float F)
{
    log("FOV( float"@F@")");
	if( (F >= 80.0) || (Level.Netmode==NM_Standalone) )
	{
        DefaultFOV = FClamp(F, 1, 170);
		DesiredFOV = DefaultFOV;
		HackedFOV = DefaultFOV; // Change by NickP: FOV fix
		SaveConfig();
		// We don't want to save the newly calculated FOV. That would confuse people.
		// (Why is my FOV slider changing!?)
		DefaultFOV = CalculateFOV(DefaultFOV);
		DesiredFOV = DefaultFOV;
		FOVAngle   = DefaultFOV;
	}
}

exec function SetSensitivity(float F)
{
	PlayerInput.UpdateSensitivity(F);
}

exec function ForceReload()
{
	if ( (Pawn != None) && (Pawn.Weapon != None) )
	{
		Pawn.Weapon.ForceReload();
	}
}

// Grabs current res, calculates aspect ratio, and corrects FOV with aspect ratio.
function float CalculateFOV(float FOV)
{
   local bool IsFullScreen;
   local vector Res;
   local float horizontalFOV;
   //local string CurrentRes;
   // Check if this is a start of the game/level load/etc..
   Res = GetResolution();

    /*
    log("CalculateFOV("@FOV@")");
    log("IsFullScreen is"@IsFullScreen);
    log(Res.X @ "x" @ Res.Y);
    log(ConsoleCommand("GetCurrentRes"));
    */

   //log(AspectRatio);

   horizontalFOV = ApplyAspectRatio(FOV);
	// Change by NickP: MP fix
	if(horizontalFOV == 0 )
		horizontalFOV = FOV;
	// End

   //log(horizontalFOV);

   return horizontalFOV;
}

function vector GetResolution()
{
   local bool IsFullScreen;
   local vector Res;

   //local string CurrentRes;
   // Check if this is a start of the game/level load/etc..
   if("" == (ConsoleCommand("GetCurrentRes")))
   {
        //log("Using ini for fullscreen value");
        IsFullScreen = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager StartupFullscreen"));
        //log(ConsoleCommand("GetCurrentRes"));
        //log("IsFullScreen is"@IsFullScreen);
   }
   else
   {
        // Unreliable. GetFullScreen starts at zero on level load even if they're fullscreen.
        //log("Using console command for fullscreen value");
        IsFullScreen = bool(ConsoleCommand("GetFullScreen"));
        //log(ConsoleCommand("GetCurrentRes"));
        //log("IsFullScreen is"@IsFullScreen);
   }

   if(IsFullScreen)
   {
       Res.X = float(ConsoleCommand("get ini:Engine.Engine.ViewportManager FullscreenViewportX"));
       Res.Y = float(ConsoleCommand("get ini:Engine.Engine.ViewportManager FullscreenViewportY"));
   }
   else
   {
       Res.X = float(ConsoleCommand("get ini:Engine.Engine.ViewportManager WindowedViewportX"));
       Res.Y = float(ConsoleCommand("get ini:Engine.Engine.ViewportManager WindowedViewportY"));
   }
   return Res;
}

// Takes old FOV and calculates the correct FOV based on aspect ratio.
// This would be about 4 lines, but the engine doesn't seem to be able to
// calculate math 3 brackets deep.
function float ApplyAspectRatio(float FOV)
{
    local float temp;
    local float FOVInRadians;
    local float AspectRatio;
    local vector Res;

    Res = GetResolution();

    AspectRatio = Res.X / Res.Y;

    FOVInRadians = (pi/180) * FOV;

    temp = atan(AspectRatio * (0.75) * tan( FOVInRadians / 2));
    temp = temp * 2;
    temp = (180/pi) * temp;

    return temp;
}

// Get functions for resolution calcs

// Returns nearest 4:3 resolution width.
function float GetFourByThreeResolution(optional canvas canvas)
{
    if(canvas == None)
        return FOUR_BY_THREE_ASPECT_RATIO * (GetResolution().Y);
    else
        return FOUR_BY_THREE_ASPECT_RATIO * (Canvas.ClipY);
}

// Returns nearest 4:3 resolution width.
function float GetSixteenByTenResolution(optional canvas canvas)
{
    if(canvas == None)
        return SIXTEEN_BY_TEN_ASPECT_RATIO * (GetResolution().Y);
    else
        return SIXTEEN_BY_TEN_ASPECT_RATIO * (Canvas.ClipY);
}
function float GetAspectRatio()
{
    return GetResolution().X / GetResolution().Y;
}

// ------------------------------------------------------------------------
// Messaging functions

// Send a message to all players.
exec function Say( string Msg )
{
	local controller C;

	// center print admin messages which start with #
	if (PlayerReplicationInfo.bAdmin && left(Msg,1) == "#" )
	{
		Msg = right(Msg,len(Msg)-1);
		for( C=Level.ControllerList; C!=None; C=C.nextController )
			if( C.IsA('PlayerController') )
			{
				PlayerController(C).ClearProgressMessages();
				PlayerController(C).SetProgressTime(5);
				PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(200,0,0));
			}
		return;
	}
	Level.Game.Broadcast(self, Msg, 'Say');
}

exec function TeamSay( string Msg )
{
	Level.Game.BroadcastTeam(self, Msg, 'Say');
}
// ------------------------------------------------------------------------

function ServerSetHandedness( float hand)
{
	Handedness = hand;
	if ( Pawn.Weapon != None )
		Pawn.Weapon.SetHand(Handedness);
}

function SetHand()
{
	Pawn.Weapon.SetHand(Handedness);
	ServerSetHandedness(Handedness);
}

function ChangeSetHand( string S )
{
	if ( S ~= "Left" )
		Handedness = -1;
	else if ( S~= "Right" )
		Handedness = 1;
	else if ( S ~= "Center" )
		Handedness = 0;
	else if ( S ~= "Hidden" )
		Handedness = 2;
	SetHand();
}

// RWS CHANGE: Merged from UT2003
function bool IsDead()
{
	return false;
}

event PreClientTravel()
{
}

// Event called when map change fails.
event ClientTravelFailed(string Error)
{
	// Send it on up to the menu system
	if(Player != None)
		Player.InteractionMaster.BaseMenu.GoToErrorWindow(TravelFailTitle, Error @ TravelFailText);
}

function ClientSetFixedCamera(bool B)
{
	bFixedCamera = B;
}

function ClientSetBehindView(bool B)
{
	bBehindView = B;
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	local VoicePack V;

	if ( (Sender == None) || (Sender.voicetype == None) || (Player.Console == None) )
		return;

	V = Spawn(Sender.voicetype, self);
	if ( V != None )
		V.ClientInitialize(Sender, Recipient, messagetype, messageID);
}

/* ForceDeathUpdate()
Make sure ClientAdjustPosition immediately informs client of pawn's death
*/
function ForceDeathUpdate()
{
	LastUpdateTime = Level.TimeSeconds - 10;
}

/* ShortServerMove()
compressed version of server move for bandwidth saving
*/
function ShortServerMove
(
	float TimeStamp,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	byte ClientRoll,
	int View
)
{
	ServerMove(TimeStamp,vect(0,0,0),ClientLoc,NewbRun,NewbDuck,NewbJumpStatus,DCLICK_None,ClientRoll,View);
}

/* ServerMove()
- replicated function sent by client to server - contains client movement and firing info
Passes acceleration in components so it doesn't get rounded.
*/
function ServerMove
(
	float TimeStamp,
	vector InAccel,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	eDoubleClickDir DoubleClickMove,
	byte ClientRoll,
	int View,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local rotator DeltaRot, Rot, ViewRot;
	local vector Accel, LocDiff, ClientVel, ClientFloor;
	local int maxPitch, ViewPitch, ViewYaw;
	local bool NewbPressedJump, OldbRun, OldbDuck;
	local eDoubleClickDir OldDoubleClickMove;
	local actor ClientBase;
	local ePhysics ClientPhysics;


	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if (  OldTimeDelta != 0 )
	{
		OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
		if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
		{
			// split out components of lost move (approx)
			Accel.X = OldAccel >>> 23;
			if ( Accel.X > 127 )
				Accel.X = -1 * (Accel.X - 128);
			Accel.Y = (OldAccel >>> 15) & 255;
			if ( Accel.Y > 127 )
				Accel.Y = -1 * (Accel.Y - 128);
			Accel.Z = (OldAccel >>> 7) & 255;
			if ( Accel.Z > 127 )
				Accel.Z = -1 * (Accel.Z - 128);
			Accel *= 20;

			OldbRun = ( (OldAccel & 64) != 0 );
			OldbDuck = ( (OldAccel & 32) != 0 );
			NewbPressedJump = ( (OldAccel & 16) != 0 );
			if ( NewbPressedJump )
				bJumpStatus = NewbJumpStatus;

			switch (OldAccel & 7)
			{
				case 0:
					OldDoubleClickMove = DCLICK_None;
					break;
				case 1:
					OldDoubleClickMove = DCLICK_Left;
					break;
				case 2:
					OldDoubleClickMove = DCLICK_Right;
					break;
				case 3:
					OldDoubleClickMove = DCLICK_Forward;
					break;
				case 4:
					OldDoubleClickMove = DCLICK_Back;
					break;
			}
			//log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
			MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, NewbPressedJump, OldDoubleClickMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}

	// View components
	ViewPitch = View/32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;
	// Make acceleration.
	Accel = InAccel/10;

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	ViewRot.Pitch = ViewPitch;
	ViewRot.Yaw = ViewYaw;
	ViewRot.Roll = 0;
	SetRotation(ViewRot);

	if ( Pawn != None )
	{
		Rot.Roll = 256 * ClientRoll;
		Rot.Yaw = ViewYaw;
		if ( (Pawn.Physics == PHYS_Swimming) || (Pawn.Physics == PHYS_Flying) )
			maxPitch = 2;
		else
			maxPitch = 1;
		If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
		{
			If (ViewPitch < 32768)
				Rot.Pitch = maxPitch * RotationRate.Pitch;
			else
				Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
		}
		else
			Rot.Pitch = ViewPitch;
		DeltaRot = (Rotation - Rot);
		Pawn.SetRotation(Rot);
	}

	// Perform actual movement.
	if ( (Level.Pauser == None) && (DeltaTime > 0) )
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DoubleClickMove, Accel, DeltaRot);

	// Accumulate movement error.
	if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
		ClientErr = 10000;
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
		if ( Pawn == None )
			LocDiff = Location - ClientLoc;
		else
			LocDiff = Pawn.Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
		if ( Pawn == None )
		{
			ClientPhysics = Physics;
			ClientLoc = Location;
			ClientVel = Velocity;
		}
		else
		{
			ClientPhysics = Pawn.Physics;
			ClientVel = Pawn.Velocity;
			ClientBase = Pawn.Base;
			if ( Mover(Pawn.Base) != None )
				ClientLoc = Pawn.Location - Pawn.Base.Location;
			else
				ClientLoc = Pawn.Location;
			ClientFloor = Pawn.Floor;
		}
		//log("Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
		LastUpdateTime = Level.TimeSeconds;

		if ( (Pawn == None) || (Pawn.Physics != PHYS_Spider) )
		{
			if ( ClientVel == vect(0,0,0) )
			{
				if ( IsInState('PlayerWalking') && (Pawn != None) && (Pawn.Physics == PHYS_Walking) )
				{
					VeryShortClientAdjustPosition
					(
						TimeStamp,
						ClientLoc.X,
						ClientLoc.Y,
						ClientLoc.Z,
						ClientBase
					);
				}
				else
					ShortClientAdjustPosition
					(
						TimeStamp,
						GetStateName(),
						ClientPhysics,
						ClientLoc.X,
						ClientLoc.Y,
						ClientLoc.Z,
						ClientBase
					);
			}
			else
				ClientAdjustPosition
				(
					TimeStamp,
					GetStateName(),
					ClientPhysics,
					ClientLoc.X,
					ClientLoc.Y,
					ClientLoc.Z,
					ClientVel.X,
					ClientVel.Y,
					ClientVel.Z,
					ClientBase
				);
		}
		else
			LongClientAdjustPosition
			(
				TimeStamp,
				GetStateName(),
				ClientPhysics,
				ClientLoc.X,
				ClientLoc.Y,
				ClientLoc.Z,
				ClientVel.X,
				ClientVel.Y,
				ClientVel.Z,
				ClientBase,
				ClientFloor.X,
				ClientFloor.Y,
				ClientFloor.Z
			);
	}
	//log("Server moved stamp "$TimeStamp$" location "$Pawn.Location$" Acceleration "$Pawn.Acceleration$" Velocity "$Pawn.Velocity);
}

function ProcessMove ( float DeltaTime, vector newAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
{
	if ( Pawn != None )
		Pawn.Acceleration = newAccel;
}

final function MoveAutonomous
(
	float DeltaTime,
	bool NewbRun,
	bool NewbDuck,
	bool NewbPressedJump,
	eDoubleClickDir DoubleClickMove,
	vector newAccel,
	rotator DeltaRot
)
{
	if ( NewbRun )
		bRun = 1;
	else
		bRun = 0;

	if ( NewbDuck )
		bDuck = 1;
	else
		bDuck = 0;
	bPressedJump = NewbPressedJump;

	HandleWalking();
	ProcessMove(DeltaTime, newAccel, DoubleClickMove, DeltaRot);
	if ( Pawn != None )
		Pawn.AutonomousPhysics(DeltaTime);
	else
		AutonomousPhysics(DeltaTime);
	//log("Role "$Role$" moveauto time "$100 * DeltaTime$" ("$Level.TimeDilation$")");
}

/* VeryShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed, and pawn is walking
*/
function VeryShortClientAdjustPosition
(
	float TimeStamp,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,'PlayerWalking',PHYS_Walking,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed
*/
function ShortClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ClientAdjustPosition
- pass newloc and newvel in components so they don't get rounded
*/
function ClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,NewVelX,NewVelY,NewVelZ,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* LongClientAdjustPosition
long version, when care about pawn's floor normal
*/
function LongClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase,
	float NewFloorX,
	float NewFloorY,
	float NewFloorZ
)
{
	local vector NewLocation, NewFloor;
	local Actor MoveActor;

	// RWS CHANGE: Merged new ping calculation from UT2003
	// update ping
	if ( (PlayerReplicationInfo != None) /*&& !bDemoOwner*/ )
	{
		if ( ExactPing < 0.006 )
			ExactPing = Level.TimeSeconds - TimeStamp;
		else
			ExactPing = 0.99 * ExactPing + 0.008 * (Level.TimeSeconds - TimeStamp); // placebo effect
		PlayerReplicationInfo.Ping = 1000 * ExactPing;

		if ( Level.TimeSeconds - LastPingUpdate > 4 )
		{
			/* RWS FIXME: Merge dynamic net speed stuff at some point?
			if ( bDynamicNetSpeed && (OldPing > DynamicPingThreshold * 0.001) && (ExactPing > DynamicPingThreshold * 0.001) )
			{
				if ( Player.CurrentNetSpeed > 5000 )
					SetNetSpeed(5000);
				else if ( Level.MoveRepSize < 80 )
					Level.MoveRepSize += 8;
				else if ( Player.CurrentNetSpeed > 4000 )
					SetNetSpeed(4000);
				OldPing = 0;
			}
			else*/
				OldPing = ExactPing;
			LastPingUpdate = Level.TimeSeconds;
			ServerUpdatePing(1000 * ExactPing);
		}
	}

	if ( Pawn != None )
	{
		if ( Pawn.bTearOff )
		{
			Pawn = None;
			if ( !IsInState('GameEnded') && !IsInState('Dead') )
			{
            	GotoState('Dead');
            }
			return;
		}
		MoveActor = Pawn;
        if ( (ViewTarget != Pawn)
			&& ((ViewTarget == self) || ((Pawn(ViewTarget) != None) && (Pawn(ViewTarget).Health <= 0))) )
		{
			bBehindView = false;
			SetViewTarget(Pawn);
		}
	}
	else
		MoveActor = self;

	if ( CurrentTimeStamp > TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	NewLocation.X = NewLocX;
	NewLocation.Y = NewLocY;
	NewLocation.Z = NewLocZ;
	MoveActor.Velocity.X = NewVelX;
	MoveActor.Velocity.Y = NewVelY;
	MoveActor.Velocity.Z = NewVelZ;

	NewFloor.X = NewFloorX;
	NewFloor.Y = NewFloorY;
	NewFloor.Z = NewFloorZ;
	MoveActor.SetBase(NewBase, NewFloor);
	if ( Mover(NewBase) != None )
		NewLocation += NewBase.Location;

	//log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$MoveActor.Location);
	MoveActor.bCanTeleport = false;
	MoveActor.SetLocation(NewLocation);
	MoveActor.bCanTeleport = true;
	MoveActor.SetPhysics(newPhysics);

	if( GetStateName() != newstate )
		GotoState(newstate);

	bUpdatePosition = true;
}

// RWS CHANGE: Merged new ping calculation from UT2003
function ServerUpdatePing(int NewPing)
{
	PlayerReplicationInfo.Ping = NewPing;
	PlayerReplicationInfo.bReceivedPing = true;
}

function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool bRealJump;
	local float TotalTime;

	bUpdatePosition = false;
	realbRun= bRun;
	realbDuck = bDuck;
	bRealJump = bPressedJump;
	CurrentMove = SavedMoves;
	bUpdating = true;
	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			if ( (TotalTime > 0) && (Pawn != None) )
				AdjustRadius(CurrentMove.Delta * Pawn.GroundSpeed);
			TotalTime += CurrentMove.Delta;
			MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, CurrentMove.DoubleClickMove, CurrentMove.Acceleration, rot(0,0,0));
			CurrentMove = CurrentMove.NextMove;
		}
	}
	//log("Client updated position to "$Pawn.Location);
	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	bPressedJump = bRealJump;
}

function AdjustRadius(float MaxMove)
{
	// Change by NickP: MP fix
	/*local Pawn P;
	local vector Dir;

	// if other pawn moving away from player, push it away if its close
	// since the client-side position is behind the server side position
	ForEach DynamicActors(class'Pawn', P)
		if ( (P != Pawn) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
		{
			Dir = Normal(P.Location - Pawn.Location);
			if ( (Pawn.Velocity Dot Dir > 0) && (P.Velocity Dot Dir > 0) )
			{
				if ( VSize(P.Location - Pawn.Location) < P.CollisionRadius + Pawn.CollisionRadius + MaxMove )
					P.MoveSmooth(P.Velocity * 0.5 * PlayerReplicationInfo.Ping);
			}
		}*/
	// End
}

final function SavedMove GetFreeMove()
{
	local SavedMove s, first;
	local int i;

	if ( FreeMoves == None )
	{
		// don't allow more than 30 saved moves
		For ( s=SavedMoves; s!=None; s=s.NextMove )
		{
			i++;
			if ( i > 30 )
			{
				first = SavedMoves;
				SavedMoves = SavedMoves.NextMove;
				first.Clear();
				first.NextMove = None;
				// clear out all the moves
				While ( SavedMoves != None )
				{
					s = SavedMoves;
					SavedMoves = SavedMoves.NextMove;
					s.Clear();
					s.NextMove = FreeMoves;
					FreeMoves = s;
				}
				return first;
			}
		}
		return Spawn(class'SavedMove');
	}
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		return s;
	}
}

function int CompressAccel(int C)
{
	if ( C >= 0 )
		C = Min(C, 127);
	else
		C = Min(abs(C), 127) + 128;
	return C;
}

/*
========================================================================
Here's how player movement prediction, replication and correction works in network games:

Every tick, the PlayerTick() function is called.  It calls the PlayerMove() function (which is implemented
in various states).  PlayerMove() figures out the acceleration and rotation, and then calls ProcessMove()
(for single player or listen servers), or ReplicateMove() (if its a network client).

ReplicateMove() saves the move (in the PendingMove list), calls ProcessMove(), and then replicates the move
to the server by calling the replicated function ServerMove() - passing the movement parameters, the client's
resultant position, and a timestamp.

ServerMove() is executed on the server.  It decodes the movement parameters and causes the appropriate movement
to occur.  It then looks at the resulting position and if enough time has passed since the last response, or the
position error is significant enough, the server calls ClientAdjustPosition(), a replicated function.

ClientAdjustPosition() is executed on the client.  The client sets its position to the servers version of position,
and sets the bUpdatePosition flag to true.

When PlayerTick() is called on the client again, if bUpdatePosition is true, the client will call
ClientUpdatePosition() before calling PlayerMove().  ClientUpdatePosition() replays all the moves in the pending
move list which occured after the timestamp of the move the server was adjusting.
*/

//
// Replicate this client's desired movement to the server.
//
function ReplicateMove
(
	float DeltaTime,
	vector NewAccel,
	eDoubleClickDir DoubleClickMove,
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local float OldTimeDelta, NetMoveDelta;
	local int OldAccel;
	local vector BuildAccel, AccelNorm, MoveLoc;

	// Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
		PendingMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);

	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
			if ( NewMove.bPressedJump || ((NewMove.DoubleClickMove != DCLICK_NONE) && (NewMove.DoubleClickMove < 5))
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( NewMove.bPressedJump || ((NewMove.DoubleClickMove != DCLICK_NONE) && (NewMove.DoubleClickMove < 5))
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	if ( NewMove == None )
		return;
	NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);

	// adjust radius of nearby players with uncertain location
	if ( Pawn != None )
		AdjustRadius(NewMove.Delta * Pawn.GroundSpeed);

	// Simulate the movement locally.
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);
	if ( Pawn != None )
		Pawn.AutonomousPhysics(NewMove.Delta);
	else
		AutonomousPhysics(DeltaTime);

	//log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

	// Decide whether to hold off on move
	// send if double click move, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
	NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);

	if ( !PendingMove.bPressedJump && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		// save as pending move
		return;
	}
	else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
		return;
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
		// log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23)
					+ (CompressAccel(BuildAccel.Y) << 15)
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
		if ( OldMove.bDuck )
			OldAccel += 32;
		if ( OldMove.bPressedJump )
			OldAccel += 16;
		OldAccel += OldMove.DoubleClickMove;
	}
	//else
	//	log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);
	//log("Replicate move at "$NewMove.TimeStamp$" location "$Pawn.Location);
	// Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;

	if ( Pawn == None )
		MoveLoc = Location;
	else
		MoveLoc = Pawn.Location;

	if ( (NewMove.Acceleration == vect(0,0,0)) && (NewMove.DoubleClickMove == DCLICK_None) )
		ShortServerMove
		(
			NewMove.TimeStamp,
			MoveLoc,
			NewMove.bRun,
			NewMove.bDuck,
			bJumpStatus,
			ClientRoll,
			(32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2))
		);
	else
		ServerMove
		(
			NewMove.TimeStamp,
			NewMove.Acceleration * 10,
			MoveLoc,
			NewMove.bRun,
			NewMove.bDuck,
			bJumpStatus,
			NewMove.DoubleClickMove,
			ClientRoll,
			(32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
			OldTimeDelta,
			OldAccel
		);
}

function HandleWalking()
{
	if ( Pawn != None )
		Pawn.SetWalking( (bRun != 0) && !Region.Zone.IsA('WarpZoneInfo') );
}

function ServerRestartGame()
{
}

function SetFOVAngle(float newFOV)
{
	FOVAngle = newFOV;
}

function ClientFlash( float scale, vector fog )
{
	DesiredFlashScale = scale;
	DesiredFlashFog = 0.001 * fog;
}

function ClientSetFlash(vector Scale, vector Fog)
{
	FlashScale=Scale;
	FlashFog=Fog;
}

function ClientInstantFlash( float scale, vector fog )
{
	InstantFlash = scale;
	InstantFog = 0.001 * fog;
}

function ClientAdjustGlow( float scale, vector fog )
{
	ConstantGlowScale += scale;
	ConstantGlowFog += 0.001 * fog;
}

// RWS Change 01/06/03 start. Fixes when you get hit by an explosion and
// after the shake the camera slowly moves down
// from vr. 2141
/* ShakeView()
Call this function to shake the player's view
shaketime = how long to roll view
RollMag = how far to roll view as it shakes
OffsetMag = max view offset
RollRate = how fast to roll view
OffsetRate = how fast to offset view
OffsetTime = how long to offset view (number of shakes)
*/
simulated function ShakeView(vector shRotMag,    vector shRotRate,    float shRotTime,
                   vector shOffsetMag, vector shOffsetRate, float shOffsetTime)
{
    if ( VSize(shRotMag) > VSize(ShakeRotMax) )
    {
        ShakeRotMax  = shRotMag;
        ShakeRotRate = shRotRate;
        ShakeRotTime = shRotTime * vect(1,1,1);
    }

    if ( VSize(shOffsetMag) > VSize(ShakeOffsetMax) )
    {
        ShakeOffsetMax  = shOffsetMag;
        ShakeOffsetRate = shOffsetRate;
        ShakeOffsetTime = shOffsetTime * vect(1,1,1);
    }
}

// vr. 927
/* ClientShake()
Function called on client to shake view.
Only ShakeView() should call ClientShake()
*/

private function ClientShake(vector ShakeRoll, vector OffsetMag, vector ShakeRate, float OffsetTime)
{
	/*
	if ( (MaxShakeRoll < ShakeRoll.X) || (ShakeRollTime < 0.01 * ShakeRoll.Y) )
	{
		MaxShakeRoll = ShakeRoll.X;
		ShakeRollTime = 0.01 * ShakeRoll.Y;
		ShakeRollRate = 0.01 * ShakeRoll.Z;
	}
	if ( VSize(OffsetMag) > VSize(MaxShakeOffset) )
	{
		ShakeOffsetTime = OffsetTime * vect(1,1,1);
		MaxShakeOffset = OffsetMag;
		ShakeOffsetRate = ShakeRate;
	}
	*/
	// Currently unused.. check to use the same function here as above (a client version of shakeview)
}


/* ShakeView()
Call this function to shake the player's view
shaketime = how long to roll view
RollMag = how far to roll view as it shakes
OffsetMag = max view offset
RollRate = how fast to roll view
OffsetRate = how fast to offset view
OffsetTime = how long to offset view (number of shakes)
*/
/*
function ShakeView( float shaketime, float RollMag, vector OffsetMag, float RollRate, vector OffsetRate, float OffsetTime)
{
	local vector ShakeRoll;

	ShakeRoll.X = RollMag;
	ShakeRoll.Y = 100 * shaketime;
	ShakeRoll.Z = 100 * rollrate;
	ClientShake(ShakeRoll, OffsetMag, OffsetRate, OffsetTime);
}
*/
// RWS Change 01/06/03 end

function damageAttitudeTo(pawn Other, float Damage)
{
	if ( (Other != None) && (Other != Pawn) && (Damage > 0) )
		Enemy = Other;
}

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
	if ( bTyping && (Pawn != None) && !Pawn.bTearOff )
		Pawn.ChangeAnimation();

// RWS CHANGE: No longer logged
//	if (Level.Game.StatLog != None)
//		Level.Game.StatLog.LogTypingEvent(bTyping, Self);
}

//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it

exec function Jump( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
		SetPause(False);
	else
		bPressedJump = true;
}

// Send a voice message of a certain type to a certain player.
exec function Speech( name Type, int Index, int Callsign )
{
	local VoicePack V;

	V = Spawn( PlayerReplicationInfo.VoiceType, Self );
	if (V != None)
		V.PlayerSpeech( Type, Index, Callsign );
}

exec function RestartLevel()
{
	if( Level.Netmode==NM_Standalone )
		ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function LocalTravel( string URL )
{
	if( Level.Netmode==NM_Standalone )
		ClientTravel( URL, TRAVEL_Relative, true );
}

///////////////////////////////////////////////////////////////////////////////
// Mutator commands
///////////////////////////////////////////////////////////////////////////////
exec function Mutate(coerce string Params)
{
	Level.Game.BaseMutator.Mutate(Params, Self);
}

// ------------------------------------------------------------------------
// Loading and saving

/* QuickSave()
Save game to slot 9
*/
exec function QuickSave()
{
	if ( (Pawn.Health > 0)
		&& (Level.NetMode == NM_Standalone) )
	{
		ClientMessage(QuickSaveString);
		ConsoleCommand("SaveGame 9");
	}
}

/* QuickLoad()
Load game from slot 9
*/
exec function QuickLoad()
{
	if ( Level.NetMode == NM_Standalone )
		ClientTravel( "?load=9", TRAVEL_Absolute, false);
}

/* SetPause()
 Try to pause game; returns success indicator.
 Replicated to server in network games.
 */
function bool SetPause( BOOL bPause )
{
	return Level.Game.SetPause(bPause, self);
}

/* Pause()
Command to try to pause the game.
*/
exec function Pause()
{
	// Stub out annoying message
	if( !SetPause(Level.Pauser==None) )
		//ClientMessage(NoPauseMessage);
		return;
}

// Activate specific inventory item
exec function ActivateInventoryItem( class InvItem )
{
	local Powerups Inv;

	Inv = Powerups(Pawn.FindInventoryType(InvItem));
	if ( Inv != None )
		Inv.Activate();
}

// ------------------------------------------------------------------------
// Weapon changing functions

/* ThrowWeapon()
Throw out current weapon, and switch to a new weapon
*/
// RWS Change from 2141 MP
/*
exec function ThrowWeapon()
{
	if( Level.NetMode == NM_Client )
		return;
	if( Pawn.Weapon==None || !Pawn.Weapon.bCanThrow )
		return;
	Pawn.Weapon.bTossedOut = true;
	Pawn.TossWeapon(Vector(Rotation) * 500 + vect(0,0,220));
	if ( Pawn.Weapon == None )
		SwitchToBestWeapon();
}
*/
/* ThrowWeapon()
Throw out current weapon, and switch to a new weapon
*/
exec function ThrowWeapon()
{
    if ( (Pawn == None) || (Pawn.Weapon == None) )
        return;

    ServerThrowWeapon();
}

function ServerThrowWeapon()
{
    local Vector TossVel;
	if(!Pawn.Weapon.bCanThrow )
		return;
	Pawn.Weapon.bTossedOut = true;
    TossVel = Vector(GetViewRotation());
    TossVel = TossVel * ((Pawn.Velocity Dot TossVel) + 500) + Vect(0,0,200);
	Pawn.TossWeapon(TossVel);
    ClientSwitchToBestWeapon();
/*
    if (Pawn.CanThrowWeapon())
    {
        TossVel = Vector(GetViewRotation());
        TossVel = TossVel * ((Pawn.Velocity Dot TossVel) + 500) + Vect(0,0,200);
        Pawn.TossWeapon(TossVel);
        ClientSwitchToBestWeapon();
    }
	*/
}
// end RWS Change from 2141 MP


/* PrevWeapon()
- switch to previous inventory group weapon
*/
exec function PrevWeapon()
{
	if( Level.Pauser!=None )
		return;
	if ( Pawn.Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	if ( Pawn.PendingWeapon != None )
		Pawn.PendingWeapon = Pawn.Inventory.PrevWeapon(None, Pawn.PendingWeapon);
	else
		Pawn.PendingWeapon = Pawn.Inventory.PrevWeapon(None, Pawn.Weapon);

	if ( Pawn.PendingWeapon != None )
		Pawn.Weapon.PutDown();
}

/* NextWeapon()
- switch to next inventory group weapon
*/
exec function NextWeapon()
{
	if( Level.Pauser!=None )
		return;
	if ( Pawn.Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	if ( Pawn.PendingWeapon != None )
		Pawn.PendingWeapon = Pawn.Inventory.NextWeapon(None, Pawn.PendingWeapon);
	else
		Pawn.PendingWeapon = Pawn.Inventory.NextWeapon(None, Pawn.Weapon);

	if ( Pawn.PendingWeapon != None )
		Pawn.Weapon.PutDown();
}

// The player wants to switch to weapon group number F.
exec function SwitchWeapon (byte F )
{
	local weapon newWeapon;

	if ( (Level.Pauser!=None) || (Pawn == None) || (Pawn.Inventory == None) )
		return;
	if ( (Pawn.Weapon != None) && (Pawn.Weapon.Inventory != None) )
		newWeapon = Pawn.Weapon.Inventory.WeaponChange(F);
	else
		newWeapon = None;
	if ( newWeapon == None )
		newWeapon = Pawn.Inventory.WeaponChange(F);

	if ( newWeapon == None )
		return;

	if ( Pawn.Weapon == None )
	{
		Pawn.PendingWeapon = newWeapon;
		Pawn.ChangedWeapon();
	}
	else if ( Pawn.Weapon != newWeapon )
	{
		Pawn.PendingWeapon = newWeapon;
		if ( !Pawn.Weapon.PutDown() )
			Pawn.PendingWeapon = None;
	}
}

exec function GetWeapon(class<Weapon> NewWeaponClass )
{
	local Inventory Inv;
	// RWS CHANGE: Merged bail-out code from 2110
	local int Count;

	if ( (Pawn.Inventory == None) || (NewWeaponClass == None)
		|| ((Pawn.Weapon != None) && (Pawn.Weapon.Class == NewWeaponClass)) )
		return;

	for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( Inv.Class == NewWeaponClass )
		{
			Pawn.PendingWeapon = Weapon(Inv);
			if ( !Pawn.PendingWeapon.HasAmmo() )
			{
				ClientMessage( Pawn.PendingWeapon.ItemName$Pawn.PendingWeapon.MessageNoAmmo );
				Pawn.PendingWeapon = None;
				return;
			}
			Pawn.Weapon.PutDown();
			return;
		}
		Count++;
		if ( Count > 5000 )
			return;
	}
}

// The player wants to select previous item
// Steve Polge suggested to not replicate straight exec functions, but to
// put a buffer in to make it easier to do patches in MP.
exec function PrevItem()
{
	ServerPrevItem();
}

function ServerPrevItem()
{
	local Inventory Inv;
	local Powerups LastItem;

	if ( Level.Pauser!=None )
		return;
	if (Pawn.SelectedItem==None)
	{
		Pawn.SelectedItem = Pawn.Inventory.SelectNext();
		Return;
	}
	if (Pawn.SelectedItem.Inventory!=None)
		for( Inv=Pawn.SelectedItem.Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			if (Inv==None) Break;
			if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
		}
	for( Inv=Pawn.Inventory; Inv!=Pawn.SelectedItem; Inv=Inv.Inventory )
	{
		if (Inv==None) Break;
		if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
	}
	if (LastItem!=None)
		Pawn.SelectedItem = LastItem;
}

// The player wants to active selected item
exec function ActivateItem()
{
	if( Level.Pauser!=None )
		return;
	if ( (Pawn != None) && (Pawn.SelectedItem!=None) )
		Pawn.SelectedItem.Activate();
}

// The player wants to fire.
exec function Fire( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
	if( Pawn.Weapon!=None )
		Pawn.Weapon.Fire(F);
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
	if( Pawn.Weapon!=None )
		Pawn.Weapon.AltFire(F);
}

// The player wants to use something in the level.
exec function Use()
{
	ServerUse();
}

function ServerUse()
{
	local Actor A;

	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}

	if (Pawn==None)
		return;

	// Send the 'DoUse' event to each actor player is touching.
	ForEach Pawn.TouchingActors(class'Actor', A)
	{
		A.UsedBy(Pawn);
	}
}

exec function Suicide()
{
	Pawn.KilledBy( None );
}

exec function Name( coerce string S )
{
	// RWS CHANGE: Don't allow changing names in singleplayer, it screws up load/save
	if(Level.Game != None && Level.Game.bIsSinglePlayer)
		return;
	ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
}

exec function SetName( coerce string S)
{
	// RWS CHANGE: Don't allow changing names in singleplayer, it screws up load/save
	if(Level.Game != None && Level.Game.bIsSinglePlayer)
		return;
	ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
}

function ChangeName( coerce string S )
{
	if ( Len(S) > 20 )
		S = left(S,20);
	ReplaceText(S, " ", "_");
	Level.Game.ChangeName( self, S, true );
}

exec function SwitchTeam()
{
	if ( (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 1) )
		ChangeTeam(0);
	else
		ChangeTeam(1);
}

function ChangeTeam( int N )
{
	local TeamInfo OldTeam;

	OldTeam = PlayerReplicationInfo.Team;
	Level.Game.ChangeTeam(self, N, true);
	//RWS CHANGE: Make sure there's a Pawn to kill
	if ( Pawn != None && Level.Game.bTeamGame && (PlayerReplicationInfo.Team != OldTeam) )
		Pawn.Died( None, class'DamageType', Pawn.Location );
}


exec function SwitchLevel( string URL )
{
	if( Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
		Level.ServerTravel( URL, false );
}

event function ProgressCommand(string Cmd, string Msg1, string Msg2)
{
	local string c,v;
	local int p;


	p = InStr(Cmd,":");
	c = left(Cmd,p);
	v = right(Cmd,len(Cmd)-p-1);

	if(V != "connecting" && V != "receiving")
		log("PlayerController::ProgressCommand"@Msg1@Msg2);

	if ( (C~="menu") ) // && (!Player.GUIController.bActive) )
	{
		//ClientOpenMenu(v, false, Msg1, Msg2);
		if(V~="cancel")				// Cancel pending level menu
			Player.InteractionMaster.BaseMenu.GoToErrorWindow(Msg1, Msg2);
		else if(V~="receiving")		// Receiving a file
			Player.InteractionMaster.BaseMenu.GoToConnectingWindow(Msg1, Msg2, true);
		else if(V~="connecting")	// Connecting menu
		{
			if(Level.LevelAction != LEVACT_Connecting)
				Player.InteractionMaster.BaseMenu.GoToConnectingWindow(Msg1, Msg2, false);
		}
		else if(V~="upgrade")		// Need an upgrade
			Player.InteractionMaster.BaseMenu.GoToUpgradeWindow();
		else if(V~="kick")
		{
			ConsoleCommand("disconnect");
			//ClientTravel("Entry.fuk", TRAVEL_Absolute, false);
			Player.InteractionMaster.BaseMenu.GoToErrorWindow(Msg1, Msg2, true);
		}
		else						// Error menu
			Player.InteractionMaster.BaseMenu.GoToErrorWindow(Msg1, Msg2);
	}
}

exec function ClearProgressMessages()
{
	local int i;

	for (i=0; i<ArrayCount(ProgressMessage); i++)
	{
		ProgressMessage[i] = "";
		ProgressColor[i] = class'Canvas'.Static.MakeColor(255,255,255);
	}
}

exec event SetProgressMessage( int Index, string S, color C )
{
	if ( Index < ArrayCount(ProgressMessage) )
	{
		ProgressMessage[Index] = S;
		ProgressColor[Index] = C;
	}
}

exec event SetProgressTime( float T )
{
	ProgressTimeOut = T + Level.TimeSeconds;
}

function Restart()
{
	Super.Restart();
	ServerTimeStamp = 0;
	TimeMargin = 0;
	EnterStartState();
	SetViewTarget(Pawn);
	bBehindView = Pawn.PointOfView();
	ClientRestart();
}

function EnterStartState()
{
	local name NewState;

	if ( Pawn.PhysicsVolume.bWaterVolume )
	{
		if ( Pawn.HeadVolume.bWaterVolume )
			Pawn.BreathTime = Pawn.UnderWaterTime;
		NewState = Pawn.WaterMovementState;
	}
	else
		NewState = Pawn.LandMovementState;

	if ( IsInState(NewState) )
		BeginState();
	else
		GotoState(NewState);
}

function ClientRestart()
{
	if ( (Pawn != None) && Pawn.bTearOff )
	{
		Pawn.Controller = None;
		Pawn = None;
	}
	if ( Pawn == None )
	{
		GotoState('WaitingForPawn');
		return;
	}
	Pawn.ClientRestart();
	SetViewTarget(Pawn);
	bBehindView = Pawn.PointOfView();
	// RWS CHANGE: Merged cleaning of moves from UT2003
	CleanOutSavedMoves();
	EnterStartState();
}

exec function BehindView( Bool B )
{
	if ( (Level.NetMode == NM_Standalone) || Level.Game.bAllowBehindView || PlayerReplicationInfo.bOnlySpectator ) // || bAdmin || IsA('Admin') )
	{
		bBehindView = B;
		ClientSetBehindView(bBehindView);
	}
}

//=============================================================================
// functions.

// Just changed to pendingWeapon
function ChangedWeapon()
{
	if ( Pawn.PendingWeapon != None )
		Pawn.PendingWeapon.SetHand(Handedness);
	// RWS Change for game stats
	if(Pawn.Weapon != None)
        LastPawnWeapon = Pawn.Weapon.Class;
}

event TravelPostAccept()
{
	if ( Pawn.Health <= 0 )
		Pawn.Health = Pawn.Default.Health;
}

event PlayerTick( float DeltaTime )
{
	PlayerInput.PlayerInput(DeltaTime);
	if ( bUpdatePosition )
		ClientUpdatePosition();
	PlayerMove(DeltaTime);
}

function PlayerMove(float DeltaTime);

//
/* AdjustAim()
Calls this version for player aiming help.
Aimerror not used in this version.
Only adjusts aiming at pawns
*/
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local vector FireDir, AimSpot, HitNormal, HitLocation, OldAim, AimOffset;
	local actor BestTarget;
	local float bestAim, bestDist, projspeed;
	local actor HitActor;
	local bool bNoZAdjust, bLeading;
	local rotator AimRot;

	FireDir = vector(Rotation);
	if ( FiredAmmunition.bInstantHit )
		HitActor = Trace(HitLocation, HitNormal, projStart + 10000 * FireDir, projStart, true);
	else
		HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
	if ( (HitActor != None) && HitActor.bProjTarget )
	{
		FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
		BestTarget = HitActor;
		bNoZAdjust = true;
		OldAim = HitLocation;
		BestDist = VSize(BestTarget.Location - Pawn.Location);
	}
	else
	{
		// adjust aim based on FOV
		bestAim = 0.95;
		if ( AimingHelp == 1 )
		{
			bestAim = 0.93;
			if ( FiredAmmunition.bInstantHit )
				bestAim = 0.97;
			if ( FOVAngle < DefaultFOV - 8 )
				bestAim = 0.99;
		}
		else
		{
			if ( FiredAmmunition.bInstantHit )
				bestAim = 0.98;
			if ( FOVAngle != DefaultFOV )
				bestAim = 0.995;
		}
		BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart);
		if ( BestTarget == None )
		{
			if (bBehindView)
				return Pawn.Rotation;
			else
				return Rotation;
		}
		FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
		OldAim = projStart + FireDir * bestDist;
	}
	if ( AimingHelp == 0 )
	{
		if (bBehindView)
			return Pawn.Rotation;
		else
			return Rotation;
	}

	// aim at target - help with leading also
	if ( !FiredAmmunition.bInstantHit )
	{
		projspeed = FiredAmmunition.ProjectileClass.default.speed;
		BestDist = vsize(BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart);
		bLeading = true;
		FireDir = BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
		// if splash damage weapon, try aiming at feet - trace down to find floor
		if ( FiredAmmunition.bTrySplash
			&& ((BestTarget.Velocity != vect(0,0,0)) || (BestDist > 1500)) )
		{
			HitActor = Trace(HitLocation, HitNormal, AimSpot - BestTarget.CollisionHeight * vect(0,0,2), AimSpot, false);
			if ( (HitActor != None)
				&& FastTrace(HitLocation + vect(0,0,4),projstart) )
				return rotator(HitLocation + vect(0,0,6) - projStart);
		}
	}
	else
	{
		FireDir = BestTarget.Location - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
	}
	AimOffset = AimSpot - OldAim;

	// adjust Z of shooter if necessary
	if ( bNoZAdjust || (bLeading && (Abs(AimOffset.Z) < BestTarget.CollisionHeight)) )
		AimSpot.Z = OldAim.Z;
	else if ( AimOffset.Z < 0 )
		AimSpot.Z = BestTarget.Location.Z + 0.4 * BestTarget.CollisionHeight;
	else
		AimSpot.Z = BestTarget.Location.Z - 0.7 * BestTarget.CollisionHeight;

	if ( !bLeading )
	{
		// if not leading, add slight random error ( significant at long distances )
		if ( !bNoZAdjust )
		{
			AimRot = rotator(AimSpot - projStart);
			if ( FOVAngle < DefaultFOV - 8 )
				AimRot.Yaw = AimRot.Yaw + 200 - Rand(400);
			else
				AimRot.Yaw = AimRot.Yaw + 375 - Rand(750);
			return AimRot;
		}
	}
	else if ( !FastTrace(projStart + 0.9 * bestDist * Normal(FireDir), projStart) )
	{
		FireDir = BestTarget.Location - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
	}

	return rotator(AimSpot - projStart);
}

function bool NotifyLanded(vector HitNormal)
{
	return bUpdating;
}

function eAttitude AttitudeTo(Pawn Other)
{
	if ( Other.Controller == None )
		return ATTITUDE_Ignore;
	if ( Other.IsPlayerPawn() )
		return AttitudeToPlayer;
	return Other.Controller.AttitudeToPlayer;
}

//=============================================================================
// Player Control

// Player view.
// Compute the rendering viewpoint for the player.
//

function AdjustView(float DeltaTime )
{
	// teleporters affect your FOV, so adjust it back down
	if ( FOVAngle != DesiredFOV )
	{
		if ( FOVAngle > DesiredFOV )
			FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
		else
			FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
		if ( Abs(FOVAngle - DesiredFOV) <= 10 )
			FOVAngle = DesiredFOV;
	}

	// adjust FOV for weapon zooming
	if ( bZooming )
	{
		ZoomLevel += DeltaTime * 1.0;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	}
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View;
}

function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
	// First-person view.
	CameraRotation = Rotation;
	CameraLocation = CameraLocation + Pawn.EyePosition() + ShakeOffset;
}

event AddCameraEffect(CameraEffect NewEffect,optional bool RemoveExisting)
{
	if(RemoveExisting)
		RemoveCameraEffect(NewEffect);

	CameraEffects.Length = CameraEffects.Length + 1;
	CameraEffects[CameraEffects.Length - 1] = NewEffect;
}

event RemoveCameraEffect(CameraEffect ExEffect)
{
	local int	EffectIndex;

	for(EffectIndex = 0;EffectIndex < CameraEffects.Length;EffectIndex++)
		if(CameraEffects[EffectIndex] == ExEffect)
		{
			CameraEffects.Remove(EffectIndex,1);
			return;
		}
}

exec function CreateCameraEffect(class<CameraEffect> EffectClass)
{
	AddCameraEffect(new EffectClass);
}

function rotator GetViewRotation()
{
	if ( bBehindView && (Pawn != None) )
		return Pawn.Rotation;
	return Rotation;
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;

	if ( (ViewTarget == None) || ViewTarget.bDeleteMe )
	{
		// RWS Change. Remove this comment, because the server will fail to find a
		// viewtarget after a while.
		//log("No VIEWTARGET in PlayerCalcView");
		if ( (Pawn != None) && !Pawn.bDeleteMe )
			SetViewTarget(Pawn);
		else
			SetViewTarget(self);
	}

	ViewActor = ViewTarget;
	CameraLocation = ViewTarget.Location;

	if ( ViewTarget == Pawn )
	{
		if( bBehindView ) //up and behind
			CalcBehindView(CameraLocation, CameraRotation, CameraDist * Pawn.Default.CollisionRadius);
		else
			CalcFirstPersonView( CameraLocation, CameraRotation );
		return;
	}
	if ( ViewTarget == self )
	{
		if ( bCameraPositionLocked
			// RWS Change 02/10/03, added check
			&& CheatManager != None)
			CameraRotation = CheatManager.LockedRotation;
		else
			CameraRotation = Rotation;
		return;
	}
	CameraRotation = ViewTarget.Rotation;
	PTarget = Pawn(ViewTarget);
	if ( PTarget != None )
	{
		if ( Level.NetMode == NM_Client )
		{
			if ( PTarget.IsPlayerPawn() )
			{
				PTarget.SetViewRotation(TargetViewRotation);
				CameraRotation = TargetViewRotation;
			}
			PTarget.EyeHeight = TargetEyeHeight;
			if ( PTarget.Weapon != None )
				PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
		}
		else if ( PTarget.IsPlayerPawn() )
			CameraRotation = PTarget.GetViewRotation();
		if ( !bBehindView )
			CameraLocation += PTarget.EyePosition();
	}
	if ( bBehindView )
	{
		CameraLocation = CameraLocation + (ViewTarget.Default.CollisionHeight - ViewTarget.CollisionHeight) * vect(0,0,1);
		CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
	}
}

// RWS Change 01/06/03 start. Fixes when you get hit by an explosion and
// after the shake the camera slowly moves down
// from vr. 2141
function CheckShake(out float MaxOffset, out float Offset, out float Rate, out float Time, float dt)
{
    if ( abs(Offset) < abs(MaxOffset) )
        return;

    Offset = MaxOffset;
    if ( Time > 1 )
    {
        if ( Time * abs(MaxOffset/Rate) <= 1 )
            MaxOffset = MaxOffset * (1/Time - 1);
        else
            MaxOffset *= -1;
        Time -= dt;
        Rate *= -1;
    }
    else
    {
        MaxOffset = 0;
        Offset = 0;
        Rate = 0;
    }
}

/*
function CheckShake(out float MaxOffset, out float Offset, out float Rate, out float Time)
{
	if ( abs(Offset) < abs(MaxOffset) )
		return;

	Offset = MaxOffset;
	if ( Time > 1 )
	{
		if ( Time * abs(MaxOffset/Rate) <= 1 )
			MaxOffset = MaxOffset * (1/Time - 1);
		else
			MaxOffset *= -1;
		Time -= 1;
		Rate *= -1;
	}
	else
	{
		MaxOffset = 0;
		Offset = 0;
		Rate = 0;
	}
}
*/
function UpdateShakeRotComponent(out float max, out int current, out float rate, out float time, float dt)
{
    local float fCurrent;

    current = ((current & 65535) + rate * dt) & 65535;
    if ( current > 32768 )
    current -= 65536;

    fCurrent = current;
    CheckShake(max, fCurrent, rate, time, dt);
    current = fCurrent;
}

function ViewShake(float DeltaTime)
{
    if ( ShakeOffsetRate != vect(0,0,0) )
    {
        // modify shake offset
        ShakeOffset.X += DeltaTime * ShakeOffsetRate.X;
        CheckShake(ShakeOffsetMax.X, ShakeOffset.X, ShakeOffsetRate.X, ShakeOffsetTime.X, DeltaTime);

        ShakeOffset.Y += DeltaTime * ShakeOffsetRate.Y;
        CheckShake(ShakeOffsetMax.Y, ShakeOffset.Y, ShakeOffsetRate.Y, ShakeOffsetTime.Y, DeltaTime);

        ShakeOffset.Z += DeltaTime * ShakeOffsetRate.Z;
        CheckShake(ShakeOffsetMax.Z, ShakeOffset.Z, ShakeOffsetRate.Z, ShakeOffsetTime.Z, DeltaTime);
    }

    if ( ShakeRotRate != vect(0,0,0) )
    {
        UpdateShakeRotComponent(ShakeRotMax.X, ShakeRot.Pitch, ShakeRotRate.X, ShakeRotTime.X, DeltaTime);
        UpdateShakeRotComponent(ShakeRotMax.Y, ShakeRot.Yaw,   ShakeRotRate.Y, ShakeRotTime.Y, DeltaTime);
        UpdateShakeRotComponent(ShakeRotMax.Z, ShakeRot.Roll,  ShakeRotRate.Z, ShakeRotTime.Z, DeltaTime);
    }
}
/*
vr. 927
function ViewShake(float DeltaTime)
{
	local Rotator ViewRotation;
	local float FRoll;

	if ( ShakeOffsetRate != vect(0,0,0) )
	{
		// modify shake offset
		ShakeOffset.X += DeltaTime * ShakeOffsetRate.X;
		CheckShake(MaxShakeOffset.X, ShakeOffset.X, ShakeOffsetRate.X, ShakeOffsetTime.X);

		ShakeOffset.Y += DeltaTime * ShakeOffsetRate.Y;
		CheckShake(MaxShakeOffset.Y, ShakeOffset.Y, ShakeOffsetRate.Y, ShakeOffsetTime.Y);

		ShakeOffset.Z += DeltaTime * ShakeOffsetRate.Z;
		CheckShake(MaxShakeOffset.Z, ShakeOffset.Z, ShakeOffsetRate.Z, ShakeOffsetTime.Z);
	}

	ViewRotation = Rotation;

	if ( ShakeRollRate != 0 )
	{
		ViewRotation.Roll = ((ViewRotation.Roll & 65535) + ShakeRollRate * DeltaTime) & 65535;
		if ( ViewRotation.Roll > 32768 )
			ViewRotation.Roll -= 65536;
		FRoll = ViewRotation.Roll;
		CheckShake(MaxShakeRoll, FRoll, ShakeRollRate, ShakeRollTime);
		ViewRotation.Roll = FRoll;
	}
	else if ( bZeroRoll )
		ViewRotation.Roll = 0;
	SetRotation(ViewRotation);
}
*/
// RWS Change 01/06/03 end

function bool TurnTowardNearestEnemy();

function TurnAround()
{
	if ( !bSetTurnRot )
	{
		TurnRot180 = Rotation;
		TurnRot180.Yaw += 32768;
		bSetTurnRot = true;
	}

	DesiredRotation = TurnRot180;
	bRotateToDesired = ( DesiredRotation.Yaw != Rotation.Yaw );
}

// RWS CHANGE: Merged func from UT2003
function int LimitPitch(int pitch)
{
    pitch = pitch & 65535;

    if (pitch > 18000 && pitch < 49152)
    {
        if (aLookUp > 0)
            pitch = 18000;
        else
            pitch = 49152;
    }

    return pitch;
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation, ViewRotation;

	if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
	{
		ViewShake(deltaTime);
		return;
	}
	ViewRotation = Rotation;
	DesiredRotation = ViewRotation; //save old rotation
	if ( bTurnToNearest != 0 )
		TurnTowardNearestEnemy();
	else if ( bTurn180 != 0 )
		TurnAround();
	else
	{
		TurnTarget = None;
		bRotateToDesired = false;
		bSetTurnRot = false;
		ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
		ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
	}
	// RWS CHANGE: Call func instead of doing work here
	ViewRotation.Pitch = LimitPitch(ViewRotation.Pitch);
	SetRotation(ViewRotation);

	ViewShake(deltaTime);
	ViewFlash(deltaTime);

	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;

	if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
		Pawn.FaceRotation(NewRotation, deltatime);
}

function ClearDoubleClick()
{
	if (PlayerInput != None)
		PlayerInput.DoubleClickTimer = 0.0;
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldAccel;
		local bool OldCrouch;

		// RWS CHANGE: Merged check for none from UT2003
		if ( Pawn == None )
			return;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		if ( bPressedJump )
			Pawn.DoJump(bUpdating);

		// RWS Change 07/23/03 ViewPitch brought over from 2141 to do torso twisting
        Pawn.ViewPitch = Clamp(Rotation.Pitch / 256, 0, 255);

		if ( Pawn.Physics != PHYS_Falling )
		{
			OldCrouch = Pawn.bWantsToCrouch;
			if (bDuck == 0)
				Pawn.ShouldCrouch(false);
			else if ( Pawn.bCanCrouch )
				Pawn.ShouldCrouch(true);
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local bool	bSaveJump;

		// RWS CHANGE: Merged check for none from UT2003
        if( Pawn == None )
        {
            GotoState('Dead'); // this was causing instant respawns in mp games
            return;
        }

		GetAxes(Pawn.Rotation,X,Y,Z);

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y;
		NewAccel.Z = 0;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);
		DoubleClickMove = PlayerInput.CheckForDoubleClickMove(DeltaTime);

		GroundPitch = 0;
		ViewRotation = Rotation;
		if ( Pawn.Physics == PHYS_Walking )
		{
			// tell pawn about any direction changes to give it a chance to play appropriate animation
			//if walking, look up/down stairs - unless player is rotating view
			if ( (bLook == 0)
				&& (((Pawn.Acceleration != Vect(0,0,0)) && bAlwaysLevel && bSnapToLevel) || !bKeyboardLook) )
			{
				if ( bLookUpStairs || bSnapToLevel )
				{
					GroundPitch = FindStairRotation(deltaTime);
					ViewRotation.Pitch = GroundPitch;
				}
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;
				}
			}
		}
		else
		{
			if ( !bKeyboardLook && (bLook == 0) && bCenterView )
			{
				ViewRotation.Pitch = ViewRotation.Pitch & 65535;
				if (ViewRotation.Pitch > 32768)
					ViewRotation.Pitch -= 65536;
				ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
				if ( Abs(ViewRotation.Pitch) < 1000 )
					ViewRotation.Pitch = 0;
			}
		}
		Pawn.CheckBob(DeltaTime, Y);

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{

		if ( Pawn.Mesh == None )
			Pawn.SetMesh();
		DoubleClickDir = DCLICK_None;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_Karma) // FIXME HACK!!!
			Pawn.SetPhysics(PHYS_Walking);
		GroundPitch = 0;
	}

	function EndState()
	{

		GroundPitch = 0;
		if ( Pawn != None && bDuck==0 )
		{
			Pawn.ShouldCrouch(false);
		}
	}
}

// player is climbing ladder
state PlayerClimbing
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		else
			GotoState(Pawn.LandMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;

		if ( bPressedJump )
		{
			Pawn.DoJump(bUpdating);
			if ( Pawn.Physics == PHYS_Falling )
				GotoState('PlayerWalking');
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local bool	bSaveJump;

		GetAxes(Rotation,X,Y,Z);

		// Update acceleration.
		if ( Pawn.OnLadder != None )
			NewAccel = aForward*Pawn.OnLadder.ClimbDir;
		else
			NewAccel = aForward*X + aStrafe*Y;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);

		ViewRotation = Rotation;

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
	}

	function EndState()
	{
		if ( Pawn != None )
			Pawn.ShouldCrouch(false);
	}
}

// Player movement.
// Player Driving a Karma vehicle.
state PlayerDriving
{
ignores SeePlayer, HearNoise, Bump;

    event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
    {
        local vector View, CamLookAt, HitLocation, HitNormal;
        local plane CamView;
		local KVehicle DrivenVehicle;

	    ViewActor = ViewTarget;
	    CameraLocation = ViewTarget.Location;

	    if ( ViewTarget == Pawn )
	    {
		    if( !bBehindView ) // not drawing car
            {
    		    CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
            }
		    else // drawing car (use vehicles camera position info)
            {
				DrivenVehicle = KVehicle(Pawn);
                CamView = DrivenVehicle.CamPos[DrivenVehicle.CamPosIndex];

                // Only follow vehicle rotation in 'in car' view.
                //if(DrivenVehicle.CamPosIndex == 0)
	                //CameraRotation = Rotation+ViewTarget.Rotation;
                //else
	                //CameraRotation = Rotation;

				//if(VSize(DrivenVehicle.Velocity) > 10)
				//	CameraRotation = Rotator(DrivenVehicle.Velocity);
				//else
					CameraRotation = Rotation;

	            View = CamView >> ViewTarget.Rotation;
	            CameraLocation += View;
				CamLookAt = CameraLocation;

	            View = (vect(1, 0, 0) * CamView.W) >> CameraRotation;
	            CameraLocation -= View;

				if( Trace( HitLocation, HitNormal, CameraLocation, CamLookAt, false ) != None )
				{
					CameraLocation = HitLocation;
				}
            }
		    return;
	    }
	    if ( ViewTarget == self )
	    {
		    CameraRotation = Rotation;
		    return;
	    }
	    CameraRotation = ViewTarget.Rotation;
	    if ( bBehindView )
	    {
		    CameraLocation = CameraLocation + (ViewTarget.Default.CollisionHeight - ViewTarget.CollisionHeight) * vect(0,0,1);
		    CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
	    }
    }

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{

	}

    exec function Fire(optional float F)
    {

    }

    exec function AltFire(optional float F)
    {
		local KVehicle DrivenVehicle;
		DrivenVehicle = KVehicle(Pawn);

		if(DrivenVehicle != None)
			DrivenVehicle.bLookSteer = !DrivenVehicle.bLookSteer;
    }

	function PlayerMove( float DeltaTime )
	{
		local KVehicle DrivenVehicle;
		local vector Right, Forward, Up, LookDir, LookDirInPlane;
		local float UpComp, DesYaw;


		DrivenVehicle = KVehicle(Pawn);
        if(DrivenVehicle == None)
        {
            log("PlayerDriving.PlayerMove: No Vehicle");
            return;
        }

        // check for 'jump' to throw the driver out.
        if(bPressedJump)
        {
            GotoState('PlayerWalking');
            return;
        }

		//log("Drive:"$aForward$" Steer:"$aStrafe);

        if(aForward > 1)
        {
            DrivenVehicle.Throttle = 1;
        }
        else if(aForward < -1)
        {
            DrivenVehicle.Throttle = -1;
        }
        else
        {
            DrivenVehicle.Throttle = 0;
        }

		// If we are using 'look steer' - take steering from current look vector.
		if(DrivenVehicle.bLookSteer)
		{
			GetAxes(DrivenVehicle.Rotation,Right,Forward,Up);
			LookDir = -1 * vector(Rotation);

			UpComp = LookDir Dot Up;

			//If we are looking straight up or down, don't do any steering (go straight)
			if(Abs(UpComp) > 0.98f)
			{
				DrivenVehicle.Steering = 0;
			}
			else
			{
				LookDirInPlane = Normal(LookDir - (Up * UpComp));

				DesYaw = -65535/6.2832 * Acos(FClamp(LookDirInPlane Dot Forward, -1.0, 1.0));
				if((LookDirInPlane Dot Right) > 0)
					DesYaw *= -1;

				DrivenVehicle.Steering = FClamp(DesYaw * DrivenVehicle.LookSteerSens, -1.0, 1.0);
			}
		}
		// otherwise use the strafe keys for steering.
		// TODO: Add proper follow-cam - but what does mouse do then?
		else
		{
			if(aStrafe < -1)
				DrivenVehicle.Steering = 1;
			else if(aStrafe > 1)
				DrivenVehicle.Steering = -1;
			else
				DrivenVehicle.Steering = 0;
		}

        // update 'looking' rotation - no affect on driving
		UpdateRotation(DeltaTime, 2);
	}


	function BeginState()
	{
		SetRotation(rotator( vect(0, -1, 0) >> Pawn.Rotation ));
        bBehindView = true;
		bFreeCamera = true;
	}

	function EndState()
	{
		local KVehicle DrivenVehicle;

		DrivenVehicle = KVehicle(Pawn);
        DrivenVehicle.KDriverLeave(); // execute 'Leave' event
		bBehindView = false;
		bFreeCamera = false;
	}
}

// Player movement.
// Player walking on walls
state PlayerSpidering
{
ignores SeePlayer, HearNoise, Bump;

	event bool NotifyHitWall(vector HitNormal, actor HitActor)
	{
		Pawn.SetPhysics(PHYS_Spider);
		Pawn.SetBase(HitActor, HitNormal);
		return true;
	}

	// if spider mode, update rotation based on floor
	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local rotator TempRot, ViewRotation;
		local vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

		if ( bInterpolating || Pawn.bInterpolating )
		{
			ViewShake(deltaTime);
			return;
		}

		TurnTarget = None;
		bRotateToDesired = false;
		bSetTurnRot = false;

		if ( (Pawn.Base == None) || (Pawn.Floor == vect(0,0,0)) )
			MyFloor = vect(0,0,1);
		else
			MyFloor = Pawn.Floor;

		if ( MyFloor != OldFloor )
		{
			// smoothly change floor
			RealFloor = MyFloor;
			MyFloor = Normal(6*DeltaTime * MyFloor + (1 - 6*DeltaTime) * OldFloor);
			if ( (RealFloor Dot MyFloor) > 0.999 )
				MyFloor = RealFloor;

			// translate view direction
			CrossDir = Normal(RealFloor Cross OldFloor);
			FwdDir = CrossDir Cross MyFloor;
			OldFwdDir = CrossDir Cross OldFloor;
			ViewX = MyFloor * (OldFloor Dot ViewX)
						+ CrossDir * (CrossDir Dot ViewX)
						+ FwdDir * (OldFwdDir Dot ViewX);
			ViewX = Normal(ViewX);

			ViewZ = MyFloor * (OldFloor Dot ViewZ)
						+ CrossDir * (CrossDir Dot ViewZ)
						+ FwdDir * (OldFwdDir Dot ViewZ);
			ViewZ = Normal(ViewZ);
			OldFloor = MyFloor;
			ViewY = Normal(MyFloor Cross ViewX);
		}

		if ( (aTurn != 0) || (aLookUp != 0) )
		{
			// adjust Yaw based on aTurn
			if ( aTurn != 0 )
				ViewX = Normal(ViewX + 2 * ViewY * Sin(0.0005*DeltaTime*aTurn));

			// adjust Pitch based on aLookUp
			if ( aLookUp != 0 )
			{
				OldX = ViewX;
				ViewX = Normal(ViewX + 2 * ViewZ * Sin(0.0005*DeltaTime*aLookUp));
				ViewZ = Normal(ViewX Cross ViewY);

				// bound max pitch
				if ( (ViewZ Dot MyFloor) < 0.707   )
				{
					OldX = Normal(OldX - MyFloor * (MyFloor Dot OldX));
					if ( (ViewX Dot MyFloor) > 0)
						ViewX = Normal(OldX + MyFloor);
					else
						ViewX = Normal(OldX - MyFloor);

					ViewZ = Normal(ViewX Cross ViewY);
				}
			}

			// calculate new Y axis
			ViewY = Normal(MyFloor Cross ViewX);
		}
		ViewRotation =  OrthoRotation(ViewX,ViewY,ViewZ);
		SetRotation(ViewRotation);
		ViewShake(deltaTime);
		ViewFlash(deltaTime);
		Pawn.FaceRotation(ViewRotation, deltaTime );
	}

	function bool NotifyLanded(vector HitNormal)
	{
		Pawn.SetPhysics(PHYS_Spider);
		return bUpdating;
	}

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;

		if ( bPressedJump )
			Pawn.DoJump(bUpdating);
	}

	function PlayerMove( float DeltaTime )
	{
		local vector NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local bool	bSaveJump;

		GroundPitch = 0;
		ViewRotation = Rotation;

		if ( !bKeyboardLook && (bLook == 0) && bCenterView )
		{
			// FIXME - center view rotation based on current floor
		}
		Pawn.CheckBob(DeltaTime,vect(0,0,0));

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		// Update acceleration.
		NewAccel = aForward*Normal(ViewX - OldFloor * (OldFloor Dot ViewX)) + aStrafe*ViewY;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);

		if ( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		local Rotator NewRot;

		if ( Pawn.Mesh == None )
			Pawn.SetMesh();
		OldFloor = vect(0,0,1);
		GetAxes(Rotation,ViewX,ViewY,ViewZ);
		DoubleClickDir = DCLICK_None;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		if (Pawn.Physics != PHYS_Falling)
			Pawn.SetPhysics(PHYS_Spider);
		GroundPitch = 0;
		Pawn.bCrawler = true;
		Pawn.SetCollisionSize(Pawn.Default.CollisionHeight,Pawn.Default.CollisionHeight);
	}

	function EndState()
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetCollisionSize(Pawn.Default.CollisionRadius,Pawn.Default.CollisionHeight);
			Pawn.ShouldCrouch(false);
			Pawn.bCrawler = Pawn.Default.bCrawler;
		}
	}
}

// Player movement.
// Player Swimming
state PlayerStartSwimming
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume );

	function bool WantsSmoothedView()
	{
		return ( !Pawn.bJustLanded );
	}

	function bool NotifyLanded(vector HitNormal)
	{
		if ( Pawn.PhysicsVolume.bWaterVolume )
			Pawn.SetPhysics(PHYS_Swimming);
		else
			GotoState(Pawn.LandMovementState);
		return bUpdating;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector X,Y,Z, OldAccel;

		GetAxes(Rotation,X,Y,Z);
		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		Pawn.bUpAndOut = ((X Dot Pawn.Acceleration) > 0) && ((Pawn.Acceleration.Z > 0) || (Rotation.Pitch > 2048));
		if ( !Pawn.PhysicsVolume.bWaterVolume ) //check for waterjump
			NotifyPhysicsVolumeChange(Pawn.PhysicsVolume);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;

		GetAxes(Rotation,X,Y,Z);

		NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);

		//add bobbing when swimming
		Pawn.CheckBob(DeltaTime, Y);

		// Update rotation.
		oldRotation = Rotation;
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		bPressedJump = false;
	}

	function Timer()
	{
		if ( !Pawn.PhysicsVolume.bWaterVolume && (Role == ROLE_Authority) )
			GotoState(Pawn.LandMovementState);

		Disable('Timer');
	}

	function BeginState()
	{
		Disable('Timer');
		Pawn.SetPhysics(PHYS_Swimming);
	}
	
Begin:
	// Wait just a bit before going into the full swimming state.
	// Some weirdness with NotifyPhysicsVolumeChange was causing the player to get "stuck"
	Sleep(0.25);
	GotoState('PlayerSwimming');
}
state PlayerSwimming extends PlayerStartSwimming
{
	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, checkpoint;
		
		if ( !NewVolume.bWaterVolume )
		{
			Pawn.SetPhysics(PHYS_Falling);
			if (Pawn.bUpAndOut && Pawn.CheckWaterJump(HitNormal)) //check for waterjump
			{
				Pawn.velocity.Z = FMax(Pawn.JumpZ,420) + 2 * Pawn.CollisionRadius; //set here so physics uses this for remainder of tick
				GotoState(Pawn.LandMovementState);
			}
			else if ( (Pawn.Velocity.Z > 160) || !Pawn.TouchingWaterVolume() )
				GotoState(Pawn.LandMovementState);
			else //check if in deep water
			{
				checkpoint = Pawn.Location;
				checkpoint.Z -= (Pawn.CollisionHeight + 6.0);
				HitActor = Trace(HitLocation, HitNormal, checkpoint, Pawn.Location, false);
				if (HitActor != None)
					GotoState(Pawn.LandMovementState);
				else
				{
					// Weird shit happening, go to StartSwimming and wait it out
					GotoState('PlayerStartSwimming');
					//Enable('Timer');
					//SetTimer(0.7,false);
				}
			}
		}
		else
		{
			Disable('Timer');
			Pawn.SetPhysics(PHYS_Swimming);
		}
		return false;
	}
}

state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = aForward*X + aStrafe*Y;
		if ( VSize(Pawn.Acceleration) < 1.0 )
			Pawn.Acceleration = vect(0,0,0);
		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
		// Update rotation.
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}

	function BeginState()
	{
		Pawn.SetPhysics(PHYS_Flying);
	}
}

state PlayerHelicoptering extends PlayerFlying
{
	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);
		if ( VSize(Pawn.Acceleration) < 1.0 )
			Pawn.Acceleration = vect(0,0,0);
		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
		// Update rotation.
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}
}

// RWS CHANGE: Merged from UT2003
function bool IsSpectating()
{
	return false;
}

state BaseSpectating
{
	// RWS CHANGE: Merged from UT2003
	function bool IsSpectating()
	{
		return true;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
	}
}

state Scripting
{
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
	exec function Fire( optional float F )
	{
	}

	exec function AltFire( optional float F )
	{
		Fire(F);
	}
}

function ServerViewNextPlayer()
{
	local Controller C;
	local Pawn Pick;
	local bool bFound, bRealSpec, bWasSpec;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    // RWS CHANGE: Merged from UT2003
	bWasSpec = !bBehindView && (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;

	// view next player
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.Pawn != None && Level.Game.CanSpectate(self,true,C) )
		{
			if ( Pick == None )
				Pick = C.Pawn;
			if ( bFound )
			{
				Pick = C.Pawn;
				break;
			}
			else
				bFound = ( ViewTarget == C.Pawn );
		}
	}
	SetViewTarget(Pick);
	// RWS Change: Set client view, from UT2003
    ClientSetViewTarget(Pick);
	// RWS CHANGE: Check if was spectating, from UT2003
    if ( (ViewTarget == self) || bWasSpec )
		bBehindView = false;
	else
		bBehindView = true; //bChaseCam;
    // RWS CHANGE: set client behindview too, from UT2003
	ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}

function ServerViewSelf()
{
	bBehindView = false;
	SetViewtarget(self);
// RWS Change from 2141, MP
    ClientSetViewTarget(self);
	ClientMessage(OwnCamera, 'Event');
}

state Spectating extends BaseSpectating
{
	ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
	 ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

	exec function Fire( optional float F )
	{
		bBehindView = true;
		ServerViewNextPlayer();
	}

	// Return to spectator's own camera.
	exec function AltFire( optional float F )
	{
		bBehindView = false;
		ServerViewSelf();
	}

	function BeginState()
	{
		if ( Pawn != None )
		{
			SetLocation(Pawn.Location);
			UnPossess();
		}
		bCollideWorld = true;
	}

	function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;
		bCollideWorld = false;
	}
}

auto state PlayerWaiting extends BaseSpectating
{
// RWS CHANGE: Merged ignoring of weapon functions from UT2003
ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon, SwitchToBestWeapon;

	exec function Jump( optional float F )
	{
	}

	exec function Suicide()
	{
	}

	function ChangeTeam( int N )
	{
		Level.Game.ChangeTeam(self, N, true);
	}

	function ServerRestartPlayer()
	{
		if ( Level.TimeSeconds < WaitDelay )
			return;
		if ( Level.NetMode == NM_Client )
			return;
		if ( Level.Game.bWaitingToStartMatch )
		{
			PlayerReplicationInfo.bReadyToPlay = true;
		}
		else
		{
			Level.Game.RestartPlayer(self);
		}
	}

	exec function Fire(optional float F)
	{
		ServerRestartPlayer();
	}

	exec function AltFire(optional float F)
	{
        // RWS CHANGE: Call Fire so we don't have to duplicate things for alt fire
		Fire(F);
	}

	simulated function EndState()
	{
		if ( Pawn != None )
			Pawn.SetMesh();
		if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetWaitingPlayer(false);
		bCollideWorld = false;
	}

	simulated function BeginState()
	{
		if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetWaitingPlayer(true);
		bCollideWorld = true;
		if(myHUD != None)
			myHUD.bShowScores = false;
	}
}

state WaitingForPawn extends BaseSpectating
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

	exec function Fire( optional float F )
	{
		// RWS CHANGE: Merged asking for pawn from UT2003
		AskForPawn();
	}

	exec function AltFire( optional float F )
	{
	}

	function LongClientAdjustPosition
	(
		float TimeStamp,
		name newState,
		EPhysics newPhysics,
		float NewLocX,
		float NewLocY,
		float NewLocZ,
		float NewVelX,
		float NewVelY,
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
		// RWS CHANGE: Merged going to GameEnded from UT2003
		if ( newState == 'GameEnded' )
			GotoState(newState);
	}

	function PlayerTick(float DeltaTime)
	{
		Global.PlayerTick(DeltaTime);

		if ( Pawn != None )
		{
			Pawn.Controller = self;
			ClientRestart();
		}
        // RWS CHANGE: Merged else block from UT2003
		else if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
		{
			SetTimer(0.2,true);
			AskForPawn();
		}
	}

	function Timer()
	{
		AskForPawn();
	}

	function BeginState()
	{
		SetTimer(0.2, true);
        // RWS CHANGE: Merged asking for pawn from UT2003
		AskForPawn();
	}

	function EndState()
	{
		// RWS CHANGE: Merged ending behind view from UT2003
		bBehindView = false;
		SetTimer(0.0, false);
	}
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide;

	// RWS CHANGE: Merged from UT2003
	function ServerRestartPlayer()
	{
	}

	// RWS CHANGE: Merged from UT2003
	function bool IsSpectating()
	{
		return true;
	}

	exec function ThrowWeapon()
	{
	}

	function ServerReStartGame()
	{
		Level.Game.RestartGame();
	}

	exec function Fire( optional float F )
	{
		if ( Role < ROLE_Authority)
			return;
		if ( !bFrozen )
			ServerReStartGame();
		else if ( TimerRate <= 0 )
			SetTimer(1.5, false);
	}

	exec function AltFire( optional float F )
	{
		Fire(F);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local Rotator ViewRotation;

		GetAxes(Rotation,X,Y,Z);
		// Update view rotation.

		if ( !bFixedCamera )
		{
			ViewRotation = Rotation;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			// RWS CHANGE: Call func instead of doing work here
			ViewRotation.Pitch = LimitPitch(ViewRotation.Pitch);
			SetRotation(ViewRotation);
		}
		else if ( ViewTarget != None )
			SetRotation(ViewTarget.Rotation);

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		bPressedJump = false;
	}

	function ServerMove
	(
		float TimeStamp,
		vector InAccel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
		eDoubleClickDir DoubleClickMove,
		byte ClientRoll,
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,
							DoubleClickMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)) );

	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}

		ViewRotation.Yaw = startYaw + besttry * 4096;
		SetRotation(ViewRotation);
	}

	function Timer()
	{
		bFrozen = false;
	}

	/// RWS CHANGE: Merged from UT2003
	function LongClientAdjustPosition
	(
		float TimeStamp,
		name newState,
		EPhysics newPhysics,
		float NewLocX,
		float NewLocY,
		float NewLocZ,
		float NewVelX,
		float NewVelY,
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
	}

	function BeginState()
	{
		local Pawn P;

		EndZoom();
		bFire = 0;
		bAltFire = 0;
		if ( Pawn != None
			&& Pawn.Health > 0) // RWS Change 09/05/03 Only do this to live pawns
		{
			// RWS CHANGE: Merged clearing of velocity, physics, ambient, from UT2003
			Pawn.Velocity = vect(0,0,0);
			Pawn.SetPhysics(PHYS_None);
			Pawn.AmbientSound = None;
			Pawn.SimAnim.AnimRate = 0;
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
			// RWS CHANGE: Changed actor collision to true per UT2003
			Pawn.SetCollision(true,false,false);
		}
		// RWS CHANGE: Don't show scores here (we don't want it like this and neither does UT2003)
		//myHUD.bShowScores = true;
		bFrozen = true;
		if ( !bFixedCamera )
		{
			FindGoodView();
			bBehindView = true;
		}
		// RWS CHANGE: Change from 1.5 to UT2003 setting
		SetTimer(5, false);
		SetPhysics(PHYS_None);
		// This stops all your local pawns from moving right when you stop too.
		ForEach DynamicActors(class'Pawn', P)
		{
			P.AmbientSound = None;
			P.Velocity = vect(0,0,0);
			// RWS Change 09/05/03 Only do this to live pawns
			if(P.Health > 0)
			{
				P.SetCollision(true,false,false);
				P.SetPhysics(PHYS_None);
			}
		}
	}

Begin:
}

state Dead
{
// RWS CHANGE: Merged next and prev from UT2003
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon, NextWeapon, PrevWeapon;

	function bool IsDead()
	{
		return true;
	}

	function ServerRestartPlayer()
	{
		Super.ServerRestartPlayer();
	}

	exec function Fire( optional float F )
	{
		// RWS CHANGE: Merged if block from UT2003
		if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}
		ServerRestartPlayer();
	}

	exec function AltFire( optional float F )
	{
		// RWS CHANGE: Got rid of retarded alt-fire functionality
		//if (myHUD.bShowScores)
			Fire(F);
		//else
		//	Timer();
	}

	function ServerMove
	(
		float TimeStamp,
		vector Accel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
		eDoubleClickDir DoubleClickMove,
		byte ClientRoll,
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(
					TimeStamp,
					Accel,
					ClientLoc,
					false,
					false,
					false,
					DoubleClickMove,
					ClientRoll,
					View);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local rotator ViewRotation;

		if ( !bFrozen )
		{
			if ( bPressedJump )
			{
				Fire(0);
				bPressedJump = false;
			}
			GetAxes(Rotation,X,Y,Z);
			// Update view rotation.
			ViewRotation = Rotation;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			// RWS CHANGE: Call func instead of doing work here
			ViewRotation.Pitch = LimitPitch(ViewRotation.Pitch);
			SetRotation(ViewRotation);
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
        else if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
			bFrozen = false;

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		////log("Find good death scene view");
		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			cameraLoc = ViewTarget.Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}

		ViewRotation.Yaw = startYaw + besttry * 4096;
		SetRotation(ViewRotation);
	}

	function Timer()
	{
		if (!bFrozen)
			return;

		bFrozen = false;
		// RWS CHANGE: This is now done in state code (see below)
		// myHUD.bShowScores = true;
		bPressedJump = false;
	}

	function BeginState()
	{
		Enemy = None;
		bBehindView = true;
		bFrozen = true;
		bPressedJump = false;
		FindGoodView();
        // RWS CHANGE: Shortened timer and no longer repeats, per UT2003
		SetTimer(1.0, false);
		// RWS CHANGE: Merged cleaning of moves from UT2003
		CleanOutSavedMoves();
	}

	function EndState()
	{
		// RWS CHANGE: Merged cleaning of moves from UT2003
		CleanOutSavedMoves();
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
        // RWS CHANGE: Merged check for lives from UT2003
		if ( !PlayerReplicationInfo.bOutOfLives )
			bBehindView = false;
		bPressedJump = false;
		myHUD.bShowScores = false;
	}
Begin:
    Sleep(3.0);
	myHUD.bShowScores = true;
}

//------------------------------------------------------------------------------
// ngStats Accessors
function string GetNGSecret()
{
	return ngWorldSecret;
}

function SetNGSecret(string newSecret)
{
	ngWorldSecret = newSecret;
}

//------------------------------------------------------------------------------
// Control options
function ChangeStairLook( bool B )
{
	bLookUpStairs = B;
	if ( bLookUpStairs )
		bAlwaysMouseLook = false;
}

function ChangeAlwaysMouseLook(Bool B)
{
	bAlwaysMouseLook = B;
	if ( bAlwaysMouseLook )
		bLookUpStairs = false;
}

// RWS CHANGE: Merged from UT2003
function bool CanRestartPlayer()
{
    return !PlayerReplicationInfo.bOnlySpectator;
}

// RWS CHANGE: Merged admin functions from UT2003
/////////////////////////////////////////////////////////////////////////////
// Admin Handling : Was previously in Admin.uc
//
//
//

// Execute an administrative console command on the server.
exec function Admin( string CommandLine )
{
	local string Result;

	if (AdminManager != None)
	{
    	// Do not allow get/set commands for now.  Eventually, lock them to a level

        if ( Left(CommandLine,3)~= "get" || Left(CommandLine,3)~="set" )
        	return;

		Result = ConsoleCommand( CommandLine );
		if (Level.Game.AccessControl != None && Level.Game.AccessControl.bReplyToGUI)
			AdminReply(Result);
		else if( Result!="" )
			ClientMessage( Result );
	}
}

exec function AdminLogin(string CmdLine)
{
	if (AdminManager == None)
	{
		MakeAdmin();
		ConsoleCommand("DoLogin"@CmdLine);
		if (!AdminManager.bAdmin)
			AdminManager = None;
//		else
//			AddCheats();
	}
}

function AdminCommand( string CommandLine )
{
	if (CommandLine ~= "Logged")
	{
		ReportAdmin();
	}
	else if (Left(CommandLine, 11) ~= "AdminLogin ")
	{
		AdminLogin(Mid(CommandLine, 11));
		ReportAdmin();
	}
	else if (Left(CommandLine, 11) ~= "AdminLogout")
	{
		AdminLogout();
		ReportAdmin();
	}
	else if (Level.Game.AccessControl != None)
	{
		Level.Game.AccessControl.bReplyToGUI = true;
		Admin(CommandLine);
		Level.Game.AccessControl.bReplyToGUI = false;
	}
}

function ReportAdmin()
{
	if (AdminManager != None && AdminManager.bAdmin)
	{
/* RWS CHANGE: We aren't using an admin name
		if (Level.Game.AccessControl != None)
			AdminReply(Level.Game.AccessControl.GetAdminName(Self));
		else*/
			AdminReply("Admin");
	}
	else
		AdminReply("");
}

function AdminReply( string Reply )
{
	Log("Received AdminReply: '"$Reply$"'");
/* RWS FIXME: We should figure out how to display replies in our admin menu interface
	if (Player.GUIController != None)
		Player.GUIController.OnAdminReply(Reply); */
}

exec function AdminLogout()
{
  if (AdminManager != None)
  {
	ConsoleCommand("DoLogout");
	if (!AdminManager.bAdmin)
		AdminManager = None;
  }
}

exec function AdminGUI()
{
/* RWS FIXME: Bring up our admin menu here?
	Player.GUIController.OpenMenu("AdminGUI.AdminGUIPage");*/
}

// Kamek edit - look for active SceneManager, if any.
function SceneManager GetCurrentSceneManager()
{
	local SceneManager SM;
	
	// Don't bother looking unless interpolating - save processor time
	if (bInterpolating)
	{
		foreach DynamicActors(class'SceneManager', SM)
			if (SM.Viewer == Self)
				return SM;
	}
	
	return None;
}

//ErikFOV Change: Subtitle system
event CallSubtitle(sound Sound, int index, int Actorindex, Actor A);
//end

defaultproperties
{
	 AimingHelp=0.0
     OrthoZoom=+40000.000000
     FlashScale=(X=1.000000,Y=1.000000,Z=1.000000)
	 AnnouncerVolume=4
	 FOVAngle=85.000
     DesiredFOV=85.000000
	 DefaultFOV=85.000000
     Handedness=1.000000
     bAlwaysMouseLook=True
	 ViewingFrom="Now viewing from"
	 OwnCamera="Now viewing from own camera"
     QuickSaveString="Quick Saving"
     NoPauseMessage="Game is not pauseable"
     bTravel=True
     bStasis=False
	 NetPriority=3
	 MaxTimeMargin=+1.0
	 LocalMessageClass=class'LocalMessage'
	 bIsPlayer=true
	 bCanOpenDoors=true
	 bCanDoSpecial=true
	 Physics=PHYS_None
	 EnemyTurnSpeed=45000
	 // RWS Change 02/10/03 Keep it commented out so can't be gotten around except through modifying code
	 //CheatClass=class'Engine.CheatManager'
	 InputClass=class'Engine.PlayerInput'
	 CameraDist=+9.0
	 bZeroRoll=true
	 bNeverSwitchOnPickup=true
	 TravelFailTitle="Error Loading Game or Map"
	 TravelFailText="The map or save game may depend on Steam Workshop and/or game mod resources no longer present, or your copy of POSTAL 2 may be corrupt."
}
