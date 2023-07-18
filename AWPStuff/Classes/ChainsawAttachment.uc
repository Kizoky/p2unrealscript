class ChainsawAttachment extends P2WeaponAttachment;

defaultproperties
{
	WeapClass=Class'ChainsawWeapon'
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.Weapons.TP_Chainsaw'
	FiringMode="SHOVEL1"
	DrawScale=1	// Was -1 for whatever reason???!
	Skins[0]=Texture'xPatchTex.Weapons.chainsawskin1'	// non-bloody skin
}