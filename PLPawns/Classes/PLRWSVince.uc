///////////////////////////////////////////////////////////////////////////////
// PL Vince aka "Papa Desi"
///////////////////////////////////////////////////////////////////////////////
class PLRWSVince extends PLRWSStaff
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
	ActorID="PLRWSVince"

	HeadSkin=Texture'ChamelHeadSkins.Special.Vince'
	HeadMesh=SkeletalMesh'heads.AvgMale'
	Mesh=SkeletalMesh'Characters.Avg_M_SS_Pants_D'
	Skins[0]=Texture'ChameleonSkins2.rws.MW__203__Avg_M_SS_Pants_D'
	WeapChangeDist=200.000000
	dialogclass=Class'DialogVince'
	BaseEquipment(0)=(WeaponClass=Class'AWInventory.SledgeWeapon')
	BaseEquipment(1)=(WeaponClass=Class'Inventory.ShotGunWeapon')
	bPersistent=True
	bCanTeleportWithPlayer=False
	bKeepForMovie=True
	//Mesh=SkeletalMesh'Characters.Avg_M_SS_Pants'
	//Skins(0)=Texture'ChameleonSkins.Special.RWS_Pants'
	AmbientGlow=30
	bCellUser=false
	bNoDismemberment=True
	TakesShotgunHeadShot=0.1
	TakesRifleHeadShot=		0.1
	TakesShovelHeadShot=	0.25
	TakesOnFireDamage=		0.3
	TakesAnthraxDamage=		0.4
	TakesShockerDamage=		0.1
	TakesChemDamage=		0.5
}
