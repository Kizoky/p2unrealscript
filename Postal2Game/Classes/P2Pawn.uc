///////////////////////////////////////////////////////////////////////////////
// Postal2Pawn
// Pawn stuff specific to Postal 2.
///////////////////////////////////////////////////////////////////////////////
class P2Pawn extends FPSPawn
	notplaceable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

// User set vars
// PawnAttributes
var (PawnAttributes) bool  bStartupRandomization;	// Randomizes some of these attributes
								// a little around there start values, in PostBeginPlay.
var (PawnAttributes) float Psychic;	// How well the character knows where something is
								// just through code, not through 'seeing'. Generally only used
								// when someone just lost their attacker, the higher this is the longer (though
								// never for very long) they could just know where the bad guy is.
var (PawnAttributes) float Champ;	// How persistantly they track their enemy. If set
								// high, he comes after you, set low, he stays put.
var (PawnAttributes) float Cajones;	// How likely he is to doing dangerous things like
								// walk through fire
var (PawnAttributes) float Temper;	// How quickly you get mad (usually from damage) see Anger below
var (PawnAttributes) float Glaucoma;// Determines how accurate and reliable their
								// targeting is. Lower settings are better.
var (PawnAttributes) float Twitch;	// Time between bursts
var (PawnAttributes) float Rat;		// How likely he will shout out the player or
								// an enemy's location or not.
var (PawnAttributes) float Compassion;	// How likely he is to shout "Get Down!"
								// before he fires to protect bystanders.
var (PawnAttributes) float WarnPeople;	// How likely someone is to warn their enemy
								// before shooting. Police high, Military low.
var (PawnAttributes) float Conscience;	// How likely they are in trying to avoid
								// hurting bystanders.
var (PawnAttributes) float Beg;		// How likely they are to beg for life.
var (PawnAttributes) float PainThreshold;	// How much a character can get hurt
								// before they run for their life.
var (PawnAttributes) float Reactivity;	// How quickly you react to things
var (PawnAttributes) float Confidence;	// How certain you are about things (like picking paths to run)
var (PawnAttributes) float Rebel;	// How likely you are to rebel against what you're told to do
								// Like when someone tells you get to Get Down.
var (PawnAttributes) float Curiosity;// How interested they are in the world around them.
var (PawnAttributes) float Patience; // How much you can harass them before they go crazy or get scared
var (PawnAttributes) float WillDodge;	// If they will try to dodge if you fire at them
var (PawnAttributes) float WillKneel;   // If they will kneel and fire, in a fire fight
var (PawnAttributes) float WillUseCover;// If they will try to find cover and use it (possibly if they're
									// are under attack. Also if they are running and have no weapon
var (PawnAttributes) float Talkative; // How likely they are to start up conversations or greet you on the street.
var (PawnAttributes) float Stomach;	// How likely they are to throw up or something, if you they see/have gross things
									// happen to them
var (PawnAttributes) travel float Armor;	// How much armor you have.
var (PawnAttributes) float ArmorMax;// How much armor you can possibly have
var (PawnAttributes) float VoicePitch;	// How much to adjust voice pitch (1.0 = normal)
var (PawnAttributes) float Greed;	// How greedy someone is. How likely they'll go for money the player has dropped
var (PawnAttributes) float TalkWhileFighting;	// How likely someone is to smack talk while they are fighting you.
var (PawnAttributes) int   MaxMoneyToStart;	// The pawn will start with between 0 and this number for how
									// much money they get.
var (PawnAttributes) bool  bScaredOfPantsDown; // if this is false, then they may just ignore that
									// you have your pants down. It defaults to true so everyone notices you. But
									// some people like doctors or something may not care about your pants being down.
									// Cops always do so this isn't tested in police/security.
var (PawnAttributes) bool  bTeamLeader;	// Usually reserved for military and swat types. Determines what
									// I do in group AI situations

// The 'Takes' damage reduction variables all go from 0.0 to 1.0. 1.0 means they allow the full HealthMax
// to be taken by this damage (a bystander shot in the face by a shotgun will react this way). 0.0, probably
// shouldn't be used, but it would mean they sustain no damage from that damage type.
var (PawnAttributes) float TakesShotgunHeadShot;// how suspectible they are to a direct shotgun blast to the face
var (PawnAttributes) float TakesRifleHeadShot;	// how suspectible they are to a sniper rifle round in the head
var (PawnAttributes) float TakesShovelHeadShot;	// how suspectible they are to a direct smack by a shovel to the head
var (PawnAttributes) float TakesOnFireDamage;	// If 1.0, they catch on fire and die. < 1.0, means they can fight
										// while on fire, and take that much less damage from the fire.
var (PawnAttributes) float TakesAnthraxDamage;	// If it's 1.0, they run away from anthrax, throw up blood and die,
										// < 1.0, means they run away, throw up blood, and then keep fighting, taking
										// less damage.
var (PawnAttributes) float TakesShockerDamage;	// This is the percentage of Health to HealthMax at which
										// the pawn either gets shocked and stands there dazed (higher)
										// or they fall over and pee themselves (equal or lower)

var (PawnAttributes) bool  bGunCrazy;	// This guy loves his gun (make sure to give him one first). If he
										// sees anyone with a gun, or hears anything, he'll just go attack
										// them on the spot

var (PawnAttributes)array<name> PatrolTags;	// Succession of tags for pathnodes that I walk between
									// Walk first to PatrolEndPoints[0], using the pathnodes system to get
									// there, then walk to PatrolEndPoints[1], etc (and then
									// back to 0, if there's no more). The point is, don't pick
									// all the pathnodes in between to make your path. That's determined
									// by the pathnode system. You pick the end points.
var (PawnAttributes) name  StartInterest;// If you want someone to stand in a q, set this to its tag, and
									// set their initial state to GoStandInQueue;

var (PawnAttributes) float TakesPistolHeadShot;// How susceptible they are to a direct pistol shot in the back of the
								//  head, execution style
var (PawnAttributes) float TakesMachinegunDamage; // How susceptible they are to any machine gun bullets
var (PawnAttributes) float TalkBeforeFighting;	// How liklely someone is to yell before they attack
var (PawnAttributes) float WeapChangeDist;	// If 0, weapon changing is ignored. If not, then the weapon
									// in BaseEquipment[0] is used for distances where the attacker is below
									// WeapChangeDist. BaseEquipment[1] is used for distance where the attacker is
									// greater than WeapChangeDist. A buffere is used also around this area to
									// keep them from consistently changing if the attacker is right on that distance.
									// BaseEquipement[0], [1] are actaully referenced by values in Personpawn
									// called CloseWeapon and FarWeaponIndex. These are editable. Police
									// change them by default.
var (PawnAttributes) float Fitness;	// Generally relates to how far they can run before they get tired. 0-1.0.
									// 1.0 is really fit, 0.0 is really unfit.
var (PawnAttributes) bool  bAdvancedFiring;	// Used so pawns can do extra crazy stuff--like always
									// shoot seeking rockets from a rocket launcher, instead of normal rockets.
var (PawnAttributes) float TwitchFar;	// Twitch will be the twitch time for the close weapon, TwitchFar is the
									// Twitch time for the far away weapon so you can make rocket launchers
									// wait longer than machineguns.
var (PawnAttributes) bool bNoRadarTarget;	// Disallows the use of Chompy the Voodoo Fish on this pawn.
var(PawnAttributes) bool bNoRadar;		// If true we won't be drawn on the radar at all (also prevents Chompy attacks)

// Internal vars
var bool bPlayerHater;			// Don't let editors set this. This is for when the errand makes people
								// hate the player on sight. Related to, but different from bPlayerIsEnemy.
								// All haters have bPlayerIsEnemy set, but not all pawns with bPlayerIsEnemy
								// should have bPlayerHater set.
var array<PathNode>	PatrolNodes;	// Actual pathnodes built from PatrolTags that is my patrol path.
var int	PatrolI;				// Index into PatrolTags.

var float Anger;				// Desire to shoot target. Overrides Cajones (even
								// if he's getting shot at, if this is high,
								// he'll try to shoot you anyway).
								// Proportional to Temper and how much you get hurt
var float Cowardice;			// How much of a scaredy cat someone is.

var TimedMarker MyMarker;		// Marks my dead body or maybe that i'm puking
								// Marker handles when body disappears

var bool bHasHead;				// Swap this with a MyHead to be put inside P2Pawn someday, rather than
								// having it in P2MocapPawn, maybe?
								// We have this here so the controllers can see if this guy has a head or not.

var bool bHeadCanComeOff;		// This should be set per character class who needs it. It defaults to true
								// meaning normal people can have their heads blown off. False means, they'll still
								// die, but they'll just fall over, and thier head won't blow off/pop off (like
								// the Krotchy character, in the foam suit).

var travel float CrackAddictionTime;// When this reaches 0, we'll be hurt by the crack addiction if we don't
								// get more crack
var float CrackMaxHealthPercentage;	// Percentage of your max health that crack takes you to, when you take it

var Material BurnSkin;			// what I switch to after I die from fire

var P2Pawn MyLeader;			// if i'm not a leader, this is set to who is the leader.

var float ReportLooksRadius;	// Radius within which people will be told what i look like (have weapon drawn, etc)

var bool bCompletedDeadSetup;	// I've been through my beginstate for the Dying state.

// Types of people
var bool bAuthorityFigure;		// If i'm something like police, military or swat. AI cares for friendly fire

// Inventory
var P2Weapon MyFoot;			// The thing that lets me do kicking
var int StartWeapon_Group;		// Start weapon is what you want to start the game with
var int StartWeapon_Offset;		// offset for that start weapon
var bool bHasViolentWeapon;		// I have a weapon that is considered violent (like pistol, not just hands)
var bool bPlayerStarting;		// Only for the player--the weapons need this info before a player controller is made
var class<P2Weapon> CloseWeap;	// Weapon class used (gotten out of BaseEquipment[0]) when the attacker is closer than
								// WeapChangeDist;
var class<P2Weapon> FarWeap;	// Weapon class used (gotten out of BaseEquipment[1]) when the attacker is farther than
								// WeapChangeDist.
var bool bHasDistanceWeapon;	// I have a weapon that I can strike at you with from a good distance (pistol,
								// throwing a grenade, rocket--not gas, or baton, kicking, etc.)
var bool bHasRef;				// Important pawn

// Animation
var EMood	mood;				// Very important for animations. As this changes, it determines which different
								// style of weapon handling the pawn has. For MP we set it to combat from the
								// start *and never change it*. It would require to multi-cast the mood to all
								// which isn't very doable.
var float	LeaderSlowdown;		// 0.0 to 1.0. Determines how much slower than normal people, leaders walk. This
								// is so their underlings can keep better pace with them.

// Dialog
var (PawnAttributes) class<P2Dialog> DialogClass;	// Dialog class to use
var P2Dialog myDialog;				// Reference to current dialog object

var class<P2Damage> LastDamageType;	// Last type we got hurt by (we can still get hurt after death)
var class<P2Damage> DyingDamageType;// Damage type that killed us

// equipment
// This is setup in struct form, because a array<class<>> thing wouldn't work with the compiler
struct PawnWeaponClassStruct
{
	var() class<Inventory> weaponclass;
};
// The unfortunate part about this setup, is that when you want BaseEquipment to take for someone
// you have to explicitly list all the entries right there. There is no inheritance, apparently.
// So you can't have BaseEquipment[0] set to hands in P2Pawn and then BaseEquipment[1] set to
// hand cuffs in Police. You have to set them both together, in Police.
// Also you don't necessarily need to use this for just weapons.. it can be
// any inventory item. It was just called that originally.
var (PawnAttributes) export editinline array<PawnWeaponClassStruct> BaseEquipment;

var byte ViolenceRankTolerance;	// What ViolenceRank you can tolerate. You don't mind any P2Weapon with a
								// ViolenceRank of this number or lower.
								// The default is 2 so anything over 0 you are concerned about

// Effects
var Emitter bloodpool;			// Blood pool I've made below me
var Emitter PeePool;			// Piss pool I've made below me
var PartDrip BodyDrips;			// What's dripping off of me
var bool bHasPeed;				// You've peed once if this is true
var int	PukeType;		// What I'm puking (normal puke or bloody, please)
//var travel int InfectedUrethra;
var int	 PukeCount;				// How many times have I thrown up? gross....
var bool bCrotchHit;			// Got hit in the crotch, sometimes you say special stuff then

var Sound FootKickHead;
var Sound FootKickBody;
var Sound ShovelHitHead;
var Sound ShovelCleaveHead;
var Sound ShovelHitBody;

var (PawnAttributes) float TakesChemDamage;	// If 1.0, become infected and fall down. < 1.0, means they can fight
										// while infected.
var (PawnAttributes) bool  bInnocent;		// True means, these characters could possibly not hate the player. Protestors for instance
											// are never innocent. They always carry a weapon and always attack things
											// (if the player instigates something especially.). But basic bystanders
											// are generally not that bad. So we check this for a few things (like getting
											// quick kills) later on.

var P2WeaponAttachment	MyWeapAttach;		// Independent of the weapon. The Weapon in the pawn should
											// have the attachement for this. But in networked games
											// this value is updatted by the attachment and used becuase
											// non-local clients don't have a Weapon in their pawn.

var bool bReceivedHeadShot;		// Local variable to see if you got hit in the head. Clear it after each
								// hit

// These two textures are generally only used for MP games (clothes handle changing the view
// of the character in SP games). They were put here instead of MpPawn because P2Weapon needs
// access to them
var Texture HandsTexture;		// Texture for the hand's of this person in 1st person view
var Texture	FootTexture;		// New skin for foot in fps mode for this person
var Texture DefaultHandsTexture;// Texture for normal dude hands. We need this really only as a constant
								// in Pawn before Player comes along, otherwise we'd use players. P2Player
								// has it because it uses it so often with the clothes powerups.
var Sound DudeSuicideSound;		// Dialog used for when he commits suicide. Seperate from
								// dialog because it wouldn't play correctly like that in MP.
var bool bShortSleeves;			// Whether the character you're playing is wearing a short sleeves
								// shirt--only used in MP games. (Dude doesn't have short sleeves).

var transient KarmaParamsCollision KParamsTrans; // Used *only* for preserving karma on pawns during a save
								// KParams in Actor can't be transient, but these need to be because they
								// are connected to the P2Player 'newed' Kparams made in the transient package.
								// If KParams is saved as it is, the save will fail, so we foist it off on to
								// this until the save is over.
var class<P2Weapon> HandsClass; // for short and long sleeves


// JWB: Shadow implementation
//var Effect_ShadowController RealtimeShadow;
//var bool bRealtimeShadows;
// JWB: Simple Shadows
var P2ShadowProjector PlayerShadow;

// Flag to forbid player from picking up cats
var bool bCannotPickupCats;		// If true this pawn can't pick up cats.

const RAND_ATTRIBUTE_DEFAULT=	0.2;

const REPORT_DEATH_RADIUS	=	4096;
const REMOVE_DEAD_BODY_RADIUS=	4096;
const BLOOD_DRIP_GRAVITY	=	-0.7;
const DIST_TO_WALL_FOR_BLOODSPLAT	=	450;
const DRIP_FLOOR_Z_CHECK	=	800;

// Moved this into properties so Gary etc. can redefine it for correct headshots. - Rick
//const HEAD_RATIO_OF_FULL_HEIGHT	=	0.5;
var float HEAD_RATIO_OF_FULL_HEIGHT;

const DISTANCE_TO_EXPLODE_HEAD	=	220;
const DISTANCE_TO_PUNCTURE_HEAD	=	140;  	//32; 	Change by Man Chrzan: xPatch 2.0 

const DIE_Z_MULT				=	1.3;
const DEATH_CRAWL_ON_FIRE_PCT	=	25;

const DEAD_CHECK_TO_REMOVE_TIME			=	3.0;
const INITIAL_DEAD_CHECK_TO_REMOVE_TIME	=	3.0;

const NO_CEILING_CHECK			=	1024;

// MAKE sure head timers are set to the same values
// It's hard to keep the heads in tune with the bodies on remote clients because
// they are in 'bTearOff' mode, so we don't have a pointer to the head like in normal
// SP or MP.
const REMOVE_DEAD_START_TIME	=	12.0;
const REMOVE_DEAD_TIME			=	2.0;

const REMOVE_DEAD_START_TIME_SP	=	30.0;
const REMOVE_DEAD_TIME_SP		=	8.0;

// Armor can allow a certain amount of damage through and absorb the rest.
// 1.0 means it absorbs all the damage, 0.0 means the pawn takes all the damage
const ARMOR_BULLET_BLOCK	=	0.85;
const ARMOR_BLUDGEON_BLOCK	=	0.5;
const ARMOR_EXPLODED_BLOCK	=	0.45;
const ARMOR_CUTTING_BLOCK	=	1.0;
const ARMOR_KICKING_BLOCK	=	1.0;
const ARMOR_SMASH_BLOCK		=	0.4;

// Make bullets kill people in interesting momentum ways
const BULLET_DAMP		= 0.1;
const BULLET_DAMP_BASE	= 0.1;

// Headshots in MP do a lot more damage
const HEAD_RATIO_MP				=	0.76;
const HEAD_SHOT_DAMAGE_MP		=	3.5;	// tries to make it so two pistol head shots kill a guy

// Spawn time (for playing weapon switch sounds)
var float SpawnTime;

// "Non-lethal" health
var float NonLethalHealth;

// This was defined in P2MoCapPawn but we need it here for determing blood/spark hits etc.
var bool					bIsAutomaton;

var int PeopleBurned;		// Number of people burned by our napalm launcher

// Added by Man Chrzan: xPatch 2.0
//var bool bIsBulletHit;		// For Bullet-Hit Blood effects
var(PawnAttributes) bool bForceDualWield;	// Enables dual wielding for all owned weapons (if possible).

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && bNetOwner && (Role==ROLE_Authority) )
		Armor;

	// Variables the server should send to the client.
//	reliable if(RoleROLE_Authority)
//		bPlayerStarting;

	// functions client sends this to server
	reliable if(Role < ROLE_Authority)
		Notify_PrepMouthForGrenade, Notify_SpawnGrenadeHead;

	// functions server sends this to client
	reliable if(Role == ROLE_Authority)
		ClientSetFoot, ClientSetUrethra, ClientPlayerStartingFinished, ClientStartRocketBeeping,
		ClientSniperViewingMe;
}

// STUB
function RemoveFluidSpout();

///////////////////////////////////////////////////////////////////////////
// Copied from LambController so we have notifications of being hit with
// fluids are not dependent on having a LambController
///////////////////////////////////////////////////////////////////////////
function HitWithFluid(Fluid.FluidTypeEnum ftype, vector HitLocation)
{
    // STUB
}

///////////////////////////////////////////////////////////////////////////////
// Nothing happens in alive version
///////////////////////////////////////////////////////////////////////////////
function AttemptZombieRevival(P2Pawn Other)
{
	// STUB defined in AWZombie
}

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	SpawnTime = Level.TimeSeconds;
	
	Super.PostBeginPlay();

	// See if the GameMod wants to do anything.
	P2GameInfoSingle(Level.Game).BaseMod.ModifyAppearance(Self);

	// Check to randomize the start values some if the LD said to
	if(bStartupRandomization)
	{
		RandomizeAttribute(Psychic, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Champ, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Cajones, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Temper, 0.08, 1.0, 0.0);
		RandomizeAttribute(Glaucoma, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Twitch, 1.0, 1000.0, 0.0);
		RandomizeAttribute(TwitchFar, 1.0, 1000.0, 0.0);
		RandomizeAttribute(Rat, 0.1, 1.0, -1.0);
		RandomizeAttribute(Compassion, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(WarnPeople, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Conscience, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Beg, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(PainThreshold, 0.1, 1.0, 0.0);
		RandomizeAttribute(Reactivity, 0.5, 1.0, 0.0);
		RandomizeAttribute(Confidence, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Rebel, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Curiosity, 0.5, 1.0, 0.0);
		RandomizeAttribute(Patience, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(WillDodge, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(WillKneel, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(WillUseCover, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Talkative, 0.09, 1.0, 0.0);
		RandomizeAttribute(Stomach, 0.1, 1.0, 0.0);
		RandomizeAttribute(SafeRangeMin, 1000, 100000.0, 0.0);
		RandomizeAttribute(VoicePitch, RAND_ATTRIBUTE_DEFAULT, 1.15, 0.85);
		RandomizeAttribute(DonutLove, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(Greed, 0.3, 1.0, 0.0);
		RandomizeAttribute(TalkWhileFighting, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(TalkBeforeFighting, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		RandomizeAttribute(WeapChangeDist, 0.2*WeapChangeDist, 100000.0, 0.0);
		RandomizeAttribute(Fitness, RAND_ATTRIBUTE_DEFAULT, 1.0, 0.0);
		MaxMoneyToStart = Rand(MaxMoneyToStart);
	}

	// Check entry values to make sure they make sense
	ClipFloat(Psychic, 1.0, 0.0);
	ClipFloat(Champ, 1.0, 0.0);
	ClipFloat(Cajones, 1.0, 0.0);
	ClipFloat(Temper, 1.0, 0.0);
	ClipFloat(Glaucoma, 1.0, 0.0);
	//ClipFloat(Twitch, 1.0, 0.0);
	ClipFloat(Rat, 1.0, -1.0);
	ClipFloat(Compassion, 1.0, 0.0);
	ClipFloat(WarnPeople, 1.0, 0.0);
	ClipFloat(Conscience, 1.0, 0.0);
	ClipFloat(Beg, 1.0, 0.0);
	ClipFloat(PainThreshold, 1.0, 0.0);
	ClipFloat(Reactivity, 1.0, 0.0);
	ClipFloat(Confidence, 1.0, 0.0);
	ClipFloat(Rebel, 1.0, 0.0);
//	ClipFloat(Psychic, 1.0, 0.0);
//	ClipFloat(Psychic, 1.0, 0.0);
	ClipFloat(SafeRangeMin, 100000.0, 0.0);
	ClipFloat(Fitness, 1.0, 0.0);

	// Make his starting health be the health max that they set.
	Health = HealthMax;
	SetMaxHealth(HealthMax);
	NonLethalHealth = HealthMax;

	Cowardice = 1.0-PainThreshold; // Currently these are the opposite but linked

	// Set default mood
	SetMood(MOOD_Normal, 1.0);

	// Build your patrol path if you have one
	BuildPatrolPath();

	// Only for the player--the weapons need this info before a player controller is made
	bPlayerStarting=true;

	// One is for all the pawns in the level, the other is just for pawns
	// that will be counted as 'extra' or expendable and removed when you scale
	// down the slider in the options
	if(P2GameInfo(Level.Game) != None)
		P2GameInfo(Level.Game).PawnsActive++;
/*
	// These are extremely slow.. they must be turned on in the options
	if(P2GameInfo(Level.Game).FullBodyShadows())
	{
		MyShadow = Spawn(class'ShadowProjector',Self,'',Location);
		MyShadow.ShadowActor = self;
		MyShadow.LightDirection = Normal(vect(1,1,3));
		MyShadow.LightDistance = 380;
		MyShadow.MaxTraceDistance = 350;
		MyShadow.UpdateShadow();
	}
*/
    // Postal 2 Shadows. Only simply ones are in atm.
    if (bActorShadows && P2GameInfo(Level.Game).bPlayerShadows && (Level.NetMode != NM_DedicatedServer))
	{
		// decide which type of shadow to spawn
		if (P2GameInfo(Level.Game).bSimpleShadows)
		{
			PlayerShadow = Spawn(class'P2ShadowProjector',Self,'',Location);
			PlayerShadow.ShadowActor = self;
			PlayerShadow.LightDirection = Normal(vect(1,1,3));
			PlayerShadow.LightDistance = 320;
			PlayerShadow.MaxTraceDistance = 350;
			PlayerShadow.InitShadow();
        }
	}
	
	//log(self$" postbeginplay ");
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PlayerStartingFinished()
{
	bPlayerStarting=false;
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		ClientPlayerStartingFinished();

}
function ClientPlayerStartingFinished()
{
	bPlayerStarting=false;
}

///////////////////////////////////////////////////////////////////////////////
// PawnSpawner sets some things for you.
// See the explanation in pawnspawner as to why this function just a silly,
// long copy of all these variables and what it should be changed to.
// This is totally ugly, but I didn't go and set all these things *also* in the
// PawnSpawner defaults because if you change one of them in here, you'd have
// to make sure to always coordinate them in there, and that seems like it
// would be *even worse* (as bad as this is) than this.
// The theory with the DEF_SPAWN_FLOAT is that all these are defaulted to
// -1, because most of the time they go from 0 to 1.0, so I wouldn't want to
// let it default 0. So if it's not -1, then they've probably changed it initially.
// As for boolean variables, they default to false and always get set.
// So the editor has to be mindful of the defaults of the class getting
// spawned and reset them accordingly.
///////////////////////////////////////////////////////////////////////////////
function InitBySpawner(PawnSpawner initsp)
{
	local int i;
	local Inventory Tmp;

	Super.InitBySpawner(initsp);

	if(initsp.InitVoicePitch != DEF_SPAWN_FLOAT)
		VoicePitch				= initsp.InitVoicePitch;
	if(initsp.InitTwitch != DEF_SPAWN_FLOAT)
		Twitch					= initsp.InitTwitch;
	if(initsp.InitPsychic != DEF_SPAWN_FLOAT)
		Psychic					= initsp.InitPsychic;
	if(initsp.InitChamp != DEF_SPAWN_FLOAT)
		Champ					= initsp.InitChamp;
	if(initsp.InitCajones != DEF_SPAWN_FLOAT)
		Cajones					= initsp.InitCajones;
	if(initsp.InitTemper != DEF_SPAWN_FLOAT)
		Temper					= initsp.InitTemper;
	if(initsp.InitGlaucoma != DEF_SPAWN_FLOAT)
		Glaucoma				= initsp.InitGlaucoma;
	if(initsp.InitRat != DEF_SPAWN_FLOAT)
		Rat						= initsp.InitRat;
	if(initsp.InitCompassion != DEF_SPAWN_FLOAT)
		Compassion				= initsp.InitCompassion;
	if(initsp.InitWarnPeople != DEF_SPAWN_FLOAT)
		WarnPeople				= initsp.InitWarnPeople;
	if(initsp.InitConscience != DEF_SPAWN_FLOAT)
		Conscience				= initsp.InitConscience;
	if(initsp.InitBeg != DEF_SPAWN_FLOAT)
		Beg						= initsp.InitBeg;
	if(initsp.InitPainThreshold != DEF_SPAWN_FLOAT)
		PainThreshold			= initsp.InitPainThreshold;
	if(initsp.InitReactivity != DEF_SPAWN_FLOAT)
		Reactivity				= initsp.InitReactivity;
	if(initsp.InitConfidence != DEF_SPAWN_FLOAT)
		Confidence				= initsp.InitConfidence;
	if(initsp.InitRebel != DEF_SPAWN_FLOAT)
		Rebel					= initsp.InitRebel;
	if(initsp.InitCuriosity != DEF_SPAWN_FLOAT)
		Curiosity				= initsp.InitCuriosity;
	if(initsp.InitPatience != DEF_SPAWN_FLOAT)
		Patience				= initsp.InitPatience;
	if(initsp.InitWillDodge != DEF_SPAWN_FLOAT)
		WillDodge				= initsp.InitWillDodge;
	if(initsp.InitWillKneel != DEF_SPAWN_FLOAT)
		WillKneel				= initsp.InitWillKneel;
	if(initsp.InitWillUseCover != DEF_SPAWN_FLOAT)
		WillUseCover			= initsp.InitWillUseCover;
	if(initsp.InitTalkative != DEF_SPAWN_FLOAT)
		Talkative				= initsp.InitTalkative;
	if(initsp.InitStomach != DEF_SPAWN_FLOAT)
		Stomach					= initsp.InitStomach;
	if(initsp.InitArmor != DEF_SPAWN_FLOAT)
		Armor					= initsp.InitArmor;
	if(initsp.InitArmorMax != DEF_SPAWN_FLOAT)
		ArmorMax				= initsp.InitArmorMax;
	if(initsp.InitGreed != DEF_SPAWN_FLOAT)
		Greed					= initsp.InitGreed;
	if(initsp.InitTalkWhileFighting != DEF_SPAWN_FLOAT)
		TalkWhileFighting		= initsp.InitTalkWhileFighting;
	if(initsp.InitMaxMoneyToStart != DEF_SPAWN_FLOAT)
		MaxMoneyToStart			= initsp.InitMaxMoneyToStart;

	if(initsp.InitbScaredOfPantsDown== 0)
		bScaredOfPantsDown= false;
	else if(initsp.InitbScaredOfPantsDown== 1)
		bScaredOfPantsDown= true;

	if(initsp.InitbTeamLeader== 0)
		bTeamLeader= false;
	else if(initsp.InitbTeamLeader== 1)
		bTeamLeader= true;

	if(initsp.InitTakesShotgunHeadShot != DEF_SPAWN_FLOAT)
		TakesShotgunHeadShot	= initsp.InitTakesShotgunHeadShot;
	if(initsp.InitTakesRifleHeadShot != DEF_SPAWN_FLOAT)
		TakesRifleHeadShot		= initsp.InitTakesRifleHeadShot;
	if(initsp.InitTakesShovelHeadShot != DEF_SPAWN_FLOAT)
		TakesShovelHeadShot		= initsp.InitTakesShovelHeadShot;
	if(initsp.InitTakesOnFireDamage != DEF_SPAWN_FLOAT)
		TakesOnFireDamage		= initsp.InitTakesOnFireDamage;
	if(initsp.InitTakesAnthraxDamage != DEF_SPAWN_FLOAT)
		TakesAnthraxDamage		= initsp.InitTakesAnthraxDamage;
	if(initsp.InitTakesShockerDamage != DEF_SPAWN_FLOAT)
		TakesShockerDamage		= initsp.InitTakesShockerDamage;

	if(initsp.InitbGunCrazy== 0)
		bGunCrazy= false;
	else if(initsp.InitbGunCrazy== 1)
		bGunCrazy= true;

	if(initsp.InitStartInterest != '')
		StartInterest			= initsp.InitStartInterest;
	if(initsp.InitTakesPistolHeadShot != DEF_SPAWN_FLOAT)
		TakesPistolHeadShot		= initsp.InitTakesPistolHeadShot;
	if(initsp.InitTakesMachinegunDamage != DEF_SPAWN_FLOAT)
		TakesMachinegunDamage	= initsp.InitTakesMachinegunDamage;
	if(initsp.InitTalkBeforeFighting != DEF_SPAWN_FLOAT)
		TalkBeforeFighting		= initsp.InitTalkBeforeFighting;
	if(initsp.InitWeapChangeDist != DEF_SPAWN_FLOAT)
		WeapChangeDist			= initsp.InitWeapChangeDist;
	if(initsp.InitFitness != DEF_SPAWN_FLOAT)
		Fitness					= initsp.InitFitness;

	if(initsp.InitbAdvancedFiring== 0)
		bAdvancedFiring= false;
	else if(initsp.InitbAdvancedFiring== 1)
		bAdvancedFiring= true;

	// Edit base inventory if necessary.
	if(initsp.InitBaseEquipment.Length > 0)
	{
		// Clear out the old inventory first.
		for(i = 0; i < BaseEquipment.Length; i++)
		{
			Tmp = FindInventoryType(BaseEquipment[i].weaponclass);

			if(Tmp != None)
			{
				DeleteInventory(Tmp);
				Tmp.Destroy();
			}
		}

		// Empty the old weapon array.
		BaseEquipment.Remove(0, BaseEquipment.Length);

		for(i = 0; i < initsp.InitBaseEquipment.Length; i++)
		{
			if(initsp.InitBaseEquipment[i] == None)
			{
				log(initsp @ "No inventory class in InitBaseEquipment at index" @ i);
				continue;
			}
			BaseEquipment.Length = BaseEquipment.Length + 1;
			BaseEquipment[BaseEquipment.Length - 1].weaponclass = initsp.InitBaseEquipment[i];
		}
	}
	
	// Add patrol tags
	if (initsp.InitPatrolTag != 'None')
	{
		PatrolTags.Insert(0,1);
		PatrolTags[0] = initsp.InitPatrolTag;
		BuildPatrolPath();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Build your patrol path if you have one.
// Comes from the tags in PatrolTags and goes into a dynamic array called PatrolNodes
///////////////////////////////////////////////////////////////////////////////
function BuildPatrolPath()
{
	local PathNode newnode;
	local int i;

	foreach AllActors(class'PathNode', newnode)
	{
		for(i=0; i < PatrolTags.Length; i++)
		{
			if(PatrolTags[i] == newnode.Tag)
			{
				//log(self$" adding "$newnode$" with tag "$newnode.Tag);
				PatrolNodes.Insert(PatrolNodes.Length, 1);
				PatrolNodes[PatrolNodes.Length-1] = newnode;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Do this before you teleport
///////////////////////////////////////////////////////////////////////////////
event bool PreTeleport( Teleporter InTeleporter )
{
	if(PersonController(Controller) != None)
		PersonController(Controller).PreTeleport(InTeleporter);

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Randomize by randval AROUND val and return it.
// Don't randomize if you're at a limit
///////////////////////////////////////////////////////////////////////////////
function RandomizeAttribute(out float val, float randval, float max, float min)
{
	local float half;
	if(val > min && val < max)
	{
		half = randval/2;

		val += randval*FRand() - half;

		if(val < min)
			val = min;
		else if(val > max)
			val = max;
	}
}


///////////////////////////////////////////////////////////////////////////////
// If you're a team leader, walk a little slower, so the others can
// catch up to you.
///////////////////////////////////////////////////////////////////////////////
function float GetDefaultWalkingPct()
{
	if(bTeamLeader)
		return LeaderSlowdown*default.WalkingPct;
	else
		return default.WalkingPct;
}
function float GetDefaultMovementPct()
{
	if(bTeamLeader)
		return LeaderSlowdown*default.MovementPct;
	else
		return default.MovementPct;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the client knows about the foot
///////////////////////////////////////////////////////////////////////////////
function ClientSetFoot(P2Weapon newfoot)
{
	MyFoot = newfoot;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the client knows about the urethra
///////////////////////////////////////////////////////////////////////////////
function ClientSetUrethra(P2Weapon newurethra)
{
	MyUrethra = newurethra;
}

///////////////////////////////////////////////////////////////////////////////
// Determines how much a threat to the player this pawn is
///////////////////////////////////////////////////////////////////////////////
function float DetermineThreat()
{
	if(Health > 0)
	{
		if(LambController(Controller) != None)
			return LambController(Controller).DetermineThreat();
		else if(P2Player(Controller) != None)
			return P2Player(Controller).DetermineThreat();
	}

	return 0.0;
}

///////////////////////////////////////////////////////////////////////////////
// Compute offset for drawing an inventory item.
///////////////////////////////////////////////////////////////////////////////
simulated function vector CalcDrawOffset(inventory Inv)
{
	local vector DrawOffset;

	if ( P2Player(Controller) == None )
		return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);

	DrawOffset = ((0.9/Weapon.DisplayFOV * 100 * ModifiedPlayerViewOffset(Inv)) >> GetViewRotation() );
	if ( !IsLocallyControlled() )
		DrawOffset.Z += BaseEyeHeight;
	else
	{
		DrawOffset.Z += EyeHeight;
        if(P2Player(Controller).bWeaponBob)
		    DrawOffset += WeaponBob(Inv.BobDamping);
        DrawOffset += CameraShake();
	}
	return DrawOffset;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function vector WeaponBob(float BobDamping)
{
	Local Vector WBob;
	local vector x1, y1, z1;

	WBob = BobDamping * WalkBob;
	WBob.Z = (0.45 + 0.55 * BobDamping) * WalkBob.Z;
	return WBob;
}

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
			BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
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
///////////////////////////////////////////////////////////////////////////////
function vector CameraShake()
{
    local vector x, y, z, shakevect;
    local PlayerController pc;

    pc = PlayerController(Controller);

    if (pc == None)
        return shakevect;

    GetAxes(pc.Rotation, x, y, z);

    shakevect = pc.ShakeOffset.X * x +
                pc.ShakeOffset.Y * y +
                pc.ShakeOffset.Z * z;

    return shakevect;
}

///////////////////////////////////////////////////////////////////////////////
// Radar uses this
///////////////////////////////////////////////////////////////////////////////
simulated function CheckInDoors()
{
	local vector AboveMe;

	if(P2Player(Controller) != None)
	{
		// Check a good ways above us, and see if we're "in doors".
		AboveMe = Location;
		AboveMe.z += NO_CEILING_CHECK;
		if(FastTrace(Location, AboveMe))
			P2Player(Controller).RadarInDoors=0;
		else
			P2Player(Controller).RadarInDoors=1;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Tell other people around you that you have a big weapon(or not). They might care
///////////////////////////////////////////////////////////////////////////////
function ReportPersonalLooksToOthers()
{
	local P2Pawn CheckP;
	local PersonController Personc;
	local vector loc;

	// Don't do it if you're dead or have no controller
	if(Health <= 0
		|| Controller == None)
		return;

	// Tell the pawns around me what i look like,
	// but tell them from the top of my head.
	loc = Location;
	loc.z += CollisionHeight;
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, ReportLooksRadius, loc)
	{
		// If not me
		if(CheckP != self
			// if still alive (and not dying)
			&& CheckP.Health > 0)
		{
			Personc = PersonController(CheckP.Controller);
			if(Personc != None)
			{
				Personc.CheckObservePawnLooks(self);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Tell other people around you that you have a big weapon(or not). They might care
// Don't allow this in MP--have radar handle finding players
///////////////////////////////////////////////////////////////////////////////
function ReportPlayerLooksToOthers(out array<P2Pawn> PawnsAroundMe, bool bRecordPawns,
									out byte InDoors)
{
	local P2Pawn CheckP;
	local PersonController Personc;
	local vector loc, AboveMe;

	// Don't do it if you're dead or have no controller
	if(Health <= 0
		|| Controller == None)
		return;

	// Tell the pawns around me what i look like,
	// but tell them from the top of my head.
	loc = Location;
	loc.z += CollisionHeight;

	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		if(bRecordPawns)
		// If they are recorded, then they're stuffed into an array for the radar.
		// The radar uses this list to display the 'fish'.
		{
			if(PawnsAroundMe.Length > 0)
				PawnsAroundMe.Remove(0, PawnsAroundMe.Length);

			// Check a good ways above us, and see if we're "in doors".
			AboveMe = Location;
			AboveMe.z += NO_CEILING_CHECK;
			if(FastTrace(Location, AboveMe))
				InDoors=0;
			else
				InDoors=1;

			ForEach CollidingActors(class'P2Pawn', CheckP, ReportLooksRadius, loc)
			{
				// If not me
				if(CheckP != self
					// if still alive (and not dying)
					&& CheckP.Health > 0)
				{
					// Record them for the radar (players and NPCs)
					if(CheckP.Controller != None
						&& !CheckP.bNoRadar)
					{
						PawnsAroundMe.Insert(PawnsAroundMe.Length, 1.0);
						PawnsAroundMe[PawnsAroundMe.Length-1] = CheckP;
					}

					// Tell the SP NPC's about the player.
					Personc = PersonController(CheckP.Controller);
					if(Personc != None)
						Personc.CheckObservePawnLooks(self);
				}
			}
		}
		else	// Not recording the pawns means you're just telling
			// the single player AI what you're doing. This is how it knows
			// how to react to you in various ways.
		{
			// Sure VisibleCollidingActors is faster, but it doesn't seem to work! People
			// behind crotch level obstructions don't get updates. Seems a lot like 'visible'
			// means not rendered and "can't trace from center to center". Bad, bad.. use CollidingActors from now on
			ForEach CollidingActors(class'P2Pawn', CheckP, ReportLooksRadius, loc)
			{
				// If not me
				if(CheckP != self
					// if still alive (and not dying)
					&& CheckP.Health > 0)
				{
					Personc = PersonController(CheckP.Controller);
					if(Personc != None)
					{
						Personc.CheckObservePawnLooks(self);
					}
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// GetGonorrhea
// You've contracted gonorrhea
///////////////////////////////////////////////////////////////////////////////
function bool ContractGonorrhea()
{
	// STUB handled in personpawn
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// CureGonorrhea
// You've fixed your gonorrhea
///////////////////////////////////////////////////////////////////////////////
function bool CureGonorrhea()
{
	// STUB handled in personpawn
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// You've got a vd if true
///////////////////////////////////////////////////////////////////////////////
function bool UrethraIsInfected()
{
	// STUB handled in personpawn
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// My head says I'm still talking
///////////////////////////////////////////////////////////////////////////////
function bool IsTalking()
{
	// STUB handled in personpawn
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Handle health additions, but uses the percentage passed in to determine
// how much health to add to the player.
// Returns true if it added any health at all
// If any is left over, the amount returned back is also a percentage
///////////////////////////////////////////////////////////////////////////////
function bool AddHealthPct(float NewHealthPct,
						optional int Tainted,
						optional out float LeftOver,
						optional bool bIsAddictive,
						optional bool bCanSurpassMax,
						optional bool bIsFood)
{
	local float LeftOverAbs;
	local float HeathRatio;
	local bool breturn;

	breturn = AddHealth(NewHealthPct*HealthPctConversion,
				Tainted,
				LeftOverAbs,
				bIsAddictive,
				bCanSurpassMax,
				bIsFood);

	LeftOver = LeftOverAbs/HealthPctConversion;

	return breturn;
}

///////////////////////////////////////////////////////////////////////////////
// Handle health additions
// Returns true if it added any health at all
///////////////////////////////////////////////////////////////////////////////
function bool AddHealth(float NewHealth,
						optional int Tainted,
						optional out float LeftOver,
						optional bool bIsAddictive,
						optional bool bCanSurpassMax,
						optional bool bIsFood)
{
	local float HealthAdded;

	if (Health < HealthMax
		|| bCanSurpassMax)
	{
		Health += NewHealth;
		if(Health > HealthMax
			&& !bCanSurpassMax)
		{
			LeftOver = Health - HealthMax;	// record what we didn't use
			Health = HealthMax;
		}
		if(P2Player(Controller) != None)
		{
			P2Player(Controller).AddedHealth(NewHealth - LeftOver, bIsAddictive, Tainted, bIsFood);
		}
		//log("health "$Health);
		//log("left over "$LeftOver);
		//log("health added "$NewHealth-LeftOver);
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// See if you want this armor
///////////////////////////////////////////////////////////////////////////////
function bool AcceptThisArmor(float ArmorAdd, optional float UseArmorMax)
{
	if(UseArmorMax == 0)
		UseArmorMax = ArmorMax;

	if(Armor < UseArmorMax)
		return true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Change textures/icons/models if we're wearing armor
///////////////////////////////////////////////////////////////////////////////
function UsingNewArmor(Texture HudArmorIcon,
					   class<Inventory> HudArmorClass)
{
	// Only change the icon if we accepted the armor.
	if(P2Player(Controller) != None)
	{
		// This updates the icon see in the hud for this armor.
		P2Player(Controller).HudArmorIcon = HudArmorIcon;
		// This is to transfer armor type info across levels.
		P2Player(Controller).HudArmorClass = HudArmorClass;
	}
}

///////////////////////////////////////////////////////////////////////////////
// AddArmor
// Add some armor, but only if we need it. UseArmorMax is used for
// making the armor percetage go passed 100.
///////////////////////////////////////////////////////////////////////////////
function bool AddArmor(float ArmorAdd, Texture HudArmorIcon,
					   class<Inventory> HudArmorClass, optional float UseArmorMax)
{
	// Don't let bots use armor unless we make them store the hudarmor class
	// somewhere properly
	if(P2Player(Controller) != None)
	{
		if(UseArmorMax == 0)
			UseArmorMax = ArmorMax;

		if(Armor < UseArmorMax
			&& Health > 0)
		{
			Armor += ArmorAdd;
			if(Armor > UseArmorMax)
			{
				Armor = UseArmorMax;
			}
			// Only change the icon if we accepted the armor.
			UsingNewArmor(HudArmorIcon, HudArmorClass);
			return true;
		}
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// ReduceArmor
// Take away some armor
///////////////////////////////////////////////////////////////////////////////
function ReduceArmor(float ArmorDamage, Vector HitLocation)
{
	Armor -= ArmorDamage;
	if(Armor < 0)
		Armor = 0;
}

///////////////////////////////////////////////////////////////////////////////
//	Get the percentage of your armor (usually for display purposes)
///////////////////////////////////////////////////////////////////////////////
function int GetArmorPercent()
{
	return (100*Armor)/ArmorMax;
}

///////////////////////////////////////////////////////////////////////////////
// When you're dead, check to quickly add kevlar to your inventory, to
// have it dropped by you
///////////////////////////////////////////////////////////////////////////////
function DropArmorDead()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Pick Twitch when we're using our close weapon and TwitchFar when we're using
// our far weapon. Default to Twitch when in doubt.
///////////////////////////////////////////////////////////////////////////////
function float GetTwitch()
{
	if(Weapon != None
		&& Weapon.class == FarWeap)
		return TwitchFar;
	else
		return Twitch;
}

///////////////////////////////////////////////////////////////////////////////
//	Check the head for collision here
//	Use bEasyHit for a bigger area to collide with the heads, resulting in a
//  more likely hit.
///////////////////////////////////////////////////////////////////////////////
function bool CheckHeadForHit(vector HitLocation, out float ZDist, optional bool bEasyHit)
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
//	detonate the head
///////////////////////////////////////////////////////////////////////////////
function ExplodeHead(vector HitLocation, vector Momentum)
{
}

///////////////////////////////////////////////////////////////////////////////
//	poke a whole in the head
///////////////////////////////////////////////////////////////////////////////
function PunctureHead(vector HitLocation, vector Momentum)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
//	Decapitate the head and send it flying.
///////////////////////////////////////////////////////////////////////////////
function PopOffHead(vector HitLocation, vector Momentum)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Pee your pants.
///////////////////////////////////////////////////////////////////////////////
function PeePants()
{
	// STUB detailed in PersonPawn
}

///////////////////////////////////////////////////////////////////////////////
// Stop peeing your pants--turn off the feeder
///////////////////////////////////////////////////////////////////////////////
function StopPeeingPants()
{
	// STUB detailed in PersonPawn
}

///////////////////////////////////////////////////////////////////////////////
// This is primarily taken straight from Pawn,
// Except, only let people hurt animals by hopping on them (not people on people)
///////////////////////////////////////////////////////////////////////////////
singular event BaseChange()
{
	local float decorMass;
	local Rotator ZeroRot;

	if ( bInterpolating )
		return;
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if (Base != None
		&& Base.IsA('AWZombie'))
		JumpOffPawn();
	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise we do some damage and jump off.
	else if ( Pawn(Base) != None )
	{
		if ( !Pawn(Base).bCanBeBaseForPawns
			&& (P2MocapPawn(Base) == None
				|| !P2MocapPawn(Base).bIsDeathCrawling))
		{
			// Only let people hurt animals by jumping on them
			if(AnimalController(Pawn(Base).Controller) != None)
				Base.TakeDamage( (1-Velocity.Z/400)* Mass/Base.Mass, Self,Location,0.5 * Velocity , class'Crushed');

			JumpOffPawn();
		}
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);

		// NPC's can still crush other things
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, class'Crushed');
	}
	else if(PeoplePart(Base) != None)
		// Don't let you stand on heads, becuase when you stand on them, and then kick
		// them, you're view can get rotated all screwy, as the head spins away.
	{
		JumpOffPawn();
	}
}

///////////////////////////////////////////////////////////////////////////////
//	Tries to make a small blood splat on the ground based on hit velocity
///////////////////////////////////////////////////////////////////////////////
function DripBloodOnGround(vector Momentum)
{
	local Actor HitActor;
	local vector checkpoint, HitNormal, HitLocation;

	//log("before mom "$Momentum);
	Momentum.x*=FRand();
	Momentum.y*=FRand();
	Momentum = Normal(Momentum);
	Momentum.z=BLOOD_DRIP_GRAVITY;
	//log("after mom "$Momentum);
	checkpoint = Location + DRIP_FLOOR_Z_CHECK*Momentum;
	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true);
	if ( HitActor != None
		&& HitActor.bWorldGeometry
		&& HitNormal.z > 0.9)
	{
		spawn(class'BloodDripSplatMaker',self,,HitLocation,rotator(HitNormal));
	}
}

///////////////////////////////////////////////////////////////////////////////
//	A blood splash here
///////////////////////////////////////////////////////////////////////////////
function BloodHit(vector BloodHitLocation, vector Momentum)
{
	local vector BloodOffset, dir, HitLocation, HitNormal, checkpoint;
	local float tempf;
	local Actor HitActor;
	//, Mo;
	//local class<Effects> DesiredEffect;
//		class<P2Damage>(damageType).static.GetPawnDamageEffect(HitLocation, Damage, Momentum, self, (Level.bDropDetail || !Level.bHighDetailMode));
//		DesiredEffect = DamageType.static.GetPawnDamageEffect(HitLocation, Damage, Momentum, self, (Level.bDropDetail || !Level.bHighDetailMode));

//		if ( DesiredEffect != None )
//		{

	// Find direction to center
	dir = BloodHitLocation - Location;
	dir = Normal(BloodHitLocation - Location);
	// push it away from the his center
	BloodOffset = 0.2 * CollisionRadius * dir;
	// pull it up some from the bottom and pull it down from the top
	BloodOffset.Z = BloodOffset.Z * 0.75;

	//Mo = Momentum;
	//if ( Mo.Z > 0 )
		//Mo.Z *= 0.5;

//			spawn(DesiredEffect,self,,BloodHitLocation + BloodOffset);//, rotator(Mo));
//		}
	////////////////
	// Blood that squirts in the air
	if(!bReceivedHeadShot)
		spawn(class'BloodImpactMaker',self,,BloodHitLocation+BloodOffset,Rotator(dir));
	else// Do a special effect if you hit them in the head so they
		// can see they did well
		spawn(class'BloodImpactHeadShotMaker',self,,BloodHitLocation+BloodOffset,Rotator(dir));	 


	//log(self$" blood hit "$bloodhitvar);

	////////////////
	// Blood that shoots onto the wall
	// Check to see if you're close enough to the wall, to squirt blood on it.
	// Do this by coming out of the actor where we hit and continue along the path
	// that goes from the original hit point, toward the player. (So look
	// behind the player)
	checkpoint = BloodHitLocation + DIST_TO_WALL_FOR_BLOODSPLAT*Normal(Momentum);
	//log("momentum "$Momentum);
	HitActor = Trace(HitLocation, HitNormal, checkpoint, BloodHitLocation, true);

	//log(self$" blood hit, hit actor "$HitActor);

	if ( HitActor != None
		&& HitActor.bStatic )
//	if(LevelInfo(HitActor) != None
//		|| TerrainInfo(HitActor) != None
//		|| StaticMeshActor(HitActor) != None
//		|| Brush(HitActor) != None)
	{
		spawn(class'BloodMachineGunSplatMaker',self,,HitLocation,rotator(HitNormal));
	}

	////////////////
	// Drips of blood on the ground around you (smaller)
	if(FRand() <= 0.7)
	{
		DripBloodOnGround(Momentum);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Dust like effects for a hit impact
///////////////////////////////////////////////////////////////////////////////
function DustHit(vector HitLocation, vector Momentum)
{
	// STUB done in personpawn
}

///////////////////////////////////////////////////////////////////////////////
// Spark effects for a hit impact
///////////////////////////////////////////////////////////////////////////////
function SparkHit(vector HitLocation, vector Momentum, byte PlayRicochet)
{
	// STUB done in personpawn
}

///////////////////////////////////////////////////////////////////////////////
// Electrical effects--only in MP (handled differently in SP)
///////////////////////////////////////////////////////////////////////////////
function ElectricalHit()
{
	// STUB done in personpawn
}

///////////////////////////////////////////////////////////////////////////////
//	Does damage effects (blood) and plays hit animations
///////////////////////////////////////////////////////////////////////////////
function PlayHit(float Damage, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
	if ( (Damage <= 0)
		&& Controller != None
		&& !Controller.bGodMode )
		return;

	if(ClassIsChildOf(DamageType, class'BloodMakingDamage'))
	{
		if (bIsAutomaton)
			SparkHit(HitLocation, Momentum, 0);
		else if(class'P2Player'.static.BloodMode())
		{
			// Added by Man Chrzan: xPatch 2.0 ED Blood Effects
			//if(ClassIsChildOf(DamageType, class'BulletDamage'))
			//	bIsBulletHit = true;
			//else
			//	bIsBulletHit = false;
			// end
			
			BloodHit(HitLocation, Momentum);
		}
		else
			DustHit(HitLocation, Momentum);
	}
	else if(damageType == class'BodyDamage')
	// do a pansy effect like dust or something
	{
		DustHit(HitLocation, Momentum);
	}
	else if(damageType == class'ElectricalDamage'
		&& !FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		ElectricalHit();
	}

	if ( Level.TimeSeconds - LastPainTime > 0.1 )
	{
		PlayTakeHit(HitLocation,Damage,damageType);
		LastPainTime = Level.TimeSeconds;
	}
	bReceivedHeadShot=false;
}

///////////////////////////////////////////////////////////////////////////////
// Swap out to our burned mesh
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim()
{
	// Always refix the ambient glow
	SetAmbientGlow(default.AmbientGlow);

	if(class'P2Player'.static.BloodMode() && !bIsAutomaton)
	{
		// Set my body skin
		Skins[0] = BurnSkin;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Begin the process for swapping to the burn skin in MP games. Don't
// actually do it here though
///////////////////////////////////////////////////////////////////////////////
function SwapToBurnMPStart()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Set ambient glow
///////////////////////////////////////////////////////////////////////////////
function SetAmbientGlow(int NewGlow)
{
	if(Skins[0] != BurnSkin)
	{
		// Set my body
		AmbientGlow = NewGlow;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Die with a grenade in your mouth
// Can't get around this, even with God mode
///////////////////////////////////////////////////////////////////////////////
function GrenadeSuicide()
{
	// STUB defined in Dude.uc
}

///////////////////////////////////////////////////////////////////////////////
// Anim notifies associated with the grenade suicide

///////////////////////////////////////////////////////////////////////////////
// Make a grenade in his hand
///////////////////////////////////////////////////////////////////////////////
function Notify_SpawnGrenadeHand()
{
}
///////////////////////////////////////////////////////////////////////////////
// Take the spawned grenade from his hand
///////////////////////////////////////////////////////////////////////////////
function Notify_RemoveGrenadeHand()
{
}
///////////////////////////////////////////////////////////////////////////////
// Ready the mouth! (blend it to open wide)
///////////////////////////////////////////////////////////////////////////////
function Notify_PrepMouthForGrenade()
{
}
///////////////////////////////////////////////////////////////////////////////
// Put the grenade in his head and open the mouth
///////////////////////////////////////////////////////////////////////////////
function Notify_SpawnGrenadeHead()
{
}
///////////////////////////////////////////////////////////////////////////////
// Remove the grenade in his head and close the mouth
///////////////////////////////////////////////////////////////////////////////
function Notify_RemoveGrenadeHead()
{
}
///////////////////////////////////////////////////////////////////////////////
// End of: Anim notifies associated with the grenade suicide

///////////////////////////////////////////////////////////////////////////////
// Starts follow me anim on server--called by ServerFire--no need to rep. MP only
///////////////////////////////////////////////////////////////////////////////
function ServerFollowMe()
{
}

///////////////////////////////////////////////////////////////////////////////
// Starts stay here anim on server--called by ServerFire--no need to rep. MP only
///////////////////////////////////////////////////////////////////////////////
function ServerStayHere()
{
}

///////////////////////////////////////////////////////////////////////////////
// Make the body drip
///////////////////////////////////////////////////////////////////////////////
function MakeDrip(Fluid.FluidTypeEnum ftype, vector HitLocation)
{
	//STUB--handled in personpawn
}

///////////////////////////////////////////////////////////////////////////////
// You're head has fluids dripping of it
///////////////////////////////////////////////////////////////////////////////
function bool HeadIsDripping()
{
	//STUB--handled in personpawn
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Stop the dripping
///////////////////////////////////////////////////////////////////////////////
function WipeHead()
{
	//STUB--handled in personpawn
}

///////////////////////////////////////////////////////////////////////////////
// Something's happening (like a crouch our puke) where we need to stop all the
// dripping (body and head)
///////////////////////////////////////////////////////////////////////////////
simulated function StopAllDripping()
{
	//STUB--handled in personpawn
}

///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
function float GetRandPitch()
{
	return (0.96 + FRand()*0.08);
}

///////////////////////////////////////////////////////////////////////////////
// Check which body part closest to this point, aiming in to the center
///////////////////////////////////////////////////////////////////////////////
function name FindBodyPart(vector HitPoint)
{
	// STUB--defined in p2mocappawn
	return 'None';
}

///////////////////////////////////////////////////////////////////////////////
// Check to hurt the head (I took the stupid logic of 'using the top of the collision volume'
// from Epic's code
// Check for special HEAD SHOTS
// True means whatever damage was dealt (either headshot--or even no damage from a perfect block
// dealt out by something like TakesPistolHeadShot == 0.))
//
// MPGary overrides this.
///////////////////////////////////////////////////////////////////////////////
function bool HandleSpecialShots(int Damage, vector HitLocation, vector Momentum, out class<DamageType> ThisDamage,
							vector XYdir, Pawn InstigatedBy, out int returndamage, out byte HeadShot)
{
	local float PercentUpBody, ZDist, DistToMe, BoostDamage;

	// Only let the player get special head shots
	// Projectile weapons
	if(FPSPawn(InstigatedBy).bPlayer
		|| (P2GameInfoSingle(Level.Game) != None && P2GameInfoSingle(Level.Game).InMasochistMode()))	// xPatch: Ludicurous difficulty
	{
		if(Health > 0)
		{
			if(ThisDamage == class'ShotgunDamage'
				|| ThisDamage == class'RifleDamage'
				|| ThisDamage == class'BulletDamage'
				|| ClassIsChildOf(ThisDamage, class'SuperRifleDamage')	// xPatch
				|| ThisDamage == class'SuperShotgunDamage'				// xPatch
				|| ThisDamage == class'SuperBulletDamage')				// xPatch

			{
				// For if no damage is done
				if(TakesShotgunHeadShot == 0.0
					|| TakesShotgunHeadShot == 0.0
					|| TakesPistolHeadShot == 0.0)
				{
					// Make a ricochet sound and puff out some smoke and sparks
					SparkHit(HitLocation, Momentum, 1);//Rand(2));
					DustHit(HitLocation, Momentum);
					returndamage = 0;
					return true;
				}

				PercentUpBody = (hitlocation.z - Location.z)/CollisionHeight;
				//log("dist to head for explode try "$VSize(XYDir));
				//log("percent up body "$PercentUpBody);
				// Check to see if we're in fake head shot range
				if(PercentUpBody > HEAD_RATIO_OF_FULL_HEIGHT)
				{
					DistToMe = VSize(XYdir);

					if((DistToMe < DISTANCE_TO_PUNCTURE_HEAD
							|| (P2GameInfo(Level.Game) != None
								&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
						&& (ThisDamage == class'BulletDamage'
							|| ThisDamage == class'SuperBulletDamage'))	// xPatch: Super one too.
					// Is close enough with a pistol and behind them to puncture head with a pistol
					{
						// Check a little more accurately, if you actually hit the head or not
						// And check to make sure the guy got shot from behind, before we allow it.
						if(((Momentum dot vector(Rotation)) > 0
								&& CheckHeadForHit(HitLocation, ZDist))
							|| (P2GameInfo(Level.Game) != None
								&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
						{
							// We've hit the head, now reduce the damage, if necessary
							if(!(P2GameInfo(Level.Game) != None
								&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
							{
								// xPatch: Actually, make super one 2x more effective.
								if(ThisDamage == class'SuperBulletDamage')
								{
									BoostDamage = TakesPistolHeadShot * 2;
									if(BoostDamage > 1.00)
										BoostDamage = 1.00;
										
									returndamage = BoostDamage*HealthMax;
								}
								else
									returndamage = TakesPistolHeadShot*HealthMax;
							}
							else
								returndamage = HealthMax;
							// if this kills them, puncture the head
							if(returndamage >= Health
								&& bHeadCanComeOff
								&& !(P2GameInfo(Level.Game) != None
									&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
							{
								// record special kill
								if(P2GameInfoSingle(Level.Game) != None
									&& P2GameInfoSingle(Level.Game).TheGameState != None
									&& P2Pawn(InstigatedBy) != None
									&& P2Pawn(InstigatedBy).bPlayer)
								{
									P2GameInfoSingle(Level.Game).TheGameState.PistolHeadShot++;
								}

								if(class'P2Player'.static.BloodMode())
								{
									// xPatch: Super one explodes it instead.
									if(ThisDamage == class'SuperBulletDamage')
										ExplodeHead(HitLocation, Momentum);
									else
										PunctureHead(HitLocation, Momentum);
								}
							}
							HeadShot = 1;
							return true;
						}
						// Over the head but not hitting the head means this guy won't take damage
						// If we had hit the head, the above would have returned already
						if(ZDist > 0)
							return false;
					}
					else if((DistToMe < DISTANCE_TO_EXPLODE_HEAD && ThisDamage == class'ShotgunDamage')
								|| ThisDamage == class'SuperShotgunDamage')	// xPatch: SuperShotgunDamage Fix
					// Is close enough with a shotgun to explode the head
					{
						// Check a little more accurately, if you actually hit the head or not
						if(CheckHeadForHit(HitLocation, ZDist))
						{
							// We've hit the head, now reduce the damage, if necessary
							if(!(P2GameInfo(Level.Game) != None
								&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
							{
								// xPatch: Change for Headshots option
								if(P2GameInfoSingle(Level.Game).xManager.bSPHeadshots)
								{
									if(TakesShotgunHeadShot >= 0.5)
										returndamage = HealthMax; 
									else
										returndamage = Damage * 4;
								}
								else // End
									returndamage = TakesShotgunHeadShot*HealthMax;
							}
							else
								returndamage = HealthMax;

							// if this kills them, blow their head up
							if(returndamage >= Health
								&& bHeadCanComeOff)
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
							HeadShot = 1;
							return true;
						}
						// Over the head but not hitting the head means this guy won't take damage
						// If we had hit the head, the above would have returned already
						if(ZDist > 0)
							return false;
					}
					else if(ThisDamage == class'RifleDamage'
							|| ClassIsChildOf(ThisDamage, class'SuperRifleDamage'))	// xPatch: handle the Super version too.
					// Sniper rifle round to the head punctures your head
					{
						// We've hit the head, now reduce the damage, if necessary
						returndamage = TakesRifleHeadShot*HealthMax;	// Restored by Man Chrzan: xPatch 2.0
						//returndamage = HealthMax;						// Why someone made it insta-kill everything?
						// if this kills them, puncture the head
						if(returndamage >= Health
							&& bHeadCanComeOff)
						{
							// record special kill
							if(P2GameInfoSingle(Level.Game) != None
								&& P2GameInfoSingle(Level.Game).TheGameState != None
								&& P2Pawn(InstigatedBy) != None
								&& P2Pawn(InstigatedBy).bPlayer
								&& (ThisDamage == class'RifleDamage' // xPatch: Don't record Rifle Headshots for SuperRifleDamage extensions
									|| ThisDamage == class'SuperRifleDamage'))	// like the new MinigunDamage for Paradise Lost.
							{
								P2GameInfoSingle(Level.Game).TheGameState.RifleHeadShot++;
							}

							if(class'P2Player'.static.BloodMode())
							{
								// xPatch: Super one explodes, normal one punctures.
								if(ClassIsChildOf(ThisDamage, class'SuperRifleDamage'))
									ExplodeHead(HitLocation, Momentum);
								else
									PunctureHead(HitLocation, Momentum);
							}
						}
						HeadShot = 1;
						return true;
					}
				}
				// continue on, if this didn't take
			}
			else if((P2GameInfo(Level.Game) != None
						&& P2GameInfo(Level.Game).PlayerGetsHeadShots())
					&& ThisDamage == class'MachinegunDamage')
				// Just for the silly head shots cheat
			{
				PercentUpBody = (hitlocation.z - Location.z)/CollisionHeight;
				if(PercentUpBody > HEAD_RATIO_OF_FULL_HEIGHT)
				{
					// We've hit the head, now make it take two machine gun bullets
					// to down a guy when hit in the head.
					returndamage = 0.5*HealthMax;
					HeadShot = 1;
					return true;
				}
				// Over the head but not hitting the head means this guy won't take damage
				// If we had hit the head, the above would have returned already
				if(ZDist > 0)
					return false;
			}
		}
	}

	// Melee
	if(ClassIsChildOf(ThisDamage, class'BludgeonDamage'))
	{
		if(CheckHeadForHit(HitLocation, ZDist, true))
		{
			// shovel's knock heads off
			if(ThisDamage == class'ShovelDamage')
			{
				// Decide randomly to knock the head off. If you're closer to
				// death, then be more likely to make the head pop off
				// Let the player take off heads, and let NPCs take off each
				// others heads
				if(bHeadCanComeOff
					&& class'P2Player'.static.BloodMode()
					&& FRand() >= Health/HealthMax
					&& (P2Player(InstigatedBy.Controller) != None
						|| P2Player(Controller) == None))
				{
					// We've hit the head, now compound the damage, if necessary
					returndamage = TakesShovelHeadShot*HealthMax;
				}
				else
				{
					returndamage = Damage;
				}
				// If this kills them, pop off the head
				if(returndamage >= Health)
				{
					PopOffHead(HitLocation, Momentum);
					HeadShot = 1;
					PlaySound(ShovelCleaveHead,,,,,GetRandPitch());
				}
				else // Otherwise, they just get hit in the head, hard
					PlaySound(ShovelHitHead,,,,,GetRandPitch());
			}
			else if(ThisDamage == class'BatonDamage')
				// batons incapacitate people.
			{
				if(P2GameInfoSingle(Level.Game) != None
					&& P2GameInfoSingle(Level.Game).VerifySeqTime()
					&& P2Pawn(InstigatedBy) != None
					&& P2Pawn(InstigatedBy).bPlayer)
				{
					// We've hit the head, now reduce the damage, if necessary
					// use same version as shotgun explodes
					returndamage = TakesShotgunHeadShot*HealthMax;
					// if this kills them, explodes the head
					if(returndamage >= Health
							&& bHeadCanComeOff)
					{
						if(class'P2Player'.static.BloodMode())
						{
							ExplodeHead(HitLocation, Momentum);
						}
					}
					HeadShot = 1;
					return true;
				}
				else
					returndamage = Damage;
			}
			else if(ThisDamage == class'KickingDamage')
			{
				PlaySound(FootKickHead,,,,,GetRandPitch());
				// kicking to the face just draws blood
				returndamage = Damage;
			}
			else
			{
				returndamage = Damage;
			}
			return true;
		}
		else // if it was a bludgeon attack, but didn't hit the
			// face, then don't draw blood
		{
			if(ThisDamage == class'ShovelDamage')
			{
				PlaySound(ShovelHitBody,,,,,GetRandPitch());
			}
			else if(ThisDamage == class'KickingDamage')
			{
				PlaySound(FootKickBody,,,,,GetRandPitch());
			}
			// Cutting attacks always draw blood, but if not, at this point
			// we only want a dust hit, so change the damage type.
			if(!ClassIsChildOf(ThisDamage, class'CuttingDamage'))
			{
				if (ThisDamage == class'CuttingDamageShovel'
					|| ThisDamage == class'ShovelDamage')
					ThisDamage = class'BodyDamageShovel';
				else
				{
					//log(ThisDamage@"converted to Body Damage");
					ThisDamage = class'BodyDamage';
				}
			}
		}
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Get headshot damage based on weapon--defined in MpPawn
///////////////////////////////////////////////////////////////////////////////
function int GetHeadShotDamageMP(class<DamageType> ThisDamage, int Damage)
{
	return Damage;
}

///////////////////////////////////////////////////////////////////////////////
// Check to see if this is a headshot in MP games
///////////////////////////////////////////////////////////////////////////////
function bool IsMPHeadshot(vector hitlocation)
{
	return false; // STUB
}

///////////////////////////////////////////////////////////////////////////////
// Lower the damage based on body location, closer to the center of the
// person, the closer to Damage it is
// Taking the incident angle and the angle from the hit to the center,
// the more inline these two are, the closer the return damage is to Damage.
//
// MPGary overrides this.
///////////////////////////////////////////////////////////////////////////////
function int ModifyDamageByBodyLocation( int Damage, Pawn InstigatedBy,
						  vector HitLocation, vector Momentum,
						  out class<DamageType> ThisDamage,
						  out byte HeadShot)
{
	local int returndamage;
	local vector XYdir, MyRot;
	local float dotcheck;
	local float PercentUpBody, ZDist;
	local float diffoffset, critprc;

	if(Controller != None
		&& Controller.bGodMode)
		return 0;

	if(InstigatedBy == None
		|| InstigatedBy.Controller == None
		// Check to for two teams shooting each other--don't do anything if so
		|| (IsPlayerPawn()
			&& instigatedby.IsPlayerPawn()
			&& PlayerReplicationInfo.Team != None	// Make sure we're using teams
			&& PlayerReplicationInfo.Team == instigatedby.PlayerReplicationInfo.Team))
		return Damage;

	// Find the direction in the xy direction
	XYdir = HitLocation - InstigatedBy.Location;
	XYdir.z = 0;

	// Check to hurt the head (i took the stupid logic of 'using the top of the collision volume'
	// from Epic's code
	// Check for special HEAD SHOTS
	if(HandleSpecialShots(Damage, HitLocation, Momentum, ThisDamage,
				XYdir, InstigatedBy, returndamage, HeadShot))
	{
		return returndamage;
	}

	if(ClassIsChildOf(ThisDamage, class'BulletDamage'))
	{
		// Test first for no machinegun damage
		if(ThisDamage == class'MachinegunDamage')
		{
			if(TakesMachinegunDamage == 0)
			{
				// Make a ricochet sound and puff out some smoke and sparks
				SparkHit(HitLocation, Momentum, 1);//Rand(2));
				DustHit(HitLocation, Momentum);
				returndamage = 0;
				return returndamage;
			}
			else
				Damage = TakesMachinegunDamage*Damage;
		}
		
		// xPatch: Tell if it's a headshot but don't change the damage.
		// Done so we can spawn STP Headshot FX in Singleplayer if enabled.
		if(IsMPHeadshot(hitlocation) && Class'EffectMaker'.default.bSTPBloodFX)	
			bReceivedHeadShot=true;
			
		// Multiply damage from dude by a certain factor
		Damage = FPSPawn(InstigatedBy).DamageMult*Damage;

		// If you shoot the head in MP, make it take off more damage. Don't do
		// any centering checks on the head.. any shot will do
		if((Level.Game == None
				|| !Level.Game.bIsSinglePlayer)
			&& IsMPHeadshot(hitlocation))
			//&& ((hitlocation.z - Location.z)/CollisionHeight) >= HEAD_RATIO_MP)
		{
			returndamage = P2Pawn(InstigatedBy).GetHeadShotDamageMP(ThisDamage, Damage);
			//returndamage = HEAD_SHOT_DAMAGE_MP*Damage;
			bReceivedHeadShot=true;
		}
		else // Make the shot take off more damage if it's closer to his center (but
			// not a head shot).
		{
			// Make the momentum be the vector from the hit point, to the pawn's center point.
			Momentum = HitLocation - Location;
			Momentum.z = 0;
			Momentum = Normal(Momentum);

			// Now compare how inline with the hit vector is (the momentum) to the vector from the attacker
			// to the attacked. The more inline, the more damage done.
			XYdir = Normal(XYdir);
			dotcheck = XYdir dot Momentum;

			returndamage = Damage*abs(dotcheck);
			//log(self$" second-- vect to target "$xydir$" hitpoint to center "$momentum$" dot "$dotcheck$" new damage "$returndamage);
		}
		
		// xPatch: Optional Singleplayer Headshots!	
		if(P2GameInfoSingle(Level.Game).xManager.bSPHeadshots)
		{										
			// We will reuse a multiplayer headshot detection.
			if ( IsMPHeadshot(hitlocation) )
			{
				// We hit non-player pawn
				if(!Controller.bIsPlayer )
					returndamage = P2Pawn(InstigatedBy).GetHeadShotDamageMP(ThisDamage, Damage);
				else // We hit the player
				{
					diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();
					critprc = 0.25;
					
					// Depending on difficulty increase the headshot chance a little for NPCs
					// diffoffset = 1 -> critprc 0.30 (+0.05), diffoffset = 10 -> critprc = 0.75 (+0.50) etc.
					if(diffoffset > 0)
						critprc = critprc + (0.05 * diffoffset);
						
					if( FRand() < critprc)
						returndamage = P2Pawn(InstigatedBy).GetHeadShotDamageMP(ThisDamage, Damage);
				}
					
			}
		}
		// END

		// Check to ensure the damage takes at least one PERCENT off your health
		if(returndamage < OneUnitInHealth)
			returndamage = OneUnitInHealth;
			
				
		// xPatch: handle this new damage type too (for Revolver).
		// It doesn't use any TakesSomethingHeadShot so do it here.
		if (ClassIsChildOf(ThisDamage, class'SuperBulletDamage'))
		{
			if(IsMPHeadshot(hitlocation)
				&& returndamage >= Health
				&& bHeadCanComeOff)
			{
				if(class'P2Player'.static.BloodMode())
					ExplodeHead(HitLocation, Momentum);
			}
		}

		return returndamage;
	}
	// Reduce Shocker damage as necessary
	else if(ThisDamage == class'ElectricalDamage')
	{
		returndamage = Damage;
		if(TakesShockerDamage == 0.0)
		{
			returndamage = 0;
		}

		return returndamage;
	}
	// modify how much fire hurts us
	else if(ClassIsChildOf(ThisDamage, class'BurnedDamage')
		|| ClassIsChildOf(ThisDamage, class'OnFireDamage'))
	{
		returndamage = Damage*TakesOnFireDamage;
		return returndamage;
	}

	return Damage;
}

///////////////////////////////////////////////////////////////////////////////
// Don't do anything if the vel mag is 0
///////////////////////////////////////////////////////////////////////////////
function AddVelocity( vector NewVelocity)
{
	if ( bIgnoreForces )
		return;

	// return earlier if you have nothing to do
	if(NewVelocity.x==0
		&& NewVelocity.y==0
		&& NewVelocity.z==0)
		return;

	// Dont set to falling or the guy will not transition to animations properly
	if ( Physics != PHYS_KarmaRagDoll
		&& (Physics == PHYS_Walking
		&& NewVelocity.z != 0)
		|| (((Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) && (NewVelocity.Z > Default.JumpZ)) )
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

///////////////////////////////////////////////////////////////////////////////
// ArmorAbsorbDamage
// Intercept damage, and if you have armor on, and it's a certain type of damage,
// modify the damage amount, based on the what hurt you.
// Armor doesn't do anything for head shots
///////////////////////////////////////////////////////////////////////////////
function ArmorAbsorbDamage(Pawn instigatedby, out int Damage, class<DamageType> damageType,
						   Vector hitlocation)
{
	local float ArmorDamage;

	// Allow friendly fire to take off armor now that it functions more consistently. Friendly
	// fire past version 1408 now includes explosive and bullets. So if you have it on, it should
	// take off armor as usual.
	//
	// It used to not before bullets were only included as friendly fire and not explosives.
	/*
	if(IsPlayerPawn()
		&& instigatedby.IsPlayerPawn()
		&& PlayerReplicationInfo.Team != None	// Make sure we're using teams
		&& PlayerReplicationInfo.Team == instigatedby.PlayerReplicationInfo.Team)
		return;
	*/

	// Has armor, now check for damage types
	if(ClassIsChildOf(damageType, class'BulletDamage'))
	{
		// armor blocks most bullet damage
		ArmorDamage = Damage*ARMOR_BULLET_BLOCK;
	}
	else if(ClassIsChildOf(damageType, class'BludgeonDamage'))
	{
		// armor blocks about half the bludgeoning
		ArmorDamage = Damage*ARMOR_BLUDGEON_BLOCK;
	}
	else if(ClassIsChildOf(damageType,class'ExplodedDamage'))
	{
		// armor blocks a little bit of explosive damage
		ArmorDamage = Damage*ARMOR_EXPLODED_BLOCK;
	}
	else if(ClassIsChildOf(damageType, class'CuttingDamage'))
	{
		// armor blocks a lot of cutting damage
		ArmorDamage = Damage*ARMOR_CUTTING_BLOCK;
	}
	else if(ClassIsChildOf(damageType, class'KickingDamage'))
	{
		// armor blocks a lot of kicking damage
		ArmorDamage = Damage*ARMOR_KICKING_BLOCK;
	}
	else if(ClassIsChildOf(damageType, class'SmashDamage'))
	{
		// armor blocks about half smash damage
		ArmorDamage = Damage*ARMOR_SMASH_BLOCK;
	}
	// ArmorDamage is how much damage the armor will sustain. This is
	// how much it absorbs. The rest goes to the pawn.
	Damage = Damage - ArmorDamage;
	// Check to ensure the damage takes at least one PERCENT off your health
	if(Damage < OneUnitInHealth)
		Damage = OneUnitInHealth;

	// Now reduce our armor by how much damage to it there was
	ReduceArmor(ArmorDamage, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
//  Handle effects side of things for body fire
///////////////////////////////////////////////////////////////////////////////
function SetOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	local FireTorsoEmitter tfire;

	if(MyBodyFire == None)
	{
		tfire = Spawn(class'FireTorsoEmitter',self,,Location);
		tfire.SetPawns(self, Doer);
		tfire.SetFireType(bIsNapalm);

		Super.SetOnFire(Doer, bIsNapalm);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set to be infected.
///////////////////////////////////////////////////////////////////////////////
function SetInfected(FPSPawn Doer)
{
	if(MyBodyChem == None)
	{
		MyBodyChem = Spawn(class'ChemTorsoEmitter',self,,Location);
		ChemTorsoEmitter(MyBodyChem).SetPawns(self, Doer);

		Super.SetInfected(Doer);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Take damage (pawn call) but also save who attacked me
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;
	local int returnDamage;
	local vector OrigMomentum;
	local byte HeadShot;
	local LambController lambc;
	local int StartDamage;
	local class<Inventory> TestClass;

//	log(self$" TakeDamage d "$Damage$" p "$instigatedBy$" hit "$HitLocation$" mom "$Momentum$" type "$DamageType$" state "$GetStateName()$" god mode "$Controller.bGodMode,'Debug');
	lambc = LambController(Controller);

	// If we don't have a controller then we're either the player in a movie, or
	// we're an NPC starting out in a pain volume--either way, we don't
	// want to take damage in this state, without a controller.
	// For the player, this gives him god mode, while a movie is playing.
	if(Controller == None)
		return;

	if(!AcceptHit(hitlocation, momentum))
		return;

	// Wake them from stasis now that we've been hit
	if(Controller.bStasis)
		lambc.ComeOutOfStasis(false);

	// If I'm already on fire, don't take any more damage from fire
	if(MyBodyFire != None
		&& ClassIsChildOf(damageType, class'BurnedDamage'))
		return;

	// Used for debugging.
	if(NO_ONE_DIES != 0)
		return;

	DamageInstigator = instigatedBy;
	StartDamage = Damage;
	// Calc the damage based on the body location for the hit
	Damage = ModifyDamageByBodyLocation(Damage, InstigatedBy, HitLocation,
										momentum, DamageType, HeadShot);
	// Save the momentum because for some reason it has to be squished in Z so most poeple
	// don't go flying into the air from a bullet shot.
	OrigMomentum = momentum;

	// Eleminate any momentum from clean head shots, so the head gets hurt/removed, but
	// the body just slumps down
	if(HeadShot == 1)
		Momentum = vect(0, 0, 0);

	//////////
	// The following is mostly the original TakeDamage from Engine.Pawn but I had to change
	// a few idiotic things like the momentum getting randomly modified.
	//////////
	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();

	if ( instigatedBy == self )
		momentum *= 0.6;

	momentum = momentum/Mass;

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	// Armor check.
	// Intercept damage, and if you have armor on, and it's a certain type of damage,
	// modify the damage amount, based on the what hurt you.
	// Armor doesn't do anything for head shots
	if(Armor > 0
		&& HeadShot==0
		&& !bReceivedHeadShot
		&& (Controller == None
			|| !Controller.bGodMode)
		&& ActualDamage > 0)
		ArmorAbsorbDamage(instigatedby, ActualDamage, DamageType, HitLocation);

	// If the pawn's puking up blood from an anthrax infection, don't let any further anthrax damage kill them before they're done.
	if (ActualDamage >= Health
		&& (Controller.IsInState('PoisonedByAnthrax') || Controller.IsInState('RunFromAnthrax'))
		&& ClassIsChildOf(DamageType, class'AnthDamage'))
		ActualDamage = Health - 1;

	//log(Self$" damage in "$Damage$" actual "$ActualDamage$" type "$DamageType$" my team "$PlayerReplicationInfo.Team$" inst team "$instigatedBy.PlayerReplicationInfo.Team);
	// Don't call at all if you didn't get hurt
	if(Actualdamage <= 0)
	{
		// Tell the character about the non-damage. Most of them will ignore this damage
		// but some people (like Krotchy) will use this to do things
		// Report the original damage asked to be delivered as a negative, so it's not
		// used as actual damage, but it's used to know how bad the damage would have been.
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, -StartDamage, DamageType, Momentum);
		return;
	}

	// he needs to catch on fire because this was a real fire (not just a match)
	if(ClassIsChildOf(damageType, class'BurnedDamage'))
	{
		if(lambc != None)
			lambc.CatchOnFire(FPSPawn(instigatedBy), (damageType==class'NapalmDamage'));
		else
			SetOnFire(FPSPawn(instigatedBy), (damageType==class'NapalmDamage'));
	}

	// We got hit with a plague. You're infected now.
	if(damageType == class'ChemDamage'
		&& lambc != None)
	{
		lambc.ChemicalInfection(FPSPawn(instigatedBy));
		return;
	}
	// This guy needs to violently throw up blood and die
	// Make sure this guy takes at least some damage first, otherwise, just leave
	if(ClassIsChildOf(damageType, class'AnthDamage')
		&& lambc != None)
	{
		// Takes no damage
		if(TakesAnthraxDamage <= 0.0)
		{
			// Tell the character about the attack
			if ( lambc.Attacker != instigatedBy)
				lambc.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
			return;
		}
		else // Runs to throw up blood
		{
			lambc.AnthraxPoisoning(P2Pawn(instigatedBy));
			return;
		}
	}

	// Check about the friendly player hurting people. If the player shoots people that are
	// his friends, the damage is removed from their threshold. When that reaches zero, the
	// are no longer friends, but enemies with him
	if(P2Pawn(instigatedBy) != None
		&& P2Pawn(instigatedBy).bPlayer
		&& bPlayerIsFriend)
	{
		FriendDamageThreshold = int(FriendDamageThreshold) - actualDamage;
		// He's turned to your enemy
		if(FriendDamageThreshold <= 0)
		{
			FriendDamageThreshold = 0;
			bPlayerIsFriend=false;
			bPlayerIsEnemy=true;
		}
	}
	
	// Handle non-lethal damage
	if (class<P2Damage>(damageType) != None
		&& class<P2Damage>(damageType).default.bNonLethal)
	{
		// Take damage in non-lethal health.
		NonLethalHealth -= actualDamage;
		// Zero out if below zero. Controller will handle being "knocked out"
		if (NonLethalHealth < 0)
			NonLethalHealth = 0;
	}

	// Now that we're officially damage, check the damage types we don't want to kill
	// us all the way. If taking away this much health would have killed us and we don't
	// want it to, reduce us to one unit of health.
	// We don't want to go below this, becuase the HUD will display 0, and that will look
	// broken.
	else if(class<P2Damage>(damageType) != None
		&& (!class<P2Damage>(damageType).default.bCanKill
			|| (class<P2Damage>(damageType).default.bNoKillPlayers
				&& bPlayer))
		&& ((Health - actualDamage) < OneUnitInHealth))
	{
		Health = OneUnitInHealth;
	}
	else
	{
		// if this damage type CAN kill you, take off damage like normal
		Health = Health - actualDamage;
	}

	// Save the type that just hurt us
	LastDamageType = class<P2Damage>(DamageType);

	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( bAlreadyDead )
	{
		Warn(self$" took regular damage "$damagetype$" from "$instigatedby$" while already dead at "$Level.TimeSeconds$" in state "$GetStateName());
		//ChunkUp(-1 * Health);
		return;
	}

	// Monkey with the explosion momentum until we get everything handled by either
	// karma or animations
	if(ClassIsChildOf(damageType,class'ExplodedDamage'))
	{
		// Dampen the z if he's not dead until we get animations in there that make sense
		if(Health > 0)
		{
			Momentum.z = 0.25*Momentum.z;
		}
	}
	// Don't make things shoot you up into the air unless it's specific damage types
	else if(class<P2Damage>(damageType) == None
			|| !class<P2Damage>(damageType).default.bAllowZThrow)
	{
		if(Physics == PHYS_Walking)
			momentum.z=0;
	}

	// Send the real momentum to this function, please
	PlayHit(actualDamage, hitLocation, damageType, OrigMomentum);
	//log(self@"took damage"@ActualDamage@Health,'Debug');

	if ( Health <= 0 )
	{
		// If fire has killed me,
		// or we're on fire and we died,
		// then swap to my burn victim mesh
		if(damageType == class'OnFireDamage'
			|| ClassIsChildOf(damageType, class'BurnedDamage')
			|| MyBodyFire != None)
		{
			if(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
				SwapToBurnVictim();
			else
				SwapToBurnMPStart();
		}

		// pawn died
		if ( instigatedBy != None )
			Killer = InstigatedBy.GetKillerController();
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = OrigMomentum / Mass;

		Died(Killer, damageType, HitLocation);
	}
	else
	{
		// Dampen crazy momentum on death from bullets
		if(ClassIsChildOf(damageType, class'BulletDamage'))
		{
			AddVelocity( (FRand()*BULLET_DAMP + BULLET_DAMP_BASE)*momentum );
		}
		else
			AddVelocity( momentum );

		// Tell the character about the damage
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}

	MakeNoise(1.0);

	// If I'm on fire and it's the fire on me, that's hurting me, then
	// darken me, based on how much life I have left
	if(damageType == class'OnFireDamage'
		&& actualDamage > 0)
	{
		// Only change ambient glow if we don't have a burned texture
		// Use default ambient glow because 255 is pulsing
		SetAmbientGlow((Health*default.AmbientGlow)/HealthMax);
		// Sometimes fall over early, and swap our burned skin now,
		// so we can deathcrawl and look really gross
		if(Health > 0 && Health < (FRand()*DEATH_CRAWL_ON_FIRE_PCT)
			&& PersonController(Controller) != None
			&& !PersonController(Controller).IsInState('DeathCrawlFromAttacker'))
		{
			PersonController(Controller).DoDeathCrawlAway();
			// Swap early, so we'll deathcrawl all burnt
			SwapToBurnVictim();
		}
	}

	// This guy needs to shake a lot from getting electricuted. He'll probably
	// pee his pants
	// Putting it down here ensure he gets hurt by this, but also will go to this new state
	if(lambc != None)
	{
		if(damageType == class'ElectricalDamage')
		{
			lambc.GetShocked(P2Pawn(instigatedBy), HitLocation);
			return;
		}
		else if(damageType == class'RifleDamage')
		{
			lambc.WingedByRifle(P2Pawn(instigatedBy), HitLocation);
			return;
		}
	}

		// If it was a baton hit, the controller might want to do something
	if (ClassIsChildof(DamageType, class'BatonDamage')
		&& LambC != None)
	{
		LambC.HitByBaton(P2Pawn(InstigatedBy));
	}

}

///////////////////////////////////////////////////////////////////////////////
// Same as engine, but we don't want people who died with no damageType
// to chunk up. They should go through normal channels.
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local FPSGameInfo checkg;
	local class TestClass;

	if ( bDeleteMe )
		return; //already destroyed

	// If I'm used for an errand, check to see if I did anything important
	CheckForErrandCompleteOnDeath(Killer);

	// If I got killed by the player, tell the GameState so they can rack up our kill count
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
		P2GameInfoSingle(Level.Game).TheGameState.PawnKilledByDude(Self, DamageType);

	// Check to give the player achievements for killing me
	// Kamek 4-23
	// Death-related achievements instigated by the player go here

	//log(PersonController(Controller)@"RefusedToDonate"@PersonController(Controller).bRefusedToDonate,'Debug');

	// 5-1 - killed a guy who refused to sign the petition
	if (PersonController(Controller) != None
		&& PersonController(Controller).bRefusedToDonate
		&& PlayerController(Killer) != None)
		{
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().EvaluateAchievement(PlayerController(Killer),'PetitionKill');
		}

	//log(Controller@"killed by damage type"@DamageType@"in state"@Controller.GetStateName(),'Debug');
	// 8/28 - killed a guy running away with a flying sledge
	TestClass = class<DamageType>(DynamicLoadObject("BaseFX.FlyingSledgeDamage",class'Class'));
	if (PersonController(Controller) != None
		&& (Controller.IsInState('RunToTargetFromDanger')
			|| Controller.IsInState('RunToTargetFromAttacker')
			|| Controller.IsInState('RunFromPisser')
			)
		&& ClassIsChildOf(DamageType,TestClass))
		{
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().EvaluateAchievement(PlayerController(Killer),'AngerManagement');
		}

	// Kills by fire (any kind)
	if (ClassIsChildOf(DamageType, class'OnFireDamage') || ClassIsChildOf(DamageType, class'BurnedDamage'))
	{
		if (PlayerController(Killer) != None)
		// Fire kill made by the player. Record it
		{
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Killer),'FireKills',1,true);
		}
		else if (MyBodyFire != None
			&& MyBodyFire.Instigator != None
			&& PlayerController(MyBodyFire.Instigator.Controller) != None)
		{
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(MyBodyFire.Instigator.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Killer),'FireKills',1,true);
		}
	}
	// Kills while wearing gimp outfit
	TestClass = class<Inventory>(DynamicLoadObject("Inventory.GimpClothesInv",class'Class'));
	// Don't allow gimped achievement for killing rednecks.
	if (P2Player(Killer) != None && ClassisChildOf(P2Player(Killer).CurrentClothes,TestClass)
		&& !Self.IsA('Rednecks'))
		{
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Killer),'BystandersKilledWhileGimped',1,true);
		}
	// ANY kill made on a person
	if (PlayerController(Killer) != None && Self.IsA('PersonPawn'))
	{
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Killer),'PeopleKilled',1,true);

		// Now record if we're black, mexican, or white (for the racial equality kill achievement)
		if (Left(GetItemName(String(Skins[0])), 4) ~= "MW__"
			|| Left(GetItemName(String(Skins[0])), 4) ~= "FW__"
			|| GetItemName(String(Skins[0])) ~= "Gimp"
			|| GetItemName(String(Skins[0])) ~= "Priest"
			|| GetItemName(String(Skins[0])) ~= "RWS_Pants"
			|| GetItemName(String(Skins[0])) ~= "RWS_Shorts"
			|| GetItemName(String(Skins[0])) ~= "UncleDave")
			{
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Killer),'WhitesKilled',1,true);
			}

		if (Left(GetItemName(String(Skins[0])), 4) ~= "MM__"
			|| Left(GetItemName(String(Skins[0])), 4) ~= "FM__")
			{
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Killer),'MexicansKilled',1,true);
			}

		if (Left(GetItemName(String(Skins[0])), 4) ~= "MB__"
			|| Left(GetItemName(String(Skins[0])), 4) ~= "FB__"
			|| GetItemName(String(Skins[0])) ~= "Colemans_Crew"
			|| GetItemName(String(Skins[0])) ~= "Gary")
			{
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Killer),'BlacksKilled',1,true);
			}

		if (Left(GetItemName(String(Skins[0])), 4) ~= "MF__"
			|| Left(GetItemName(String(Skins[0])), 4) ~= "FF__"
			|| GetItemName(String(Skins[0])) ~= "Habib"
			|| GetItemName(String(Skins[0])) ~= "Kumquat")
			{
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Killer),'FanaticsKilled',1,true);
			}

		// Now evaluate the achievement
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(Killer).GetEntryLevel().EvaluateAchievement(PlayerController(Killer),'EqualOpportunityKiller');
	}

	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	Health = Min(0, Health);

	Level.Game.Killed(Killer, Controller, self, damageType);

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	// This was from the engine. I changed it to a constant at least.
	// It apparently bumps up a person who's moving when they die, to make it
	// a little more dramatic.
	Velocity.Z *= DIE_Z_MULT;

	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();

	PlayDying(DamageType, HitLocation);

	if ( Level.Game.bGameEnded )
		return;
	if ( !bPhysicsAnimUpdate && !IsLocallyControlled() )
		ClientDying(DamageType, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayTurnHeadStraightAnim(float fRate)
{
	// STUB--defined in p2mocappawn
}

///////////////////////////////////////////////////////////////////////////////
// Set the mood, which determines how various actions are performed.
//
// The amount is between 0.0 to 1.0 and is used by some of the mood-based
// to further refine the responses.  Most functionality is based purely on
// the specified mood, completely ignoring the amount.
///////////////////////////////////////////////////////////////////////////////
function SetMood(EMood moodNew, float amount)
	{
	if (moodNew != mood
		&& Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
		{
		mood = moodNew;
		ChangeAnimation();
		// Check to look forward--not allowing yourself to possibly continue to
		// look in some random direction
		PlayTurnHeadStraightAnim(0.1);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Say the specified line of dialog.
// Returns the duration of the specified line.
///////////////////////////////////////////////////////////////////////////////
function float Say(out P2Dialog.SLine line, optional bool bImportant,
				   optional bool bIndexValid, optional int SpecIndex)
	{
	// Play this line using assigned dialog
	return myDialog.Say(self, line, VoicePitch, bImportant, bIndexValid, SpecIndex);
	}

///////////////////////////////////////////////////////////////////////////////
// Find this number in a switch and say the number
// bPureNumbers means don't say things like 'a' for '1', say '1', so you
// can say "i'll take a number 1, please"
///////////////////////////////////////////////////////////////////////////////
function float SayThisNumber(int NumberToSay, optional bool bPureNumbers, optional bool bImportant)
{

	switch(NumberToSay)
	{
		case 1:
			// Play this line using assigned dialog
			if(bPureNumbers)
				return Say(MyDialog.lNumbers_1, bImportant);
			else
				return Say(MyDialog.lNumbers_a, bImportant);
			break;
		case 2:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_2, bImportant);
			break;
		case 3:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_3, bImportant);
			break;
		case 4:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_4, bImportant);
			break;
		case 5:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_5, bImportant);
			break;
		case 6:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_6, bImportant);
			break;
		case 7:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_7, bImportant);
			break;
		case 8:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_8, bImportant);
			break;
		case 9:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_9, bImportant);
			break;
		case 10:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_10, bImportant);
			break;
		case 11:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_11, bImportant);
			break;
		case 12:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_12, bImportant);
			break;
		case 13:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_13, bImportant);
			break;
		case 14:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_14, bImportant);
			break;
		case 15:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_15, bImportant);
			break;
		case 16:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_16, bImportant);
			break;
		case 17:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_17, bImportant);
			break;
		case 18:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_18, bImportant);
			break;
		case 19:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_19, bImportant);
			break;
		case 20:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_20, bImportant);
			break;
		case 30:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_30, bImportant);
			break;
		case 40:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_40, bImportant);
			break;
		case 50:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_50, bImportant);
			break;
		case 60:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_60, bImportant);
			break;
		case 70:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_70, bImportant);
			break;
		case 80:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_80, bImportant);
			break;
		case 90:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_90, bImportant);
			break;
		case 100:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_100, bImportant);
			break;
		case 200:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_200, bImportant);
			break;
		case 300:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_300, bImportant);
			break;
		case 400:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_400, bImportant);
			break;
		case 500:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_500, bImportant);
			break;
		case 600:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_600, bImportant);
			break;
		case 700:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_700, bImportant);
			break;
		case 800:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_800, bImportant);
			break;
		case 900:
			// Play this line using assigned dialog
			return Say(MyDialog.lNumbers_900, bImportant);
			break;
		default:
			Warn(self$" SayThisNumber(): Can't find "$NumberToSay);
			break;
	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// Spit and make a sound
///////////////////////////////////////////////////////////////////////////////
function float DisgustedSpitting(out P2Dialog.SLine line)
{
	// Play this line using assigned dialog
	return myDialog.Say(self, line, VoicePitch, true);
}

///////////////////////////////////////////////////////////////////////////////
// See if you have any violent weapons still
// Usually called after you drop a weapon
///////////////////////////////////////////////////////////////////////////////
function EvaluateWeapons()
{
	local Inventory Inv;
	local P2Weapon weapinv;

	Inv = Inventory;

	bHasViolentWeapon=false;
	bHasDistanceWeapon=false;
	// Go through your inventory, and set this bool to true, if you have
	// any violent weapons or distance weapons left
	while(Inv != None)
	{
		weapinv = P2Weapon(Inv);
		if(weapinv != None)
		{
			if(weapinv.ViolenceRank > 0)
				bHasViolentWeapon=true;
			if(weapinv.bMeleeWeapon)
				bHasDistanceWeapon=true;
		}
		Inv = Inv.Inventory;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Return how much of this inventory item we have
///////////////////////////////////////////////////////////////////////////////
function int HowMuchInventory(class<Inventory> CheckMe)
{
	local P2PowerupInv Inv;

	Inv = P2PowerupInv(FindInventoryType(CheckMe));

	if(Inv != None)
		return Inv.Amount;
	else
		return 0;
}

///////////////////////////////////////////////////////////////////////////////
// Used to make a new inventory item with a class
///////////////////////////////////////////////////////////////////////////////
function Inventory CreateInventoryByClass(class<Inventory> MakeMe,
										  optional out byte CreatedNow,
										  optional bool bIgnoreDifficulty)
{
	local Inventory Inv;
	local P2Weapon weapinv;
	local P2PowerupInv p2inv;
	local P2AmmoInv ainv;
	local int AmmoGive;

	Inv = FindInventoryType(MakeMe);

	//log(self$" make this class "$MakeMe);

	if( (MakeMe!=None) && (Inv==None) )
	{
		Inv = Spawn(MakeMe, self);
		CreatedNow=1;
		//log(self$" creatinvclass added "$inv);
		if( Inv != None )
		{
			weapinv = P2Weapon(Inv);
			p2inv = P2PowerupInv(Inv);
			ainv = P2AmmoInv(Inv);

			if(weapinv != None)
				weapinv.bJustMade=true;

			Inv.GiveTo(self);

			// Adds in how much of each powerup to give to the inventory
			// do this by spawning a pickup, getting the number, then destroying it
			if(weapinv != None)
			{
				if(inv.PickupClass != None)
				{
					// Multiplayer has different balancing for how much ammo you get with things
					if(Level.Game != None
						&& FPSGameInfo(Level.Game).bIsSinglePlayer)
						AmmoGive=class<P2WeaponPickup>(inv.PickupClass).default.AmmoGiveCount;
					else
						AmmoGive=class<P2WeaponPickup>(inv.PickupClass).default.MPAmmoGiveCount;
				}
				weapinv.GiveAmmoFromPickup(self, AmmoGive);
			}
			else if(inv.PickupClass != None)
			{
				if(p2inv != None)
				{
					p2inv.AddAmount(class<P2PowerupPickup>(inv.PickupClass).default.AmountToAdd);
				}
				else if(ainv != None)
				{
					// Multiplayer has different balancing for how much ammo you get with things
					if(Level.Game != None
						&& FPSGameInfo(Level.Game).bIsSinglePlayer)
						ainv.AddAmmo(class<P2AmmoPickup>(inv.PickupClass).default.AmmoAmount);
					else
						ainv.AddAmmo(class<P2AmmoPickup>(inv.PickupClass).default.MPAmmoAmount);
				}
			}

			Inv.PickupFunction(self);

			// Check to see if someone has given us a violent or distance weapon
			if(weapinv != None)
			{
				if(weapinv.ViolenceRank > 0)
					bHasViolentWeapon=true;
				if(weapinv.bMeleeWeapon)
					bHasDistanceWeapon=true;
			}

			if(weapinv != None)
				weapinv.bJustMade=false;
		}
	}
	return Inv;
}

///////////////////////////////////////////////////////////////////////////////
// Used to make a new inventory item
///////////////////////////////////////////////////////////////////////////////
function Inventory CreateInventory(string InventoryClassName, optional out byte CreatedNow)
{
	local Inventory Inv;
	local P2Weapon weapinv;
	local P2PowerupInv p2inv;
	local P2AmmoInv ainv;
	local class<Inventory> InventoryClass;
	local int AmmoGive;

	InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);

	Inv = FindInventoryType(InventoryClass);

	if( (InventoryClass!=None) && (Inv==None) )
	{
		Inv = Spawn(InventoryClass, self);
		CreatedNow=1;
		//log(self$" creatinv added "$inv);
		if( Inv != None )
		{
			weapinv = P2Weapon(Inv);
			p2inv = P2PowerupInv(Inv);
			ainv = P2AmmoInv(Inv);

			if(weapinv != None)
				weapinv.bJustMade=true;

			Inv.GiveTo(self);

			// Adds in how much of each powerup to give to the inventory
			// do this by spawning a pickup, getting the number, then destroying it
			if(weapinv != None)
			{
				if(inv.PickupClass != None)
				{
					// Multiplayer has different balancing for how much ammo you get with things
					if(Level.Game != None
						&& FPSGameInfo(Level.Game).bIsSinglePlayer)
						AmmoGive=class<P2WeaponPickup>(inv.PickupClass).default.AmmoGiveCount;
					else
						AmmoGive=class<P2WeaponPickup>(inv.PickupClass).default.MPAmmoGiveCount;
				}
				weapinv.GiveAmmoFromPickup(self, AmmoGive);
			}
			else if(inv.PickupClass != None)
			{
				if(p2inv != None)
				{
					p2inv.AddAmount(class<P2PowerupPickup>(inv.PickupClass).default.AmountToAdd);
				}
				else if(ainv != None)
				{
					// Multiplayer has different balancing for how much ammo you get with things
					if(Level.Game != None
						&& FPSGameInfo(Level.Game).bIsSinglePlayer)
						ainv.AddAmmo(class<P2AmmoPickup>(inv.PickupClass).default.AmmoAmount);
					else
						ainv.AddAmmo(class<P2AmmoPickup>(inv.PickupClass).default.MPAmmoAmount);
				}
			}


			Inv.PickupFunction(self);

			// Check to see if someone has given us a violent or distance weapon
			if(weapinv != None)
			{
				if(weapinv.ViolenceRank > 0)
					bHasViolentWeapon=true;
				if(weapinv.bMeleeWeapon)
					bHasDistanceWeapon=true;
			}
		}
	}
	return Inv;
}

///////////////////////////////////////////////////////////////////////////////
// Adds all the required equipment and picks out the urethra.
///////////////////////////////////////////////////////////////////////////////
function AddDefaultInventory()
{
	// STUB--done in BasePeople::PersonPawn so we have access to the inventory actors
}

///////////////////////////////////////////////////////////////////////////////
// Add Item to this pawn's inventory.
// Returns true if successfully added, false if not.
// Overrides directly (doesn't call super) for Pawn.uc
///////////////////////////////////////////////////////////////////////////////
function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	local Inventory currinv;
	local actor Last;

	Last = self;

	// The item should not have been destroyed if we get here.
	if (NewItem ==None )
	{
		Warn("P2Pawn.AddInventory(): tried to add none inventory to "$self);
		return false;
	}

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if( Inv == NewItem )
			return false;
		Last = Inv;
	}

	//log("addinventory "$NewItem);
	// Check if we already have a class of this type in our inventory.
	// If so, try to just add more of it
	currinv = FindInventoryType(NewItem.class);
	// You'll only have this in your inventory *and* have this function
	// get called if you've just done a level warp. Normally after a pickup
	// this function won't get called if you already have ammo.
	if(Ammunition(currinv) != None)
	{
		// This is touchy and may not work. This was a work around for the
		// original ammo bug from Epic in here. The problem was if you picked
		// up a weapon and then warped to a new level, it duplicated the ammo
		// in your inventory.
		// Now, the pickup adds ammo to the weapon, and then when you warp
		// your weapon is added, and ammo (from the inventory which also travelled)
		// is added THEN to your weapon. Before both was happening, so you'd
		// get both things in a warp.
		currinv.Destroy();
		return false;
		/*
		// Trying to figure out why ammo is added again when you warp
		//  between levels.
		Ammunition(currinv).AddAmmo(Ammunition(NewItem).AmmoAmount);
		log("tried to add me again, even though i'm already here "$currinv);
		currinv.Destroy();
		return false;
		*/
	}
	else
	{
		// Add to back of inventory chain (so minimizes net replication effect).
		NewItem.SetOwner(Self);
		NewItem.Inventory = None;
		Last.Inventory = NewItem;

		if ( Controller != None )
			Controller.NotifyAddInventory(NewItem);

		// Change by NickP: MP fix
		if(P2Weapon(NewItem) != None)
			P2Weapon(NewItem).ClientInventoryAdded();
		// End
	}

	// Do anything extra after this first gets added
	if(P2AmmoInv(NewItem) != None)
	{
		P2AmmoInv(NewItem).AddedToPawnInv(self, Controller);
	}
	else if(P2Weapon(NewItem) != None)
	{
		P2Weapon(NewItem).AddedToPawnInv(self, Controller);
	}
	else if(P2PowerupInv(NewItem) != None)
	{
		P2PowerupInv(NewItem).AddedToPawnInv(self, Controller);
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Ensure when we're not possessed anymore, we don't allow shooting
///////////////////////////////////////////////////////////////////////////////
function UnPossessed()
{
	Super.UnPossessed();

	if(Weapon != None)
		P2Weapon(Weapon).ForceEndFire();
}

///////////////////////////////////////////////////////////////////////////////
// All this ensures is that the weapon we currently have equipped (even if it's
// none) is not violent.
///////////////////////////////////////////////////////////////////////////////
function bool ViolentWeaponNotEquipped()
{
	return (P2Weapon(Weapon) == None
			|| P2Weapon(Weapon).ViolenceRank == 0);
}

///////////////////////////////////////////////////////////////////////////////
// True if he has a urethra equipped
///////////////////////////////////////////////////////////////////////////////
function bool HasPantsDown()
{
	return (Weapon != None
		&& Weapon.IsA('UrethraWeapon'));
}

///////////////////////////////////////////////////////////////////////////////
// True if he has a gas can equipped
///////////////////////////////////////////////////////////////////////////////
function bool HasGasCan()
{
	return (Weapon != None
		&& Weapon.IsA('GasCanWeapon'));
}

///////////////////////////////////////////////////////////////////////////////
// Make sure BEFORE this, that he has the weapon you care about
// True if he's using it actively
///////////////////////////////////////////////////////////////////////////////
function bool ActivelyUsingWeapon()
{
	if(PressingFire()					// trying to use it
	&& Weapon != None
	&& (Weapon.IsInState('NormalFire')	// actively using it
		|| Weapon.IsInState('AltFire')))
		return	true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Pressing Fire in the pawn. Make sure the controller says it's okay
// first
///////////////////////////////////////////////////////////////////////////////
simulated function bool PressingFire()
{
	return (P2Player(Controller) != None && P2Player(Controller).PressingFire());
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function bool PressingAltFire()
{
	return (P2Player(Controller) != None && P2Player(Controller).PressingAltFire());
}


///////////////////////////////////////////////////////////////////////////////
// toss out the weapon currently held
///////////////////////////////////////////////////////////////////////////////
function TossWeapon(vector TossVel)
{
	local vector X,Y,Z;

	if(Weapon == None)
		return;

	// Really make it stop doing it's stuff
	// And don't drop things that can't be dropped
	if(!Weapon.bCanThrow
		|| (!P2Weapon(Weapon).bCanThrowMP
			&& !Level.Game.bIsSinglePlayer))
		return;

	// really make it stop doing it's stuff
	P2Weapon(Weapon).ForceEndFire();

	// make it go up in the air some, and away from him
	if(VSize(TossVel) == 0)
	{
		TossVel = vector(Rotation);
		TossVel = (FRand()*127)*Normal(TossVel);
		TossVel.z+=(FRand()*255);
	}
	Weapon.velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	// And make the weapon align with the direction of the throw
	Weapon.SetRotation(Rotation);
	Weapon.DropFrom(Location + 0.3 * CollisionRadius * X + CollisionRadius * Z);
}

///////////////////////////////////////////////////////////////////////////////
// toss out the inventory passed in
///////////////////////////////////////////////////////////////////////////////
function bool TossThisInventory(vector TossVel, Inventory ThisInv)
{
	local vector X,Y,Z;
	local Rotator userot;
	local P2Weapon ThisWeap;

	debuglog("toss this inventory"@thisinv);

	if(ThisInv == None)
		return false;

	// Really make it stop doing it's stuff
	// And don't drop things that can't be dropped
	ThisWeap = P2Weapon(ThisInv);
	if(ThisWeap != None)
	{
		if(!ThisWeap.bCanThrow
			|| (!ThisWeap.bCanThrowMP
				&& !Level.Game.bIsSinglePlayer))
			return false;

		ThisWeap.ForceEndFire();
	}

	if(P2PowerupInv(ThisInv) != None)
	{
		debuglog(P2PowerupInv(ThisInv).bCanThrow@P2PowerupInv(ThisInv).Amount);
		if(!P2PowerupInv(ThisInv).bCanThrow
			// 1409 fix, make sure you have stuff to throw!
			// Before this, you could use a crack pipe, then throw it quickly as the
			// smoke was coming out, and you'd still get the health and the crack pipe back--fixed!
			|| P2PowerupInv(ThisInv).Amount <= 0)
			return false;
	}

	ThisInv.velocity = TossVel;
	userot = Rotation;
	userot.Yaw = FRAnd()*65535;
	GetAxes(userot,X,Y,Z);
	// And make the ThisWeap align with the direction of the throw
	ThisInv.SetRotation(userot);
	ThisInv.DropFrom(Location + 0.3 * CollisionRadius * X + CollisionRadius * Z);
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Decide on a prize for a quick kill
///////////////////////////////////////////////////////////////////////////////
function PickQuickKillPrize(int KillIndex)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Remove Item from this pawn's inventory, if it exists.
//
// If the selected item is on the deleted one, move it
///////////////////////////////////////////////////////////////////////////////
function DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local actor Link;
	local int Count;

	if ( Item == Weapon )
		Weapon = None;
	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			// Adding in NotifyDeleteInventory().
			if ( Controller != None )
				Controller.NotifyDeleteInventory(Item);

			// Change by NickP: MP fix
			if(P2Weapon(Item) != None)
				P2Weapon(Item).ClientInventoryDeleted(Item.Owner);
			// End

			Link.Inventory = Item.Inventory;
			Item.Inventory = None;
			break;
		}
		if ( Level.NetMode == NM_Client )
		{
			Count++;
			if ( Count > 5000 )
			break;
		}
	}

	if ( Item == SelectedItem )
		NextItem();

	Item.SetOwner(None);
}

///////////////////////////////////////////////////////////////////////////////
// Destroy all inventory items
///////////////////////////////////////////////////////////////////////////////
function DestroyAllInventory( )
{
	local Inventory Inv, Next;
	local int count;

	Inv = Inventory;
	while ( Inv != None )
	{
		Next = Inv.Inventory;
		Inv.Destroy();
		Inv = Next;
		if ( Level.NetMode == NM_Client )
		{
			Count++;
			if ( Count > 5000 )
			break;
		}
	}
	Inventory = None;
	SelectedItem = None;
	Weapon = None;
	Armor = 0;
}

///////////////////////////////////////////////////////////////////////////////
// Set to false bGotDefaultInventory in personpawn. We need it at this low level though
///////////////////////////////////////////////////////////////////////////////
function ResetGotDefaultInventory( )
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// The player/bot wants to select next item
// Copied from engine, but accessed none fixed.
///////////////////////////////////////////////////////////////////////////////
exec function NextItem()
{
	//log(self$" NextItem "$SelectedItem);
	if (SelectedItem==None)
	{
		if(Inventory != None)
			SelectedItem = Inventory.SelectNext();
		return;
	}

	if (SelectedItem.Inventory!=None)
		SelectedItem = SelectedItem.Inventory.SelectNext();
	else
	{
		if(Inventory != None)
			SelectedItem = Inventory.SelectNext();
	}

	if ( SelectedItem == None )
	{
		if(Inventory != None)
			SelectedItem = Inventory.SelectNext();
	}

	// We have to send p2player a notify becuase Engine.Pawn only has NextItem
	// (not PrevItem--that's in playercontroller)
	if(P2Player(Controller) != None)
		P2Player(Controller).InvChanged();
}

///////////////////////////////////////////////////////////////////////////////
// Player is pressing the button to make him shout "Get Down!"
///////////////////////////////////////////////////////////////////////////////
simulated final function bool PressingGetDown()
{
	local P2Player p2cont;

	p2cont = P2Player(Controller);

	return ( (p2cont != None) && (p2cont.bShoutGetDown != 0) );
}

///////////////////////////////////////////////////////////////////////////////
//Player Jumped
// Like Engine.Pawn but lets you cruch jump *but* don't let you deathcrawl-jump
///////////////////////////////////////////////////////////////////////////////
function DoJump( bool bUpdating )
{
	if ( !bIsDeathCrawling
		&& !bIsKnockedOut
		&& !bWantsToDeathCrawl
		&& ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{
		if ( Role == ROLE_Authority )
		{
			if ( (Level.Game != None) && (Level.Game.GameDifficulty > 0) )
				MakeNoise(0.1 * Level.Game.GameDifficulty);
			if ( bCountJumps && (Inventory != None) )
				Inventory.OwnerEvent('Jumped');
		}
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if ( (Base != None) && !Base.bWorldGeometry )
			Velocity.Z += Base.Velocity.Z;
		SetPhysics(PHYS_Falling);
	}
}

///////////////////////////////////////////////////////////////////////////////
// If I'm used for an errand, tell them I died
///////////////////////////////////////////////////////////////////////////////
function CheckForErrandCompleteOnDeath(Controller Killer)
{
	local P2GameInfoSingle checkg;
	local P2Player p2p;
	local bool bCompleted;
	local FPSPawn usepawn;

	if(bUseForErrands)
	{
		checkg = P2GameInfoSingle(Level.Game);
		if(checkg != None)
		{
			// Instead of checking the killer controller, check all P2Players in the level.
			// Should fix the fringe case where Dave is killed by someone other than the player, rendering the errand unbeatable
			foreach DynamicActors(class'P2Player', p2p)
			{
				// Check if the player beats an errand by completing this
				bCompleted = checkg.CheckForErrandCompletion(None,
												None,
												self,
												p2p,
												false);
			}

			// Regardless of this, always trigger this event
			if(Killer != None)
				usepawn = FPSPawn(Killer.Pawn);
			TriggerEvent(DIED_EARLY_EVENT, self, usepawn);

			// Reset this if it worked
			if(bCompleted)
				bUseForErrands=false;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Unhook ragdoll completely
///////////////////////////////////////////////////////////////////////////////
function UnhookRagdoll()
{
	if(Level.NetMode != NM_DedicatedServer)
	{
		// Make sure to unhook any references to your karma ragdoll
		if((KarmaParamsSkel(KParams) != None)
			&& Physics == PHYS_KarmaRagdoll)
			KFreezeRagdoll();

		SetPhysics(PHYS_None);

		KParams = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Rocket is after me! MP
///////////////////////////////////////////////////////////////////////////////
simulated function ClientStartRocketBeeping(Projectile ThisRocket)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Someone is aiming a sniper rifle at me! MP
///////////////////////////////////////////////////////////////////////////////
simulated function ClientSniperViewingMe(P2Pawn Shooter, bool bInView)
{
	if(bInView)
	{
		//log(self$" I'm in his view!"$Shooter);
		P2Player(Controller).StartSniperBars(Shooter);
	}
	else
	{
		//log(self$" Shew..I'm safe!"$Shooter);
		P2Player(Controller).EndSniperBars();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make some glare from my sniper rifle
///////////////////////////////////////////////////////////////////////////////
//simulated
function MakeSniperGlare()
{
	// STUB
}
function DestroySniperGlare()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function GiveBackRagdoll()
{
	local P2Player p2p, Cont;

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
		if(p2p != None)
		{
			p2p.GiveBackRagdollSkel(self);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function GetKarmaSkeleton()
{
	// STUB--defined in p2mocappawn
}

///////////////////////////////////////////////////////////////////////////////
// If you have a ragdoll/karma, unhook it, or the saves will not work with
// this reference to transient (from p2player ragdoll)
///////////////////////////////////////////////////////////////////////////////
event PreSaveGame()
{
	Super.PreSaveGame();
	if(KParams != None)
	{
		KParamsTrans = KParams;
		KParams = None;
		// Don't change the physics to none here--it will make the ragdoll
		// stop moving, and we won't be able to restore the proper velocity.
		// Before Actor::PostLoad we simply check to make sure the pawn has
		// kparams before trying to init them because the physics says to init them.
	}
}
///////////////////////////////////////////////////////////////////////////////
// Give back the ragdoll so they can keep playing with karma
///////////////////////////////////////////////////////////////////////////////
event PostSaveGame()
{
	Super.PostSaveGame();
	if(KParamsTrans != None)
	{
		KParams = KParamsTrans;
		KParamsTrans = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// check to stop blood flow
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	local  P2GameInfoSingle p2game;

	if(!bDeleteMe)
	{
		p2game = P2GameInfoSingle(Level.Game);

		// Make sure if we instantly got chunked up at some point, to add us
		// to the list to be remembered, if we're persistent.
		// This is because normally dead people are counted up at the end of the
		// level, but if you got removed early (chunked up), add us now.
		if(bPersistent
			&& p2game != None
			&& p2game.TheGameState != None
			&& bChunkedUp)
			p2game.TheGameState.AddPersistentPawn(self);

		//log(self$" Destroyed, kparams "$KParams);
		UnhookRagdoll();

		GiveBackRagdoll();

		// Contact the p2gameinfo and report that you're being destroyed
		if(!bPlayer)
		{
			if(bReportDeath
				&& p2game != None)
				p2game.RemoveDeadBody(self);
		}

		DestroyAllInventory();

		if(bloodpool != None)
		{
			DetachFromBone(bloodpool);
			bloodpool.Destroy();
		}

		StopPeeingPants();

		if(MyMarker != None)
		{
			MyMarker.Destroy();
		}

		if( PlayerShadow != none )
            PlayerShadow.Destroy();

        //if( RealtimeShadow != none )
        //    RealtimeShadow.Destroy();

		Super.Destroyed();
	}
	else
		log(self$" ERROR: bDeleteMe already set in P2Pawn::Destroyed");
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Player is suiciding by a grenade.. don't let him do much
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
State Suiciding
{
	ignores PlayTakeHit;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dying
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dying
{
	ignores SetMood;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		if(Level.NetMode == NM_Client
			|| Level.NetMode == NM_ListenServer)
		{
			if ( !PlayerCanSeeMe() )
				Destroy();
			else
				SetTimer(REMOVE_DEAD_TIME, false);
		}
		// xPatch: Singleplayer version
		else
		{	
			if ( !PlayerCanSeeMe() && P2GameInfo(Level.Game).BodiesLifetimeMax != 0 )
				Destroy();
			else if( !PlayerCanSeeMe() && P2GameInfo(Level.Game).CanRemoveThisBody(self) )
				Destroy();
			else
				SetTimer(REMOVE_DEAD_TIME_SP, false);
		}
		// End
	}

	///////////////////////////////////////////////////////////////////////////////
	// Disconnect my variable from my torso fire, now or later
	///////////////////////////////////////////////////////////////////////////////
	function UnhookPawnFromFire()
	{
		//log(self$" UnhookPawnFromFire1 "$GetStateName());
		GotoState('Dying', 'WaitToResetFire');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event AnimEnd(int Channel)
	{
		if(Physics != PHYS_KarmaRagDoll)
		{
			if ( Channel != 0 )
				return;
			if ( Physics == PHYS_None )
				LieStill();
			else if ( PhysicsVolume.bWaterVolume )
			{
				bThumped = true;
				LieStill();
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function LieStill()
	{
		if ( !bThumped )
			LandThump();
		if ( CollisionHeight != CarcassCollisionHeight )
			ReduceCylinder();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Landed(vector HitNormal)
	{
		LandBob = FMin(50, 0.055 * Velocity.Z);

		if ( Level.NetMode == NM_DedicatedServer )
			return;

		if(Physics != PHYS_KarmaRagDoll)
			SetPhysics(PHYS_None);

		if ( Shadow != None )
			Shadow.Destroy();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	singular function BaseChange()
	{
		if( base == None && Physics != PHYS_KarmaRagDoll)
			SetPhysics(PHYS_Falling);
		else if ( Pawn(base) != None )
			ChunkUp(200); // don't let corpse ride around on someone's head
	}

	///////////////////////////////////////////////////////////////////////////////
	// prone body should have low height, wider radius
	///////////////////////////////////////////////////////////////////////////////
	function ReduceCylinder()
	{
		local float OldHeight, OldRadius;
		local vector OldLocation;

		SetCollision(bCollideActors,False,False);
		SetCollisionSize(CollisionRadius, CollisionHeight/3);
/*
		SetCollision(True,False,False);
		OldHeight = CollisionHeight;
		OldRadius = CollisionRadius;
		SetCollisionSize(1.5 * Default.CollisionRadius, CarcassCollisionHeight);
		//PrePivot = vect(0,0,1) * (OldHeight - CollisionHeight); // FIXME - changing prepivot isn't safe w/ static meshes
		OldLocation = Location;
		if ( !SetLocation(OldLocation - PrePivot) )
		{
			SetCollisionSize(OldRadius, CollisionHeight);
			if ( !SetLocation(OldLocation - PrePivot) )
			{
				SetCollisionSize(CollisionRadius, OldHeight);
				SetCollision(false, false, false);
				//PrePivot = vect(0,0,0);
				if ( !SetLocation(OldLocation) )
					ChunkUp(200);
			}
		}
		*/
		//PrePivot = PrePivot + vect(0,0,3);
	}

	///////////////////////////////////////////////////////////////////////////////
	// LoadedDying in P2MocapPawn is an example of not dying normally. If a dead
	// guy gets loaded, he gets recreated in a strange way, so we say he's abnormal
	///////////////////////////////////////////////////////////////////////////////
	function bool DiedNormally()
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Tell all around you who care, that you just died.
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		local P2Pawn CheckP;
		local PersonController Personc;
		
		//ErikFOV Change: Fix problem
		if (bPendingDelete || bDeleteMe)
			return;
		//End

		//log(self$" beginstate dying");
		if(!bCompletedDeadSetup)
		{
			// Wake up your partner (possibly) from stasis, since you've died, and hopefully
			// he'll wander into view and not make the level's seem so unpopulated.
			if(StasisPartner != None
				&& !StasisPartner.bDeleteMe
				&& StasisPartner.Health > 0
				&& LambController(StasisPartner.Controller) != None)
				LambController(StasisPartner.Controller).PartnerReviveFromStasis(self);

			// Tell your attacker you died/Blank out his target
			if(DamageInstigator != None
				&& DamageInstigator.Controller != None)
			{
				DamageInstigator.Controller.Target = None;
			}
			if(DiedNormally())
			{
				// Check all the pawns around me and tell them I died
				ForEach VisibleCollidingActors(class'P2Pawn', CheckP, REPORT_DEATH_RADIUS, Location)
				{
					if(CheckP != self
						&& CheckP != None)
					{
						Personc = PersonController(CheckP.Controller);
						if(Personc != None && Personc.IsInState('WatchForViolence'))
						{
							//log("telling to watch me "$CheckP);
							Personc.Focus = self;
							Personc.ViolenceWatchDeath(self);
						}
						else if(P2Player(CheckP.Controller) != None)
						{
							P2Player(CheckP.Controller).SomeoneDied(self, P2Pawn(DamageInstigator), DyingDamageType);
						}
					}
				}
			}

			if ( bTearOff && Level.NetMode == NM_DedicatedServer )
				LifeSpan = 1.0;
			else if(Level.NetMode == NM_Client
					|| Level.NetMode == NM_ListenServer)
				// Clients in MP remove dead bodies after a while
				SetTimer(REMOVE_DEAD_START_TIME, false);

			// Turn off all collision if it's ragdolled (it'll handle the collision)
			// or if it's animating MP

			// Kamek 1/17 - Turn off collision anyway, non-ragdolled pawns block the player
			//if(Physics == PHYS_KarmaRagDoll)
			//{
			//	if(Level.Game == None
			//		|| !Level.Game.bIsSinglePlayer)
					SetCollision(bCollideActors, false, false);
			//}

			// Bugfix--if the pawns are animating for deaths on a client and a listenserver is ragdolling
			// deaths, then when it turns off collideworld on the server, even though it tears off in that
			// tick when it sets that to false, that last packet will be sent--then the collideworld
			// will also get turned off here though it doesn't want too
			//else
			if(Level.Game == None
					|| !Level.Game.bIsSinglePlayer)
					bCollideWorld=true;

			bInvulnerableBody = true;

			if ( Controller != None )
			{
				if ( Controller.bIsPlayer )
					Controller.PawnDied(self);
				else // Destroy the NPC controller make sure to set it to none now!
				{
					Controller.Destroy();
					Controller = None;
				}
			}

			if(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
			{
				// Make a marker saying i'm a dead body
				// Marker handles when body disappears
				if(!bPlayer)
				{
					if(bReportDeath)
					{
						// xPatch: DeadBodyMarker-less method for the hard difficulties
						if(NoDeadBodyMarker())
						{
							// if lifetime method is not used we use the body count
							if(P2GameInfo(Level.Game).BodiesLifetimeMax == 0)
							{
								P2GameInfo(Level.Game).AddDeadBody(self);
								SetTimer(REMOVE_DEAD_START_TIME_SP, false);
							}
						}
						else // End
						{
							MyMarker = spawn(class'DeadBodyMarker',self,,Location);
							if(P2GameInfo(Level.Game) != None)
								P2GameInfo(Level.Game).AddDeadBody(self);
						}
							
						// xPatch: remove bodies multiplayer way if enabled
						if(P2GameInfo(Level.Game).BodiesLifetimeMax != 0)
						{
							SetTimer(P2GameInfo(Level.Game).BodiesLifetimeMax, false);
							//log("xPatch Log: "$self$" will be removed within "$P2GameInfo(Level.Game).BodiesLifetimeMax);
						}
					}
				}
				else	// Make sure they know it's a dead dude
				{
					MyMarker = spawn(class'DeadDudeMarker',self,,Location);
				}
			}
			else if(Physics != PHYS_KarmaRagDoll)
				SetPhysics(PHYS_Falling);

			// Mark that we've done this now
			bCompletedDeadSetup=true;
		}
	}

WaitToResetFire:
	Sleep(FIRE_RESET_TIME);
	MyBodyFire=None;
Begin:
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: To reduce crashes on super hard difficulties where a lot is going  
// on -- don't spawn dead body markers at all. They are not that useful on  
// these since aggresive NPCs don't panic when they see bodies anyway.
///////////////////////////////////////////////////////////////////////////////
function bool NoDeadBodyMarker()
{
	return (P2GameInfo(Level.Game) != None && P2GameInfo(Level.Game).TheyHateMeMode()
		&& (P2GameInfo(Level.Game).InHestonmode() || P2GameInfo(Level.Game).InInsanemode() || P2GameInfo(Level.Game).InLudicrousMode()));
}

/*
///////////////////////////////////////////////////////////////////////////////
// Check to come out of stasis
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	// Check to come out of stasis, if you're being rendered again
	if(LambController(Controller) != None
		&& Controller.bStasis
		&& LastRenderTime + DeltaTime >= Level.TimeSeconds)
	{
		// Instantly snap us back.
		//log(self$" try for stasis OFF, render time "$LastRenderTime$" stasis time "$TimeTillStasis$" level time "$Level.TimeSeconds);
		LambController(Controller).ComeOutOfStasis();
	}
	// Zero means they don't want to try for a stasis, the player pawns should
	// default this way
	// bAllowStasis is for internal determination of something being allowed to use the stasis
	// and should not be set in the editor.
	else if(bAllowStasis
		&& TimeTillStasis > 0)
	{
		// only lamb controllers try to turn themselves off
		if(LambController(Controller) != None)
		{
			if(LastRenderTime + TimeTillStasis < Level.TimeSeconds)
			{
				// if not already trying for stasis, set it so
				if(!LambController(Controller).bPendingStasis
					&& !Controller.bStasis)
				{
					//log(self$" try for stasis on ");
					LambController(Controller).MakeStasisPending(true);
				}
			}
		}
	}
}
*/
defaultproperties
{
	bTravel=true
	bCanTeleportWithPlayer=true
	ControllerClass=class'PersonController'
	Psychic=0.01
	Champ=0.3
	Cajones=0.2
	Temper=0.2
	Glaucoma=0.9
	Twitch=2.0
	TwitchFar=2.0
	Rat=0.1
	Compassion=0.4
	WarnPeople=0.1
	Conscience=0.5
	Beg=0.15
	PainThreshold=0.5
	Reactivity=0.35
	Confidence=0.1
	Rebel=0.1
	Curiosity=0.5
	Patience=0.9
	WillDodge=0.1
	WillKneel=0.1
	WillUseCover=0.45
	MaxMoneyToStart=0
	Talkative=0.15
	Stomach=0.8
	Armor=0.0
	ArmorMax=75.0
	VoicePitch=1.0
	DonutLove=0.0
	Greed=0.5
	TalkWhileFighting=0.05
	TalkBeforeFighting=0.05
	Fitness=0.45
	bScaredOfPantsDown=true
	bHasRef=true
	HealthMax=100
	bStartupRandomization=true
	AttackRange=(Min=1024,Max=2048)
	SafeRangeMin=512
    SightRadius=+05000.000000
	bCanPickupInventory=false
	GroundSpeed=450
	BaseMovementRate=450
	WalkingPct=0.25
	StartWeapon_Group=0
	StartWeapon_Offset=2
	BurnSkin=Texture'ChameleonSkins.Special.BurnVictim'
	CrackMaxHealthPercentage=1.25
	ViolenceRankTolerance=2
	TransientSoundRadius = 100
	ReportLooksRadius=1024
	TakesShotgunHeadShot=	1.0
	TakesRifleHeadShot=		1.0
	TakesShovelHeadShot=	1.0
	TakesOnFireDamage=		1.0
	TakesAnthraxDamage=		1.0
	TakesShockerDamage=		0.8
	TakesPistolHeadShot=	1.0
	TakesMachinegunDamage=	1.0
	TakesChemDamage=		1.0
	bHasHead=true
	bHeadCanComeOff=true
	LeaderSlowdown=1.0
	FootKickHead=Sound'WeaponSounds.Foot_KickHead'
	FootKickBody=Sound'WeaponSounds.Foot_KickBody'
	ShovelHitHead=Sound'WeaponSounds.Shovel_HitHead'
	ShovelCleaveHead=Sound'WeaponSounds.Shovel_HitHead'
	ShovelHitBody=Sound'WeaponSounds.Shovel_HitBody'
	WeapChangeDist=0
	mood=MOOD_Combat
//	DefaultHandsTexture=Texture'WeaponSkins.Dude_Hands'
	DefaultHandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	DudeSuicideSound=Sound'DudeDialog.dude_iregretnothing'
	bShortSleeves=false
	bActorShadows=true
	HEAD_RATIO_OF_FULL_HEIGHT=0.5
}
