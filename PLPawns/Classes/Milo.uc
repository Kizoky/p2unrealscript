class Milo extends PLBystanders;

defaultproperties
{
	ActorID="Milo"

	HeadMesh=SkeletalMesh'PLHeads.Head_Milo'
	HeadSkin=Texture'PLCharacterSkins.HappyBrit.HappyBritHead'
	Skins[0]=Texture'PLCharacterSkins.HappyBrit.HappyBritBody'
	Mesh=SkeletalMesh'Characters.Avg_M_Jacket_Pants'
	DialogClass=class'DialogMilo'
	bNoChamelBoltons=True
	bUsePawnSlider=False
	bIsGay=true
	BaseEquipment[0]=(weaponclass=class'PLInventory.PL_DildoWeapon')
	DialogClass=class'DialogMilo'
}
