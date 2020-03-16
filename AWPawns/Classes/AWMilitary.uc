//=============================================================================
// AWMilitary
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//=============================================================================
class AWMilitary extends AWAuthorityFigure
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
		AWGameState(P2GameInfoSingle(Level.Game).TheGameState).ArmyKilled++;
	}

	Super.Died(Killer, damageType, HitLocation);
}
*/

defaultproperties
{
	ActorID="Soldier"
	StumpClass=Class'StumpBigGuy'
	LimbClass=Class'LimbBigGuy'
	TakesSledgeDamage=0.000000
	TakesDervishDamage=0.500000
	BlockMeleeFreq=0.900000
	bRandomizeHeadScale=False
	boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'boltons.Swat_Helmet',Skin=Texture'BoltonSkins.Military_Helmet',bAttachToHead=True)
	boltons(1)=(Bone="MALE01 spine1",StaticMesh=StaticMesh'boltons.Military_Pack')
	ChameleonSkins(0)="ChameleonSkins.MM__074__Big_M_LS_Pants"
	ChameleonSkins(1)="ChameleonSkins.MW__076__Big_M_LS_Pants"
	ChameleonSkins(2)="End"
	ChameleonMeshPkgs(0)="Characters"
	ChamelHeadSkins(0)="ChamelHeadSkins.MWA__001__AvgMale"
	ChamelHeadSkins(1)="ChamelHeadSkins.MBA__013__AvgBrotha"
	ChamelHeadSkins(2)="ChamelHeadSkins.MBA__014__AvgBrotha"
	ChamelHeadSkins(3)="ChamelHeadSkins.MMA__016__AvgMale"
	ChamelHeadSkins(4)="ChamelHeadSkins.MWA__002__AvgMale"
	ChamelHeadSkins(5)="ChamelHeadSkins.MMA__003__AvgMale"
	ChamelHeadSkins(6)="ChamelHeadSkins.MWA__007__AvgMale"
	ChamelHeadSkins(7)="ChamelHeadSkins.MWA__008__AvgMale"
	ChamelHeadSkins(8)="ChamelHeadSkins.MWA__015__AvgMale"
	ChamelHeadSkins(9)="ChamelHeadSkins.MWA__021__AvgMaleBig"
	ChamelHeadSkins(10)="ChamelHeadSkins.MWA__035__AvgMale"
	ChamelHeadSkins(11)="ChamelHeadSkins.MWF__025__FatMale"
	ChamelHeadSkins(12)="ChamelHeadSkins.MWA__022__AvgMaleBig"
	ChamelHeadSkins(13)="ChamelHeadSkins.FBA__033__FemSH"
	ChamelHeadSkins(14)="ChamelHeadSkins.FWA__031__FemSH"
	ChamelHeadSkins(15)="ChamelHeadSkins.FWA__026__FemLH"
	ChamelHeadSkins(16)="ChamelHeadSkins.FWA__027__FemLH"
	ChamelHeadSkins(17)="ChamelHeadSkins.FWA__029__FemSH"
	ChamelHeadSkins(18)="ChamelHeadSkins.FWA__032__FemSH"
	ChamelHeadSkins(19)="ChamelHeadSkins.FWF__023__FatFem"
	ChamelHeadSkins(20)="ChamelHeadSkins.FWA__037__FemSHcropped"
	ChamelHeadSkins(21)="ChamelHeadSkins.FMA__039__FemSHcropped"
	ChamelHeadSkins(22)="ChamelHeadSkins.FWA__040__FemSHcropped"
	ChamelHeadSkins(23)="ChamelHeadSkins.FMF__044__FatFem"
	ChamelHeadSkins(24)="ChamelHeadSkins.FBF__043__FatFem"
	ChamelHeadSkins(25)="ChamelHeadSkins.MBF__042__FatMale"
	ChamelHeadSkins(26)="End"
	Psychic=0.300000
	Champ=0.500000
	Cajones=0.700000
	Glaucoma=0.650000
	Rat=1.000000
	Compassion=0.300000
	WarnPeople=0.300000
	Conscience=0.300000
	Beg=0.050000
	PainThreshold=0.800000
	Reactivity=0.500000
	Rebel=1.000000
	WillDodge=0.200000
	WillUseCover=0.200000
	Stomach=0.900000
	TakesShotgunHeadShot=0.400000
	TakesRifleHeadShot=0.350000
	TakesShovelHeadShot=0.600000
	TakesOnFireDamage=0.600000
	TakesAnthraxDamage=0.500000
	TakesShockerDamage=0.400000
	Fitness=0.700000
	dialogclass=Class'BasePeople.DialogMaleMilitary'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.MachineGunWeapon')
	BaseEquipment(1)=(WeaponClass=Class'Inventory.PistolWeapon')
	ViolenceRankTolerance=0
	TakesChemDamage=0.500000
	HealthMax=130.000000
	Gang="Military"
	AttackRange=(Min=256.000000,Max=4096.000000)
	ControllerClass=Class'AWPawns.AWMilitaryController'
	Mesh=SkeletalMesh'Characters.Big_M_LS_Pants'
	Skins(0)=Texture'ChameleonSkins.Military.XX__152__Big_M_LS_Pants'
	bNoChamelBoltons=True
	RandomizedBoltons(0)=None
}
