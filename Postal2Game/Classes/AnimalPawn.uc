///////////////////////////////////////////////////////////////////////////////
// Animal pawn for Postal 2
// Different from P2Pawn because that's for people.
///////////////////////////////////////////////////////////////////////////////
class AnimalPawn extends FPSPawn
	notplaceable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

var bool bDangerous;		// If the animal is capable of harming people in this
							// state, this is true

// animation
var bool bTrotting;			// Animation for a double-time walk
var float TrottingPct;	// Percent of motion for movement when trotting. 0-1.

// effects
var Material BurnSkin;			// what I switch to after I die from fire
var Emitter UrineStream;		// What we use for our pee.

var (PawnAttributes) float TakeDamageModifier;	// General modification of damage done to *me* not me doing
												// to other people
var (PawnAttributes) bool bGunCrazy;	// Set for crazy animals
var (PawnAttributes) bool bCannotTrain;	// If true, we can't make this dog our friend
var (PawnAttributes) bool bElephantNoRearUp;		// If true, disables "rearing up" on hindlegs (for putting elephants in confined spaces)
var (PawnAttributes) string HateGangTag;		// Name of gang we hate (dogs only)

var Sound ExplodeSound;
var class<FireTorsoEmitter> TorsoFireClass; // fire emitter for this pawn to catch on fire with

var bool bKickedByPlayer;	// Kamek 4-23 -- for the kick 30 dogs achievement,
							// we don't want the dude to kick the same dog 30
							// times, so record when they kick us and don't
							// count it if they kick us again.
var bool bHighOnCatnip;	// used in the new catpawn							

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////

const RAND_ATTRIBUTE_DEFAULT=	0.2;
const REPORT_DEATH_RADIUS	=	4028;
const BLOOD_DRIP_GRAVITY	=	-0.7;
const DIST_TO_WALL_FOR_BLOODSPLAT	=	450;
const DRIP_FLOOR_Z_CHECK	=	800;

const PREDATOR_ALERT_RADIUS	=	 1024;

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


///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	// See if the GameMod wants to do anything.
	P2GameInfoSingle(Level.Game).BaseMod.ModifyAppearance(Self);

	Super.PostBeginPlay();
	SetupAnims();
}

// Change by NickP: MP fix
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (Role < ROLE_Authority)
	{
		AnimBlendParams(MOVEMENTCHANNEL,0.0);
		if (Health <= 0)
			PlayAnim(GetAnimDeath(), 10000);
	}
}
// End

///////////////////////////////////////////////////////////////////////////////
// Clean up
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	// Make sure if we instantly got chunked up at some point, to add us
	// to the list to be remembered, if we're persistent. 
	// This is because normally dead people are counted up at the end of the
	// level, but if you got removed early (chunked up), add us now.
	if(bPersistent
		&& P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& bChunkedUp)
		P2GameInfoSingle(Level.Game).TheGameState.AddPersistentPawn(self);

	if(UrineStream != None)
		UrineStream.Destroy();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Play special anims to 'reinit' a ragdoll (it doesn't get saved well)
///////////////////////////////////////////////////////////////////////////////
function SetupDeadAfterLoad()
{
	PlayAnim(GetAnimDeath(),10000);
}

///////////////////////////////////////////////////////////////////////////////
// Restore your animation if you had one, otherwise, just changeanimation.
// Don't call Super here! We need to override it.
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	if(!bPostLoadCalled)
	{
		bPostLoadCalled=true;
		// Force the animations to restart
		bInitializeAnimation=false;
		if(Health <= 0)
			SetupDeadAfterLoad();
		else
		{
			//log(self$" PostLoadGame, save anim "$SaveAnim$" save frame "$SaveFrame$" rate "$SaveRate$" controller "$Controller);
			if(LambController(Controller) == None
				|| LambController(Controller).ChangeAnimationOnLoad())
				ChangeAnimation();
			else if(SaveAnim != '')
				PlayAnimAt(SaveAnim, SaveRate, , , SaveFrame);
		}
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
			p2p = P2Player(Killer);

			// InterestPawn is giving MyPawn the owninv.
			bCompleted = checkg.CheckForErrandCompletion(None, 
											None, 
											self, 
											p2p,
											false);

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
// Check to remove us from the list
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local FPSGameInfo checkg;

	// If not already dead or already destroyed, don't continue
	if ( bDeleteMe || Health > 0)
		return;

	// If I'm used for an errand, check to see if I did anything important
	CheckForErrandCompleteOnDeath(Killer);

	// If I got killed by the player, tell the GameState so they can rack up our kill count
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
		P2GameInfoSingle(Level.Game).TheGameState.PawnKilledByDude(Self, DamageType);

	Super.Died(Killer, damageType, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
// redetermine the direction of the stream
///////////////////////////////////////////////////////////////////////////////
function SnapStream()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Tell your enemy where you are, so they can attack you
///////////////////////////////////////////////////////////////////////////////
function AlertPredator()
{
	// STUB
}

/*
///////////////////////////////////////////////////////////////////////////////
// Update the urine stream
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// continuously update the stream if we have one
	if(UrineStream != None)
	{
		SnapStream();
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
//
// These functions are called by the pawn or the controller to request general
// types of animations: stand, walk, crouch, shoot, jump, get hit and so on.
//
// Many of these are defined by the engine, while others have been added
// specifically for this game.
//
// Each of these functions should be written to figure out which SetAnimXXXXX
// function should be called, and then to call it.  They shouldn't be directly
// setting up any animations.  They take care of the "higher level" logic and
// leave the details to the SetAnimXXXXX group.
// 
///////////////////////////////////////////////////////////////////////////////

simulated function PlayWaiting()
	{
	if ( Physics == PHYS_Flying )
		SetAnimFlying();
	else if ( Physics == PHYS_Falling )
		{
		if ( !IsAnimating(FALLINGCHANNEL) )
			PlayFalling();
		}
	else
		SetAnimStanding();
	}

simulated function PlayMoving()
{
	if ((Physics == PHYS_None) || ((Controller != None) && Controller.bPreparingMove) )
	{
		// Controller is preparing move - not really moving
		PlayWaiting();
	}
	else
	{
		if ( Physics == PHYS_Walking )
		{
			if(bTrotting)
				SetAnimTrotting();
			else if ( bIsWalking )
				SetAnimWalking();
			else
				SetAnimRunning();
		}
		//else if ( Physics == PHYS_Swimming )
		//	SetAnimSwimming();
		else if ( Physics == PHYS_Ladder )
			SetAnimClimbing();
		else if ( Physics == PHYS_Flying )
			SetAnimFlying();
		else
		{
			if(bTrotting)
				SetAnimTrotting();
			else if ( bIsWalking )
				SetAnimWalking();
			else
				SetAnimRunning();
		}
	}
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
	}

	return 0.0;
}

///////////////////////////////////////////////////////////////////////////////
// Play looping animation only if not already animating
///////////////////////////////////////////////////////////////////////////////
simulated function LoopIfNeeded(name NewAnim, float NewRate)
	{
	local name OldAnim;
	local float frame,rate;
	
	GetAnimParams(0,OldAnim,frame,rate);
	
	// FIXME - call function to get tween time
	if ( (NewAnim != OldAnim) || (NewRate != Rate) || !IsAnimating(0) )
		LoopAnim(NewAnim, NewRate, 0.1);
	else
		LoopAnim(NewAnim, NewRate);
	}

///////////////////////////////////////////////////////////////////////////////
// forward decs.
///////////////////////////////////////////////////////////////////////////////
simulated function SetupAnims();
simulated function SetAnimWalking()
{
	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		SimAnimChannel = MOVEMENTCHANNEL;
	}
	// End
}
simulated function SetAnimRunning()
{
	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		SimAnimChannel = MOVEMENTCHANNEL;
	}
	// End
}
simulated function SetAnimRunningScared()
{
	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		SimAnimChannel = MOVEMENTCHANNEL;
	}
	// End
}
simulated function SetAnimFlying();
simulated function SetAnimClimbing();
simulated function SetAnimStanding();
simulated function PlayAnimLimping();
simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc);
simulated function name GetAnimDeath();

// Generic functions are declared here, so later in People.Elephant and other
// animal pawns, we can flesh them out specifically. But in order to get around the
// dependencies caused when we call these things in their controllers from AIPack and the fact
// the pawns need to list their controllers in their defaultprops and that we don't want
// ElephantPawn and ElephantBasePawn and all that crap, we make some generic functions here.
simulated function PlayAnimStanding();
simulated function PlayHappySound();
simulated function PlayScaredSound();
simulated function PlayHurtSound();
simulated function PlayThrownSound();
simulated function PlayContentSound();
simulated function PlayAngrySound();
simulated function PlayGetAngered();
simulated function PlayGetScared();
simulated function PlayAttack1();
simulated function PlayAttack2();
simulated function PlayInvestigate();
simulated function PlaySitDown();
simulated function PlaySitting();
simulated function PlayStandUp();
simulated function PlayLayDown();
simulated function PlayLaying();
simulated function PlayDruggedOut();
simulated function PlayGetBackUp();
simulated function PlayPissing(float AnimSpeed);
simulated function PlayCovering();
simulated function SetAnimTrotting()
{
	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		SimAnimChannel = MOVEMENTCHANNEL;
	}
	// End
}
simulated function SetToTrot(bool bSet);
simulated function PlayShockedAnim();
simulated function PlayGrabPickupOnGround();


///////////////////////////////////////////////////////////////////////////////
// Start your urine feeder
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_PissStart()
{
}

///////////////////////////////////////////////////////////////////////////////
// Stop your urine feeder
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_PissStop()
{
}

///////////////////////////////////////////////////////////////////////////////
// Move blood pool to where you are, attach, when this is called
///////////////////////////////////////////////////////////////////////////////
function AttachBloodEffectsWhenDead()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	bPlayedDeath = true;
	if ( bPhysicsAnimUpdate )
	{
		bTearOff = true;
		bReplicateMovement = false;
		HitDamageType = DamageType;
		TakeHitLocation = HitLoc;
		if ( (HitDamageType != None) && (HitDamageType.default.GibModifier >= 100) )
			ChunkUp(-1 * Health);
	}

	Velocity += TearOffMomentum;
	SetPhysics(PHYS_Falling);

	if ( Physics != PHYS_KarmaRagDoll )
	{
		ChangeAnimation();
		AnimBlendToAlpha(TAKEHITCHANNEL,0,0.0);
		AnimBlendToAlpha(FALLINGCHANNEL,0,0.0);
		AnimBlendToAlpha(MOVEMENTCHANNEL,0,0.0);

		// Change by NickP: MP fix
		if (bReplicateAnimations)
		{
			SimAnimChannel = RESTINGPOSECHANNEL;
		}
		// End

		// If you start dead, then play your death animation
		// but warp to the end of it (so it's like you're posing in the last frame
		// of the animation)
		if(PawnInitialState == EPawnInitialState.EP_Dead)
		{
			if(StartAnimation != '')
				PlayAnim(StartAnimation, 10000);
			else
				PlayAnim(GetAnimDeath(), 10000);
		}
		else	// Otherwise, play the proper animation
			PlayDyingAnim(DamageType,HitLoc);
	}
	else
		StopAnimating();

	// Set what happened to us on death
//	DyingDamageType = DamageType;
//	DyingHitLocation = HitLoc;

	// Check to make blood pool below us.
	// See if we already have blood squrting out of us in some other spot first
	// --if so, don't make this
	AttachBloodEffectsWhenDead();

	bPlayedDeath = true;

	GotoState('Dying');
}

simulated event PlayFalling()
{
	PlayJump();
}


simulated event PlayJump()
{
}

///////////////////////////////////////////////////////////////////////////////
// Allow the pawn to turn off certain channels when having an AI script
// action play an animation
///////////////////////////////////////////////////////////////////////////////
function ActionPlayAnim( name BaseAnim, float AnimRate, float BlendInTime)
{
	AnimBlendParams(TAKEHITCHANNEL,0.0);
	AnimBlendParams(FALLINGCHANNEL,0.0);
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(BaseAnim,AnimRate,BlendInTime);
}
function ActionLoopAnim( name BaseAnim, float AnimRate)
{
//	AnimBlendParams(TAKEHITCHANNEL,0.0);
//	AnimBlendParams(FALLINGCHANNEL,0.0);
//	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	LoopAnim(BaseAnim,AnimRate);
}

///////////////////////////////////////////////////////////////////////////////
// Handle end of animation on specified channel
///////////////////////////////////////////////////////////////////////////////
simulated event AnimEnd(int Channel)
	{
	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		if (Physics == PHYS_Falling)
			SimAnimChannel = FALLINGCHANNEL;
		else if (VSize(Acceleration) > 1)
			SimAnimChannel = MOVEMENTCHANNEL;
		else SimAnimChannel = RESTINGPOSECHANNEL;
	}
	// End

	if ( Channel == TAKEHITCHANNEL )
		AnimBlendToAlpha(TAKEHITCHANNEL,0,0.1);
//	else
//		PlayMoving();
	}

///////////////////////////////////////////////////////////////////////////////
// This is called whenever anything that might effect the animation has
// changed (physics, accelleration, status, weapons, etc.)
///////////////////////////////////////////////////////////////////////////////
simulated event ChangeAnimation()
	{
	// Setup new waiting and moving animations.  It's lame setting them up
	// this way, but it's how they did it, so we're folling along.
	PlayWaiting();
	PlayMoving();

	// If not falling, don't blend with falling animation
	if ( Physics != PHYS_Falling )
		AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
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
		spawn(class'BloodDripSplatMaker',self,,HitLocation,Rotator(HitNormal));
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
	spawn(class'BloodImpactMaker',self,,BloodHitLocation+BloodOffset, Rotator(dir));
	////////////////
	// Blood that shoots onto the wall 
	// Check to see if you're close enough to the wall, to squirt blood on it.
	// Do this by coming out of the actor where we hit and continue along the path
	// that goes from the original hit point, toward the player. (So look 
	// behind the player)
	checkpoint = BloodHitLocation + DIST_TO_WALL_FOR_BLOODSPLAT*Normal(Momentum);
	//log("momentum "$Momentum);
	HitActor = Trace(HitLocation, HitNormal, checkpoint, BloodHitLocation, true);

	if ( HitActor != None
		&& HitActor.bStatic ) 
//	if(LevelInfo(HitActor) != None
//		|| TerrainInfo(HitActor) != None
//		|| StaticMeshActor(HitActor) != None
//		|| Brush(HitActor) != None)
	{
		spawn(class'BloodMachineGunSplatMaker',self,,Location,rotator(HitNormal));
	}

	////////////////
	// Drips of blood on the ground around you (smaller)
	if(FRand() <= 0.7)
	{
		DripBloodOnGround(Momentum);
	}
}

///////////////////////////////////////////////////////////////////////////////
//	Does damage effects (blood) and plays hit animations
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
				BloodHit(HitLocation, Momentum);
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
	if ( (Physics == PHYS_Walking
		&& NewVelocity.z != 0)
		|| (((Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) && (NewVelocity.Z > Default.JumpZ)) )
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

///////////////////////////////////////////////////////////////////////////////
// Swap out to our burned mesh
///////////////////////////////////////////////////////////////////////////////
function SwapToBurnVictim()
{
	if(class'P2Player'.static.BloodMode())
	{
		// Set my body skin
		Skins[0] = BurnSkin;

		AmbientGlow=default.AmbientGlow;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Cat's and the like don't hurt people by jumping on them
///////////////////////////////////////////////////////////////////////////////
singular event BaseChange()
{
	local float decorMass;
	
	if(AnimalController(Controller) != None)
		AnimalController(Controller).BaseChange();
}

///////////////////////////////////////////////////////////////////////////////
// Check to chunk up from some attacks/attackers
///////////////////////////////////////////////////////////////////////////////
function bool TryToChunk(Pawn instigatedBy, class<DamageType> damageType)
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
//  Handle effects side of things for body fire
///////////////////////////////////////////////////////////////////////////////
function SetOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	local FireTorsoEmitter tfire;

	if(MyBodyFire == None)
	{
		tfire = Spawn(TorsoFireClass,self,,Location);
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

	// Send the real momentum to this function, please
	PlayHit(actualDamage, hitLocation, damageType, OrigMomentum);
	if ( Health <= 0 )
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
	
	// Kamek 4-23
	// If the dude kicks us, record it and give them an achievement.
	if (ClassIsChildOf(DamageType, class'KickingDamage') && PlayerController(InstigatedBy.Controller) != None && !bKickedByPlayer && Controller.IsA('DogController'))
	{
		bKickedByPlayer = true;	// Record it so they don't get points for kicking us again
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(InstigatedBy.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(InstigatedBy.Controller),'DogsKicked',1,true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
function float GetRandPitch()
{
	return (0.96 + FRand()*0.08);
}

///////////////////////////////////////////////////////////////////////////////
// Generate a broader pitch
///////////////////////////////////////////////////////////////////////////////
function float GenPitch()
{
	return 0.9+FRand()*0.4;
}

///////////////////////////////////////////////////////////////////////////////
// blow up into little pieces (implemented in subclass)		
///////////////////////////////////////////////////////////////////////////////
simulated function ChunkUp(int Damage)
{
	if ( Controller != None )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
			Controller.Destroy();
	}
	//	destroy();
	//log("tried to chunk me up");
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
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dying
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
State Dying
{
	///////////////////////////////////////////////////////////////////////////////
	// Disconnect my variable from my torso fire, now or later
	///////////////////////////////////////////////////////////////////////////////
	function UnhookPawnFromFire()
	{
		GotoState('Dying', 'WaitToResetFire');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		// If the player isn't around and the settings let bodies disappear
		// then consider removing yourself from the world
		// If the pawn is persistent, we can't let the body disappear--gamestate
		// needs to record it being dead on a level transfer.
		if(P2GameInfo(Level.Game).GetBodiesMax() == 0
			&& !bPersistent
			&& bBodyDisappears
			&& bReportDeath)
		{
			if ( !PlayerCanSeeMe() )
				Destroy();
			else
				SetTimer(2.0, false);	
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Be able to still see blood as something dies
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
	{
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

		PlayHit(Damage, hitLocation, damageType, Momentum);
	}
WaitToResetFire:
	Sleep(FIRE_RESET_TIME);
	MyBodyFire=None;
Begin:
}

defaultproperties
{
	// Change by NickP: MP fix
	bReplicateMovementAnim=false
	// End

	bTravel=true
    ControllerClass=class'AnimalController'
	HealthMax=50
	bCanPickupInventory=false
	BurnSkin=Texture'ChameleonSkins.Special.BurnVictim'
	TakeDamageModifier=1.0
	ExplodeSound=Sound'WeaponSounds.flesh_explode'
	bCanCrouch=false
	bCannotTrain=false
}
