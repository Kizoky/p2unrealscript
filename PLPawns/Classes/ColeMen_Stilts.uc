///////////////////////////////////////////////////////////////////////////////
// ColeMen_Stilts
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// All decked out for the Apocalypse with our mechanical stilts courtesy
// of one T. Dude
///////////////////////////////////////////////////////////////////////////////
class ColeMen_Stilts extends ColeMen;

///////////////////////////////////////////////////////////////////////////////
// Very early setup
///////////////////////////////////////////////////////////////////////////////
simulated function PreBeginPlay()
{
	local Material skin;
	// Here we swap skin indexes 0 and 1 to confuse the chameleon into working correctly
	skin = Skins[0];
	Skins[0] = Skins[1];
	Skins[1] = skin;
	Super.PreBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Get ready
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	local Material skin;
	Super.PostBeginPlay();
	// Here we swap the skins back so the mesh looks correct
	skin = Skins[0];
	Skins[0] = Skins[1];
	Skins[1] = skin;
}

// Make 'em a little tougher than their non-stilted counterparts
defaultproperties
{
	ActorID="ColeMen"

	Skins[0]=Texture'shockingextra.aluminum'	
	Skins[1]=Texture'PLCharacterSkins.ColeMen.XX__430__GaryStiltWar'
	Skins[2]=Texture'shockingextra.stiltskin'
	Mesh=SkeletalMesh'PLshockingExtras.GaryStiltWar'
	ChameleonMeshPkgs(0)="PLshockingExtras"
	ChameleonSkins(0)="PLCharacterSkins.ColeMen.MB__430__GaryStiltWar"
	ChameleonSkins(1)="PLCharacterSkins.ColeMen.MM__431__GaryStiltWar"
	ChameleonSkins(2)="PLCharacterSkins.ColeMen.MW__432__GaryStiltWar"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)
	BaseEquipment[0]=(weaponclass=class'Inventory.MachineGunWeapon')
	HealthMax=150
	BlockMeleeFreq=0.90
	Beg=0
	PainThreshold=0.95
	Cajones=0.95
	Rebel=0.9
	WillDodge=0.85
	WillKneel=0.55
	WillUseCover=0.85
	Stomach=0.8
	VoicePitch=1.5
	CharacterType=CHARACTER_avgdude
	CoreMeshAnim=MeshAnimation'Characters.animAvg'
	PeeBody=class'UrineBodyDrip'
	GasBody=class'GasBodyDrip'
	bNoDismemberment=true
    AW_SPMeshAnim=MeshAnimation'AWCharacters.animAvg_AW'
	ExtraAnims(0)=MeshAnimation'AW7Characters.animAvg_AW7'
	HEAD_RATIO_OF_FULL_HEIGHT=0.5
}
