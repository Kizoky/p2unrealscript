class PartnerPawn_RWSBob extends PartnerPawn;

defaultproperties
{
	ActorID="PLRWSBob"

	HeadMesh=SkeletalMesh'PLHeads.bob_head'
	HeadSkin=Texture'PLCharacterSkins.RWS_CREW.MWA__010__BOB'
	Skins[0]=Texture'PLCharacterSkins.RWS_CREW.MW__203__Avg_M_RWS_2'
	Mesh=Mesh'Characters.Avg_M_SS_Pants_D'
	Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws3',bAttachToHead=True)
	Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Aviators_M',bAttachToHead=True)	
	bRandomizeHeadScale=false
	bPersistent=true
	bKeepForMovie=true
	bCanTeleportWithPlayer=true
	bIsTrained=true
	bStartupRandomization=false
	RandomizedBoltons(0)=None
	ExtraAnims(2)=MeshAnimation'MP_Characters.Anim_MP'
	bMPAnims=true
}
