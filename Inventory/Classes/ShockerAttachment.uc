///////////////////////////////////////////////////////////////////////////////
// Shocker attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class ShockerAttachment extends P2WeaponAttachment;

defaultproperties
	{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.Tazer3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)

	MuzzleFlashClass=class'ShockerMuzzleFlash'
	MuzzleRotationOffset=(Pitch=0,Yaw=0,Roll=0)
	MuzzleOffset=(X=28.000000,Y=-5.000000,Z=2.000000)
	FiringMode="SHOCKER1"
	WeapClass=class'ShockerWeapon'
	}
