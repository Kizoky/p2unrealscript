/**
 * RevolverAttachment
 */
class RevolverAttachment extends P2WeaponAttachment;

defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'PL_Weapons_Mesh.Revolver.TP_Magnum'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(Y=1,Z=-0.3)

	MuzzleFlashClass=class'PistolMuzzleFlash'
	MuzzleRotationOffset=(Pitch=0,Yaw=0,Roll=0)
	MuzzleOffset=(X=28,Z=5)
	WeapClass=class'RevolverWeapon'

	FireSound=sound'PLWeapons.Revolver.Revolver_shoot1'
	
	CatOffset=(X=28.000000,Y=0.000000,Z=7.000000)	// xPatch
}
