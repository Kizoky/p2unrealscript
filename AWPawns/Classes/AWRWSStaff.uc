//=============================================================================
// RWSStaff.uc
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all RWS staff members.
//
//=============================================================================
class AWRWSStaff extends AWBystander
	notplaceable
	Abstract;

defaultproperties
{
	ActorID="RWSWorker"
	Skins[0]=Texture'ChameleonSkins2.RWS.XX__204__Avg_M_SS_Shorts'
	Mesh=Mesh'Characters.Avg_M_SS_Shorts'
	// RWS skins
	ChameleonSkins[0]="ChameleonSkins2.RWS.MW__202__Avg_M_SS_Pants"
	ChameleonSkins[1]="ChameleonSkins2.RWS.MW__203__Avg_M_SS_Pants"
	// For third skin, individual RWS classes decide whether to use pants or shorts with the "old" RWS tee.
	// Pants is MW__205__Avg_M_SS_Pants
	// Shorts is MW__206__Avg_M_SS_Shorts
	ChameleonSkins[2]="ChameleonSkins2.RWS.MW__205__Avg_M_SS_Pants"
	//ChameleonSkins[2]="ChameleonSkins2.RWS.MW__206__Avg_M_SS_Shorts"
	ChameleonSkins[3]="End"

	TakesSledgeDamage=0.100000
	TakesMacheteDamage=0.100000
	TakesScytheDamage=0.100000
	TakesZombieSmashDamage=0.300000
	bLookForZombies=True
	BlockMeleeFreq=1.000000
	bRandomizeHeadScale=False
	bIsTrained=True
	bStartupRandomization=False
	Psychic=0.400000
	Cajones=1.000000
	Glaucoma=0.300000
	PainThreshold=1.000000
	Rebel=1.000000
	Stomach=1.000000
	TakesShotgunHeadShot=0.250000
	TakesShovelHeadShot=0.350000
	TakesOnFireDamage=0.400000
	TakesAnthraxDamage=0.500000
	TakesShockerDamage=0.300000
	BaseEquipment(0)=(WeaponClass=Class'Inventory.PistolWeapon')
	BaseEquipment(1)=(WeaponClass=Class'Inventory.MachineGunWeapon')
	ViolenceRankTolerance=0
	TakesChemDamage=0.600000
	HealthMax=200.000000
	bPlayerIsFriend=True
	Gang="RWSStaff"
	DamageMult=2.500000
	FriendDamageThreshold=170.000000
	ControllerClass=Class'AWPawns.AWRWSController'

	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(4)=BoltonDef'BoltonDefBallcap_RWS'
	RandomizedBoltons(5)=None
 }
