class PLRWSMick extends PLRWSStaff;

defaultproperties
{
	ActorID="PLRWSMick"

	HeadMesh=SkeletalMesh'PLHeads.mickyan_head'
	HeadSkin=Texture'PLCharacterSkins.RWS_CREW.MWA__010__MICK'
	Skins[0]=Texture'PLCharacterSkins.RWS_CREW.MW__203__Avg_M_RWS_2'
	Mesh=Mesh'Characters.Avg_M_SS_Pants_D'
	Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws5',bAttachToHead=True)
	RandomizedBoltons(0)=None
}
