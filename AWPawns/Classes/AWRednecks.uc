///////////////////////////////////////////////////////////////////////////////
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//  Country rednecks. They now run the dogpound in AW.
//
///////////////////////////////////////////////////////////////////////////////
class AWRednecks extends AWBystander
	placeable;


function PreBeginPlay()
	{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
	}

defaultproperties
{
	ActorID="Redneck"
	BlockMeleeFreq=0.050000
	bDogFriend=True
	ChameleonSkins(0)="ChameleonSkins.MW__055__Avg_M_SS_Pants"
	ChameleonSkins(1)="ChameleonSkins.MW__072__Big_M_LS_Pants"
	ChameleonSkins(2)="ChameleonSkins.MW__103__Fat_M_SS_Pants"
	ChameleonSkins(3)="End"
	Cajones=0.800000
	Glaucoma=0.800000
	PainThreshold=0.950000
	Rebel=1.000000
	Stomach=0.900000
	Greed=0.800000
	TalkWhileFighting=0.300000
	TalkBeforeFighting=0.500000
	dialogclass=Class'BasePeople.DialogRedneck'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.ShotGunWeapon')
	ViolenceRankTolerance=1
	HealthMax=100.000000
	Gang="Rednecks"
	Mesh=SkeletalMesh'Characters.Avg_M_SS_Pants'
	Skins(0)=Texture'ChameleonSkins.Rednecks.XX__154__Avg_M_SS_Pants'
	ControllerClass=Class'AWPawns.AWBystanderController'
	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(4)=BoltonDef'BoltonDef_CowboyHat_RedNeck'
	RandomizedBoltons(5)=BoltonDef'BoltonDef_Cigarette_RedNeck'
	RandomizedBoltons(6)=None
	bAllowRandomGuns=True	// xPatch
}
