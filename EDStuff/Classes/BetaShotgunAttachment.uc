class BetaShotgunAttachment extends P2WeaponAttachment;

defaultproperties
	{	
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.TP_Original_Shotgun'
	DrawScale=0.8

	MuzzleFlashClass=class'Inventory.ShotgunMuzzleFlash'
	//MuzzleFlashClass=class'EmitterMuzzleFlash'	
	MuzzleRotationOffset=(Pitch=0,Yaw=0,Roll=0)
	MuzzleOffset=(X=75.000000,Y=0.000000,Z=5.000000)
	WeapClass=class'ShotgunWeapon'

	FireSound=Sound'WeaponSoundsToo.BetaShotgun' //'WeaponSounds.shotgun_fire'
	}
