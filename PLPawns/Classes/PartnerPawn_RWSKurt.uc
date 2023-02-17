class PartnerPawn_RWSKurt extends PartnerPawn;

defaultproperties
{
	ActorID="PLRWSKurt"

	HeadMesh=SkeletalMesh'PLHeads.kurt_head'
	HeadSkin=Texture'PLCharacterSkins.RWS_CREW.MWA__002__KURT'
	Skins[0]=Texture'PLCharacterSkins.RWS_CREW.MW__203__Avg_M_RWS_2'
	Mesh=Mesh'Characters.Avg_M_SS_Pants_D'
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
