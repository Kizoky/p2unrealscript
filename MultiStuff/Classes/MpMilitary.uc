class MpMilitary extends xMpPawn;

defaultproperties
	{
	// Change by NickP: MP fix
	StumpClass=Class'StumpBigGuy'
	LimbClass=Class'LimbBigGuy'
	// End

	Mesh=Mesh'MP_Characters.Big_M_LS_Pants'
	CoreSPMesh=Mesh'Characters.Big_M_LS_Pants'
	Skins[0]=Texture'ChameleonSkins.MM__074__Big_M_LS_Pants'
	HeadSkin=Texture'ChamelHeadSkins.MWA__021__AvgMaleBig'
	HeadMesh=Mesh'Heads.AvgMaleBig'

	HandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_military'
	FootTexture =Texture'ChameleonSkins.Special.Dude'

	Boltons[0]=(bone="NODE_Parent",staticmesh=staticmesh'boltons.Swat_Helmet',skin=texture'BoltonSkins.Military_Helmet',bCanDrop=false,bAttachToHead=true)
	Boltons[1]=(bone="MALE01 spine1",staticmesh=staticmesh'boltons.Military_Pack')

	DialogClass=class'BasePeople.DialogMaleMilitary'

	Menuname="Military"
	}
