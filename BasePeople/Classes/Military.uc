//=============================================================================
// Military
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all military characters.
//
//=============================================================================
class Military extends AuthorityFigure
	placeable;

function PreBeginPlay()
	{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
	}

function PostBeginPlay()
	{
	Super.PostBeginPlay();

	Cowardice=0.0;
	}

// Moved to P2Pawn/GameState	
/*
///////////////////////////////////////////////////////////////////////////////
// Record pawn dead, if player killed them
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		// Record him dying as military
		P2GameInfoSingle(Level.Game).TheGameState.ArmyKilled++;
	}

	Super.Died(Killer, damageType, HitLocation);
}
*/

defaultproperties
	{
	ActorID="Soldier"
	Skins[0]=Texture'ChameleonSkins.XX__152__Big_M_LS_Pants'
	Mesh=Mesh'Characters.Big_M_LS_Pants'

	bRandomizeHeadScale=false	// don't let head scale or it may clip with helmets

	ChameleonSkins(0)="ChameleonSkins.MM__074__Big_M_LS_Pants"
	ChameleonSkins(1)="ChameleonSkins.MW__076__Big_M_LS_Pants"
	ChameleonSkins(2)="end"	// end-of-list marker (in case super defines more skins)
// These are military skins, too, but we don't want them to be chosen at random (LD's will choose them manually)
//	ChameleonSkins()="ChameleonSkins.MB__077__Big_M_LS_Pants"
//	ChameleonSkins()="ChameleonSkins.MW__078__Big_M_LS_Pants"

	HealthMax=130
	Psychic=0.3
	Rat=1.0
	Temper=0.2
	Compassion=0.3
	WarnPeople=0.3
	Champ=0.5
	Cajones=0.7
	Conscience=0.3
	Beg=0.05
	Reactivity=0.5
	PainThreshold=0.8
	Glaucoma=0.65
	Rebel=1.0
	WillDodge=0.2
	WillKneel=0.1
	WillUseCover=0.2
	Stomach=0.9
	Fitness=0.7
	AttackRange=(Min=256,Max=4096)
    ControllerClass=class'MilitaryController'
	DialogClass=class'BasePeople.DialogMaleMilitary'
	Gang="Military"
	BaseEquipment[0]=(weaponclass=class'Inventory.MachineGunWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.PistolWeapon')
	ViolenceRankTolerance=0
	TakesShotgunHeadShot=	0.4
	TakesRifleHeadShot=		0.35
	TakesShovelHeadShot=	0.6
	TakesOnFireDamage=		0.6
	TakesAnthraxDamage=		0.5
	TakesShockerDamage=		0.4
	TakesChemDamage=		0.5

	// Give all military helmets
	Boltons[0]=(bone="NODE_Parent",staticmesh=staticmesh'boltons.Swat_Helmet',skin=texture'BoltonSkins.Military_Helmet',bCanDrop=false,bAttachToHead=true)
	// Give them backpacks too
	Boltons[1]=(bone="MALE01 spine1",staticmesh=staticmesh'boltons.Military_Pack')

	bNoChamelBoltons=True
	RandomizedBoltons(0)=None
	BlockMeleeFreq=0.9
	}
