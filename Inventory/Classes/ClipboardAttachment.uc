///////////////////////////////////////////////////////////////////////////////
// Clipboard attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class ClipboardAttachment extends P2WeaponAttachment;

defaultproperties
{	
	DrawType=DT_StaticMesh
	DrawScale=0.5
	StaticMesh=StaticMesh'TP_Weapons.Clipboard3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)
	WeapClass=class'ClipboardWeapon'
}
