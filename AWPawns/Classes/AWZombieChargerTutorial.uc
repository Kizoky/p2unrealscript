//=============================================================================
// AWZombieCharger
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Charges you more often
//
//=============================================================================
class AWZombieChargerTutorial extends AWZombieCharger
	placeable;

// Explanation: in the patch we expanded the number of zombie skins and let
// the chameleon pick them out, but in certain levels the LD would override the
// head and/or skin texture, causing some funky results. AWZombie has a quick-fix
// to bypass these selections and generate random zombies, but of course this
// has come back to bite us in the butt and mess up the visuals for the tutorial
// and fast food zombie in LowerParadise.fuk... so here's another quick-fix
// to bypass the bypass. Hopefully this won't come back and bite us again :)

// Kamek from the future - So hey this bit us in the ass again with the magical
// clothes-changing zombies. Guess we'll have to do this the hard way.

/*
function PreBeginPlay()
{
	Super(AWPerson).PreBeginPlay();
}
*/

defaultproperties
{
	HeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_M02'
	HeadMesh=SkeletalMesh'AW_Heads.AW_Zombie'
	Mesh=SkeletalMesh'AWCharacters.Zombie_M_Jacket_Pants'
	Skins(0)=Texture'AW_Characters.Zombie_Skins.Zombie_skin_M02'
}
