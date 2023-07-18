///////////////////////////////////////////////////////////////////////////////
// AWCowBossPawn for Postal 2 AW
//
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWCowBossPawn extends AnimalPawn
	placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var bool bCharging;		// if we're charging while running, with our head down
var float ChargeGroundSpeed;	// How fast we run as charging (not just normal running)
var class<P2Emitter> ChargeDustClass;
var class<CowFinishDust> FinishDustClass;
var P2Emitter ChargingDust;
var class<DamageType> MyChargeDamage;	// Type of damage we inflict

var Sound DieMoo;
var Sound ChargingSound;
var Sound SquirtSound;

var class<GaryHeadOrbit> orbitheadclass;
var array<GaryHeadOrbit> orbitheads;	// heads orbiting me to protect me

var vector EyeOffset;			// offset above me from where the great eye exists and protects me
var AWBossEye GreatEye;			// watches over me
var float ZapFactor;			// how much closer to get to the dude from the zap damage
var Sound RicHit[2];								// Ricochet noises.
var class<SparkHitMachineGun> sparkclass;

// System to tell boss about incoming rockets/grenades
// Touch cyclinder attaches to boss and tells him when things touch it, it's bigger than he is so
// they hit this first
var class<BossEarlyCheck> earlyclass;	
var BossEarlyCheck earlycheck;

var class<P2Emitter> firefootclass, firestepclass;
var P2Emitter ffootleft, ffootright;

var float AbsorbDamage;
var float AbsorbLimit;

var class<GaryHeadProjectile> GStraightHeadClass;		// class of heads thrown at dude that fly straight
var class<GaryHeadProjectile> GHomingHeadClass;			// class that seeks
var class<P2Emitter> StraightBurnClass;				// fire class that burns in his hand before he throws straight
var class<P2Emitter> HomingBurnClass;				// fire class that burns in his hand before he throws homing
var class<BossMilkProjectile> BossMilkClass;	// projectile shot from teat

var float SquirtSpeedMin;		// Minimum speed of milk squirt
var float SquirtSpeedMax;		// Maximum speed of milk squirt

// Dialog
var class<P2Dialog> DialogClass;	// Dialog class to use
var P2Dialog myDialog;				// Reference to current dialog object
var float VoicePitch;
var float GenAnimSpeed;

// xPatch:
var() bool bFireFootsteps;

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

const DEFAULT_FUCKING_HEALTH	= 5000;		// I just can't... if someone's reading this, please help me. ~Piotr S. aka Man Chrzan
const DIFF_CHANGE_HEALTH	= 0.1;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
	// Make early check system
	if(earlyclass != None)
	{
		earlycheck = spawn(earlyclass, self, , Location);
		earlycheck.SetBase(self);
	}
	// Make fire on his feet
	if(firefootclass != None)
	{
		if(ffootleft == None)
			ffootleft = spawn(firefootclass, self);
		if(ffootright == None)
			ffootright = spawn(firefootclass, self);
		AttachToBone(ffootleft, BONE_LEFTFOOT);
		AttachToBone(ffootright, BONE_RIGHTFOOT);
	}

	SetupDialog();
	SetupDifficulty(False);
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: So the Health and HealthMax often aren't matching if its done 
// via the Controller and some weird shit happens with it. I have no fucking 
// clue why it works so abnormally. Moved here, hopefully it will work now.
///////////////////////////////////////////////////////////////////////////////
function SetupDifficulty(bool bPostLoad)
{
	local float gamediff, diffoffset;
	local float NewHealth;
	local bool bLudicrousHealth;
	
	gamediff = P2GameInfo(Level.Game).GetGameDifficulty();
	diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();
	
	// Since we do not have Crackola, Nuke and such make things a bit more fair. 
	if(P2GameInfoSingle(Level.Game).InLudicrousDifficulty()
		&& P2GameInfoSingle(Level.Game).InClassicMode())
	{
		// diffoffset 10 is Ludicrous
		// diffoffset 5 is Heston to Impossible, the normal maximum
		if(diffoffset > 5)
			diffoffset=5;
	}
	
	//Log(self@"Game Difficulty:"@gamediff@"|"@"Difficulty Offset:"@diffoffset);
	//Log(self@"Health:"@Health);
	//Log(self@"HealthMax:"@HealthMax);	
	
	// Just to be safe check if it's not more than ususal
	if(diffoffset != 0 && HealthMax == DEFAULT_FUCKING_HEALTH)
	{
		NewHealth = HealthMax += (diffoffset*HealthMax*DIFF_CHANGE_HEALTH);
		HealthMax = NewHealth;
		
		if(!bPostLoad)
			Health = NewHealth;
			
		if(P2GameInfoSingle(Level.Game).InLudicrousDifficulty())
			bFireFootsteps = true;
			
		//Log(self@"NEW HealthMax:"@HealthMax);
		//Log(self@"NEW Health:"@Health);
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Another fix, so apparently if we quit game to desktop and then
// load a save HealthMax sometimes gets fucked hard and our health bar gets 
// so long it doesn't fit on the screen lol, cuz it resets to default 5000...
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Super.PostLoadGame();
	SetupDifficulty(True);	
}

///////////////////////////////////////////////////////////////////////////////
// If I'm used for an errand, tell them I died
///////////////////////////////////////////////////////////////////////////////
function CheckForErrandCompleteOnDeath(Controller Killer)
{
	// Make sure the dude's still alive before triggering this.
	if(Killer != None
		&& Killer.Pawn != None
		&& Killer.Pawn.Health > 0)
		Super.CheckForErrandCompleteOnDeath(Killer);
}

///////////////////////////////////////////////////////////////////////////////
// Setup dialog
///////////////////////////////////////////////////////////////////////////////
function SetupDialog()
{
	if (P2GameInfo(Level.Game) != None)
	{
		myDialog = P2GameInfo(Level.Game).GetDialogObj(String(DialogClass));
		if (myDialog == None)
			Warn("Couldn't load dialog: "$String(DialogClass));
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
// Projectile approaching--tell the great eye!
///////////////////////////////////////////////////////////////////////////////
function ProjectileComing(Actor Other)
{
	if(GreatEye != None
		&& !GreatEye.bDeleteMe)
	{
		GreatEye.ZapActor(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Dervish or not, this cat is toast!
///////////////////////////////////////////////////////////////////////////////
function DervishComing(Actor Other)
{
	if(GreatEye != None
		&& !GreatEye.bDeleteMe)
	{
		GreatEye.ZapActor(Other);
	}
}


///////////////////////////////////////////////////////////////////////////////
// Swap out to our burned mesh
///////////////////////////////////////////////////////////////////////////////
function SwapToBurnVictim()
{
	// STUBBED out for the moment on cows
}

///////////////////////////////////////////////////////////////////////////////
// shake the camera from the heavy cow
///////////////////////////////////////////////////////////////////////////////
function ShakeCameraDistanceBased(float Mag)
{
	local controller con;
	local float usemag, usedist;

	for(con = Level.ControllerList; con != None; con=con.NextController)
	{
		// Find who did it first, then shake them
		if(con.bIsPlayer && Con.Pawn!=None
			&& Con.Pawn.Physics != PHYS_FALLING)
		{
			usedist = VSize(con.Pawn.Location - Location);		
			if(usedist > MAX_SHAKE_DIST)
				usedist = MAX_SHAKE_DIST;
			usemag = ((MAX_SHAKE_DIST - usedist)/MAX_SHAKE_DIST)*Mag;
			//log("use mag "$usemag);
			if(usemag < MIN_MAG_FOR_SHAKE)
				return;

			con.ShakeView((usemag * 0.2 + 1.0)*vect(1.0,1.0,3.0), 
               vect(1000,1000,1000),
               1.0 + usemag*0.02,
               (usemag * 0.3 + 1.0)*vect(1.0,1.0,2.0),
               vect(800,800,800),
               1.0 + usemag*0.02);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set to be infected. Cows never carry it,it just pisses them off
///////////////////////////////////////////////////////////////////////////////
function SetInfected(FPSPawn Doer)
{
	// STUB
}
/*
///////////////////////////////////////////////////////////////////////////////
// Set to start charge and do effects
///////////////////////////////////////////////////////////////////////////////
function BeginCharge()
{
	local vector usel;

	bCharging=true;
	if(ChargeDustClass != None)
	{
		ChargingDust = spawn(ChargeDustClass, self);
		//SetBase(ChargingDust);
		AttachToBone(ChargingDust, BUTT_BONE);
		usel.y = -CollisionRadius;
		ChargingDust.SetRelativeLocation(usel);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set to end charge run and stop those effects
///////////////////////////////////////////////////////////////////////////////
function EndCharge()
{
	bCharging=false;
	if(ChargingDust != None)
	{
		DetachFromBone(ChargingDust);
		ChargingDust.SelfDestroy();
		ChargingDust = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Wrap up charge with finish effects
///////////////////////////////////////////////////////////////////////////////
function FinishCharge()
{
	local CowFinishDust cfd;
	local vector useloc;

	if(FinishDustClass != None)
	{
		useloc = Location;
//		useloc.z -= CollisionRadius;
		cfd = spawn(FinishDustClass, self,,useloc);
		cfd.SetVel(FINISH_VEL*vector(Rotation));
	}
	// Play anim
	PlayAnimFinishCharge();
}
*/
/*
///////////////////////////////////////////////////////////////////////////////
// Play normal moo
///////////////////////////////////////////////////////////////////////////////
function PlayNormalMoo()
{
	PlaySound(CowNormalMoo[Rand(CowNormalMoo.Length)], SLOT_Talk,,,,GenPitch());
}
*/

///////////////////////////////////////////////////////////////////////////////
// Spark effects for a hit impact
///////////////////////////////////////////////////////////////////////////////
function SparkHit(vector HitLocation, vector Momentum, byte PlayRicochet)
{
	local SparkHitMachineGun spark1;

	if(sparkclass != None)
	{
		spark1 = Spawn(sparkclass,,,HitLocation);
		spark1.FitToNormal(-Normal(Momentum));
		if(PlayRicochet > 0)
			spark1.PlaySound(RicHit[Rand(ArrayCount(RicHit))],,255,,SPARK_SND_RADIUS,GetRandPitch());
	}
}

///////////////////////////////////////////////////////////////////////////////
// Eye blocks all damage as long as it exists
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local vector useloc;

	if(Controller == None)
		return;

	// if we have an eye, block the damage with it
	if(GreatEye != None)
	{
		if(ClassIsChildOf(damageType, class'BulletDamage')
			|| ClassIsChildOf(damageType, class'ExplodedDamage')
			|| ClassIsChildOf(damageType, class'BludgeonDamage'))
		{
			useloc = ZapFactor*(instigatedBy.Location - hitlocation) + hitlocation;
			GreatEye.BlastSpot(useloc, damageType);
			// Add in ricochet for bullets
			if(ClassIsChildOf(damageType, class'BulletDamage'))
				SparkHit(useloc, momentum, 1);
		}
		// Absorb damage and consider laughing at him
		if(AWCowBossController(Controller).DoCountAbsorbedDamage())
		{
			AbsorbDamage+=damage;
			if(AbsorbDamage >= AbsorbLimit)
			{
				AWCowBossController(Controller).LaughAtAttacker();
			}
		}
	}
	// Ignores fire damage--he's already on fire!
	else if(!ClassIsChildOf(damageType, class'OnFireDamage')
		&& !ClassIsChildOf(damageType, class'BurnedDamage')
		&& !ClassIsChildOf(damageType, class'AnthDamage'))
	{
		// ignore mass
		Super.TakeDamage(Damage, instigatedBy, hitlocation, vect(0,0,1), damageType);
		//log(self$" new health "$Health);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Reset absorb
///////////////////////////////////////////////////////////////////////////////
function ResetAbsorb()
{
	AbsorbDamage=0;
	AbsorbLimit+=AbsorbLimit;
}

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


simulated function SetAnimStanding()
{
	LoopAnim(GetAnimStand(), 1.0, 0.15);//, MOVEMENTCHANNEL);
}

simulated function SetAnimWalking()
{
	Super.SetAnimWalking();
	GroundSpeed = default.GroundSpeed;
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim(GetAnimWalk(), 1.0, 0.15, MOVEMENTCHANNEL);// + FRand()*0.4);
}


simulated function SetAnimRunning()
{
	local name runanim;

	Super.SetAnimRunning();
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
	// Get rid of foot fires on death
	if(ffootright != None)
	{
		ffootright.SelfDestroy();
		ffootright=None;
	}
	if(ffootleft != None)
	{
		ffootleft.SelfDestroy();
		ffootleft=None;
	}
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

///////////////////////////////////////////////////////////////////////////////
// hurt stuff on this side of me.
///////////////////////////////////////////////////////////////////////////////
function HurtThings(vector HitPos, vector HitMomentum, float Rad, float DamageAmount)
{
	local Actor HitActor;
	local FPSPawn CheckP;
	local float usedam;

	ForEach CollidingActors(class'Actor', HitActor, Rad, HitPos)
	{
		if(HitActor != self
			&& FastTrace(HitPos, HitActor.Location))
		{
			// Kill normal bystander types instantly, the dude, cops, special
			// other characters and such, we just hurt some
			CheckP = FPSPawn(HitActor);
			if(CheckP != None
				&& CheckP.Health > 0
				&& !(CheckP.bPlayer
					|| CheckP.IsA('AuthorityFigure')
					|| CheckP.bPersistent))
				usedam = CheckP.Health;
			else
				usedam = DamageAmount;

			HitActor.TakeDamage(usedam, 
								self, HitActor.Location, HitMomentum, MyChargeDamage);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add orbiting head
//////////////////////////////////////////////////////////////////////////////
function SpawnOrbitHead()
{
	local coords usecoords;
	local vector useloc;
	local GaryHeadOrbit ghead;

	if(orbitheadclass != None)
	{
		usecoords = GetBoneCoords(BONE_MOUTH);
		useloc = usecoords.Origin + MOUTH_DIST*vector(Rotation);
		ghead = spawn(orbitheadclass, self, , useloc);
		ghead.PrepVelocity(HEAD_LAUNCH_SPEED*vector(Rotation));
		orbitheads.Insert(orbitheads.Length, 1);
		orbitheads[orbitheads.Length-1] = ghead;
		AWCowBossController(Controller).MadeHead();
	}
}
function RemoveOrbitHead(GaryHeadOrbit ghead)
{
	local int i;

	for(i=0; i<orbitheads.Length; i++)
	{
		if(orbitheads[i] != None
			&& orbitheads[i] == ghead)
		{
			orbitheads.Remove(i, 1);
			break;
		}
	}
	if(orbitheads.Length <= 0)
		AWCowBossController(Controller).NeedMoreHeads();
}

//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Notifies
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Make a gary head
//////////////////////////////////////////////////////////////////////////////
function Notify_SpitHead()
{
	Say(myDialog.lSpitting);
	SpawnOrbitHead();
}

//////////////////////////////////////////////////////////////////////////////
// Leave foot fires
//////////////////////////////////////////////////////////////////////////////
function Notify_StepLeft()
{
	local coords usecoords;
	local vector useloc;
	
	// xPatch: this Notify_ was not included in animations before.
	// Added it back BUT it will be only used for Ludicrous difficulty.
	if(bFireFootsteps)
	{
		if(firestepclass != None
			&& Controller != None
			&& !Controller.bDeleteMe
			&& Controller.IsInState('LegMotionToTarget'))
		{
			usecoords = GetBoneCoords(BONE_LEFTFOOT);
			useloc = usecoords.origin;
			useloc.z+=STEP_FIRE_OFFSET;
			spawn(firestepclass, self, , useloc);
		}
	}
}
function Notify_StepRight()
{
	local coords usecoords;
	local vector useloc;

	// xPatch: this Notify_ was not included in animations before.
	// Added it back BUT it will be only used for Ludicrous difficulty.
	if(bFireFootsteps)
	{
		if(firestepclass != None
			&& Controller != None
			&& !Controller.bDeleteMe
			&& Controller.IsInState('LegMotionToTarget'))
		{
			usecoords = GetBoneCoords(BONE_RIGHTFOOT);
			useloc = usecoords.origin;
			useloc.z+=STEP_FIRE_OFFSET;
			spawn(firestepclass, self, , useloc);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Just before it gets thrown he makes a fire in his hand
///////////////////////////////////////////////////////////////////////////////
function Notify_FormLeft()
{
	local coords usecoords;
	local P2Emitter handfire;
	
	if(StraightBurnClass != None)
	{
		usecoords = GetBoneCoords(BONE_LEFTHAND);
		handfire= spawn(StraightBurnClass, self, , usecoords.origin);
		AttachToBone(handfire, BONE_LEFTHAND);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Throws straight-shot burning gary heads
///////////////////////////////////////////////////////////////////////////////
function Notify_ThrowLeft()
{
	local GaryHeadProjectile ghead;
	local coords usecoords;
	local vector useloc;

	if(GStraightHeadClass != None)
	{
		usecoords = GetBoneCoords(BONE_LEFTHAND);
		ghead = spawn(GStraightHeadClass, self, , usecoords.Origin);

		if(AWCowBossController(Controller) != None
			&& AWCowBossController(Controller).Attacker != None)
		{
			useloc = AWCowBossController(Controller).Attacker.Location;
		}
		else
			useloc = ghead.Speed*vector(Rotation) + Location;

		ghead.PrepVelocity(ghead.Speed*Normal(useloc - usecoords.Origin));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Just before it gets thrown he makes a green fire in his hand
///////////////////////////////////////////////////////////////////////////////
function Notify_FormRight()
{
	local coords usecoords;
	local P2Emitter handfire;

	if(HomingBurnClass != None)
	{
		usecoords = GetBoneCoords(BONE_RIGHTHAND);
		handfire= spawn(HomingBurnClass, self, , usecoords.origin);
		AttachToBone(handfire, BONE_RIGHTHAND);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Throws homing green burning gary heads
///////////////////////////////////////////////////////////////////////////////
function Notify_ThrowRight()
{
	local GaryHeadProjectile ghead;
	local coords usecoords;
	local vector useloc;

	if(GHomingHeadClass != None)
	{
		usecoords = GetBoneCoords(BONE_RIGHTHAND);
		ghead = spawn(GHomingHeadClass, self, , usecoords.Origin);

		if(AWCowBossController(Controller) != None
			&& AWCowBossController(Controller).Attacker != None)
		{
			if(GaryHeadHomingProjectile(ghead) != None)
				GaryHeadHomingProjectile(ghead).SetTarget(AWCowBossController(Controller).Attacker);
			useloc = AWCowBossController(Controller).Attacker.Location;
		}
		else
			useloc = ghead.Speed*vector(Rotation) + Location;

		ghead.PrepVelocity(ghead.Speed*Normal(useloc - usecoords.Origin));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Squirts boss milk
///////////////////////////////////////////////////////////////////////////////
function SquirtMilk(name UseBone)
{
	local coords usecoords;
	local vector useloc;
	local BossMilkProjectile milkproj;
	local float dist, zvel, usetime;
	local vector usev;

	if(BossMilkClass != None)
	{
		usecoords = GetBoneCoords(UseBone);
		milkproj = spawn(BossMilkClass, self, , usecoords.Origin);

		if(milkproj != None)
		{
			PlaySound(SquirtSound, SLOT_Talk,,,,GenPitch());
			// Determine velocity of shot
			// Check distance to target
			if(AWCowBossController(Controller) != None
			&& AWCowBossController(Controller).Attacker != None)
				dist = VSize(AWCowBossController(Controller).Attacker.Location - Location);
			else
				dist = DEFAULT_SQUIRT_DIST + FRand()*DEFAULT_SQUIRT_DIST;
			// xy direction is vside*t
			// z direction is vup*t + 0.5at^2
			milkproj.Speed = FRand()*(SquirtSpeedMax - SquirtSpeedMin) + SquirtSpeedMin;
			usetime = dist/milkproj.Speed;
			zvel = -0.5*milkproj.Acceleration.z*usetime;
			usev = milkproj.Speed*(vector(Rotation));
			usev.z = zvel;
			// Put velocity into projectile
			milkproj.PrepVelocity(usev);
		}
	}
}
function Notify_Utter1()
{
	SquirtMilk(BONE_UTTER1);
}
function Notify_Utter2()
{
	SquirtMilk(BONE_UTTER2);
}
function Notify_Utter3()
{
	SquirtMilk(BONE_UTTER3);
}
function Notify_Utter4()
{
	SquirtMilk(BONE_UTTER4);
}

/*
///////////////////////////////////////////////////////////////////////////////
// Swinging your head right
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_GoreRight()
{
	local vector HitPos, Rot, HitMomentum;

	// for point around where to hurt things
	HitPos = Location;
	Rot = vector(Rotation);
	Rot.z = 0;
	// move it forward to the head
	HitPos += CollisionRadius*Rot;
	// and over to the right
	HitPos.x -= (GORE_DAMAGE_RADIUS_RIGHT*Rot.y);
	HitPos.y += (GORE_DAMAGE_RADIUS_RIGHT*Rot.x);
	// form momentum
	HitMomentum.x = -Rot.y;
	HitMomentum.y = Rot.x;
	HitMomentum.z = 0.5;
	HitMomentum*=(GORE_IMPULSE_RIGHT);

//	log("hurting stuff to the right "$HitPos$" loc "$Location$" momentum "$HitMomentum);

	HurtThings(HitPos, HitMomentum,
				GORE_DAMAGE_RADIUS_RIGHT,
				GORE_DAMAGE_RIGHT);
}

///////////////////////////////////////////////////////////////////////////////
// Swinging your head right
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_GoreLeft()
{
	local vector HitPos, Rot, HitMomentum;

	// for point around where to hurt things
	HitPos = Location;
	Rot = vector(Rotation);
	Rot.z = 0;
	// move it forward to the head
	HitPos += CollisionRadius*Rot;
	// and over to the right
	HitPos.x += (GORE_DAMAGE_RADIUS*Rot.y);
	HitPos.y -= (GORE_DAMAGE_RADIUS*Rot.x);
	// form momentum
	HitMomentum.x = Rot.y;
	HitMomentum.y = -Rot.x;
	HitMomentum.z = 0.5;
	HitMomentum*=(GORE_IMPULSE);

//	log("hurting stuff to the LEFT "$HitPos$" loc "$Location$" momentum "$HitMomentum);

	HurtThings(HitPos, HitMomentum,
				GORE_DAMAGE_RADIUS,
				GORE_DAMAGE);
}
*/

///////////////////////////////////////////////////////////////////////////////
// Smashing things by stomping/bucking
///////////////////////////////////////////////////////////////////////////////
/*
///////////////////////////////////////////////////////////////////////////////
// Coming back down after you've reared up, so smash things
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_Stomp()
{
	local vector HitPos, Rot, HitMomentum;

	// for point around where to hurt things
	HitPos = Location;
	Rot = vector(Rotation);
	Rot.z = 0;
	// move it forward to the head
	HitPos += 0.8*CollisionRadius*Rot;
	// form momentum
	HitMomentum.x = Rot.x;
	HitMomentum.y = Rot.y;
	HitMomentum.z = 0.5;
	HitMomentum*=(STOMP_IMPULSE);

//	log("hurting stuff in front from stomp "$HitPos$" loc "$Location$" momentum "$HitMomentum);

	HurtThings(HitPos, HitMomentum,
				STOMP_DAMAGE_RADIUS,
				STOMP_DAMAGE);
}

///////////////////////////////////////////////////////////////////////////////
// Swinging your head right after you're stomping/bucking
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_GoreRightFromStomp()
{
	local vector HitPos, Rot, HitMomentum;

	// for point around where to hurt things
	HitPos = Location;
	Rot = vector(Rotation);
	Rot.z = 0;
	// move it forward to the head
	HitPos += CollisionRadius*Rot;
	// and over to the right
	HitPos.x -= (STOMPGORE_DAMAGE_RADIUS_RIGHT*Rot.y);
	HitPos.y += (STOMPGORE_DAMAGE_RADIUS_RIGHT*Rot.x);
	// form momentum
	HitMomentum.x = -Rot.y;
	HitMomentum.y = Rot.x;
	HitMomentum.z = 0.5;
	HitMomentum*=(STOMPGORE_IMPULSE_RIGHT);

//	log("hurting stuff to the right stompgore "$HitPos$" loc "$Location$" momentum "$HitMomentum);

	HurtThings(HitPos, HitMomentum,
				STOMPGORE_DAMAGE_RADIUS_RIGHT,
				STOMPGORE_DAMAGE_RIGHT);
}

///////////////////////////////////////////////////////////////////////////////
// Swinging your head left after you're stomping/bucking
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_GoreLeftFromStomp()
{
	local vector HitPos, Rot, HitMomentum;

	// for point around where to hurt things
	HitPos = Location;
	Rot = vector(Rotation);
	Rot.z = 0;
	// move it forward to the head
	HitPos += CollisionRadius*Rot;
	// and over to the right
	HitPos.x += (STOMPGORE_DAMAGE_RADIUS*Rot.y);
	HitPos.y -= (STOMPGORE_DAMAGE_RADIUS*Rot.x);
	HitPos.z += MIN_TUSK_HIT_HEIGHT;
	// form momentum
	HitMomentum.x = Rot.y;
	HitMomentum.y = -Rot.x;
	HitMomentum.z = 0.5;
	HitMomentum*=(STOMPGORE_IMPULSE);

//	log("hurting stuff to the left stompgore "$HitPos$" loc "$Location$" momentum "$HitMomentum);

	HurtThings(HitPos, HitMomentum,
				STOMPGORE_DAMAGE_RADIUS,
				STOMPGORE_DAMAGE);
}

///////////////////////////////////////////////////////////////////////////////
// Swinging your head left before you're stomping/bucking
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_SwipeLeftFromStomp()
{
	local vector HitPos, Rot, HitMomentum;

	// for point around where to hurt things
	HitPos = Location;
	Rot = vector(Rotation);
	Rot.z = 0;
	// move it forward to the head
	HitPos += CollisionRadius*Rot;
	// and over to the right
	HitPos.x += (SWIPEGORE_DAMAGE_RADIUS*Rot.y);
	HitPos.y -= (SWIPEGORE_DAMAGE_RADIUS*Rot.x);
	// form momentum
	HitMomentum.x = Rot.y;
	HitMomentum.y = -Rot.x;
	HitMomentum.z = 0.5;
	HitMomentum*=(SWIPEGORE_IMPULSE);

//	log("hurting stuff to the left swipegore "$HitPos$" loc "$Location$" momentum "$HitMomentum);

	HurtThings(HitPos, HitMomentum,
				SWIPEGORE_DAMAGE_RADIUS,
				SWIPEGORE_DAMAGE);
}

///////////////////////////////////////////////////////////////////////////////
// Big feet hit the ground
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_BigGroundHit()
{
	ShakeCameraDistanceBased(SHAKE_CAMERA_BIG);
}

///////////////////////////////////////////////////////////////////////////////
// Big feet hit the ground
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_MedGroundHit()
{
	ShakeCameraDistanceBased(SHAKE_CAMERA_MED);
}
*/

defaultproperties
{
	 ActorID="MadCowMikeJ"
     ChargeGroundSpeed=1500.000000
     ChargeDustClass=Class'AWEffects.CowChargeDust'
     FinishDustClass=Class'AWEffects.CowFinishDust'
     MyChargeDamage=Class'AWEffects.CowSmashDamage'
     ChargingSound=Sound'MiscSounds.Props.ElectricMeter'
     SquirtSound=Sound'WeaponSounds.bullet_hitflesh2'
     orbitheadclass=Class'AWPawns.GaryHeadOrbit'
     EyeOffset=(Z=500.000000)
     ZapFactor=0.250000
     RicHit(0)=Sound'WeaponSounds.bullet_ricochet1'
     RicHit(1)=Sound'WeaponSounds.bullet_ricochet2'
     sparkclass=Class'FX.SparkHitMachineGun'
     earlyclass=Class'AWPawns.BossEarlyCheck'
     firefootclass=Class'AWEffects.FootFireEmitter'
     firestepclass=Class'AWEffects.FootFireBurn'
     AbsorbLimit=10.000000
     GStraightHeadClass=Class'AWInventory.GaryHeadBurnProjectile'
     GHomingHeadClass=Class'AWInventory.GaryHeadHomingProjectile'
     StraightBurnClass=Class'AWEffects.StraightHandFire'
     HomingBurnClass=Class'AWEffects.HomingHandFire'
     BossMilkClass=Class'AWInventory.BossMilkProjectile'
     SquirtSpeedMin=200.000000
     SquirtSpeedMax=600.000000
     dialogclass=Class'AWPawns.DialogCowBoss'
     VoicePitch=1.000000
     GenAnimSpeed=1.000000
     bDangerous=True
     TakeDamageModifier=0.200000
     TorsoFireClass=Class'FX.FireElephantEmitter'
     HealthMax=5000.000000
     bPlayerIsEnemy=True
     AttackRange=(Min=300.000000,Max=2048.000000)
     WalkingPct=0.250000
     ControllerClass=Class'AWPawns.AWCowBossController'
     LODBias=3.000000
     Mesh=SkeletalMesh'AWCharacters.CowBoss'
     TransientSoundRadius=400.000000
     CollisionRadius=120.000000
     CollisionHeight=200.000000
     Mass=400.000000
     RotationRate=(Pitch=4096,Yaw=40000,Roll=3072)
	 bFireFootsteps=False
}
