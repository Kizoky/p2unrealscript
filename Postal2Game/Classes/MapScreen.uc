///////////////////////////////////////////////////////////////////////////////
// MapScreen.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The map screen.
//
//	History:
//      11/05/12 JWB    Fixed for widescreen, doesn't stretch
//                      unless user wants it too.
//
//		07/03/02 MJR	Now displays You-Are-Here marker on map.
//
//		06/06/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
//
// This is the overall sequence of events:
//		- Pause game
//		- Fade out game screen
//		- Fade in map screen
//		- If errand is about to be completed, cross out errand
//		- If errands are being revealed, reveal them one at a time
//		- Wait for player to press key
//		- Fade out map screen
//		- Fade in game screen
//		- Resume game
//
//
// YOU ARE HERE
//
// One of the key functions of the map is to show the player where he is in
// the overall game world.  This is somewhat tricky because the map shows
// the world as if it's one contiguous level, when instead it's actually made
// of many smaller levels all pieced together in a rather haphazard manner.
//
// For instance, if you took any two levels that are linked together and put
// them side-by-side, the link points probably wouldn't line up at all.
// So we can't use any kind of simple mapping scheme to translate the player's
// real location into a position on the map.
//
// Instead, we use a scheme that relies on the level designers to place a
// bunch of MapPoint's in their levels.  The purpose of a MapPoint is to
// relate a location in the level with a point on the map.
//
// For example, let's say you place a MapPoint right in the middle of an
// intersection of two roads.  You would give it a unique tag, which should
// be the level name followed by some indication of where it is located,
// like maybe "suburbs-3-nw" for "north west".  You would then look at the
// 2D map in Photoshop and get the X,Y coordinates of where those roads
// intersect.  Finally, you would enter the unique tag and the X,Y coords
// in the MapPositions array (in this class).  At runtime we can then easily
// associate a MapPoint's 3D positon in the world with it's 2D position on the
// map.  (By the way, the reason for keeping the 2D coordinates in an array
// in this file rather than stuffing them directly into the MapPoint's using
// the editor is that this method makes it much easier to tweak and tune the
// 2D positions which need to be changed everytime the map is modified, which
// occurs quite frequently.)
//
// So if the player were standing right at that MapPoint then we'd know
// exactly where to draw the "You Are Here" marker on the map.  Of course it
// gets a little more complicated because he's rarely standing directly at
// a MapPoint, but that's the general idea.
//
// The more MapPoints the better, especially because, as mentioned earlier,
// there is likely to be a lot of distortion in the map as a result of trying
// to make it look right even thought the levels don't really line up.
//
// Accuracy is EXTREMELY important!  Be very careful to make sure the MapPoint's
// level location lines up as well as possible with it's map location.
//
///////////////////////////////////////////////////////////////////////////////
class MapScreen extends P2Screen;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var DayBase				Day;				// current day
var int					DayIndex;			// current day index
var GameState			gs;					// current game state
var bool				bGoFast;			// whether to do everything fast (player is in a hurry)
var bool				bNoFast;			// whether to block fast mode
var int					LongDudeLineTime;
enum EMapMode
	{
	Mode_JustLooking,
	Mode_RevealErrands,
	Mode_CrossOutErrand,
	Mode_ShowHaters
	};
var EMapMode			Mode;				// What mode the map screen is in

enum ESpriteStatus
	{
	SS_Off,
	SS_Fading,
	SS_On
	};
struct Sprite								// Simple sprite
	{
	var Texture			tex;				// texture
	var float			x;					// x coord
	var float			y;					// y coord
	var ESpriteStatus	status;				// status
	};
var array<Sprite>		Sprites;			// Array of sprites
var int					SpritesNextUnused;	// Used for allocating sprites

var() array<vector>		ErrandPositions;	// Where errand names and crossouts are drawn
var() float				ErrandNameFadeTime;		// Time for fading in name
var() float				ErrandNameCommentPad;	// Extra time after comment about errand
var() float				ErrandWhereCommentPad;	// Extra time after comment asking where it is
var() float				ErrandLocFadeTime;		// Time for fading in location
var() float				ErrandLocCommentPad;	// Extra time after comment about location
var() float				ErrandBetweenTime;		// Time between errands (if doing multiple errands)
var String				PostRevealSendToURL;// optional URL to send player to after errands are revealed
var int					RevealErrand;		// errand currently being revealed
var int					RevealCount;		// number of errands that were revealed
var int					ErrandNameBase;		// index of first errand name sprite
var int					ErrandLocBase;		// index of first errand location sprite
var int					ErrandLocCrossBase;	// index of first errand location crossout sprite
var bool				bFancyMapFade;

var() array<Texture>	CrossoutTex;		// Crossout textures
var() float				CrossoutFadeTime;	// Time for fading in crossout
var() float				CrossoutCommentPad;	// Extra time after comment about completing errand
var int					CrossOutErrand;		// index of errand to cross out
var int					CrossoutBase;		// index of first crossout sprite

var() array<vector>		HaterDesPositions;	// Hater description positions
var() array<vector>		HaterPicPositions;	// Hater picture positions
var() texture			HateTitleTex;		// Hater title texture
var() vector			HateTitlePosition;	// Hater title position
var() float				HaterTitleFadeTime;
var() float				HaterTitlePad;		// Extra time after title appears but before name appears
var() float				HaterPicFadeTime;
var() float				HaterPicPad;		// Extra time after picture appears
var() float				HaterDesFadeTime;
var() float				HaterDesPad;		// Extra time after description appears
var() float				HaterBetweenTime;	// Time between haters (if doing multiple haters)
var() float				HaterCommentPad;
var int					HaterIndex;			// hater currently being revealed
var int					HaterTitleBase;
var int					HaterDesBase;
var int					HaterPicBase;

var Texture				BlackBox;			// Blacks out some screen for text to show up better

var int					EscapeBase;

var float				LastFrameTime;

var() float				PreReadyForHome;
var() float				BigHoldTime;
var() float				FastTime;

var() array<Sound>		WritingSounds;		// Writing sounds
var() array<Sound>		DudeGoHomeSounds;	// Things dude says when he needs to go home
var() array<Sound>		DudeLostOnMap;		// Dudes says this when he's completely lost (not marked on the map)
var() bool				bDudeIsLost;		// There's no arrow, so the dude is lost
var() float				WritingVolume;
var() float				DudeVolume;

var() StaticMesh		HeadMesh;
var() float				HeadScaleMin;
var() float				HeadScaleMax;
var() float				HeadScaleGiant;
var RawActor			HeadMarker;

var() StaticMesh		TrailMesh;
var() float				TrailScaleMin;
var() float				TrailScaleMax;
var() float				TrailUpdateDistance;// Trail is updated when players moves this distance
var() const float		TrailPulseCycle;
var float				TrailPulseTime;
var bool				bTrailGiantHead;
var bool				bDrawTrail;
var RawActor			TrailMarker;
var int					TrailHead;			// index to most recent player position
var int					TrailCount;			// number of player positions
struct STrailItem
	{
	var vector Loc;
	var int Yaw;
	};
var STrailItem			Trail[10];			// trail of player positions over time
var STrailItem			TrailSaveHead;

var Texture				DebugTex1;			// texture used to draw points (for debugging)
var Texture				DebugTex2;			// texture used to draw points (for debugging)

struct SMapPos
	{
	var() name			UniqueTag;			// The unique tag of the MapPoint this position is associated with
	var() vector		Pos;				// Position on map corresponding to MapPoint's world position
	};
var() array<SMapPos>	MapPositions;		// Used to associate MapPoint's with their map positions

var() localized String	ReminderMessage1;	// Hint message to point out your errands
var() localized String	ReminderMessage2;
var() localized String	ReminderMessage3;
var() localized String	ReminderMessage4;
var() localized String	ReminderMessage5;
var() float		ReminderMsgX;				// ReminderMessage x position (% of screen width)
var() float		ReminderMsgY;				// ReminderMessage y position (% of screen height)
var() float		ReminderYInc;				// How much to move down for each extra line of remainder messages

var array<int>			EndKeys;			// Keys that can be pressed to end this screen

var	bool				bUnpauseAfterReaveal;

// 11/05/12 JWB whether or not the user wants to stretch the map/voting card
// 11/12/12 JWB	Holds bStretch from P2Screen.uc
var  bool             bEnableWidescreenStretch;


// The number of MapPoints to use when calculating player position.  Must be
// at least 2.  My original idea was to use several pairs of points to get
// better results, but because the map is very distorted compared to the
// world, using more points just results in more error.  So 2 is the right value.
const NUM_REF_POINTS				= 2;

// This is the maximum difference in angles between the world and map lines
// taht we support.  It's unlikely there would ever be more than a 90 degree
// difference.  This must be less than 180 or the results will be screwed up.
const MAX_DIFF_DEGREES				= 135;

// Multiply by these to convert from one to the other
const DEGREES_TO_RADIANS			=  0.01745;
const RADIANS_TO_DEGREES			= 57.29577;

// Yaw needs to be corrected when going from world to map
const YAW_CORRECTION				= 16384;

// Debug flags
const DISPLAY_DEBUG_AIDS			= 0;
const PLAY_GAME_WITH_MAP_RUNNING	= 0;

// Alpha darkness (255 would be black) for background behind hint text
const BACKTEXT_ALPHA				= 180;
// Part of darker message background that extends below bottom of text
const BOTTOM_FADE_BUFFER			= 0.01;

// 11/05/12 JWB
// This is the magical equation that will solve all of our widescreen stretching problems
// Result of 4/3, just need to use it to solve x in = x/y part
// What a mouth full..
const FOUR_BY_THREE_ASPECT_RATIO = 1.33333333333;


///////////////////////////////////////////////////////////////////////////////
// Called after this object has been created
///////////////////////////////////////////////////////////////////////////////
event Initialized()
	{
	Super.Initialized();


	ClearTrail();
	}

///////////////////////////////////////////////////////////////////////////////
// Check the users widescreen preferences
///////////////////////////////////////////////////////////////////////////////
function CheckWidescreenPreference()
{
    //bEnableWidescreenStretch = Super.isStretched();
    bEnableWidescreenStretch = GetGameSingle().GetWidescreenStretch();
	//Log("MapScreen.uc " @ bEnableWidescreenStretch);
}

///////////////////////////////////////////////////////////////////////////////
// Show map normally (nothing special, player just wants to look at it)
///////////////////////////////////////////////////////////////////////////////
function Show()
	{
	MapInit();

    // 11/05/12 JWB Check to see if the user enabled Widescreen Stretch
    //bEnableWidescreenStretch = ConsoleCommand("get" @ WidescreenStretchPath);


    //Log("bEnableWidescreenStretch = " @ bEnableWidescreenStretch);
    //Log(ConsoleCommand("get" @ WidescreenStretchPath));

	// In a real game, ShowErrands() is always used at the start of a day,
	// so by the time the player has control, the errands have already been
	// revealed.  Also, when new errands are activated, the map is always
	// brought up immediately or shortly thereafter.  So the only time there
	// should be unrevealed errands at this point is when we're testing maps.
	// So if that's the case, we switch modes to reveal the errands.
	if (FindUnrevealedErrand(-1) != -1)
		{
		ShowErrands();
		}
	else
		{
		Mode = Mode_JustLooking;
		AfterFadeInScreen = 'JustLooking';
		MapStart(true, PLAY_GAME_WITH_MAP_RUNNING > 0);
		}

	}

///////////////////////////////////////////////////////////////////////////////
// Show map and reveal any unrevealed errands
///////////////////////////////////////////////////////////////////////////////
function ShowErrands(optional String SendToURL, optional bool bWantFancyFadeIn)
	{
	MapInit();

	// Only allow this mode if there are unrevealed errands
	if (FindUnrevealedErrand(-1) != -1)
		{
		// Normally we don't allow the player to skip this stuff because they
		// might miss something useful/funny, but when we're testing/debugging
		// we definitely want to be able to skip it.

		// Disabled per Jon
		//if (!GetGameSingle().bTesting && !GetPlayer().DebugEnabled())
		//	bNoFast = true;

		Mode = Mode_RevealErrands;
		PostRevealSendToURL = SendToURL;
		if (SendToURL != "" || bWantFancyFadeIn)
			{
			bUnpauseAfterReaveal = bWantFancyFadeIn;
			bFadeGameInOut = false;
			FadeInGameTime = 0.0;
			FadeOutGameTime = 0.0;
			bFadeScreenInOut = false;
			FadeInScreenTime = 0.0;
			FadeOutScreenTime = 0.0;
			bFancyMapFade = true;
			AfterFadeInScreen = 'RevealErrandsAlphaIn';
			MapStart(false, true);
			}
		else
			{
			AfterFadeInScreen = 'RevealErrands';
			MapStart(false);
			}
		}
	else
		Show();
	}

///////////////////////////////////////////////////////////////////////////////
// Show map and show any new haters
///////////////////////////////////////////////////////////////////////////////
function ShowHaters(optional String SendToURL)
	{
	MapInit();

	// Only allow this mode if there are new haters
	if (FindNewHaters(-1) != -1)
		{
		Mode = Mode_ShowHaters;
		PostRevealSendToURL = SendToURL;
		if (SendToURL != "")
			{
			/*
			bFadeGameInOut = false;
			FadeInGameTime = 0.0;
			FadeOutGameTime = 0.0;
			bFadeScreenInOut = false;
			FadeInScreenTime = 0.0;
			FadeOutScreenTime = 0.0;
			bFancyMapFade = true;
			*/
			AfterFadeInScreen = 'NewHaters';
			MapStart(false);
			}
		else
			{
			AfterFadeInScreen = 'NewHaters';
			MapStart(false);
			}
		}
	else
		Show();
	}

///////////////////////////////////////////////////////////////////////////////
// Show map and cross out the specified errand
///////////////////////////////////////////////////////////////////////////////
function ShowCrossOut(int ErrandIndex, optional string SendToURL)
	{
	MapInit();
	Mode = Mode_CrossOutErrand;
	CrossOutErrand = ErrandIndex;
	AfterFadeInScreen = 'CrossOut';
	PostRevealSendToURL = SendToURL;
	MapStart(false);
	}

///////////////////////////////////////////////////////////////////////////////
// Call from various Show***() functions before doing anything.
///////////////////////////////////////////////////////////////////////////////
function MapInit()
	{
	SetupActors();
	CheckWidescreenPreference();
	Day = GetGameSingle().GetCurrentDayBase();
	DayIndex = GetGameSingle().GetCurrentDay();
	bGoFast = false;
	bNoFast = false;
	bFancyMapFade = false;
	bFadeScreenInOut = default.bFadeScreenInOut;
	FadeInGameTime = default.FadeInGameTime;
	FadeInScreenTime = default.FadeInScreenTime;
	bFadeGameInOut = default.bFadeGameInOut;
	SetupEndKeys();
	bWantInputEvents = true;
	}

function SetupEndKeys()
	{
	local int i;
	local int key;

	EndKeys.remove(0, EndKeys.length);

	// Find all keys with the specified binding
	do	{
		key = int(ViewportOwner.Actor.ConsoleCommand("BINDING2KEYVAL \"QuickUseMap\"" @ i));
		if (key != 0)
			{
			EndKeys.insert(i, 1);
			EndKeys[i] = key;
			}
		i++;
		} until (key == 0);
	}

///////////////////////////////////////////////////////////////////////////////
// Call from various Show***() functions to actually start the map
///////////////////////////////////////////////////////////////////////////////
function MapStart(bool bShowTrail, optional bool bDontPauseGame_In)
	{
	Backgroundtex = Day.GetMapTexture();

	// Setup trail stuff before it gets shown
	PreShowTrail();

	SetupSprites();

	if (bShowTrail)
		ShowTrail();

	bDontPauseGame = bDontPauseGame_In;

	Super.Start();
	}

///////////////////////////////////////////////////////////////////////////////
// This is called when this screen is about to shutdown.
///////////////////////////////////////////////////////////////////////////////
function ShuttingDown()
	{
	PostShowTrail();
	}

///////////////////////////////////////////////////////////////////////////////
// Called before player travels to a new level
///////////////////////////////////////////////////////////////////////////////
function PreTravel()
	{
	Super.PreTravel();

	// Get rid of all actors because they'll be invalid in the new level (not
	// doing this will lead to intermittent crashes!)
	gs = None;
	HeadMarker = None;
	TrailMarker = None;
	}

///////////////////////////////////////////////////////////////////////////////
// Player has traveled to new level
///////////////////////////////////////////////////////////////////////////////
function PostTravel()
	{
	Super.PostTravel();

	// Restore actors that were destroyed in PreTravel()
	SetupActors();

	// Clear trail because old positions will be incorrect in new level
	ClearTrail();
	}

///////////////////////////////////////////////////////////////////////////////
// Setup all actors used by this screen
///////////////////////////////////////////////////////////////////////////////
function SetupActors()
	{
	// Get gamestate
	gs = GetGameSingle().TheGameState;

	// Spawn actors for head and trail markers
	if (HeadMarker == None)
		{
		HeadMarker = ViewportOwner.Actor.Spawn(class'RawActor', ViewportOwner.Actor);
		HeadMarker.SetStaticMesh(HeadMesh);
		HeadMarker.SetDrawType(DT_StaticMesh);
		HeadMarker.bUnlit = true;
		}
	if (TrailMarker == None)
		{
		TrailMarker = ViewportOwner.Actor.Spawn(class'RawActor', ViewportOwner.Actor);
		TrailMarker.SetStaticMesh(TrailMesh);
		TrailMarker.SetDrawType(DT_StaticMesh);
		TrailMarker.bUnlit = true;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Allocate a number of sprites.
// Returns the starting index for the allocated number of sprites.
///////////////////////////////////////////////////////////////////////////////
function int AllocateSprites(int Num)
	{
	local int Base;
	local int ReqLen;
	local int i;

	// When allocating new sprites, only increase the array size if necessary.
	// The array never shrinks.  Each time the map is called, we start the
	// SpritesNextUnused at 0, thereby re-using previously-allocated sprites.
	Base = SpritesNextUnused;
	ReqLen = SpritesNextUnused + Num;
	if (ReqLen > Sprites.length)
		Sprites.insert(Sprites.length, ReqLen - Sprites.length);
	SpritesNextUnused += Num;

	// Clear newly allocated sprites to avoid any nasty surprises
	for (i = Base; i < SpritesNextUnused; i++)
		{
		Sprites[i].tex = None;
		Sprites[i].x = 0;
		Sprites[i].y = 0;
		Sprites[i].status = SS_Off;
		}

	return Base;
	}

///////////////////////////////////////////////////////////////////////////////
// Set all sprites to the proper settings for when the map first appears.
///////////////////////////////////////////////////////////////////////////////
function SetupSprites()
	{
	//ErikFOV Change: Fix problem
		//local canvas Canvas;
	//end
	local int i, j;
	local float x, y;
	local int RevealedHaters;
	local float MapScale, MapX, MapY;
    local float NearestFourByThree, OffsetX;

	//ErikFOV Change: Fix problem
		//NearestFourByThree = FOUR_BY_THREE_ASPECT_RATIO * (Canvas.SizeY);
		//OffsetX = (Canvas.ClipX - NearestFourByThree) /2;
	//end

	// Clear previously allocated sprites
	SpritesNextUnused = 0;

	// Setup all errand names and locations
	ErrandNameBase = AllocateSprites(Day.NumErrands());
	ErrandLocBase = AllocateSprites(Day.NumErrands());
	ErrandLocCrossBase = AllocateSprites(Day.NumErrands());
	CrossoutBase = AllocateSprites(Day.NumErrands());
	for (i = 0; i < Day.NumErrands(); i++)
		{
		Sprites[ErrandNameBase+i].tex = Day.GetErrandName(i);
		Sprites[ErrandNameBase+i].x = ErrandPositions[i].X;
		Sprites[ErrandNameBase+i].y = ErrandPositions[i].Y;
		Sprites[ErrandNameBase+i].status = SS_Off;

		Sprites[ErrandLocBase+i].tex = Day.GetErrandLocation(i, x, y);
		Sprites[ErrandLocBase+i].x = x;
		Sprites[ErrandLocBase+i].y = y;//y;
		Sprites[ErrandLocBase+i].status = SS_Off;

		Sprites[ErrandLocCrossBase+i].tex = Day.GetErrandLocationCrossout(i, x, y);
		Sprites[ErrandLocCrossBase+i].x = x;
		Sprites[ErrandLocCrossBase+i].y = y;
		Sprites[ErrandLocCrossBase+i].status = SS_Off;

		Sprites[CrossoutBase+i].tex = CrossoutTex[i];
		Sprites[CrossoutBase+i].x = ErrandPositions[i].X;
		Sprites[CrossoutBase+i].y = ErrandPositions[i].Y;
		Sprites[CrossoutBase+i].status = SS_Off;

		// Crossout completed errands and locations, unless it's the errand that's about to be crossed off
		if (Day.IsErrandActive(i) && Day.IsErrandComplete(i) && !(Mode == Mode_CrossOutErrand && i == CrossOutErrand))
			{
			if (Sprites[ErrandNameBase+i].tex != None)
				Sprites[CrossoutBase+i].status = SS_On;
			if (Sprites[ErrandLocCrossBase+i].tex != None)
				Sprites[ErrandLocCrossBase+i].status = SS_On;
			}
		}

	// Turn on the name and location for each errand that has been revealed.
	for (i = 0; i < gs.RevealedErrands.length; i++)
		{
		if (gs.RevealedErrands[i].Day == DayIndex)
			{
			j = gs.RevealedErrands[i].Errand;
			Sprites[ErrandNameBase+j].status = SS_On;
			}
		}
	for (i = 0; i < gs.RevealedLocationTex.length; i++)
		{
		if (gs.RevealedLocationTex[i].Day == DayIndex)
			{
			j = gs.RevealedLocationTex[i].Errand;
			if (Sprites[ErrandLocBase+j].tex != None)
				Sprites[ErrandLocBase+j].status = SS_On;
			}
		}		

	// If there are any haters then setup hater sprites
	if (gs.CurrentHaters.length > 0)
		{
		HaterDesBase = AllocateSprites(gs.CurrentHaters.length);
		HaterPicBase = AllocateSprites(gs.CurrentHaters.length);
		for (i = 0; i < gs.CurrentHaters.length; i++)
			{
			Sprites[HaterDesBase+i].status = SS_Off;
			if (gs.CurrentHaters[i].DesTex != '')
				{
				Sprites[HaterDesBase+i].Tex = Texture(DynamicLoadObject(String(gs.CurrentHaters[i].DesTex), class'Texture'));
				Sprites[HaterDesBase+i].x = HaterDesPositions[i].x;
				Sprites[HaterDesBase+i].y = HaterDesPositions[i].y;
				}
			Sprites[HaterPicBase+i].status = SS_Off;
			if (gs.CurrentHaters[i].PicTex != '')
				{
				Sprites[HaterPicBase+i].Tex = Texture(DynamicLoadObject(String(gs.CurrentHaters[i].PicTex), class'Texture'));
				Sprites[HaterPicBase+i].x = HaterPicPositions[i].x;
				Sprites[HaterPicBase+i].y = HaterPicPositions[i].y;
				}

			if (gs.CurrentHaters[i].Revealed == 1)
				{
//				Sprites[HaterDesBase+i].status = SS_On;
				Sprites[HaterPicBase+i].status = SS_On;
				RevealedHaters++;
				}
			}

		// Setup hater title (turn on if there are any revealed haters)
		HaterTitleBase = AllocateSprites(1);
		Sprites[HaterTitleBase].tex = HateTitleTex;
		Sprites[HaterTitleBase].x = HateTitlePosition.X;
		Sprites[HaterTitleBase].y = HateTitlePosition.Y;
//		if (RevealedHaters > 0)
//			Sprites[HaterTitleBase].status = SS_On;
//		else
//			Sprites[HaterTitleBase].status = SS_Off;
		}

//	EscapeBase = AllocateSprites(1);
	}

///////////////////////////////////////////////////////////////////////////////
// Simple sprite functions
///////////////////////////////////////////////////////////////////////////////
function SpriteFadeIn(int SpriteIndex, float time)
	{
	SetFadeIn(time);
	Sprites[SpriteIndex].status = SS_Fading;
	}

function SpriteTurnOn(int SpriteIndex)
	{
	Sprites[SpriteIndex].status = SS_On;
	}

function SpriteTurnOff(int SpriteIndex)
	{
	Sprites[SpriteIndex].status = SS_Off;
	}

///////////////////////////////////////////////////////////////////////////////
// Setup before trail is shown
///////////////////////////////////////////////////////////////////////////////
function PreShowTrail()
	{
	local vector PlayerLoc;
	local int PlayerYaw;

	bDrawTrail = false;

	// Get player's current location and direction
	PlayerLoc = GetPlayer().GetMapLocation();
	PlayerYaw = GetPlayer().GetMapDirection();

	// In case the map comes up before the trail has been updated for the
	// first time, force the update here.
	if (TrailCount == 0)
		AddToTrail(PlayerLoc, PlayerYaw);

	// The trail will normally have several entries in it already, each spaced
	// apart by whatever the minimum travel distance is.  But the player wants to
	// know EXACTLY where he is right now, not where he was the last time the
	// trail was updated.  We don't actually want to modify the trail, instead we
	// just temporarily update the head of the trail to reflect the player's
	// current location and direction, and then when this screen ends we'll
	// restore the head's previous values.
	TrailSaveHead.Loc = Trail[TrailHead].Loc;
	TrailSaveHead.Yaw = Trail[TrailHead].Yaw;
	Trail[TrailHead].Loc = PlayerLoc;
	Trail[TrailHead].Yaw = PlayerYaw;
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to show the trail
///////////////////////////////////////////////////////////////////////////////
function ShowTrail()
	{
	bDrawTrail = true;
	ResetPulse();
	}

///////////////////////////////////////////////////////////////////////////////
// Cleanup after trail is no longer being shown
///////////////////////////////////////////////////////////////////////////////
function PostShowTrail()
	{
	bDrawTrail = false;

	// Restore trail head
	Trail[TrailHead].Loc = TrailSaveHead.Loc;
	Trail[TrailHead].Yaw = TrailSaveHead.Yaw;
	}

///////////////////////////////////////////////////////////////////////////////
// Clear the trail of player positions
///////////////////////////////////////////////////////////////////////////////
function ClearTrail()
	{
	TrailHead = 0;
	TrailCount = 0;
	}

///////////////////////////////////////////////////////////////////////////////
// Reset pulse stuff
///////////////////////////////////////////////////////////////////////////////
function ResetPulse()
	{
	TrailPulseTime = 0.0;
	bTrailGiantHead = true;
	}

///////////////////////////////////////////////////////////////////////////////
// Update the trail of player positions.  The player calls this periodically.
///////////////////////////////////////////////////////////////////////////////
function UpdateTrail(Vector Loc, int Yaw)
	{
	local float distance;

	// Don't update trail while map is running because it will screw up the
	// head, which is temporarily modified while the map is running.
	if (!bIsRunning)
		{
		if (TrailCount == 0)
			{
			AddToTrail(Loc, Yaw);
			}
		else
			{
			// It would be great if we could determine the minimum distance at
			// runtime based on the scale of the map.  For now it's just hardwired
			// and needs to be changed depending on the map's scale.
			distance = VSize(Loc - Trail[TrailHead].Loc);
			if (distance > TrailUpdateDistance)
				AddToTrail(Loc, Yaw);
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Add player location to the head of the trail
///////////////////////////////////////////////////////////////////////////////
function AddToTrail(Vector Loc, int Yaw)
	{
	if (++TrailHead == ArrayCount(Trail))
		TrailHead = 0;
	if (TrailCount < ArrayCount(Trail))
		TrailCount++;
	Trail[TrailHead].Loc = Loc;
	Trail[TrailHead].Yaw = Yaw;
	}

///////////////////////////////////////////////////////////////////////////////
// Render the screen
//
// I'm still not 100% sure, but it has seemed as if some bugs might have been
// due to this code being executed in the middle of state code.  Just to be
// safe, this code should not modify any values -- it should be "read only".
///////////////////////////////////////////////////////////////////////////////
function RenderScreen(canvas Canvas)
	{
	local Texture tex;
	local float alpha;
	local int s;
	local float MapScale, MapX, MapY;
    local float NearestFourByThree, OffsetX;

	if (bEnableRender)
		{
		// Calculate overall scaling (background stretched out to full canvas)
		ScaleX = Canvas.ClipX / BackgroundTex.USize;
		ScaleY = Canvas.ClipY / BackgroundTex.VSize;

		// NOTE: If map is drawn using STY_Normal then trail doesn't show up.  Using
		// STY_Alpha fixes this problem.  My guess is it has something to do with alpha'd
		// items being sorted separately during rendering.
		// In any case, we now have other reasonss why we want the map to be alpha'd.
		Canvas.Style = 5; //ERenderStyle.STY_Alpha;

		// Calculate map scaling and positioning.  Normally the scale is 1.0 so it
		// takes up the full screen, but it changes when we're doing the "fade in while
		// flying towards the screen" sequence.
		if (!bFancyMapFade)
			{
			// For debugging use alpha, otherwise it's opaque
			if (PLAY_GAME_WITH_MAP_RUNNING > 0)
				Canvas.SetDrawColor(255, 255, 255, 100);
			else
				Canvas.SetDrawColor(255, 255, 255, 255);
			MapScale = 1.0;
			MapX = 0;
			MapY = 0;
			}
		else
			{
			Canvas.SetDrawColor(255, 255, 255, FadeAlpha);
			MapScale = 0.5 + ((FadeAlpha / 255) * 0.5);
			MapX = (Canvas.SizeX - (Canvas.SizeX * MapScale)) / 2;
			MapY = (Canvas.SizeY - (Canvas.SizeY * MapScale)) / 1.5;

			}
			
		// Quick hack to fix 1280x1024 (Looking into it later)	
		if((Canvas.ClipX / Canvas.ClipY) == 1.25)
		  bEnableWidescreenStretch = true;

        // Grab the nearest 4:3 resolution
        NearestFourByThree = FOUR_BY_THREE_ASPECT_RATIO *(Canvas.SizeY * MapScale);
        OffsetX = (Canvas.ClipX - NearestFourByThree) /2;


        // 11/12/12 JWB "Hey game is Widescreen stretch enabled? No? Well Alright."
		// We use this instead of the super function to draw tiled background, because it breaks fadein/out.
		// Also it causes some really ugly aliasing. (Like eye bleeding aliasing)
        if(!bEnableWidescreenStretch)
        {
            // Lets get this background colour out of the way...
			// Don't use MapX, MapY. They scale, and cause issues with the fade in and fade out.
            Canvas.SetPos(0, 0);
            //Canvas.DrawTile(TileTex, Canvas.SizeX, Canvas.SizeY, 0, 0, TileTex.USize, TileTex.VSize);
			if(Canvas.SizeX > NearestFourByThree)
			Canvas.SetPos(OffsetX, MapY);
			else
			Canvas.SetPos(MapX, MapY);
        }
		else
			Canvas.SetPos(MapX, MapY);


        //Canvas.DrawTile(BackgroundTex, Canvas.SizeX * MapScale, Canvas.SizeY * MapScale, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);

        // scale image height to canvas height, and then use equation to find x
        if(!bEnableWidescreenStretch)
        {
            Canvas.DrawTile(BackgroundTex, NearestFourByThree, Canvas.SizeY * MapScale, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);
        }
        else
            Canvas.DrawTile(BackgroundTex, Canvas.SizeX * MapScale, Canvas.SizeY * MapScale, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);

		// Display all sprites according to their current settings
		for (s = 0; s < SpritesNextUnused; s++)
			{
			tex = Sprites[s].tex;
            //Log("Texture Name: " @ tex);
			if (tex != None && Sprites[s].status != SS_Off)
				{
				if (Sprites[s].status == SS_On || bFadeScreen || bGoFast)
					alpha = 255;
				else
					alpha = FadeAlpha;

				if (bFancyMapFade)
					alpha = FadeAlpha;
				Canvas.SetDrawColor(255, 255, 255, alpha);

                // 11/05/12 JWB Check if they don't want it stretched! (Also use ScaleY)
                if(!bEnableWidescreenStretch)
                {
					MapX = OffsetX;

                    Canvas.SetPos(FOUR_BY_THREE_ASPECT_RATIO * (Sprites[s].x * ScaleY * MapScale) + MapX, (Sprites[s].y * ScaleY * MapScale) + MapY);
                    Canvas.DrawTile(tex, FOUR_BY_THREE_ASPECT_RATIO * (tex.USize * ScaleY) * MapScale, (tex.VSize * ScaleY) * MapScale, 0, 0, tex.USize, tex.VSize);
                }
                else
                {
                    Canvas.SetPos((Sprites[s].x * ScaleX * MapScale) + MapX, (Sprites[s].y * ScaleY * MapScale) + MapY);
                    Canvas.DrawTile(tex, (tex.USize * ScaleX) * MapScale, (tex.VSize * ScaleY) * MapScale, 0, 0, tex.USize, tex.VSize);
                }
				}
			}

		// Draw the player's trail (if enabled)
		if (bDrawTrail)
			DrawTrail(canvas);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Draw trail
///////////////////////////////////////////////////////////////////////////////
function DrawTrail(Canvas canvas)
	{
	local int i;
	local int j;
	local float PulseIndex;
	local float NewIndex;
	local float Scale;
	local Actor Marker;
	local float MarkerScale;
	local vector Loc;
	local int Yaw;

	// This value goes from 0 to TrailCount over the period of time specified by TrailPulseCycle
	PulseIndex = (TrailPulseTime / TrailPulseCycle) * TrailCount;

	for (i = 0; i < TrailCount; i++)
		{
		// Note that we go backwards through the array starting at the head
		j = TrailHead - i;
		if (j < 0)
			j += ArrayCount(Trail);
		Loc = Trail[j].Loc;
		Yaw = Trail[j].Yaw;

		// Combine the current index with the pulse index and wrap around so it stays
		// within the range 0 to TrailCount.  We then use the result to calculate a
		// a sin wave that slowly moves through the trail, and the height of the wave
		// determines the scale.
		NewIndex = PulseIndex + float(i);
		if (NewIndex > float(TrailCount))
			NewIndex -= float(TrailCount);
		Scale = (sin((NewIndex / float(TrailCount)) * 6.2832) + 1) / 2;

		// Head is treated differently than rest of trail
		if (i == 0)
			{
			Marker = HeadMarker;
			if (bTrailGiantHead)
				{
				Scale = sin((TrailPulseTime / TrailPulseCycle) * 1.5707);
				MarkerScale = HeadScaleGiant - (Scale * (HeadScaleGiant - HeadScaleMax));
				Loc.X += (1.0 - Scale) * 32768;
				Loc.Y += (1.0 - Scale) * 32768;
				Yaw += (Scale * 65535 * 4);
				}
			else
				MarkerScale = HeadScaleMin + (Scale * (HeadScaleMax - HeadScaleMin));
			}
		else
			{
			Marker = TrailMarker;
			MarkerScale = TrailScaleMin + (Scale * (TrailScaleMax - TrailScaleMin));
			}

		DrawTrailMarker(canvas, Loc, Yaw, Marker, MarkerScale);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Draw a marker on the map.
//
// Each MapPoint indicates two locations: a location in the world and a
// corresponding location on the map.  Given any two MapPoints, we can convert
// the player's world location into a corresponding map location.
//
// Let's say we have point1 and point2.  We calculate the length and slope of
// the TWO lines running from point1 to point2: one using world coords and the
// other using map coords.  Let's say the world line comes to 500 units long
// and 45 degrees and the map line comes to 50 units long and 50 degrees.  So
// then we know that in order to convert any given line from the world to the
// map we need to scale it by 0.10 and rotate it by 5 degrees.
//
// Next we calculate the length and slope of the line running from point1 to
// to the player's world location.  Let's say the line comes to 200 units and
// 120 degrees.  So we scale and rotate using the above values and we end up
// with 20 units and 125 degrees.  Finally, we take point1's map coords and
// draw a line out 20 units at 125 degrees and wherever we end up is the
// player's map location.
//
// The original plan was two use several pairs of points to calculate several
// versions of the player position, and then to average them all together to
// come up with a final position.  The idea was that this would lead to a
// more accurate result.  However, since the map is so badly distorted, this
// actually yielded WORSE results!  The code is still in place to avarage the
// results together, but NUM_REF_POINTS should be set to 2 so only one pair
// of points is used.
//
///////////////////////////////////////////////////////////////////////////////
function DrawTrailMarker(Canvas canvas, Vector PlayerLoc, int PlayerYaw, Actor Marker, float MarkerScale)
	{
	local int i, j;
	local MapPoint mp;
	local MapPoint points[NUM_REF_POINTS];
	local float WorldLen;
	local float WorldDeg;
	local float MapLen;
	local float MapDeg;
	local float DiffDeg;
	local float PlayerLen;
	local float PlayerDeg;
	local float PlayerMapX;
	local float PlayerMapY;
	local float AverageX;
	local float AverageY;
	local int MapPointCount;
	local vector pos;

	if (ViewportOwner != None && ViewportOwner.Actor != None)
		{
		// Go through all the map points and pick out the ones closest to the player
		ForEach ViewportOwner.Actor.AllActors(class'MapPoint', mp)
			{
			// Calculate distance to current map point
			mp.Distance = Sqrt(((PlayerLoc.X - mp.Location.X) * (PlayerLoc.X - mp.Location.X)) +
							   ((PlayerLoc.Y - mp.Location.Y) * (PlayerLoc.Y - mp.Location.Y)));
			// Compare distance to all map points that were already added to list
			for (i = 0; i < ArrayCount(points); i++)
				{
				if (points[i] == None || (points[i] != None && mp.Distance < points[i].Distance))
					{
					// Insert new point into the array (may drop an existing map point off the end)
					for (j = ArrayCount(points)-1; j > i; j--)
						points[j] = points[j-1];
					points[i] = mp;
					// Lookup the map point's position on the 2D map
					points[i].Pos = FindMapPointPos(mp);
					MapPointCount++;
					break;
					}
				}
			if (DISPLAY_DEBUG_AIDS > 0 && Marker == HeadMarker)
				{
				// Draw crosshair at MapPoint's position on map
				DrawScaled(canvas, DebugTex1, points[i].Pos.X, points[i].Pos.Y, true);
				// Show MapPoint in game (normally hidden)
				mp.bHidden = false;
				}
			}

		// Make sure we found at least as many points as we wanted
		if (MapPointCount >= ArrayCount(points))
			{

			// Draw the closest points using a different crosshair (for debugging)
			if (DISPLAY_DEBUG_AIDS > 0 && Marker == HeadMarker)
				{
				for (i = 0; i < ArrayCount(points); i++)
					{
					if (points[i] != None)
						DrawScaled(canvas, DebugTex2, points[i].Pos.X, points[i].Pos.Y, true);
					}
				}

			// Calculate the players position using several different pairs of
			// points, then we'll average the results together.
			for (i = 0; i < ArrayCount(points); i++)
				{
				j = i + 1;
				if (j == ArrayCount(points))
					j = 0;

				// Get length and angle of line from point1 to point2 in world
				CalcLineInfo(
					points[i].Location.X, points[i].Location.Y,
					points[j].Location.X, points[j].Location.Y,
					WorldLen, WorldDeg);

				// Get length and angle of line from point1 to point2 on map
				CalcLineInfo(
					points[i].Pos.X, points[i].Pos.Y,
					points[j].Pos.X, points[j].Pos.Y,
					MapLen, MapDeg);

				// Get length and angle of line from point1 to player in world
				CalcLineInfo(
					points[i].Location.X, points[i].Location.Y,
					PlayerLoc.X, PlayerLoc.Y,
					PlayerLen, PlayerDeg);

				// Adjust player angle by difference between map and world angles
				DiffDeg = MapDeg - WorldDeg;
				if (DiffDeg > MAX_DIFF_DEGREES)
					DiffDeg = DiffDeg - 360;
				else if (DiffDeg < -MAX_DIFF_DEGREES)
					DiffDeg = DiffDeg + 360;

				PlayerDeg = PlayerDeg + DiffDeg;
				if (PlayerDeg < 0)
					PlayerDeg = 360 + PlayerDeg;
				else if (PlayerDeg >= 360)
					PlayerDeg = PlayerDeg - 360;

				// Adjust player length by the ratio between map and world lengths
				PlayerLen = PlayerLen * (MapLen / WorldLen);

				// Use adjusted player length and angle to calculate position of player
				// relative to point1's map coordinates.
				PlayerMapX = points[i].Pos.X + cos(PlayerDeg * DEGREES_TO_RADIANS) * PlayerLen;
				PlayerMapY = points[i].Pos.Y + sin(PlayerDeg * DEGREES_TO_RADIANS) * PlayerLen;
				if (DISPLAY_DEBUG_AIDS > 0 && Marker == HeadMarker)
					DrawScaled(canvas, DebugTex1, PlayerMapX, PlayerMapY, true);

				// Average all the results together
				AverageX += (4/3) * PlayerMapX;
				AverageY += PlayerMapY;
				}

			// Draw marker at average location
			AverageX /= ArrayCount(points);
			AverageY /= ArrayCount(points);
			DrawMarkerOnMap(canvas, AverageX, AverageY, PlayerYaw, DiffDeg, Marker, MarkerScale);
			if (DISPLAY_DEBUG_AIDS > 0 && Marker == HeadMarker)
				DrawScaled(canvas, DebugTex2, AverageX, AverageY, true);
			bDudeIsLost = false;	// If he was lost before, he's not now
			}
		else // No arrow was displayed so the dude is officially lost! He'll say something about
			// it, even though we didn't have any specific lines recorded for this.
			{
				if(!bDudeIsLost)
					log(self$"		I'm lost! There's no arrow on the map!");
				bDudeIsLost=true;
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Calculate the length and angle of the line from (x1,y1) to (x2,y2).
///////////////////////////////////////////////////////////////////////////////
function CalcLineInfo(float x1, float y1, float x2, float y2, out float length, out float angle)
	{
	local float dx, dy;

	dx = x2 - x1;
	dy = y2 - y1;
	length = Sqrt((dx * dx) + (dy * dy));
	angle = ACos(dx / length) * RADIANS_TO_DEGREES;
	if (dy < 0)
		angle = 360 - angle;
	}

///////////////////////////////////////////////////////////////////////////////
// Draw actor at specified map coordinates
///////////////////////////////////////////////////////////////////////////////
function DrawMarkerOnMap(Canvas canvas, float MapX, float MapY, int PlayerYaw, float DiffDeg, Actor Marker, float MarkerScale)
	{
	local vector screen;
	local vector world;
	local vector CameraLocation;
	local rotator CameraRotation;
	local Actor viewtarget;
    local float NearestFourByThree, OffsetX;
	local float ScaleFOVAdjust;

	if (Marker != None)
		{
		// Set draw style
		Canvas.Style = 1; //ERenderStyle.STY_Normal;
		Canvas.SetDrawColor(255, 255, 255);

		// Convert from map to screen coords (map is stretched to full screen)
        // For the love of FSM and all that is holy, this is going into a variable.
        NearestFourByThree = FOUR_BY_THREE_ASPECT_RATIO *(Canvas.SizeY);
        OffsetX = (Canvas.ClipX - NearestFourByThree) /2;

        // 11/05/12 JWB Check if stretching is enabled
        if(!bEnableWidescreenStretch)
            screen.X = OffsetX + (FOUR_BY_THREE_ASPECT_RATIO) * (MapX * ScaleY);
        else
            screen.X = MapX * ScaleX;

		screen.Y = MapY * ScaleY;
		screen.Z = 0;

		// Convert from 2D to 3D world vector.  Vector comes back extremely close to
		// the near clipping plane, so we push it back to avoid actor clipping problems.
		world = ScreenToWorld(screen);
		world *= 2.0;

		// Adjust scale based on FOV (high FOV makes the arrow appear smaller and vice versa)
		ScaleFOVAdjust = (ViewportOwner.Actor.FOVAngle ** 2)/ 6400;
		Marker.SetDrawScale(MarkerScale * (ScaleFOVAdjust));

		// Get player's camera's location and rotation.  Marker needs to be positioned
		// relative to the camera and be rotated just like the camera so we'll always
		// see the same side of it even as the camera rotates.  We add an additional
		// rotation to the marker so it faces the direction the player is facing in
		// the map (if he's facing "north" in the game we want the marker to face
		// "north" too).
		ViewportOwner.Actor.PlayerCalcView(ViewTarget, CameraLocation, CameraRotation);
		Marker.SetLocation(CameraLocation + world);
		CameraRotation.Roll = PlayerYaw + ((DiffDeg/360) * 65535) + YAW_CORRECTION;
		Marker.SetRotation(CameraRotation);

		Canvas.DrawActor(Marker, false);
		}
	else
		Warn("MapScreen.DrawMarkerOnMap(): Marker is None!");
	}

///////////////////////////////////////////////////////////////////////////////
// Put up the space bar message, but also say that the player needs to
// read his errands list and decide to do one.
///////////////////////////////////////////////////////////////////////////////
function RenderMsgBody(Canvas canvas)
{
	local float usey;

	if(GetPlayer().RemindPlayerOfErrands())
	{
		canvas.SetPos(0, 0);
		canvas.Style = GetPlayer().MyHud.ERenderStyle.STY_Alpha;
		canvas.SetDrawColor(255, 255, 255, BACKTEXT_ALPHA);
		canvas.DrawTile(BlackBox, Canvas.SizeX, Canvas.SizeY*(ReminderMsgY + ReminderYInc*5 + BOTTOM_FADE_BUFFER),
						0, 0, BlackBox.USize, BlackBox.VSize);

		usey = ReminderMsgY;
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, ReminderMsgX * Canvas.ClipX, usey * Canvas.ClipY,
								ReminderMessage1, 1, false, EJ_Center);
		usey+= ReminderYInc;
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, ReminderMsgX * Canvas.ClipX, usey * Canvas.ClipY,
								ReminderMessage2, 1, false, EJ_Center);
		usey+= ReminderYInc;
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, ReminderMsgX * Canvas.ClipX, usey * Canvas.ClipY,
								ReminderMessage3, 1, false, EJ_Center);
		usey+= ReminderYInc;
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, ReminderMsgX * Canvas.ClipX, usey * Canvas.ClipY,
								ReminderMessage4, 1, false, EJ_Center);
		usey+= ReminderYInc;
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, ReminderMsgX * Canvas.ClipX, usey * Canvas.ClipY,
								ReminderMessage5, 1, false, EJ_Center);
	}

	Super.RenderMsgBody(canvas);
}

///////////////////////////////////////////////////////////////////////////////
// Find MapPoint position on this map
///////////////////////////////////////////////////////////////////////////////
function vector FindMapPointPos(MapPoint mp)
	{
	local int i;
	local vector bad;

	for (i = 0; i < MapPositions.length; i++)
		{
		if (MapPositions[i].UniqueTag == mp.Tag)
			return MapPositions[i].Pos;
		}

	Warn("MapScreen.FindMapPointPos(): Can't find position for MapPoint with tag "$mp.Tag);
	return bad;
	}

///////////////////////////////////////////////////////////////////////////////
// This is called by the HUD to see if it should draw itself
///////////////////////////////////////////////////////////////////////////////
function bool ShouldDrawHUD()
	{
	// Add an extra condition for when the map is getting alpha'd in
	return Super.ShouldDrawHUD() && !bFancyMapFade;
	}

///////////////////////////////////////////////////////////////////////////////
// Handle input events
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
	local bool bHandled;
	local int i;

	if (Action == IST_Press)
		{
		for (i = 0; i < EndKeys.length; i++)
			{
			if (Key == EndKeys[i])
				{
				bPlayerWantsToEnd = true;
				bHandled = true;
				}
			}
		}

	return bHandled;
	}

///////////////////////////////////////////////////////////////////////////////
// Default tick function.
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
	{
	Super.Tick(DeltaTime);

	// Pulse time simply goes from 0 to TrailPulseCycle and then keeps wrapping around
	TrailPulseTime += DeltaTime;
	if (TrailPulseTime > TrailPulseCycle)
		{
		TrailPulseTime -= TrailPulseCycle;
		bTrailGiantHead = false;
		}

	if (bPlayerWantsToEnd)
		{
		// Clear flag (it may get set again)
		bPlayerWantsToEnd = false;

		// If already showing message then end right away
		if (bShowMsg)
			{
			End();
			ChangeExistingDelay(FastTime);
			}
		else
			{
			// Check if player is allowed to skip stuff
			if (!bNoFast)
				{
				// If not going fast, then start going fast now
				if (!bGoFast)
					{
					bGoFast = true;
					ChangeExistingDelay(FastTime);
					}
				}
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Convert preferred time to actual time, depending on whether we're in fast
// or normal mode.
///////////////////////////////////////////////////////////////////////////////
function float PreferredTime(float f)
	{
	if (bGoFast)
		f = FMin(f, FastTime);
	return f;
	}

///////////////////////////////////////////////////////////////////////////////
// Play writing sound
///////////////////////////////////////////////////////////////////////////////
function PlayWritingSound()
	{
	local Actor.ESoundSlot UseSlot;
	
	// Use the SLOT_Talk slot if we're going fast, so we'll cut off the Dude or whoever is talking over the map so they don't keep talking after the map closes
	if (bGoFast)
		UseSlot = SLOT_Talk;
	else
		UseSlot = SLOT_Misc;
	//UseSlot = (bGoFast ? SLOT_Talk : SLOT_Misc);	
	GetSoundActor().PlaySound(WritingSounds[Rand(WritingSounds.length)], UseSlot, WritingVolume,,,,,False);
	}

///////////////////////////////////////////////////////////////////////////////
// Play dude comment.
// For convenience sake this function returns a value that is the greater of
// dude comment's duration + PadTime versus OtherDuration.
///////////////////////////////////////////////////////////////////////////////
function float PlayDudeComment(Sound DudeComment, optional float PadTime, optional float OtherDuration)
	{
	GetSoundActor().PlaySound(DudeComment, SLOT_Talk, DudeVolume,,,,,False);
	return FMax(GetSoundDuration(DudeComment) + PadTime, OtherDuration);
	}

///////////////////////////////////////////////////////////////////////////////
// Play dude comment about going home and return duration
///////////////////////////////////////////////////////////////////////////////
function float PlayDudeGoHomeComment()
{
	local Sound UseSound;
	// See if there's one for the daybase
	UseSound = Sound(DynamicLoadObject(Day.EndOfDayComment, class'Sound'));
	if (UseSound == None)
		return PlayDudeComment(DudeGoHomeSounds[Rand(DudeGoHomeSounds.length)]);
	else
		return PlayDudeComment(UseSound);
}

///////////////////////////////////////////////////////////////////////////////
// Play dude comment when he's lost and not marked on the map (his position)
///////////////////////////////////////////////////////////////////////////////
function float PlayDudeIsLostComment()
	{
	return PlayDudeComment(DudeLostOnMap[Rand(DudeLostOnMap.length)]);
	}

///////////////////////////////////////////////////////////////////////////////
// Find the next unrevealed errand AFTER the specified errand (use -1 to start
// with the first possible errand).
///////////////////////////////////////////////////////////////////////////////
function int FindUnrevealedErrand(int ErrandIndex)
	{
	local int i;

	for (ErrandIndex++; ErrandIndex < Day.NumErrands(); ErrandIndex++)
		{
		if (Day.IsErrandActive(ErrandIndex))
			{
			for (i = 0; i < gs.RevealedErrands.length; i++)
				{
				if (gs.RevealedErrands[i].Day == DayIndex && gs.RevealedErrands[i].Errand == ErrandIndex)
					break;
				}
			// If errand wasn't on the list then we found an unreaveled errand
			if (i == gs.RevealedErrands.length)
				return ErrandIndex;
			// Check revealed errand locations too
			for (i = 0; i < gs.RevealedLocationTex.length; i++)
				{
				if (gs.RevealedLocationTex[i].Day == DayIndex && gs.RevealedLocationTex[i].Errand == ErrandIndex)
					break;
				}
			// If errand wasn't on the list then we found an unreaveled errand
			if (i == gs.RevealedLocationTex.length
				&& Day.IsLocationTexActive(ErrandIndex))
				return ErrandIndex;
			}
		}
	return -1;
	}

///////////////////////////////////////////////////////////////////////////////
// Find the next new hater AFTER the specified hater (use -1 to start
// with the first possible hater).
///////////////////////////////////////////////////////////////////////////////
function int FindNewHaters(int HaterIndex)
	{
	for (HaterIndex++; HaterIndex < gs.CurrentHaters.length; HaterIndex++)
		{
		if (gs.CurrentHaters[HaterIndex].Revealed == 0)
			return HaterIndex;
		}
	return -1;
	}

///////////////////////////////////////////////////////////////////////////////
// Reveal each of the errands names and locations
///////////////////////////////////////////////////////////////////////////////
state RevealErrandsAlphaIn extends ShowScreen
	{
	function BeginState()
		{
		SetFadeIn(1.5);
		DelayedGotoState(1.5, 'RevealErrandsAlphaInDone');
		}
	}

state RevealErrandsAlphaInDone extends ShowScreen
	{
	function BeginState()
		{
		bFancyMapFade = false;
		ViewportOwner.Actor.SetPause(true);
		MaybeLog("MapScreen.RevealErrandsAlphaInDone.BeginState(): pausing game");
		DelayedGotoState(0.2, 'RevealErrands');
		}
	}

state RevealErrands extends ShowScreen
	{
	function BeginState()
		{
		RevealErrand = FindUnrevealedErrand(-1);
		RevealCount = 0;
		DelayedGotoState(PreferredTime(BigHoldTime), 'RevealErrands2');
		}
	}

state RevealErrands2 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;
		local int i;
		local bool bEscape;
		
		// Skip this bit if the errand itself is already revealed, but not the location
		for (i = 0; i < gs.RevealedErrands.Length; i++)
			if (gs.RevealedErrands[i].Day == DayIndex && gs.RevealedErrands[i].Errand == RevealErrand)
			{
				bEscape = true;
				break;
			}
				
		if (bEscape)
		{
			duration = 0;
		}		
		else
		{
			// Don't play writing sound if he's not writing anything ("invisible" suberrands)
			if (Sprites[ErrandNameBase + RevealErrand].Tex != None)
			{
				// The dude writes the errand name and makes a comment about it
				duration = ErrandNameFadeTime;
				SpriteFadeIn(ErrandNameBase + RevealErrand, duration);
				PlayWritingSound();
				if (!bGoFast)
					duration = PlayDudeComment(Day.GetErrandStartComment(RevealErrand), ErrandNameCommentPad, duration);
			}
			else
				duration = 0;
		}
		DelayedGotoState(PreferredTime(duration), 'RevealErrands3');
		}
	}

state RevealErrands3 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;
		local Sound DudeComment;
		local int i;
		local bool bEscape;

		SpriteTurnOn(ErrandNameBase + RevealErrand);

		// Only mark off location if the errand wants it
		if (Day.IsLocationTexActive(RevealErrand))
		{
			// The dude wonders where this errand is located
			DudeComment = Day.GetErrandWhereComment(RevealErrand);
			if (!bGoFast && DudeComment != None)
				duration = PlayDudeComment(DudeComment, ErrandWhereCommentPad, duration);
		}

		DelayedGotoState(PreferredTime(duration), 'RevealErrands4');
		}
	}

state RevealErrands4 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;
		local Sound DudeComment;
		local int i;
		
		// Only mark off location if the errand wants it
		if (Day.IsLocationTexActive(RevealErrand))
		{
			// The Dude (optionally) writes the errand location
			duration = ErrandLocFadeTime;
			if (Sprites[ErrandLocBase + RevealErrand].tex != None)
				{
				SpriteFadeIn(ErrandLocBase + RevealErrand, duration);
				PlayWritingSound();
				}
			// The Dude (optionally) makes a comment about it
			DudeComment = Day.GetErrandFoundComment(RevealErrand);
			if (!bGoFast && DudeComment != None)
				duration = PlayDudeComment(DudeComment, ErrandLocCommentPad, duration);

				// Permanently mark this errand as having been revealed
			i = gs.RevealedLocationTex.length;
			gs.RevealedLocationTex.insert(i, 1);
			gs.RevealedLocationTex[i].Day = DayIndex;
			gs.RevealedLocationTex[i].Errand = RevealErrand;
		}

		DelayedGotoState(PreferredTime(duration), 'RevealErrands5');
		}
	}

state RevealErrands5 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;
		local int i;

		if (Sprites[ErrandLocBase + RevealErrand].tex != None
			&& Day.IsLocationTexActive(RevealErrand))
			SpriteTurnOn(ErrandLocBase + RevealErrand);

		// Permanently mark this errand as having been revealed
		i = gs.RevealedErrands.length;
		gs.RevealedErrands.insert(i, 1);
		gs.RevealedErrands[i].Day = DayIndex;
		gs.RevealedErrands[i].Errand = RevealErrand;
		RevealCount++;

		// Check if there are more errands to reveal
		RevealErrand = FindUnrevealedErrand(RevealErrand);
		if (RevealErrand != -1)
			{
			// Reveal next errand
			DelayedGotoState(PreferredTime(ErrandBetweenTime), 'RevealErrands2');
			}
		else
			{
			if (PostRevealSendToURL == "")
				{
				if (bUnpauseAfterReaveal)
					bDontPauseGame = false;

				// Wrap it up
				DelayedGotoState(0.2, 'RevealErrandsFinish');
				}
			else
				{
				// Send player to next level (small delay works a little better)
				DelayedGotoState(PreferredTime(2.0), 'RevealSendPlayer');
				}
			}
		}
	}

state RevealSendPlayer extends ShowScreen
	{
	function BeginState()
		{
		SendThePlayerTo(PostRevealSendToURL, 'RevealPostSend');
		}
	}

state RevealPostSend extends ShowScreen
	{
	function BeginState()
		{
		// Unpause the game while we do the fancy map-fading effect.
		// It's only ok to unpause the game because we only do this
		// at the start of the game, so we know nothing critical will
		// be happening while the screen fades out.
		ViewportOwner.Actor.SetPause(false);
		MaybeLog("MapScreen.RevealPostSend.BeginState(): unpausing game");
		bFancyMapFade = true;
		SetFadeOut(1.5);
		DelayedGotoState(1.5, 'Shutdown');
		}
	}

state RevealErrandsFinish extends ShowScreen
	{
	function BeginState()
		{
		local float duration;

		// Start drawing the trail
		ShowTrail();

		// Dude only makes "better get started" comment if more than one errand
		// was revealed, which is assumed to be at the start of the day.
		if (!bGoFast && RevealCount > 1)
			duration = PlayDudeComment(Day.GetDudeStartComment());
		else
			duration = BigHoldTime;

		DelayedGotoState(PreferredTime(duration), 'HoldScreen');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Cross out completed errand
///////////////////////////////////////////////////////////////////////////////
state CrossOut extends ShowScreen
	{
	function BeginState()
		{
		DelayedGotoState(PreferredTime(BigHoldTime), 'CrossOut1');
		}
	}

state CrossOut1 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;

		// Dude crosses out the errand name
		if (Sprites[ErrandNameBase + CrossoutErrand].tex != None)
		{
			duration = CrossoutFadeTime;
			SpriteFadeIn(CrossoutBase + CrossOutErrand, duration);
			PlayWritingSound();
		}

		DelayedGotoState(PreferredTime(duration), 'CrossOut2');
		}
	}

state CrossOut2 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;

		// Turn crossout on (done fading)
		if (Sprites[ErrandNameBase + CrossoutErrand].tex != None)
		{
			SpriteTurnOn(CrossoutBase + CrossOutErrand);
		}

		// Dude crosses out the errand location (optional)
		if (Sprites[ErrandLocCrossBase + CrossOutErrand].tex != None)
			{
			duration = CrossoutFadeTime;
			SpriteFadeIn(ErrandLocCrossBase + CrossOutErrand, duration);
			PlayWritingSound();
			}

		// Dude makes comment about finishing the errand
		if (!bGoFast)
			duration = PlayDudeComment(Day.GetErrandCompletedComment(CrossOutErrand), CrossoutCommentPad, duration);

		DelayedGotoState(PreferredTime(duration), 'CrossOut3');
		}
	}

state CrossOut3 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;

		// Turn location crossout on (done fading)
		SpriteTurnOn(ErrandLocCrossBase + CrossOutErrand);

		duration = BigHoldTime;

		// Check if there are more errands to reveal
		RevealErrand = FindUnrevealedErrand(RevealErrand);
		if (RevealErrand != -1)
		{
			// Reveal next errand
			DelayedGotoState(PreferredTime(ErrandBetweenTime), 'RevealErrands2');
		}
		else
		{
			// If dude is ready to go home, he makes a comment about it
			if (!bGoFast && GetGameSingle().IsPlayerReadyForHome())
				duration += PlayDudeGoHomeComment();

			if (PostRevealSendToURL == "")
				{
				// In this mode we don't wait for the player to decide when to finish,
				// we simply end the screen automatically.
				DelayedGotoState(PreferredTime(duration), 'FadeOutScreen');
				}
			else
				{
				// Send player to next level (small delay works a little better)
				DelayedGotoState(PreferredTime(1.0), 'RevealSendPlayer');
				}
		}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Show new haters
///////////////////////////////////////////////////////////////////////////////
state NewHaters extends ShowScreen
	{
	function BeginState()
		{
		HaterIndex = FindNewHaters(-1);
		DelayedGotoState(BigHoldTime, 'NewHaters1');
		}
	}

state NewHaters1 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;

//		// Dude writes the title of the haters list if it's the first one
//		if (HaterIndex == 0)
//			{
//			duration = HaterTitleFadeTime;
//			SpriteFadeIn(HaterTitleBase, duration);
//			PlayWritingSound();
//			duration += HaterTitlePad;
//			}

		DelayedGotoState(duration, 'NewHaters2');
		}
	}

state NewHaters2 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;
		local Sound DudeComment;

//		SpriteTurnOn(HaterTitleBase);

		// Dude writes the haters picture on the map
		duration = HaterPicFadeTime;
		SpriteFadeIn(HaterPicBase + HaterIndex, duration);
		PlayWritingSound();
		duration += HaterPicPad;

		// Dude makes comment about haters.
		if (!bGoFast)
		{
			DudeComment = Sound(DynamicLoadObject(String(gs.CurrentHaters[HaterIndex].Comment), class'Sound'));
			LongDudeLineTime = PlayDudeComment(DudeComment, HaterCommentPad);
			LongDudeLineTime -= duration;
		}
		else
		{
			LongDudeLineTime = FastTime;
			duration = FastTime;
		}

		DelayedGotoState(duration, 'NewHaters3');
		}
	}

state NewHaters3 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;

		SpriteTurnOn(HaterPicBase + HaterIndex);

/*		// Dude writes the haters picture on the map
		duration = HaterDesFadeTime;
		SpriteFadeIn(HaterDesBase + HaterIndex, duration);
		PlayWritingSound();

		if (!bGoFast)
			duration = FMax(LongDudeLineTime, duration);

		duration += HaterDesPad;
*/
		DelayedGotoState(duration, 'NewHaters4');
		}
	}

state NewHaters4 extends ShowScreen
	{
	function BeginState()
		{
//		SpriteTurnOn(HaterDesBase + HaterIndex);

		// Permanently mark this hater as having been revealed
		gs.CurrentHaters[HaterIndex].Revealed = 1;
		
		// Check for more new haters
		HaterIndex = FindNewHaters(HaterIndex);
		if (HaterIndex != -1)
		{
			if (bGoFast)
				DelayedGotoState(FastTime, 'NewHaters2');
			else
				DelayedGotoState(LongDudeLineTime + HaterBetweenTime, 'NewHaters2');
		}
		else
			{
			if (PostRevealSendToURL == "")
				{
				// Show trail after all new haters have been shown
				ShowTrail();
				if (bGoFast)
					DelayedGotoState(FastTime, 'CheckReadyForHome');
				else
					DelayedGotoState(LongDudeLineTime, 'CheckReadyForHome');					
				}
			else
				{
				// Send player to next level (wait for dude to stop talking)
				if (bGoFast)
					DelayedGotoState(FastTime, 'RevealSendPlayer');
				else
					DelayedGotoState(LongDudeLineTime + HaterBetweenTime, 'RevealSendPlayer');
				}
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Player is just looking at the map (nothing special happens)
///////////////////////////////////////////////////////////////////////////////
state JustLooking extends ShowScreen
	{
	function BeginState()
		{
		// Show message right away in this mode to make it easier to get out of
		ShowMsg();
		DelayedGotoState(0, 'CheckReadyForHome');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Player should go home
///////////////////////////////////////////////////////////////////////////////
state CheckReadyForHome extends ShowScreen
	{
	function BeginState()
		{
		local float duration;

		log(self$" CheckReadyForHome lost: "$bDudeIsLost);

		// If dude is ready to go home then he makes a comment about it
		if (!bGoFast && GetGameSingle().IsPlayerReadyForHome())
			{
			duration = PreReadyForHome;
			DelayedGotoState(PreferredTime(duration), 'CheckReadyForHome2');
			}
		else if(!bGoFast && bDudeIsLost)
			{
			duration = PreReadyForHome; // smaller time to wait till he talks
			DelayedGotoState(PreferredTime(duration), 'PlayerIsLost');
			}
		else
			{
			duration = FMax(duration, BigHoldTime);
			DelayedGotoState(PreferredTime(duration), 'HoldScreen');
			}
		}
	}

state CheckReadyForHome2 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;

		// Make comment about going home
		duration = PlayDudeGoHomeComment();
		duration = FMax(duration, BigHoldTime);
		DelayedGotoState(PreferredTime(duration), 'HoldScreen');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Play some sounds to show that the dude knows he's lost (there's no arrow on the screen)
///////////////////////////////////////////////////////////////////////////////
state PlayerIsLost extends ShowScreen
	{
	function BeginState()
		{
		local float duration;

		log(self$" player is lost");
		// Make comment about being lost
		duration = PlayDudeIsLostComment();
		duration = FMax(duration, BigHoldTime);
		DelayedGotoState(PreferredTime(duration), 'HoldScreen');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// View screen until player decides to stop
///////////////////////////////////////////////////////////////////////////////
state HoldScreen extends ShowScreen
	{
	function BeginState()
		{
		ShowMsg();
		WaitForEndThenGotoState('FadeOutScreen');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     ErrandPositions(0)=(X=83.000000,Y=616.000000)
     ErrandPositions(1)=(X=101.000000,Y=691.000000)
     ErrandPositions(2)=(X=119.000000,Y=775.000000)
     ErrandPositions(3)=(X=131.000000,Y=832.000000)
     ErrandPositions(6)=(X=121.000000,Y=691.000000)	// Hack for PL
     ErrandNameFadeTime=1.000000
     ErrandNameCommentPad=0.500000
     ErrandWhereCommentPad=0.500000
     ErrandLocFadeTime=1.000000
     ErrandLocCommentPad=0.500000
     CrossoutTex(0)=Texture'P2Misc.Map.crossout_1'
     CrossoutTex(1)=Texture'P2Misc.Map.crossout_2'
     CrossoutTex(2)=Texture'P2Misc.Map.crossout_3'
     CrossoutTex(3)=Texture'P2Misc.Map.crossout_4'
     CrossoutFadeTime=1.000000
     CrossoutCommentPad=0.500000
     HaterDesPositions(0)=(X=332.000000,Y=154.000000)
     HaterDesPositions(1)=(X=172.000000,Y=295.000000)
     HaterDesPositions(2)=(X=223.000000,Y=414.000000)
     HaterDesPositions(3)=(X=66.000000,Y=609.000000)
     HaterDesPositions(4)=(X=47.000000,Y=169.000000)
     HaterDesPositions(5)=(X=100.000000,Y=100.000000)
     HaterPicPositions(0)=(X=151.000000,Y=85.000000)
     HaterPicPositions(1)=(X=109.000000,Y=336.000000)
     HaterPicPositions(2)=(X=794.000000,Y=436.000000)
     HaterPicPositions(3)=(X=776.000000,Y=179.000000)
     HaterPicPositions(4)=(X=362.000000,Y=729.000000)
     HaterPicPositions(5)=(X=10.000000,Y=10.000000)
     HateTitleTex=Texture'P2Misc.Map.Hate_Title'
     HateTitlePosition=(X=182.000000,Y=2.000000)
     HaterTitleFadeTime=1.000000
     HaterTitlePad=0.500000
     HaterPicFadeTime=1.000000
     HaterPicPad=0.500000
     HaterDesFadeTime=1.000000
     HaterDesPad=0.500000
     HaterBetweenTime=0.200000
     HaterCommentPad=0.500000
     BlackBox=Texture'nathans.Inventory.blackbox64'
     PreReadyForHome=1.000000
     BigHoldTime=1.500000
     FastTime=0.200000
     WritingSounds(0)=Sound'MiscSounds.Map.checkmark'
     WritingSounds(1)=Sound'MiscSounds.Map.CheckMark2'
     DudeGoHomeSounds(0)=Sound'DudeDialog.dude_timetogohome'
     DudeLostOnMap(0)=Sound'DudeDialog.dude_bettergetoutta'
     DudeLostOnMap(1)=Sound'DudeDialog.dude_thatsclearly'
     DudeLostOnMap(2)=Sound'DudeDialog.dude_whoeverdesigned'
     DudeLostOnMap(3)=Sound'DudeDialog.dude_whydoesthisnot'
     WritingVolume=0.200000
     DudeVolume=1.000000
     HeadMesh=StaticMesh'stuff.stuff1.ArrowBox'
     HeadScaleMin=0.013000
     HeadScaleMax=0.016000
     HeadScaleGiant=1.000000
     TrailMesh=StaticMesh'stuff.stuff1.DashBox'
     TrailScaleMin=0.001500
     TrailScaleMax=0.002000
     TrailUpdateDistance=500.000000
     TrailPulseCycle=2.000000
     DebugTex1=Texture'P2Misc.Reticle.Reticle_CrosshairOpen'
     DebugTex2=Texture'P2Misc.Reticle.Reticle_CrosshairOpenLg'
     MapPositions(0)=(UniqueTag="suburbs-1-ne",pos=(X=722.000000,Y=475.000000))
     MapPositions(1)=(UniqueTag="suburbs-1-sw",pos=(X=655.000000,Y=559.000000))
     MapPositions(2)=(UniqueTag="suburbs-2-n",pos=(X=681.000000,Y=619.000000))
     MapPositions(3)=(UniqueTag="suburbs-2-se",pos=(X=725.000000,Y=703.000000))
     MapPositions(4)=(UniqueTag="suburbs-3-ne",pos=(X=789.000000,Y=469.000000))
     MapPositions(5)=(UniqueTag="suburbs-3-sw",pos=(X=748.000000,Y=512.000000))
     MapPositions(6)=(UniqueTag="suburbs-4-nw",pos=(X=767.000000,Y=703.000000))
     MapPositions(7)=(UniqueTag="suburbs-4-c",pos=(X=815.000000,Y=754.000000))
     MapPositions(8)=(UniqueTag="forest-e",pos=(X=814.000000,Y=830.000000))
     MapPositions(9)=(UniqueTag="forest-w",pos=(X=772.000000,Y=824.000000))
     MapPositions(10)=(UniqueTag="parade-c",pos=(X=715.000000,Y=812.000000))
     MapPositions(11)=(UniqueTag="parade-e",pos=(X=739.000000,Y=813.000000))
     MapPositions(12)=(UniqueTag="rwsblock-n",pos=(X=642.000000,Y=263.000000))
     MapPositions(13)=(UniqueTag="rwsblock-s",pos=(X=730.000000,Y=394.000000))
     MapPositions(14)=(UniqueTag="westmall-nw",pos=(X=569.000000,Y=318.000000))
     MapPositions(15)=(UniqueTag="westmall-mid",pos=(X=568.000000,Y=354.000000))
     MapPositions(16)=(UniqueTag="eastmall-mid",pos=(X=577.000000,Y=379.000000))
     MapPositions(17)=(UniqueTag="eastmall-se",pos=(X=642.000000,Y=380.000000))
     MapPositions(18)=(UniqueTag="highlands-w",pos=(X=435.000000,Y=300.000000))
     MapPositions(19)=(UniqueTag="highlands-e",pos=(X=533.000000,Y=330.000000))
     MapPositions(20)=(UniqueTag="industry-n",pos=(X=529.000000,Y=395.000000))
     MapPositions(21)=(UniqueTag="industry-s",pos=(X=504.000000,Y=456.000000))
     MapPositions(22)=(UniqueTag="industry2-s",pos=(X=511.000000,Y=488.000000))
     MapPositions(23)=(UniqueTag="industry2-n",pos=(X=573.000000,Y=446.000000))
     MapPositions(24)=(UniqueTag="greenbelt1-n",pos=(X=465.000000,Y=574.000000))
     MapPositions(25)=(UniqueTag="greenbelt1-s",pos=(X=593.000000,Y=664.000000))
     MapPositions(26)=(UniqueTag="greenbelt2-n",pos=(X=468.000000,Y=420.000000))
     MapPositions(27)=(UniqueTag="greenbelt2-c",pos=(X=436.000000,Y=515.000000))
     MapPositions(28)=(UniqueTag="napalm-nw",pos=(X=392.000000,Y=459.000000))
     MapPositions(29)=(UniqueTag="napalm-se",pos=(X=426.000000,Y=505.000000))
     MapPositions(30)=(UniqueTag="compound-sw",pos=(X=558.000000,Y=254.000000))
     MapPositions(31)=(UniqueTag="compound-c",pos=(X=596.000000,Y=163.000000))
     MapPositions(32)=(UniqueTag="lib1",pos=(X=681.000000,Y=540.000000))
     MapPositions(33)=(UniqueTag="lib2",pos=(X=655.000000,Y=501.000000))
     MapPositions(34)=(UniqueTag="post1",pos=(X=831.000000,Y=766.000000))
     MapPositions(35)=(UniqueTag="post2",pos=(X=891.000000,Y=729.000000))
     MapPositions(36)=(UniqueTag="pol1",pos=(X=699.000000,Y=671.000000))
     MapPositions(37)=(UniqueTag="pol2",pos=(X=730.000000,Y=629.000000))
     MapPositions(38)=(UniqueTag="slaughter1",pos=(X=786.000000,Y=785.000000))
     MapPositions(39)=(UniqueTag="slaughter2",pos=(X=768.000000,Y=764.000000))
     MapPositions(40)=(UniqueTag="church-se",pos=(X=473.000000,Y=330.000000))
     MapPositions(41)=(UniqueTag="church-nw",pos=(X=402.000000,Y=226.000000))
     MapPositions(42)=(UniqueTag="brewery-se",pos=(X=533.000000,Y=366.000000))
     MapPositions(43)=(UniqueTag="brewery-nw",pos=(X=571.000000,Y=398.000000))
     MapPositions(44)=(UniqueTag="estates-n",pos=(X=788.000000,Y=318.000000))
     MapPositions(45)=(UniqueTag="estates-s",pos=(X=736.000000,Y=317.000000))
     MapPositions(46)=(UniqueTag="junkyard-nw",pos=(X=387.000000,Y=560.000000))
     MapPositions(47)=(UniqueTag="junkyard-se",pos=(X=431.000000,Y=634.000000))
     ReminderMessage1="Look at the yellow pad of paper in the lower-left"
     ReminderMessage2="of the screen. Decide on an errand to complete."
     ReminderMessage3="Now, examine the map and find out where to"
     ReminderMessage4="journey in order to complete it."
     ReminderMessage5="OR, ignore this and keep having fun screwing around!"
     ReminderMsgX=0.500000
     ReminderMsgY=0.020000
     ReminderYInc=0.035000
     Song="map_muzak.ogg"
     FadeInScreenSound=Sound'MiscSounds.Map.MapUncrumple'
     FadeOutScreenSound=Sound'MiscSounds.Map.MapCrumple'
     bEnableLogging=True
     bEnableWidescreenStretch=False
     //TileName="JakeWS.Misc.WidescreenMapBGFixed"
	 
	 	 
	 //ErikFOV Change: Subtitle system
	 bShowSubtitles=True
	 //end
}
