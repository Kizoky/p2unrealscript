//=============================================================================
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class RWSNathan extends RWSStaff
	placeable;

defaultproperties
	{
	ActorID="Nathan"
	HeadScale=(X=0.95,Y=1.0,Z=1.0)
	bStartupRandomization=false
	Conscience=1.0
	PainThreshold=1.0
	Talkative=0.5
	DonutLove=1.0
	VoicePitch=0.95
	Twitch=1.7

	//Skins[0]=Texture'ChameleonSkins.Special.RWS_Shorts'
	//Mesh=Mesh'Characters.Avg_M_SS_Shorts'
	ChameleonSkins[2]="ChameleonSkins2.RWS.MW__206__Avg_M_SS_Shorts"
	HeadSkin=Texture'ChamelHeadSkins.MWA__008__AvgMale'
	bNoChamelBoltons=true
	}
