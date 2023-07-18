///////////////////////////////////////////////////////////////////////////////
// Shotgun attachment for 3rd person
//
// Weapon attachment gets it's ThirdPersonEffects called on all remote
// clients all the time when things are fired. Instead of having PlayOwnedSound
// *also* getting replicated to all remote clients to play the firing sound
// for fast-firing things like guns, I put it into here. It's messier, but
// it saves bandwidth.
///////////////////////////////////////////////////////////////////////////////
class ShotgunAttachment extends P2WeaponAttachment;

defaultproperties
	{	
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.Shotgun3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)
	
	MuzzleFlashClass=class'ShotgunMuzzleFlash'
	//MuzzleFlashClass=class'EmitterMuzzleFlash'	
	MuzzleRotationOffset=(Pitch=0,Yaw=0,Roll=0)
	MuzzleOffset=(X=75.000000,Y=0.000000,Z=5.000000)
	CatOffset=(X=75.000000,Y=-3.000000,Z=7.500000)		// xPatch
	WeapClass=class'ShotgunWeapon'

	FireSound=Sound'WeaponSounds.shotgun_fire'
	}
