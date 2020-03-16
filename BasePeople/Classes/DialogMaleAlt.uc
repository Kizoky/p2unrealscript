///////////////////////////////////////////////////////////////////////////////
// DialogAltMale
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all white males (alternate variation)
//
///////////////////////////////////////////////////////////////////////////////
class DialogMaleAlt extends DialogMale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();

	Clear(lapplauding);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_amazingv1", 1);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_amazingv2", 2);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_booyawv1", 1);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_booyawv2", 2);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_booyawv3", 3);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_gomanv1", 1);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_gomanv2", 2);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_theonev1", 1);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_theonev2", 2);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_whatimtalkinboutv1", 1);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_whatimtalkinboutv2", 2);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_wootv1", 1);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_wootv2", 2);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_wootv3", 3);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_wootv4", 4);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_wootv5", 5);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_yeahx2v1", 1);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_yeahx2v2", 2);
	AddTo(lApplauding,							"WMaleAltDialog.wm_cheer_yeahx2v3", 3);

	Clear(lgreeting);
	Addto(lgreeting,							"WMaleAltDialog.wm_greet_hellov1", 1);
	Addto(lgreeting,							"WMaleAltDialog.wm_greet_hellov2", 2);
	Addto(lgreeting,							"WMaleAltDialog.wm_greet_heyv1", 1);
	Addto(lgreeting,							"WMaleAltDialog.wm_greet_heyv2", 2);
	Addto(lgreeting,							"WMaleAltDialog.wm_greet_hiv1", 1);
	Addto(lgreeting,							"WMaleAltDialog.wm_greet_hiv2", 2);
	Addto(lgreeting,							"WMaleAltDialog.wm_greet_supv1", 1);
	Addto(lgreeting,							"WMaleAltDialog.wm_greet_supv2", 2);

	Clear(lhotgreeting);
	Addto(lhotGreeting,							"WMaleAltDialog.wm_sleez_hellov1", 1);
	Addto(lhotGreeting,							"WMaleAltDialog.wm_sleez_hellov2", 2);
	Addto(lhotGreeting,							"WMaleAltDialog.wm_sleez_heyv1", 1);
	Addto(lhotGreeting,							"WMaleAltDialog.wm_sleez_heyv2", 2);
	Addto(lhotGreeting,							"WMaleAltDialog.wm_sleez_hiv1", 1);
	Addto(lhotGreeting,							"WMaleAltDialog.wm_sleez_hiv2", 2);
	Addto(lhotGreeting,							"WMaleAltDialog.wm_sleez_supv1", 1);
	Addto(lhotGreeting,							"WMaleAltDialog.wm_sleez_supv2", 2);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,					"WMaleAltDialog.wm_greet_howareyouv1", 1);
	Addto(lGreetingquestions,					"WMaleAltDialog.wm_greet_howareyouv2", 2);
	Addto(lGreetingquestions,					"WMaleAltDialog.wm_greet_howsitgoingv1", 1);
	Addto(lGreetingquestions,					"WMaleAltDialog.wm_greet_howsitgoingv2", 2);
	Addto(lGreetingquestions,					"WMaleAltDialog.wm_greet_howyoudoinv1", 1);
	Addto(lGreetingquestions,					"WMaleAltDialog.wm_greet_howyoudoinv2", 2);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,				"WMaleAltDialog.wm_prettyhotv1", 1);
	Addto(lHotGreetingquestions,				"WMaleAltDialog.wm_prettyhotv2", 1);
	Addto(lHotGreetingquestions,				"WMaleAltDialog.wm_sleez_howareyouv1", 1);
	Addto(lHotGreetingquestions,				"WMaleAltDialog.wm_sleez_howareyouv2", 2);
	Addto(lHotGreetingquestions,				"WMaleAltDialog.wm_sleez_howsitgoingv1", 1);
	Addto(lHotGreetingquestions,				"WMaleAltDialog.wm_sleez_howsitgoingv2", 2);
	Addto(lHotGreetingquestions,				"WMaleAltDialog.wm_sleez_howyoudoinv1", 1);
	Addto(lHotGreetingquestions,				"WMaleAltDialog.wm_sleez_howyoudoinv2", 2);

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,				"WMaleAltDialog.wm_doiknowyouv1", 1);
	Addto(lrespondtohotgreeting,				"WMaleAltDialog.wm_doiknowyouv2", 2);
	Addto(lrespondtohotgreeting,				"WMaleAltDialog.wm_negative_goawayv1", 1);
	Addto(lrespondtohotgreeting,				"WMaleAltDialog.wm_negative_goawayv2", 2);
	Addto(lrespondtohotgreeting,				"WMaleAltDialog.wm_negative_notinterestedv1", 1);
	Addto(lrespondtohotgreeting,				"WMaleAltDialog.wm_negative_notinterestedv2", 2);
	Addto(lrespondtohotgreeting,				"WMaleAltDialog.wm_ughv1", 1);
	Addto(lrespondtohotgreeting,				"WMaleAltDialog.wm_ughv2", 2);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_beenbetterv1", 1);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_beenbetterv2", 1);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_doiknowyouv1", 1);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_doiknowyouv2", 2);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_doinprettygoodv1", 1);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_doinprettygoodv2", 2);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_finethanksv1", 1);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_finethanksv2", 2);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_grandmawcamedownv1", 1);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_grandmawcamedownv2", 2);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_ohokayiguessv1", 1);
	Addto(lrespondtogreeting,					"WMaleAltDialog.wm_ohokayiguessv2", 2);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_gladtohearitv1", 1);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_gladtohearitv2", 2);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_imsorryv1", 1);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_imsorryv2", 2);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_itsallgoodv1", 1);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_itsallgoodv2", 2);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_noproblemv1", 1);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_noproblemv2", 2);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_noworriesv1", 1);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_noworriesv2", 2);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_ohhowawfulv1", 1);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_ohhowawfulv2", 2);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_welltakecarev1", 1);
	Addto(lrespondtogreetingresponse,			"WMaleAltDialog.wm_welltakecarev2", 2);

	Clear(lHelloCop);
	Addto(lHelloCop,								"WMaleAltDialog.wm_isanythingwrongv1", 1);
	Addto(lHelloCop,								"WMaleAltDialog.wm_isanythingwrongv2", 2);
	Addto(lHelloCop,								"WMaleAltDialog.wm_whatseemstobethev1", 1);
	Addto(lHelloCop,								"WMaleAltDialog.wm_whatseemstobethev2", 2);
	
	//Clear(lHelloGimp);
	//Addto(lHelloGimp,							"", 1);

	Clear(lApologize);
	Addto(lApologize,							"WMaleAltDialog.wm_imsorryv1", 1);
	Addto(lApologize,							"WMaleAltDialog.wm_imsorryv2", 2);

	Clear(lyourewelcome);
	Addto(lyourewelcome,						"WMaleAltDialog.wm_yourewelcomev1", 1);
	Addto(lyourewelcome,						"WMaleAltDialog.wm_yourewelcomev2", 2);

	Clear(lno);
	Addto(lno,									"WMaleAltDialog.wm_negative_absolutelynotv1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_absolutelynotv2", 2);
	Addto(lno,									"WMaleAltDialog.wm_negative_asifv1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_asifv2", 2);
	Addto(lno,									"WMaleAltDialog.wm_negative_fuckthatv1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_fuckthatv2", 2);
	Addto(lno,									"WMaleAltDialog.wm_negative_idontthinksov1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_idontthinksov2", 2);
	Addto(lno,									"WMaleAltDialog.wm_negative_nopev1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_nopev2", 2);
	Addto(lno,									"WMaleAltDialog.wm_negative_nothanksv1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_nothanksv2", 2);
	Addto(lno,									"WMaleAltDialog.wm_negative_notinterestedv1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_notinterestedv2", 2);
	Addto(lno,									"WMaleAltDialog.wm_negative_notv1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_notv2", 2);
	Addto(lno,									"WMaleAltDialog.wm_negative_nov1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_nov2", 2);
	Addto(lno,									"WMaleAltDialog.wm_negative_sorryv1", 1);
	Addto(lno,									"WMaleAltDialog.wm_negative_sorryv2", 2);

	Clear(lyes);
	Addto(lyes,									"WMaleAltDialog.wm_positive_probablyv1", 1);
	Addto(lyes,									"WMaleAltDialog.wm_positive_probablyv2", 2);
	Addto(lyes,									"WMaleAltDialog.wm_positive_surev1", 1);
	Addto(lyes,									"WMaleAltDialog.wm_positive_surev2", 2);
	Addto(lyes,									"WMaleAltDialog.wm_positive_uhhunhv1", 1);
	Addto(lyes,									"WMaleAltDialog.wm_positive_uhhunhv2", 2);
	Addto(lyes,									"WMaleAltDialog.wm_positive_yeahv1", 1);
	Addto(lyes,									"WMaleAltDialog.wm_positive_yeahv2", 2);
	Addto(lyes,									"WMaleAltDialog.wm_positive_yesv1", 1);
	Addto(lyes,									"WMaleAltDialog.wm_positive_yesv2", 2);
	Addto(lyes,									"WMaleAltDialog.wm_positive_yupv1", 1);
	Addto(lyes,									"WMaleAltDialog.wm_positive_yupv2", 2);

	Clear(lthanks);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_greatv1", 1);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_greatv2", 2);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_kickassv1", 1);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_kickassv2", 2);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_sweetv1", 1);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_sweetv2", 2);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_thanksv1", 1);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_thanksv2", 2);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_thatrocksv1", 1);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_thatrocksv2", 2);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_yourulev1", 1);
	Addto(lthanks,								"WMaleAltDialog.wm_positive_yourulev2", 2);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"WMaleAltDialog.wm_positive_greatv1", 1);
	Addto(lThatsGreat,							"WMaleAltDialog.wm_positive_greatv2", 2);
	Addto(lThatsGreat,							"WMaleAltDialog.wm_positive_kickassv1", 1);
	Addto(lThatsGreat,							"WMaleAltDialog.wm_positive_kickassv2", 2);
	Addto(lThatsGreat,							"WMaleAltDialog.wm_positive_sweetv1", 1);
	Addto(lThatsGreat,							"WMaleAltDialog.wm_positive_sweetv2", 2);
	Addto(lThatsGreat,							"WMaleAltDialog.wm_positive_thatrocksv1", 1);
	Addto(lThatsGreat,							"WMaleAltDialog.wm_positive_thatrocksv2", 2);

	Clear(lGetDown);
	AddTo(lGetDown,								"WMaleAltDialog.wm_shotblocked2v1", 1);
	AddTo(lGetDown,								"WMaleAltDialog.wm_shotblocked2v2", 2);
	AddTo(lGetDown,								"WMaleAltDialog.wm_shotblocked4v1", 1);
	AddTo(lGetDown,								"WMaleAltDialog.wm_shotblocked4v2", 2);

	Clear(lGetDownMP);
	AddTo(lGetDownMP,							"WMaleAltDialog.wm_shotblocked2v1", 1);
	AddTo(lGetDownMP,							"WMaleAltDialog.wm_shotblocked2v2", 2);
	AddTo(lGetDownMP,							"WMaleAltDialog.wm_shotblocked4v1", 1);
	AddTo(lGetDownMP,							"WMaleAltDialog.wm_shotblocked4v2", 2);

	Clear(lCussing);
	Addto(lCussing,								"WMaleAltDialog.wm_damage_shitv1", 1);
	Addto(lCussing,								"WMaleAltDialog.wm_damage_shitv2", 2);
	Addto(lCussing,								"WMaleAltDialog.wm_damage_fuckv1", 1);
	Addto(lCussing,								"WMaleAltDialog.wm_damage_fuckv2", 2);
	Addto(lCussing,								"WMaleAltDialog.wm_damage_christv1", 1);
	Addto(lCussing,								"WMaleAltDialog.wm_damage_christv2", 2);
	Addto(lCussing,								"WMaleAltDialog.wm_damage_christv3", 3);
	Addto(lCussing,								"WMaleAltDialog.wm_pissedon_christv1", 4);
	Addto(lCussing,								"WMaleAltDialog.wm_pissedon_christv2", 5);

	//Clear(lgetdownscared);
	//Addto(lgetdownscared,						"", 1);

	Clear(ldefiant);
	Addto(ldefiant,								"WMaleAltDialog.wm_bully_whatyoulookingatv1", 1);
	Addto(ldefiant,								"WMaleAltDialog.wm_bully_whatyoulookingatv2", 2);
	//Addto(ldefiant,								"WMaleAltDialog.wm_bully_yougonnadiev1", 1);
	//Addto(ldefiant,								"WMaleAltDialog.wm_bully_yougonnadiev2", 1);
	Addto(ldefiant,								"WMaleAltDialog.wm_bully_yougotaproblemv1", 1);
	Addto(ldefiant,								"WMaleAltDialog.wm_bully_yougotaproblemv2", 2);

	Clear(ldefiantline);
	Addto(ldefiantline,								"WMaleAltDialog.wm_bully_whatyoulookingatv1", 1);
	Addto(ldefiantline,								"WMaleAltDialog.wm_bully_whatyoulookingatv2", 2);
	//Addto(ldefiantline,								"WMaleAltDialog.wm_bully_yougonnadiev1", 1);
	//Addto(ldefiantline,								"WMaleAltDialog.wm_bully_yougonnadiev2", 1);
	Addto(ldefiantline,								"WMaleAltDialog.wm_bully_yougotaproblemv1", 1);
	Addto(ldefiantline,								"WMaleAltDialog.wm_bully_yougotaproblemv2", 2);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"WMaleAltDialog.wm_pissedon_christv1", 1);
	Addto(lCloseToWeapon,						"WMaleAltDialog.wm_pissedon_christv2", 2);
	Addto(lCloseToWeapon,						"WMaleAltDialog.wm_seecarnage_holyfuckv1", 1);
	Addto(lCloseToWeapon,						"WMaleAltDialog.wm_seecarnage_holyfuckv2", 2);
	Addto(lCloseToWeapon,						"WMaleAltDialog.wm_seecarnage_holyshitv1", 1);
	Addto(lCloseToWeapon,						"WMaleAltDialog.wm_seecarnage_holyshitv2", 2);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"WMaleAltDialog.wm_riot_1v1", 1);
	Addto(ldecidetofight,						"WMaleAltDialog.wm_riot_1v2", 2);
	Addto(ldecidetofight,						"WMaleAltDialog.wm_riot_2v1", 1);
	Addto(ldecidetofight,						"WMaleAltDialog.wm_riot_2v2", 2);
	Addto(ldecidetofight,						"WMaleAltDialog.wm_riot_3v1", 1);
	Addto(ldecidetofight,						"WMaleAltDialog.wm_riot_3v2", 2);
	Addto(ldecidetofight,						"WMaleAltDialog.wm_riot_4v1", 1);
	Addto(ldecidetofight,						"WMaleAltDialog.wm_riot_4v2", 2);

	Clear(llaughing);
	Addto(llaughing,							"WMaleAltDialog.wm_laughv1", 1);
	Addto(llaughing,							"WMaleAltDialog.wm_laughv2", 1);

	Clear(lSnickering);
	Addto(lSnickering,							"WMaleAltDialog.wm_snickerv1", 1);
	Addto(lSnickering,							"WMaleAltDialog.wm_snickerv2", 1);

	//Clear(lOutOfBreath);
	//Addto(lOutOfBreath,							"", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_followup_areyouoncrackv1", 1);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_followup_areyouoncrackv2", 2);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_followup_iseeyourecrazyv1", 1);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_followup_iseeyourecrazyv2", 2);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_deadtaunt_freakv1", 1);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_deadtaunt_freakv2", 2);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_seepanic_1v1", 1);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_seepanic_1v2", 2);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_seepanic_2v1", 1);
	Addto(lWatchingCrazy,						"WMaleAltDialog.wm_seepanic_2v2", 2);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_getcop_helppolicev1", 1);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_getcop_helppolicev2", 2);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_getcop_policex2v1", 1);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_getcop_policex2v2", 2);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_gunfightv1", 1);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_gunfightv2", 2);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_heargunfirev1", 1);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_heargunfirev2", 2);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_idiotisfiringv1", 1);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_idiotisfiringv2", 2);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_shootingovertherev1", 1);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_shootingovertherev2", 2);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_thoseweregunshotsv1", 1);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_heargun_thoseweregunshotsv2", 2);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_seecarnage_getthatguyv1", 1);
	Addto(lshootingoverthere,					"WMaleAltDialog.wm_seecarnage_getthatguyv2", 2);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,					"WMaleAltDialog.wm_getcop_helppolicev1", 1);
	Addto(lkillingoverthere,					"WMaleAltDialog.wm_getcop_helppolicev2", 2);
	Addto(lkillingoverthere,					"WMaleAltDialog.wm_getcop_policex2v1", 1);
	Addto(lkillingoverthere,					"WMaleAltDialog.wm_getcop_policex2v2", 2);
	Addto(lkillingoverthere,					"WMaleAltDialog.wm_seecarnage_getthatguyv1", 1);
	Addto(lkillingoverthere,					"WMaleAltDialog.wm_seecarnage_getthatguyv2", 2);
	Addto(lkillingoverthere,					"WMaleAltDialog.wm_seecarnage_someguyskillingv1", 1);
	Addto(lkillingoverthere,					"WMaleAltDialog.wm_seecarnage_someguyskillingv2", 2);
	
	Clear(lscreaming);
	Addto(lscreaming,							"WMaleAltDialog.wm_scream1", 1);
	Addto(lscreaming,							"WMaleAltDialog.wm_scream2", 1);
	Addto(lscreaming,							"WMaleAltDialog.wm_scream3", 1);
	Addto(lscreaming,							"WMaleAltDialog.wm_scream4", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_awghelpmev1", 1);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_awghelpmev2", 2);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_babyjesusv1", 1);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_babyjesusv2", 2);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_fiyaaav1", 1);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_fiyaaav2", 2);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_imburningv1", 1);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_imburningv2", 2);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_putmeoutv1", 1);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_putmeoutv2", 2);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_yeaghv1", 1);
	Addto(lscreamingonfire,						"WMaleAltDialog.wm_onfire_yeaghv2", 2);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_bringitv1", 1);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_bringitv2", 2);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_howaboutsomeofthisv1", 1);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_howaboutsomeofthisv2", 2);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_rahv1", 1);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_rahv2", 2);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_tryandstopmev1", 1);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_tryandstopmev2", 2);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_youthinkimscaredv1", 1);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_youthinkimscaredv2", 2);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_youthinkthatcanv1", 1);
	Addto(lDoHeroics,							"WMaleAltDialog.wm_tough_youthinkthatcanv2", 2);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"WMaleAltDialog.wm_spitoutpissv1", 1);
	Addto(lgettingpissedon,						"WMaleAltDialog.wm_spitoutpissv2", 1);
	Addto(lgettingpissedon,						"WMaleAltDialog.wm_spitoutpissv3", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_assholev1", 1);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_assholev2", 2);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_christv1", 1);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_christv2", 2);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_disgustingv1", 1);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_disgustingv2", 2);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_eughv1", 1);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_eughv2", 2);
	//Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_likeditv1", 1);
	//Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_likeditv2", 2);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_myshirtv1", 1);
	Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_myshirtv2", 2);
	//Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_wayoflifev1", 1);
	//Addto(laftergettingpissedon,				"WMaleAltDialog.wm_pissedon_wayoflifev2", 2);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"WMaleAltDialog.wm_huhv1", 1);
	Addto(lwhatthe,								"WMaleAltDialog.wm_huhv2", 2);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_heeyv1", 1);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_heeyv2", 2);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_whatthev1", 1);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_whatthev2", 2);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_whatthev3", 3);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_whatthev4", 4);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_whuhv1", 1);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_whuhv2", 2);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_whuhv3", 3);
	Addto(lwhatthe,								"WMaleAltDialog.wm_pissedon_whuhv4", 4);

	Clear(lseeingpisser);
	Addto(lseeingpisser,						"WMaleAltDialog.wm_seepissing1v1", 1);
	Addto(lseeingpisser,						"WMaleAltDialog.wm_seepissing1v2", 2);
	Addto(lseeingpisser,						"WMaleAltDialog.wm_seepissing1v3", 3);
	Addto(lseeingpisser,						"WMaleAltDialog.wm_seepissing2v1", 1);
	Addto(lseeingpisser,						"WMaleAltDialog.wm_seepissing2v2", 2);
	Addto(lseeingpisser,						"WMaleAltDialog.wm_seepissing3v1", 1);
	Addto(lseeingpisser,						"WMaleAltDialog.wm_seepissing3v2", 2);
	Addto(lseeingpisser,						"WMaleAltDialog.wm_seepissing4v1", 1);
	Addto(lseeingpisser,						"WMaleAltDialog.wm_seepissing4v2", 2);

	//Clear(lSomethingIsGross);
	//Addto(lSomethingIsGross,					"", 1);

	Clear(lgothit);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_aghkv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_aghkv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_aiieev1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_aiieev2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_akv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_akv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_akv3", 3);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_arghv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_arghv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_aughv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_aughv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_badtouchv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_badtouchv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_christv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_christv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_christv3", 3);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_fuckv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_fuckv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_gakv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_gakv2", 2);
	//Addto(lgothit,								"WMaleAltDialog.wm_damage_mandownv1", 1);
	//Addto(lgothit,								"WMaleAltDialog.wm_damage_mandownv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_mommyv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_mommyv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_mommyv3", 3);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_myspinev1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_myspinev2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_owv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_owv2", 2);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_shitv1", 1);
	Addto(lgothit,								"WMaleAltDialog.wm_damage_shitv2", 2);

	Clear(lAttacked);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_aghkv1", 1);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_aghkv2", 2);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_akv1", 1);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_akv2", 2);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_akv3", 3);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_arghv1", 1);	
	addto(lAttacked,							"WMaleAltDialog.wm_damage_arghv2", 2);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_aughv1", 1);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_aughv2", 2);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_gakv1", 1);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_gakv2", 2);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_shitv1", 1);
	addto(lAttacked,							"WMaleAltDialog.wm_damage_shitv2", 2);

	Clear(lGrunt);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_aghkv1", 1);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_aghkv2", 2);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_akv1", 1);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_akv2", 2);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_akv3", 3);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_arghv1", 1);	
	addto(lGrunt,								"WMaleAltDialog.wm_damage_arghv2", 2);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_aughv1", 1);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_aughv2", 2);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_gakv1", 1);
	addto(lGrunt,								"WMaleAltDialog.wm_damage_gakv2", 2);

	Clear(lPissing);
	Addto(lPissing,								"WMaleAltDialog.wm_pissing_ohyeahv1", 1);
	Addto(lPissing,								"WMaleAltDialog.wm_pissing_ohyeahv2", 2);
	Addto(lPissing,								"WMaleAltDialog.wm_pissing_ownbeerv1", 1);
	Addto(lPissing,								"WMaleAltDialog.wm_pissing_ownbeerv2", 2);
	Addto(lPissing,								"WMaleAltDialog.wm_pissing_talkinboutv1", 1);
	Addto(lPissing,								"WMaleAltDialog.wm_pissing_talkinboutv2", 2);

	//Clear(lPissOnSelf);
	//Addto(lPissOnSelf,							"", 2);
	
	//Clear(lPissOutFireOnSelf);
	//Addto(lPissOutFireOnSelf,					"", 1);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,				"WeaponSounds.sniper_zoombreathing", 1);

	//Clear(lGotHealth);
	//Addto(lGotHealth,							"", 1);

	//Clear(lGotHealthFood);
	//Addto(lGotHealthFood,						"", 1);

	//Clear(lGotCrackHealth);
	//Addto(lGotCrackHealth,						"", 1);

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_aghkv1", 1);
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_aghkv2", 2);
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_akv1", 1);
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_akv2", 2);
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_akv3", 3);
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_arghv1", 1);	
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_arghv2", 2);
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_aughv1", 1);
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_aughv2", 2);
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_gakv1", 1);
	addto(lGotHitInCrotch,						"WMaleAltDialog.wm_damage_gakv2", 2);

	Clear(lbegforlife);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_crying1", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_crying2", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_crying3", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_crying4", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_cryingv1", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_cryingv2", 2);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_dontkillvirginv1", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_dontkillvirginv2", 2);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_pleasedontkillmev1", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_pleasedontkillmev2", 2);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_pleasepleasenov1", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_snivel1", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_snivel2", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_sparemylifekidsv1", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_beg_sparemylifekidsv2", 2);
	Addto(lbegforlife,							"WMaleAltDialog.wm_fearful_donthurtmev1", 1);
	Addto(lbegforlife,							"WMaleAltDialog.wm_fearful_donthurtmev2", 2);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_crying1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_crying2", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_crying3", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_crying4", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_cryingv1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_cryingv2", 2);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_dontkillvirginv1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_dontkillvirginv2", 2);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_pleasedontkillmev1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_pleasedontkillmev2", 2);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_pleasepleasenov1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_snivel1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_snivel2", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_sparemylifekidsv1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_sparemylifekidsv2", 2);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_sparemylifekidsv1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_dontkillminorityv1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_beg_dontkillminorityv2", 2);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_fearful_donthurtmev1", 1);
	Addto(lbegforlifeMin,						"WMaleAltDialog.wm_fearful_donthurtmev2", 2);
	
	//Clear(ldying);
	//Addto(ldying,								"", 1);

	Clear(lCrying);
	Addto(lCrying,								"WMaleAltDialog.wm_beg_crying1", 1);
	Addto(lCrying,								"WMaleAltDialog.wm_beg_crying2", 1);
	Addto(lCrying,								"WMaleAltDialog.wm_beg_crying3", 1);
	Addto(lCrying,								"WMaleAltDialog.wm_beg_crying4", 1);
	Addto(lCrying,								"WMaleAltDialog.wm_beg_cryingv1", 1);
	Addto(lCrying,								"WMaleAltDialog.wm_beg_cryingv2", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,					"WMaleAltDialog.wm_beg_didntmeanitv1", 1);	
	Addto(lfrightenedapology,					"WMaleAltDialog.wm_beg_didntmeanitv2", 1);	
	Addto(lfrightenedapology,					"WMaleAltDialog.wm_beg_neveragainv1", 1);	
	Addto(lfrightenedapology,					"WMaleAltDialog.wm_beg_neveragainv2", 1);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"WMaleAltDialog.wm_taunt_cmonfightlikeamanv1", 1);
	Addto(ltrashtalk,							"WMaleAltDialog.wm_taunt_cmonfightlikeamanv2", 2);
	Addto(ltrashtalk,							"WMaleAltDialog.wm_taunt_ohyeahbigmanwithav1", 1);
	Addto(ltrashtalk,							"WMaleAltDialog.wm_taunt_ohyeahbigmanwithav2", 2);
	Addto(ltrashtalk,							"WMaleAltDialog.wm_taunt_whereyougoingsissyv1", 1);
	Addto(ltrashtalk,							"WMaleAltDialog.wm_taunt_whereyougoingsissyv2", 2);
	Addto(ltrashtalk,							"WMaleAltDialog.wm_taunt_yourenotsotoughv1", 1);
	Addto(ltrashtalk,							"WMaleAltDialog.wm_taunt_yourenotsotoughv2", 2);

	Clear(lWhileFighting);
	Addto(lWhileFighting,						"WMaleAltDialog.wm_taunt_cmonfightlikeamanv1", 1);
	Addto(lWhileFighting,						"WMaleAltDialog.wm_taunt_cmonfightlikeamanv2", 2);
	Addto(lWhileFighting,						"WMaleAltDialog.wm_taunt_ohyeahbigmanwithav1", 1);
	Addto(lWhileFighting,						"WMaleAltDialog.wm_taunt_ohyeahbigmanwithav2", 2);
	Addto(lWhileFighting,						"WMaleAltDialog.wm_taunt_whereyougoingsissyv1", 1);
	Addto(lWhileFighting,						"WMaleAltDialog.wm_taunt_whereyougoingsissyv2", 2);
	Addto(lWhileFighting,						"WMaleAltDialog.wm_taunt_yourenotsotoughv1", 1);
	Addto(lWhileFighting,						"WMaleAltDialog.wm_taunt_yourenotsotoughv2", 2);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,						"WMaleAltDialog.wm_whatseemstobethev1", 1);
	Addto(laskcopwhatsup,						"WMaleAltDialog.wm_whatseemstobethev2", 2);

	Clear(lratout);
	Addto(lratout,								"WMaleAltDialog.wm_report_hediditv1", 1);
	Addto(lratout,								"WMaleAltDialog.wm_report_hediditv2", 2);
	Addto(lratout,								"WMaleAltDialog.wm_report_hestheonev1", 1);
	Addto(lratout,								"WMaleAltDialog.wm_report_hestheonev2", 2);
	Addto(lratout,								"WMaleAltDialog.wm_report_itwashimv1", 1);
	Addto(lratout,								"WMaleAltDialog.wm_report_itwashimv2", 2);
	Addto(lratout,								"WMaleAltDialog.wm_report_thatguyovertherev1", 1);
	Addto(lratout,								"WMaleAltDialog.wm_report_thatguyovertherev2", 2);
	Addto(lratout,								"WMaleAltDialog.wm_report_thatguyv1", 1);
	Addto(lratout,								"WMaleAltDialog.wm_report_thatguyv2", 2);

	Clear(lfakeratout);
	Addto(lfakeratout,							"WMaleAltDialog.wm_lying_hediditisawv1", 1);
	Addto(lfakeratout,							"WMaleAltDialog.wm_lying_hediditisawv2", 2);
	Addto(lfakeratout,							"WMaleAltDialog.wm_lying_imawitnessv1", 1);
	Addto(lfakeratout,							"WMaleAltDialog.wm_lying_imawitnessv2", 2);

	Clear(lcleanshot);
	Addto(lcleanshot,							"WMaleAltDialog.wm_shotblocked1v1", 1);
	Addto(lcleanshot,							"WMaleAltDialog.wm_shotblocked1v2", 2);
	Addto(lcleanshot,							"WMaleAltDialog.wm_shotblocked3v1", 1);
	Addto(lcleanshot,							"WMaleAltDialog.wm_shotblocked3v2", 2);
	Addto(lcleanshot,							"WMaleAltDialog.wm_shotblocked4v1", 1);
	Addto(lcleanshot,							"WMaleAltDialog.wm_shotblocked4v2", 2);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"WMaleAltDialog.wm_shotblocked3v1", 1);
	Addto(lCleanMeleeHit,						"WMaleAltDialog.wm_shotblocked3v2", 2);
	Addto(lCleanMeleeHit,						"WMaleAltDialog.wm_shotblocked4v1", 1);
	Addto(lCleanMeleeHit,						"WMaleAltDialog.wm_shotblocked4v2", 2);

	Clear(lInhale);
	Addto(lInhale,								"WMaleDialog.wm_inhale", 1);
												
	Clear(lExhale);								
	Addto(lExhale,								"WMaleDialog.wm_exhale", 1);
	
	//Clear(lEatingFood);
	//Addto(lEatingFood,							"", 1);

	//Clear(lAfterEating);
	//Addto(lAfterEating,							"", 1);

	//Clear(lpleasureresponse);					
	//Addto(lpleasureresponse,					"", 1);

	//Clear(laftersitdown);
	//Addto(laftersitdown,						"", 1);

	//Clear(lSpitting);
	//Addto(lSpitting,							"", 1);
	
	Clear(lhmm);
	Addto(lhmm,									"WMaleAltDialog.wm_hmmmmv1", 1);
	Addto(lhmm,									"WMaleAltDialog.wm_hmmmmv2", 1);

	//Clear(lfollowme);
	//Addto(lfollowme,							"", 1);	

	//Clear(lStayHere);
	//Addto(lStayHere,							"", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_heybuddyyourbarnv1", 1);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_heybuddyyourbarnv2", 2);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_noonesimpressedv1", 1);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_noonesimpressedv2", 2);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_pullyourpantsupv1", 1);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_pullyourpantsupv2", 2);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_whyyourschwartzv1", 1);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_whyyourschwartzv2", 2);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_xyzv1", 1);
	Addto(lnoticedickout,						"WMaleAltDialog.wm_seewang_xyzv2", 2);

	//Clear(lilltakenumber);
	//Addto(lilltakenumber,						"", 1);

	//Clear(lmakedeposit);
	//Addto(lmakedeposit,							"", 1);

	//Clear(lmakewithdrawal);
	//Addto(lmakewithdrawal,						"", 1);

	//Clear(lconsumerbuy);
	//Addto(lconsumerbuy,							"", 1);

	//Clear(lconteststoretransaction);
	//Addto(lconteststoretransaction,				"", 1);
	
	//Clear(lcontestbanktransaction);
	//Addto(lcontestbanktransaction,				"", 1);

	Clear(lGoPostal);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_forgivemev1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_forgivemev2", 2);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_godsaiditsv1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_godsaiditsv2", 2);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_goodbookv1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_goodbookv2", 2);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_howaboutwev1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_howaboutwev2", 2);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_ifonemorev1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_ifonemorev2", 2);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_illusethisv1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_illusethisv2", 2);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_imsorryv1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_imsorryv2", 2);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_motherneverlovedv1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_motherneverlovedv2", 2);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_stayawayv1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_stayawayv2", 2);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_youdontwannaseev1", 1);
	Addto(lGoPostal,							"WMaleAltDialog.wm_postal_youdontwannaseev2", 2);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_fearful_isnthappeningv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_fearful_isnthappeningv2", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_fearful_shitgetoutv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_fearful_shitgetoutv2", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_ghaspv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_ghaspv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_ghaspv3", 3);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_ambulancev1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_ambulancev2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_anyoneseethatv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_anyoneseethatv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_apocolypsev1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_apocolypsev2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_callcnnv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_callthearmyv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_callthearmyv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_cantbelievehedidv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_cantbelievehedidv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_cantbelievethisv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_cantbelievethisv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_goingtovomitv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_goingtovomitv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_helpv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_helpv2", 2);
	//Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_hesgotagunv1", 1);
	//Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_hesgotagunv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_holyfuckv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_holyfuckv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_holyshitv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_holyshitv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_jesushelpv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_jesushelpv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_killedthatguyv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_killedthatguyv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_killingeveryonev1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_killingeveryonev2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_makeitstopv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_makeitstopv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_needtherapyv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_needtherapyv2", 2);
	//Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_niceparticlesv1", 1);
	//Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_niceparticlesv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_nightmarev1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_nightmarev2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_ohmygodv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_ohmygodv2", 2);
	//Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_outtaherev1", 1);
	//Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_outtaherev2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_runrunv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_runrunv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_sooftenv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_sooftenv2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_sweetlordnov1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_sweetlordnov2", 2);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_thehorrorv1", 1);
	Addto(lcarnageoccurred,						"WMaleAltDialog.wm_seecarnage_thehorrorv2", 2);

	Clear(lCallCat);
	Addto(lCallCat, 							"WMaleAltDialog.wm_likescat_awkittyv1", 1);
	Addto(lCallCat, 							"WMaleAltDialog.wm_likescat_awkittyv2", 2);
	Addto(lCallCat, 							"WMaleAltDialog.wm_likescat_herekittyv1", 1);
	Addto(lCallCat, 							"WMaleAltDialog.wm_likescat_herekittyv2", 2);
	Addto(lCallCat, 							"WMaleAltDialog.wm_likescat_herekittyv3", 3);

	Clear(lHateCat);
	Addto(lHateCat, 							"WMaleAltDialog.wm_hatescat_getoutfurballv1", 1);
	Addto(lHateCat, 							"WMaleAltDialog.wm_hatescat_getoutfurballv2", 2);
	Addto(lHateCat, 							"WMaleAltDialog.wm_hatescat_goddamcatv1", 1);
	Addto(lHateCat, 							"WMaleAltDialog.wm_hatescat_goddamcatv2", 2);
	Addto(lHateCat, 							"WMaleAltDialog.wm_hatescat_herekittyevilv1", 1);
	Addto(lHateCat, 							"WMaleAltDialog.wm_hatescat_herekittyevilv2", 2);

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"WMaleAltDialog.wm_damage_shitv1", 1);
	Addto(lStartAttackingAnimal,				"WMaleAltDialog.wm_damage_shitv2", 2);
	Addto(lStartAttackingAnimal,				"WMaleAltDialog.wm_damage_fuckv1", 1);
	Addto(lStartAttackingAnimal,				"WMaleAltDialog.wm_damage_fuckv2", 2);
	Addto(lStartAttackingAnimal,				"WMaleAltDialog.wm_damage_christv1", 1);
	Addto(lStartAttackingAnimal,				"WMaleAltDialog.wm_damage_christv2", 2);
	Addto(lStartAttackingAnimal,				"WMaleAltDialog.wm_damage_christv3", 3);
	Addto(lStartAttackingAnimal,				"WMaleAltDialog.wm_pissedon_christv1", 4);
	Addto(lStartAttackingAnimal,				"WMaleAltDialog.wm_pissedon_christv2", 5);

	//Clear(lGettingRobbed);	
	//Addto(lGettingRobbed,						"", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"WMaleAltDialog.wm_fearful_donthurtmev1", 1);
	Addto(lGettingMugged,						"WMaleAltDialog.wm_fearful_donthurtmev2", 2);
	Addto(lGettingMugged,						"WMaleAltDialog.wm_ghaspv1", 1);
	Addto(lGettingMugged,						"WMaleAltDialog.wm_ghaspv2", 1);
	Addto(lGettingMugged,						"WMaleAltDialog.wm_ghaspv3", 1);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"WMaleAltDialog.wm_getcop_callacopv1", 1);
	Addto(lAfterMugged,							"WMaleAltDialog.wm_getcop_callacopv2", 2);
	Addto(lAfterMugged,							"WMaleAltDialog.wm_getcop_helppolicev1", 1);
	Addto(lAfterMugged,							"WMaleAltDialog.wm_getcop_helppolicev2", 2);
	Addto(lAfterMugged,							"WMaleAltDialog.wm_getcop_policex2v1", 1);
	Addto(lAfterMugged,							"WMaleAltDialog.wm_getcop_policex2v2", 2);

	//Clear(lDoMugging);	
	//Addto(lDoMugging,							"", 3);
	
	Clear(lQuestion);	
	Addto(lQuestion,							"WMaleAltDialog.wm_question_whatareyoutalkingv1", 1);
	Addto(lQuestion,							"WMaleAltDialog.wm_question_whatareyoutalkingv2", 2);
	Addto(lQuestion,							"WMaleAltDialog.wm_question_whatv1", 1);
	Addto(lQuestion,							"WMaleAltDialog.wm_question_whatv2", 2);
	Addto(lQuestion,							"WMaleAltDialog.wm_question_whyv1", 1);
	Addto(lQuestion,							"WMaleAltDialog.wm_question_whyv2", 2);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_marmosetsv1", 1);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_marmosetsv2", 2);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_tvshowv1", 1);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_tvshowv2", 2);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_videogamesv1", 1);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_videogamesv2", 2);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_whattimev1", 1);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_whattimev2", 2);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_whatwereyoudoingv1", 1);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_whatwereyoudoingv2", 2);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_whereslunchv1", 1);
	Addto(lGenericQuestion,						"WMaleAltDialog.wm_call_whereslunchv2", 2);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_disinterest_boringv1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_disinterest_boringv2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_disinterest_dontcarev1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_disinterest_dontcarev2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_disinterest_mehv1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_disinterest_mehv2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_question_idontcarev1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_question_idontcarev2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_candidcamerav1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_candidcamerav2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_climbthaybuildingv1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_climbthaybuildingv2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_iforgetv1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_iforgetv2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_ineedadrinkv1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_ineedadrinkv2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_maltliquaav1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_maltliquaav2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_upyourassv1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_upyourassv2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_whatisabbav1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_whenyouretalkingv1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_whenyouretalkingv2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_williwinaprizev1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_williwinaprizev2", 2);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_youkeeptalkingv1", 1);
	Addto(lGenericAnswer,						"WMaleAltDialog.wm_response_youkeeptalkingv2", 2);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_areyouevenlisteningv1", 1);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_areyouevenlisteningv2", 2);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_areyouoncrackv1", 1);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_areyouoncrackv2", 2);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_geezstopdoingthatv1", 1);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_geezstopdoingthatv2", 2);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_iseeyourecrazyv1", 1);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_iseeyourecrazyv2", 2);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_listenjusttellmev1", 1);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_listenjusttellmev2", 2);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_whatv1", 1);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_whatv2", 2);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_yourenotreallyv1", 1);
	Addto(lGenericFollowup,						"WMaleAltDialog.wm_followup_yourenotreallyv2", 2);

	Clear(lGenericGoodbye);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_confusednowv1", 1);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_confusednowv2", 2);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_greatseeingyouv1", 1);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_greatseeingyouv2", 2);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_outtaherev1", 1);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_outtaherev2", 2);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_seeyoulaterv1", 1);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_seeyoulaterv2", 2);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_stupidv1", 1);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_stupidv2", 1);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_yourecrazyv1", 1);
	Addto(lGenericGoodbye,						"WMaleAltDialog.wm_leadout_yourecrazyv2", 2);

	//Clear(linvadeshome);	
	//Addto(linvadeshome,							"", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,						"WMaleAltDialog.wm_seeonfire_allburningv1", 1);
	Addto(lsomeoneonfire,						"WMaleAltDialog.wm_seeonfire_allburningv2", 2);
	Addto(lsomeoneonfire,						"WMaleAltDialog.wm_seeonfire_dropandrollv1", 1);
	Addto(lsomeoneonfire,						"WMaleAltDialog.wm_seeonfire_dropandrollv2", 2);
	Addto(lsomeoneonfire,						"WMaleAltDialog.wm_seeonfire_everyonesonfirev1", 1);
	Addto(lsomeoneonfire,						"WMaleAltDialog.wm_seeonfire_everyonesonfirev2", 2);
	Addto(lsomeoneonfire,						"WMaleAltDialog.wm_seeonfire_ohmygodv1", 1);
	Addto(lsomeoneonfire,						"WMaleAltDialog.wm_seeonfire_ohmygodv2", 2);

	Clear(labouttopuke);
	Addto(labouttopuke,							"WMaleAltDialog.wm_pissedon_sickv1", 1);
	Addto(labouttopuke,							"WMaleAltDialog.wm_pissedon_sickv2", 2);
	Addto(labouttopuke,							"WMaleAltDialog.wm_puke_idontfeelsogoodv1", 1);
	Addto(labouttopuke,							"WMaleAltDialog.wm_puke_idontfeelsogoodv2", 2);
	Addto(labouttopuke,							"WMaleAltDialog.wm_puke_ohgodimv1", 1);
	Addto(labouttopuke,							"WMaleAltDialog.wm_puke_ohgodimv2", 2);
	Addto(labouttopuke,							"WMaleAltDialog.wm_puke_ohgodimv3", 3);
	Addto(labouttopuke,							"WMaleAltDialog.wm_puke_ohgodimv4", 4);
	Addto(labouttopuke,							"WMaleAltDialog.wm_puke_ohmanimgonnabesickv1", 1);
	Addto(labouttopuke,							"WMaleAltDialog.wm_puke_ohmanimgonnabesickv2", 2);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,						"WMaleAltDialog.wm_vomitv1", 1);
	Addto(lbodyfunctions,						"WMaleAltDialog.wm_vomitv2", 2);
	Addto(lbodyfunctions,						"WMaleAltDialog.wm_vomitv3", 3);

	//Clear(lGettingShocked);
	//Addto(lGettingShocked,						"", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,							"HabibDialog.habib_ailili", 1);

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_marmosetsv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_marmosetsv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_tvshowv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_tvshowv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_videogamesv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_videogamesv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_whattimev1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_whattimev2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_whatwereyoudoingv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_whatwereyoudoingv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_whereslunchv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_call_whereslunchv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_burningdrippingv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_burningdrippingv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_burnitoffv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_burnitoffv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_greatboredv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_greatboredv2", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_greatboredv3", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_greatboredv4", 3);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_haveyouheardv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_haveyouheardv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_krotchyebayv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_krotchyebayv2", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_nonov1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_nonov2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_okayv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_okayv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_okayv3", 3);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_stophappyv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_stophappyv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_thatsfunnyv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_thatsfunnyv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_thatsgreatv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_thatswhatithoughtv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_thatswhatithoughtv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_thestainv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_thestainv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_turnedgreenv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_turnedgreenv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_uhhuhv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_uhhuhv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_uhhuhv3", 3);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_welldidyouseeemv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_welldidyouseeemv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_yeahbuticanttellv1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_yeahbuticanttellv2", 2);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_youwouldntbelievev1", 1);
	Addto(lCellPhoneTalk,						"WMaleAltDialog.wm_cell_youwouldntbelievev2", 2);
	
	//Clear(lZealots);
	//Addto(lZealots,								"", 1);
	
	//Clear(lKrotchyCustomerComment);
	//Addto(lKrotchyCustomerComment,				"", 1);

	//Clear(lKrotchyCustomerWant);
	//Addto(lKrotchyCustomerWant,					"", 1);

	//Clear(lGaryAutograph);
	//Addto(lGaryAutograph,						"", 1);
	
	//Clear(lProtestorCut);
	//Addto(lProtestorCut,						"", 1);
	
	Clear(ldudedead);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_bethewasgayv1", 1);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_bethewasgayv2", 2);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_freakv1", 1);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_freakv2", 2);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_goddamliberalv1", 1);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_goddamliberalv2", 2);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_iftherewerenogunsv1", 1);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_iftherewerenogunsv2", 2);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_nextlifedodgev1", 1);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_nextlifedodgev2", 2);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_whatanassholev1", 1);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_whatanassholev2", 2);
	Addto(ldudedead,							"WMaleAltDialog.wm_deadtaunt_whatanassholev3", 3);

	Clear(lKickDead);
	Addto(lKickDead,							"WMaleAltDialog.wm_deadtaunt_forgotonev1", 1);
	Addto(lKickDead,							"WMaleAltDialog.wm_deadtaunt_forgotonev2", 2);
	Addto(lKickDead,							"WMaleAltDialog.wm_deadtaunt_oneformotherv1", 1);
	Addto(lKickDead,							"WMaleAltDialog.wm_deadtaunt_oneformotherv2", 2);
	Addto(lKickDead,							"WMaleAltDialog.wm_deadtaunt_takethiswithyouv1", 1);
	Addto(lKickDead,							"WMaleAltDialog.wm_deadtaunt_takethiswithyouv2", 2);

	//Clear(lNameCalling);
	//Addto(lNameCalling,							"", 1);

	Clear(lRogueCop);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seecarnage_ifihadcamerav1", 1);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seecarnage_ifihadcamerav2", 2);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seescop_abusev1", 1);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seescop_abusev2", 2);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seescop_copsinsanev1", 1);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seescop_copsinsanev2", 2);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seescop_ifihadacamerav1", 1);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seescop_ifihadacamerav2", 2);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seescop_oppressingusv1", 1);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seescop_oppressingusv2", 2);
	Addto(lRogueCop,							"WMaleAltDialog.wm_seescop_oppressingusv3", 3);

	Clear(lgetbumped);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_cominthroughv1", 1);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_cominthroughv2", 2);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_cominthroughv3", 3);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_heywatchitv1", 1);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_heywatchitv2", 2);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_lookoutv1", 1);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_lookoutv2", 2);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_onesidev1", 1);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_onesidev2", 2);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_oofidiotv1", 1);
	Addto(lgetbumped,							"WMaleAltDialog.wm_bumped_oofidiotv2", 2);

	Clear(lGetMad);
	Addto(lGetMad,								"WMaleAltDialog.wm_bumped_heywatchitv1", 1);
	Addto(lGetMad,								"WMaleAltDialog.wm_bumped_heywatchitv2", 2);
	Addto(lGetMad,								"WMaleAltDialog.wm_bumped_lookoutv1", 1);
	Addto(lGetMad,								"WMaleAltDialog.wm_bumped_lookoutv2", 2);
	Addto(lGetMad,								"WMaleAltDialog.wm_bumped_oofidiotv1", 1);
	Addto(lGetMad,								"WMaleAltDialog.wm_bumped_oofidiotv2", 2);
	Addto(lGetMad,								"WMaleAltDialog.wm_bully_yougotaproblemv1", 1);
	Addto(lGetMad,								"WMaleAltDialog.wm_bully_yougotaproblemv2", 2);

	Clear(lLynchMob);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_gethimv1", 1);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_gethimv2", 2);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_heyyouv1", 1);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_heyyouv2", 2);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_idontlikethelookv1", 1);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_idontlikethelookv2", 2);
	//Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_notfromaroundherev1", 1);
	//Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_notfromaroundherev2", 2);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_somethingfunnyv1", 1);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_somethingfunnyv2", 2);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_thatstheonev1", 1);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_thatstheonev2", 2);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_thereheisv1", 1);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_thereheisv2", 2);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_theresthekillerv1", 1);
	Addto(lLynchMob,							"WMaleAltDialog.wm_lynch_theresthekillerv2", 2);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"WMaleAltDialog.wm_lynch_gethimv1", 1);
	Addto(lSeesEnemy,							"WMaleAltDialog.wm_lynch_gethimv2", 2);
	Addto(lSeesEnemy,							"WMaleAltDialog.wm_lynch_heyyouv1", 1);
	Addto(lSeesEnemy,							"WMaleAltDialog.wm_lynch_heyyouv2", 2);
	Addto(lSeesEnemy,							"WMaleAltDialog.wm_tough_howaboutsomeofthisv1", 1);
	Addto(lSeesEnemy,							"WMaleAltDialog.wm_tough_howaboutsomeofthisv2", 2);
	Addto(lSeesEnemy,							"WMaleAltDialog.wm_tough_rahv1", 1);
	Addto(lSeesEnemy,							"WMaleAltDialog.wm_tough_rahv2", 2);

	/*
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
	*/

	Clear(lSignPetition);							
	Addto(lSignPetition,						"WMaleAltDialog.wm_positive_imdownv1", 1);
	Addto(lSignPetition,						"WMaleAltDialog.wm_positive_imdownv2", 2);
	Addto(lSignPetition,						"WMaleAltDialog.wm_positive_okayilldoitv1", 1);
	Addto(lSignPetition,						"WMaleAltDialog.wm_positive_okayilldoitv2", 2);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_absolutelynotv1", 1);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_absolutelynotv2", 2);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_asifv1", 1);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_asifv2", 2);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_fuckthatv1", 1);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_fuckthatv2", 2);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_idontthinksov1", 1);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_idontthinksov2", 2);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_nothanksv1", 1);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_nothanksv2", 2);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_notinterestedv1", 1);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_notinterestedv2", 2);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_sorryv1", 1);
	Addto(lDontSignPetition,					"WMaleAltDialog.wm_negative_sorryv2", 2);

	Clear(lPetitionBother);
	Addto(lPetitionBother,						"WMaleAltDialog.wm_negative_goawayv1", 1);
	Addto(lPetitionBother,						"WMaleAltDialog.wm_negative_goawayv2", 2);
	
	Clear(lChampPhotoReaction);
	Addto(lChampPhotoReaction,					"WMaleDialog.wm_christ", 1);
	Addto(lChampPhotoReaction,					"WMaleDialog.wm_shit", 1);
	Addto(lChampPhotoReaction,					"WMaleDialog.wm_holyshit", 1);
	Addto(lChampPhotoReaction,					"WMaleDialog.wm_thehorror", 1);
	Addto(lChampPhotoReaction,					"WMaleDialog.wm_itshorrible", 1);
	Addto(lChampPhotoReaction,					"WMaleDialog.wm_sweetlordno", 1);
	Addto(lChampPhotoReaction,					"WMaleDialog.wm_ghasp", 1);

	//Clear(lcallsecurity);
	//Addto(lcallsecurity,						"", 1);
	
	//Clear(lrowdycustomer);
	//Addto(lrowdycustomer,						"", 1);
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	VolumeMult=0.60
}
