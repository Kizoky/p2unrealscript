///////////////////////////////////////////////////////////////////////////////
// Rifle attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class RifleAttachment extends P2WeaponAttachment;

defaultproperties
	{	
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.Sniper3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)

	MuzzleFlashClass=class'RifleMuzzleFlash'
	//MuzzleFlashClass=class'EmitterMuzzleFlash'	
	MuzzleRotationOffset=(Pitch=0,Yaw=0,Roll=0)
	MuzzleOffset=(X=98.000000,Y=0.000000,Z=10.000000)
	CatOffset=(X=90.000000,Y=-1.500000,Z=10.000000)
	WeapClass=class'RifleWeapon'
	
	FireSound=Sound'WeaponSounds.sniper_fire'
	}
