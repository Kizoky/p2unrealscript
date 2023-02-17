///////////////////////////////////////////////////////////////////////////////
// PLMikeJ
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Mike J in all his jewcow glory.
// This is an "invincible" version of Mike J intended only for cutscenes -
// use PLCowBossPawn for the actual enemy version.
///////////////////////////////////////////////////////////////////////////////
class PLMikeJ extends PersonPawn
	placeable
	hidecategories(Boltons,Cell,Character,Police);

// FIXME a huge amount of this was c/p'd from the AW cowboss. Need to remove
// boss features like leaving fire trails everywhere etc

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const SHAKE_CAMERA_BIG = 350;
const SHAKE_CAMERA_MED = 250;
const MIN_MAG_FOR_SHAKE = 20;
const MAX_SHAKE_DIST	= 2000.0;

const STEP_FIRE_OFFSET	=	-25;

const BONE_LEFTFOOT		=	'Bip01 L Toe0';
const BONE_RIGHTFOOT	=	'Bip01 R Toe0';
const BONE_MOUTH		=	'Bip01 Head';
const BONE_LEFTHAND		=	'Bip01 L Hand';
const BONE_RIGHTHAND	=	'Bip01 R Hand';
const BONE_UTTER1		=	'Dummy03';	// utter1
const BONE_UTTER2		=	'Dummy05';	// utter2
const BONE_UTTER3		=	'Dummy04';	// utter3
const BONE_UTTER4		=	'Dummy06';	// utter4

const MOUTH_DIST		=	60;
const HEAD_LAUNCH_SPEED	=	300;
const SPARK_SND_RADIUS	=	800;
const DEFAULT_SQUIRT_DIST= 400;

// Don't fully understand channel usage yet, other than knowing that channels 2
// through 11 are used by the engine's movement code, which is where the
// commented-out values came from.  Channel's 4 through 7 roughly correspond
// to the values in the MovementAnims[] array.  See UpdateMovementAnimation().
const RESTINGPOSECHANNEL = 0;
const FALLINGCHANNEL = 1;
const MOVEMENTCHANNEL = 2;
//
const TAKEHITCHANNEL = 12;
const FIRINGCHANNEL = 13;

const CB_CHARGE = 'cb_walk';

function SetupHead()
{
	Super.SetupHead();
	
	// Krotchy doesn't really want a head, so scale the head way down so it isn't seen
	if (myHead != None)
	{
		myHead.SetDrawScale(0.1);
		MyHead.bHidden = true;
	}
}

// Stub out all damage.
function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType);

///////////////////////////////////////////////////////////////////////////////
// Handle end of animation on specified channel
///////////////////////////////////////////////////////////////////////////////
simulated event AnimEnd(int Channel)
{
	if ( Channel == TAKEHITCHANNEL )
		AnimBlendToAlpha(TAKEHITCHANNEL,0,0.1);
//	else
//		PlayMoving();
}

///////////////////////////////////////////////////////////////////////////////
//
// Private animation functions for this animal in particular.
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
// stand
// gore
// buck
// idle
// die
// run
// charge
// walk
// strole
//
///////////////////////////////////////////////////////////////////////////////

/*
simulated function name GetAnimCharge()
{
	return 'cb_charge';
}

simulated function name GetAnimFinishCharge()
{
	return 'cb_charge';
}

simulated function name GetAnimStand()
{
	return 'cb_idle';
}

simulated function name GetAnimSpitHead()
{
	return 'cb_spit_head';
}

simulated function name GetAnimWalk()
{
	return 'cb_walk';
}

simulated function name GetAnimRun()
{
	return 'cb_charge';
}

simulated function name GetAnimLaugh()
{
	return 'cb_laugh';
}

simulated function name GetAnimLeftShoot()
{
	return 'cb_left_throw';
}

simulated function name GetAnimRightShoot()
{
	return 'cb_right_throw';
}

simulated function name GetAnimTeatShoot()
{
	return 'cb_uttershoot';
}
*/

/*
simulated function name GetAnimKick()
{
	return 'backkick';
}
*/


simulated function name GetAnimDeath()
{
	return 'cb_die';
}

simulated function SetupAnims()
{
	// Make sure to blend all this channel in, ie, always play all of this channel when not 
	// playing something else, because this is the main movement channel
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim(GetAnimStand(), 1.0, 0.15, MOVEMENTCHANNEL);
}

/*
simulated function SetAnimStanding()
{
	LoopAnim(GetAnimStand(), 1.0, 0.15);//, MOVEMENTCHANNEL);
}

simulated function SetAnimWalking()
{
	GroundSpeed = default.GroundSpeed;
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim(GetAnimWalk(), 1.0, 0.15, MOVEMENTCHANNEL);// + FRand()*0.4);
}


simulated function SetAnimRunning()
{
	local name runanim;

	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	if(!bCharging)
	{
		GroundSpeed = default.GroundSpeed;
		runanim = GetAnimRun();
	}
	else
	{
		GroundSpeed = ChargeGroundSpeed;
		runanim = GetAnimCharge();
	}
	LoopAnim(runanim, 4.0, 0.15, MOVEMENTCHANNEL);
}


// PLAY THESE on the default channel
function PlayAnimStanding()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStand(), 1.0, 0.2);
}

function PlayAnimSpitHead()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimSpitHead(), GenAnimSpeed, 0.2);
}

function PlayAnimLeftShoot()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimLeftShoot(), GenAnimSpeed, 0.2);
}

function PlayAnimLaughing()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimLaugh(), 1.0, 0.2);
}

function PlayAnimRightShoot()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimRightShoot(), GenAnimSpeed, 0.2);
}

function PlayAnimTeatShoot()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimTeatShoot(), GenAnimSpeed, 0.2);
}
*/

/*
function PlayAnimKick()
{
	log(Self$" anim kick ");
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimKick(), 1.0, 0.2);
}
*/
function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	Say(myDialog.lSpitting, true);
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	AnimBlendParams(TAKEHITCHANNEL,0.0);
	PlayAnim(GetAnimDeath(), 1.4, 0.15);	// TEMP!  Speed up dying animation!
}

function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	local float BlendAlpha, BlendTime;

	// Don't do anything with these damages
	if(ClassIsChildOf(damageType, class'BurnedDamage')
		|| damageType == class'OnFireDamage'
		|| ClassIsChildOf(damageType, class'AnthDamage'))
		return;

	// blend in a hit
	BlendAlpha = 0.2;
	BlendTime=0.2;

	AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
	// Pick a cowboss anim to blend to
	switch(Rand(3))
	{
		case 0:
			TweenAnim(GetAnimStand(),0.1,TAKEHITCHANNEL);
			break;
		case 1:
			TweenAnim('cb_takehit1',0.1,TAKEHITCHANNEL);
			break;
		case 2:
			TweenAnim('cb_takehit2',0.1,TAKEHITCHANNEL);
			break;
	}

	Super.PlayTakeHit(HitLoc,Damage,damageType);
}

//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Anims
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
simulated function name GetAnimStand()
{
	return 'cb_idle';
}
simulated function name GetAnimClimb()
{
	return 'cb_walk';
}
simulated function name GetAnimKick() // a low kick (aimed at a prone body)
{
	return 'cb_right_throw';
}
simulated function name GetAnimShocked() // electrocuted by a Shocker
{
	return 'cb_takehit1';
}
simulated function name GetAnimDazed()
{
	return 'cb_takehit2';
}
simulated function name GetAnimKickedInTheBalls()
{
	return 'cb_takehit2';
}
simulated function name GetAnimClapping()
{
	return 'cb_laugh';
}
simulated function name GetAnimDancing()
{
	return 'cb_uttershoot';
}
simulated function name GetAnimLaugh()
{
	return 'cb_laugh';
}
simulated function name GetAnimTellThemOff()
{
	return 'cb_spit_head';
}
simulated function name GetAnimFlipThemOff()
{
	return 'cb_spit_head';
}
simulated function name GetAnimRestStanding()
{
	return 'cb_idle';
}
simulated function name GetAnimIdle()
{
	return 'cb_idle';
}
simulated function name GetAnimIdleQ()
{
	return 'cb_idle';
}
simulated function PlayMoving()
{
	if ((Physics == PHYS_None) || ((Controller != None) && Controller.bPreparingMove) )
	{
		// Controller is preparing move - not really moving
		PlayWaiting();
	}
	else if (bIsWalking)
		SetAnimWalking();
	else
		SetAnimRunning();
}	
simulated function SetAnimStanding()
{
	LoopIfNeeded(GetAnimStand(), 1.0);
}
simulated function SetAnimWalking()
{
	TurnLeftAnim = 'cb_walk';
	TurnRightAnim = 'cb_walk';
	MovementAnims[0] = 'cb_walk';
	MovementAnims[1] = 'cb_walk';
	MovementAnims[2] = 'cb_walk';
	MovementAnims[3] = 'cb_walk';
}
simulated function SetAnimRunning()
{
	TurnLeftAnim = CB_CHARGE;
	TurnRightAnim = CB_CHARGE;
	MovementAnims[0] = CB_CHARGE;
	MovementAnims[1] = CB_CHARGE;
	MovementAnims[2] = CB_CHARGE;
	MovementAnims[3] = CB_CHARGE;
}
// Cannot crouch or deathcrawl
simulated function SetAnimStartCrouching();
simulated function SetAnimCrouching();
simulated function SetAnimEndCrouching();
simulated function SetAnimCrouchWalking();
simulated function SetAnimStartDeathCrawling();
simulated function SetAnimEndDeathCrawling();
simulated function SetAnimDeathCrawlWait();
simulated function SetAnimStartKnockOut();
simulated function SetAnimEndKnockOut();
simulated function SetAnimKnockedOut();
simulated function SetAnimDeathCrawling();
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorID="PLMikeJ"

	RicHit(0)=Sound'WeaponSounds.bullet_ricochet1'
	RicHit(1)=Sound'WeaponSounds.bullet_ricochet2'
	dialogclass=Class'AWPawns.DialogCowBoss'
	VoicePitch=1.000000
	TakeDamageModifier=0.200000
	HealthMax=99999.000000
	AttackRange=(Min=300.000000,Max=2048.000000)
	WalkingPct=0.250000
	ControllerClass=Class'BystanderController'
	LODBias=3.000000
	Mesh=SkeletalMesh'AWCharacters.CowBoss'
	TransientSoundRadius=400.000000
	CollisionRadius=120.000000
	CollisionHeight=200.000000
	Mass=400.000000
	RotationRate=(Pitch=4096,Yaw=40000,Roll=3072)
	Gang="ZombieGang"
	Skins[0]=Texture'AW_Characters.Special.Cow_Boss_Head'
	Skins[1]=Texture'AW_Characters.Special.Cow_Boss_Head'
	Skins[2]=Texture'AW_Characters.Special.Cow_Boss_Skin'
	bChameleon=false
	CullDistance=0
	bCanCrouch=false
	bNoDismemberment=True
	bHeadCanComeOff=false
	bStartupRandomization=false
	bRandomizeHeadScale=false
	bPersistent=true
	bHasRef=false
	bKeepForMovie=true
	bCanTeleportWithPlayer=false
	bPlayerIsFriend=true
	FriendDamageThreshold=99999
	Psychic=1.0
	Champ=0.9
	Cajones=1.0
	Temper=1.0
	Glaucoma=0.4
	Twitch=1.0
	TwitchFar=3.0
	Rat=0.1
	Compassion=0.0
	WarnPeople=0.0
	Conscience=0.0
	Beg=0.0
	PainThreshold=1.0
	Reactivity=0.5
	Confidence=1.0
	Rebel=1.0
	Curiosity=0.5
	Patience=0.5
	WillDodge=0.1
	WillKneel=0.05
	WillUseCover=0.1
	Talkative=0.2
	Stomach=1.0
	VoicePitch=1.0
	TalkWhileFighting=0.4
	TalkBeforeFighting=1.0
	TakesShotgunHeadShot=	0.25
	TakesRifleHeadShot=		0.25
	TakesShovelHeadShot=	0.25
	TakesPistolHeadShot=	0.25
	TakesMachinegunDamage=	0.5
	TakesOnFireDamage=		0.5
	TakesAnthraxDamage=		0.0
	TakesShockerDamage=		0.0
	TakesChemDamage=		0.0
	TakesSledgeDamage = 	0.25
	TakesMacheteDamage =	0.25
	TakesScytheDamage =		0.25
	TakesDervishDamage =	0.5
    AW_SPMeshAnim=None
	ExtraAnims(0)=None
	ExtraAnims(1)=None
	ExtraAnims(2)=None
	ExtraAnims(3)=None
	ExtraAnims(4)=None
	ExtraAnims(5)=None
	ExtraAnims(6)=None
	AmbientGlow=30
	bCellUser=false
}
