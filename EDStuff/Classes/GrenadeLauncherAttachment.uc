///////////////////////////////////////////////////////////////////////////////
// Pistol attachment for 3rd person
//
// Weapon attachment gets it's ThirdPersonEffects called on all remote
// clients all the time when things are fired. Instead of having PlayOwnedSound
// *also* getting replicated to all remote clients to play the firing sound
// for fast-firing things like guns, I put it into here. It's messier, but
// it saves bandwidth.
///////////////////////////////////////////////////////////////////////////////
class GrenadeLauncherAttachment extends P2WeaponAttachment;

defaultproperties
{
     MuzzleFlashClass=Class'PistolMuzzleFlash'
     MuzzleOffset=(X=65.000000,Z=5.000000)
	 CatOffset=(X=52.000000,Y=-2,Z=11.000000)
     WeapClass=Class'GrenadeLauncherWeapon'
     DrawType=DT_StaticMesh
     RelativeLocation=(Y=1.000000)
     RelativeRotation=(Roll=32768)
     StaticMesh=StaticMesh'ED_TPMeshes.Weapons.TP_M79'
}
