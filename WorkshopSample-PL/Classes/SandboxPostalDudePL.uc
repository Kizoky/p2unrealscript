///////////////////////////////////////////////////////////////////////////////
// Sandbox Postal Dude
// In the base game, the Postal Dude has a bandaged head skin by default
// that gets swapped out. Here's a version of the dude that defaults to the
// non-bandaged head skin.
// We could fix this in the GameInfo, but I'm doing this instead as an example
// of how to create your own Dude class.
//
// New player classes should extend from AWDude and not AWPostalDude
// because AWPostalDude includes special handling for changing out the head
// skin.
///////////////////////////////////////////////////////////////////////////////
class SandboxPostalDudePL extends AWDude;

// In the default properties, make his head skin use the un-bandaged one
defaultproperties
{
	// This extends from AWDude and not AWPostalDude, so we need to define his base equipment again.
	// You can also use this opportunity to add your own base equipment, like a really sweet weapon
    BaseEquipment(0)=(WeaponClass=Class'UrethraWeapon')
    BaseEquipment(1)=(WeaponClass=Class'FootWeapon')
    BaseEquipment(2)=(WeaponClass=Class'MatchesWeapon')
	
	// Define skins and head skins here. Give the dude an even more badass coat if you want!
    Skins(0)=Texture'PLCharacterSkins.Dude.Dude_HiRes'
    HeadSkin=Texture'AW_Characters.Special.Dude_AW'
    HeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
    HeadClass=Class'AWDudeHead'
	DialogClass=Class'DialogDudePL'
	HandsClassNormal="PLInventory.PLHandsWeapon"
	Footprints[0]=(SurfaceType=EST_Snow,FootprintClassLeft=class'FootprintMaker_Snow_Left',FootprintClassRight=class'FootprintMaker_Snow_Right')
	AmbientGlow=30
}
