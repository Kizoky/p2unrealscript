///////////////////////////////////////////////////////////////////////////////
// StumpCow
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Bloody neck stump where head was.
//
///////////////////////////////////////////////////////////////////////////////
class StumpCow extends PeoplePart;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var bool bExploded;

var StaticMesh ExplodedMesh;

///////////////////////////////////////////////////////////////////////////////
// CONSTS
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// Setup the stump
///////////////////////////////////////////////////////////////////////////////
simulated function SetupStump(Material NewSkin, byte NewAmbientGlow,
							  bool bNewExploded)
{
	// Ambient glow should match body
	AmbientGlow = NewAmbientGlow;

	// setup appropriate skin
	Skins[0]=NewSkin;

	bExploded=bNewExploded;

	if(bExploded)
		SetStaticMesh(ExplodedMesh);
}

defaultproperties
{
     ExplodedMesh=StaticMesh'awpeoplestatic.Limbs.Cow_neck_2'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'awpeoplestatic.Limbs.Cow_neck'
     Skins(0)=Texture'AW_Characters.Zombie_Cows.AW_Cow3'
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}