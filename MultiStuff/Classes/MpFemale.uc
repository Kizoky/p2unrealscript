///////////////////////////////////////////////////////////////////////////////
// MpFemale.uc
// Copyright 2019 Running With Scissors.  All Rights Reserved.
// by NickP, nickp@gopostal.com
//
// Base mp female character.
//
///////////////////////////////////////////////////////////////////////////////
class MpFemale extends xMpPawn;

const FEM_PEE_BONE = 'MALE01 pelvis';

function name GetWeaponBoneFor(Inventory I)
{
	if( UrethraWeapon(I) != None )
		return FEM_PEE_BONE;
	else return Super.GetWeaponBoneFor(I);
}

defaultproperties
{
	HeadSkin=Texture'ChamelHeadSkins.Female.FWA__026__FemLH'
	HeadMesh=SkeletalMesh'heads.FemLH'
	dialogclass=class'MpFemaleDialog'
	HandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_girl'
	FootTexture=Texture'ChameleonSkins.BystandersF.FW__084__Fem_LS_Skirt'
	DudeSuicideSound=Sound'WFemaleDialog.wf_postal_forgiveme'
	bIsFemale=true
	MenuName="Girl"
	Mesh=SkeletalMesh'Characters.Fem_LS_Skirt'
	Skins(0)=Texture'ChameleonSkins.BystandersF.FW__084__Fem_LS_Skirt'
}
