class PartnerPawn_RWSMikeJ extends PartnerPawn;

defaultproperties
{
	ActorID="PLRWSMikeJ"

	HeadMesh=SkeletalMesh'PLHeads.MikeJ_RWS'
	HeadSkin=Texture'PLCharacterSkins.RWS_CREW.MWA__008__MIKEJ'
	Skins[0]=Texture'PLCharacterSkins.RWS_CREW.MW__203__Avg_M_RWS'
	Mesh=Mesh'Characters.Avg_M_SS_Pants_D'
	DialogClass=class'DialogMikeJ'
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
