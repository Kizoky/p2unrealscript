class MpPriest extends xMpPawn;

defaultproperties
	{
	Mesh=Mesh'MP_Characters.Avg_M_Jacket_Pants'
	CoreSPMesh=Mesh'Characters.Avg_M_Jacket_Pants'
	Skins[0]=Texture'Mp_Misc.priest_bling'
	HeadSkin=Texture'ChamelHeadSkins.MWA__007__AvgMale'
	HeadMesh=Mesh'Heads.AvgMale'

	HandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_priest'
	FootTexture =Texture'Mp_Misc.priest_bling'

	DialogClass=class'BasePeople.DialogPriest'
	DudeSuicideSound=Sound'WMaleDialog.wm_postal_godsaidits'

	Menuname="Priest"
	}
