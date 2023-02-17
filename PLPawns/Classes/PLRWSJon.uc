class PLRWSJon extends PLRWSStaff;

defaultproperties
{
	ActorID="PLRWSJon"

	HeadMesh=SkeletalMesh'PLHeads.jon_head'
	HeadSkin=Texture'PLCharacterSkins.RWS_CREW.MWA__006__JON'
	Skins[0]=Texture'PLCharacterSkins.RWS_CREW.MW__203__Avg_M_RWS'
	Mesh=Mesh'Characters.Avg_M_SS_Pants_D'
	Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws2',bAttachToHead=True)
	Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Aviators_M',bAttachToHead=True)	
	RandomizedBoltons(0)=None
}
