/**
 * LeverActionShotgunAttachment
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Attachment for the Lever Action Shotgun
 *
 * @author Gordon Cheng
 */
class LeverActionShotgunAttachment extends P2DualWeaponAttachment;

defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'PL_Weapons_Mesh.1887.TP_1887'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)

	MuzzleFlashClass=class'ShotgunMuzzleFlash'
	//MuzzleFlashClass=class'EmitterMuzzleFlash'
	MuzzleRotationOffset=(Pitch=0,Yaw=0,Roll=0)
	MuzzleOffset=(X=75.000000,Y=0.000000,Z=5.000000)
	WeapClass=class'LeverActionShotgunWeapon'

	FireSound=Sound'WeaponSounds.shotgun_fire'
}
