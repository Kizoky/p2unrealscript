class MpSWAT extends xMpPawn;

defaultproperties
	{
	// Change by NickP: MP fix
	StumpClass=Class'StumpBigGuy'
	LimbClass=Class'LimbBigGuy'
	// End

	Mesh=Mesh'MP_Characters.Big_M_LS_Pants'
	CoreSPMesh=Mesh'Characters.Big_M_LS_Pants'
	Skins[0]=Texture'Mp_Misc.Mp_swat'
	HeadSkin=Texture'ChamelHeadSkins.Special.Robber'
	HeadMesh=Mesh'Heads.Masked'

	HandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_swat'
	FootTexture =Texture'ChameleonSkins.Special.Dude'

	DialogClass=class'BasePeople.DialogMaleMilitary'

	Menuname="SWAT"
	}
