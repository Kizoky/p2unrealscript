///////////////////////////////////////////////////////////////////////////////
// GasCan attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class GasCanAttachment extends P2WeaponAttachment;

defaultproperties
	{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.GasCan3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	WeapClass=class'GasCanWeapon'
	}
