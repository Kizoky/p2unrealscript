///////////////////////////////////////////////////////////////////////////////
// Rifle attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class MP5Attachment extends P2DualWeaponAttachment;

defaultproperties
{
     MuzzleFlashClass=Class'MP5MuzzleFlash'
     MuzzleOffset=(X=58.000000,Z=10.000000)
	 CatOffset=(X=45.000000,Y=-2.000000,Z=12.000000)	// xPatch
     FireSound=Sound'EDWeaponSounds.Weapons.MP5'
     DrawType=DT_StaticMesh
     RelativeLocation=(Y=1.000000,Z=-0.300000)
     RelativeRotation=(Roll=32768)
     StaticMesh=StaticMesh'ED_TPMeshes.Weapons.TP_MP5'
}
