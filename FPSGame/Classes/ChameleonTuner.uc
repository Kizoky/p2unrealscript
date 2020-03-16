///////////////////////////////////////////////////////////////////////////////
// ChameleonTuner.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Sets desired gender and racial balance for a level.
//
// History:
//	08/31/02 MJR	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class ChameleonTuner extends Info
	placeable;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

struct SRacialBalance
	{
	var() int				Blacks;
	var() int				Mexicans;
	var() int				Whites;
	};

struct SGenderBalance
	{
	var() int				Females;
	var() int				Males;
	};

struct SPeopleBalance
	{
	var() SGenderBalance	Gender;
	var() SRacialBalance	RacialFemale;
	var() SRacialBalance	RacialMale;
	var() int				OverallMaleGay;
	var() int				OverallFemaleFem;
	var() int				OverallFat;
	var() int				OverallTall;
	};

var() SPeopleBalance		Balance;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	// NOTE: If a level doesn't contain a ChameleonTuner then these defaults will NOT be used and instead the defaults in Chameleon itself are used.
	Balance=(Gender=(Females=50,Males=50),RacialFemale=(Blacks=10,Mexicans=15,Whites=75),RacialMale=(Blacks=10,Mexicans=15,Whites=75),OverallMaleGay=3,OverallFemaleFem=10,OverallFat=5,OverallTall=3)
	Texture=Texture'PostEd.Icons_256.chameleonsettings'
	DrawScale=0.25
	}
