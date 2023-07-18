///////////////////////////////////////////////////////////////////////////////
// Rifle attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class GSelectAttachment extends P2DualWeaponAttachment;

defaultproperties
{
     MuzzleFlashClass=Class'Inventory.PistolMuzzleFlash'
	 //MuzzleFlashClass=class'EmitterMuzzleFlash'
     MuzzleOffset=(X=28.000000,Z=5.000000)
	 CatOffset=(X=24.000000,Y=0.000000,Z=10.000000)	// xPatch
     WeapClass=Class'GSelectWeapon'
     DrawType=DT_StaticMesh
     RelativeLocation=(Y=1.000000,Z=-0.300000)
     RelativeRotation=(Roll=32768)
     StaticMesh=StaticMesh'ED_TPMeshes.Weapons.TP_Glock'
}
