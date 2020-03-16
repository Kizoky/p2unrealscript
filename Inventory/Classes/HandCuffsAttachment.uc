///////////////////////////////////////////////////////////////////////////////
// HandCuffs attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class HandCuffsAttachment extends P2WeaponAttachment;

defaultproperties
	{	
	StaticMesh=StaticMesh'TP_Weapons.Handcuffs3'
	DrawType=DT_StaticMesh
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)
	WeapClass=class'HandCuffsWeapon'
	}
