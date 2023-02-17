class PartnerPawn_RWSRickF extends PartnerPawn;

defaultproperties
{
	ActorID="PLRWSRickF"

	HeadMesh=SkeletalMesh'PLHeads.rick_head'
	HeadSkin=Texture'PLCharacterSkins.RWS_CREW.MWA__010__RICK'
	Skins[0]=Texture'PLCharacterSkins.RWS_CREW.MW__203__Avg_M_RWS'
	Mesh=Mesh'Characters.Avg_M_SS_Pants_D'
	Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws',bAttachToHead=True)
	RandomizedBoltons(0)=None
	bRandomizeHeadScale=false
	bPersistent=true
	bKeepForMovie=true
	bCanTeleportWithPlayer=true
	bIsTrained=true
	bStartupRandomization=false
	ExtraAnims(2)=MeshAnimation'MP_Characters.Anim_MP'
	bMPAnims=true
}
