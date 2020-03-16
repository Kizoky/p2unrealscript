//=============================================================================
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class BankRobber extends Bystander
 	placeable;

defaultproperties
	{
	ActorID="Robber"
	PainThreshold=1.0
	Cajones=1.0
	Skins[0]=Texture'ChameleonSkins.MM__018__Avg_M_Jacket_Pants'
	Mesh=Mesh'Characters.Avg_M_Jacket_Pants'
	HeadSkin=Texture'ChamelHeadSkins.Special.Robber'
	HeadMesh=Mesh'Heads.Masked'
	BaseEquipment[0]=(weaponclass=class'Inventory.ShotgunWeapon')
	ControllerClass=class'RobberController'
	// Pick nothing on startup--let controller take over
	StartWeapon_Group=-1
	StartWeapon_Offset=-1
	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None
	}
