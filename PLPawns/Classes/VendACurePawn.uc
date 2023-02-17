///////////////////////////////////////////////////////////////////////////////
// VendACurePawn
// Copyright 2014, Running With Scissors, Inc.
//
// Mobile automated Vend-A-Cure stations that look and sound suspiciously
// similar to a well-known robot from another franchise :O
///////////////////////////////////////////////////////////////////////////////
class VendACurePawn extends PersonPawn
	placeable
	hidecategories(Boltons,Cell,Character,Police);

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() Sound DeactivateSound;
var() Sound Idle1Sound;
var() Sound Idle2Sound;
var() Sound Melee1Sound;
var() Sound Melee2Sound;
var() Sound RangedSound;
var() Sound RunSound;
var() Sound WalkSound;

var() Material EyesNormal, EyesLove, EyesAngry;		// Materials for normal, loving, and angry eyes
var() class<Emitter> DestructionEmitter;			// Emitter to spawn when destroyed

var name VendACurePickupBone;
var() array< class<P2PowerupPickup> > VendACurePickups;

var() array<name> PatrolNodeTags;

var(Events) name EventPissedIn;						// Event to trigger when we deactivate after being pissed in (as opposed to just being shot and killed)

var VendACureController VendACureController;

const EYES_INDEX = 1;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Functions specific to VACXJ2 Craptrap
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// SetEyes
// Sets eye texture
///////////////////////////////////////////////////////////////////////////////
function SetEyes(Material NewEyes)
{
	Skins[EYES_INDEX] = NewEyes;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Override functions
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool AllowRagdoll(class<DamageType> DamageType);	// No ragdolls allowed!

///////////////////////////////////////////////////////////////////////////////
// SetupHead
// We don't want a regular head for these guys.
///////////////////////////////////////////////////////////////////////////////
function SetupHead();

///////////////////////////////////////////////////////////////////////////////
// Adds all the required equipment and picks out the urethra.
// Do this here so we access to the inventory package for specific things
// like HandsWeapon and UrethraWeapon.
///////////////////////////////////////////////////////////////////////////////
//function AddDefaultInventory()
//{
//}

/** For some reason this gets automatically overriding my code, so stub it! */
event SetWalking(bool bNewIsWalking);

event SetPawnWalking(bool bNewIsWalking) {
	if (bNewIsWalking != bIsWalking) {
		bIsWalking = bNewIsWalking;
		ChangeAnimation();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set the mood, which determines how various actions are performed.
//
// The amount is between 0.0 to 1.0 and is used by some of the mood-based
// to further refine the responses.  Most functionality is based purely on
// the specified mood, completely ignoring the amount.
///////////////////////////////////////////////////////////////////////////////
function SetMood(EMood moodNew, float amount)
{
	Super.SetMood(moodNew, amount);

	// Craptrap has no head, instead it has a screen. Update screen based on newmood
	switch (moodNew)
	{
		case MOOD_Normal:
		case MOOD_Scared:
		case MOOD_Puking:
		case MOOD_Paranoid:
		case MOOD_Sad:
			SetEyes(EyesNormal);
			break;

		case MOOD_Combat:
		case MOOD_Angry:
			SetEyes(EyesAngry);
			break;

		case MOOD_Happy:
			SetEyes(EyesLove);
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Animations.
///////////////////////////////////////////////////////////////////////////////
simulated function SetAnimWalking()
{
	local EWeaponHoldStyle hold;
	local name useanim1, useanim2;
	local WeaponAttachment wpattach;

	// prep for defaults
	WalkingPct			= GetDefaultWalkingPct();
	MovementPct			= GetDefaultMovementPct();

	if(mood == MOOD_Combat
		|| mood == MOOD_Scared)
		// Since we've got a weapon out or are scared, make sure to rotate faster now
		RotationRate = CombatRotationRate;
	else
		// Since we've *don't* a weapon out, make sure to rotate slower now
		RotationRate = default.RotationRate;

	TurnLeftAnim = '';
	TurnRightAnim = '';
	MovementAnims[0] = 'Run';
	MovementAnims[1] = 'Run';
	MovementAnims[2] = 'Strafe_Left';
	MovementAnims[3] = 'Strafe_Right';
	AmbientSound=WalkSound;
}
simulated function SetAnimRunning()
{
	local EWeaponHoldStyle hold;
	local name useanim1, useanim2;
	local WeaponAttachment wpattach;

	if(mood == MOOD_Combat
		|| mood == MOOD_Scared)
		// Since we've got a weapon out or are scared, make sure to rotate faster now
		RotationRate = CombatRotationRate;
	else
		// Since we've *don't* a weapon out, make sure to rotate slower now
		RotationRate = default.RotationRate;

	TurnLeftAnim = '';
	TurnRightAnim = '';
	MovementAnims[0] = 'Run';
	MovementAnims[1] = 'Run';
	MovementAnims[2] = 'Strafe_Left';
	MovementAnims[3] = 'Strafe_Right';
	AmbientSound=RunSound;
}
simulated function PlayTalkingGesture(float userate)
{
	local int userand;
	local name useanim;

	useanim='Talking';

	PlayAnim(useanim, userate, 0.1);
}
simulated function name GetAnimIdle()
{
    if (Rand(1) == 0)
	{
		AmbientSound=Idle1Sound;
	    return 'Idle1';
	}
    else
	{
		AmbientSound=Idle2Sound;
        return 'Idle2';
	}
}
simulated function SetAnimStanding()
{
	local float AnimRate;
	AnimRate = 1.0 + (FRand() - 0.5) / 10.0;
	SoundPitch = 64.0 * AnimRate;
	LoopIfNeeded(GetAnimStand(), AnimRate);
}
simulated function name GetAnimStand()
{
	return GetAnimIdle();
}
simulated function PlayShuttingDown()
{
	AmbientSound=None;
	PlayAnim('DeActivate', 1.0, 0, 0);
	PlaySound(DeactivateSound, SLOT_Interact);
}
simulated function PlayShutDown()
{
	PlayAnim('Deactivate_Post', 1.0, 0, 0);
}
simulated function PlayUrineHit()
{
	LoopAnim('Urine_hit', 1.0, 0, 0.15);
}
simulated function PlayDeactivating()
{
	PlayAnim('Deactivate_Fall', 1.0, 0, 0);
}
simulated function PlayMelee1Sound()
{
	PlaySound(Melee1Sound, SLOT_Interact);
}
simulated function PlayMelee2Sound()
{
	PlaySound(Melee2Sound, SLOT_Interact);
}
simulated function PlayRangedSound()
{
	PlaySound(RangedSound, SLOT_Interact);
}

/** Notification from */
function Notify_SpawnHealth() {
    local int i;
    local P2PowerupPickup HealthPickup;
	local vector X,Y,Z,TossVel;
	local Rotator userot;
	const TOSS_MAG = 800;

    i = Rand(VendACurePickups.length);

    if (VendACurePickups[i] != none && VendACurePickupBone != '' &&
        VendACurePickupBone != 'None') {

        HealthPickup = Spawn(VendACurePickups[i],,,
            GetBoneCoords(VendACurePickupBone).Origin);
			
		// Toss it toward the dude or something
		HealthPickup.SetPhysics(PHYS_Falling);
		TossVel = Vector(GetViewRotation()) * TOSS_MAG;
		HealthPickup.Velocity = TossVel;
		userot = Rotation;
		userot.Yaw = FRAnd()*65535;
		GetAxes(userot,X,Y,Z);
		// And make the ThisWeap align with the direction of the throw
		HealthPickup.SetRotation(userot);
    }
}

/** Notification for our Controller of a melee attack */
function NotifyMeleeAttack() {
    if (VendACureController != none)
        VendACureController.NotifyMeleeAttack();
}

/** Notification for our Controller of a ranged attack */
function NotifyRangedAttack() {
    if (VendACureController != none)
        VendACureController.NotifyRangedAttack();
}

/** Notify our AI Controller that it has been hit with fluids */
function HitWithFluid(Fluid.FluidTypeEnum ftype, vector HitLocation) {
    if (VendACureController != none)
        VendACureController.HitWithFluid(ftype, HitLocation);
}

/** Overriden so we ignore Urine damage, we're urinals afterall */
function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType) {
    if (!ClassIsChildOf(damageType, class'UrineDamage'))
        super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum,
            DamageType);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Explodes in a shower of robot parts if killed
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dying
{
	// Use a grenade explosion as a placeholder.
	// Might keep the damage aspect and simply change the visuals - I wouldn't
	// want to be too close to an exploding robot
	event BeginState()
	{
		Spawn(DestructionEmitter, Self, , Location, Rotation);
		Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Deactivated
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Shutdown
{
	ignores TakeDamage;

	///////////////////////////////////////////////////////////////////////////////
	event BeginState()
	{
		PlayShuttingDown();
		// Turn off collision so we don't block other players or pisstraps
		SetCollision(false,false,false);
		// Trigger our deactivation event
		TriggerEvent(EventPissedIn, Self, None);
	}
	event AnimEnd(int Channel)
	{
		GotoState('Deactivating');
	}

	simulated function name GetAnimIdle()
	{
		return 'DeActivate_Post';
	}
	simulated function name GetAnimStand()
	{
		return 'DeActivate_Post';
	}
}
state Deactivating extends Shutdown
{
	ignores AnimEnd;
	
	event BeginState()
	{
		PlayDeactivating();
	}
	simulated function name GetAnimIdle()
	{
		return 'DeActivate_Fall_Post';
	}
	simulated function name GetAnimStand()
	{
		return 'DeActivate_Fall_Post';
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorID="VendACurePawn"

	VendACurePickupBone="Item_nub"
	VendACurePickups(0)=class'FastFoodPickup'
	VendACurePickups(1)=class'DonutPickup'
	VendACurePickups(2)=class'PizzaPickup'
	VendACurePickups(3)=class'WaterBottlePickup'

    // VACXJ2-specific
	DestructionEmitter=class'PisstrapExplosion'

	// Skins etc.
	Mesh=SkeletalMesh'PLCharacters.craptrap'
	Skins[0]=Shader'PL_Craptrap.craptrap.craptrap_shader'
	BurnSkin=Shader'PL_Craptrap.craptrap.craptrap_shader'
	Skins[1]=Shader'PL_Craptrap.craptrap.NeutralScreen'
	EyesNormal=Shader'PL_Craptrap.craptrap.NeutralScreen'
	EyesLove=Shader'PL_Craptrap.craptrap.HeartScreen'
	EyesAngry=Shader'PL_Craptrap.craptrap.AngryScreen'

	// Pawn shit
	CollisionHeight=63
	CollisionRadius=28
	ControllerClass=class'VendACureController'
	GibsClass=None	// FIXME make it a shower of robot parts
	CoreMeshAnim=MeshAnimation'PLCharacters.pl_pisstrap'

	// Pawn attributes
	Gang="Vendacure"
	bScaredOfPantsDown=False
	bHasHead=False
	bHeadCanComeOff=False
	bCanCrouch=false
	bUsePawnSlider=False
	Champ=0.75
	Cajones=1.0
	Temper=0.7
	Glaucoma=0.2
	Compassion=0.0
	WarnPeople=0.0
	Conscience=0.0
	Beg=0.0
	PainThreshold=1.0
	Reactivity=0.7
	Rebel=1.0
	WillDodge=0.4
	WillKneel=0.0
	WillUseCover=0.1
	Stomach=1.0
	Greed=0.0
	TalkWhileFighting=0.8
	TakesShotgunHeadshot=0.5
	TakesRifleHeadshot=0.5
	TakesShovelHeadshot=0.5
	TakesOnFireDamage=0.0
	TakesAnthraxDamage=0.0
	TakesShockerDamage=0.0
	TakesPistolHeadshot=0.5
	TakesMachinegunDamage=0.5
	TalkBeforeFighting=0.75
	Fitness=1.0
	TakesChemDamage=0.0
	HealthMax=100
	bRiotMode=true
	bInnocent=False
	bIsTrained=True
	DialogClass=none // I prefer using a timer based dialog system, don't need something as sophisticated as a dialog class. Up for debate though
	bIsAutomaton=true
	bChameleon=False
	BlockMeleeFreq=0.0		// FIXME if we add melee-blocking anims
	bCellUser=False
	bNoChamelBoltons=True

	// Sounds
	FootKickHead=Sound'MiscSounds.Props.metalhitsground1'
	FootKickBody=Sound'MiscSounds.Props.metalhitsground2'
	ShovelHitHead=Sound'WeaponSounds.shovel_hitwall'
	ShovelCleaveHead=None	// This never happens
	ShovelHitBody=Sound'WeaponSounds.shovel_hitwall'
	DeactivateSound=Sound'PissTrap-Movement.PissTrap-DeActivate'
	Idle1Sound=Sound'PissTrap-Movement.PissTrap-Idle1'
	Idle2Sound=Sound'PissTrap-Movement.PissTrap-Idle2'
	Melee1Sound=Sound'PissTrap-Movement.PissTrap-Melee1'
	Melee2Sound=Sound'PissTrap-Movement.PissTrap-Melee2'
	RangedSound=Sound'PissTrap-Movement.PissTrap-Ranged'
	RunSound=Sound'PissTrap-Movement.PissTrap-Run'
	WalkSound=Sound'PissTrap-Movement.PissTrap-Strafe'
	
	SoundVolume=192
	SoundRadius=128
	
	AmbientGlow=30
	bCellUser=false
	EventPissedIn="PisstrapsPissedOn"
}
