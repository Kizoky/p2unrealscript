//===============================================================================================
// ""Fix"" for many MP5 issues like SWAT not carrying the weapon while patroling streets
// Weird fire-rate etc. Basically MachineGun but drops MP5 and looks like it in 3rd person.
//===============================================================================================
class MP5Weapon_NPC extends MachineGunWeapon;

state NormalFire
{
// HACK to improve machinegun fire rate
Begin:
	if (Class == class'MP5Weapon_NPC')
		Goto('BeginHack');
	else
		Goto('');
BeginHack:
	Sleep(1/ActualFireRate);
	Finish();
	Goto('BeginHack');
}

defaultproperties
{
	PickupClass=Class'MP5Pickup'
	AmmoName=Class'NineAmmoInv'
    AttachmentClass=Class'MP5Attachment'
	FireSound=Sound'EDWeaponSounds.Weapons.MP5'
    AltFireSound=Sound'EDWeaponSounds.Weapons.MP5'
    ShellClass=Class'Postal2Game.P2Shell_9mm'
}
