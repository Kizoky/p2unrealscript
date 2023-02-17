///////////////////////////////////////////////////////////////////////////////
// RaptorPawn
// Copyright 2014 Running With Scissors, Inc. All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
class RaptorPawn extends AnimalPawn
	placeable;
	
///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() array<Sound> WalkSteps;		// Footsteps made when walking
var() array<Sound> RunSteps;		// Footsteps made when running
var() array<Sound> RoarSounds;		// Sound made when roaring
var() array<Sound> BiteSounds;		// Sound made when biting
var() array<Sound> PounceSounds;	// Sound made when pouncing
var() array<Sound> PainSounds;		// Sound made when hurt
var() array<Sound> JumpSounds;		// Sound made when jumping
var() array<Sound> JumpLanding;		// Sound made when landing from a jump
var() class<Emitter> JumpLandingFX;	// Effects made when landing from a jump

const MIN_DAMAGE_TO_REACT = 50;		// Raptor no-sells damage below this value
const MIN_SPEED_FOR_FOOTSTEP = 100;

///////////////////////////////////////////////////////////////////////////////
// The Raptor is very much an "in your face" enemy, so ignore encroachment
///////////////////////////////////////////////////////////////////////////////
event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry )
		return true;
		
	return false;
}

event EncroachedBy( actor Other );

///////////////////////////////////////////////////////////////////////////////
// Take damage (pawn call) but also save who attacked me
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local Vector UseMom;
	
	if (Damage >= MIN_DAMAGE_TO_REACT)
		UseMom = Momentum;
		
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, UseMom, DamageType);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Animation notifications
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_RaptorRoar()
{
	PlaySound(RoarSounds[Rand(RoarSounds.Length)], ,,,, GenPitch());
}
function Notify_RaptorStep()
{
	if (VSize(Velocity) > MIN_SPEED_FOR_FOOTSTEP && Controller.IsInState('LegMotionToTarget') && !Controller.IsInState('PounceOnTarget'))
		PlaySound(WalkSteps[Rand(Walksteps.Length)], SLOT_Interact,,,,GenPitch());
}
function Notify_RaptorStomp()
{
	if (VSize(Velocity) > MIN_SPEED_FOR_FOOTSTEP && Controller.IsInState('LegMotionToTarget') && !Controller.IsInState('PounceOnTarget'))
		PlaySound(RunSteps[Rand(Runsteps.Length)], SLOT_Interact,,,,GenPitch());
}
function Notify_RaptorBite()
{
	RaptorController(Controller).Notify_RaptorBite();
}
function Notify_RaptorPounce()
{
	RaptorController(Controller).Notify_RaptorPounce();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Anims
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function SetupAnims()
{
	// Make sure to blend all this channel in, ie, always play all of this channel when not 
	// playing something else, because this is the main movement channel
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('raptor_idle1', 1.0, 0.2);
}
simulated function SetAnimWalking()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('raptor_walk', 1.0, 0.2, MOVEMENTCHANNEL);
}
simulated function SetAnimRunning()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('raptor_run', 1.0, 0.2, MOVEMENTCHANNEL);
}
simulated function SetAnimRunningScared()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('raptor_run', 1.0, 0.2, MOVEMENTCHANNEL);
}
//simulated function SetAnimFlying();
//simulated function SetAnimClimbing();
simulated function SetAnimStanding()
{
	LoopAnim(GetAnimStanding(), 1.0, 0.2, MOVEMENTCHANNEL);
}
simulated function PlayAnimLimping()
{
	LoopAnim(GetAnimStanding(), 1.0, 0.2, MOVEMENTCHANNEL);
}
simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimDeath(), 1.0, 0.15);
}
simulated function PlayEating()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimEating(), 1.5, 0.15);
}

simulated function name GetAnimDeath()
{
	return 'raptor_die';
}
simulated function name GetAnimEating()
{
	return 'raptor_eat';
}

// Generic functions are declared here, so later in People.Elephant and other
// animal pawns, we can flesh them out specifically. But in order to get around the
// dependencies caused when we call these things in their controllers from AIPack and the fact
// the pawns need to list their controllers in their defaultprops and that we don't want
// ElephantPawn and ElephantBasePawn and all that crap, we make some generic functions here.
simulated function PlayAnimStanding()
{
	// turn off 
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStanding(), 1.0, 0.2);	
}
simulated function PlayHappySound();
simulated function PlayScaredSound();
function PlayHurtSound()
{
	PlaySound(PainSounds[Rand(Painsounds.Length)], SLOT_Talk,,,,GenPitch());
}
simulated function PlayThrownSound();
simulated function PlayContentSound();
simulated function PlayAngrySound();
simulated function PlayGetAngered()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimRoar(), 2.5, 0.2);	
}
simulated function PlayGetScared();
function PlayAttack1Sound()
{
	PlaySound(BiteSounds[Rand(BiteSounds.Length)], SLOT_Talk,,,,GenPitch());
}
function PlayAttack2Sound()
{
	PlaySound(PounceSounds[Rand(PounceSounds.Length)], SLOT_Talk,,,,GenPitch());
}
simulated function PlayAttack1()
{
	PlayAttack1Sound();
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimAttack(), 2.5, 0.2);
}
simulated function PlayAttack2()
{
	PlayAttack2Sound();
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimAttack2(), 3, 0.2);
}
simulated function PlayInvestigate()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('raptor_idle2', 1.0, 0.2);
}
simulated function PlaySitDown()
{
	SetAnimStartCrouching();
}
simulated function PlaySitting()
{
	SetAnimCrouching();
}
simulated function PlayStandUp()
{
	SetAnimEndCrouching();
}
simulated function PlayLayDown()
{
	SetAnimStartCrouching();
}
simulated function PlayLaying()
{
	SetAnimCrouching();
}
simulated function PlayDruggedOut();
simulated function PlayGetBackUp()
{
	SetAnimEndCrouching();
}
simulated function PlayPissing(float AnimSpeed);
simulated function PlayCovering();
simulated function SetAnimTrotting();
simulated function SetToTrot(bool bSet);
simulated function PlayShockedAnim();
simulated function PlayGrabPickupOnGround();

// Extra anims for Raptor, it can crouch and jump unlike other animals.
simulated function SetAnimStartCrouching()
{
	PlayAnim(GetAnimStartCrouch(), 1.0, 0.25, MOVEMENTCHANNEL);
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
function PlayJumpSound()
{
	PlaySound(JumpSounds[Rand(JumpSounds.Length)]);
}
function PlayJumpLanding()
{
	PlaySound(JumpLanding[Rand(JumpLanding.Length)]);
	Spawn(JumpLandingFX, self,, Location, Rotation);
}
simulated event PlayJump()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimJumping(), 1.0, 0.2);
	PlayJumpSound();
}

simulated function name GetAnimStanding()
{
	return 'raptor_idle1';
}
simulated function name GetAnimStartCrouch()
{
	return 'raptor_crouch_in';
}
simulated function name GetAnimEndCrouch()
{
	return 'raptor_crouch_out';
}
simulated function name GetAnimCrouch()
{
	return 'raptor_crouch';
}
simulated function name GetAnimJumping()
{
	return 'raptor_jump';
}
simulated function name GetAnimAttack()
{
	return 'raptor_bite';
}
simulated function name GetAnimAttack2()
{
	return 'raptor_pounce';
}
simulated function name GetAnimRoar()
{
	return 'raptor_roar';
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bCanCrouch=true
	Mesh=SkeletalMesh'PLCharacters.Raptor'
	CollisionRadius=60
	CollisionHeight=95
	WalkingPct=0.15
	GroundSpeed=1000
	HealthMax=1000
	ControllerClass=class'RaptorController'
	bGunCrazy=true
	JumpZ=800
	RotationRate=(Pitch=0,Yaw=95000,Roll=2048)
	Gang="RaptorGang"
	
	WalkSteps[0]=Sound'PLAnimalSounds.Raptor.RaptorWalk01'
	WalkSteps[1]=Sound'PLAnimalSounds.Raptor.RaptorWalk02'
	WalkSteps[2]=Sound'PLAnimalSounds.Raptor.RaptorWalk03'
	WalkSteps[3]=Sound'PLAnimalSounds.Raptor.RaptorWalk04'
	WalkSteps[4]=Sound'PLAnimalSounds.Raptor.RaptorWalk05'
	WalkSteps[5]=Sound'PLAnimalSounds.Raptor.RaptorWalk06'
	RunSteps[0]=Sound'PLAnimalSounds.Raptor.RaptorRun01'
	RunSteps[1]=Sound'PLAnimalSounds.Raptor.RaptorRun02'
	RunSteps[2]=Sound'PLAnimalSounds.Raptor.RaptorRun03'
	RunSteps[3]=Sound'PLAnimalSounds.Raptor.RaptorRun04'
	RunSteps[4]=Sound'PLAnimalSounds.Raptor.RaptorRun05'
	RunSteps[5]=Sound'PLAnimalSounds.Raptor.RaptorRun06'
	RoarSounds[0]=Sound'PLAnimalSounds.Raptor.RaptorRoar01'
	RoarSounds[1]=Sound'PLAnimalSounds.Raptor.RaptorRoar02'
	PounceSounds[0]=Sound'PLAnimalSounds.Raptor.RaptorPounceRoar01'
	PounceSounds[1]=Sound'PLAnimalSounds.Raptor.RaptorPounceRoar02'
	BiteSounds[0]=Sound'PLAnimalSounds.Raptor.RaptorBite01'
	BiteSounds[1]=Sound'PLAnimalSounds.Raptor.RaptorBite02'
	PainSounds[0]=Sound'PLAnimalSounds.Raptor.RaptorPain01'
	PainSounds[1]=Sound'PLAnimalSounds.Raptor.RaptorPain02'
	PainSounds[2]=Sound'PLAnimalSounds.Raptor.RaptorPain03'
	JumpSounds[0]=Sound'PLAnimalSounds.Raptor.RaptorJump01'
	JumpSounds[1]=Sound'PLAnimalSounds.Raptor.RaptorJump02'
	JumpLanding[0]=Sound'PLAnimalSounds.Raptor.RaptorLand01'
	JumpLandingFX=class'PLFX.RaptorLandingDust'
	AmbientGlow=30
}
