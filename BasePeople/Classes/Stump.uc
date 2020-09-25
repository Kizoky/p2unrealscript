///////////////////////////////////////////////////////////////////////////////
// Stump
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Bloody bone stump where limb was.
//
///////////////////////////////////////////////////////////////////////////////
class Stump extends PeoplePart;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var bool bFat;					// from a fat person
var bool bFemale;				// from a girl
var bool bPants;				// has pant leg showing
var bool bSkirt;				// has skirt on
var byte StumpIndex;			// which part you are

var const array<StaticMesh> Meshes;	// various stumps
var const array<StaticMesh> FemaleMeshes; // same stumps, but for girls
var const array<StaticMesh> SkirtMeshes; // same stumps, but for skirts

var const byte LeftLegI, RightLegI, LeftArmI, RightArmI;	// indices into Meshes array
var const byte TorsoI, PelvisI;

var bool bClientSync;

///////////////////////////////////////////////////////////////////////////////
// CONSTS
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Some of you'll be made again after the load, so don't let yourself be loaded
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	//log(Self$" post load game, stump index "$stumpindex);
	if(stumpindex == TorsoI
		|| stumpindex == PelvisI)
		Destroy();
	else
	{
		//log(Self$" continuing on ");
		Super.PostLoadGame();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Conversion functions to keep all the various classes and permutations down
// a little. This is only for single player. MP games will want each class
// created seperately.
///////////////////////////////////////////////////////////////////////////////
function ConvertToLeftArm()
{
	StumpIndex=LeftArmI;
	SetStaticMesh(Meshes[LeftArmI]);
}
function ConvertToRightArm()
{
	StumpIndex=RightArmI;
	SetStaticMesh(Meshes[RightArmI]);
}
function ConvertToLeftLeg()
{
	StumpIndex=LeftLegI;
	if(bSkirt)
		SetStaticMesh(SkirtMeshes[LeftLegI]);
	else if(bFemale)
		SetStaticMesh(FemaleMeshes[LeftLegI]);
	else
		SetStaticMesh(Meshes[LeftLegI]);
}
function ConvertToRightLeg()
{
	StumpIndex=RightLegI;
	if(bSkirt)
		SetStaticMesh(SkirtMeshes[RightLegI]);
	else if(bFemale)
		SetStaticMesh(FemaleMeshes[RightLegI]);
	else
		SetStaticMesh(Meshes[RightLegI]);
}
function ConvertToTorso()
{
	StumpIndex=TorsoI;
	if(bFemale)
		SetStaticMesh(FemaleMeshes[TorsoI]);
	else
		SetStaticMesh(Meshes[TorsoI]);
}
function ConvertToPelvis()
{
	StumpIndex=PelvisI;
	if(bFemale)
		SetStaticMesh(FemaleMeshes[PelvisI]);
	else
		SetStaticMesh(Meshes[PelvisI]);
}

///////////////////////////////////////////////////////////////////////////////
// Setup the stump
///////////////////////////////////////////////////////////////////////////////
simulated function SetupStump(Material NewSkin, byte NewAmbientGlow,
							 bool bNewFat, bool bNewFemale, bool bNewPants,
							 bool bNewSkirt)
{
	// Ambient glow should match body
	AmbientGlow = NewAmbientGlow;

	// setup appropriate skin
	Skins[0]=NewSkin;

	bFat=bNewFat;
	bFemale=bNewFemale;
	bPants = bNewPants;
	bSkirt = bNewSkirt;
}

// Change by NickP: MP fix
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (Role < ROLE_Authority && bClientSync)
	{
		if (AWPerson(Base) != None 
			&& !Base.bDeleteMe 
			&& AttachmentBone != '')
		{
			AWPerson(Base).ClientSetupStump(self);
		}
		else Destroy();
	}
}
// End

defaultproperties
{
	// Change by NickP: MP fix
	bClientSync=true
	bReplicateSkin=true
	// End

     Meshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump'
     Meshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump'
     Meshes(2)=StaticMesh'awpeoplestatic.Limbs.L_arm_stump'
     Meshes(3)=StaticMesh'awpeoplestatic.Limbs.R_arm_stump'
     Meshes(4)=StaticMesh'awpeoplestatic.Limbs.male_upper_torso'
     Meshes(5)=StaticMesh'awpeoplestatic.Limbs.male_lower_torso'
     FemaleMeshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump_Fem'
     FemaleMeshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump_Fem'
     FemaleMeshes(4)=StaticMesh'awpeoplestatic.Limbs.fem_upper_torso'
     FemaleMeshes(5)=StaticMesh'awpeoplestatic.Limbs.fem_lower_torso'
     SkirtMeshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump_skirt'
     SkirtMeshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump_skirt'
     RightLegI=1
     LeftArmI=2
     RightArmI=3
     TorsoI=4
     PelvisI=5
     DrawType=DT_StaticMesh
     RelativeRotation=(Pitch=16383)
     StaticMesh=StaticMesh'awpeoplestatic.Limbs.L_arm_stump'
     Skins(0)=Texture'ChameleonSkins.Special.RWS_Shorts'
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
