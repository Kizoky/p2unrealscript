///////////////////////////////////////////////////////////////////////////////
// Machinegun attachment for 3rd person
//
// Weapon attachment gets it's ThirdPersonEffects called on all remote
// clients all the time when things are fired. Instead of having PlayOwnedSound
// *also* getting replicated to all remote clients to play the firing sound
// for fast-firing things like guns, I put it into here. It's messier, but
// it saves bandwidth.
///////////////////////////////////////////////////////////////////////////////
class MachinegunAttachment extends P2DualWeaponAttachment;

defaultproperties
	{	
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.MachineGun3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)

	MuzzleFlashClass=class'Inventory.MachinegunMuzzleFlash'
	//MuzzleFlashClass=class'EmitterMuzzleFlash'
	MuzzleRotationOffset=(Pitch=0,Yaw=0,Roll=0)
	MuzzleOffset=(X=68.000000,Y=-4.000000,Z=8.000000)
	CatOffset=(X=55.000000,Y=-3.000000,Z=10.000000)		// xPatch
	WeapClass=class'MachinegunWeapon'

	FireSound=Sound'WeaponSounds.machinegun_fire'
	}
