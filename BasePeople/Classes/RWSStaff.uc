//=============================================================================
// RWSStaff.uc
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all RWS staff members.
//
//=============================================================================
class RWSStaff extends Bystander
	notplaceable
	Abstract;


defaultproperties
	{
	Skins[0]=Texture'ChameleonSkins2.RWS.XX__204__Avg_M_SS_Shorts'
	Mesh=Mesh'Characters.Avg_M_SS_Shorts'
	// RWS skins
	ChameleonSkins[0]="ChameleonSkins2.RWS.MW__202__Avg_M_SS_Pants_D"
	ChameleonSkins[1]="ChameleonSkins2.RWS.MW__203__Avg_M_SS_Pants_D"
	// For third skin, individual RWS classes decide whether to use pants or shorts with the "old" RWS tee.
	// Pants is MW__205__Avg_M_SS_Pants
	// Shorts is MW__206__Avg_M_SS_Shorts
	ChameleonSkins[2]="ChameleonSkins2.RWS.MW__205__Avg_M_SS_Pants"
	//ChameleonSkins[2]="ChameleonSkins2.RWS.MW__206__Avg_M_SS_Shorts"
	ChameleonSkins[3]="End"

	ControllerClass=class'RWSController'
	// rws staff are trained and well armed
	bIsTrained=true
	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.MachinegunWeapon')
	bPlayerIsFriend=true
	Gang="RWSStaff"
	bRandomizeHeadScale=false
	bStartupRandomization=false
	HealthMax=200
	PainThreshold=1.0
	Rebel=1.0
	DamageMult=2.5
	Cajones=1.0
	Stomach=1.0
	Psychic=0.4
	Glaucoma=0.3
	ViolenceRankTolerance=0
	FriendDamageThreshold=170

	TakesShotgunHeadShot=	0.25
	TakesShovelHeadShot=	0.35
	TakesOnFireDamage=		0.4
	TakesAnthraxDamage=		0.5
	TakesShockerDamage=		0.3
	TakesChemDamage=		0.6

	Begin Object Class=BoltonDef Name=BoltonDefBallcap_RWS
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws',bAttachToHead=True)
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws2',bAttachToHead=True)
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws3',bAttachToHead=True)
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws4',bAttachToHead=True)
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws5',bAttachToHead=True)
		Gender=Gender_Male
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object

	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(4)=BoltonDef'BoltonDefBallcap_RWS'
	RandomizedBoltons(5)=None
	BlockMeleeFreq=1.0
	}
