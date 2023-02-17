///////////////////////////////////////////////////////////////////////////////
// MutantDogPawn
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// PL's mutant dogs. They're a bit meaner and tougher than regular dogs.
///////////////////////////////////////////////////////////////////////////////
class MutantDogPawn extends DogPawn;

function PlayAttack2()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimPounce(), 1.5, 0.2);
	PlaySound(BitingSounds[Rand(ArrayCount(BitingSounds))], SLOT_Talk,,,,GenPitch());
	// Make him be able to move faster than normal
	GroundSpeed = PounceSpeed;
}

simulated function SetAnimWalking()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('walk', 0.7, 0.2, MOVEMENTCHANNEL);
}

simulated function SetAnimRunning()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('run', 1.5, 0.2, MOVEMENTCHANNEL);
}

simulated function SetAnimRunningScared()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('run_scared', 1.75, 0.2, MOVEMENTCHANNEL);
}

simulated function SetAnimTrotting()
{
	AnimBlendParams(MOVEMENTCHANNEL,1.0);
	LoopAnim('walk', 1.4, 0.2, MOVEMENTCHANNEL);// + FRand()*0.4);
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
	UrinePourFeeder(UrineStream).SetDir(checkcoords.Origin, checkcoords.XAxis);
}

defaultproperties
{
	ControllerClass=class'MutantDogController'
	Mesh=SkeletalMesh'PLAnimals.meshDog_Mutant'
	Skins[0]=Texture'PLAnimalSkins.PLDog.MutantDog_base'
	Skins[1]=Texture'PLAnimalSkins.PLDog.teethclaws'
	CollisionHeight=60
	CollisionRadius=35
	DrawScale=1
	WalkingPct=0.09
	GroundSpeed=600
	PounceSpeed=750
	HealthMax=100
	CatchProjFreq=0.600000
	
	bNoDismemberment=True

	Barks[0] = Sound'PLAnimalSounds.dogg.mutdog_bark1'
	Barks[1] = Sound'PLAnimalSounds.dogg.mutdog_bark2'
	Barks[2] = Sound'PLAnimalSounds.dogg.mutdog_bark3'
	BitingSounds[0] = Sound'PLAnimalSounds.dogg.mutdog_biting2'
	BitingSounds[1] = Sound'PLAnimalSounds.dogg.mutdog_biting3'
	GrowlSounds[0] = Sound'PLAnimalSounds.dogg.mutdog_growl2'
	GrowlSounds[1] = Sound'PLAnimalSounds.dogg.mutdog_growl3'
	MeanBark = Sound'PLAnimalSounds.dogg.mutdog_meanbark2'
	PantSound = Sound'PLAnimalSounds.dogg.mutdog_pant'
	WhimperSound = Sound'PLAnimalSounds.dogg.mutdog_whimper2'
	HurtSounds[0] = Sound'PLAnimalSounds.dogg.mutdog_hit1'
	HurtSounds[1] = Sound'PLAnimalSounds.dogg.mutdog_hit2'
	Sniff=Sound'PLAnimalSounds.dogg.mutdog_sniffing'
	AmbientGlow=30	
}
