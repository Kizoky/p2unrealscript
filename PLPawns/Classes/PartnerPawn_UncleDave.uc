class PartnerPawn_UncleDave extends PartnerPawn;

defaultproperties
{
	ActorID="PLUncleDave"

	Mesh=Mesh'Characters.Avg_M_SS_Pants'
	Skins[0]=Texture'PLCharacterSkins.UncleDave.UncleDavie'
	HeadSkin=Texture'ChamelHeadSkins.Special.UncleDave'
	HeadMesh=Mesh'Heads.AvgMale'
	bRandomizeHeadScale=false
	bPersistent=true
	bKeepForMovie=true
	bCanTeleportWithPlayer=true
	bIsTrained=true
	bStartupRandomization=false
	RandomizedBoltons(0)=None
	Boltons[0]=(bone="NODE_Parent",staticmesh=staticmesh'PLCharacterMeshes.UncleDave.HugeAfro_Vtex',bCanDrop=false,bAttachToHead=true,Skin=Texture'PLCharacterSkins.UncleDave.Davefro')
	ExtraAnims(2)=MeshAnimation'MP_Characters.Anim_MP'
	bMPAnims=true
}
