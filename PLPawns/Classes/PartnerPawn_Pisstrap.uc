///////////////////////////////////////////////////////////////////////////////
// Pisstrap version of the AI partner! >:D
// What has Science done?!
///////////////////////////////////////////////////////////////////////////////
class PartnerPawn_Pisstrap extends PartnerPawn;

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
	LoopIfNeeded(GetAnimStand(), 1.0 + (FRand() - 0.5) / 10.0 );
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

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorID="VendACurePawn"

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
	GibsClass=None	// FIXME make it a shower of robot parts
	CoreMeshAnim=MeshAnimation'PLCharacters.pl_pisstrap'
	
	// Pisstrap specific
	bHasHead=False
	bHeadCanComeOff=False
	bCanCrouch=false
	bIsAutomaton=true
	ExtraAnims(0)=None
	ExtraAnims(1)=None
	ExtraAnims(2)=None
	ExtraAnims(3)=None
	ExtraAnims(4)=None
	ExtraAnims(5)=None
	ExtraAnims(6)=None
	ExtraAnims(7)=None
	ExtraAnims(8)=None
	ExtraAnims(9)=None
	DialogClass=class'DialogPisstrap'

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
	SoundRadius=512

	bRandomizeHeadScale=false
	bPersistent=true
	bKeepForMovie=true
	bCanTeleportWithPlayer=true
	bIsTrained=true
	bStartupRandomization=false
	RandomizedBoltons(0)=None
}
