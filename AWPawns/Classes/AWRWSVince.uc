//=============================================================================
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class AWRWSVince extends AWRWSStaff
	placeable;

// Vince needs to not use the turning anims when using these anims

simulated function PlayLaughingAnim()
{
	ChangePhysicsAnimUpdate(false);
	PlayAnim(GetAnimLaugh(), 1.0, 0.15);
}
simulated function PlayYourFiredAnim()
{
	ChangePhysicsAnimUpdate(false);
	PlayAnim('s_fired', 1.0, 0.15);
}


// Let his tag be 'AWRWSVince'

defaultproperties
{
	ActorID="Vince"
	HeadSkin=Texture'ChamelHeadSkins.Special.Vince'
	HeadMesh=SkeletalMesh'heads.AvgMale'
	WeapChangeDist=200.000000
	dialogclass=Class'AWPawns.AWDialogVince'
	BaseEquipment(0)=(WeaponClass=Class'AWInventory.SledgeWeapon')
	BaseEquipment(1)=(WeaponClass=Class'Inventory.ShotGunWeapon')
	bPersistent=True
	bCanTeleportWithPlayer=False
	bKeepForMovie=True
	//Mesh=SkeletalMesh'Characters.Avg_M_SS_Pants'
	//Skins(0)=Texture'ChameleonSkins.Special.RWS_Pants'
}
