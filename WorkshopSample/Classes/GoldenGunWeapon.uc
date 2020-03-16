///////////////////////////////////////////////////////////////////////////////
// GoldenGunWeapon
// A modified pistol with infinite ammo and instagib.
///////////////////////////////////////////////////////////////////////////////
class GoldenGunWeapon extends PistolWeapon;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// Change out a few properties here for our new gun.
	ItemName="Golden Gun"
	AmmoName=class'GoldenGunAmmoInv'
	
	// Set CanThrow to false, that way it can't be removed.
	// We don't need to create new pickup classes this way, either.
	bCanThrow=false

	InventoryGroup=2
	// Make sure to change the GroupOffset, otherwise the player will be unable to access the regular pistol.
	GroupOffset=90
	ReloadCount=0
	TraceAccuracy=0

	// Make it a bit faster
	WeaponSpeedHolster = 4.5
	WeaponSpeedLoad    = 4.5
	WeaponSpeedReload  = 4.5
	WeaponSpeedShoot1  = 3.0
	WeaponSpeedShoot1Rand=0.04
	WeaponSpeedShoot2  = 3.0

	// These are basically code-form definitions for the "golden" effect that is applied to the weapon.
	// You can also make these in the editor and save it as a package to include with your mod.	
	// We define three materials for our golden gun skin.
	Begin Object Class=ConstantColor Name=ConstantYellow
		// First up, a solid yellow texture that kinda looks like gold
		Color=(G=255,R=255)
	End Object
	Begin Object Class=Combiner Name=PistolGold
		// Next, a Combiner that combines the solid yellow with the gun default texture,
		// making it look kind of like a golden pistol.
		CombineOperation=CO_Subtract
		Material1=Texture'WeaponSkins.desert_eagle_timb'
		Material2=ConstantColor'ConstantYellow'
	End Object
	Begin Object Class=Shader Name=GoldenGunShader
		// Finally, a shader that combines our golden pistol with a shiny specular effect,
		// making it look even more like gold.
		Diffuse=Combiner'PistolGold'
		Specular=TexEnvMap'AW7Tex.Cubes.CubeShineMap'
		SpecularityMask=TexEnvMap'AW7Tex.Cubes.CubeShineMap'
	End Object
	
	// Skins[0] is the material for the dude hands, so we change Skins[1] instead.
	Skins[1]=Shader'GoldenGunShader'
}
