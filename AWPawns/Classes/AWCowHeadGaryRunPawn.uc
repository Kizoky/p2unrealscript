//=============================================================================
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//	Warning!
//	Do not use any of the 'initial states' such as Attack Player or Panic with
// this character or he may do unpredictable things. He will not function as
// expected. Just place this guy and let him go for expected results.
//=============================================================================
class AWCowheadGaryRunPawn extends AWCowheadGaryPawn
	placeable;

defaultproperties
{
	BaseEquipment(0)=(WeaponClass=Class'Inventory.ScissorsWeapon')
	BaseEquipment(1)=(WeaponClass=Class'AWInventory.AWGrenadeWeapon')
	HealthMax=50.000000
	ControllerClass=Class'AWPawns.AWCowHeadGaryRunController'
	Skins(0)=Texture'AW_Characters.Zombie_Skins.Pygmy_skin'
	//Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel11
	//	KSkeleton="Avg_Mini_Skel"
	//	KFriction=0.500000
	//	Name="KarmaParamsSkel11"
	//End Object
	//KParams=KarmaParamsSkel'AWPawns.KarmaParamsSkel11'
	CharacterType=CHARACTER_Mini
}
