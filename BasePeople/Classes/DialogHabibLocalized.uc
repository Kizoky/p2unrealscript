///////////////////////////////////////////////////////////////////////////////
// DialogHabib
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for Habib
//
//	History:
//		02/07/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class DialogHabibLocalized extends DialogGeneric;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lGreeting);
	Addto(lGreeting, 								"HabibDialog.habib_hellowhatdoyou", 1);
	
	Clear(lRespondToGreeting);
	Addto(lRespondToGreeting, 						"HabibDialog.habib_okayandpleaseto", 1);
	
	Clear(lYes);
	Addto(lYes, 									"HabibDialog.habib_yes", 1);

	Clear(lNo);
	Addto(lNo, 										"HabibDialog.habib_no", 1);

	Clear(lGetDownMP);
	Addto(lGetDownMP,	 							"HabibDialog.habib_infidel", 1);
	Addto(lGetDownMP,								"HabibDialog.habib_ailili", 1);

	Clear(lFollowMe);
	Addto(lFollowMe,								"HabibDialog.habib_pleasemoveforward", 1);

	Clear(lStayHere);
	Addto(lStayHere,								"HabibDialog.habib_stop", 1);

	Clear(lyourewelcome);
	Addto(lyourewelcome,							"HabibDialog.habib_pleasethankyou", 1);

	Clear(lHabib_Bother);
	Addto(lHabib_Bother, 							"HabibDialog.habib_hurryupandbuy", 1);
	Addto(lHabib_Bother,							"HabibDialog.habib_thisisnotastand", 1);

	Clear(lTrashTalk);
	Addto(lTrashTalk,								"HabibDialog.habib_hurryupandbuy", 1);
	Addto(lTrashTalk, 								"HabibDialog.habib_yousoundjust", 1);

	// Clear these.. we don't have good lines for them
	Clear(lCloseToWeapon);
	Clear(lDoHeroics);

	Clear(lWhileFighting);
	Addto(lWhileFighting, 							"HabibDialog.habib_infidel", 1);
	Addto(lWhileFighting, 							"HabibDialog.habib_yourmotherisa", 1);
	Addto(lWhileFighting,							"HabibDialog.habib_eatleadanddie", 1);

	Clear(lDecideToFight);
	Addto(lDecideToFight,							"HabibDialog.habib_ailili", 1);

	Clear(lDying);
	Addto(lDying, 									"HabibDialog.habib_imreadyformy", 1);
	Addto(lDying,									"HabibDialog.habib_dying", 1);

	Clear(lGotHit);
	Addto(lGotHit, 									"HabibDialog.habib_aahimhit", 1);
	Addto(lGotHit,									"HabibDialog.habib_argh", 1);
	Addto(lGotHit,									"HabibDialog.habib_ak", 1);

	Clear(lAttacked);
	Addto(lAttacked,									"HabibDialog.habib_argh", 1);
	Addto(lAttacked,									"HabibDialog.habib_ak", 1);

	Clear(lGrunt);
	Addto(lGrunt,									"HabibDialog.habib_argh", 1);
	Addto(lGrunt,									"HabibDialog.habib_ak", 1);

	Clear(lCussing);
	Addto(lCussing,		 							"HabibDialog.habib_infidel", 1);
	Addto(lCussing,									"HabibDialog.habib_aahimhit", 1);
	Addto(lCussing,									"HabibDialog.habib_ailili", 1);

	Clear(lGotHitInCrotch);	
	Addto(lGotHitInCrotch,								"HabibDialog.habib_ak", 1);

	// no pissing talking
	//Clear(lPissing);

	Clear(lPissOnSelf);
	Addto(lPissOnSelf,								"HabibDialog.habib_ak", 1);
	
	// no pissing myself out talking
	//Clear(lPissOutFireOnSelf);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,					"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lGotHealth);
	Addto(lGotHealth,								"HabibDialog.habib_pleasethankyou", 1);
	Addto(lGotHealth, 								"HabibDialog.habib_yes", 1);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,							"HabibDialog.habib_pleasethankyou", 1);
	Addto(lGotHealthFood, 							"HabibDialog.habib_yes", 1);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth,							"HabibDialog.habib_ailili", 1);

	Clear(lGettingRobbed);
	Addto(lGettingRobbed, 							"HabibDialog.habib_youarestealing", 1);
	Addto(lGettingRobbed,							"HabibDialog.habib_stop", 1);
	Addto(lGettingRobbed,							"HabibDialog.habib_someonestophim", 1);
	Addto(lGettingRobbed,							"HabibDialog.habib_policepolice", 1);

	Clear(lNextInLine);
	Addto(lNextInLine, 								"HabibDialog.habib_illtakethenext", 1);

	Clear(lsomeoneonfire);

	Clear(lHelpYouOverHere);
	Addto(lHelpYouOverHere, 						"HabibDialog.habib_icanhelpyouover", 1);
		
	Clear(lSomeoneCuts);
	Addto(lSomeoneCuts, 							"HabibDialog.habib_imsorrybutyoull", 1);

	Clear(lPleaseMoveForward);
	Addto(lPleaseMoveForward, 						"HabibDialog.habib_pleasemoveforward", 1);

	Clear(lCanIHelpYou);
	Addto(lCanIHelpYou, 							"HabibDialog.habib_howcanihelpyou", 1);
	Addto(lCanIHelpYou,								"HabibDialog.habib_canihelpyou", 1);

	Clear(lIsThisEverything);
	Addto(lIsThisEverything, 						"HabibDialog.habib_hurryupandbuy", 1);
	Addto(lIsThisEverything,						"HabibDialog.habib_thisisnotastand", 1);
	
	Clear(lNumbers_Thatllbe);
	Addto(lNumbers_Thatllbe,					"HabibDialog.habib_thatllbe", 1);

	Clear(lNumbers_a);
	Addto(lNumbers_a,							"HabibDialog.habib_a", 1);

	Clear(lNumbers_1);
	Addto(lNumbers_1,							"HabibDialog.habib_1", 1);

	Clear(lNumbers_2);
	Addto(lNumbers_2,							"HabibDialog.habib_2", 1);

	Clear(lNumbers_3);
	Addto(lNumbers_3,							"HabibDialog.habib_3", 1);

	Clear(lNumbers_4);
	Addto(lNumbers_4,							"HabibDialog.habib_4", 1);

	Clear(lNumbers_5);
	Addto(lNumbers_5,							"HabibDialog.habib_5", 1);

	Clear(lNumbers_10);
	Addto(lNumbers_10,							"HabibDialog.habib_10", 1);

	Clear(lNumbers_20);
	Addto(lNumbers_20,							"HabibDialog.habib_20", 1);

	Clear(lNumbers_40);
	Addto(lNumbers_40,							"HabibDialog.habib_40", 1);

	Clear(lNumbers_60);
	Addto(lNumbers_60,							"HabibDialog.habib_60", 1);

	Clear(lNumbers_80);
	Addto(lNumbers_80,							"HabibDialog.habib_80", 1);

	Clear(lNumbers_100);
	Addto(lNumbers_100,							"HabibDialog.habib_100", 1);

	Clear(lNumbers_200);
	Addto(lNumbers_200,							"HabibDialog.habib_200", 1);

	Clear(lNumbers_300);
	Addto(lNumbers_300,							"HabibDialog.habib_300", 1);

	Clear(lNumbers_400);
	Addto(lNumbers_400,							"HabibDialog.habib_400", 1);

	Clear(lNumbers_500);
	Addto(lNumbers_500,							"HabibDialog.habib_500", 1);

	Clear(lNumbers_Dollars);
	Addto(lNumbers_Dollars,						"HabibDialog.habib_dollars", 1);

	Clear(lNumbers_SingleDollar);
	Addto(lNumbers_SingleDollar,				"HabibDialog.habib_dollar", 1);

	Clear(lSellingItem);
	Addto(lSellingItem, 						"HabibDialog.habib_thankyouforyour", 1);
	Addto(lSellingItem, 						"HabibDialog.habib_pleasethankyou", 1);

	Clear(lAfterSellingItem);
	Addto(lAfterSellingItem, 					"HabibDialog.habib_nowgetoutand", 1);
	
	Clear(lLackOfMoney);
	Addto(lLackOfMoney, 						"HabibDialog.habib_comebackwithmore", 1);
	addto(lLackOfMoney,							"HabibDialog.habib_thatisnotenough", 1);
	
	Clear(lRowdyCustomer);
	Addto(lRowdyCustomer, 						"HabibDialog.habib_pleasecalmdown", 1);

	Clear(lwhatthe);
	Addto(lwhatthe,								"HabibDialog.habib_argh", 1);
	Addto(lwhatthe,								"HabibDialog.habib_ak", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
