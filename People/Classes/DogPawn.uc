///////////////////////////////////////////////////////////////////////////////
// DogPawn for Postal 2
//
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// 8/11 kamek backport from AW.
///////////////////////////////////////////////////////////////////////////////
class DogPawn extends AnimalPawn
	placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var Sound Barks[3];		// Barking sounds
var Sound MeanBark;		// When he's really mad
var Sound BitingSounds[2];  // when he's biting someone
var Sound GrowlSounds[2];   // just growling
var Sound PantSound;    // panting
var Sound WhimperSound; // whimpering to get your attention
var Sound HurtSounds[2]; // just got hurt
var Sound Sniff;        // sniffing

var float PounceSpeed;	// How fast he moves as he pounces

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////

const BONE_PELVIS	= 'Bip01 pelvis';

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var (PawnAttributes) float CatchProjFreq;		// How often they'll catch a projectile thrown at them
var (PawnAttributes) bool bNoDismemberment;		// Prevent slicing in half

var class<AnimalPart> PartClass;
var Sound CutPartSound;
var float PartMomMag;

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const SPINE_BONE	= 'Bip01 Spine1';
const MOVE_PART		=	25;

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
		if(newsp.InitCatchProjFreq != DEF_SPAWN_FLOAT)
		{
			CatchProjFreq = newsp.InitCatchProjFreq;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to see if we caught this projectile in our mouthes, that was thrown
// at us.
///////////////////////////////////////////////////////////////////////////////
function CheckCatchProjectile(Projectile catchme, class<Pickup> makeme, optional out byte StateChange)
{
	if(AWDogController(Controller)!= None
		&& FRand() < CatchProjFreq)
		AWDogController(Controller).CheckCatchProjectile(catchme, makeme, StateChange);
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
///////////////////////////////////////////////////////////////////////////////
function PlayCatchProjectile()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	// Faster pounce
	PlayAnim(GetAnimPounce(), 3.0, 0.1);
	PlaySound(BitingSounds[Rand(ArrayCount(BitingSounds))], SLOT_Talk,,,,GenPitch());
	// Make him be able to move faster than normal
	GroundSpeed = PounceSpeed;
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
		usePart.SetupAnimalPart(Skins[0], AmbientGlow, PartRot, true);
		usePart.GiveMomentum(Momentum);
		usePart.ConvertToFrontHalf();
	}

	// Make back half
	hitlocation = -MOVE_PART*vector(MoveRot) + usec.origin;
	Momentum = -PartMomMag*(Normal(HitLocation - Location) + 0.01*VRand()) + addmom;
	Momentum.z += Rand(PartMomMag);
	usePart = spawn(PartClass,self,,HitLocation,Rotation);
	if(usePart != None)
	{
		usePart.SetupAnimalPart(Skins[0], AmbientGlow, PartRot, true);
		usePart.GiveMomentum(Momentum);
		usePart.ConvertToBackHalf();
	}

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
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
	Super.PreBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Record pawn dead, if player killed them
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	// Moved to P2Pawn/GameState
	/*
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.DogsKilled++;
	}
	*/

	Super.Died(Killer, damageType, HitLocation);
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
			exp.ReduceMagBasedOnProx(Location, 1.0+Frand());
			exp.PlaySound(ExplodeSound,,,,,GetRandPitch());
		}
	}
	else
		spawn(class'RocketSmokePuff',,,Location);	// gotta give the lame no-blood mode something!

	Super.ChunkUp(Damage);

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
		//return;
	}
	else
		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	
	// Kamek 4-28
	// If the dude kills us, and we're a dog, check to see if it was done with a catgun
	// right now this won't work if we kill the dog with the last shot of a catgun
	// i.e., when the cat goes flying off. Considering changing the damage type in
	// CatRocket and checking for it here.
	if (Health <= 0
		&& PlayerController(InstigatedBy.Controller) != None
		&& (ClassIsChildOf(DamageType, class'ShotgunDamage')
			|| ClassIsChildOf(DamageType, class'MachineGunDamage'))
		&& ((CatableWeapon(InstigatedBy.Weapon) != None && CatableWeapon(InstigatedBy.Weapon).CatOnGun == 1)
			|| (DualCatableWeapon(InstigatedBy.Weapon) != None && DualCatableWeapon(InstigatedBy.Weapon).CatOnGun == 1)
		))
	{
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(InstigatedBy.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(InstigatedBy.Controller),'DogsKilledWithCatgun',1,true);
	}
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

		if(Damage > 0
			&& 	(damageType == class'ShotgunDamage'
				|| damageType == class'SmashDamage'
				|| damageType == class'DogBiteDamage'
				|| ClassIsChildOf(damageType, class'ExplodedDamage')))
		{
			ChunkUp(Damage);
			return;
		}
		else
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

simulated function name GetAnimPounce()
{
	return 'pounce';
}

simulated function name GetAnimPiss()
{
	return 'piss';
}

simulated function name GetAnimBark()
{
	return 'bark';
}

simulated function name GetAnimJump()
{
	return 'pounce';
}

simulated function name GetAnimAttack()
{
	return 'attack';
}

simulated function name GetAnimStanding()
{
	return 'stand';
}

simulated function name GetAnimSitDown()
{
	return 'lay_in';
}

simulated function name GetAnimSitting()
{
	return 'lay_on';
}

simulated function name GetAnimStandUp()
{
	return 'lay_out';
}

simulated function name GetAnimLayDown()
{
	return 'lay_in';
}

simulated function name GetAnimLaying()
{
	return 'lay_on';
}

simulated function name GetAnimGetBackUp()
{
	return 'lay_out';
}

simulated function name GetAnimFalling()
{
	return 'run';
}

simulated function name GetAnimDeath()
{
	return 'die';
}

simulated function name GetAnimLimping()
{
	return 'limp';
}

simulated function SetupAnims()
{
	// Make sure to blend all this channel in, ie, always play all of this channel when not 
	// playing something else, because this is the main movement channel
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('stand', 1.0, 0.2);
}

simulated function SetAnimStanding()
{
	LoopAnim(GetAnimStanding(), 1.0, 0.2, MOVEMENTCHANNEL);
}

simulated function SetAnimWalking()
{
	Super.SetAnimWalking();
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('walk', 1.0, 0.2, MOVEMENTCHANNEL);
}

simulated function SetAnimRunning()
{
	Super.SetAnimRunning();
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('run', 2.5, 0.2, MOVEMENTCHANNEL);
}

simulated function SetAnimRunningScared()
{
	Super.SetAnimRunningScared();
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('run_scared', 2.5, 0.2, MOVEMENTCHANNEL);
}

simulated function SetAnimTrotting()
{
	Super.SetAnimTrotting();
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('walk', 4.0, 0.2, MOVEMENTCHANNEL);// + FRand()*0.4);
}


simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
	{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimDeath(), 1.5, 0.15);	// TEMP!  Speed up dying animation!
	//StopAnimating();
	}

function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	local float BlendAlpha, BlendTime;

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
	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		SimAnimChannel = RESTINGPOSECHANNEL;
	}
	// End
	// turn off 
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStanding(), 1.0, 0.2);
}

function PlayAnimLimping()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimLimping(), 1.0, 0.2);
}

function PlayHappySound()
{
	PlaySound(Barks[Rand(ArrayCount(Barks))], SLOT_Talk,,,,GenPitch());
}

function PlayContentSound()
{
	PlaySound(PantSound,
		SLOT_Talk,,,,GenPitch());
}

function PlayScaredSound()
{
	PlaySound(WhimperSound, SLOT_Talk,,,,GenPitch());
}

function PlayHurtSound()
{
	PlaySound(HurtSounds[Rand(ArrayCount(HurtSounds))], SLOT_Talk,,,,GenPitch());
}

function PlayThrownSound()
{
}

function PlayAngrySound()
{
	PlaySound(MeanBark, SLOT_Talk,,,,GenPitch());
}

function PlayGetAngered()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStanding(), 1.0, 0.2);
	PlaySound(GrowlSounds[Rand(ArrayCount(GrowlSounds))], SLOT_Talk,,,,GenPitch());
}

function PlayGetScared()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimBark(), 1.0, 0.3);
	PlaySound(Barks[Rand(ArrayCount(Barks))], SLOT_Talk,,,,GenPitch());
}

function PlayAttack1()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimAttack(), 1.5, 0.2);
	PlaySound(MeanBark, SLOT_Talk,,,,GenPitch());
}

function PlayAttack2()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimPounce(), 2.0, 0.2);
	PlaySound(BitingSounds[Rand(ArrayCount(BitingSounds))], SLOT_Talk,,,,GenPitch());
	// Make him be able to move faster than normal
	GroundSpeed = PounceSpeed;
}

function PlayInvestigate()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStanding(), 1.0, 0.2);
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
	//PlaySound(Purr);
}

function PlayPissing(float AnimSpeed)
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimPiss(), AnimSpeed, 0.2);
//	PlaySound(Purr);
}

function PlayGrabPickupOnGround()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimPounce(), 1.0, 0.2);
}

simulated event PlayJump()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimJump(), 2.0, 0.2);
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
	UrinePourFeeder(UrineStream).SetDir(checkcoords.Origin, -checkcoords.YAxis);
}

function PlayGetBackUp()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimGetBackUp(), 1.0, 0.2);
}

function PlayFalling()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim(GetAnimFalling(), , , MOVEMENTCHANNEL);
}

simulated function PlayShockedAnim()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	LoopAnim(GetAnimAttack(), 10.0, 0.15);
//	PlaySound(Hiss,
//			SLOT_Talk,,,,GenPitch());
}

defaultproperties
{
	Mesh=SkeletalMesh'Animals.meshDog'
	Skins[0]=Texture'AnimalSkins.Dog'
	CollisionHeight=37
	CollisionRadius=35
	DrawScale=1.6
    ControllerClass=class'AWDogController'
	WalkingPct=0.09
	GroundSpeed=550
	PounceSpeed = 750
	HealthMax=80
	Barks[0] = Sound'AnimalSounds.Dog.dog_bark1'
	Barks[1] = Sound'AnimalSounds.Dog.dog_bark2'
	Barks[2] = Sound'AnimalSounds.Dog.dog_bark3'
	BitingSounds[0] = Sound'AnimalSounds.Dog.dog_biting2'
	BitingSounds[1] = Sound'AnimalSounds.Dog.dog_biting3'
	GrowlSounds[0] = Sound'AnimalSounds.Dog.dog_growl2'
	GrowlSounds[1] = Sound'AnimalSounds.Dog.dog_growl3'
	MeanBark = Sound'AnimalSounds.Dog.dog_meanbark2'
	PantSound = Sound'AnimalSounds.Dog.dog_pant'
	WhimperSound = Sound'AnimalSounds.Dog.dog_whimper2'
	HurtSounds[0] = Sound'AnimalSounds.Dog.dog_hit1'
	HurtSounds[1] = Sound'AnimalSounds.Dog.dog_hit2'
	Sniff=Sound'AnimalSounds.Dog.dog_sniffing'
	TrottingPct=0.4
	TorsoFireClass=class'FireCatEmitter'
	bPersistent=true
    bBlockActors=false
    bBlockPlayers=false
     CatchProjFreq=0.500000
     PartClass=Class'AnimalPart'
     CutPartSound=Sound'AWSoundFX.Machete.machetelimbhit'
     PartMomMag=12000.000000
}
