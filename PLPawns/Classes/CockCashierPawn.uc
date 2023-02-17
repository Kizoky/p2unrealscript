///////////////////////////////////////////////////////////////////////////////
// CockCashierPawn
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Class for Cock Asian Cashier. Set to always female because we don't have
// male dialog for the extended cashier transactions
///////////////////////////////////////////////////////////////////////////////
class CockCashierPawn extends CashierDialogPawn
	placeable;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Female;
}

defaultproperties
{
	ActorID="Cashier"

	bUsePawnSlider=false
	bInnocent=true
	//ControllerClass=class'CockCashierController'
	bIsFemale=true
	Skins[0]=Texture'PLCharacterSkins.cockasian.FW__307__Fat_F_SS_Pants'
	Mesh=SkeletalMesh'Characters.Fat_F_SS_Pants'
	HeadSkin=Texture'ChamelHeadSkins.FWF__023__FatFem'
	HeadMesh=SkeletalMesh'heads.FatFem'
	DialogClass=class'BasePeople.DialogFemale'
	bStartupRandomization=false
	Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.cockasian.cockhat_fatfem',Skin=Texture'PLCharacterSkins.cockasian.ChicHat',bAttachToHead=True)
	Gang="CockAsian"

	bNoChamelBoltons=True
	bCanEnterHomes=true
	bAngryWithHomeInvaders=true
	
	//ChameleonSkins(0)="PLCharacterSkins.cockasian.FW__307__Fat_F_SS_Pants"
	//ChameleonSkins(1)="End"
	AmbientGlow=30
	bCellUser=false
}
