//=============================================================================
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class AWGary extends AWBystander
	placeable;

var float DissolveTime;				// Actual time we bubble for when dissolving
var float DissolveRate;				// DissolveRate*DeltaTime is subtracted from the scale each time
									// so have the time this takes be about the same as DissolveTime
var float MinDissolveSize;
var class<ZDissolvePuddle> dissolveclass;
var Sound DissolveSound;			// sound we make as we dissolve
//var Texture RealSkin;				// for some 

const BONE_LCALF			= 'MALE01 l calf';

const WAIT_FOR_DISSOLVE_TIME	=	3.0;
const XY_DISSOLVE_RATIO			=	0.5;

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
	// Allow no more interaction
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
	{
		// Reset time to dissolve each time, if it gets moved significantly
		if(!ClassIsChildOf(damageType, class'BulletDamage')
			&& !ClassIsChildOf(damageType, class'BurnedDamage')
			&& !ClassIsChildOf(damageType, class'OnFireDamage')
			&& TimeTillDissolve > 0)
			SetTimer(TimeTillDissolve, false);

		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		GotoState('PrepForDissolving');
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		Super.BeginState();
		// reset the timer to do our bidding.. namely, make him dissolve after
		// a time
		if(TimeTillDissolve > 0)
			SetTimer(TimeTillDissolve, false);
	}
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PrepForDissolving
// Hold him to he doesn't move around for a few seconds first, before
// removing him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepForDissolving extends Dying
{
	ignores TakeDamage;
	///////////////////////////////////////////////////////////////////////////////
	// Do actual dissolve now
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		GotoState('Dissolving');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn off our collision with players/damage first
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		bBlockZeroExtentTraces=false;
		bBlockNonZeroExtentTraces=false;
		SetCollision(false, false, false);
		SetTimer(WAIT_FOR_DISSOLVE_TIME, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dissolving
// bubble effects play as I 'sink' into the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dissolving extends Dying
{
	ignores TakeDamage;
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		local vector newd;
		newd = DrawScale3D;
		// shrink mostly up and down
		newd.z-=(DeltaTime*DissolveRate);
		// also shrink side to side, but less
		newd.x-=(DeltaTime*DissolveRate*XY_DISSOLVE_RATIO);
		newd.y-=(DeltaTime*DissolveRate*XY_DISSOLVE_RATIO);
		if(newd.z < MinDissolveSize)
			newd.z = MinDissolveSize;
		SetDrawScale3D(newd);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Make him fall out of the world now
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		GotoState('FallDissolve');
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function MakeDissolvePuddle(vector loc)
	{
		local ZDissolvePuddle dissolver;
		local vector endpt, hitlocation, hitnormal;
		local Actor HitActor;

		// Trace down and find the ground first
		endpt = loc;
		endpt.z -= default.CollisionHeight;
		HitActor = Trace(HitLocation, HitNormal, endpt, loc, true);
		if(HitActor != None
			&& HitActor.bStatic)
		{
			loc = HitLocation;
		}
		// Set emitter at neck line
		dissolver = spawn(dissolveclass,self,,loc);
		dissolver.SetTimer(DissolveTime, false);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn off our collision with players/damage first
	// Modify sound also
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local coords usecoords;
		// How long we dissolve for
		SetTimer(DissolveTime, false);

		// Setup boiling sound
		AmbientSound=DissolveSound;
		SoundRadius=30;
		TransientSoundRadius=SoundRadius;
		SoundVolume=255;
		TransientSoundVolume=SoundVolume;
		SoundPitch=0.75;

		// Make effects to go with shrinking
		if(dissolveclass != None)
		{
			// Set emitter below neck line
			usecoords = GetBoneCoords(BONE_NECK);
			MakeDissolvePuddle(usecoords.origin);
			// Put one below pelvis too
			usecoords = GetBoneCoords(BONE_PELVIS);
			MakeDissolvePuddle(usecoords.origin);
			// If he's got a right calf, one for there too
			if(BoneArr[RIGHT_LEG] == 1)
			{
				usecoords = GetBoneCoords(BONE_RCALF);
				MakeDissolvePuddle(usecoords.origin);
			}
			// If he's got a left calf, one for there too
			if(BoneArr[LEFT_LEG] == 1)
			{
				usecoords = GetBoneCoords(BONE_LCALF);
				MakeDissolvePuddle(usecoords.origin);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FallDissolve
// Sink into the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallDissolve extends Dying
{
	ignores TakeDamage;
	///////////////////////////////////////////////////////////////////////////////
	// Delete me now if not already gone
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		Destroy();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn off world collision to make it fall
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		SetTimer(1.0, false);
		bCollideWorld=false;
	}
}

defaultproperties
{
	ActorID="Gary"
	DissolveTime=6.000000
	DissolveRate=0.200000
	MinDissolveSize=0.300000
	dissolveclass=Class'AWEffects.ZDissolvePuddle'
	DissolveSound=Sound'LevelSounds.potBoil'
	StumpClass=Class'StumpGary'
	LimbClass=Class'LimbGary'
	TimeTillDissolve=10.000000
	AW_SPMeshAnim=MeshAnimation'AWGary_Characters.animMini_AW'
	PeeBody=Class'FX.UrineSmallBodyDrip'
	GasBody=Class'FX.GasSmallBodyDrip'
	HeadClass=Class'AWPawns.AWGaryHead'
	HeadSkin=Texture'AW_Characters.Zombie_Heads.Pygmy_head'
	HeadMesh=SkeletalMesh'heads.Gary'
	bRandomizeHeadScale=False
	AnimGroupUsed=-1
	CoreMeshAnim=MeshAnimation'Gary_Characters.animMini'
	bStartupRandomization=False
	Psychic=1.000000
	Champ=0.900000
	Cajones=1.000000
	Temper=1.000000
	Glaucoma=0.500000
	Twitch=3.500000
	Compassion=0.000000
	WarnPeople=0.000000
	Conscience=0.000000
	Beg=0.000000
	PainThreshold=1.000000
	Reactivity=0.500000
	Confidence=1.000000
	Rebel=0.000000
	Patience=0.500000
	WillDodge=0.500000
	WillKneel=0.050000
	WillUseCover=0.900000
	Talkative=0.200000
	Stomach=1.000000
	VoicePitch=1.300000
	TalkWhileFighting=0.500000
	TakesShotgunHeadShot=0.050000
	TakesRifleHeadShot=1.0 //0.150000
	TakesShovelHeadShot=0.150000
	TakesOnFireDamage=0.250000
	TakesAnthraxDamage=0.250000
	TakesShockerDamage=0.100000
	TakesPistolHeadShot=0.250000
	TakesMachinegunDamage=0.300000
	TalkBeforeFighting=1.000000
	WeapChangeDist=500.000000
	TwitchFar=3.500000
	bHasRef=False
	dialogclass=Class'BasePeople.DialogGary'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.ScissorsWeapon')
	BaseEquipment(1)=(WeaponClass=Class'AWInventory.AWGrenadeWeapon')
	TakesChemDamage=0.100000
	HealthMax=250.000000
	bPlayerIsEnemy=True
	bPersistent=True
	bCanTeleportWithPlayer=False
	DamageMult=2.000000
	bKeepForMovie=True
	Mesh=SkeletalMesh'Gary_Characters.Mini_M_Jacket_Pants'
	Skins(0)=Texture'AW_Characters.Zombie_Skins.Pygmy_skin'
	//Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel14
	//	KSkeleton="Avg_Mini_Skel"
	//	KFriction=0.500000
	//	Name="KarmaParamsSkel14"
	//End Object
	//KParams=KarmaParamsSkel'People.GarySkel'
	CharacterType=CHARACTER_Mini
	ControllerClass=Class'AWPawns.AWBystanderController'
	RandomizedBoltons(0)=None
	ExtraAnims(0)=MeshAnimation'MP_Gary_Characters.anim_GaryMP'
	ExtraAnims(1)=None
	ExtraAnims(2)=None
	ExtraAnims(3)=None
	ExtraAnims(4)=None
	ExtraAnims(5)=None
	ExtraAnims(6)=None
	HEAD_RATIO_OF_FULL_HEIGHT=0.1
	
	// Addded by Man Chrzan: xPatch 2.0
	// Seems like it switches to PLAnims intead of using PLAnims_Mini
	// after loading saved game... well, that should do the trick.
	PLAnims_Mini=MeshAnimation'Gary_Characters.animMini_PL'
	PLAnims=MeshAnimation'Gary_Characters.animMini_PL'
	PLAnims_Fat=MeshAnimation'Gary_Characters.animMini_PL'
}
