///////////////////////////////////////////////////////////////////////////////
// P2PlayerController.
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Postal 2 player controller
//
///////////////////////////////////////////////////////////////////////////////
class P2Player extends FPSPlayer;


///////////////////////////////////////////////////////////////////////////////
// CONST
///////////////////////////////////////////////////////////////////////////////
const DUDE_SHOUT_GET_DOWN_RADIUS	=	1800;
const GRAB_TELEPORTER_RADIUS		=	512;

const REPORT_LOOKS_SLEEP_TIME		=	1.0;

const AFTER_SPITTING_WAIT_TIME		=	1.5;

const TOSS_STUFF_VEL				=	800;

const FREEZE_TIME_AFTER_DYING		=	0.5;	// Number of seconds to freeze player after he dies
const FREEZE_TIME_AFTER_DYING_MP	=	2.0;

const RADAR_TARGET_MOVE_MOD			=	0.02;
const RADAR_TARGET_START_TIME		=	10.;
const TARGET_FRAME_TIME				=	0.5;
const TARGET_FRAME_MAX				=	2;
const TARGET_ATTACK_TIME			=	1.5;
const TARGET_WAIT_TIME				=	3.0;
const RADAR_TARGET_MAX_RADIUS		=	55;
const TARGET_RAND_WATCHX			=	0.1;
const TARGET_RAND_WATCHY			=	0.3;

const AUTO_SAVE_WAIT				=	1.0;

// map states
const MS_NO_STATE					=	0;
const MS_FADE_OUT_OF_GAME			=	1;
const MS_FADE_IN_MAP				=	2;
const MS_VIEW_MAP					=	3;
const MS_FADE_OUT_OF_MAP			=	4;
const MS_FADE_IN_GAME				=	5;

const FADE_OUT_GAME_TIME			=	0.3;
const FADE_IN_MAP_TIME				=	0.7;
const FADE_OUT_MAP_TIME				=	0.7;
const FADE_IN_GAME_TIME				=	0.3;

const FIRE_NOTHING					=	0;
const FIRE_WAITING					=	1;
const FIRE_ENDED					=	2;

const MAX_CRACK_HINTS				=	3;
const HEART_SCALE_CRACK_ADD			=	0.5;

const PLAYER_HEAD_LOD_BIAS			=	1.5;	// This is so when the camera is in 3rd person (suicide for instance)
												// the head doesn't get bad polys dropped from it.

const HURT_BAR_FADE_TIME			=	1.0;
const SKULL_FADE_TIME				=	2.0;
const DIRECTIONAL_HURT_BAR_COUNT	=	4;
const HURT_DIR_UP					=	0;
const HURT_DIR_RIGHT				=	1;
const HURT_DIR_DOWN					=	2;
const HURT_DIR_LEFT					=	3;
const HURT_DIR_SKULL				=	4;
const CENTER_DOT_HIT				=	0.8;
const MIN_DIR						=	0.35;
const SKULL_HEALTH_PERC				=   0.35;

const CATNIP_SPEED					=	5.0;
const CATNIP_START_TIME				=	60.0;

const DUAL_WIELD_TIME				=	29.9;

const CAMERA_MAX_DIST				=	10.0;// Max and min values for CameraDist. Controllable through Next/PrevWeapon
const CAMERA_MIN_DIST				=	3.0;
const CAMERA_DEAD_MAX_DIST			=	40.0;	// Uses for when he's dead and for when he's suiciding
const CAMERA_DEAD_MIN_DIST			=	3.0;
const CAMERA_ZOOM_CHANGE			=	0.5;
const CAMERA_DEAD_ZOOM_CHANGE		=	2.0;
const CAMERA_TARGET_BONE			=	'MALE01 head';
const CAMERA_MAX_LOW_SUICIDE_PITCH	=	10500;
const CAMERA_MIN_HIGH_SUICIDE_PITCH	=	45000;

const CAMERA_ROCKET_OFFSET_Z		=	10.0;
const CAMERA_ROCKET_OFFSET_X		=	-20.0;
const CAMERA_VICTIM_OFFSET_Z		=	5.0;
const CAMERA_VICTIM_OFFSET_X		=	5.0;
const WATCH_ROCKET_RESULTS_TIME		=   3.0;
const VICTIM_CAMERA_VIEW_DIST		=   15.0;

const STUCK_TIME_HINT				=	0.3;
const MAX_STUCK_TIME				=	2.0;
const STUCK_RADIUS					=	2048;
const STUCK_UNDER_MAP_DIST			=	1000.0;

const WAIT_FOR_DEATH_COMMENT_GUN	=	0.8;
const WAIT_FOR_DEATH_COMMENT_MELEE	=	0.8;
const WAIT_FOR_DEATH_COMMENT_PROJ	=	1.5;
const COMMENT_ON_RACE				=	0.4;

const CHECKMAP_HINT1_TIME			=	5;
const CHECKMAP_HINT2_TIME			=	10;
const CHECKMAP_HINT3_TIME			=	15;
const MIN_MAP_REMINDER_REFRESH		=	9.0;
const MIN_MAP_REMINDER_DEC			=	0.5;
const MAP_REMINDER_HINT_TIME		=	7.0;

const QUICK_KILL_FREQ				=	0.07;
//const QUICK_KILL_FREQ = 1.0; // FOR TESTING ONLY
const QUICK_KILL_TIME				=	16;
const QUICK_KILL_MAX				=	7;

const LAST_AI_DAMAGE_TIME			=   10.0;
const LOW_AI_DAMAGE_RATE			=   5.0;
const LOW_AI_DAMAGE_TOTAL			=	30;
const MIN_DAMAGE_RATE_TO_SHOW_HINT	=	18.0;
const DEATH_MESSAGE_MAX				=	3;
const DEATH_MESSAGE_MAX_LUDICROUS	=	6;
const DeathMessagePath				=   "Postal2Game.P2GameInfo DeathMessageUseNum"; // ini path
const PissedMeOutPath				=   "Postal2Game.P2GameInfo bPlayerPissedHimselfOut"; // ini path
const CheatsPath					=	"Postal2Game.P2GameInfoSingle bAllowCManager"; // ini path

const SNIPER_BAR_FADE				=   1.1;	// factor by which they fade out (they fade faster than they grow in)

// Persistent cheats
const QUICK_MULT					= 	10.0;

// Player dying event
const PLAYER_DIED_EVENT				= 'PlayerDied';

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

// Internal vars
var input byte
	bDeathCrawl, bCower;

var globalconfig bool	bAutoSwitchOnEmpty;		// true means it goes to the next strongest weapon on empty, false means it goes
												// back to your hands when the current weapon is empty.

var P2MocapPawn	MyPawn;				// P2MocapPawn version of Pawn inside Controller.

var input byte	bPee;				// Pee button has been pressed
var input byte	bShoutGetDown;		// GetDown button has been pressed.
var input byte  btemp;


var bool bStillTalking;				// This sound is still playing
var bool bStillYelling;				// Getting hurt sounds, urgent sounds
var bool bWaitingToTalk;			// When Timer gets called, instead of turning off bStillTalking
									// leave it on, and say your thing, then SetTimer again.
var P2Dialog.SLine DelayedSayLine;	// bWaitingToTalk will trigger this line to be said next when
									// Timer gets called next.

// These next four values are duplicated in gamestate, in order to travel them (don't
// put them in pawn, because only the player needs to use them)
// There are two seperate groups to remember the last weapon before you peed and used your hands
// because you could theoretically be using the pistol, fast switch to the hands, then decide to
// pee. So it needs to be able to go back to your hands when you unzip your pants, then go back to
// the pistol when you untoggle the 'switch to hands' button.
var int LastWeaponGroupPee;			// Last weapon group we had before changing to the urethra.
var int LastWeaponOffsetPee;		// specific weapon in the LastWeaponGroupPee we were using
var int LastWeaponGroupHands;		// Last weapon group we had before swapping to the hands.
var int LastWeaponOffsetHands;		// specific weapon in the LastWeaponGroupHands we were using

var name MyOldState;				// Next state to be in

// These next few variables are for the disguises the dude wears. Because the effects of
// each outfit is so specific, each disguise has its own entry function (like ChangeToCopClothes)
var class<Inventory> CurrentClothes;	// Inventory class of clothes we're wearing.
var class<Inventory> NewClothes;		// Clothes we're about to put on
var class<Inventory> DefaultClothes;	// Our default dude clothes class
var Texture DefaultHandsTexture;// Texture for normal dude hands

// xPatch: Textures for classic dude hands etc.
var Texture DefaultClassicHandsTexture;	
var array<Texture> AltHandsSkins;
struct ReplaceHandsSkinsStr
{
	var Texture NewSkin;	// P2 STP 
	var Texture OldSkin;	// P2 2003
};
var array<ReplaceHandsSkinsStr> ReplaceHandsSkins;
// End

var int WeaponFirstTimeFireInstance;	// If you've shot your weapon for the first time or not, sometimes comment on it

var float SayTime;					// how long a dialogue file plays for
var float SayThingsOnGuyDeathFreq;	// how often you mouth off during a death
var float SayThingsOnZombieKillFreq;	// tweak zombie kill rate (this is a FUNCTION of SayThingsOnGuyDeathFreq - if the roll for the zombie kill fails, a normal kill line is played instead)
var float SayThingsOnGuyBurningDeathFreq;	// how often you mouth off during a death from someone you torched
var float SayThingsOnWeaponFire;	// how often you mouth off while shooting for particular weapons

var FPSPawn InterestPawn;			// who I'm currently dealing with
var bool bDealingWithCashier;		// If my interest pawn is a cashier and I can pay them

var int CrackHintTimes[MAX_CRACK_HINTS];	// Array of times to tell the player that he needs more crack
									// Oth time is considered the lowest with the MAX_CRACK_HINTS-1 the highest
var float CrackDamagePercentage;	// How much the crack hurts us by, if we didn't get more in time
var float CrackStartTime;			// Time we start with till we get hurt by the crack addiction

var float CatnipUseTime;			// How long we still have to keep our cat-speed effects
var float DualWieldUseTime;			// How long we still have to keep our dual-wield effects
var bool bCheatDualWield;			// True if dual wielding cheat is on

var float TimeSinceErrandCheck;		// This is how long since the last time the player did something
									// to do with the errands--either he checked the map or went into
									// a place that has to do with errands, or something like that
									// --gets reset after he checks it.
var float TimeForMapReminder;		// This is then number of seconds that have to pass before
									// the player will be reminded to check the map to figure out what
									// errands he should do.
var float MapReminderRefresh;		// While he still waiting to check the map, wait this time
									// before you bother him again
var int	  MapReminderCount;			// Number of times you've had to tell him about checking the map
									// before he finally checks--gets reset after he checks it.

var float BodySpeed;				// Modifier for how fast you move and work your weapons (defaults to 1)

var array<AnimalPawn> AnimalFriends;// Animal who has us as our their hero

var FPSPawn.EPawnInitialState SightReaction;	// Type of reaction you inspire in NPCs when they see you. InterestVolume
									// controls this.

var bool	bCommitedSuicide;		// You intentionally died.

var float StuckTime;				// How long the player has been 'stuck'. Determined below. If they are not
									// moving in Z for too long (MAX_STUCK_TIME),
									// then warp them to the nearest good pathnode.
var float StuckCheckRadius;			// Size around which you check for pathnodes to warp to
var localized String StuckText1;	// Tells player what's happening
var localized String StuckText2;
var localized string MuggerHint1;	// Details of how to handle a mugger
var localized string MuggerHint2;
var localized string MuggerHint3;
var localized string MuggerHint4;

var localized string CopBribeHint1;	// Details on how to bribe a cop
var localized string CopBribeHint2;

var localized string CheckMapText1;	// Hints that tell the player to check the map so he can start
var localized string CheckMapText2; // doing some errands.
var localized string CheckMapText3;
var localized string CheckMapText4;

var localized string NoMoreHealthItems;	// Tells you after you do a quickhealth that you don't have anymore health
									// items to automatically use.

// The following are hints for the player that died too quickly. These are tied to the DamageTotal variables.
// The damage is calculated. If he died very quickly, then one of these groups of hints are picked to
// help him out next time.
var array<localized string>DeathHints1;
var array<localized string>DeathHints2;
var array<localized string>DeathHints3;
var array<localized string>FireDeathHints1;
var array<localized string>POSTALHints1;
var array<localized string>POSTALHints2;
var array<localized string>POSTALHints3;
var array<localized string>ImpossibleHints;
var array<localized string>LudicrousHints1;		// xPatch: New hints for new difficulty
var array<localized string>LudicrousHints1Alt;
var array<localized string>LudicrousHints2;
var array<localized string>LudicrousHints3;
var array<localized string>LudicrousHints4;
var array<localized string>LudicrousHints5;
var array<localized string>LudicrousHints6;

// Hud code
var float HeartBeatSpeed;			// How fast your heart is beating
									// The default of this value is how fast your heart beats when you're perfectly fine
var float HeartBeatSpeedAdd;		// Gets added to the base and multiplied by a ratio with your health to
									// make it beat faster the more hurt you are
var float HeartTime;				// Time used to pump the heart
var float HeartScale;				// Scale used for drawing heart (can be modified by crack)
var float HeartScaleDelta;			// Change in scale, after you start commenting on how you're addicted to crack

var bool  bShowWeaponHints;			// When the dude is getting told by a cop to drop his weapon, this is
									// set so various hints pop up in the hud to instruct the player.
var class<P2Weapon> LastWeaponSeen;// Last weapon a cop saw when they were trying to arrest me. We'll use this
								// to know if he's still hiding that same weapon or not

var bool bMuggerGoingToShoot;		// At first, use hints MuggerHint1-2, then use MuggerHint3-4 if this is true.

var Texture HudArmorIcon;			// Icon texture for type of armor we have currently.
var class<Inventory> HudArmorClass;		// Class of armor type we have on

var bool bRadarShowGuns;			// True when your radar can recognize fish with concealed weapons
var bool bRadarShowCops;			// True when your radar can recognize fish who are authority figures
var bool bUseRocketCameras;			// True means the player can view rockets he shoots

var float PlayerMoveX, PlayerMoveY;	// Used to control the rocket through the rocket camera.
									// Saves directions the player is inputting.

var rotator OldViewRotation;		// Rotation we had before the rocket took the view

var PathNode LastUnstuckPoint;		// Save the last point we warped to, after being unstuck. Don't use it
									// the very next time, to keep us from infinite unsticking--still stuck
									// scenarios.

var const localized string	HintsOnText;// Hints for how to toggle inv hints
var const localized string	HintsOffText;
// Cheats on/off
var const localized string	CheatsOnText;
var const localized string	CheatsOffText;
var const localized string	SissyOffText;

// These damage values are only for calculating how fast the AI is hurting the player. They eventually
// are put together to decide to give hints to the player. They might not be consecutive damage across
// his whole life. They can stop and start sequences if they last time he got hit was too far
// from this current time he's being hit.
var float DamageTotal;				// Total amount of damage taken from AI in this sequence
var float DamageThisHitTime;		// Level time of this current damage.
var float DamageFirstHitTime;		// Level time of first damage to start this sequence
var float DamageRate;				// damage amount over time gives rate at which AI is hurting us

// Radar for nearby people (on the hud)
enum ERadarState
{
	ERadarOff,
	ERadarBringUp,
	ERadarWarmUp,
	ERadarOn,
	ERadarCoolDown,
	ERadarDropDown
};
enum ERadarTargetState
{
	ERTargetOff,
	ERTargetWaiting,
	ERTargetPaused,
	ERTargetOn,
	ERTargetKilling1,
	ERTargetKilling2,
	ERTargetKilling3,
	ERTargetKilling4,
	ERTargetDead,
	ERTargetStatsWait,
	ERTargetStats
};
var ERadarState RadarState;			// Do a simple state system here for the radar
var float RadarSize;				// radius of radar
var float RadarShowRadius;			// radius inside which pawns are shown on radar
var float RadarScale;				// scale of pawn check radius to draw on radar radius
var float RadarMaxZ;				// farthest in z a pawn can be and still be put on radar
var float RadarBackY;				// Position of background image for radar
var array<P2Pawn> RadarPawns;		// Array of pawns picked up on radar
var byte  RadarInDoors;				// A quick, faulty test (a straight above you line check) says 1 if we're "in doors"
var float RadarTargetX;				// reticle on radar coords
var float RadarTargetY;
var float RadarTargetTimer;			// How long you have to target things
var float RadarTargetAnimTime;		// frame timer for animating the target
var int	  RadarTargetKills;			// Number of kills time around
var Sound RadarTargetMusic;			// Sound played as you target in radar.
var ERadarTargetState RadarTargetState;// What radar targetting is doing
var class<PawnShotMarker> RadarTargetHitMarker;	 // Marker tells people around the target was hit
var float HurtBarTime[6];			// If this is 0, things are up to date, if not, then the hud will show
									// a hurt bars corresponding to the HURT_DIR const'd above. This time
									// will be faded in the hud. 0 through 3 are for actual directional hurt
									// while the 4th one is for the big death skull telling you that you are
									// about dead.

var class<PawnShotMarker> SuicideStartMarker;// Tells people to freak out when you start to kill yourself
var Sound RadarClickSound;
var Sound RadarBuzzSound;
var Sound TargetAttackSounds[2];

// Screens
var transient MapScreen MyMapScreen;	// Map screen
var transient NewsScreen MyNewsScreen;	// Newspaper screen
var transient VoteScreen MyVoteScreen;	// Voting screen
var transient PickScreen MyPickScreen;	// Pick-a-dude screen
var transient LoadScreen MyLoadScreen;	// Load screen
var transient LoadScreen MyFastLoadScreen;
var transient ClothesScreen MyClothesScreen;	// screen i change my clothes in
var transient StatsScreen MyStatsScreen;	// game stats
var transient P2Screen CurrentScreen;	// The currently running screen

// Map/errand code
var bool bErrandCompleted;			// Whether an errand was completed
var Name CompletionTrigger;			// Event to trigger after errand completion

var float LastQuickSaveTime;		// Time of last quicksave
var bool bDidPrepForSave;

var bool bQuickKilling;				// You're killing bystanders quickly in succession
var float QuickKillLastTime;		// Last time since you quick killed. Must be in small time span to continue 'combo'
var int   QuickKillSoundIndex;		// Sound index we just played for when killing the last person
var P2Dialog.SLine QuickKillLine; // The array of sounds we use for quick kill lines
var Sound QuickKillGoodEndSound;	// Sound he makes when he's successfully finished quick killing
var Sound QuickKillBadEndSound;		// Sound he makes when he's unsuccessfully finished quick killing

var P2Pawn SniperAfterMe;			// Sniper that is currently aiming at me.
									// This causes black bars to indicate his direction.
var float SniperBarTime[4];			// Set each time to determine from what direction the sniper is coming
var bool bSniperBarsClear;			// If it's false, draw the bars in the hud. Can exist independent of
									// SniperAfterMe, in order to have them fade nicely
var float PulseGlow;				// How much extra, if at all, the glow on the radar shines
var float PulseGlowChange;

const RAGDOLL_FRICTION		=	0.8;
const RAGDOLL_IMPACT_MAX	=	500;
// List of karma ragdoll params that are allowed in a given game. Pawns
// who want to ragdoll must query the gameinfo for an available skeleton--they
// are not allowed to start with a skeleton themself.
var transient array<KarmaParamsSkel> RagdollSkels;
// Pawns that are using the corresponding array of skeletons
var array<FPSPawn> RagdollPawns;
var globalconfig int   RagdollMax;	// Maximum number of simulatenous ragdolls allow in the game. Though
									// it may look like a hundred dead, ragdoll bodies before you, only this
									// many can have the physics applied them at once.. this gets shifted around
									// among them as needed.

// Moved over from P2GameInfo for MP games (because no level.game exists on clients)
var() Texture			Reticles[9];			// Reticle icons for weapons
var() globalconfig Texture CustomReticle;		// Custom crosshair, another fun toy for modders
var Color				ReticleColor;			// Reticle color
var globalconfig bool	bEnableReticle;			// Used to enable/disable reticles
var globalconfig int	ReticleNum;				// Current reticle number
var globalconfig int	ReticleAlpha;			// Reticle alpha value
var globalconfig bool	ShowBlood;				// true means you get blood, false means dust--bahahahahaa
var globalconfig int    HurtBarAlpha;// Alpha level for glowy, red hurt bars that show at the
									// sides of the screen when you get hurt.
var globalconfig int    HudViewState;// If Inventory, Weapon, and health icons are visible or not
									// 0 is all is hidden, HUD_VIEW_MAX is all is present
var globalconfig bool   bWeaponBob;	// True means the view will bob as you walk
var globalconfig bool	bMpHints; // true means it shows multiplayer hints before/after a match

const HUD_VIEW_MAX				= 3;
const HudViewStatePath			= "Postal2Game.P2Player HudViewState"; // ini path

var FPSPawn		AttachedCat;	// cat attached to us

// Kill count--awtrigger in given level drives this, this part really
// just handles the hud display of it

// PL edit: we can have several of these going at once now
struct KillJob
{
	var float StartTime;		// Time we started this kill job
	var Texture HUDIcon;		// Icon to display in the HUD
	var FPSPawn BossPawn;		// If set, the kill job is for this boss pawn
	var Trigger KillTrigger;	// AWTrigger keeping track of our kills/boss health
	var float ShakeKillTime;	// Amount of time to shake kill icon for
	var int OldCount;			// for shaking hud icon
	var bool bPercentageDisplay;	// True if we want a percentage output instead of the actual numbers.
	var bool bWillow;			// True if this kill job is a health bar
	var string WillowText;		// Text to overlay over Willow style health bar
};
const SHAKE_KILL_TIME	=	1.5;

var array<KillJob> KillJobs;	// List of kill jobs we have going

// Outdated single-kill-job code
/*
var bool		bKillJob;		// You're currently doing a kill count job
var float		StartKillTime;	// Time we started current kill job
var Texture		KillPawnIcon;	// image of pawn we're killing right now for the counter
var Texture		BossPawnIcon;	// image of boss we're trying to kill
var FPSPawn		KillEnemy;		// Current enemy we're showing the health of that we want to kill
*/
var bool		bLimbSnapper;	// sledge cheat
var int			StateCount;		// generic int for states to use
var array<FPSPawn> AwFriends;	// Friends we may have
// for generic camera shakes
var vector ShakeRotMag;           // how far to rot view
var vector ShakeRotRate;          // how fast to rot view
var float  ShakeRotTime;          // how much time to rot the instigator's view
var vector ShakeOffsetMag;        // max view offset vertically
var vector ShakeOffsetRate;       // how fast to offset view vertically
var float  ShakeOffsetTime;       // how much time to offset view

var bool bCowHitButt;			// if you hit a cow in the butt already or not

// Poor excuse for dialog substitution, since we can't add any new dialog fields while extending
// from original classes. Use these arrays instead for new things to say
var array<Sound> DudeBladeKill;
var array<Sound> DudeHalloweenKill;
var array<Sound> DudeZombieKill;
var array<Sound> DudeMacheteThrow;
var array<Sound> DudeMacheteCatch;
var array<Sound> DudeButtHit;
var Sound DelayedSaySound;	// like DelayedSayLine, but the actual sound, since we're not using P2Dialog here.

var float SayThingsOnCatch;
var float SayThingsOnThrow;

const WAIT_FOR_CATCH_COMMENT	=	0.8;
const WAIT_FOR_THROW_COMMENT	=	0.8;

var byte LastStuckCheckZone;
var Vector LowestNavPoint;
var bool bNoNavPointsInZone;
var bool bIsCool;

var globalconfig bool bPlegg, bFlubber, bOldskool, bNuts, bMunch, bProtest, bRads;
var globalconfig float JoySensitivity;	// Value from 0.2 to 2.0, determines how sensitive movement is
var globalconfig float LookSensitivityX;
var globalconfig float LookSensitivityY;	// From 0.1 to 1.0.
var float LastGroundSpeed;	// Last value of GroundSpeed in PlayerMove
//var float LookAccelTimeTurn, LookAccelTimeUp;	// How long we've been holding the look axis.
var float UseaTurn, UseaLookUp;	// "Actual" values of aTurn and aLookUp
var float OldaTurn, OldaLookUp;

const WEAPONCHANGEWAIT_FIRST = 0.4;
const WEAPONCHANGEWAIT_FAST = 0.1;
var float LastWeaponChange;
var int RapidWeaponChange;
var bool bWasWalking;

var globalconfig bool bCrouchToggle;	// If true, crouch button acts as a toggle switch, not a "hold to crouch"
var byte bDuckOld;						// For checking release of bDuck
var globalconfig bool bDualWieldSwap;	// If true, switches Fire and Alt Fire while dual-wielding (and for particular weapons when not dual-wielding)

//ErikFOV Change: Subtitle system
var globalconfig bool bEnableSubtitles;
var globalconfig float SubtitlesSize;
var bool bAllowSubs;
//end

// Cutscenes seen list
var globalconfig array<String> CutscenesSeen;

// Change by NickP: MP fix
var bool bPlayerIsValid;
// End

// Added by Man Chrzan: xPatch 2.0
var globalconfig bool 	ThirdPersonView;
var() Texture			NewReticles[8];			// Reticle icons for weapons
var globalconfig int	ReticleRed;				// Reticle red value
var globalconfig int	ReticleGreen;			// Reticle green value
var globalconfig int	ReticleBlue;			// Reticle blue value
var globalconfig float 	ReticleSize;			// Reticle size value
var globalconfig int  	ReticleGroup;			// To switch between new and old rendering style ( 0 - Old, 1 - New)
var globalconfig bool  	bNoCustomCrosshairs;	// Don't allow custom crosshair
var globalconfig bool  	bHUDCrosshair;			// Draw crosshair with HUD

var bool bForceCrosshair; 	// Forces crosshair to be shown (for settings menu)
var bool bForceViewmodel; 	// Forces viewmodel to be shown (for settings menu)

///////////////////////////////////////////////////////////////////////////////
// Replication
///////////////////////////////////////////////////////////////////////////////
replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) && bNetOwner )
		HudArmorIcon;

	reliable if( bNetDirty && Role==ROLE_Authority)
		MyPawn;

	// server sends this to client
	reliable if(Role == ROLE_Authority)
		ClientHurtBars, ClientShakeView;

	// Client sends this to server
	reliable if(Role < ROLE_Authority)
		ServerPerformSuicide, ServerCancelSuicide, HandleStuckPlayer, NextInvItem,
		QuickHealth, ServerThrowPowerup,
		ServerGetDown, ServerAneurism;

	// Change by NickP: MP fix
	reliable if( Role == ROLE_Authority )
		ClientSwitchToHands;
	reliable if(Role < ROLE_Authority)
		ServerOnSelectedItem;
	// End
}

// For testing
exec function dumpinv()
{
	local string s;
	local Inventory inv;

	if (!DebugEnabled())
		return;

	for (inv = Pawn.Inventory; inv != None; inv = inv.Inventory)
		s = s @ inv;

	ClientMessage(S);
}

// Also for testing
exec function Aspect(float Aspect)
{
	local float X, Y;
	
	//Y = 900.f;
	//X = Y * Aspect;
	X = 1600.f;
	Y = X / Aspect;
	while (Y > 900)
	{
		X *= 0.9;
		Y *= 0.9;
	}
	ConsoleCommand("SETRES"@Int(X)$"x"$Int(Y));
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AW backports Kamek
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

function ContraCode();

///////////////////////////////////////////////////////////////////////////////
// Add new kill job, returns index of kill job
///////////////////////////////////////////////////////////////////////////////
function int AddKillJob(Texture UseIcon, optional name EnemyTag, optional name TriggerTag, optional bool bPercentageDisplay, optional bool bWillow, optional string WillowText)
{
	local int i;
	local FPSPawn Boss;
	local Trigger AWTrig;

	// Make sure kill counter doesn't exist already
	for (i = 0; i < KillJobs.Length; i++)
		// If this job has a boss pawn or kill trigger matching the input tag, abort
		if ((KillJobs[i].BossPawn != None && KillJobs[i].BossPawn.Tag == EnemyTag)
			|| (KillJobs[i].KillTrigger != None && KillJobs[i].KillTrigger.Tag == TriggerTag))
			return -1;
			
	if (EnemyTag != '')
	{
		// Find the boss we're fighting
		foreach DynamicActors(class'FPSPawn', Boss, EnemyTag)
			break;
			
		if (Boss == None)
		{
			warn("In AddKillJob, no boss with tag"@EnemyTag);
			return -1;
		}
	}
	else if (TriggerTag != '')
	{
		// Find the AWTrigger we're counting
		foreach DynamicActors(class'Trigger', AWTrig, TriggerTag)
			if (AWTrig.IsA('AWTrigger'))
				break;
				
		if (AWTrig == None
			|| !AWTrig.IsA('AWTrigger'))
		{
			warn("In AddKillJob, no AWTrigger with tag"@TriggerTag);
			return -1;
		}		
	}
	else
	{
		// Some idiot forgot to give us a tag at all. Probably me.
		warn("In AddKillJob, no boss or trigger tag specified");
		return -1;
	}
			
	KillJobs.Insert(KillJobs.Length, 1);
	i = KillJobs.Length - 1;
	
	KillJobs[i].StartTime = Level.TimeSeconds;
	KillJobs[i].HUDIcon = UseIcon;
	if (Boss != None)
		KillJobs[i].BossPawn = Boss;
	if (AWTrig != None)
		KillJobs[i].KillTrigger = AWTrig;
	KillJobs[i].bPercentageDisplay = bPercentageDisplay;
	KillJobs[i].bWillow = bWillow;
	KillJobs[i].WillowText = WillowText;
		
	return i;
}

///////////////////////////////////////////////////////////////////////////////
// Remove kill job, either by matching tag or index number
// Returns true if removed successfully, false if not.
///////////////////////////////////////////////////////////////////////////////
function bool RemoveKillJob(name MatchTag, optional int RemoveMe)
{
	local int i, removed;
	
	removed = -1;

	if (MatchTag != '')
	{
		for (i = 0; i < KillJobs.Length; i++)
			if ((KillJobs[i].BossPawn != None
				&& KillJobs[i].BossPawn.Tag == MatchTag)
				|| (KillJobs[i].KillTrigger != None
					&& KillJobs[i].KillTrigger.Tag == MatchTag))
			{
				removed = i;
				break;
			}
	}
	else if (RemoveMe < KillJobs.Length)
		removed = RemoveMe;
	
	// Didn't remove nothin'
	if (removed == -1)
		return false;
	else
	{
		// Do the removal
		KillJobs.Remove(removed, 1);
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Look at trigger/boss and tell HUD the values.
///////////////////////////////////////////////////////////////////////////////
function GetKillJobValues(int Index, out int UseCount, out int UseMax, out int bPercentageDisplay);
	// STUB -- filled out in DudePlayer.

///////////////////////////////////////////////////////////////////////////////
// Look at trigger and tell hud what we still need to do
///////////////////////////////////////////////////////////////////////////////
function GetKillCountVals(out int UseMax, out int UseCount)
{
	// STUB filled out in dudeplayer
}
///////////////////////////////////////////////////////////////////////////////
// Look at boss enemy your fighting and return health to hud
///////////////////////////////////////////////////////////////////////////////
function GetBossVals(out int UseMax, out int UseCount)
{
	// STUB, no longer used.
	
	/*
	if(KillEnemy != None)
	{
		UseMax = KillEnemy.HealthMax;
		UseCount = KillEnemy.Health;
		// As soon as we know he's dead, remove everything
		if(UseCount <= 0)
		{
			FinishBossFight();
		}
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Done fighting this guy
///////////////////////////////////////////////////////////////////////////////
function FinishBossFight()
{
	// STUB no longer used
	
	/*
	bKillJob=false;
	P2Hud(MyHud).BossIcon = None;
	BossPawnIcon = None;
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Generic shake of player's view
///////////////////////////////////////////////////////////////////////////////
function BigShake()
{
	ShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime,
		ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RaisedZombie()
{
	// You know you shouldn't have done that
	DelayedSayLine = MyPawn.myDialog.lDude_CantBeGood;
	bWaitingToTalk=true;
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// Add a friend
///////////////////////////////////////////////////////////////////////////////
function AddAWFriend(FPSPawn newfriend)
{
	local int i;
	local bool bDontAdd;

	//log(self$" AddAnimalFriend "$newfriend);
	// Make sure he's not already in the list
	for(i=0; i<AwFriends.Length; i++)
	{
		if(AwFriends[i] == newfriend)
		{
			//log(self$" already here ");
			bDontAdd=true;
		}
	}

	if(!bDontAdd)
	{
		i = AwFriends.Length;
		AwFriends.Insert(i, 1);
		AwFriends[i] = newfriend;
		//log(self$" new animal friend! "$newfriend$" at "$i);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Remove a friend
///////////////////////////////////////////////////////////////////////////////
function RemoveAWFriend(FPSPawn newfriend)
{
	local int i;
	local bool bDontAdd;

	//log(self$" RemoveAnimalFriend "$newfriend);
	// Make sure he's there to be removed
	for(i=0; i<AwFriends.Length; i++)
	{
		if(AwFriends[i] == newfriend)
		{
			//log(self$" found him.. removing ");
			AwFriends.Remove(i, 1);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check if this pawn is a player friend
///////////////////////////////////////////////////////////////////////////////
function bool IsAWFriend(FPSPawn cfriend)
{
	local int i;

	// Make sure he's not already in the list
	for(i=0; i<AwFriends.Length; i++)
	{
		if(AwFriends[i] == cfriend)
			return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Say something
///////////////////////////////////////////////////////////////////////////////
function bool SayCustomLine(Sound SayMe)
{
	if(!bStillTalking)
	{
		SayTime = 0;
		DelayedSaySound = SayMe;
		SayTime = GetSoundDuration(SayMe);
		bWaitingToTalk=true;

		if(SayTime > 0
			|| bWaitingToTalk)
		{
			SetTimer(SayTime, false);
			bStillTalking=true;
		}

		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// CaughtMachete
///////////////////////////////////////////////////////////////////////////////
function CaughtMachete()
{
	if(!bStillTalking)
	{
		SayTime = 0;
		if(FRand() <= SayThingsOnCatch)
		{
			DelayedSaySound = DudeMacheteCatch[Rand(DudeMacheteCatch.Length)];
			SayTime = WAIT_FOR_CATCH_COMMENT;
			bWaitingToTalk=true;
		}
		if(SayTime > 0
			|| bWaitingToTalk)
		{
			SetTimer(SayTime, false);
			bStillTalking=true;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// ThrowMachete
///////////////////////////////////////////////////////////////////////////////
function ThrowMachete()
{
	if(!bStillTalking)
	{
		SayTime = 0;
		if(FRand() <= SayThingsOnThrow)
		{
			DelayedSaySound = DudeMacheteThrow[Rand(DudeMacheteThrow.Length)];
			SayTime = WAIT_FOR_THROW_COMMENT;
			bWaitingToTalk=true;
		}
		if(SayTime > 0
			|| bWaitingToTalk)
		{
			SetTimer(SayTime, false);
			bStillTalking=true;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool DoGaryPowers(optional bool bTravelRevive)
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function HeadAdded()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function HeadRemoved()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Say a line for when you get a sledge in a cow's butt
///////////////////////////////////////////////////////////////////////////////
function CowButtHit()
{
	GotoState('PlayerHitCowButtWithSledge');
}

///////////////////////////////////////////////////////////////////////////////
// End AW backports
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Possess a pawn
///////////////////////////////////////////////////////////////////////////////
function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);

	//log(self$" P2Player.Possess(): possessed pawn "$aPawn$" current mypawn "$MyPawn);

	MyPawn = P2MocapPawn(Pawn);
	if(MyPawn == None)
		Warn("P2Player.Possess(): Error! MyPawn is None");
	else
		SetHeartBeatBasedOnHealth();	// get the beating correct

	// Make sure player characters never try for a stasis
	MyPawn.TimeTillStasis=0;
	MyPawn.StartTimeTillStasis=0;
	MyPawn.bAllowStasis=false;
	MyPawn.bPlayer=true;
	MyPawn.bKeepForMovie=true;
	//mypawnfix
	Pawn.SetCollision(true, true, true);
	MyPawn.MyHead.LODBias=PLAYER_HEAD_LOD_BIAS;

	// If we already have a weapon and it's not doing anything, make it idle
	if(Pawn.Weapon != None
		&& !Pawn.Weapon.bDeleteMe
		&& Pawn.Weapon.GetStateName() == Pawn.Weapon.Tag)
		Pawn.Weapon.GotoState('Idle');

	StuckCheckRadius = STUCK_RADIUS;

	// Restore any time dilation effects
	SetupCatnipUseage(CatnipUseTime);
	
	// Restore any dual-wield effects
	SetupDualWielding(DualWieldUseTime);

	SetupScreens();

	// If server, it will set up the pawns after they login. So instead of
	// travel post accept doing it, let's finish up the pawn here.
	if(Role == ROLE_Authority
		&& (Level.Game == None
			|| !FPSGameInfo(Level.Game).bIsSinglePlayer))
	{
		P2Pawn(Pawn).PlayerStartingFinished();
		//log(self$" Possess, server finished setting up pawn");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Unpossess the pawn
///////////////////////////////////////////////////////////////////////////////
function UnPossess()
{
	Super.UnPossess();

	//log(self$" P2Player.UnPossess(): unpossessed pawn, current mypawn"$MyPawn);

	// Set normal time, if you're leaving the player (in case a movie)
	// is playing now.
	P2GameInfoSingle(Level.Game).SetGameSpeedNoSave(1.0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Make your ragdolls here
	if(Level.NetMode != NM_DedicatedServer)
	{
		InitRagdollSkels(RagdollMax);
	}

	/*
	// Linux achievement
	if (PlatformIsUnix())
	{
		//log(self@"running on Linux. Hooray! :)");
		GetEntryLevel().EvaluateAchievement(Self, 'LinuxAchievement');
	}
	//else if (PlatformIsMacOS())
		//log(self@"running on Mac. No achievement awarded :(");
	//else if (PlatformIsWindows())
		//log(self@"running on Windows. No achievement awarded :(");
	*/
	
	//ErikFOV Change: Subtitle system
	if(SubtitleManager != none && SubtitleManager.SubSound.length > 0)
	bAllowSubs = true;
	//end
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	MyPawn = None;
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// For each group of karma ragdoll skeletons we'll use for the different groups,
// allocate the space for them, and fill in initial values.
///////////////////////////////////////////////////////////////////////////////
simulated function InitRagdollSkels(int max)
{
	local int i;

	//log(self$" InitRagdollSkels "$max);
	// Clear out any possible old params (shouldn't be any)
	if(RagdollSkels.Length > 0)
		RagdollSkels.Remove(0, RagdollSkels.Length);
	if(RagdollPawns.Length > 0)
		RagdollPawns.Remove(0, RagdollPawns.Length);

	// allocate skeletons and pawn slots
	RagdollSkels.Insert(0, max);
	RagdollPawns.Insert(0, max);

	// Fill in karma information
	for(i=0; i<RagdollSkels.Length; i++)
	{
		RagdollSkels[i] = new(None) class'KarmaParamsSkel';
		//log(self$" getting skel "$i$" after "$RagdollSkels[i]);
		if(RagdollSkels[i] == None)
			warn(self$" ERROR::InitRagdollSkels, KarmaParamsSkel not allocated!");
		RagdollSkels[i].KFriction=RAGDOLL_FRICTION;
		RagdollSkels[i].KImpactThreshold=RAGDOLL_IMPACT_MAX;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Given a skel group,
///////////////////////////////////////////////////////////////////////////////
simulated function KarmaParamsSkel GetNewRagdollSkel(FPSPawn NewPawn, name skelname)
{
	local int i;
	local bool bEmpty;

	//log(self$" GetNewRagdollSkel called by "$NewPawn$" length "$RagdollPawns.Length);
	
	// If we have ragdolls turned off don't assign one
	if (P2GameInfoSingle(Level.Game) != None && P2GameInfoSingle(Level.Game).bForbidRagdolls)
		return None;
		
	for(i=0; i<RagdollPawns.Length; i++)
	{
		if(RagdollPawns[i] == None)
			bEmpty=true;

		if(bEmpty
			|| RagdollPawns[i].FinishedWithRagdoll())
		{
			// Freeze the ragdoll in it's last position
			if(!bEmpty)
			{
				RagdollPawns[i].UnhookRagdoll();
			}
			// Save the new pawn
			RagdollPawns[i] = NewPawn;
			// Record the time we started using the ragdoll
			RagdollPawns[i].RagDollStartTime = Level.TimeSeconds;
			RagdollSkels[i].KSkeleton = skelname;
			//log(self$" success with "$RagdollSkels[i]);
			// Return his new ragdoll skeleton
			return RagdollSkels[i];
		}

	}
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// Have pawn undo his karma, if he's destroyed instantly.
///////////////////////////////////////////////////////////////////////////////
simulated function GiveBackRagdollSkel(FPSPawn CheckPawn)
{
	local int i;

	//log(self$" GiveBackRagdollSkel called by "$CheckPawn);
	for(i=0; i<RagdollPawns.Length; i++)
	{
		if(RagdollPawns[i] == CheckPawn)
		{
			//log(self$" unhooking from "$CheckPawn$" at "$i);
			RagdollPawns[i]=None;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get current reticle index
///////////////////////////////////////////////////////////////////////////////
simulated function Texture GetReticleTexture()
	{
	if (bEnableReticle)
	{
		if (CustomReticle != None 
			&& !bNoCustomCrosshairs)
			return CustomReticle;
		if(ReticleGroup == 0)
			return Reticles[ReticleNum];
		else
			return NewReticles[ReticleNum];
	}
	return None;
	}

simulated function Color GetReticleColor()
	{
	ReticleColor.A = ReticleAlpha;
	ReticleColor.R = 255;
	ReticleColor.G = 255;
	ReticleColor.B = 255;
	return ReticleColor;
	}

// Can't edit old function without causing bugs with old mods so here's new one.
simulated function Color GetReticleColor2()
	{
	ReticleColor.A = ReticleAlpha;
	ReticleColor.R = ReticleRed;
	ReticleColor.G = ReticleGreen;
	ReticleColor.B = ReticleBlue;
	return ReticleColor;
	}
	
simulated function bool IsCustomReticle()
	{
		if (CustomReticle != None)
			return true;
		else
			return false;
	}

///////////////////////////////////////////////////////////////////////////////
// True, you get blood, false, you suck
///////////////////////////////////////////////////////////////////////////////
static function bool BloodMode()
{
	//log(" checking blood mode ");
	if(default.ShowBlood)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Add a friend
///////////////////////////////////////////////////////////////////////////////
function AddAnimalFriend(AnimalPawn newfriend)
{
	local int i;
	local bool bDontAdd;

	//log(self$" AddAnimalFriend "$newfriend);
	// Make sure he's not already in the list
	for(i=0; i<AnimalFriends.Length; i++)
	{
		if(AnimalFriends[i] == newfriend)
		{
			//log(self$" already here ");
			bDontAdd=true;
		}
	}

	if(!bDontAdd)
	{
		i = AnimalFriends.Length;
		AnimalFriends.Insert(i, 1);
		AnimalFriends[i] = newfriend;
		//log(self$" new animal friend! "$newfriend$" at "$i);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Remove a friend
///////////////////////////////////////////////////////////////////////////////
function RemoveAnimalFriend(AnimalPawn newfriend)
{
	local int i;
	local bool bDontAdd;

	//log(self$" RemoveAnimalFriend "$newfriend);
	// Make sure he's there to be removed
	for(i=0; i<AnimalFriends.Length; i++)
	{
		if(AnimalFriends[i] == newfriend)
		{
			//log(self$" found him.. removing ");
			AnimalFriends.Remove(i, 1);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check if this pawn is a player animal friend
///////////////////////////////////////////////////////////////////////////////
function bool IsAnimalFriend(FPSPawn cfriend)
{
	local int i;

	// Make sure he's not already in the list
	for(i=0; i<AnimalFriends.Length; i++)
	{
		if(AnimalFriends[i] == cfriend)
			return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check if we should prepare for a save
///////////////////////////////////////////////////////////////////////////////
function CheckPrepForSave()
{
	// For single-player game, if we haven't done this already, prepare to save asap
	if(P2GameInfoSingle(Level.Game) != None
		// Don't ever allow saving in the demo
		&& !P2GameInfoSingle(Level.Game).bIsDemo
		&& !bDidPrepForSave)
	{
		PrepForSave();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Usually only used by the demo to make sure the map comes up to explain
// things at the start (since the intro movie didn't here).
///////////////////////////////////////////////////////////////////////////////
function ForceMapUp()
{
	GotoState('PlayerDemoMapFirst');
}

///////////////////////////////////////////////////////////////////////////////
// Called after a saved game has been loaded
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
	{
	Super.PostLoadGame();

	InitRagdollSkels(RagdollMax);

	// Screens aren't saved so they need to be setup after a load
	SetupScreens();
	
	// xPatch: Restore catnip effects
	if(CatnipUseTime > 0)
		P2HUD(MyHud).DoCatnipEffects();

	/*
	// Re-init the hud if we're killing things with a counter on the screen
	P2Hud(MyHud).KillIcon = KillPawnIcon;
	P2Hud(MyHud).BossIcon = BossPawnIcon;
	*/
	}

///////////////////////////////////////////////////////////////////////////////
// Prepare for a save
///////////////////////////////////////////////////////////////////////////////
function PrepForSave()
{
	// STUB! Don't allow it here
}

///////////////////////////////////////////////////////////////////////////////
// Give us the right state
///////////////////////////////////////////////////////////////////////////////
function ExitPrepToSave()
{
	GotoState('PlayerWalking');
}

///////////////////////////////////////////////////////////////////////////////
// Check whether save is allowed
///////////////////////////////////////////////////////////////////////////////
function bool IsSaveAllowed()
	{
	//log(self$" IsSaveAllowed "$Pawn$" my pawn "$MyPawn$" health "$Pawn.Health);
	if (Pawn != None &&			// only if player has pawn (aka not during cinematics)
		Pawn.Health > 0)		// only if player is alive
		return true;
	return false;
	}

/*
// Dump player inventory and ammo types to log
function DumpInv()
	{
	local Inventory inv;
	local P2Weapon weap;

	Log("DumpInv(): Player inventory:");
	inv = Pawn.Inventory;
	while (inv != None)
		{
		Log("   "$inv);
		weap = P2Weapon(inv);
		if (weap != None)
			Log("      "$weap.AmmoType);
		inv = inv.inventory;
		}

	Log("   MyPawn.MyFoot"$MyPawn.MyFoot);
	Log("   MyPawn.MyUrethra"$MyPawn.MyUrethra);
	}
*/

///////////////////////////////////////////////////////////////////////////////
// P2CheatManager cheats are ready to be used if this is a single player
// game with bAllowCManager true or it's just a multiplayer.
// Make sure he has a pawn too.
///////////////////////////////////////////////////////////////////////////////
function bool CheatsAllowed()
{
	if(P2GameInfoSingle(Level.Game) == None
		|| (P2GameInfoSingle(Level.Game).bAllowCManager
			&& Pawn != None
			&& Pawn.Health > 0))
		return true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Change hud icon show amount
///////////////////////////////////////////////////////////////////////////////
exec function GrowHud()
	{
	if(HudViewState < HUD_VIEW_MAX)
		{
		HudViewState++;
		ConsoleCommand("set "@HudViewStatePath@HudViewState);
		}
	}
exec function ShrinkHud()
	{
	if(HudViewState > 0)
		{
		HudViewState--;
		ConsoleCommand("set "@HudViewStatePath@HudViewState);
		}
	}
///////////////////////////////////////////////////////////////////////////////
// Override engine functionality for quick save/load
///////////////////////////////////////////////////////////////////////////////
exec function QuickSave()
	{
	local float CurTime;

	// Try the quick save (may not occur if conditions aren't right)
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TryQuickSave(self))
		{
		// Taunt player if he's saving too often
		CurTime = Level.TimeSeconds;
		if (LastQuickSaveTime != 0 && CurTime - LastQuickSaveTime < 60)
			MyPawn.Say(MyPawn.myDialog.lDude_SaveTooMuch);
		LastQuickSaveTime = CurTime;
		}
	}

exec function QuickLoad()
	{
	if(P2GameInfoSingle(Level.Game) != None)
		// Try the quick load (may not occur if contions aren't right)
		P2GameInfoSingle(Level.Game).TryQuickLoad(self);
	}

///////////////////////////////////////////////////////////////////////////////
// Only allow this for debugging -- leads to bad things when actually
// trying to play the game.
///////////////////////////////////////////////////////////////////////////////
exec function RestartLevel()
	{
	// Only allow this in debug mode
	if (DebugEnabled())
		{
		Log("CHEAT: RestartLevel");
		Super.RestartLevel();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Start up the debug menu
///////////////////////////////////////////////////////////////////////////////
exec function EnableDebugMenu()
{
	Super.EnableDebugMenu();
	// If they turn on debug, set the save as cheated, even if they don't do anything
	if (DebugEnabled())
		P2GameInfoSingle(Level.Game).TheGameState.PlayerCheated("Used EnableDebugMenu");
}

///////////////////////////////////////////////////////////////////////////////
// Toggle the cheats for single player game
///////////////////////////////////////////////////////////////////////////////
exec function Sissy()
{
	local P2GameInfoSingle psg;

	psg = P2GameInfoSingle(Level.Game);
	
	// xPatch: Ludicrous Mode
	// In this mode we do NOT alllow cheats :)
	if(psg.InLudicrousMode()
		&& psg.InMasochistMode()
		&& psg.InVeteranMode()
		&& !psg.InCustomMode() // but the Custom Mode is an exception ;)
		&& !psg.GetPlayer().DebugEnabled())	// And debug too

	{
		// Say GottaBeKidding line
		SayTime = MyPawn.Say(MyPawn.myDialog.lDude_GottaBeKidding) + 0.5;
		SetTimer(SayTime, false);
		bStillTalking=true;
		ClientMessage(SissyOffText);
		return;
	}

	if(psg != None)
	{
		// Kamek 4-22
		if(Level.NetMode != NM_DedicatedServer ) GetEntryLevel().EvaluateAchievement(Self, 'Sissy');
		psg.bAllowCManager=!psg.bAllowCManager;
		ConsoleCommand("set "@CheatsPath@(psg.bAllowCManager));
		if(psg.bAllowCManager)
		{
			// Say he's a sissy
			SayTime = MyPawn.Say(MyPawn.myDialog.lDude_PlayerSissy) + 0.5;
			SetTimer(SayTime, false);
			bStillTalking=true;
			ClientMessage(CheatsOnText);
		}
		else
			ClientMessage(CheatsOffText);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Turn cheats on for single player game. Not a toggle
///////////////////////////////////////////////////////////////////////////////
exec function ForceSissy()
{
	local P2GameInfoSingle psg;

	psg = P2GameInfoSingle(Level.Game);
	
	// xPatch: Ludicrous Mode
	// In this mode we do NOT alllow cheats :)
	if(psg.InLudicrousMode()
		&& psg.InMasochistMode()
		&& psg.InVeteranMode()
		&& !psg.InCustomMode())	// but the Custom Mode is an exception ;)
	{
		// Say GottaBeKidding line
		SayTime = MyPawn.Say(MyPawn.myDialog.lDude_GottaBeKidding) + 0.5;
		SetTimer(SayTime, false);
		bStillTalking=true;
		ClientMessage(SissyOffText);
		return;
	}

	if(psg != None)
	{
		if(!psg.bAllowCManager)
		{
			// Say he's a sissy
			SayTime = MyPawn.Say(MyPawn.myDialog.lDude_PlayerSissy) + 0.5;
			SetTimer(SayTime, false);
			bStillTalking=true;
			ClientMessage(CheatsOnText);
		}

		psg.bAllowCManager=true;
		ConsoleCommand("set "@CheatsPath@(psg.bAllowCManager));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Turn cheats off. Not a toggle
///////////////////////////////////////////////////////////////////////////////
exec function UnSissy()
{
	local P2GameInfoSingle psg;

	psg = P2GameInfoSingle(Level.Game);

	if(psg != None)
	{
		psg.bAllowCManager=false;
		ConsoleCommand("set "@CheatsPath@(psg.bAllowCManager));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Pressing Fire in the pawn. Make sure the controller says it's okay
// first
///////////////////////////////////////////////////////////////////////////////
simulated function bool PressingFire()
{
	if (bDualWieldSwap && P2Weapon(Pawn.Weapon) != None)
	{
		if (P2Weapon(Pawn.Weapon).bContextualFireSwap
			|| (P2DualWieldWeapon(Pawn.Weapon) != None && P2DualWieldWeapon(Pawn.Weapon).bDualWielding))
			return ( bAltFire != 0 );
	}
	return ( bFire != 0 );
}
simulated function bool PressingAltFire()
{
	if (bDualWieldSwap && P2Weapon(Pawn.Weapon) != None)
	{
		if (P2Weapon(Pawn.Weapon).bContextualFireSwap
			|| (P2DualWieldWeapon(Pawn.Weapon) != None && P2DualWieldWeapon(Pawn.Weapon).bDualWielding))
			return ( bFire != 0 );
	}
	return ( bAltFire != 0 );
}

///////////////////////////////////////////////////////////////////////////////
// Same as Engine::PlayerController--blocking pawn checks for when you're in a movie now
// The player wants to fire.
///////////////////////////////////////////////////////////////////////////////
exec function Fire( optional float F )
{
	local P2DualWieldWeapon DualWieldWeapon;
	
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
	
	if (Pawn != none && Pawn.Weapon != none) {
	
	    DualWieldWeapon = P2DualWieldWeapon(Pawn.Weapon);
		if (DualWieldWeapon != None && DualWieldWeapon.bDualWielding)
		{
			if (bDualWieldSwap)
				DualWieldWeapon.Fire(F);
			else if (DualWieldWeapon.LeftWeapon != none)
				DualWieldWeapon.LeftWeapon.Fire(F);
		}
		else if (P2Weapon(Pawn.Weapon) != None && P2Weapon(Pawn.Weapon).bContextualFireSwap)
			Pawn.Weapon.AltFire(F);
		else
		    Pawn.Weapon.Fire(F);
		
	}
}

///////////////////////////////////////////////////////////////////////////////
// Same as Engine::PlayerController--blocking pawn checks for when you're in a movie now
// The player wants to alternate-fire.
///////////////////////////////////////////////////////////////////////////////
exec function AltFire( optional float F )
{
	local P2DualWieldWeapon DualWieldWeapon;
	
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
	
	if (Pawn != none && Pawn.Weapon != none) {
	
	    DualWieldWeapon = P2DualWieldWeapon(Pawn.Weapon);
		if (DualWieldWeapon != None && DualWieldWeapon.bDualWielding)
		{
			if (bDualWieldSwap && DualWieldWeapon.LeftWeapon != none)
				DualWieldWeapon.LeftWeapon.Fire(F);
			else
				DualWieldWeapon.Fire(F);
		}
		else if (P2Weapon(Pawn.Weapon) != None && P2Weapon(Pawn.Weapon).bContextualFireSwap)
			Pawn.Weapon.Fire(F);
		else
		    Pawn.Weapon.AltFire(F);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Do anything special you need to, after your inventory and weapons have
// been taken from you.
///////////////////////////////////////////////////////////////////////////////
function CheckInventoryAfterItsTaken()
{
	local Inventory Inv;

	Inv = MyPawn.Inventory;
	// Tell any remaining inventory and weapon items that they should have been
	// stolen.. things like Radar we definitely want to stay, but others may need to do things
	while(Inv != None)
	{
		if(P2Weapon(Inv) != None)
			P2Weapon(Inv).AfterItsTaken(MyPawn);
		else if(P2PowerupInv(Inv) != None)
			P2PowerupInv(Inv).AfterItsTaken(MyPawn);

		Inv = Inv.Inventory;
	}


	// Kevlar is special because armor is in the usepawn, so strip any armor
	// from him too. And don't give any back
	MyPawn.Armor = 0;

	// If you had a weapon you were currently using, it could have screwed up things
	// so just default to switching your hands (like if you're clipboard was taken and
	// was currently being used)
	ResetHandsToggle();

	if(MyPawn != None)
		SwitchToHands(true);
}

///////////////////////////////////////////////////////////////////////////////
// Used only for AIScripts, make sure the MyPawn gets cleared too
///////////////////////////////////////////////////////////////////////////////
function PendingStasis()
{
	Super.PendingStasis();
	MyPawn = None;
}

///////////////////////////////////////////////////////////////////////////////
// Determines how much a threat to the player this pawn is
///////////////////////////////////////////////////////////////////////////////
function float DetermineThreat()
{
	return 0.0;
}

///////////////////////////////////////////////////////////////////////////////
// Setup various screens.  Screens aren't saved because they're objects (and
// are markred transient).  Once they are created, the screens will exist
// throughout the game, so we always look for existing screens first, and if
// they don't exist then we create them.
///////////////////////////////////////////////////////////////////////////////
function SetupScreens()
	{
	local int i;
	local MapScreen map;
	local NewsScreen news;
	local VoteScreen vote;
	local PickScreen pick;
	local LoadScreen load;
	local LoadScreen fastload;
	local ClothesScreen clothes;
	local StatsScreen stats;

	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		// Search for existing screens
		for (i = 0; i < Player.LocalInteractions.Length; i++)
			{
			map = MapScreen(Player.LocalInteractions[i]);
			if (map != None)
				MyMapScreen = map;

			news = NewsScreen(Player.LocalInteractions[i]);
			if (news != None)
				MyNewsScreen = news;

			vote = VoteScreen(Player.LocalInteractions[i]);
			if (vote != None)
				MyVoteScreen = vote;

			pick = PickScreen(Player.LocalInteractions[i]);
			if (pick != None)
				MyPickScreen = pick;

			load = LoadScreen(Player.LocalInteractions[i]);
			if (load != None
				&& LoadScreenNoFade(Load) == None)
				MyLoadScreen = load;

			fastload = LoadScreenNoFade(Player.LocalInteractions[i]);
			if (fastload != None)
				MyFastLoadScreen = fastload;

			clothes = ClothesScreen(Player.LocalInteractions[i]);
			if (clothes != None)
				MyClothesScreen = clothes;

			stats = StatsScreen(Player.LocalInteractions[i]);
			if (stats != None)
				MyStatsScreen = stats;
			}

		// Destroy the old stats screen -- vital to make sure that proper game types load their correct stats screens.
		if (MyStatsScreen != None
			&& String(MyStatsScreen.Class) != P2GameInfoSingle(Level.Game).StatsScreenClassName)
		{
			Player.InteractionMaster.RemoveInteraction(MyStatsScreen);
			MyStatsScreen = None;
		}

		// Destroy the old Map screen -- vital to make sure that proper game types load their correct Map screens.
		if (MyMapScreen != None
			&& String(MyMapScreen.Class) != P2GameInfoSingle(Level.Game).MapScreenClassName)
		{
			Player.InteractionMaster.RemoveInteraction(MyMapScreen);
			MyMapScreen = None;
		}
		
		// If screens weren't found, create new ones
		if (MyMapScreen == None)
			MyMapScreen = MapScreen(Player.InteractionMaster.AddInteraction(P2GameInfoSingle(Level.Game).MapScreenClassName, Player));
			
		if (MyNewsScreen == None)
			MyNewsScreen = NewsScreen(Player.InteractionMaster.AddInteraction("Postal2Game.NewsScreen", Player));

		if (MyVoteScreen == None)
			MyVoteScreen = VoteScreen(Player.InteractionMaster.AddInteraction("Postal2Game.VoteScreen", Player));

		if (MyPickScreen == None)
			MyPickScreen = PickScreen(Player.InteractionMaster.AddInteraction("Postal2Game.PickScreen", Player));

		if (MyLoadScreen == None)
			MyLoadScreen = LoadScreen(Player.InteractionMaster.AddInteraction("Postal2Game.LoadScreen", Player));

		if (MyFastLoadScreen == None)
			MyFastLoadScreen = LoadScreen(Player.InteractionMaster.AddInteraction("Postal2Game.LoadScreenNoFade", Player));

		if (MyClothesScreen == None)
			MyClothesScreen = ClothesScreen(Player.InteractionMaster.AddInteraction("Postal2Game.ClothesScreen", Player));

		if (MyStatsScreen == None)
			MyStatsScreen = StatsScreen(Player.InteractionMaster.AddInteraction(P2GameInfoSingle(Level.Game).StatsScreenClassName, Player));
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Clean up our screens.
///////////////////////////////////////////////////////////////////////////////
function DetachScreens()
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		if (MyMapScreen != None)
			{
			Player.InteractionMaster.RemoveInteraction(MyMapScreen);
			MyMapScreen = None;
			}

		if (MyNewsScreen != None)
			{
			Player.InteractionMaster.RemoveInteraction(MyNewsScreen);
			MyNewsScreen = None;
			}

		if (MyVoteScreen != None)
			{
			Player.InteractionMaster.RemoveInteraction(MyVoteScreen);
			MyVoteScreen = None;
			}

		if (MyPickScreen != None)
			{
			Player.InteractionMaster.RemoveInteraction(MyPickScreen);
			MyPickScreen = None;
			}

		if (MyLoadScreen != None)
			{
			Player.InteractionMaster.RemoveInteraction(MyLoadScreen);
			MyLoadScreen = None;
			}

		if (MyClothesScreen != None)
			{
			Player.InteractionMaster.RemoveInteraction(MyClothesScreen);
			MyClothesScreen = None;
			}

		if (MyStatsScreen != None)
			{
			Player.InteractionMaster.RemoveInteraction(MyStatsScreen);
			MyStatsScreen = None;
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SendHintText(coerce string Msg, float MsgLife)
{
	P2Hud(myHUD).AddTextMessageEx(Msg, MsgLife, class'StringMessagePlus');
}

///////////////////////////////////////////////////////////////////////////////
// Record the old state
///////////////////////////////////////////////////////////////////////////////
function SetMyOldState()
{
	MyOldState = GetStateName();
}

///////////////////////////////////////////////////////////////////////////////
// Something bad has happened and sometimes the dude likes to hear about it
///////////////////////////////////////////////////////////////////////////////
function MarkerIsHere(class<TimedMarker> bliphere,
					  FPSPawn CreatorPawn,
					  Actor OriginActor,
					  vector blipLoc)
{
	if(bliphere == class'HeadExplodeMarker')
	{
		//WatchHeadExplode(bliphere.OriginPawn);
	}
	else if(bliphere == class'DeadBodyMarker')
	{
		//CheckDeadBody(bliphere.OriginPawn);
	}
	else if(ClassIsChildOf(bliphere, class'DesiredThingMarker'))
	{
		//CheckDesiredThing(bliphere.OriginPawn);
	}
	else if(bliphere == class'DeadCatHitGuyMarker')
	{
	}
	else if(bliphere == class'PanicMarker')
	{
		// Say something about the carnage wrought by you for the first time
		CheckForFirstTimeWeaponSeen(None);//bliphere);
	}
	else if(bliphere == class'GunfireMarker')
	{
	}
	/*
	else if(bliphere == class'PawnShotMarker'
		&& FPSPawn(OriginActor) != None
		&& FPSPawn(OriginActor).Health > 0)
	{
		// Say something about the carnage wrought by you for the first time
		CheckForFirstTimeWeaponUse(CreatorPawn);
	}
	*/
}

/*
///////////////////////////////////////////////////////////////////////////////
// Say something about the carnage wrought by you for the first time
///////////////////////////////////////////////////////////////////////////////
function CheckForFirstTimeWeaponUse(FPSPawn CreatorPawn)
{
	if(WeaponFirstTimeFireInstance == FIRE_WAITING
		&& CreatorPawn == MyPawn)
	{
		if(FRand() <= 0.5)
			MyPawn.Say(MyPawn.myDialog.lDude_WeaponFirstTime);
		WeaponFirstTimeFireInstance=FIRE_ENDED;
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// Set the type of reaction NPC's have to seeing the player now
///////////////////////////////////////////////////////////////////////////////
function SetSightReaction(FPSPawn.EPawnInitialState NewSightReaction)
{
	SightReaction = NewSightReaction;
	// Always update everyone around you, as you move to a different interest
	MyPawn.ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
}

///////////////////////////////////////////////////////////////////////////////
// Clear the type of reaction NPC's have to seeing the player now
///////////////////////////////////////////////////////////////////////////////
function ClearSightReaction()
{
	SightReaction = MyPawn.EPawnInitialState.EP_Think;
}

///////////////////////////////////////////////////////////////////////////////
// Set speed based on current health
///////////////////////////////////////////////////////////////////////////////
function SetHeartBeatBasedOnHealth()
{
	local float pct;

	pct = 1.0 - (MyPawn.Health/MyPawn.HealthMax);
	// cap percentage
	if(pct < 0.0)
		pct=0.0;
	// heart stuff
	HeartBeatSpeed = HeartBeatSpeedAdd*pct + default.HeartBeatSpeed;
}

///////////////////////////////////////////////////////////////////////////////
// Tell dude he got some health
///////////////////////////////////////////////////////////////////////////////
function NotifyGotHealth(int howmuch)
{
//	MyPawn.Say(MyPawn.myDialog.lDude_GotHealth);
}

///////////////////////////////////////////////////////////////////////////////
// Tell dude he got his vd fixed
///////////////////////////////////////////////////////////////////////////////
function NotifyCuredGonorrhea()
{
	MyPawn.Say(MyPawn.myDialog.lDude_CuredGonorrhea);
}

///////////////////////////////////////////////////////////////////////////////
// Make sure client puts up red bars showing direction of pain and intensity
///////////////////////////////////////////////////////////////////////////////
function ClientHurtBars(pawn InstigatedBy)
{
	local int i;
	local float hitdot, dist, useunit;
	local vector usevec, usevec2, hitcross, disttopawn;
	local bool bCenter, bUpDown;

	//log(self$" rot "$Rotation$" Pawn.Rot "$Pawn.Rotation);

	// Register the hurt so the hud can show the hurt bars to indicate the direction
	// of the attacker
	// First find the direction from the pawn to the attacker.
	if(InstigatedBy != None
		&& InstigatedBy != Pawn)
	{
		disttopawn = InstigatedBy.Location - Pawn.Location;
		usevec = Normal(disttopawn);
	}
	else
		usevec = vector(Pawn.Rotation);
	// Now get the direction of the player
	usevec2 = vector(Rotation);

	// Find the angle of the attacker relative to the player
	hitdot = usevec dot usevec2;
	hitcross = usevec cross usevec2;

	//log(self$" hit dot "$hitdot$" cross "$hitcross$" player "$vector(Rotation));
/*
	// If it's within a certain center range, light up all the hurt,
	// if it's heavy to a given direction, then light that way up.
	if(hitdot > CENTER_DOT_HIT)
	{
		for(i=0; i<DIRECTIONAL_HURT_BAR_COUNT; i++)
			HurtBarTime[i]=HURT_BAR_FADE_TIME;
	}
	else	// It has a specific direction to the hurt, so calculate it
	{
		dist = abs(0.5*VSize(disttopawn));
		// If differing Z by more than 45 degrees, show up/down
		//if(abs(disttopawn.z) > dist)
		if(abs(hitcross.y) > 0.4)
		{
			// he's below you
			if(hitcross.y < -0.4)
				HurtBarTime[HURT_DIR_DOWN]=HURT_BAR_FADE_TIME;
			else	// above you
				HurtBarTime[HURT_DIR_UP]=HURT_BAR_FADE_TIME;
		}

		// If outside of normal dot range, always show a left or right
		if(hitcross.z < 0)
			HurtBarTime[HURT_DIR_RIGHT]=HURT_BAR_FADE_TIME;
		else
			HurtBarTime[HURT_DIR_LEFT]=HURT_BAR_FADE_TIME;
	}
	*/
	useunit = (abs(hitcross.x) + abs(hitcross.y))/2;
	if(useunit > MIN_DIR
		&& hitdot >= 0)
	{
		// he's above you
		if(usevec2.z > 0)
			HurtBarTime[HURT_DIR_DOWN]=HURT_BAR_FADE_TIME;
		else	// below you
			HurtBarTime[HURT_DIR_UP]=HURT_BAR_FADE_TIME;
		bUpDown=true;
	}
	// draw all forward (all four bars)
	if(hitdot > CENTER_DOT_HIT)
	{
		for(i=0; i<DIRECTIONAL_HURT_BAR_COUNT; i++)
			HurtBarTime[i]=HURT_BAR_FADE_TIME;
		bCenter=true;
	}
	// Tell you left or right, if all else fails
	if((!bUpDown
			&& !bCenter)
		|| abs(hitcross.z) > MIN_DIR)
	{
		// he's to your right
		if(hitcross.z < 0)
			HurtBarTime[HURT_DIR_RIGHT]=HURT_BAR_FADE_TIME;
		else	// he's to your left
			HurtBarTime[HURT_DIR_LEFT]=HURT_BAR_FADE_TIME;
	}
	// Check if we're close to death. If so, show a skull to push the point
	// that you're almost dead.
	if(MyPawn.Health < MyPawn.HealthMax*SKULL_HEALTH_PERC)
	{
		HurtBarTime[HURT_DIR_SKULL]=HURT_BAR_FADE_TIME;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make sure client puts up black bars showing direction of sniper who
// has got them in his sights
///////////////////////////////////////////////////////////////////////////////
function StartSniperBars(P2Pawn InstigatedBy)
{
	SniperAfterMe = InstigatedBy;
	bSniperBarsClear=false;
}
function EndSniperBars()
{
	SniperAfterMe = None;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CalcSniperBars(float DeltaTime, float UseMax)
{
	local int i, BarsClear;
	local float hitdot, dist, useunit, FadeTime;
	local vector usevec, usevec2, hitcross, disttopawn;
	local bool bCenter, bUpDown;
	local byte SniperNew[4];

	if(SniperAfterMe != None)
	{
		disttopawn = SniperAfterMe.Location - Pawn.Location;
		usevec = Normal(disttopawn);
		// Now get the direction of the player
		usevec2 = vector(Rotation);

		// Find the angle of the attacker relative to the player
		hitdot = usevec dot usevec2;
		hitcross = usevec cross usevec2;

		useunit = (abs(hitcross.x) + abs(hitcross.y))/2;
		if(useunit > MIN_DIR
			&& hitdot >= 0)
		{
			// he's above you
			if(usevec2.z > 0)
			{
				SniperBarTime[HURT_DIR_DOWN]+=DeltaTime;
				SniperNew[HURT_DIR_DOWN]=1;
			}
			else	// below you
			{
				SniperBarTime[HURT_DIR_UP]+=DeltaTime;
				SniperNew[HURT_DIR_UP]=1;
			}
			bUpDown=true;
		}
		// draw all forward (all four bars)
		if(hitdot > CENTER_DOT_HIT)
		{
			for(i=0; i<DIRECTIONAL_HURT_BAR_COUNT; i++)
			{
				SniperBarTime[i]+=DeltaTime;
				SniperNew[i]=1;
			}
			bCenter=true;
		}
		// Tell you left or right, if all else fails
		if((!bUpDown
				&& !bCenter)
			|| abs(hitcross.z) > MIN_DIR)
		{
			// he's to your right
			if(hitcross.z < 0)
			{
				SniperBarTime[HURT_DIR_RIGHT]+=DeltaTime;
				SniperNew[HURT_DIR_RIGHT]=1;
			}
			else	// he's to your left
			{
				SniperBarTime[HURT_DIR_LEFT]+=DeltaTime;
				SniperNew[HURT_DIR_LEFT]=1;
			}
		}
		/*
		disttopawn = SniperAfterMe.Location - Pawn.Location;
		usevec = Normal(disttopawn);
		// Now get the direction of the player
		usevec2 = vector(Pawn.Rotation);

		// Find the angle of the attacker relative to the player
		hitdot = usevec dot usevec2;
		hitcross = usevec cross usevec2;

		// If it's within a certain center range, light up all the hurt,
		// if it's heavy to a given direction, then light that way up.
		if(hitdot > CENTER_DOT_HIT)
		{
			for(i=0; i<DIRECTIONAL_HURT_BAR_COUNT; i++)
			{
				SniperBarTime[i]+=DeltaTime;
				SniperNew[i]=1;
			}
		}
		else	// It has a specific direction to the hurt, so calculate it
		{
			dist = abs(0.5*VSize(disttopawn));
			// If differing Z by more than 45 degrees, show up/down
			if(abs(disttopawn.z) > dist)
			{
				// he's below you
				if(disttopawn.z < 0)
				{
					SniperBarTime[HURT_DIR_DOWN]+=DeltaTime;
					SniperNew[HURT_DIR_DOWN]=1;
				}
				else	// above you
				{
					SniperBarTime[HURT_DIR_UP]+=DeltaTime;
					SniperNew[HURT_DIR_UP]=1;
				}
			}

			// If outside of normal dot range, always show a left or right
			if(hitcross.z < 0)
			{
				SniperBarTime[HURT_DIR_RIGHT]+=DeltaTime;
				SniperNew[HURT_DIR_RIGHT]=1;
			}
			else
			{
				SniperBarTime[HURT_DIR_LEFT]+=DeltaTime;
				SniperNew[HURT_DIR_LEFT]=1;
			}
		}
		*/
	}

	// Fade out any of them you didn't at to
	FadeTime = (SNIPER_BAR_FADE*DeltaTime);
	for(i=0; i<ArrayCount(SniperNew); i++)
	{
		// Check to cap times at max
		if(SniperBarTime[i] > UseMax)
			SniperBarTime[i] = UseMax;
		// Any times that didn't increase, should fade out
		if(SniperNew[i] == 0)
		{
			SniperBarTime[i] -= FadeTime;
			if(SniperBarTime[i] < 0)
				SniperBarTime[i]=0;
		}
		if(SniperBarTime[i] == 0)
			BarsClear++;
	}
	if(BarsClear == ArrayCount(SniperNew))
		bSniperBarsClear=true;
}

///////////////////////////////////////////////////////////////////////////////
// Yell when hurt, set up flashy hurt bars, etc.
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local float randcheck;
	local bool bExitNow;

	// Getting hurt dialogue for dude
	// Say various things when you get hit.
	// We do things here so we have access to damagetype
	SayTime=0;
	randcheck = FRand();
	if(damageType == class'CrackSmokingDamage')
	{
		SayTime=MyPawn.Say(MyPawn.myDialog.lDude_GotHurtByCrack);
	}
	else if(!bStillYelling)
	{
		if(ClassIsChildOf(damageType, class'BurnedDamage')
			|| damageType == class'OnFireDamage')
		{
			if(MyPawn.TakesOnFireDamage > 0)
				SayTime=MyPawn.Say(MyPawn.myDialog.lGrunt);
			else	// Don't respond when your magically fire resistant.
				bExitNow=true;
		}
		else if(MyPawn.bCrotchHit)
			SayTime=MyPawn.Say(MyPawn.myDialog.lGotHitInCrotch);
		else if(randcheck < 0.85)
			SayTime=MyPawn.Say(MyPawn.myDialog.lGrunt);
		else if(randcheck < 0.9)
			SayTime=MyPawn.Say(MyPawn.myDialog.lGotHit);
		else
			SayTime=MyPawn.Say(MyPawn.myDialog.lCussing);
	}

	if(SayTime > 0)
	{
		bStillYelling=true;
		SetTimer(SayTime, false);
	}

	if(!bExitNow)
	{
		// Flash bars when hurt (red flashes)
		ClientHurtBars(InstigatedBy);

		// Handle damage rate. Keeps track of how often you've been hurt by the AI
		// or burned by yourself
		if(InstigatedBy != None
			&& ((!FPSPawn(InstigatedBy).bPlayer
					&& ClassIsChildof(damageType, class'BulletDamage'))
				|| ClassIsChildof(damageType, class'OnFireDamage')))
		{
			DamageThisHitTime = Level.TimeSeconds;

			// Check if the last time we were hurt is too far from this current time
			if(DamageFirstHitTime != 0)
			{
				if(DamageThisHitTime - DamageFirstHitTime > LAST_AI_DAMAGE_TIME
					&& (Damage + DamageTotal) > 0
					&& ((Damage + DamageTotal)/(DamageThisHitTime - DamageFirstHitTime)) < LOW_AI_DAMAGE_RATE)
				// Reset the damage counters
				{
					DamageTotal = 0;
					//log(self$" resetting ");
				}
			}

			// First time hurt
			if(DamageTotal == 0)
			{
				DamageTotal = Damage;
				DamageFirstHitTime = Level.TimeSeconds;
				DamageRate = 0;
			}
			else
			{
				DamageTotal += Damage;
				if(DamageThisHitTime - DamageFirstHitTime > 0)
					DamageRate = DamageTotal/(DamageThisHitTime - DamageFirstHitTime);
			}
			//log(self$" new damage rate "$DamageRate$" total "$DamageTotal$" first "$DamageFirstHitTime$" this "$DamageThisHitTime);
		}

		// Show a special flash if it's chem hurt
		if(ClassIsChildof(damageType, class'ChemDamage'))
			FlashChemHurt();

		// set our heartbeat and other things
		damageAttitudeTo(instigatedBy, Damage);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Speed up heart
///////////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	Super.DamageAttitudeTo(Other, Damage);

	SetHeartBeatBasedOnHealth();
}

///////////////////////////////////////////////////////////////////////////////
// Timers are used for talking and could interrupt our count.
// We'll add up how long it's been since we used crack in the state code
// of PlayerMoving and PlayerClimbing and such.
///////////////////////////////////////////////////////////////////////////////
function CheckForCrackUse(float TimePassed)
{
	// Filled out in DudePlayer becuase it needs some access to inventory classes.
}

///////////////////////////////////////////////////////////////////////////////
// Return heart time and scale to defaults
///////////////////////////////////////////////////////////////////////////////
function ResetHeart()
{
	HeartTime = 0;
	HeartScale = default.HeartScale;
}

///////////////////////////////////////////////////////////////////////////////
// Setup our crack addiciton
///////////////////////////////////////////////////////////////////////////////
function InitCrackAddiction()
{
	MyPawn.CrackAddictionTime = CrackStartTime;
	//log(MyPawn$" initting crack addiction");

	// Calc the final scale size of your heart will be by the end of the crack addiction
	// You will do this over the time from the first time you commented on it, *not*
	// from the entire start time of your addiction
	HeartScaleDelta = HEART_SCALE_CRACK_ADD/CrackHintTimes[MAX_CRACK_HINTS-1];

	// Reset your heart
	ResetHeart();
}

///////////////////////////////////////////////////////////////////////////////
// Go into dual-wield mode
///////////////////////////////////////////////////////////////////////////////
function SetupDualWielding(float starttime)
{
	// xPatch: Dual Wielding can be Disabled
	if(P2DualWieldWeapon(Pawn.Weapon).bDisableDualWielding)
		return;
		
	if(starttime > 0)
	{
		DualWieldUseTime = starttime;
		// Set our current weapon into dual-wield mode
		if (P2DualWieldWeapon(Pawn.Weapon) != None && !P2DualWieldWeapon(Pawn.Weapon).bDualWielding)
		{
			// Setup dual wielding if not already setup
			if (P2DualWieldWeapon(Pawn.Weapon).LeftWeapon == None)
				P2DualWieldWeapon(Pawn.Weapon).SetupDualWielding();
			Pawn.Weapon.GotoState('ToggleDualWielding');				
		}
	}
	else // reset things
	{
		DualWieldUseTime = 0;
		// Take off dual-wield mode
		if (!bCheatDualWield && P2DualWieldWeapon(Pawn.Weapon) != None && P2DualWieldWeapon(Pawn.Weapon).bDualWielding)
		{
			Pawn.Weapon.GotoState('ToggleDualWielding');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// When the Dude drinks the caffeinergy sauce, give him dual wielding powers
///////////////////////////////////////////////////////////////////////////////
function BeginDualWielding()
{
	SetupDualWielding(DUAL_WIELD_TIME);
}

///////////////////////////////////////////////////////////////////////////////
// Say something about going into dual wield mode
///////////////////////////////////////////////////////////////////////////////
function CommentOnDualWielding()
{
	MyPawn.Say(MyPawn.myDialog.lDude_BeginDualWielding);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function FollowDualWieldUse(float TimePassed)
{
	if(DualWieldUseTime == 0)
		return;

	DualWieldUseTime-=TimePassed;

	if(DualWieldUseTime <= 0)
	{
		DualWieldUseTime = 0;
		// Reset effects
		SetupDualWielding(0);
	}
}

///////////////////////////////////////////////////////////////////////////////
// If the player 'uses' the catnip, he'll smoke it to gain cat-like speed.
///////////////////////////////////////////////////////////////////////////////
function SmokeCatnip()
{
	// xPatch: In Ludicrous Difficulty make it 20 seconds instead of 60
	if(P2GameInfoSingle(Level.Game) != None 
		&& P2GameInfoSingle(Level.Game).InVeteranMode())
		SetupCatnipUseage(CATNIP_START_TIME / 3);
	else
		SetupCatnipUseage(CATNIP_START_TIME);
	MyPawn.Say(MyPawn.myDialog.lDude_SmokedCatnip);
	if(P2GameInfoSingle(Level.Game) != None)
		P2GameInfoSingle(Level.Game).TheGameState.SmokedCrackPipe(true);
}

///////////////////////////////////////////////////////////////////////////////
// Setup the catnip with this time
///////////////////////////////////////////////////////////////////////////////
function SetupCatnipUseage(float starttime)
{
	if(starttime > 0)
	{
		CatnipUseTime = starttime;
		// Leave a log here just so we know when this was used.
		//log(self$" Setting catnip time--slomo: "$starttime);
		if(P2GameInfoSingle(Level.Game) != None)
			P2GameInfoSingle(Level.Game).SetGameSpeedNoSave(1/CATNIP_SPEED);
		// xPatch: Add New Catnip Effects
		P2HUD(MyHud).DoCatnipEffects();
	}
	else // reset things
	{
		CatnipUseTime = 0;
		//log(self$" Resetting catnip time: "$starttime);
		// Reset effects
		if(P2GameInfoSingle(Level.Game) != None)
			P2GameInfoSingle(Level.Game).SetGameSpeedNoSave(1.0);
		// xPatch: Stop Catnip Effects
		P2HUD(MyHud).StopCatnipEffects(CatnipUseTime);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function FollowCatnipUse(float TimePassed)
{
	if(CatnipUseTime == 0)
		return;

	CatnipUseTime-=TimePassed;
	
	// xPatch: Start fading out the Catnip Effects
	if(CatnipUseTime <= 5)
		P2HUD(MyHud).StopCatnipEffects(CatnipUseTime);
	
	if(CatnipUseTime <= 0)
	{
		CatnipUseTime = 0;
		// Reset effects
		P2GameInfoSingle(Level.Game).SetGameSpeedNoSave(1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Blow smoke for smoking health pipe and catnip.
///////////////////////////////////////////////////////////////////////////////
simulated function BlowSmoke(vector smokecolor)
{
	// STUB, dudeplayer
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function EatingFood()
{
	// STUB, dudeplayer
}
///////////////////////////////////////////////////////////////////////////////
// Show a flash of color for when you're hurt by chem infection clouds
///////////////////////////////////////////////////////////////////////////////
function FlashChemHurt()
{
}

///////////////////////////////////////////////////////////////////////////////
// Do various things to the heart, mostly used for crack addiction
///////////////////////////////////////////////////////////////////////////////
function ModifyHeartTime(float DeltaTime)
{
	local float AddictionLevel;

	if (MyPawn != None)
	{
		// If we're addicted to crack and you've already commented on how
		// you don't feel so good, give yourself a fake murmur
		if(MyPawn.CrackAddictionTime > 0
			&& MyPawn.CrackAddictionTime <= CrackHintTimes[MAX_CRACK_HINTS-1])
		{
			AddictionLevel = (CrackHintTimes[MAX_CRACK_HINTS-1] - MyPawn.CrackAddictionTime)/MyPawn.CrackAddictionTime;

			// Change heart beat
			if(FRand() <= AddictionLevel)
				HeartTime+=(FRand()*AddictionLevel);

			// Change scale of heart
			HeartScale += (DeltaTime*HeartScaleDelta);
		}
		// Make it beat faster, but in an even fashion (not a jerky fashion)
		// Add in more time to the heart
		else if(CatnipUseTime > 0 || DualWieldUseTime > 0)
		{
			HeartTime += ((CATNIP_SPEED - 1)*HeartBeatSpeed*DeltaTime);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Slow heart down
///////////////////////////////////////////////////////////////////////////////
function AddedHealth(float HealthAdded, bool bIsAddictive, int Tainted, bool bIsFood)
{
	SetHeartBeatBasedOnHealth();

	// If you got bad health, say so
	if(Tainted == 1)
	{
		MyPawn.Say(MyPawn.myDialog.lPissOnSelf);
		//log(MyPawn$" don't pee on me!");
	}
	// Say something about the nice health
	else if(!bIsAddictive)
	{
		if(bIsFood)
		{
			MyPawn.Say(MyPawn.myDialog.lGotHealthFood);
			//log(MyPawn$" i love food!");
		}
		else
		{
			MyPawn.Say(MyPawn.myDialog.lGotHealth);
			//log(MyPawn$" i love medkits!");
		}
	}
	else
	{
		InitCrackAddiction();
		// Don't make comment about how good it is here.. make crackinv do that later
		// after you exhale.
	}
}

///////////////////////////////////////////////////////////////////////////////
// Say something the first time someone sees your gun out.
///////////////////////////////////////////////////////////////////////////////
function CheckForFirstTimeWeaponSeen(FPSPawn CreatorPawn)
{
	if(WeaponFirstTimeFireInstance == FIRE_NOTHING
		&& CreatorPawn == MyPawn)
	{
		if(FRand() <= 0.5
			&& P2Weapon(CreatorPawn.Weapon) != None
			&& P2Weapon(CreatorPawn.Weapon).ViolenceRank > 1
			&& AllowTalking())
			MyPawn.Say(MyPawn.myDialog.lDude_FirstSeenWithWeapon);
		WeaponFirstTimeFireInstance=FIRE_ENDED;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Most of the time you allow talking. This is usually only checked by NPC's talking
// to you. Sniper mode won't allow talking--you're in the zone.
///////////////////////////////////////////////////////////////////////////////
function bool AllowTalking()
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Say something about the evil health
///////////////////////////////////////////////////////////////////////////////
function CommentOnCrackUse()
{
	MyPawn.Say(MyPawn.myDialog.lGotCrackHealth);
	//log(MyPawn$" crack feels good...");
}

///////////////////////////////////////////////////////////////////////////////
// Say something funny as you fire the weapon, not just as people die
///////////////////////////////////////////////////////////////////////////////
function CommentOnWeaponThrow()
{
	if(FRand() <= SayThingsOnWeaponFire)
	{
		if(MyPawn != None)
			MyPawn.Say(MyPawn.myDialog.lDude_ThrowGrenade);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Talk back while getting arrested
///////////////////////////////////////////////////////////////////////////////
function float CommentOnGettingArrested()
{
	SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Arrested) + 0.5;
	SetTimer(SayTime, false);
	bStillTalking=true;
	return SayTime;
}

///////////////////////////////////////////////////////////////////////////////
// Make fun of player for cheating
///////////////////////////////////////////////////////////////////////////////
function CommentOnCheating()
{
	SayTime = MyPawn.Say(MyPawn.myDialog.lDude_PlayerCheating) + 0.5;
	SetTimer(SayTime, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// Dude starts grinding at a lengthy achievement
///////////////////////////////////////////////////////////////////////////////
function CommentOnGrinding()
{
	SayTime = MyPawn.Say(MyPawn.myDialog.lDude_AchievementProgress) + 0.5;
	SetTimer(SayTime, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// Dude finishes an achievement
///////////////////////////////////////////////////////////////////////////////
function CommentOnAchievement(int AchNum)
{
	if(Level.NetMode != NM_DedicatedServer ) 
	{
		if (GetEntryLevel().GetAchievementManager().IsGrindy(AchNum))
			SayTime = MyPawn.Say(MyPawn.myDialog.lDude_AchievementUnlockedGrind) + 0.5;
		else
			SayTime = MyPawn.Say(myPawn.MyDialog.lDude_AchievementUnlocked) + 0.5;
	}
	
	SetTimer(SayTime, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// Say you need to pee badly
///////////////////////////////////////////////////////////////////////////////
function CommentOnNeedingToPee()
{
	SayTime = MyPawn.Say(MyPawn.myDialog.lDude_HaveToPee) + 0.5;
	SetTimer(SayTime, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// Apologize for farting
///////////////////////////////////////////////////////////////////////////////
function float CommentOnFarting()
{
	if(!bStillTalking)
		return MyPawn.Say(MyPawn.myDialog.lApologize);
	return 0.0;
}

///////////////////////////////////////////////////////////////////////////////
// Breath while zoomed in
///////////////////////////////////////////////////////////////////////////////
function float SniperBreathing()
{
	if(!bStillTalking
		&& !bStillYelling)
		return MyPawn.Say(MyPawn.myDialog.lDude_SniperBreathing);
	return 0.0;
}

///////////////////////////////////////////////////////////////////////////////
// Got fired
///////////////////////////////////////////////////////////////////////////////
function GotFired()
{
	MyPawn.Say(MyPawn.myDialog.lDude_GetFired);
}

///////////////////////////////////////////////////////////////////////////////
// If he's essentially someone you'd meet out on the street and kill, he's okay.
// Bystanders and cops/military are included, but protestors/osamas/etc aren't
// because in the linear play situations, you'd run into so many streams in a row
// it'd be way too easy to get. Override this in dudeplayer to include cops/military
///////////////////////////////////////////////////////////////////////////////
function bool ValidQuickKill(P2Pawn DeadGuy)
{
	return DeadGuy.bInnocent;
}

///////////////////////////////////////////////////////////////////////////////
// Say something funny when someone dies (if you're not already talking)
// Only in single player
///////////////////////////////////////////////////////////////////////////////
function SomeoneDied(P2Pawn DeadGuy, P2Pawn Killer, class<DamageType> DeadDamageType)
{
	local bool bValidQuickKilling;
	if(Killer == MyPawn
		&& Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		// You're killing people in quick succession. If you kill the next person
		// within QUICK_KILL_TIME of killing the last one, he'll say something
		// else and give you something.

		// Only check real bystanders for this--innocents. (they may have weapons though).
		bValidQuickKilling = (ValidQuickKill(DeadGuy) && bQuickKilling);
		if(bValidQuickKilling)
		{
			//log(self$" just killed "$DeadGuy$" time "$Level.TimeSeconds$" time section "$(Level.TimeSeconds - QuickKillLastTime));
			if((Level.TimeSeconds - QuickKillLastTime) < (QUICK_KILL_TIME - QuickKillSoundIndex))
			{
				QuickKillLastTime=Level.TimeSeconds;
				DelayedSayLine = QuickKillLine;
				bWaitingToTalk=true;
				SayTime = WAIT_FOR_DEATH_COMMENT_GUN;
				DeadGuy.PickQuickKillPrize(QuickKillSoundIndex);
			}
			else	// You've waited too long... not into the
			{
				//Pawn.PlaySound(QuickKillBadEndSound, SLOT_Misc);
				bQuickKilling=false;
			}
			if(SayTime > 0
				|| bWaitingToTalk)
			{
				SetTimer(SayTime, false);
				bStillTalking=true;
			}
		}
		
		// Count kills made while dual wielding
		if (DualWieldUseTime > 0)
			MadeDualWieldKill(DeadGuy);

		if(!bStillTalking
			&& !bValidQuickKilling)
		{
				if(FRand() <= SayThingsOnGuyDeathFreq)
				{
				}
				if(SayTime > 0
					|| bWaitingToTalk)
				{
					SetTimer(SayTime, false);
					bStillTalking=true;
				}

			SayTime = 0;
			if(DeadDamageType == class'OnFireDamage'
				|| ClassIsChildOf(DeadDamageType, class'BurnedDamage'))
			{
				if(FRand() <= SayThingsOnGuyBurningDeathFreq)
					SayTime = MyPawn.Say(MyPawn.myDialog.lDude_BurningPeople) + 0.5;
			}
			else if(DudeIsCop())
			{
				if(FRand() <= SayThingsOnGuyDeathFreq)
					SayTime = MyPawn.Say(MyPawn.myDialog.lDude_AttackAsCop) + 0.5;
			}
			// Zombie kill remarks
			else if (P2MocapPawn(DeadGuy) != None
				&& DeadGuy.IsA('AWZombie')
				&& FRand() <= SayThingsOnZombieKillFreq
				&& DudeZombieKill.Length > 0
				)
			{
				DelayedSaySound = DudeZombieKill[Rand(DudeZombieKill.Length)];
				SayTime = WAIT_FOR_DEATH_COMMENT_MELEE;
				bWaitingToTalk=true;
			}
			else if(FRand() <= SayThingsOnGuyDeathFreq
				&& !DeadGuy.IsA('AWZombie'))
			{
				// Say something when killing costumed bystanders or skeletons
				if (P2MocapPawn(DeadGuy) != None
					&& (P2MocapPawn(DeadGuy).bHalloween
					|| DeadGuy.IsA('SkeletonBase'))
					&& DudeHalloweenKill.Length > 0
					)
				{
					// Special Halloween kill remark
					DelayedSaySound = DudeHalloweenKill[Rand(DudeHalloweenKill.Length)];
					SayTime = WAIT_FOR_DEATH_COMMENT_MELEE;
					bWaitingToTalk=true;
				}
				else if(ClassIsChildOf(DeadDamageType , class'MacheteDamage')
					|| ClassIsChildOf(DeadDamageType , class'ScytheDamage')
					|| ClassIsChildOf(DeadDamageType , class'BaliDamage')	// xPatch: Comment on using bali too
					// Don't comment on supershotgun damage
					&& !ClassIsChildOf(DeadDamageType,class'SuperShotgunBodyDamage'))
				{
					DelayedSaySound = DudeBladeKill[Rand(DudeBladeKill.Length)];
					SayTime = WAIT_FOR_DEATH_COMMENT_MELEE;
					bWaitingToTalk=true;
				}
				else if(ClassIsChildOf(DeadDamageType , class'BulletDamage'))
				{
					// Randomly (not very often) start allowing the player to kill people
					// in quick succession (only with guns). Doesn't count sniper rifle
					// head shot kills in this.
					if(!bQuickKilling
						&& FRand() < QUICK_KILL_FREQ
						&& ValidQuickKill(DeadGuy))
					{
						bQuickKilling=true;
						QuickKillSoundIndex=0;
						if (FRand() < 0.5)
							QuickKillLine = MyPawn.myDialog.lDude_QuickKills;
						else
							QuickKillLine = MyPawn.myDialog.lDude_QuickKills2;
						QuickKillLastTime=Level.TimeSeconds;
					}
					else // Otherwise, make general comments about killing them with a gun
					{
						if(FRand() < COMMENT_ON_RACE
							&& (P2MocapPawn(DeadGuy).bIsBlack
								|| P2MocapPawn(DeadGuy).bIsMexican
								|| P2MocapPawn(DeadGuy).bIsHindu
								|| P2MocapPawn(DeadGuy).bIsAsian)
								&& !DeadGuy.IsA('Military') 			// Added by Man Chrzan: xPatch 2.0
								&& !DeadGuy.IsA('AWMilitary'))			// Dunno why but it used to happen sometimes with military guys?
							DelayedSayLine = MyPawn.myDialog.lDude_ShootMinorities;
						// Added by Man Chrzan: xPatch 2.0
						else if(DeadGuy.IsA('Bums'))
							DelayedSayLine = MyPawn.myDialog.lDude_ShootBum;
						// End
						else
							DelayedSayLine = MyPawn.myDialog.lDude_KillWithGun;
						bWaitingToTalk=true;
						SayTime = WAIT_FOR_DEATH_COMMENT_GUN;
					}
				}
				else if(ClassIsChildOf(DeadDamageType , class'BludgeonDamage')
						|| ClassIsChildOf(DeadDamageType , class'SledgeDamage')			// xPatch: Comment on Sledge 
						|| ClassIsChildOf(DeadDamageType , class'BaseballBatDamage'))	// and Baseball too
				{
					DelayedSayLine = MyPawn.myDialog.lDude_KillWithMelee;
					bWaitingToTalk=true;
					SayTime = WAIT_FOR_DEATH_COMMENT_MELEE;
				}
				else if(ClassIsChildOf(DeadDamageType , class'ExplodedDamage'))
				{
					DelayedSayLine = MyPawn.myDialog.lDude_KillWithProjectile;
					bWaitingToTalk=true;
					SayTime = WAIT_FOR_DEATH_COMMENT_PROJ;
				}
			}

			if(SayTime > 0
				|| bWaitingToTalk)
			{
				SetTimer(SayTime, false);
				bStillTalking=true;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to turn on/off the hands
///////////////////////////////////////////////////////////////////////////////
function SetWeaponUseability(bool bUseable, class<P2Weapon> weapclass)
{
	// STUB--defined in dudeplayer
}

///////////////////////////////////////////////////////////////////////////////
// Find the next-highest-ranked weapon (wraps around to lowest-ranked weapon
// if necessary).
///////////////////////////////////////////////////////////////////////////////
simulated function FindNextWeapon(P2Weapon CurrentWeapon, out P2Weapon NewWeap, optional out byte Abort,
								  optional bool bForce)
{
	local P2Weapon pickweap, checkweap, lowestweap;
	local int pickrank, checkrank, currank, lowestrank;
	local Inventory inv;
	local int Count;

	if(CurrentWeapon == None
		|| CurrentWeapon.AllowNextWeapon()
		|| bForce)
	{
		// Find the next-highest-ranked weapon after the current weapon.  If there isn't
		// one, then find the lowest-ranked weapon (in other words, wrap around).  We
		// must go through the full list anyway, so we look for both at the same time.
		if(CurrentWeapon != None)
			currank = CurrentWeapon.GetRank();
		else
			warn(self$" NO CurrentWeapon");
		pickrank = 100000;
		lowestrank = 100000;
		// Mypawnfix
		inv = Pawn.Inventory;
		while (inv != None)
		{
			checkweap = P2Weapon(inv);
			//if (checkweap != None)
			//	log(checkweap$" FindNextWeapon, has ammo "$checkweap.AmmoType.AmmoAmount);
			if (checkweap != None
				&& checkweap != pickweap
//				&& checkweap.AmmoType.HasAmmo())		// Change by Man Chrzan: xPatch 2.0
				&& checkweap.HasAmmo())					// Reloadable weapons support.
			{
				checkrank = checkweap.GetRank();
				if (checkrank > currank && checkrank < pickrank)
				{
					pickrank = checkrank;
					pickweap = checkweap;
				}
				if (checkrank < lowestrank)
				{
					lowestrank = checkrank;
					lowestweap = checkweap;
				}
			}

			if ( Level.NetMode == NM_Client )
			{
				Count++;
				if ( Count > 5000 )
				break;
			}

			inv = inv.Inventory;
		}

		if (pickweap == None)
			pickweap = lowestweap;

		NewWeap = pickweap;
	}
	else
	{
		Abort=1;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Find the next-lowest-ranked weapon (wraps around to highest-ranked weapon
// if necessary).
///////////////////////////////////////////////////////////////////////////////
simulated function FindPrevWeapon(P2Weapon CurrentWeapon, out P2Weapon NewWeap, out byte Abort,
								 optional bool bForce)
{
	local P2Weapon pickweap, checkweap, highestweap;
	local int pickrank, checkrank, currank, highestrank;
	local Inventory inv;
	local int Count;

	if(CurrentWeapon == None
		|| CurrentWeapon.AllowPrevWeapon()
		|| bForce)
	{
		// Find the next-highest-ranked weapon after the current weapon.  If there isn't
		// one, then find the lowest-ranked weapon (in other words, wrap around).  We
		// must go through the full list anyway, so we look for both at the same time.
		if(CurrentWeapon != None)
			currank = CurrentWeapon.GetRank();
		else
			warn(self$" NO CurrentWeapon");
		pickrank = -1;
		highestrank = -1;
		// Mypawnfix
		inv = Pawn.Inventory;
		while (inv != None)
		{
			checkweap = P2Weapon(inv);
			//if (checkweap != None)
			//	log(checkweap$" FindPrevWeapon, has ammo "$checkweap.AmmoType.AmmoAmount);
			if (checkweap != None
				&& checkweap != pickweap
				//&& checkweap.AmmoType.HasAmmo())							// Change by Man Chrzan: xPatch 2.0
				&& checkweap.HasAmmo())										// Reloadable weapons support.	
			{
				checkrank = checkweap.GetRank();
				if (checkrank < currank && checkrank > pickrank)
				{
					pickrank = checkrank;
					pickweap = checkweap;
				}
				if (checkrank > highestrank)
				{
					highestrank = checkrank;
					highestweap = checkweap;
				}
			}

			if ( Level.NetMode == NM_Client )
			{
				Count++;
				if ( Count > 5000 )
				break;
			}

			inv = inv.Inventory;
		}

		if (pickweap == None)
			pickweap = highestweap;

		NewWeap = pickweap;
	}
	else
	{
		Abort=1;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Find a weapon in a specific group, and remember the last weapon you were
// using in this group as the first one to pick
///////////////////////////////////////////////////////////////////////////////
simulated function FindGroupWeapon(byte FindGroup, out P2Weapon NewWeap, out byte Abort)
{
	local P2Weapon pickweap, checkweap, curweap, lowestweap;
	local int pickrank, checkrank, currank, lowestrank;
	local Inventory inv;
	local int Count;

	curweap = P2Weapon(Pawn.Weapon);
	if(curweap != None)
		currank = curweap.GetRank();
	pickrank = 100000;
	lowestrank = 100000;

	// Mypawnfix
	inv = Pawn.Inventory;

	while (inv != None)
	{
		checkweap = P2Weapon(inv);
		if(checkweap != None)
		{
			//log(checkweap$" FindGroupWeapon, has ammo "$checkweap.AmmoType.AmmoAmount);
			if(FindGroup == checkweap.InventoryGroup
			//&& checkweap.AmmoType.HasAmmo())						// Change by Man Chrzan: xPatch 2.0
			&& checkweap.HasAmmo())									// Reloadable weapons support.	
			{
				checkrank = checkweap.GetRank();
				// We disregard the last selected thing because I'm already in the right group
				// and we just look for the next one in the group
				if(curweap != None
					&& curweap.InventoryGroup == FindGroup)
				{
					if (checkrank > currank && checkrank < pickrank)
					{
						pickrank = checkrank;
						pickweap = checkweap;
					}
					if (checkrank < lowestrank)
					{
						lowestrank = checkrank;
						lowestweap = checkweap;
					}
				}
				else // In this version we were on a different group and are coming back to this one
					// so we want to either find the first in the group, or find the one that
				{
					if(checkweap.bLastSelected)
					{
						pickweap = checkweap;
						pickrank = checkrank;
					}
					if (checkrank > currank
						&& checkrank < pickrank
						&& (pickweap == None
							|| !pickweap.bLastSelected))
					{
						pickrank = checkrank;
						pickweap = checkweap;
					}
					if(checkrank < lowestrank)
					{
						lowestrank = checkrank;
						lowestweap = checkweap;
					}
				}
			}
		}

		if ( Level.NetMode == NM_Client )
		{
			Count++;
			if ( Count > 5000 )
			break;
		}

		inv = inv.Inventory;
	}

	if(pickweap == None)
		pickweap = lowestweap;


	NewWeap = pickweap;
}

///////////////////////////////////////////////////////////////////////////////
// PrevWeapon()
// switch to previous inventory group weapon
///////////////////////////////////////////////////////////////////////////////
exec function PrevWeapon()
{
	local P2Weapon CWeap, NWeap;
	local byte Abort;

	if( Level.Pauser!=None || Pawn == None )
		return;

	if ( Pawn.Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	if ( Pawn.PendingWeapon != None )
		CWeap = P2Weapon(Pawn.PendingWeapon);
	else
		CWeap = P2Weapon(Pawn.Weapon);

	FindPrevWeapon(CWeap, NWeap, Abort);

	if(Abort == 0)
	{
		Pawn.PendingWeapon = NWeap;

		if ( Pawn.PendingWeapon != None )
		{
			Pawn.Weapon.PutDown();
		}
	}	
	
	// Handle bPrevWeapon
	if (bPrevWeapon != 0 || bNextWeapon != 0)
	{
		LastWeaponChange = Level.TimeSeconds;
		RapidWeaponChange++;
	}
	else
		RapidWeaponChange = 0;
}

///////////////////////////////////////////////////////////////////////////////
// NextWeapon()
// switch to next inventory group weapon
//
///////////////////////////////////////////////////////////////////////////////
exec function NextWeapon()
{
	local P2Weapon CWeap, NWeap;
	local byte Abort;

	if( Level.Pauser!=None || Pawn == None )
		return;

	if ( Pawn.Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	if ( Pawn.PendingWeapon != None )
		CWeap = P2Weapon(Pawn.PendingWeapon);
	else
		CWeap = P2Weapon(Pawn.Weapon);

	FindNextWeapon(CWeap, NWeap, Abort);

	if(Abort == 0)
	{
		Pawn.PendingWeapon = NWeap;

		if ( Pawn.PendingWeapon != None )
		{
			Pawn.Weapon.PutDown();
		}
	}	
	
	// Handle bNextWeapon
	if (bPrevWeapon != 0 || bNextWeapon != 0)
	{
		LastWeaponChange = Level.TimeSeconds;
		RapidWeaponChange++;
	}
	else
		RapidWeaponChange = 0;
}

///////////////////////////////////////////////////////////////////////////////
// The player wants to switch to weapon group number F.
///////////////////////////////////////////////////////////////////////////////
exec function SwitchWeapon (byte F )
{
	local P2Weapon NWeap;
	local byte Abort;

	if ( (Level.Pauser!=None) || (Pawn == None) || (Pawn.Inventory == None) )
		return;
	if ( (Pawn.Weapon != None) && (Pawn.Weapon.Inventory != None) )
		FindGroupWeapon(F, NWeap, Abort);
		//newWeapon = Pawn.Weapon.Inventory.WeaponChange(F);
	else
		NWeap = None;
	if ( NWeap == None )
		FindGroupWeapon(F, NWeap, Abort);
		//newWeapon = Pawn.Inventory.WeaponChange(F);

	if ( NWeap == None )
		return;

	if ( Pawn.Weapon == None
		|| Pawn.Weapon.bDeleteMe)
	{
		Pawn.PendingWeapon = NWeap;
		Pawn.ChangedWeapon();
	}
	else if ( Pawn.Weapon != NWeap || Pawn.PendingWeapon != None )
	{
		Pawn.PendingWeapon = NWeap;
		if ( !Pawn.Weapon.PutDown() )
		{
			Pawn.PendingWeapon = None;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToBestWeapon()
{
	local float rating;

	//log(self$" switch to best "$Pawn.Weapon);
	if( Level.Pauser!=None)
		return;

	if ( Pawn == None || Pawn.Inventory == None )
		return;

	StopFiring();
	Pawn.PendingWeapon = Pawn.Inventory.RecommendWeapon(rating);
	if ( Pawn.PendingWeapon == Pawn.Weapon )
		Pawn.PendingWeapon = None;
	if ( Pawn.PendingWeapon == None )
		return;

	if ( Pawn.Weapon == None
		|| Pawn.Weapon.bDeleteMe)
		Pawn.ChangedWeapon();

	if ( Pawn.Weapon != Pawn.PendingWeapon
		&& Pawn.PendingWeapon != None)
		Pawn.Weapon.PutDown();
}

///////////////////////////////////////////////////////////////////////////////
// Different than 'find best weapon', this skips certain weapons that
// aren't good to switch to in the heat of combat.
///////////////////////////////////////////////////////////////////////////////
function bool SwitchAfterOutOfAmmo()
{
	local Inventory inv, pickinv;
	local float currat, newrat;
	local int Count;

	// Mypawnfix
	if ( Pawn.Inventory == None )
		return false;

	StopFiring();
	inv = Pawn.Inventory;

	// Combat rating
	if(P2Weapon(Pawn.Weapon) != None)
		currat = P2Weapon(Pawn.Weapon).CombatRating;
	newrat = -1;

	while(inv != None)
	{
		if(P2Weapon(inv) != None
			// Make sure it has ammo
//			&& P2AmmoInv(Weapon(inv).AmmoType).HasAmmo()					// Change by Man Chrzan: xPatch 2.0
			&& P2Weapon(inv).HasAmmo()										// Reloadable weapons support.	
			&& P2Weapon(inv).CombatRating > newrat)
		{
			newrat = P2Weapon(inv).CombatRating;
			pickinv = inv;
		}

		if ( Level.NetMode == NM_Client )
		{
			Count++;
			if ( Count > 5000 )
			break;
		}

		inv = inv.Inventory;
	}

	if(pickinv != None)
	{
		// Mypawnfix
		Pawn.PendingWeapon = Weapon(pickinv);
	}
	else
	{
		ToggleToHands();
		return false;
	}

	if ( Pawn.PendingWeapon == Pawn.Weapon )
		Pawn.PendingWeapon = None;
	if ( Pawn.PendingWeapon == None )
		return true;

	if ( Pawn.Weapon == None
		|| Pawn.Weapon.bDeleteMe)
		Pawn.ChangedWeapon();

	if ( Pawn.Weapon != Pawn.PendingWeapon
		&& Pawn.PendingWeapon != None)
		Pawn.Weapon.PutDown();

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// We've stated a weapon we want to switch to
///////////////////////////////////////////////////////////////////////////////
function bool SwitchToThisWeapon(int GroupNum, int OffsetNum, optional bool bForceReady)
{
	local Inventory inv;
	local bool bFoundIt;
	local int Count;

	// Mypawnfix
	if ( Pawn.Inventory == None )
		return false;

	StopFiring();
	inv = Pawn.Inventory;

	//log("Group num"$GroupNum);
	//log("Offset num "$OffsetNum);

	while(inv != None
		&& !bFoundIt)
	{
		//log("inv "$inv);
		//log("inv group "$inv.InventoryGroup);
		//log("inv offset "$inv.GroupOffset);
		if(Weapon(inv) != None
			&& inv.InventoryGroup == GroupNum
			&& inv.GroupOffset == OffsetNum)
			bFoundIt=true;
		else
			inv = inv.Inventory;

		if ( Level.NetMode == NM_Client )
		{
			Count++;
			if ( Count > 5000 )
			break;
		}

	}

	if(bFoundIt)
	{
		// Make sure our pending weapon has some ammo
		// Don't use HasAmmo--it checks ammo readiness. We need to simply see if it's either
		// infinite or has any ammo at all-we don't care about weapon readiness here.
//		if(!P2AmmoInv(Weapon(inv).AmmoType).HasAmmoStrict())										// Change by Man Chrzan: xPatch 2.0
		if( (!P2AmmoInv(Weapon(inv).AmmoType).HasAmmoStrict() && !P2Weapon(inv).bReloadableWeapon)	// Reloadable weapons support.
			|| (!P2Weapon(inv).HasAmmo() && P2Weapon(inv).bReloadableWeapon) )		
		{
			return false;
		}
		else
			Pawn.PendingWeapon = Weapon(inv);
	}
	else
		return bFoundIt;

	//log("success "$Pawn.PendingWeapon);
	//log("w group "$Pawn.PendingWeapon.InventoryGroup);
	//log("w offset "$Pawn.PendingWeapon.GroupOffset);
	//log("pending level "$Pawn.PendingWeapon.InventoryGroup);

	// If force ready, then make sure this weapon is set to useable (like the clipboard
	// may have turned the hands off, but we want to definitely use it so turn them
	// back on.)
	if(bForceReady
		&& P2Weapon(Pawn.PendingWeapon) != None)
		P2Weapon(Pawn.PendingWeapon).SetReadyForUse(true);

	if ( Pawn.PendingWeapon == Pawn.Weapon )
		Pawn.PendingWeapon = None;
	if ( Pawn.PendingWeapon == None )
		return bFoundIt;

	if ( Pawn.Weapon == None
		|| Pawn.Weapon.bDeleteMe)
		Pawn.ChangedWeapon();

	if ( Pawn.Weapon != Pawn.PendingWeapon
		&& Pawn.PendingWeapon != None)
		Pawn.Weapon.PutDown();

	return bFoundIt;
}

///////////////////////////////////////////////////////////////////////////////
// Given the group, find the weapon that's furtherst down in the offsets.
// For instance, group 0, should be Urethra, Hands, Clipboard. So given
// the dude always has the first two, this will switch to the hands. But on a
// day he has the clipboard, he'll pick that has his 'hands'.
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToLastWeaponInGroup(int GroupNum)
{
	local Inventory inv, last;
	local int lastoffset;
	local int Count;

	if( Level.Pauser!=None)
		return;

	if ( Pawn == None || Pawn.Inventory == None )
		return;

	StopFiring();
	inv = Pawn.Inventory;
	lastoffset = -1;

	while(inv != None)
	{
		if(Weapon(inv) != None)
		{
			//log(self$" checking "$inv$" my ammo "$Weapon(inv).AmmoType$" is ready? "$P2AmmoInv(Weapon(inv).AmmoType).bReadyForUse);
			if(Weapon(inv).AmmoType.HasAmmo())
			{
				//log(self$" has ammo "$inv);
				if(inv.InventoryGroup == GroupNum
					&& inv.GroupOffset > lastoffset)
				{
					last = inv;
					lastoffset = inv.GroupOffset;
				//log(self$" picking "$lastoffset);
				}
			}
		}

		if ( Level.NetMode == NM_Client )
		{
			Count++;
			if ( Count > 5000 )
			break;
		}

		inv = inv.Inventory;
	}

	if(last != None)
		Pawn.PendingWeapon = Weapon(last);
	else
		return;

	//log(self$" REALLY picking "$last$" pending "$Pawn.PendingWeapon$" my weap "$Pawn.Weapon$" delete me "$Pawn.Weapon.bDeleteMe);

	if ( Pawn.PendingWeapon == Pawn.Weapon )
		Pawn.PendingWeapon = None;
	if ( Pawn.PendingWeapon == None )
		return;

	if ( Pawn.Weapon == None
		|| Pawn.Weapon.bDeleteMe)
		Pawn.ChangedWeapon();

	if ( Pawn.Weapon != Pawn.PendingWeapon
		&& Pawn.PendingWeapon != None)
		Pawn.Weapon.PutDown();
}

///////////////////////////////////////////////////////////////////////////////
// We've stated an item we want to switch to
///////////////////////////////////////////////////////////////////////////////
function bool SwitchToThisPowerup(int GroupNum, int OffsetNum)
{
	local Inventory inv;
	local int Count;

	if( Level.Pauser!=None)
		return false;

	if ( Pawn.Inventory == None )
		return false;

	inv = Pawn.Inventory;

	//log("Group num"$GroupNum);
	//log("Offset num "$OffsetNum);

	while(inv != None
		&& !(inv.InventoryGroup == GroupNum
		&& inv.GroupOffset == OffsetNum))
	{
		//log("inv "$inv);
		//log("inv group "$inv.InventoryGroup);
		//log("inv offset "$inv.GroupOffset);
		inv = inv.Inventory;
		if ( Level.NetMode == NM_Client )
		{
			Count++;
			if ( Count > 5000 )
			break;
		}
	}

	if(inv != None
		&& inv.InventoryGroup == GroupNum
		&& inv.GroupOffset == OffsetNum)
	{
		if(Powerups(inv) != None)
		{
			if(Powerups(inv).bActivatable)
			{
				// Mypawnfix
				Pawn.SelectedItem = Powerups(inv);
				return true;
			}
		}
		else
			warn(self$" ERROR: SwitchToThisPowerup, inv not a powerup "$inv$" Group offset probably bad");
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// The player wants to select previous item
///////////////////////////////////////////////////////////////////////////////
exec function PrevItem()
{
	if( Level.Pauser!=None)
		return;

	if(Pawn != None
		&& Pawn.Inventory != None)
	{
		Super.PrevItem();
		InvChanged();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Tell the hud about new inventory hints
///////////////////////////////////////////////////////////////////////////////
function InvChanged()
{
	UpdateHudInvHints();
}

///////////////////////////////////////////////////////////////////////////////
// Send the hud the current inventory item's hints
///////////////////////////////////////////////////////////////////////////////
function UpdateHudInvHints()
{
	local String str1, str2, str3;
	local byte InfiniteHintTime;

	if(P2PowerupInv(MyPawn.SelectedItem) != None)
	{
		P2PowerupInv(MyPawn.SelectedItem).GetHints(MyPawn, str1, str2, str3, InfiniteHintTime);
		if(P2Hud(MyHud) != None)
			P2Hud(MyHud).SetInvHints(str1, str2, str3, InfiniteHintTime);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Turn your inventory and weapon hints on or off. If you turn them on,
// go through, and turn back on any hints that the user turned off by using them.
///////////////////////////////////////////////////////////////////////////////
exec function ToggleInvHints()
{
	local Inventory inv;

	if(Pawn != None)
	{
		// Turning them off so clear all inv hints
		if(P2GameInfo(Level.Game).bInventoryHints)
		{
			P2GameInfo(Level.Game).ClearInventoryHints();
			// Go through all your inventory and weapons and reset their hints
			// Mypawnfix
			inv = Pawn.Inventory;
			while (inv != None)
			{
				if(P2PowerupInv(inv) != None)
					P2PowerupInv(inv).RefreshHints();
				else if(P2Weapon(inv) != None)
					P2Weapon(inv).RefreshHints();
				inv = inv.Inventory;
			}
		}

		P2GameInfo(Level.Game).bInventoryHints = !P2GameInfo(Level.Game).bInventoryHints;

		// Make sure to update the hud if we're coming back on
		if(P2GameInfo(Level.Game).bInventoryHints)
		{
			UpdateHudInvHints();
			if(P2Weapon(Pawn.Weapon) != None)
				P2Weapon(Pawn.Weapon).UpdateHudHints();
			ClientMessage(HintsOnText);
		}
		else
			ClientMessage(HintsOffText);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide if we're going to put up death hint messages and whether or not
// to increment them so the player will get a different one next time.
///////////////////////////////////////////////////////////////////////////////
function IncDeathMessageNum()
{
	local int MaxDeathMessages; 
	
	if(DamageRate > MIN_DAMAGE_RATE_TO_SHOW_HINT
		&& DamageTotal > LOW_AI_DAMAGE_TOTAL
		&& !bCommitedSuicide
		&& MyPawn.DyingDamageType != class'OnFireDamage')
	{
		// xPatch: Ludicrous mode has more hints.
		if (P2GameInfoSingle(Level.Game).InLudicrousMode())
			MaxDeathMessages = DEATH_MESSAGE_MAX_LUDICROUS;
		else
			MaxDeathMessages = DEATH_MESSAGE_MAX;
		
		P2GameInfo(Level.Game).DeathMessageUseNum++;
		if(P2GameInfo(Level.Game).DeathMessageUseNum >= MaxDeathMessages)
			P2GameInfo(Level.Game).DeathMessageUseNum = 0;
		// Save which message we'll use next
		ConsoleCommand("set "@DeathMessagePath@P2GameInfo(Level.Game).DeathMessageUseNum);
	}
}

///////////////////////////////////////////////////////////////////////////////
// If you died in a manner that seems like you need help (you got shot up
// for a long time, just standing there) then return true and send out
// some helpful advice
///////////////////////////////////////////////////////////////////////////////
function bool GetDeathHints(out array<string> strs)
{
	if (MyPawn == None)
		return false;
		
	if((DamageRate > MIN_DAMAGE_RATE_TO_SHOW_HINT
			|| (MyPawn.DyingDamageType == class'OnFireDamage'
				&& !P2GameInfo(Level.Game).bPlayerPissedHimselfOut))
		&& DamageTotal > LOW_AI_DAMAGE_TOTAL
		&& !bCommitedSuicide)
	{
		// If you burned to death and have never put yourself out, give a special
		// message of hints on how to do that
		if(MyPawn.DyingDamageType == class'OnFireDamage')
		{
			if(!P2GameInfo(Level.Game).bPlayerPissedHimselfOut)
			{
				strs = FireDeathHints1;
				return true;
			}
			else
				return false;
		}
		else
		{
			// Returns a different set of hints in POSTAL mode.
			if (P2GameInfoSingle(Level.Game).InNightmareMode())
			{
				// xPatch: Ludicrous mode hints.
				if (P2GameInfoSingle(Level.Game).InLudicrousMode())
				{
					if (P2GameInfoSingle(Level.Game).InClassicMode())
						LudicrousHints1 = LudicrousHints1Alt;
					
					switch(P2GameInfo(Level.Game).DeathMessageUseNum)
					{
						case 0:
							strs = LudicrousHints1;
							break;
						case 1:
							strs = LudicrousHints2;
							break;
						case 2:
							strs = LudicrousHints3;
							break;
						case 3:
							strs = LudicrousHints4;
							break;
						case 4:
							strs = LudicrousHints5;
							break;
						case 5:
							strs = LudicrousHints6;
							break;
					}
				}
				// Impossible mode hints.
				else if (P2GameInfoSingle(Level.Game).InImpossibleMode())
					strs = ImpossibleHints;
				else
				{
					switch(P2GameInfo(Level.Game).DeathMessageUseNum)
					{
						case 0:
							strs = POSTALHints1;
							break;
						case 1:
							strs = POSTALHints2;
							break;
						case 2:
							strs = POSTALHints3;
							break;
					}
				}
			}
			else {
				switch(P2GameInfo(Level.Game).DeathMessageUseNum)
				{
					case 0:
						strs = DeathHints1;
						break;
					case 1:
						strs = DeathHints2;
						break;
					case 2:
						strs = DeathHints3;
						break;
				}
			}
			return true;
		}
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// You're getting mugged by someone
///////////////////////////////////////////////////////////////////////////////
function SetupGettingMugged(P2Pawn NewMugger)
{
	if(InterestPawn == None)
	{
		InterestPawn = NewMugger;
		GotoState('PlayerGettingMugged');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Return true if it's okay to mug you now
// Make sure you're only dealing with the mugger no one, and
// that you have some cash to take
///////////////////////////////////////////////////////////////////////////////
function bool CanBeMugged(P2Pawn NewMugger)
{
	return ((InterestPawn == NewMugger
				|| InterestPawn == None)
				&& CashPlayerHas() > 0);
}

///////////////////////////////////////////////////////////////////////////////
// Only show these when you're in getting mugged mode
///////////////////////////////////////////////////////////////////////////////
function bool GetMuggerHints(out String str1, out String str2)
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// He really means it now!
///////////////////////////////////////////////////////////////////////////////
function EscalateMugging()
{
}

///////////////////////////////////////////////////////////////////////////////
// For when the mugger wants to end with the player
///////////////////////////////////////////////////////////////////////////////
function UnhookPlayerGetMugged()
{
}

///////////////////////////////////////////////////////////////////////////////
// Returns the number of dollars the player has right now.
///////////////////////////////////////////////////////////////////////////////
function float CashPlayerHas()
{
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// Only show these when you're getting arrested
///////////////////////////////////////////////////////////////////////////////
function bool GetBriberyHints(out String str1, out String str2)
{
	// STUB -- handled in DudePlayer

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// GetSellItemHints
///////////////////////////////////////////////////////////////////////////////
function bool GetSellItemHints(out String str1, out String str2)
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Pop up the radar in the hud
///////////////////////////////////////////////////////////////////////////////
exec function ShowRadar()
{
	if( Level.Pauser!=None)
		return;

	//MYpawnfix
	if(P2Pawn(Pawn) != None)
	{
		if(RadarState != ERadarOff)
			RadarState=ERadarOff;
		else
			RadarState=ERadarOn;
		if(RadarState != ERadarOff)
		{
			if(MyHud != None)
				RadarBackY=P2Hud(MyHud).GetRadarYOffset();
			P2Pawn(Pawn).ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Pop it in, ready to start warming
///////////////////////////////////////////////////////////////////////////////
simulated function BringupRadar()
{
	if(P2Hud(MyHud) != None)
	{
		Pawn.PlaySound(RadarClickSound, SLOT_Misc, 1.0,,TransientSoundRadius);
		RadarBackY=P2Hud(MyHud).GetStartRadarY();
	}
	RadarState = ERadarBringUp;
}

///////////////////////////////////////////////////////////////////////////////
// It's powered down, not it's sitting there, ready to blink away
///////////////////////////////////////////////////////////////////////////////
simulated function DropdownRadar()
{
	Pawn.PlaySound(RadarClickSound, SLOT_Misc, 1.0,,TransientSoundRadius);
	RadarState = ERadarDropDown;
}
///////////////////////////////////////////////////////////////////////////////
// Let it warm up, and eventually turn on.
///////////////////////////////////////////////////////////////////////////////
simulated function WarmupRadar()
{
	if(P2Hud(MyHud) != None)
	{
		// Snap it up there
		RadarBackY=P2Hud(MyHud).GetRadarYOffset();
		Pawn.PlaySound(RadarBuzzSound, SLOT_Misc, 1.0,,TransientSoundRadius);
	}
	RadarState = ERadarWarmUp;
}
///////////////////////////////////////////////////////////////////////////////
// Let it cool down, ready to turn off
///////////////////////////////////////////////////////////////////////////////
simulated function CooldownRadar()
{
	RadarState = ERadarCoolDown;
}
///////////////////////////////////////////////////////////////////////////////
// Power it along more
// RadarAmount is how much energy left the radar has.
// If you are in targetting mode, it will
// simply report this to the radar, and it won't take any battery time from you.
///////////////////////////////////////////////////////////////////////////////
simulated function bool BoostRadar(int RadarAmount)
{
	if(RadarState != ERadarOn)
	{
		RadarState = ERadarOn;
		//Mypawnfix
		P2Pawn(Pawn).ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
	}
	// Not using targetting, so take battery time
	if(RadarTargetState == 0)
		return true;
	else	// In targetting mode, so supspend battery time.
		return false;
}
///////////////////////////////////////////////////////////////////////////////
// Shut off immediately with no cool down.
///////////////////////////////////////////////////////////////////////////////
simulated function ShutoffRadar()
{
	RadarState = ERadarOff;
	// Turn off RadarTarget too if you have it up
	EndRadarTarget();
}
///////////////////////////////////////////////////////////////////////////////
// These are for P2HUD to decide what/when to show things
///////////////////////////////////////////////////////////////////////////////
simulated function bool ShowRadarBackOnly()
{
	if(RadarState == ERadarBringUp
		|| RadarState == ERadarDropDown)
		return true;
	return false;
}
simulated function bool ShowRadarBringingUp()
{
	return (RadarState == ERadarBringUp);
}
simulated function bool ShowRadarDroppingDown()
{
	return (RadarState == ERadarDropDown);
}
simulated function bool ShowRadarFlicker()
{
	if(RadarState == ERadarWarmUp
		|| RadarState == ERadarCoolDown)
		return true;
	return false;
}
simulated function bool ShowRadarFull()
{
	if(RadarState == ERadarOn)
		return true;
	return false;
}
simulated function bool ShowRadarAny()
{
	if(RadarState != ERadarOff)
		return true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Handles the radar's ability to recognize cops
///////////////////////////////////////////////////////////////////////////////
simulated function SetRadarShowCops(bool bNewState)
{
	bRadarShowCops=bNewState;
}
///////////////////////////////////////////////////////////////////////////////
// Handles the radar's ability to recognize concealed weapons
///////////////////////////////////////////////////////////////////////////////
simulated function SetRadarShowGuns(bool bNewState)
{
	bRadarShowGuns=bNewState;
}

///////////////////////////////////////////////////////////////////////////////
// Setup the camera on the rocket that's travelling now
///////////////////////////////////////////////////////////////////////////////
function StartViewingRocket(Actor NewRocket)
{
	SetViewTarget(NewRocket);
	ViewTarget.BecomeViewTarget();
	GotoState('PlayerWatchRocket');
}

///////////////////////////////////////////////////////////////////////////////
// Restore the player as the view target
///////////////////////////////////////////////////////////////////////////////
function StopViewingRocketOrTarget()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Tell rocket what input for movement the player is giving
///////////////////////////////////////////////////////////////////////////////
function ModifyRocketMotion(out float PlayerTurnX, out float PlayerTurnY)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// The rocket blew up
///////////////////////////////////////////////////////////////////////////////
function RocketDetonated(Actor HitThing)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// If our rocket is in the state without gas, we say so
///////////////////////////////////////////////////////////////////////////////
function bool RocketHasGas()
{
	if(P2Projectile(ViewTarget) != None)
		return P2Projectile(ViewTarget).AllowControl();
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool StartRadarTarget()
{
	//Mypawnfix
	if(Pawn.Health > 0
		&& Pawn.Physics == PHYS_Walking
		&& RadarState == ERadarOn
		&& RadarTargetState == ERTargetOff
		&& InterestPawn == None)
	{
		// Reset target position
		RadarTargetX = 0;
		RadarTargetY = 0;
		RadarTargetState=ERTargetPaused;
		RadarTargetTimer = RADAR_TARGET_START_TIME;
		RadarTargetAnimTime=TARGET_FRAME_TIME;
		GotoState('PlayerRadarTargetting');
		return true;
	}
	return false;
}

function EndRadarTarget()
{
	if(RadarTargetState != ERTargetOff)
	{
		RadarTargetState=ERTargetOff;
		GotoState('PlayerWalking');
	}
}
// Radar targetting system is waiting for someone to play
// or they are currently playing
function bool RadarTargetReady()
{
	if(RadarTargetState > ERTargetOff
		&& RadarTargetState <= ERTargetOn
		&& ViewTarget == MyPawn)
		return true;
	return false;
}
// We're focussed on someone else, killing them
function bool RadarTargetKilling()
{
	if(RadarTargetState > ERTargetOn
		&& ViewTarget != MyPawn)
		return true;
	return false;
}
// We're done targetting, showing stats now
function bool RadarTargetStats()
{
	if((RadarTargetState == ERTargetStats
			|| RadarTargetState == ERTargetStatsWait)
		&& ViewTarget == MyPawn)
		return true;
	return false;
}
// You're ready for input after stats
function bool RadarTargetStatsGetInput()
{
	if(RadarTargetState == ERTargetStats
		&& ViewTarget == MyPawn)
		return true;
	return false;
}

function int RadarTargetKillHint()
{
	return (RadarTargetState - ERTargetKilling1);
}

function bool RadarTargetWaiting()
{
	return (RadarTargetState == ERTargetWaiting);
}

function bool RadarTargetIsOn()
{
	return (RadarTargetState == ERTargetOn);
}

function float GetRadarTargetTimer()
{
	return RadarTargetTimer;
}

function bool RadarTargetNotStartedYet()
{
	return(RadarTargetTimer == RADAR_TARGET_START_TIME);
}

function int GetRadarTargetFrame()
{
	return RadarTargetAnimTime/TARGET_FRAME_TIME;
}
function TargetKillsPawn(FPSPawn KillMe)
{
	// STUB--defined in PlayerRadarTargetting
}
function SetupTargetPrizeTextures()
{
	// STUB--defined in DudePlayer
}

///////////////////////////////////////////////////////////////////////////////
// Return the inventory item, but don't switch to it
///////////////////////////////////////////////////////////////////////////////
function Inventory GetInv(int GroupNum, int OffsetNum)
{
	local Inventory inv;

	if ( Pawn.Inventory == None )
		return None;

	inv = Pawn.Inventory;

	while(inv != None
		&& !(inv.InventoryGroup == GroupNum
		&& inv.GroupOffset == OffsetNum))
	{
		//log("inv "$inv);
		//log("inv group "$inv.InventoryGroup);
		//log("inv offset "$inv.GroupOffset);
		inv = inv.Inventory;
	}

	return inv;
}

///////////////////////////////////////////////////////////////////////////////
// Like Controller HandlePickup, we can take a pickup class
///////////////////////////////////////////////////////////////////////////////
function HandlePickupClass(class<Pickup> pclass)
{
	ReceiveLocalizedMessage( pclass.default.MessageClass,
							0, None, None, pclass );
}

///////////////////////////////////////////////////////////////////////////////
// Go through all your weapons and change out the hands texture for this new one
///////////////////////////////////////////////////////////////////////////////
function ChangeAllWeaponHandTextures(Texture NewHandsTexture, Texture NewFootTexture)
{
	local Inventory inv;
	local int Count; // Change by NickP: bail out fix

	//Mypawnfix
	inv = Pawn.Inventory;

	// Do all the weapons in your inventory
	while(inv != None)
	{
		if(P2Weapon(inv) != None)
		{
			P2Weapon(inv).ChangeHandTexture(NewHandsTexture, DefaultHandsTexture, NewFootTexture);
		}
		inv = inv.Inventory;

		// Change by NickP: bail out fix
		Count++;
		if ( Count > 5000 )
			break;
		// End
	}
	if(P2Pawn(Pawn) != None
		&& P2Pawn(Pawn).MyFoot != None)
	{
		// Now do your foot
		P2Pawn(Pawn).MyFoot.ChangeHandTexture(NewHandsTexture, DefaultHandsTexture, NewFootTexture);
	}
}

// If we get a weapon pickup, update our weapon speeds
function HandlePickup(Pickup pick)
{
	Super.HandlePickup(Pick);
	if (P2WeaponPickup(pick) != None)
		ChangeAllWeaponSpeeds(1.0);
}

///////////////////////////////////////////////////////////////////////////////
// Go through all your weapons and modify their speeds
///////////////////////////////////////////////////////////////////////////////
function ChangeAllWeaponSpeeds(float NewSpeed)
{
	local Inventory inv;
	local float AdditionalMult;

	if (P2GameInfoSingle(Level.Game).TheGameState.bTheQuick)
		NewSpeed *= QUICK_MULT;

	//Mypawnfix
	inv = Pawn.Inventory;

	// Do all the weapons in your inventory
	while(inv != None)
	{
		if(P2Weapon(inv) != None)
		{
			P2Weapon(inv).ChangeSpeed(NewSpeed);
		}
		inv = inv.Inventory;
	}
	if(P2Pawn(Pawn) != None
		&& P2Pawn(Pawn).MyFoot != None)
	{
		// Now do your foot
		P2Pawn(Pawn).MyFoot.ChangeSpeed(NewSpeed);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check if we can use these clothes and they aren't the same as what we
// have on, if so, change them.
///////////////////////////////////////////////////////////////////////////////
function bool CheckForChangeClothes(class<Inventory> NewClothesClass)
{
	//	STUB--check dudeplayer
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// After a level change we have to re-clothe you with the clothes you left
// with (we don't save all the skin changes across a level transition--we just
// save what you were wearing when you left, so now we have to redo it)
// CurrentClothes is saved by the gamestate. Check it against default dude
// clothes, and if it's different, change them. (But with no screen fade
// and no level transition
///////////////////////////////////////////////////////////////////////////////
function SetClothes(class<Inventory> NewClothesClass)
{
	//	STUB--check dudeplayer
}

///////////////////////////////////////////////////////////////////////////////
// Change the dudes clothes from what they are now, to the this new clothing
// type, and if specified, keep the old clothes in his inventory
///////////////////////////////////////////////////////////////////////////////
function ChangeToNewClothes()
{
	//	STUB--check dudeplayer
}

///////////////////////////////////////////////////////////////////////////////
// Just finished putting my clothes on, say something funny
///////////////////////////////////////////////////////////////////////////////
function FinishedPuttingOnClothes()
{
	//	STUB--check dudeplayer
}

///////////////////////////////////////////////////////////////////////////////
// I just finished dressing as the cop, so say something
///////////////////////////////////////////////////////////////////////////////
function BecomingCop()
{
	SayTime = MyPawn.Say(MyPawn.myDialog.lDude_BecomingCop) + 0.5;

	SetTimer(SayTime, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// I just finished dressing as the cop, so say something
///////////////////////////////////////////////////////////////////////////////
function NowIsCop()
{
	SayTime = MyPawn.Say(MyPawn.myDialog.lDude_NowIsCop) + 0.5;

	SetTimer(SayTime, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// I just finished dressing back as Dude, so say something
///////////////////////////////////////////////////////////////////////////////
function NowIsDude()
{
	SayTime = MyPawn.Say(MyPawn.myDialog.lDude_NowIsDude) + 0.5;

	SetTimer(SayTime, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// I just finished dressing back as Gimp, so say something
///////////////////////////////////////////////////////////////////////////////
function NowIsGimp()
{
}

///////////////////////////////////////////////////////////////////////////////
// I'm dressed as boring old me...
///////////////////////////////////////////////////////////////////////////////
function bool DudeIsDude()
{
	//	STUB--check dudeplayer
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// I'm dressed a cop! (for ai use)
///////////////////////////////////////////////////////////////////////////////
function bool DudeIsCop()
{
	//	STUB--check dudeplayer
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// I'm dressed the gimp! (for ai use)
///////////////////////////////////////////////////////////////////////////////
function bool DudeIsGimp()
{
	//	STUB--check dudeplayer
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Errand Code start

///////////////////////////////////////////////////////////////////////////////
// You finished an errand early, not really doing it well
///////////////////////////////////////////////////////////////////////////////
function ErrandIsCloseEnough()
{
	// noise for the moment of getting gas on you
	SayTime = MyPawn.Say(MyPawn.myDialog.lDude_CloseEnough) + 0.5;

	SetTimer(SayTime, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// You dropped something important
///////////////////////////////////////////////////////////////////////////////
function NeedThatForAnErrand()
{
	MyPawn.Say(MyPawn.myDialog.lDude_NeedsItem);
}

// Errand Code end
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Search around this spot, in limited fashion for the teleporter we just came from
// Find closest one!
///////////////////////////////////////////////////////////////////////////////
function Telepad TelepadWeCameFrom(vector TLoc)
{
	local Telepad closet, checkt;
	local float closer, checkr;

	closer = GRAB_TELEPORTER_RADIUS;

	foreach RadiusActors(class'Telepad', checkt, GRAB_TELEPORTER_RADIUS, TLoc)
	{
		checkr = VSize(checkt.Location - TLoc);
		if(checkr < closer)
		{
			closer = checkr;
			closet = checkt;
		}
	}

	return closet;
}

///////////////////////////////////////////////////////////////////////////////
// This gets called before the player is sent to another level
///////////////////////////////////////////////////////////////////////////////
function PreTravel()
{
	local int i;
	local P2Screen screen;
	local Inventory inv;
	local P2WeaponPickup Pick;

    // Checks window state
	CheckWindowState();

	// Tell screens
	for (i = 0; i < Player.LocalInteractions.Length; i++)
	{
		screen = P2Screen(Player.LocalInteractions[i]);
		if (screen != None)
			screen.PreTravel();
	}

	// This used to access none because of no Pawn check after a restart
	// level load (spacebar on death)
	if(Pawn != None)
	{
		// Tell your weapons
		inv = Pawn.Inventory;
		while(inv != None)
		{
			if(P2Weapon(inv) != None)
				P2Weapon(inv).PreTravel();
			inv = inv.Inventory;
		}
		
		// See if we left the clipboard at the police station
		foreach DynamicActors(class'P2WeaponPickup', Pick)
		{
			Pick.PreTravel(Pawn);
		}
	}	
}

// Check to see if the window matches up with the ini setting.
// (Checks fullscreen/windowed)
function CheckWindowState()
{
    local bool ConsoleState, INIState;
    //log("Checking Window State");

    ConsoleState = bool(ConsoleCommand("GetFullScreen"));
    INIState     = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager StartupFullscreen"));

    //log("False means window mode.");
    //log("Console state  : "$ConsoleState);
    //log("INI state      : "$INIState);

    // If they're not the same we can safely use Console State.
    if(ConsoleState != INIState)
    {
        //log("Setting INI value as "$ConsoleState);
        ConsoleCommand("set ini:Engine.Engine.ViewportManager StartupFullscreen "$ConsoleState);
    }
}


/*
///////////////////////////////////////////////////////////////////////////////
// If the player came in at a player start, make sure it's the right one for
// this day. We need the GameState to do this, that's why we wait
// till TravelPostAccept to check. It may be that the one he's at
// is only to be used for a demo day, or later day, so pick him up and move him
// if this is the case. We don't mess with teleporters/telepads/telemarketers--
// we assume those are correctly linked for the various days.
///////////////////////////////////////////////////////////////////////////////
function WarpPlayerToProperStart()
{
	local float BestRating, NewRating;
	local NavigationPoint np, BestStart;
	local byte Needed, SpecifiedDay;

	if(PlayerStart(StartSpot) != None)
	{
		P2GameInfoSingle(Level.Game).NeededForThisDay(StartSpot, Needed, SpecifiedDay);
		if(Needed == 0)
		{
			// The player start he's at is bad for this day.. move him
			for ( np=Level.NavigationPointList; np!=None; np=np.NextNavigationPoint )
			{
				// We don't know the InTeam var here, so we don't specify it
				NewRating = Level.Game.RatePlayerStart(np,0,self);
				P2GameInfoSingle(Level.Game).NeededForThisDay(np, Needed, SpecifiedDay);
				if(Needed==1)
					NewRating+=10000;
				if ( NewRating > BestRating )
				{
					BestRating = NewRating;
					BestStart = np;
				}
			}
			if(BestStart != None)
			{
				if(Pawn.SetLocation(BestStart.Location))
				{
					Pawn.SetRotation(BestStart.Rotation);
					StartSpot=BestStart;
				}
			}
			else
				warn("Playerstart was bad for this day, but we couldn't find a new/valid one");
		}

	// Trigger the event associated with the correct playerstart
	TriggerEvent( StartSpot.Event, StartSpot, Pawn);
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// Called after travel to a new level
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	local vector Loc, UseLoc;
	local Telepad tpad;
	local int i;
	local P2Screen screen;
	
	//log("Strict IGT: TravelPostAccept level time is"@Level.GetMillisecondsNow());

	if ( MyPawn.Health <= 0 )
		MyPawn.Health = MyPawn.Default.Health;

	// Reposition based on offset from teleporter before the level change
	tpad = TelepadWeCameFrom(MyPawn.Location);
	if(tpad != None && tpad.tmarker != None)
		UseLoc = tpad.tmarker.Location;
	else
		UseLoc = MyPawn.Location;

	// Now make sure he snaps to the ground nicely.
	Loc = MyPawn.FindBestLocAfterTeleport(UseLoc, UseLoc, MyPawn.CollisionHeight);
	MyPawn.SetLocation(Loc);

	// Give the game a chance to do some special stuff after a travel
	if (P2GameInfoSingle(Level.Game) != None)
		P2GameInfoSingle(Level.Game).PostTravel(MyPawn);

	// Ask the Game Mod if they want to do anything.
	P2GameInfoSingle(Level.Game).BaseMod.ModifyPlayer(Pawn);

	// Add default inventory UNLESS we're loading a saved game, in which case
	// the player will already have everything he's supposed to have
	if (P2GameInfoSingle(Level.Game) == None || !P2GameInfoSingle(Level.Game).bLoadedSavedGame)
		{
		//Log("TravelPostAccept(): Calling AddDefaultInventory");
		MyPawn.AddDefaultInventory();
		P2GameInfoSingle(Level.Game).BaseMod.ModifyPlayerInventory(Pawn);
		}
	//else
		//Log("TravelPostAccept(): Not calling AddDefaultInventory");
		
	// Tell screens about it (this must be after the game state is valid)
	for (i = 0; i < Player.LocalInteractions.Length; i++)
		{
		screen = P2Screen(Player.LocalInteractions[i]);
		if (screen != None)
			screen.PostTravel();
		}

	// If we we're preparing to save, get us out of that
	if(IsInState('PlayerPrepSave'))
	{
		ExitPrepToSave();
	}

	// Classic debug message that must never be removed for any reason.
	if(MyPawn.MyUrethra == None)
		warn("I'm a p2pawn and I have no urethra "$self);

	ChangeAllWeaponSpeeds(1.0);
//	WarpPlayerToProperStart();

	// Reset coolness
	bIsCool = false;
}

///////////////////////////////////////////////////////////////////////////////
// doused himself with gas
///////////////////////////////////////////////////////////////////////////////
function DousedHimselfInGas()
{
	if(!bStillTalking)
	{
		// noise for the moment of getting gas on you
		SayTime = MyPawn.Say(MyPawn.myDialog.lPissOnSelf) + 0.5;

		SetTimer(SayTime, false);
		bStillTalking=true;
		// only needs to be set once, really
		MyPawn.bExtraFlammable=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// pissed on himself
///////////////////////////////////////////////////////////////////////////////
function PissedOnHimself()
{
	if (AttachedCat != None && !AttachedCat.bDeleteMe)
		return;

	if(!bStillTalking
		&& P2Pawn(Pawn) != None)
	{
		// You weren't on fire.. you were just stupid, pissing on yourself
		if(P2Pawn(Pawn).MyBodyFire == None)
		{
			// cough and spit, because hey, that's pretty gross
			SayTime = P2Pawn(Pawn).Say(P2Pawn(Pawn).myDialog.lPissOnSelf) + 0.5;
			// Kamek 5-1
			// Give them an achievement because why not
			if(Level.NetMode != NM_DedicatedServer ) GetEntryLevel().EvaluateAchievement(Self,'ChokedOnPiss');

			// Wait a little longer than the dialogue time, so it won't come back in and terminate
			// the piss stream again if you just keep pissing straight up
			SetTimer(SayTime + AFTER_SPITTING_WAIT_TIME, false);
			bStillTalking=true;

			// Assume you're using your urethra here, since you peed on yourself
			P2Weapon(Pawn.Weapon).ForceEndFire();
			P2Weapon(Pawn.Weapon).UseWaitTime = SayTime;
			Pawn.Weapon.GotoState('WaitAfterStopping');
		}
		else
		{
			// The fluid soothes your burning body (at puts out the fire)
			SayTime = P2Pawn(Pawn).Say(P2Pawn(Pawn).myDialog.lPissOutFireOnSelf) + 0.5;
			SetTimer(2*SayTime, false);
			bStillTalking=true;
			bStillYelling=true;	// This ensures that he doesn't overwrite this
				// with yells of pain (as he gets hurt by the fire he's putting out)
			// Record that you figured out how to piss yourself out
			P2GameInfo(Level.Game).bPlayerPissedHimselfOut=true;
			ConsoleCommand("set "@PissedMeOutPath@P2GameInfo(Level.Game).bPlayerPissedHimselfOut);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Player wants to kill himself but not hurt others. Happens instantly
// with no going back.
///////////////////////////////////////////////////////////////////////////////
exec function Aneurism()
{
	if( Level.Pauser!=None)
		return;

	//log(self$" Aneurism ");

	// Mypawnfix
	if(P2Pawn(Pawn) != None
		&& !P2Pawn(Pawn).bPlayerStarting
		&& Pawn.Health > 0
		&& Pawn.Physics == PHYS_Walking
		&& (!(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
			|| P2Player(MyPawn.Controller) == self))	// so you can't do this in a movie
	{
		ServerAneurism();
	}
}
function ServerAneurism()
{
	// Kill the pawn
	Pawn.Health = 0;
	Pawn.Died( None, class'Suicided', Pawn.Location );
}

///////////////////////////////////////////////////////////////////////////////
// Player wants to kill himself. Check to initiate suicide sequence
//
///////////////////////////////////////////////////////////////////////////////
exec function Suicide()
{
	if( Level.Pauser!=None)
		return;

	//log(self$" suicide ");

	// Mypawnfix
	if(P2Pawn(Pawn) != None
		&& !P2Pawn(Pawn).bPlayerStarting
		&& Pawn.Health > 0
		&& Pawn.Physics == PHYS_Walking
		&& (!(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
			|| P2Player(MyPawn.Controller) == self))	// so you can't do this in a movie
	{
		GotoState('PlayerSuicideByGrenade');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Suicide call is done on the client, so make sure the server handles travelling
// to the next state.
///////////////////////////////////////////////////////////////////////////////
function ServerPerformSuicide()
{
	GotoState('PlayerSuicidingByGrenade');
}

///////////////////////////////////////////////////////////////////////////////
// Cancel suicide call is done on the client, so make sure the server handles travelling
// to the next state.
///////////////////////////////////////////////////////////////////////////////
function ServerCancelSuicide()
{
	// Steven: Allow if we're able to exit the suicide state.
	if(Level.Game != None /*&& !FPSGameInfo(Level.Game).bIsSinglePlayer*/)
		Pawn.bCanPickupInventory = true;

	GotoState('PlayerWalking');
}

///////////////////////////////////////////////////////////////////////////////
// Client must get back to normal also
///////////////////////////////////////////////////////////////////////////////
simulated function ClientCancelSuicide()
{
	GotoState('PlayerWalking');
	//if(Level.Game == None
		//|| !Level.Game.bIsSinglePlayer)
		ServerCancelSuicide();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function WeaponZoom()
{
	if( Level.Pauser!=None)
		return;

	if ( (Pawn != None) && (Pawn.Weapon != None) )
		Pawn.Weapon.Zoom();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function WeaponZoomIn()
{
	if( Level.Pauser!=None)
		return;

	if ( (Pawn != None) && (P2Weapon(Pawn.Weapon) != None) )
		P2Weapon(Pawn.Weapon).ZoomIn();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function WeaponZoomOut()
{
	if( Level.Pauser!=None)
		return;

	if ( (Pawn != None) && (P2Weapon(Pawn.Weapon) != None) )
		P2Weapon(Pawn.Weapon).ZoomOut();
}

///////////////////////////////////////////////////////////////////////////////
// The player unzips his pants, and prepares his urethra for peeing.
// The Fire button makes him actually pee.
///////////////////////////////////////////////////////////////////////////////
exec function UseZipper( optional float F )
{
	//STUB
	// Defined in DudePlayer where it has access to the urethra weapon type.
}

///////////////////////////////////////////////////////////////////////////////
// Search through the players inventory and use the most powerful health he has.
///////////////////////////////////////////////////////////////////////////////
exec function QuickHealth()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Said a Corey Line
///////////////////////////////////////////////////////////////////////////////
function SaidCoreyLine(float Duration); // STUB

///////////////////////////////////////////////////////////////////////////////
// You're not talking anymore
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	local int soundindex;

	// We haven't said our thing yet
	if(bWaitingToTalk
		&& P2Pawn(Pawn) != None)
	{
		// Handle quick kills
		if(DelayedSaySound != None)
		{
			MyPawn.PlaySound(DelayedSaySound, SLOT_Talk, 1.0,,, MyPawn.VoicePitch);
			SayTime = GetSoundDuration(DelayedSaySound) / MyPawn.VoicePitch;
			DelayedSaySound=None;
		}
		// We're about to do a line about 'and one for yer...'
		else if(DelayedSayLine == QuickKillLine)
		{
			if(!bQuickKilling
				&& QuickKillSoundIndex >= QUICK_KILL_MAX)
			{
				//mypawnfix
				SayTime = P2Pawn(Pawn).Say(DelayedSayLine, , true, QUICK_KILL_MAX-1) + 0.5;
			}
			else
			{
				soundindex = QuickKillSoundIndex;
				//log(self$" quick kill index "$QuickKillSoundIndex);
				QuickKillSoundIndex++;
				if(QuickKillSoundIndex >= QUICK_KILL_MAX)
				{
					bQuickKilling=false;
					// Make a noise first, showing that it's over
					Pawn.PlaySound(QuickKillGoodEndSound, SLOT_Misc);
					// Then set up the timer for after the noise to make
					// him say the last thing.
					DelayedSayLine = QuickKillLine;
					SayTime = GetSoundDuration(QuickKillGoodEndSound);
					SetTimer(SayTime, false);
					bStillTalking=true;
					// Kamek 5-1 - award an achievement!
					if(Level.NetMode != NM_DedicatedServer ) GetEntryLevel().EvaluateAchievement(Self,'MonsterKill');
					return; // don't keep going after this
				}
				else
					SayTime = P2Pawn(Pawn).Say(DelayedSayLine, , true, soundindex) + 0.5;
			}
		}
		else // Handle normal lines
			SayTime = P2Pawn(Pawn).Say(DelayedSayLine) + 0.5;

		bWaitingToTalk=false;	// Now that we've said it, reset
		DelayedSayLine = P2Pawn(Pawn).myDialog.lDude_KillWithGun; // 'reset' the line (to something typical)
		SetTimer(SayTime, false);
	}
	else
	{
		bStillTalking=false;
		bStillYelling=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Server get down for MP
///////////////////////////////////////////////////////////////////////////////
function ServerGetDown()
{
	local FPSPawn CheckP;
	local int peoplecount;
	local byte StateChange;

	//mypawnfix
	if(P2Pawn(Pawn) == None)
		return;

	// don't allow this to unpause the game
	if ( Level.Pauser == PlayerReplicationInfo )
		return;

	if(!bStillTalking
		&& P2Pawn(Pawn).myDialog != None)
	{
		// shout it!
		//log("-----------------------dude dialogue: Get Down!");
		// This is about how long it takes him to shout this. So
		// don't let people shout it while he's already shouting it.
		if(Level.Game != None
			&& Level.Game.bIsSinglePlayer)
			SayTime = P2Pawn(Pawn).Say(P2Pawn(Pawn).myDialog.lGetDown) + 0.5;
		else
			SayTime = P2Pawn(Pawn).Say(P2Pawn(Pawn).myDialog.lGetDownMP) + 0.5;
		SetTimer(SayTime, false);
		bStillTalking=true;
		bShoutGetDown=0;
		// Now tell the people around you that it happened.

		// First send the message to people to get down. In the process,
		// count how many people heard me.
		peoplecount=0;
		ForEach RadiusActors(class'FPSPawn', CheckP, DUDE_SHOUT_GET_DOWN_RADIUS, Pawn.Location)
		{
			if(CheckP != Pawn
				&& LambController(CheckP.Controller) != None)
			{
				// Tell them who's shouting
				StateChange = 0;
				LambController(CheckP.Controller).RespondToTalker(MyPawn, P2Pawn(Enemy), TALK_getdown, StateChange);
				peoplecount++;
			}
		}
		// You could check peoplecount here and then say something
		// funny like "i'm talking to myself" if no one heard you.
	}
}

///////////////////////////////////////////////////////////////////////////////
// dude shouts out "Get Down"
///////////////////////////////////////////////////////////////////////////////
exec function DudeShoutGetDown( optional float F )
{
	ServerGetDown();
}

///////////////////////////////////////////////////////////////////////////////
// Record how long the player has been playing and decide if he's looked
// at the map enough. If he hasn't and it's the first day, we figure he doesn't
// know what he's doing, so we will eventually tell him to look at the map to
// grasp the idea of completing errands in the game.
///////////////////////////////////////////////////////////////////////////////
function CheckMapReminder(float TimePassed)
{
	// Only allow this in SP
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfo(Level.Game).AllowReminderHints())
	{
		TimeSinceErrandCheck += TimePassed;
		//log(self$" non-map time "$TimeSinceErrandCheck$" count "$MapReminderCount);
		if(TimeSinceErrandCheck >= TimeForMapReminder)
		{
			MapReminderCount++;

			if(MapReminderCount < CHECKMAP_HINT1_TIME)
				SendHintText(CheckMapText1, MAP_REMINDER_HINT_TIME);
			else if(MapReminderCount < CHECKMAP_HINT2_TIME)
				SendHintText(CheckMapText2, MAP_REMINDER_HINT_TIME);
			else if(MapReminderCount < CHECKMAP_HINT3_TIME)
				SendHintText(CheckMapText3, MAP_REMINDER_HINT_TIME);
			else
				SendHintText(CheckMapText4, MAP_REMINDER_HINT_TIME);

			//log(self$" Player needs to check the map! "$TimeSinceErrandCheck);
			// Set the time back so it will pause the message, but then
			// show another again, after a short time (unless, of course, the
			// player does something to reset the reminders)
			TimeSinceErrandCheck= TimeForMapReminder - MapReminderRefresh;
			if(MapReminderRefresh > MIN_MAP_REMINDER_REFRESH)
				MapReminderRefresh-=MIN_MAP_REMINDER_DEC;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// The player has done something that could have vaguely reminded him that
// he has errands to complete (like he checked the map, completed and errand, etc)
///////////////////////////////////////////////////////////////////////////////
function ResetMapReminder(optional bool bTurnOffHints)
{
	TimeSinceErrandCheck=0;
	MapReminderCount=0;
	MapReminderRefresh = default.MapReminderRefresh;
	P2Hud(myHUD).ClearTextMessages();

	// Eventually, it seemed like the reminder during the demo came up too
	// much, so now we turn it off when you check it once.
	if(bTurnOffHints)
	{
		P2GameInfo(Level.Game).SetErrandReminder(false);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Forces the time forward to show a reminder now. Continues to show them
// like normal functionality, until the player checks the map
///////////////////////////////////////////////////////////////////////////////
function TriggerMapReminder()
{
	TimeSinceErrandCheck = TimeForMapReminder;
	CheckMapReminder(0.0);
}

///////////////////////////////////////////////////////////////////////////////
// If true, the player needs to be reminded of the errands he's to complete.
///////////////////////////////////////////////////////////////////////////////
function bool RemindPlayerOfErrands()
{
	return (MapReminderCount > 0);
}

///////////////////////////////////////////////////////////////////////////////
// You're ready to take down signatures
///////////////////////////////////////////////////////////////////////////////
function bool ClipboardReady()
{
	// STUB define in dudeplayer
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Dude is asking for money to be donated to him or a charity
///////////////////////////////////////////////////////////////////////////////
function DudeAskForMoney(vector AskPoint, float AskRadius, Actor HitActor, bool bIsForCharity)
{
	// STUB define in dudeplayer
}

///////////////////////////////////////////////////////////////////////////////
// Get a certain amount of money to be given to us
///////////////////////////////////////////////////////////////////////////////
function DudeTakeDonationMoney(int MoneyToGet, bool bIsForCharity)
{
	// STUB define in dudeplayer so we can access clipboard weapon
}

///////////////////////////////////////////////////////////////////////////////
// Make the dude reach out and grab money
///////////////////////////////////////////////////////////////////////////////
function GrabMoneyPutInCan(int MoneyToGet)
{
	// STUB define in dudeplayer so we can access clipboard weapon
}

///////////////////////////////////////////////////////////////////////////////
// Get mad because someone didn't donate to you
///////////////////////////////////////////////////////////////////////////////
function LostDonation()
{
	// ignore still talking and talk over it
	SayTime = MyPawn.Say(MyPawn.myDialog.lDude_CollectBalk) + 0.5;
	SetTimer(SayTime, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// set him on fire
///////////////////////////////////////////////////////////////////////////////
function CatchOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	//log("i'm on fire");
}

///////////////////////////////////////////////////////////////////////////////
// Use this to update our trail on the map
///////////////////////////////////////////////////////////////////////////////
function PlayerTick(float DeltaTime)
{
	local int Yaw;

	// Change by NickP: MP fix
	CheckPlayerValid();
	// End

	Super.PlayerTick(DeltaTime);

	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
	{
		if (MyMapScreen != None && Pawn != None)
		{
			// If pawn is moving then use direction it's moving in, otherwsie use direction it's facing
			if (VSize(Pawn.Velocity) > 0.0)
				Yaw = Rotator(Normal(Pawn.Velocity)).Yaw;
			else
				Yaw = Pawn.Rotation.Yaw;
			MyMapScreen.UpdateTrail(Pawn.Location, Yaw);
		}
	}
	
	// Handle fast weapon changes
	if (bNextWeapon != 0 && (
		((Level.TimeSeconds - LastWeaponChange > WEAPONCHANGEWAIT_FIRST) && RapidWeaponChange == 1) ||
		((Level.TimeSeconds - LastWeaponChange > WEAPONCHANGEWAIT_FAST) && RapidWeaponChange > 1)))
		NextWeapon();

	if (bPrevWeapon != 0 && (
		((Level.TimeSeconds - LastWeaponChange > WEAPONCHANGEWAIT_FIRST) && RapidWeaponChange == 1) ||
		((Level.TimeSeconds - LastWeaponChange > WEAPONCHANGEWAIT_FAST) && RapidWeaponChange > 1)))
		PrevWeapon();
		
	if (bNextWeapon == 0 && bPrevWeapon == 0)
		RapidWeaponChange = 0;
}

// Map calls this to get player's location (where he is on the map)
function vector GetMapLocation()
	{
	// If pawn doesn't exist then use controller as a backup
	if (Pawn != None)
		return Pawn.Location;
	return Location;
	}

// Map calls this to get player's direction (which way he's facing on the map)
function int GetMapDirection()
	{
	// If pawn doesn't exist then use controller as a backup
	if (Pawn != None)
		return Pawn.Rotation.Yaw;
	return Rotation.Yaw;
	}

///////////////////////////////////////////////////////////////////////////////
// Player doesn't have the map selected, but wants to use it now anyway
///////////////////////////////////////////////////////////////////////////////
exec function QuickUseMap()
{
	// STUB--handled in dude player
}

///////////////////////////////////////////////////////////////////////////////
// Player wants to look at map, make sure it's okay to do it now.
///////////////////////////////////////////////////////////////////////////////
function RequestMap()
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{

		// REMOVED: So you could do all these things while requesting the map
		// Don't allow while jumping or firing a weapon
		//if ((Pawn.Physics != PHYS_Falling) && !(Pawn.Weapon != None && !Pawn.Weapon.IsInState('Idle')))


			if (!MyMapScreen.IsRunning()
				&& !P2GameInfoSingle(Level.Game).IsWeekend())	// don't allow during weekend
				DisplayMap();
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Player wants to look at newspaper, make sure it's okay to do it now.
///////////////////////////////////////////////////////////////////////////////
function RequestNews()
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		// REMOVED: So you could do all these things while requesting the map... when
		// the newspaper auto-activates, we want to makes sure it works when you
		// walk over it.
		// Don't allow while jumping or firing a weapon
		//if ((Pawn.Physics != PHYS_Falling) && !(Pawn.Weapon != None && !Pawn.Weapon.IsInState('Idle')))

			if (!MyNewsScreen.IsRunning()
				&& !P2GameInfoSingle(Level.Game).IsWeekend())	// don't allow during weekend
				DisplayNews();
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Player wants to change his clothes and has a valid set with which to change into
///////////////////////////////////////////////////////////////////////////////
function RequestClothes()
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		// Don't allow while jumping or firing a weapon
		//if ((Pawn.Physics != PHYS_Falling) && !(Pawn.Weapon != None && !Pawn.Weapon.IsInState('Idle')))
			DisplayClothes();
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Player wants to look at newspaper, make sure it's okay to do it now.
///////////////////////////////////////////////////////////////////////////////
exec function RequestStats()
	{
	if (!DebugEnabled())
		return;

	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		// Don't allow while jumping or firing a weapon
		if ((Pawn.Physics != PHYS_Falling) && !(Pawn.Weapon != None && !Pawn.Weapon.IsInState('Idle')))
			DisplayStats(P2GameInfoSingle(Level.Game).MainMenuURL);
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Display the news screen (called externally)
///////////////////////////////////////////////////////////////////////////////
function DisplayNews()
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		if (!MyNewsScreen.IsRunning())
			{
			// Apocalypse newspaper is the only one that doesn't let you skip
			MyNewsScreen.Show(P2GameInfoSingle(Level.Game).TheGameState.bIsApocalypse);
			CurrentScreen = MyNewsScreen;
			SetMyOldState();
			GotoState('WaitScreen');
			}
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Display the vote screen (called externally)
///////////////////////////////////////////////////////////////////////////////
function DisplayVote()
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		if (!MyVoteScreen.IsRunning())
			{
			MyVoteScreen.Show();
			CurrentScreen = MyVoteScreen;
			SetMyOldState();
			GotoState('WaitVoteScreen');
			}
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Display the stats screen (called externally)
///////////////////////////////////////////////////////////////////////////////
function DisplayStats(optional String URL)
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		if (!MyStatsScreen.IsRunning())
			{
			MyStatsScreen.Show(URL);
			CurrentScreen = MyStatsScreen;
			SetMyOldState();
			GotoState('WaitScreen');
			}
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Display the pick screen (called externally)
///////////////////////////////////////////////////////////////////////////////
function DisplayPick()
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		if (!MyPickScreen.IsRunning())
			{
			MyPickScreen.Show();
			CurrentScreen = MyPickScreen;
			SetMyOldState();
			GotoState('WaitScreen');
			}
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Display the load screen (called externally)
///////////////////////////////////////////////////////////////////////////////
function DisplayLoad(DayBase day, String URL)
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		if (!MyLoadScreen.IsRunning())
			{
			MyLoadScreen.Show(day, URL);
			CurrentScreen = MyLoadScreen;
			SetMyOldState();
			GotoState('WaitScreen');
			}
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Display the load screen (called externally)
///////////////////////////////////////////////////////////////////////////////
function DisplayLoadForced(Texture LoadTex, String URL)
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		if (!MyLoadScreen.IsRunning())
			{
			MyLoadScreen.ForcedShow(LoadTex, URL);
			CurrentScreen = MyLoadScreen;
			SetMyOldState();
			GotoState('WaitScreen');
			}
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Display the load screen (called externally)
///////////////////////////////////////////////////////////////////////////////
function DisplayLoadForcedNoFade(Texture LoadTex, String URL)
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		if (!MyFastLoadScreen.IsRunning())
			{
			MyFastLoadScreen.ForcedShow(LoadTex, URL);
			CurrentScreen = MyFastLoadScreen;
			SetMyOldState();
			GotoState('WaitScreen');
			}
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Display the clothes screen (called externally)
///////////////////////////////////////////////////////////////////////////////
function DisplayClothes()
	{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
		{
		if (!MyClothesScreen.IsRunning())
			{
			MyClothesScreen.Show();
			CurrentScreen = MyClothesScreen;
			SetMyOldState();
			GotoState('WaitClothesScreen');
			}
		}
	else
		Warn("DisplayLoad() should not be called in multiplayer game.");
	}

///////////////////////////////////////////////////////////////////////////////
// Display the map screen.  This is called both internally and externally.
//
// There are possible three modes (selected using the bool paremeters):
//		- reveal the errands at the start of a day
//		- mark an errand as completed
//		- just look at the the map
//
// The map screen is triggered and the player is put into a temporary
// 'WaitMapScreen' state until the map screen is done, at which point he goes
// back to his prior state.  The map screen pauses the game while it is
// running and unpauses it afterwards.  Note that there is a slight delay from
// when MapScreen.Show() is called to when the game actually pauses.
//
// The 'WaitMapScreen' state handles certain triggering and notification aspects
// of errand completion.  This is a bit ugly but it ensures those things will
// happen only after the map screen is finished and the game is running again.
///////////////////////////////////////////////////////////////////////////////
function DisplayMap()
	{
	MyMapScreen.Show();
	CurrentScreen = MyMapScreen;
	// For debugging, you can keep playing while map is running
	if (MyMapScreen.PLAY_GAME_WITH_MAP_RUNNING == 0)
		{
		SetMyOldState();
		GotoState('WaitMapScreen');
		}
	}

function DisplayMapErrands(optional String SendToURL, optional bool bWantFancyFadeIn)
	{
	MyMapScreen.ShowErrands(SendToURL, bWantFancyFadeIn);
	CurrentScreen = MyMapScreen;
	SetMyOldState();
	GotoState('WaitMapScreen');
	}

function DisplayMapHaters(optional String SendToURL)
	{
	MyMapScreen.ShowHaters(SendToURL);
	CurrentScreen = MyMapScreen;
	SetMyOldState();
	GotoState('WaitMapScreen');
	}

function DisplayMapCrossOut(int ErrandIndex, name CompletionTrigger_In, optional String SendToURL)
	{
	// Set flag and save trigger for use after map screen ends
	bErrandCompleted = true;
	CompletionTrigger = CompletionTrigger_In;
	MyMapScreen.ShowCrossOut(ErrandIndex, SendToURL);
	CurrentScreen = MyMapScreen;
	SetMyOldState();
	GotoState('WaitMapScreen');
	}

///////////////////////////////////////////////////////////////////////////////
// Generate the toss velocity for something your throwing out of your inventory
///////////////////////////////////////////////////////////////////////////////
function vector GenTossVel(optional P2PowerupInv ppinv)
{
	local float usemag;

	if(ppinv != None)
		usemag = ppinv.GetTossMag();
	else
		usemag = TOSS_STUFF_VEL;
	//Mypawnfix
	return (vector(Pawn.GetViewRotation()) * usemag);
}

///////////////////////////////////////////////////////////////////////////////
// Throw/toss out current powerup, and switch to a new powerup
///////////////////////////////////////////////////////////////////////////////
exec function ThrowPowerup()
{
	if( Level.Pauser!=None)
		return;

	if(Pawn != None)
	{
		ServerThrowPowerup();
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerThrowPowerup()
{
	local P2PowerupInv ppinv;

	//mypawnfix
	ppinv = P2PowerupInv(Pawn.SelectedItem);

	if( ppinv==None || !ppinv.bCanThrow )
		return;

	P2Pawn(Pawn).TossThisInventory(GenTossVel(), ppinv);
}

///////////////////////////////////////////////////////////////////////////////
// For consistancies sake, two new functions are used. Before NextItem was
// in Pawn and PrevItem was in playercontroller, so they're both now in
// here so different states can override them or ignore them.
///////////////////////////////////////////////////////////////////////////////
exec function PrevInvItem()
{
	PrevItem();
}
exec function NextInvItem()
{
	if( Level.Pauser!=None)
		return;

	//mypawnfix
	if(P2Pawn(Pawn) != None)
		P2Pawn(Pawn).NextItem();
}

///////////////////////////////////////////////////////////////////////////////
// Fire foot weapon
///////////////////////////////////////////////////////////////////////////////
exec function DoKick()
{
	if( Level.Pauser!=None)
		return;

	//mypawnfix
	if( P2Pawn(Pawn) != None
		&& P2Pawn(Pawn).MyFoot!=None )
	{
		P2Pawn(Pawn).StopAcc();
		P2Pawn(Pawn).MyFoot.Fire(1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Switch directly to your hands weapon
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToHands(optional bool bForce)
{
	// STUB.
	// Defined in dudeplayer where it has access to the hands weapon type
}

// Change by NickP: MP fix
simulated function ClientSwitchToHands(optional bool bForceReady)
{
	SwitchToHands(bForceReady);
}
function ServerOnSelectedItem(Inventory UseInv)
{
	if (Powerups(UseInv) != None)
		Pawn.SelectedItem = Powerups(UseInv);
	//ClientMessage("ServerOnSelectedItem" @ UseInv);
}
// End

///////////////////////////////////////////////////////////////////////////////
// Switch directly to your hands weapon, or back to what you had before hands
///////////////////////////////////////////////////////////////////////////////
exec function ToggleToHands(optional bool bForce)
{
	// STUB.
	// Defined in dudeplayer where it has access to the hands weapon type
}

///////////////////////////////////////////////////////////////////////////////
// The player wants to active selected item
///////////////////////////////////////////////////////////////////////////////
exec function ActivateItem()
{
	local UseTrigger CheckT;
	
	if( Level.Pauser!=None )
		return;
		
	// If we're touching a UseTrigger, activate that instead.
	if (Pawn != none)
	{
	    foreach Pawn.TouchingActors(class'UseTrigger', CheckT)
	    {
		    Use();
		    return;
	    }
	}

	Super.ActivateItem();	
}

///////////////////////////////////////////////////////////////////////////////
// If we've gone through a level transition that takes our weapons/inventory
// use this to reset the toggle button
///////////////////////////////////////////////////////////////////////////////
function ResetHandsToggle()
{
	// STUB.
	// Defined in dudeplayer where it has access to the hands weapon type
}

///////////////////////////////////////////////////////////////////////////////
// Do you have only your hands out?
///////////////////////////////////////////////////////////////////////////////
function bool HasHandsOut()
{
	// STUB.
	// Defined in dudeplayer where it has access to the hands weapon type
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// This exec doesn't do anything unless player is dead
///////////////////////////////////////////////////////////////////////////////
exec function GameOverRestart(optional float F)
{
}

///////////////////////////////////////////////////////////////////////////////
// Most of the time (if you're not dead), you're ready to deal with a cashier
///////////////////////////////////////////////////////////////////////////////
function bool ReadyForCashier()
{
	if(Pawn == None
		|| Pawn.Health <= 0)
		return false;
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if you are currently in range to give money to the cashier
///////////////////////////////////////////////////////////////////////////////
function bool DealingWithCashier()
{
	return bDealingWithCashier;
}

///////////////////////////////////////////////////////////////////////////////
// True if he's in the state just before actually killing himself
///////////////////////////////////////////////////////////////////////////////
function bool IsReadyToCommitSuicide()
{
	return (GetStateName() == 'PlayerSuicideByGrenade');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function EnterSnipingState()
{
	GotoState('PlayerSniping');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ExitSnipingState()
{
	GotoState('PlayerWalking');
}

///////////////////////////////////////////////////////////////////////////////
// These two zoom the camera in and out
///////////////////////////////////////////////////////////////////////////////
exec function DeadNextWeapon(float ZoomInc, int ZoomMin)
{
	if( Level.Pauser!=None)
		return;

	CameraDist -= CAMERA_ZOOM_CHANGE;
	if(CameraDist < ZoomMin)
		CameraDist = ZoomMin;
}
exec function DeadPrevWeapon(float ZoomInc, int ZoomMax)
{
	if( Level.Pauser!=None)
		return;

	CameraDist += CAMERA_ZOOM_CHANGE;
	if(CameraDist > ZoomMax)
		CameraDist = ZoomMax;
}
///////////////////////////////////////////////////////////////////////////////
// Same as Engine.PlayerController version except we
// pick the neck bone to stare at
///////////////////////////////////////////////////////////////////////////////
function SuicideCalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;
	local coords checkcoords;

	if(Pawn != None)
	{
		//mypawnfix
		// Look at the dude's head while we're ready to kill him
		checkcoords = Pawn.GetBoneCoords(CAMERA_TARGET_BONE);
		// Set the location now to the head
		CameraLocation = checkcoords.Origin;

		// Now modify it based on your surroundings.
		CameraRotation = Rotation;
		if(CameraRotation.Pitch < CAMERA_MIN_HIGH_SUICIDE_PITCH
			&& CameraRotation.Pitch > CAMERA_MAX_LOW_SUICIDE_PITCH)
			CameraRotation.Pitch = CAMERA_MAX_LOW_SUICIDE_PITCH;
		View = vect(1,0,0) >> CameraRotation;
		if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
			ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
		else
			ViewDist = Dist;
		CameraLocation -= (ViewDist - 30) * View;
	}
}
///////////////////////////////////////////////////////////////////////////////
// Same as Engine.PlayerController version except we
// use our own distance numbers for the camera
///////////////////////////////////////////////////////////////////////////////
function DeadCalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;
	local coords checkcoords;

	// We used to look at the dude's head, but now we just look at his center. It makes sure
	// the camera is less likely to be inside things
	//checkcoords = MyPawn.GetBoneCoords(CAMERA_TARGET_BONE);
	// Set the location now to the head
	//CameraLocation = checkcoords.Origin;
	CameraLocation = Pawn.Location;
	CameraLocation.z += Pawn.CollisionHeight;

	// Now modify it based on your surroundings.
	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View;
}

///////////////////////////////////////////////////////////////////////////////
// Quick cheat for MP testing anims
///////////////////////////////////////////////////////////////////////////////
exec function TCam()
{
	if (!DebugEnabled())
		return;

	bFreeCamera = !bFreeCamera;
	bBehindView = !bBehindView;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientShakeView(vector shRotMag,    vector shRotRate,    float shRotTime,
                   vector shOffsetMag, vector shOffsetRate, float shOffsetTime)
{
	ShakeView(shRotMag, shRotRate, shRotTime, shOffsetMag, shOffsetRate, shOffsetTime);
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
	local vector eyepos;
	local float lowerheight;
	local vector x1, y1, z1;

	// First-person view.
	/*

	 This is head-moving-down code for when you look down. This is to make
	things not look so small when you look at them. We didn't go with this approach
	but it's kept in, in case we want to mess with it.

	God mode toggles it

	if(CameraRotation.Pitch <= 18000)
	{
	}
	else if(CameraRotation.Pitch >= 49152)
	{
		if(bGodMode)
		{
			lowerheight = (65536 - CameraRotation.Pitch)/400;
			eyepos.z-=lowerheight;
		}
	}
	*/
    GetAxes(Rotation, x1, y1, z1);

    // First-person view.
    CameraRotation = Normalize(Rotation + ShakeRot);
    CameraLocation = CameraLocation + Pawn.EyePosition() +// Pawn.WalkBob +
                     ShakeOffset.X * x1 +
                     ShakeOffset.Y * y1 +
                     ShakeOffset.Z * z1;
	//log(self$" CameraRotation "$CameraRotation$" shakerot "$ShakeRot$" rotation "$Rotation);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function FindGoodCameraView()
{
	local vector cameraLoc;
	local rotator cameraRot, ViewRotation;
	local int tries, besttry;
	local float bestdist, newdist;
	local int startYaw;
	local actor ViewActor;

	//log("FindGoodCameraView, p2player, pawn "$Pawn$" mypawn "$MyPawn$" view "$ViewTarget);
	ViewRotation.Roll = Rotation.Roll;
	ViewRotation.Yaw = (Rotation.Yaw + 32768) & 65535;
	ViewRotation.Pitch = 60000;
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

///////////////////////////////////////////////////////////////////////////////
// Decide if he's stuck or not
///////////////////////////////////////////////////////////////////////////////
function bool DetectStuckPlayer(float DeltaTime)
{
	local NavigationPoint N;

	// If you're falling and not moving for too long, you're stuck
	if(Pawn.Physics == PHYS_Falling
		&& !Pawn.bIsCrouched
		&& !bCheatFlying)
	{
		// If you're not moving in z for too long
		if(Pawn.Velocity.z == 0)
		{
			StuckTime += DeltaTime;

			// After we're pretty sure, put up a helpful message
			if(StuckTime - DeltaTime < STUCK_TIME_HINT
				&& StuckTime >= STUCK_TIME_HINT)
			{
				//mypawnfix
				Pawn.ClientMessage(StuckText1);
				Warn(self$" Player appears stuck "$Pawn.Location);
			}

			// Now that he's really stuck, move him
			if(StuckTime > MAX_STUCK_TIME)
			{
				StuckTime = 0;
				return true;
			}
		}
		else
			StuckTime = 0;
	}

	// Disable for now.
	/*
	// If they fall off the map, consider them stuck
	// If you fall more than 3000 UU's under the lowest NavigationPoint in the map, you're probably not coming back from that
	if (LastStuckCheckZone != Pawn.Region.ZoneNumber)
	{
		LowestNavPoint.Z = 99999;
		foreach DynamicActors(class'NavigationPoint', N)
			if (N.Region.ZoneNumber == Pawn.Region.ZoneNumber
				&& N.Location.Z < LowestNavPoint.Z)
				LowestNavPoint = N.Location;

		LastStuckCheckZone = Pawn.Region.ZoneNumber;
	}

	// If they're stuck under the map, warp them back
	// But don't warp them while they're in midair (they could be plunging toward a death zone)
	if (LowestNavPoint.Z != 99999
		&& LowestNavPoint.Z - STUCK_UNDER_MAP_DIST > Pawn.Location.Z
		&& Pawn.Physics != PHYS_Falling)
		return true;
	*/

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Find the nearest free pathnode to the stuck player, and put him there
// Warps him to each possible spot to make sure it will work. But it doesn't
// warp him back, it just uses the oldloc to test from. The last one you warped
// him to will have to be the closest to oldloc.
///////////////////////////////////////////////////////////////////////////////
function HandleStuckPlayer(optional int ForceUnstuck)
{
	local PathNode pn, savepn;
	local float closedist, usedist;
	local vector useloc, oldloc;

	const MAX_STUCK_LOOP = 10;

	Warn(self$" ERROR! PLAYER WAS STUCK here: "$Pawn.Location);

	oldloc = Pawn.Location;
	// reset vel
	Pawn.Velocity.X = 0;
	Pawn.Velocity.Y = 0;
	Pawn.Velocity.Z = 0;

	closedist = StuckCheckRadius;
	// Check pathnodes in a given radius
	foreach RadiusActors(class'Pathnode', pn, StuckCheckRadius, oldloc)
	{
		usedist = VSize(pn.Location - oldloc);
		if(LastUnstuckPoint	!= pn		// Not where we last unstuck ourself from
			&& usedist < closedist		// closest one
			&& !pn.bBlocked)			// not blocked
		{
			// Warp the player there now, to make sure the spot was
			// okay for him to be there. If this happens, it will only
			// work with the closest node, so this will also be the final move
			useloc = pn.Location;
			// Add just enough buffer to pathnode, to make sure he somehow doesn't
			// get warped to a point below the floor, and then fall through the floor.
			useloc.z += (Pawn.CollisionHeight/2);
			if(Pawn.SetLocation(useloc))
			{
				closedist = usedist;
				savepn = pn;
			}
		}
	}

	if(savepn != None)
	{
		//mypawnfix
		Pawn.ClientMessage(StuckText2);
		StuckCheckRadius = STUCK_RADIUS;
		LastUnstuckPoint = savepn;	// Save where we last unstuck from so as to not use it again, next time
		Warn(self$" UNsticking player--warping him to "$savepn);
	}
	else
	{
		Warn(self$" UNsticking warp failed");
		// You've failed, then increase you're check area
		StuckCheckRadius += STUCK_RADIUS;
		if (ForceUnstuck > 0
			&& ForceUnstuck < MAX_STUCK_LOOP)
			HandleStuckPlayer(ForceUnstuck + 1);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Clean up in anyway (state stuff, for instance) after being
// sent to jail
///////////////////////////////////////////////////////////////////////////////
function GettingSentToJail()
{
	//log(self$" basic GettingSentToJail");
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait for screen to finish running
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitScreen
	{
	ignores Fire, Use, Jump, Pause, Speech, AltFire, DudeShoutGetDown, UseZipper,
		SetMyOldState, RequestMap, QuickUseMap, RequestNews, RequestStats, DisplayVote,
		Suicide, DoKick, QuickSave, WeaponZoom, WeaponZoomIn, WeaponZoomOut, ThrowWeapon,
		ThrowPowerup, PrevInvItem, NextInvItem, CanBeMugged, SwitchWeapon, SwitchToHands, ToggleToHands,
		PressingFire, PressingAltFire;
	function BeginState()
		{
		// Seems like a good idea to stop the pawn from moving
		MyPawn.StopAcc();
		// Undo any slomo effects before we start the map
		P2GameInfoSingle(Level.Game).SetGameSpeedNoSave(1.0);
		}

	function EndState()
		{
		CurrentScreen = None;
		// Restore any time dilation effects
		SetupCatnipUseage(CatnipUseTime);
		}

	// Wait until screen is no longer running, then goto prior state
Begin:
	if (CurrentScreen.IsRunning() == false)
	{
		//log(self$" going back to "$MyOldState);
		GotoState(MyOldState);
	}
	Sleep(0.05);
	Goto('Begin');
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait for voting screen to finish, then do special stuff afterwards
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitVoteScreen extends WaitScreen
	{
	function EndState()
		{
		Super.EndState();

		// The voting errand has been completed.  To indicate its completion,
		// we spawn a temporary actor with its tag set to the unique tag the
		// errand goal looks for and pass it to the completion process.
		P2GameInfoSingle(Level.Game).CheckForErrandCompletion(
			spawn(class'RawActor', ,'VoteScreen'),
			None,
			None,
			self,
			false);
		}
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait for map screen to finish, then do special stuff afterwards
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitMapScreen extends WaitScreen
	{
	function EndState()
		{
		local Actor TriggerMe;

		Super.EndState();

		// Reset the map hints now that we've looked at the map
		ResetMapReminder(true);

		// If errand was completed then there's some special things to do...
		if (bErrandCompleted)
			{
			// May need to trigger event associated with completed errand
			if(CompletionTrigger != 'None')
				{
				ForEach AllActors(class 'Actor', TriggerMe, CompletionTrigger)
					TriggerMe.Trigger(None, Pawn);
				}

			// May need to inform another character of errand completion
			if(InterestPawn != None && InterestPawn.Health > 0 && LambController(InterestPawn.Controller) != None)
				LambController(InterestPawn.Controller).DudeErrandComplete();

			bErrandCompleted = false;
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Say something after putting on your clothes
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitClothesScreen extends WaitScreen
	{
	function EndState()
		{
		Super.EndState();
		FinishedPuttingOnClothes();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Controller shit goes here
///////////////////////////////////////////////////////////////////////////////
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
		//log("UpdateRotation"@aTurn@aLookUp@LookAccelTimeTurn@LookAccelTimeUp);
		if (InputTracker.bUsingJoystick)
		{
			// The longer we hold the stick, the faster it builds up to the desired look speed.
			// Reset if the axis drops
			//log("aTurn"@aTurn@OldaTurn@"aLookUp"@aLookUp@OldALookUp);
			/*
			if (Abs(aTurn) < 30)
				LookAccelTimeTurn = 0;
			else if (Abs(aTurn) > Abs(OldaTurn))
			{
				// Adjust value if aTurn goes up further after hitting 1.0, so the 1.0 doesn't "follow" the aTurn value
				if (LookAccelTimeTurn >= 1.0)
					LookAccelTimeTurn = Abs(OldaTurn / aTurn);
				else
					LookAccelTimeTurn += DeltaTime * (LookSensitivityX);
			}
			*/
			
			//log("BEFORE aTurn ("$UseaTurn$"/"$aTurn$") aLookUp ("$UseaLookUp$"/"$aLookUp$")");
			if (Abs(aTurn) > Abs(UseaTurn))
			{
				if ((aTurn < 0 && UseaTurn > 0)
					|| (aTurn > 0 && UseaTurn < 0))
					UseaTurn = 0;
				else
					UseaTurn += DeltaTime * LookSensitivityX * aTurn;
			}
			else
				UseaTurn = aTurn;			
			OldaTurn = aTurn;
			
			/*
			if (Abs(aLookUp) < 30)
				LookAccelTimeUp = 0;
			else if (Abs(aLookUp) > Abs(OldaLookUp))
			{
				if (LookAccelTimeUp >= 1.0)
					LookAccelTimeUp = Abs(OldaLookUp / aLookUp);
				else
					LookAccelTimeUp += DeltaTime * (LookSensitivityY);
			}
			*/
			if (Abs(aLookUp) > Abs(UseaLookUp))
			{
				if ((aLookUp < 0 && UseaLookUp > 0)
					|| (aLookUp > 0 && UseaLookUp < 0))
					UseaLookUp = 0;
				else
					UseaLookUp += DeltaTime * LookSensitivityY * aLookUp;
			}
			else
				UseaLookUp = aLookUp;
			OldaLookUp = aLookUp;
			
			/*
			LookAccelTimeTurn = FClamp(LookAccelTimeTurn, 0, 1.0);
			LookAccelTimeUp = FClamp(LookAccelTimeUp, 0, 1.0);
			ViewRotation.Yaw += 32.0 * DeltaTime * LookAccelTimeTurn * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * LookAccelTimeUp * aLookUp;
			*/
			if (aTurn < 0)
				UseaTurn = FClamp(UseaTurn, aTurn, 0);
			else
				UseaTurn = FClamp(UseaTurn, 0, aTurn);
			if (aLookUp < 0)
				UseaLookUp = FClamp(UseaLookUp, aLookUp, 0);
			else
				UseaLookUp = FClamp(UseaLookUp, 0, aLookUp);
			//log("AFTER aTurn ("$UseaTurn$"/"$aTurn$") aLookUp ("$UseaLookUp$"/"$aLookUp$")");
			ViewRotation.Yaw += 32.0 * DeltaTime * UseaTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * UseaLookUp;
		}
		else
		{
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
		}
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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PlayerFlying
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerFlying
{
	///////////////////////////////////////////////////////////////////////////////
	// Updated for proper controller input during flying
	///////////////////////////////////////////////////////////////////////////////
	function PlayerMove(float DeltaTime)
	{
		local float UseAxis, UseGroundSpeed;	// UseGroundSpeed in this case actually refers to air speed
		const AXIS_MAX = 1800.0;
		
		Super.PlayerMove(DeltaTime);

		// Should not happen while flying, but worth checking for anyway.
		if(DetectStuckPlayer(DeltaTime))
		{
			HandleStuckPlayer();
		}
		
		// Sanity check.
		if (MyPawn.GroundSpeedMax == 0)
			MyPawn.GroundSpeedMax = MyPawn.Default.GroundSpeed;
		
		// Set max ground speed based on axis position
		UseAxis = FMax(abs(aForward), abs(aStrafe));
		
		// For zero, always use regular ground speed, so player doesn't stop on a dime (or be unable to move at the beginning of a map)
		if (UseAxis == 0)
			UseGroundSpeed = MyPawn.GroundSpeedMax;		
		else
			UseGroundSpeed = FMin(MyPawn.GroundSpeedMax, (UseAxis/AXIS_MAX) ** JoySensitivity * MyPawn.GroundSpeedMax);
			
		// If player is currently moving quicker than the desired ground speed, wait for him to slow down first
		if (VSize(Pawn.Velocity) > UseGroundSpeed)
			UseGroundSpeed = VSize(Pawn.Velocity);
		
		// Can't duck or run while flying, so we can skip the entire "walk/run" bit from the ground-based implementation
			
		// Sanity check
		UseGroundSpeed = FClamp(UseGroundSpeed, 0.0, MyPawn.GroundSpeedMax);
		
		// Now set the actual ground speed
		Pawn.AirSpeed = UseGroundSpeed;
		LastGroundSpeed = UseGroundSpeed;

		//log("PlayerMove"@aForward@aStrafe@UseGroundSpeed);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Extend the original playerwalking from playercontroller. Add
// that you alert people of your weapon
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerWalking
{
	///////////////////////////////////////////////////////////////////////////////
	// Prepare for a save
	///////////////////////////////////////////////////////////////////////////////
	function PrepForSave()
	{
		GotoState('PlayerPrepSave');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for getting stuck (and do normal player move)
	///////////////////////////////////////////////////////////////////////////////
	function PlayerMove( float DeltaTime )
	{
		local float UseAxis, UseGroundSpeed;
		local bool bShouldWalk;
		
		Super.PlayerMove(DeltaTime);

		if(DetectStuckPlayer(DeltaTime))
		{
			HandleStuckPlayer();
		}
		
		// Sanity check.
		if (MyPawn.GroundSpeedMax == 0)
			MyPawn.GroundSpeedMax = MyPawn.Default.GroundSpeed;
			
		// Set max ground speed based on axis position
		UseAxis = FMax(abs(aForward), abs(aStrafe));
		
		// For zero, always use regular ground speed, so player doesn't stop on a dime (or be unable to move at the beginning of a map)
		if (UseAxis == 0)
			UseGroundSpeed = MyPawn.GroundSpeedMax;		
		else
			UseGroundSpeed = FMin(MyPawn.GroundSpeedMax, (UseAxis/AXIS_MAX) ** JoySensitivity * MyPawn.GroundSpeedMax);
			
		// If player is currently moving quicker than the desired ground speed, wait for him to slow down first
		if (VSize(Pawn.Velocity) > UseGroundSpeed)
			UseGroundSpeed = VSize(Pawn.Velocity);
		
		if (!Pawn.bWantsToCrouch) // Changed this because bDuck no longer accurately represents whether the pawn is crouching or not (crouch toggle)
		{
			// If player is holding down the "run" button (walk button actually), don't do any of this
			if (bRun == 0)
			{
				if (UseGroundSpeed < (Pawn.Default.GroundSpeed * 0.75))
					bShouldWalk = true;
				else
					bShouldWalk = false;
					
				// Change anim accordingly
				if (bShouldWalk != bWasWalking)
				{
					if (bShouldWalk)
					{
						MyPawn.SetAnimWalking();
						MyPawn.BaseMovementRate = MyPawn.Default.BaseMovementRate / 2;	// jack this up so he doesn't walk super-slow
						bWasWalking = true;
					}
					else
					{
						MyPawn.SetAnimRunning();
						MyPawn.BaseMovementRate = MyPawn.Default.BaseMovementRate;		// reset this to normal
						bWasWalking = false;
					}
				}
			}
		}
			
		// Sanity check
		UseGroundSpeed = FClamp(UseGroundSpeed, 0.0, MyPawn.GroundSpeedMax);
		
		// Change from walking to running if we cross a certain amount
		// Sort this out later...
			
		// Now set the actual ground speed
		Pawn.GroundSpeed = UseGroundSpeed;
		LastGroundSpeed = UseGroundSpeed;

		//log("PlayerMove"@aForward@aStrafe@UseGroundSpeed);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Process Move
	///////////////////////////////////////////////////////////////////////////////
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldAccel;
		local bool OldCrouch;
		local bool bShouldDuck;			// Added crouch toggle

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		if ( bPressedJump )
			Pawn.DoJump(bUpdating);

		// NPF 07/23/03 ViewPitch brought over from 2141 to do torso twisting
        Pawn.ViewPitch = Clamp(Rotation.Pitch / 256, 0, 255);

		// NPF 2/26/02
		// Removed test that doesn't let you crouch if you're falling, to make crouch jumping work
		OldCrouch = Pawn.bWantsToCrouch;
		
		// Crouch toggle check
		if (bCrouchToggle)
		{
			// Only do a crouch toggle duck change check if the button is different from what it was last frame.
			if (bDuck != bDuckOld)
				bShouldDuck = (OldCrouch ^^ (bDuck == 1));
			else
				bShouldDuck = OldCrouch;
		}
		else
			bShouldDuck = (bDuck == 1);
		
		if (!bShouldDuck)
			Pawn.ShouldCrouch(false);
		else if ( Pawn.bCanCrouch )
			Pawn.ShouldCrouch(true);
			
		bDuckOld = bDuck;
		/*
		if (bCower == 0)
			MyPawn.ShouldCower(false);
		else
			MyPawn.ShouldCower(true);

		if (bDeathCrawl == 0)
		{
			MyPawn.ShouldDeathCrawl(false);
		}
		else
			MyPawn.ShouldDeathCrawl(true);
		*/

	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		// Check if we should prepare for a save.
		// We could be sent here first if a movie finished playing and repossessed us.
		CheckPrepForSave();
	}

Begin:
	Sleep(REPORT_LOOKS_SLEEP_TIME);
	//mypawnfix
	P2Pawn(Pawn).ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
	CheckForCrackUse(REPORT_LOOKS_SLEEP_TIME);
	FollowCatnipUse(REPORT_LOOKS_SLEEP_TIME);
	FollowDualWieldUse(REPORT_LOOKS_SLEEP_TIME);
	CheckMapReminder(REPORT_LOOKS_SLEEP_TIME);
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Player just got into the level or waiting after a movie. Don't let him
// do anything else so that it's safe to save the game.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerPrepSave extends PlayerWalking
{
	ignores PrepForSave, CheckPrepForSave,SeePlayer, HearNoise, KilledBy, NotifyBump,
		HitWall, ActivateInventoryItem,
		Jump, ThrowWeapon, PlayerMove, ThrowPowerup, PrevInvItem, NextInvItem, ActivateItem,
		NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, CheckMapReminder,
		DamageAttitudeTo, Suicide, UseZipper, DudeShoutGetDown, ToggleInvHints, ToggleToHands,
		QuickUseMap, DoKick, QuickSave, CanBeMugged, WeaponZoom, WeaponZoomIn, WeaponZoomOut,
		NextWeapon, PrevWeapon, Fire, AltFire, PressingFire, PressingAltFire, Pause, ReadyForCashier;

	///////////////////////////////////////////////////////////////////////////////
	// Returns true if any screen is still running
	///////////////////////////////////////////////////////////////////////////////
	function bool ScreenStillRunning()
	{
		local int i;
		local P2Screen screen;
		local bool bScreenRunning;

		for (i = 0; i < Player.LocalInteractions.Length; i++)
		{
			screen = P2Screen(Player.LocalInteractions[i]);
			if (screen != None)
				bScreenRunning = bScreenRunning || screen.IsRunning();
		}

		return bScreenRunning;
	}

	// Block begin/endstate, and then list logs
	function beginstate()
	{
		//log(self$" begin state PlayerPrepSave ");
	}
	function endstate()
	{
		//log(self$" end state PlayerPrepSave");
	}
Begin:
	Sleep(AUTO_SAVE_WAIT);

	if (ScreenStillRunning() ||
		!P2GameInfoSingle(Level.Game).ReadyForSave(self) )
		Goto('Begin');
		
	// Tell the IGT we're done loading in
	P2GameInfoSingle(Level.Game).InitPostTravelIGT();		

	// We don't need to do this again
	bDidPrepForSave = true;

	// Go back to playing normally
	ExitPrepToSave();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Player just got into the level or waiting after a movie. Don't let him
// do anything else so that it's safe to save the game.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerDiffPatch extends PlayerPrepSave
{
	ignores PrepForSave, CheckPrepForSave,SeePlayer, HearNoise, KilledBy, NotifyBump,
		HitWall, ActivateInventoryItem,
		Jump, ThrowWeapon, PlayerMove, ThrowPowerup, PrevInvItem, NextInvItem, ActivateItem,
		NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, CheckMapReminder,
		DamageAttitudeTo, Suicide, UseZipper, DudeShoutGetDown, ToggleInvHints, ToggleToHands,
		QuickUseMap, DoKick, QuickSave, CanBeMugged, WeaponZoom, WeaponZoomIn, WeaponZoomOut,
		NextWeapon, PrevWeapon, Fire, AltFire, PressingFire, PressingAltFire, Pause, ReadyForCashier;

	// Block begin/endstate, and then list logs
	function beginstate()
	{
		//log(self$"patching saved file with Difficulty Fix");
	}
	function endstate()
	{
		//log(self$" end state PlayerDiffPatch");
	}
Begin:

	Sleep(AUTO_SAVE_WAIT);
	//log(self$" waiting in "$GetStateName());

	// Have them set the difficulty again
	if (ScreenStillRunning() ||
		!P2GameInfoSingle(Level.Game).ReadyForSaveFix(self) )
		Goto('Begin');

	// We don't need to do this again
	bDidPrepForSave = true;

	// Go back to playing normally
	ExitPrepToSave();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PlayerDemoMapFirst
// Wait for a second, with the game world shown, then bring up the map
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerDemoMapFirst extends PlayerWalking
{
	ignores PrepForSave, CheckPrepForSave,SeePlayer, HearNoise, KilledBy, NotifyBump,
		HitWall, ActivateInventoryItem,
		Jump, ThrowWeapon, PlayerMove, ThrowPowerup, PrevInvItem, NextInvItem, ActivateItem,
		NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, CheckMapReminder,
		DamageAttitudeTo, Suicide, UseZipper, DudeShoutGetDown, ToggleInvHints, ToggleToHands,
		QuickUseMap, DoKick, QuickSave, CanBeMugged, WeaponZoom, WeaponZoomIn, WeaponZoomOut,
		NextWeapon, PrevWeapon, Fire, AltFire, PressingFire, PressingAltFire, Pause, ReadyForCashier;
	///////////////////////////////////////////////////////////////////////////////
	// Force my old state to be PlayerWalking so he returns from the
	// map, ready to play the game.
	///////////////////////////////////////////////////////////////////////////////
	function SetMyOldState()
	{
		MyOldState = 'PlayerWalking';
	}

Begin:
	Sleep(1.5);
	DisplayMapErrands("", true);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// A guy is trying to mug you. If you exit this state early, the
// mugger will attack you. If you go out of a certain radius he'll attack you
// then too.
// Don't mess with crack or catnip timing here.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerGettingMugged extends PlayerWalking
{
	ignores CanBeMugged, CheckMapReminder, ReadyForCashier;

	///////////////////////////////////////////////////////////////////////////////
	// He really means it now!
	///////////////////////////////////////////////////////////////////////////////
	function EscalateMugging()
	{
		bMuggerGoingToShoot=true;
	}
	///////////////////////////////////////////////////////////////////////////////
	// For when the mugger wants to end with the player
	///////////////////////////////////////////////////////////////////////////////
	function UnhookPlayerGetMugged()
	{
		GotoState('PlayerWalking');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Hints on how to hande over your money to a guy mugging you
	///////////////////////////////////////////////////////////////////////////////
	function bool GetMuggerHints(out String str1, out String str2)
	{
		if(!bMuggerGoingToShoot)
		{
			str1 = MuggerHint1;
			str2 = MuggerHint2;
		}
		else
		{
			str1 = MuggerHint3;
			str2 = MuggerHint4;
		}
		return true;
	}
	///////////////////////////////////////////////////////////////////////////////
	//  Check him to make sure he hasn't lost interest in you, if he has
	// then unhook yourself
	///////////////////////////////////////////////////////////////////////////////
	function CheckMugger()
	{
		if(InterestPawn == None
			|| PersonController(InterestPawn.Controller) == None
			|| !PersonController(InterestPawn.Controller).IsInState('DoPlayerMugging'))
			UnhookPlayerGetMugged();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Clean up in anyway (state stuff, for instance) after being
	// sent to jail
	///////////////////////////////////////////////////////////////////////////////
	function GettingSentToJail()
	{
		//log(self$" GettingSentToJail from "$GetStateName());
		// Exit this state
		GotoState('PlayerWalking');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		InterestPawn = None;
		bMuggerGoingToShoot=true;
	}
Begin:
	Sleep(REPORT_LOOKS_SLEEP_TIME);
	P2Pawn(Pawn).ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
	CheckMugger();
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You've shot a rocket, and now the camera is racing around with the rocket.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerWatchRocket extends PlayerWalking
{
	ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, ActivateInventoryItem, ThrowWeapon,
			ThrowPowerup, PrevInvItem, NextInvItem, /*ActivateItem,*/ NotifyHeadVolumeChange,
			NotifyPhysicsVolumeChange, Falling, CheckMapReminder, Fire, AltFire,
			DamageAttitudeTo, Suicide, UseZipper, DudeShoutGetDown, ToggleInvHints,
			QuickUseMap, DoKick, QuickSave, WeaponZoom, WeaponZoomIn, WeaponZoomOut,
			IsSaveAllowed, SwitchWeapon, ProcessMove, ExitSnipingState, CanBeMugged, ReadyForCashier,
			PressingFire, PressingAltFire;

	///////////////////////////////////////////////////////////////////////////////
	// E detonates rocket
	///////////////////////////////////////////////////////////////////////////////
	exec function ActivateItem()
	{
		// Rocket projectiles: GenExplosion
		if (ViewTarget.IsA('LauncherProjectile'))
			P2Projectile(ViewTarget).GenExplosion(ViewTarget.Location, Vect(0,0,1), None);
		// Other projectiles: BlowUp		
		else if (P2Projectile(ViewTarget) != None)
			P2Projectile(ViewTarget).BlowUp(ViewTarget.Location);
	}
			
	///////////////////////////////////////////////////////////////////////////////
	// Jump takes you back to the player
	///////////////////////////////////////////////////////////////////////////////
	exec function Jump( optional float F )
	{
		if( Level.Pauser!=None)
			return;

		StopViewingRocketOrTarget();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Tell rocket what input for movement the player is giving
	///////////////////////////////////////////////////////////////////////////////
	function ModifyRocketMotion(out float PlayerTurnX, out float PlayerTurnY)
	{
		PlayerTurnX = PlayerMoveX;
		PlayerTurnY = PlayerMoveY;
		PlayerMoveX=0.0;
		PlayerMoveY=0.0;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Handle moving target instead of player
	///////////////////////////////////////////////////////////////////////////////
	function PlayerMove(float DeltaTime)
	{
		Super.PlayerMove(DeltaTime);

		if(aForward > 0)
			PlayerMoveY -= DeltaTime;
		else if(aForward < 0)
			PlayerMoveY += DeltaTime;
		if(aStrafe > 0)
			PlayerMoveX += DeltaTime;
		else if(aStrafe < 0)
			PlayerMoveX -= DeltaTime;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
	{
		local vector x1, y1, z1;

		GetAxes(ViewTarget.Rotation, x1, y1, z1);

		// First-person view.
		CameraRotation = ViewTarget.Rotation;
		// Viewing the rocket
		if(Projectile(ViewTarget) != None)
		{
			CameraLocation = CameraLocation + ShakeOffset
						+ CAMERA_ROCKET_OFFSET_X*x1 + CAMERA_ROCKET_OFFSET_Z*z1;
			// Put some extra crazy shake it
			CameraLocation = CameraLocation + VRand();
		}
		else // viewing the carnage
		{
			CameraLocation = CameraLocation + ShakeOffset
						+ CAMERA_VICTIM_OFFSET_X*x1 + CAMERA_VICTIM_OFFSET_Z*z1;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// The rocket hit a pawn directly
	///////////////////////////////////////////////////////////////////////////////
	function RocketDetonated(Actor HitThing)
	{
		SetViewTarget(HitThing);
		bBehindView=true;
		ViewTarget.BecomeViewTarget();
		FindGoodCameraView();
		GotoState('PlayerWatchRocket', 'WatchResults');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Restore the player as the view target
	///////////////////////////////////////////////////////////////////////////////
	function StopViewingRocketOrTarget()
	{
		bBehindView=false;
		if ( (MyPawn != None) && !MyPawn.bDeleteMe )
		{
			SetViewTarget(MyPawn);
		}
		else
			SetViewTarget(self);
		// Restore rotation
		ViewTarget.SetRotation(OldViewRotation);
		GotoState('PlayerWalking');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Based off of PlayerController::PlayerCalcView.
	///////////////////////////////////////////////////////////////////////////////
	event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
	{
		local Pawn PTarget;

		// We now restore viewtarget more carefully when it's destroyed
		if ( (ViewTarget == None) || ViewTarget.bDeleteMe )
		{
			StopViewingRocketOrTarget();
		}

		ViewActor = ViewTarget;
		CameraLocation = ViewTarget.Location;
		CameraRotation = ViewTarget.Rotation;
		if ( bBehindView )
		{
			CameraLocation = CameraLocation + (ViewTarget.CollisionHeight) * vect(0,0,1);
			CalcBehindView(CameraLocation, CameraRotation, VICTIM_CAMERA_VIEW_DIST * ViewTarget.Default.CollisionRadius);
		}
		else
			CalcFirstPersonView( CameraLocation, CameraRotation );
	}

	///////////////////////////////////////////////////////////////////////////////
	// Clean up in anyway (state stuff, for instance) after being
	// sent to jail
	///////////////////////////////////////////////////////////////////////////////
	function GettingSentToJail()
	{
		//log(self$" GettingSentToJail from "$GetStateName());
		// Exit this state
		GotoState('PlayerWalking');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Switch back to what you had before.
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		ToggleToHands(true);
		Super.EndState();
	}

	///////////////////////////////////////////////////////////////////////////////
	// If you don't have your hands out when you start, then put away
	// the weapon so you don't attract more attention than necessary
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// stop running
		MyPawn.StopAcc();
		// reset movement vars
		PlayerMoveX=0.0;
		PlayerMoveY=0.0;
		// Put away you're rocket launcher
		if(P2Weapon(MyPawn.Weapon) == None
			|| P2Weapon(MyPawn.Weapon).ViolenceRank > 0)
			ToggleToHands(true);
	}

WatchResults:
	Sleep(WATCH_ROCKET_RESULTS_TIME);
	StopViewingRocketOrTarget();
Begin:
	Sleep(REPORT_LOOKS_SLEEP_TIME);
	MyPawn.ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
	FollowCatnipUse(REPORT_LOOKS_SLEEP_TIME);
	FollowDualWieldUse(REPORT_LOOKS_SLEEP_TIME);
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Player can't run or climb while sniping
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerSniping extends PlayerWalking
{
	ignores HandleWalking, Jump, CanBeMugged, Suicide, CheckMapReminder,
		SomeoneDied, AllowTalking, CommentOnCheating, ReadyForCashier;

	///////////////////////////////////////////////////////////////////////////////
	// Clean up in anyway (state stuff, for instance) after being
	// sent to jail
	///////////////////////////////////////////////////////////////////////////////
	function GettingSentToJail()
	{
		//log(self$" GettingSentToJail from "$GetStateName());
		// Exit this state
		GotoState('PlayerWalking');
	}

	function EndState()
	{
		Super.EndState();
		//mypawnfix
		if(P2Pawn(Pawn) != None)
			P2Pawn(Pawn).bCanClimbLadders=P2Pawn(Pawn).default.bCanClimbLadders;
	}

	function BeginState()
	{
		Super.BeginState();
		//mypawnfix
		if(P2Pawn(Pawn) != None)
		{
			P2Pawn(Pawn).SetWalking(true);
			P2Pawn(Pawn).bCanClimbLadders=false;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// player is climbing ladder
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerClimbing
{
	ignores CanBeMugged, ReadyForCashier;

	///////////////////////////////////////////////////////////////////////////////
	// Prepare for a save
	///////////////////////////////////////////////////////////////////////////////
	function PrepForSave()
	{
		GotoState('PlayerPrepSave');
	}

Begin:
	Sleep(REPORT_LOOKS_SLEEP_TIME);
	//mypawnfix
	P2Pawn(Pawn).ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
	CheckForCrackUse(REPORT_LOOKS_SLEEP_TIME);
	CheckMapReminder(REPORT_LOOKS_SLEEP_TIME);
	FollowCatnipUse(REPORT_LOOKS_SLEEP_TIME);
	FollowDualWieldUse(REPORT_LOOKS_SLEEP_TIME);
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PlayerRadarTargetting
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerRadarTargetting extends PlayerWalking
{
	ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, ActivateInventoryItem, Jump, ThrowWeapon,
			ThrowPowerup, PrevInvItem, NextInvItem, ActivateItem, NotifyHeadVolumeChange,
			NotifyPhysicsVolumeChange, Falling, CheckMapReminder,
			DamageAttitudeTo, Suicide, UseZipper, DudeShoutGetDown, ToggleToHands, ToggleInvHints,
			QuickUseMap, DoKick, QuickSave, Fire, AltFire, PressingFire, PressingAltFire,
			WeaponZoom, WeaponZoomIn, WeaponZoomOut,
			SwitchWeapon, ProcessMove, ExitSnipingState, CanBeMugged, ReadyForCashier,
			IsSaveAllowed, ExitPrepToSave, SetupGettingMugged;

	///////////////////////////////////////////////////////////////////////////////
	// These two zoom the camera in and out
	///////////////////////////////////////////////////////////////////////////////
	exec function NextWeapon()
	{
		if( Level.Pauser!=None)
			return;

		if(ViewTarget == MyPawn)
			DeadNextWeapon(CAMERA_ZOOM_CHANGE, CAMERA_MIN_DIST);
	}
	exec function PrevWeapon()
	{
		if( Level.Pauser!=None)
			return;

		if(ViewTarget == MyPawn)
			DeadPrevWeapon(CAMERA_ZOOM_CHANGE, CAMERA_MAX_DIST);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Animate the targetter
	///////////////////////////////////////////////////////////////////////////////
	function AnimateTargetter(float DeltaTime)
	{
		RadarTargetAnimTime -= DeltaTime;
		if(RadarTargetAnimTime < 0)
			RadarTargetAnimTime+=(TARGET_FRAME_TIME*TARGET_FRAME_MAX);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Handle moving target instead of player
	///////////////////////////////////////////////////////////////////////////////
	function PlayerMove(float DeltaTime)
	{
		local bool bMoved;
		local float tryX, tryY;

		Super.PlayerMove(DeltaTime);

		// Don't allow chompy movement till the radar isn't paused
		// and are focussed on the player
		if(ViewTarget == MyPawn
			&& RadarTargetState != ERTargetPaused)
		{
			tryY = RadarTargetY;
			tryX = RadarTargetX;
			if(aForward > 0)
			{
				tryY -= DeltaTime*RADAR_TARGET_MOVE_MOD;
				bMoved=true;
			}
			else if(aForward < 0)
			{
				tryY += DeltaTime*RADAR_TARGET_MOVE_MOD;
				bMoved=true;
			}
			if(aStrafe > 0)
			{
				tryX += DeltaTime*RADAR_TARGET_MOVE_MOD;
				bMoved=true;
			}
			else if(aStrafe < 0)
			{
				tryX -= DeltaTime*RADAR_TARGET_MOVE_MOD;
				bMoved=true;
			}

			// Make sure the target is within it's bounds
			if(((100*tryY)*(100*tryY) + (100*tryX)*(100*tryX)) < RADAR_TARGET_MAX_RADIUS)
			{
				RadarTargetY = tryY;
				RadarTargetX = tryX;
			}

			// Check to stop looking at stats screen and return to normal game
			if(RadarTargetState == ERTargetStatsWait)
				AnimateTargetter(DeltaTime);
			else if(RadarTargetState == ERTargetStats)
			{
				AnimateTargetter(DeltaTime);
				if(bMoved)
				{
					EndRadarTarget();
				}
			}
			else
			{
				// Check to stop waiting
				if(RadarTargetState == ERTargetWaiting
					&& bMoved)
					RadarTargetState = ERTargetOn;

				if(RadarTargetState == ERTargetOn)
				{
					AnimateTargetter(DeltaTime);
					// Decrement how long target-game time is
					RadarTargetTimer-=DeltaTime;
					if(RadarTargetTimer <= 0)
					{
						RadarTargetTimer = 0.0;
						RadarTargetState = ERTargetStatsWait;
						SetupTargettingMusic();
						SetupTargetPrizeTextures();
						GotoState('PlayerRadarTargetting', 'TargetStatsScreen');
					}
				}
			}
		}
		else if(RadarTargetState >= ERTargetKilling1
			&& RadarTargetState <= ERTargetDead)
		{
			AnimateTargetter(DeltaTime);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Snap the camera to who you're killing
	///////////////////////////////////////////////////////////////////////////////
	function TargetKillsPawn(FPSPawn KillMe)
	{
		SetViewTarget(KillMe);
		bBehindView = true;
		RadarTargetState = ERTargetKilling1;
		RadarTargetX = 0.5 + FRand()*TARGET_RAND_WATCHX - TARGET_RAND_WATCHX/2;
		RadarTargetY = 0.5 + FRand()*TARGET_RAND_WATCHY - TARGET_RAND_WATCHY/2;
		MyPawn.AmbientSound = None;
		GotoState('PlayerRadarTargetting', 'WatchPawnDie');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Hurt the pawn that you see, till he dies
	///////////////////////////////////////////////////////////////////////////////
	function HurtTargetPawn()
	{
		local FPSPawn Viewpawn;
		local vector attackpos;

		Viewpawn = FPSPawn(ViewTarget);
		if(Viewpawn != None
			&& Viewpawn != MyPawn)
		{
			attackpos = Viewpawn.Location;
			attackpos += (VRand()*Viewpawn.CollisionRadius);
			// Play attack sound
			Viewpawn.PlaySound(TargetAttackSounds[Rand(ArrayCount(TargetAttackSounds))],SLOT_Misc,,,,0.5);
			// He's attacked
			if (Viewpawn.IsA('PLBossPawn'))
				Viewpawn.TakeDamage(Viewpawn.HealthMax/20, None, attackpos, VRand(), class'BloodMakingDamage');
			else if (RadarTargetState == ERTargetKilling4)
				Viewpawn.TakeDamage(Viewpawn.HealthMax, None, attackpos, VRand(), class'BloodMakingDamage');
			else
				Viewpawn.TakeDamage(Viewpawn.HealthMax/4, None, attackpos, VRand(), class'BloodMakingDamage');
			// Tell others he's been attacked
			RadarTargetHitMarker.static.NotifyControllersStatic(
				Level,
				RadarTargetHitMarker,
				Viewpawn,
				Viewpawn,
				RadarTargetHitMarker.default.CollisionRadius,
				Viewpawn.Location);
			// Freak out
			if(PersonController(Viewpawn.Controller) != None)
				PersonController(Viewpawn.Controller).GotoState('AttackedByChompy');
			// Special: If it's the fifth time and they're just not dying, force a kill
			if (ViewPawn.Health > 0
				&& RadarTargetState == ERTargetKilling4
				&& !ViewPawn.IsA('PLBossPawn'))
			{
				// If it's a zombie blow up the head
				if (ViewPawn.IsA('AWZombie'))
					ViewPawn.TakeDamage(ViewPawn.HealthMax, None, P2MoCapPawn(ViewPawn).MyHead.Location, VRand(), class'SledgeDamage');
				// Otherwise blow up the entire body (but only if they're above 1/4th health, indicating god mode or something else that won't cause them to die soon)
				else if (ViewPawn.Health > ViewPawn.HealthMax / 4)
					ViewPawn.Died(None, class'BloodMakingDamage', AttackPos);
			}
			if(ViewPawn.Health > 0 && RadarTargetState < ERTargetKilling4)
			{
				RadarTargetX = 0.5 + FRand()*TARGET_RAND_WATCHX - TARGET_RAND_WATCHX/2;
				RadarTargetY = 0.5 + FRand()*TARGET_RAND_WATCHY - TARGET_RAND_WATCHY/2;
				// Move through the killing stages
				if(RadarTargetState == ERTargetKilling1)
					RadarTargetState = ERTargetKilling2;
				else if(RadarTargetState == ERTargetKilling2)
					RadarTargetState = ERTargetKilling3;
				else if(RadarTargetState == ERTargetKilling3)
					RadarTargetState = ERTargetKilling4;
				GotoState('PlayerRadarTargetting', 'WatchPawnDie');
			}
			else
			{
				RadarTargetKills++;
				RadarTargetState = ERTargetDead;
				P2Pawn(ViewPawn).bNoRadarTarget = true;
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Put the camera back on the player
	///////////////////////////////////////////////////////////////////////////////
	function GoBackToPlayer()
	{
		SetViewTarget(MyPawn);
		bBehindView = false;
		RadarTargetState = ERTargetPaused;
		SetupTargettingMusic();
		// Reset target position
		RadarTargetX = 0;
		RadarTargetY = 0;
		// Reupdate radar
		MyPawn.ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Music plays before you kill people
	///////////////////////////////////////////////////////////////////////////////
	function SetupTargettingMusic()
	{
		MyPawn.AmbientSound = RadarTargetMusic;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Clean up in anyway (state stuff, for instance) after being
	// sent to jail
	///////////////////////////////////////////////////////////////////////////////
	function GettingSentToJail()
	{
		//log(self$" GettingSentToJail from "$GetStateName());
		// Exit this state
		GotoState('PlayerWalking');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// Put away your weapons
		SwitchToHands();
		// stop running
		MyPawn.StopAcc();
		// start the crazy music
		SetupTargettingMusic();
		// Give him god mode, to not get hurt while targetting
		bGodMode=true;
		// reset kills
		RadarTargetKills=0;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		// clear game music
		MyPawn.AmbientSound = None;
		// Setup player again
		SetViewTarget(MyPawn);
		bBehindView = false;
		// Take god mode away if necessary
		if(P2GameInfoSingle(Level.Game) == None
			|| P2GameInfoSingle(Level.Game).TheGameState == None
			|| !P2GameInfoSingle(Level.Game).TheGameState.bCheatGod)
			bGodMode=false;
	}

Begin:
	Sleep(REPORT_LOOKS_SLEEP_TIME);
	RadarTargetState = ERTargetWaiting;
Playing:
	Sleep(REPORT_LOOKS_SLEEP_TIME);
	MyPawn.ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
	Goto('Playing');
WatchPawnDie:
	Sleep(TARGET_ATTACK_TIME);
	HurtTargetPawn();
	Sleep(TARGET_WAIT_TIME);
	GoBackToPlayer();
	Goto('Begin');
TargetStatsScreen:
	Sleep(2.0);
	RadarTargetState = ERTargetStats;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PlayerSuicideByGrenade
//
// Player getting ready to commit suicide
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerSuicideByGrenade
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, ActivateInventoryItem, Jump, ThrowWeapon,
		ThrowPowerup, PrevInvItem, NextInvItem, ActivateItem, NotifyHeadVolumeChange,
		NotifyPhysicsVolumeChange, Falling, CheckMapReminder, SwitchWeapon,
		DamageAttitudeTo, Suicide, UseZipper, DudeShoutGetDown, ToggleInvHints, ToggleToHands,
		QuickUseMap, DoKick, QuickSave, CanBeMugged, WeaponZoom, WeaponZoomIn, WeaponZoomOut,
		IsSaveAllowed, ReadyForCashier, ExitSnipingState, ExitPrepToSave, SetupGettingMugged;

	///////////////////////////////////////////////////////////////////////////////
	// Both fires kill you
	///////////////////////////////////////////////////////////////////////////////
	exec function Fire( optional float F )
	{
		if ( Level.Pauser == PlayerReplicationInfo )
		{
			SetPause(false);
			return;
		}
		// client side
		GotoState('PlayerSuicidingByGrenade');
		// server side
		ServerPerformSuicide();
	}
	exec function AltFire( optional float F )
	{
		if ( Level.Pauser == PlayerReplicationInfo )
		{
			SetPause(false);
			return;
		}
		// Single player can't cancel out
		// You're more likely to accidentally hit in MP than SP.
		/*
		if(Level.Game != None
			&& Level.Game.bIsSinglePlayer)
			ServerPerformSuicide();
		else // MP can cancel out
		*/
			ClientCancelSuicide();
	}

	///////////////////////////////////////////////////////////////////////////////
	// These two zoom the camera in and out
	///////////////////////////////////////////////////////////////////////////////
	exec function NextWeapon()
	{
		if( Level.Pauser!=None)
			return;
		DeadNextWeapon(CAMERA_DEAD_ZOOM_CHANGE, CAMERA_DEAD_MIN_DIST);
	}
	exec function PrevWeapon()
	{
		if( Level.Pauser!=None)
			return;
		DeadPrevWeapon(CAMERA_DEAD_ZOOM_CHANGE, CAMERA_DEAD_MAX_DIST);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Pick the head to stare at
	///////////////////////////////////////////////////////////////////////////////
	function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
	{
		//log(self$" CalcBehindView, state "$GetStateName());
		SuicideCalcBehindView(CameraLocation, CameraRotation, Dist);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local rotator ViewRotation;

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
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
		{
			If (aLookUp > 0)
				ViewRotation.Pitch = 18000;
			else
				ViewRotation.Pitch = 49152;
		}
		SetRotation(ViewRotation);
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
	}

	simulated function BeginState()
	{
		local SavedMove Next;

		// Steven: Don't allow picking up stuff in this state.
		Pawn.bCanPickupInventory = false;

		Enemy = None;
		bBehindView = true;
		bFrozen = false;
		bPressedJump = false;
		FindGoodCameraView();
		ResetFOV();
		// Make sure the proper fog is used on this zone
		if(P2GameInfo(Level.Game) != None)
			P2GameInfo(Level.Game).SetGeneralZoneFog(Pawn);

		// Turn off twisting
		Pawn.SetTwistLook(0, 0);
		Pawn.bDoTorsoTwist=false;

		// Put away your current weapon
		SwitchToHands(true);

		// Stop running
		//mypawnfix
		P2Pawn(Pawn).StopAcc();

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

	simulated function EndState()
	{
		CleanOutSavedMoves();
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		bPressedJump = false;

		bBehindView = false;
	}
Begin:
	Sleep(1.0);
	CheckForCrackUse(1.0);
	FollowCatnipUse(1.0);
	FollowDualWieldUse(1.0);
	// Wait to make sure you're hands are all the way out
	if(!HasHandsOut())
		SwitchToHands(true);
	goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PlayerSuicidingByGrenade
//
// Player is actually pulling the pin and waiting for the explosion now
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerSuicidingByGrenade extends PlayerSuicideByGrenade
{
	ignores Fire, AltFire, EndState, TakeDamage, NotifyTakeHit, ServerPerformSuicide,
		PressingFire, PressingAltFire, ClientCancelSuicide;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function AlertOthers()
	{
		// Tell others something is wrong
		SuicideStartMarker.static.NotifyControllersStatic(
			Level,
			SuicideStartMarker,
			MyPawn,
			MyPawn,
			SuicideStartMarker.default.CollisionRadius,
			Pawn.Location);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make yourself invincible once you start this state (but the grenade
	// in your mouth will still kill you)
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		bBehindView = true;
		// Only set god mode in SP games--suicide cheat
		if(Level.Game != None
			&& FPSGameInfo(Level.Game).bIsSinglePlayer)
			bGodMode = true;
		bCommitedSuicide=true;
		//mypawnfix
		Pawn.GotoState('Suiciding');
	}
	function EndState()
	{
		// clean up
		bGodMode = false;
		Super.EndState();
	}
Begin:
	// Wait to make sure you're hands are all the way out
	if(!HasHandsOut())
	{
		SwitchToHands(true);
		Sleep(0.5);	// Give him time to put my gun away
		Goto('Begin');
	}

	//mypawnfix
	P2MocapPawn(Pawn).PlayGrenadeSuicideAnim();
	//SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Suicide) + 0.5;
	Pawn.PlaySound(P2Pawn(Pawn).DudeSuicideSound);

	//Sleep(SayTime + 0.5);
	// hacked time--make it a notify
	// You're saying your line
	Sleep(2.5);
	// And just before you tell others something is wrong
	AlertOthers();
	// Wait just a hair
	Sleep(1.0);
	// Then your head explodes
	P2Pawn(Pawn).GrenadeSuicide();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dead
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dead
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, ActivateInventoryItem, ThrowPowerup,
		PrevInvItem, NextInvItem, CheckMapReminder,
		ThrowWeapon, ActivateItem, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling,
		TakeDamage, Suicide, UseZipper, DudeShoutGetDown, WeaponZoom, WeaponZoomIn, WeaponZoomOut,
		QuickUseMap, DoKick, QuickSave, SwitchToHands, ToggleToHands, CanBeMugged, ToggleInvHints,
		IsSaveAllowed, ReadyForCashier, SetupGettingMugged, ExitPrepToSave, ExitSnipingState,
		ServerPerformSuicide, ClientCancelSuicide;

	///////////////////////////////////////////////////////////////////////////////
	// These two zoom the camera in and out
	///////////////////////////////////////////////////////////////////////////////
	exec function NextWeapon()
	{
		if( Level.Pauser!=None)
			return;
		DeadNextWeapon(CAMERA_DEAD_ZOOM_CHANGE, CAMERA_DEAD_MIN_DIST);
	}
	exec function PrevWeapon()
	{
		if( Level.Pauser!=None)
			return;
		DeadPrevWeapon(CAMERA_DEAD_ZOOM_CHANGE, CAMERA_DEAD_MAX_DIST);
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
	{
//		log(self$" p2player calcbehind view, pawn "$Pawn);
		if(Pawn != None)
			DeadCalcBehindView(CameraLocation, CameraRotation, Dist);
		else
			Super.CalcBehindView(CameraLocation, CameraRotation, Dist);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Don't allow the camera to mess up things if you've suicided (because we've
	// already gotten a good camera view at that point)
	///////////////////////////////////////////////////////////////////////////////
	function FindGoodView()
	{
		//mypawnfix
		if(P2Pawn(Pawn) != None
			&& P2Pawn(Pawn).HitDamageType != class'Suicided')
		{
			Global.FindGoodCameraView();
		}
		else
			Super.FindGoodView();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		IncDeathMessageNum();
		Super.EndState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		// Put a min cap on the camera dist
		if(CameraDist < CAMERA_DEAD_MIN_DIST)
			CameraDist = CAMERA_DEAD_MIN_DIST;

		// Let super do it's stuff
		Super.BeginState();

		ResetFOV();

		// Make sure we're not still in god mode at this point. If we don't,
		// then in MP, if we suicided, we could restart in god mode
		bGodMode=false;

		// Show the hud (for death messages)
		MyHud.bHideHud=false;

		// Force it back to normal game speed
		if(P2GameInfoSingle(Level.Game) != None)
			P2GameInfoSingle(Level.Game).SetGameSpeedNoSave(1.0);

		// Make you hang around longer staring at your dead body in MP
		if(Level.Game == None
			|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
			SetTimer(FREEZE_TIME_AFTER_DYING_MP, true);
		else
			SetTimer(FREEZE_TIME_AFTER_DYING, true);
			
		// Single player only: trigger an event
		if (FPSGameInfo(Level.Game).bIsSinglePlayer)
			TriggerEvent(PLAYER_DIED_EVENT, self, MyPawn);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	exec function GameOverRestart(optional float F)
	{
		if( Level.Pauser!=None)
			return;

		if ( !bFrozen
			&& Level.Game != None)
		{
			if(P2GameInfoSingle(Level.Game).bIsDemo)
			{
				// Go back to main menu to restart demo
				//Log("'Return to main menu' is happening while Dead in the demo.");
				P2GameInfoSingle(Level.Game).QuitGame();
			}
			else
			{
				// Load the most recent game
				Log("GameOverRestart is happening while Dead.");
				P2GameInfoSingle(Level.Game).LoadMostRecentGame();
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Spectating
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Spectating
{
	ignores ThrowPowerup, Suicide, CheckMapReminder;
}

exec function StartMe()
{
	ConsoleCommand("Start 192.168.0.3");
}

///////////////////////////////////////////////////////////////////////////////
// Say a line when you've thrown a sledge in a cow's butt
///////////////////////////////////////////////////////////////////////////////
state PlayerHitCowButtWithSledge extends PlayerWalking
{
Begin:
	Sleep(0.6);
	if(bCowHitButt)
		MyPawn.PlaySound(DudeButtHit[Rand(DudeButtHit.Length-1)+1], SLOT_Talk, 1.0);
	else
	{
		bCowHitButt = true;
		MyPawn.PlaySound(DudeButtHit[0], SLOT_Talk, 1.0);
	}

	GotoState('PlayerWalking');
}

function RestoreCheat(string CheatToRestore)
{
	// STUB
}

exec function RobMe()
{
	PlayerGotRobbed(None, true);
}

function ScoredNutShot(P2Pawn Victim);	// STUB, filled out in plplayer.
function MadeDualWieldKill(P2Pawn Victim);	// STUB, filled out in plplayer.
function ShouldUseCure(); // STUB, filled out in plplayer.

///////////////////////////////////////////////////////////////////////////////
// PlayerGotRobbed
// Function for taking all the player's shit
///////////////////////////////////////////////////////////////////////////////
function PlayerGotRobbed(class<Inventory> ItemToSteal, optional bool bTakeEverything)
{
	local RobbedInv Robber;
	local Inventory Inv, NextInv;
	local bool bPawnWeaponStolen;
	
	// Create/locate our robbery inventory
	Robber = RobbedInv(MyPawn.CreateInventoryByClass(class'RobbedInv'));
	
	// Go through inventory and give it
	Inv = Pawn.Inventory;
	while (Inv != None)
	{
		NextInv = Inv.Inventory;
		// Robber steals this item if it's on the list.
		//log("Attempting to steal"@Inv);
		if (Inv.Class == ItemToSteal || bTakeEverything)
		{
			// If it's the player's current weapon, make a note of it.
			if (Pawn.Weapon == Inv)
				bPawnWeaponStolen = true;
			// Take item away
			if (Robber.StealThisItem(Inv, MyPawn))
			// Stealing items screws the inventory chain. Start over.
			{
				Inv = Pawn.Inventory;
				//log("Stole it, starting over with"@Inv);
			}
			else			
			{
				Inv = NextInv;
				//log("Didn't steal it, moving on to"@Inv);
			}
		}
		else
		{
			Inv = NextInv;
			//log("Didn't steal it, moving on to"@Inv);
		}
	}
	
	// Switch out to hands if our weapon was taken.
	if (bPawnWeaponStolen)
		ToggleToHands(true);
}

//ErikFOV Change: Subtitle system
event CallSubtitle(sound Sound, int index, int Actorindex, Actor A)
{
	local P2HUD H;
	local String Text, ActorName;
	Local Float DisplayTime;
	local Color TextColor, NameColor, nullColor;
	local int lang, SpeakerState, Priority;

	if (bAllowSubs && bEnableSubtitles && SubtitleManager != none)
	{
		lang = SubtitleLangIndex;
		ActorName = "";
		NameColor = SubtitleManager.DefaultNameColor;

		/////////Setup Priority and color
		Priority = SubtitleManager.Priority[index];
		SpeakerState = CheckSpeakerState(A);
		TextColor = SubtitleManager.DefaultColor;

		if (SpeakerState == 1)
		{
			TextColor = SubtitleManager.AppealForPlayerColor;
		}
		else if (SpeakerState == 2)
		{
			TextColor = SubtitleManager.EnemyColor;
			//if (Priority != 0) Priority = 1;
		}
		else if (SpeakerState == 3)
		{
			if (Priority != 0) Priority = 3;
		}
		else if (SpeakerState == 4)
		{
			if (Priority != 0) return;
		}
		else if (SpeakerState == 5)
		{
			TextColor = SubtitleManager.PlayerColor;
		}

		//////////Setup text
		if (SubtitleManager.Subtitle[index].Text.length > lang)
		{
			Text = SubtitleManager.Subtitle[index].Text[lang];
		}

		//////////Setup display time
		if (SubtitleManager.DisplayTime[index].Time.length > lang && SubtitleManager.DisplayTime[index].Time[lang] != 0)
		{
			DisplayTime = SubtitleManager.DisplayTime[index].Time[lang];
		}
		else if (SubtitleManager.DisplayTime[index].Time[0] != 0)
		{
			DisplayTime = SubtitleManager.DisplayTime[index].Time[0];
		}
		else
		{
			DisplayTime = GetSoundDuration(Sound) + 2;
			if (DisplayTime < 2) DisplayTime = 2;
		}

		//////////Setup sub text color
		if (Actorindex != -1 && SubtitleManager.ActorTextColor[Actorindex] != nullColor)
		{
			TextColor = SubtitleManager.ActorTextColor[Actorindex];
		}
		else if (SubtitleManager.TextColor[index] != nullColor)
		{
			TextColor = SubtitleManager.TextColor[index];
		}

		if (Actorindex != -1 && SubtitleManager.ActorNameColor[Actorindex] != nullColor)
		{
			NameColor = SubtitleManager.ActorNameColor[Actorindex];
		}
		else if (SubtitleManager.NameColor[index] != nullColor)
		{
			NameColor = SubtitleManager.NameColor[index];
		}

		//////////Setup sub name
		if (Actorindex != -1 && SubtitleManager.ActorName[Actorindex].Text.length > lang)
		{
			ActorName = SubtitleManager.ActorName[Actorindex].Text[lang]; 
		}
		else if (SubtitleManager.SpeakerName[index].Text.length > lang && SubtitleManager.SpeakerName[index].Text[lang] != "")
		{
			ActorName = SubtitleManager.SpeakerName[index].Text[lang];
		}

		//////////Add subtitle
		H = P2HUD(myHUD);
		if (H != none && Text != "")
		{
			H.AddSubtitles(ActorName, Text, DisplayTime, NameColor, TextColor, Priority, lang);
		}
	}
}

function int CheckSpeakerState(Actor A)
{
	local P2Pawn P, S;
	local PersonController PC;
	local ScriptedController SC;
	local vector HitLocation, HitNormal, StartTrace, EndTerace;
	local Actor HitActor, VT;
	local float dist, pdist;

	if (A != none)
	{
		P = P2Pawn(Pawn);
		S = P2Pawn(A);

		if (S == none) // if speaker not pawn
			return 0;
		else if (S == P) // if speaker is player
			return 5;

		if (S != none && S.Controller != none)
			PC = PersonController(S.Controller);

		SC = ScriptedController(S.Controller);

		if (viewtarget != none) VT = viewtarget;
		else VT = self;

		if (SC != none && SC.SequenceScript != none) // if speaker controls by scripted sequence
		{
			return 1;
		}
		else if (VT != none) 
		{
			pdist = Vsize(P.location - S.location);
			dist = Vsize(VT.location - S.location);

			StartTrace = S.location;
			EndTerace.x = FClamp(pdist, 0, 50000);
			EndTerace = S.location + (EndTerace >> S.Rotation);
			EndTerace.z = P.location.z;

			HitActor = Trace(HitLocation, HitNormal, EndTerace, StartTrace, true);

			if (PC != none && P != none && HitActor == P && PC.Attacker == P) // if player is enemy for speaker and speaker look at player
			{
				return 2;
			}
			else if (PC != none && P != none && HitActor == P && PC.Attacker == None) // if speaker look at player
			{
				return 1;
			}
			else if (dist > 1000) 
			{
				StartTrace = S.location;
				EndTerace = VT.location;
				HitActor = Trace(HitLocation, HitNormal, EndTerace, StartTrace, false);
				if (HitLocation == vect(0, 0, 0)) // if player not behind the wall concerning speaker
					return 3;
				else  // if player behind the wall concerning speaker
					return 4;
			}
		}
	}
	return 0;
}
//end

simulated function StartCutscene()
{
	local SceneManager SM;
	
	SM = GetCurrentSceneManager();
	if (SM != None)
	{
		// If we can only skip if the game has been beaten once, check and set the skip flag now.
		if (SM.bLetPlayerSkipIfSeen
			&& SawCutscene(SM))
			SM.bLetPlayerSkip = true;
			
		// Record that we've seen this cutscene
		RecordCutscene(SM);
	}
}

simulated function bool SawCutscene(SceneManager InCutscene)
{
	local int i;
	local String LevelName;
	local String CutsceneName;

	// Can't see what doesn't exist
	if (InCutscene == None)
		return false;
		
	LevelName = P2GameInfo(Level.Game).ParseLevelName(Level.GetLocalURL());
	CutsceneName = LevelName $ "." $ InCutscene.Name;
		
	for (i = 0; i < CutscenesSeen.Length; i++)
	{
		if (CutscenesSeen[i] ~= CutsceneName)
			return true;
	}
	
	return false;
}

simulated function RecordCutscene(SceneManager InCutscene)
{
	local int i;
	local String LevelName;
	local String CutsceneName;

	// Can't record what isn't there
	if (InCutscene == None)
		return;
		
	// Don't record what you already saw
	if (SawCutscene(InCutscene))
		return;
	
	LevelName = P2GameInfo(Level.Game).ParseLevelName(Level.GetLocalURL());
	CutsceneName = LevelName $ "." $ InCutscene.Name;
		
	CutscenesSeen.Insert(0,1);
	CutscenesSeen[0] = CutsceneName;
	//SaveConfig();
}

// Change by NickP: MP fix
simulated function CheckPlayerValid()
{
	if(!bPlayerIsValid && Player != None)
	{
		NotifyPlayerValid();
		bPlayerIsValid = true;
	}
}

simulated function NotifyPlayerValid()
{
	SetupInteractions();
	ClientSetupSubtitles();
}

simulated function ClientSetupSubtitles()
{
	if( Level.NetMode != NM_Client )
		return;

	if( SubtitleManager == None )
		SubtitleManager = spawn(class'SubtitleManager',,,location,rotation);
	if( SubtitleManager != None && SubtitleManager.SubSound.length > 0 )
		bAllowSubs = true;
}

exec function ShowMP()
{
	ConsoleCommand("set MenuMain bShowMP true");
	ClientMessage("Multiplayer option added! Now restart the game.");
}

exec function HideMP()
{
	ConsoleCommand("set MenuMain bShowMP false");
}
// End

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// xPatch: New functions for new stuff.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PickupThrownWeapon(int GroupNum, int OffsetNum, optional bool bForceReady)
{
	// STUB. Defined in dudeplayer where it has access to the hands weapon type
}

function Texture GetCurrentClothesHandsTexture()
{	
	// STUB. Defined in dudeplayer where it has access to the clothes inv
	return None;
}

function HideWeaponSelector()
{
	// STUB. Defined in dudeplayer where it has access to the selector
}

function bool GetWeaponGroupFull(class<Inventory> InvType, optional out int MaxCount)
{
	// STUB. Defined in dudeplayer where it has access to the Dude pawn
	return false;
}

function bool UseGroupLimit()
{
	// STUB. Defined in dudeplayer
	return False;
}

function FlipMiddleFinger()
{
	// STUB. Defined in AWDudePlayer where it has access to the hands
}

// Allows to use the classic boss health icon for Classic Game
function bool ForceOldBossHealthMeter(int Index)
{
	return (KillJobs[Index].HUDIcon != None && P2GameInfoSingle(Level.Game).InClassicMode());
}

defaultproperties
{
	bAutoSwitchOnEmpty=true
	LastWeaponGroupPee=1
	HeartBeatSpeed=5
	HeartBeatSpeedAdd=14
	HeartScale=0.5
	SayThingsOnGuyDeathFreq=0.22
	SayThingsOnZombieKillFreq=0.04
	SayThingsOnGuyBurningDeathFreq=0.4
	SayThingsOnWeaponFire=0.2
	CrackDamagePercentage = 0.25;
	CrackHintTimes[0]=10
	CrackHintTimes[1]=30
	CrackHintTimes[2]=60
	CrackStartTime=400
	DefaultClassicHandsTexture=Texture'WeaponSkins.Dude_Hands'
	DefaultHandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	ReplaceHandsSkins[0]=(NewSkin=Texture'MP_FPArms.LS_hands_robber',OldSkin=Texture'WeaponSkins.Cop_Hands')
	ReplaceHandsSkins[1]=(NewSkin=Texture'MP_FPArms.LS_arms.LS_hands_gimp',OldSkin=Texture'WeaponSkins.Gimp_Hands')
	ReplaceHandsSkins[2]=(NewSkin=Texture'MP_FPArms.LS_arms.LS_hands_dude',OldSkin=Texture'WeaponSkins.Dude_Hands')
	TimeForMapReminder=900
	MapReminderRefresh=20
	RadarSize=200
	RadarShowRadius=80
	RadarMaxZ=200
	RadarScale=0.04
	RadarBackY=1.0
	BodySpeed=1.0
	CameraDist=7.0
	RadarClickSound=Sound'MiscSounds.Radar.RadarClick'
	RadarBuzzSound=Sound'MiscSounds.Radar.RadarBuzz'
	TargetAttackSounds[0] = Sound'AnimalSounds.Dog.dog_biting2'
	TargetAttackSounds[1] = Sound'AnimalSounds.Dog.dog_biting3'
	RadarTargetMusic = Sound'MiscSounds.TargetMusic'
	RadarTargetHitMarker=class'PawnShotMarker'
	SuicideStartMarker=class'PawnShotMarker'
	StuckText1="You look like you're stuck."
	StuckText2="There you go... now stay outta that spot!"
	HintsOnText="Inventory and weapon hints on are On."
	HintsOffText="Inventory and weapon hints on are Off."
	MuggerHint1="They sound serious! Better drop your"
	MuggerHint2="money if you don't want to get hurt."
	MuggerHint3="Find the money in your inventory with %KEY_InventoryPrevious%/%KEY_InventoryNext%"
	MuggerHint4="and press %KEY_ThrowPowerup% to drop it before they shoot!"
	CheckMapText1="Press %KEY_QuickUseMap% to check the map for errands to complete."
	CheckMapText2="HEY! Press %KEY_QuickUseMap% to check the freakin' map for errands to do!"
	CheckMapText3="PRESS %KEY_QUICKUSEMAP% TO CHECK THE MAP AND LOOK AT YOUR ERRANDS!"
	CheckMapText4="THIS ANNOYING MESSAGE WILL GO AWAY IF YOU PRESS %KEY_QUICKUSEMAP%!"
	DeathHints1[0]="Hmmm... looks like you're dying pretty quickly."
	DeathHints1[1]="Instead of just standing around enjoying the pain,"
	DeathHints1[2]="try running and hiding from your aggressors."
	DeathHints1[3]="Wait and hide from them and then attack them"
	DeathHints1[4]="when they come running around the corner to find you."
	DeathHints2[0]="Make sure to conserve your health powerups for the worst"
	DeathHints2[1]="fire-fights. Try to keep and eye on your health for the"
	DeathHints2[2]="best time for a health boost. Gather up lots of powerups"
	DeathHints2[3]="before going into a big battle."
	DeathHints3[0]="Take a slower pace when you get into fire-fights."
	DeathHints3[1]="If you rush through an area of people who are trying to"
	DeathHints3[2]="kill you, get ready for a lot of damage."
	DeathHints3[3]="Try moving along slowly, letting only a few of their"
	DeathHints3[4]="buddies know about you at once. They'll be easier to handle."
	FireDeathHints1[0]="That sure looks hot. I bet it hurts too."
	FireDeathHints1[1]="Did you know there's a way to put yourself out"
	FireDeathHints1[2]="when you're on fire? Yup... there sure is."
	FireDeathHints1[3]="Try thinking with your lower half next time."
	POSTALHints1[0]="Hmm, looks like this game mode isn't"
	POSTALHints1[1]="going to be so easy, is it?"
	POSTALHints1[2]="You got a free fish radar for a reason..."
	POSTALHints1[3]="Try putting it to good use, and remember that every single"
	POSTALHints1[4]="blip on that radar is packing some serious firepower."
	POSTALHints2[0]="You know what would be really useful for this mode?"
	POSTALHints2[1]="If you had some way of getting, I dunno, some kind of"
	POSTALHints2[2]="assistant that would attack enemies and draw fire for you."
	POSTALHints2[3]="Maybe you should start hunting for some doggy treats."
	POSTALHints3[0]="It sucks that you can't carry around health with you, doesn't it?"
	POSTALHints3[1]="And you can only save once per map... Maybe for this mode,"
	POSTALHints3[2]="we'll forgive you if you abuse that one save."
	POSTALHints3[3]="And if you keep up the killing, maybe you'll find"
	POSTALHints3[4]="that health isn't as scarce as you might think."
	ImpossibleHints[0]="Sorry, I got nothin'."
	ImpossibleHints[1]="You ARE playing Impossible mode after all."
	ImpossibleHints[2]="At least the enemies are kind enough to drop"
	ImpossibleHints[3]="their weapons when they die... "
// 	xPatch: Ludicrous Hints
	LudicrousHints1[0]="You better get yourself a Machete as soon as possible."
	LudicrousHints1[1]="But a Shocker and Shovel combo can be nice to start things off."
	LudicrousHints1Alt[0]="Shame you can't get a Machete in Classic Mode."
	LudicrousHints1Alt[1]="But hey, at least THEY don't have it either!"
	LudicrousHints2[0]="You are not a hero. Don't be ashamed to run away or play dirty!"
	LudicrousHints2[1]="Place unarmed grenades to make traps, block their path with fire, or combine them,"
	LudicrousHints2[2]="kick back what they throw at you, and use cat silencers (they're not just decorations!)."
	LudicrousHints2[3]="Put everything in your inventory to a good use. Every item has its purpose."
	LudicrousHints3[0]="You can't carry too many weapons in the same group. Sucks, huh?"
	LudicrousHints3[1]="At least you can always drop your current weapon to replace it."
	LudicrousHints4[0]="In this difficulty, catnip works only for 20 seconds, and your Bass Sniffer"
	LudicrousHints4[1]="radar isn't infinite. You should really consider looking for both of these"
	LudicrousHints4[2]="power-ups and make a use of them only when you really need to."
	LudicrousHints5[0]="Have you noticed that cats are also pretty crazy in this mode?"
	LudicrousHints5[1]="If you have some in your inventory, maybe throwing a few at your"
	LudicrousHints5[2]="enemies isn't such a bad idea. They can be good distractions!"
	LudicrousHints6[0]="I know what you're thinking, but the funny thing is,"	
	LudicrousHints6[1]="both 'Impossible' and this mode is perfectly possible to beat!"
	NoMoreHealthItems="You're out of healing items."
	CheatsOnText="Cheats are enabled. Hope you're happy."
	CheatsOffText="Cheats are disabled. Restart the game to re-enable achievements."
	SissyOffText="Don't be a sissy. Cheats are not allowed in this mode. :)"
	QuickSaveString="Saving" 	// Change engine's default message
	QuickKillGoodEndSound=Sound'LevelSounds.train_cross_bell_LP'
	QuickKillBadEndSound=Sound'AmbientSounds.FactoryBuzzer'
	RagdollMax=10
	TransientSoundRadius = 100
	ReticleNum=1
	ReticleAlpha=90
	Reticles[0]=Texture'P2Misc.Reticle.Reticle_Crosshair_Redline'
	Reticles[1]=Texture'P2Misc.Reticle.Reticle_Crosshair_Circular'
	Reticles[2]=Texture'P2Misc.Reticle.Reticle_Crosshair_Cross'
	Reticles[3]=Texture'P2Misc.Reticle.Reticle_Crosshair_WhiteLine'
	Reticles[4]=Texture'P2Misc.Reticle.Reticle_CrosshairOpenLg'
	Reticles[5]=Texture'P2Misc.Reticle.Reticle_CrosshairOpen'
	Reticles[6]=Texture'P2Misc.Reticle.Reticle_Red4Dots'
	Reticles[7]=Texture'P2Misc.Reticle.Reticle_GreenDot'
	Reticles[8]=Texture'P2Misc.Reticle.Reticle_RedDot'
	ReticleColor=(R=255,G=255,B=255,A=90)	// Alpha gets overwritten by ReticleAlpha
	ShowBlood=true
	HurtBarAlpha=255
	HudViewState=3
	bWeaponBob=true
	bMpHints=true
	DudeButtHit(0)=Sound'AWDialog.Dude.Dude_CowAss_1'
	DudeButtHit(1)=Sound'AWDialog.Dude.Dude_CowAss_2'
	DudeButtHit(2)=Sound'AWDialog.Dude.Dude_CowAss_3'
	DudeButtHit(3)=Sound'AWDialog.Dude.Dude_CowAss_4'
	DudeBladeKill(0)=Sound'AWDialog.Dude.Dude_EdgedWeapon_1'
	DudeBladeKill(1)=Sound'AWDialog.Dude.Dude_EdgedWeapon_2'
	DudeBladeKill(2)=Sound'AWDialog.Dude.Dude_EdgedWeapon_3'
	DudeBladeKill(3)=Sound'AWDialog.Dude.Dude_EdgedWeapon_4'
	DudeBladeKill(4)=Sound'AWDialog.Dude.Dude_UseBlade_1'
	DudeBladeKill(5)=Sound'AWDialog.Dude.Dude_UseBlade_2'
	DudeBladeKill(6)=Sound'AWDialog.Dude.Dude_UseBlade_3'
	DudeBladeKill(7)=Sound'AWDialog.Dude.Dude_UseBlade_4'		// xPatch: Unused Voiceline
	DudeMacheteThrow(0)=Sound'AWDialog.Dude.Dude_AltBlade_1'
	DudeMacheteThrow(1)=Sound'AWDialog.Dude.Dude_AltBlade_2'
	DudeMacheteThrow(2)=Sound'AWDialog.Dude.Dude_AltBlade_3'
	DudeMacheteCatch(0)=Sound'AWDialog.Dude.Dude_Machete_Daddy'
	DudeMacheteCatch(1)=Sound'AWDialog.Dude.Dude_Machete_Fingers'
	DudeMacheteCatch(2)=Sound'AWDialog.Dude.Dude_Machete_ImGood'
	DudeMacheteCatch(3)=Sound'AWDialog.Dude.Dude_Machete_ThereItIs'
	DudeHalloweenKill(0)=Sound'DudeDialog.dude_halloween_happyhalloween1'
	DudeHalloweenKill(1)=Sound'DudeDialog.dude_halloween_happyhalloween2'
	DudeHalloweenKill(2)=Sound'DudeDialog.dude_halloween_happyhalloween3'
	DudeHalloweenKill(3)=Sound'DudeDialog.dude_halloween_trickortreat1'
	DudeHalloweenKill(4)=Sound'DudeDialog.dude_halloween_trickortreat2'
	DudeHalloweenKill(5)=Sound'DudeDialog.dude_halloween_trickortreat3'
	DudeZombieKill(0)=Sound'AWDialog.Dude.Dude_Zombies_1'	// xPatch: Unused Voiceline
	DudeZombieKill(1)=Sound'AWDialog.Dude.Dude_Zombies_2'	// xPatch: Unused Voiceline
	DudeZombieKill(2)=Sound'AWDialog.Dude.Dude_Zombies_3'	// xPatch: Unused Voiceline
	DudeZombieKill(3)=Sound'AWDialog.Dude.Dude_Zombies_4'	// xPatch: Unused Voiceline
	DudeZombieKill(4)=Sound'AWDialog.Dude.Dude_Zombies_5'	// xPatch: Unused Voiceline
	SayThingsOnCatch=0.200000
	SayThingsOnThrow=0.200000
	ShakeRotMag=(X=300.000000,Y=50.000000,Z=50.000000)
	ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
	ShakeRotTime=6.000000
	ShakeOffsetMag=(X=5.000000,Y=5.000000,Z=5.000000)
	ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
	ShakeOffsetTime=6.000000
	JoySensitivity=1.4
	LookSensitivityX=1.4
	LookSensitivityY=1.5
	
	// xPatch: New Crosshairs
	bHUDCrosshair=True
	ReticleGroup=1
	ReticleSize=1.00
	ReticleRed=136
	ReticleGreen=255
	ReticleBlue=136
	NewReticles[0]=Texture'xPatchTex.Crosshairs.Crosshair_01'
	NewReticles[1]=Texture'xPatchTex.Crosshairs.Crosshair_03' 
	NewReticles[2]=Texture'xPatchTex.Crosshairs.Crosshair_02'
	NewReticles[3]=Texture'xPatchTex.Crosshairs.Crosshair_04'
	NewReticles[4]=Texture'xPatchTex.Crosshairs.Crosshair_05'
	NewReticles[5]=Texture'xPatchTex.Crosshairs.Crosshair_06'
	NewReticles[6]=Texture'xPatchTex.Crosshairs.Crosshair_07'
	NewReticles[7]=Texture'xPatchTex.Crosshairs.Crosshair_08'
	NewReticles[8]=Texture'xPatchTex.UniqueCrosshair'
	
	// xPatch: Alternative hands skins
	AltHandsSkins[1]=Texture'xPatchExtraTex.LS_hands_dude_black'
	AltHandsSkins[2]=Texture'xPatchExtraTex.LS_hands_dude_black2'
}