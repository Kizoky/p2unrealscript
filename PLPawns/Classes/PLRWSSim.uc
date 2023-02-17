class PLRWSSim extends PLRWSStaff;

defaultproperties
{
	ActorID="PLRWSSim"

	HeadMesh=SkeletalMesh'PLHeads.sim_head'
	HeadSkin=Texture'PLCharacterSkins.RWS_CREW.FWA__027__SIM'
	Skins[0]=Texture'PLCharacterSkins.RWS_CREW.MW__203__Avg_M_RWS'
	Mesh=Mesh'Characters.Fem_LS_Pants'
	bIsFemale=true
	MyGender=Gender_Female
	DialogClass=class'DialogFemale'
	ChameleonOnlyHasGender=Gender_Female
	Begin Object Class=BoltonDef Name=BoltonDefBallcap_RWS_PL_Fem
		UseChance=1
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_rws',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_rws2',bAttachToHead=True)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_rws3',bAttachToHead=True)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_rws4',bAttachToHead=True)
		Boltons(4)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_rws5',bAttachToHead=True)
		Gender=Gender_Female
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefBallcap_RWS_PL_Fem'
	RandomizedBoltons(2)=None
}
