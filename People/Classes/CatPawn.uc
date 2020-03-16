///////////////////////////////////////////////////////////////////////////////
// CatPawn for Postal 2
//
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Weird part is this pawn defaults to bBlockPlayer and Actors to false. 
// This is so he can 'squeeze' through peoples legs. But he needs
// to use Touch instead of Bump to receive these messages.
//
///////////////////////////////////////////////////////////////////////////////
class CatPawn extends AnimalPawn
	placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var(PawnAttributes)float DervishTimeMax;	// how long to dervish for, about
var(PawnAttributes)name  InitAttackTag;		// Tag to attack when you get triggered
var(PawnAttributes)float DervishAfterHurtFreq; // Randomly decide to dervish if you get hurt.. closer to 1.0 the more likely
var(PawnAttributes)float HackLegFreq; // how often you'll chop a person's leg rather than attach to them
var(PawnAttributes)float GrindLimbFreq; // How often you decide to grind up the limb you touch
var(PawnAttributes)float DervishChaserFreq; // Fight back sometimes when getting chased
var(PawnAttributes)float AttackFreq;		// 1.0 - 0.0, 1.0 attacks as often as it can
var(PawnAttributes)bool	bNoDismemberment;

var Mesh DervishMesh;		// mesh used as it swirls around
var P2Emitter MyDust;		// dervish dust when swirling
var P2Emitter MyBloodMist;	// dervish blood mist when clawing someone
var P2Emitter MyGrindBlood;	 // blood made by dervish grinding a bone
var class<P2Emitter> DustClass;
var class<P2Emitter> BloodMistClass;
var class<P2Emitter> GrindBloodClass;
var float DervishAccel;		// slower acceleration as a dervish
var float DervishGroundSpeed;
var Sound DervishMoveSound, DervishAttackSound, DervishEndSound;
var float DervishVolume, DervishRadius;
var float DervishTakeDamage;	// Dervish takes less damage from everything (he's harder to hit, swirls so much)

var class<AnimalPart> PartClass;
var Sound CutPartSound;
var float PartMomMag;

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const SPINE_BONE	= 'Bip01 Spine1';
const MOVE_PART		=	25;


///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var Sound Purr;		// played when it's lying down
var Sound Meow1;	// played as it's walking around
var Sound Meow2;	// played as it's walking around
var Sound Meow3;	// played as it's walking around
var Sound Thrown;	// Screams when you throw it
var Sound Scared;	// Plays as it runs away
var Sound Hiss;		// Plays when hissing
var Sound Sniff;	// Plays when sniffing a cat butt

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////

const BONE_PELVIS	= 'Bip01 pelvis';

///////////////////////////////////////////////////////////////////////////////
// PawnSpawner sets some things for you
///////////////////////////////////////////////////////////////////////////////
function InitBySpawner(PawnSpawner initsp)
{
	local AWBasePawnSpawner newsp;
	
	Super.InitBySpawner(initsp);

	newsp = AWBasePawnSpawner(initsp);
	if(newsp != None)
	{
		if(newsp.InitAttackFreq != DEF_SPAWN_FLOAT)
		{
			AttackFreq = newsp.InitAttackFreq;
		}
		if(newsp.InitDervishTimeMax != DEF_SPAWN_FLOAT)
		{
			DervishTimeMax = newsp.InitDervishTimeMax;
		}
	}
	//else
		//warn("Can't use old pawn spawner--use AWBasePawnSpawner");
}

///////////////////////////////////////////////////////////////////////////////
//  Landed, tell controller
///////////////////////////////////////////////////////////////////////////////
function Landed(vector HitNormal)
{
	//log(self$" landed ");
	if(Controller != None)
		Controller.Landed(HitNormal);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	// Turn off all possible dervish effects
	TurnOffDervish();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Dervish effects
///////////////////////////////////////////////////////////////////////////////
function StartDust()
{
	StopDust();
	if(DustClass != None)
	{
		MyDust = spawn(DustClass,self);
		MyDust.SetBase(self);
	}
}
function StopDust()
{
	if(MyDust != None)
	{
		MyDust.SelfDestroy();
		MyDust = None;
	}
}
function StartBloodMist()
{
	StopBloodMist();
	if(BloodMistClass != None)
	{
		MyBloodMist= spawn(BloodMistClass,self);
		MyBloodMist.SetBase(self);
	}
}
function StopBloodMist()
{
	if(MyBloodMist != None)
	{
		MyBloodMist.SelfDestroy();
		MyBloodMist= None;
	}
}
function StartGrindBlood()
{
	StopGrindBlood();
	if(GrindBloodClass != None)
	{
		MyGrindBlood= spawn(GrindBloodClass,self);
		MyGrindBlood.SetBase(self);
	}
}
function StopGrindBlood()
{
	if(MyGrindBlood != None)
	{
		MyGrindBlood.SelfDestroy();
		MyGrindBlood= None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// IsCrazy
// Returns true if we're a test cat and can dervish
///////////////////////////////////////////////////////////////////////////////
function bool IsCrazy()
{
	return (AWCatPawn(Self) != None
		|| P2GameInfoSingle(Level.Game).IsWeekend()
		|| bHighOnCatnip);
}

///////////////////////////////////////////////////////////////////////////////
// Going from normal cat to dervish
///////////////////////////////////////////////////////////////////////////////
function TurnOnDervish()
{
	if(!bDeleteMe
		&& Health > 0)
	{
		// Change mesh
		LinkMesh(DervishMesh);
		// put on dust effects
		StartDust();
		// change physics
		AccelRate = DervishAccel;
		Groundspeed = DervishGroundSpeed;
		SetPhysics(PHYS_FLYING);
		// Put sound on 
		AmbientSound=DervishMoveSound;
		SoundVolume=DervishVolume;
		SoundRadius=DervishRadius;
		// Change damage taking
		TakeDamageModifier=DervishTakeDamage;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Going from dervish back to normal cat
///////////////////////////////////////////////////////////////////////////////
function TurnOffDervish()
{
	// Change mesh back
	LinkMesh(default.Mesh);
	// turn off effects
	StopDust();
	StopBloodMist();
	// reset physics
	AccelRate = default.AccelRate;
	Groundspeed = default.GroundSpeed;
	SetPhysics(PHYS_Falling);
	// play wind down sound
	if(AmbientSound != None)
		PlaySound(DervishEndSound, SLOT_None,,,,GenPitch());
	// Put sound off 
	AmbientSound=None;
	SoundVolume=default.SoundVolume;
	SoundRadius=default.SoundRadius;
	// Change damage taking back
	TakeDamageModifier=default.TakeDamageModifier;
}

///////////////////////////////////////////////////////////////////////////////
// Cutting up someone
///////////////////////////////////////////////////////////////////////////////
function StartAttachDervish()
{
	// Prepare collision and physics
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);
	SetPhysics(PHYS_None);
	bCollideWorld=false;
	// turn off dust
	StopDust();
	if(!bDeleteMe)
	{
		// put on blood effects
		StartBloodMist();
		// Put sound on 
		AmbientSound=DervishAttackSound;
	}
}
///////////////////////////////////////////////////////////////////////////////
// Stopping cutting them up and go back to the ground as a normal cat
///////////////////////////////////////////////////////////////////////////////
function StopAttachDervish()
{
	// revert physics and collision
	SetPhysics(PHYS_Falling);
	bCollideWorld=true;
	if(!bDeleteMe
		&& Health > 0)
	{
		// turn off blood effects
		StopBloodMist();
		// turn dust back on
		StartDust();
		// Put sound to move
		AmbientSound=DervishMoveSound;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function StartGrindingLimb()
{
	// turn off dust
	StopDust();
	// put on blood effects
	StartBloodMist();
	StartGrindBlood();
	// Put sound on 
	AmbientSound=DervishAttackSound;
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function StopGrindingLimb()
{
	// turn off blood effects
	StopBloodMist();
	StopGrindBlood();
	if(!bDeleteMe
		&& Health > 0)
	{
		// turn dust back on
		StartDust();
		// Put sound to move
		AmbientSound=DervishMoveSound;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PlayDervish()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('spin', 1.0, 0.0, MOVEMENTCHANNEL);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PlayDervishFinish()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	LoopAnim('lay_out', 1.0, 0.2);
}

///////////////////////////////////////////////////////////////////////////////
// This is called whenever anything that might effect the animation has
// changed (physics, accelleration, status, weapons, etc.)
///////////////////////////////////////////////////////////////////////////////
simulated event ChangeAnimation()
{
	if(Mesh != DervishMesh)
		Super.ChangeAnimation();
}

///////////////////////////////////////////////////////////////////////////////
// We got cut in half by a bladed weapon
///////////////////////////////////////////////////////////////////////////////
function SplitInHalf(Pawn EventInstigator, vector HitLoc, class<DamageType> DamageType)
{
	local rotator PartRot, MoveRot;
	local coords usec;
	local vector hitlocation, startloc, momentum, addmom;
	local AnimalPart usePart;

	//log(self$" split in half");
	// Generate Part cut off
	// Move hit location to bone joint of the next part down
	usec = GetBoneCoords(SPINE_BONE);
	hitlocation = usec.origin;
	// momentum for Parts is different
	PartRot=rotator(-usec.Zaxis);
	PartRot.Pitch+=16000;
	MoveRot=rotator(usec.Xaxis);
	addmom = (Velocity*Mass)/2;
	// Make front half
	hitlocation = MOVE_PART*vector(MoveRot) + usec.origin;
	Momentum = PartMomMag*(Normal(HitLocation - Location) + 0.01*VRand()) + addmom;
	Momentum.z += Rand(PartMomMag);
	usePart = spawn(PartClass,self,,HitLocation,Rotation);
	if(usePart != None)
	{
		usePart.SetupAnimalPart(Skins[0], AmbientGlow, PartRot, , true);
		usePart.GiveMomentum(Momentum);
		usePart.ConvertToFrontHalf();
	}
	//log(Self$" front half made "$usePart);
	// Make back half
	hitlocation = -MOVE_PART*vector(MoveRot) + usec.origin;
	Momentum = -PartMomMag*(Normal(HitLocation - Location) + 0.01*VRand()) + addmom;
	Momentum.z += Rand(PartMomMag);
	usePart = spawn(PartClass,self,,HitLocation,Rotation);
	if(usePart != None)
	{
		usePart.SetupAnimalPart(Skins[0], AmbientGlow, PartRot, , true);
		usePart.GiveMomentum(Momentum);
		usePart.ConvertToBackHalf();
	}
	//log(Self$" back half made "$usePart);

	//if(FRand() < DoBlood)
	spawn(class'LimbExplode',self,,usec.origin);

	//if(FRand() < DoSound)
		// play gross sound
		PlaySound(CutPartSound,,,,,GetRandPitch());
	
	// Get rid of the body
	//Died(EventInstigator.Controller, DamageType, HitLoc);
	bChunkedUp=true;
	Health = 0;
	if ( Controller != None )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
			Controller.Destroy();
	}
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Take damage (pawn call) but also save who attacked me
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local LambController lambc;

	lambc = LambController(Controller);

	// Wake them from stasis now that we've been hit
	if(Controller.bStasis)
		lambc.ComeOutOfStasis(false);

	// Don't call at all if you didn't get hurt
	if(Damage <= 0)
		return;

	//log(Self$" take damage "$damagetype);
	// Check if cut in half
	if(ClassIsChildOf(damageType, class'MacheteDamage')
		|| ClassIsChildOf(damageType, class'ScytheDamage'))
	{
		// Don't bother in non-dismemberment or non-blood mode
		if (!P2GameInfo(Level.Game).bEnableDismemberment
			|| !class'P2Player'.Static.BloodMode()
			|| bNoDismemberment)
			Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
		else
		{
			// If I got killed by the player, tell the GameState so they can rack up our kill count
			if(P2GameInfoSingle(Level.Game) != None
				&& P2GameInfoSingle(Level.Game).TheGameState != None
				&& InstigatedBy.Controller != None
				&& InstigatedBy.Controller.bIsPlayer)
				P2GameInfoSingle(Level.Game).TheGameState.PawnKilledByDude(Self, DamageType);
			SplitInHalf(InstigatedBy, HitLocation, DamageType);
		}
		return;
	}
	else
		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	/*
	// Set persistence based on game type
	if (P2GameInfoSingle(Level.Game) != None
		&& !P2GameInfoSingle(Level.Game).IsWeekend())
		bPersistent = true;
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Record pawn dead, if player killed them
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	// Turn off all possible dervish effects
	if(AWCatController(Controller) != None
		&& AWCatController(Controller).bDervish)
		AWCatController(Controller).TurnOffDervish(true);

	// Moved to P2Pawn/GameState
	/*
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.CatsKilled++;
	}
	*/

	Super.Died(Killer, damageType, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Tell your enemy where you are, so they can attack you
///////////////////////////////////////////////////////////////////////////////
function AlertPredator()
{
	local AnimalController acont;
	local DogPawn CheckP;

	foreach VisibleCollidingActors(class'DogPawn', CheckP, PREDATOR_ALERT_RADIUS, Location)
	{
		acont = AnimalController(CheckP.Controller);
		if(acont != None)
			acont.InvestigatePrey(self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to chunk up from some attacks/attackers
///////////////////////////////////////////////////////////////////////////////
function bool TryToChunk(Pawn instigatedBy, class<DamageType> damageType)
{
	// Dogs always gib cats
	if(damageType == class'ShotgunDamage'
		|| damageType == class'SmashDamage'
		|| damageType == class'DogBiteDamage'
		|| ClassIsChildOf(damageType, class'ExplodedDamage'))
	{
		ChunkUp(Health);
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// make blood explosion
///////////////////////////////////////////////////////////////////////////////
simulated function ChunkUp(int Damage)
{
	local CatExplosion exp;

	bChunkedUp=true;

	if(class'P2Player'.static.BloodMode())
	{
		// Should make this inside ChunkUp, but we needs special distance stuff
		// so we do it out here
		exp = spawn(class'CatExplosion',,,Location);
		if(exp != None)
		{
			exp.ReduceMagBasedOnProx(Location, 1.0);//hitmag);
			exp.PlaySound(ExplodeSound,,,,,GetRandPitch());
		}
	}
	else
		spawn(class'RocketSmokePuff',,,Location);	// gotta give the lame no-blood mode something!

	Super.ChunkUp(Damage);

	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Extends Pawn.Dying
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dying
{

	///////////////////////////////////////////////////////////////////////////////
	// Be able to still see blood as something dies
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
	{
		local LambController lambc;

		if (Controller != None
			&& LambController(Controller) != None)
		{
			lambc = LambController(Controller);

			// Wake them from stasis now that we've been hit
			if(Controller.bStasis)
				lambc.ComeOutOfStasis(false);
			
		}

		// Don't call at all if you didn't get hurt
		if(Damage <= 0)
			return;

		//log(Self$" take damage dead "$damagetype);
		// Check if cut in half
		if(ClassIsChildOf(damageType, class'MacheteDamage')
			|| ClassIsChildOf(damageType, class'ScytheDamage'))
		{
			// Don't bother in non-dismemberment or non-blood mode
			if (!P2GameInfo(Level.Game).bEnableDismemberment
				|| !class'P2Player'.Static.BloodMode()
				|| bNoDismemberment)
				Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
			else
				SplitInHalf(InstigatedBy, HitLocation, DamageType);
			return;
		}

		// If you're infected, be infected even in death
		if(damageType == class'ChemDamage')
			SetInfected(FPSPawn(instigatedBy));

		// If fire hit you, even dead, catch on fire for sure
		if(ClassIsChildOf(damageType, class'BurnedDamage'))
			SetOnFire(FPSPawn(instigatedBy), (damageType==class'NapalmDamage'));

		// If fire has killed me,
		// or we're on fire and we died,
		// then swap to my burn victim mesh
		if(damageType == class'OnFireDamage'
			|| ClassIsChildOf(damageType, class'BurnedDamage')
			|| MyBodyFire != None)
			SwapToBurnVictim();

		if(!(Damage > 0
			&& TryToChunk(Instigator, DamageType)))
		{
			if(Physics == PHYS_Walking
				&& momentum.z != 0)
				momentum.z=0;
			AddVelocity( momentum ); 

			PlayHit(Damage, hitLocation, damageType, Momentum);
		}
	}
}

/*
///////////////////////////////////////////////////////////////////////////////
// Take half on fire damage
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local vector Rot, Diff, dmom;
	local float dot1, dot2;

	// Take half on all fire damage
	if(damageType == class'BurnedDamage'
		|| damageType == class'OnFireDamage')
		Damage/=2;

	// Check for if this really hit me or not
	Rot = vector(Rotation);
	dmom = Momentum;
	dmom.z=0;
	dmom = Normal(dmom);
	dot1 = Rot Dot dmom;

//	log("rot "$Rot$" mom "$dmom$" dot1 "$dot1);

	if(abs(dot1) > BODY_SIDE_DOT)
	{
		Diff = Normal(Location - HitLocation);
		dot2 = Rot Dot Diff;
		//log(" diff "$Diff$" dot2 "$dot2);

		if(abs(dot2) > BODY_INLINE_DOT)
		{
			Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		}
		else
			// no hit, so return without taking damage
			return;
	}
	else
	{
		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

}
*/
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
// sneak
// pounce
// jump
// walk
// run
// stand
// lay_in
// lay_on
// lay_out
// sit_in
// sit_on
// sit_out
// sniff
// cover
// piss
// hiss
// fall
//
///////////////////////////////////////////////////////////////////////////////


simulated function name GetAnimSneak()
{
	return 'sneak';
}

simulated function name GetAnimPounce()
{
	return 'pounce';
}

simulated function name GetAnimPiss()
{
	return 'piss';
}

simulated function name GetAnimCover()
{
	return 'cover';
}

simulated function name GetAnimHiss()
{
	return 'hiss';
}

simulated function name GetAnimSniff()
{
	return 'sniff';
}

simulated function name GetAnimJump()
{
	return 'jump';
}

simulated function name GetAnimStanding()
{
	return 'stand';
}

simulated function name GetAnimSitDown()
{
	return 'sit_in';
}

simulated function name GetAnimSitting()
{
	return 'sit_on';
}

simulated function name GetAnimStandUp()
{
	return 'sit_out';
}

simulated function name GetAnimLayDown()
{
	return 'lay_in';
}

simulated function name GetAnimLaying()
{
	return 'lay_on';
}

simulated function name GetAnimDruggedOut()
{
	return 'cheech';
}

simulated function name GetAnimGetBackUp()
{
	return 'lay_out';
}

simulated function name GetAnimFalling()
{
	return 'fall';
}

simulated function name GetAnimDeath()
{
	return 'death';
}

simulated function SetupAnims()
{
	// Make sure to blend all this channel in, ie, always play all of this channel when not 
	// playing something else, because this is the main movement channel
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	// Turn on this channel too
	LoopAnim('stand',1.0,0.2);
}

simulated function SetAnimStanding()
{
	//AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim(GetAnimStanding(), 1.0, 0.2);//, MOVEMENTCHANNEL);
}

simulated function SetAnimWalking()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('walk', 1.0, 0.2, MOVEMENTCHANNEL);// + FRand()*0.4);
}

simulated function SetAnimRunning()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('run', 2.5, 0.2, MOVEMENTCHANNEL);
}

simulated function SetAnimTrotting()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('walk', 4.0, 0.2, MOVEMENTCHANNEL);// + FRand()*0.4);
}


simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
	{
	PlayAnim(GetAnimDeath(), 1.5, 0.15);
	}

function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	local float BlendAlpha, BlendTime;

	// Don't blend if you're a dervish
	if(Mesh != DervishMesh)
		return;

	// Don't do anything with these damages
	if(ClassIsChildOf(damageType, class'BurnedDamage')
		|| damageType == class'OnFireDamage')
		return;

	// blend in a hit
	BlendAlpha = 1;
	BlendTime=0.2;

	AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
	TweenAnim('stand',0.1,TAKEHITCHANNEL);

//	PlaySound(Meow1,
//		SLOT_Talk,,,,GenPitch);

	Super.PlayTakeHit(HitLoc,Damage,damageType);
}


// PLAY THESE on the default channel
function PlayAnimStanding()
{
	// turn off 
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStanding(), 1.0, 0.2);
}

function PlayHappySound()
{
	local float randtype;

	randtype = FRand();
	if(randtype < 0.3)
		PlaySound(Meow1,
			SLOT_Talk,,,,GenPitch());
	else if(randtype < 0.6)
		PlaySound(Meow2,
			SLOT_Talk,,,,GenPitch());
	else
		PlaySound(Meow3,
			SLOT_Talk,,,,GenPitch());
}

function PlayContentSound()
{
	PlaySound(Purr,
		SLOT_Talk,,,1.0,GenPitch());
}

function PlayScaredSound()
{
	PlaySound(Scared);
}

function PlayThrownSound()
{
	PlaySound(Thrown,
			SLOT_Talk,,,,GenPitch());
}

function PlayGetScared()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimHiss(), 1.0, 0.2);
	PlaySound(Hiss,
			SLOT_Talk,,,,GenPitch());
}

function PlayAttack1()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimSniff(), 1.0, 0.2);
}

function PlayAttack2()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimSniff(), 1.0, 0.2);
}

function PlayInvestigate()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimSniff(), 1.0, 0.2);
	PlaySound(Sniff,
			SLOT_Talk,,,,GenPitch());
}

function PlaySitDown()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimSitDown(), 1.0, 0.2);
}

function PlaySitting()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimSitting(), 1.0, 0.2);
}

function PlayStandUp()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStandUp(), 1.0, 0.2);
}

function PlayLayDown()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimLayDown(), 1.0, 0.2);
}

function PlayLaying()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimLaying(), 1.0, 0.2);
	PlaySound(Purr);
}

function PlayDruggedOut()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimDruggedOut(), 1.0, 0.2);
	PlaySound(Purr);
}

function PlayPissing(float AnimSpeed)
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimPiss(), AnimSpeed, 0.2);
//	PlaySound(Purr);
}

function SetToTrot(bool bSet)
{
	if(bTrotting != bSet)
	{
		bTrotting=bSet;
		ChangeAnimation();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Start your urine feeder
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_PissStart()
{
	local UrinePourFeeder checkurine;

	if(UrineStream == None)
	{
		checkurine = spawn(class'UrinePourFeeder',self,,Location);
		if(AnimalController(Controller) == None
			|| AnimalController(Controller).PissingValid())
		{
			UrineStream = checkurine;
			UrinePourFeeder(UrineStream).MyOwner = self;
			// Trim the arcing z height of this bad boy
			UrinePourFeeder(UrineStream).InitialSpeedZPlus/=4;
			AttachToBone(UrineStream, BONE_PELVIS);
			SnapStream();
		}
		else
			checkurine.Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Stop your urine feeder
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_PissStop()
{
	if(UrineStream != None)
	{
		DetachFromBone(UrineStream);
		UrineStream.Destroy();
		UrineStream=None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// redetermine the direction of the stream
///////////////////////////////////////////////////////////////////////////////
function SnapStream()
{
	local vector startpos, X,Y,Z;
	local vector forward;
	local coords checkcoords;

	checkcoords = GetBoneCoords(BONE_PELVIS);
	UrinePourFeeder(UrineStream).SetLocation(checkcoords.Origin);
	UrinePourFeeder(UrineStream).SetDir(checkcoords.Origin, -checkcoords.XAxis);
}

function PlayCovering()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimCover(), 1.0, 0.2);
//	PlaySound(Purr);
}

function PlayGetBackUp()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimGetBackUp(), 1.0, 0.2);
}

function PlayFalling()
{
	if(AWCatController(Controller) == None
		|| !AWCatController(Controller).bDervish)
	{
		AnimBlendParams(MOVEMENTCHANNEL,1.0);
		LoopAnim(GetAnimFalling(), , , MOVEMENTCHANNEL);
	}
}

simulated function PlayShockedAnim()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	LoopAnim(GetAnimFalling(), 10.0, 0.15);
	PlaySound(Hiss,
			SLOT_Talk,,,,GenPitch());
}

defaultproperties
{
	Mesh=SkeletalMesh'Animals.meshCat'
	Skins[0]=Texture'AnimalSkins.Cat_Orange'
	CollisionHeight=25
	CollisionRadius=18
    WalkingPct=0.065
	GroundSpeed=480
	HealthMax=15
	Purr=Sound'AnimalSounds.Cat.CatPurr'
	Meow1=Sound'AnimalSounds.Cat.CatMeow'
	Meow2=Sound'AnimalSounds.Cat.CatMeow2'
	Meow3=Sound'AnimalSounds.Cat.CatCry'
	Thrown=Sound'AnimalSounds.Cat.CatVicious'
	Scared=Sound'AnimalSounds.Cat.CatScream'
	Hiss=Sound'AnimalSounds.Cat.CatHiss'
	Sniff=Sound'AnimalSounds.Cat.CatSniff'
	TrottingPct=0.4
    CarcassCollisionHeight=15.00000
	TorsoFireClass=class'FireCatEmitter'
    bBlockActors=false
    bBlockPlayers=false
     DervishTimeMax=30.000000
     DervishAfterHurtFreq=0.800000
     HackLegFreq=0.500000
     GrindLimbFreq=0.500000
     DervishChaserFreq=0.500000
     AttackFreq=1.000000
     DervishMesh=SkeletalMesh'AwAnimals.meshDervish'
     DustClass=Class'AWEffects.DervishDust'
     BloodMistClass=Class'AWEffects.DervishBloodMist'
     GrindBloodClass=Class'AWEffects.GrindLimbBlood'
     DervishAccel=800.000000
     DervishGroundSpeed=440.000000
     DervishMoveSound=Sound'AWSoundFX.Cat.DervishMove'
     DervishAttackSound=Sound'AWSoundFX.Cat.dervishlimbeat'
     DervishEndSound=Sound'AWSoundFX.Cat.dervishwinddown'
     DervishVolume=255.000000
     DervishRadius=200.000000
     DervishTakeDamage=0.400000
     PartClass=Class'AnimalPart'
     CutPartSound=Sound'AWSoundFX.Machete.machetelimbhit'
     PartMomMag=12000.000000
     MaxFallSpeed=5000.000000
     ControllerClass=Class'AWCatController'
     Skins(0)=Texture'AnimalSkins.Cat_Orange'
}
