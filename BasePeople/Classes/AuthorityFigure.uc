//=============================================================================
// AuthorityFigure
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all authority figures.
//
//=============================================================================
class AuthorityFigure extends AWPerson
	notplaceable;


///////////////////////////////////////////////////////////////////////////////
// Setup
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
	{
	Super.PostBeginPlay();

	Cowardice=0.0;
	}


defaultproperties
	{
	bAuthorityFigure=true
	bIsTrained=true		

	// These were picked from the general pool because they look good as cops, swat, etc.
	ChamelHeadSkins(0)="ChamelHeadSkins.MWA__001__AvgMale"
	ChamelHeadSkins(1)="ChamelHeadSkins.MBA__013__AvgBrotha"
	ChamelHeadSkins(2)="ChamelHeadSkins.MBA__014__AvgBrotha"
	ChamelHeadSkins(3)="ChamelHeadSkins.MMA__016__AvgMale"
	ChamelHeadSkins(4)="ChamelHeadSkins.MWA__002__AvgMale"
	ChamelHeadSkins(5)="ChamelHeadSkins.MMA__003__AvgMale"
	ChamelHeadSkins(6)="ChamelHeadSkins.MWA__007__AvgMale"
	ChamelHeadSkins(7)="ChamelHeadSkins.MWA__008__AvgMale"
	ChamelHeadSkins(8)="ChamelHeadSkins.MWA__015__AvgMale"
	ChamelHeadSkins(9)="ChamelHeadSkins.MWA__021__AvgMaleBig"
	ChamelHeadSkins(10)="ChamelHeadSkins.MWA__035__AvgMale"
	ChamelHeadSkins(11)="ChamelHeadSkins.MWF__025__FatMale"
	ChamelHeadSkins(12)="ChamelHeadSkins.MWA__022__AvgMaleBig"
	ChamelHeadSkins(13)="ChamelHeadSkins.FBA__033__FemSH"
	ChamelHeadSkins(14)="ChamelHeadSkins.FWA__031__FemSH"
	ChamelHeadSkins(15)="ChamelHeadSkins.FWA__026__FemLH"
	ChamelHeadSkins(16)="ChamelHeadSkins.FWA__027__FemLH"
	ChamelHeadSkins(17)="ChamelHeadSkins.FWA__029__FemSH"
	ChamelHeadSkins(18)="ChamelHeadSkins.FWA__032__FemSH"
	ChamelHeadSkins(19)="ChamelHeadSkins.FWF__023__FatFem"
	ChamelHeadSkins(20)="ChamelHeadSkins.FWA__037__FemSHcropped"
	ChamelHeadSkins(21)="ChamelHeadSkins.FMA__039__FemSHcropped"
	ChamelHeadSkins(22)="ChamelHeadSkins.FWA__040__FemSHcropped"
	ChamelHeadSkins(23)="ChamelHeadSkins.FMF__044__FatFem"
	ChamelHeadSkins(24)="ChamelHeadSkins.FBF__043__FatFem"
	ChamelHeadSkins(25)="ChamelHeadSkins.MBF__042__FatMale"
	ChamelHeadSkins(26)="end"	// end-of-list marker (in case super defines more skins)
	
	bCellUser=False
	BlockMeleeFreq=0.7
	}
