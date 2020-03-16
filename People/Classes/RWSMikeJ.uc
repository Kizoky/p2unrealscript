//=============================================================================
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class RWSMikeJ extends RWSStaff
	placeable;

defaultproperties
{
	ActorID="MikeJ"
	Begin Object Class=BoltonDef Name=BoltonDef_HalloweenFacePaint_MikeJ
		UseChance=1.0
		Tag="Costume"
		ExcludeTags(0)="Costume"
		HeadSkin=Texture'Halloweeen_Tex.SexyMikeJ'
		HeadMesh=Mesh'Heads.AvgMale'
		ValidHoliday="SeasonalHalloween"
	End Object

	DialogClass=class'BasePeople.DialogMikeJ'
	VoicePitch=1.0
	//Skins[0]=Texture'ChameleonSkins.Special.RWS_Shorts'
	//Mesh=Mesh'Characters.Avg_M_SS_Shorts'
	ChameleonSkins[2]="ChameleonSkins2.RWS.MW__206__Avg_M_SS_Shorts"
	HeadSkin=Texture'ChamelHeadSkins.MWA__006__AvgMale'
	ControllerClass=class'RWSMikeJController'
	RandomizedBoltons(0)=BoltonDef'BoltonDef_HalloweenFacePaint_MikeJ'
	RandomizedBoltons(1)=None
}
