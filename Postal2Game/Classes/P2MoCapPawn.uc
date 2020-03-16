//=============================================================================
// P2MoCapPawn
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all MoCap-based characters.
//
//	History:
//		01/29/02 MJR	Beautified the file so Nathan wouldn't recognize it.
//						Started this history, but we probably won't use it
//						much until the pace of changes slows down.
//
//		03/06/02 MJR	Cleaned up and revised animation crap to deal with
//						how our mocap moves were designed.
//
//		03/10/02 MJR	Added support for different dialog for each character.
//
//=============================================================================
//
// PHYSICS BASED ANIMATIONS
// ------------------------
// Know that the order of animations in the MovementAnims array goes like this:
// 0 is forward
// 1 is back
// 2 is left
// 3 is right
// 
//
// SKELETONS AND ANIMATIONS
// ------------------------
//
// This applies to the human characters only, we'll have to deal with cats,
// dogs, and cows separately.
//
// Each character is based on a particular skeleton: avg, big, fat or tall.
// Some of the special characters, such as Gary Coleman, will have their own
// unique meshes, but the same ideas apply to them.
//
// For each skeleton there's a .psa file of the same name that contains all
// the animations designed to be used with that skeleton.
//
// The names of all the various animations are the same across all .psa files.
// However, not all .psa files contain all the same animations.  In some cases
// we only ever use a particular animation with a particular skeleton, so we
// don't waste space by including it in the other .psa files.
//
//
// ANIMATION VARIATIONS
// --------------------
//
// Many animations have more than one variation.  For example, for walking
// we have normal male walk, scared male walk, determined male walk, male walk
// with gun held read to fire, normal female walk, and on and on.  The point is
// that simply knowing we want the character to walk isn't enough.
//
// The following are the things we need to take into account to determine which
// variation of a particular animation to play.
//
//		Masculine or Feminine
//			- Selects between male and female/gay animations
//			- Query: P2MocapPawn.bIsFeminine
//			- Determined by each subclass of P2MocapPawn
//
//		Trained or Untrained
//			- Controls whether character is confortable or nervious with a weapon
//			- Query: P2MocapPawn.bIsTrained
//			- Determined by each subclass of P2MocapPawn
//
//		Weapon holding style
//			- Controls how the character holds and uses his weapons
//			- Query: P2MocapPawn.GetWeaponHoldStyle()
//			- Determined by each weapon class, see P2Weapon.GetHoldingStyle()
//
//		Mood
//			- Controls how character does various things
//			- Query: P2Pawn.mood
//			- Determined by pawn's controller, see P2Pawn.SetMood()
//
// Currently, this class is being designed to take all those variables into
// account so the subclasses don't have to do anything.  However, if things get
// too unwieldy, Masculine/Feminine and Trained/Untrained could be good things
// to let the subclasses handle since those subclasses already determine the
// settings for those variables.
//
//
// Special animation notes:
// WEAPONHOLDSTYLE_Both is now being used to hold extra big things. To avoid
// a full recompile, I didn't change the name nor the comments in Actor.uc. Yeah
// probably not reason enough, but that's why. Instead, that style is for the biggest
// weapons, like the rocket launcher and the napalm launcher. Perhaps in the future
// it should be called something like WEAPONHOLDSTYLE_Big.
//
// AUDIO
// -----
//
// Some audio notes:
//
//		To turn off sound on a particular slot, use 'none' as the sound parameter.
//		But a licensee says this wasn't working properly a while back.
//
//		SLOT_None is supposed to be special in that anything played on that
//		will not cutoff any existing sounds.  They say to use it for rapid-fire
//		gunshot sounds.
//
//		Actor.ESoundSlot defines the slots:
//				SLOT_None,
//				SLOT_Misc,
//				SLOT_Pain,
//				SLOT_Interact,
//				SLOT_Ambient,
//				SLOT_Talk,
//				SLOT_Interface,
//
// Each subclass of P2MocapPawn selects which dialog class it wants to use.
//
//=============================================================================
class P2MoCapPawn extends P2Pawn
	notplaceable
	abstract
	config(Footsteps);


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var bool bWasTurningLeft;

var(Character) class<BodyPart> HeadClass;			// Class for character's head
var(Character) Material		HeadSkin;				// Skin for head
var(Character) Mesh			HeadMesh;				// Skin for mesh
var(Character) Vector		HeadScale;
var(Character) bool			bRandomizeHeadScale;	// Whether or not to slightly randomize the scale of the head
var BodyPart				myHead;					// Character's head

var(Character) Sound		NormalStepSound;
var(Character) bool			bIsFeminine;			// Whether character is feminie (female or gay)
var(Character) bool			bIsTrained;				// Whether character is trained to use weapons
var(Character) bool			bIsGhetto;				// Whether character walks like they're from the hood
var(Character) String		FirstPersonMeshPrefix;	// Prefix of first-person mesh to be used
var(Police)	   bool			bHasRadio;				// If this police type can use the radio (which 
													// keeps track of it headquarters is looking for the dude)
													// Only use this for Police and their descendants.													

// Animation states for motion
var Rotator					CombatRotationRate;		// You rotate more quickly while doing this

var bool					bProtesting;			// Animation for protesting with hands around sign and marching and all
var float					ProtestingPct;			// Percent of motion for movement when protesting. 0-1.
var bool					bMarching;				// Animation for marching with hands on an instrument
var float					MarchingPct;			// Percent of motion for movement when marching. 0-1.
var float					SingleGunWalkPct;		// gun out walk speed
var float					DoubleGunWalkPct;		// big gun out walk speed
var float					GhettoFemWalkPct;		// ghetto and feminine
var float					GhettoWalkPct;			// ghetto
var float					FemWalkPct;				// feminine
var bool					bLeftFoot;				// Lead with your left foot (defaults to lead with right foot)
var int						AnimGroupUsed;			// This is just used to consistently pick a different, random
													// animation group. For instance, some people will always walk
													// with one normal walk anim, while others will pick a different
													// just for variety. Set this to AnimGroupUsed=-1 in the default
													// properties and on startup, it will pick the basic one--so
													// Krotchy and Gary don't need all the crazy anims

// Bolt-ons are decorative (non-functional) meshes that are "bolted-on"
// (attached) to characters.  Boltons are set via default properties and
// can be overridden by LD's.
const MAX_BOLTONS			= 8;
struct SBoltOn
	{
	var() Name bone;								// Name of bone to attach to
	var() Mesh mesh;								// Mesh to use
	var() StaticMesh staticmesh;					// Static mesh to use
	var() Material skin;								// Skin to use (leave blank to use default skin)
	var() bool bCanDrop;							// Whether you can drop this (ex: you can drop your hat but not your head)
	var() bool bInActive;							// Whether or not you're actually using this--ATFAgents had trouble inheriting from
		// Police and *not* having badges--even when they had their static mesh part removed, so this was added.
	var() bool bAttachToHead;						// Whether or not this attaches to the head or the body
	// New 11/6/13
	var() float DrawScale;
	/*
	var() bool bUseDrawScale;
	var() vector DrawScale3D;
	var() bool bUseDrawScale3D;
	var() vector RelativeLocation;
	var() rotator RelativeRotation;
	*/
	var PeoplePart part;							// The actual bolton part
	};
var(Boltons) SBoltOn		boltons[MAX_BOLTONS];	// List of bolt-ons (decorative stuff)
var SBoltOn					TempBolton;				// Temporary bolton assigned for interest points and shit
var bool					bDroppedBoltons;		// Is set when boltons are dropped (so they'll only get dropped once)

enum CharEnum{
	CHARACTER_avgdude,
	CHARACTER_big,
	CHARACTER_fat,	
	CHARACTER_female,
	CHARACTER_mini,
	CHARACTER_krotchy,
};
var CharEnum				CharacterType;			// Type of character mesh (average male, female, etc)

var Actor					ExchangeActor;			// Visual representation of the pickup I'm handing 
													// someone or taking from someone

// Ragdoll related vars and enums
var float					DeathVelMag;			// Extra momentum given at death
var	array<Sound>			BodyHitSounds;			// Sounds played when the body hits the ground in ragdoll mode
var float					TimeBetweenPainSounds;	// Min time required between sound plays to play another sound
var float					LastBodyHitTime;		// Last time we played a sound for when a body hit hard.
var Rotator					PreRagdollRotation;		// Rotation we had just before dying (and then ragdolling)

// More character descriptors (added them after existing vars to avoid the adding-bool-before-existing-bools bug)
// Can be set in default properties or by chameleon at runtime.
var bool					bIsFat;
var bool					bIsTall;
//var bool					bIsFemale;				// This is already defined in Pawn.
var bool					bIsBlack;
var bool					bIsMexican;
var bool					bIsAsian;
var bool					bIsHindu;
var bool					bIsFanatic;
var bool					bIsGay;
var EGender					MyGender;				// Character's gender (alternative to the bIsFemale flag)
var ERace					MyRace;					// Character's race (alternative to the individual flags)
var EBody					MyBody;					// Character's body (alternative to the bIsFat flag)

var(Character) MeshAnimation	CoreMeshAnim;		// Core animations (used in addition to special animations)

var bool					bChameleon;				// Whether chameleon feature is enabled
var(Character) array<Name>	ChameleonSkins;			// Available chameleon body skins
var(Character) array<Name>	ChameleonMeshPkgs;		// Packages to search for meshes referenced by skins
var(Character) array<Name>	ChamelHeadSkins;		// Available chameleon head skins
var(Character) array<Name>	ChamelHeadMeshPkgs;		// Packages to search for meshes referenced by skins
var(Character) EGender		ChameleonGender;		// Allows choosing gender (defaults to any)
var Material LastSkin;								// Used to detect changes to skin in editor
var EGender					ChameleonOnlyHasGender;	// When not Gender_Any, it means chameleon only offers specified gender

var float					WeaponBlendTime;		// Blend time to use when switching weapons vs firing weapons
var globalconfig bool 		bNCClientRagdolls;

const MAX_UPWARD_MOMENTUM			= 15000;
const MAX_DOWNWARD_MOMENTUM			= -5000;
const MAX_XY_MOMENTUM				= 5000;
const MAX_EXPL_MOMENTUM				= 100000;

const RAND_MOVE_AROUND_RAGDOLL_HIT  = 100;

//const AFTER_DEATH_RATIO				= 0.75;
const THROW_VEL_RATIO_EXPL			= 0.009;
const THROW_VEL_RATIO				= 0.004;
const KARMA_DAMPEN_BLUDGEON_XY		= 0.5;
const KARMA_DAMPEN_BLUDGEON_Z		= 0.5;
const KARMA_DAMPEN_NON_EXPLOSION	= 0.5;
const KARMA_DAMPEN_SHOTGUN			= 0.5;
const BLUDGEON_RAND_MAG				= 10.0;
const RAGDOLL_Z_IS_FLOOR			= 0.8;

// Skeleton strings for ragdolls
const DUDE_SKEL				= 'Avg_Dude_Skel';
const FEM_SKEL				= 'Avg_Fem_Skel';
const FAT_SKEL				= 'Avg_Fat_Skel';
const MINI_SKEL				= 'Avg_Mini_Skel';
const BIG_SKEL				= 'Avg_Big_Skel';

// Don't fully understand channel usage yet, other than knowing that channels 2
// through 11 are used by the engine's movement code, which is where the
// commented-out values came from.  Channel's 4 through 7 roughly correspond
// to the values in the MovementAnims[] array.  See UpdateMovementAnimation().
const RESTINGPOSECHANNEL	= 0;
const FALLINGCHANNEL		= 1;

// Only use these two if bPhysicsAnimUpdate is off.
const RIGHTTURNCHANNEL_NO_PHYSICS	= 2;
const LEFTTURNCHANNEL_NO_PHYSICS	= 3;

const TAKEHITCHANNEL		= 12;
const WEAPONCHANNEL			= 13;
const HEADCHANNEL			= 14;
const EXCHANGEITEMCHANNEL	= 15;

// Bone names
const BONE_INVENTORY		= 'MALE01 r hand';
const BONE_HEAD				= 'MALE01 head';
const BONE_BLENDFIRING		= 'MALE01 spine1';
const BONE_BLENDTAKEHIT		= 'MALE01 spine2';
const BONE_NECK				= 'MALE01 neck';
const BONE_PELVIS			= 'MALE01 pelvis';
const BONE_TOP_SPINE		= 'MALE01 spine1';
const BONE_MID_SPINE		= 'MALE01 spine2';
const BONE_RTHIGH			= 'MALE01 r thigh';
const BONE_RCALF			= 'MALE01 r calf';
const BONE_RFOOT			= 'MALE01 r foot';

const BONE_LEFT_HAND		= 'MALE01 l hand';


const HEAD_HEIGHT_RATIO		= 0.75;
const TORSO_HEIGHT_RATIO	= 0.25;
const PELVIS_HEIGHT_RATIO	= 0.0;
const KNEE_HEIGHT_RATIO		= -0.25;
const FOOT_HEIGHT_RATIO		= -0.5;	


const CROTCH_OFFSET			= 0;
const CROTCH_SIZE			= 10;
const CROTCH_FRONT			= 0.8;

const KICK_DAMAGE_RADIUS	= 100;
const KICK_DAMAGE_IMPULSE	= 50000;
const KICK_DAMAGE_AMOUNT	= 8;

const FIRING_BLEND_TIME		= 0.05;
const SWITCH_WEAPON_BLEND_TIME = 0.1;
const BRING_UP_BLEND_TIME	= 0.0;
const BRING_UP_WEAPON_RATE	= 2.0;
const PUT_DOWN_WEAPON_RATE	= 1.5;

const HEAD_PERCENT			= 0.8;

const SUPER_FAST_RATE		= 50000;

const BURN_ACTION_MP		= 'BurnMe';
const FOLLOW_ME				= 'FollowMe';
const STAY_HERE				= 'StayHere';

// Kamek 4-30
// Tazed achievement
// Tag if they taze you so you don't give them extra points for getting tazed again
var bool bPlayerTazedMe;

// AW backport stuff
var bool bZombie;
var (PawnAttributes) bool  bLookForZombies;	// When thinking look around for zombies in your ReportLooksRadius
											// and decide what to do (fight or run) 
var (PawnAttributes) bool	bDogFriend;		// friend with dogs (most rednecks in AW are)
var bool bMissingLimbs;					// hands, arms, legs, anything missing, and it's true
var bool bMissingLegParts;				// Any legs are missing, it's true
var bool bMissingTopHalf;				// Your already dead, and your missing your top from the pelvis up
var bool bMissingBottomHalf;			// Your already dead, and your missing from your pelvis down
var vector StumpAdjust;	// Value to adjust stumps by
const BLOCK_MELEE_DOT		=	0.05;
var (PawnAttributes) float BlockMeleeTime;	// how long they try to block for
var (PawnAttributes) float BlockMeleeFreq;	// How often they will decide to block melee attacks 0.0 to 1.0
var(Cell) class<P2Weapon> CellPhoneClass;
var(Cell) bool bCellUser;
var(Cell) sound CellBeep;
var(Cell) sound CellRing;
var (PawnAttributes) bool bNoChamelBoltons;	// Don't assign boltons to this pawn

var array<Name> BoltonTagsUsed;

// Extra pawn attributes for chameleon plus
var (Boltons) bool bNoExtendedAnims;	// If we're assigned a briefcase or something heavy, don't make a lot of huge movements.
var (Boltons) editinline array<BoltonDef> RandomizedBoltons;
var name SpecialHoldWalkAnim;	// If non-null, indicates a special anim for holding our bolton
var name SpecialHoldStandAnim;
								// Do not set in actor properties. This gets set by the assigned bolton if needed.
								

var bool bHadThroatSlit;
var bool bSlomoDeath;					// Turn on slomotion for a few seconds to see them die cool

// Valentine Day crap
var bool bValentine;		// If true, do Valentines Day special hot-greetings
var int HoldingVase;		// If non-zero, indicates bolton slot where the vase is being held (so we can turn it off after giving it away)

// Halloween crap
var bool bHalloween;		// If true, wearing a Halloween costume (Dude makes special kill remark)

// Cigarette crap
var int HoldingCigarette;	// If non-zero, indicates bolton slot where we're holding a cigarette

// NEW PL footsteps
struct FootstepSound
{
	var() ESurfaceType SurfaceType;
	var() array<String> Sounds;
};
var(Footsteps) globalconfig array<FootstepSound> FootstepSounds;
var(Footsteps) globalconfig bool bDoFootsteps;
var Sound LastFootstepSound;
const FOOTSTEP_VOLUME_DEFAULT = 0.75;
const FOOTSTEP_RADIUS_DEFAULT = 64.0;
var(PawnAttributes) float IdleCellPct;		// Chance to use cell phone
var(PawnAttributes) float IdleFartPct;		// Chance to fart
var(PawnAttributes) float IdleSneezePct;	// Chance to sneeze

// Surface type tension
struct SurfaceTypeTension
{
	var() ESurfaceType SurfaceType;
	var() float GroundSpeedMult;
	var() float GroundFriction;
	var() float MaxFallMult;
};
var/*(Footsteps) globalconfig*/ array<SurfaceTypeTension> SurfaceTypeTensions;
var float GroundSpeedMax;	// Maximum value for ground speed allowed on the current terrain
var float GroundSpeedMult;	// So we can get the SonicBoom cheat working again

// Footprints!
struct Footprint
{
	var() ESurfaceType SurfaceType;
	var() class<SplatMaker> FootprintClassLeft, FootprintClassRight;
};
var array<Footprint> Footprints;
var bool bRightFoot;

const AXIS_MAX = 1800.0;
var(Character) bool bForbidRagdoll;	// If true, this pawn will not use ragdoll physics when dying

var bool bInitialSetup;	// Hack to not call LinkAnims twice
var bool bInitialDifficulty;	// Hack to not set up difficulty adjustment twice

// STUBS defined later in AWPerson
simulated function PlayCellIn();
simulated function PlayCellOut();
simulated function PlayCellOn();
simulated function PlayCellLoop();
simulated function float PlayIncomingCall();

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CheckBob(float DeltaTime, vector Y)
{
	local float Speed2D;

	if(P2Player(Controller) == None
		|| !P2Player(Controller).bWeaponBob)
    {
		BobTime = 0;
		WalkBob = Vect(0,0,0);
        return;
    }
	Bob = FClamp(Bob, -0.01, 0.01);
	if (Physics == PHYS_Walking )
	{
		Speed2D = VSize(Velocity);
		if ( Speed2D < 10 )
			BobTime += 0.2 * DeltaTime;
		else
			BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeedMax);
		WalkBob = Y * Bob * Speed2D * sin(8 * BobTime);
		AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
		WalkBob.Z = AppliedBob;
		if ( Speed2D > 10 )
			WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * sin(16 * BobTime);
		if ( LandBob > 0.01 )
		{
			AppliedBob += FMin(1, 16 * deltatime) * LandBob;
			LandBob *= (1 - 8*Deltatime);
		}
	}
	else if ( Physics == PHYS_Swimming )
	{
		Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
		WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
		WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
	}
	else
	{
		BobTime = 0;
		WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Surface type ground speed
///////////////////////////////////////////////////////////////////////////////
function SetGroundSpeedOn(ESurfaceType NewST)
{
	local int i;
	
	// Find listed surface type
	for (i = 0; i < SurfaceTypeTensions.Length; i++)
	{
		if (SurfaceTypeTensions[i].SurfaceType == NewST)
		{
			// Set new values based on these values.
			GroundSpeedMax = Default.GroundSpeed * GroundSpeedMult * SurfaceTypeTensions[i].GroundSpeedMult;
			GroundSpeed = GroundSpeedMax;
			WalkFriction = SurfaceTypeTensions[i].GroundFriction;
			return;
		}
	}
	
	// No match? No problem!
	GroundSpeedMax = Default.GroundSpeed * GroundSpeedMult;
	GroundSpeed = GroundSpeedMax;
	WalkFriction = Default.WalkFriction;
}

///////////////////////////////////////////////////////////////////////////////
// UpdateSurfaceType
// Updates our SurfaceType with what we're standing on.
// Don't play any footsteps or adjust speed, just set the new SurfaceType.
// Uses a Trace, so don't call too often.
///////////////////////////////////////////////////////////////////////////////
function UpdateSurfaceType()
{
	local vector TraceStart, TraceEnd, HitLocation, HitNormal;
	local Material OutMaterial;
	local Actor HitActor;
	
	// Find current surfacetype, try based actor first
	if (Base != None && LevelInfo(Base) == None && Base.SurfaceType != EST_Default)
	{
		SurfaceType = Base.SurfaceType;
		//log("Based on"@Base@"with SurfaceType"@SurfaceType);
	}
	// otherwise, do it the hard way, with a trace
	else
	{
		TraceStart = Location /*+ (Vect(0,0,1) * CollisionHeight)*/;
		TraceEnd = TraceStart - (Vect(0,0,2) * CollisionHeight);
		HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, , , OutMaterial);
		if (OutMaterial != None)
		{
			//log("Traced and hit Material"@OutMaterial@"with SurfaceType"@SurfaceType);
			SurfaceType = OutMaterial.SurfaceType;
		}
		else if (HitActor != None)
		{
			//log("Traced and hit no Material, defaulting to hitactor"@HitActor@"surfacetype"@HitActor.SurfaceType);
			SurfaceType = HitActor.SurfaceType;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Places a footprint in the snow, dirt, etc.
///////////////////////////////////////////////////////////////////////////////
function DrawFootprint(optional bool bJump)
{
	local class<SplatMaker> FootprintClass;
	local SplatMaker Spawned;
	local int i;
	
	// See if we want to drop down a footprint
	for (i = 0; i < Footprints.Length && Spawned == None; i++)
		if (Footprints[i].SurfaceType == SurfaceType)
		{
			// Pick the right splat maker for the foot we're stepping on
			if (Footprints[i].FootprintClassRight != None && (bRightFoot || bJump))
				Spawned = Spawn(Footprints[i].FootprintClassRight, Self,, Location, Rotation);
			if (Footprints[i].FootprintClassLeft != None && (!bRightFoot || bJump))
				Spawned = Spawn(Footprints[i].FootprintClassLeft, Self,, Location, Rotation);
			break;
		}
		
	if (Spawned != None && !bJump)
	{		
		// Switch feet for next step
		bRightFoot = !bRightFoot;
	}
}

///////////////////////////////////////////////////////////////////////////////
// New footstep code
///////////////////////////////////////////////////////////////////////////////
function PlayFootstep(optional float Volume, optional float Radius, optional float Pitch)
{
	local Vector HitLocation, HitNormal, TraceEnd, TraceStart;
	local Material OutMaterial;
	local Actor HitActor;
	local int i, j, UseIndex;
	local Sound UseSound;
	local class<SplatMaker> FootprintClass;
	
	// Move playercontroller check here, so other pawns aren't constantly updating
	if (bDoFootsteps
			&& PlayerController(Controller) != None)
	{
		UpdateSurfaceType();
		
		// find a matching sound
		for (i = 0; i < FootstepSounds.Length; i++)
			if (FootstepSounds[i].SurfaceType == SurfaceType)
			{
				// Don't use the same sound twice
				j = 0;
				while ((UseSound == None || UseSound == LastFootstepSound) && j++ < 100)
					UseSound = Sound(DynamicLoadObject(FootstepSounds[i].Sounds[Rand(FootstepSounds[i].Sounds.Length)], class'Sound'));
				LastFootstepSound = UseSound;
				break;
			}
			
		//log(self@"Playing footstep"@UseSound@"on surfacetype"@SurfaceType);
		// Set our new ground speed
		SetGroundSpeedOn(SurfaceType);
		
		// now play that bitch
		if (UseSound != None)
		{
			if (Volume == 0)
				Volume = FOOTSTEP_VOLUME_DEFAULT;
			if (Radius == 0)
				Radius = FOOTSTEP_RADIUS_DEFAULT;
			if (Pitch == 0)
				Pitch = GetRandPitch();
			PlaySound(UseSound,SLOT_Interact,Volume,,Radius,Pitch,,,True);
		}		
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function name GetAnimBlockMelee()
{
	return's_block';
}
simulated function PlayBlockMeleeAnim()
{
	//log(self$" play block melee");
	ChangePhysicsAnimUpdate(false);
	AnimBlendParams(EXCHANGEITEMCHANNEL, 1.0, 0,0);
	PlayAnim(GetAnimBlockMelee(), 1.0, 0.1, EXCHANGEITEMCHANNEL);
}
simulated function ContinueBlockAnim(int channel)
{
	if(channel == EXCHANGEITEMCHANNEL)
		PlayBlockMeleeAnim();
}
simulated function bool IsBlockChannel(int channel)
{
	return (channel == EXCHANGEITEMCHANNEL);
}
simulated function FinishBlockAnim()
{
	AnimEnd(EXCHANGEITEMCHANNEL); // Stop animating block
}

///////////////////////////////////////////////////////////////////////////////
// Someone is about to attack us with a big weapon! (like a sledge or scythe)
// Do something!
// Humans try to block, zombies use this and attack or run
///////////////////////////////////////////////////////////////////////////////
function BigWeaponAlert(P2MoCapPawn Swinger)
{
	//log(Self$" big weapon alert "$swinger);
	BlockMelee(Swinger);
}

///////////////////////////////////////////////////////////////////////////////
// Flying machete coming our way--check to block it!
///////////////////////////////////////////////////////////////////////////////
function BlockMelee(Actor MeleeAttacker)
{
	local vector Rot, dir;
	local float dot1;

	//log(self$" BlockMelee "$MeleeAttacker$" weapon "$weapon$" firing style "$P2Weapon(Weapon).GetFiringStyle());
	if(Health > 0					// alive
		&& !bDeleteMe				// not deleted
		&& bHasViolentWeapon		// can block with the weapon
		&& MyBodyFire == None		// not on fire
		&& !bIsCrouched				// not crouching
		&& !bIsDeathCrawling		// not crawling
		&& !bIsKnockedOut			// not knocked out
		&& FRand() < BlockMeleeFreq	// randomly decide to block or not
		&& P2Weapon(Weapon) != None	// has a weapon
		&& (P2Weapon(Weapon).GetFiringStyle() == WEAPONHOLDSTYLE_Both			// has a two-handed weapon
			|| P2Weapon(Weapon).GetFiringStyle() == WEAPONHOLDSTYLE_Double))
	{
		// Check now if you can see the actor to block against
		Rot = vector(Rotation);
		dir = MeleeAttacker.Location - Location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;
		//log(self$" check melee, dot "$dot1$" hit loc "$MeleeAttacker.Location);

		if(dot1 > BLOCK_MELEE_DOT)
		{
			if(PersonController(Controller) != None)
				PersonController(Controller).PerfomBlockMelee(MeleeAttacker);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//  If we can block this melee attack
///////////////////////////////////////////////////////////////////////////////
function CheckBlockMelee(vector HitLocation, out byte StateChange)
{
	local vector Rot, dir;
	local float dot1;

	//log(self$" check block melee "$controller$" state "$controller.getstatename());
	// Check to complete block the melee attack
	if(Controller != None
		&& !Controller.bDeleteMe
		&& Controller.IsInState('BlockMelee'))
	{
		//log(Self$" doing block ");
		// See if they are facing our direction enough to block the attack
		Rot = vector(Rotation);
		dir = HitLocation - Location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;
		//log(self$" block melee, dot "$dot1$" hit loc "$HitLocation);

		if(dot1 > BLOCK_MELEE_DOT)
		{
			if(PersonController(Controller) != None)
				PersonController(Controller).DidBlockMelee(StateChange);
		}
		//log(self$" after block state "$statechange);
	}
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
	local class<Inventory> TestClass;

	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	if (ClassIsChildOf(DamageType, class'ElectricalDamage')
		&& P2Player(InstigatedBy.Controller) != None)
	{
		//log(self@"electrical damage from"@InstigatedBy.Controller@"wearing"@P2Player(InstigatedBy.Controller).CurrentClothes,'Debug');
		// This may not work
		TestClass = class<Inventory>(DynamicLoadObject("Inventory.CopClothesInv",class'Class'));
		//log("comparing"@TestClass@"to"@P2Player(InstigatedBy.Controller).CurrentClothes,'Debug');
		if (P2Player(InstigatedBy.Controller).CurrentClothes == TestClass && !bPlayerTazedMe)
		{
			bPlayerTazedMe = true;
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(InstigatedBy.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(InstigatedBy.Controller),'BystandersTazed',1,true);		
		}
	}
	// If they took a nut shot, the controller might want to know
	if (Damage > 0
		&& WasCrotchHit(HitLocation, Momentum)
		&& PersonController(Controller) != None
		&& ClassIsChildOf(DamageType, class'KickingDamage'))
	{
		PersonController(Controller).TookNutShot(P2Pawn(InstigatedBy));
		// Tell the player if they did it
		if (P2Player(InstigatedBy.Controller) != None)
			P2Player(InstigatedBy.Controller).ScoredNutShot(Self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Determine if he's allowed to see the weapon fall, may have no legs, etc,
// then we wouldn't want him to go after it.
///////////////////////////////////////////////////////////////////////////////
function bool SeeWeaponDrop(P2WeaponPickup grabme)
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Certain weapons, like the sledge pickup, can fall and tell all zombies
// around it, about this, with the hopes that they will run and pick 
// it up. They won't then use it, they'll simply grab it from the player.
///////////////////////////////////////////////////////////////////////////////
function WeaponDropped(P2WeaponPickup grabme)
{
}

///////////////////////////////////////////////////////////////////////////////
// Very early setup
///////////////////////////////////////////////////////////////////////////////
simulated function PreBeginPlay()
	{
	local Chameleon cham;

	Super.PreBeginPlay();

	if(!bHasRef
		&& P2GameInfoSingle(Level.Game) != None
		&& Level.IsDemoBuild())
		{
		Destroy();
		}
	else
		{
		// Use the skin name to determine whether chameleon mode is enabled or not.
		if (Left(GetItemName(String(Skins[0])), 4) ~= "XX__")
			bChameleon = true;
		else
			bChameleon = false;

		// Here we update the new-style enums to match the old-style flags.
		// This is important for older, non-chameleon characters that only
		// set the flags in their default properties.
		MyGender = Gender_Male;
		if (bIsFemale)
			MyGender = Gender_Female;
		
		MyRace = Race_White;
		if (bIsBlack)
			MyRace = Race_Black;
		else if (bIsMexican)
			MyRace = Race_Mexican;
		else if (bIsAsian)
			MyRace = Race_Asian;
		else if (bIsHindu)
			MyRace = Race_Hindu;
		else if (bIsFanatic)
			MyRace = Race_Fanatic;
		else if (bIsAutomaton)
			MyRace = RACE_Automaton;

		MyBody = Body_Avg;
		if (bIsFat)
			MyBody = Body_Fat;

		// Register non-chameleon pawns' appearance so we can try to avoid
		// choosing the same appearances for chameleon pawns.
		if (!bChameleon && P2GameInfo(Level.Game) != None)
			{
			cham = P2GameInfo(Level.Game).GetChameleon();
			if (cham != None)
				cham.Register(self);
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Get ready
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
	{	
	// Turn on bInitialSetup. Check for bInitialSetup in LinkAnims so it doesn't get called twice
	bInitialSetup=true;
	SetupAppearance();
	SetupHead();
	SetupBoltons();
	// Now turn off bInitialSetup and link our animations
	bInitialSetup=false;
	SetupAnims();
	SetupDialog();
	SetupCollisionInfo();
	Super.PostBeginPlay();
	GroundSpeedMax = GroundSpeed;
	}

///////////////////////////////////////////////////////////////////////////////
// Clean up
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	DestroyHead();
	DestroyBoltons();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Called after a saved game has been loaded
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
	{
	LinkMeshAndAnims(Mesh);
	Super.PostLoadGame();
	PlayFootstep(0);	// hack for 1416 saves
	}

///////////////////////////////////////////////////////////////////////////////
// Called by editor when something has changed
///////////////////////////////////////////////////////////////////////////////
event PostEditChange()
	{
	// If there is no skin it probably means the user cleared it in the editor,
	// which is taken to mean "restore the default skin".  The default will be
	// be either a chameleon skin or a specific skin, depending on the class.
	if (Skins[0] == None)
		{
		// Make sure a default skin was assigned
		if (default.Skins[0] == None)
			Warn("Missing default value for Skins[0] for "$self);
		SetMySkin(default.Skins[0]);
		EditorSkinChange();
		}

	// Check if the skin has been changed.  Note that LastSkin == None means
	// this function is being called for the first time for this pawn, which
	// means this is the first change being made to this pawn, which is why
	// we can compare the current skin to the default skin and get a
	// meaningful result.  On subsequent calls we always compare the current
	// skin to LastSkin.
	if ((LastSkin == None && Skins[0] != default.Skins[0]) ||
		(LastSkin != None && Skins[0] != LastSkin))
		{
		EditorSkinChange();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Skin was changed in the editor
///////////////////////////////////////////////////////////////////////////////
function EditorSkinChange()
	{
	local class<Chameleon> cham;

	// Tell chameleon class to update this pawn based on the new skin
	cham = class<Chameleon>(DynamicLoadObject("Postal2Game.Chameleon", class'Class'));
	cham.static.UseCurrentSkin(self);

	LastSkin = Skins[0];
	}

///////////////////////////////////////////////////////////////////////////////
// Set this pawn's skin
///////////////////////////////////////////////////////////////////////////////
simulated function SetMySkin(Material NewSkin)
	{
	Skins[0] = NewSkin;
	}

///////////////////////////////////////////////////////////////////////////////
// Set this pawn's mesh
///////////////////////////////////////////////////////////////////////////////
simulated function SetMyMesh(Mesh NewMesh, optional Mesh NewCoreMesh, optional bool bKeepAnimState)
	{
	if (NewMesh != Mesh)
		LinkMeshAndAnims(NewMesh, bKeepAnimState);
	}

///////////////////////////////////////////////////////////////////////////////
// Link this pawn to the mesh and anims it needs
///////////////////////////////////////////////////////////////////////////////
simulated function LinkMeshAndAnims(Mesh NewMesh, optional bool bKeepAnimState)
	{
	bInitializeAnimation = false;
	LinkMesh(NewMesh, bKeepAnimState);
	LinkAnims();
	}

///////////////////////////////////////////////////////////////////////////////
// Link this pawn to the anims it needs
///////////////////////////////////////////////////////////////////////////////
simulated function LinkAnims()
	{
	// Ignore if we're still setting up in the chameleon
	if (bInitialSetup)
		return;
	// Always link to mesh's default anim (as set in the editor)
	LinkSkelAnim(GetDefaultAnim(SkeletalMesh(Mesh)));

	// Always link to the core anims, too, because some characters use a mixture
	// of their own anims plus some core anims.  Linking to core anims twice,
	// which can happen if default anims happen to match core anims, is safe.
	LinkSkelAnim(CoreMeshAnim);
	}

///////////////////////////////////////////////////////////////////////////////
// Setup head
///////////////////////////////////////////////////////////////////////////////
function SetupHead()
	{
	local ChamelHead cham;

	if (P2GameInfo(Level.Game) != None)
		{
		cham = P2GameInfo(Level.Game).GetChamelHead();
		if (cham != None)
			{
			// If no skin is specified then we generate a random head, regardless of
			// whether the mesh was specified or not.
			if (HeadSkin == None)
				{
				// Pick a head that matches my gender, race and body
				cham.Pick(self, MyGender, MyRace, MyBody);
				}
			else
				{
				// A skin was specified so we will use it.  If no mesh was specified
				// then we'll figure out the correct mesh to use based on the skin.
				// Otherwise, we use whatever mesh was specified and hope the user
				// knows what they are doing.
				if (HeadMesh == None)
					HeadMesh = cham.GetRelatedMesh(self, HeadSkin);
				}
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Change head scale
///////////////////////////////////////////////////////////////////////////////
simulated function SetHeadScale(float NewScale)
{
	if (myHead != None)
		myHead.SetScale(NewScale);
}

///////////////////////////////////////////////////////////////////////////////
// Remove the head and destroy it
///////////////////////////////////////////////////////////////////////////////
simulated function DestroyHead()
{
	if(myHead != None)
	{
		// Dissociate head and destroy it
		DissociateHead(true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Separate the head from the body and optionally destroy it
///////////////////////////////////////////////////////////////////////////////
simulated function DissociateHead(bool bDestroyHead)
{
	// STUB --fill out in personpawn.
}

///////////////////////////////////////////////////////////////////////////////
// Show the movement anims
///////////////////////////////////////////////////////////////////////////////
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);

	Canvas.DrawText("movement anims 0:"$MovementAnims[0]$", 1:"$MovementAnims[1]$", 2:"$MovementAnims[2]$", 3:"$MovementAnims[3]);
	YPos += YL;
}
		 		
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool IsAMinority()
{
	if(bIsBlack 
		|| bIsHindu
		|| bIsMexican
		|| bIsAsian)
		return true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// ShouldCrouch()
//Controller is requesting that pawn crouch
///////////////////////////////////////////////////////////////////////////////
function ShouldCrouch(bool Crouch)
{
	Super.ShouldCrouch(Crouch);
}

///////////////////////////////////////////////////////////////////////////////
// Perform protesting motion
///////////////////////////////////////////////////////////////////////////////
function SetProtesting(bool bSet)
{
	if(bProtesting != bSet)
	{
		bProtesting=bSet;
		ChangeAnimation();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Perform marching motion
///////////////////////////////////////////////////////////////////////////////
function SetMarching(bool bSet)
{
	if(bMarching != bSet)
	{
		bMarching=bSet;
		ChangeAnimation();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Setup just this bolton
///////////////////////////////////////////////////////////////////////////////
function SetupBolton(int i)
{
	local Emitter CigaretteSmoke;
	
	if(!boltons[i].bInActive)
		{

		// check for draw types
		if (boltons[i].mesh != None)
			{
			boltons[i].part = spawn(class 'BoltonPart');
			boltons[i].part.LinkMesh(boltons[i].mesh);
			}
		else if (boltons[i].staticmesh != None)
			{
			boltons[i].part = spawn(class 'BoltonPart');
			boltons[i].part.SetStaticMesh(boltons[i].staticmesh);
			boltons[i].part.SetDrawType(DT_StaticMesh);				
			//log(self@"spawned bolton part"@boltons[i].part@"staticmesh"@boltons[i].staticmesh,'Debug');
			}

		// If skin is specified then use it (otherwise use default skin)
		if (boltons[i].skin != None)
			boltons[i].part.Skins[0] = boltons[i].skin;
			
		// If we made a part, attach it
		if(boltons[i].part != None)
			{
			// Use inventory bone if no specific bone was specified
			if (boltons[i].bone == '')
				boltons[i].bone = BONE_INVENTORY;

			// Check it goes on the head or the pawn
			//log("attaches to head?"@boltons[i].battachtohead,'Debug');
			if(boltons[i].bAttachToHead
				|| boltons[i].bone == 'NODE_Parent')	// For now, assume anything that bolts on to NODE_Parent is a head bolton.
				MyHead.AttachToBone(boltons[i].part, boltons[i].bone);
			else
				AttachToBone(boltons[i].part, boltons[i].bone);
				
			//log("attached bolton to"@boltons[i].bone@"...or did it?",'Debug');
				
			if (boltons[i].DrawScale != 0)
			{
				//log(self@"setting boltons"@i@"draw scale"@Boltons[i].DrawScale,'Debug');
				boltons[i].part.SetDrawScale(boltons[i].DrawScale);
			}
			boltons[i].part.AmbientGlow = AmbientGlow;
	
			/*
			// If they specified a draw scale, relative location, or relative rotation, set it now
			if (boltons[i].bUseDrawScale)
			{
				log(self@"setting boltons"@i@"draw scale"@Boltons[i].DrawScale,'Debug');
				boltons[i].part.SetDrawScale(boltons[i].DrawScale);
			}
			if (boltons[i].bUseDrawScale3D)
			{
				log(self@"setting boltons"@i@"draw scale 3d"@Boltons[i].DrawScale3D,'Debug');
				boltons[i].part.SetDrawScale3D(boltons[i].DrawScale3D);
			}
			// These default to 0 so no problem just setting these anyway.
			log(self@"setting boltons"@i@"loc rot"@boltons[i].RelativeLocation@boltons[i].RelativeRotation,'Debug');
			boltons[i].part.SetRelativeLocation(boltons[i].RelativeLocation);
			boltons[i].part.SetRelativeRotation(boltons[i].RelativeRotation);
			*/
			
			// If this was a cigarette bolton, spawn some smoke to go with it
			if (HoldingCigarette == i)
			{
				CigaretteSmoke = spawn(class'CigaretteSmoke',,,Location);
				Boltons[i].Part.AttachToBone(CigaretteSmoke, 'cig_end');
			}
			}
		}
}

///////////////////////////////////////////////////////////////////////////////
// Setup and destroy bolt-ons (decorative non-functional stuff)
///////////////////////////////////////////////////////////////////////////////
function SetupBoltons()
	{
	local int i;

	for (i = 0; i < MAX_BOLTONS; i++)
		{
			SetupBolton(i);
		}
	}
///////////////////////////////////////////////////////////////////////////////
// Setup and destroy bolt-ons (decorative non-functional stuff)
///////////////////////////////////////////////////////////////////////////////
function SetupTempBolton()
{
	local int i;

	if(!TempBolton.bInActive
		&& TempBolton.part == None)
		{

		// check for draw types
		if (TempBolton.mesh != None)
			{
			TempBolton.part = spawn(class 'BoltonPart');
			TempBolton.part.LinkMesh(TempBolton.mesh);
			}
		else if (TempBolton.staticmesh != None)
			{
			TempBolton.part = spawn(class 'BoltonPart');
			TempBolton.part.SetStaticMesh(TempBolton.staticmesh);
			TempBolton.part.SetDrawType(DT_StaticMesh);				
			//log(self@"spawned bolton part"@TempBolton.part@"staticmesh"@TempBolton.staticmesh,'Debug');
			}

		// If skin is specified then use it (otherwise use default skin)
		if (TempBolton.skin != None)
			TempBolton.part.Skins[0] = TempBolton.skin;
			
		// If we made a part, attach it
		if(TempBolton.part != None)
			{
			// Use inventory bone if no specific bone was specified
			if (TempBolton.bone == '')
				TempBolton.bone = BONE_INVENTORY;

			// Check it goes on the head or the pawn
			//log("attaches to head?"@TempBolton.battachtohead,'Debug');
			if(TempBolton.bAttachToHead
				|| TempBolton.bone == 'NODE_Parent')	// For now, assume anything that bolts on to NODE_Parent is a head bolton.
				MyHead.AttachToBone(TempBolton.part, TempBolton.bone);
			else
				AttachToBone(TempBolton.part, TempBolton.bone);
				
			//log("attached bolton to"@TempBolton.bone@"...or did it?",'Debug');
				
			if (TempBolton.DrawScale != 0)
			{
				//log(self@"setting boltons"@i@"draw scale"@TempBolton.DrawScale,'Debug');
				TempBolton.part.SetDrawScale(TempBolton.DrawScale);
			}
			TempBolton.part.AmbientGlow = AmbientGlow;
	
			/*
			// If they specified a draw scale, relative location, or relative rotation, set it now
			if (TempBolton.bUseDrawScale)
			{
				log(self@"setting boltons"@i@"draw scale"@TempBolton.DrawScale,'Debug');
				TempBolton.part.SetDrawScale(TempBolton.DrawScale);
			}
			if (TempBolton.bUseDrawScale3D)
			{
				log(self@"setting boltons"@i@"draw scale 3d"@TempBolton.DrawScale3D,'Debug');
				TempBolton.part.SetDrawScale3D(TempBolton.DrawScale3D);
			}
			// These default to 0 so no problem just setting these anyway.
			log(self@"setting boltons"@i@"loc rot"@TempBolton.RelativeLocation@TempBolton.RelativeRotation,'Debug');
			TempBolton.part.SetRelativeLocation(TempBolton.RelativeLocation);
			TempBolton.part.SetRelativeRotation(TempBolton.RelativeRotation);
			*/
			}
		}
}

///////////////////////////////////////////////////////////////////////////////
// Count up the bolt-ons
///////////////////////////////////////////////////////////////////////////////
function int CountBoltons()
{
	local int i, count;

	// Count up our bolt-ons
	for (i = 0; i < MAX_BOLTONS; i++)
	{
		if (boltons[i].mesh != None)
			count++;
		else if (boltons[i].staticmesh != None)
			count++;
	}
	return count;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure to remove any boltons from my head
///////////////////////////////////////////////////////////////////////////////
function DestroyHeadBoltons()
{
	local int i;

	if(MyHead != None)
	{
		for (i = 0; i < MAX_BOLTONS; i++)
		{
			if (boltons[i].part != None
				&& boltons[i].bAttachToHead)
			{
				MyHead.DetachFromBone(boltons[i].part);
				boltons[i].part.Destroy();
				// dissociate from pawn
				boltons[i].part = None;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Drop any bolt-ons that can be dropped
// Simply dissociates them and turns on their physics
///////////////////////////////////////////////////////////////////////////////
function DropBoltons(vector Momentum)
{
	local int i;

	// Don't try to drop them again
	if(bDroppedBoltons)
		return;

	// Mark that we're dropping them now
	bDroppedBoltons=true;
	
	// Set that we can use all our anims again
	bNoExtendedAnims=false;
	
	// Set that we no longer have a vase to hold
	bValentine=false;
	if (HoldingVase >= 0)
	{
		HoldingVase=-1;
		SpecialHoldWalkAnim='';
		SetAnimWalking();
	}
	
	// Set that we dropped our cigarette
	if (HoldingCigarette >= 0)
	{
		HoldingCigarette = -1;
		SpecialHoldWalkAnim='';
		SetAnimWalking();
	}
	
	// If we have some other special anim, kill it now
	if (SpecialHoldWalkAnim != '')
	{
		SpecialHoldWalkAnim = '';
		SpecialHoldStandAnim = '';
		SetAnimWalking();
	}

	for (i = 0; i < MAX_BOLTONS; i++)
	{
		if (boltons[i].part != None
			&& boltons[i].bCanDrop)
		{
			// pull it off the pawn/head
			if(boltons[i].bAttachToHead)
				MyHead.DetachFromBone(boltons[i].part);
			else
				DetachFromBone(boltons[i].part);
			// turn on physics
			boltons[i].part.GiveMomentum(Momentum);
			// kill it soon
			boltons[i].part.LifeSpan=1;
			// dissociate from pawn
			boltons[i].part = None;
		}
	}
	if (TempBolton.part != None)
	{
		// pull it off the pawn/head
		if(TempBolton.bAttachToHead)
			MyHead.DetachFromBone(TempBolton.part);
		else
			DetachFromBone(TempBolton.part);
		// turn on physics
		TempBolton.part.GiveMomentum(Momentum);
		// kill it soon
		TempBolton.part.LifeSpan=1;
		// dissociate from pawn
		TempBolton.part = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Destroy just one bolton
///////////////////////////////////////////////////////////////////////////////
function DestroyBolton(int DestroyThis)
	{
	local int i;

	if (boltons[DestroyThis].part != None)
		{
		boltons[DestroyThis].part.Destroy();
		boltons[DestroyThis].part = None;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Destroy just one bolton
///////////////////////////////////////////////////////////////////////////////
function DestroyTempBolton()
	{
	local int i;

	if (TempBolton.part != None)
		{
		TempBolton.part.Destroy();
		TempBolton.part = None;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Destroy them all
///////////////////////////////////////////////////////////////////////////////
function DestroyBoltons()
	{
	local int i;

	for (i = 0; i < MAX_BOLTONS; i++)
		{
		if (boltons[i].part != None)
			{
			boltons[i].part.Destroy();
			boltons[i].part = None;
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// PawnSpawner sets some things for you
// The spawer can set the skin of the thing spawned. If they set a specific
// skin, then make sure we go through and set all the gender/race attributes
// associated with this specific skin. Reinit the head once we got the new
// skin.
///////////////////////////////////////////////////////////////////////////////
function InitBySpawner(PawnSpawner initsp)
{
	local Chameleon cham;

	Super.InitBySpawner(initsp);

	if (P2GameInfo(Level.Game) != None
		&& initsp.SpawnSkin != None)
	{
		cham = P2GameInfo(Level.Game).GetChameleon();
		if (cham != None)
		{
			cham.UseCurrentSkin(self);
			// Head skin go set before, so clear here, so the new, spawned skin
			// can take over
			HeadSkin = None;
			SetupHead();
			// Redo the dialog to match new skin (clear to make sure it sets it)
			DialogClass=None;
			SetupDialog();
		}
	}
	/*
	if(initsp.InitDialogClass != None)
	{
		DialogClass = initsp.InitDialogClass;
		SetupDialog();
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Setup appearance
///////////////////////////////////////////////////////////////////////////////
function SetupAppearance()
	{
	local Chameleon cham;

	// If chameleon feature is enabled then pick a random appearance
	if (P2GameInfo(Level.Game) != None)
		{
		cham = P2GameInfo(Level.Game).GetChameleon();
		if (cham != None)
			{
				if (bChameleon)
					cham.Pick(self, ChameleonGender);
				// Whether or not we use the chameleon, call ExtraSetup on it anyway to assign boltons, racial dialog etc.
				cham.ExtraSetup(self);
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Setup dialog
///////////////////////////////////////////////////////////////////////////////
function SetupDialog()
	{
	SetDialogClass();

	// Voice pitches were already setup by super class but we change it here based on
	// various human-specific attributes.  Note: Pitch is not linear!  It ranges from
	// 0.5 (half) to 2.0 (double) so the min/max values aren't equal offsets from 1.0.
	if (bStartupRandomization)
		{
		if (bIsFemale)
			RandomizeAttribute(VoicePitch, RAND_ATTRIBUTE_DEFAULT, 1.10, 0.85);	// full range
		else if (bIsGay)
			RandomizeAttribute(VoicePitch, RAND_ATTRIBUTE_DEFAULT, 1.10, 1.03);	// high range
		else if (bIsFat || bIsBlack)
			RandomizeAttribute(VoicePitch, RAND_ATTRIBUTE_DEFAULT, 0.9, 0.8);	// low range
		else
			RandomizeAttribute(VoicePitch, RAND_ATTRIBUTE_DEFAULT, 1.03, 0.9);	// mid range
		}

	if (P2GameInfo(Level.Game) != None)
		{
		myDialog = P2GameInfo(Level.Game).GetDialogObj(String(DialogClass));
		if (myDialog == None)
			Warn("Couldn't load dialog: "$String(DialogClass));
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Set dialog class.  Dialog class can be set via default properties in
// which case the extended class doesn't need to define this function.
///////////////////////////////////////////////////////////////////////////////
function SetDialogClass()
	{
	// STUB
	}

///////////////////////////////////////////////////////////////////////////////
// Setup collision info based on the skeleton being used by this character.
///////////////////////////////////////////////////////////////////////////////
function SetupCollisionInfo()
	{
/*
	local string str;

	// The size of the collision cylinder is based on the skeleton.  All of our
	// mesh names start with the name of the skeleton.
	//
	// It would be nice if this could be setup as part of the mesh data
	// but I don't think it can, so this seemed to be the least error-prone
	// way to ensure all characters are using the proper collision size.
	str = GetItemName(String(Mesh));
	if (Left(str, 3) ~= "Avg")
		{
		//SetCollisionSize(28.0, 70.0);
		CharacterType = CHARACTER_avgdude;
		}
	else if (Left(str, 3) ~= "Big")
		{
		//SetCollisionSize(34.0, 80.0);
		CharacterType = CHARACTER_big;
		}
	else if (Left(str, 3) ~= "Fat")
		{
		//SetCollisionSize(34.0, 64.0);
		CharacterType = CHARACTER_fat;
		}
	else if (Left(str, 3) ~= "Fem")
		{
		//SetCollisionSize(26.0, 70.0);
		CharacterType = CHARACTER_female;
		}
	else if (Left(str, 4) ~= "Mini")
		{
		//SetCollisionSize(28.0, 70.0);
		CharacterType = CHARACTER_mini;
		}
	else if (Left(str, 7) ~= "Krotchy")
		{
		//SetCollisionSize(34.0, 70.0);
		CharacterType = CHARACTER_krotchy;
		}
	else
		{
		//SetCollisionSize(34.0, 78.0);
		Warn("SetupCollisionInfo(): WARNING! Using defaults for unrecognized mesh: "$str);
		}

	//log(self$" my mesh string "$str$" my collision radius "$CollisionRadius$" my collision height "$CollisionHeight);
*/
	}

// Just changed to pendingWeapon
function ChangedWeapon()
{
	local Weapon OldWeapon;
	local P2DualWieldWeapon DualWeap;

	//log(self$" new begin changed weapon "$Weapon$" pending "$PendingWeapon);
	OldWeapon = Weapon;

	if (Weapon == PendingWeapon)
	{
		if ( Weapon == None )
		{
			Controller.SwitchToBestWeapon();
			return;
		}
		else if ( Weapon.IsInState('DownWeapon') ) 
			Weapon.GotoState('Idle');
		PendingWeapon = None;
		ServerChangedWeapon(OldWeapon, Weapon);
		return;
	}
	if ( PendingWeapon == None )
		PendingWeapon = Weapon;
		
	Weapon = PendingWeapon;
	if ( (Weapon != None) && (Level.NetMode == NM_Client) )
	{
		Weapon.BringUp();
		
		// weapon code handles this now in BringUp()
		//DualWeap = P2DualWieldWeapon(Weapon);
	
		//if (DualWeap != none && DualWeap.bDualWielding && DualWeap.LeftWeapon != none)
			//DualWeap.LeftWeapon.AttachToPawn(self);
	}
	PendingWeapon = None;
	Weapon.Instigator = self;
	ServerChangedWeapon(OldWeapon, Weapon);

	if ( Controller != None )
		Controller.ChangedWeapon();
}

function ServerChangedWeapon(Weapon OldWeapon, Weapon W)
{
	local P2DualWieldWeapon DualWeap;
	
	/*
	if ( OldWeapon != Weapon )
	{
		log(self$" called PutDown on "$OldWeapon);
		if(OldWeapon != None)
			OldWeapon.PutDown();
	}
*/
	
	// weapon code handles this...
	/*
	DualWeap = P2DualWieldWeapon(OldWeapon);	
	
	if (DualWeap != none && DualWeap.bDualWielding && DualWeap.LeftWeapon != none)
	    DualWeap.LeftWeapon.DetachFromPawn(self);
	*/
	
	if ( OldWeapon != None )
	{
		OldWeapon.SetDefaultDisplayProperties();
		OldWeapon.DetachFromPawn(self);		
	}
	Weapon = W;
	if ( Weapon == None )
		return;

	if ( Weapon != None )
	{
		//log("ServerChangedWeapon: Attaching Weapon to actor bone.");
		Weapon.AttachToPawn(self);
	}

	Weapon.SetRelativeLocation(Weapon.Default.RelativeLocation);
	Weapon.SetRelativeRotation(Weapon.Default.RelativeRotation);

	Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)

	if ( OldWeapon == Weapon )
	{
		if ( Weapon.IsInState('DownWeapon') ) 
		{
			Weapon.BringUp();
			
			DualWeap = P2DualWieldWeapon(Weapon);
	
			if (DualWeap != none && DualWeap.bDualWielding && DualWeap.LeftWeapon != none)
				DualWeap.LeftWeapon.AttachToPawn(self);
		}
	}
	else
	{
		// if we don't check for down here, it may try to bring them up twice
		if(OldWeapon != None
			&& !Weapon.IsInState('DownWeapon'))
			OldWeapon.PutDown();

		if ( Level.Game != None )
			MakeNoise(0.1 * Level.Game.GameDifficulty);		

		PlayWeaponSwitch(W);

		Weapon.BringUp();
		
		DualWeap = P2DualWieldWeapon(Weapon);
	
		if (DualWeap != none && DualWeap.bDualWielding && DualWeap.LeftWeapon != none)
			DualWeap.LeftWeapon.AttachToPawn(self);
	}

	// Set mood here so for MP we handle it on the server and mood
	// gets replicated to client properly.
	if(P2Weapon(Weapon).ViolenceRank > 0)
	{
		SetMood(MOOD_Combat, 1.0);
	}
	else
	{
		SetMood(MOOD_Normal, 1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Override super class to return proper bone for weapon attachments.
///////////////////////////////////////////////////////////////////////////////
function name GetWeaponBoneFor(Inventory I)
{
	if (P2DualWieldWeapon(I) != none &&
		P2DualWieldWeapon(I).RightWeapon != none)
		return BONE_LEFT_HAND;
	else
		return BONE_INVENTORY;
	
	return '';
}

///////////////////////////////////////////////////////////////////////////////
// Get the style with which to hold/switch/fire the current weapon.
//
// Returns WEAPONHOLDSTYLE_None if there isn't a current weapon.
//
// Be aware that WEAPONHOLDSTYLE_None is a valid way to hold certain weapons
// (like handcuffs) so it doesn't necessarily mean there isn't any weapon!
///////////////////////////////////////////////////////////////////////////////
simulated function EWeaponHoldStyle GetWeaponHoldStyle()
	{
	if (Weapon != None)
		return P2Weapon(Weapon).GetHoldStyle();
	else if(MyWeapAttach != None)
		return MyWeapAttach.GetHoldStyle();
	return WEAPONHOLDSTYLE_None;
	}
simulated function EWeaponHoldStyle GetWeaponSwitchStyle()
	{
	if (Weapon != None)
		return P2Weapon(Weapon).GetSwitchStyle();
	else if(MyWeapAttach != None)
		return MyWeapAttach.GetSwitchStyle();
	return WEAPONHOLDSTYLE_None;
	}
simulated function EWeaponHoldStyle GetWeaponFiringStyle()
	{
	if (Weapon != None)
		return P2Weapon(Weapon).GetFiringStyle();
	else if(MyWeapAttach != None)
		return MyWeapAttach.GetFiringStyle();
	return WEAPONHOLDSTYLE_None;
	}

///////////////////////////////////////////////////////////////////////////////
// If you're switching physics anims back and forth, null out the turning
// channels.
///////////////////////////////////////////////////////////////////////////////
function ChangePhysicsAnimUpdate(bool bNewUpdate)
{
	if(bPhysicsAnimUpdate != bNewUpdate)
	{
		bPhysicsAnimUpdate=bNewUpdate;
		if(bPhysicsAnimUpdate)	// turn back on
		{
			AnimBlendToAlpha(RIGHTTURNCHANNEL_NO_PHYSICS,1.0,0.1);
			AnimBlendToAlpha(LEFTTURNCHANNEL_NO_PHYSICS,1.0,0.1);
		}
		else	// turn them off
		{
			AnimBlendToAlpha(RIGHTTURNCHANNEL_NO_PHYSICS,0,0.1);
			AnimBlendToAlpha(LEFTTURNCHANNEL_NO_PHYSICS,0,0.1);
		}
		if(bPhysicsAnimUpdate)
			ChangeAnimation();
	}
}

///////////////////////////////////////////////////////////////////////////////
// This is called whenever anything that might effect the animation has
// changed (physics, accelleration, status, weapons, etc.)
///////////////////////////////////////////////////////////////////////////////
simulated event ChangeAnimation()
	{
	// Make sure controller doesn't want to control animations
	if (!((Controller != None) && Controller.bControlAnimations))
		{
		// Setup new waiting and moving animations.  It's lame setting them up
		// this way, but it's how they did it, so we're folling along.
		PlayWaiting();
		PlayMoving();
// Leave this removed so you can let AnimEnd finish the blend
		// If not falling, don't blend with falling animation
//		if ( Physics != PHYS_Falling )
//			AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
		}
	}


///////////////////////////////////////////////////////////////////////////////
//
// These functions are called by the pawn or the controller to request general
// types of animations: stand, walk, crouch, shoot, jump, get hit and so on.
//
// Many of these are defined by the engine, while others have been added
// specifically for this game.
//
// Each of these functions should be written to figure out which SetAnimXXXXX
// function should be called, and then to call it.  They shouldn't be directly
// setting up any animations.  They take care of the "higher level" logic and
// leave the details to the SetAnimXXXXX group.
// 
///////////////////////////////////////////////////////////////////////////////

simulated function PlayWaiting()
	{
	if ( Physics == PHYS_Swimming )
		SetAnimTreading();
	else if ( Physics == PHYS_Flying )
		SetAnimFlying();
	else if ( Physics == PHYS_Ladder )
		SetAnimStoppedOnLadder();
	else if ( Physics == PHYS_Falling 
		&& !IsInState('Dying'))
		{
		if ( !IsAnimating(FALLINGCHANNEL) )
			PlayFalling();
		}
	else if ( bMarching )
		SetAnimMarching();
	else if ( bProtesting )
		SetAnimProtesting();
	else if (bIsKnockedOut)
		PlayKnockedOutAnim();
	else if ( bIsDeathCrawling )
		SetAnimDeathCrawlWait();
	else if ( bIsCrouched )
		SetAnimCrouching();
	else if ( bIsCowering )
		PlayCoweringInBallAnim();
//	else if ( bSteadyFiring )
//		PlayFiring(1.0,'');
	else
		SetAnimStanding();
	}

// Stub - not used by AI
simulated function PlayWalking(bool bWalk);

simulated function PlayMoving()
	{
	if ((Physics == PHYS_None) || ((Controller != None) && Controller.bPreparingMove) )
		{
		// Controller is preparing move - not really moving
		PlayWaiting();
		}
	else
		{
		if ( Physics == PHYS_Walking )
			{
			if ( bMarching )
				SetAnimMarching();
			else if ( bProtesting )
				SetAnimProtesting();
			else if (bIsKnockedOut)
				PlayKnockedOutAnim();
			else if ( bIsDeathCrawling )
				SetAnimDeathCrawling();
			else if ( bIsCrouched )
				SetAnimCrouchWalking();
			else if ( bIsWalking )
				SetAnimWalking();
			else
				SetAnimRunning();
			}
		else if ( Physics == PHYS_Swimming )
			SetAnimSwimming();
		else if ( Physics == PHYS_Ladder )
			SetAnimClimbing();
		else if ( Physics == PHYS_Flying )
			SetAnimFlying();
		else
			{
			if ( bMarching )
				SetAnimMarching();
			else if ( bProtesting )
				SetAnimProtesting();
			else if (bIsKnockedOut)
				PlayKnockedOutAnim();
			else if ( bIsDeathCrawling )
				SetAnimDeathCrawling();
			else if ( bIsCrouched )
				SetAnimCrouchWalking();
			else if ( bIsCowering )
				PlayCoweringInBallAnim();
			else if ( bIsWalking )
				SetAnimWalking();
			else
				SetAnimRunning();
			}
		}
	}


event StartCrouch(float HeightAdjust)
	{
	Super.StartCrouch(HeightAdjust);
	SetAnimStartCrouching();
	}


event EndCrouch(float HeightAdjust)
	{
	Super.EndCrouch(HeightAdjust);
	SetAnimEndCrouching();
	}

//
// Last time I checked, SetBoneDirection WASN'T working properly.. if you just get the 
// rotation and then set it in the direction, it doesn't work.
// To start calling this again, change it in FPSPawn.cpp
// Epic does this with UpdateRotation in their player controller, but we want it for
// all characters, check 927 code to see how
event RotateTowards(Actor Focus, Vector FocalPoint)
{
	local vector LookLoc;
	local Rotator newrot, NeckRot;

	if(Focus == None)
		LookLoc = FocalPoint;
	else
		LookLoc = Focus.Location;

	NeckRot = GetBoneRotation(BONE_NECK);

	//newrot = Rotator(Normal(LookLoc - Location));
	//NeckRot += newrot;

//	NeckRot.Pitch = NeckRot.Pitch & 65535;
//	NeckRot.Yaw = NeckRot.Yaw & 65535;
//	NeckRot.Roll = NeckRot.Roll & 65535;

	//NeckRot.Yaw = newrot.Yaw;
	//NeckRot.Pitch = Clamp(newrot.Pitch & 65535, -8192, 8192);
	SetBoneDirection( BONE_NECK, NeckRot);

/*
	newrot = Rotator(Normal(LookLoc - Location));
	newrot.Pitch -= Rotation.Pitch;
	newrot.Yaw -= Rotation.Yaw;
	newrot.Roll -= Rotation.Roll;

//	newrot.Pitch += 0;
	newrot.Pitch = newRot.Pitch & 65535;
	newrot.Yaw += -16384;
	newrot.Yaw = newRot.Yaw & 65535;
	newrot.Roll += 16384;
	newrot.Roll = newRot.Roll & 65535;

//	log("i got calleD! "$newrot);
	//rot.Pitch = 0;
	//rot.Yaw = -16384;
	//rot.Roll = 16384;
	MyHead.SetRelativeRotation(newrot);
	*/
}


///////////////////////////////////////////////////////////////////////////////
//	You will now puke
// More complicated than a normal play animation, it triggers the animation
// but also creates the puking effect. This function is usually called by the
// controller.
///////////////////////////////////////////////////////////////////////////////
function StartPuking(int newpuketype)
{
	PukeType = newpuketype;
	PukeCount++;
}

///////////////////////////////////////////////////////////////////////////////
// Special puking for when we're deathcrawling.
///////////////////////////////////////////////////////////////////////////////
function Notify_StartDeathCrawlPuking()
{
	PukeType=6;
	Notify_StartPuking();
}

///////////////////////////////////////////////////////////////////////////////
// For the love of all that's good and holy, please just stop puking...
// Tells the head to stop the puking.
///////////////////////////////////////////////////////////////////////////////
function StopPuking()
{
	// STUB
}

simulated function Notify_StartPuking()
{
	// STUB
}
simulated function Notify_StopPuking()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Hurt stuff on this side of me.
// Using this because sometimes HurtRadius doesn't seem to work well
// This is slow!
///////////////////////////////////////////////////////////////////////////////
function HurtThings(vector HitPos, vector HitMomentum, float Rad, float DamageAmount)
{
	local Actor HitActor;

	ForEach CollidingActors(class'Actor', HitActor, Rad, HitPos)
	{
		if(HitActor != self
			&& HitActor.Owner != self
			&& FastTrace(HitPos, HitActor.Location))
		{
			HitActor.TakeDamage(DamageAmount, 
								self, HitActor.Location, HitMomentum, class'KickingDamage');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Hurt things in this small area with kicking damage
///////////////////////////////////////////////////////////////////////////////
simulated function DoKickingDamage()
{
	local vector HitPos, UseRot, HitMomentum;
	local FPSPawn KickTarget;

	if(PersonController(Controller) != None)
		PersonController(Controller).DoKickingDamage(KickTarget, KICK_DAMAGE_RADIUS);

	// Put the kick down at the ground
	HitPos = Location;
	HitPos.z -= CollisionHeight;
	UseRot = vector(Rotation);
	UseRot.z = 0;
	// Move it forward
	HitPos += (0.8*KICK_DAMAGE_RADIUS)*UseRot;
	// form momentum
	HitMomentum.x = UseRot.x;
	HitMomentum.y = UseRot.y;
	HitMomentum.z = 0.8;
	HitMomentum=HitMomentum*KICK_DAMAGE_IMPULSE;

	if(KickTarget != None)
	{
		KickTarget.TakeDamage(KICK_DAMAGE_AMOUNT, 
							self, KickTarget.Location, HitMomentum, class'KickingDamage');
	}
	else
	{
		HurtThings(HitPos, HitMomentum, KICK_DAMAGE_RADIUS, KICK_DAMAGE_AMOUNT);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Notify to hurt things in this small area with kicking damage
// Player doesn't do damage through anim--he does it through his foot weapon
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_DoKickingDamage()
{
	if(!bPlayer)
		DoKickingDamage();
}

///////////////////////////////////////////////////////////////////////////////
//	Begging for life
///////////////////////////////////////////////////////////////////////////////
function PerformCrouchBeg()
{
	PlayCrouchBeggingAnim();
}
simulated function PlayCrouchBeggingAnim()
{
	local name useanim;
	useanim = GetAnimCrouchBeg();
	LoopAnim(useanim, 1.0, 0.5);
}

///////////////////////////////////////////////////////////////////////////////
//	Begging for life while prone
///////////////////////////////////////////////////////////////////////////////
function PerformProneBeg()
{
	PlayProneBeggingAnim();
}
simulated function PlayProneBeggingAnim()
{
	PlayAnim(GetAnimProneBeg(), 1.0, 0.5);
}

simulated function PlayShockedAnim()
{
	TermSecondaryChannels();
	PlayAnim(GetAnimShocked(), 1.5, 0.15);
}

simulated function PlayDazedAnim()
{
	PlayAnim(GetAnimDazed(), 1.0, 0.15);
}

simulated function PlayStunnedAnim()
{
	// Play this one a little faster
	PlayAnim(GetAnimDazed(), 1.5, 0.15);
}
simulated function PlayKickedInTheBalls()
{
	PlayAnim(GetAnimKickedInTheBalls(), 1.5, 0.15);
}

simulated function PlayStunnedByFlashbang_In()
{
	// Add a bit of randomness... with the flashbangs, having them all play the same anim in unison looks strange
	PlayAnim(GetAnimFlashbang_In(), 1.0 + Frand() * 0.5 - 0.25, 0.15);
}

simulated function PlayStunnedByFlashbang_Loop()
{
	// Add a bit of randomness... with the flashbangs, having them all play the same anim in unison looks strange
	PlayAnim(GetAnimFlashbang_Loop(), 1.0 + Frand() * 0.5 - 0.25, 0.15);
}

simulated function PlayStunnedByFlashbang_Out()
{
	// Add a bit of randomness... with the flashbangs, having them all play the same anim in unison looks strange
	PlayAnim(GetAnimFlashbang_Out(), 1.0 + Frand() * 0.5 - 0.25, 0.15);
}

simulated function PlayLaughingAnim()
{
	if (bNoExtendedAnims)
		return;
	//ChangePhysicsAnimUpdate(false);
	PlayAnim(GetAnimLaugh(), 1.0, 0.15);
}

simulated function PlayClappingAnim()
{
	if (bNoExtendedAnims)
		return;
	//ChangePhysicsAnimUpdate(false);
	PlayAnim(GetAnimClapping(), 1.0, 0.15);
}

simulated function PlayDancingAnim()
{
	PlayAnim(GetAnimDancing(), 1.0, 0.15);
}

simulated function PlaySmokingAnim()
{
	PlayAnim(GetAnimSmoking(), 1.0, 0.15);
}

simulated function PlayArcadeAnim()
{
	PlayAnim(GetAnimArcade(), 1.0, 0.15);
}

simulated function PlayCustomAnim()
{
	PlayAnim(CustomAnimLoop, 1.0, 0.15);
}

simulated function PlayGuitarAnim()
{
	PlayAnim(GetAnimGuitar(), 1.0, 0.15);
}

simulated function PlayKeyboardTypeAnim()
{
	PlayAnim(GetAnimKeyboardType(), 1.0, 0.15);
}

simulated function PlayPantingAnim()
{
	PlayAnim(GetAnimPanting(), 1.0, 0.15);
}

simulated function PlayTurnHeadLeftAnim(float fRate, float BlendFactor)
{
	AnimBlendParams(HEADCHANNEL, BlendFactor, 0,0, BONE_HEAD);
	PlayAnim('s_look_left', fRate, 0.2, HEADCHANNEL);
}

simulated function PlayTurnHeadRightAnim(float fRate, float BlendFactor)
{
	AnimBlendParams(HEADCHANNEL, BlendFactor, 0,0, BONE_HEAD);
	PlayAnim('s_look_right', fRate, 0.2, HEADCHANNEL);
}

simulated function PlayTurnHeadDownAnim(float fRate, float BlendFactor)
{
	AnimBlendParams(HEADCHANNEL, BlendFactor, 0,0, BONE_HEAD);
	PlayAnim('s_look_down', fRate, 0.2, HEADCHANNEL);
}

simulated function PlayTurnHeadUpAnim(float fRate, float BlendFactor)
{
	AnimBlendParams(HEADCHANNEL, BlendFactor, 0,0, BONE_HEAD);
//	PlayAnim('s_look_up', fRate, 0.2, HEADCHANNEL);
}

simulated function PlayTurnHeadStraightAnim(float fRate)
{
	AnimBlendToAlpha(HEADCHANNEL,0.0,fRate);
}

simulated function PlayEyesLookLeftAnim(float fRate, float BlendFactor)
{
	// STUB--defined in PersonPawn
}

simulated function PlayEyesLookRightAnim(float fRate, float BlendFactor)
{
	// STUB--defined in PersonPawn
}

simulated function PlayTalkingGesture(float userate)
{
	local int userand;
	local name useanim;

	if (bNoExtendedAnims)
		return;
		
	userand = Rand(3);

	if (bNoExtendedAnims)
		userand = 1;

	switch(userand)
	{
		case 0:
			useanim='s_gesture1';
			break;
		case 1:
			useanim='s_gesture2';
			break;
		case 2:
			useanim='s_gesture3';
			break;
	}
	//ChangePhysicsAnimUpdate(false);
	PlayAnim(useanim, userate, 0.1);

}

simulated function PlayHelloGesture(float userate)
{
	if (bNoExtendedAnims)
		return;
	//ChangePhysicsAnimUpdate(false);
	PlayAnim('s_gesture1', userate, 0.15);
}

simulated function PlayTellOffAnim()
{
	local name useanim;

	// Don't play if no extendede anims
	if (bNoExtendedAnims)
		return;
		
	if(FRand() < 0.5)
		useanim = GetAnimTellThemOff();
	else
		useanim = GetAnimFlipThemOff();
	PlayAnim(useanim, 1.0, 0.15);
}

simulated function PlayPointThatWayAnim()
{
	if (bNoExtendedAnims)
		return;
	PlayAnim(GetAnimTellThemOff(), 1.0, 0.15);
}

simulated function PlayYourFiredAnim()
{
	//ChangePhysicsAnimUpdate(false);
	PlayAnim('s_fired', 1.0, 0.15);
}

simulated function PlayGiveGesture()
{
	AnimBlendParams(EXCHANGEITEMCHANNEL, 1.0, 0,0);
	PlayAnim('s_give', 1.0, 0.2, EXCHANGEITEMCHANNEL);
}

simulated function PlayTakeGesture()
{
	AnimBlendParams(EXCHANGEITEMCHANNEL, 1.0, 0,0);
	PlayAnim('s_take', 1.0, 0.2, EXCHANGEITEMCHANNEL);
}
// Spawn some money or something in the hand as it comes up
simulated function Notify_GiveSpawnItem()
{
	if(PersonController(Controller) != None)
		PersonController(Controller).NotifyHandSpawnItem();
}
// Take it away as they give it to someone
simulated function Notify_GiveRemoveItem()
{
	if(PersonController(Controller) != None)
		PersonController(Controller).NotifyHandRemoveItem();
}
// Spawn some money or something as somene hands me some
simulated function Notify_TakeSpawnItem()
{
	if(PersonController(Controller) != None)
		PersonController(Controller).NotifyHandSpawnItem();
}
// Remove it as I put my hand by my side
simulated function Notify_TakeRemoveItem()
{
	if(PersonController(Controller) != None)
		PersonController(Controller).NotifyHandRemoveItem();
}

simulated function PlayCoweringInBallAnim()
{
	LoopAnim(GetAnimCowerInBall(), 1.0, 0.5);
}

simulated function PlayKnockedOutAnim()
{
	LoopAnim(GetAnimKnockedOut(), 1.0, 0.5);
}

simulated function PlayCoweringInBallShockedAnim(float playspeed, float blendrate)
{
	if(playspeed > 10)
		playspeed=10;
	PlayAnim(GetAnimCowerInBall(), playspeed, blendrate);
}

simulated function PlayFallOverAfterShocked()
{
	StopAllDripping();
	PlayAnim(GetAnimDeathFallForward(), 3.0, 0.3);
}

simulated function PlayRestStanding()
{
	PlayAnim(GetAnimRestStanding(), 1.0 + FRand()/10, 0.3);
}

simulated function PlayPatFireAnim()
{
	PlayAnim(GetAnimPatFire(), 1.0, 0.3);
}

simulated function PlayIdleAnim()
{
	// Get a small amount of variance here, so pawns don't all stand in unison all the dang time
	PlayAnim(GetAnimIdle(), 1.0 + FRand() / 10, 0.15);
}

simulated function PlayIdleAnimQ()
{
	PlayAnim(GetAnimIdleQ(), 1.0, 0.15);
}

simulated function PlayScreamingStillAnim()
{
	PlayAnim('s_scream', 1.0, 0.15);
}

simulated function PlayWipeFaceAnim()
{
	PlayAnim('s_sick', 1.0, 0.15);
}

simulated function PlayKissGimp()
{
	PlayAnim('kiss1', , 0.15);
}
simulated function PlayKissing()
{
	PlayAnim('kiss2', , 0.15);
}
simulated function PlaySneezing()
{
	if (bNoExtendedAnims)
		return;
	PlayAnim(GetAnimSneezing(), 1.0, 0.15);
}
simulated function PlaySneezingWalking()
{
	if (bNoExtendedAnims)
		return;
	PlayAnim(GetAnimSneezingWalking(), 1.0, 0.15);
}

///////////////////////////////////////////////////////////////////////////////
// Swap out to our burned mesh
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim()
{
	if(class'P2Player'.static.BloodMode())
	{
		// Destroy all boltons
		DestroyBoltons();

		// Set my head skin
		if(MyHead != None)
			MyHead.SwapToBurnVictim();

		Super.SwapToBurnVictim();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Begin the process for swapping to the burn skin in MP games. Don't 
// actually do it here though
///////////////////////////////////////////////////////////////////////////////
function SwapToBurnMPStart()
{
	SetAnimAction(BURN_ACTION_MP);
}

///////////////////////////////////////////////////////////////////////////////
// Set ambient glow
///////////////////////////////////////////////////////////////////////////////
function SetAmbientGlow(int NewGlow)
{
	// Set my head
	if(MyHead != None
		&& Skins[0] != BurnSkin)
		MyHead.AmbientGlow = NewGlow;

	Super.SetAmbientGlow(NewGlow);
}

///////////////////////////////////////////////////////////////////////////////
// Play special anims to 'reinit' a ragdoll (it doesn't get saved well)
// We take this old pawn, and make a new one just like him (we hope) right where
// we are, then we animate him to the ground very fast and destroy the old one.
// The point of this is because once a pawn has ragdolled (after death), the 
// version 927 ragdolls don't save/load correctly AND you can't just animate
// this same pawn because he doesn't go from anims to ragdolls and back to anims
// and all.
///////////////////////////////////////////////////////////////////////////////
function SetupDeadAfterLoad()
{
	local Actor HitActor;
	local P2MocapPawn newme;
	local vector startloc, endloc, newloc, HitLocation, HitNormal;
	local bool bHadKarma;
	local Material PickSkin;
	local Chameleon cham;

	//log(self$" SetupDeadAfterLoad");

	if(KParams != None)
		bHadKarma=true;
	KParams = None;
	SetCollision(false, false, false);
	bCollideWorld=false;
	startloc = Location;
	startloc.z+=1;
	endloc = Location;
	endloc.z-=default.CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, endloc, startloc, true);
	if(HitActor != None)
	{
		newloc = HitLocation;
		// Move him off the ground if your not from a load
		if(GetStateName() != 'LoadedDying')
			newloc.z+=default.CollisionHeight;
		else
			newloc.z+=default.CarcassCollisionHeight;
	}
	else
	{
		newloc = Location;
		// Move him off the ground if your not from a load
		if(GetStateName() != 'LoadedDying')
			newloc.z+=CollisionHeight;
	}
	
	if(Skins.Length > 0
		&& Skins[0] != BurnSkin)
		PickSkin = Skins[0];

	//log(self$" my picked skin "$Skins[0]$" new loc "$newloc$" location "$Location$" start "$startloc$" end "$endloc$" hit actor "$HitActor$" old rotation "$PreRagdollRotation);

	newme = spawn(class,,,newloc,PreRagdollRotation,PickSkin);
	if(newme != None)
	{
		newme.bPostLoadCalled=true;
		newme.Health=0;
		newme.bHidden=true;// Hide him while he animates to the ground, dead
		newme.PreRagdollRotation = newme.Rotation;
		// Copy over a few important FPSPawn values
		newme.bPersistent=bPersistent;
		newme.bCanTeleportWithPlayer=bCanTeleportWithPlayer;

		// Restore correct skins and heads and meshes
		cham = P2GameInfo(Level.Game).GetChameleon();
		if (cham != None)
		{
			cham.UseCurrentSkin(newme);
			// Head skin go set before, so clear here, so the new, spawned skin
			// can take over
			newme.HeadSkin = None;
			newme.SetupHead();
		}
		// Remove head of new guy if he is missing one 
		if(MyHead == None)
		{
			newme.DestroyHeadBoltons();
			newme.MyHead.Destroy();
			newme.MyHead = None;
		}
		// Set to burn if I was burned
		if(Skins.Length > 0
			&& Skins[0] == BurnSkin)
		{
			newme.SwapToBurnVictim();
		}
		newme.bReportDeath = bReportDeath;
		newme.GotoState('LoadedDying');
	}

	// Get rid of the old me now, the one that had been animating and stopped, and was
	// probably ragdolling. I'm no good anymore.
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
	{
	// If you start dead, and you have an animation to play, then play it 
	// but warp to the end of it (so it's like you're posing in the last frame
	// of the animation)
	if(PawnInitialState == EPawnInitialState.EP_Dead
		&& StartAnimation != '')
	{
		PlayAnim(StartAnimation, SUPER_FAST_RATE);
	}
	else if(bIsCowering)
	{
		PlayAnim(GetAnimDeathCowering(), 1.0, 0.3);
	}
	else if(bIsDeathCrawling || bIsKnockedOut)
	{
		if(MyHead == None)
			// Intentionally speed up the death animation after you deathcrawl,
			// IF you're missing your head. It makes it look really gross, like you're
			// convulsing or something. 
			PlayAnim(GetAnimDeathCrawlDeath(), 3.0, 0.3);
		else
			PlayAnim(GetAnimDeathCrawlDeath(), 1.0, 0.3);
	}
	else if (bIsCrouched)
		PlayAnim(GetAnimDeathCrouch(), 3.0, 0.3);
	else
		PlayAnim(GetAnimDeathFallForward(), 3.0, 0.3);
	}

///////////////////////////////////////////////////////////////////////////////
// Move blood pool to where you are, attach, when this is called
///////////////////////////////////////////////////////////////////////////////
function AttachBloodEffectsWhenDead()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Check if you're in a state that allows ragdoll to happen at the end
///////////////////////////////////////////////////////////////////////////////
function bool AllowRagdoll(class<DamageType> DamageType)
{
	// Don't ragdoll burnt people, because their animations look cool (but it's
	// okay to ragdoll them after their dead, when you shoot them again--
	// that's handled in Dying::TakeDamage). But only if they weren't crouching.
	if(((ClassIsChildOf(damageType, class'BurnedDamage')
		|| ClassIsChildOf(damageType, class'OnFireDamage'))
		&& !bIsCrouched)
			//|| P2GameInfoSingle(Level.Game) == None
		|| bForbidRagdoll
			)
		return false;

	// Everything else allows it
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// If there's any more karam skels avaialable, it takes one from whoever
// was using it, and gives it to this new pawn, that called this function
// If not, it returns none
///////////////////////////////////////////////////////////////////////////////
function GetKarmaSkeleton()
{
	local P2GameInfo checkg;
	local name skelname;
	local P2Player p2p, cont;

	if(CharacterType == CHARACTER_avgdude)
		skelname=DUDE_SKEL;
	else if(CharacterType == CHARACTER_female)
		skelname=FEM_SKEL;
	else if(CharacterType == CHARACTER_fat)
		skelname=FAT_SKEL;
	else if(CharacterType == CHARACTER_big)
		skelname=BIG_SKEL;
	else if(CharacterType == CHARACTER_mini)
		skelname=MINI_SKEL;
	else
	{
		skelname=DUDE_SKEL;
		Warn("GetKarmaSkeleton::unknown ragdoll skeleton");
	}

	if(Level.NetMode != NM_DedicatedServer)
	{
		// Go through all the player controllers till you find the one on
		// your computer that has a valid viewport and has your ragdolls
		foreach DynamicActors(class'P2Player', Cont)
		{
			if (ViewPort(Cont.Player) != None)
			{
				p2p = Cont;
				break;
			}
		}
		if(p2p != None
			&& KParams == None)
		{
			KParams = p2p.GetNewRagdollSkel(self, skelname);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// If we don't they tend to disappear
///////////////////////////////////////////////////////////////////////////////
function CapKarmaMomentum(out vector Kmomentum, class<damageType> mydam, 
						  float ratioexpl, float ratio, optional out vector HitLocation)
{
	if(ClassIsChildOf(mydam, class'BludgeonDamage'))
	{
		HitLocation = Location + BLUDGEON_RAND_MAG*VRand();
		KMomentum.x = KARMA_DAMPEN_BLUDGEON_XY*Kmomentum.x;
		KMomentum.y = KARMA_DAMPEN_BLUDGEON_XY*Kmomentum.y;
		KMomentum.z = KARMA_DAMPEN_BLUDGEON_Z*Kmomentum.z;
	}
	else if(!ClassIsChildOf(mydam, class'ExplodedDamage')
		&& !ClassIsChildOf(mydam, class'SmashDamage'))
	{
		if(mydam == class'ShotgunDamage')
			KMomentum = KARMA_DAMPEN_SHOTGUN*Kmomentum;
		else
			KMomentum = KARMA_DAMPEN_NON_EXPLOSION*Kmomentum;

		// Limit momentum to keep bodies from going through walls
		if(KMomentum.x > MAX_XY_MOMENTUM)
			KMomentum.x = MAX_XY_MOMENTUM;
		else if(KMomentum.x < -MAX_XY_MOMENTUM)
			KMomentum.x = -MAX_XY_MOMENTUM;
		if(KMomentum.y > MAX_XY_MOMENTUM)
			KMomentum.y = MAX_XY_MOMENTUM;
		else if(KMomentum.y < -MAX_XY_MOMENTUM)
			KMomentum.y = -MAX_XY_MOMENTUM;
		if(KMomentum.z > MAX_UPWARD_MOMENTUM)
			KMomentum.z = MAX_UPWARD_MOMENTUM;
		else if(KMomentum.z < MAX_DOWNWARD_MOMENTUM)
			KMomentum.z = MAX_DOWNWARD_MOMENTUM;
		KMomentum = ratio*KMomentum;
	}
	else // Limit explosions too
	{
		if(VSize(KMomentum) > MAX_EXPL_MOMENTUM)
		{
			KMomentum = MAX_EXPL_MOMENTUM*Normal(KMomentum);
		}
		KMomentum = ratioexpl*KMomentum;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make sure if they are crouching they don't fall through the ground when
// newly dead. (This only seems to be a problem in MP)
///////////////////////////////////////////////////////////////////////////////
simulated function PopUpDead()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Make sure both the head and the body are independently running on the client
// after this. 
///////////////////////////////////////////////////////////////////////////////
simulated function TearOffNetworkConnection(class<DamageType> DamageType)
{
	if (Role == ROLE_Authority 
		&& P2Player(Controller) != None)
		P2Player(Controller).MyPawn = None;
	bTearOff=true;
	bReplicateMovement = false;
	if(MyHead != None)
		MyHead.TearOffNetworkConnection(DamageType);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
	{
	local vector shotDir, hitLocation, hitNormal, DeathImpulse, DeathVel;
	local actor tmpActor;
	local float maxDim;
	local bool bUsingRagdoll;

	// Save our rotation before we ragdolled.
	PreRagdollRotation = Rotation;

	bUsingRagdoll = AllowRagdoll(DamageType);

	bPlayedDeath = true;
	if ( bPhysicsAnimUpdate )
	{
		if(!bUsingRagdoll)
			PopUpDead();
		// only in MP
		if(Level.Game == None
			|| !Level.Game.bIsSinglePlayer
			|| bNCClientRagdolls)
			TearOffNetworkConnection(DamageType);
		HitDamageType = DamageType;
		TakeHitLocation = HitLoc;
		if ( (HitDamageType != None) && (HitDamageType.default.GibModifier >= 100) )
			ChunkUp(-1 * Health);
	}

	log(self$" PlayDying, use ragdoll "$bUsingRagdoll);
	if(KParams == None
		// Don't let people who are supposed to die on start, to use ragdoll
		// unless they don't have a starting animation set
		// We disregard this after death.
		&& (PawnInitialState != EPawnInitialState.EP_Dead
			|| StartAnimation == '')
		&& bUsingRagdoll)
	{
		// Check to get a ragdoll skeleton from the game info.
		GetKarmaSkeleton();
	}

	if (Level.NetMode != NM_DedicatedServer
		&& (KarmaParamsSkel(KParams) != None) )
	{
		// Don't crouch or crawl anymore
		ShouldCrouch(false);
		ShouldDeathCrawl(false);

		StopAnimating();

		bPhysicsAnimUpdate = false;

		SetPhysics(PHYS_KarmaRagDoll);

		// Get things going first, for sure
		KWake();

		if((bIsDeathCrawling || bIsKnockedOut)
			&& !ClassIsChildOf(DamageType, class'ExplodedDamage'))
		{
			DeathVel = vect(0,0,0);
			DeathImpulse = vect(0,0,0);
		}
		else
		{
			DeathVel = DeathVelMag * Normal(TearOffMomentum);
			DeathImpulse = Mass*TearOffMomentum;
		}

		CapKarmaMomentum(DeathImpulse, DamageType, 1.0, 1.0);

		// Set the guy moving in direction he was shot in general
		KSetSkelVel( DeathVel );

		// Move the body
		KAddImpulse(DeathImpulse, HitLoc);
	}

    SetTwistLook(0, 0);
    bDoTorsoTwist=false;

	TermSecondaryChannels();

	if(Physics != PHYS_KarmaRagDoll)
	{
		PlayDyingAnim(DamageType,HitLoc);
		StopAcc();
	}

	// Set what happened to us on death
	DyingDamageType = class<P2Damage>(DamageType);

	// Check to make blood pool below us.
	// See if we already have blood squrting out of us in some other spot first
	// --if so, don't make this
	AttachBloodEffectsWhenDead();

	// If the head is still attached, then detach it, set collision ready
	// but don't make it fall. This way, people can get fairly accurate head
	// collision on dead bodies, so they can shoot the heads, even on dead
	// bodies
	if(MyHead != None)
	{
		if(MyHead.SetupAfterDetach())
		{
			// No matter what, always play the dead animation on the head
			MyHead.GotoState('Dead');
		}
	}

	GotoState('Dying');
	}


///////////////////////////////////////////////////////////////////////////////
// True if it was a crotch hit (very limited area)
///////////////////////////////////////////////////////////////////////////////
function bool WasCrotchHit(Vector HitLocation, Vector Momentum)
{
	local vector hitvec, dir;
	local vector CrotchLoc;

	CrotchLoc = Location;
	CrotchLoc.z -= CROTCH_OFFSET;

	hitvec = HitLocation - CrotchLoc;
	dir = Normal(hitvec);
	// if hitting us from the front
	if((dir dot vector(Rotation)) > CROTCH_FRONT)
	{
		if(abs(hitvec.z) < CROTCH_SIZE)
		{
			return true;
		}
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check which body part closest to this point, aiming in to the center
///////////////////////////////////////////////////////////////////////////////
function name FindBodyPart(vector HitPoint)
{
	local float bratio;

	//log(self$" FindBodyPart at "$HitPoint$" my location "$Location);

	if(!bIsDeathCrawling && !bIsKnockedOut
		&& Physics != PHYS_KarmaRagDoll)
	{
		// Find ratio up/down body
		bratio = (HitPoint.z-Location.z)/CollisionHeight;

		//log(self$" bratio "$bratio);

		if(bratio > HEAD_HEIGHT_RATIO)
		{
			return BONE_HEAD;
		}
		else if(bratio > TORSO_HEIGHT_RATIO)
		{
			return BONE_MID_SPINE;
		}
		else if(bratio > PELVIS_HEIGHT_RATIO)
		{
			return BONE_PELVIS;
		}
		else if(bratio > KNEE_HEIGHT_RATIO)
		{
			return BONE_RCALF;
		}
		else if(bratio > FOOT_HEIGHT_RATIO)
		{
			return BONE_RFOOT;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
	{
	local vector X,Y,Z,Dir;
	local float BlendAlpha, BlendTime, PercentUpBody;
	local EWeaponHoldStyle wstyle;
	local bool bDidHit;

	// Don't make him play a single frame hit from getting hurt by fire
	if(damageType != class'OnFireDamage'
		&& !ClassIsChildOf(damageType, class'BurnedDamage')	
		&& damageType != class'ElectricalDamage')
		{
			if (bIsKnockedOut)
			{
				// just take a quick hit while laid out, don't tween it or do anything complex
				PlayAnim('ko_loop2',5.0);				
				//BlendAlpha = FRand()*0.4 + 0.1;
				//BlendTime=0.2;
				//AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
				//TweenAnim(GetAnimKnockedOut(),BlendTime,TAKEHITCHANNEL);
			}
			else if(bIsDeathCrawling)
			{
				BlendAlpha = FRand()*0.4 + 0.1;
				BlendTime=0.2;
				AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
				TweenAnim(GetAnimDeathCrawlDeath(),BlendTime,TAKEHITCHANNEL);
			}
			else if(bIsCowering)
			{
				BlendAlpha = FRand()*0.5 + 0.1;
				BlendTime=0.2;
				AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
				TweenAnim(GetAnimCowerInBall(),BlendTime,TAKEHITCHANNEL);
			}
			else
			{
				GetAxes(Rotation,X,Y,Z);
				Dir = Normal(HitLoc - Location);

				if(bIsCrouched)
				{
					BlendAlpha=0.2;
					BlendTime=0.5;
				}
				else
				{
					BlendAlpha = 1.0;
					BlendTime=0.25+Frand()*0.1;
				}

				// Check what anim to tween to
				wstyle = GetWeaponHoldStyle();

				// If we get hit by a shovel, play something special if they hit us in the head
				if(damageType == class'ShovelDamage')
				{
					PercentUpBody = (HitLoc.z - Location.z)/CollisionHeight;
					if(PercentUpBody > HEAD_RATIO_OF_FULL_HEIGHT
						&& bHeadCanComeOff)
					{
						if(DamageInstigator != None)	// Use other Dir (above) if no hitter
							Dir = Normal(DamageInstigator.Location - Location);
						//log(self$" dir "$Dir$" X "$x$" dot "$Dir Dot X$" hitter "$DamageInstigator);
						BlendTime=0.2;
						BlendAlpha = 0.5 + Frand()*0.5;
						if(Dir Dot X < 0)
						{
							AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, 0,0, BONE_NECK);
							TweenAnim('s_neckr', BlendTime, TAKEHITCHANNEL);
							//log(self$" playing right ");
						}
						else
						{
							AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, 0,0, BONE_NECK);
							TweenAnim('s_neckl', BlendTime, TAKEHITCHANNEL);
							//log(self$" playing left ");
						}
						bDidHit=true;
					}
				}
				
				// If we get hit with non-lethal damage, play a special hit anim
				if (class<P2Damage>(damageType) != None
					&& class<P2Damage>(damageType).Default.bNonLethal)
				{
					//log(self$" dir "$Dir$" Y "$y$" dot "$Dir Dot Y$" hitter "$DamageInstigator);
					// Only play this if we're NOT knocked out -- the take hit anim screws with the fall-down anim
					if (NonLethalHealth > 0)
					{
						BlendTime=1.0;
						BlendAlpha = 0.5 + Frand()*0.5;
						if(Dir Dot Y > 0.25)
						{
							AnimBlendParams(TAKEHITCHANNEL, BlendAlpha);
							TweenAnim('ko_hit3', BlendTime, TAKEHITCHANNEL);
							//log(self$" playing right ");
						}
						else if (Dir Dot Y < 0.25)
						{
							AnimBlendParams(TAKEHITCHANNEL, BlendAlpha);
							TweenAnim('ko_hit2', BlendTime, TAKEHITCHANNEL);
							//log(self$" playing left ");
						}
						else
						{
							AnimBlendParams(TAKEHITCHANNEL, BlendAlpha);
							TweenAnim('ko_hit1', BlendTime, TAKEHITCHANNEL);
						}
					}
					bDidHit=true;
				}

				if(!bDidHit)
				{
					if(wstyle == WEAPONHOLDSTYLE_Single)
					{
						BlendAlpha = FRand()*0.5 + 0.5;
						BlendTime=0.2;
						AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
						if(Dir Dot Y > 0)
						{
							TweenAnim('ss_base_hitr',BlendTime,TAKEHITCHANNEL);
						}
						else
						{
							TweenAnim('ss_base_hitl',BlendTime,TAKEHITCHANNEL);
						}
					}
					else if (wstyle == WEAPONHOLDSTYLE_Dual)
					{
						BlendAlpha = FRand()*0.5 + 0.5;
						BlendTime=0.2;
						AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
						
						if (Dir Dot Y > 0)
							TweenAnim('sb2_base_hitr',BlendTime,TAKEHITCHANNEL);
						else
							TweenAnim('sb2_base_hitl',BlendTime,TAKEHITCHANNEL);
					}
					else if (wstyle == WEAPONHOLDSTYLE_DualBig)
					{
						BlendAlpha = FRand()*0.5 + 0.5;
						BlendTime=0.2;
						AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
						
						if (Dir Dot Y > 0)
							TweenAnim('sb2_base_hitr',BlendTime,TAKEHITCHANNEL);
						else
							TweenAnim('sb2_base_hitl',BlendTime,TAKEHITCHANNEL);
					}
					else if(wstyle == WEAPONHOLDSTYLE_Double
						|| wstyle == WEAPONHOLDSTYLE_Both)
					{
						BlendAlpha = FRand()*0.5 + 0.5;
						BlendTime=0.2;
						AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
						if(Dir Dot Y > 0)
						{
		//					AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, 0,0, BONE_BLENDTAKEHIT);
		//					PlayAnim('sd2_base_hitr', 0.1, BlendTime, TAKEHITCHANNEL);
							TweenAnim('sd2_base_hitr',BlendTime,TAKEHITCHANNEL);
						}
						else
						{
		//					AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, 0,0, BONE_BLENDTAKEHIT);
		//					PlayAnim('sd2_base_hitl', 0.1, BlendTime, TAKEHITCHANNEL);
							TweenAnim('sd2_base_hitl',BlendTime,TAKEHITCHANNEL);
						}
					}
					else
					{
						if ( (Dir Dot X) < 0 )
						{
							AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, 0,0, BONE_BLENDTAKEHIT);
							PlayAnim('s_shotSPINE', 0.1, BlendTime, TAKEHITCHANNEL);
							//TweenAnim('s_shotSPINE',BlendTime,TAKEHITCHANNEL);
						}
						else if ( ((Dir Dot X) > 0.9) || (HitLoc.Z <= Location.Z) )
						{
							AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, 0,0, BONE_BLENDTAKEHIT);
							PlayAnim('s_shotstomach', 0.1, BlendTime, TAKEHITCHANNEL);
							//TweenAnim('s_shotstomach',BlendTime,TAKEHITCHANNEL);
						}
						else if ( (Dir Dot Y) > 0 )
						{
							AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, 0,0, BONE_BLENDTAKEHIT);
							PlayAnim('s_shotRTfrontshoulder', 0.1, BlendTime, TAKEHITCHANNEL);
							//TweenAnim('s_shotRTfrontshoulder',BlendTime,TAKEHITCHANNEL);
						}
						else
						{
							// FIX: Using wrong (but workable) anim because correct one is screwed up
							AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, 0,0, BONE_BLENDTAKEHIT);
							PlayAnim('s_shotRTbackshoulder', 0.1, BlendTime, TAKEHITCHANNEL);
							//TweenAnim('s_shotRTbackshoulder',BlendTime,TAKEHITCHANNEL); 
						}
					}
				}
			}
		}

	Super.PlayTakeHit(HitLoc,Damage,damageType);
	}


simulated event PlayJump()
	{
	/*
	local vector X,Y,Z, Dir;
	local float f, TweenTime;
	
	PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
	
	if ( CurrentDir == DCLICK_Left )
		PlayAnim('Dodge_right', FMax(0.35, PhysicsVolume.Gravity.Z/PhysicsVolume.Default.Gravity.Z), 0.06);
	else if ( CurrentDir == DCLICK_Right )
		PlayAnim('Dodge_left', FMax(0.35, PhysicsVolume.Gravity.Z/PhysicsVolume.Default.Gravity.Z), 0.06);
	else if ( CurrentDir == DCLICK_Back )
		PlayAnim('DodgeB', FMax(0.35, PhysicsVolume.Gravity.Z/PhysicsVolume.Default.Gravity.Z), 0.06);
	else if ( CurrentDir == DCLICK_Forward )
		PlayAnim('Dodge_forward', FMax(0.35, PhysicsVolume.Gravity.Z/PhysicsVolume.Default.Gravity.Z), 0.06);
	else

		{
		BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
		if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
			PlayAnim(ANIM_JUMP_RUN);
		else
			PlayAnim(ANIM_JUMP_STAND); 
		}
	CurrentDir = DCLICK_None;
	*/
	}


function PlayLanded(float impactVel)
	{	
	BaseEyeHeight = Default.BaseEyeHeight;
	/*
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	if ( impactVel > 0.17 )
		PlayOwnedSound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
	if ( (impactVel > 0.01) && !TouchingWaterVolume() )
		PlayOwnedSound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
	*/
	}


simulated event PlayLandingAnimation(float ImpactVel)
	{
	if (IsInState('Dying'))
		return;
	if ( (impactVel > 0.06) || IsAnimating(FALLINGCHANNEL) ) 
		{
		PlayWaiting();
		}
	else if ( !IsAnimating(0) )
		{
		PlayWaiting();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// This is for the pawn to animate putting away the current weapon
///////////////////////////////////////////////////////////////////////////////
function PlayWeaponDown()
{
	local EWeaponHoldStyle wstyle;
	local WeaponAttachment wpattach;

	wstyle = GetWeaponSwitchStyle();
	if(MyWeapAttach != None)
		wpattach = MyWeapAttach;
	else if(Weapon != None)
		wpattach = WeaponAttachment(Weapon.ThirdPersonActor);

	AnimEndSwitch();

	//log(self$" weapon down "$Weapon);
	// Choose appropriate shooting animation and blend it into
	// current animation.  We assume the current animation is
	// amenable to shooting; if it isn't, this will look stupid.
	if(wstyle != WEAPONHOLDSTYLE_None)
	{
		AnimBlendParams(WEAPONCHANNEL, 1.0, SWITCH_WEAPON_BLEND_TIME, 0, BONE_BLENDFIRING);
		WeaponBlendTime = SWITCH_WEAPON_BLEND_TIME;
	}

	switch (wstyle)
		{
		case WEAPONHOLDSTYLE_None:
			if(wpattach != None
				&& wpattach.FiringMode == 'URETHRA1')
			{
				AnimBlendParams(WEAPONCHANNEL, 1.0, SWITCH_WEAPON_BLEND_TIME, 0, BONE_BLENDFIRING);
				WeaponBlendTime = SWITCH_WEAPON_BLEND_TIME;
				PlayAnim('s_piss_end', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			}
			break;
		case WEAPONHOLDSTYLE_Toss:
		case WEAPONHOLDSTYLE_Single:
			if (bIsCrouched)
				PlayAnim('c_draw_sh_out', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('s_holster_sh', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Dual:
			if (bIsCrouched)
				PlayAnim('cb2_holster', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('sb2_holster', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_DualBig:
			if (bIsCrouched)
				PlayAnim('cb3_holster', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('sb3_holster', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Both:
			if (bIsCrouched)
				PlayAnim('c_draw_dh', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('s_holster_dh', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Double:
			if (bIsCrouched)
				PlayAnim('c_draw_dh', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('s_holster_dh', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Pour:
				PlayAnim('s_draw_sh_out', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Carry:
				PlayAnim('sc_holster', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Melee:
			if(wpattach != None
				&& (wpattach.FiringMode == 'SHOVEL1' || wpattach.FiringMode == 'WEED1'))
			{
				PlayAnim('s_holster_shovel', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			}
			else
			{
				if (bIsCrouched)
					PlayAnim('c_draw_sh_out', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
				else
					PlayAnim('s_draw_sh_out', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			}
			break;

		default:
			Warn("Unknown EWeaponHoldStyle");
			break;
		}
}

///////////////////////////////////////////////////////////////////////////////
// This should be called PlayWeaponBringUp or whatever, but Epic named it so....
// Anyway, it's for the pawn to play an anim to bring up the new weapon
///////////////////////////////////////////////////////////////////////////////
function PlayWeaponSwitch(Weapon NewWeapon)
	{
	local EWeaponHoldStyle wstyle;
	local WeaponAttachment wpattach;

	wstyle = GetWeaponSwitchStyle();

	if(MyWeapAttach != None)
		wpattach = MyWeapAttach;
	else if(Weapon != None)
		wpattach = WeaponAttachment(Weapon.ThirdPersonActor);

	AnimEndSwitch();

	// Make sure to reshow the grenade or anything coming out of your pockets.
	if(NewWeapon.AmmoType != None
		&& NewWeapon.AmmoType.HasAmmo()
		&& NewWeapon.ThirdPersonActor != None)
		NewWeapon.ThirdPersonActor.bHidden=false;

	//log(self$" weapon Up "$Weapon);

	// Choose appropriate shooting animation and blend it into
	// current animation.  We assume the current animation is
	// amenable to shooting; if it isn't, this will look stupid.
	if(wstyle != WEAPONHOLDSTYLE_None)
	{
		AnimBlendParams(WEAPONCHANNEL, 1.0, BRING_UP_BLEND_TIME, 0, BONE_BLENDFIRING);
		WeaponBlendTime = SWITCH_WEAPON_BLEND_TIME;
	}

	switch (wstyle)
		{
		case WEAPONHOLDSTYLE_None:
			if(wpattach != None
				&& wpattach.FiringMode == 'URETHRA1')
			{
				AnimBlendParams(WEAPONCHANNEL, 1.0, BRING_UP_BLEND_TIME, 0, BONE_BLENDFIRING);
				WeaponBlendTime = SWITCH_WEAPON_BLEND_TIME;
				PlayAnim('s_piss_start', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			}
			break;
		case WEAPONHOLDSTYLE_Toss:
		case WEAPONHOLDSTYLE_Single:
			if (bIsCrouched)
				PlayAnim('c_draw_sh_in', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('s_load_sh', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Dual:
			if (bIsCrouched)
				PlayAnim('cb2_unholster', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('sb2_unholster', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_DualBig:
			if (bIsCrouched)
				PlayAnim('cb3_unholster', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('sb3_unholster', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Both:
			if (bIsCrouched)
				PlayAnim('c_draw_dh', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('s_load_dh', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Double:
			if (bIsCrouched)
				PlayAnim('c_draw_dh', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			else
				PlayAnim('s_load_dh', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Pour:
				PlayAnim('s_draw_sh_in', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Carry:
				PlayAnim('sc_load', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Melee:
			if(wpattach != None
				&& (wpattach.FiringMode == 'SHOVEL1' || wpattach.FiringMode == 'WEED1'))
			{
				PlayAnim('s_load_shovel', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
			}
			else
			{
				if (bIsCrouched)
					PlayAnim('c_draw_sh_in', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
				else
					PlayAnim('s_draw_sh_in', BRING_UP_WEAPON_RATE, BRING_UP_BLEND_TIME, WEAPONCHANNEL);
			}
			break;

		default:
			Warn("Unknown EWeaponHoldStyle");
			break;
		}
	}

/*
///////////////////////////////////////////////////////////////////////////////
// Some weapons have an elaborate charge like the grenades.
///////////////////////////////////////////////////////////////////////////////
simulated function PlayChargingIntro(float Rate, EWeaponHoldStyle wstyle)
{
	local bool StandingStill;

	// If he's not moving and not rotating make a recoil
	// Some weapons (like guns) don't want a recoil if you're
	// moving too much
	StandingStill = (NoLegMotion()
					&& (!bPlayer
						|| Controller.DesiredRotation == Controller.Rotation));
	wstyle = GetWeaponHoldStyle();

	// Choose appropriate shooting animation and blend it into
	// current animation.  We assume the current animation is
	// amenable to shooting; if it isn't, this will look stupid.
	if(wstyle != WEAPONHOLDSTYLE_None)
	{
		AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
		WeaponBlendTime = FIRING_BLEND_TIME;
	}

	switch (wstyle)
		{
		case WEAPONHOLDSTYLE_Toss:
			PlayAnim('sg_pull_pin', Rate, 0.1, WEAPONCHANNEL);
			break;
		default:
			Warn("Unknown EWeaponHoldStyle");
			break;
		}
}
*/
///////////////////////////////////////////////////////////////////////////////
// Play 3rd person shooting anims
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring(float Rate, name FiringMode)
{
	local EWeaponHoldStyle wstyle;
	local bool StandingStill;

	// If he's not moving and not rotating make a recoil
	// Some weapons (like guns) don't want a recoil if you're
	// moving too much
	StandingStill = (NoLegMotion()
					&& (!bPlayer
						|| (Controller != None
							&& Controller.DesiredRotation == Controller.Rotation)));

	wstyle = GetWeaponFiringStyle();

	// Choose appropriate shooting animation and blend it into
	// current animation.  We assume the current animation is
	// amenable to shooting; if it isn't, this will look stupid.
	if(StandingStill)
	{
		AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
		WeaponBlendTime = FIRING_BLEND_TIME;
	}

	switch (wstyle)
		{
		case WEAPONHOLDSTYLE_None:
				if(FiringMode == 'URETHRA1')
					PlayAnim('s_piss_loop', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
				else
					PlayAnim('s_gesture1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
			break;

		case WEAPONHOLDSTYLE_Single:
			if(FiringMode == 'SHOCKER1')
			{
				AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
				WeaponBlendTime = FIRING_BLEND_TIME;

				PlayAnim('sg_rocket', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
			}
			else if(StandingStill)
			{
				if(FRand() < 0.5)
					PlayAnim('ss_recoil_singleframe1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
				else
					PlayAnim('ss_recoil_singleframe2', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
			}
			break;
		case WEAPONHOLDSTYLE_Dual:
			if(StandingStill)
			{
				if (bIsCrouched)
				{
					if (FRand() < 0.5)
						PlayAnim('cb2_recoil_singleframe1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					else
						PlayAnim('cb2_recoil_singleframe2', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
				}
				else
				{
					if (FRand() < 0.5)
						PlayAnim('sb2_recoil_singleframe1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					else
						PlayAnim('sb2_recoil_singleframe2', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
				}
			}
			break;
		case WEAPONHOLDSTYLE_DualBig:
			if(StandingStill)
			{
				if (bIsCrouched)
				{
					if (FRand() < 0.5)
						PlayAnim('cb3_recoil_singleframe1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					else
						PlayAnim('cb3_recoil_singleframe2', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
				}
				else
				{
					if (FRand() < 0.5)
						PlayAnim('sb3_recoil_singleframe1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					else
						PlayAnim('sb3_recoil_singleframe2', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
				}
			}
			break;
		case WEAPONHOLDSTYLE_Both:
			if(StandingStill)
			{
				if (bIsCrouched)
				{
					if (FRand() < 0.5)
						PlayAnim('cd_recoil_singleframe1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					else
						PlayAnim('cd_recoil_singleframe2', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
				}
				else
				{
					if(bIsTrained)
					{
						if (FRand() < 0.5)
							PlayAnim('sd1_recoil_singleframe3', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
						else
							PlayAnim('sd1_recoil_singleframe4', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					}
					else
					{
						if (FRand() < 0.5)
							PlayAnim('sd2_recoil_singleframe1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
						else
							PlayAnim('sd2_recoil_singleframe2', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					}
				}
			}
		case WEAPONHOLDSTYLE_Double:
			if(StandingStill)
			{
				if (bIsCrouched)
				{
					if (FRand() < 0.5)
						PlayAnim('cd_recoil_singleframe1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					else
						PlayAnim('cd_recoil_singleframe2', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
				}
				else
				{
					if(bIsTrained)
					{
						if (FRand() < 0.5)
							PlayAnim('sd1_recoil_singleframe3', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
						else
							PlayAnim('sd1_recoil_singleframe4', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					}
					else
					{
						if (FRand() < 0.5)
							PlayAnim('sd2_recoil_singleframe1', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
						else
							PlayAnim('sd2_recoil_singleframe2', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
					}
				}
			}
			break;
		case WEAPONHOLDSTYLE_Pour:
				AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
				WeaponBlendTime = FIRING_BLEND_TIME;
				PlayAnim('sd_shoot_gas', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Carry:
				AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
				WeaponBlendTime = FIRING_BLEND_TIME;
				PlayAnim('sc_throw', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Toss:
			AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
			WeaponBlendTime = FIRING_BLEND_TIME;
			if(FiringMode == 'SCISSORS1')
			{
				PlayAnim('sg_throw_scissors', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
			}
			else if(FiringMode == 'MATCHES1')
			{
				PlayAnim('sg_throw_match', Rate, FIRING_BLEND_TIME, WEAPONCHANNEL);
			}
			else
				PlayAnim('sg_throw', Rate, 0.1, WEAPONCHANNEL);
			break;
		case WEAPONHOLDSTYLE_Melee:
				AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
				WeaponBlendTime = FIRING_BLEND_TIME;
				if(FiringMode == 'SHOVEL1')
					PlayAnim('sd_shovel1', Rate, 0.1, WEAPONCHANNEL);
				else if (FiringMode == 'WEED1')
				{
					if (P2Weapon(Weapon).bAltFiring)
						PlayAnim('sd_shovel1', Rate, 0.1, WEAPONCHANNEL);
					else
						PlayAnim('sww_fire1', Rate/10, FIRING_BLEND_TIME, WEAPONCHANNEL);
				}
				else if(FiringMode == 'SHOVEL2')
					PlayAnim('sd_shovel2', Rate, 0.1, WEAPONCHANNEL);
				else if(FiringMode == 'BATON1'
					|| FiringMode == 'BASEBALLBAT1')
					PlayAnim('sd_baton1', Rate, 0.1, WEAPONCHANNEL);
				else if(FiringMode == 'BATON2')
					PlayAnim('sd_baton2', Rate, 0.1, WEAPONCHANNEL);
				else if (FiringMode == 'CLIPPER1')
					PlayAnim('Vchop', Rate, 0.1, WEAPONCHANNEL);
			break;

		default:
			Warn("Unknown EWeaponHoldStyle");
			break;
		}
}

///////////////////////////////////////////////////////////////////////////////
// When you hit something
///////////////////////////////////////////////////////////////////////////////
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local Actor HitActor;
	local vector checkpoint, HitLocation, HitNormal;

	//log(self$" hit this hard "$impactVel$" mag "$VSize(impactVel));
	// Make hit noises
	if(Level.TimeSeconds > (LastBodyHitTime + TimeBetweenPainSounds))
	{
		PlaySound(BodyHitSounds[Rand(BodyHitSounds.Length)], SLOT_Pain, 1.0, , 100, GetRandPitch());
		LastBodyHitTime = Level.TimeSeconds;

		// From the big impact, put a blood splat
		checkpoint = Location - DIST_TO_WALL_FOR_BLOODSPLAT*Normal(impactNorm);

		HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true);

		if ( HitActor != None
			&& HitActor.bStatic
			&& class'P2Player'.static.BloodMode()
			&& MyRace != RACE_Automaton)
		{
			spawn(class'BloodExplosionSplatMaker',self,,HitLocation,rotator(HitNormal));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// In Warfare, this is called by various weapons to tell the pawn to stop firing.
// In Postal2, it is currently unused.
///////////////////////////////////////////////////////////////////////////////
simulated event StopPlayFiring()
	{
/*	if ( bSteadyFiring )
		{
		// FIXME - smooth blend out firing
		bSteadyFiring = false;
		AnimBlendToAlpha(WEAPONCHANNEL, 0, FIRING_BLEND_TIME);
		PlayWaiting();
		}
		*/
	}


///////////////////////////////////////////////////////////////////////////////
// Handle end of animation on specified channel
///////////////////////////////////////////////////////////////////////////////
simulated event AnimEnd(int Channel)
	{
	if ( Channel == 0 )
	{
		// Turn physics anim-blending back on
		ChangePhysicsAnimUpdate(true);
		PlayWaiting();
	}
	else if ( Channel == EXCHANGEITEMCHANNEL )
		{
			AnimBlendToAlpha(EXCHANGEITEMCHANNEL,0,0.1);
		}
	else if ( Channel == HEADCHANNEL )
		{
			AnimBlendToAlpha(HEADCHANNEL,0,0.2);
		}
	else if ( Channel == WEAPONCHANNEL )
		{
		// FIREWEAPONCHANNEL used for upper body (firing weapons, holster, load, etc.)
		//if ( !bSteadyFiring )
		//	{
			//log(self$" end blending on weapon "$Weapon$" WeaponBlendTime "$WeaponBlendTime);
			AnimBlendToAlpha(WEAPONCHANNEL, 0, WeaponBlendTime);
			WeaponBlendTime = 0;
		//	}
		}
	else if ( Channel == TAKEHITCHANNEL )
		AnimBlendToAlpha(TAKEHITCHANNEL,0,0.1);
	else if ( Channel == FALLINGCHANNEL )
		{
		//	AnimBlendParams(HEADCHANNEL, BlendFactor, 0,0, BONE_HEAD);
			if(Physics == PHYS_Falling)
				PlayFalling();
			else
				AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Free up all channels (effectively stopping those animations)
///////////////////////////////////////////////////////////////////////////////
function TermSecondaryChannels()
{
	AnimBlendToAlpha(HEADCHANNEL,0,0.1);
	AnimBlendToAlpha(EXCHANGEITEMCHANNEL, 0, 0.1);
	AnimBlendToAlpha(WEAPONCHANNEL,0,0.1);
	AnimBlendToAlpha(TAKEHITCHANNEL,0,0.1);
	AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
}

///////////////////////////////////////////////////////////////////////////////
// Handle an early holster/load end (especially if you're new weapon is wanting
// to play it's load animation)
///////////////////////////////////////////////////////////////////////////////
simulated function AnimEndSwitch()
{
//			log(self$" EARLY end blending on weapon "$Weapon);
//			WeaponBlendTime = 0;
//			AnimBlendToAlpha(WEAPONCHANNEL, 0, WeaponBlendTime);
}

///////////////////////////////////////////////////////////////////////////////
// Because not all meshes have it, don't allow running/walking backwards in SP
///////////////////////////////////////////////////////////////////////////////
simulated function bool AllowBackpeddle()
{
	return (Level.Game == None
		|| !Level.Game.bIsSinglePlayer);
}

///////////////////////////////////////////////////////////////////////////////
//
// Private animation functions.
//
// These functions take all the common character attributes into account to
// determine which animations to use.  Derived classes can certainly extend
// these functions, but it shouldn't be necessary for most cases.
//
// The SetAnimXXXXX functions set up the character to start playing the
// appropriate animation.
//
// The GetAnimXXXXX functions simply return the name of the appropriate
// animation, which is useful when several areas of the code need to refer to
// the same animation.
//
///////////////////////////////////////////////////////////////////////////////
simulated function SetupAnims()
	{
	LinkAnims();
		
	TurnLeftAnim		= 's_turn1';//s_look_left';
	TurnRightAnim		= 's_turn1';//'s_look_right';
	MovementAnims[0]	= 's_walk1';
	if(!AllowBackpeddle())
		MovementAnims[1]	= MovementAnims[0];
	else
		MovementAnims[1]	= 's_walkback';
	MovementAnims[2]	= 's_strafel';
	MovementAnims[3]	= 's_strafer';

	// Pick your leading foot
	//if(Frand() < 0.5)
	//	bLeftFoot=true;
	// Make sure dude/player never picks left foot

	if(AnimGroupUsed != -1)
		AnimGroupUsed = Rand(2);	// Pick which walks and other random anims to pick.
	else
		AnimGroupUsed=0;	// Pick the basic one

	// After all the setup, check to see if we're too fat to run much
	if (bIsFat)
		{
		// He's fat, so drop his fitness
		if(default.Fitness != Fitness)
			Fitness=0.5*Fitness;
		}
	}


simulated function SetAnimStanding()
	{
	local EWeaponHoldStyle hold;
	local WeaponAttachment wpattach;

	// Check if player is typing
	if ( (PlayerController(Controller) != None) && PlayerController(Controller).bIsTyping )
		return;

	hold = GetWeaponHoldStyle();
	if(MyWeapAttach != None)
		wpattach = MyWeapAttach;
	else if(Weapon != None)
		wpattach = WeaponAttachment(Weapon.ThirdPersonActor);


	if ((hold != WEAPONHOLDSTYLE_None) && (mood == MOOD_Combat))
		{
		switch(GetWeaponHoldStyle())
			{
			case WEAPONHOLDSTYLE_Single:
				if(!bLeftFoot)
					LoopIfNeeded('ss_base_singleframe', 1.0);
				else
					LoopIfNeeded('ss_base_singleframe2', 1.0);
				break;
			case WEAPONHOLDSTYLE_Dual:
				LoopIfNeeded('sb2_base_singleframe', 1.0);
				break;
			case WEAPONHOLDSTYLE_DualBig:
				LoopIfNeeded('sb3_base_singleframe', 1.0);
				break;
			case WEAPONHOLDSTYLE_Both:
				if(bIsTrained)
					LoopIfNeeded('sd1_base2', 1.0);
				else
					LoopIfNeeded('sd2_base', 1.0);
				break;
			case WEAPONHOLDSTYLE_Double:
				if(bIsTrained)
					LoopIfNeeded('sd1_base', 1.0);
				else
					LoopIfNeeded('sd2_base', 1.0);
				break;
			case WEAPONHOLDSTYLE_Pour:
				LoopIfNeeded('sd_base_gas', 1.0);
				break;
			case WEAPONHOLDSTYLE_Carry:
				LoopIfNeeded('sc_base', 1.0);
				break;
			case WEAPONHOLDSTYLE_Toss:
				LoopIfNeeded('sg_base', 1.0);
				break;
			case WEAPONHOLDSTYLE_Melee:
				if(wpattach != None
					&& (wpattach.FiringMode == 'SHOVEL1'
						|| wpattach.FiringMode == 'BASEBALLBAT1'
						|| wpattach.FiringMode == 'WEED1'))
					LoopIfNeeded('sd_base', 1.0);
				else if (wpattach != None
					&& wpattach.FiringMode == 'CLIPPER1')
					LoopIfNeeded('shears_idle', 1.0);
				else
					LoopIfNeeded('s_base1', 1.0);
				break;

			case WEAPONHOLDSTYLE_None:
			default:
				Warn("Unknown EWeaponHoldStyle");
				break;
			}
		}
	else
		{
		LoopIfNeeded(GetAnimStand(), 1.0 + FRand()/10);
		}
	}

simulated function MaybeUseSpecialWalkAnim(name SpecialWalkAnim)
{
	SetAnimWalking();
	if (SpecialWalkAnim != ''
		&& mood == MOOD_Normal)
		{
			TurnLeftAnim = SpecialWalkAnim;
			TurnRightAnim = SpecialWalkAnim;
			MovementAnims[0] = SpecialWalkAnim;
			MovementAnims[1] = SpecialWalkAnim;
			MovementAnims[2] = SpecialWalkAnim;
			MovementAnims[3] = SpecialWalkAnim;
		}
}

simulated function SetAnimWalking()
	{
	local EWeaponHoldStyle hold;
	local name useanim1, useanim2;
	local WeaponAttachment wpattach;

	// prep for defaults
	WalkingPct			= GetDefaultWalkingPct();
	MovementPct			= GetDefaultMovementPct();

	if(mood == MOOD_Combat
		|| mood == MOOD_Scared)
		// Since we've got a weapon out or are scared, make sure to rotate faster now
		RotationRate = CombatRotationRate;
	else
		// Since we've *don't* a weapon out, make sure to rotate slower now
		RotationRate = default.RotationRate;

	hold = GetWeaponHoldStyle();

	if(MyWeapAttach != None)
		wpattach = MyWeapAttach;
	else if(Weapon != None)
		wpattach = WeaponAttachment(Weapon.ThirdPersonActor);

	if ((hold != WEAPONHOLDSTYLE_None) && (mood == MOOD_Combat))
		{
		switch (GetWeaponHoldStyle())
			{
			case WEAPONHOLDSTYLE_Single:
				TurnLeftAnim		= 'ss_base_singleframe';
				TurnRightAnim		= 'ss_base_singleframe';
				MovementAnims[0]	= 'ss_walk';
				if(!AllowBackpeddle())
					MovementAnims[1]	= MovementAnims[0];
				else
					MovementAnims[1]	= 'ss_walkback';
				MovementAnims[2]	= 'ss_strafel';
				MovementAnims[3]	= 'ss_strafer';
				WalkingPct			= SingleGunWalkPct;
				break;
			case WEAPONHOLDSTYLE_Dual:
				TurnLeftAnim		= 'sb2_base_singleframe';
				TurnRightAnim		= 'sb2_base_singleframe';
				MovementAnims[0]	= 'sb2_walk';
				if(!AllowBackpeddle())
					MovementAnims[1]	= MovementAnims[0];
				else
					MovementAnims[1]	= 'sb2_walk';
				MovementAnims[2]	= 'sb2_strafel';
				MovementAnims[3]	= 'sb2_strafer';
				WalkingPct			= SingleGunWalkPct;
				break;
			case WEAPONHOLDSTYLE_DualBig:
				TurnLeftAnim		= 'sb3_base_singleframe';
				TurnRightAnim		= 'sb3_base_singleframe';
				MovementAnims[0]	= 'sb3_walk';
				if(!AllowBackpeddle())
					MovementAnims[1]	= MovementAnims[0];
				else
					MovementAnims[1]	= 'sb3_walk';
				MovementAnims[2]	= 'sb3_strafel';
				MovementAnims[3]	= 'sb3_strafer';
				WalkingPct			= SingleGunWalkPct;
				break;
			case WEAPONHOLDSTYLE_Both:
				if(bIsTrained)
				{
					useanim1	= 'sd1_base2';
					useanim2	= 'sd1_walk';
				}
				else
				{
					useanim1	= 'sd2_base';
					useanim2	= 'sd2_walk';
				}

				TurnLeftAnim		= useanim1;
				TurnRightAnim		= useanim1;
				MovementAnims[0]	= useanim2;
				if(!AllowBackpeddle())
					MovementAnims[1]	= MovementAnims[0];
				else
					MovementAnims[1]	= 'sd1_walkback';
				// Just use sd2 for both strafes here, because it doesn't matter much otherwise
				MovementAnims[2]	= 'sd2_strafel';
				MovementAnims[3]	= 'sd2_strafer';
				WalkingPct			= DoubleGunWalkPct;
				break;
			case WEAPONHOLDSTYLE_Double:
				if(bIsTrained)
				{
					useanim1	= 'sd1_base';
					useanim2	= 'sd1_walk';
				}
				else
				{
					useanim1	= 'sd2_base';
					useanim2	= 'sd2_walk';
				}

				TurnLeftAnim		= useanim1;
				TurnRightAnim		= useanim1;
				MovementAnims[0]	= useanim2;
				if(!AllowBackpeddle())
					MovementAnims[1]	= MovementAnims[0];
				else
					MovementAnims[1]	= 'sd1_walkback';
				// Just use sd2 for both strafes here, because it doesn't matter much otherwise
				MovementAnims[2]	= 'sd2_strafel';
				MovementAnims[3]	= 'sd2_strafer';
				WalkingPct			= DoubleGunWalkPct;
				break;
			case WEAPONHOLDSTYLE_Pour:
				TurnLeftAnim		= 'sd_base_gas';//'ss_turn_right';
				TurnRightAnim		= 'sd_base_gas';//'ss_turn_right';
				MovementAnims[0]	= 'sd_walk_gas';
				MovementAnims[1]	= 'sd_walk_gas';
				MovementAnims[2]	= 's_strafel';
				MovementAnims[3]	= 's_strafer';
				WalkingPct			= SingleGunWalkPct;
				break;
			case WEAPONHOLDSTYLE_Carry:
				TurnLeftAnim		= 'sc_base';//'ss_turn_right';
				TurnRightAnim		= 'sc_base';//'ss_turn_right';
				MovementAnims[0]	= 'sc_walk';
				MovementAnims[1]	= 'sc_walk';
				MovementAnims[2]	= 'sc_walk';
				MovementAnims[3]	= 'sc_walk';
				WalkingPct			= SingleGunWalkPct;
				break;
			case WEAPONHOLDSTYLE_Toss:
				TurnLeftAnim		= 'sg_base';//'ss_turn_right';
				TurnRightAnim		= 'sg_base';//'ss_turn_right';
				MovementAnims[0]	= 'sg_walk';
				MovementAnims[1]	= 'sg_walk';
				MovementAnims[2]	= 's_strafel';
				MovementAnims[3]	= 's_strafer';
				//WalkingPct			= SingleGunWalkPct;
				break;
			case WEAPONHOLDSTYLE_Melee:
				if(wpattach != None
					&& (wpattach.FiringMode == 'SHOVEL1' || wpattach.FiringMode == 'WEED1'))
				{
					TurnLeftAnim		= 'sd_base';//'ss_turn_right';
					TurnRightAnim		= 'sd_base';//'ss_turn_right';
					MovementAnims[0]	= 'sd_walk';
					MovementAnims[1]	= 'sd_walk';
					MovementAnims[2]	= 's_strafel';
					MovementAnims[3]	= 's_strafer';
					//WalkingPct			= SingleGunWalkPct;
				}
				else if (wpattach != None
					&& wpattach.FiringMode == 'CLIPPER1')
				{
					TurnLeftAnim		= 'shears_idle';//'ss_turn_right';
					TurnRightAnim		= 'shears_idle';//'ss_turn_right';
					MovementAnims[0]	= 'HTWALK';
					MovementAnims[1]	= 'HTWALK';
					MovementAnims[2]	= 's_strafel';
					MovementAnims[3]	= 's_strafer';
				}
				else
				{
					TurnLeftAnim		= 's_base1';//'ss_turn_right';
					TurnRightAnim		= 's_base1';//'ss_turn_right';
					MovementAnims[0]	= 's_walk1';
					MovementAnims[1]	= 's_walk1';
					MovementAnims[2]	= 's_strafel';
					MovementAnims[3]	= 's_strafer';
					//WalkingPct			= SingleGunWalkPct;
				}
				break;

			case WEAPONHOLDSTYLE_None:

			default:
				Warn("Unknown EWeaponHoldStyle");
				break;
			}
		}
	else
		{
		// Only use you're funky ghetto or cool walks if you're in a normal mood..
		// if you're scared, then walk normal.

		if (bIsFeminine
			&& mood == MOOD_Normal)
			{
			if (bIsGhetto)
				{
				TurnLeftAnim		= 's_turn1';
				TurnRightAnim		= 's_turn1';
				switch(AnimGroupUsed)
				{
					case 0:
						MovementAnims[0]	= 'sf_walk1';
						if(!AllowBackpeddle())
							MovementAnims[1]	= MovementAnims[0];
						else
							MovementAnims[1]	= 's_walkback';
						break;
					case 1:
						MovementAnims[0]	= 'sf_walk3';
						if(!AllowBackpeddle())
							MovementAnims[1]	= MovementAnims[0];
						else
							MovementAnims[1]	= 's_walkback';
						break;
				}
				WalkingPct			= GhettoFemWalkPct;
				}
			else
				{
				TurnLeftAnim		= 's_turn1';
				TurnRightAnim		= 's_turn1';
				if (AnimGroupUsed == 0)
					MovementAnims[0]	= 'sf_walk2';
				else
					MovementAnims[0]	= 'pl_s_catwalk';
				if(!AllowBackpeddle())
					MovementAnims[1]	= MovementAnims[0];
				else
					MovementAnims[1]	= 's_walkback';
				WalkingPct			= FemWalkPct;
				}
			}
		else
			{
			if (bIsGhetto
				&& mood == MOOD_Normal)
				{
				TurnLeftAnim		= 's_turn1';
				TurnRightAnim		= 's_turn1';
				MovementAnims[0]	= 's_walk3';
				if(!AllowBackpeddle())
					MovementAnims[1]	= MovementAnims[0];
				else
					MovementAnims[1]	= 's_walkback';
				WalkingPct			= GhettoWalkPct;
				}
			else
				{
				TurnLeftAnim		= 's_turn1';
				TurnRightAnim		= 's_turn1';
				// Make sure military walk all tough with their guns out
				if(bIsTrained
					&& hold == WEAPONHOLDSTYLE_Both
					&& HasAnim('sd4_walk'))
					useanim1	= 'sd4_walk';
				else // normal people walk
				{
					switch(AnimGroupUsed)
					{
						case 0:
							useanim1	= 's_walk1';
							useanim1	= 's_walk1';
							break;
						case 1:
							useanim1	= 's_walk4';
							useanim1	= 's_walk4';
							break;
					}
				}
				MovementAnims[0]	= useanim1;
				if(!AllowBackpeddle())
					MovementAnims[1]	= MovementAnims[0];
				else
					MovementAnims[1]	= 's_walkback';
				}
			}

		// If you're in combat mode, or scared, use a strafe
		if(mood == MOOD_Combat
			|| mood == MOOD_Scared)
			{
			MovementAnims[2]	= 's_strafel';
			MovementAnims[3]	= 's_strafer';
			}
		else	// Normal people just use their walk cycles to strafe
			{
			MovementAnims[2]	= MovementAnims[0];
			MovementAnims[3]	= MovementAnims[0];
			}
		}
		// If holding a briefcase, use the briefcase walk
		if (bNoExtendedAnims)
		{
			MovementAnims[0] = 'holding_walk';
			MovementAnims[1] = 'holding_walk';
			MovementAnims[2] = 'holding_walk';
			MovementAnims[3] = 'holding_walk';
		}
		// If we have a special walk anim set, use that over everything
		if (SpecialHoldWalkAnim != '')
		{
			MovementAnims[0] = SpecialHoldWalkAnim;
			MovementAnims[1] = SpecialHoldWalkAnim;
			MovementAnims[2] = SpecialHoldWalkAnim;
			MovementAnims[3] = SpecialHoldWalkAnim;
		}
	}


simulated function SetAnimRunning()
	{
	local EWeaponHoldStyle hold;
	local WeaponAttachment wpattach;
	local float attackerdot;
	local name useanim1;

	if(mood == MOOD_Combat
		|| mood == MOOD_Scared)
		// Since we've got a weapon out, make sure to rotate faster now
		RotationRate = CombatRotationRate;
	else
		// Since we've *don't* a weapon out, make sure to rotate slower now
		RotationRate = default.RotationRate;

	// Everyone runs the same on fire
	if (MyBodyFire != None)
		{
		TurnLeftAnim		= 's_run1a';
		TurnRightAnim		= 's_run1a';
		MovementAnims[0]	= 's_run1a';
		if(!AllowBackpeddle())
			MovementAnims[1]	= MovementAnims[0];
		else
			MovementAnims[1]	= 's_runback';
		MovementAnims[2]	= 's_run1a';
		MovementAnims[3]	= 's_run1a';
		}
	// Or if blind
	else if (Controller.IsInState('RunningBlind'))
		{
			TurnLeftAnim		= 'pl_run_blind';
			TurnRightAnim		= 'pl_run_blind';
			MovementAnims[0]	= 'pl_run_blind';
			if(!AllowBackpeddle())
				MovementAnims[1]	= MovementAnims[0];
			else
				MovementAnims[1]	= 's_runback';
			MovementAnims[2]	= 'pl_run_blind';
			MovementAnims[3]	= 'pl_run_blind';
		}
	else
		{
		hold = GetWeaponHoldStyle();

		if(MyWeapAttach != None)
			wpattach = MyWeapAttach;
		else if(Weapon != None)
			wpattach = WeaponAttachment(Weapon.ThirdPersonActor);

		if ((hold != WEAPONHOLDSTYLE_None) && (mood == MOOD_Combat))
			{
			switch (GetWeaponHoldStyle())
				{
				case WEAPONHOLDSTYLE_Single:
					if(Level.Game != None
						&& FPSGameInfo(Level.Game).bIsSinglePlayer)
					{
						if(bIsTrained)
						{
							// Hold pistol various ways
							if(FRand() < 0.5)
								useanim1 = 'ss_run';
							else
								useanim1 = 'ss_run2';
						}
						else // just run, untrained, with pistol at side
							useanim1 = 's_run2';
					}
					else	// MP running forward with a pistol (because you can shoot while running
						// the pistol) as opposed to SP AI.
						useanim1='ss_run3';

					TurnLeftAnim		= 'ss_base_singleframe';
					TurnRightAnim		= 'ss_base_singleframe';
					MovementAnims[0]	= useanim1;
					if(!AllowBackpeddle())
						MovementAnims[1]	= MovementAnims[0];
					else
						MovementAnims[1]	= 'ss_runback';
					MovementAnims[2]	= 'ss_strafel';
					MovementAnims[3]	= 'ss_strafer';
					break;
				case WEAPONHOLDSTYLE_Dual:
					TurnLeftAnim		= 'sb2_base_singleframe';
					TurnRightAnim		= 'sb2_base_singleframe';
					MovementAnims[0]	= 'sb2_run';
					if(!AllowBackpeddle())
						MovementAnims[1]	= MovementAnims[0];
					else
						MovementAnims[1]	= 'sb2_run';
					MovementAnims[2]	= 'sb2_strafel';
					MovementAnims[3]	= 'sb2_strafer';
					break;
				case WEAPONHOLDSTYLE_DualBig:
					TurnLeftAnim		= 'sb3_base_singleframe';
					TurnRightAnim		= 'sb3_base_singleframe';
					MovementAnims[0]	= 'sb3_run';
					if(!AllowBackpeddle())
						MovementAnims[1]	= MovementAnims[0];
					else
						MovementAnims[1]	= 'sb3_run';
					MovementAnims[2]	= 'sb3_strafel';
					MovementAnims[3]	= 'sb3_strafer';
					break;
				case WEAPONHOLDSTYLE_Both:
					if(bIsTrained)
					{
						TurnLeftAnim		= 'sd1_base2';
						TurnRightAnim		= 'sd1_base2';
						MovementAnims[0]	= 'sd1_run';
						if(!AllowBackpeddle())
							MovementAnims[1]	= MovementAnims[0];
						else
							MovementAnims[1]	= 'sd1_runback';
					}
					else
					{
						TurnLeftAnim		= 'sd2_base';
						TurnRightAnim		= 'sd2_base';
						MovementAnims[0]	= 'sd2_run';
						if(!AllowBackpeddle())
							MovementAnims[1]	= MovementAnims[0];
						else
							MovementAnims[1]	= 'sd1_runback';
					}
					MovementAnims[2]	= 'sd2_strafel';
					MovementAnims[3]	= 'sd2_strafer';
					break;
				case WEAPONHOLDSTYLE_Double:
					if(bIsTrained)
					{
						TurnLeftAnim		= 'sd1_base';
						TurnRightAnim		= 'sd1_base';
						MovementAnims[0]	= 'sd1_run';
						if(!AllowBackpeddle())
							MovementAnims[1]	= MovementAnims[0];
						else
							MovementAnims[1]	= 'sd1_runback';
					}
					else
					{
						TurnLeftAnim		= 'sd2_base';
						TurnRightAnim		= 'sd2_base';
						MovementAnims[0]	= 'sd2_run';
						if(!AllowBackpeddle())
							MovementAnims[1]	= MovementAnims[0];
						else
							MovementAnims[1]	= 'sd1_runback';
					}
					MovementAnims[2]	= 'sd2_strafel';
					MovementAnims[3]	= 'sd2_strafer';
					break;
				case WEAPONHOLDSTYLE_Pour:
					TurnLeftAnim		= 'sd_base_gas';
					TurnRightAnim		= 'sd_base_gas';
					MovementAnims[0]	= 'sd_run_gas';
					MovementAnims[1]	= 'sd_run_gas';
					MovementAnims[2]	= 's_strafel';
					MovementAnims[3]	= 's_strafer';
					break;
				case WEAPONHOLDSTYLE_Carry:
					TurnLeftAnim		= 'sc_base';
					TurnRightAnim		= 'sc_base';
					MovementAnims[0]	= 'sc_run';
					MovementAnims[1]	= 'sc_run';
					MovementAnims[2]	= 'sc_run';
					MovementAnims[3]	= 'sc_run';
					break;
				case WEAPONHOLDSTYLE_Toss:
					TurnLeftAnim		= 'sg_base';
					TurnRightAnim		= 'sg_base';
					MovementAnims[0]	= 'sg_run';
					MovementAnims[1]	= 'sg_run';
					MovementAnims[2]	= 'sg_run';
					MovementAnims[3]	= 'sg_run';
					break;
				case WEAPONHOLDSTYLE_Melee:
					if(wpattach != None
						&& (wpattach.FiringMode == 'SHOVEL1' || wpattach.FiringMode == 'WEED1'))
					{
						TurnLeftAnim		= 'sd_base';
						TurnRightAnim		= 'sd_base';
						MovementAnims[0]	= 'sd_run';
						MovementAnims[1]	= 'sd_run';
						MovementAnims[2]	= 'sd_run';
						MovementAnims[3]	= 'sd_run';
					}
					else if (wpattach != None
						&& wpattach.FiringMode == 'CLIPPER1')
					{
						TurnLeftAnim		= 'shears_idle';//'ss_turn_right';
						TurnRightAnim		= 'shears_idle';//'ss_turn_right';
						MovementAnims[0]	= 'HTrun';
						MovementAnims[1]	= 'HTrun';
						MovementAnims[2]	= 'HTrun';
						MovementAnims[3]	= 'HTrun';
					}
					else
					{
						TurnLeftAnim		= 's_base1';
						TurnRightAnim		= 's_base1';
						MovementAnims[0]	= 's_run2';
						if(!AllowBackpeddle())
							MovementAnims[1]	= MovementAnims[0];
						else
							MovementAnims[1]	= 's_runback';
						MovementAnims[2]	= 's_run2';
						MovementAnims[3]	= 's_run2';
					}
					break;

				case WEAPONHOLDSTYLE_None:
				default:
					Warn("Unknown EWeaponHoldStyle");
					break;
				}
			}
		else
			{
			TurnLeftAnim		= 's_turn1';//'s_look_left';
			TurnRightAnim		= 's_turn1';//'s_look_right';
			if (mood == MOOD_Scared)
				{
					// If this didn't determine our run for us, then pick one ourselves.
					if(PersonController(Controller) == None
						|| !PersonController(Controller).CalcScaredRunAnim())
						{
						MovementAnims[0]	= 's_run1t1';
						if(!AllowBackpeddle())
							MovementAnims[1]	= MovementAnims[0];
						else
							MovementAnims[1]	= 's_runback';
						MovementAnims[2]	= 's_run1t1';
						MovementAnims[3]	= 's_run1t1';
						}
				}
			else
				{
				if (bIsFeminine)
					{
					MovementAnims[0]	= 'sf_run2';
					if(!AllowBackpeddle())
						MovementAnims[1]	= MovementAnims[0];
					else
						MovementAnims[1]	= 's_runback';
					MovementAnims[2]	= 'sf_run2';
					MovementAnims[3]	= 'sf_run2';
					}
				else
					{
					MovementAnims[0]	= 's_run2';
					if(!AllowBackpeddle())
						MovementAnims[1]	= MovementAnims[0];
					else
						MovementAnims[1]	= 's_runback';
					MovementAnims[2]	= 's_run2';
					MovementAnims[3]	= 's_run2';
					}
				}
			}
		}
	}


simulated function SetAnimStartCrouching()
	{
		PlayAnim(GetAnimStartCrouch(), 1.0, 0.25);
	}


simulated function SetAnimCrouching()
	{
	local name OldAnim;
	local float OldFrame,OldRate;
	local name crouch;


	// See what animation is currently playing
	GetAnimParams(0, OldAnim, OldFrame, OldRate);
	if (OldAnim != GetAnimStartCrouch())
		{
		crouch = GetAnimCrouch();
		if (OldAnim != crouch)
			PlayAnim(crouch, 1.0, 0.00);	// was 0.25 for blending
		else
			PlayAnim(crouch);
		}
	}

simulated function SetAnimEndCrouching()
	{
	PlayAnim(GetAnimEndCrouch(), 1.0, 0.25);
	}

simulated function SetAnimCrouchWalking()
	{
	local EWeaponHoldStyle hold;

	// prep for defaults
	WalkingPct			= default.WalkingPct;
	MovementPct			= default.MovementPct;


	hold = GetWeaponHoldStyle();
	if ((hold != WEAPONHOLDSTYLE_None) && (mood == MOOD_Combat))
		{
		switch (GetWeaponHoldStyle())
			{
			case WEAPONHOLDSTYLE_Single:
				TurnLeftAnim		= GetAnimCrouch();
				TurnRightAnim		= GetAnimCrouch();
				MovementAnims[0]	= 'cs_walk';
				MovementAnims[1]	= 'cs_walk';
				MovementAnims[2]	= 'cs_strafel';
				MovementAnims[3]	= 'cs_strafer';
				break;
			case WEAPONHOLDSTYLE_Dual:
				TurnLeftAnim		= GetAnimCrouch();
				TurnRightAnim		= GetAnimCrouch();
				MovementAnims[0]	= 'cb2_walk';
				MovementAnims[1]	= 'cb2_walk';
				MovementAnims[2]	= 'cb2_strafel';
				MovementAnims[3]	= 'cb2_strafer';
				break;
			case WEAPONHOLDSTYLE_DualBig:
				TurnLeftAnim		= GetAnimCrouch();
				TurnRightAnim		= GetAnimCrouch();
				MovementAnims[0]	= 'cb3_walk';
				MovementAnims[1]	= 'cb3_walk';
				MovementAnims[2]	= 'cb3_strafel';
				MovementAnims[3]	= 'cb3_strafer';
				break;
			case WEAPONHOLDSTYLE_Both:
			case WEAPONHOLDSTYLE_Double:
				TurnLeftAnim		= GetAnimCrouch();
				TurnRightAnim		= GetAnimCrouch();
				MovementAnims[0]	= 'cd_walk';
				MovementAnims[1]	= 'cd_walk';
				MovementAnims[2]	= 'cd_strafel';
				MovementAnims[3]	= 'cd_strafer';
				break;
			case WEAPONHOLDSTYLE_Pour:
				TurnLeftAnim		= GetAnimCrouch();
				TurnRightAnim		= GetAnimCrouch();
				MovementAnims[0]	= 'cs_walk';
				MovementAnims[1]	= 'cs_walk';
				MovementAnims[2]	= 'cs_strafel';
				MovementAnims[3]	= 'cs_strafer';
				break;
			case WEAPONHOLDSTYLE_Carry:
				TurnLeftAnim		= GetAnimCrouch();
				TurnRightAnim		= GetAnimCrouch();
				MovementAnims[0]	= 'cs_walk';
				MovementAnims[1]	= 'cs_walk';
				MovementAnims[2]	= 'cs_strafel';
				MovementAnims[3]	= 'cs_strafer';
				break;
			case WEAPONHOLDSTYLE_Toss:
				TurnLeftAnim		= GetAnimCrouch();
				TurnRightAnim		= GetAnimCrouch();
				MovementAnims[0]	= 'c_walk';
				MovementAnims[1]	= 'c_walk';
				MovementAnims[2]	= 'cs_strafel';
				MovementAnims[3]	= 'cs_strafer';
				break;
			case WEAPONHOLDSTYLE_Melee:
				TurnLeftAnim		= GetAnimCrouch();
				TurnRightAnim		= GetAnimCrouch();
				MovementAnims[0]	= 'c_walk';
				MovementAnims[1]	= 'c_walk';
				MovementAnims[2]	= 'cs_strafel';
				MovementAnims[3]	= 'cs_strafer';
				break;

			case WEAPONHOLDSTYLE_None:
			default:
				Warn("Unknown EWeaponHoldStyle");
				break;
			}
		}
	else
		{
		// Crouch with or without weapon
		TurnLeftAnim = 'c_walk';//'c_lookl';
		TurnRightAnim = 'c_walk';//'c_lookr';
		MovementAnims[0] = 'c_walk';
		MovementAnims[1] = 'c_walk';
		MovementAnims[2] = 'c_strafel';
		MovementAnims[3] = 'c_strafer';
//		MovementAnimRate[0] = 1.0;
//		MovementAnimRate[1] = 1.0;
//		MovementAnimRate[2] = 1.0;
//		MovementAnimRate[3] = 1.0;
		}
	}

simulated function SetAnimStartDeathCrawling()
	{
	PlayAnim(GetAnimStartDeathCrawling(), 1.0, 0.25);
	}

simulated function SetAnimEndDeathCrawling()
	{
	PlayAnim(GetAnimEndDeathCrawling(), 1.0, 0.25);
	}

simulated function SetAnimDeathCrawlWait()
	{
	local name OldAnim;
	local float OldFrame,OldRate;
	local name dcrawl;

	// See what animation is currently playing
	GetAnimParams(0, OldAnim, OldFrame, OldRate);
	if(OldAnim != GetAnimStartDeathCrawling())
		{
		dcrawl = GetAnimDeathCrawl();
		if (OldAnim != dcrawl)
			PlayAnim(dcrawl, 1.0, 0.00);
		else
			PlayAnim(dcrawl);
		}
	}
	
simulated function SetAnimStartKnockOut()
	{
	PlayAnim(GetAnimStartKnockOut(), 1.0, 0.25);
	}

simulated function SetAnimEndKnockOut()
	{
	PlayAnim(GetAnimEndKnockOut(), 1.0, 0.25);
	}
simulated function SetAnimKnockedOut()
{
	local name dcrawl;
	// set speeds

	WalkingPct			= DeathCrawlingPct;
	MovementPct			= default.MovementPct;

//	WalkingPct			= default.WalkingPct;
//	MovementPct			= DeathCrawlingPct;

	dcrawl = GetAnimKnockedOut();

	// Crouch with or without weapon
	TurnLeftAnim     = dcrawl;
	TurnRightAnim	 = dcrawl;
	MovementAnims[0] = dcrawl;
	MovementAnims[1] = dcrawl;
	MovementAnims[2] = dcrawl;
	MovementAnims[3] = dcrawl;
}	

simulated function SetAnimDeathCrawling()
	{
	local name dcrawl;
	// set speeds

	WalkingPct			= DeathCrawlingPct;
	MovementPct			= default.MovementPct;

//	WalkingPct			= default.WalkingPct;
//	MovementPct			= DeathCrawlingPct;

	dcrawl = GetAnimDeathCrawl();

	// Crouch with or without weapon
	TurnLeftAnim     = dcrawl;
	TurnRightAnim	 = dcrawl;
	MovementAnims[0] = dcrawl;
	MovementAnims[1] = dcrawl;
	MovementAnims[2] = dcrawl;
	MovementAnims[3] = dcrawl;
	}

event StartDeathCrawl(float HeightAdjust)
	{
	If(!bUpdateEyeHeight)
		EyeHeight -= HeightAdjust;
	OldZ -= HeightAdjust;
	BaseEyeHeight = HEAD_PERCENT * DeathCrawlHeight;

	RotationRate = DeathCrawlRotationRate;
	if (bIsKnockedOut)
		SetAnimStartKnockOut();
	else
		SetAnimStartDeathCrawling();
	}


event EndDeathCrawl(float HeightAdjust)
	{
	If(!bUpdateEyeHeight)
		EyeHeight += HeightAdjust;
	OldZ += HeightAdjust;
	BaseEyeHeight = Default.BaseEyeHeight;

	RotationRate = default.RotationRate;
	if (bIsKnockedOut)
		SetAnimEndKnockOut();
	else
		SetAnimEndDeathCrawling();
	}

simulated function SetAnimProtesting()
	{
		// set speeds
		WalkingPct			= default.WalkingPct;
		MovementPct			= ProtestingPct;

		TurnLeftAnim = 's_protest';
		TurnRightAnim = 's_protest';
		MovementAnims[0] = 's_protest';
		MovementAnims[1] = 's_protest';
		MovementAnims[2] = 's_protest';
		MovementAnims[3] = 's_protest';
	}

simulated function SetAnimMarching()
	{
		// set speeds
		WalkingPct			= default.WalkingPct;
		MovementPct			= MarchingPct;

		TurnLeftAnim = 's_march';
		TurnRightAnim = 's_march';
		MovementAnims[0] = 's_march';
		MovementAnims[1] = 's_march';
		MovementAnims[2] = 's_march';
		MovementAnims[3] = 's_march';
	}


simulated function SetAnimClimbing()
	{
	local name NewAnim;
	local int i;
	
	if ( (OnLadder == None) || (OnLadder.ClimbingAnimation == '') )
		NewAnim = GetAnimClimb(); 
	else
		NewAnim = OnLadder.ClimbingAnimation;
	for ( i=0; i<4; i++ )
		MovementAnims[i] = NewAnim;
	TurnLeftAnim = NewAnim;
	TurnRightAnim = NewAnim;
	}


simulated function SetAnimStoppedOnLadder()
	{
	local name NewAnim;
	
	if ( (OnLadder == None) || (OnLadder.ClimbingAnimation == '') )
		NewAnim = GetAnimClimb(); 
	else
		NewAnim = OnLadder.ClimbingAnimation;
	LoopIfNeeded('s_wait_ladder', 1.0);
	//TweenAnim(NewAnim, 1.0); // FIXME TEMP - need paused on ladder animation
	}


simulated function SetAnimSwimming()
	{
	// Should never be used, but fill in something just in case
	MovementAnims[0] = 'c_walk';
	MovementAnims[1] = 'c_walk';
	MovementAnims[2] = 'c_walk';
	MovementAnims[3] = 'c_walk';
//	MovementAnimRate[0] = 1.0;
//	MovementAnimRate[1] = 1.0;
//	MovementAnimRate[2] = 1.0;
//	MovementAnimRate[3] = 1.0;
	}


simulated function SetAnimTreading()
	{
	// Should never be used, but fill in something just in case
	SetAnimSwimming();
	}


simulated function SetAnimFlying()
	{
	// Should never be used, but fill in something just in case
	SetAnimSwimming();
	}


///////////////////////////////////////////////////////////////////////////////
// Specifically play the anim of pulling the grenade pin.
// Must use AnimAction to work on remote clients.
///////////////////////////////////////////////////////////////////////////////
simulated function PlayGrenadePullPin()
{
	SetAnimAction('sg_pull_pin');
}
///////////////////////////////////////////////////////////////////////////////
//	Kick low (like you're kicking a dead body)
///////////////////////////////////////////////////////////////////////////////
simulated function PerformKick()
{
	SetAnimAction(GetAnimKick());
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayGrenadeSuicideAnim()
{
	SetAnimAction('s_suicide2');
}

///////////////////////////////////////////////////////////////////////////////
// MpPawn
///////////////////////////////////////////////////////////////////////////////
simulated function DoFollowMe()
{
	// STUB
}
function ServerFollowMe()
{
	if(Controller != None
		&& !Controller.IsInState('PlayerSuicideByGrenade'))
		SetAnimAction(FOLLOW_ME);
}
simulated function DoStayHere()
{
	// STUB
}
function ServerStayHere()
{
	if(Controller != None
		&& !Controller.IsInState('PlayerSuicideByGrenade'))
		SetAnimAction(STAY_HERE);
}

///////////////////////////////////////////////////////////////////////////////
// Function that determines how to play all these specific animations.
// Needed complexity to work on remote clients (otherwise only the guy
// on his own machine could see his pawn animating like the following and
// no one elses.)
///////////////////////////////////////////////////////////////////////////////
simulated event SetAnimAction(name NewAction)
{
    AnimAction = NewAction;
  //  if (!bWaitForAnim)
    //{
		// Pulling pin on grenade to throw it as a weapon
		if ( AnimAction == 'sg_pull_pin' )
        {
			WeaponBlendTime = FIRING_BLEND_TIME;
			AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
            PlayAnim(NewAction, 1.0, 0.1, WEAPONCHANNEL);
        }
		// Grenade suicide
		else if(AnimAction == 's_suicide2')
		{
			PlayAnim(AnimAction, 1.5, 0.15);
		}
		// third person kicking
		else if(AnimAction == GetAnimKick())
		{
			//PlayAnim(AnimAction, 5.0, 0.15);
			PlayAnim(AnimAction, 1.5, 0.15);
		}
		// hack for swapping to burned mesh in MP
		else if(AnimAction == BURN_ACTION_MP)
		{
			SwapToBurnVictim();
		}
		else if(AnimAction == FOLLOW_ME)
		{
			DoFollowMe();
		}
		else if(AnimAction == STAY_HERE)
		{
			DoStayHere();
		}
//	}
}

simulated function name GetAnimStand()
	{
	// If holding a briefcase, return idle briefcase anim
	if (SpecialHoldStandAnim != '')
		return SpecialHoldStandAnim;
	else if (bNoExtendedAnims)
		return 'holding_idle';

	// Just stand normally with or without weapon
	if (bIsFeminine
		&& mood == MOOD_Normal)
		return 'sf_base1';
	else
		return 's_base1';
	}


simulated function name GetAnimStartCrouch()
	{
	// We don't have the proper transition yet so just go right to crouching
	return GetAnimCrouch();
	}


simulated function name GetAnimEndCrouch()
	{
	// We don't have the proper transition yet so just go right to standing
	return GetAnimStand();
	}


simulated function name GetAnimCrouch()
	{
	local name nameAnim;
	local EWeaponHoldStyle hold;

	hold = GetWeaponHoldStyle();
	if ((hold != WEAPONHOLDSTYLE_None) && (mood == MOOD_Combat))
		{
		switch (GetWeaponHoldStyle())
			{
			case WEAPONHOLDSTYLE_Single:
				nameAnim = 'cs_shoot_loop';
				break;
			case WEAPONHOLDSTYLE_Dual:
				nameAnim = 'cb2_base_singleframe';
				break;
			case WEAPONHOLDSTYLE_DualBig:
				nameAnim = 'cb3_base_singleframe';
				break;
			case WEAPONHOLDSTYLE_Both:
			case WEAPONHOLDSTYLE_Double:
				nameAnim = 'cd_base_singleframe';
				break;
			case WEAPONHOLDSTYLE_Pour:
			case WEAPONHOLDSTYLE_Carry:
				nameAnim = 'cs_shoot_loop';
				break;
			case WEAPONHOLDSTYLE_Toss:
				nameAnim = 'c_base_pose';
				break;
			case WEAPONHOLDSTYLE_Melee:
				nameAnim = 'c_base_pose';
				break;

			case WEAPONHOLDSTYLE_None:
			default:
				Warn("Unknown EWeaponHoldStyle");
				break;
			}
		}
	else
		{
		// Normally just get this base pose for crouching, but if your controller
		// says you're begging, then use the other instead
		if(PersonController(Controller) != None
			&& PersonController(Controller).IsBegging())
			nameAnim = GetAnimCrouchBeggingIdle();
		else
			nameAnim = 'c_base_pose';
		}

	return nameAnim;
	}

simulated function name GetAnimDeathCrawlDeath()
{
		return 'p_death1';
}
simulated function name GetAnimDeathCrawl()
{
		return 'p_deathcrawl';
}
simulated function name GetAnimStartDeathCrawling()
{
	// we have no proper transition--same problem with crouch.
	return GetAnimDeathCrawl();
}
simulated function name GetAnimEndDeathCrawling()
{
	// We don't have the proper transition yet so just go right to standing
	return GetAnimStand();
}
simulated function name GetAnimKnockedOut()
{
	return 'ko_loop1';
}
simulated function name GetAnimStartKnockOut()
{
	return 'ko_falldown';
}
simulated function name GetAnimEndKnockOut()
{
	return 'ko_getup';
}
simulated function name GetAnimDeathCowering()
{
	return 'p_death3';
}
simulated function name GetAnimDeathCrouch()
{
	return 'c_death';
}
simulated function name GetAnimDeathFallForward()
{
//	return 's_fall_fore';
	//return 's_fall_fore_inplace';
	return 'pl_s_fall_fore_inplace';
}


simulated function name GetAnimClimb()
	{
	return 's_climb_ladder';
	}

simulated function name GetAnimPuke()
	{
	if (bIsFeminine)
		return 'sf_vomitt2';
	else
		return 's_vomit';
	}

simulated function name GetAnimKick() // a low kick (aimed at a prone body)
	{
	//return 's_rodney';
	return 'pl_s_rodney';
	}

simulated function name GetAnimShocked() // electrocuted by a Shocker
	{
	//return 's_shock';
	return 'pl_s_shock';
	}

simulated function name GetAnimDazed()
	{
	return 's_stunned';
	}
simulated function name GetAnimKickedInTheBalls()
	{
	return 'pl_kickedintheballs';
	}

simulated function name GetAnimFlashbang_in()
	{
	return 'pl_blindreaction_in';
	}

simulated function name GetAnimFlashbang_loop()
	{
	return 'pl_blindreaction_loop';
	}

simulated function name GetAnimFlashbang_out()
	{
	return 'pl_blindreaction_out';
	}

// played all the while he's crouching and begging (not a real beg through, just hands folded)
simulated function name GetAnimCrouchBeggingIdle()
	{
	return 'c_base_beg';
	}

simulated function name GetAnimCrouchBeg() // two types of begging on knees
	{
	if(FRand() < 0.5)
		return 'c_beg1';
	else
		return 'c_beg2';
	}

simulated function name GetAnimProneBeg()
	{
		return 'p_beg';
	}

simulated function name GetAnimClapping()
	{
	return 's_applause';
	}

simulated function name GetAnimPanting()
	{
	return 's_pant';
	}

simulated function name GetAnimDancing()
	{
	local float fr;
	fr = Rand(7);
	if(fr == 0)
		return 's_dance1';
	else if(fr == 1)
		return 's_dance2';
	else if (fr == 2)
		return 's_dance3';
	else if (fr == 3)
		return 'PL_Dance_Twerk';
	else if (fr == 4)
		return 'pl_clubdance1';
	else if (fr == 5)
		return 'pl_clubdance2';
	else
		return 'pl_clubdance3';
	}
	
simulated function name GetAnimSmoking()
{
	return 'pl_smoking';
}

simulated function name GetAnimArcade()
	{
	return 's_arcade';
	}

simulated function name GetAnimGuitar()
	{
	return 'pl_guitar_play';
	}

simulated function name GetAnimKeyboardType()
	{
	return 's_type';
	}

simulated function name GetAnimPatFire()
	{
	return 's_flames';
	}

simulated function name GetAnimLaugh()
	{
	//return 's_laugh';
	local int seed;
	
	seed = Rand(3);
	if (seed == 0)
		return 's_laugh';
	else if (seed == 1)
		return 'pl_laugh2';
	else
		return 'pl_laugh3';
	}

simulated function name GetAnimTellThemOff()
	{
	return 's_angry';
	}

simulated function name GetAnimFlipThemOff()
	{
	return 's_midfinger';
	}

simulated function name GetAnimCowerInBall()
	{
	return 'p_cower';
	}

simulated function name GetAnimRestStanding()
	{
	return 's_pant';
	}

simulated function name GetAnimIdle()
	{
	local int checkr;
	local int count;
	local bool bAdvancedAnims;
	
	// If holding a briefcase, return idle briefcase anim
	if (SpecialHoldStandAnim != '')
		return SpecialHoldStandAnim;
	else if (bNoExtendedAnims)
		return 'holding_idle';

	checkr = Rand(19);

	count = CountBoltons();

	// If we have any bolt-ons, don't allow complicated idles.
	if(count>0)
		bAdvancedAnims=false;
	else
		bAdvancedAnims=true;

	if(checkr < 3)
		return 's_idle_survey';
	else if(checkr < 6
		&& !bIsFeminine
		&& !bIsFemale)
		return 's_idle_crotch';
	else if(checkr < 9
		&& bAdvancedAnims)
		return 's_idle_shoe';
	else if(checkr < 12)
		return 's_idle_stretch';
	else if(checkr < 15)
		return 's_idle_watch';
	else if(checkr < 17
		&& bAdvancedAnims)
		return 's_idle_speck';	// only studies speck
	else if(checkr <= 18
		&& bAdvancedAnims)		// eats speck
		return 's_idle_speck2';
	}

simulated function name GetAnimIdleQ()
	{
	if(Rand(2) == 0)
		return 's_idle_shiftr';
	else
		return 's_idle_shiftl';
	}
	
simulated function name GetAnimSneezing()
{
	return 'pl_s_sneeze';
}
simulated function name GetAnimSneezingWalking()
{
	return 'pl_walk_sneeze';
}

///////////////////////////////////////////////////////////////////////////////
// Play looping animation only if not already animating
///////////////////////////////////////////////////////////////////////////////
simulated function LoopIfNeeded(name NewAnim, float NewRate)
	{
	local name OldAnim;
	local float frame,rate;
	
	GetAnimParams(0,OldAnim,frame,rate);
	
	// FIXME - call function to get tween time
	if ( (NewAnim != OldAnim) || (NewRate != Rate) || !IsAnimating(0) )
		LoopAnim(NewAnim, NewRate, 0.2);
	else
		LoopAnim(NewAnim, NewRate, 0.2);
	}


///////////////////////////////////////////////////////////////////////////////
// Called by animation notification
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_Footstep()
	{
	// At the very least we should have two slightly different footstep sounds
	// and alternate between them.  Epic was randomly choosing between three
	// variations to further mix it up.
	//
	// It would be nice to have different sounds for characters based on their
	// weight and their footwear.  Since they're all sharing meshes the
	// footwear is limited to something like:
	//
	//		Boots
	//		Shoes
	//		Sneakers
	//
	// and their weights could be:
	//
	//		Heavy (fat and big skeletons)
	//		Light (fem and mini skeletons)
	//		Average (everything else)
	//
	// We may be able to use pitch/volume changes to create weigh-related
	// footstep variations.  And maybe use even more subtle pitch/volume
	// changes to create even the basic 2 to 3 footsteps?
	//
	// We'd really like the footstep sounds to change based on the type
	// of material the character is walking on.  Some possibilities are:
	//
	//		Wood
	//		Metal
	//		Gravel
	//		Dirt
	//		Water
	//		Metal stairways
	//
	// Once we extend materials to add our own properties to them, this
	// will be relatively easy to support.  I'm thinking that instead of
	// having a single descriptive property for the material, it would
	// be better to have separate properties for which footsteps to use
	// and for which particle effects to use.  In fact, I'm actually thinking
	// we might want the material itself to play the footstep sounds and
	// trigger the particle effects.  The material could query the character
	// to see how heavy it is and such, or query the weapon that hit it,
	// or whatever.
	//
	// ACTUALLY, however it is we determine which sound to play, it has
	// to be the pawn that actually plays it!  If the material tried to
	// do it, the location of the sound would be off and the material could
	// only play sound for one character at a time.  Can't work that way.
	// But we can still let the material determine the sound and then
	// pass it to the pawn to play it.
	
	// For now, some really simple stuff
//	if (TouchingWaterVolume())
//		PlaySound(WaterStep, SLOT_Interact, 1.0, false, 1000.0, 1.0);
//	else
		PlaySound(NormalStepSound, SLOT_Interact, 0.2, false, 1000.0, 1.0);
	}

///////////////////////////////////////////////////////////////////////////////
// Switch to this new mesh
///////////////////////////////////////////////////////////////////////////////
function SwitchToNewMesh(Mesh NewMesh, 
						 Material NewSkin,
						 Mesh NewHeadMesh, 
						 Material NewHeadSkin,
						 optional Mesh NewCoreMesh)
{
	// Setup body (true means "keep anim state")
	SetMyMesh(NewMesh, NewCoreMesh, true);
	SetMySkin(NewSkin);
	PlayWaiting();

	// Setup head
	MyHead.LinkMesh(NewHeadMesh, true);
	MyHead.Skins[0] = NewHeadSkin;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Extends P2Pawn.Dying
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dying
{
	///////////////////////////////////////////////////////////////////////////////
	// This dead body touched something.. tell live pawns about it
	///////////////////////////////////////////////////////////////////////////////
	event Touch(Actor Other)
	{
		if(FPSPawn(Other) != None
			&& LambController(FPSPawn(Other).Controller) != None)
		{
			LambController(FPSPawn(Other).Controller).GetHitByDeadThing(self, FPSPawn(Instigator));
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Get hurt, plus some ragdoll
	//
	// Only let you hurt the dead guys in single player, because in MP, the characters
	// won't match up with other people's computers and if you set someone on fire
	// they will be on fire in two different incorrect places (blood would shoot
	// out of weird places too.. ) It just makes a big mess.
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, 
							Vector Momentum, class<DamageType> DamageType)
	{
		local vector shotDir, hitNormal;
		local actor tmpActor;
		local float maxDim;
		local bool bReInitted;
		local vector KMomentum;

		//ErikFOV Change: Fix problem
		if (bPendingDelete || bDeleteMe)
			return;
		//End

		if(Level.Game != None
			&& Level.Game.bIsSinglePlayer)
		{
			// Save who last hit us
			Instigator = InstigatedBy;

			// Keep a karma momentum, and cap it from going through walls and floor too much
			KMomentum = Momentum;

			CapKarmaMomentum(KMomentum, damageType, 1.0, 1.0, HitLocation);

			// If fire hit you, even dead, catch on fire for sure
			if(ClassIsChildOf(damageType, class'BurnedDamage'))
				SetOnFire(FPSPawn(instigatedBy), (damageType==class'NapalmDamage'));
			// If you're infected, be infected even in death
			if(damageType == class'ChemDamage')
				SetInfected(FPSPawn(instigatedBy));

			// If fire has killed me,
			// or we're on fire and we died,
			// then swap to my burn victim mesh
			if(damageType == class'OnFireDamage'
				|| ClassIsChildOf(damageType, class'BurnedDamage')
				|| MyBodyFire != None)
				SwapToBurnVictim();

			if(MyHead != None
				&& bHeadCanComeOff)
			{
				// Check to remove their heads off, even when dead, with the shotgun or shovel
				// If the thing hit the head, and you're close enough to take it off
				if(VSize(MyHead.Location - HitLocation) < CollisionRadius
					&& DamageType == class'ShotgunDamage')
				{
					if(VSize(Location - InstigatedBy.Location) < DISTANCE_TO_EXPLODE_HEAD)
					{
						// record special kill
						if(P2GameInfoSingle(Level.Game) != None
							&& P2GameInfoSingle(Level.Game).TheGameState != None
							&& P2Pawn(InstigatedBy) != None
							&& P2Pawn(InstigatedBy).bPlayer)
						{
							P2GameInfoSingle(Level.Game).TheGameState.ShotgunHeadShot++;
						}

						if(class'P2Player'.static.BloodMode())
						{
							ExplodeHead(HitLocation, Momentum);
						}
					}
				}
				// Because the collision on the shovel is so large and general, just take their
				// head off anyway, half the time.
				else if(DamageType == class'ShovelDamage'
					&& FRand() > 0.5)
				{
					if(class'P2Player'.static.BloodMode())
					{
						PopOffHead(HitLocation, Momentum);
						PlaySound(ShovelCleaveHead,,,,,GetRandPitch());
					}
				}
			}

			// If his skeleton has been taken away from him, reserve it
			// for some more time, if one's available
			if(KParams == None
				&& AllowRagdoll(DamageType))
			{
				GetKarmaSkeleton();
				if(KParams != None)
				{
					// Don't crouch or crawl anymore
					ShouldCrouch(false);
					ShouldDeathCrawl(false);

					StopAnimating();
					
					bPhysicsAnimUpdate = false;

					//log(self$" setting ragdoll "$GetStateName());
					SetPhysics(PHYS_KarmaRagDoll);

					// Get things going first, for sure
					KWake();
					KSetSkelVel( (DeathVelMag * Normal(KMomentum)) );
					bReInitted=true;
				}
			}

			if(Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer
				&& (KarmaParamsSkel(KParams) != None) 
				&& Physics == PHYS_KarmaRagDoll)
			{
				// Reset timer to ensure use of ragdoll
				RagDollStartTime = Level.TimeSeconds;

				// Again, (as in p2pawn, takedamage) modify explosion momentum for funnier effects
				if(ClassIsChildOf(damageType,class'ExplodedDamage'))
				{
					// Move the hit point around the ragdoll to get a better tumble
					HitLocation = RAND_MOVE_AROUND_RAGDOLL_HIT*VRand() + HitLocation;

					// Make sure to throw it a good ways, if we can
					if(KMomentum.z > 0
						&& KMomentum.z < DeathVelMag*Mass)
					{
						KMomentum.z *= 8;
						KMomentum = MAX_EXPL_MOMENTUM*Normal(KMomentum);
					}

					//log(self$" hit "$KMomentum$" size "$VSize(KMomentum)$" loc "$Location$" hit "$HitLocation);
					/*
					if(!bReInitted)
						KSetSkelVel(THROW_VEL_RATIO_EXPL*KMomentum);
					else
					*/
					if(bReInitted)
					{
						//log(self$" setting ragdoll "$GetStateName());
						// Ensure each time we set the physics
						SetPhysics(PHYS_KarmaRagDoll);
						bReInitted=false;
					}
					KAddImpulse(KMomentum, HitLocation, BONE_PELVIS);
				}
				else
				{
					// If you don't take any of these damages, then block them here
					if((TakesMachinegunDamage == 0.0
							&& DamageType == class'MachinegunDamage')
						|| (TakesShotgunHeadShot == 0.0
							&& DamageType == class'ShotgunDamage')
						|| (TakesPistolHeadShot == 0.0
							&& DamageType == class'BulletDamage'))
					{
						// Make a ricochet sound and puff out some smoke and sparks
						SparkHit(HitLocation, Momentum, 1);
						DustHit(HitLocation, Momentum);
					}
					else
						// Throw out some effects of the hit
						PlayHit(Damage, hitLocation, damageType, Momentum);

					if(VSize(KMomentum) > 0)
					{
						// Move the body
						if(!bReInitted)

							KSetSkelVel(THROW_VEL_RATIO*KMomentum);
						else
						{
							//log(self$" setting ragdoll "$GetStateName());
							// Ensure each time we set the physics
							SetPhysics(PHYS_KarmaRagDoll);
							bReInitted=false;
						}
						//log(self$" hit "$KMomentum$" size "$VSize(KMomentum)$" loc "$Location$" hit "$HitLocation);
						KAddImpulse(KMomentum, HitLocation, BONE_PELVIS);
					}
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Turn off head collision too
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		//ErikFOV Change: Fix problem
		if (bPendingDelete || bDeleteMe)
			return;
		//End

		if(MyHead != None)
			MyHead.SetCollision(false, false, false);

		// Make sure you absolutely drop your things, if you were stealthily killed
		DropBoltons(Velocity);

		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LoadedDying
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LoadedDying extends Dying
{
	///////////////////////////////////////////////////////////////////////////////
	// LoadedDying is not normal. For instance, we don't want to retell people
	// around us that we died, or they'll freak out all over again.
	///////////////////////////////////////////////////////////////////////////////
	function bool DiedNormally()
	{
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Disconnect my variable from my torso fire, now or later
	///////////////////////////////////////////////////////////////////////////////
	function UnhookPawnFromFire()
	{
		GotoState('LoadedDying', 'WaitToResetFire');
	}

WaitToResetFire:
	Sleep(FIRE_RESET_TIME);
	MyBodyFire=None;
Begin:
	//.Fall to the ground
	SetPhysics(PHYS_Falling);
	PlayAnim(GetAnimDeathFallForward(),SUPER_FAST_RATE);
	Sleep(0.05);
	bHidden=false;
}

// STUB
function HandleStuckPlayer();

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bPhysicsAnimUpdate=true

	RotationRate=(Pitch=0,Yaw=35000,Roll=0)
	CombatRotationRate=(Pitch=0,Yaw=48000,Roll=0)
	DeathCrawlRotationRate = (Pitch=0,Yaw=500,Roll=0)
	
	DeathCrawlRadius = 80
	DeathCrawlHeight=12
	
	MovementPct=1.0
	DeathCrawlingPct=0.02
	ProtestingPct=0.5
	MarchingPct=1.0
	SingleGunWalkPct=0.4
	DoubleGunWalkPct=0.35
	GhettoFemWalkPct=0.3
	GhettoWalkPct=0.3
	FemWalkPct=0.3
	
	BlockMeleeFreq=0.05

	HeadScale=(X=1.0,Y=1.0,Z=1.0)
	bRandomizeHeadScale=true
	DeathVelMag=150
	FirstPersonMeshPrefix="FP_Dude_"
	TimeBetweenPainSounds=0.5
	BodyHitSounds[0]=Sound'MiscSounds.People.bodyhitground1'
	BodyHitSounds[1]=Sound'MiscSounds.People.bodyhitground2'
	NormalStepSound=Sound'MiscSounds.People.footstep'
	CoreMeshAnim=MeshAnimation'Characters.animAvg'

	ChameleonMeshPkgs(0)="Characters"
	ChamelHeadMeshPkgs(0)="Heads"

	// Set default anims -- necessary for multiplayer so client has something to start with
	TurnLeftAnim=s_turn1
	TurnRightAnim=s_turn1
	MovementAnims[0]=s_walk1
	MovementAnims[1]=s_walkback
	MovementAnims[2]=s_strafel
	MovementAnims[3]=s_strafer

    RootBone="MALE01"
    HeadBone="MALE01 head"
    SpineBone1="MALE01 Spine1"
    SpineBone2="MALE01 Spine2"
    bDoTorsoTwist=true

	// Bolton Definitions.
	Begin Object Class=BoltonDef Name=BoltonDefSantaHat
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.SantaHat_M_Fat',bAttachToHead=True)
		UseChance=1.00
		Gender=Gender_Male
		BodyType=Body_Fat
		Tag="Hat"
		ExcludeTags(0)="Hat"
		ValidDates=(MonthMin=12,MonthMax=12,DayMin=15,DayMax=25)
	End Object
	
	// V-day DLC
	Begin object class=BoltonDef Name=BoltonDefVDayVase
		Boltons(0)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'ValentineMesh.Bolton.RosesBunch',bCanDrop=True)
		UseChance=0.40
		Tag="SpecialHold"
		BodyType=Body_Avg
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="SpecialHold"
		ExcludeTags(3)="ShoppingBag"
		ValidDates=(MonthMin=2,MonthMax=2,DayMin=12,DayMax=16)
		SpecialFlags=(bLargeAndBulky=True,bValentine=True,SpecialHoldWalkAnim="walk_hold")
	End Object		
	
	// Briefcases for businesspeople.
	Begin Object Class=BoltonDef Name=BoltonDefBriefcase
		Boltons(0)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'Boltons_Package.Briefcase01_side',Skin=Texture'Boltons_Tex.Briefcase2',bCanDrop=True)
		Boltons(1)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'Boltons_Package.Briefcase01_side',Skin=Texture'Boltons_Tex.Briefcase_lit02',bCanDrop=True)
		UseChance=0.50
		Tag="Briefcase"
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="SpecialHold"
		ExcludeTags(3)="ShoppingBag"
		IncludeSkins(0)=Texture'ChameleonSkins.BystandersM.MM__018__Avg_M_Jacket_Pants'
		IncludeSkins(1)=Texture'ChameleonSkins.BystandersM.MW__019__Avg_M_Jacket_Pants'
		IncludeSkins(2)=Texture'ChameleonSkins.BystandersM.MW__021__Avg_M_Jacket_Pants'				
		BodyType=Body_Avg
		// They'll be holding this in their hand and making it basically useless, so don't let them do any extended animations other than walking and talking
		SpecialFlags=(bLargeAndBulky=True)
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefShades1
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Aviators_M',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.SportShades_M',bAttachToHead=True)
		UseChance=0.5
		Gender=Gender_Male
		BodyType=Body_Avg
		Tag="Glasses"
		ExcludeTags(0)="Glasses"
		InvalidHoliday="NightMode"
	End Object

	Begin Object Class=BoltonDef Name=BoltonDefShades2
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Aviators_M_Fat',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.SportShades_M_Fat',bAttachToHead=True)
		UseChance=0.5
		Gender=Gender_Male
		BodyType=Body_Fat
		Tag="Glasses"
		ExcludeTags(0)="Glasses"
		InvalidHoliday="NightMode"
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefShades3
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Aviators_F',bAttachToHead=True)
		//Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Sports_Shades_F',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Aviators_F',bAttachToHead=True)
		//Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Sports_Shades_F',bAttachToHead=True)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Aviators_F',Skin=Shader'Boltons_Tex.aviators_pink_s',bAttachToHead=True)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Aviators_F',Skin=Shader'Boltons_Tex.aviators_purple_s',bAttachToHead=True)
		//Boltons(6)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Sports_Shades_F',Skin=Shader'Boltons_Tex.sportshades_blue_s'bAttachToHead=True)
		UseChance=0.5
		Gender=Gender_Female
		BodyType=Body_Avg
		Tag="Glasses"
		ExcludeTags(0)="Glasses"
		ExcludedHeads(0)=Mesh'Heads.FemLH'
		InvalidHoliday="NightMode"
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefBallcap
		UseChance=0.1
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_High',Skin=Texture'Boltons_Tex.baseballcap_02',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_High',Skin=Texture'Boltons_Tex.baseballcap',bAttachToHead=True)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_High',Skin=Texture'Boltons_Tex.baseballcap_weed02',bAttachToHead=True)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_High',Skin=Texture'Boltons_Tex.baseballcap_weed',bAttachToHead=True)
		Boltons(4)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_High',Skin=Texture'Boltons_Tex.baseballcap_white',bAttachToHead=True)
		Boltons(5)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_02',bAttachToHead=True)
		Boltons(6)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap',bAttachToHead=True)
		Boltons(7)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_weed02',bAttachToHead=True)
		Boltons(8)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_weed',bAttachToHead=True)
		Boltons(9)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_white',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
		ExcludeSkins(0)=Texture'ChameleonSkins.BystandersM.MM__018__Avg_M_Jacket_Pants'
		ExcludeSkins(1)=Texture'ChameleonSkins.BystandersM.MW__019__Avg_M_Jacket_Pants'
		ExcludeSkins(2)=Texture'ChameleonSkins.BystandersM.MW__021__Avg_M_Jacket_Pants'		
		ExcludeSkins(3)=Texture'ChameleonSkins.Scientists.MW__005__Avg_Dude'
		ExcludeSkins(4)=Texture'ChameleonSkins.Scientists.MW__006__Avg_Dude'
		ExcludeSkins(5)=Texture'ChameleonSkins.Scientists.MW__163__Avg_Dude'
		ExcludeSkins(6)=Texture'ChameleonSkins.Scientists.MW__164__Avg_Dude'
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefBallcap_Fem
		UseChance=0.1
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_02',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap',bAttachToHead=True)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_weed02',bAttachToHead=True)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_weed',bAttachToHead=True)
		Boltons(4)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_white',bAttachToHead=True)
		AllowedHeads(0)=Mesh'heads.FemSHCropped'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefBallcap_Backwards
		UseChance=0.05
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_Back',Skin=Texture'Boltons_Tex.baseballcap_02',bAttachToHead=True,DrawScale=1.02)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_Back',Skin=Texture'Boltons_Tex.baseballcap',bAttachToHead=True,DrawScale=1.02)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_Back',Skin=Texture'Boltons_Tex.baseballcap_weed02',bAttachToHead=True,DrawScale=1.02)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_Back',Skin=Texture'Boltons_Tex.baseballcap_weed',bAttachToHead=True,DrawScale=1.02)
		Boltons(4)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_Back',Skin=Texture'Boltons_Tex.baseballcap_white',bAttachToHead=True,DrawScale=1.02)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
		ExcludeSkins(0)=Texture'ChameleonSkins.BystandersM.MM__018__Avg_M_Jacket_Pants'
		ExcludeSkins(1)=Texture'ChameleonSkins.BystandersM.MW__019__Avg_M_Jacket_Pants'
		ExcludeSkins(2)=Texture'ChameleonSkins.BystandersM.MW__021__Avg_M_Jacket_Pants'		
		ExcludeSkins(3)=Texture'ChameleonSkins.Scientists.MW__005__Avg_Dude'
		ExcludeSkins(4)=Texture'ChameleonSkins.Scientists.MW__006__Avg_Dude'
		ExcludeSkins(5)=Texture'ChameleonSkins.Scientists.MW__163__Avg_Dude'
		ExcludeSkins(6)=Texture'ChameleonSkins.Scientists.MW__164__Avg_Dude'
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefCowboyHat
		UseChance=0.05
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat01_M',Skin=Texture'Boltons_Tex.fedora_black',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat01_M',Skin=Texture'Boltons_Tex.fedora_brown',bAttachToHead=True)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat01_M',Skin=Texture'Boltons_Tex.fedora_uv',bAttachToHead=True)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat02_M',Skin=Texture'Boltons_Tex.cowboy_uvw',bAttachToHead=True)
		Boltons(4)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat02_M',Skin=Texture'Boltons_Tex.cowboy_white',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
		ExcludeSkins(0)=Texture'ChameleonSkins.BystandersM.MM__018__Avg_M_Jacket_Pants'
		ExcludeSkins(1)=Texture'ChameleonSkins.BystandersM.MW__019__Avg_M_Jacket_Pants'
		ExcludeSkins(2)=Texture'ChameleonSkins.BystandersM.MW__021__Avg_M_Jacket_Pants'		
		ExcludeSkins(3)=Texture'ChameleonSkins.Scientists.MW__005__Avg_Dude'
		ExcludeSkins(4)=Texture'ChameleonSkins.Scientists.MW__006__Avg_Dude'
		ExcludeSkins(5)=Texture'ChameleonSkins.Scientists.MW__163__Avg_Dude'
		ExcludeSkins(6)=Texture'ChameleonSkins.Scientists.MW__164__Avg_Dude'
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefFedora
		UseChance=0.05
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Fedora01_M',Skin=Texture'Boltons_Tex.fedora_black',bAttachToHead=True,DrawScale=1.02)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Fedora01_M',Skin=Texture'Boltons_Tex.fedora_brown',bAttachToHead=True,DrawScale=1.02)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Fedora01_M',Skin=Texture'Boltons_Tex.fedora_uv',bAttachToHead=True,DrawScale=1.02)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Fedora02_M',Skin=Texture'Boltons_Tex.fedora_black',bAttachToHead=True,DrawScale=1.02)
		Boltons(4)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Fedora02_M',Skin=Texture'Boltons_Tex.fedora_brown',bAttachToHead=True,DrawScale=1.02)
		Boltons(5)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Fedora02_M',Skin=Texture'Boltons_Tex.fedora_uv',bAttachToHead=True,DrawScale=1.02)
		Boltons(6)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.FedoraHigh_M',Skin=Texture'Boltons_Tex.fedora_black',bAttachToHead=True,DrawScale=1.02)
		Boltons(7)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.FedoraHigh_M',Skin=Texture'Boltons_Tex.fedora_brown',bAttachToHead=True,DrawScale=1.02)
		Boltons(8)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.FedoraHigh_M',Skin=Texture'Boltons_Tex.fedora_uv',bAttachToHead=True,DrawScale=1.02)
		Boltons(9)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.FedoraTilt_M',Skin=Texture'Boltons_Tex.fedora_black',bAttachToHead=True,DrawScale=1.02)
		Boltons(10)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.FedoraTilt_M',Skin=Texture'Boltons_Tex.fedora_brown',bAttachToHead=True,DrawScale=1.02)
		Boltons(11)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.FedoraTilt_M',Skin=Texture'Boltons_Tex.fedora_uv',bAttachToHead=True,DrawScale=1.02)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
		ExcludeSkins(0)=Texture'ChameleonSkins.BystandersM.MM__018__Avg_M_Jacket_Pants'
		ExcludeSkins(1)=Texture'ChameleonSkins.BystandersM.MW__019__Avg_M_Jacket_Pants'
		ExcludeSkins(2)=Texture'ChameleonSkins.BystandersM.MW__021__Avg_M_Jacket_Pants'		
		ExcludeSkins(3)=Texture'ChameleonSkins.Scientists.MW__005__Avg_Dude'
		ExcludeSkins(4)=Texture'ChameleonSkins.Scientists.MW__006__Avg_Dude'
		ExcludeSkins(5)=Texture'ChameleonSkins.Scientists.MW__163__Avg_Dude'
		ExcludeSkins(6)=Texture'ChameleonSkins.Scientists.MW__164__Avg_Dude'
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefPurse
		UseChance=0.25
		Boltons(0)=(Bone="MALE01 Spine2",StaticMesh=StaticMesh'Boltons_Package.shoulder_bag01',bCanDrop=True)
		Gender=Gender_Female
		Tag="Purse"
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="ShoppingBag"
		ExcludeTags(3)="SpecialHold"
		BodyType=Body_Avg
		ExcludedMeshes(0)=SkeletalMesh'Characters.Fem_LS_Pants'
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefPurseGay
		//UseChance=0.1
		UseChance=0		
		Boltons(0)=(Bone="MALE01 Spine2",StaticMesh=StaticMesh'Boltons_Package.shoulder_bag01',bCanDrop=True)
		Gender=Gender_Male
		Lifestyle=Lifestyle_Gay
		Tag="Purse"
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="ShoppingBag"
		ExcludeTags(3)="SpecialHold"
		BodyType=Body_Avg
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefPornBag
		UseChance=0.02
		Boltons(0)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'Boltons_Package.Bags.PaperBag01',bCanDrop=true)
		Tag="ShoppingBag"
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="ShoppingBag"
		ExcludeTags(3)="SpecialHold"
		SpecialFlags=(bLargeAndBulky=True)
		BodyType=Body_Avg
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefAfro
		UseChance=0.01
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Afro01',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Afro02',bAttachToHead=True)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Afro03',bAttachToHead=True)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Afro04',bAttachToHead=True)
		Gender=Gender_Male
		Race=Race_Black
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefRastaHat_F
		UseChance=0.003
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.RastaHat_F',bAttachToHead=True)
		Gender=Gender_Female
		BodyType=Body_Avg
		AllowedHeads(0)=Mesh'Heads.FemSH'
		AllowedHeads(1)=Mesh'Heads.FemSHCropped'
		Tag="Hat"
		ExcludeTags(0)="Hat"
		RareTag="Rasta"
	End Object
		
	Begin Object Class=BoltonDef Name=BoltonDefRastaHat_F_LH
		UseChance=0.003
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.RastaHat_F_LH',bAttachToHead=True)
		Gender=Gender_Female
		BodyType=Body_Avg
		AllowedHeads(0)=Mesh'Heads.FemLH'
		Tag="Hat"
		ExcludeTags(0)="Hat"
		RareTag="Rasta"
	End Object

	Begin Object Class=BoltonDef Name=BoltonDefRastaHat_M
		UseChance=0.03
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.RastaHat_M',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		RareTag="Rasta"
		Tag="Hat"
		ExcludeTags(0)="Hat"
		ExcludeSkins(0)=Texture'ChameleonSkins.BystandersM.MM__018__Avg_M_Jacket_Pants'
		ExcludeSkins(1)=Texture'ChameleonSkins.BystandersM.MW__019__Avg_M_Jacket_Pants'
		ExcludeSkins(2)=Texture'ChameleonSkins.BystandersM.MW__021__Avg_M_Jacket_Pants'		
		ExcludeSkins(3)=Texture'ChameleonSkins.Scientists.MW__005__Avg_Dude'
		ExcludeSkins(4)=Texture'ChameleonSkins.Scientists.MW__006__Avg_Dude'
		ExcludeSkins(5)=Texture'ChameleonSkins.Scientists.MW__163__Avg_Dude'
		ExcludeSkins(6)=Texture'ChameleonSkins.Scientists.MW__164__Avg_Dude'
	End Object

	Begin Object Class=BoltonDef Name=BoltonDefRastaHat_M_Fat
		UseChance=0.005
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.RastaHat_M_Fat',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Fat
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefCigarette_M
		UseChance=0.15
		Boltons(0)=(Bone="Male01 R finger2",Mesh=SkeletalMesh'MoreCharacters.cig_skel',bCanDrop=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		Tag="SpecialHold"
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="ShoppingBag"
		ExcludeTags(3)="SpecialHold"
		SpecialFlags=(bCigarette=true,SpecialHoldWalkAnim="pl_smoking_walk")
	End Object

	Begin Object Class=BoltonDef Name=BoltonDefCigarette_F
		UseChance=0.15
		Boltons(0)=(Bone="Male01 R finger2",Mesh=SkeletalMesh'MoreCharacters.cig_skel',bCanDrop=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		Tag="SpecialHold"
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="ShoppingBag"
		ExcludeTags(3)="SpecialHold"
		SpecialFlags=(bCigarette=true,SpecialHoldWalkAnim="pl_smoking_walk")
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDefEarring_M
		UseChance=0.1
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Earring_01_M',bAttachToHead=True)
		Gender=Gender_Male
		Tag="Ear"
		ExcludeTags(0)="Ear"
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenCostume_Skeleton
		UseChance=0.05
		Gender=Gender_Male
		BodyType=Body_Avg
		Race=Race_White
		Tag="SkeletonCostume"
		ExcludeTags(0)="WitchCostume"
		ExcludeTags(1)="Hat"
		IncludedMeshes=SkeletalMesh'Characters.Avg_M_SS_Pants'
		BodySkin=Texture'Halloweeen_Tex.Avg_M_Skeleton'
		HeadSkin=Texture'Halloweeen_Tex.AvgMale_Skull'
		HeadMesh=Mesh'Heads.AvgMale'
		ValidHoliday="SeasonalHalloween"
		SpecialFlags=(bHalloween=true)
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenFacePaint_Clown
		UseChance=0.2
		Gender=Gender_Male
		BodyType=Body_Fat
		Race=Race_White
		Tag="Costume"
		ExcludeTags(0)="Costume"
		HeadSkin=Texture'Halloweeen_Tex.AvgMale_Clown'
		HeadMesh=Mesh'Heads.FatMale'
		ValidHoliday="SeasonalHalloween"
		SpecialFlags=(bHalloween=true)
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenFacePaint_Panda
		UseChance=0.2
		AllowedHeads(0)=Mesh'Heads.FemLH'
		Race=Race_White
		Tag="Costume"
		ExcludeTags(0)="Costume"
		HeadSkin=Texture'Halloweeen_Tex.FemLH_Panda'
		ValidHoliday="SeasonalHalloween"
		SpecialFlags=(bHalloween=true)
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenFacePaint_Skull
		UseChance=0.2
		AllowedHeads(0)=Mesh'Heads.FemLH'
		Race=Race_White
		Tag="Costume"
		ExcludeTags(0)="Costume"
		HeadSkin=Texture'Halloweeen_Tex.FemLH_Skull'
		ValidHoliday="SeasonalHalloween"
		SpecialFlags=(bHalloween=true)
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenFacePaint_Cat
		UseChance=0.2
		AllowedHeads(0)=Mesh'Heads.FemSH'
		Race=Race_White
		Tag="Costume"
		ExcludeTags(0)="Costume"
		HeadSkin=Texture'Halloweeen_Tex.FemSH_Cat'
		ValidHoliday="SeasonalHalloween"
		SpecialFlags=(bHalloween=true)
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenCostume_Witch
		UseChance=0.1
		Gender=Gender_Female
		BodyType=Body_Avg
		Race=Race_White
		Tag="WitchCostume"
		ExcludeTags(0)="Costume"
		IncludedMeshes=SkeletalMesh'Characters.Fem_LS_Skirt'
		BodySkin=Texture'Halloweeen_Tex.Fem_LS_Skirt_Sexy_Witch'
		HeadSkin=Texture'Halloweeen_Tex.SexyWitchFace'
		HeadMesh=Mesh'Heads.FemLH'
		ValidHoliday="SeasonalHalloween"
		SpecialFlags=(bHalloween=true)
	End Object
	
	Begin Object Class=Boltondef Name=BoltonDef_HalloweenBolton_WitchHead
		UseChance=0.1
		Gender=Gender_Female
		BodyType=Body_Avg
		Tag="WitchHead"
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'MRT_Holidays.Halloween.Witch_Head',bAttachToHead=True)
		ValidHoliday="SeasonalHalloween"
		SpecialFlags=(bHalloween=true)
	End Object
	
	Begin Object Class=Boltondef Name=BoltonDef_HalloweenBolton_WitchHat
		UseChance=0
		Gender=Gender_Female
		BodyType=Body_Avg
		Tag="WitchHat"
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'MRT_Holidays.Halloween.witch_hat',bAttachToHead=True)
		ValidHoliday="SeasonalHalloween"
		SpecialFlags=(bHalloween=true)
		IncludeTags(0)="WitchCostume"
		ExcludedHeads(0)=Mesh'Heads.FemLH'
	End Object
	
	Begin Object Class=BoltonDef NAme=BoltonDef_HalloweenBolton_WitchBroom
		UseChance=0
		Tag="WitchBroom"
		Gender=Gender_Female
		BodyType=Body_Avg
		IncludeTags(0)="WitchCostume"
		IncludeTags(1)="WitchHead"
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="ShoppingBag"
		ExcludeTags(3)="SpecialHold"
		Boltons(0)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'MRT_Holidays.Halloween.broom_bolton',bCanDrop=True)		
		SpecialFlags=(bHalloween=true)
	End Object		
	
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenBolton_FrankensteinHead
		UseChance=0.1
		Gender=Gender_Male
		BodyType=Body_Avg
		Tag="FrankenHead"
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'MRT_Holidays.Halloween.frankenstein_head',bAttachToHead=True)
		ValidHoliday="SeasonalHalloween"
		ExcludeTags(0)="Hat"
		SpecialFlags=(bHalloween=true)
	End Object
		
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenBolton_PumpkinHead
		UseChance=0.1
		Tag="PumpkinHead"
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'MRT_Holidays.Halloween.pumpkin_bolton',bAttachToHead=True)
		ValidHoliday="SeasonalHalloween"
		ExcludeTags(0)="Hat"
		SpecialFlags=(bHalloween=true)
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenBolton_DevilHorns
		UseChance=0.1
		Gender=Gender_Male
		BodyType=Body_Avg
		Tag="DevilHorns"
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'MRT_Holidays.Halloween.devilhorns',bAttachToHead=True)
		ValidHoliday="SeasonalHalloween"
		ExcludeTags(0)="Hat"
		SpecialFlags=(bHalloween=true)
		Race=Race_White
		IncludedMeshes=SkeletalMesh'Characters.Avg_M_LS_Pants'
		BodySkin=Texture'Halloweeen_Tex.White_M_Devil'
	End Object
	
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenBolton_DevilHorns_Black
		UseChance=0.1
		Gender=Gender_Male
		BodyType=Body_Avg
		Tag="DevilHorns"
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'MRT_Holidays.Halloween.devilhorns',bAttachToHead=True)
		ValidHoliday="SeasonalHalloween"
		ExcludeTags(0)="Hat"
		SpecialFlags=(bHalloween=true)
		Race=Race_Black
		IncludedMeshes=SkeletalMesh'Characters.Avg_M_LS_Pants'
		BodySkin=Texture'Halloweeen_Tex.Black_M_Devil'
	End Object
	
	Begin Object Class=BoltonDef NAme=BoltonDef_HalloweenBolton_PitchFork
		UseChance=0
		Tag="PitchFork"
		Gender=Gender_Male
		BodyType=Body_Avg
		IncludeTags(0)="DevilHorns"
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="ShoppingBag"
		ExcludeTags(3)="SpecialHold"
		Boltons(0)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'MRT_Holidays.Halloween.pitchfork_bolton',bCanDrop=True)		
		SpecialFlags=(bHalloween=true)
		ValidHoliday="SeasonalHalloween"
	End Object		

	// KFIXME these throw compiler warnings but work anyway
	RandomizedBoltons(0)=BoltonDef'BoltonDefVDayVase'
	RandomizedBoltons(1)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(2)=BoltonDef'BoltonDefAfro'
	RandomizedBoltons(3)=BoltonDef'BoltonDefRastaHat_F'
	RandomizedBoltons(4)=BoltonDef'BoltonDefRastaHat_F_LH'
	RandomizedBoltons(5)=BoltonDef'BoltonDefRastaHat_M'
	RandomizedBoltons(6)=BoltonDef'BoltonDefRastaHat_M_Fat'
	RandomizedBoltons(7)=BoltonDef'BoltonDefFedora'
	RandomizedBoltons(8)=BoltonDef'BoltonDefCowboyHat'
	RandomizedBoltons(9)=BoltonDef'BoltonDefBallcap_Backwards'
	RandomizedBoltons(10)=BoltonDef'BoltonDefBriefcase'
	RandomizedBoltons(11)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(12)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(13)=BoltonDef'BoltonDefShades3'
	RandomizedBoltons(14)=BoltonDef'BoltonDefBallcap'
	RandomizedBoltons(15)=BoltonDef'BoltonDefBallcap_Fem'
	RandomizedBoltons(16)=BoltonDef'BoltonDefPurse'
	RandomizedBoltons(17)=BoltonDef'BoltonDefPurseGay'
	RandomizedBoltons(18)=BoltonDef'BoltonDefCigarette_M'
	RandomizedBoltons(19)=BoltonDef'BoltonDefCigarette_F'
	RandomizedBoltons(20)=BoltonDef'BoltonDefEarring_M'
	RandomizedBoltons(21)=BoltonDef'BoltonDefPornBag'
	RandomizedBoltons(22)=BoltonDef'BoltonDef_HalloweenCostume_Skeleton'
	RandomizedBoltons(23)=BoltonDef'BoltonDef_HalloweenFacePaint_Clown'
	RandomizedBoltons(24)=BoltonDef'BoltonDef_HalloweenFacePaint_Panda'
	RandomizedBoltons(25)=BoltonDef'BoltonDef_HalloweenFacePaint_Skull'
	RandomizedBoltons(26)=BoltonDef'BoltonDef_HalloweenFacePaint_Cat'
	RandomizedBoltons(27)=BoltonDef'BoltonDef_HalloweenCostume_Witch'
	RandomizedBoltons(28)=BoltonDef'BoltonDef_HalloweenBolton_WitchHead'
	RandomizedBoltons(29)=BoltonDef'BoltonDef_HalloweenBolton_WitchBroom'
	RandomizedBoltons(30)=BoltonDef'BoltonDef_HalloweenBolton_FrankensteinHead'
	RandomizedBoltons(31)=BoltonDef'BoltonDef_HalloweenBolton_PumpkinHead'
	RandomizedBoltons(32)=BoltonDef'BoltonDef_HalloweenBolton_DevilHorns'
	RandomizedBoltons(33)=BoltonDef'BoltonDef_HalloweenBolton_DevilHorns_Black'
	RandomizedBoltons(34)=BoltonDef'BoltonDef_HalloweenBolton_PitchFork'
	RandomizedBoltons(35)=BoltonDef'BoltonDef_HalloweenBolton_WitchHat'
	HoldingVase=-1
	// If ChameleonPlus finds a "none" BoltonDef, it will halt processing immediately.
	// Always end the RandomizedBoltons section with a None to stop inheritance of superclass boltons.
	
	IdleCellPct=.001
	IdleFartPct=.0009
	IdleSneezePct=.001
	GroundSpeedMult=1.0
	FootstepSounds[0]=(SurfaceType=EST_Default,Sounds=("MoreMiscSounds.loudfootsteps.footstep1h","MoreMiscSounds.loudfootsteps.footstep2h","MoreMiscSounds.loudfootsteps.footstep4h","MoreMiscSounds.loudfootsteps.footstep5h","MoreMiscSounds.loudfootsteps.footstep6h"))
	FootstepSounds[1]=(SurfaceType=EST_Rock,Sounds=("MoreMiscSounds.loudfootsteps.footstep1h","MoreMiscSounds.loudfootsteps.footstep2h","MoreMiscSounds.loudfootsteps.footstep4h","MoreMiscSounds.loudfootsteps.footstep5h","MoreMiscSounds.loudfootsteps.footstep6h"))
	FootstepSounds[2]=(SurfaceType=EST_Dirt,Sounds=("Footsteps.BFootstepDirt1","Footsteps.BFootstepDirt2","Footsteps.BFootstepDirt4","Footsteps.BFootstepDirt5","Footsteps.BFootstepDirt6"))
	FootstepSounds[3]=(SurfaceType=EST_Metal,Sounds=("Footsteps.BFootstepMetal1","Footsteps.BFootstepMetal2","Footsteps.BFootstepMetal4","Footsteps.BFootstepMetal5","Footsteps.BFootstepMetal6"))
	FootstepSounds[4]=(SurfaceType=EST_Wood,Sounds=("Footsteps.BFootstepWood1","Footsteps.BFootstepWood2","Footsteps.BFootstepWood3","Footsteps.BFootstepWood4","Footsteps.BFootstepWood5","Footsteps.BFootstepWood6"))
	FootstepSounds[5]=(SurfaceType=EST_Plant,Sounds=("Footsteps.BFootstepPlant1","Footsteps.BFootstepPlant2","Footsteps.BFootstepPlant3","Footsteps.BFootstepPlant4","Footsteps.BFootstepPlant5","Footsteps.BFootstepPlant6"))
	FootstepSounds[6]=(SurfaceType=EST_Flesh,Sounds=("Footsteps.BFootstepFlesh1","Footsteps.BFootstepFlesh2","Footsteps.BFootstepFlesh3","Footsteps.BFootstepFlesh4","Footsteps.BFootstepFlesh5","Footsteps.BFootstepFlesh6"))
	FootstepSounds[7]=(SurfaceType=EST_Ice,Sounds=("Footsteps.BFootstepIce1","Footsteps.BFootstepIce2","Footsteps.BFootstepIce4","Footsteps.BFootstepIce4b","Footsteps.BFootstepIce5","Footsteps.BFootstepIce5b","Footsteps.BFootstepIce6","Footsteps.BFootstepIce6b"))
	FootstepSounds[8]=(SurfaceType=EST_Snow,Sounds=("Footsteps.BFootstepSnow1","Footsteps.BFootstepSnow2","Footsteps.BFootstepSnow3","Footsteps.BFootstepSnow4","Footsteps.BFootstepSnow5","Footsteps.BFootstepSnow6"))
	FootstepSounds[9]=(SurfaceType=EST_Water,Sounds=("Footsteps.BFootstepWater1","Footsteps.BFootstepWater2","Footsteps.BFootstepWater4","Footsteps.BFootstepWater5","Footsteps.BFootstepWater6"))
	FootstepSounds[10]=(SurfaceType=EST_Glass,Sounds=("Footsteps.BFootstepGlass1","Footsteps.BFootstepGlass2","Footsteps.BFootstepGlass4","Footsteps.BFootstepGlass5","Footsteps.BFootstepGlass6"))
	FootstepSounds[11]=(SurfaceType=EST_Sand,Sounds=("Footsteps.BFootstepSand1","Footsteps.BFootstepSand2","Footsteps.BFootstepSand4","Footsteps.BFootstepSand5","Footsteps.BFootstepSand6"))
	FootstepSounds[12]=(SurfaceType=EST_BrokenGlass,Sounds=("Footsteps.BFootstepBrokenGlass1","Footsteps.BFootstepBrokenGlass2","Footsteps.BFootstepBrokenGlass3","Footsteps.BFootstepBrokenGlass4","Footsteps.BFootstepBrokenGlass5","Footsteps.BFootstepBrokenGlass6"))
	FootstepSounds[13]=(SurfaceType=EST_Carpet,Sounds=("Footsteps.BFootstepCarpet1","Footsteps.BFootstepCarpet2","Footsteps.BFootstepCarpet4","Footsteps.BFootstepCarpet5","Footsteps.BFootstepCarpet6"))
	FootstepSounds[14]=(SurfaceType=EST_Ceramic,Sounds=("Footsteps.BFootstepCeramic1","Footsteps.BFootstepCeramic2","Footsteps.BFootstepCeramic3","Footsteps.BFootstepCeramic4","Footsteps.BFootstepCeramic5","Footsteps.BFootstepCeramic6"))
	FootstepSounds[15]=(SurfaceType=EST_MutedWood,Sounds=("Footsteps.BFootstepMutedWood1","Footsteps.BFootstepMutedWood2","Footsteps.BFootstepMutedWood3","Footsteps.BFootstepMutedWood4","Footsteps.BFootstepMutedWood5","Footsteps.BFootstepMutedWood6"))
	FootstepSounds[16]=(SurfaceType=EST_LightMetal,Sounds=("Footsteps.BFootstepLightMetal1","Footsteps.BFootstepLightMetal2","Footsteps.BFootstepLightMetal4","Footsteps.BFootstepLightMetal5","Footsteps.BFootstepLightMetal6"))
	FootstepSounds[17]=(SurfaceType=EST_Trash,Sounds=("Footsteps.BFootstepTrash1","Footsteps.BFootstepTrash2","Footsteps.BFootstepTrash3","Footsteps.BFootstepTrash4","Footsteps.BFootstepTrash5","Footsteps.BFootstepTrash6"))
	FootstepSounds[18]=(SurfaceType=EST_Shit,Sounds=("Footsteps.BFootstepShit1","Footsteps.BFootstepShit2","Footsteps.BFootstepShit4","Footsteps.BFootstepShit5","Footsteps.BFootstepShit6"))
	FootstepSounds[19]=(SurfaceType=EST_Puddle,Sounds=("Footsteps.BFootstepPuddles1","Footsteps.BFootstepPuddles2","Footsteps.BFootstepPuddles4","Footsteps.BFootstepPuddles5","Footsteps.BFootstepPuddles6"))
	SurfaceTypeTensions[0]=(SurfaceType=EST_Default,GroundSpeedMult=1.0,GroundFriction=8.0)
	SurfaceTypeTensions[1]=(SurfaceType=EST_Ice,GroundSpeedMult=1.1,GroundFriction=1.0)
	SurfaceTypeTensions[2]=(SurfaceType=EST_Snow,GroundSpeedMult=0.8,GroundFriction=13.0)
	SurfaceTypeTensions[3]=(SurfaceType=EST_Dirt,GroundSpeedMult=0.9,GroundFriction=9.0)
	SurfaceTypeTensions[4]=(SurfaceType=EST_Sand,GroundSpeedMult=0.9,GroundFriction=10.0)
	SurfaceTypeTensions[5]=(SurfaceType=EST_Shit,GroundSpeedMult=1.0,GroundFriction=4.0)
	SurfaceTypeTensions[5]=(SurfaceType=EST_Water,GroundSpeedMult=0.8,GroundFriction=13.0)
	
	HoldingCigarette=-1
	}
