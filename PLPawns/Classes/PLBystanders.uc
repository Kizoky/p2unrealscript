///////////////////////////////////////////////////////////////////////////////
// PLBystanders
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Paradise Lost bystanders, pretty much like regular bystanders but with
// dirty and roughed up clothes. Also, no cell phones or other luxuries.
///////////////////////////////////////////////////////////////////////////////
class PLBystanders extends Bystander
	placeable;
	
var BoltonDef DummyBolton;	// This is a dummy bolton so we have a reference to the Umbrella boltondef that can be manually inserted into maps.
							// Without it, the compiler doesn't save the Umbrella boltondef.

function PlayFootstep(optional float Volume, optional float Radius, optional float Pitch)
{
	// We don't play footsteps, but we DO want to update our SurfaceType so that we leave footprints in the snow.
	UpdateSurfaceType();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bUsePawnSlider=true
	bInnocent=true
	bCellUser=false

	// Default to chameleon skin and associated mesh
	Skins[0]=Texture'PLBystanderSkins.Female.XX__800__Fem_SS_Shorts'
	Mesh=Mesh'Characters.Fem_SS_Shorts'
	
	ChameleonSkins(00)="PLBystanderSkins.Female.FB__800__Fat_F_SS_Pants"
	ChameleonSkins(01)="PLBystanderSkins.Female.FB__801__Fem_LS_Pants"
	ChameleonSkins(02)="PLBystanderSkins.Female.FB__802__Fem_LS_Pants"
	ChameleonSkins(03)="PLBystanderSkins.Female.FB__808__Fem_SS_Shorts"
	ChameleonSkins(04)="PLBystanderSkins.Female.FM__803__Fem_LS_Pants"
	ChameleonSkins(05)="PLBystanderSkins.Female.FM__804__Fem_LS_Pants"
	ChameleonSkins(06)="PLBystanderSkins.Female.FM__809__Fem_SS_Shorts"
	ChameleonSkins(07)="PLBystanderSkins.Female.FM__812__Fem_LS_Skirt"
	ChameleonSkins(08)="PLBystanderSkins.Female.FW__805__Fat_F_SS_Pants"
	ChameleonSkins(09)="PLBystanderSkins.Female.FW__806__Fem_LS_Pants"
	ChameleonSkins(10)="PLBystanderSkins.Female.FW__807__Fem_LS_Pants"
	ChameleonSkins(11)="PLBystanderSkins.Female.FW__810__Fem_SS_Shorts"
	ChameleonSkins(12)="PLBystanderSkins.Female.FW__813__Fem_LS_Skirt"
	ChameleonSkins(13)="PLBystanderSkins.Female.FW__814__Fem_LS_Skirt"
	ChameleonSkins(14)="PLBystanderSkins.Female.FW__815__Fem_LS_Skirt"
	ChameleonSkins(15)="PLBystanderSkins.Female.FW__817__Fem_LS_Skirt"
	ChameleonSkins(16)="PLBystanderSkins.Female.FW__818__Fem_LS_Skirt"
	ChameleonSkins(17)="PLBystanderSkins.Male.MB__819__Avg_M_Jacket_Pants"
	ChameleonSkins(18)="PLBystanderSkins.Male.MB__825__Avg_M_SS_Pants"
	ChameleonSkins(19)="PLBystanderSkins.Male.MB__826__Avg_M_SS_Pants"
	ChameleonSkins(20)="PLBystanderSkins.Male.MB__833__Avg_M_SS_Shorts"
	ChameleonSkins(21)="PLBystanderSkins.Male.MB__837__Fat_M_SS_Pants"
	ChameleonSkins(22)="PLBystanderSkins.Male.MM__820__Avg_M_Jacket_Pants"
	ChameleonSkins(23)="PLBystanderSkins.Male.MM__827__Avg_M_SS_Pants"
	ChameleonSkins(24)="PLBystanderSkins.Male.MM__834__Avg_M_SS_Shorts"
	ChameleonSkins(25)="PLBystanderSkins.Male.MM__836__Fat_M_SS_Pants"
	ChameleonSkins(26)="PLBystanderSkins.Male.MM__838__Fat_M_SS_Pants"
	ChameleonSkins(27)="PLBystanderSkins.Male.MM__839__Fat_M_SS_Pants"
	ChameleonSkins(28)="PLBystanderSkins.Male.MW__821__Avg_M_Jacket_Pants"
	ChameleonSkins(29)="PLBystanderSkins.Male.MW__822__Avg_M_Jacket_Pants"
	ChameleonSkins(30)="PLBystanderSkins.Male.MW__823__Avg_M_Jacket_Pants"
	ChameleonSkins(31)="PLBystanderSkins.Male.MW__824__Avg_M_Jacket_Pants"
	ChameleonSkins(32)="PLBystanderSkins.Male.MW__828__Avg_M_SS_Pants"
	ChameleonSkins(33)="PLBystanderSkins.Male.MW__829__Avg_M_SS_Pants"
	ChameleonSkins(34)="PLBystanderSkins.Male.MW__830__Avg_M_SS_Pants"
	ChameleonSkins(35)="PLBystanderSkins.Male.MW__831__Avg_M_SS_Pants"
	ChameleonSkins(36)="PLBystanderSkins.Male.MW__832__Avg_M_SS_Pants"
	ChameleonSkins(37)="PLBystanderSkins.Male.MW__835__Avg_M_SS_Shorts"
	ChameleonSkins(38)="PLBystanderSkins.Male.MW__840__Fat_M_SS_Pants"
	ChameleonSkins(39)="PLBystanderSkins.Male.MW__841__Fat_M_Jacket_Pants"
	ChameleonSkins(40)="End"
	AmbientGlow=30

	Begin object class=BoltonDef Name=BoltonDefUmbrella
		Boltons(0)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_I',Skin=Texture'PL_Hart2.Boltons.ty_umbrella_Black',bCanDrop=True)
		Boltons(1)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_I',Skin=Texture'PL_Hart2.Boltons.ty_umbrella_Blue',bCanDrop=True)
		Boltons(2)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_U',Skin=Texture'PL_Hart2.Boltons.ty_umbrella_Black',bCanDrop=True)
		Boltons(3)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_U',Skin=Texture'PL_Hart2.Boltons.ty_umbrella_Blue',bCanDrop=True)
		Boltons(4)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_I',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella01',bCanDrop=True)
		Boltons(5)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_I',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella02',bCanDrop=True)
		Boltons(6)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_I',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella03',bCanDrop=True)
		Boltons(7)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_I',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella04',bCanDrop=True)
		Boltons(8)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_I',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella05',bCanDrop=True)
		Boltons(9)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_U',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella01',bCanDrop=True)
		Boltons(10)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_U',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella02',bCanDrop=True)
		Boltons(11)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_U',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella03',bCanDrop=True)
		Boltons(12)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_U',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella04',bCanDrop=True)
		Boltons(13)=(Bone="MALE01 R Hand",StaticMesh=StaticMesh'PL_tylermesh2.Boltons.ty_umbrella_U',Skin=Texture'PL-MeshSkins.Umbrellas.umbrella05',bCanDrop=True)
		UseChance=0.5
		Tag="SpecialHold"
		BodyType=Body_Avg
		ExcludeTags(0)="Briefcase"
		ExcludeTags(1)="Purse"
		ExcludeTags(2)="SpecialHold"
		ExcludeTags(3)="ShoppingBag"
		SpecialFlags=(bLargeAndBulky=True,SpecialHoldWalkAnim="pl_umbrella_walk",SpecialHoldStandAnim="pl_umbrella_stand")
	End Object		
	DummyBolton=BoltonDefUmbrella

	RandomizedBoltons(0)=BoltonDef'Postal2Game.BoltonDefAfro'
	RandomizedBoltons(1)=BoltonDef'Postal2Game.BoltonDefRastaHat_F'
	RandomizedBoltons(2)=BoltonDef'Postal2Game.BoltonDefRastaHat_F_LH'
	RandomizedBoltons(3)=BoltonDef'Postal2Game.BoltonDefRastaHat_M'
	RandomizedBoltons(4)=BoltonDef'Postal2Game.BoltonDefRastaHat_M_Fat'
	RandomizedBoltons(5)=BoltonDef'Postal2Game.BoltonDefFedora'
	RandomizedBoltons(6)=BoltonDef'Postal2Game.BoltonDefCowboyHat'
	RandomizedBoltons(7)=BoltonDef'Postal2Game.BoltonDefBallcap_Backwards'
	RandomizedBoltons(8)=BoltonDef'Postal2Game.BoltonDefBriefcase'
	RandomizedBoltons(9)=BoltonDef'Postal2Game.BoltonDefShades1'
	RandomizedBoltons(10)=BoltonDef'Postal2Game.BoltonDefShades2'
	RandomizedBoltons(11)=BoltonDef'Postal2Game.BoltonDefShades3'
	RandomizedBoltons(12)=BoltonDef'Postal2Game.BoltonDefBallcap'
	RandomizedBoltons(13)=BoltonDef'Postal2Game.BoltonDefBallcap_Fem'
	RandomizedBoltons(14)=BoltonDef'Postal2Game.BoltonDefPurse'
	RandomizedBoltons(15)=BoltonDef'Postal2Game.BoltonDefPurseGay'
	RandomizedBoltons(16)=BoltonDef'Postal2Game.BoltonDefCigarette_M'
	RandomizedBoltons(17)=BoltonDef'Postal2Game.BoltonDefCigarette_F'
	RandomizedBoltons(18)=BoltonDef'Postal2Game.BoltonDefEarring_M'
	RandomizedBoltons(19)=BoltonDef'Postal2Game.BoltonDefPornBag'
	RandomizedBoltons(20)=None
	
	Footprints[0]=(SurfaceType=EST_Snow,FootprintClassLeft=class'FootprintMaker_Snow_Left',FootprintClassRight=class'FootprintMaker_Snow_Right')
	
	RandomLieberWeapons(0)="AWPStuff.DustersWeapon"
	RandomLieberWeapons(1)="Inventory.BatonWeapon"
	RandomLieberWeapons(2)="Inventory.ShovelWeapon"
	RandomHestonWeapons(0)="Inventory.PistolWeapon"
	RandomHestonWeapons(1)="EDStuff.GSelectWeapon"
	RandomHestonWeapons(2)="Inventory.ShotgunWeapon"
	RandomHestonWeapons(3)="Inventory.MachineGunWeapon"
	RandomHestonWeapons(4)="EDStuff.MP5Weapon"
	RandomHestonWeapons(5)="PLInventory.LeverActionShotgunWeapon"
	RandomHestonWeapons(6)="PLInventory.RevolverWeapon"
	RandomInsaneWeapons(0)="Inventory.PistolWeapon"
	RandomInsaneWeapons(1)="EDStuff.GSelectWeapon"
	RandomInsaneWeapons(2)="Inventory.ShotgunWeapon"
	RandomInsaneWeapons(3)="Inventory.MachineGunWeapon"
	RandomInsaneWeapons(4)="EDStuff.DynamiteWeapon"
	RandomInsaneWeapons(5)="Inventory.GrenadeWeapon"
	RandomInsaneWeapons(6)="Inventory.MolotovWeapon"
	RandomInsaneWeapons(7)="Inventory.ScissorsWeapon"
	RandomInsaneWeapons(8)="EDStuff.MP5Weapon"
	RandomInsaneWeapons(9)="PLInventory.LeverActionShotgunWeapon"
	RandomInsaneWeapons(10)="PLInventory.RevolverWeapon"
	RandomInsaneWeapons(11)="PLInventory.FGrenadeWeapon"
	RandomRareWeapons(0)="EDStuff.GrenadeLauncherWeapon"
	RandomRareWeapons(1)="Inventory.LauncherWeapon"
	RandomRareWeapons(2)="Inventory.NapalmWeapon"
	RandomMeleeWeapons(0)="AWPStuff.DustersWeapon"
	RandomMeleeWeapons(1)="AWInventory.MacheteWeapon"
	RandomMeleeWeapons(2)="AWInventory.ScytheWeapon"
	RandomMeleeWeapons(3)="EDStuff.ShearsWeapon"
	RandomMeleeWeapons(4)="Inventory.ShovelWeapon"
	RandomMeleeWeapons(5)="AWInventory.SledgeWeapon"
	RandomMeleeWeapons(6)="EDStuff.AxeWeapon"
	RandomMeleeWeapons(7)="AWPStuff.BaseballBatWeapon"
	RandomLudicrousWeapons(0)="Inventory.CowHeadWeapon"
	RandomLudicrousWeapons(1)="Inventory.PlagueWeapon"
	RandomLudicrousWeapons(2)="AWPStuff.SawnOffWeapon"
}