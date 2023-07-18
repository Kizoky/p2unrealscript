///////////////////////////////////////////////////////////////////////////////
// Survivalists
// Copyright 2014, Running With Scissors, Inc.
//
// Survivalist faction for Paradise Lost. Basically SWAT guys with
// full-body radiation/hazmat suits
///////////////////////////////////////////////////////////////////////////////
class Survivalist extends AuthorityFigure
	placeable;

function PreBeginPlay()
{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
}

defaultproperties
{
	ActorID="Survivalist"

	Skins[0]=Texture'PLCharacterSkins.Survivalist.MW__300__Avg_Survivalist'
	Mesh=SkeletalMesh'PLCharacters.Avg_Survivalist'

	ChameleonMeshPkgs(0)="PLCharacters"
	ChameleonSkins(0)="PLCharacterSkins.Survivalist.MW__300__Avg_Survivalist"
	ChameleonSkins(1)="end"	// end-of-list marker (in case super defines more skins)

	ChamelHeadMeshPkgs(0)="PLHeads"
	ChamelHeadSkins(0)="PLCharacterSkins.Survivalist_Head.MWA__300__Head_Survivalist"
	ChamelHeadSkins(1)="end"

	ADJUST_RELATIVE_HEAD_X=-8
	bRandomizeHeadScale=false	// don't let head scale or it may clip with helmets

	HealthMax=225
	BlockMeleeFreq=0.900000
	Psychic=0.400000
	Champ=0.700000
	Cajones=0.700000
	Temper=0.350000
	Glaucoma=0.450000
	Rat=1.000000
	Compassion=0.000000
	WarnPeople=0.000000
	Conscience=0.000000
	Beg=0.000000
	PainThreshold=1.000000
	Reactivity=0.750000
	Rebel=1.000000
	WillDodge=0.400000
	WillKneel=0.200000
	WillUseCover=0.800000
	Stomach=1.000000
	Armor=100.000000
	ArmorMax=100.000000
	TalkWhileFighting=0.200000
	TalkBeforeFighting=0.200000
	Fitness=0.900000
	AttackRange=(Min=512,Max=4096)
	BaseEquipment[0]=(weaponclass=class'Inventory.MachineGunWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.PistolWeapon')
	TalkWhileFighting=0.1
	TalkBeforeFighting=0.1
    ControllerClass=class'SurvivalistController'
	DialogClass=class'DialogSurvivalist'
	Gang="Survivalists"

	ViolenceRankTolerance=0
	TakesShotgunHeadShot=	0.25
	TakesRifleHeadShot=		0.5 //0.3
	TakesShovelHeadShot=	0.35
	TakesOnFireDamage=		0.4
	TakesAnthraxDamage=		0.5
	TakesShockerDamage=		0.1

	bNoChamelBoltons=True
	RandomizedBoltons(0)=None
	bFriendWithAuthority=False
	
	StumpClass=class'StumpSurvivalist'
	LimbClass=class'LimbSurvivalist'
	HeadClass=class'SurvivalistHead'
	StumpAdjust=(X=5)
	AmbientGlow=30
	bCellUser=false
}
