///////////////////////////////////////////////////////////////////////////////
// CowPawn for Postal 2 AW
//
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWCowPawn extends CowPawn
	placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var (PawnAttributes) float FeedFreq;		// how often you want to feed
var (PawnAttributes) float StandThenFeedFreq; // you stand then you feed 
var (PawnAttributes) float CalmDownFreq;	// how quickly you calm down (1.0 is instantly, 0.0 is never)
var (PawnAttributes) float TakesSledgeDamage;
var (PawnAttributes) float TakesCowDamage;
var (PawnAttributes) name  InitAttackTag;		// Tag to attack when you get triggered

var Rotator StoppedRotationRate;	// stopped rotating
var Rotator NormalRotationRate;	// how slowly he normaly turns
var Rotator FastRotationRate; // how quickly he turns when attacking
var class<DamageType> MyDamage;	// Type of damage we inflict
var bool bHasHead;		// Has a head or not
var class<P2Emitter> HeadExplodeClass;	// what explodes
var class<CowHeadChunkFall> HeadChunkClass;	// what falls from the sky afterwards
var class<DamageType> HeadExplodeDamageClass;	// what damage blows up our head
var class<DamageType> HeadExplodeDamageClass2;	// what other damage blows up our head
var float HeadExplodeMaxDist2;		// max distance you can be away from the cow and explode damage 2 will still
									// blow up the head
var Sound ExplodeHeadSound;
var class<ButtHammer> HammerStuckClass; // what gets stuck in the butt, None for not allowing it
var class<P2WeaponPickup> HammerPickupClass; // what comes out
var ButtHammer StuckHammer;		// visual that's actually stuck there
var Sound ButtHitSound;	// hammer goes in butt
var Sound ButtPopSound; // pull out hammer sound
var class<P2Emitter> ButtHitClass; // visual particles for butt hit
var class<P2Emitter> ButtPopClass; // visual particles for butt pop
var bool bCharging;		// if we're charging while running, with our head down
var float ChargeGroundSpeed;	// How fast we run as charging (not just normal running)
var class<P2Emitter> ChargeDustClass;
var class<CowFinishDust> FinishDustClass;
var P2Emitter ChargingDust;
var class<StumpCow> NeckStumpClass;
var StumpCow MyNeckStump;
var class<P2Emitter> StumpBloodClass;	// type of blood stumps make
var class<SideSprayBlood> SprayBloodClass;
var bool bZombie;			// Zombie cows (mad cows), don't take damage from anything, but having their
							// head exploded. But they do bleed when shot/cut

var Sound CowButtHit;		// Sound cow moos when hit in butt
var array<Sound> CowNormalMoo;
var array<Sound> CowHurtMoo;
var Sound CowDieMoo;
var Sound PreChargeSound;
var Sound ChargingSound;

var float ChargingVolume, ChargingRadius;
var float HeadHealth;		// Health of our head (neck, really)
var float HeadTakesScytheDamage;	// how susceptible the head is to these damages, 1.0, means full damage
var float HeadTakesMacheteDamage;
var class<AWHeadCow> HeadClass;


///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////


const BACKKICK_DAMAGE_RADIUS= 180;
const BACKKICK_IMPULSE		= 1000;
const BACKKICK_DAMAGE		= 50;

const SHAKE_CAMERA_BIG = 350;
const SHAKE_CAMERA_MED = 250;
const MIN_MAG_FOR_SHAKE = 20;
const MAX_SHAKE_DIST	= 2000.0;


// Since the cow is not a perfect cyclinder, try to approximate its shape and don't
// allow some bullets to hit, if they impact to widely.
const BODY_SIDE_DOT = 0.9;
const BODY_INLINE_DOT = 0.8;

const NECK_BONE	= 'Bip01 Neck';
const HEAD_BONE	= 'Bip01 Head';
const BUTT_BONE = 'Bip01 Pelvis';

const SPLAT_CHECK	=	200;
const HIT_HEAD_DOT	=	-0.2;
const HIT_BUTT_DOT	=	-0.9;
const TAKE_HAMMER_DOT=	-0.8;
const FINISH_VEL	=	300;

const HEAD_FLY_SPEED = 200;

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
	Super.PreBeginPlay();
	NormalRotationRate = RotationRate;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	if(MyNeckStump != None)
	{
		MyNeckStump.Destroy();
		MyNeckStump = None;
	}

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Record pawn dead, if player killed them
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
/*	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.ElephantsKilled++;
	}
*/
//	PlaySound(CowDieMoo, SLOT_Talk,,,100,GenPitch());
	DropHammer();
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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RemoveHammer()
{
	DetachFromBone(StuckHammer);
	StuckHammer.Destroy();
	StuckHammer = None;
}

///////////////////////////////////////////////////////////////////////////////
// See if the player bumped me in the butt to get the hammer
///////////////////////////////////////////////////////////////////////////////
function bool CheckGetHammer(AWDude Other)
{
	local vector Rot, dir;
	local float dot1;
	local P2Emitter butteffects;

	if(StuckHammer != None)
	{
		// See if it's hitting my butt
		Rot = vector(Rotation);
		dir = Other.location - location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;

		if(dot1 < TAKE_HAMMER_DOT)
		{
			RemoveHammer();
			Other.CreateInventory("AWInventory.SledgeWeapon");
			// make effects
			if(ButtPopClass != None)
			{
				butteffects = spawn(ButtPopClass,self);
				butteffects.PlaySound(ButtPopSound,,,,100,GetRandPitch());
				AttachToBone(butteffects, BUTT_BONE);
			}
			return true;
		}
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Put hammer in butt
///////////////////////////////////////////////////////////////////////////////
function HammerGetsStuck()
{
	local P2Emitter butteffects;
	local AWPlayer P;

	StuckHammer = spawn(HammerStuckClass, self,,Location);
	AttachToBone(StuckHammer, BUTT_BONE);
	// make effects
	if(ButtHitClass != None)
	{
		butteffects = spawn(ButtHitClass,self);
		butteffects.PlaySound(ButtHitSound,,,,100,GetRandPitch());
		AttachToBone(butteffects, BUTT_BONE);
	}

	// play cow hit in the butt sound
	PlayButHittMoo();

	// play appropriate line for dude
	ForEach DynamicActors(class'AWPlayer', P)
		break;
	
	P.CowButtHit();

	// Have the game state count it up
	AWGameState(P2GameInfoSingle(Level.Game).TheGameState).LostSledgeInCow++;
	
	// Give them an achievement
	//log("cowbutt achievement"@P,'Debug');
	if( Level.NetMode != NM_DedicatedServer ) P.GetEntryLevel().EvaluateAchievement(P, 'BovineProstateInspector');
}

///////////////////////////////////////////////////////////////////////////////
// Drop hammer on death, turn it into a pickup
///////////////////////////////////////////////////////////////////////////////
function DropHammer()
{
	local P2WeaponPickup newmac;
	local vector usemom, useloc;

	if(StuckHammer != None)
	{
		useloc = StuckHammer.Location;
		RemoveHammer();

		newmac = spawn(HammerPickupClass, Owner,,useloc);
		// Turn into a pickup in that orientation
		if(newmac != None)
		{
			newmac.bRecordAfterPickup=false;
			// Throw it up into the air from the hit
			usemom = -vector(Rotation);
			usemom.z+=FRand()*1000;
			usemom = usemom;
			newmac.TakeDamage(1,Instigator,Location,usemom,class'damageType');
		}

	}
}

///////////////////////////////////////////////////////////////////////////////
// Check if this will stick in my butt,
// the projectile will take care of killing itself if this returns true
///////////////////////////////////////////////////////////////////////////////
function bool CheckHammerGetsStuckProj(P2Projectile Other)
{
	local vector Rot, dir;
	local float dot1;

	if(HammerStuckClass != None
		&& Health > 0)
	{
		// See if it's hitting my butt
		Rot = vector(Rotation);
		dir = Other.location - location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;
		if(dot1 < HIT_BUTT_DOT)
		{
			if(AWCowController(Controller) != None
				&& StuckHammer == None)
			{
				HammerGetsStuck();
				AWCowController(Controller).GotoState('ButtHit');
				return true;
			}
		}
	}
	return false;
}

// Play sound while cow's running
function StartRunningSound()
{
	AmbientSound=ChargingSound;
	SoundVolume=ChargingVolume;
	SoundRadius=ChargingRadius;
}

// Stop running sound
function StopRunningSound()
{
	AmbientSound=None;
	SoundVolume=default.SoundVolume;
	SoundRadius=default.SoundRadius;
}

///////////////////////////////////////////////////////////////////////////////
// Scared/hurt moo
///////////////////////////////////////////////////////////////////////////////
function PlayScaredSound()
{
	if(bHasHead)
		PlaySound(CowHurtMoo[Rand(CowHurtMoo.Length)], SLOT_Talk,,,,GenPitch());
}

///////////////////////////////////////////////////////////////////////////////
// Play normal moo
///////////////////////////////////////////////////////////////////////////////
function PlayNormalMoo()
{
	if(bHasHead)
		PlaySound(CowNormalMoo[Rand(CowNormalMoo.Length)], SLOT_Talk,,,,GenPitch());
}

///////////////////////////////////////////////////////////////////////////////
// Play hit in the butt moo
///////////////////////////////////////////////////////////////////////////////
function PlayButHittMoo()
{
	if(bHasHead)
		PlaySound(CowButtHit, SLOT_Talk,,,,GenPitch());
}

///////////////////////////////////////////////////////////////////////////////
// Play pre-charging sound
///////////////////////////////////////////////////////////////////////////////
function PlayPreChargeSound()
{
	if(bHasHead)
		PlaySound(PreChargeSound, SLOT_Interact,,,,GenPitch());
}

///////////////////////////////////////////////////////////////////////////////
// Play charging sound
///////////////////////////////////////////////////////////////////////////////
function PlayChargeSound()
{
	if(bHasHead)
		PlaySound(ChargingSound, SLOT_Interact,,,,GenPitch());
}

///////////////////////////////////////////////////////////////////////////////
//	A blood splash here
///////////////////////////////////////////////////////////////////////////////
function BloodSpray(vector BloodHitLocation, vector Momentum)
{
	local vector BloodOffset, dir, HitLocation, HitNormal, checkpoint;
	local float tempf;
	local Actor HitActor;
	local SideSprayBlood sprayb;
	local vector usecross, forward1, up1;

	// Find direction to center
	dir = BloodHitLocation - Location;
	dir = Normal(BloodHitLocation - Location);
	// push it away from the his center
	BloodOffset = 0.2 * CollisionRadius * dir;
	// pull it up some from the bottom and pull it down from the top
	BloodOffset.Z = BloodOffset.Z * 0.75;

	////////////////
	forward1 = Normal(Location - BloodHitLocation);
	up1.z = 1.0;
	usecross = forward1 cross up1;
	sprayb = spawn(SprayBloodClass,self,,BloodHitLocation+BloodOffset,Rotator(dir));
	sprayb.SetSpray(usecross);

	
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
// Does damage effects (blood) and plays hit animations
// Do a better blood effect for scythes
///////////////////////////////////////////////////////////////////////////////
function PlayHit(float Damage, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
	if (Damage <= 0 
		&& Controller != None
		&& !Controller.bGodMode )
		return;

	if(ClassIsChildOf(DamageType, class'BloodMakingDamage'))
	{
		if (Damage > 0) //spawn some blood
		{
			if(class'P2Player'.static.BloodMode())
			{
				if(ClassIsChildOf(DamageType, class'ScytheDamage'))
					BloodSpray(HitLocation, Momentum);
				else
					BloodHit(HitLocation, Momentum);
			}
		}

		if ( Health <= 0 )
		{
			if ( PhysicsVolume.bDestructive && (PhysicsVolume.ExitActor != None) )
				Spawn(PhysicsVolume.ExitActor);
			return;
		}
	}
	if ( Level.TimeSeconds - LastPainTime > 0.1 )
	{
		PlayTakeHit(HitLocation,Damage,damageType);
		LastPainTime = Level.TimeSeconds;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Very similar to AnimalPawn TakeDamage, but we check if we're a zombie or not
// If so, then we only bleed, but take not real damage from anything else--
// the head explosion is done before this so it's okay.
///////////////////////////////////////////////////////////////////////////////
function TakeDamageSuper( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;
	local int returnDamage;
	local vector OrigMomentum;
	local byte HeadShot;
	local LambController lambc;
	local int OldDamage;

	lambc = LambController(Controller);

	// Wake them from stasis now that we've been hit
	if(Controller.bStasis)
		lambc.ComeOutOfStasis(false);

	// Don't call at all if you didn't get hurt
	if(Damage <= 0)
		return;

	// If I'm already on fire, don't take any more damage from fire
	if(MyBodyFire != None
		&& ClassIsChildOf(damageType, class'BurnedDamage'))
		return;

	// Used for debugging.
	if(NO_ONE_DIES != 0)
		return;

	DamageInstigator = instigatedBy;
	// Modify the damage based on our attribute
	OldDamage = Damage;
	Damage = TakeDamageModifier*Damage;
	// Make sure if it's supposed to cause damage, it causes at least a little
	if(OldDamage > 0
		&& Damage <=0)
		Damage = 1;
	// Calc the damage based on the body location for the hit
	Damage = ModifyDamageByBodyLocation(Damage, InstigatedBy, HitLocation, momentum, DamageType, HeadShot);

	// Save the momentum because for some reason it has to be squished and saved.
	OrigMomentum = momentum;

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

	// Don't make things shoot you up into the air unless it's specific damage types
	if(class<P2Damage>(damageType) == None
			|| !class<P2Damage>(damageType).default.bAllowZThrow)
	{
		if(Physics == PHYS_Walking)
			momentum.z=0;
	}

	// he needs to catch on fire because this was a real fire (not just a match)
	if(ClassIsChildOf(damageType, class'BurnedDamage'))
	{
		if(lambc != None)
			lambc.CatchOnFire(FPSPawn(instigatedBy), (damageType==class'NapalmDamage'));
		else
			SetOnFire(FPSPawn(instigatedBy), (damageType==class'NapalmDamage'));
	}

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	// Only if we're a normal cow, do we allow ourselves to get hurt here
	if(!bZombie)
	{
		Health -= actualDamage;
		if ( HitLocation == vect(0,0,0) )
			HitLocation = Location;
		if ( bAlreadyDead )
		{
			// Added in level thing here because Warn is particular to the engine i think.
			Level.Warn(self$" took regular damage "$damagetype$" from "$instigatedby$" while already dead at "$Level.TimeSeconds);
			ChunkUp(-1 * Health);
			return;
		}
	}

	// Send the real momentum to this function, please
	PlayHit(actualDamage, hitLocation, damageType, OrigMomentum);

	if ( Health <= 0 
		&& !bZombie)
	{
		// If fire has killed me,
		// or we're on fire and we died,
		// then swap to my burn victim mesh
		if(damageType == class'OnFireDamage'
			|| ClassIsChildOf(damageType, class'BurnedDamage')
			|| MyBodyFire != None)
			SwapToBurnVictim();

		// Check to chunk if we're killed by a certain thing or group
		TryToChunk(Instigator, DamageType);

		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.Controller; //FIXME what if killer died before killing you
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = momentum;
		Died(Killer, damageType, HitLocation);
	}
	else
	{
		AddVelocity( momentum ); 
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}

	AddVelocity( momentum ); 
	if ( Controller != None )
		Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);

	MakeNoise(1.0); 

	// If you're infected, be infected even in death
	if(damageType == class'ChemDamage')
	{
		SetInfected(FPSPawn(instigatedBy));
		return;
	}

	// If I'm on fire and it's the fire on me, that's hurting me, then
	// darken me, based on how much life I have left
	if(damageType == class'OnFireDamage')
	{
		AmbientGlow = (Health*default.AmbientGlow)/HealthMax; // because 255 is insane pulsing
	}
	// This animal needs to shake a lot from getting electricuted.
	if(damageType == class'ElectricalDamage'
		&& LambController(Controller) != None)
	{
		LambController(Controller).GetShocked(P2Pawn(instigatedBy), HitLocation);
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Take half on fire damage
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local vector Rot, Diff, dmom;
	local float dot1, dot2, StartDamage, HeadDamage;
	local Controller Killer;
	local bool bNoSuper, bBodyHit;
	local coords usec;

	StartDamage = Damage;

	// Take half on all fire damage
	if(ClassIsChildOf(damageType, class'BurnedDamage')
		|| damageType == class'OnFireDamage')
		Damage/=2;
	// Scale down damages
	if(ClassIsChildOf(damageType, class'SledgeDamage'))
		Damage = TakesSledgeDamage*Damage;
	// My own damage is reduced
	if(ClassIsChildOf(damageType, MyDamage))
		Damage = TakesCowDamage*Damage;

	// See if it's hitting my head
	Rot = vector(Rotation);
	diff = hitlocation - location;
	dmom.z=0;
	dmom = Normal(diff);
	dot1 = Rot Dot dmom;
	usec = GetBoneCoords(HEAD_BONE);

	// Zombie cow's severed head was blown up somewhere, so now he dies
	if(ClassIsChildOf(damageType, class'HeadKillDamage'))
	{
		// kills it instantly
		Health=0;
		// pawn died
		if ( instigatedBy != None )
			Killer = InstigatedBy.GetKillerController();
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = Momentum / Mass;
		Died(Killer, damageType, HitLocation);
		bNoSuper=true;
	}
	else if(dot1 > HIT_HEAD_DOT)
	{
		// If this explodes then head, then do so, and kill it instantly
		if(ClassIsChildOf(damageType, HeadExplodeDamageClass)
			|| (ClassIsChildOf(damageType, HeadExplodeDamageClass2)
				&& VSize(InstigatedBy.Location - Location) < HeadExplodeMaxDist2))
		{
			// kills it instantly
			Health=0;
			// do effects
			ExplodedHead(InstigatedBy);
			// pawn died
			if ( instigatedBy != None )
				Killer = InstigatedBy.GetKillerController();
			if ( bPhysicsAnimUpdate )
				TearOffMomentum = Momentum / Mass;
			Died(Killer, damageType, HitLocation);
			bNoSuper=true;
		}
		else // Check for some damages to potentially cut the head off
		{
			// Scythe damage cuts off the head in one try
			if(ClassIsChildOf(damageType, class'ScytheDamage'))
			{
				HeadDamage = HeadTakesScytheDamage*StartDamage;
			}
			// Machete damage takes several hits to cut off the head
			else if(ClassIsChildOf(damageType, class'MacheteDamage'))
			{
				HeadDamage = HeadTakesMacheteDamage*StartDamage;
			}
			HeadHealth -= HeadDamage;

			// Head comes off, when the health is 0 or lower
			if(HeadHealth <= 0)
			{
				// kills it instantly
				Health=0;
				// do effects
				SeverHead();
				// Normal cows die from their head coming off, zombies don't
				if(!bZombie)
				{
					// pawn died
					if ( instigatedBy != None )
						Killer = InstigatedBy.GetKillerController();
					if ( bPhysicsAnimUpdate )
						TearOffMomentum = Momentum / Mass;
					Died(Killer, damageType, HitLocation);
				}
				else // Tell them to get mad about their head missing
				{
					if(MadCowController(Controller) != None)
						MadCowController(Controller).HeadSevered(InstigatedBy);
				}
				bNoSuper=true;
			}
		}
	}

	if(!bNoSuper)
	{
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
				bBodyHit=true;
			}
		}
		else
		{
			bBodyHit=true;
		}

		if(bBodyHit)
		{
			TakeDamageSuper(Damage, instigatedBy, hitlocation, momentum, damageType);
		}
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


simulated function name GetAnimPreCharge()
{
	return 'precharge';
}

simulated function name GetAnimCharge()
{
	return 'charge';
}

simulated function name GetAnimFinishCharge()
{
	return 'finishcharge';
}

simulated function name GetAnimStand()
{
	return 'stand';
}

simulated function name GetAnimWalk()
{
	return 'walk';
}

simulated function name GetAnimRun()
{
	return 'run';
}

simulated function name GetAnimFeed()
{
	return 'feed';
}

simulated function name GetAnimReeling()
{
	return 'feed';
}

simulated function name GetAnimButtHit()
{
	return 'butthit';
}

simulated function name GetAnimKick()
{
	return 'backkick';
}

simulated function name GetAnimButtStand()
{
	return 'buttstand';
}

simulated function name GetAnimDeath()
{
	if(bHasHead)
		return 'die';
	else
		return 'diehead';
}

simulated function SetupAnims()
{
	// Make sure to blend all this channel in, ie, always play all of this channel when not 
	// playing something else, because this is the main movement channel
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	// Turn on this channel too
	SetNormalRotationRate();
	LoopAnim(GetAnimStand(), 1.0, 0.15, MOVEMENTCHANNEL);
}


simulated function SetAnimStanding()
{
	//AnimBlendParams(MOVEMENTCHANNEL,1.0);
	StopRotationRate();
	LoopAnim(GetAnimStand(), 1.0, 0.15);//, MOVEMENTCHANNEL);
}

simulated function SetAnimWalking()
{
	GroundSpeed = default.GroundSpeed;
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	SetNormalRotationRate();
	LoopAnim(GetAnimWalk(), 1.0, 0.15, MOVEMENTCHANNEL);// + FRand()*0.4);
}


simulated function SetAnimRunning()
{
	local name runanim;

	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	SetFastRotationRate();
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

function PlayAnimFeeding()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimFeed(), 1.0, 0.2);
}

function PlayAnimReeling()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimReeling(), 1.0, 0.2);
}

function PlayAnimButtHit()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimButtHit(), 1.0, 0.2);
}

function PlayAnimButtStand()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimButtStand(), 1.0, 0.2);
}

function PlayAnimPreCharge()
{
	SetFastRotationRate();
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimPreCharge(), 1.0, 0.2);
}

function PlayAnimFinishCharge()
{
	SetFastRotationRate();
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimFinishCharge(), 1.0, 0.2);
}

function PlayAnimKick()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimKick(), 1.0, 0.2);
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
	TweenAnim(GetAnimStand(),0.1,TAKEHITCHANNEL);

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
								self, HitActor.Location, HitMomentum, MyDamage);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Ways to hurt people
///////////////////////////////////////////////////////////////////////////////
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
// Someone's messing with you from behind, kick them
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_BackKick()
{
	local vector HitPos, Rot, HitMomentum;

	// for point around where to hurt things
	HitPos = Location;
	Rot = vector(Rotation);
	Rot.z = 0;
	// move it backwards
	HitPos -= 0.8*CollisionRadius*Rot;
	// form momentum
	HitMomentum.x = -Rot.x;
	HitMomentum.y = -Rot.y;
	HitMomentum.z = 0.5;
	HitMomentum*=(BACKKICK_IMPULSE);

//	log("hurting stuff in front from come down "$HitPos$" loc "$Location$" momentum "$HitMomentum);

	HurtThings(HitPos, HitMomentum,
				BACKKICK_DAMAGE_RADIUS,
				BACKKICK_DAMAGE);
}

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

///////////////////////////////////////////////////////////////////////////////
// Shrink the head bone done, add the stump, add stump blood
///////////////////////////////////////////////////////////////////////////////
function ShrinkHeadAddStump(coords usec, optional bool bExploded)
{
	local P2Emitter sblood;

	// Stick on stump
	MyNeckStump = spawn(NeckStumpClass,self,,usec.origin);
	AttachToBone(MyNeckStump, NECK_BONE);
	MyNeckStump.SetupStump(Skins[0], AmbientGlow, bExploded);

	// Totally shrink the head
	SetBoneScale(0, 0.0, HEAD_BONE);
}

///////////////////////////////////////////////////////////////////////////////
// Do visual/sound effects for exploding head part
///////////////////////////////////////////////////////////////////////////////
function DoHeadExplosionEffects(coords usec)
{
	local P2Emitter headeffects;
	local CowHeadChunkFall chunkeffects;

	// Do blood effects
	headeffects = spawn(HeadExplodeClass, , ,usec.origin);
	headeffects.PlaySound(ExplodeHeadSound,,,,100,GetRandPitch()-0.3);
	if(HeadChunkClass != None)
	{
		chunkeffects = spawn(HeadChunkClass, , ,usec.origin);
		// If we don't have enough room, get rid of the chunks
		if(!chunkeffects.SetupHeight())
			chunkeffects.Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Blow up head in a big way
///////////////////////////////////////////////////////////////////////////////
function ExplodedHead(Pawn InstigatedBy)
{
	local coords usec;
	local Actor HitActor;
	local vector hitnormal, hitlocation, checkpoint;

	usec = GetBoneCoords(HEAD_BONE);

	if(bHasHead
		&& class'P2Player'.static.BloodMode())
	{
		bHasHead=false;

		ShrinkHeadAddStump(usec, true);

		DoHeadExplosionEffects(usec);

		// spawn blood splat on the ground
		checkpoint = usec.origin;
		checkpoint.z-=SPLAT_CHECK;
		//log("momentum "$Momentum);
		HitActor = Trace(HitLocation, HitNormal, checkpoint, usec.origin);

		if ( HitActor != None
			&& HitActor.bStatic ) 
			spawn(class'BloodMachineGunSplatMaker',self,,HitLocation,rotator(HitNormal));

		// Tell the dude if he did it
		if(AWDude(InstigatedBy) != None)
			AWDude(InstigatedBy).CrushedHead(self);
	}
	else
	{
		spawn(class'DustHitPuff',,,usec.origin);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Cut off cow head
///////////////////////////////////////////////////////////////////////////////
function SeverHead()
{
	local coords usec;
	local P2Emitter headeffects;
	local CowHeadChunkFall chunkeffects;
	local Actor HitActor;
	local vector hitnormal, hitlocation, checkpoint;
	local AWHeadCow myhead;
	local vector usemom;
	local SideSprayBlood sprayb;

	usec = GetBoneCoords(HEAD_BONE);

	if(bHasHead
		&& class'P2Player'.static.BloodMode())
	{
		bHasHead=false;

		ShrinkHeadAddStump(usec);

		// Do blood effects
		//sprayb = spawn(SprayBloodClass,self,,usec.Origin);
		// set a random directon for the blood, basically in line with the neck
		//sprayb.SetSpray(-usec.ZAxis + 0.1*VRand());

		// spawn blood splat on the ground
		checkpoint = usec.origin;
		checkpoint.z-=SPLAT_CHECK;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, usec.origin);

		// General blood cloud
		spawn(class'PoppedHeadEffects',,,usec.origin);

		if ( HitActor != None
			&& HitActor.bStatic ) 
			spawn(class'BloodMachineGunSplatMaker',self,,HitLocation,rotator(HitNormal));

		// Spawn a head
		MyHead = spawn(HeadClass, , , usec.origin, rotator(-usec.ZAxis), Skins[0]);

		if(MyHead != None)
		{
			if(AWHeadMadCow(MyHead) != None)
				AWHeadMadCow(MyHead).MyZombie = self;
			MyHead.GotoState('Dead');

			// Send it flying
			usemom = (VRand()*HEAD_FLY_SPEED + Velocity)*MyHead.Mass;
			MyHead.GiveMomentum(usemom);
		}
		else // show blood explosion, and get rid of head, but it just couldn't come
			// of for whatever reason, tell the zombie he's really dead, also
		{
			DoHeadExplosionEffects(usec);
		}
	}
	else
	{
		spawn(class'DustHitPuff',,,usec.origin);
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
	// Take half on fire damage
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
	{
		local vector Rot, Diff, dmom;
		local float dot1, dot2, StartDamage, HeadDamage;
		local Controller Killer;
		local bool bNoSuper, bBodyHit;
		local coords usec;

		StartDamage = Damage;

		// See if it's hitting my head
		Rot = vector(Rotation);
		diff = hitlocation - location;
		dmom.z=0;
		dmom = Normal(diff);
		dot1 = Rot Dot dmom;
		usec = GetBoneCoords(HEAD_BONE);

		if(dot1 > HIT_HEAD_DOT)
		{
			// If this explodes then head, then do so, and kill it instantly
			if(ClassIsChildOf(damageType, HeadExplodeDamageClass)
				|| ClassIsChildOf(damageType, HeadExplodeDamageClass2))
			{
				// do effects
				ExplodedHead(InstigatedBy);
				bNoSuper=true;
			}
			else // Check for some damages to potentially cut the head off
			{
				// Scythe damage cuts off the head in one try
				if(ClassIsChildOf(damageType, class'ScytheDamage'))
				{
					HeadDamage = HeadTakesScytheDamage*StartDamage;
				}
				// Machete damage takes several hits to cut off the head
				else if(ClassIsChildOf(damageType, class'MacheteDamage'))
				{
					HeadDamage = HeadTakesMacheteDamage*StartDamage;
				}
				HeadHealth -= HeadDamage;

				// Head comes off, when the health is 0 or lower
				if(HeadHealth <= 0)
				{
					// kills it instantly
					Health=0;
					// do effects
					SeverHead();
					// pawn died
					if ( instigatedBy != None )
						Killer = InstigatedBy.GetKillerController();
					if ( bPhysicsAnimUpdate )
						TearOffMomentum = Momentum / Mass;
					Died(Killer, damageType, HitLocation);
					bNoSuper=true;
				}
			}
		}

		if(!bNoSuper)
			Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

}

defaultproperties
{
     FeedFreq=0.500000
     StandThenFeedFreq=0.500000
     CalmDownFreq=0.700000
     TakesSledgeDamage=0.200000
     TakesCowDamage=0.200000
     FastRotationRate=(Pitch=4096,Yaw=40000,Roll=3072)
     MyDamage=Class'AWEffects.CowSmashDamage'
     bHasHead=True
     HeadExplodeClass=Class'AWEffects.CowHeadExplode'
     HeadChunkClass=Class'AWEffects.CowHeadChunkFall'
     HeadExplodeDamageClass=Class'SledgeDamage'
     HeadExplodeDamageClass2=Class'ShotGunDamage'
     HeadExplodeMaxDist2=300.000000
     ExplodeHeadSound=Sound'AWSoundFX.Cow.CowHeadExplode'
     HammerStuckClass=Class'AWPawns.ButtHammer'
     HammerPickupClass=Class'AWInventory.SledgePickup'
     ButtHitSound=Sound'AWSoundFX.Cow.CowButtHit'
     ButtPopSound=Sound'AWSoundFX.Cow.cowbuttpop'
     ButtHitClass=Class'AWEffects.ButtHitEffects'
     ButtPopClass=Class'AWEffects.ButtPopEffects'
     ChargeGroundSpeed=1500.000000
     ChargeDustClass=Class'AWEffects.CowChargeDust'
     FinishDustClass=Class'AWEffects.CowFinishDust'
     NeckStumpClass=Class'AWPawns.StumpCow'
     SprayBloodClass=Class'AWEffects.SideSprayBlood'
     CowButtHit=Sound'AWSoundFX.Cow.cowconfusedmoo'
     CowNormalMoo(0)=Sound'AWSoundFX.Cow.cowmoo1'
     CowNormalMoo(1)=Sound'AWSoundFX.Cow.cowmoo2'
     CowNormalMoo(2)=Sound'AWSoundFX.Cow.cowmoo3'
     CowHurtMoo(0)=Sound'AWSoundFX.Cow.cowhurt1'
     CowHurtMoo(1)=Sound'AWSoundFX.Cow.cowhurt2'
     CowDieMoo=Sound'AWSoundFX.Cow.cowdie'
     PreChargeSound=Sound'AWSoundFX.Cow.cowprecharging'
     ChargingSound=Sound'AWSoundFX.Cow.cowcharge'
     ChargingVolume=2.000000
     ChargingRadius=200.000000
     HeadHealth=50.000000
     HeadTakesScytheDamage=1.000000
     HeadTakesMacheteDamage=0.300000
     HeadClass=Class'AWPawns.AWHeadCow'
     TorsoFireClass=Class'FX.FireElephantEmitter'
     HealthMax=350.000000
     bCanBeBaseForPawns=True
     GroundSpeed=500.000000
     WalkingPct=0.020000
     ControllerClass=Class'AWPawns.AWCowController'
     LODBias=3.000000
     Mesh=SkeletalMesh'AwAnimals.meshCow'
     Skins(0)=Texture'AnimalSkins.Cow'
     TransientSoundRadius=100.000000
     CollisionRadius=120.000000
     CollisionHeight=70.000000
     Mass=200.000000
     RotationRate=(Pitch=4096,Yaw=10000,Roll=3072)
}
