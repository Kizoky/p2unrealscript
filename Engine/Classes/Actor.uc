//=============================================================================
// Actor: The base class of all actors.
// Actor is the base class of all gameplay objects.
// A large number of properties, behaviors and interfaces are implemented in Actor, including:
//
// -	Display
// -	Animation
// -	Physics and world interaction
// -	Making sounds
// -	Networking properties
// -	Actor creation and destruction
// -	Triggering and timers
// -	Actor iterator functions
// -	Message broadcasting
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Actor extends Object
	abstract
	native
	nativereplication
	hidecategories(Shadow);

// Imported data (during full rebuild).
#exec Texture Import File=Textures\S_Actor.pcx Name=S_Actor Mips=Off MASKED=1
#exec Texture Import File=Textures\LockLocation.pcx Name=S_LockLocation Mips=Off MASKED=1
#exec Texture Import File=Textures\AutoAlignToTerrain.pcx Name=S_AutoAlignToTerrain Mips=Off MASKED=1

// Flags.
var			  const bool	bStatic;			// Does not move or change over time. Don't let L.D.s change this - screws up net play
var(Advanced)		bool	bHidden;			// Is hidden during gameplay.
var(Advanced) const bool	bNoDelete;			// Cannot be deleted during play.
var					bool	bAnimByOwner;		// Animation dictated by owner.
var			  const	bool	bDeleteMe;			// About to be deleted.
var transient const bool	bTicked;			// Actor has been updated.
var(Lighting)		bool	bDynamicLight;		// This light is dynamic.
var					bool	bTimerLoop;			// Timer loops (else is one-shot).
var(Advanced)		bool	bCanTeleport;		// This actor can be teleported.
var 				bool	bOwnerNoSee;		// Everything but the owner can see this actor.
var					bool    bOnlyOwnerSee;		// Only owner can see this actor.
var			  const	bool	bAlwaysTick;		// Update even when players-only.
var(Advanced)		bool    bHighDetail;		// Only show up on high-detail.
var(Advanced)		bool	bStasis;			// In StandAlone games, turn off if not in a recently rendered zone turned off if  bStasis  and physics = PHYS_None or PHYS_Rotating.
var					bool	bTrailerSameRotation; // If PHYS_Trailer and true, have same rotation as owner.
var					bool	bTrailerPrePivot;	// If PHYS_Trailer and true, offset from owner by PrePivot.
var					bool	bClientAnim;		// Don't replicate any animations - animation done client-side
// RWS Change 01/23/03	Exposed it to Advanced for level designers.
var(Advanced)		bool	bWorldGeometry;		// Collision and Physics treats this actor as world geometry
var(Advanced)		bool    bAcceptsProjectors;	// Projectors can project onto this actor
var					bool	bOrientOnSlope;		// when landing, orient base on slope of floor
var					bool    bDisturbFluidSurface; // Cause ripples when in contact with FluidSurface.
var			  const	bool	bOnlyAffectPawns;	// Optimisation - only test ovelap against pawns. Used for influences etc.

// Networking flags
var			  const	bool	bNetTemporary;				// Tear-off simulation in network play.
var			  const	bool	bNetOptional;				// Actor should only be replicated if bandwidth available.
var			  const	bool	bNetDirty;					// set when any attribute is assigned a value in unrealscript, reset when the actor is replicated
var					bool	bAlwaysRelevant;			// Always relevant for network.
var					bool	bReplicateInstigator;		// Replicate instigator to client (used by bNetTemporary projectiles).
var					bool	bReplicateMovement;			// if true, replicate movement/location related properties
var					bool	bSkipActorPropertyReplication; // if true, don't replicate actor class variables for this actor
var					bool	bUpdateSimulatedPosition;	// if true, update velocity/location after initialization for simulated proxies
var					bool	bTearOff;					// if true, this actor is no longer replicated to new clients, and
														// is "torn off" (becomes a ROLE_Authority) on clients to which it was being replicated.
var					bool	bOnlyDirtyReplication;		// if true, only replicate actor if bNetDirty is true - useful if no C++ changed attributes (such as physics)
														// bOnlyDirtyReplication only used with bAlwaysRelevant actors
var					bool	bReplicateAnimations;		// Should replicate SimAnim
var					int		SimAnimChannel;				// Which channel is replicated for SimAnim
// RWS CHANGE: Merged from UT2003 to fix problems with gameobject attachments
var					bool	bAlwaysZeroBoneOffset;		// if true, offset always zero when attached to skeletalmesh

// RWS CHANGE: Remember tick on which bDeleteMe was set to true
var transient		int		DeletedOnTick;

// Priority Parameters
// Actor's current physics mode.
var(Movement) const enum EPhysics
{
	PHYS_None,
	PHYS_Walking,
	PHYS_Falling,
	PHYS_Swimming,
	PHYS_Flying,
	PHYS_Rotating,
	PHYS_Projectile,
	PHYS_Interpolating,
	PHYS_MovingBrush,
	PHYS_Spider,
	PHYS_Trailer,
	PHYS_Ladder,
	PHYS_RootMotion,
    PHYS_Karma,
    PHYS_KarmaRagDoll
} Physics;

// Net variables.
enum ENetRole
{
	ROLE_None,              // No role at all.
	ROLE_DumbProxy,			// Dumb proxy of this actor.
	ROLE_SimulatedProxy,	// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,	// Locally autonomous proxy of this actor.
	ROLE_Authority,			// Authoritative control over the actor.
};
var ENetRole Role;
var ENetRole RemoteRole;

// Drawing effect.
var(Display) const enum EDrawType
{
	DT_None,
	DT_Sprite,
	DT_Mesh,
	DT_Brush,
	DT_RopeSprite,
	DT_VerticalSprite,
	DT_Terraform,
	DT_SpriteAnimOnce,
	DT_StaticMesh,
	DT_DrawType,
	DT_Particle,
	DT_AntiPortal,
	DT_FluidSurface
} DrawType;

var const transient int		NetTag;
var			float			LastRenderTime;	// last time this actor was rendered.
var(Events) name			Tag;			// Actor's tag name.

//ErikFOV Change: draw event lines
struct native LineActor
{
	var() edfindable Actor Actor;
};

struct native UnEDLine
{
	var() Array<LineActor> Actors;
	var() Array<Name> Events;
	var() Color LineColor;
};

var(Display) array<UnEDLine>  	DrawLineActors;
var Color LineColor;
////////////////////////////////////

// Change by NickP: karma fix
var(Karma) float KarmaMaxSpeed;				// Max speed actor with karma physics can achieve, pawns uses AirSpeed instead
// End

// Execution and timer variables.
var				float       TimerRate;		// Timer event, 0=no timer.
var		const	float       TimerCounter;	// Counts up until it reaches TimerRate.
var(Advanced)	float		LifeSpan;		// How old the object lives before dying, 0=forever.

var transient MeshInstance MeshInstance;	// Mesh instance.

var(Display) float		  LODBias;			// Level of Detail bias. >1 = higher LoD, <1 = lower LoD

// Owner.
var         const Actor   Owner;			// Owner actor.
var(Object) name InitialState;
var(Object) name Group;

// RWS Change
// These are used to indicate the style in which a weapon should be held (and used).
enum EWeaponHoldStyle
	{
	WEAPONHOLDSTYLE_None,						// nothing
	WEAPONHOLDSTYLE_Single,						// single-handed (ex: pistol)
	WEAPONHOLDSTYLE_Dual,						// single-handed in both hands (ex: two pistols)
	WEAPONHOLDSTYLE_DualBig,					// for dual wielding large such as weapons with a stock
	WEAPONHOLDSTYLE_Both,						// for large weapons so they don't clip the face
	WEAPONHOLDSTYLE_Double,						// double-handed (ex: shotgun, shovel)
	WEAPONHOLDSTYLE_Pour,						// two-handed pour (ex: gas can)
	WEAPONHOLDSTYLE_Carry,						// heavy object carried in arms (ex: cow head)
	WEAPONHOLDSTYLE_Toss,						// single-handed light objects to be thrown (ex: grenade)
	WEAPONHOLDSTYLE_Melee						// things like a shovel and such
	};

// RWS Change
// These are used to indicate a character's mood, which in turn can determine
// how the character performs various actions.
enum EMood
	{
	MOOD_Normal,								// normal
	MOOD_Scared,								// scared
	MOOD_Combat,								// ready to use weapon
	MOOD_Puking,								// throwing up
	MOOD_Angry,									// Mad, but not using a weapon
	MOOD_Happy,									// Smiling
	MOOD_Paranoid,								// Really shifty eyes and head looking around stuff
	MOOD_Sad									// Ready to cry
	};

// RWS Change
// Used by controllers to determine what sort of thing was said to me
// It's an enum so that one function can accept this sort of thing instead
// of having entry functions for every type of talking. That would
// complicate the AI states even more
enum ETalk
{
	TALK_getdown,
	TALK_askformoney,
	TALK_greeting,
	TALK_fuckyou,
};

//-----------------------------------------------------------------------------
// Structures.

// Identifies a unique convex volume in the world.
struct PointRegion
{
	var zoneinfo Zone;       // Zone.
	var int      iLeaf;      // Bsp leaf.
	var byte     ZoneNumber; // Zone number.
};

//-----------------------------------------------------------------------------
// Major actor properties.

// Scriptable.
var       const LevelInfo Level;         // Level this actor is on.
var transient const Level XLevel;        // Level object.
var(Events) name          Event;         // The event this actor causes.
var Pawn                  Instigator;    // Pawn responsible for damage caused by this actor.
var(Sound) sound          AmbientSound;  // Ambient sound effect.
//ErikFOV change: for subtitles and more
var(Sound) name		  ActorID;		 // For customizes subtitles and other settings
//end
var Inventory             Inventory;     // Inventory chain.
var const Actor           Base;          // Actor we're standing on.
var const PointRegion     Region;        // Region this actor is in.
var transient array<int>  Leaves;		 // BSP leaves this actor is in.

// Internal.
var const float           LatentFloat;   // Internal latent function use.
var const array<Actor>    Touching;		 // List of touching actors.
var const actor           Deleted;       // Next actor in just-deleted chain.

// Internal tags.
var const native int CollisionTag, LightingTag, ActorTag;
var const transient int JoinedTag;

// The actor's position and rotation.
var const	PhysicsVolume	PhysicsVolume;	// physics volume this actor is currently in
var(Movement) const vector	Location;		// Actor's location; use Move to set.
var(Movement) const rotator Rotation;		// Rotation.
var(Movement) vector		Velocity;		// Velocity.
var			  vector        Acceleration;	// Acceleration.

// Attachment related variables
var(Movement)	name	AttachTag;			// Actors matching this Tag will be attached to this actor on startup.
var const array<Actor>  Attached;			// array of actors attached to this actor.
var const vector		RelativeLocation;	// location relative to base/bone (valid if base exists)
var const rotator		RelativeRotation;	// rotation relative to base/bone (valid if base exists)
var const name			AttachmentBone;		// name of bone to which actor is attached (if attached to center of base, =='')

// Projectors
struct ProjectorRenderInfoPtr { var int Ptr; };	// Hack to to fool C++ header generation...
var const transient array<ProjectorRenderInfoPtr> Projectors;// Projected textures on this actor

//-----------------------------------------------------------------------------
// Display properties.

var(Display) Material		Texture;			// Sprite texture.if DrawType=DT_Sprite
var(Display) const mesh		Mesh;				// Mesh if DrawType=DT_Mesh.
var(Display) const StaticMesh StaticMesh;		// StaticMesh if DrawType=DT_StaticMesh
var StaticMeshInstance		StaticMeshInstance; // Contains per-instance static mesh data, like static lighting data.
var const export model		Brush;				// Brush if DrawType=DT_Brush.
var(Display) const float	DrawScale;			// Scaling factor, 1.0=normal size.
var(Display) const vector	DrawScale3D;		// Scaling vector, (1.0,1.0,1.0)=normal size.
var(Display) vector			PrePivot;			// Offset from box center for drawing.
var(Display) array<Material> Skins;				// Multiple skin support - not replicated.
var(Display) byte			AmbientGlow;		// Ambient brightness, or 255=pulsing.
var(Display) byte           MaxLights;          // Limit to hardware lights active on this primitive.
var(Display) ConvexVolume	AntiPortal;			// Convex volume used for DT_AntiPortal

struct native LodSM
{
	var()	float			Distance;		// How far away camera must be to render this LODmesh
	var()	StaticMesh		StaticMesh;		// StaticMesh to render instead of the base mesh
};

//!! FIXME if we ever update the multiplayer to the current codebase...
var(Display) const array<LodSM>	StaticMeshLOD;	// Array of Level-Of-Detail StaticMeshes.

// Style for rendering sprites, meshes.
var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_Alpha,
	STY_Particle
} Style;

// Display.
var(Display)  bool      bUnlit;					// Lights don't affect actor.
var(Display)  bool      bShadowCast;			// Casts static shadows.
var(Display)  bool		bStaticLighting;		// Uses raytraced lighting.
var(Display)  bool		bUseLightingFromBase;	// Use Unlit/AmbientGlow from Base
var(Display) const name	ForcedVisibilityZoneTag;// Culls actor unless viewing it from a ZoneInfo with a Tag matching this one
var(Display)	float	CullDistance;			// <0 = display only at distance, 0 = always display, >0 = display only up to distance

// Advanced.
var			  bool		bHurtEntry;				// keep HurtRadius from being reentrant
var(Advanced) bool		bGameRelevant;			// Always relevant for game
var(Advanced) bool		bCollideWhenPlacing;	// This actor collides with the world when placing.
var			  bool		bTravel;				// Actor is capable of travelling among servers.
var(Advanced) bool		bMovable;				// Actor can be moved.
var			  bool		bDestroyInPainVolume;	// destroy this actor if it enters a pain volume
var(Advanced) bool		bShouldBaseAtStartup;	// if true, find base for this actor at level startup, if collides with world and PHYS_None or PHYS_Rotating
var			  bool		bPendingDelete;			// set when actor is about to be deleted (since endstate and other functions called
												// during deletion process before bDeleteMe is set).
//-----------------------------------------------------------------------------
// Sound.

// Ambient sound.
var(Sound) float        SoundRadius;			// Radius of ambient sound.
var(Sound) byte         SoundVolume;			// Volume of ambient sound.
var(Sound) byte         SoundPitch;				// Sound pitch shift, 64.0=none.

// Sound occlusion
enum ESoundOcclusion
{
	OCCLUSION_Default,			// Default occlusion (BSP).
	OCCLUSION_None,				// No occlusion.
	OCCLUSION_BSP,				// Occlusion by BSP.
	OCCLUSION_StaticMeshes,		// Occlusion by Static Meshes.
	OCCLUSION_All				// Occlusion by BSP and Static Meshes.
};

var(Sound) ESoundOcclusion SoundOcclusion;		// Sound occlusion approach.

// Sound slots for actors.
enum ESoundSlot
{
	SLOT_None,
	SLOT_Misc,
	SLOT_Pain,
	SLOT_Interact,
	SLOT_Ambient,
	SLOT_Talk,
	SLOT_Interface,
};

// Music transitions.
enum EMusicTransition
{
	MTRAN_None,
	MTRAN_Instant,
	MTRAN_Segue,
	MTRAN_Fade,
	MTRAN_FastFade,
	MTRAN_SlowFade,
};

// Regular sounds.
var(Sound) float TransientSoundVolume;	// default sound volume for regular sounds (can be overridden in playsound)
var(Sound) float TransientSoundRadius;	// default sound radius for regular sounds (can be overridden in playsound)

//-----------------------------------------------------------------------------
// Collision.

// Collision size.
var(Collision) const float CollisionRadius;		// Radius of collision cyllinder.
var(Collision) const float CollisionHeight;		// Half-height cyllinder.

// Collision flags.
var(Collision) const bool bCollideActors;		// Collides with other actors.
var(Collision) bool       bCollideWorld;		// Collides with the world.
var(Collision) bool       bBlockActors;			// Blocks other nonplayer actors.
var(Collision) bool       bBlockPlayers;		// Blocks other player actors.
var(Collision) bool       bProjTarget;			// Projectiles should potentially target this actor.
var(Collision) bool		  bBlockZeroExtentTraces; // block zero extent actors/traces
var(Collision) bool		  bBlockNonZeroExtentTraces;	// block non-zero extent actors/traces
var(Collision) bool       bAutoAlignToTerrain;  // Auto-align to terrain in the editor
var(Collision) bool		  bUseCylinderCollision;// Force axis aligned cylinder collision (useful for static mesh pickups, etc.)
var(Collision) const bool bBlockKarma;			// Block actors being simulated with Karma.
// RWS CHANGE 1/8/2014 - Adds bSkipEncroachmentCheck bool to speed up SetLocation/FarMoveActor on fluids (prevents KActor lag)
// Should ONLY be used for fluid feeders unless you know exactly what you are doing!
var const bool bSkipEncroachmentCheck;			// Skips encroachment check when moved.

var(Collision) enum ESurfaceType
{
	EST_Default,
	EST_Rock,
	EST_Dirt,
	EST_Metal,
	EST_Wood,
	EST_Plant,
	EST_Flesh,
	EST_Ice,
	EST_Snow,
	EST_Water,
	EST_Glass,
	EST_Sand,
	EST_BrokenGlass,
	EST_Carpet,
	EST_Ceramic,
	EST_MutedWood,
	EST_LightMetal,
	EST_Trash,
	EST_Shit,
	EST_Puddle,
	EST_Reserved00,
	EST_Reserved01,
	EST_Reserved02,
	EST_Reserved03,
	EST_Reserved04,
	EST_Reserved05,
	EST_Reserved06,
	EST_Reserved07,
	EST_Reserved08,
	EST_Reserved09,
	EST_Reserved10,
	EST_Reserved11,	
	EST_Custom00,
	EST_Custom01,
	EST_Custom02,
	EST_Custom03,
	EST_Custom04,
	EST_Custom05,
	EST_Custom06,
	EST_Custom07,
	EST_Custom08,
	EST_Custom09,
	EST_Custom10,
	EST_Custom11,
	EST_Custom12,
	EST_Custom13,
	EST_Custom14,
	EST_Custom15,
	EST_Custom16,
	EST_Custom17,
	EST_Custom18,
	EST_Custom19,
	EST_Custom20,
	EST_Custom21,
	EST_Custom22,
	EST_Custom23,
	EST_Custom24,
	EST_Custom25,
	EST_Custom26,
	EST_Custom27,
	EST_Custom28,
	EST_Custom29,
	EST_Custom30
} SurfaceType;		// Surface type of this actor (mainly used on StaticMeshes and BlockingVolumes)

//-----------------------------------------------------------------------------
// Lighting.

// Light modulation.
var(Lighting) enum ELightType
{
	LT_None,
	LT_Steady,
	LT_Pulse,
	LT_Blink,
	LT_Flicker,
	LT_Strobe,
	LT_BackdropLight,
	LT_SubtlePulse,
	LT_TexturePaletteOnce,
	LT_TexturePaletteLoop
} LightType;	// Light modulation (bDynamicLight must be True for all but LT_None and LT_Steady)

// Spatial light effect to use.
var/*(Lighting)*/ enum ELightEffect
{
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
	LE_Unused,
	LE_Sunlight
} LightEffect;	// Special lighting effects. (FIXME: Only works in editor)

// Lighting info.
var(LightColor) float
	LightBrightness;	// Brightness 0-255
var(LightColor) byte
	LightHue,			// Light color 0-255. 0 = red, 40 = yellow, 80 = green, 160 = blue, 200 = violet
	LightSaturation;	// Light saturation 0-255. Must be less than 255 to have a color other than white

// Light properties.
var(Lighting) float
	LightRadius;		// Radius of light effect
var(Lighting) byte
	LightPeriod,		// Determines the rate of special lighting effects
	LightPhase,			// Determines fade in/out of special lighting effects
	LightCone;			// Determines angle of LT_Spotlight

// Lighting.
var(Lighting) bool	     bSpecialLit;	// Only affects special-lit surfaces.
var(Lighting) bool	     bActorShadows; // Light casts actor shadows.
var(Lighting) bool	     bCorona;       // Light uses Skin as a corona.
var bool				 bLightChanged;	// Recalculate this light's lighting now.

//-----------------------------------------------------------------------------
// Physics.

// Options.
var			  bool		  bIgnoreOutOfWorld; // Don't destroy if enters zone zero
var(Movement) bool        bBounce;           // Bounces when hits ground fast.
var(Movement) bool		  bFixedRotationDir; // Fixed direction of rotation.
var(Movement) bool		  bRotateToDesired;  // Rotate to DesiredRotation.
var           bool        bInterpolating;    // Performing interpolating.
var			  const bool  bJustTeleported;   // Used by engine physics - not valid for scripts.

// Physics properties.
var(Movement) float       Mass;				// Mass of this actor.
var(Movement) float       Buoyancy;			// Water buoyancy.
var(Movement) rotator	  RotationRate;		// Change in rotation per second.
var(Movement) rotator     DesiredRotation;	// Physics will smoothly rotate actor to this rotation if bRotateToDesired.
var			  Actor		  PendingTouch;		// Actor touched during move which wants to add an effect after the movement completes
var       const vector    ColLocation;		// Actor's old location one move ago. Only for debugging

const MAXSTEPHEIGHT = 35.0; // Maximum step height walkable by pawns
const MINFLOORZ = 0.7; // minimum z value for floor normal (if less, not a walkable floor)
					   // 0.7 ~= 45 degree angle for floor
// ifdef WITH_KARMA
var(Karma) export editinline KarmaParamsCollision KParams; // Parameters for Karma Collision/Dynamics.
// endif

//-----------------------------------------------------------------------------
// Animation replication (can be used to replicate channel 0 anims for dumb proxies)
struct AnimRep
{
	var name AnimSequence;
	var bool bAnimLoop;
	var byte AnimRate;		// note that with compression, max replicated animrate is 4.0
	var byte AnimFrame;
	var byte TweenRate;		// note that with compression, max replicated tweentime is 4 seconds
};
var transient AnimRep		  SimAnim;		   // only replicated if bReplicateAnimations is true


// RWS CHANGE 02/15/03	Added some variables to serialize animations
// Saving/Loading animations
var name	SaveAnim;			// Last anim I was playing when saved
var float	SaveFrame;			// 0 to 1.0 value for what frame we were on
var float	SaveRate;			// value for how fast we were playing the frame, 1.0 is normal.


//-----------------------------------------------------------------------------
// Forces.

enum EForceType
{
	FT_None,					// Does not affect emitters.
	FT_DragAlong,				// Emitter particles are "dragged along" with this actor.
};

var (Force) EForceType	ForceType;		// Type of force imparted to emitter particles
var (Force)	float		ForceRadius;	// Effective radius of force
var (Force) float		ForceScale;		// Scale of force applied


//-----------------------------------------------------------------------------
// Networking.

// Network control.
var float NetPriority; // Higher priorities means update it more frequently.
var float NetUpdateFrequency; // How many seconds between net updates.

// Symmetric network flags, valid during replication only.
var const bool bNetInitial;       // Initial network update.
var const bool bNetOwner;         // Player owns this actor.
var const bool bNetRelevant;      // Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool bDemoRecording;	  // True we are currently demo recording
var const bool bClientDemoRecording;// True we are currently recording a client-side demo
var const bool bClientDemoNetFunc;// True if we're client-side demo recording and this call originated from the remote.


//Editing flags
var(Advanced) bool        bHiddenEd;     // Is hidden during editing.
var(Advanced) bool        bHiddenEdGroup;// Is hidden by the group brower.
var(Advanced) bool        bDirectional;  // Actor shows direction arrow during editing.
var const bool            bSelected;     // Selected in UnrealEd.
var(Advanced) bool        bEdShouldSnap; // Snap to grid in editor.
var transient bool        bEdSnap;       // Should snap to grid in UnrealEd.
var transient const bool  bTempEditor;   // Internal UnrealEd.
var	bool				  bObsolete;	 // actor is obsolete - warn level designers to remove it
var(Collision) bool		  bPathColliding;// this actor should collide (if bWorldGeometry && bBlockActors is true) during path building (ignored if bStatic is true, as actor will always collide during path building)
var transient bool		  bPathTemp;	 // Internal/path building

var	bool				  bScriptInitialized; // set to prevent re-initializing of actors spawned during level startup
var(Advanced) bool        bLockLocation; // Prevent the actor from being moved in the editor.
var class<LocalMessage> MessageClass;

// RWS edit 4/10/14 Advanced Spawning
var native const array<String> SpawnPropertyText, SpawnPropertyValue;

//var native const float AvgTickMs;

//-----------------------------------------------------------------------------
// Enums.

// Travelling from server to server.
enum ETravelType
{
	TRAVEL_Absolute,	// Absolute URL.
	TRAVEL_Partial,		// Partial (carry name, reset server).
	TRAVEL_Relative,	// Relative URL.
};


// double click move direction.
enum EDoubleClickDir
{
	DCLICK_None,
	DCLICK_Left,
	DCLICK_Right,
	DCLICK_Forward,
	DCLICK_Back,
	DCLICK_Active,
	DCLICK_Done
};

// RWS CHANGE: Merged from UT2003
enum EFlagState
{
    FLAG_Home,
    FLAG_HeldFriendly,
    FLAG_HeldEnemy,
    FLAG_Down,
};

// Change by NickP: MP fix
var(Display) bool bReplicateSkin;			// Should replicate Skins[0]
var Material RepSkin;						// Replicated skin
// End

//-----------------------------------------------------------------------------
// natives.

// Execute a console command in the context of the current level and game engine.
native function string ConsoleCommand( string Command );

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	// Location
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Location;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& ((DrawType == DT_Mesh) || (DrawType == DT_StaticMesh))
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Rotation;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& RemoteRole<=ROLE_SimulatedProxy )
		Base;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& RemoteRole<=ROLE_SimulatedProxy && (Base != None) && !Base.bWorldGeometry)
		RelativeRotation, RelativeLocation, AttachmentBone;

	// Physics
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& (((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition))
						|| ((RemoteRole == ROLE_DumbProxy) && (Physics == PHYS_Falling))) )
		Velocity;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& (((RemoteRole == ROLE_SimulatedProxy) && bNetInitial)
						|| (RemoteRole == ROLE_DumbProxy)) )
		Physics;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& (RemoteRole <= ROLE_SimulatedProxy) && (Physics == PHYS_Rotating) )
		bFixedRotationDir, bRotateToDesired, RotationRate, DesiredRotation;

	// Ambient sound.
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) )
		AmbientSound;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim)
					&& (AmbientSound!=None) )
		SoundRadius, SoundVolume, SoundPitch;

	// Animation.
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial)
				&& (Role==ROLE_Authority) && (DrawType==DT_Mesh) && bReplicateAnimations )
		SimAnim;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) )
		bHidden;

	// Properties changed using accessor functions (Owner, rendering, and collision)
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && bNetDirty )
		Owner, DrawScale, DrawScale3D, DrawType, bCollideActors,bCollideWorld,bOnlyOwnerSee,Texture,Style;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && bNetDirty
					&& (bCollideActors || bCollideWorld) )
		bProjTarget, bBlockActors, bBlockPlayers, CollisionRadius, CollisionHeight;

	// Properties changed only when spawning or in script (relationships, rendering, lighting)
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) )
		Role,RemoteRole,bNetOwner,LightType,bTearOff;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority)
					&& bNetDirty && bNetOwner )
		Inventory;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority)
					&& bNetDirty && bReplicateInstigator )
		Instigator;

	// Infrequently changed mesh properties
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority)
					&& bNetDirty && (DrawType == DT_Mesh) )
		AmbientGlow,bUnlit,PrePivot,Mesh;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority)
				&& bNetDirty && (DrawType == DT_StaticMesh) )
		StaticMesh;

	// Infrequently changed lighting properties.
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority)
					&& bNetDirty && (LightType != LT_None) )
		LightEffect, LightBrightness, LightHue, LightSaturation,
		LightRadius, LightPeriod, LightPhase, bSpecialLit;

	// replicated functions
	unreliable if( bDemoRecording )
		DemoPlaySound;

	// Change by NickP: MP fix
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial)
				&& (Role==ROLE_Authority) && bReplicateSkin && Skins.Length > 0 )
		RepSkin;
	// End
}

//=============================================================================
// Actor error handling.

// Handle an error and kill this one actor.
native(233) final function Error( coerce string S );

//=============================================================================
// General functions.

// Latent functions.
native(256) final latent function Sleep( float Seconds );

// Collision.
native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
native(283) final function bool SetCollisionSize( float NewRadius, float NewHeight );
native final function SetDrawScale(float NewScale);
native final function SetDrawScale3D(vector NewScale3D);
native final function SetStaticMesh(StaticMesh NewStaticMesh);
native final function SetDrawType(EDrawType NewDrawType);

// Lod Static Mesh functions.

// Adds or replaces a LodSM entry at the given Distance.
native final function SetLodStaticMesh(float Distance, StaticMesh LodStaticMesh);
// Deletes the LodSM entry at the given Distance or all entries matching the given LodStaticMesh. Return value is the number of entries deleted.
native final function int DeleteLodStaticMesh(optional float Distance, optional StaticMesh LodStaticMesh);
// Removes all LodSM entries.
native final function ClearLodStaticMesh();

// Movement.
native(266) final function bool Move( vector Delta );
// RWS 2014 added bIgnoreEncroachment - use with care
native(267) final function bool SetLocation( vector NewLocation, optional bool bIgnoreEncroachment );
native(299) final function bool SetRotation( rotator NewRotation );

// SetRelativeRotation() sets the rotation relative to the actor's base
native final function bool SetRelativeRotation( rotator NewRotation );
native final function bool SetRelativeLocation( vector NewLocation );

native(3969) final function bool MoveSmooth( vector Delta );
native(3971) final function AutonomousPhysics(float DeltaSeconds);

// Relations.
native(298) final function SetBase( actor NewBase, optional vector NewFloor );
native(272) final function SetOwner( actor NewOwner );

//=============================================================================
// Animation.

// Animation functions.
native(259) final function PlayAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel );

// RWS CHANGE 02/15/03 Added play anim that can set the frame to start at (0 start, 1.0 end)
native final function PlayAnimAt(name SequenceName, optional float PlayAnimRate, optional float TweenTime,
							optional int Channel, optional float AtFrame);

native(260) final function LoopAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel );
native(294) final function TweenAnim( name Sequence, float Time, optional int Channel );
native(282) final function bool IsAnimating(optional int Channel);
native(261) final latent function FinishAnim(optional int Channel);
native(263) final function bool HasAnim( name Sequence );
native final function StopAnimating();
native final function FreezeAnimAt( float Time, optional int Channel);
native final function bool IsTweening(int Channel);

// Animation notifications.
event AnimEnd( int Channel );
native final function EnableChannelNotify ( int Channel, int Switch );
native final function int GetNotifyChannel();

// Skeletal animation.
simulated native final function LinkSkelAnim( MeshAnimation Anim, optional mesh NewMesh );
simulated native final function LinkMesh( mesh NewMesh, optional bool bKeepAnim );
// RWS CHANGE: Get the default animation for the specified skeletal mesh.
simulated native final function MeshAnimation GetDefaultAnim(SkeletalMesh Mesh);
// RWS CHANGE: Get the default animation for the specified skeletal mesh.

native final function AnimBlendParams( int Stage, optional float BlendAlpha, optional float InTime, optional float OutTime, optional name BoneName, optional bool bGlobalPose);
native final function AnimBlendToAlpha( int Stage, float TargetAlpha, float TimeInterval );

native final function coords  GetBoneCoords(   name BoneName );
native final function rotator GetBoneRotation( name BoneName, optional int Space );	// 0 local, 1 global, 2 relative reference pose (?) 

native final function vector  GetRootLocation();
native final function rotator GetRootRotation();
native final function vector  GetRootLocationDelta();
native final function rotator GetRootRotationDelta();

native final function bool  AttachToBone( actor Attachment, name BoneName );
native final function bool  DetachFromBone( actor Attachment );

native final function LockRootMotion( int Lock );
native final function SetBoneScale( int Slot, optional float BoneScale, optional name BoneName );

native final function SetBoneDirection( name BoneName, rotator BoneTurn, optional vector BoneTrans, optional float Alpha );
native final function SetBoneLocation( name BoneName, optional vector BoneTrans, optional float Alpha );
native final function SetBoneRotation( name BoneName, optional rotator BoneTurn, optional int Space, optional float Alpha );
native final function GetAnimParams( int Channel, out name OutSeqName, out float OutAnimFrame, out float OutAnimRate );
native final function bool AnimIsInGroup( int Channel, name GroupName );

//=========================================================================
// Rendering.

native final function plane GetRenderBoundingSphere();

//=========================================================================
// Physics.

// Physics control.
native(301) final latent function FinishInterpolation();
native(3970) final function SetPhysics( EPhysics newPhysics );

// ifdef WITH_KARMA

native final function KSetMass( float mass );
native final function float KGetMass();

// Set inertia tensor assuming a mass of 1. Scaled by mass internally to calculate actual inertia tensor.
native final function KSetInertiaTensor( vector it1, vector it2 );
native final function KGetInertiaTensor( out vector it1, out vector it2 );

native final function KSetDampingProps( float lindamp, float angdamp );
native final function KGetDampingProps( out float lindamp, out float angdamp );

native final function KSetFriction( float friction );
native final function float KGetFriction();

native final function KSetRestitution( float rest );
native final function float KGetRestitution();

native final function KAddForce( vector force, optional vector Position );
native final function KAddTorque( vector torque );

native final function KSetCOMOffset( vector offset );
native final function KGetCOMOffset( out vector offset );
native final function KGetCOMPosition( out vector pos ); // get actual position of actors COM in world space

native final function KSetImpactThreshold( float thresh );
native final function float KGetImpactThreshold();

native final function KWake();
native final function KAddImpulse( vector Impulse, vector Position, optional name BoneName );
native final function KSetSkelVel( vector Velocity );

native final function KSetStayUpright( bool stayUpright, bool allowRotate );

native final function KSetBlockKarma( bool newBlock );

// Disable/Enable Karma contact generation between this actor, and another actor.
// Collision is on by default.
native final function KDisableCollision( actor Other );
native final function KEnableCollision( actor Other );

// RWS Change 08/08/02, allow ragdolls to be frozen in their last position, then turned off
// http://mail.epicgames.com/listarchive/showpost.php?list=unprog&id=29372&lessthan=0&show=20
// This should deallocate the ragdoll from the karma pool, then leave the mesh in it's last
// position (so that other pawns could then use the memory)
native final function KFreezeRagdoll();

// RWS Change 02/19/02 Turn off the karma for this object (usually only for jittering ragdolls)
// this simple disables the karma for that object. (Doesn't terminate it)
native final function KDisableKarma();

native final function OnlyAffectPawns(bool B);

// event called when PHYS_Karma actor hits with impact velocity over KImpactThreshold
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm);

// RWS Change 02/19/02
// Called when the ragdoll (usually) has it's limbs pulled in such a way that it looks
// really bad. Decide what to do with it. Usually just destroy it.
event KExcessiveJointError();

// endif

//=========================================================================
// Music

native final function int PlayMusic( string Song, float FadeInTime, optional float VolumeOverride, optional bool bAllowPause );
// RWS CHANGE: Attenuate music as this actor moves around (just like sounds)
native final function int PlayMusicAttenuate( string Song, float FadeInTime, optional float Volume, optional float Radius, optional float Pitch, optional float VolumeOverride, optional bool bAllowPause, optional bool bLegacy);
// RWS CHANGE: Attenuate music as this actor moves around (just like sounds)
native final function StopMusic( int SongHandle, float FadeOutTime );
native final function StopAllMusic( float FadeOutTime );


//=========================================================================
// Engine notification functions.

//
// Major notifications.
//
event Destroyed();
event GainedChild( Actor Other );
event LostChild( Actor Other );
event Tick( float DeltaTime );

//
// Triggers.
//
event Trigger( Actor Other, Pawn EventInstigator );
event UnTrigger( Actor Other, Pawn EventInstigator );
event BeginEvent();
event EndEvent();

//
// Physics & world interaction.
//
event Timer();
event HitWall( vector HitNormal, actor HitWall );
event Falling();
event Landed( vector HitNormal );
event ZoneChange( ZoneInfo NewZone );
event PhysicsVolumeChange( PhysicsVolume NewVolume );
event Touch( Actor Other );
event PostTouch( Actor Other ); // called for PendingTouch actor after physics completes
event UnTouch( Actor Other );
event Bump( Actor Other );
event BaseChange();
event Attach( Actor Other );
event Detach( Actor Other );
event Actor SpecialHandling(Pawn Other);
event bool EncroachingOn( actor Other );
event EncroachedBy( actor Other );
event FinishedInterpolation()
{
	bInterpolating = false;
}

event EndedRotation();			// called when rotation completes
event UsedBy( Pawn user ); // called if this Actor was touching a Pawn who pressed Use

// RWS CHANGE: Added simulated per UT2003
simulated event FellOutOfWorld()
{
	SetPhysics(PHYS_None);
	Destroy();
}

//
// Damage and kills.
//
event KilledBy( pawn EventInstigator );
event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType);

//
// Trace a line and see what it collides with first.
// Takes this actor's collision properties into account.
// Returns first hit actor, Level if hit level, or None if hit nothing.
//
native(277) final function Actor Trace
(
	out vector      HitLocation,
	out vector      HitNormal,
	vector          TraceEnd,
	optional vector TraceStart,
	optional bool   bTraceActors,
	optional vector Extent,
	optional out material Material
);

// returns true if did not hit world geometry
native(548) final function bool FastTrace
(
	vector          TraceEnd,
	optional vector TraceStart
);

//
// Spawn an actor. Returns an actor of the specified class, not
// of class Actor (this is hardcoded in the compiler). Returns None
// if the actor could not be spawned (either the actor wouldn't fit in
// the specified location, or the actor list is full).
// Defaults to spawning at the spawner's location.
//
native(278) final function actor Spawn
(
	class<actor>      SpawnClass,
	optional actor	  SpawnOwner,
	optional name     SpawnTag,
	optional vector   SpawnLocation,
	optional rotator  SpawnRotation,
// RWS Change 12/18/02 Added optional skin parameter to spawn
	optional Material SpawnSkin
// RWS Change 12/18/02
// RWS Edit 4/10/14 Advanced Spawning
// Do not use this flag except with editor-generated code
,	optional bool bUseSpawnProperties
);

// RWS Edit 4/10/14 Advanced Spawning
// Do not use except with editor-generated code
native final function AddSpawnProperty(string PropertyName, string PropertyValue);

//
// Destroy this actor. Returns true if destroyed, false if indestructable.
// Destruction is latent. It occurs at the end of the tick.
//
native(279) final function bool Destroy();

// Networking - called on client when actor is torn off (bTearOff==true)
event TornOff();

//=============================================================================
// Timing.

// Causes Timer() events every NewTimerRate seconds.
native(280) final function SetTimer( float NewTimerRate, bool bLoop );

//=============================================================================
// Sound functions.

/* Play a sound effect.
*/
native(264) final function PlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
	optional bool		Attenuate,
	optional bool		bAllowPause,
	optional bool		bMaxPriority
);

// RWS Edit: Play a "flashbang" sound that drowns out everything 
native final function PlayFlashbangSound(Sound Sound, optional float OverrideDuration);

/* play a sound effect, but don't propagate to a remote owner
 (he is playing the sound clientside)
 */
native simulated final function PlayOwnedSound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
	optional bool		Attenuate
);

native simulated event DemoPlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
	optional bool		Attenuate
);

/* Get a sound duration.
*/
native final function float GetSoundDuration( sound Sound );

//=============================================================================
// AI functions.

/* Inform other creatures that you've made a noise
 they might hear (they are sent a HearNoise message)
 Senders of MakeNoise should have an instigator if they are not pawns.
*/
native(512) final function MakeNoise( float Loudness );

/* PlayerCanSeeMe returns true if any player (server) or the local player (standalone
or client) has a line of sight to actor's location.
*/
native(532) final function bool PlayerCanSeeMe();

//=============================================================================
// Regular engine functions.

// Teleportation.
event bool PreTeleport( Teleporter InTeleporter );
event PostTeleport( Teleporter OutTeleporter );

// Level state.
event BeginPlay();

//========================================================================
// Disk access.

// Find files.
native(539) final function string GetMapName( string NameEnding, string MapName, int Dir );
native(545) final function GetNextSkin( string Prefix, string CurrentSkin, int Dir, out string SkinName, out string SkinDesc );
native(547) final function string GetURLMap();
native final function string GetNextInt( string ClassName, int Num );
native final function GetNextIntDesc( string ClassName, int Num, out string Entry, out string Description );
native final function bool GetCacheEntry( int Num, out string GUID, out string Filename );
native final function bool MoveCacheEntry( string GUID, optional string NewFilename );
native final function bool DoesMapExist(string MapName);

//=============================================================================
// Iterator functions.

// Iterator functions for dealing with sets of actors.

/* AllActors() - avoid using AllActors() too often as it iterates through the whole actor list and is therefore slow
*/
native(304) final iterator function AllActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* DynamicActors() only iterates through the non-static actors on the list (still relatively slow, bu
 much better than AllActors).  This should be used in most cases and replaces AllActors in most of
 Epic's game code.
*/
native(313) final iterator function DynamicActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* ChildActors() returns all actors owned by this actor.  Slow like AllActors()
*/
native(305) final iterator function ChildActors   ( class<actor> BaseClass, out actor Actor );

/* BasedActors() returns all actors based on the current actor (slow, like AllActors)
*/
native(306) final iterator function BasedActors   ( class<actor> BaseClass, out actor Actor );

/* TouchingActors() returns all actors touching the current actor (fast)
*/
native(307) final iterator function TouchingActors( class<actor> BaseClass, out actor Actor );

/* TraceActors() return all actors along a traced line.  Reasonably fast (like any trace)
*/
native(309) final iterator function TraceActors   ( class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent );

/* RadiusActors() returns all actors within a give radius.  Slow like AllActors().  Use CollidingActors() or VisibleCollidingActors() instead if desired actor types are visible
(not bHidden) and in the collision hash (bCollideActors is true)
*/
native(310) final iterator function RadiusActors  ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

/* VisibleActors() returns all visible actors within a radius.  Slow like AllActors().  Use VisibleCollidingActors() instead if desired actor types are
in the collision hash (bCollideActors is true)
*/
native(311) final iterator function VisibleActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc );

/* VisibleCollidingActors() returns visible (not bHidden) colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() since it uses the collision hash
*/
native(312) final iterator function VisibleCollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc, optional bool bIgnoreHidden );

/* CollidingActors() returns colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() for reasonably small radii since it uses the collision hash
*/
native(321) final iterator function CollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

//=============================================================================
// Color functions
native(549) static final operator(20) color -     ( color A, color B );
native(550) static final operator(16) color *     ( float A, color B );
native(551) static final operator(20) color +     ( color A, color B );
native(552) static final operator(16) color *     ( color A, float B );

//=============================================================================
// Scripted Actor functions.

/* RenderOverlays()
called by player's hud to request drawing of actor specific overlays onto canvas
*/
function RenderOverlays(Canvas Canvas);

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	// Handle autodestruction if desired.
	if( !bGameRelevant && (Level.NetMode != NM_Client) && !Level.Game.BaseMutator.CheckRelevance(Self) )
		Destroy();
}

//
// Broadcast a localized message to all players.
// Most message deal with 0 to 2 related PRIs.
// The LocalMessage class defines how the PRI's and optional actor are used.
//
event BroadcastLocalizedMessage( class<LocalMessage> MessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Level.Game.BroadcastLocalized( self, MessageClass, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

// Called immediately after gameplay begins.
//
event PostBeginPlay();

// RWS CHANGE 02/14/03
// Called before a saved game is loaded (not called during a normal level load.)
// Not sure what this would be used for, it was primarily added as a "balance" to PostLoadGame().
event PreLoadGame();

// RWS CHANGE 08/29/02
// Called after a saved game has been loaded (not called during a normal level load.)
// Generally used to re-init things that aren't saved properly.  Also used to restore object
// references that were cleared in PreSaveGame().
event PostLoadGame()
{
	// Force the animations to restart
	//log(self$" PostLoadGame, save anim "$SaveAnim$" save frame "$SaveFrame$" rate "$SaveRate);
	if(SaveAnim != '')
		PlayAnimAt(SaveAnim, SaveRate, , , SaveFrame);
}

// RWS CHANGE 08/29/02
// Called before a game is saved.
// Generally used to either save things the engine doesn't save properly or to clear
// object references that cause problems when loading saved games.  Object references
// that are cleared here may need to be restored in PostSaveGame() and PostLoadGame().
event PreSaveGame()
{
	// Make anything that was playing an anim in the 0 channel restore properly.
	// Only get them for channel 0.
	GetAnimParams(0, SaveAnim, SaveFrame, SaveRate);
	if(SaveFrame < 0.0)
		SaveFrame = 0.0;
	else if(SaveFrame > 1.0)
		SaveFrame = 1.0;
	//log(self$" PreSaveGame, save anim "$SaveAnim$" save frame "$SaveFrame$" rate "$SaveRate);
}

// RWS CHANGE 02/14/03
// Called after a game is saved.
// Generally used to restore object references that were cleared in PreSaveGame().
event PostSaveGame();

// RWS CHANGE
// Called whenever a change is made in the editor
event PostEditChange();

// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	bScriptInitialized = true;
	if( InitialState!='' )
		GotoState( InitialState );
	else
		GotoState( 'Auto' );
}

// called after PostBeginPlay.  On a net client, PostNetBeginPlay() is spawned after replicated variables have been initialized to
// their replicated values
event PostNetBeginPlay();

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
native simulated singular final function HurtRadius(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation);

// So, lots of P2 subclasses overrode the engine HurtRadius for a variety of reasons, and all these custom UScript-based scripts that get called constantly every tick just
// bog the game down tremendously... so I made this "mega-version" that should encompass any purpose that we need.
// Returns the number of LIVE pawns hit.
native simulated singular final function int HurtRadiusEX(
	float DamageAmount,					// Amount of damage to deal
	float DamageRadius,					// Radius of damage effect
	class<DamageType> DamageType,		// Damage type dealt
	float Momentum,						// Momentum imparted to target
	vector HitLocation,					// Location of the "center" of the blast
	optional bool bNoScale,				// If true, all actors in range take exactly DamageAmount, don't do "splash damage" scaling
	optional float RoundUpIf,			// If nonzero, rounds damage up to 1 if this value of more (example: 0.5 means that if it at least tried to deal 0.5 damage, it'll round up to 1)
	optional bool bStopAtWall,			// If true, damage stops at a wall (equivalent of a FastTrace check)
	optional bool bIgnoreInstigator,	// If true, our Instigator is immune
	optional Actor IgnoreActor,			// If specified, ignores this actor
	optional class<Actor> TargetClass,	// If specified, targets only Actors of this class or subclass
	optional bool bExplosion,			// If true, this is an explosion, and affected actors should be thrown skyward
	optional string ClassCheck,			// If specified, returns a bool if we hit any actors of this class or classes. Separate with commas, do not specify package. (Example: "Kumquat,Taliban")
	optional out int bClassCheckResult,	// If this and ClassCheck is specified, returns 1 if we hit any actors whose class name matches a ClassCheck parameter
	optional float InstigatorRadius		// If specified, checks this value instead of DamageRadius if the target is the instigator
	);	// rip 15-parameter limit
/*
simulated final function DONOTUSE( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (Victims != self) && (Victims.Role == ROLE_Authority) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				Max(damageScale * DamageAmount, 1),
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			//log(self$": HurtRadius, "$Victims$" took "$Max(damageScale * damageAmount,1)$" damage of class "$DamageType,'Debug');
		}
	}
	bHurtEntry = false;
}
*/

// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept();

// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept();

// Called by PlayerController when this actor becomes its ViewTarget.
//
function BecomeViewTarget();

// Returns the string representation of the name of an object without the package
// prefixes.
//
function String GetItemName( string FullName )
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

// Returns the human readable string representation of an object.
//
// RWS CHANGE: Made simulated per UT2003
simulated function String GetHumanReadableName()
//function String GetHumanReadableName()
{
	return GetItemName(string(class));
}

final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;

	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(ERenderStyle NewStyle, Material NewTexture, bool bLighting )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
}

// Get localized message string associated with this actor
static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return "";
}

function MatchStarting(); // called when gameplay actually starts

function String GetDebugName()
{
	return GetItemName(string(self));
}

/* DisplayDebug()
list important actor variable on canvas.  HUD will call DisplayDebug() on the current ViewTarget when
the ShowDebug exec is used
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local float XL;
	local int i;
	local Actor A;
	local name anim;
	local float frame,rate;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.StrLen("TEST", XL, YL);
	YPos = YPos + YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,0,0);
	T = GetDebugName();
	if ( bDeleteMe )
		T = T$" DELETED (bDeleteMe == true)";

	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,255,255);

	if ( Level.NetMode != NM_Standalone )
	{
		// networking attributes
		T = "ROLE ";
		Switch(Role)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		T = T$" REMOTE ROLE ";
		Switch(RemoteRole)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		if ( bTearOff )
			T = T$" Tear Off";
		Canvas.DrawText(T, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	T = "Physics ";
	Switch(PHYSICS)
	{
		case PHYS_None: T=T$"None"; break;
		case PHYS_Walking: T=T$"Walking"; break;
		case PHYS_Falling: T=T$"Falling"; break;
		case PHYS_Swimming: T=T$"Swimming"; break;
		case PHYS_Flying: T=T$"Flying"; break;
		case PHYS_Rotating: T=T$"Rotating"; break;
		case PHYS_Projectile: T=T$"Projectile"; break;
		case PHYS_Interpolating: T=T$"Interpolating"; break;
		case PHYS_MovingBrush: T=T$"MovingBrush"; break;
		case PHYS_Spider: T=T$"Spider"; break;
		case PHYS_Trailer: T=T$"Trailer"; break;
		case PHYS_Ladder: T=T$"Ladder"; break;
	}
	T = T$" in physicsvolume "$GetItemName(string(PhysicsVolume))$" on base "$GetItemName(string(Base));
	if ( bBounce )
		T = T$" - will bounce";
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Location: "$Location$" Rotation "$Rotation, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Velocity: "$Velocity$" Speed "$VSize(Velocity), false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Acceleration: "$Acceleration, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawColor.B = 0;
	Canvas.DrawText("Collision Radius "$CollisionRadius$" Height "$CollisionHeight);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Collides with Actors "$bCollideActors$", world "$bCollideWorld$", proj. target "$bProjTarget);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Blocks Actors "$bBlockActors$", players "$bBlockPlayers);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Touching ";
	ForEach TouchingActors(class'Actor', A)
		T = T$GetItemName(string(A))$" ";
	if ( T == "Touching ")
		T = "Touching nothing";
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawColor.R = 0;
	T = "Rendered: ";
	Switch(Style)
	{
		case STY_None: T=T; break;
		case STY_Normal: T=T$"Normal"; break;
		case STY_Masked: T=T$"Masked"; break;
		case STY_Translucent: T=T$"Translucent"; break;
		case STY_Modulated: T=T$"Modulated"; break;
		case STY_Alpha: T=T$"Alpha"; break;
	}

	Switch(DrawType)
	{
		case DT_None: T=T$" None"; break;
		case DT_Sprite: T=T$" Sprite "; break;
		case DT_Mesh: T=T$" Mesh "; break;
		case DT_Brush: T=T$" Brush "; break;
		case DT_RopeSprite: T=T$" RopeSprite "; break;
		case DT_VerticalSprite: T=T$" VerticalSprite "; break;
		case DT_Terraform: T=T$" Terraform "; break;
		case DT_SpriteAnimOnce: T=T$" SpriteAnimOnce "; break;
		case DT_StaticMesh: T=T$" StaticMesh "; break;
	}

	if ( DrawType == DT_Mesh )
	{
		T = T$Mesh;
		if ( Skins.length > 0 )
		{
			T = T$" skins: ";
			for ( i=0; i<Skins.length; i++ )
			{
				if ( skins[i] == None )
					break;
				else
					T =T$skins[i]$", ";
			}
		}

		Canvas.DrawText(T, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);

		// mesh animation
		GetAnimParams(0,Anim,frame,rate);
		T = "AnimSequence "$Anim$" Frame "$frame$" Rate "$rate;
		if ( bAnimByOwner )
			T= T$" Anim by Owner";
	}
	else if ( (DrawType == DT_Sprite) || (DrawType == DT_SpriteAnimOnce) )
		T = T$Texture;
	else if ( DrawType == DT_Brush )
		T = T$Brush;

	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawColor.B = 255;
	Canvas.DrawText("Tag: "$Tag$" Event: "$Event$" STATE: "$GetStateName(), false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Instigator "$GetItemName(string(Instigator))$" Owner "$GetItemName(string(Owner)));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Timer: "$TimerCounter$" LifeSpan "$LifeSpan$" AmbientSound "$AmbientSound);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

// NearSpot() returns true is spot is within collision cylinder
simulated final function bool NearSpot(vector Spot)
{
	local vector Dir;

	Dir = Location - Spot;

	if ( abs(Dir.Z) > CollisionHeight )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius );
}

simulated final function bool TouchingActor(Actor A)
{
	local vector Dir;

	Dir = Location - A.Location;

	if ( abs(Dir.Z) > CollisionHeight + A.CollisionHeight )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius + A.CollisionRadius );
}

// MERGE NOTE PlusDir() replaced by int operator ClockwiseFrom()

/* StartInterpolation()
when this function is called, the actor will start moving along an interpolation path
beginning at Dest
*/
simulated function StartInterpolation()
{
	GotoState('');
	SetCollision(True,false,false);
	bCollideWorld = False;
	bInterpolating = true;
	SetPhysics(PHYS_None);
}

// does viewer-specific things when a cutscene starts
simulated function StartCutscene()
{
	// STUB
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset();

/*
Trigger an event
*/
event TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( (EventName == '') || (EventName == 'None') )
		return;

	ForEach DynamicActors( class 'Actor', A, EventName )
		A.Trigger(Other, EventInstigator);
}

/*
Untrigger an event
*/
function UntriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( (EventName == '') || (EventName == 'None') )
		return;

	ForEach DynamicActors( class 'Actor', A, EventName )
		A.Untrigger(Other, EventInstigator);
}

function bool IsInVolume(Volume aVolume)
{
	local Volume V;

	ForEach TouchingActors(class'Volume',V)
		if ( V == aVolume )
			return true;
	return false;
}

function bool IsInPain()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bPainCausing && (V.DamagePerSec > 0) )
			return true;
	return false;
}

function PlayTeleportEffect(bool bOut, bool bSound);

function bool CanSplash()
{
	return false;
}

function vector GetCollisionExtent()
{
	local vector Extent;

	Extent = CollisionRadius * vect(1,1,0);
	Extent.Z = CollisionHeight;
	return Extent;
}

defaultproperties
{
	// Change by NickP: karma fix
	KarmaMaxSpeed=+02500.000000
	SimAnimChannel=0
	// End

     DrawType=DT_Sprite
     Texture=S_Actor
     DrawScale=+00001.000000
	 MaxLights = 4;
	 DrawScale3D=(X=1,Y=1,Z=1)
     SoundRadius=64
     SoundVolume=128
     SoundPitch=64
	 TransientSoundVolume=+00001.000000
     CollisionRadius=+00022.000000
     CollisionHeight=+00022.000000
     bJustTeleported=True
     Mass=+00100.000000
     Role=ROLE_Authority
     RemoteRole=ROLE_DumbProxy
     NetPriority=+00001.000000
	 Style=STY_Normal
	 bMovable=True
	 bHighDetail=False
	 InitialState=None
	 NetUpdateFrequency=100
	 LODBias=1.0
	 MessageClass=class'LocalMessage'
	 bHiddenEdGroup=False
	 bBlockZeroExtentTraces=true
	 bBlockNonZeroExtentTraces=true
	 bReplicateMovement=true
	 bSkipEncroachmentCheck=false
//	 AvgTickMs=0
}
