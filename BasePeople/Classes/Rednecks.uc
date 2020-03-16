///////////////////////////////////////////////////////////////////////////////
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
//  Country rednecks. One of the groups to end up hating the dude.
//
///////////////////////////////////////////////////////////////////////////////
class Rednecks extends Bystander
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
	Skins[0]=Texture'ChameleonSkins.XX__154__Avg_M_SS_Pants'
	Mesh=Mesh'Characters.Avg_M_SS_Pants'

	ChameleonSkins(0)="ChameleonSkins.MW__055__Avg_M_SS_Pants"
	ChameleonSkins(1)="ChameleonSkins.MW__072__Big_M_LS_Pants"
	ChameleonSkins(2)="ChameleonSkins.MW__103__Fat_M_SS_Pants"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)

	bIsTrained=false
	BaseEquipment[0]=(weaponclass=class'Inventory.ShotgunWeapon')
	Gang="Rednecks"
	HealthMax=100
	PainThreshold=0.95
	Glaucoma=0.8
	Rebel=1.0
	Cajones=0.8
	Stomach=0.9
	Greed=0.8
	ViolenceRankTolerance=1
	TalkWhileFighting=0.3
	TalkBeforeFighting=0.5
    ControllerClass=class'RedneckController'
	DialogClass=class'BasePeople.DialogRedneck'

	Begin Object Class=BoltonDef Name=BoltonDef_CowboyHat_RedNeck
		UseChance=0.5
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat01_M',Skin=Texture'Boltons_Tex.fedora_black',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat01_M',Skin=Texture'Boltons_Tex.fedora_brown',bAttachToHead=True)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat01_M',Skin=Texture'Boltons_Tex.fedora_uv',bAttachToHead=True)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat02_M',Skin=Texture'Boltons_Tex.cowboy_uvw',bAttachToHead=True)
		Boltons(4)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CowboyHat02_M',Skin=Texture'Boltons_Tex.cowboy_white',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		Tag="Hat"
		ExcludeTags(0)="Hat"
		ExcludeSkins(0)=Texture'ChameleonSkins.BystandersM.MM__018__Avg_M_Jacket_Pants'
		ExcludeSkins(1)=Texture'ChameleonSkins.BystandersM.MW__019__Avg_M_Jacket_Pants'
		ExcludeSkins(2)=Texture'ChameleonSkins.BystandersM.MW__021__Avg_M_Jacket_Pants'		
		ExcludeSkins(3)=Texture'ChameleonSkins.Scientists.MW__005__Avg_Dude'
		ExcludeSkins(4)=Texture'ChameleonSkins.Scientists.MW__006__Avg_Dude'
		ExcludeSkins(5)=Texture'ChameleonSkins.Scientists.MW__163__Avg_Dude'
		ExcludeSkins(6)=Texture'ChameleonSkins.Scientists.MW__164__Avg_Dude'
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
	End Object
	Begin Object Class=BoltonDef Name=BoltonDef_Cigarette_RedNeck
		UseChance=0.25
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.cigarette_M',bAttachToHead=True)
		BodyType=Body_Avg
		Tag="Mouth"
		ExcludeTags(0)="Mouth"
	End Object
		
	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(4)=BoltonDef'BoltonDef_CowboyHat_RedNeck'
	RandomizedBoltons(5)=BoltonDef'BoltonDef_Cigarette_RedNeck'
	RandomizedBoltons(6)=None
	}
