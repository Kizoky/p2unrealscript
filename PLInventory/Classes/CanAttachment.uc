///////////////////////////////////////////////////////////////////////////////
// Can attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class CanAttachment extends P2WeaponAttachment;

defaultproperties
{	
	DrawType=DT_StaticMesh
	DrawScale=0.5
	StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.OldTinCup_D'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)
	WeapClass=class'CanWeapon'
}
