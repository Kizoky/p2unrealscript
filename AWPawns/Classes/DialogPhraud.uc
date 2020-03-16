///////////////////////////////////////////////////////////////////////////////
// DialogPhraud Hogslop
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//
///////////////////////////////////////////////////////////////////////////////
class DialogPhraud extends DialogMale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();
/*
	Clear(lCussing);
	Addto(lCussing,								"WMaleDialog.wm_christ", 1);
	Addto(lCussing,								"WMaleDialog.wm_shit", 2);
	Addto(lCussing,								"WMaleDialog.wm_holyshit", 2);
	Addto(lCussing,								"WMaleDialog.wm_motherfucker", 3);

	Clear(ldefiant);
	Addto(ldefiant,								"WMaleDialog.wm_goscrewyourself", 1);
	Addto(ldefiant,								"WMaleDialog.wm_fuckyoubuddy", 1);
	Addto(ldefiant,								"WMaleDialog.wm_yomomma", 2);
	Addto(ldefiant,								"WMaleDialog.wm_upyourspig", 2);
	Addto(ldefiant,								"WMaleDialog.wm_yourenottheboss", 2);
	Addto(ldefiant,								"WMaleDialog.wm_biteme", 3);
	Addto(ldefiant,								"WMaleDialog.wm_shutupmoron", 3);

	Clear(ldefiantline);
	Addto(ldefiantline,							"WMaleDialog.wm_goscrewyourself", 1);
	Addto(ldefiantline,							"WMaleDialog.wm_fuckyoubuddy", 1);
	Addto(ldefiantline,							"WMaleDialog.wm_yomomma", 2);
	Addto(ldefiantline,							"WMaleDialog.wm_upyourspig", 2);
	Addto(ldefiantline,							"WMaleDialog.wm_biteme", 3);
	Addto(ldefiantline,							"WMaleDialog.wm_shutupmoron", 3);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"WMaleDialog.wm_christ", 1);
	Addto(lCloseToWeapon,						"WMaleDialog.wm_eugh", 1);
	Addto(lCloseToWeapon,						"WMaleDialog.wm_cop_jesus", 1);
	Addto(lCloseToWeapon,						"WMaleDialog.wm_shit", 2);
	Addto(lCloseToWeapon,						"WMaleDialog.wm_holyshit", 2);
	Addto(lCloseToWeapon,						"WMaleDialog.wm_motherfucker", 3);
*/
	Clear(ldecidetofight);
	Addto(ldecidetofight,						"AWDialog.Phraud.Phraud_NotShooting", 1);
	Addto(ldecidetofight,						"AWDialog.Phraud.Phraud_DontHaveGun", 1);
	Addto(ldecidetofight,						"AWDialog.Phraud.Phraud_CountOf3", 2);
/*
	Clear(llaughing);
	Addto(llaughing,							"WMaleDialog.wm_laugh", 1);

	Clear(lSnickering);
	Addto(lSnickering,							"WMaleDialog.wm_snicker", 1);
*/	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"AWDialog.Phraud.Phraud_NotShooting", 1);
	Addto(lDoHeroics,							"AWDialog.Phraud.Phraud_DontHaveGun", 1);
	Addto(lDoHeroics,							"AWDialog.Phraud.Phraud_CountOf3", 2);
	Addto(lDoHeroics,							"WMaleDialog.wm_youthinkimscared", 3);

	Clear(lgothit);
	Addto(lgothit,								"AWDialog.Phraud.Phraud_Help", 1);
	addto(lgothit,								"WMaleDialog.wm_argh", 1);	
	addto(lgothit,								"WMaleDialog.wm_ow", 1);
	addto(lgothit,								"WMaleDialog.wm_shit", 2);
	addto(lgothit,								"WMaleDialog.wm_aghk", 2);
	addto(lgothit,								"WMaleDialog.wm_gak", 3);

	Clear(lAttacked);
	addto(lAttacked,							"AWDialog.Phraud.Phraud_Help", 1);	
	addto(lAttacked,							"WMaleDialog.wm_ow", 1);
	addto(lAttacked,							"WMaleDialog.wm_shit", 2);
	addto(lAttacked,							"WMaleDialog.wm_aghk", 2);
	addto(lAttacked,							"WMaleDialog.wm_gak", 3);
/*
	Clear(lGrunt);
	addto(lGrunt,								"WMaleDialog.wm_argh", 1);	
	addto(lGrunt,								"WMaleDialog.wm_ow", 1);
	addto(lGrunt,								"WMaleDialog.wm_aghk", 2);
	addto(lGrunt,								"WMaleDialog.wm_gak", 3);

	Clear(ldying);
	Addto(ldying,								"WMaleDialog.wm_mommy", 1);
	Addto(ldying,								"WMaleDialog.wm_icantfeelmylegs", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl1", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl2", 2);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl3", 3);
	Addto(ldying,								"WMaleDialog.wm_icantbreathe", 1);
	Addto(ldying,								"WMaleDialog.wm_somebodypleasemake", 2);
	Addto(ldying,								"WMaleDialog.wm_godithurts", 2);
	Addto(ldying,								"WMaleDialog.wm_ohgod", 3);
	Addto(ldying,								"WMaleDialog.wm_justfinishit", 3);
*/
	Clear(ltrashtalk);
	Addto(ltrashtalk,							"AWDialog.Phraud.Phraud_DontHaveGun", 1);
	Addto(ltrashtalk,							"AWDialog.Phraud.Phraud_CountOf3", 1);
	Addto(ltrashtalk,							"AWDialog.Phraud.Phraud_NotShooting", 2);
	Addto(ltrashtalk,							"AWDialog.Phraud.Phraud_Promise", 2);

	Clear(lWhileFighting);
	Addto(lWhileFighting,						"AWDialog.Phraud.Phraud_NotShooting", 1);
	Addto(lWhileFighting,						"AWDialog.Phraud.Phraud_DontHaveGun", 1);
	Addto(lWhileFighting,						"AWDialog.Phraud.Phraud_Promise", 2);
	Addto(lWhileFighting,						"AWDialog.Phraud.Phraud_CountOf3", 2);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     TestModeClasses(0)="BasePeople.DialogDude"
     TestModeClasses(1)="BasePeople.DialogFemale"
     TestModeClasses(2)="BasePeople.DialogFemaleCop"
     TestModeClasses(3)="BasePeople.DialogGary"
     TestModeClasses(4)="BasePeople.DialogGeneric"
     TestModeClasses(5)="BasePeople.DialogHabib"
     TestModeClasses(6)="BasePeople.DialogKrotchy"
     TestModeClasses(7)="BasePeople.DialogMale"
     TestModeClasses(8)="BasePeople.DialogMaleCop"
     TestModeClasses(9)="BasePeople.DialogMaleMilitary"
     TestModeClasses(10)="BasePeople.DialogPriest"
     TestModeClasses(11)="BasePeople.DialogRedneck"
     TestModeClasses(12)="BasePeople.DialogVince"
}
