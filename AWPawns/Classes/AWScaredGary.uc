//=============================================================================
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class AWScaredGary extends AWBystander
	placeable;

///////////////////////////////////////////////////////////////////////////////
// PawnSpawner sets some things for you
// The spawer can set the skin of the thing spawned. If they set a specific
// skin, then make sure we go through and set all the gender/race attributes
// associated with this specific skin. Reinit the head once we got the new
// skin.
//
// Garys will have crazy skins put on them, but they *don't* want the chameleon
// code to work for them, so grab the skins out, and then None them in the
// spawn so P2MocapPawn doesn't try to use the chameleon code on him.
///////////////////////////////////////////////////////////////////////////////
function InitBySpawner(PawnSpawner initsp)
{
	local Material usebodyskin, useheadskin;

	usebodyskin = initsp.SpawnSkin;
	useheadskin = AWPawnSpawner(initsp).SpawnHeadSkin;
	// Set up skin for body
	if(usebodyskin != None)
		Skins[0]			= usebodyskin;
	// Blank it out so the chameleon won't use it
	initsp.SpawnSkin	= None;
	// Set up skin for head
	if(useheadskin != None)
	{
		MyHead.Skins[0]		= useheadskin;
		HeadSkin			= useheadskin;
	}
	// Blank it out so the chameleon won't use it
	AWPawnSpawner(initsp).SpawnHeadSkin = None;

	Super.InitBySpawner(initsp);

	// Restore textures for next spawned guy to use!
	initsp.SpawnSkin	= usebodyskin;
	AWPawnSpawner(initsp).SpawnHeadSkin = useheadskin;
}

defaultproperties
{
	ActorID="Gary"
	StumpClass=Class'StumpGary'
	LimbClass=Class'LimbGary'
	AW_SPMeshAnim=MeshAnimation'AWGary_Characters.animMini_AW'
	PeeBody=Class'FX.UrineSmallBodyDrip'
	GasBody=Class'FX.GasSmallBodyDrip'
	HeadSkin=Texture'ChamelHeadSkins.Special.Gary'
	HeadMesh=SkeletalMesh'heads.Gary'
	bRandomizeHeadScale=False
	AnimGroupUsed=-1
	CoreMeshAnim=MeshAnimation'Gary_Characters.animMini'
	bStartupRandomization=False
	Psychic=0.000000
	Champ=0.010000
	Cajones=0.010000
	Temper=0.010000
	Glaucoma=0.500000
	Twitch=3.500000
	Compassion=0.000000
	WarnPeople=0.000000
	Conscience=0.000000
	Beg=0.000000
	PainThreshold=0.010000
	Reactivity=0.500000
	Confidence=1.000000
	Rebel=0.000000
	Patience=0.500000
	WillDodge=0.500000
	WillKneel=0.050000
	WillUseCover=0.900000
	Talkative=0.200000
	Stomach=0.200000
	TalkWhileFighting=0.010000
	TakesShotgunHeadShot=0.050000
	TakesRifleHeadShot=0.150000
	TakesShovelHeadShot=0.150000
	TakesOnFireDamage=0.250000
	TakesAnthraxDamage=0.250000
	TakesShockerDamage=0.100000
	TakesPistolHeadShot=0.250000
	TakesMachinegunDamage=0.300000
	TalkBeforeFighting=0.010000
	TwitchFar=3.500000
	bHasRef=False
	dialogclass=Class'AWPawns.DialogScaredGary'
	TakesChemDamage=0.100000
	HealthMax=250.000000
	bPlayerIsEnemy=True
	bPersistent=True
	bCanTeleportWithPlayer=False
	bKeepForMovie=True
	ControllerClass=Class'AWPawns.AWScaredGaryController'
	Mesh=SkeletalMesh'Gary_Characters.Mini_M_Jacket_Pants'
	Skins(0)=Texture'AW_Characters.Zombie_Skins.BattleDamageGary'
	//Begin Object Class=KarmaParamsSkel Name=GarySkel
	//	KSkeleton="Avg_Mini_Skel"
	//	KFriction=0.500000
	//	Name="GarySkel"
	//End Object
	//KParams=KarmaParamsSkel'AWPawns.GarySkel'
	CharacterType=CHARACTER_Mini
	RandomizedBoltons(0)=None
	ExtraAnims(0)=MeshAnimation'MP_Gary_Characters.anim_GaryMP'
	ExtraAnims(1)=None
	ExtraAnims(2)=None
	ExtraAnims(3)=None
	ExtraAnims(4)=None
	ExtraAnims(5)=None
	ExtraAnims(6)=None
	HEAD_RATIO_OF_FULL_HEIGHT=0.1
}
