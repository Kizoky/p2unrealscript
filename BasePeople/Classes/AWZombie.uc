///////////////////////////////////////////////////////////////////////////////
// AWZombie
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all zombie characters in AW.
//
///////////////////////////////////////////////////////////////////////////////
class AWZombie extends AWPerson
	notplaceable;

var(PawnAttributes)name  InitAttackTag;		// Tag to attack when you get triggered
var(PawnAttributes)float ChargeFreq;		// 1.0 - 0.0, checks to charge second
var(PawnAttributes)float VomitFreq;			// 1.0 - 0.0,  checks to vomit first
var(PawnAttributes)float SpitSpeedMin;		// Minimum speed of spit vomit
var(PawnAttributes)float SpitSpeedMax;		// Maximum speed of spit vomit
var(PawnAttributes)float MoanFreq;			// 1.0 - 0.0
var(PawnAttributes)float TouretteFreq;		// 1.0 - 0.0
// All of this time will automatically be used, and a the same will have a portion randomly added
// so it has the potentional to be double the number entered
// 1.0 + Frand()*1.0 + MinTime (0.1)
var(PawnAttributes)float WalkAttackTimeHalf;// How long they walk towards attacker before they decide to attack
var(PawnAttributes)float ChargeAttackTimeHalf;// How long they charge towards attacker before they decide to attack
var(PawnAttributes)float CrawlAttackTimeHalf;// How long they crawl towards attacker before they decide to attack
// When the sledge hammer/scythe is raised to strike they are told about it, and will act accordingly to
// either attack you sooner, off guard, or run from you, or charge and then attack
var(PawnAttributes)float PreSledgeChargeFreq;	// Frequency of doing a charge attack if the player winds up for a sledge swing
var(PawnAttributes)float PreSledgeAttackFreq;	// Frequency of doing an attack if the player winds up for a sledge swing
var(PawnAttributes)float PreSledgeFleeFreq;		// Frequency of moving out of the way if the player winds up for a sledge swing

var class<DamageType> MyDamage;			// melee attack
var class<DamageType> BigSmashDamage;	// stronger melee
var class<VomitProjectile> vomitclass;
var bool bBlendTakeHit;			// When you're attacked during an attack, or if you're 
									// crawling, you'll quickly blend the attack if it's 
									// just a bludgeon attack. Otherwise, you'll play
									// a longer animation in a seperate state, to be stunned
									// by the attack.
var float DissolveTime;				// Actual time we bubble for when dissolving
var float DissolveRate;				// DissolveRate*DeltaTime is subtracted from the scale each time
									// so have the time this takes be about the same as DissolveTime
var float MinDissolveSize;
var class<ZDissolvePuddle> dissolveclass;
var Sound DissolveSound;			// sound we make as we dissolve
var bool  bFloating;
var float FloatTime;				// time we have to float
var float LastFloatTime;			// time since last check
var float StartingFloatTime;
var float FloatTimeInc;
var float PissTime;
var float PissReqTime;
var float ShakeMag;
var float PissInc;
var float StartPissTime;
var class<ZFloatStart> zfstartclass;
var ZFloatStart zfstart;
var class<ZFloatMove> zfmoveclass;
var ZFloatMove zfmove;
var class<ZFloatBlast> zfblastclass;
var ZFloatBlast zfblast;
var class<ZFloatRevive> zfreviveclass;
var ZFloatRevive zfrevive;
var class<ZFloatZap> zfzapclass;
var class<ZFloatZapMini> zfzapminiclass;
var float GenAnimSpeed, DefAnimSpeed;				// Speed of most animations--defaults to 1.0
var Sound ZapSound;
var transient AWZombie OldRagdollVersion;		// Version of me that was ragdolling still alive, save it
										// to replace it when I'm supposed to animate again
var transient AWZombie NewRagdollVersion;	// version to take my place
var transient ZombieHead	MyZombieHead;	// Zombie head we have--use to keep track of decapped head
											// as I'm destroyed and respawned after ragdolled from an explosion
											// Set and cleared by ZombieHead
var class<StumpBlood> StumpBloodClass;	// type of blood stumps make

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const SWIPE_DAMAGE_RADIUS	= 130;
const SWIPE_DAMAGE			= 15;
const SWIPE_IMPULSE			= 100;

const SMASH_DAMAGE_RADIUS	= 140;
const SMASH_DAMAGE			= 30;
const SMASH_IMPULSE			= 110;

const BALL_FORWARD			= 15;
const DEFAULT_SPIT_DIST		= 400;

const BONE_LCALF			= 'MALE01 l calf';

const RECOIL_BLEND_TIME		=	0.2;
const WAIT_FOR_DISSOLVE_TIME	=	3.0;
const XY_DISSOLVE_RATIO			=	0.5;
const FLOAT_ANIM_SPEED		=	1.8;
const ZAP_SIZE	=	2.5;
const REVIVE_PERCENT		= 0.95;

const TAKE_HIT_BLEND_ALPHA	= 0.5;

const ZOMBIE_SEVER_RAND		= 7; // 4 limbs, 1 to cut in half, 1 to cut off the head, and 1 to do nothing

const KARMA_RAND_TIME		      =	0.3;
const KARMA_ALIVE_TIME			  = 1.5;
const TOUCH_BLANK				  = 18;
const RECHECK_RAGDOLL_GROUND_TIME = 0.2;
const REANIMATE_RAGDOLL_DOWN_CHECK	= 30;
const RAGDOLL_STANDUP_BLENDTIME   = 0.4;
const RAGDOLL_CRAWL_PLAYSPEED	  = 10.0;
const RAGDOLL_STANDUP_PLAYSPEED	  = 4.0;
const STANDUP_WAITTIME			  = 0.4;
const FIND_GROUND_ALIVE_RAGDOLL	  = 200;
const CHANGE_OVER_RESTART_TIME	  = 0.4;

// Fix for invisible head If LD defines head skin but body skin
// (default body skins were overwritten by the chameleon skin setup)
// Quick fix, for now just override the LD setting and have the chameleon
// pick our zombies out
/*
function PreBeginPlay()
{
	// Ignore the cinematic zombies in Lower Paradise, these need to keep their skins.
	if (Tag != 'ZombieCashier')
	{
		HeadSkin = class'AWZombie'.Default.HeadSkin;
		Skins[0] = class'AWZombie'.Default.Skins[0];
	}

	Super.PreBeginPlay();
}
*/

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	// Check to randomize the start values some if the LD said to
	if(bStartupRandomization)
	{
		// Redo some zombie variables
		RandomizeAttribute(VoicePitch, RAND_ATTRIBUTE_DEFAULT, 0.7, 0.5);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Setup dialog
///////////////////////////////////////////////////////////////////////////////
function SetupDialog()
{
	// Zombies never change away from the default dialog
	DialogClass = Default.DialogClass;
	Super.SetupDialog();

	// Check to randomize the start values some if the LD said to
	if(bStartupRandomization)
	{
		// Redo some zombie variables
		RandomizeAttribute(VoicePitch, RAND_ATTRIBUTE_DEFAULT, 0.7, 0.5);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Determine if he's allowed to see the weapon fall, may have no legs, etc,
// then we wouldn't want him to go after it.
///////////////////////////////////////////////////////////////////////////////
function bool SeeWeaponDrop(P2WeaponPickup grabme)
{
	if(LambController(Controller) != None)
		return (!bFloating				// not your guy
				&& !bMissingLegParts	// has legs to move there
				&& (P2Weapon(Weapon) == None			// make sure he doesn't already have a big weapon
					|| P2Weapon(Weapon).ViolenceRank <= 0)
				&& LambController(Controller).SeeWeaponDrop(grabme));
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Certain weapons, like the sledge pickup, can fall and tell all zombies
// around it, about this, with the hopes that they will run and pick 
// it up. They won't then use it, they'll simply grab it from the player.
///////////////////////////////////////////////////////////////////////////////
function WeaponDropped(P2WeaponPickup grabme)
{
	if(LambController(Controller) != None)
		LambController(Controller).WeaponDropped(grabme);
}

///////////////////////////////////////////////////////////////////////////////
// Tear the torso from the extremities and send it flying backwards,
// while the limbs fall to the ground, but your head explodes, cause your a zombie
// Must have all your limbs to start with
///////////////////////////////////////////////////////////////////////////////
function BlowOffHeadAndLimbs(Pawn InstigatedBy, vector momentum, out int Damage)
{
	local int i;

	// blow up head
	ExplodeHead(MyHead.Location, Momentum);

	// Tear off all limbs
	for(i=0; i<SeverBone.Length; i+=2)
	{
		CutThisLimb(InstigatedBy, i, momentum, 0.5, 0.5);
	}

	// You'll definitely die from this
	Damage=Health;
	bSlomoDeath=true;
}

///////////////////////////////////////////////////////////////////////////////
// Add in new variables
///////////////////////////////////////////////////////////////////////////////
function InitBySpawner(PawnSpawner initsp)
{
	local AWBasePawnSpawner newsp;

	Super.InitBySpawner(initsp);

	newsp = AWBasePawnSpawner(initsp);
	if(newsp != None)
	{
		if(newsp.InitChargeFreq != DEF_SPAWN_FLOAT)
			ChargeFreq		= newsp.InitChargeFreq;	
		if(newsp.InitVomitFreq != DEF_SPAWN_FLOAT)
			VomitFreq		= newsp.InitVomitFreq;	
		if(newsp.InitMoanFreq != DEF_SPAWN_FLOAT)
			MoanFreq		= newsp.InitMoanFreq;	
	}
	//else
		//warn("Can't use old pawn spawner--use AWPawnSpawner");
}

///////////////////////////////////////////////////////////////////////////////
// Blood gurgles out the top
///////////////////////////////////////////////////////////////////////////////
function DoNeckGurgle()
{
	local GurgleBlood gb;

	// Only do the extra blood gurgle when you're not squirting other blood out the neck
	// just so it looks better
	if(gurgleclass != None
		&& FluidSpout == None)
	{
		gb = spawn(gurgleclass, self);
		AttachToBone(gb, BONE_NECK);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Copy of PersonPawn version, but blood spouts are changed
//
//	Decapitate the head and send it flying.
///////////////////////////////////////////////////////////////////////////////
function PopOffHead(vector HitLocation, vector Momentum)
{
	local PoppedHeadEffects headeffects;
	local P2Emitter HeadBloodTrail;			// Blood trail I drip if I'm detached.
	local StumpBlood sblood;
	local coords usec;

	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& P2Pawn(DamageInstigator) != None
		&& P2Pawn(DamageInstigator).bPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.HeadsLopped++;
	}

	Super(MpPawn).PopOffHead(HitLocation, Momentum);

	// Create blood from neck hole
	if(FluidSpout == None
		&& P2GameInfo(Level.Game).AllowBloodSpouts())
	{
		// If we're puking at the time our head goes away, then
		// keep puke going out the neckhole
		if(Head(MyHead).PukeStream != None)
		{
			FluidSpout = spawn(class'PukePourFeeder',self,,Location);
			// Make it the same type of puke
			FluidSpout.SetFluidType(Head(MyHead).PukeStream.MyType);
		}
		//else// If our head is removed while not puking, then make blood squirt out
		//	FluidSpout = spawn(class'BloodSpoutFeeder',self,,Location);
		else
		{
			usec = GetBoneCoords(BONE_HEAD);
			// attach blood too
			sblood= spawn(StumpBloodClass,self,,usec.origin);
			AttachToBone(sblood, BONE_HEAD);
		}

		if(FluidSpout != None)
		{
			FluidSpout.MyOwner = self;
			FluidSpout.SetStartSpeeds(100, 10.0);
			AttachToBone(FluidSpout, BONE_HEAD);
			SnapSpout(true);
		}
	}

	// Pop off the head
	DetachFromBone(MyHead);

	// Get it ready to fly
	Head(MyHead).StopPuking();
	Head(MyHead).StopDripping();
	MyHead.SetupAfterDetach();
	// Make a blood drip effect come out of the head
	HeadBloodTrail = Spawn(class'BloodChunksDripping ',self);
	HeadBloodTrail.Emitters[0].RespawnDeadParticles=false;
	HeadBloodTrail.SetBase(self);

	MyHead.GotoState('Dead');

	// Send it flying
	MyHead.GiveMomentum(Momentum);

	// Make some blood mist where it hit
	headeffects = spawn(class'PoppedHeadEffects',,,HitLocation);
	headeffects.SetRelativeMotion(Momentum, Velocity);

	//Remove connection to head but don't destroy it
	DissociateHead(false);
}

///////////////////////////////////////////////////////////////////////////////
// Copy of PersonPawn version, but blood spouts are changed
//
// Detonate head
///////////////////////////////////////////////////////////////////////////////
function ExplodeHead(vector HitLocation, vector Momentum)
{
	local int i, BloodDrips;
	local StumpBlood sblood;
	local coords usec;

	if (HitLocation == vect(0,0,0))
		HitLocation = MyHead.Location;

	Super(MpPawn).ExplodeHead(HitLocation, Momentum);

	Head(MyHead).PinataStyleExplodeEffects(HitLocation, Momentum);

	BloodDrips = FRand()*4;
	for(i=0; i<BloodDrips; i++)
		DripBloodOnGround(Momentum);

	// Simply don't put spouts in MP.
	if(FluidSpout == None
		&& Level.Game != None
		&& Level.Game.bIsSinglePlayer)
	{
		// If we're puking at the time our head goes away, then
		// keep puke going out the neckhole
		if(Head(MyHead).PukeStream != None)
		{
			FluidSpout = spawn(class'PukePourFeeder',self,,Location);
			// Make it the same type of puke
			FluidSpout.SetFluidType(Head(MyHead).PukeStream.MyType);
		}
//		else if(P2GameInfo(Level.Game).AllowBloodSpouts())
//			// If our head is removed while not puking, then make blood squirt out
//		{
//			FluidSpout = spawn(class'BloodSpoutFeeder',self,,Location);
//		}
		else
		{
			usec = GetBoneCoords(BONE_HEAD);
			// attach blood too
			sblood= spawn(StumpBloodClass,self,,usec.origin);
			AttachToBone(sblood, BONE_HEAD);
		}

		if(FluidSpout != None)
		{
			FluidSpout.MyOwner = self;
			FluidSpout.SetStartSpeeds(100, 10.0);
			AttachToBone(FluidSpout, BONE_NECK);
			SnapSpout(true);
		}
	}
	// No more head
	MyHead = None;
	bHasHead=false;
}

///////////////////////////////////////////////////////////////////////////////
//  Landed, tell controller
///////////////////////////////////////////////////////////////////////////////
function Landed(vector HitNormal)
{
	if(Controller != None)
		Controller.Landed(HitNormal);
}

///////////////////////////////////////////////////////////////////////////////
//	Stop running/walking
///////////////////////////////////////////////////////////////////////////////
function StopAcc()
{
	if(bFloating)
	{
		Acceleration = vect(0,0,0);
		Velocity=vect(0,0,0);
	}
	else if(Physics == PHYS_WALKING)
	{
		Acceleration = vect(0,0,0);
		Velocity = vect(0, 0, 0);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function SetupAnims()
{
	LinkAnims();

	//if(AnimGroupUsed != -1)
		AnimGroupUsed = Rand(10);	// Pick which walks and other random anims to pick.
	//debuglog(self@"pick anim group"@AnimGroupUsed);
	//else
	//	AnimGroupUsed=0;	// Pick the basic one

	if(bFloating)
		MovementAnims[0]	= 'z_bob';
	else if(AnimGroupUsed == 0)
		MovementAnims[0]	= 'z_walk1';
	else if(AnimGroupUsed == 1)
		MovementAnims[0]	= 'z_walk2';
	else if(AnimGroupUsed == 2)
		MovementAnims[0]	= 'z_walk3';
	else if(AnimGroupUsed == 3)
		MovementAnims[0]	= 'z_walk4';
	else if(AnimGroupUsed == 4)
		MovementAnims[0]	= 'z_walk5';
	else if(AnimGroupUsed == 5)
		MovementAnims[0]	= 'z_walk6';
	else if(AnimGroupUsed == 6)
		MovementAnims[0]	= 'z_walk7';
	else if(AnimGroupUsed == 7)
		MovementAnims[0]	= 'z_walk8';
	else if (AnimGroupUsed == 8)
		MovementAnims[0]	= 'z_walk9';
	else if (AnimGroupUsed == 9)
		MovementAnims[0]	= 'z_walk10';

	TurnLeftAnim		= MovementAnims[0];
	TurnRightAnim		= MovementAnims[0];
	MovementAnims[0]	= MovementAnims[0];
	MovementAnims[1]	= MovementAnims[0];
	MovementAnims[2]	= MovementAnims[0];
	MovementAnims[3]	= MovementAnims[0];


	// After all the setup, check to see if we're too fat to run much
	if (bIsFat)
	{
		// He's fat, so drop his fitness
		if(default.Fitness != Fitness)
			Fitness=0.5*Fitness;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function SetAnimWalking()
{
	if(bFloating)
		MovementAnims[0]	= 'z_bob';
	else if(AnimGroupUsed == 0)
		MovementAnims[0]	= 'z_walk1';
	else if(AnimGroupUsed == 1)
		MovementAnims[0]	= 'z_walk2';
	else if(AnimGroupUsed == 2)
		MovementAnims[0]	= 'z_walk3';
	else if(AnimGroupUsed == 3)
		MovementAnims[0]	= 'z_walk4';
	else if(AnimGroupUsed == 4)
		MovementAnims[0]	= 'z_walk5';
	else if(AnimGroupUsed == 5)
		MovementAnims[0]	= 'z_walk6';
	else if(AnimGroupUsed == 6)
		MovementAnims[0]	= 'z_walk7';
	else if(AnimGroupUsed == 7)
		MovementAnims[0]	= 'z_walk8';

	TurnLeftAnim		= MovementAnims[0];
	TurnRightAnim		= MovementAnims[0];
	MovementAnims[0]	= MovementAnims[0];
	MovementAnims[1]	= MovementAnims[0];
	MovementAnims[2]	= MovementAnims[0];
	MovementAnims[3]	= MovementAnims[0];
}
simulated function SetAnimCrouchWalking()
{
	if(bFloating)
		SetAnimWalking();
	else
		warn("Not supposed to be crouching--supply animations!");
}
simulated function SetAnimFlying()
{
	if(bFloating)
	{
		SetAnimWalking();
	}
	else
		warn("Not supposed to be flying--supply animations!");
}
simulated function SetAnimRunning()
{
	if(bFloating)
		MovementAnims[0]	= 'c_walk';
	else if (FRand() < 0.5)
		MovementAnims[0]	= 'z_charge';
	else
		MovementAnims[0]	= 'z_charge_alt';
	TurnLeftAnim		= MovementAnims[0];
	TurnRightAnim		= MovementAnims[0];
	MovementAnims[0]	= MovementAnims[0];
	MovementAnims[1]	= MovementAnims[0];
	MovementAnims[2]	= MovementAnims[0];
	MovementAnims[3]	= MovementAnims[0];
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function name GetAnimStand()
{
	if(bFloating)
		return 'z_bob';
	else
		return 'z_idle_stand';
}
simulated function name GetAnimRecognize()
{
	return 'z_recognizetarget';
}
simulated function name GetAnimSwipeLeft()
{
	if(!bFloating
		&& bMissingLegParts)
		return 'z_crawlswipeleft';
	else
		return 'z_swipeleft';
}
simulated function name GetAnimSwipeRight()
{
	if(!bFloating
		&& bMissingLegParts)
		return 'z_crawlswiperight';
	else
		return 'z_swiperight';
}
simulated function name GetAnimSmash()
{
	if (FRand() < 0.5)
		return 'z_smash';
	else
		return 'z_smash_alt';
}
simulated function name GetAnimVomitAttack()
{
	if(!bFloating
		&& bMissingLegParts)
	{
		return 'z_crawlspit';
	}
	else
		return 'z_spit';
}
simulated function name GetAnimHitLeft()
{
	return 'z_hitleft';
}
simulated function name GetAnimHitRight()
{
	return 'z_hitright';
}
simulated function name GetAnimHitBack()
{
	return 'z_hitback';
}
simulated function name GetAnimTourettes()
{
	return 'z_tourettemotions';
}
simulated function name GetAnimDeathCrawl()
{
	if (FRand() < 0.5)
		return 'z_crawl';
	else
		return 'z_crawl_alt';
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PlayAnimRecognize()
{
	//log(Self$" anim recognize ");
	PlayAnim(GetAnimRecognize(), GenAnimSpeed, 0.2);
}
function PlayAnimSwipeLeft()
{
	//log(Self$" anim swipe left, speed "$GenAnimSpeed);
	PlayAnim(GetAnimSwipeLeft(), GenAnimSpeed, 0.2);
}
function PlayAnimSwipeRight()
{
	//log(Self$" anim swipe right, speed "$GenAnimSpeed);
	PlayAnim(GetAnimSwipeRight(), GenAnimSpeed, 0.2);
}
function PlayAnimSmash()
{
	//log(Self$" anim smash, speed "$GenAnimSpeed);
	PlayAnim(GetAnimSmash(), GenAnimSpeed, 0.2);
}
function PlayAnimVomitAttack()
{
	//log(Self$" anim vomit attack ");
	PlayAnim(GetAnimVomitAttack(), GenAnimSpeed, 0.2);
}
function PlayAnimHitLeft()
{
	//log(Self$" anim hit left");
	PlayAnim(GetAnimHitLeft(), GenAnimSpeed, 0.2);
}
function PlayAnimHitRight()
{
	//log(Self$" anim hit right");
	PlayAnim(GetAnimHitRight(), GenAnimSpeed, 0.2);
}
function PlayAnimHitBack()
{
	//log(Self$" anim hit back");
	PlayAnim(GetAnimHitBack(), GenAnimSpeed, 0.2);
}

function PlayAnimHitLeftBlend()
{
	local float BlendAlpha;
	local float BlendTime;

	//log(Self$" anim hit left blend");
	BlendAlpha = TAKE_HIT_BLEND_ALPHA;//FRand()*0.5 + 0.5;
	BlendTime=0.2;
	AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, RECOIL_BLEND_TIME, 0, BONE_TOP_SPINE);
//	TweenAnim(GetAnimHitLeft(), BlendTime, TAKEHITCHANNEL);
	PlayAnim(GetAnimHitLeft(), GenAnimSpeed, BlendTime, TAKEHITCHANNEL);
}
function PlayAnimHitRightBlend()
{
	local float BlendAlpha;
	local float BlendTime;
	
	//log(Self$" anim hit right blend");
	BlendAlpha = TAKE_HIT_BLEND_ALPHA;//FRand()*0.5 + 0.5;
	BlendTime=0.2;
	AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, RECOIL_BLEND_TIME, 0, BONE_TOP_SPINE);
//	TweenAnim(GetAnimHitRight(), BlendTime, TAKEHITCHANNEL);
	PlayAnim(GetAnimHitRight(), GenAnimSpeed, BlendTime, TAKEHITCHANNEL);
}
function PlayAnimHitBackBlend()
{
	local float BlendAlpha;
	local float BlendTime;

	//log(Self$" anim hit back blend");
	BlendAlpha = TAKE_HIT_BLEND_ALPHA;//FRand()*0.5 + 0.5;
	BlendTime=0.2;
	AnimBlendParams(TAKEHITCHANNEL, BlendAlpha, RECOIL_BLEND_TIME, 0, BONE_TOP_SPINE);
//	TweenAnim(GetAnimHitBack(), BlendTime, TAKEHITCHANNEL);
	PlayAnim(GetAnimHitBack(), GenAnimSpeed, BlendTime, TAKEHITCHANNEL);
}
function PlayAnimTourettes()
{
//	AnimBlendParams(WEAPONCHANNEL, GenAnimSpeed, SWITCH_WEAPON_BLEND_TIME, 0, BONE_NECK);
//	PlayAnim(GetAnimTourettes(), GenAnimSpeed, 0.2, WEAPONCHANNEL);
}
function float PlayAnimStandUpFromRagdoll()
{
	local float BlendTime;

	PlayAnim(GetAnimDeathCrawl(), RAGDOLL_CRAWL_PLAYSPEED, 0.0);
	BlendTime = RAGDOLL_STANDUP_BLENDTIME;// + FRand()*KARMA_RAND_TIME;
	AnimBlendParams(TAKEHITCHANNEL, 1.0, BlendTime);
	PlayAnim(GetAnimStand(), RAGDOLL_STANDUP_PLAYSPEED, 0.0, TAKEHITCHANNEL);

	return STANDUP_WAITTIME;
}
function EndFightAnim()
{
	if(bFloating)
		LoopAnim(GetAnimStand(), 1.0, 0.2);
}
///////////////////////////////////////////////////////////////////////////////
// All other anims should end tourettes before playing, like attacking
// and such. The controller should call it as it ends it's state that
// started the tourettes animation in the first place. 
///////////////////////////////////////////////////////////////////////////////
function EndTourettes()
{
	AnimBlendToAlpha(WEAPONCHANNEL,0,0.0);
}

///////////////////////////////////////////////////////////////////////////////
// Notifies
///////////////////////////////////////////////////////////////////////////////
function NotifySwipeLeft()
{
	local vector HitPos, Rot, HitMomentum;

	if(!bDeleteMe
		&& Health > 0)
	{
		// for point around where to hurt things
		HitPos = Location;
		Rot = vector(Rotation);
		Rot.z = 0;
		// move it forwards
		HitPos += 0.8*CollisionRadius*Rot;
		// form momentum
		HitMomentum.x = -Rot.x;
		HitMomentum.y = -Rot.y;
		HitMomentum.z = 0.0;
		HitMomentum*=(SWIPE_IMPULSE);

		ZHurtThings(HitPos, HitMomentum,
					SWIPE_DAMAGE_RADIUS,
					SWIPE_DAMAGE, MyDamage);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function NotifySwipeRight()
{
	local vector HitPos, Rot, HitMomentum;

	if(!bDeleteMe
		&& Health > 0)
	{
		// for point around where to hurt things
		HitPos = Location;
		Rot = vector(Rotation);
		Rot.z = 0;
		// move it forwards
		HitPos += 0.8*CollisionRadius*Rot;
		// form momentum
		HitMomentum.x = -Rot.x;
		HitMomentum.y = -Rot.y;
		HitMomentum.z = 0.0;
		HitMomentum*=(SWIPE_IMPULSE);

		ZHurtThings(HitPos, HitMomentum,
					SWIPE_DAMAGE_RADIUS,
					SWIPE_DAMAGE, MyDamage);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function NotifySmash()
{
	local vector HitPos, Rot, HitMomentum;

	if(!bDeleteMe
		&& Health > 0)
	{
		// for point around where to hurt things
		HitPos = Location;
		Rot = vector(Rotation);
		Rot.z = 0;
		// move it forwards
		HitPos += 0.8*CollisionRadius*Rot;
		// form momentum
		HitMomentum.x = -Rot.x;
		HitMomentum.y = -Rot.y;
		HitMomentum.z = 0.0;
		HitMomentum*=(SMASH_IMPULSE);

		ZHurtThings(HitPos, HitMomentum,
					SMASH_DAMAGE_RADIUS,
					SMASH_DAMAGE, 
					BigSmashDamage, 
					true);
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function NotifySpitBall()
{
	local vector loc;
	local coords headloc;
	local VomitProjectile vproj;
	local vector usev;
	local float dist, usetime, zvel;

	if(!bDeleteMe
		&& Health > 0)
	{
		if(vomitclass != None)
		{
			if(bHasHead)
				headloc = GetBoneCoords(BONE_HEAD);
			else
				headloc = GetBoneCoords(BONE_NECK);

			loc = headloc.Origin;
			loc = BALL_FORWARD*(vector(Rotation)) + loc;
			vproj = spawn(vomitclass, self, , loc);
			if(vproj != None)
			{
				// Determine velocity of shot
				// Check distance to target
				if(LambController(Controller) != None
					&& LambController(Controller).Attacker != None)
					dist = VSize(LambController(Controller).Attacker.Location - Location);
				else
					dist = DEFAULT_SPIT_DIST + FRand()*DEFAULT_SPIT_DIST;
				// xy direction is vside*t
				// z direction is vup*t + 0.5at^2
				vproj.Speed = FRand()*(SpitSpeedMax - SpitSpeedMin) + SpitSpeedMin;
				usetime = dist/vproj.Speed;
				zvel = -0.5*vproj.Acceleration.z*usetime;
				usev = vproj.Speed*(vector(Rotation));
				usev.z = zvel;
				// Put velocity into projectile
				vproj.PrepVelocity(usev);
			}
		}

		// spitting noise
		Say(myDialog.lSpitting,true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Someone is about to attack us with a big weapon! (like a sledge or scythe)
// Do something!
///////////////////////////////////////////////////////////////////////////////
function BigWeaponAlert(P2MoCapPawn Swinger)
{
	//log(self$" big weapon alert "$swinger);
	if(PersonController(Controller) != None)
	{
		PersonController(Controller).DodgeBigWeapon(Swinger);
	}
}

///////////////////////////////////////////////////////////////////////////////
// hurt stuff on this side of me.
///////////////////////////////////////////////////////////////////////////////
function ZHurtThings(vector HitPos, vector HitMomentum, float Rad, float DamageAmount,
					class<DamageType> usedamage, optional bool bOnlyTarget)
{
	local Actor HitActor;
	local FPSPawn CheckP;

	ForEach CollidingActors(class'Actor', HitActor, Rad, HitPos)
	{
		// Don't hurt me
		if(HitActor != self
			// Don't hurt my hero
			&& (LambController(Controller) == None
				|| LambController(Controller).Hero != HitActor)
			// Don't attack through walls
			&& FastTrace(HitPos, HitActor.Location))
		{
			if(!bOnlyTarget
				|| (LambController(Controller) != None
					&& LambController(Controller).Attacker == HitActor))
				HitActor.TakeDamage(DamageAmount, self, HitPos, HitMomentum, usedamage);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	// If we're already on the ground then only have a single anim
	// reaction to a hit, otherwise, the controller will go into a special state to react
	// to the hit (not done here)
	if(bWantsToDeathCrawl
		|| bIsDeathCrawling
		|| bBlendTakeHit)
	{
		Super.PlayTakeHit(HitLoc, Damage, DamageType);
		bBlendTakeHit=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Zombies now auto-die if all limbs and head severed
///////////////////////////////////////////////////////////////////////////////
function bool HandleSever(Pawn instigatedBy, vector momentum, out class<DamageType> damageType,
						  int cutindex, out int Damage, out vector hitlocation)
{
	local bool returnval;

	returnval = Super.HandleSever(instigatedBy, momentum, damageType, cutindex, Damage, hitlocation);

	if(BoneArr[LEFT_ARM] == 0
		&& BoneArr[RIGHT_ARM] == 0
		&& 
		// If both legs are gone, or just the entire bottom half
		((BoneArr[LEFT_LEG] == 0
		&& BoneArr[RIGHT_LEG] == 0)
		|| bMissingBottomHalf)
		&& MyHead == None)
	{
		// Blow up their head
		MyZombieHead.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, class'ExplodedDamage');
	}
	
	return returnval;
}

///////////////////////////////////////////////////////////////////////////////
// Only takes shotgun shots to the head to blow up the head
///////////////////////////////////////////////////////////////////////////////
function bool HandleSpecialShots(int Damage, vector HitLocation, vector Momentum, out class<DamageType> ThisDamage,
							vector XYdir, Pawn InstigatedBy, out int returndamage, out byte HeadShot)
{
	local float PercentUpBody, ZDist, DistToMe;

	// Only let the player get special head shots
	// Projectile weapons
	if(FPSPawn(InstigatedBy).bPlayer)
	{
		if(Health > 0)
		{
			if(ThisDamage == class'ShotgunDamage'
				|| ThisDamage == class'RifleDamage')
			{
				// For if no damage is done
				if(TakesShotgunHeadShot == 0.0
					|| TakesRifleHeadShot == 0.0)
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
					
					if(DistToMe < DISTANCE_TO_EXPLODE_HEAD
						&& ThisDamage == class'ShotgunDamage')
					// Is close enough with a shotgun to explode the head
					{
						// Check a little more accurately, if you actually hit the head or not
						if(CheckHeadForHit(HitLocation, ZDist))
						{
							// We've hit the head, now reduce the damage, if necessary
							if(!(P2GameInfo(Level.Game) != None
								&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
								returndamage = TakesShotgunHeadShot*HealthMax;
							else
								returndamage = HealthMax+1;

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
					else if(ThisDamage == class'RifleDamage')
					// Sniper rifle rounds knock their heads off--they blow them up when the head
					// is decapitated.
					{
						HandleSever(instigatedBy, momentum, ThisDamage, HEAD_INDEX, Damage, hitlocation);
						HeadShot = 1;
						return true;
					}
				}
				// continue on, if this didn't take
			}
		}
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// If the guy your recreating isn't supposed to have a head, get rid of it here
// Called inside SwapGuy
///////////////////////////////////////////////////////////////////////////////
function SwapDestroyOldHead(AWPerson NewMe)
{
	if(ZombieHead(newme.MyHead) != None)
		ZombieHead(newme.MyHead).MyZombie = None;	// unhook the zombie pawn
		// we're connected to, he'll be killed for us nicely, later
	Super.SwapDestroyOldHead(newme);
}

///////////////////////////////////////////////////////////////////////////////
// Return back to deathcrawling, after getting thrown by karma alive still
// After load means while a guy was alive-ragdolling the game was saved.
// After the load then, this gets recalled, but doesn't set up the rotation
// and instantly deletes the old version
///////////////////////////////////////////////////////////////////////////////
function ConvertToAnimAfterRagdoll(bool bAfterLoad)
{
	local Actor HitActor;
	local AWZombie newme;
	local vector startloc, endloc, newloc, HitLocation, HitNormal;
	local bool bHadKarma;
	local Material PickSkin;
	local Chameleon cham;
	local coords usecoords;
	local rotator userot;

	if(!bAfterLoad)
	{
		// Find the pelvis bone and use it's direction as the new direction to start us in (Yaw only)
		usecoords = GetBoneCoords(BONE_PELVIS);
		//log(self$" pelvis x: "$rotator(usecoords.XAxis)$" pelvis y: "$rotator(usecoords.YAxis)$" pelvis z: "$rotator(usecoords.ZAxis)$" orig rotation "$PreRagdollRotation);
		userot = rotator(usecoords.XAxis);
		PreRagdollRotation.Yaw = userot.Yaw;
		//log(self$" using rot "$PreRagdollRotation);
	}
	else
		PreRagdollRotation = Rotation;

	SetCollision(false, false, false);
	bCollideWorld=false;
	startloc = Location;
	startloc.z+=1;
	endloc = Location;
	endloc.z-=FIND_GROUND_ALIVE_RAGDOLL;
	HitActor = Trace(HitLocation, HitNormal, endloc, startloc, true);
	if(HitActor != None)
	{
		newloc = HitLocation;
		newloc.z+=2*default.CollisionHeight;
	}
	else
	{
		newloc = Location;
		newloc.z+=2*default.CollisionHeight;
	}
	
	if(Skins.Length > 0
		&& Skins[0] != BurnSkin)
		PickSkin = Skins[0];

	//log("Pre-Spawn",'Debug');
	newme = spawn(class,,,newloc,PreRagdollRotation,PickSkin);
	//log("Post-Spawn",'Debug');
	if(newme != None)
	{
		newme.PreRagdollRotation = newme.Rotation;
		// Copy over a few important FPSPawn values
		newme.bPersistent=bPersistent;
		newme.bCanTeleportWithPlayer=bCanTeleportWithPlayer;
		// Save old version which is the current self
		newme.OldRagdollVersion = self;
		NewRagdollVersion = newme;
		// Be invisible while animating down
		newme.bHidden=true;

		SwapGuy(self, newme, false);
		
		if(MyZombieHead != None)
			MyZombieHead.SetZombieBody(newme);

		if(bAfterLoad)
		{
			newme.GotoState('RestartAfterUnRagdollLoad');
			Destroy();
		}
		else
		{
			newme.GotoState('RestartAfterUnRagdoll');
			// I wait for the change here
			GotoState('RagdollAliveChanging');
		}
	}
	else // Didn't work to make new guy, try again soon
	{
		if(bAfterLoad)
			Destroy();
		else
			GotoState('RagdollAlive');
	}
}
function ShouldDeathCrawl(bool bDoDeathCrawl)
{
	//log(Self$" should dcrawl "$bdodeathcrawl$" height "$CollisionHeight$" rad "$CollisionRadius);
	super.shoulddeathcrawl(bdodeathcrawl);
}
event StartDeathCrawl(float HeightAdjust)
{
	//log(self$" start death crawl "$heightadjust$" height "$CollisionHeight$" rad "$CollisionRadius);
	Super.StartDeathcrawl(heightadjust);
}
event EndDeathCrawl(float HeightAdjust)
{
	//log(self$" STOP death crawl "$heightadjust$" height "$CollisionHeight$" rad "$CollisionRadius);
	Super.EndDeathcrawl(heightadjust);
}

function ShouldCrouch(bool Crouch)
{
	//log(Self$" should crouch "$Crouch$" height "$CollisionHeight$" rad "$CollisionRadius);
	super.shouldCrouch(Crouch);
}
event StartCrouch(float HeightAdjust)
{
	//log(self$" start crouch"$heightadjust$" height "$CollisionHeight$" rad "$CollisionRadius);
	Super.StartCrouch(heightadjust);
}
event EndCrouch(float HeightAdjust)
{
	//log(self$" STOP crouch "$heightadjust$" height "$CollisionHeight$" rad "$CollisionRadius);
	Super.EndCrouch(heightadjust);
}

///////////////////////////////////////////////////////////////////////////////
// Handle explosions blowing you apart or any kind of big smashing damage
// like elephants smashing you around
///////////////////////////////////////////////////////////////////////////////
function HandleExplosion(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local vector usevel;
	local int userand;

	// Randomly decide to cut off limbs or cut them in half, also now decide to cut off the head
	userand = Rand(ZOMBIE_SEVER_RAND);	// 4 limbs, 1 to cut in half, 1 to cut off the head, and 1 to do nothing
	switch(userand)
	{
		// cut off right arm
		case 0: HandleSever(instigatedBy, momentum, damageType, RIGHT_ARM, Damage, hitlocation);
			break;
		// cut off left arm
		case 1: HandleSever(instigatedBy, momentum, damageType, LEFT_ARM, Damage, hitlocation);
			break;
		// cut off right leg
		case 2: HandleSever(instigatedBy, momentum, damageType, RIGHT_LEG, Damage, hitlocation);
			break;
		// cut off left leg
		case 3: HandleSever(instigatedBy, momentum, damageType, LEFT_LEG, Damage, hitlocation);
			break;
		// cut them in half
		case 4: 
			if(!bMissingTopHalf
				&& !bMissingBottomHalf)
				ChopInHalf(InstigatedBy, DamageType, momentum, Damage, hitlocation);
			break;
		// cut off head
		case 5: HandleSever(instigatedBy, momentum, damageType, HEAD_INDEX, Damage, hitlocation);
			break;
	}
	
	// Save our rotation before we ragdolled.
	PreRagdollRotation = Rotation;

	// Convert them, still alive, to a karma skeleton, and send them flying through
	// the air
	if(KParams == None
		&& AllowRagdoll(DamageType))
	{
		// Check to get a ragdoll skeleton from the game info.
		GetKarmaSkeleton();
	}

	if (Level.NetMode != NM_DedicatedServer
		&& (KarmaParamsSkel(KParams) != None) )
	{
		usevel = DeathVelMag * Normal(momentum/Mass);

		if(Physics != PHYS_KarmaRagDoll)
		{
			// Don't crouch or crawl anymore
			ShouldCrouch(false);
			ShouldDeathCrawl(false);

			StopAnimating();
			bPhysicsAnimUpdate = false;

			SetPhysics(PHYS_KarmaRagDoll);

			// Get things going first, for sure
			KWake();

			CapKarmaMomentum(momentum, DamageType, 1.0, 1.0);

			// Set the guy moving in direction he was shot in general
			KSetSkelVel( usevel );
		}

		// Move the body
		KAddImpulse(momentum, hitlocation);

		// Tell your controller you live-karma-ing
		LambController(Controller).DoLiveRagdoll();

		// Start ragdolling alive
		GotoState('RagdollAlive');
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

	lambc = LambController(Controller);

	//log(self$" zombie take damage "$myhead$" can come off "$bheadcancomeoff$" num "$P2GameInfoSingle(Level.Game).TheGameState.ShotgunHeadShot);
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

	// Don't get hurt by our own hero
	if(lambc.Hero == instigatedBy
		&& instigatedBy != None)
		return;

	// Used for debugging.
	if(NO_ONE_DIES != 0)
		return;

	// Save who did this
	DamageInstigator = instigatedBy;

	// Handle limb chopping/new weapons in AW
	StartDamage = Damage;
	// Reduce damage as necessary
	if(ClassIsChildOf(damageType, class'MacheteDamage'))
		Damage = TakesMacheteDamage*Damage;
	else if(ClassIsChildOf(damageType, class'SledgeDamage'))
		Damage = TakesSledgeDamage*Damage;
	else if(ClassIsChildOf(damageType, class'ScytheDamage'))
		Damage = TakesScytheDamage*Damage;
	else if(ClassIsChildOf(damageType, class'SwipeSmashDamage'))
		Damage = TakesZombieSmashDamage*Damage;

	if(class'P2Player'.static.BloodMode()
		// can't cut off zombie limbs
		&& P2Player(Controller) == None)
	{
		// If it's a damage type and hasn't been lowered
		if(Damage >= StartDamage
			&& ClassIsChildOf(damageType, class'MacheteDamage'))
			HandleSever(InstigatedBy, momentum, damagetype, INVALID_LIMB, Damage, HitLocation);
		else if(Damage >= StartDamage
				&& (ClassIsChildOf(damageType, class'SledgeDamage')
					|| ClassIsChildOf(damageType, class'SwipeSmashDamage')))
		{
			if(HandleSledge(InstigatedBy, momentum, damagetype, Damage, HitLocation))
				HeadShot=1;
		}
		else if(Damage >= StartDamage
				&& ClassIsChildOf(damageType, class'ScytheDamage'))
			HandleScythe(InstigatedBy, momentum, damagetype, Damage, HitLocation);
		else if((ClassIsChildOf(damageType, class'ExplodedDamage')
					|| ClassIsChildOf(damageType, class'SmashDamage'))
				&& !bFloating)
			HandleExplosion(Damage, InstigatedBy, HitLocation, momentum, damageType);
	}
	// End of Handle limb chopping/new weapons in AW

	// Calc the damage based on the body location for the hit
	if(HeadShot == 0)
		Damage = ModifyDamageByBodyLocation(Damage, InstigatedBy, HitLocation, 
										momentum, DamageType, HeadShot);
	// Save the momentum because for some reason it has to be squished in Z so most poeple
	// don't go flying into the air from a bullet shot.
	OrigMomentum = momentum;

	// Eleminate any momentum from clean head shots, so the head gets hurt/removed, but
	// the body just slumps down
	if(HeadShot == 1)
		Momentum = vect(0, 0, 0);

	// Bullets don't slow us down
	if(ClassIsChildOf(damageType, class'BulletDamage'))
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

	// Now that we're officially damage, check the damage types we don't want to kill
	// us all the way. If taking away this much health would have killed us and we don't
	// want it to, reduce us to one unit of health.
	// We don't want to go below this, becuase the HUD will display 0, and that will look
	// broken.
	if(class<P2Damage>(damageType) != None
		&& (!class<P2Damage>(damageType).default.bCanKill
			|| (class<P2Damage>(damageType).default.bNoKillPlayers
				&& bPlayer))
		&& ((Health - actualDamage) < OneUnitInHealth))
	{
		Health = OneUnitInHealth;
	}
	else
	{
		// Shotgun, sledgehammer, and zombie smash head shot damage is the only type to blow up a zombies head
		// Or if your head was killed, then you must die too
		if(damageType == class'HeadKillDamage'
			|| ((ClassIsChildOf(damageType, class'ShotgunDamage')
					|| ClassIsChildOf(damageType, class'SledgeDamage')
					|| ClassIsChildOf(damageType, class'SwipeSmashDamage'))
				&& HeadShot == 1))
		{
			// if this damage type CAN kill you, take off damage like normal
			Health = Health - actualDamage;
		}
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

		// Send the real momentum to this function, please
	PlayHit(actualDamage, hitLocation, damageType, OrigMomentum);

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
}

///////////////////////////////////////////////////////////////////////////////
// Nothing happens in alive version
///////////////////////////////////////////////////////////////////////////////
function AttemptZombieRevival(P2Pawn Other)
{
}

///////////////////////////////////////////////////////////////////////////////
// Start floating
///////////////////////////////////////////////////////////////////////////////
function SetToFloating()
{
	local AWDude usedude, makerdude;

	// Make sure you're floating
	bFloating=true;
	// Make your new controller
	Controller = spawn(ControllerClass);
	Controller.Possess(self);
	// Convert your body to missing a head and bottom, but with arms
	DissociateHead(true);
	bMissingBottomHalf=true;
	BoneArr[LEFT_LEG]=0;
	BoneArr[RIGHT_LEG]=0;
	RemoveLimbsAfterLoad(self);
	bMissingLimbs=true;
	bMissingLegParts=true;
	SetCollisionSize(CrouchRadius, CrouchHeight);
	// Set some variables to make sure he's useable, for instance, you may have gotten a 'no charge'
	// zombie in which case he'll seem pretty broken and lame. This doesn't make them all the same,
	// it just makes them all a little more useful.
	if(ChargeFreq < default.ChargeFreq)
		ChargeFreq = default.ChargeFreq;
	if(VomitFreq < default.VomitFreq)
		VomitFreq = default.VomitFreq;
	
	// Setup anims
	ChangeAnimation();
	// Play zapping sound
	PlaySound(ZapSound, SLOT_Misc, 1.0,,1000);
	// Make him love his ressurrector
	foreach DynamicActors(class'AWDude', makerdude)
	{
		if(makerdude != None)
			usedude = makerdude;
	}
	StartFloatTime();
	LambController(Controller).HookHero(usedude);
	// Speed him up
	GenAnimSpeed=FLOAT_ANIM_SPEED;
	// Take strength from dude
	TakeStrengthFromHero(true);
	// Tell game info you ressurected another zombie
	P2GameInfoSingle(Level.Game).TheGameState.ZombiesResurrected++;
	P2GameInfoSingle(Level.Game).Tunneling = TOUCH_BLANK + Rand(TOUCH_BLANK) + 1;
	// Get an achievement!
	if( Level.NetMode != NM_DedicatedServer ) PlayerController(UseDude.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(UseDude.Controller),'Resurrection');
	//log(Self$" setting tunneling "$AWGameSP(Level.Game).Tunneling);

	GotoState('FloatingAlive');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TakeStrengthFromHero(optional bool bBigZap)
{
	local FPSPawn myhero;
	local ZFloatZap	zfzap;

	if(LambController(Controller) != None)
		myhero = LambController(Controller).Hero;
	// zap player for energy
	if(myhero != None)
	{
		if(bBigZap)
		{
			if(zfzapclass != None)
			{
				zfzap = spawn(zfzapclass,myhero,,Location);
				// align lightning at the dude
				zfzap.SetEndPoint(ZAP_SIZE*(myhero.Location - zfzap.Location));
			}
		}
		else if(zfzapminiclass != None)
		{
			zfzap = spawn(zfzapminiclass,myhero,,Location);
			// align lightning at the dude
			zfzap.SetEndPoint(ZAP_SIZE*(myhero.Location - zfzap.Location));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function StartFloatTime()
{
	FloatTime = StartingFloatTime;
	LastFloatTime = Level.TimeSeconds;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function IncreaseFloatTime()
{
	FloatTime = FloatTime + FloatTimeInc;
	if(FloatTime > StartingFloatTime)
		FloatTime = StartingFloatTime;
	LastFloatTime = Level.TimeSeconds;
}

///////////////////////////////////////////////////////////////////////////////
// Either create a new one or revive an old one
///////////////////////////////////////////////////////////////////////////////
function HandleZStartEffect()
{
	local byte StateChange;
	local vector useloc;
	local vector endpt, hitlocation, hitnormal;
	local Actor HitActor;

	// Try to revive
	if(zfstart != None)
	{
		zfstart.Revive(StateChange);
		if(StateChange == 0)
			RemoveZStartEffect();
	}

	// add effect
	if(zfstart == None)
	{
		if(zfstartclass != None)
		{
			// Trace down and find the ground first
			endpt = Location;
			endpt.z -= 500;
			HitActor = Trace(HitLocation, HitNormal, endpt, Location, true);
			if(HitActor != None
				&& HitActor.bStatic)
				useloc = hitlocation;
			else 
				useloc = Location;
			zfstart = spawn(zfstartclass, self, , useloc);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// It's going to die
///////////////////////////////////////////////////////////////////////////////
function RemoveZStartEffect()
{
	zfstart = None;
}

///////////////////////////////////////////////////////////////////////////////
// Make a new one if we need it
///////////////////////////////////////////////////////////////////////////////
function HandleZReviveEffect()
{
	local byte StateChange;

	// add effect
	if(zfrevive == None)
	{
		if(zfreviveclass != None)
		{
			zfrevive = spawn(zfreviveclass, self, , Location);
			AttachToBone(zfrevive, BONE_PELVIS);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// It's going to die
///////////////////////////////////////////////////////////////////////////////
function RemoveZReviveEffect()
{
	zfrevive = None;
	TakeStrengthFromHero();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ShakeMe()
{
	local vector kmom;

	if(KarmaParamsSkel(KParams) != None
		&& Physics == PHYS_KarmaRagDoll)
	{
		// Reset timer to ensure use of ragdoll
		RagDollStartTime = Level.TimeSeconds;
		kmom.z = ShakeMag;
		KAddImpulse(kmom, Location, BONE_PELVIS);
	}
	else // animate the body around
	{
		//kmom = ShakeMag*VRand();
		TweenAnim(GetAnimDeathCrawlDeath(),0.2,TAKEHITCHANNEL);
	}
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
	///////////////////////////////////////////////////////////////////////////////
	// Player pissed on him without head, has two arms, and no body, gets ressurrected.
	///////////////////////////////////////////////////////////////////////////////
	function AttemptZombieRevival(P2Pawn Other)
	{
		log(self$" body juice "$other$" head "$bhashead$" missing "$bmissingbottomhalf$" left "$BoneArr[LEFT_ARM]$" right "$BoneArr[RIGHT_ARM]);

		if(!bHasHead
			&& bMissingBottomHalf
			&& BoneArr[LEFT_ARM] == 1
			&& BoneArr[RIGHT_ARM] == 1
			&& AWDude(Other)!=None)
		{
			// start piss time
			if(PissTime < StartPissTime)
				PissTime=StartPissTime;

			// Reset dissolve timer
			if(TimeTillDissolve > 0)
				SetTimer(TimeTillDissolve, false);

			HandleZStartEffect();

			// If his skeleton has been taken away from him, reserve it
			// for some more time, if one's available
			if(KParams == None)
			{
				GetKarmaSkeleton();
				if(KParams != None)
				{
					// Don't crouch or crawl anymore
					ShouldCrouch(false);
					ShouldDeathCrawl(false);

					StopAnimating();
					
					bPhysicsAnimUpdate = false;

					SetPhysics(PHYS_KarmaRagDoll);

					// Get things going first, for sure
					KWake();
					KSetSkelVel( (DeathVelMag * VRand()) );
				}
			}

			GotoState('DyingShaking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Allow no more interaction
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
	{
		//ErikFOV Change: Fix problem
		if (bPendingDelete || bDeleteMe)
			return;
		//End

		// Reset time to dissolve each time, if it gets moved significantly
		if(!ClassIsChildOf(damageType, class'BulletDamage')
			&& !ClassIsChildOf(damageType, class'BurnedDamage')
			&& !ClassIsChildOf(damageType, class'OnFireDamage')
			&& TimeTillDissolve > 0)
			SetTimer(TimeTillDissolve, false);

		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		// If we're in no-ragdoll mode, just vanish
		if (P2GameInfoSingle(Level.Game) != None && P2GameInfoSingle(Level.Game).bForbidRagdolls)
		{
			TryToRemoveDeadBody();
			if (!bDeleteMe)
				SetTimer(5.0, false); // try again later
		}
		else // otherwise dissolve like normal
			GotoState('PrepForDissolving');
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		//ErikFOV Change: Fix problem
		if (bPendingDelete || bDeleteMe)
			return;
		//End

		Super.BeginState();
		// reset the timer to do our bidding.. namely, make him dissolve after
		// a time
		if(TimeTillDissolve > 0)
			SetTimer(TimeTillDissolve, false);
		//log(Self$" begin state "$getstatename());
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RestartAfterUnRagdoll
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestartAfterUnRagdoll
{
	ignores TakeDamage;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function StartupController()
	{
		if ( ControllerClass != None)
			Controller = spawn(ControllerClass);
		if ( Controller != None )
		{
			Controller.Possess(self);
			LambController(Controller).RestartAfterUnRagdollWait();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function FinishController()
	{
		if ( LambController(Controller)!= None )
		{
			LambController(Controller).RestartAfterUnRagdoll();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function DumpOldVersion()
	{
		// The version that started us should be destroyed
		if(OldRagdollVersion != None
			&& !OldRagdollVersion.bDeleteMe)
		{
			OldRagdollVersion.NewRagdollVersion = None;
			OldRagdollVersion.Destroy();
		}
	}
Begin:
	//.Fall to the ground
	SetPhysics(PHYS_Falling);
	PlayAnim(GetAnimDeathFallForward(),SUPER_FAST_RATE);
	StartupController();
	Sleep(CHANGE_OVER_RESTART_TIME);
	RemoveLimbsAfterLoad(self, true);
	FinishController();
	bHidden=false;
	DumpOldVersion();
	GotoState('');
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RestartAfterUnRagdollLoad
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestartAfterUnRagdollLoad extends RestartAfterUnRagdoll
{
	///////////////////////////////////////////////////////////////////////////////
	// No old version to dump after a load, he's already been destroyed
	///////////////////////////////////////////////////////////////////////////////
	function DumpOldVersion()
	{
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RagdollAlive
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RagdollAlive
{
	ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer,
		SetMood, AttemptZombieRevival;

	///////////////////////////////////////////////////////////////////////////////
	// Get rid of me on load
	///////////////////////////////////////////////////////////////////////////////
	event PostLoadGame()
	{
		if(!bPostLoadCalled)
		{
			bPostLoadCalled=true;
			ConvertToAnimAfterRagdoll(true);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		GotoState('RagdollAliveChecking');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if your head exploded while in this state
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
	{
		local Controller Killer;

		if(ClassIsChildOf(damageType, class'HeadKillDamage'))
		{
			Health = 0;
			// Pawn died
			if ( instigatedBy != None )
				Killer = InstigatedBy.GetKillerController();
			if ( bPhysicsAnimUpdate )
				TearOffMomentum = Momentum / Mass;

			Died(Killer, damageType, HitLocation);
		}
		else
			Super(AWPerson).TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
	}
Begin:
	SetTimer(KARMA_ALIVE_TIME + FRand()*KARMA_RAND_TIME, false);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RagdollAliveChecking
// Getting ready to reanimate
// Do checks to see if we're close enough to the ground to reanimate
// Either way, a timer will go off when we need to start moving
// even if we haven't found the ground by then.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RagdollAliveChecking extends RagdollAlive 
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		ConvertToAnimAfterRagdoll(false);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if we're close enough to the ground to start crawling again
	///////////////////////////////////////////////////////////////////////////////
	function CheckToReanimate()
	{
		local vector endpt;

		endpt = Location;
		endpt.z -= REANIMATE_RAGDOLL_DOWN_CHECK;

		if(!FastTrace(endpt, Location))
		{
			ConvertToAnimAfterRagdoll(false);
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		SetTimer(KARMA_ALIVE_TIME + FRand()*KARMA_RAND_TIME, false);
	}
Begin:
	Sleep(RECHECK_RAGDOLL_GROUND_TIME);
	CheckToReanimate();
	goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RagdollAliveChanging
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RagdollAliveChanging extends RagdollAlive
{
	ignores Timer, TakeDamage, BeginState;
	///////////////////////////////////////////////////////////////////////////////
	// Get rid of me on load
	///////////////////////////////////////////////////////////////////////////////
	event PostLoadGame()
	{
		if(NewRagdollVersion != None
			&& !NewRagdollVersion.bDeleteMe)
			NewRagdollVersion.OldRagdollVersion = None;
		Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DyingShaking
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DyingShaking extends Dying
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		// Been too long, return to dying state
		if(PissTime > 0)
			PissTime-=DeltaTime;
		if(PissTime <= 0)
		{
			GotoState('Dying');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Player pissed on him without head, has two arms, and no body, gets ressurrected.
	///////////////////////////////////////////////////////////////////////////////
	function AttemptZombieRevival(P2Pawn Other)
	{
		local vector useloc;
		local vector endpt, hitlocation, hitnormal;
		local Actor HitActor;

		if(!bHasHead
			&& bMissingBottomHalf
			&& BoneArr[LEFT_ARM] == 1
			&& BoneArr[RIGHT_ARM] == 1
			&& AWDude(Other)!=None)
		{
			if(zfblast == None)
			{
				// Add to piss time
				PissTime+=PissInc;
				// If we've started, check if they've pissed on him enough to change him
				if(PissTime > PissReqTime)
				{
					if(zfblastclass != None)
					{
						// Trace down and find the ground first
						endpt = Location;
						endpt.z -= 500;
						HitActor = Trace(HitLocation, HitNormal, endpt, Location, true);
						if(HitActor != None
							&& HitActor.bStatic)
							useloc = hitlocation;
						else 
							useloc = Location;
						zfblast = spawn(zfblastclass, self,,useloc);
						zfblast.awp = P2Player(Other.Controller);;
						GotoState('DyingShakingFloating');
					}
					else
						warn("can't continue without zfloatblast class!");
				}
				else // still working on reviving him
				{
					// Reset dissolve timer
					if(TimeTillDissolve > 0)
						SetTimer(TimeTillDissolve, false);

					// Constantly revive starting effect--if they stop pissing it'll go
					// away
					HandleZStartEffect();

					ShakeMe();
				}
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		// Get rid of ground effect
		if(zfstart != None)
		{
			zfstart.SelfDestroy();
			zfstart = None;
		}
		Super.EndState();
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DyingShakingFloating
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DyingShakingFloating extends Dying
{
	ignores AttemptZombieRevival, TakeDamage;
Begin:
	Sleep(0.1);
	ShakeMe();
	goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FloatingAlive
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FloatingAlive
{
	///////////////////////////////////////////////////////////////////////////////
	// Pissing on me when floating revives me
	///////////////////////////////////////////////////////////////////////////////
	function AttemptZombieRevival(P2Pawn Other)
	{
		if(AWDude(Other) != None)
			IncreaseFloatTime();
		// Check to show effect, only if he's not got enough juice yet
		// If he doesn't then don't show the effect and don't zap the player
		// so he knows the zombie is full and ready to go
		if(FloatTime < REVIVE_PERCENT*StartingFloatTime)
			HandleZReviveEffect();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Remove effect when we stop this
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(zfmove != None)
		{
			zfmove.SelfDestroy();
			zfmove = None;
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		SetPhysics(PHYS_FLYING);
		if(zfmove == None
			&& zfmoveclass != None)
		{
			zfmove = spawn(zfmoveclass, self, , Location);
			AttachToBone(zfmove, BONE_PELVIS);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PrepForDissolving
// Hold him so he doesn't move around for a few seconds first, before
// removing him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepForDissolving extends Dying
{
	ignores TakeDamage;
	///////////////////////////////////////////////////////////////////////////////
	// Do actual dissolve now
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		GotoState('Dissolving');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn off our collision with players/damage first
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		bBlockZeroExtentTraces=false;
		bBlockNonZeroExtentTraces=false;
		SetCollision(false, false, false);
		SetTimer(WAIT_FOR_DISSOLVE_TIME, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dissolving
// bubble effects play as I 'sink' into the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dissolving extends Dying
{
	ignores TakeDamage;
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		local vector newd;
		newd = DrawScale3D;
		// shrink mostly up and down
		newd.z-=(DeltaTime*DissolveRate);
		// also shrink side to side, but less
		newd.x-=(DeltaTime*DissolveRate*XY_DISSOLVE_RATIO);
		newd.y-=(DeltaTime*DissolveRate*XY_DISSOLVE_RATIO);
		if(newd.z < MinDissolveSize)
			newd.z = MinDissolveSize;
		SetDrawScale3D(newd);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Make him fall out of the world now
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		GotoState('FallDissolve');
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function MakeDissolvePuddle(vector loc)
	{
		local ZDissolvePuddle dissolver;
		local vector endpt, hitlocation, hitnormal;
		local Actor HitActor;

		// Trace down and find the ground first
		endpt = loc;
		endpt.z -= default.CollisionHeight;
		HitActor = Trace(HitLocation, HitNormal, endpt, loc, true);
		if(HitActor != None
			&& HitActor.bStatic)
		{
			loc = HitLocation;
		}
		// Set emitter at neck line
		dissolver = spawn(dissolveclass,self,,loc);
		dissolver.SetTimer(DissolveTime, false);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn off our collision with players/damage first
	// Modify sound also
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local coords usecoords;
		// How long we dissolve for
		SetTimer(DissolveTime, false);

		// Setup boiling sound
		AmbientSound=DissolveSound;
		SoundRadius=30;
		TransientSoundRadius=SoundRadius;
		SoundVolume=255;
		TransientSoundVolume=SoundVolume;
		SoundPitch=0.75;

		// Make effects to go with shrinking
		if(dissolveclass != None)
		{
			// Set emitter below neck line
			usecoords = GetBoneCoords(BONE_NECK);
			MakeDissolvePuddle(usecoords.origin);
			// Put one below pelvis too
			usecoords = GetBoneCoords(BONE_PELVIS);
			MakeDissolvePuddle(usecoords.origin);
			// If he's got a right calf, one for there too
			if(BoneArr[RIGHT_LEG] == 1)
			{
				usecoords = GetBoneCoords(BONE_RCALF);
				MakeDissolvePuddle(usecoords.origin);
			}
			// If he's got a left calf, one for there too
			if(BoneArr[LEFT_LEG] == 1)
			{
				usecoords = GetBoneCoords(BONE_LCALF);
				MakeDissolvePuddle(usecoords.origin);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FallDissolve
// Sink into the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallDissolve extends Dying
{
	ignores TakeDamage;
	///////////////////////////////////////////////////////////////////////////////
	// Delete me now if not already gone
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		Destroy();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn off world collision to make it fall
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		SetTimer(1.0, false);
		bCollideWorld=false;
	}
}

defaultproperties
{
	 ActorID="Zombie"
     ChargeFreq=0.400000
     VomitFreq=0.400000
     SpitSpeedMin=300.000000
     SpitSpeedMax=700.000000
     MoanFreq=0.500000
     TouretteFreq=1.000000
     WalkAttackTimeHalf=2.000000
     ChargeAttackTimeHalf=1.000000
     CrawlAttackTimeHalf=3.000000
     PreSledgeChargeFreq=0.400000
     PreSledgeAttackFreq=0.400000
     PreSledgeFleeFreq=0.500000
     MyDamage=Class'SwipeDamage'
     BigSmashDamage=Class'SwipeSmashDamage'
     vomitclass=Class'VomitProjectile'
     DissolveTime=6.000000
     DissolveRate=0.200000
     MinDissolveSize=0.300000
     dissolveclass=Class'ZDissolvePuddle'
     DissolveSound=Sound'LevelSounds.potBoil'
     StartingFloatTime=130.000000
     FloatTimeInc=1.000000
     PissReqTime=20.000000
     ShakeMag=8500.000000
     PissInc=0.300000
     StartPissTime=5.000000
     zfstartclass=Class'ZFloatStart'
     zfmoveclass=Class'ZFloatMove'
     zfblastclass=Class'ZFloatBlast'
     zfreviveclass=Class'ZFloatRevive'
     zfzapclass=Class'ZFloatZap'
     zfzapminiclass=Class'ZFloatZapMini'
     GenAnimSpeed=1.000000
     DefAnimSpeed=1.000000
     ZapSound=Sound'AWSoundFX.Level.ThunderQuick'
     StumpBloodClass=Class'StumpBlood'
     SeverBone(0)="MALE01 L UpperArm"
     SeverBone(1)="MALE01 L Forearm"
     SeverBone(2)="MALE01 R UpperArm"
     SeverBone(3)="MALE01 R Forearm"
     SeverBone(4)="MALE01 L Thigh"
     SeverBone(5)="MALE01 L Calf"
     SeverBone(6)="MALE01 R Thigh"
     SeverBone(7)="MALE01 r calf"
     BoneArr(0)=1
     BoneArr(1)=1
     BoneArr(2)=1
     BoneArr(3)=1
     BoneArr(4)=1
     BoneArr(5)=1
     BoneArr(6)=1
     BoneArr(7)=1
     TimeTillDissolve=15.000000
     bCheapBloodSpouts=True
     bZombie=True
     HeadClass=Class'ZombieHead'
     BodyHitSounds(0)=Sound'MiscSounds.People.bodyhitground1'
     BodyHitSounds(1)=Sound'MiscSounds.People.bodyhitground2'
     Cajones=1.000000
     Twitch=5.000000
     Conscience=0.000000
     PainThreshold=1.000000
     bGunCrazy=True
     TwitchFar=5.000000
     dialogclass=Class'DialogZombie'
     HealthMax=80.000000
     AttackRange=(Min=120.000000)
     DeathCrawlingPct=0.100000
     DeathCrawlRotationRate=(Yaw=25000)
     WalkingPct=0.150000
     MovementAnims(0)="z_walk1"
     MovementAnims(1)="z_walk1"
     MovementAnims(2)="z_walk1"
     MovementAnims(3)="z_walk1"
     TurnLeftAnim="z_walk1"
     TurnRightAnim="z_walk1"
	RandomizedBoltons(0)=None
	bNoChamelBoltons=True

	// ED Zombie Skins
	Skins(0)=Texture'AW7_EDZombies.Misc.XX__142__Fem_SS_Shorts'
	Mesh=SkeletalMesh'AW7Characters.Avg_Zombie'
	ChameleonMeshPkgs(0)="Characters"
	ChameleonSkins(00)="AW7_EDZombies.Bodies_Female.FM__042__Fem_LS_Skirt"
	ChameleonSkins(01)="AW7_EDZombies.Bodies_Female.FM__043__Fem_LS_Skirt"
	ChameleonSkins(02)="AW7_EDZombies.Bodies_Female.FM__044__Fem_LS_Skirt"
	ChameleonSkins(03)="AW7_EDZombies.Bodies_Female.FM__045__Fem_LS_Skirt"
	ChameleonSkins(04)="AW7_EDZombies.Bodies_Female.FM__046__Fem_LS_Skirt"
	ChameleonSkins(05)="AW7_EDZombies.Bodies_Female.FM__047__Fem_SS_Shorts"
	ChameleonSkins(6)="AW7_EDZombies.Bodies_AW.MW__207__Avg_M_SS_Pants"
	ChameleonSkins(07)="AW7_EDZombies.Bodies_Female.FM__049__Fem_LS_Pants"
	ChameleonSkins(08)="AW7_EDZombies.Bodies_Female.FM__050__Fem_LS_Pants"
	ChameleonSkins(09)="AW7_EDZombies.Bodies_Female.FM__051__Fem_LS_Pants"
	ChameleonSkins(10)="AW7_EDZombies.Bodies_Female.FM__052__Fem_LS_Pants"
	ChameleonSkins(11)="AW7_EDZombies.Bodies_Female.FM__053__Fem_LS_Skirt"
	ChameleonSkins(12)="AW7_EDZombies.Bodies_Female.FM__095__Fem_SS_Shorts"
	ChameleonSkins(13)="AW7_EDZombies.Bodies_Female.FW__032__Fem_LS_Pants"
	ChameleonSkins(14)="AW7_EDZombies.Bodies_Female.FW__033__Fem_LS_Pants"
	ChameleonSkins(15)="AW7_EDZombies.Bodies_Female.FW__034__Fem_LS_Pants"
	ChameleonSkins(16)="AW7_EDZombies.Bodies_AW.MW__205__Avg_M_SS_Pants"
	ChameleonSkins(17)="AW7_EDZombies.Bodies_Female.FW__036__Fem_LS_Skirt"
	ChameleonSkins(18)="AW7_EDZombies.Bodies_Female.FW__037__Fem_LS_Skirt"
	ChameleonSkins(19)="AW7_EDZombies.Bodies_Female.FW__038__Fem_LS_Skirt"
	ChameleonSkins(20)="AW7_EDZombies.Bodies_Female.FW__039__Fem_LS_Skirt"
	ChameleonSkins(21)="AW7_EDZombies.Bodies_Female.FW__040__Fem_LS_Skirt"
	ChameleonSkins(22)="AW7_EDZombies.Bodies_Female.FW__041__Fem_LS_Skirt"
	ChameleonSkins(23)="AW7_EDZombies.Bodies_Male.MM__002__Avg_M_Jacket_Pants"
	ChameleonSkins(24)="AW7_EDZombies.Bodies_Male.MM__003__Avg_M_Jacket_Pants"
	ChameleonSkins(25)="AW7_EDZombies.Bodies_Male.MM__004__Avg_M_SS_Pants"
	ChameleonSkins(26)="AW7_EDZombies.Bodies_Male.MM__005__Avg_M_SS_Pants"
	ChameleonSkins(27)="AW7_EDZombies.Bodies_Male.MM__006__Avg_M_SS_Pants"
	ChameleonSkins(28)="AW7_EDZombies.Bodies_Male.MM__007__Avg_M_SS_Pants"
	ChameleonSkins(29)="AW7_EDZombies.Bodies_Male.MM__008__Avg_M_SS_Pants"
	ChameleonSkins(30)="AW7_EDZombies.Bodies_AW.MW__204__Avg_M_SS_Pants"
	ChameleonSkins(31)="AW7_EDZombies.Bodies_Male.MM__010__Avg_Dude"
	ChameleonSkins(32)="AW7_EDZombies.Bodies_Male.MM__011__Avg_Dude"
	ChameleonSkins(33)="AW7_EDZombies.Bodies_Male.MM__012__Avg_M_SS_Pants"
	ChameleonSkins(34)="AW7_EDZombies.Bodies_Male.MM__013__Avg_M_SS_Pants"
	ChameleonSkins(35)="AW7_EDZombies.Bodies_AW.MW__203__Avg_M_Jacket_Pants"
	ChameleonSkins(36)="AW7_EDZombies.Bodies_AW.MW__202__Avg_M_Jacket_Pants"
	ChameleonSkins(37)="AW7_EDZombies.Bodies_Male.MM__018__Avg_M_Jacket_Pants"
	ChameleonSkins(38)="AW7_EDZombies.Bodies_Male.MM__052__Avg_M_SS_Pants"
	ChameleonSkins(39)="AW7_EDZombies.Bodies_Male.MM__061__Avg_M_SS_Shorts"
	ChameleonSkins(40)="AW7_EDZombies.Bodies_Male.MM__090__Big_M_LS_Pants"
	ChameleonSkins(41)="AW7_EDZombies.Bodies_AW.FW__201__Fem_LS_Skirt"
	ChameleonSkins(42)="AW7_EDZombies.Bodies_AW.FW__208__Fem_LS_Pants"
	ChameleonSkins(43)="AW7_EDZombies.Bodies_AW.MM__206__Avg_Dude"
	ChameleonSkins(44)="AW7_EDZombies.Bodies_Male.MW__016__Avg_Dude"
	ChameleonSkins(45)="AW7_EDZombies.Bodies_Male.MW__017__Avg_Dude"
	ChameleonSkins(46)="AW7_EDZombies.Bodies_Male.MW__018__Avg_M_Jacket_Pants"
	ChameleonSkins(47)="AW7_EDZombies.Bodies_Male.MW__019__Avg_M_Jacket_Pants"
	ChameleonSkins(48)="AW7_EDZombies.Bodies_Male.MW__020__Avg_M_Jacket_Pants"
	ChameleonSkins(49)="AW7_EDZombies.Bodies_Male.MW__021__Avg_M_SS_Pants"
	ChameleonSkins(50)="AW7_EDZombies.Bodies_Male.MW__022__Avg_M_SS_Pants"
	ChameleonSkins(51)="AW7_EDZombies.Bodies_Male.MW__023__Avg_M_SS_Pants"
	ChameleonSkins(52)="AW7_EDZombies.Bodies_Male.MW__024__Avg_M_SS_Pants"
	ChameleonSkins(53)="AW7_EDZombies.Bodies_Male.MW__025__Avg_M_SS_Pants"
	ChameleonSkins(54)="AW7_EDZombies.Bodies_Male.MW__026__Avg_M_SS_Pants"
	ChameleonSkins(55)="AW7_EDZombies.Bodies_AW.FW__200__Fem_LS_Pants"
	ChameleonSkins(56)="AW7_EDZombies.Bodies_Male.MW__028__Big_M_LS_Pants"
	ChameleonSkins(57)="AW7_EDZombies.Bodies_Male.MW__029__Big_M_LS_Pants"
	ChameleonSkins(58)="End"
	
	HeadMesh=SkeletalMesh'AW_Heads.AW_Zombie'
	ChamelHeadSkins(00)="AW7_EDZombies.Heads_Female.FMA__080__FemSHcropped"
	ChamelHeadSkins(01)="AW7_EDZombies.Heads_Female.FMA__081__FemLH"
	ChamelHeadSkins(02)="AW7_EDZombies.Heads_Female.FMA__082__FemSH"
	ChamelHeadSkins(03)="AW7_EDZombies.Heads_Female.FMA__083__FemSH"
	ChamelHeadSkins(04)="AW7_EDZombies.Heads_Female.FMA__084__FemSH"
	ChamelHeadSkins(05)="AW7_EDZombies.Heads_Female.FMA__085__FemSH"
	ChamelHeadSkins(06)="AW7_EDZombies.Heads_Female.FMA__086__FemSHcropped"
	ChamelHeadSkins(07)="AW7_EDZombies.Heads_Female.FMA__087__FemSHcropped"
	ChamelHeadSkins(08)="AW7_EDZombies.Heads_Female.FMA__088__FemSH"
	ChamelHeadSkins(09)="AW7_EDZombies.Heads_AW.MWA__212__AvgMale"
	ChamelHeadSkins(10)="AW7_EDZombies.Heads_Female.FWA__090__FemSH"
	ChamelHeadSkins(11)="AW7_EDZombies.Heads_Female.FWA__091__FemSH"
	ChamelHeadSkins(12)="AW7_EDZombies.Heads_Female.FWA__092__FemLH"
	ChamelHeadSkins(13)="AW7_EDZombies.Heads_Male.MBA__013__AvgBrotha"
	ChamelHeadSkins(14)="AW7_EDZombies.Heads_Male.MBA__014__AvgBrotha"
	ChamelHeadSkins(15)="AW7_EDZombies.Heads_Male.MMA__003__AvgMale"
	ChamelHeadSkins(16)="AW7_EDZombies.Heads_Male.MMA__016__AvgMale"
	ChamelHeadSkins(17)="AW7_EDZombies.Heads_Male.MMA__054__AvgMale"
	ChamelHeadSkins(18)="AW7_EDZombies.Heads_Male.MMA__055__AvgMale"
	ChamelHeadSkins(19)="AW7_EDZombies.Heads_Male.MMA__056__AvgMale"
	ChamelHeadSkins(20)="AW7_EDZombies.Heads_Male.MMA__057__AvgMale"
	ChamelHeadSkins(21)="AW7_EDZombies.Heads_Male.MMA__058__AvgMale"
	ChamelHeadSkins(22)="AW7_EDZombies.Heads_Male.MMA__059__AvgMale"
	ChamelHeadSkins(23)="AW7_EDZombies.Heads_Male.MMA__060__AvgMale"
	ChamelHeadSkins(24)="AW7_EDZombies.Heads_Male.MMA__061__AvgMale"
	ChamelHeadSkins(25)="AW7_EDZombies.Heads_Male.MMA__062__AvgMale"
	ChamelHeadSkins(26)="AW7_EDZombies.Heads_Male.MMA__063__AvgMale"
	ChamelHeadSkins(27)="AW7_EDZombies.Heads_Male.MMA__064__AvgMale"
	ChamelHeadSkins(28)="AW7_EDZombies.Heads_Male.MMA__065__AvgMale"
	ChamelHeadSkins(29)="AW7_EDZombies.Heads_Male.MWA__066__AvgMale"
	ChamelHeadSkins(30)="AW7_EDZombies.Heads_Male.MWA__067__AvgMale"
	ChamelHeadSkins(31)="AW7_EDZombies.Heads_Male.MWA__068__AvgMale"
	ChamelHeadSkins(32)="AW7_EDZombies.Heads_Male.MWA__069__AvgMale"
	ChamelHeadSkins(33)="AW7_EDZombies.Heads_Male.MWA__070__AvgMale"
	ChamelHeadSkins(34)="AW7_EDZombies.Heads_Male.MWA__071__AvgMale"
	ChamelHeadSkins(35)="AW7_EDZombies.Heads_Male.MWA__072__AvgMale"
	ChamelHeadSkins(36)="AW7_EDZombies.Heads_Male.MWA__073__AvgMale"
	ChamelHeadSkins(37)="AW7_EDZombies.Heads_Male.MWA__074__AvgMale"
	ChamelHeadSkins(38)="AW7_EDZombies.Heads_Male.MWA__075__AvgMale"
	ChamelHeadSkins(39)="AW7_EDZombies.Heads_Male.MWA__076__AvgMale"
	ChamelHeadSkins(40)="AW7_EDZombies.Heads_Male.MWA__077__AvgMale"
	ChamelHeadSkins(41)="AW7_EDZombies.Heads_AW.MWA__214__AvgMale"
	ChamelHeadSkins(42)="AW7_EDZombies.Heads_AW.MWA__216__AvgMale"
	ChamelHeadSkins(43)="AW7_EDZombies.Heads_AW.FWA__200__FemSH"
	ChamelHeadSkins(44)="AW7_EDZombies.Heads_AW.FWA__201__FemSH"
	ChamelHeadSkins(45)="AW7_EDZombies.Heads_AW.FWA__202__FemSH"
	ChamelHeadSkins(46)="AW7_EDZombies.Heads_AW.FWA__203__FemSH"
	ChamelHeadSkins(47)="AW7_EDZombies.Heads_AW.FWA__204__FemSHcropped"
	ChamelHeadSkins(48)="AW7_EDZombies.Heads_AW.MMA__213__AvgMale"
	ChamelHeadSkins(49)="AW7_EDZombies.Heads_AW.MMA__215__AvgMale"
	ChamelHeadSkins(50)="AW7_EDZombies.Heads_AW.MWA__205__AvgMale"
	ChamelHeadSkins(51)="AW7_EDZombies.Heads_AW.MWA__206__AvgMale"
	ChamelHeadSkins(52)="AW7_EDZombies.Heads_AW.MWA__207__AvgMale"
	ChamelHeadSkins(53)="AW7_EDZombies.Heads_AW.MWA__208__AvgMale"
	ChamelHeadSkins(54)="AW7_EDZombies.Heads_AW.MWA__209__AvgMale"
	ChamelHeadSkins(55)="AW7_EDZombies.Heads_AW.MWA__210__AvgMale"
	ChamelHeadSkins(56)="AW7_EDZombies.Heads_AW.MWA__211__AvgMale"
	ChamelHeadSkins(57)="End"
	ChamelHeadMeshPkgs(0)="heads"
	Airspeed=1200
	bCellUser=False
	ExtraAnims(10)=MeshAnimation'AW7Characters.MoreZombieAnims'
}
