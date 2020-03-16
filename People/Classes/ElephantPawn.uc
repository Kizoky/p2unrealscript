///////////////////////////////////////////////////////////////////////////////
// ElephantPawn for Postal 2
//
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ElephantPawn extends AnimalPawn
	placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

var Rotator StoppedRotationRate;	// stopped rotating
var Rotator NormalRotationRate;	// how slowly he normaly turns
var Rotator FastRotationRate; // how quickly he turns when attacking
var Sound Trumpet;
var class<DamageType> MyDamage;	// Type of damage we inflict

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////

const GORE_DAMAGE_RADIUS = 180;
const GORE_IMPULSE = 120000;
const GORE_DAMAGE = 60;

const GORE_DAMAGE_RADIUS_RIGHT = 120;
const GORE_IMPULSE_RIGHT = 40000;
const GORE_DAMAGE_RIGHT = 30;

const COMEDOWN_DAMAGE_RADIUS = 180;
const COMEDOWN_IMPULSE = 80000;
const COMEDOWN_DAMAGE = 80;

const STOMP_DAMAGE_RADIUS = 180;
const STOMP_IMPULSE = 40000;
const STOMP_DAMAGE = 60;

const STOMPGORE_DAMAGE_RADIUS = 120;
const STOMPGORE_IMPULSE = 40000;
const STOMPGORE_DAMAGE = 30;

const STOMPGORE_DAMAGE_RADIUS_RIGHT = 150;
const STOMPGORE_IMPULSE_RIGHT = 50000;
const STOMPGORE_DAMAGE_RIGHT = 40;

const SWIPEGORE_DAMAGE_RADIUS = 120;
const SWIPEGORE_IMPULSE = 50000;
const SWIPEGORE_DAMAGE = 20;

const MIN_TUSK_HIT_HEIGHT = 50;

const SHAKE_CAMERA_BIG = 350;
const SHAKE_CAMERA_MED = 250;
const MIN_MAG_FOR_SHAKE = 20;
const MAX_SHAKE_DIST	= 2000.0;


// Since the elephant is not a perfect cyclinder, try to approximate its shape and don't
// allow some bullets to hit, if they impact to widely.
const BODY_SIDE_DOT = 0.9;
const BODY_INLINE_DOT = 0.8;

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
	Super.PreBeginPlay();
	NormalRotationRate = RotationRate;
}

///////////////////////////////////////////////////////////////////////////////
// Record pawn dead, if player killed them
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	// Moved to P2Pawn/GameState.
	/*
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.ElephantsKilled++;
	}
	*/

	Super.Died(Killer, damageType, HitLocation);
}

function StopRotationRate()
{
	RotationRate = StoppedRotationRate;
}

function SetNormalRotationRate()
{
	RotationRate = NormalRotationRate;
}

function SetFastRotationRate()
{
	RotationRate = FastRotationRate;
}

///////////////////////////////////////////////////////////////////////////////
// Swap out to our burned mesh
///////////////////////////////////////////////////////////////////////////////
function SwapToBurnVictim()
{
	// STUBBED out for the moment on elephants
}

///////////////////////////////////////////////////////////////////////////////
// shake the camera from the heavy elephant
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
// Set to be infected. Elephants never carry it,it just pisses them off
///////////////////////////////////////////////////////////////////////////////
function SetInfected(FPSPawn Doer)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Take half on fire damage
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local vector Rot, Diff, dmom;
	local float dot1, dot2;

	// Take half on all fire damage
	if(ClassIsChildOf(damageType, class'BurnedDamage')
		|| damageType == class'OnFireDamage')
		Damage/=2;

	// Don't get hurt by other elephants (smashing damage)
	if(ClassIsChildOf(damageType, MyDamage))
		return;

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


simulated function name GetAnimRearup()
{
	SetNormalRotationRate();
	return 'stand';
}

simulated function name GetAnimStomp()
{
	return 'buck';
}

simulated function name GetAnimGore()
{
	return 'gore';
}

simulated function name GetAnimStand()
{
	return 'idle';
}

simulated function name GetAnimDeath()
{
	return 'die';
}

simulated function SetupAnims()
{
	// Make sure to blend all this channel in, ie, always play all of this channel when not 
	// playing something else, because this is the main movement channel
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	// Turn on this channel too
	SetNormalRotationRate();
	LoopAnim('idle', 1.0, 0.15, MOVEMENTCHANNEL);
}


simulated function SetAnimStanding()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	StopRotationRate();
	LoopAnim('idle', 1.0, 0.15, MOVEMENTCHANNEL);
}

simulated function SetAnimWalking()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	SetNormalRotationRate();
	LoopAnim('walk', 1.0, 0.15, MOVEMENTCHANNEL);// + FRand()*0.4);
}


simulated function SetAnimRunning()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	SetFastRotationRate();
//	LoopAnim('run', 1.0);
	LoopAnim('charge', 1.0, 0.15, MOVEMENTCHANNEL);
}
/*
simulated function SetAnimCharging()
{
	SetFastRotationRate();
	LoopAnim('charge', 1.0);
}
*/

function PlayAnimStanding()
{
	// turn off 
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim('idle', 1.0, 0.2);
}

function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
	{
	SetNormalRotationRate();
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	AnimBlendParams(TAKEHITCHANNEL,0.0);
	PlayAnim(GetAnimDeath(), 1.4, 0.15);	// TEMP!  Speed up dying animation!
	}

function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	local float BlendAlpha, BlendTime;

	// Don't do anything with these damages
	if(ClassIsChildOf(damageType, class'BurnedDamage')
		|| damageType == class'OnFireDamage')
		return;

	// blend in a hit
	BlendAlpha = 0.2;
	BlendTime=0.2;

	AnimBlendParams(TAKEHITCHANNEL,BlendAlpha);
	TweenAnim('gore',0.1,TAKEHITCHANNEL);

	Super.PlayTakeHit(HitLoc,Damage,damageType);
}

function PlayGetScared()
{
	StopRotationRate();
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStand(), 1.0, 0.2);
}

function PlayGetAngered()
{
	StopRotationRate();
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimRearup(), 1.0, 0.2);
	PlaySound(trumpet,SLOT_Talk,,,,GetRandPitch());
}

function PlayAngrySound()
{
	PlaySound(trumpet,SLOT_Talk,,,,GetRandPitch());
}

function PlayAttack1()
{
	StopRotationRate();
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStomp(), 1.0, 0.2);
	PlaySound(trumpet,SLOT_Talk,,,,GetRandPitch());
}

function PlayAttack2()
{
	StopRotationRate();
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimGore(), 1.0, 0.2);
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
				&& !(CheckP.bPlayer
					|| CheckP.IsA('AuthorityFigure')
					|| CheckP.bPersistent))
				usedam = CheckP.Health;
			else
				usedam = DamageAmount;

			HitActor.TakeDamage(usedam, 
								self, HitActor.Location, HitMomentum, MyDamage);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Ways to hurt people
///////////////////////////////////////////////////////////////////////////////
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

///////////////////////////////////////////////////////////////////////////////
// Coming back down after you've reared up, so smash things
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_ComingDownHigh()
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
	HitMomentum*=(COMEDOWN_IMPULSE);

//	log("hurting stuff in front from come down "$HitPos$" loc "$Location$" momentum "$HitMomentum);

	HurtThings(HitPos, HitMomentum,
				COMEDOWN_DAMAGE_RADIUS,
				COMEDOWN_DAMAGE);
}

///////////////////////////////////////////////////////////////////////////////
// Smashing things by stomping/bucking
///////////////////////////////////////////////////////////////////////////////
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

defaultproperties
{
	Mesh=SkeletalMesh'Animals.meshElephant'
	CollisionHeight=145
	CollisionRadius=180
    ControllerClass=class'ElephantController'
	WalkingPct=0.1
	GroundSpeed=500
	FastRotationRate=(Pitch=4096,Yaw=20000,Roll=3072)
    RotationRate=(Pitch=4096,Yaw=5000,Roll=3072)
    StoppedRotationRate=(Pitch=0,Yaw=0,Roll=0)
	HealthMax=500
	Mass=200
	Trumpet=Sound'AnimalSounds.Elephant.elephant_trumpet'
	bCanBeBaseForPawns=true
	TorsoFireClass=class'FireElephantEmitter'
	MyDamage=class'SmashDamage'
}
