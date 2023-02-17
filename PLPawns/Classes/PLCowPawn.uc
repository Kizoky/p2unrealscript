///////////////////////////////////////////////////////////////////////////////
// PLCowPawn
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// PL cows, these have a certain set of behaviors that AW doesn't have
///////////////////////////////////////////////////////////////////////////////
class PLCowPawn extends AWCowPawn;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var(PawnAttributes) float CowMilkMax;		// How much milk this cow starts with
var(PawnAttributes) bool bDiesAfterMilked;	// If true, this cow dies after being milked dry
var sound HitWallSound;

var float CowMilk;						// How much milk this cow has

///////////////////////////////////////////////////////////////////////////////
// We're being milked, so hold tight.
///////////////////////////////////////////////////////////////////////////////
function BeingMilkedBy(Pawn Milker)
{
	if (PLCowController(Controller) != None)
		PLCowController(Controller).BeingMilkedBy(Milker);
		
	// Ebola cows die after having all their milk drained.
	// Do NOT count it as a kill for the dude, however.
	if (Milker == None && CowMilk <= 0 && bDiesAfterMilked)
	{
		Health = 0;
		Died(None, class'Suicided', Location );
	}
}
/*
///////////////////////////////////////////////////////////////////////////////
// Someone's messing with you from behind, kick them
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_BackKick()
{
	// STUB, we don't use this in PL
}
*/
///////////////////////////////////////////////////////////////////////////////
// setup our cow milk
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	CowMilk = CowMilkMax;
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Animation & Sound
///////////////////////////////////////////////////////////////////////////////
function PlayHitWallSound()
{
	PlaySound(HitWallSound, SLOT_Interact,,,, GenPitch());
}
function PlayAnimStunIn()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStunIn(), 1.0, 0.2);
}
function PlayAnimStunLoop()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStunLoop(), 1.0, 0.2);
}
function PlayAnimStunOut()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimStunOut(), 1.0, 0.2);
}

function name GetAnimStunIn()
{
	return 'stun_in';
}
function name GetAnimStunLoop()
{
	return 'stun_loop';
}
function name GetAnimStunOut()
{
	return 'stun_out';
}

/*
///////////////////////////////////////////////////////////////////////////////
// If we run into a wall, tell our controller so they might do something
///////////////////////////////////////////////////////////////////////////////
event HitWall( vector HitNormal, actor HitWall )
{
	Controller.HitWall(HitNormal, HitWall);
}
*/

defaultproperties
{
	ControllerClass=Class'PLCowController'
	CowMilkMax=5.00
	bDiesAfterMilked=false
	Mesh=SkeletalMesh'PLAnimals.meshCow_PL'
	Skins[0]=Texture'AW_Characters.Zombie_Cows.AW_Cow3'
	HitWallSound=Sound'LevelSoundsToo.Brewery.woodCrash03'
	CollisionRadius=80
	CollisionHeight=90
	AmbientGlow=30
}

