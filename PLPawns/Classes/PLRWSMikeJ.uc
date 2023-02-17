class PLRWSMikeJ extends PLRWSStaff;

defaultproperties
{
	ActorID="PLRWSMikeJ"

	HeadMesh=SkeletalMesh'PLHeads.MikeJ_RWS'
	HeadSkin=Texture'PLCharacterSkins.RWS_CREW.MWA__008__MIKEJ'
	Skins[0]=Texture'PLCharacterSkins.RWS_CREW.MW__203__Avg_M_RWS'
	Mesh=Mesh'Characters.Avg_M_SS_Pants_D'
	DialogClass=class'DialogMikeJ'
	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=None
}
