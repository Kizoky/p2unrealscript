///////////////////////////////////////////////////////////////////////////////
// DialogSurvivalist
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all Doomsday Survivalists. Why are the good people dying?
//
///////////////////////////////////////////////////////////////////////////////
class DialogSurvivalist extends DialogGeneric;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lgreeting);
	Addto(lgreeting,							"PLDialogSurvivalist.dds_hello", 1);
	Addto(lgreeting,							"PLDialogSurvivalist.dds_hi", 1);
	Addto(lGreeting,							"PLDialogSurvivalist.dds_hey", 1);

	Clear(lhotgreeting);
	Addto(lhotGreeting,							"PLDialogSurvivalist.dds_hothello", 1);
	Addto(lhotGreeting,							"PLDialogSurvivalist.dds_hothi", 1);
	Addto(lhotGreeting,							"PLDialogSurvivalist.dds_hothey", 1);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,						"PLDialogSurvivalist.dds_howsitgoing", 1);
	Addto(lGreetingquestions,						"PLDialogSurvivalist.dds_howareyou", 1);
	Addto(lGreetingquestions,						"PLDialogSurvivalist.dds_howyoudoin", 1);
	Addto(lGreetingquestions,						"PLDialogSurvivalist.dds_sup", 1);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,						"PLDialogSurvivalist.dds_hothowsitgoing", 1);
	Addto(lHotGreetingquestions,						"PLDialogSurvivalist.dds_hothowareyou", 1);
	Addto(lHotGreetingquestions,						"PLDialogSurvivalist.dds_hothowyoudoin", 1);
	Addto(lHotGreetingquestions,						"PLDialogSurvivalist.dds_hotsup", 1);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,						"PLDialogSurvivalist.dds_finethanks", 1);
	Addto(lrespondtogreeting,						"PLDialogSurvivalist.dds_doinprettygood", 1);
	Addto(lrespondtogreeting,						"PLDialogSurvivalist.dds_ohokayiguess", 1);
	Addto(lrespondtogreeting,						"PLDialogSurvivalist.dds_beenbetter", 1);
	Addto(lrespondtogreeting,						"PLDialogSurvivalist.dds_grandmawcamedown", 1);
	Addto(lrespondtogreeting,						"PLDialogSurvivalist.dds_doiknowyou", 1);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,					"PLDialogSurvivalist.dds_thatsnice", 1);
	Addto(lrespondtogreetingresponse,					"PLDialogSurvivalist.dds_gladtohearit", 1);
	Addto(lrespondtogreetingresponse,					"PLDialogSurvivalist.dds_welltakecare", 1);
	Addto(lrespondtogreetingresponse,					"PLDialogSurvivalist.dds_ohhowawful", 1);
	Addto(lrespondtogreetingresponse,					"PLDialogSurvivalist.dds_imsorry", 1);

	Clear(lHelloCop);
	Addto(lHelloCop,								"PLDialogSurvivalist.dds_hellocop1", 1);
	Addto(lHelloCop,								"PLDialogSurvivalist.dds_hellocop2", 1);
	Addto(lHelloCop,								"PLDialogSurvivalist.dds_hellocop3", 1);

	Clear(lHelloGimp);
	Addto(lHelloGimp,								"PLDialogSurvivalist.dds_hellogimp1", 1);
	Addto(lHelloGimp,								"PLDialogSurvivalist.dds_hellogimp2", 1);
	Addto(lHelloGimp,								"PLDialogSurvivalist.dds_hellogimp3", 1);
	Addto(lHelloGimp,								"PLDialogSurvivalist.dds_hellogimp4", 1);
	Addto(lHelloGimp,								"PLDialogSurvivalist.dds_hellogimp5", 1);

	Clear(lApologize);
	Addto(lApologize,								"PLDialogSurvivalist.dds_imsorry", 1);

	Clear(lyourewelcome);
	Addto(lyourewelcome,							"PLDialogSurvivalist.dds_yourewelcome", 1);

	Clear(lno);
	Addto(lno,								"PLDialogSurvivalist.dds_nope", 1);
	Addto(lno,								"PLDialogSurvivalist.dds_no", 1);
	Addto(lno,								"PLDialogSurvivalist.dds_sorry", 1);
	Addto(lno,								"PLDialogSurvivalist.dds_idontthinkso", 1);
	Addto(lno,								"PLDialogSurvivalist.dds_not", 1);

	Clear(lyes);
	Addto(lyes,								"PLDialogSurvivalist.dds_yup", 1);
	Addto(lyes,								"PLDialogSurvivalist.dds_yes", 1);
	Addto(lyes,								"PLDialogSurvivalist.dds_sure", 1);
	Addto(lyes,								"PLDialogSurvivalist.dds_probably", 1);
	Addto(lyes,								"PLDialogSurvivalist.dds_yeah", 1);
	Addto(lyes,								"PLDialogSurvivalist.dds_uhhunh", 1);
	Addto(lyes,								"PLDialogSurvivalist.dds_uhhuhgum", 1);

	Clear(lthanks);
	Addto(lthanks,								"PLDialogSurvivalist.dds_thanks", 1);
	Addto(lthanks,								"PLDialogSurvivalist.dds_great", 1);
	Addto(lthanks,								"PLDialogSurvivalist.dds_kickass", 1);
	Addto(lthanks,								"PLDialogSurvivalist.dds_yourule", 1);
	Addto(lthanks,								"PLDialogSurvivalist.dds_thatrocks", 1);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"PLDialogSurvivalist.dds_great", 1);
	Addto(lThatsGreat,							"PLDialogSurvivalist.dds_kickass", 1);
	Addto(lThatsGreat,							"PLDialogSurvivalist.dds_thatrocks", 1);

	Clear(lGetDown);
	AddTo(lGetDown,								"PLDialogSurvivalist.dds_angrygetdown", 1);
	AddTo(lGetDown,								"PLDialogSurvivalist.dds_angrygetdownifyou", 1);
	AddTo(lGetDown,								"PLDialogSurvivalist.dds_angrygetonground", 1);
	AddTo(lGetDown,								"PLDialogSurvivalist.dds_cop_getthefuck", 1);
	AddTo(lGetDown,								"PLDialogSurvivalist.dds_cop_isaidgetdown", 2);

	Clear(lGetDownMP);
	AddTo(lGetDownMP,								"PLDialogSurvivalist.dds_angrygetdown", 1);
	AddTo(lGetDownMP,								"PLDialogSurvivalist.dds_angrygetdownifyou", 1);
	AddTo(lGetDownMP,								"PLDialogSurvivalist.dds_angrygetonground", 1);

	Clear(lCussing);
	Addto(lCussing,								"PLDialogSurvivalist.dds_christ", 1);
	Addto(lCussing,								"PLDialogSurvivalist.dds_shit", 1);
	Addto(lCussing,								"PLDialogSurvivalist.dds_holyshit", 1);
	Addto(lCussing,								"PLDialogSurvivalist.dds_motherfucker", 1);

	Clear(lgetdownscared);
	Addto(lgetdownscared,							"PLDialogSurvivalist.dds_scaredgetdown", 1);
	Addto(lgetdownscared,							"PLDialogSurvivalist.dds_scaredgetonground", 1);
	Addto(lgetdownscared,							"PLDialogSurvivalist.dds_scaredgetdownifyou", 1);
	Addto(lgetdownscared,							"PLDialogSurvivalist.dds_scaredlookout", 1);

	Clear(ldefiant);
	Addto(ldefiant,								"PLDialogSurvivalist.dds_goscrewyourself", 1);
	Addto(ldefiant,								"PLDialogSurvivalist.dds_fuckyoubuddy", 1);
	Addto(ldefiant,								"PLDialogSurvivalist.dds_upyourspig", 1);
	Addto(ldefiant,								"PLDialogSurvivalist.dds_biteme", 1);
	Addto(ldefiant,								"PLDialogSurvivalist.dds_shutupmoron", 1);
	Addto(ldefiant,								"PLDialogSurvivalist.dds_motherfucker", 1);

	Clear(ldefiantline);
	Addto(ldefiantline,							"PLDialogSurvivalist.dds_goscrewyourself", 1);
	Addto(ldefiantline,							"PLDialogSurvivalist.dds_fuckyoubuddy", 1);
	Addto(ldefiantline,							"PLDialogSurvivalist.dds_upyourspig", 1);
	Addto(ldefiantline,							"PLDialogSurvivalist.dds_biteme", 1);
	Addto(ldefiantline,							"PLDialogSurvivalist.dds_shutupmoron", 1);
	Addto(ldefiantline,							"PLDialogSurvivalist.dds_motherfucker", 1);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"PLDialogSurvivalist.dds_christ", 1);
	Addto(lCloseToWeapon,						"PLDialogSurvivalist.dds_eugh", 1);
	Addto(lCloseToWeapon,						"PLDialogSurvivalist.dds_cop_jesus", 1);
	Addto(lCloseToWeapon,						"PLDialogSurvivalist.dds_shit", 1);
	Addto(lCloseToWeapon,						"PLDialogSurvivalist.dds_holyshit", 1);
	Addto(lCloseToWeapon,						"PLDialogSurvivalist.dds_motherfucker", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,							"PLDialogSurvivalist.dds_imnotavictim", 1);
	Addto(ldecidetofight,							"PLDialogSurvivalist.dds_youcantdothattomy", 1);
	Addto(ldecidetofight,							"PLDialogSurvivalist.dds_illkillyou", 1);
	Addto(ldecidetofight,							"PLDialogSurvivalist.dds_youcantdothattome", 1);
	Addto(ldecidetofight,							"PLDialogSurvivalist.dds_rah", 1);
	Addto(ldecidetofight,							"PLDialogSurvivalist.dds_howaboutsomeofthis", 1);
	Addto(ldecidetofight,							"PLDialogSurvivalist.dds_motherfucker", 1);

	Clear(llaughing);
	Addto(llaughing,								"PLDialogSurvivalist.dds_laugh", 1);

	Clear(lSnickering);
	Addto(lSnickering,								"PLDialogSurvivalist.dds_snicker", 1);

	Clear(lOutOfBreath);
	Addto(lOutOfBreath,								"PLDialogSurvivalist.dds_outofbreath", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,							"PLDialogSurvivalist.dds_areyouoncrack", 1);
	Addto(lWatchingCrazy,							"PLDialogSurvivalist.dds_iseeyourecrazy", 1);
	Addto(lWatchingCrazy,							"PLDialogSurvivalist.dds_freak", 1);

	//Clear(lGroupLaugh);
	//Addto(lGroupLaugh,								"PLDialogSurvivalist.dds_group_laugh", 1);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,						"PLDialogSurvivalist.dds_someoneshooting", 1);
	Addto(lshootingoverthere,						"PLDialogSurvivalist.dds_someidiotisfiring", 1);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,						"PLDialogSurvivalist.dds_someguysshooting", 1);
	Addto(lkillingoverthere,						"PLDialogSurvivalist.dds_theresalunatic", 1);
	Addto(lkillingoverthere,						"PLDialogSurvivalist.dds_stopthatguy", 1);
	Addto(lkillingoverthere,						"PLDialogSurvivalist.dds_peoplearedying", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,								"PLDialogSurvivalist.dds_scream1", 1);
	Addto(lscreaming,								"PLDialogSurvivalist.dds_scream2", 1);
	Addto(lscreaming,								"PLDialogSurvivalist.dds_scream3", 1);
	Addto(lscreaming,								"PLDialogSurvivalist.dds_scream4", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,							"PLDialogSurvivalist.dds_yeagh", 1);
	Addto(lscreamingonfire,							"PLDialogSurvivalist.dds_awghelpme", 1);
	Addto(lscreamingonfire,							"PLDialogSurvivalist.dds_imburning", 1);
	Addto(lscreamingonfire,							"PLDialogSurvivalist.dds_putmeout", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,								"PLDialogSurvivalist.dds_youthinkthatcan", 1);
	Addto(lDoHeroics,								"PLDialogSurvivalist.dds_rah", 1);
	Addto(lDoHeroics,								"PLDialogSurvivalist.dds_howaboutsomeofthis", 1);
	Addto(lDoHeroics,								"PLDialogSurvivalist.dds_youthinkimscared", 1);
	Addto(lDoHeroics,								"PLDialogSurvivalist.dds_illkillyou", 1);
	AddTo(lDoHeroics,								"PLDialogSurvivalist.dds_angrygetdown", 1);
	Addto(lDoHeroics,								"PLDialogSurvivalist.dds_mil_gogogo", 1);
	Addto(lDoHeroics,								"PLDialogSurvivalist.dds_mil_moveout", 1);
	AddTo(lDoHeroics,								"PLDialogSurvivalist.dds_mil_go", 2);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,							"PLDialogSurvivalist.dds_spitoutpiss", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,						"PLDialogSurvivalist.dds_christ", 1);
	Addto(laftergettingpissedon,						"PLDialogSurvivalist.dds_eugh", 1);
	Addto(laftergettingpissedon,						"PLDialogSurvivalist.dds_yousickbastard", 1);
	Addto(laftergettingpissedon,						"PLDialogSurvivalist.dds_motherfucker", 1);
	Addto(laftergettingpissedon,						"PLDialogSurvivalist.dds_cop_jesus", 1);
	Addto(laftergettingpissedon,						"PLDialogSurvivalist.dds_cop_yeeuuggh", 1);
	Addto(laftergettingpissedon,						"PLDialogSurvivalist.dds_cop_yousickbastard", 2);
	Addto(laftergettingpissedon,						"PLDialogSurvivalist.dds_cop_ohthatsit", 2);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"PLDialogSurvivalist.dds_whatthe", 1);
	Addto(lwhatthe,								"PLDialogSurvivalist.dds_whuh", 1);
	Addto(lwhatthe,								"PLDialogSurvivalist.dds_heey", 1);

	Clear(lseeingpisser);
	Addto(lseeingpisser,							"PLDialogSurvivalist.dds_thatsdisgusting", 1);
	Addto(lseeingpisser,							"PLDialogSurvivalist.dds_unsanitary", 1);
	Addto(lseeingpisser,							"PLDialogSurvivalist.dds_howawful", 1);
	Addto(lseeingpisser,							"PLDialogSurvivalist.dds_hemustbefrench", 1);
	Addto(lseeingpisser,							"PLDialogSurvivalist.dds_animal", 1);

	Clear(lSomethingIsGross);
	Addto(lSomethingIsGross,							"PLDialogSurvivalist.dds_thatsdisgusting", 1);
	Addto(lSomethingIsGross,							"PLDialogSurvivalist.dds_unsanitary", 1);
	Addto(lSomethingIsGross,							"PLDialogSurvivalist.dds_howawful", 1);

	Clear(lgothit);
	Addto(lgothit,								"PLDialogSurvivalist.dds_aahimhit", 1);
	addto(lgothit,								"PLDialogSurvivalist.dds_argh", 1);	
	addto(lgothit,								"PLDialogSurvivalist.dds_ow", 1);
	addto(lgothit,								"PLDialogSurvivalist.dds_shit", 1);
	addto(lgothit,								"PLDialogSurvivalist.dds_aghk", 1);
	addto(lgothit,								"PLDialogSurvivalist.dds_gak", 1);
	AddTo(lgothit,								"PLDialogSurvivalist.dds_cop_aah", 1);	
	AddTo(lgothit,								"PLDialogSurvivalist.dds_cop_imhit", 1);					
	AddTo(lgothit,								"PLDialogSurvivalist.dds_cop_argh", 1);
	AddTo(lgothit,								"PLDialogSurvivalist.dds_cop_fuck", 1);

	Clear(lAttacked);
	addto(lAttacked,								"PLDialogSurvivalist.dds_argh", 1);	
	addto(lAttacked,								"PLDialogSurvivalist.dds_ow", 1);
	addto(lAttacked,								"PLDialogSurvivalist.dds_shit", 1);
	addto(lAttacked,								"PLDialogSurvivalist.dds_aghk", 1);
	addto(lAttacked,								"PLDialogSurvivalist.dds_gak", 1);

	Clear(lGrunt);
	addto(lGrunt,								"PLDialogSurvivalist.dds_argh", 1);	
	addto(lGrunt,								"PLDialogSurvivalist.dds_ow", 1);
	addto(lGrunt,								"PLDialogSurvivalist.dds_aghk", 1);
	addto(lGrunt,								"PLDialogSurvivalist.dds_gak", 1);

	// no pissing talking
	Clear(lPissing);
	Addto(lPissing,								"PLDialogSurvivalist.dds_ahh", 1);
	Addto(lPissing,								"PLDialogSurvivalist.dds_ohyeah", 1);
	Addto(lPissing,								"PLDialogSurvivalist.dds_satisfiedsigh", 1);

	Clear(lPissOnSelf);
	Addto(lPissOnSelf,							"PLDialogSurvivalist.dds_spitting", 1);
	
	// no pissing myself out talking
	Clear(lPissOutFireOnSelf);
	Addto(lPissOutFireOnSelf,					"PLDialogSurvivalist.dds_ahh", 1);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,					"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lGotHealth);
	Addto(lGotHealth,							"PLDialogSurvivalist.dds_ahh", 1);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,						"PLDialogSurvivalist.dds_thatwasprettytasty", 1);
	Addto(lGotHealthFood,						"PLDialogSurvivalist.dds_hardtobelievethat", 1);
	Addto(lGotHealthFood,						"PLDialogSurvivalist.dds_heythatwasactually", 1);
	Addto(lGotHealthFood,						"PLDialogSurvivalist.dds_goodgodwhatwasin", 1);
	Addto(lGotHealthFood,						"PLDialogSurvivalist.dds_burp", 1);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth,						"PLDialogSurvivalist.dds_ohyeahthattookayear", 1);

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"PLDialogSurvivalist.dds_argh", 1);	

	Clear(lbegforlife);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_pleasedontkillme", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_crying", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_sparemylifekids", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_dontkillvirgin", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_pleasepleaseno", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_crying1", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_crying2", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_crying3", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_crying4", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_snivel1", 1);
	Addto(lbegforlife,							"PLDialogSurvivalist.dds_snivel2", 1);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_pleasedontkillme", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_crying", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_sparemylifekids", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_dontkillminority", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_dontkillvirgin", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_pleasepleaseno", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_crying1", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_crying2", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_crying3", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_crying4", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_snivel1", 1);
	Addto(lbegforlifeMin,							"PLDialogSurvivalist.dds_snivel2", 1);
	
	Clear(ldying);
	Addto(ldying,								"PLDialogSurvivalist.dds_mommy", 1);
	Addto(ldying,								"PLDialogSurvivalist.dds_icantfeelmylegs", 1);
	Addto(ldying,								"PLDialogSurvivalist.dds_deathcrawl1", 1);
	Addto(ldying,								"PLDialogSurvivalist.dds_deathcrawl2", 1);
	Addto(ldying,								"PLDialogSurvivalist.dds_deathcrawl3", 1);
	Addto(ldying,								"PLDialogSurvivalist.dds_icantbreathe", 1);
	Addto(ldying,								"PLDialogSurvivalist.dds_somebodypleasemake", 1);
	Addto(ldying,								"PLDialogSurvivalist.dds_godithurts", 1);
	Addto(ldying,								"PLDialogSurvivalist.dds_ohgod", 1);
	Addto(ldying,								"PLDialogSurvivalist.dds_justfinishit", 1);
	AddTo(ldying,								"PLDialogSurvivalist.dds_mil_gameoverman", 1);
	AddTo(ldying,								"PLDialogSurvivalist.dds_mil_mandown", 1);

	Clear(lCrying);
	Addto(lCrying,								"PLDialogSurvivalist.dds_crying", 1);
	Addto(lCrying,								"PLDialogSurvivalist.dds_crying1", 1);
	Addto(lCrying,								"PLDialogSurvivalist.dds_crying2", 1);
	Addto(lCrying,								"PLDialogSurvivalist.dds_crying3", 1);
	Addto(lCrying,								"PLDialogSurvivalist.dds_crying4", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,						"PLDialogSurvivalist.dds_ohimsorrysovery", 1);	
	Addto(lfrightenedapology,						"PLDialogSurvivalist.dds_pleaseillneverdo", 1);
	Addto(lfrightenedapology,						"PLDialogSurvivalist.dds_ididntmeanit", 1);

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"PLDialogSurvivalist.dds_yourenotsotough", 1);
	Addto(ltrashtalk,							"PLDialogSurvivalist.dds_cmonfightlikeaman", 1);
	Addto(ltrashtalk,							"PLDialogSurvivalist.dds_whereyougoingsissy", 1);
	Addto(ltrashtalk,							"PLDialogSurvivalist.dds_youcantdothattomy", 1);
	Addto(ltrashtalk,							"PLDialogSurvivalist.dds_illkillyou", 1);
	Addto(ltrashtalk,							"PLDialogSurvivalist.dds_youcantdothattome", 1);
	Addto(ltrashtalk,							"PLDialogSurvivalist.dds_youthinkthatcan", 1);
	Addto(ltrashtalk,							"PLDialogSurvivalist.dds_youthinkimscared", 1);
	AddTo(ltrashtalk,							"PLDialogSurvivalist.dds_mil_likearat", 1);
	AddTo(ltrashtalk,							"PLDialogSurvivalist.dds_mil_hesgoingnowhere", 2);
	AddTo(ltrashtalk,							"PLDialogSurvivalist.dds_mil_nowhereleftto", 2);
	Addto(ltrashtalk,							"PLDialogSurvivalist.dds_fuckyoubuddy", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting,							"PLDialogSurvivalist.dds_cmonfightlikeaman", 1);
	Addto(lWhileFighting,							"PLDialogSurvivalist.dds_whereyougoingsissy", 1);
	Addto(lWhileFighting,							"PLDialogSurvivalist.dds_imnotavictim", 1);
	Addto(lWhileFighting,							"PLDialogSurvivalist.dds_illkillyou", 1);
	Addto(lWhileFighting,							"PLDialogSurvivalist.dds_rah", 1);
	Addto(lWhileFighting,							"PLDialogSurvivalist.dds_howaboutsomeofthis", 1);
	Addto(lWhileFighting,							"PLDialogSurvivalist.dds_motherfucker", 1);
	AddTo(lWhileFighting,							"PLDialogSurvivalist.dds_mil_takeemdown", 2);
	AddTo(lWhileFighting,							"PLDialogSurvivalist.dds_mil_fireatwill", 3);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,							"PLDialogSurvivalist.dds_whatseemstobethe", 1);
	Addto(laskcopwhatsup,							"PLDialogSurvivalist.dds_isanythingwrong", 1);

	Clear(lratout);
	Addto(lratout,								"PLDialogSurvivalist.dds_thatguyoverthere", 1);
	Addto(lratout,								"PLDialogSurvivalist.dds_hedidit", 1);
	Addto(lratout,								"PLDialogSurvivalist.dds_thatguy", 1);
	Addto(lratout,								"PLDialogSurvivalist.dds_itwashim", 1);

	Clear(lfakeratout);
	Addto(lfakeratout,							"PLDialogSurvivalist.dds_hediditisaw", 1);

	Clear(lcleanshot);
	Addto(lcleanshot,							"PLDialogSurvivalist.dds_getouttatheway", 1);
	AddTo(lcleanshot,							"PLDialogSurvivalist.dds_angrygetdown", 1);
	AddTo(lcleanshot,							"PLDialogSurvivalist.dds_angrygetdownifyou", 1);
	AddTo(lcleanshot,							"PLDialogSurvivalist.dds_cop_getthefuck", 1);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"PLDialogSurvivalist.dds_getouttatheway", 1);
	AddTo(lCleanMeleeHit,						"PLDialogSurvivalist.dds_angrygetdown", 1);
	AddTo(lCleanMeleeHit,						"PLDialogSurvivalist.dds_angrygetdownifyou", 1);
	AddTo(lCleanMeleeHit,						"PLDialogSurvivalist.dds_cop_getthefuck", 1);

	Clear(lInhale);
	Addto(lInhale,								"PLDialogSurvivalist.dds_inhale", 1);
												
	Clear(lExhale);								
	Addto(lExhale,								"PLDialogSurvivalist.dds_exhale", 1);
	
	Clear(lEatingFood);
	Addto(lEatingFood,							"PLDialogSurvivalist.dds_mmm", 1);
	Addto(lEatingFood,							"PLDialogSurvivalist.dds_chewing", 1);
	Addto(lEatingFood,							"PLDialogSurvivalist.dds_smacking", 1);
	Addto(lEatingFood,							"PLDialogSurvivalist.dds_drinkingsucking", 1);

	Clear(lAfterEating);
	Addto(lAfterEating,							"PLDialogSurvivalist.dds_thatwasprettytasty", 1);
	Addto(lAfterEating,							"PLDialogSurvivalist.dds_ohyeahthattookayear", 1);
	Addto(lAfterEating,							"PLDialogSurvivalist.dds_hardtobelievethat", 1);
	Addto(lAfterEating,							"PLDialogSurvivalist.dds_heythatwasactually", 1);
	Addto(lAfterEating,							"PLDialogSurvivalist.dds_goodgodwhatwasin", 1);
	Addto(lAfterEating,							"PLDialogSurvivalist.dds_burp", 1);

	Clear(lpleasureresponse);					
	Addto(lpleasureresponse,						"PLDialogSurvivalist.dds_ahh", 1);
	Addto(lpleasureresponse,						"PLDialogSurvivalist.dds_ohyeah", 1);

	Clear(laftersitdown);
	Addto(laftersitdown,							"PLDialogSurvivalist.dds_thatsaloadoff", 1);
	Addto(laftersitdown,							"PLDialogSurvivalist.dds_satisfiedsigh", 1);

	Clear(lSpitting);
	Addto(lSpitting,							"PLDialogSurvivalist.dds_shortingspitting", 1);
	Addto(lSpitting,							"PLDialogSurvivalist.dds_spitting", 1);
	
	Clear(lhmm);
	Addto(lhmm,									"PLDialogSurvivalist.dds_hmmmm", 1);

	Clear(lfollowme);
	Addto(lfollowme,							"PLDialogSurvivalist.dds_followme", 1);	
	Addto(lfollowme,							"PLDialogSurvivalist.dds_thisway", 1);
	Addto(lfollowme,							"PLDialogSurvivalist.dds_mil_gogogo", 1);
	Addto(lfollowme,							"PLDialogSurvivalist.dds_mil_moveout", 1);

	Clear(lStayHere);
	Addto(lStayHere,							"PLDialogSurvivalist.dds_mil_securethearea", 1);

	Clear(lilltakenumber);
	Addto(lilltakenumber,							"PLDialogSurvivalist.dds_illtakeanumber", 1);

	Clear(lmakedeposit);
	Addto(lmakedeposit,								"PLDialogSurvivalist.dds_idliketomakea", 1);

	Clear(lmakewithdrawal);
	Addto(lmakewithdrawal,							"PLDialogSurvivalist.dds_ineedtowithdraw", 1);

	Clear(lconsumerbuy);
	Addto(lconsumerbuy,							"PLDialogSurvivalist.dds_andthereyougo", 1);
	Addto(lconsumerbuy,							"PLDialogSurvivalist.dds_letsseethatshould", 1);
	Addto(lconsumerbuy,							"PLDialogSurvivalist.dds_hereyougo", 1);

	Clear(lconteststoretransaction);
	Addto(lconteststoretransaction,						"PLDialogSurvivalist.dds_whatkindofaclip", 1);
	Addto(lconteststoretransaction,						"PLDialogSurvivalist.dds_imnotpayingthat", 1);
	Addto(lconteststoretransaction,						"PLDialogSurvivalist.dds_imnevershopping", 1);
	
	Clear(lcontestbanktransaction);
	Addto(lcontestbanktransaction,						"PLDialogSurvivalist.dds_heyihadmoremoney", 1);
	Addto(lcontestbanktransaction,						"PLDialogSurvivalist.dds_someonesembezzling", 1);	
	Addto(lcontestbanktransaction,						"PLDialogSurvivalist.dds_theremustbesome", 1);

	Clear(lGoPostal);
	Addto(lGoPostal,								"PLDialogSurvivalist.dds_postal_howaboutwe", 1);
	Addto(lGoPostal,								"PLDialogSurvivalist.dds_postal_ifonemore", 1);	
	Addto(lGoPostal,								"PLDialogSurvivalist.dds_postal_godsaidits", 1);
	Addto(lGoPostal,								"PLDialogSurvivalist.dds_postal_forgiveme", 1);	
	Addto(lGoPostal,								"PLDialogSurvivalist.dds_postal_imsorry", 1);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_thehorror", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_help", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_heseemedlikesuch", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_ohmygod", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_itshorrible", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_imgoingtobesick", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_forchristsake", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_pleasemakeitstop", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_icantbelievethis", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_icantbelievehe", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_thiscantbereal", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_itslikeapocolypse", 1);
// Not applicable
//	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_niceparticlesman", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_holyshit", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_howcanthisbe", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_heskillingeveryone", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_runrun", 1);
//	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_hesgotagun", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_sweetlordno", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_cantwealljustget", 1);
	Addto(lcarnageoccurred,							"PLDialogSurvivalist.dds_ghasp", 1);

	Clear(lCallCat);
	Addto(lCallCat, 							"PLDialogSurvivalist.dds_herekitty", 1);
	Addto(lCallCat, 							"PLDialogSurvivalist.dds_herekittyevil", 1);

	Clear(lHateCat);
	Addto(lHateCat, 							"PLDialogSurvivalist.dds_getoutfurball", 1);
	Addto(lHateCat, 							"PLDialogSurvivalist.dds_goddamcat", 1);

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"PLDialogSurvivalist.dds_whatthe", 1);
	Addto(lStartAttackingAnimal,				"PLDialogSurvivalist.dds_cop_jesus", 1);
	Addto(lStartAttackingAnimal,				"PLDialogSurvivalist.dds_cop_fuck", 1);

	Clear(lGettingRobbed);	
	Addto(lGettingRobbed,							"PLDialogSurvivalist.dds_comebackherewith", 1);
	Addto(lGettingRobbed,							"PLDialogSurvivalist.dds_hetookmymoney", 1);
	Addto(lGettingRobbed,							"PLDialogSurvivalist.dds_hejustrippedme", 1);
	Addto(lGettingRobbed,							"PLDialogSurvivalist.dds_somebodystophim", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"PLDialogSurvivalist.dds_help", 1);
	Addto(lGettingMugged,						"PLDialogSurvivalist.dds_snivel1", 1);
	Addto(lGettingMugged,						"PLDialogSurvivalist.dds_pleasedontkillme", 1);
	Addto(lGettingMugged,						"PLDialogSurvivalist.dds_snivel2", 1);
	Addto(lGettingMugged,						"PLDialogSurvivalist.dds_ghasp", 1);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"PLDialogSurvivalist.dds_comebackherewith", 1);
	Addto(lAfterMugged,							"PLDialogSurvivalist.dds_hetookmymoney", 1);
	Addto(lAfterMugged,							"PLDialogSurvivalist.dds_somebodystophim", 1);

	Clear(lDoMugging);	
	Addto(lDoMugging,							"PLDialogSurvivalist.dds_alrightbitchhand", 1);
	Addto(lDoMugging,							"PLDialogSurvivalist.dds_gimmeallyermoney", 1);
	Addto(lDoMugging,							"PLDialogSurvivalist.dds_handoverthedough", 1);
	Addto(lDoMugging,							"PLDialogSurvivalist.dds_thisisastickup", 1);
	
	Clear(lQuestion);	
	Addto(lQuestion,							"PLDialogSurvivalist.dds_whyyouvebeentold", 1);
	Addto(lQuestion,							"PLDialogSurvivalist.dds_whatsomejustasked", 1);
	Addto(lQuestion,							"PLDialogSurvivalist.dds_whatareyoutalking", 1);
	Addto(lQuestion,							"PLDialogSurvivalist.dds_idontcare", 1);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"PLDialogSurvivalist.dds_wellwhatwereyou", 1);
	Addto(lGenericQuestion,						"PLDialogSurvivalist.dds_sodoyouthink", 1);
	Addto(lGenericQuestion,						"PLDialogSurvivalist.dds_doyouknowwhattime", 1);
	Addto(lGenericQuestion,						"PLDialogSurvivalist.dds_sodoyouthinkthe", 1);
	Addto(lGenericQuestion,						"PLDialogSurvivalist.dds_wherewereyouplan", 1);
	Addto(lGenericQuestion,						"PLDialogSurvivalist.dds_heydidyouseethat", 1);


	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_ifitwasupyourass", 1);
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_ithinkineedadrink", 1);
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_youthinkicould", 1);
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_whatisabbaalex", 1);
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_williwinaprize", 1);
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_isthiscandid", 1);
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_whyisitwhenyoure", 1);
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_youkeeptalkingill", 1);
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_ithinkineedmesome", 1);
	Addto(lGenericAnswer,						"PLDialogSurvivalist.dds_iforget", 1);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"PLDialogSurvivalist.dds_yourenotreally", 1);
	Addto(lGenericFollowup,						"PLDialogSurvivalist.dds_listenjusttellme", 1);
	Addto(lGenericFollowup,						"PLDialogSurvivalist.dds_arentyouevenlistening", 1);
	Addto(lGenericFollowup,						"PLDialogSurvivalist.dds_areyouoncrack", 1);
	Addto(lGenericFollowup,						"PLDialogSurvivalist.dds_geezstopdoingthat", 1);
	Addto(lGenericFollowup,						"PLDialogSurvivalist.dds_iseeyourecrazy", 1);
	Addto(lGenericFollowup,						"PLDialogSurvivalist.dds_what", 1);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"PLDialogSurvivalist.dds_heywhoreyou", 1);
	Addto(linvadeshome,							"PLDialogSurvivalist.dds_whatareyoudoing", 1);
	Addto(linvadeshome,							"PLDialogSurvivalist.dds_getoutyoufreak", 1);
	Addto(linvadeshome,							"PLDialogSurvivalist.dds_getthehelloutofmy", 1);
	Addto(linvadeshome,							"PLDialogSurvivalist.dds_getoutnow", 1);
/*
never used
	Clear(lactionoutsidehome);
	Addto(lactionoutsidehome,						"PLDialogSurvivalist.dds_whatsalltheracket", 1);
	Addto(lactionoutsidehome,						"PLDialogSurvivalist.dds_keepitdown", 1);
	Addto(lactionoutsidehome,						"PLDialogSurvivalist.dds_thisisaquiet", 1);
	Addto(lactionoutsidehome,						"PLDialogSurvivalist.dds_whosoutthere", 1);
	Addto(lactionoutsidehome,						"PLDialogSurvivalist.dds_whatsgoingonout", 1);
*/
	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,							"PLDialogSurvivalist.dds_waittillgetabucket", 1);
	Addto(lsomeoneonfire,							"PLDialogSurvivalist.dds_ohtoobadwehaveno", 1);
	Addto(lsomeoneonfire,							"PLDialogSurvivalist.dds_ohmygodtheyreon", 1);
	Addto(lsomeoneonfire,							"PLDialogSurvivalist.dds_heystopdropandroll", 1);
	Addto(lsomeoneonfire,							"PLDialogSurvivalist.dds_ohmygodtheyreall", 1);
	Addto(lsomeoneonfire,							"PLDialogSurvivalist.dds_everyonesonfire", 1);

	Clear(labouttopuke);
	Addto(labouttopuke,							"PLDialogSurvivalist.dds_idontfeelsogood", 1);
	Addto(labouttopuke,							"PLDialogSurvivalist.dds_ohmanimgonnabesick", 1);
	Addto(labouttopuke,							"PLDialogSurvivalist.dds_ohgodim", 1);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,							"PLDialogSurvivalist.dds_vomit", 1);

	Clear(lGettingShocked);
	Addto(lGettingShocked,							"PLDialogSurvivalist.dds_vomit", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,								"HabibDialog.habib_ailili", 1);

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_uhhuh", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_nono", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_nohappy", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_yourekidding", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_okay", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_thatsgreat", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_greatbored", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_icantwait", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_hmm", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_stophappy", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_wellimnotsurebut", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_ohyouwouldnt", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_welldidyouseeem", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_iwasthinkingthe", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_yeahbuticanttell", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_thatsfunnyiwas", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_ohtheyalwaysdothat", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_itriedsixoncebuti", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_youdidntohmygawd", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_youknowittakessix", 1);
//	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_didyouhearthatkid", 1);
//	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_didyouhearsomeone", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_haveyouheardtheres", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_yeahiveheardthe", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_sohowmuchdoesa", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_wellwhatwereyou", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_sodoyouthink", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_doyouknowwhattime", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_sodoyouthinkthe", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_wherewereyouplan", 1);
	Addto(lCellPhoneTalk,							"PLDialogSurvivalist.dds_heydidyouseethat", 1);
	
	Clear(lZealots);
	Addto(lZealots,							"PLDialogSurvivalist.dds_werenotzealots", 1);
	Addto(lZealots,							"PLDialogSurvivalist.dds_thegoodbooktoldme", 1);
	Addto(lZealots,							"PLDialogSurvivalist.dds_stopoppressingus", 1);
	
//	Clear(lNormalFastFood);
//	Addto(lNormalFastFood,							"PLDialogSurvivalist.dds_helloandwelcome", 1);
//	Addto(lNormalFastFood,							"PLDialogSurvivalist.dds_haveaniceday", 1);
//	Addto(lNormalFastFood,							"PLDialogSurvivalist.dds_mayilargifythat", 1);
//	Addto(lNormalFastFood,							"PLDialogSurvivalist.dds_hereyouareenjoy", 1);
//	Addto(lNormalFastFood,							"PLDialogSurvivalist.dds_pleasehelpyourself", 1);
	
	Clear(lKrotchyCustomerComment);
	Addto(lKrotchyCustomerComment,					"PLDialogSurvivalist.dds_heyarethereanymore", 1);
	Addto(lKrotchyCustomerComment,					"PLDialogSurvivalist.dds_arentyouabitdark", 1);

	Clear(lKrotchyCustomerWant);
	Addto(lKrotchyCustomerWant,						"PLDialogSurvivalist.dds_ineedakrotchyformy", 1);
	Addto(lKrotchyCustomerWant,						"PLDialogSurvivalist.dds_anykrotchysleft", 1);
	Addto(lKrotchyCustomerWant,						"PLDialogSurvivalist.dds_icantfindanybad", 1);

	Clear(lGaryAutograph);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_iwastrulymovedby", 1);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_ihaveeveryepisode", 1);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_heywebstergimme", 1);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_ilovedyouaswebster", 1);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_heygarywewenttothe", 1);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_saythatwillisthing", 1);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_itsformymother", 1);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_itsformysister", 1);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_itsformygirluncle", 1);
	Addto(lGaryAutograph,							"PLDialogSurvivalist.dds_itsformykidbrother", 1);

	
	Clear(lProtestorCut);
	Addto(lProtestorCut,							"PLDialogSurvivalist.dds_heybuddyifyourenot", 1);
	Addto(lProtestorCut,							"PLDialogSurvivalist.dds_yeahyouprobablyeat", 1);
	
	Clear(ldudedead);
	Addto(ldudedead,							"PLDialogSurvivalist.dds_whatanasshole", 1);
	Addto(ldudedead,							"PLDialogSurvivalist.dds_iblamedoom", 1);
	Addto(ldudedead,							"PLDialogSurvivalist.dds_freak", 1);
	Addto(ldudedead,							"PLDialogSurvivalist.dds_illbethewasgay", 1);
	Addto(ldudedead,							"PLDialogSurvivalist.dds_goddamliberal", 1);
	Addto(ldudedead,							"PLDialogSurvivalist.dds_loser", 1);
	AddTo(ldudedead,							"PLDialogSurvivalist.dds_mil_allclear", 2);

	Clear(lKickDead);
	Addto(lKickDead,							"PLDialogSurvivalist.dds_heresoneforyer", 1);
	Addto(lKickDead,							"PLDialogSurvivalist.dds_hereyouforgotone", 1);
	Addto(lKickDead,							"PLDialogSurvivalist.dds_takethiswithyou", 1);

	Clear(lNameCalling);
	Addto(lNameCalling,							"PLDialogSurvivalist.dds_freak", 1);
	Addto(lNameCalling,							"PLDialogSurvivalist.dds_creep", 1);
	Addto(lNameCalling,							"PLDialogSurvivalist.dds_loser", 1);

	Clear(lRogueCop);
	Addto(lRogueCop,							"PLDialogSurvivalist.dds_ivelostmyfaithin", 1);
	Addto(lRogueCop,							"PLDialogSurvivalist.dds_thatcopsgoneinsane", 1);
	Addto(lRogueCop,							"PLDialogSurvivalist.dds_wheresmyvideocam", 1);
	Addto(lRogueCop,							"PLDialogSurvivalist.dds_ifihadacameraidbe", 1);
	Addto(lRogueCop,							"PLDialogSurvivalist.dds_lookathimoppress", 1);
	/// Sounded bad.. he chanted it, instead of screamed it (scared)
//	Addto(lRogueCop,							"PLDialogSurvivalist.dds_attica", 1);

	Clear(lgetbumped);
	Addto(lgetbumped,							"PLDialogSurvivalist.dds_heywatchit", 1);
	Addto(lgetbumped,							"PLDialogSurvivalist.dds_lookout", 1);
	AddTo(lgetbumped,							"PLDialogSurvivalist.dds_cop_nothingtosee", 1);
	AddTo(lgetbumped,							"PLDialogSurvivalist.dds_cop_moveit", 1);
	AddTo(lgetbumped,							"PLDialogSurvivalist.dds_cop_movealong", 1);
	AddTo(lgetbumped,							"PLDialogSurvivalist.dds_cop_wrongmove", 1);
	Addto(lgetbumped,							"PLDialogSurvivalist.dds_postal_ifonemore", 1);	

	Clear(lGetMad);
	Addto(lGetMad,								"PLDialogSurvivalist.dds_heywatchit", 1);
	Addto(lGetMad,								"PLDialogSurvivalist.dds_lookout", 1);
	AddTo(lGetMad,								"PLDialogSurvivalist.dds_cop_fuck", 1);
	AddTo(lGetMad,								"PLDialogSurvivalist.dds_cop_wrongmove", 1);
	AddTo(lGetMad,								"PLDialogSurvivalist.dds_cop_youllregret", 1);
	AddTo(lGetMad,								"PLDialogSurvivalist.dds_cop_youjustsigned", 1);
	Addto(lGetMad,								"PLDialogSurvivalist.dds_motherfucker", 1);

	Clear(lLynchMob);
	Addto(lLynchMob,							"PLDialogSurvivalist.dds_thereheis", 1);
	Addto(lLynchMob,							"PLDialogSurvivalist.dds_thatstheone", 1);
	Addto(lLynchMob,							"PLDialogSurvivalist.dds_heyyou", 1);
	Addto(lLynchMob,							"PLDialogSurvivalist.dds_gethim", 1);
	Addto(lLynchMob,							"PLDialogSurvivalist.dds_cop_ineedbackup", 1);
	Addto(lLynchMob,							"PLDialogSurvivalist.dds_cop_sendmebackup", 1);
	Addto(lLynchMob,							"PLDialogSurvivalist.dds_mil_takeemdown", 2);
	Addto(lLynchMob,							"PLDialogSurvivalist.dds_mil_fireatwill", 3);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"PLDialogSurvivalist.dds_illkillyou", 1);
	Addto(lSeesEnemy,							"PLDialogSurvivalist.dds_rah", 1);
	Addto(lSeesEnemy,							"PLDialogSurvivalist.dds_heyyou", 1);
	Addto(lSeesEnemy,							"PLDialogSurvivalist.dds_howaboutsomeofthis", 1);
	Addto(lSeesEnemy,							"PLDialogSurvivalist.dds_gethim", 1);
	Addto(lSeesEnemy,							"PLDialogSurvivalist.dds_mil_fireatwill", 3);

	Clear(lnextinline);
	Addto(lnextinline,							"PLDialogSurvivalist.dds_illtakethenext", 1);
	
	Clear(lhelpyouoverhere);
	Addto(lhelpyouoverhere,							"PLDialogSurvivalist.dds_icanhelpyouover", 1);

	Clear(lsomeonecuts);
	Addto(lsomeonecuts,							"PLDialogSurvivalist.dds_imsorrybutyoull", 1);

	Clear(lpleasemoveforward);
	Addto(lpleasemoveforward,						"PLDialogSurvivalist.dds_pleasemoveforward", 1);

	Clear(lcanihelpyou);
	Addto(lcanihelpyou,							"PLDialogSurvivalist.dds_howcanihelpyou", 1);
	Addto(lcanihelpyou,							"PLDialogSurvivalist.dds_cananyonehelpyou", 1);

	Clear(lNumbers_Thatllbe);
	Addto(lNumbers_Thatllbe,					"PLDialogSurvivalist.dds_thatllbe", 1);

	Clear(lNumbers_a);
	Addto(lNumbers_a,							"PLDialogSurvivalist.dds_a", 1);

	Clear(lNumbers_1);
	Addto(lNumbers_1,							"PLDialogSurvivalist.dds_1", 1);

	Clear(lNumbers_2);
	Addto(lNumbers_2,							"PLDialogSurvivalist.dds_2", 1);

	Clear(lNumbers_3);
	Addto(lNumbers_3,							"PLDialogSurvivalist.dds_3", 1);

	Clear(lNumbers_4);
	Addto(lNumbers_4,							"PLDialogSurvivalist.dds_4", 1);

	Clear(lNumbers_5);
	Addto(lNumbers_5,							"PLDialogSurvivalist.dds_5", 1);

	Clear(lNumbers_10);
	Addto(lNumbers_10,							"PLDialogSurvivalist.dds_10", 1);

	Clear(lNumbers_20);
	Addto(lNumbers_20,							"PLDialogSurvivalist.dds_20", 1);

	Clear(lNumbers_40);
	Addto(lNumbers_40,							"PLDialogSurvivalist.dds_40", 1);

	Clear(lNumbers_60);
	Addto(lNumbers_60,							"PLDialogSurvivalist.dds_60", 1);

	Clear(lNumbers_80);
	Addto(lNumbers_80,							"PLDialogSurvivalist.dds_80", 1);

	Clear(lNumbers_100);
	Addto(lNumbers_100,							"PLDialogSurvivalist.dds_100", 1);

	Clear(lNumbers_200);
	Addto(lNumbers_200,							"PLDialogSurvivalist.dds_200", 1);

	Clear(lNumbers_300);
	Addto(lNumbers_300,							"PLDialogSurvivalist.dds_300", 1);

	Clear(lNumbers_400);
	Addto(lNumbers_400,							"PLDialogSurvivalist.dds_400", 1);

	Clear(lNumbers_500);
	Addto(lNumbers_500,							"PLDialogSurvivalist.dds_500", 1);

	Clear(lNumbers_Dollars);
	Addto(lNumbers_Dollars,						"PLDialogSurvivalist.dds_dollars", 1);
	Addto(lNumbers_Dollars,						"PLDialogSurvivalist.dds_bucks", 1);

	Clear(lNumbers_SingleDollar);
	Addto(lNumbers_SingleDollar,				"PLDialogSurvivalist.dds_dollar", 1);
	Addto(lNumbers_SingleDollar,				"PLDialogSurvivalist.dds_buck", 1);

	Clear(lsellingitem);
	Addto(lsellingitem,							"PLDialogSurvivalist.dds_okaygreatandthank", 1);
	Addto(lsellingitem,							"PLDialogSurvivalist.dds_andcomeagain", 1);
	Addto(lsellingitem,							"PLDialogSurvivalist.dds_thatllworkthanks", 1);

	Clear(lIsThisEverything);
	Addto(lIsThisEverything,						"PLDialogSurvivalist.dds_isthiseverything", 1);
	
	Clear(llackofmoney);
	Addto(llackofmoney,							"PLDialogSurvivalist.dds_comebackwhenyou", 1);
	Addto(llackofmoney,							"PLDialogSurvivalist.dds_imsorrybutyouneed", 1);

	Clear(lSignPetition);							
	Addto(lSignPetition,							"PLDialogSurvivalist.dds_signpetition", 1);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,						"PLDialogSurvivalist.dds_dontsignpetition", 1);

	Clear(lPetitionBother);
	Addto(lPetitionBother,							"PLDialogSurvivalist.dds_buzzoffcreep", 1);
	Addto(lPetitionBother,							"PLDialogSurvivalist.dds_leavemealone", 1);

	Clear(lcallsecurity);
	Addto(lcallsecurity,							"PLDialogSurvivalist.dds_security", 1);
	Addto(lcallsecurity,							"PLDialogSurvivalist.dds_someonegetthisguy", 1);
	Addto(lcallsecurity,							"PLDialogSurvivalist.dds_willsomeoneplease", 1);
	
	Clear(lrowdycustomer);
	Addto(lrowdycustomer,							"PLDialogSurvivalist.dds_pleasecalmdown", 1);
	Addto(lrowdycustomer,							"PLDialogSurvivalist.dds_letsworkthisout", 1);
	Addto(lrowdycustomer,							"PLDialogSurvivalist.dds_dontmakemecallsec", 1);
	Addto(lrowdycustomer,							"PLDialogSurvivalist.dds_dontmakemecallpol", 1);
	
	Clear(lRWSemployee);
	Addto(lRWSemployee,							"PLDialogSurvivalist.dds_heydudeseevince", 1);
	Addto(lrwsemployee,							"PLDialogSurvivalist.dds_vinceneedstoseeyou", 1);

	Clear(lCityWorker);
	Addto(lCityWorker,							"PLDialogSurvivalist.dds_city_andletthatbe", 1);

	Clear(lJunkyard_DudeBuyingPart);
	Addto(lJunkyard_DudeBuyingPart,				"PLDialogSurvivalist.dds_junkyard_yeahivegot", 1);

	Clear(lJunkyard_DogsGotOut);
	Addto(lJunkyard_DogsGotOut,					"PLDialogSurvivalist.dds_junkyard_wholetthedogsou", 1);
	
	Clear(lChampPhotoReaction);
	Addto(lChampPhotoReaction,					"PLDialogSurvivalist.dds_christ", 1);
	Addto(lChampPhotoReaction,					"PLDialogSurvivalist.dds_shit", 1);
	Addto(lChampPhotoReaction,					"PLDialogSurvivalist.dds_holyshit", 1);
	Addto(lChampPhotoReaction,					"PLDialogSurvivalist.dds_thehorror", 1);
	Addto(lChampPhotoReaction,					"PLDialogSurvivalist.dds_itshorrible", 1);
	Addto(lChampPhotoReaction,					"PLDialogSurvivalist.dds_sweetlordno", 1);
	Addto(lChampPhotoReaction,					"PLDialogSurvivalist.dds_ghasp", 1);

	Clear(lPhoto_FindWiseWang);
	Addto(lPhoto_FindWiseWang,								"PLDialogSurvivalist.dds_thatguyoverthere", 1);

	Clear(lNumbers_6);
	AddTo(lNumbers_6,							"PL-Dialog.TuesdayA.6", 1);
	Clear(lNumbers_7);
	AddTo(lNumbers_7,							"PL-Dialog.TuesdayA.7", 1);
	Clear(lNumbers_8);
	AddTo(lNumbers_8,							"PL-Dialog.TuesdayA.8", 1);
	Clear(lNumbers_9);
	AddTo(lNumbers_9,							"PL-Dialog.TuesdayA.9", 1);
	Clear(lNumbers_11);
	AddTo(lNumbers_11,							"PL-Dialog.TuesdayA.11", 1);
	Clear(lNumbers_12);
	AddTo(lNumbers_12,							"PL-Dialog.TuesdayA.12", 1);
	Clear(lNumbers_13);
	AddTo(lNumbers_13,							"PL-Dialog.TuesdayA.13", 1);
	Clear(lNumbers_14);
	AddTo(lNumbers_14,							"PL-Dialog.TuesdayA.14", 1);
	Clear(lNumbers_15);
	AddTo(lNumbers_15,							"PL-Dialog.TuesdayA.15", 1);
	Clear(lNumbers_16);
	AddTo(lNumbers_16,							"PL-Dialog.TuesdayA.16", 1);
	Clear(lNumbers_17);
	AddTo(lNumbers_17,							"PL-Dialog.TuesdayA.17", 1);
	Clear(lNumbers_18);
	AddTo(lNumbers_18,							"PL-Dialog.TuesdayA.18", 1);
	Clear(lNumbers_19);
	AddTo(lNumbers_19,							"PL-Dialog.TuesdayA.19", 1);
	Clear(lNumbers_30);
	AddTo(lNumbers_30,							"PL-Dialog.TuesdayA.30", 1);
	Clear(lNumbers_50);
	AddTo(lNumbers_50,							"PL-Dialog.TuesdayA.50", 1);
	Clear(lNumbers_70);
	AddTo(lNumbers_70,							"PL-Dialog.TuesdayA.70", 1);
	Clear(lNumbers_90);
	AddTo(lNumbers_90,							"PL-Dialog.TuesdayA.90", 1);
	Clear(lNumbers_600);
	AddTo(lNumbers_600,							"PL-Dialog.TuesdayA.600", 1);
	Clear(lNumbers_700);
	AddTo(lNumbers_700,							"PL-Dialog.TuesdayA.700", 1);
	Clear(lNumbers_800);
	AddTo(lNumbers_800,							"PL-Dialog.TuesdayA.800", 1);
	Clear(lNumbers_900);
	AddTo(lNumbers_900,							"PL-Dialog.TuesdayA.900", 1);
	Clear(lCashier_PleaseTakeATicket);
	AddTo(lCashier_PleaseTakeATicket,			"PLDialogSurvivalist.dds_illtakeanumber", 1);
	Clear(lCashier_PleaseWaitYourTurn);
	AddTo(lCashier_PleaseWaitYourTurn,			"PLDialogSurvivalist.dds_imsorrybutyoull", 1);
	
	// Cop dialogue
	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,						"PLDialogSurvivalist.dds_creep", 1);
	Addto(lrespondtohotgreeting,						"PLDialogSurvivalist.dds_ugh", 1);
	Addto(lrespondtohotgreeting,						"PLDialogSurvivalist.dds_loser", 1);
	Addto(lrespondtohotgreeting,						"PLDialogSurvivalist.dds_moron", 1);
	
	Clear(lcop_nothingtosee);
	AddTo(lcop_nothingtosee,						"PLDialogSurvivalist.dds_cop_nothingtosee", 1);
	AddTo(lcop_nothingtosee,						"PLDialogSurvivalist.dds_cop_movealong", 1);
	AddTo(lcop_nothingtosee,						"PLDialogSurvivalist.dds_cop_moveit", 1);

	CLear(lcop_someonedisobeyed);
	AddTo(lcop_someonedisobeyed,						"PLDialogSurvivalist.dds_cop_wrongmove", 1);
	AddTo(lcop_someonedisobeyed,						"PLDialogSurvivalist.dds_cop_youllregret", 1);
	AddTo(lcop_someonedisobeyed,						"PLDialogSurvivalist.dds_cop_youjustsigned", 1);

	CLear(lCop_GoingToInvestigate);
	AddTo(lCop_GoingToInvestigate,						"PLDialogSurvivalist.dds_cop_staycalmill", 1);
	AddTo(lCop_GoingToInvestigate,						"PLDialogSurvivalist.dds_cop_illgocheck", 1);
	AddTo(lCop_GoingToInvestigate,						"PLDialogSurvivalist.dds_cop_imonit", 2);

	CLear(lCop_noticeillegalthing);
	Addto(lCop_noticeillegalthing,						"PLDialogSurvivalist.dds_cop_wellwellwhat", 1);
	Addto(lCop_noticeillegalthing,						"PLDialogSurvivalist.dds_cop_ohnoiamnot", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,							"PLDialogSurvivalist.dds_cop_okaythisoughta", 1);
	Addto(lnoticedickout,							"PLDialogSurvivalist.dds_cop_heymisterpeep", 1);

	Clear(lcop_putawaydick1);	
	Addto(lcop_putawaydick1,						"PLDialogSurvivalist.dds_cop_pullyourpants", 1);
	Addto(lcop_putawaydick1,						"PLDialogSurvivalist.dds_cop_zipyourpants", 1);
	Addto(lcop_putawaydick1,						"PLDialogSurvivalist.dds_cop_putthatthing", 2);	

	Clear(lcop_noticelegalgun);
	Addto(lcop_noticelegalgun,						"PLDialogSurvivalist.dds_cop_hopeyouhave", 1);
	Addto(lcop_noticelegalgun,						"PLDialogSurvivalist.dds_cop_justwatchwhere", 1);
	Addto(lcop_noticelegalgun,						"PLDialogSurvivalist.dds_cop_itsprobablynot", 2);

	Clear(lcop_noticegaspouring);	
	Addto(lcop_noticegaspouring,						"PLDialogSurvivalist.dds_cop_heywhatdoyou", 1);
	Addto(lcop_noticegaspouring,						"PLDialogSurvivalist.dds_cop_heyyoucantdo", 1);
	Addto(lcop_noticegaspouring,						"PLDialogSurvivalist.dds_cop_whoaholdup", 2);

	Clear(lcop_turnaround1);
	Addto(lcop_turnaround1,							"PLDialogSurvivalist.dds_cop_youthereturn", 1);
	Addto(lcop_turnaround1,							"PLDialogSurvivalist.dds_cop_ineedtotalkto", 1);

	Clear(lcop_turnaround2);	
	Addto(lcop_turnaround2,							"PLDialogSurvivalist.dds_cop_turnaroundand", 1);

	Clear(lcop_callforbackup);
	Addto(lcop_callforbackup,						"PLDialogSurvivalist.dds_cop_ineedbackup", 1);
	Addto(lcop_callforbackup,						"PLDialogSurvivalist.dds_cop_sendmebackup", 1);
	Addto(lcop_callforbackup,						"PLDialogSurvivalist.dds_cop_wevegotasit", 1);	
	Addto(lcop_callforbackup,						"PLDialogSurvivalist.dds_cop_shotsfired", 2);

	Clear(lcop_whofiredweapon);
	Addto(lcop_whofiredweapon,						"PLDialogSurvivalist.dds_cop_whojustfired", 1);
	Addto(lcop_whofiredweapon,						"PLDialogSurvivalist.dds_cop_isupposenobody", 1);
	Addto(lcop_whofiredweapon,						"PLDialogSurvivalist.dds_cop_somebodymust", 2);
	Addto(lcop_whofiredweapon,						"PLDialogSurvivalist.dds_cop_anyoneseewhat", 2);

	Clear(lcop_surprisesomeone);
	Addto(lcop_surprisesomeone,						"PLDialogSurvivalist.dds_cop_aha", 1);

	Clear(lcop_disappointment);				
	Addto(lcop_disappointment,						"PLDialogSurvivalist.dds_cop_hmmph", 1);
	Addto(lcop_disappointment,						"PLDialogSurvivalist.dds_cop_shit", 1);
	Addto(lcop_disappointment,						"PLDialogSurvivalist.dds_cop_wrongguy", 1);

	Clear(lcop_nevermind);
	Addto(lcop_nevermind,							"PLDialogSurvivalist.dds_cop_nevermind", 1);
	Addto(lcop_nevermind,							"PLDialogSurvivalist.dds_cop_youreclean", 1);

	Clear(lcop_whoshotme);
	Addto(lcop_whoshotme,							"PLDialogSurvivalist.dds_cop_whojustshotme", 1);
	Addto(lcop_whoshotme,							"PLDialogSurvivalist.dds_cop_tellmewhojust", 2);
	Addto(lcop_whoshotme,							"PLDialogSurvivalist.dds_cop_didyousee", 2);

	Clear(lcop_freeze1);
	Addto(lcop_freeze1,							"PLDialogSurvivalist.dds_cop_freeze", 1);	
	Addto(lcop_freeze1,							"PLDialogSurvivalist.dds_cop_stoprightthere", 1);
	Addto(lcop_freeze1,							"PLDialogSurvivalist.dds_cop_stoporill", 1);							

	Clear(lcop_putdownweapon1);
	Addto(lcop_putdownweapon1,						"PLDialogSurvivalist.dds_cop_putyourweapon", 1);
	Addto(lcop_putdownweapon1,						"PLDialogSurvivalist.dds_cop_dropyourweapon", 1);
	Addto(lcop_putdownweapon1,						"PLDialogSurvivalist.dds_cop_dropitasshole", 1);

	Clear(lcop_underarrest);
	Addto(lcop_underarrest,							"PLDialogSurvivalist.dds_cop_youreunder", 1);
	Addto(lcop_underarrest,							"PLDialogSurvivalist.dds_cop_okayyourecome", 1);
	Addto(lcop_underarrest,							"PLDialogSurvivalist.dds_cop_thatsityoure", 1);

	Clear(lcop_holdstill);
	Addto(lcop_holdstill,							"PLDialogSurvivalist.dds_cop_nowjusthold", 1);
	Addto(lcop_holdstill,							"PLDialogSurvivalist.dds_cop_imgoingtohave", 1);

	Clear(lCop_CopOuttaLine);
	Addto(lCop_CopOuttaLine,					"PLDialogSurvivalist.dds_cop_whoaheyman", 1);
	Addto(lCop_CopOuttaLine,					"PLDialogSurvivalist.dds_cop_heyitsnotworth", 1);
	Addto(lCop_CopOuttaLine,					"PLDialogSurvivalist.dds_cop_heystopman", 2);
	Addto(lCop_CopOuttaLine,					"PLDialogSurvivalist.dds_cop_cmonstop", 2);

	Clear(lcop_Miranda);
	Addto(lcop_Miranda,							"PLDialogSurvivalist.dds_cop_miranda", 1);

	Clear(lcop_SuspectSighted);
	Addto(lcop_SuspectSighted,					"PLDialogSurvivalist.dds_cop_suspectsighted", 1);
	Addto(lcop_SuspectSighted,					"PLDialogSurvivalist.dds_cop_ivegottheperp", 1);
	Addto(lcop_SuspectSighted,					"PLDialogSurvivalist.dds_cop_gotthescumbag", 1);
	
	Clear(lcop_RadioBack);
	Addto(lcop_RadioBack,						"PLDialogSurvivalist.dds_cop_roger", 1);
	Addto(lcop_RadioBack,						"PLDialogSurvivalist.dds_cop_rogerthatill", 1);
	Addto(lcop_RadioBack,						"PLDialogSurvivalist.dds_cop_uhillhaveto", 2);
	
	// Military dialogue
	Clear(lMil_MoveOut);
	AddTo(lMil_MoveOut,						"PLDialogSurvivalist.dds_mil_gogogo", 1);
	AddTo(lMil_MoveOut,						"PLDialogSurvivalist.dds_mil_moveout", 1);
	AddTo(lMil_MoveOut,						"PLDialogSurvivalist.dds_mil_huthuthut", 2);
	AddTo(lMil_MoveOut,						"PLDialogSurvivalist.dds_mil_go", 2);

	Clear(lMil_ManDown);
	AddTo(lMil_ManDown,						"PLDialogSurvivalist.dds_mil_mandown", 1);
	AddTo(lMil_ManDown,						"PLDialogSurvivalist.dds_mil_theykilled", 1);
	AddTo(lMil_ManDown,						"PLDialogSurvivalist.dds_mil_thelieutenant", 2);

	Clear(lMil_OverThere);
	AddTo(lMil_OverThere,						"PLDialogSurvivalist.dds_mil_theyreover", 1);
	AddTo(lMil_OverThere,						"PLDialogSurvivalist.dds_mil_theretheyare", 1);

	Clear(lMil_PickLeader);
	AddTo(lMil_PickLeader,						"PLDialogSurvivalist.dds_mil_someonesgotta", 1);

	Clear(lMil_NewLeader);
	AddTo(lMil_NewLeader,						"PLDialogSurvivalist.dds_mil_alrightilldoit", 1);
	AddTo(lMil_NewLeader,						"PLDialogSurvivalist.dds_mil_okaythatwould", 1);

	Clear(lMil_Commands);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_takethepoint", 1);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_coverourasses", 1);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_watchoutflank", 1);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_combtheperi", 2);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_takeemdown", 2);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_iwantthissit", 2);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_fireatwill", 3);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_retreat", 3);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_coverme", 3);
	AddTo(lMil_Commands,						"PLDialogSurvivalist.dds_mil_securethearea", 3);

	Clear(lMil_AcceptCommand);
	AddTo(lMil_AcceptCommand,						"PLDialogSurvivalist.dds_mil_Imonit", 1);
	AddTo(lMil_AcceptCommand,						"PLDialogSurvivalist.dds_mil_goodtogo", 1);
	AddTo(lMil_AcceptCommand,						"PLDialogSurvivalist.dds_mil_done", 1);

	Clear(lMil_FindCoward);
	AddTo(lMil_FindCoward,						"PLDialogSurvivalist.dds_mil_wevegothim", 1);
	AddTo(lMil_FindCoward,						"PLDialogSurvivalist.dds_mil_likearat", 1);
	AddTo(lMil_FindCoward,						"PLDialogSurvivalist.dds_mil_hesgoingnowhere", 2);
	AddTo(lMil_FindCoward,						"PLDialogSurvivalist.dds_mil_nowhereleftto", 2);

	Clear(lMil_RoomSecure);
	AddTo(lMil_RoomSecure,						"PLDialogSurvivalist.dds_mil_secure", 1);
	AddTo(lMil_RoomSecure,						"PLDialogSurvivalist.dds_mil_roomsclear", 1);
	AddTo(lMil_RoomSecure,						"PLDialogSurvivalist.dds_mil_allclear", 2);

	Clear(lMil_BystanderHelp);
	AddTo(lMil_BystanderHelp,						"PLDialogSurvivalist.dds_mil_heyhelpusout", 1);

	Clear(lSneezing);
	AddTo(lSneezing, "PLDialogSurvivalist.DoomSneezing01", 1);
	AddTo(lSneezing, "PLDialogSurvivalist.DoomSneezing02", 1);
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
     TestModeClasses(13)="BasePeople.DialogFanatic"
     TestModeClasses(14)="BasePeople.DialogFemaleAlt"
     TestModeClasses(15)="BasePeople.DialogFemaleBlack"
     TestModeClasses(16)="BasePeople.DialogFemaleMex"
     TestModeClasses(17)="BasePeople.DialogGay"
     TestModeClasses(18)="BasePeople.DialogMaleAlt"
     TestModeClasses(19)="BasePeople.DialogMaleBlack"
     TestModeClasses(20)="BasePeople.DialogMaleMex"
     TestModeClasses(21)="BasePeople.DialogMikeJ"
}
