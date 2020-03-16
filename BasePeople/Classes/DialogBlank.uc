///////////////////////////////////////////////////////////////////////////////
// DialogMale
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all white males
//
// If a new dialog class is added and it references a new sound package
// (like SuperHeroDialog.uax) then in order for those sounds to play on the
// client, you either need a hard reference in the code to one of those files
// Sound'SuperHeroDialog.DieScum', or you need to put that package in the
// ini's with serverpackages (cheesier version).
//
//	History:
//		02/07/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class DialogBlank extends DialogGeneric;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lapplauding);
	AddTo(lApplauding,							"", 1);

	Clear(lgreeting);
	Addto(lgreeting,							"", 1);

	Clear(lhotgreeting);
	Addto(lhotGreeting,							"", 1);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,					"", 1);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,				"", 1);

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,				"", 1);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,					"", 1);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,			"", 1);

	Clear(lHelloCop);
	Addto(lHelloCop,							"", 1);

	Clear(lHelloGimp);
	Addto(lHelloGimp,							"", 1);

	Clear(lApologize);
	Addto(lApologize,							"", 1);

	Clear(lyourewelcome);
	Addto(lyourewelcome,						"", 1);

	Clear(lno);
	Addto(lno,									"", 1);

	Clear(lyes);
	Addto(lyes,									"", 1);

	Clear(lthanks);
	Addto(lthanks,								"", 1);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"", 1);

	Clear(lGetDown);
	AddTo(lGetDown,								"", 1);

	Clear(lGetDownMP);
	AddTo(lGetDownMP,							"", 1);

	Clear(lCussing);
	Addto(lCussing,								"", 1);

	Clear(lgetdownscared);
	Addto(lgetdownscared,						"", 1);

	Clear(ldefiant);
	Addto(ldefiant,								"", 1);

	Clear(ldefiantline);
	Addto(ldefiantline,							"", 1);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"", 1);

	Clear(llaughing);
	Addto(llaughing,							"", 1);

	Clear(lSnickering);
	Addto(lSnickering,							"", 1);

	Clear(lOutOfBreath);
	Addto(lOutOfBreath,							"", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"", 1);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,					"", 1);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,					"", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,							"", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"", 1);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"", 1);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"", 1);

	Clear(lseeingpisser);
	Addto(lseeingpisser,						"", 1);

	Clear(lSomethingIsGross);
	Addto(lSomethingIsGross,					"", 1);

	Clear(lgothit);
	Addto(lgothit,								"", 1);

	Clear(lAttacked);
	addto(lAttacked,							"", 1);	

	Clear(lGrunt);
	addto(lGrunt,								"", 1);	

	Clear(lPissing);
	Addto(lPissing,								"", 1);

	Clear(lPissOnSelf);
	Addto(lPissOnSelf,							"", 2);
	
	Clear(lPissOutFireOnSelf);
	Addto(lPissOutFireOnSelf,					"", 1);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,				"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lGotHealth);
	Addto(lGotHealth,							"", 1);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,						"", 1);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth,						"", 1);

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"", 1);	

	Clear(lbegforlife);
	Addto(lbegforlife,							"", 1);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"", 1);
	
	Clear(ldying);
	Addto(ldying,								"", 1);

	Clear(lCrying);
	Addto(lCrying,								"", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,					"", 1);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting,						"", 1);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,						"", 1);

	Clear(lratout);
	Addto(lratout,								"", 1);

	Clear(lfakeratout);
	Addto(lfakeratout,							"", 1);

	Clear(lcleanshot);
	Addto(lcleanshot,							"", 1);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"", 1);

	Clear(lInhale);
	Addto(lInhale,								"WMaleDialog.wm_inhale", 1);
												
	Clear(lExhale);								
	Addto(lExhale,								"WMaleDialog.wm_exhale", 1);
	
	Clear(lEatingFood);
	Addto(lEatingFood,							"", 1);

	Clear(lAfterEating);
	Addto(lAfterEating,							"", 1);

	Clear(lpleasureresponse);					
	Addto(lpleasureresponse,					"", 1);

	Clear(laftersitdown);
	Addto(laftersitdown,						"", 1);

	Clear(lSpitting);
	Addto(lSpitting,							"", 1);
	
	Clear(lhmm);
	Addto(lhmm,									"", 1);

	Clear(lfollowme);
	Addto(lfollowme,							"", 1);	

	Clear(lStayHere);
	Addto(lStayHere,							"", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,						"", 1);

	Clear(lilltakenumber);
	Addto(lilltakenumber,						"", 1);

	Clear(lmakedeposit);
	Addto(lmakedeposit,							"", 1);

	Clear(lmakewithdrawal);
	Addto(lmakewithdrawal,						"", 1);

	Clear(lconsumerbuy);
	Addto(lconsumerbuy,							"", 1);

	Clear(lconteststoretransaction);
	Addto(lconteststoretransaction,				"", 1);
	
	Clear(lcontestbanktransaction);
	Addto(lcontestbanktransaction,				"", 1);

	Clear(lGoPostal);
	Addto(lGoPostal,							"", 1);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,						"", 1);

	Clear(lCallCat);
	Addto(lCallCat, 							"", 1);

	Clear(lHateCat);
	Addto(lHateCat, 							"", 1);

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"", 1);

	Clear(lGettingRobbed);	
	Addto(lGettingRobbed,						"", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"", 1);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"", 1);

	Clear(lDoMugging);	
	Addto(lDoMugging,							"", 3);
	
	Clear(lQuestion);	
	Addto(lQuestion,							"", 1);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"", 1);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"", 1);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"", 1);

	Clear(lGenericGoodbye);
	Addto(lGenericGoodbye,						"", 1);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,						"", 1);

	Clear(labouttopuke);
	Addto(labouttopuke,							"", 1);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,						"", 1);

	Clear(lGettingShocked);
	Addto(lGettingShocked,						"", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,							"HabibDialog.habib_ailili", 1);

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,						"", 1);
	
	Clear(lZealots);
	Addto(lZealots,								"", 1);
	
	Clear(lKrotchyCustomerComment);
	Addto(lKrotchyCustomerComment,				"", 1);

	Clear(lKrotchyCustomerWant);
	Addto(lKrotchyCustomerWant,					"", 1);

	Clear(lGaryAutograph);
	Addto(lGaryAutograph,						"", 1);
	
	Clear(lProtestorCut);
	Addto(lProtestorCut,						"", 1);
	
	Clear(ldudedead);
	Addto(ldudedead,							"", 1);

	Clear(lKickDead);
	Addto(lKickDead,							"", 1);

	Clear(lNameCalling);
	Addto(lNameCalling,							"", 1);

	Clear(lRogueCop);
	Addto(lRogueCop,							"", 1);

	Clear(lgetbumped);
	Addto(lgetbumped,							"", 1);

	Clear(lGetMad);
	Addto(lGetMad,								"", 1);

	Clear(lLynchMob);
	Addto(lLynchMob,							"", 1);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"", 1);

	Clear(lnextinline);
	Addto(lnextinline,							"", 1);
	
	Clear(lhelpyouoverhere);
	Addto(lhelpyouoverhere,						"", 1);

	Clear(lsomeonecuts);
	Addto(lsomeonecuts,							"", 1);

	Clear(lpleasemoveforward);
	Addto(lpleasemoveforward,					"", 1);

	Clear(lcanihelpyou);
	Addto(lcanihelpyou,							"", 1);

	Clear(lNumbers_Thatllbe);
	Addto(lNumbers_Thatllbe,					"", 1);

	Clear(lNumbers_a);
	Addto(lNumbers_a,							"", 1);

	Clear(lNumbers_1);
	Addto(lNumbers_1,							"", 1);

	Clear(lNumbers_2);
	Addto(lNumbers_2,							"", 1);

	Clear(lNumbers_3);
	Addto(lNumbers_3,							"", 1);

	Clear(lNumbers_4);
	Addto(lNumbers_4,							"", 1);

	Clear(lNumbers_5);
	Addto(lNumbers_5,							"", 1);

	Clear(lNumbers_10);
	Addto(lNumbers_10,							"", 1);

	Clear(lNumbers_20);
	Addto(lNumbers_20,							"", 1);

	Clear(lNumbers_40);
	Addto(lNumbers_40,							"", 1);

	Clear(lNumbers_60);
	Addto(lNumbers_60,							"", 1);

	Clear(lNumbers_80);
	Addto(lNumbers_80,							"", 1);

	Clear(lNumbers_100);
	Addto(lNumbers_100,							"", 1);

	Clear(lNumbers_200);
	Addto(lNumbers_200,							"", 1);

	Clear(lNumbers_300);
	Addto(lNumbers_300,							"", 1);

	Clear(lNumbers_400);
	Addto(lNumbers_400,							"", 1);

	Clear(lNumbers_500);
	Addto(lNumbers_500,							"", 1);

	Clear(lNumbers_Dollars);
	Addto(lNumbers_Dollars,						"", 1);

	Clear(lNumbers_SingleDollar);
	Addto(lNumbers_SingleDollar,				"", 1);

	Clear(lsellingitem);
	Addto(lsellingitem,							"", 1);

	Clear(lIsThisEverything);
	Addto(lIsThisEverything,					"", 1);
	
	Clear(llackofmoney);
	Addto(llackofmoney,							"", 1);

	Clear(lSignPetition);							
	Addto(lSignPetition,						"", 1);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"", 1);

	Clear(lPetitionBother);
	Addto(lPetitionBother,						"", 1);

	Clear(lcallsecurity);
	Addto(lcallsecurity,						"", 1);
	
	Clear(lrowdycustomer);
	Addto(lrowdycustomer,						"", 1);
	
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
