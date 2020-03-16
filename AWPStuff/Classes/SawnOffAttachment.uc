class SawnOffAttachment extends P2WeaponAttachment;

defaultproperties
{
	MuzzleFlashClass=Class'Inventory.ShotgunMuzzleFlash'
	//MuzzleFlashClass=class'EmitterMuzzleFlash'
	MuzzleOffset=(X=75.000000,Z=5.000000)
	WeapClass=Class'SawnOffWeapon'
	FireSound=Sound'AW7Sounds.MiscWeapons.SawnOff_Fire'
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'AW7EDMesh.Weapons.TP_SawnOff'
	DrawScale=1.2
	RelativeRotation=(Pitch=-1600)
}
