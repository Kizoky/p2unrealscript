///////////////////////////////////////////////////////////////////////////////
// MonsterBitchController
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// AI controller for Monster Bitch
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchController extends P2EAIController;

/*

Lower level (near Bitch) = -1445.62
Lower level (outer ring) = -1202.10
Upper level = -266.13

*/

// FIXME all these Ponytail Nub refs need to go to an actual mouth bone, since one doesn't exist I'll need to make a socket

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////

// Actor refs
var P2Pawn Dude;							// Current ref to player
var MonsterBitch MyPawn;					// MonsterBitch version of Pawn

// Movement
var Vector Origin;							// Origin pos of bitch monster (where she's initially placed in-map)
var Rotator DesiredRotation;				// Will gradually rotate to this rotation per RotationRate
var bool bShouldRotate;						// True if the Bitch should rotate to face the Dude. Disabled during certain attacks.
//var Vector DesiredLocation;					// Will gradually move to this location per GroundSpeed
var bool bIsOnUpperLevel;					// Returns true if we're moving to, or currently at, the upper level of the map
var float VerticalMoveTime;					// How long we've been doing the vertical move

// AI
var Name LastStateName;						// Name of last state we were in (any state)
var Name LastAttackState;					// Name of last ATTACK state we were in
var Name NextStateName;						// Name of state we want to goto next. Used only in a few states
var float DamageAbsorbed;					// Amount of damage absorbed by Gary heads
var float AbsorbedDamageBeforeTaunt;		// How much damage we need to absorb before we taunt the player about it
var float DamageTaken;						// Amount of damage taken
var float TakenDamageBeforeOuch;			// How much damage we need to take before we cry about it

// Attacks general
var float MIN_WAIT_BETWEEN_ATTACKS;		// Minimum amount of time to wait between attacks

// Slap attack
var float MELEE_ATTACK_RANGE;			// X/Y range the Dude must be in before we attempt a slap/smash attack
var int SlapDamage;							// Damage dealt by slap
var float SlapMomentum;						// Momentum dealt by slap
var float SlapRadius;						// Radius of slap attack
var class<DamageType> SlapDamageType;		// Damage type caused by slap
var class<P2Emitter> SlapEffect;			// Effect generated when slapping ground
var Sound SlapSound;						// Sound made when slapping ground
var float SlapShake;						// How much to shake the camera
var Sound SlapHitSound;

// Smash attack
var int SmashDamage;						// Damage dealt by smash
var float SmashMomentum;					// Momentum dealt by smash
var float SmashRadius;
var class<P2Emitter> SmashEffect;
var Sound SmashSound;
var class<DamageType> SmashDamageType;		// Damage type caused by smash
var float SmashShake;						// How much to shake the camera
var Sound SmashHitSound;

// Long punch attack
var float LONG_PUNCH_RANGE;			// X/Y range the Dude must be past before we attempt a long punch attack
var int LongPunchDamage;					// Amount of damage dealt by long punch
var float LongPunchMomentum;				// Momentum imparted by long punch
var class<DamageType> LongPunchDamageType;	// Type of damage caused by long punch
var Sound LongPunchHitSound;				// Sound made when it connects

// Flamethrower attack
var float FLAMETHROWER_RANGE;			// X/Y range the Dude must be in before we attempt a flamethrower attack
const FLAMETHROWER_BONE = 'mouf';	// Bone to attach flamethrower to
var class<P2Emitter> FlamethrowerEmitterClass;	// Class of emitter used for flamethrower
var P2Emitter MyFlamethrower;				// Current flamethrower emitter we're using
var Vector FlamethrowerRelLoc;				// Relative location of flamethrower
var Rotator FlamethrowerRelRot;				// Relative rotation of flamethrower (Overwritten with rotation to hit the Dude)
var Range FlamethrowerRotRange;				// Rotation range of flamethrower
var float FlamethrowerYawOffset;			// Defauly yaw offset of flamethrower
var Sound FlamethrowerSound;				// Sound of flamethrower

// Poison Gas attack
const POISON_GAS_BONE = 'mouf';	// Bone to attach gas emitter to
var P2Emitter MyGas;						// Current gas emitter we're using
var float GasRange;							// Maximum range of gas attack
var float GasDist;							// Distance between gas clouds spawned
var class<P2Emitter> GasEmitterClass;		// Class of gas emitter used for poison gas attack
var class<P2Emitter> GasCloudClass;			// Class of gas cloud to spawn
var Vector GasRelLoc;				// Relative location of flamethrower
var Rotator GasRelRot;				// Relative rotation of flamethrower (Overwritten with rotation to hit the Dude)
var Range GasRotRange;				// Rotation range of flamethrower
var float GasYawOffset;			// Defauly yaw offset of flamethrower
var Sound GasSound;							// Sound effect played by gas

// Lava dive
var float MAX_DUDE_RANGE;				// Maximum amount of X/Y range the Dude can be in before we give up and hide in the lava
var Range DiveWaitTime;				// Amount of time we'll wait underlava before checking Dude radius
var class<P2Projectile> LavaDiveProjectileClass;	// Class of projectile to shit out when diving into the lava
var range LavaDiveProjectileCount;			// Number of lava dive projectiles to spew
var float LavaSpewRadius;					// Radius to spew the lava projectiles at
var float LavaSpewZOffset;					// Z-offset to spew lava projectiles
var float LavaSpewRandFactor;				// A bit of randomness
var float ROCK_SPEW_TOSSZ_LOWER;		// TossZ for rock spew on lower level
var float ROCK_SPEW_TOSSZ_UPPER;		// TossZ for rock spew on upper level
var class<P2Emitter> LavaSplashEmitterClass;		// Class of emitter spawned for lava splash
var Sound LavaSplashSound;					// Sound played for lava splash

// Ground pound attack
var int GroundPoundDamage;							// Damage of ground pound attack
var float GroundPoundMomentum;						// Momentum of ground pound attack
var float GroundPoundRadius;
var class<DamageType> GroundPoundDamageType;
var class<P2Projectile> GroundPoundProjectileClass;	// Class of P2Projectile to spawn when doing ground pound
var float GroundPoundProjectileRadius;		// Radius to spawn ground-pound projectiles
var float GROUNDPOUND_CEILING_Z;		// Z-value of ceiling (world position, not relative to Bitch)
var range GroundPoundProjectileCount;		// Number of ground pound projectiles to rain
var class<P2Emitter> GroundPoundEffect;
var Sound GroundPoundSound;
var float GroundPoundShake;					// How much to shake the camera
var Sound GroundPoundHitSound;

// Inhale attack
const INHALE_BONE = 'mouf';	// Bone to originate inhale attack from
struct CaughtActor
{
	var Actor Actor;						// Reference to actor caught in attack
	var float CaughtTime;					// Amount of time the actor has been caught for
	//var int CaughtCount;					// Number of times we've been caught, if this number isn't high enough then it means the dude sidestepped or something and can't be inhaled
	var bool bLost;							// True if we've been "lost", our CaughtTime decays until it hits zero.
};
var array<CaughtActor> CaughtActors;		// Actors caught in inhale attack
var float CaughtActorDragTime;				// How long in seconds to "drag" caught actors before they get lifted off and sucked down the Bitch's gullet
var float CaughtActorDragAccel;				// How much acceleration toward the Bitch to apply to caught actors
var float CaughtActorFlyAccel;				// How much acceleration to apply when they go airborne
var float INHALE_RANGE_MAX;			// Max amount of X/Y range the Dude must be in to attempt an inhale attack. Also works as max distance for inhale attack.
var float INHALE_RANGE_MIN;			// Min X/Y range the Dude must be in. Any closer and the Bitch will just attempt to smash, flamethrower, etc.
var float InhaleHitDamagePct;				// Amount of damage taken when hit by something we inhaled (as a percentage of full health)
var class<MonsterBitchInhaleEmitter> InhaleEffect;
var Rotator InhaleRelRot;
var Sound InhaleSound;
var MonsterBitchInhaleEmitter MyInhaleEmitter;
var vector InhaleOrigin;

// Spit Up
const SPIT_BONE = 'mouf';	// Bone from which to originate spit-out actors
struct SpitPowerup
{
	var class<Pickup> PickupClass;					// Class of pickup to spit
	var float AmountToAdd;							// How much ammo, etc. to add
	var float Weight;								// How much weight to give this pickup when randomly selecting. Pickups with higher weight will be more likely to pop up
};
var array<SpitPowerup> SpitPowerups;			// Types of powerups we'll spit out in addition to gary heads etc.
var range SpitPowerupCount;					// Min/max number of powerups we'll spit
var float SpitPowerupChance;					// Chance from 0.0 to 1.0 to spit a powerup at all
var float SpitPowerupSpeed;					// Speed to spit out powerup
var float SpitPowerupZThrow;					// additional Z-velocity to give
var float SpitPowerupDist;					// Distance away from the bitch to spawn powerup

// Spit Gary Heads
var int Spit_GaryHead_Max;					// Max number of Gary Heads to spawn
var float Spit_GaryHead_Delay;				// Delay between Gary Heads spawned
var float Spit_GaryHead_Cooldown;			// Cooldown (in seconds) of Gary Head spit
var float Spit_GaryHead_Last;				// Last time we used the GaryHead spit
// Spit Car
var class<KActorExplodable> Spit_Car_Class;	// Class of car to spit
var float Spit_Car_Speed;					// Speed of car exiting her mouth
// Spit Rock
var class<P2Projectile> Spit_Rock_Class;	// Class of rock projectile to spit

// Wait Attack
// Waits to attack!
var bool bWaitedToAttack;
	
// Various other consts
const EYE_LEVEL = 1536.f;					// From origin to eye level
const ATTACK_LEVEL = 403.f;					// Difference between the Z-value of our world location and the actual attack location
const ATTACK_LEVEL_TOLERANCE = 700.f;		// Maximum amount of vertical tolerance between our attack level and the Dude's current location
const UPPER_LEVEL_HEIGHT = 1180.f;			// Z-value of upper level, relative to pawn origin
const LOWER_LEVEL_HEIGHT = 0.f;				// Z-value of lower level, relative to pawn origin
var float SWITCH_LEVEL_TIME;			// Amount of time it takes to change levels
const PAWN_HEIGHT = 3248.f;					// Height of entire pawn (including the "worm body" usually hidden underlava)
const SMASH_EVENT = 'BitchSmash';			// Event called when the Bitch uses either her ground pound or smash attacks. Each one destroys an obstacle in the arena
var int SmashEventsTriggered;				// Number of smash events triggered
var int SmashEventsMax;				// Maximum number of smash events we can trigger

var Sound SilentSound;

const MAX_SHAKE_DIST		=	5000.0;
const SHAKE_ADD_RATIO		=	0.35;
const SHAKE_BASE_RATIO		=	0.45;
const SHAKE_CAMERA_MAX_MAG	=	200;

// Debug
const DEBUG_LOG = false;						// Whether to log debug information
var name FORCE_THIS_ATTACK;				// If non-null, MB will repeat this state over and over, for testing

/* Attack list
Thinking
PerformLavaDive - Placeholder FX
PerformVerticalMove - GOOD
PerformPalmAttack - Placeholder FX
PerformFistAttack - Placeholder FX
PerformLongPunch - Placeholder FX
PerformFlamethrower - Placeholder sound
PerformGasAttack - Placeholder sound
PerformSpitAttack - No FX
PerformGroundPound - Placeholder FX
PerformInhaleAttack - Placeholder FX
*/

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Debug.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function dlog(coerce string S, optional name Tag, optional bool bTimestamp)
{
	if (DEBUG_LOG)
	{
		if (Tag != '')
			log(S, Tag, bTimestamp);
		else
			log(S, 'MonsterBitchDebug', bTimestamp);
	}
}
function LogAndGoto(Name NewState, optional name Label, optional string Origin)
{
	dlog("From"@Origin$": Going to state '"$NewState$"'");
		
	GotoState(NewState, Label);
}

///////////////////////////////////////////////////////////////////////////////
// Initial setup
///////////////////////////////////////////////////////////////////////////////
function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	MyPawn = MonsterBitch(aPawn);
	if (MyPawn == None)
		warn(self@"does not have a MonsterBitch pawn!");
	else
	{
		MyPawn.SetPhysics(PHYS_None);
		Origin = MyPawn.Location;
		DesiredRotation = MyPawn.Rotation;
		//DesiredLocation = Origin;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Cleanup when destroyed
///////////////////////////////////////////////////////////////////////////////
function PawnDied(Pawn P)
{
	// Have her fall back down to the ground if she dies while on the upper level
	if (bIsOnUpperLevel)
	{
		MyPawn.SmerpToZStart = Origin.Z + LOWER_LEVEL_HEIGHT;
		MyPawn.SmerpToZFinish = Origin.Z + UPPER_LEVEL_HEIGHT;
		MyPawn.bSmerpWhenKilled = true;
		MyPawn.SmerpTime = SWITCH_LEVEL_TIME / 2.0;
	}

	Super.PawnDied(P);
}

///////////////////////////////////////////////////////////////////////////////
// Generic begin/end state stuff
///////////////////////////////////////////////////////////////////////////////
event BeginState()
{
	dlog(self$"::BeginState "$GetStateName());
}
event EndState()
{
	dlog(self$"::EndState "$GetStateName());
	LastStateName = GetStateName();
}

///////////////////////////////////////////////////////////////////////////////
// Find and hook dude
///////////////////////////////////////////////////////////////////////////////
function HookDude()
{
	local P2Pawn CheckP;
	
	foreach DynamicActors(class'P2Pawn', CheckP)
		if (CheckP.Health > 0 && CheckP.Controller != None && PlayerController(CheckP.Controller) != None)
		{
			Dude = CheckP;
			break;
		}
		
	dlog(self@"Hooked dude:"@Dude);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool DudeIsDead()
{
	if (Dude != None && Dude.Health <= 0)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the dude is out of the arena entirely and cannot be
// targeted. If so, duck into the lava and wait.
///////////////////////////////////////////////////////////////////////////////
function bool DudeOutOfArena()
{
	local Vector VDiff;
	
	// Sanity check.
	if (Dude == None)
		return false;
		
	// Get difference between attack Z and dude's actual Z.
	VDiff = Pawn.Location - Dude.Location;
	VDiff.Z = 0;
	
	if (VSize(VDiff) > MAX_DUDE_RANGE)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the dude is out of range of attack and the bitch needs to
// adjust vertically.
///////////////////////////////////////////////////////////////////////////////
function bool DudeOutOfRange()
{
	local Vector VDiff;
	
	// Sanity check.
	if (Dude == None)
		return false;
		
	// Get difference between attack Z and dude's actual Z.
	VDiff = Pawn.Location - Dude.Location;
	VDiff.Z += ATTACK_LEVEL;
	
	//dlog("Dude out of vertical range check: Dude at"@Dude.Location.Z@"and we're at"@Pawn.Location.Z@"diff"@VDiff.Z);
	
	if (Abs(VDiff.Z) > ATTACK_LEVEL_TOLERANCE)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the dude is in range of one of our melee attacks.
///////////////////////////////////////////////////////////////////////////////
function bool DudeInMeleeRange()
{
	local Vector VDiff;

	// Sanity check.
	if (Dude == None)
		return false;
		
	// Get difference between attack Z and dude's actual Z.
	VDiff = Pawn.Location - Dude.Location;
	VDiff.Z = 0;
	
	//dlog("Dude in melee range check: VSize(VDiff) is"@VSize(VDiff));
	
	if (VSize(VDiff) < MELEE_ATTACK_RANGE)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the dude is in range of the long punch attack
///////////////////////////////////////////////////////////////////////////////
function bool DudeInLongPunchRange()
{
	local Vector VDiff;
	local Vector TraceStart, TraceEnd;

	// Sanity check.
	if (Dude == None)
		return false;
		
	// For the long punch, don't try it if there's not a clear line of sight
	// (i.e., if he's hiding behind a pillar or something)
	// Should stop the bitch's fist from "clipping through" the pillars.
	TraceStart = Pawn.Location;
	TraceStart.Z += PAWN_HEIGHT / 2.f;
	TraceEnd = Dude.Location;
	TraceEnd.Z += Dude.CollisionHeight / 2.4;
	// Trace past the Bitch's collision boxes so they don't block the pillar check
	VDiff = Pawn.Location - Dude.Location;
	TraceStart += Normal(VDiff) * 300.f;
	if (!FastTrace(TraceEnd, TraceStart))
		return false;
		
	// Get difference between attack Z and dude's actual Z.
	VDiff.Z = 0;
	
	//dlog("Dude in melee range check: VSize(VDiff) is"@VSize(VDiff));
	
	if (!DudeOutOfRange() && VSize(VDiff) > LONG_PUNCH_RANGE)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the dude is in range of our flamethrower
///////////////////////////////////////////////////////////////////////////////
function bool DudeInFlamethrowerRange()
{
	local Vector VDiff;

	// Sanity check.
	if (Dude == None)
		return false;
		
	// Get difference between attack Z and dude's actual Z.
	VDiff = Pawn.Location - Dude.Location;
	VDiff.Z = 0;
	
	//dlog("Dude in melee range check: VSize(VDiff) is"@VSize(VDiff));
	
	if (!DudeOutOfRange() && VSize(VDiff) < FLAMETHROWER_RANGE)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the dude is in range of our flamethrower
///////////////////////////////////////////////////////////////////////////////
function bool DudeInInhaleRange()
{
	local Vector VDiff;

	// Sanity check.
	if (Dude == None)
		return false;
		
	// Get difference between attack Z and dude's actual Z.
	VDiff = Pawn.Location - Dude.Location;
	VDiff.Z = 0;
	
	//dlog("Dude in melee range check: VSize(VDiff) is"@VSize(VDiff));
	
	if (!DudeOutOfRange() && VSize(VDiff) < INHALE_RANGE_MAX && VSize(VDiff) > INHALE_RANGE_MIN)
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the Dude is high on catnip
///////////////////////////////////////////////////////////////////////////////
function bool DudeInSloMo()
{
	// Sanity check.
	if (Dude == None || P2Player(Dude.Controller) == None)
		return false;
		
	// Return true if any catnip time is left.
	return (P2Player(Dude.Controller).CatnipUseTime > 0);
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if we can spit out more gary heads
///////////////////////////////////////////////////////////////////////////////
function bool CanUseGaryHeads()
{
	// Kamek 5/11 - disabled these as per meeting
	return false;
	
	if (MyPawn.OrbitHeads.Length >= Spit_GaryHead_Max)
		return false;
		
	if (Level.TimeSeconds - Spit_GaryHead_Last < Spit_GaryHead_Cooldown)
		return false;
		
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do next.
///////////////////////////////////////////////////////////////////////////////
function WhatToDoNext()
{
	local float f, ZDiff, XYDiff;
	local array<Name> PossibleMoves;
	local int i;
	local String s;
	local Vector VDiff;
	local Name NextMove;

	// Sanity check.
	if (Dude == None)
	{
		LogAndGoto('Thinking',,"WhatToDoNext Dude=None");
		return;
	}
		
	VDiff = Pawn.Location - Dude.Location;
	ZDiff = Abs(VDiff.Z);
	VDiff.Z = 0;
	XYDiff = VSize(VDiff);
	
	dlog("WhatToDoNext from '"$GetStateName()$"' XYDiff"@XYDiff@"ZDiff"@ZDiff@"UpperLevel"@bIsOnUpperLevel);
	
	if (!bWaitedToAttack)
	{
		LogAndGoto('WaitToAttack',,"WhatToDoNext Wait for attack");
		return;
	}
	
	// Dude dead check.
	if (DudeIsDead())
	{
		LogAndGoto('AWinnerIsMe',,"WhatToDoNext DudeDied");
		return;
	}

	// Out of arena check.
	if (DudeOutOfArena())
	{
		LogAndGoto('PerformLavaDive',,"WhatToDoNext DudeOutOfArena");
		return;
	}
	
	// Pick a random attack.
	else
	{
		// Change levels.
		if (DudeOutOfRange() && LastStateName != 'PerformVerticalMove')
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0] = 'PerformVerticalMove';
		}
		
		// Melee: Palm or fist attack
		if (DudeInMeleeRange())
		{
			if (LastAttackState != 'PerformPalmAttack')
			{
				PossibleMoves.Insert(0,1);
				PossibleMoves[0] = 'PerformPalmAttack';
			}
			if (LastAttackState != 'PerformFistAttack')
			{
				PossibleMoves.Insert(0,1);
				PossibleMoves[0] = 'PerformFistAttack';
			}
		}
		
		// Long punch.
		if (DudeInLongPunchRange() && !bIsOnUpperLevel && LastAttackState != 'PerformLongPunch')
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0] = 'PerformLongPunch';
		}

		// Flamethrower.
		if (DudeInFlamethrowerRange() && LastAttackState != 'PerformFlamethrower')
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0] = 'PerformFlamethrower';
		}
		
		// Poison gas.
		if (DudeInFlamethrowerRange() && LastAttackState != 'PerformGasAttack')
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0] = 'PerformGasAttack';
		}		
		
		// Spit attack: Gary Heads
		if (CanUseGaryHeads())
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0]='SpitGaryHeads';
		}
		
		// Spit attack: Flaming Rock
		if (!DudeOutOfRange() && LastAttackState != 'SpitRock')
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0]='SpitRock';
		}
		
		// Spit attack: Car - STUBBED OUT
		/*
		if (!DudeOutOfRange() && LastAttackState != 'SpitCar')
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0]='SpitCar';
		}
		*/
		
		// Lava dive.
		if (!DudeInMeleeRange() && LastAttackState != 'PerformLavaDive')
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0]='PerformLavaDive';
		}
		
		// Ground pound attack.
		if ((!DudeInLongPunchRange() || bIsOnUpperLevel) && LastAttackState != 'PerformGroundPound' && (!bIsOnUpperLevel || LastStateName != 'PerformVerticalMove'))
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0]='PerformGroundPound';
		}
		
		// Inhale attack
		// This one is less frequent than the others
		if (DudeInInhaleRange() && LastAttackState != 'PerformInhaleAttack' /*&& FRand() < 0.5*/)
		{
			PossibleMoves.Insert(0,1);
			PossibleMoves[0]='PerformInhaleAttack';
		}
	}
	
	// Now that we've populated the list of possible moves, do a sanity check and make sure we actually have any.
	if (PossibleMoves.Length == 0)
	{
		LastAttackState = '';			// Reset last-attack state, in case it prevented an attack.
		PossibleMoves.Insert(0,1);
		PossibleMoves[0]='Thinking';	// Think on it some more.
	}
	
	// Debug: list off attacks
	if (DEBUG_LOG)
	{
		s = "Possible attacks:";
		for (i = 0; i < PossibleMoves.Length; i++)
			s = s @ PossibleMoves[i];
		dlog(s);
	}
	
	// Pick and execute random attack.
	i = rand(PossibleMoves.Length);
	NextMove = PossibleMoves[i];
	if (FORCE_THIS_ATTACK != '')
		NextMove = FORCE_THIS_ATTACK;
		
	// DEBUG DEBUG DEBUG
	/*
	if (LastAttackState != 'PerformSpitAttack')
		NextMove = 'PerformSpitAttack';
	else
		NextMove = 'PerformInhaleAttack';
	*/
	
	//if (!bIsOnUpperLevel)
		//NextMove='PerformVerticalMove';
		
	// Override: At 80%, 60%, 40%, etc, do a ground pound if we haven't triggered our smash event enough.
	dlog("If"@Pawn.Health@"<"@(SmashEventsMax - SmashEventsTriggered) * (MyPawn.HealthMax / float(SmashEventsMax + 1)));
	if (Pawn.Health < (SmashEventsMax - SmashEventsTriggered) * (MyPawn.HealthMax / float(SmashEventsMax + 1)))
		NextMove='PerformGroundPound';
	
	// Override: When in catnip time, do the banshee scream.
	if (DudeInSloMo())
		NextMove='PerformBansheeScream';

	LogAndGoto(NextMove,,"WhatToDoNext Random Attack");
}

///////////////////////////////////////////////////////////////////////////////
// If the gary heads absorb damage, we might want to laugh at them
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	if (Damage < 0)
	{
		DamageAbsorbed += Abs(Damage);
		if (DamageAbsorbed >= AbsorbedDamageBeforeTaunt)
		{
			// Have the pawn taunt
			DamageAbsorbed = 0;
			MyPawn.PlayDialogCantHurt(true);
		}		
	}
	else
	{
		DamageTaken += Damage;
		if (DamageTaken >= TakenDamageBeforeOuch)
		{
			// Cwy about it
			DamageTaken = 0;
			MyPawn.PlayDialogHurt(true);
		}
	}
	Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
}

///////////////////////////////////////////////////////////////////////////////
// Copied from explosion.uc
///////////////////////////////////////////////////////////////////////////////
function ShakeCamera(float Mag)
{
	local controller con;
	local float usemag, usedist;
	local vector Rotv, Offsetv;

	// Put a cap on the shake to make sure no one accidentally puts too much in
	if(Mag > SHAKE_CAMERA_MAX_MAG)
		Mag = SHAKE_CAMERA_MAX_MAG;

	// Shake the view from the big explosion!
	// Move this somewhere else?
	for(con = Level.ControllerList; con != None; con=con.NextController)
	{
		// Find who did it first, then shake them
		if(con.bIsPlayer && con.Pawn!=None)
		{
			usedist = VSize(con.Pawn.Location - MyPawn.Location);
			
			if(usedist < MAX_SHAKE_DIST)
			{
				usemag = ((MAX_SHAKE_DIST - usedist)/MAX_SHAKE_DIST)*SHAKE_ADD_RATIO*Mag;
				usemag += SHAKE_BASE_RATIO*Mag;
				/*
				// If you're actually hurt by the explosion bump up the shake a lot more
				if(usedist < ExplosionRadius)
				{
					Rotv=vect(1.0,1.0,2.0);
					Offsetv=vect(1.0,1.0,2.5);
				}
				else
				{
					Rotv=vect(1.0,1.0,1.0);
					Offsetv=vect(1.0,1.0,1.0);
				}
				*/
				Rotv=vect(1.0,1.0,1.0);
				Offsetv=vect(1.0,1.0,1.0);

				con.ShakeView((usemag * 0.2 + 1.0)*Rotv, 
				   vect(1000,1000,1000),
				   1.0 + usemag*0.02,
				   (usemag * 0.3 + 1.0)*Offsetv,
				   vect(800,800,800),
				   1.0 + usemag*0.02);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Tick
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event Tick(float dT)
{
	local float Roll, Pitch, Yaw;
	local Rotator NewRotation, DiffRot;
	local Vector NewLocation, DiffLoc;
	local coords usecoords;
	local Vector AddVel;
	local int i;
	
	Super.Tick(dT);
	
	// Always use PHYS_None, don't let the base pawn code override it.
	Pawn.SetPhysics(PHYS_None);
	
	// Update desired rotation to face the Dude.
	if (Dude != None)
	{
		DesiredRotation = Rotator(Dude.Location - MyPawn.Location);
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
	}
	
	DesiredRotation = Normalize(DesiredRotation);
	
	// Continually update rotation
	if (bShouldRotate && Rotation != DesiredRotation)
	{
		// Get components of desired rotation
		DiffRot = Normalize(DesiredRotation - Rotation);
		
		// Cap out at max
		DiffRot.Yaw = FClamp(DiffRot.Yaw, -Pawn.RotationRate.Yaw * dT, Pawn.RotationRate.Yaw * dT);
		// These two will never be used, but including them for completeness sake.
		DiffRot.Roll = FClamp(DiffRot.Roll, -Pawn.RotationRate.Roll * dT, Pawn.RotationRate.Roll * dT);
		DiffRot.Pitch = FClamp(DiffRot.Pitch, -Pawn.RotationRate.Pitch * dT, Pawn.RotationRate.Pitch * dT);
		
		// Set updated rotation
		NewRotation = Normalize(Pawn.Rotation) + DiffRot;
		
		// Do the rotation
		Pawn.SetRotation(NewRotation);
	}

/*	
	// Continually update location
	if (Pawn.Location != DesiredLocation)
	{
		// Get difference between location and desired
		DiffLoc = DesiredLocation - Pawn.Location;
		
		// Cap out at max
		DiffLoc.Z = FClamp(DiffLoc.Z, -Pawn.GroundSpeed * dT, Pawn.GroundSpeed * dT);
		// These two will never be used but including for completeness sake.
		DiffLoc.X = FClamp(DiffLoc.X, -Pawn.GroundSpeed * dT, Pawn.GroundSpeed * dT);
		DiffLoc.Y = FClamp(DiffLoc.Y, -Pawn.GroundSpeed * dT, Pawn.GroundSpeed * dT);
		
		// Set updated location
		NewLocation = Pawn.Location + DiffLoc;
		if (Abs(VSize(DesiredLocation - Location)) < 15.f)
			NewLocation = DesiredLocation;
		dlog("Desired"@DesiredLocation@"Actual"@Pawn.Location@"Diff"@DiffLoc@"New"@NewLocation);
		
		// Set location
		Pawn.SetLocation(NewLocation);
	}
*/

	// Handle actors caught up in the Bitch's inhale attack
	// FIXME needs to work on non-Pawn actors too!!!
	for (i = 0; i < CaughtActors.Length; i++)
	{
		// This is now handled by the inhale emitter.
		/*
		// Now check for a line-of-sight
		if (CaughtActors[i].CaughtCount <= -1 || !FastTrace(CaughtActors[i].Actor.Location, InhaleOrigin))
		{
			// Reduce caught time, if it goes below 0 then kick 'em out
			CaughtActors[i].CaughtTime -= dT;
			dlog(CaughtActors[i].Actor@"caught time -dT "@CaughtActors[i].CaughtTime);
			if (CaughtActors[i].CaughtTime <= 0)
			{
				// Remove it and skip past the loop
				RemoveSnaggedActor(CaughtActors[i].Actor);
				i--;
			}
		}
		*/
		if (CaughtActors[i].bLost)
		{
			// Reduce caught time, if it goes below 0 then kick 'em out
			CaughtActors[i].CaughtTime -= dT;
			dlog(CaughtActors[i].Actor@"caught time -dT "@CaughtActors[i].CaughtTime);
			if (CaughtActors[i].CaughtTime <= 0)
			{
				// Remove it and skip past the loop
				RemoveSnaggedActor(CaughtActors[i].Actor);
				i--;
			}
		}
		else
		{
			// Add the delta-T
			CaughtActors[i].CaughtTime += dT;
			dlog(CaughtActors[i].Actor@"caught time +dT "@CaughtActors[i].CaughtTime);
			// Find out if they need to be dragged or sent flying.
			// Pawns only get dragged -- projectiles ALWAYS fly at the Bitch.
			// (Exception: If a pawn falls off the outer ring or decides to jump, then apply the fly acceleration so they get sucked into the Bitch's mouth and not the lava pool)
			if (Pawn(CaughtActors[i].Actor) != None && (CaughtActors[i].CaughtTime < CaughtActorDragTime && CaughtActors[i].Actor.Physics == PHYS_Walking))
			{
				//usecoords = MyPawn.GetBoneCoords(INHALE_BONE);
				addvel = Normal(InhaleOrigin/*usecoords.Origin*/ - CaughtActors[i].Actor.Location) * CaughtActorDragAccel * dT;
				addvel.Z = 0;			
			}
			else
			{
				// Lift off and apply direct velocity to the Bitch's mouth
				//usecoords = MyPawn.GetBoneCoords(INHALE_BONE);
				addvel = Normal(InhaleOrigin/*usecoords.Origin*/ - CaughtActors[i].Actor.Location) * CaughtActorFlyAccel * dT;
				// Offset for zone gravity
				if (Pawn(CaughtActors[i].Actor) != None)
					addvel -= (Pawn.PhysicsVolume.Gravity * dT * 6);
				else
					addvel -= (Pawn.PhysicsVolume.Gravity * dT * 2);
			}

			// Now add the actual velocity
			if (Pawn(CaughtActors[i].Actor) != None)
			{
				//dlog(CaughtActors[i].Actor@"addvel"@addvel);
				Pawn(CaughtActors[i].Actor).AddVelocity(addvel);			
			}
			else
			{
				CaughtActors[i].Actor.Velocity += addvel;
				NewLocation = CaughtActors[i].Actor.Location + CaughtActors[i].Actor.Velocity * dT;
				CaughtActors[i].Actor.SetLocation(NewLocation);
			}
		}
	}	
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Anim notify stubs
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_StartAttack()	// Called by animation to activate collision bits
{
	dlog("Notify_StartAttack in"@GetStateName());
}
function Notify_StopAttack()	// Called by animation to deactivate collision bits
{
	dlog("Notify_StopAttack in"@GetStateName());
}
function Notify_DoAttack()		// Called by animation for a one-time attack (spawn projectile, do radius attack etc.)
{
	dlog("Notify_DoAttack in"@GetStateName());
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// States
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Startup
///////////////////////////////////////////////////////////////////////////////
auto state Startup
{
Begin:
	// Play a default animation
	MyPawn.PlayIdle();
	
	// Wait to hook the dude before we attempt to do anything else
	while (Dude == None)
	{
		HookDude();
		Sleep(0.1);
	}
	
	// Go into Thinking and begin the carnage!
	LogAndGoto('Thinking',,"Startup State End");
}

///////////////////////////////////////////////////////////////////////////////
// Thinking. Decide what to do next
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	// Set that we're ready to face the Dude again
	event BeginState()
	{
		Global.BeginState();
		bShouldRotate = true;
		
		// Play our idle animation, but only if we didn't play it already
		if (LastStateName != 'Thinking')
			MyPawn.PlayIdle();
	}
	
// Wait a bit and then choose our next action
Begin:
	Sleep(FRand() + MIN_WAIT_BETWEEN_ATTACKS);
	dlog("From Thinking: WhatToDoNext");
	WhatToDoNext();
}

///////////////////////////////////////////////////////////////////////////////
// Perform vertical move to match the Dude's location.
///////////////////////////////////////////////////////////////////////////////
state PerformVerticalMove
{
	// Sets DesiredLocation to perform a vertical move to or from the upper level
	function DoVerticalMove()
	{
		/*
		if (bIsOnUpperLevel)
		{
			DesiredLocation = Origin;
			dlog("Setting desired location to origin"@DesiredLocation);
		}
		else	
		{
			DesiredLocation = Origin;
			DesiredLocation.Z += UPPER_LEVEL_HEIGHT;
			dlog("Setting desired location to upper level"@DesiredLocation);
		}
		*/
		bIsOnUpperLevel = !bIsOnUpperLevel;
		VerticalMoveTime = 0.f;
	}

	// Turn off that we're doing our vertical move.
	event EndState()
	{
		Global.EndState();
		VerticalMoveTime = 0.f;
		NextStateName='';	// Clear our next state
	}
	
	// Do vertical move
	event BeginState()
	{
		Global.BeginState();
		MyPawn.PlayIdle();
		DoVerticalMove();
	}

	// Perform vertical movement via smerp
	event Tick(float dT)
	{
		local float Z, ZStart, ZFinish, Alpha;
		local Vector NewPos;

		Global.Tick(dT);
		VerticalMoveTime += dT;
		
		// Figure out the Z-values
		if (bIsOnUpperLevel)
		{
			ZStart = Origin.Z + LOWER_LEVEL_HEIGHT;
			ZFinish = Origin.Z + UPPER_LEVEL_HEIGHT;
		}
		else
		{
			ZStart = Origin.Z + UPPER_LEVEL_HEIGHT;
			ZFinish = Origin.Z + LOWER_LEVEL_HEIGHT;
		}
		
		// Calculate new Z-pos
		Alpha = FClamp(VerticalMoveTime / SWITCH_LEVEL_TIME, 0.f, 1.f);
		Z = Smerp(Alpha, ZStart, ZFinish);
		
		// Set the new Z-pos
		NewPos = Pawn.Location;
		NewPos.Z = Z;
		dlog("setloc"@NewPos);
		Pawn.SetLocation(NewPos);
		
		// When finished return to idling
		if (Alpha == 1.f)
		{
			if (NextStateName != '')
				LogAndGoto(NextStateName,,"PerformVerticalMove Tick Alpha = 1.f");
			else
				LogAndGoto('Thinking',,"PerformVerticalMove Tick Alpha = 1.f");
		}
	}
Begin:
}

///////////////////////////////////////////////////////////////////////////////
// Base attack state
///////////////////////////////////////////////////////////////////////////////
state AttackBase
{
	event BeginState()
	{
		Global.BeginState();
		LastAttackState = GetStateName();	// Register this attack
	}
}

///////////////////////////////////////////////////////////////////////////////
// Attack: Open palm slam
///////////////////////////////////////////////////////////////////////////////
state PerformPalmAttack extends AttackBase
{
	// 'SlamPalm', Frame 28
	function Notify_DoAttack()
	{
		local P2Emitter Effect;
		
		Global.Notify_DoAttack();
		MyPawn.DoRadiusAttack(SlapRadius);
		if (SlapEffect != None)
		{
			Effect = Spawn(SlapEffect,,,MyPawn.CollisionParts[17].Part.Location);
			if (SlapSound != None && Effect != None)
				Effect.PlaySound(SlapSound,,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
		}
		ShakeCamera(SlapShake);
	}
	// Begin slap attack
	// 'SlamPalm', Frame 20
	function Notify_StartAttack()
	{
		local int i;

		Global.Notify_StartAttack();
		// Activate parts on right hand
		for (i = 17; i <= 22; i++)
			MyPawn.ActivateAttack(i, SlapDamage, SlapMomentum, SlapDamageType, SlapHitSound);
	}
	// Stop slap attack
	// 'SlamPalm', Frame 28
	function Notify_StopAttack()
	{
		Global.Notify_StopAttack();
		// Deactivate all parts
		MyPawn.DeactivateAttack(-1);
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlayPalmAttack();
		bShouldRotate = false;		// Can't rotate while doing slap attack
									// FIXME allow rotation during windup only
		//Notify_StartAttack();		// FIXME set notify in the animation
	}
	event AnimEnd(int Channel)
	{
		//Notify_StopAttack();		// FIXME set notify in the animation
		LogAndGoto('Thinking',,"PerformPalmAttack AnimEnd");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Attack: Fist slam
///////////////////////////////////////////////////////////////////////////////
state PerformFistAttack extends AttackBase
{
	// 'SlamFistDouble', Frame 38
	function Notify_DoAttack()
	{
		local P2Emitter Effect1, Effect2;
		
		Global.Notify_DoAttack();
		MyPawn.DoRadiusAttack(SmashRadius);
		if (SmashEffect != None)
		{
			Effect1 = Spawn(SmashEffect,,,MyPawn.CollisionParts[17].Part.Location);
			Effect2 = Spawn(SmashEffect,,,MyPawn.CollisionParts[9].Part.Location);
			if (SmashSound != None)
			{
				if (Effect1 != None)
					Effect1.PlaySound(SmashSound,,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
				if (Effect2 != None)
					Effect2.PlaySound(SmashSound,,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
			}
		}
		ShakeCamera(SmashShake);
		if (SmashEventsTriggered < SmashEventsMax)
		{
			TriggerEvent(SMASH_EVENT, Self, Pawn);
			SmashEventsTriggered++;
		}
	}
	// Begin fist smash attack
	// 'SlamFistDouble', Frame 30
	function Notify_StartAttack()
	{
		local int i;
		
		Global.Notify_StartAttack();
		// Activate parts on hands
		for (i = 9; i <= 14; i++)
			MyPawn.ActivateAttack(i, SmashDamage, SmashMomentum, SmashDamageType, SmashHitSound);
		for (i = 17; i <= 22; i++)
			MyPawn.ActivateAttack(i, SmashDamage, SmashMomentum, SmashDamageType, SmashHitSound);
	}
	// Stop fist smash attack
	// 'SlamFistDouble', Frame 38
	function Notify_StopAttack()
	{
		Global.Notify_StopAttack();
		// Deactivate all parts
		MyPawn.DeactivateAttack(-1);
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlayFistAttack();
		bShouldRotate = false;		// Can't rotate while doing fist attack
									// FIXME allow rotation during windup only
		//Notify_StartAttack();		// FIXME set notify in the animation
	}
	event AnimEnd(int Channel)
	{
		//Notify_StopAttack();		// FIXME set notify in the animation
		LogAndGoto('Thinking',,"PerformFistAttack AnimEnd");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Attack: Long punch
///////////////////////////////////////////////////////////////////////////////
state PerformLongPunch extends AttackBase
{
	// 'LongPunch', Frame 28
	function Notify_DoAttack()
	{
		Global.Notify_DoAttack();
	}
	// Begin long punch attack
	// 'LongPunch', Frame 25
	function Notify_StartAttack()
	{
		local int i;
		local Rotator NewRot;
		
		Global.Notify_StartAttack();
		// Twist the Bitch a bit so that she'll punch the Dude straight on.
		NewRot = MyPawn.Rotation;
		NewRot.Yaw += 512;
		MyPawn.SetRotation(NewRot);
		
		// Activate parts on right hand
		for (i = 15; i <= 22; i++)
			MyPawn.ActivateAttack(i, LongPunchDamage, LongPunchMomentum, LongPunchDamageType, LongPunchHitSound);
	}
	// Stop long punch attack
	// 'LongPunch', Frame 32
	function Notify_StopAttack()
	{
		Global.Notify_StopAttack();
		// Deactivate all parts
		MyPawn.DeactivateAttack(-1);
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlayLongPunch();
		bShouldRotate = false;		// Can't rotate while doing fist attack
									// FIXME allow rotation during windup only
		//Notify_StartAttack();		// FIXME set notify in the animation
	}
	event AnimEnd(int Channel)
	{
		//Notify_StopAttack();		// FIXME set notify in the animation
		LogAndGoto('Thinking',,"PerformLongPunch AnimEnd");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Attack: Flamethrower
///////////////////////////////////////////////////////////////////////////////
// Spawn flamethrower.
function SpawnFlamethrower()
{
	local P2Emitter NewFlamethrower;
	local Rotator RotToDude;
	local float UseYaw;
	local Vector UseLoc;
	
	// Sanity check
	if (FlamethrowerEmitterClass == None)
		return;
	
	// Despawn the existing one if present
	if (MyFlamethrower != None)
		DespawnFlamethrower();
		
	// Spawn the flamethrower
	NewFlamethrower = Spawn(FlamethrowerEmitterClass, self);
	
	// If we made it, set it up on our mouth
	if (NewFlamethrower != None)
	{
		MyPawn.AttachToBone(NewFlamethrower, FLAMETHROWER_BONE);
		NewFlamethrower.SetRelativeLocation(FlamethrowerRelLoc);
		
		// From the new flamethrower's location and rotation, find out what angle we need to be
		// in order to hit the Dude.
		/*
		if (Dude != None)
		{
			UseLoc = Dude.Location;
			UseLoc.Z += Dude.CollisionHeight / 2;
			RotToDude = Rotator(NewFlamethrower.Location - UseLoc);
			UseYaw = FlamethrowerYawOffset - RotToDude.Pitch;
			UseYaw = FClamp(UseYaw, FlamethrowerRotRange.Min, FlamethrowerRotRange.Max);
			dlog("Flamethrower-to-dude rotation:"@RotToDude@"UseYaw"@UseYaw);
			FlamethrowerRelRot.Yaw = UseYaw;
		}
		*/
		
		NewFlamethrower.SetRelativeRotation(FlamethrowerRelRot);
		MyFlamethrower=NewFlamethrower;
		dlog("Spawned and attached flamethrower"@MyFlamethrower);
		if (FlamethrowerSound != None)
			MyFlamethrower.PlaySound(FlamethrowerSound,,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
	}
}
// Despawn flamethrower.
function DespawnFlamethrower()
{
	// Let it die out and despawn on its own
	if (MyFlamethrower != None)
	{
		dlog("Detatching and destroying flamethrower"@MyFlamethrower);
		//MyPawn.DetachFromBone(MyFlamethrower);
		//MyFlamethrower.SelfDestroy();
		//MyFlamethrower.Destroy();
		MyFlamethrower.GotoState('DieOut');
		MyFlamethrower = None;				// Don't forget to null the actor ref
	}
}
state PerformFlamethrower extends AttackBase
{
	// 'Flamethrower', Frame 30
	function Notify_StartAttack()
	{
		Global.Notify_StartAttack();
		SpawnFlamethrower();		
	}
	// 'Flamethrower', Frame 130
	function Notify_StopAttack()
	{
		Global.Notify_StopAttack();
		DespawnFlamethrower();
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlayFlamethrower();
		bShouldRotate = false;		// Can't rotate while attacking
		//Notify_StartAttack();		// FIXME set notify in the animation
	}
	event AnimEnd(int Channel)
	{
		//Notify_StopAttack();		// FIXME set notify in the animation
		LogAndGoto('Thinking',,"PerformFlamethrower AnimEnd");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Attack: Poison Gas
// FIXME THIS IS REALLY MESSY
///////////////////////////////////////////////////////////////////////////////
// Spawns a deadly cloud of anthrax
function SpawnAnthrax()
{
	local P2Emitter NewGas;
	local Rotator RotToDude;
	local float UseYaw;
	local Vector UseLoc;
	
	// Sanity check
	if (GasCloudClass == None || GasEmitterClass == None)
		return;
	
	// Despawn the existing one if present
	if (MyGas != None)
		DespawnAnthrax();
		
	// Spawn the flamethrower
	NewGas = Spawn(GasEmitterClass, self);
	
	// If we made it, set it up on our mouth
	if (NewGas != None)
	{
		MyPawn.AttachToBone(NewGas, POISON_GAS_BONE);
		NewGas.SetRelativeLocation(FlamethrowerRelLoc);
		
		// From the new flamethrower's location and rotation, find out what angle we need to be
		// in order to hit the Dude.
		/*
		if (Dude != None)
		{
			UseLoc = Dude.Location;
			UseLoc.Z += Dude.CollisionHeight / 2;
			RotToDude = Rotator(NewGas.Location - UseLoc);
			UseYaw = GasYawOffset - RotToDude.Pitch;
			UseYaw = FClamp(UseYaw, GasRotRange.Min, GasRotRange.Max);
			dlog("Gas-to-dude rotation:"@RotToDude@"UseYaw"@UseYaw);
			GasRelRot.Yaw = UseYaw;
		}		
		*/
		NewGas.SetRelativeRotation(GasRelRot);
		if (GasSound != None)
			NewGas.PlaySound(GasSound,,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
		MyGas=NewGas;
		dlog("Spawned and attached gas emitter"@MyGas);
	}	
}
// Despawn the gas emitter attached to the bitch's mouth
function DespawnAnthrax()
{
	// Let it die out and despawn on its own
	if (MyGas != None)
	{
		dlog("Detatching and destroying MyGas"@MyGas);
		//MyPawn.DetachFromBone(MyGas);
		//MyGas.SelfDestroy();
		//MyGas.Destroy();
		MyGas.GotoState('DieOut');
		MyGas = None;				// Don't forget to null the actor ref
	}
}
// Spawn gas clouds that harm the player (wait a few seconds after the attack to do so)
function SpawnAnthraxClouds()
{
	local coords UseCoords;
	local Vector HitLocation, HitNormal, TraceStart, TraceEnd, GasLocation;
	local bool bHitWorld;
	local float UseDist;
	local Actor Other;
	local Rotator UseRot;
	
	// Trace from the attach point to the dude/ground to spawn the actual poison gas clouds that deal damage.
	usecoords = MyPawn.GetBoneCoords(POISON_GAS_BONE);
	TraceStart = usecoords.Origin;
	UseRot = MyGas.Rotation;
	UseRot.Yaw = MyPawn.Rotation.Yaw;
	TraceEnd = TraceStart + Vector(UseRot) /*Normal(Dude.Location - TraceStart)*/ * GasRange;
	dlog("Tracing"@TraceStart@"to"@TraceEnd@"for gas attack");
	// Trace until we hit world geometry.
	foreach TraceActors(class'Actor', Other, HitLocation, HitNormal, TraceEnd, TraceStart)
	{
		if (Other.bWorldGeometry)
		{
			dlog("Hit world geometry actor"@Other@"at"@HitLocation);
			bHitWorld = true;
			break;
		}
	}
	if (!bHitWorld)
	{
		dlog("No hit actor, spawn gas cloud at trace end"@TraceEnd);
		HitLocation=TraceEnd;
	}
	// Spawn additional gas clouds along the way.
	UseDist = VSize(HitLocation - TraceStart);
	for (UseDist = VSize(HitLocation - TraceStart); UseDist > 0; UseDist -= GasDist)
	{
		GasLocation = TraceStart + Normal(TraceEnd - TraceStart) * UseDist;
		Spawn(GasCloudClass, self, , GasLocation);
	}
}
state PerformGasAttack extends AttackBase
{
	function Notify_StartAttack()
	{
		Global.Notify_StartAttack();
		SpawnAnthrax();
	}
	function Notify_StopAttack()
	{
		Global.Notify_StopAttack();
		DespawnAnthrax();
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlayFlamethrower();
		bShouldRotate = false;		// Can't rotate while attacking
		//Notify_StartAttack();		// FIXME set notify in the animation
	}
	event AnimEnd(int Channel)
	{
		//Notify_StopAttack();		// FIXME set notify in animation
		LogAndGoto('Thinking',,"PerformFlamethrower AnimEnd");
	}
Begin:
	Sleep(1.5);
	SpawnAnthraxClouds();
}


///////////////////////////////////////////////////////////////////////////////
// Attack: Spit
///////////////////////////////////////////////////////////////////////////////
// Maybe spit a powerup, too
function MaybeSpitPowerup()
{
	local Pickup Drop;
	local int i, j;
	local float Seed, MaxWeight, CurWeight;
	local coords usecoords;
	local Vector TraceStart, UseNormal, UseVel;
	local Rotator UseRot;
	
	// Should we spawn anything at all?
	if (FRand() > SpitPowerupChance)
		return;
	
	// Determine maximum weight
	for (i = 0; i < SpitPowerups.Length; i++)
		MaxWeight += SpitPowerups[i].Weight;
		
	// Randomly spawn powerups
	for (i = 0; i < (Rand(SpitPowerupCount.Max) - SpitPowerupCount.Min + 2); i++)
	{
		Seed = FRand() * MaxWeight;
		CurWeight = 0;
		// Figure out which one we picked
		for (j = 0; j < SpitPowerups.Length; j++)
		{
			CurWeight += SpitPowerups[j].Weight;
			if (Seed <= CurWeight)
			{
				// Spawn this one
				usecoords = MyPawn.GetBoneCoords(SPIT_BONE);
				TraceStart = usecoords.Origin;
				UseRot = MyPawn.GetBoneRotation(SPIT_BONE, 1);
				UseNormal = Vector(UseRot);
				// Trace it out some so it doesn't hit the bitch herself
				TraceStart += UseNormal * (SpitPowerupDist * (FRand() / 4.f + 1));
				Drop = Spawn(SpitPowerups[j].PickupClass,,,TraceStart);
				// Send it flying
				UseVel = UseNormal * SpitPowerupSpeed;
				UseVel.Z = SpitPowerupZThrow; // kick it up some
				UseVel += VRand() * 10.f; // add a bit of randomness
				Drop.SetPhysics(PHYS_Falling);
				Drop.Velocity = UseNormal * SpitPowerupSpeed;
				
				// Adjust starting amount, if defined.
				if (SpitPowerups[j].AmountToAdd != 0)
				{
					if (P2PowerupPickup(Drop) != None)
						P2PowerupPickup(Drop).AmountToAdd = SpitPowerups[j].AmountToAdd;
					if (P2WeaponPickup(Drop) != None)
						P2WeaponPickup(Drop).AmmoGiveCount = SpitPowerups[j].AmountToAdd;
					if (Ammo(Drop) != None)
						Ammo(Drop).AmmoAmount = SpitPowerups[j].AmountToAdd;
				}
				break;
			}
		}
	}
}
// DEPRECATED controller now picks one of the spit attacks to use in Thinking
/*
state PerformSpitAttack extends AttackBase
{
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlaySpit();
		bShouldRotate = false;		// Can't rotate while attacking
		ChooseSpitAttack();
	}
	// Picks one of many things to spit out
	function ChooseSpitAttack()
	{
		local int i;
		
		// Don't pick the "gary head" result if we already have 3.
		if (MyPawn.OrbitHeads.Length >= Spit_GaryHead_Max)
			i = Rand(2) + 1;
		else
			i = Rand(3);
		
		// Debug
		//i = 2;
		
		//if (i == 0)
			LogAndGoto('SpitGaryHeads',,"PerformSpitAttack Chose Gary Heads");
		//else if (i <= 1)
			//LogAndGoto('SpitCar',,"PerformSpitAttack Chose Car");
		//else
			//LogAndGoto('SpitRock',,"PerformSpitAttack Chose Rock");
	}
}
*/
state SpitGaryHeads extends AttackBase
{
	function Notify_DoAttack()
	{
		Global.Notify_DoAttack();
		MaybeSpitPowerup();
		GotoState(GetStateName(), 'SpitHeads');
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlaySpit();
		bShouldRotate = false;		// Can't rotate while attacking
		Spit_GaryHead_Last = Level.TimeSeconds;
		//Notify_DoAttack();			// FIXME set notify in animation
	}
	event AnimEnd(int Channel)
	{
		LogAndGoto('Thinking',,"SpitGaryHeads AnimEnd");
	}
SpitHeads:
	// Continually shit out Gary Heads until we have the specified maximum
	if (MyPawn.OrbitHeads.Length < Spit_GaryHead_Max)
	{
		MyPawn.SpawnOrbitHead();
		Sleep(Spit_GaryHead_Delay);
		Goto('SpitHeads');
	}
}
state SpitCar extends AttackBase
{
	// 'Spit', Frame 28	
	function Notify_DoAttack()
	{
		local KActorExplodable Car;
		local coords usecoords;
		local Vector TraceStart, UseNormal, Impulse;
		local Rotator UseRot;

		Global.Notify_DoAttack();
		MaybeSpitPowerup();
		usecoords = MyPawn.GetBoneCoords(SPIT_BONE);
		TraceStart = usecoords.Origin;
		
		// Spawn up a car and send it flying
		Car = Spawn(Spit_Car_Class,,,TraceStart,RotRand(true));
		Car.bReadyForImpact = true;
		Car.KWake();
		UseRot = MyPawn.GetBoneRotation(SPIT_BONE, 1);
		UseNormal = Vector(UseRot);
		UseNormal.Z = Normal(Dude.Location - TraceStart).Z;
		//Impulse = Normal(Dude.Location - TraceStart) * Spit_Car_Speed;
		//Impulse = Vector(UseRot) * Spit_Car_Speed;
		Impulse = UseNormal * Spit_Car_Speed;
		// Kick it up a bit so it'll hit the Dude
		Impulse.Z *= -0.10;
		Car.KAddImpulse(Impulse, Car.Location);
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlaySpit();
		bShouldRotate = false;		// Can't rotate while attacking
		//Notify_DoAttack();			// FIXME set notify in animation
	}
	event AnimEnd(int Channel)
	{
		LogAndGoto('Thinking',,"SpitCar AnimEnd");
	}
}
state SpitRock extends AttackBase
{
	// 'Spit', Frame 28	
	function Notify_DoAttack()
	{
		local P2Projectile Rock;
		local coords usecoords;
		local Vector TraceStart;
		local Rotator TossDir;
		
		Global.Notify_DoAttack();
		MaybeSpitPowerup();
		usecoords = MyPawn.GetBoneCoords(SPIT_BONE);
		TraceStart = usecoords.Origin;
		
		// Spawn up a rock and send it flying
		Rock = Spawn(Spit_Rock_Class,Pawn,,TraceStart,RotRand(true));
		//TossDir = Rotator(Dude.Location - TraceStart);
		TossDir = MyPawn.GetBoneRotation(SPIT_BONE, 1);
		TossDir.Pitch = Rotator(Dude.Location - TraceStart).Pitch;
		// Bump it up some more so it'll hit the Dude
		TossDir.Pitch += 2048.f;
		Rock.Velocity = Rock.GetThrownVelocity(Pawn, TossDir, 1.0);
		dlog("Throw Rock: Spawned"@Rock@"at Velocity"@Rock.Velocity);
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlaySpit();
		bShouldRotate = false;		// Can't rotate while attacking
		//Notify_DoAttack();			// FIXME set notify in animation
	}
	event AnimEnd(int Channel)
	{
		LogAndGoto('Thinking',,"SpitRock AnimEnd");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Attack: Lava Dive
///////////////////////////////////////////////////////////////////////////////
// Dive start: Dive under lava
function SpewLavaChunks()
{
	local int i, NumChunks;
	local Vector SpawnPoint, RandV;
	local Rotator TossDir;
	local P2Projectile Rock;
	local P2Emitter Splash;
	
	NumChunks = Rand(LavaDiveProjectileCount.Max - LavaDiveProjectileCount.Min) + LavaDiveProjectileCount.Min;
	for (i = 0; i < NumChunks; i++)
	{
		RandV = VRand();
		// Always make sure a few of these shoot for the Dude
		if (i == 0)
			RandV = (Origin - Dude.Location);
		RandV.Z = 0;
		SpawnPoint = Origin + RandV * LavaSpewRadius;
		SpawnPoint.Z += LavaSpewZOffset;
		Rock = Spawn(LavaDiveProjectileClass, Pawn, , SpawnPoint);
		if (Rock != None)
		{
			TossDir = Rotator(RandV);
			if (i > 0 && i < 3)
				TossDir.Yaw += (FRand() - 0.5) * 1024.f;
			if (bIsOnUpperLevel)
				Rock.TossZ = ROCK_SPEW_TOSSZ_UPPER + (FRand() - 0.5) * LavaSpewRandFactor;
			else
				Rock.TossZ = ROCK_SPEW_TOSSZ_LOWER + (FRand() - 0.5) * LavaSpewRandFactor;
			Rock.Velocity = Rock.GetThrownVelocity(Pawn, TossDir, 0.95 + FRand() / 10.f);
		}
	}
	
	// Spawn lava splash.
	if (LavaSplashEmitterClass != None)
	{
		SpawnPoint = MyPawn.Location;
		SpawnPoint.Z += LavaSpewZOffset;
		Splash = Spawn(LavaSplashEmitterClass,,,SpawnPoint);
		dlog("LAVA EMITTER spawned"@Splash@"playing"@LavaSplashSound);
		if (LavaSplashSound != None && Splash != None)
			Splash.PlaySound(LavaSplashSound,,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
	}
}
state PerformLavaDive extends AttackBase
{
	// 'Dive_In', Frame 17
	function Notify_DoAttack()
	{
		Global.Notify_DoAttack();
		SpewLavaChunks();
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlayDiveStart();
		bShouldRotate = false;		// Can't rotate while attacking
		//Notify_DoAttack();			// FIXME set in animation
	}
	event AnimEnd(int Channel)
	{
		LogAndGoto('LavaDiveWait',,"PerformLavaDive AnimEnd");
	}
}
// Dive wait: Wait for the Dude to get back in range (if he's out of range)
// or just wait for a period of time before undiving
state LavaDiveWait
{
	event BeginState()
	{
		Global.BeginState();
		MyPawn.PlayDiveWait();
	}
	function CheckToExitState()
	{
		if (!DudeOutOfArena())
			LogAndGoto('LavaDiveFinish',,"LavaDiveWait Dude Back In Arena");
	}
Begin:
	// Wait a bit
	Sleep(RandRange(DiveWaitTime.Min, DiveWaitTime.Max));
	
	// See if the dude's still out of range
	CheckToExitState();
	
	// If so, wait some more
	Goto('Begin');
}
// Dive finish, come out of the lava and possibly spawn lava splashes to harm the dude
state LavaDiveFinish
{
	// 'Dive_Out', Frame 6
	function Notify_DoAttack()
	{
		Global.Notify_DoAttack();
		SpewLavaChunks();
	}
	event BeginState()
	{
		Global.BeginState();
		MyPawn.PlayDiveFinish();
		//Notify_DoAttack();			// FIXME set in animation
	}
	event AnimEnd(int Channel)
	{
		LogAndGoto('Thinking',,"LavaDiveFinish AnimEnd");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Attack: Ground pound
// Like the double fist attack, but comes out quicker and causes debris to fall
// from the roof. Less damage than double fist attack.
///////////////////////////////////////////////////////////////////////////////
function RainRocksFromCeiling()
{
	local int i, NumChunks;
	local Vector SpawnPoint, RandV;
	local Rotator TossDir;
	local P2Projectile Rock;
	
	NumChunks = Rand(GroundPoundProjectileCount.Max - GroundPoundProjectileCount.Min) + GroundPoundProjectileCount.Min;
	for (i = 0; i < NumChunks; i++)
	{			
		RandV = VRand();
		RandV.Z = 0;
		SpawnPoint = Origin + RandV * GroundPoundProjectileRadius;
		// Have at least one of these fall on the Dude
		if (i == 0)
			SpawnPoint = Dude.Location;
		SpawnPoint.Z = GROUNDPOUND_CEILING_Z + FRand() * 1000;	// Give it a bit of randomness, so they don't all fall down in unison
		Rock = Spawn(GroundPoundProjectileClass, Pawn, , SpawnPoint);
	}
}
state PerformGroundPound extends AttackBase
{
	event BeginState()
	{
		Global.BeginState();
		// To do this attack we have to be on the lower level. If we're not, get there.
		if (bIsOnUpperLevel)
		{
			NextStateName = 'GroundPoundAttack';
			LogAndGoto('PerformVerticalMove',,"PerformGroundPound Not on lower level");
		}
		else
			// Go directly to attack
			LogAndGoto('GroundPoundAttack',,"PerformGroundPound On lower level");
	}
}
state GroundPoundAttack extends PerformFistAttack
{
	function Notify_DoAttack()
	{
		local P2Emitter Effect1, Effect2;
		
		Global.Notify_DoAttack();
		MyPawn.DoRadiusAttack(GroundPoundRadius);
		RainRocksFromCeiling();
		if (GroundPoundEffect != None)
		{
			Effect1 = Spawn(GroundPoundEffect,,,MyPawn.CollisionParts[17].Part.Location);
			Effect2 = Spawn(GroundPoundEffect,,,MyPawn.CollisionParts[9].Part.Location);
			if (GroundPoundSound != None)
			{
				if (Effect1 != None)
					Effect1.PlaySound(GroundPoundSound,,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
				if (Effect2 != None)
					Effect2.PlaySound(GroundPoundSound,,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
			}
		}
		ShakeCamera(GroundPoundShake);
		if (SmashEventsTriggered < SmashEventsMax)
		{
			TriggerEvent(SMASH_EVENT, Self, Pawn);
			SmashEventsTriggered++;
		}
	}
	event BeginState()
	{
		// Don't call super - it registers this as our "last attack" which we want to leave as 'PerformGroundPound'
		// Plus we need to override the anim played etc.
		MyPawn.PlayGroundPound();
		bShouldRotate = false;		// Can't rotate while doing fist attack
									// FIXME allow rotation during windup only
		//Notify_StartAttack();		// FIXME set notify in the animation
		//Notify_DoAttack();			// FIXME set notify in animation
	}
	function Notify_StartAttack()
	{
		local int i;
		
		Global.Notify_StartAttack();
		// Activate parts on hands
		for (i = 9; i <= 14; i++)
			MyPawn.ActivateAttack(i, GroundPoundDamage, GroundPoundMomentum, GroundPoundDamageType, GroundPoundHitSound);
		for (i = 17; i <= 22; i++)
			MyPawn.ActivateAttack(i, GroundPoundDamage, GroundPoundMomentum, GroundPoundDamageType, GroundPoundHitSound);
	}
	// FIXME need to drop shit from the ceiling!
}

///////////////////////////////////////////////////////////////////////////////
// Attack: Inhale
// Bitch attempts to inhale the Dude, but can end up sucking in items she's
// tossed out.
///////////////////////////////////////////////////////////////////////////////
// SnagThisActor: add this actor to our "caught actors" list.
// Actors caught will be dragged slowly toward the Bitch, if they don't escape in time,
// they'll be lifted off the ground and at that point their fate is sealed.
function SnagThisActor(Actor Other)
{
	local int i;
	
	// First check to make sure it isn't already snagged.
	for (i = 0; i < CaughtActors.Length; i++)
		if (CaughtActors[i].Actor == Other)
		{
			CaughtActors[i].bLost = false;
			return;
		}
			
	// Now check for a line-of-sight
	if (!FastTrace(Other.Location, InhaleOrigin))
		return;
		
	// Only allow pawns, bitchcars, and bitchrocks
	if (Pawn(Other) == None && Other.Class != Spit_Car_Class && Other.Class != Spit_Rock_Class)
		return;
		
	// Don't allow bitchrocks that are dying
	if (Other.Class == Spit_Rock_Class && Other.IsInState('ShrinkAndDie'))
		return;
			
	// Add to caught actors list.
	CaughtActors.Insert(0,1);
	CaughtActors[0].Actor = Other;
	CaughtActors[0].CaughtTime = 0.f;
	CaughtActors[0].bLost = false;
	//CaughtActors[0].CaughtCount = 1;
	dlog("Snagged actor:"@Other);
	
	// If it's not a pawn, null its physics so we can suck it in.
	if (Pawn(Other) == None)
	{
		Other.Velocity=Vect(0,0,0);
		Other.SetPhysics(PHYS_None);
	}
}
// Reset snagged-actors list
function WipeSnaggedActors()
{
	local int i;
	
	for (i = 0; i < CaughtActors.Length; i++)
		if (CaughtActors[i].Actor != None && Pawn(CaughtActors[i].Actor) == None)
		{
			CaughtActors[i].Actor.SetPhysics(PHYS_Falling);
			// Reduce velocity of formerly-snagged actor so they don't go flying into the lava pit
			CaughtActors[i].Actor.Velocity.X *= 0.1;
			CaughtActors[i].Actor.Velocity.Y *= 0.1;
		}
			
	CaughtActors.Length = 0;
	dlog("Wiped snagged actors");
}
// Remove this actor from snag list
function RemoveSnaggedActor(Actor Other)
{
	local int i;

	for (i = 0; i < CaughtActors.Length; i++)
		if (CaughtActors[i].Actor == Other)
		{
			CaughtActors.Remove(i, 1);
			dlog("Removed snagged actor:"@Other);
			if (Pawn(Other) == None)
			{
				Other.SetPhysics(PHYS_Falling);
				// Reduce velocity of formerly-snagged actor so they don't go flying into the lava pit
				Other.Velocity.X *= 0.1;
				Other.Velocity.Y *= 0.1;				
			}
			return;
		}
}
// Remove this actor from snag list
function LostSnaggedActor(Actor Other)
{
	local int i;

	for (i = 0; i < CaughtActors.Length; i++)
		if (CaughtActors[i].Actor == Other)
		{
			CaughtActors[i].bLost = true;
			return;
		}
}
function Actor GetSnaggedActor(int i)
{
	dlog("get snagged actor"@i);
	if (i >= CaughtActors.Length)
		return None;
	else
		return CaughtActors[i].Actor;
}

state PerformInhaleAttack extends AttackBase
{
	// Start attack
	// 'Inhale', Frame 8
	function Notify_StartAttack()
	{
		local int i;
		local MonsterBitchInhaleEmitter Effect;
		local coords usecoords;
		
		Global.Notify_StartAttack();
		
		// Activate parts on head and neck
		for (i = 5; i <= 6; i++)
			MyPawn.ActivateAttack(i, 0, 0, MyPawn.InhaleEventDamageType, None);
			
		// Spawn inhale effect, this handles tagging actors for us.
		if (InhaleEffect != None)
		{
			Effect = Spawn(InhaleEffect,,,MyPawn.CollisionParts[17].Part.Location);
			if (Effect != None)
			{
				MyPawn.AttachToBone(Effect, INHALE_BONE);
				Effect.SetRelativeRotation(InhaleRelRot);
				if (InhaleSound != None)
					Effect.PlaySound(InhaleSound,SLOT_Interact,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
				MyInhaleEmitter = Effect;
				Effect.MyBitch = Self;
				usecoords = MyPawn.GetBoneCoords(INHALE_BONE);
				InhaleOrigin = usecoords.Origin;
			}			
		}
	}
	// Attack is done
	// 'Inhale', Frame 80
	function Notify_StopAttack()
	{
		Global.Notify_StopAttack();
		// Deactivate all parts
		MyPawn.DeactivateAttack(-1);
		
		// Drop all snagged actors
		WipeSnaggedActors();
		
		if (MyInhaleEmitter != None)
		{
			//MyInhaleEmitter.GotoState('DieOut');
			MyInhaleEmitter.PlaySound(SilentSound, SLOT_Interact);
			MyInhaleEmitter.Destroy();
			MyInhaleEmitter = None;
		}
	}
	// Touched by something - if it's something we spit out coming back to smack us, do something
	event Touch(Actor Other)
	{
		if (Other.Class == Spit_Rock_Class || Other.Class == Spit_Car_Class)
		{
			// If the Boss Eye is up, it blocks it
			if (MyPawn.GreatEye != None && !MyPawn.GreatEye.bDeleteMe)
				MyPawn.GreatEye.ZapActor(Other);
			else
			{
				// It hurts
				Spawn(class'GrenadeExplosion',,,Other.Location);
				Other.Destroy();
				LogAndGoto('SpitAttackBackfire',,"PerformInhaleAttack GotSmacked");
			}
		}
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlayInhale();
		bShouldRotate = false;		// Can't rotate while attacking
	}
	event EndState()
	{
		Super.EndState();
		Notify_StopAttack();		// Failsafe
	}
	event AnimEnd(int Channel)
	{
		SetTimer(0, false);
		LogAndGoto('Thinking',,"PerformInhaleAttack AnimEnd");
	}
}
state SpitAttackBackfire
{
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlayInhale_TakeHit();
		MyPawn.TakeDamage(InhaleHitDamagePct * MyPawn.HealthMax, None, Location, Vect(0,0,0), class'P2Damage');
	}
	event AnimEnd(int Channel)
	{
		LogAndGoto('Thinking',,"SpitAttackBackfire AnimEnd");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Attack: Banshee Scream
///////////////////////////////////////////////////////////////////////////////
function CancelDudeCatnip()
{
	// Reset the dude's catnip time.
	if (Dude == None || P2Player(Dude.Controller) == None)
		return;
		
	P2Player(Dude.Controller).CatnipUseTime=0.1;
}
state PerformBansheeScream extends AttackBase
{
	// 'Scream', frame 20
	function Notify_DoAttack()
	{
		Global.Notify_DoAttack();
		CancelDudeCatnip();
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn.PlayScream();
		bShouldRotate = false;		// Can't rotate while attacking
		//Notify_DoAttack();			// FIXME set in the animation!
	}
	event AnimEnd(int Channel)
	{
		LogAndGoto('Thinking',,"PerformBansheeScream AnimEnd");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Victory! Do a little dance
///////////////////////////////////////////////////////////////////////////////
state AWinnerIsMe
{
	event BeginState()
	{
		Global.BeginState();
		MyPawn.PlayDance();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Wait To Attack
// Wait a couple seconds before attacking.
///////////////////////////////////////////////////////////////////////////////
state WaitToAttack
{
Begin:
	bWaitedToAttack=true;
	Sleep(1.0);
	GotoState('Thinking');
}

defaultproperties
{
	LongPunchDamage=30
	LongPunchMomentum=500
	LongPunchDamageType=class'MonsterBitchMeleeDamage'
	LongPunchHitSound=Sound'WeaponSounds.foot_kickhead'
	SlapDamage=15
	SlapMomentum=1000
	SlapRadius=500
	SlapDamageType=class'MonsterBitchMeleeDamage'
	SlapEffect=class'DustHitPuff'
	SlapSound=Sound'WeaponSounds.foot_kickwall'
	SlapShake=100
	SlapHitSound=Sound'WeaponSounds.foot_kickhead'
	SmashDamage=100
	SmashMomentum=400
	SmashRadius=400
	SmashShake=100
	SmashDamageType=class'MonsterBitchMeleeDamage'
	SmashEffect=class'DustHitPuff'
	SmashSound=Sound'WeaponSounds.foot_kickwall'
	SmashHitSound=Sound'WeaponSounds.foot_kickhead'
	GroundPoundDamage=50
	GroundPoundMomentum=250
	GroundPoundRadius=400
	GroundPoundDamageType=class'MonsterBitchMeleeDamage'
	GroundPoundHitSound=Sound'WeaponSounds.foot_kickhead'
	GroundPoundEffect=class'DustHitPuff'
	GroundPoundSound=Sound'WeaponSounds.foot_kickwall'
	FlamethrowerEmitterClass=class'MonsterBitchFlamethrowerEmitter'
	FlamethrowerRelLoc=(X=0,Y=0,Z=0)
	FlamethrowerRelRot=(Yaw=2048)
	FlamethrowerRotRange=(Min=46500,Max=48500)
	FlamethrowerYawOffset=49000
	FlamethrowerSound=Sound'LevelSoundsToo.Napalm.napalmFlameBurst'
	GasEmitterClass=class'AnthEmitterBitch'
	GasCloudClass=class'AnthCloudBitch'
	GasRange=1800
	GasDist=400
	GasRelLoc=(X=0,Y=0,Z=0)
	GasRelRot=(Yaw=2048)
	GasRotRange=(Min=46500,Max=48500)
	GasYawOffset=49000
	GasSound=Sound'WeaponSounds.cowhead_gas'
	CaughtActorDragTime=2.0
	CaughtActorDragAccel=8000
	CaughtActorFlyAccel=12000
	InhaleHitDamagePct=0.1
	InhaleEffect=class'MonsterBitchInhaleEmitter'
	InhaleSound=Sound'PL-Ambience.Hell.MonsterBitch-Inhale'
	InhaleRelRot=(Yaw=0)
	Spit_GaryHead_Max=3
	Spit_GaryHead_Delay=0.5
	Spit_GaryHead_Cooldown=30
	Spit_GaryHead_Last=-9999
	Spit_Car_Class=class'CarExplodableBitch'
	Spit_Car_Speed=300000
	Spit_Rock_Class=class'MonsterBitchRockProjectile'
	LavaDiveProjectileClass=class'LavaSpewProjectile'
	LavaDiveProjectileCount=(min=20,max=40)
	LavaSpewRadius=960
	LavaSpewZOffset=352
	LavaSpewRandFactor=200
	LavaSplashEmitterClass=class'LavaSplashEmitter'
	LavaSplashSound=Sound'MiscSounds.Props.splash'
	GroundPoundProjectileClass=class'RockProjectile'
	GroundPoundProjectileRadius=3000
	GroundPoundProjectileCount=(min=20,max=40)	
	AbsorbedDamageBeforeTaunt=200
	TakenDamageBeforeOuch=300
	GroundPoundShake=200
	MIN_WAIT_BETWEEN_ATTACKS=0.25f
	MELEE_ATTACK_RANGE=1800.f
	LONG_PUNCH_RANGE=2000.f
	FLAMETHROWER_RANGE=2500.f
	MAX_DUDE_RANGE=3500.f
	DiveWaitTime=(Min=3.f,Max=5.f)
	ROCK_SPEW_TOSSZ_LOWER=900.f
	ROCK_SPEW_TOSSZ_UPPER=2200.f
	GROUNDPOUND_CEILING_Z=8500.f
	INHALE_RANGE_MAX=3500.f
	INHALE_RANGE_MIN=1500.f
	SWITCH_LEVEL_TIME=1.25f
	FORCE_THIS_ATTACK=""
	SpitPowerupChance=0.5
	SpitPowerupCount=(Min=1,Max=3)
	SpitPowerupSpeed=1500.000000
	SpitPowerupZThrow=3000.000000
	SpitPowerupDist=500.000000
	SpitPowerups[0]=(PickupClass=class'DonutPickup',Weight=20)
	SpitPowerups[1]=(PickupClass=class'PizzaPickup',Weight=10)
	SpitPowerups[2]=(PickupClass=class'FastFoodPickup',Weight=2)
	SpitPowerups[3]=(PickupClass=class'CrackPickup',Weight=0.5)
	SpitPowerups[4]=(PickupClass=class'PistolPickup',AmountToAdd=50,Weight=5)
	SpitPowerups[5]=(PickupClass=class'GSelectPickup',AmountToAdd=50,Weight=4)
	SpitPowerups[6]=(PickupClass=class'ShotgunPickup',AmountToAdd=20,Weight=3)
	SpitPowerups[7]=(PickupClass=class'MachineGunPickup',AmountToAdd=80,Weight=3)
	SpitPowerups[8]=(PickupClass=class'MP5Pickup',AmountToAdd=80,Weight=3)
	SmashEventsMax=4
	SilentSound=Sound'QuietMiscSounds.Shaddup.Silence'
}
