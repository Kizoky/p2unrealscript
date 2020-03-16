///////////////////////////////////////////////////////////////////////////////
// DialogAltFemale
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all white females (alternate variation)
//
///////////////////////////////////////////////////////////////////////////////
class DialogFemaleAlt extends DialogFemale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();

	Clear(lapplauding);
	AddTo(lApplauding,							"WFemaleAltDialog.wf_cheer_awesomev1", 1);
	AddTo(lApplauding,							"WFemaleAltDialog.wf_cheer_gobabyv1", 1);
	AddTo(lApplauding,							"WFemaleAltDialog.wf_cheer_incrediblev1", 1);
	AddTo(lApplauding,							"WFemaleAltDialog.wf_cheer_woohoov1", 1);
	AddTo(lApplauding,							"WFemaleAltDialog.wf_cheer_wootv1", 1);
	AddTo(lApplauding,							"WFemaleAltDialog.wf_cheer_yeahv1", 1);

	Clear(lgreeting);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_hellov1", 1);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_hellov2", 2);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_hellov3", 3);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_heyv1", 1);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_heyv2", 2);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_heyv3", 3);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_hiv1", 1);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_hiv2", 2);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_hiv3", 3);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_supv1", 1);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_supv2", 2);
	Addto(lgreeting,							"WFemaleAltDialog.wf_greet_supv3", 3);

	Clear(lhotgreeting);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_hellov1", 1);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_hellov2", 2);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_hellov3", 3);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_hellov4", 4);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_heyv1", 1);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_heyv2", 2);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_hiv1", 1);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_hiv2", 2);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_hiv3", 3);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_hiv4", 4);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_supv1", 1);
	Addto(lhotGreeting,							"WFemaleAltDialog.wf_sleez_supv2", 2);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,					"WFemaleAltDialog.wf_greet_howareyouv1", 1);
	Addto(lGreetingquestions,					"WFemaleAltDialog.wf_greet_howareyouv2", 2);
	Addto(lGreetingquestions,					"WFemaleAltDialog.wf_greet_howareyouv4", 3);
	Addto(lGreetingquestions,					"WFemaleAltDialog.wf_greet_howsitgoingv1", 1);
	Addto(lGreetingquestions,					"WFemaleAltDialog.wf_greet_howsitgoingv2", 2);
	Addto(lGreetingquestions,					"WFemaleAltDialog.wf_greet_howsitgoingv3", 3);
	Addto(lGreetingquestions,					"WFemaleAltDialog.wf_greet_howyoudoinv1", 1);
	Addto(lGreetingquestions,					"WFemaleAltDialog.wf_greet_howyoudoinv2", 2);
	Addto(lGreetingquestions,					"WFemaleAltDialog.wf_greet_howyoudoinv3", 3);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howareyouv1", 1);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howareyouv2", 2);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howareyouv3", 3);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howareyouv4", 4);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howsitgoingv1", 1);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howsitgoingv1", 2);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howsitgoingv1", 3);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howsitgoingv1", 4);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howsitgoingv1", 5);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howsitgoingv1", 6);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howyoudoinv1", 1);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howyoudoinv2", 2);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howyoudoinv3", 3);
	Addto(lHotGreetingquestions,				"WFemaleAltDialog.wf_sleez_howyoudoinv4", 4);

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,				"WFemaleAltDialog.wf_ughv1", 1);
	Addto(lrespondtohotgreeting,				"WFemaleAltDialog.wf_ughv2", 2);
	Addto(lrespondtohotgreeting,				"WFemaleAltDialog.wf_doiknowyouv1", 1);
	Addto(lrespondtohotgreeting,				"WFemaleAltDialog.wf_doiknowyouv2", 2);
	Addto(lrespondtohotgreeting,				"WFemaleAltDialog.wf_negative_notinterestedv1", 1);
	Addto(lrespondtohotgreeting,				"WFemaleAltDialog.wf_negative_notinterestedv2", 2);
	Addto(lrespondtohotgreeting,				"WFemaleAltDialog.wf_nottalking2mev1", 1);
	Addto(lrespondtohotgreeting,				"WFemaleAltDialog.wf_nottalking2mev2", 2);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_beenbetterv1", 1);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_beenbetterv2", 2);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_doiknowyouv1", 1);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_doiknowyouv2", 2);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_doinprettygoodv1", 1);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_doinprettygoodv2", 2);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_finethanksv1", 1);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_finethanksv2", 2);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_grandmawcamedownv1", 1);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_grandmawcamedownv2", 2);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_ohokayiguessv1", 1);
	Addto(lrespondtogreeting,					"WFemaleAltDialog.wf_ohokayiguessv2", 2);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_gladtohearitv1", 1);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_gladtohearitv2", 2);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_itsallgoodv1", 1);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_itsallgoodv2", 2);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_noproblemv1", 1);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_noproblemv2", 2);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_noworriesv1", 1);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_noworriesv2", 2);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_ohhowawfulv1", 1);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_ohhowawfulv2", 2);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_imsorryv1", 1);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_imsorryv2", 2);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_thatsnicev1", 1);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_thatsnicev2", 2);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_welltakecarev1", 1);
	Addto(lrespondtogreetingresponse,			"WFemaleAltDialog.wf_welltakecarev2", 2);

	Clear(lHelloCop);
	Addto(lHelloCop,								"WFemaleAltDialog.wf_isanythingwrongv1", 1);
	Addto(lHelloCop,								"WFemaleAltDialog.wf_whatseemstobethev1", 1);
	Addto(lHelloCop,								"WFemaleAltDialog.wf_whatseemstobethev2", 2);
	
	//Clear(lHelloGimp);
	//Addto(lHelloGimp,							"", 1);

	Clear(lApologize);
	Addto(lApologize,							"WFemaleAltDialog.wf_imsorryv1", 1);
	Addto(lApologize,							"WFemaleAltDialog.wf_imsorryv2", 2);

	Clear(lyourewelcome);
	Addto(lyourewelcome,						"WFemaleAltDialog.wf_yourewelcomev1", 1);
	Addto(lyourewelcome,						"WFemaleAltDialog.wf_yourewelcomev2", 2);

	Clear(lno);
	Addto(lno,									"WFemaleAltDialog.wf_negative_absolutelynotv1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_absolutelynotv2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_asifv1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_asifv2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_fuckthatv1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_fuckthatv2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_fuckthatv3", 3);
	Addto(lno,									"WFemaleAltDialog.wf_negative_goawayv1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_goawayv2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_idontthinksov1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_idontthinksov2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_nopev1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_nopev2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_nothanksv1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_nothanksv2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_notinterestedv1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_notinterestedv2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_notv1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_notv2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_nov1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_nov2", 2);
	Addto(lno,									"WFemaleAltDialog.wf_negative_sorryv1", 1);
	Addto(lno,									"WFemaleAltDialog.wf_negative_sorryv2", 2);

	Clear(lyes);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_probablyv1", 1);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_probablyv2", 2);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_surev1", 1);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_surev2", 2);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_uhhunhv1", 1);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_uhhunhv2", 2);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_yeahv1", 1);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_yeahv2", 2);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_yesv1", 1);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_yesv2", 2);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_yupv1", 1);
	Addto(lyes,									"WFemaleAltDialog.wf_positive_yupv2", 2);

	Clear(lthanks);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_greatv1", 1);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_greatv2", 2);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_kickassv1", 1);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_kickassv2", 2);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_sweetv1", 1);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_thanksv1", 1);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_thanksv2", 2);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_thatrocksv1", 1);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_yourulev1", 1);
	Addto(lthanks,								"WFemaleAltDialog.wf_positive_yourulev2", 2);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"WFemaleAltDialog.wf_positive_greatv1", 1);
	Addto(lThatsGreat,							"WFemaleAltDialog.wf_positive_greatv2", 2);
	Addto(lThatsGreat,							"WFemaleAltDialog.wf_positive_kickassv1", 1);
	Addto(lThatsGreat,							"WFemaleAltDialog.wf_positive_kickassv2", 2);
	Addto(lThatsGreat,							"WFemaleAltDialog.wf_positive_sweetv1", 1);
	Addto(lThatsGreat,							"WFemaleAltDialog.wf_positive_thatrocksv1", 1);

	Clear(lGetDown);
	AddTo(lGetDown,								"WFemaleAltDialog.wf_shotblocked2v1", 1);
	AddTo(lGetDown,								"WFemaleAltDialog.wf_shotblocked2v2", 2);
	AddTo(lGetDown,								"WFemaleAltDialog.wf_shotblocked4v1", 1);
	AddTo(lGetDown,								"WFemaleAltDialog.wf_shotblocked4v2", 2);
	AddTo(lGetDown,								"WFemaleAltDialog.wf_shotblocked4v3", 3);

	Clear(lGetDownMP);
	AddTo(lGetDownMP,							"WFemaleAltDialog.wf_shotblocked2v1", 1);
	AddTo(lGetDownMP,							"WFemaleAltDialog.wf_shotblocked2v2", 2);
	AddTo(lGetDownMP,							"WFemaleAltDialog.wf_shotblocked4v1", 1);
	AddTo(lGetDownMP,							"WFemaleAltDialog.wf_shotblocked4v2", 2);
	AddTo(lGetDownMP,							"WFemaleAltDialog.wf_shotblocked4v3", 3);

	Clear(lCussing);
	Addto(lCussing,								"WFemaleAltDialog.wf_damage_fuckv1", 1);
	Addto(lCussing,								"WFemaleAltDialog.wf_damage_fuckv2", 2);
	Addto(lCussing,								"WFemaleAltDialog.wf_damage_shitv1", 1);
	Addto(lCussing,								"WFemaleAltDialog.wf_pissedon_assholev1", 1);
	Addto(lCussing,								"WFemaleAltDialog.wf_pissedon_christv1", 1);

	// Not used. - K
	//Clear(lgetdownscared);
	//Addto(lgetdownscared,						"", 1);

	Clear(ldefiant);
	//Addto(ldefiant,								"WFemaleAltDialog.wf_bully_iheardthatv1", 1);
	//Addto(ldefiant,								"WFemaleAltDialog.wf_bully_iheardthatv2", 2);
	Addto(ldefiant,								"WFemaleAltDialog.wf_bully_whatareyoulookingatv1", 1);
	Addto(ldefiant,								"WFemaleAltDialog.wf_bully_whatareyoulookingatv2", 2);
	Addto(ldefiant,								"WFemaleAltDialog.wf_bully_whatareyoulookingatv3", 3);
	Addto(ldefiant,								"WFemaleAltDialog.wf_bully_yougotanissuev1", 1);

	Clear(ldefiantline);
	//Addto(ldefiantline,							"WFemaleAltDialog.wf_bully_iheardthatv1", 1);
	//Addto(ldefiantline,							"WFemaleAltDialog.wf_bully_iheardthatv2", 2);
	Addto(ldefiantline,							"WFemaleAltDialog.wf_bully_whatareyoulookingatv1", 1);
	Addto(ldefiantline,							"WFemaleAltDialog.wf_bully_whatareyoulookingatv2", 2);
	Addto(ldefiantline,							"WFemaleAltDialog.wf_bully_whatareyoulookingatv3", 3);
	Addto(ldefiantline,							"WFemaleAltDialog.wf_bully_yougotanissuev1", 1);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"WFemaleAltDialog.wf_damage_fuckv1", 1);
	Addto(lCloseToWeapon,						"WFemaleAltDialog.wf_damage_fuckv2", 2);
	Addto(lCloseToWeapon,						"WFemaleAltDialog.wf_damage_shitv1", 1);
	Addto(lCloseToWeapon,						"WFemaleAltDialog.wf_pissedon_assholev1", 1);
	Addto(lCloseToWeapon,						"WFemaleAltDialog.wf_pissedon_christv1", 1);
	Addto(lCloseToWeapon,						"WFemaleAltDialog.wf_seecarnage_holyshitv1", 1);
	Addto(lCloseToWeapon,						"WFemaleAltDialog.wf_seecarnage_ohmygodv1", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"WFemaleAltDialog.wf_riot1v1", 1);
	Addto(ldecidetofight,						"WFemaleAltDialog.wf_riot2v1", 1);
	Addto(ldecidetofight,						"WFemaleAltDialog.wf_riot2v2", 2);
	Addto(ldecidetofight,						"WFemaleAltDialog.wf_riot3v1", 1);
	Addto(ldecidetofight,						"WFemaleAltDialog.wf_riot4v1", 1);

	// No suitable lines. Call from Super. - K
	//Clear(llaughing);
	Addto(llaughing,							"WFemaleAltDialog.wf_laughv1", 1);

	//Clear(lSnickering);
	//Addto(lSnickering,							"", 1);

	//Clear(lOutOfBreath);
	//Addto(lOutOfBreath,							"", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"WFemaleAltDialog.wf_seepanic_1v1", 1);
	Addto(lWatchingCrazy,						"WFemaleAltDialog.wf_seepanic_1v2", 2);
	Addto(lWatchingCrazy,						"WFemaleAltDialog.wf_seepanic_1v3", 3);
	Addto(lWatchingCrazy,						"WFemaleAltDialog.wf_seepanic_2v1", 1);
	Addto(lWatchingCrazy,						"WFemaleAltDialog.wf_seepanic_3v1", 1);	
	Addto(lWatchingCrazy,						"WFemaleAltDialog.wf_followup_areyouoncrackv1", 1);
	Addto(lWatchingCrazy,						"WFemaleAltDialog.wf_followup_iseeyourecrazyv1", 1);
	
	Clear(lshootingoverthere);
	Addto(lshootingoverthere,					"WFemaleAltDialog.wf_getcop_helpv1", 1);
	Addto(lshootingoverthere,					"WFemaleAltDialog.wf_getcop_policex2v1", 1);
	Addto(lshootingoverthere,					"WFemaleAltDialog.wf_heargun_gunfightv1", 1);
	Addto(lshootingoverthere,					"WFemaleAltDialog.wf_heargun_gunshotsv1", 1);
	Addto(lshootingoverthere,					"WFemaleAltDialog.wf_heargun_heargunfirev1", 1);
	Addto(lshootingoverthere,					"WFemaleAltDialog.wf_heargun_someidiotisfiringv1", 1);
	Addto(lshootingoverthere,					"WFemaleAltDialog.wf_heargun_someoneshootingv1", 1);
	Addto(lshootingoverthere,					"WFemaleAltDialog.wf_seecarnage_someguysshootingv1", 1);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,					"WFemaleAltDialog.wf_getcop_helpv1", 1);
	Addto(lkillingoverthere,					"WFemaleAltDialog.wf_getcop_policex2v1", 1);
	Addto(lkillingoverthere,					"WFemaleAltDialog.wf_seecarnage_somebodystopv1", 1);

	Clear(lscreaming);
	Addto(lscreaming,							"WFemaleAltDialog.wf_scream1", 1);
	Addto(lscreaming,							"WFemaleAltDialog.wf_scream2", 1);
	Addto(lscreaming,							"WFemaleAltDialog.wf_scream3", 1);
	Addto(lscreaming,							"WFemaleAltDialog.wf_scream4", 1);
	Addto(lscreaming,							"WFemaleAltDialog.wf_scream5", 1);
	Addto(lscreaming,							"WFemaleAltDialog.wf_scream6", 1);
	Addto(lscreaming,							"WFemaleAltDialog.wf_scream7", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_awghelpmev1", 1);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_awghelpmev2", 2);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_awghelpmev3", 3);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_burnsmorev1", 1);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_burnsmorev2", 2);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_fiyaav1", 1);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_fiyaav2", 2);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_fiyaav3", 3);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_fiyaav4", 4);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_imburningv1", 1);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_imburningv2", 2);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_putmeoutv1", 1);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_putmeoutv2", 2);
	Addto(lscreamingonfire,						"WFemaleAltDialog.wf_onfire_yeaghv1", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_bringitv1", 1);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_bringitv2", 2);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_howaboutsomeofthisv1", 1);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_rahv1", 1);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_rahv2", 2);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_tryandstopmev1", 1);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_tryandstopmev2", 2);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_youthinkimscaredv1", 1);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_youthinkimscaredv2", 2);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_youthinkthatcanv1", 1);
	Addto(lDoHeroics,							"WFemaleAltDialog.wf_tough_youthinkthatcanv2", 2);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"WFemaleAltDialog.wf_spitoutpissv1", 1);
	Addto(lgettingpissedon,						"WFemaleAltDialog.wf_spitoutpissv2", 1);
	Addto(lgettingpissedon,						"WFemaleAltDialog.wf_spitoutpissv3", 1);
	Addto(lgettingpissedon,						"WFemaleAltDialog.wf_spitoutpissv4", 1);
	Addto(lgettingpissedon,						"WFemaleAltDialog.wf_spitoutpissv5", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"WFemaleAltDialog.wf_pissedon_assholev1", 1);
	Addto(laftergettingpissedon,				"WFemaleAltDialog.wf_pissedon_christv1", 1);
	Addto(laftergettingpissedon,				"WFemaleAltDialog.wf_pissedon_disgustingv1", 1);
	Addto(laftergettingpissedon,				"WFemaleAltDialog.wf_pissedon_eughv1", 1);
	Addto(laftergettingpissedon,				"WFemaleAltDialog.wf_pissedon_heeyv1", 1);
	//Addto(laftergettingpissedon,				"WFemaleAltDialog.wf_pissedon_likedthatv1", 1);
	//Addto(laftergettingpissedon,				"WFemaleAltDialog.wf_pissedon_likedthatv2", 2);
	Addto(laftergettingpissedon,				"WFemaleAltDialog.wf_pissedon_myblousev1", 1);
	Addto(laftergettingpissedon,				"WFemaleAltDialog.wf_pissedon_ruinedmakeupv1", 1);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"WFemaleAltDialog.wf_huhv1", 1);
	Addto(lwhatthe,								"WFemaleAltDialog.wf_huhv2", 2);
	Addto(lwhatthe,								"WFemaleAltDialog.wf_huhv3", 3);
	Addto(lwhatthe,								"WFemaleAltDialog.wf_pissedon_whatthev1", 1);
	Addto(lwhatthe,								"WFemaleAltDialog.wf_pissedon_whuhv1", 1);
	Addto(lwhatthe,								"WFemaleAltDialog.wf_pissedon_whuhv2", 2);

	Clear(lseeingpisser);
	Addto(lseeingpisser,						"WFemaleAltDialog.wf_seespissing1v1", 1);
	Addto(lseeingpisser,						"WFemaleAltDialog.wf_seespissing2v1", 1);
	Addto(lseeingpisser,						"WFemaleAltDialog.wf_seespissing3v1", 1);
	Addto(lseeingpisser,						"WFemaleAltDialog.wf_seespissing3v2", 2);
	Addto(lseeingpisser,						"WFemaleAltDialog.wf_seespissing4v1", 1);
	Addto(lseeingpisser,						"WFemaleAltDialog.wf_seespissing5v1", 1);
	Addto(lseeingpisser,						"WFemaleAltDialog.wf_seespissing5v2", 2);

	Clear(lSomethingIsGross);
	Addto(lSomethingIsGross,					"WFemaleAltDialog.wf_ewv1", 1);
	Addto(lSomethingIsGross,					"WFemaleAltDialog.wf_ewv1", 2);

	Clear(lgothit);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_aghkv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_aiieev1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_akv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_akv2", 2);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_arghv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_arghv2", 2);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_aughv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_aughv2", 2);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_badtouchv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_buddhav1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_buddhav2", 2);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_fuckinghurtv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_fuckv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_fuckv2", 2);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_gakv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_gakv2", 2);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_mommyv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_myuterusv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_owbitchv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_owv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_owv2", 2);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_painv1", 1);
	Addto(lgothit,								"WFemaleAltDialog.wf_damage_shitv1", 1);

	Clear(lAttacked);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_aghkv1", 1);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_akv1", 1);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_akv2", 2);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_arghv1", 1);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_arghv2", 2);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_aughv1", 1);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_aughv2", 2);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_fuckv1", 1);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_fuckv2", 2);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_gakv1", 1);
	Addto(lAttacked,							"WFemaleAltDialog.wf_damage_gakv2", 2);

	Clear(lGrunt);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_aghkv1", 1);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_akv1", 1);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_akv2", 2);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_arghv1", 1);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_arghv2", 2);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_aughv1", 1);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_aughv2", 2);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_gakv1", 1);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_gakv2", 2);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_owv1", 1);
	Addto(lGrunt,								"WFemaleAltDialog.wf_damage_owv2", 2);

	//Clear(lPissing);
	//Addto(lPissing,								"", 1);

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
	Addto(lGotHitInCrotch,						"WFemaleAltDialog.wf_damage_myuterusv1", 1);

	Clear(lbegforlife);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_crying1v1", 1);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_crying2", 1);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_crying3", 1);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_cryingv1", 1);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_cryingv2", 2);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_cryingv3", 3);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_dontkillvirginv1", 1);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_dontkillvirginv1", 2);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_pleasedontkillmev1", 1);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_pleasepleasenov1", 1);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_beg_sparemylifekidsv1", 1);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_fearful_donthurtv1", 1);
	Addto(lbegforlife,							"WFemaleAltDialog.wf_fearful_donthurtv2", 2);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_crying1v1", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_crying2", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_crying3", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_cryingv1", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_cryingv2", 2);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_cryingv3", 3);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_dontkillvirginv1", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_dontkillvirginv1", 2);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_pleasedontkillmev1", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_pleasepleasenov1", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_sparemylifekidsv1", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_beg_dontkillminorityv1", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_fearful_donthurtv1", 1);
	Addto(lbegforlifeMin,						"WFemaleAltDialog.wf_fearful_donthurtv2", 2);
	
	//Clear(ldying);
	//Addto(ldying,								"", 1);

	Clear(lCrying);
	Addto(lCrying,								"WFemaleAltDialog.wf_beg_crying1v1", 1);
	Addto(lCrying,								"WFemaleAltDialog.wf_beg_crying2", 1);
	Addto(lCrying,								"WFemaleAltDialog.wf_beg_crying3", 1);
	Addto(lCrying,								"WFemaleAltDialog.wf_beg_cryingv1", 1);
	Addto(lCrying,								"WFemaleAltDialog.wf_beg_cryingv2", 2);
	Addto(lCrying,								"WFemaleAltDialog.wf_beg_cryingv3", 3);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,					"WFemaleAltDialog.wf_beg_didntmeanitv1", 1);
	Addto(lfrightenedapology,					"WFemaleAltDialog.wf_beg_didntmeanitv2", 2);
	Addto(lfrightenedapology,					"WFemaleAltDialog.wf_beg_neverdothatagainv1", 1);

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"WFemaleAltDialog.wf_taunt_cmonfightlikeamanv1", 1);
	Addto(ltrashtalk,							"WFemaleAltDialog.wf_taunt_ohyeahbigmanwithav1", 1);
	Addto(ltrashtalk,							"WFemaleAltDialog.wf_taunt_whereyougoingsissyv1", 1);
	Addto(ltrashtalk,							"WFemaleAltDialog.wf_taunt_whereyougoingsissyv2", 2);
	Addto(ltrashtalk,							"WFemaleAltDialog.wf_taunt_whereyougoingsissyv3", 3);
	Addto(ltrashtalk,							"WFemaleAltDialog.wf_taunt_yourenotsotoughv1", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting,						"WFemaleAltDialog.wf_taunt_cmonfightlikeamanv1", 1);
	Addto(lWhileFighting,						"WFemaleAltDialog.wf_taunt_ohyeahbigmanwithav1", 1);
	Addto(lWhileFighting,						"WFemaleAltDialog.wf_taunt_whereyougoingsissyv1", 1);
	Addto(lWhileFighting,						"WFemaleAltDialog.wf_taunt_whereyougoingsissyv2", 2);
	Addto(lWhileFighting,						"WFemaleAltDialog.wf_taunt_whereyougoingsissyv3", 3);
	Addto(lWhileFighting,						"WFemaleAltDialog.wf_taunt_yourenotsotoughv1", 1);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,						"WFemaleAltDialog.wf_whatseemstobethev1", 1);
	Addto(laskcopwhatsup,						"WFemaleAltDialog.wf_whatseemstobethev2", 2);

	Clear(lratout);
	Addto(lratout,								"WFemaleAltDialog.wf_report_hediditv1", 1);
	Addto(lratout,								"WFemaleAltDialog.wf_report_hediditv2", 2);
	Addto(lratout,								"WFemaleAltDialog.wf_report_hestheonev1", 1);
	Addto(lratout,								"WFemaleAltDialog.wf_report_hestheonev2", 2);
	Addto(lratout,								"WFemaleAltDialog.wf_report_itwashimv1", 1);
	Addto(lratout,								"WFemaleAltDialog.wf_report_itwashimv2", 2);
	Addto(lratout,								"WFemaleAltDialog.wf_report_thatguyovertherev1", 1);
	Addto(lratout,								"WFemaleAltDialog.wf_report_thatguyovertherev2", 2);
	Addto(lratout,								"WFemaleAltDialog.wf_report_thatguyv1", 1);
	Addto(lratout,								"WFemaleAltDialog.wf_report_thatguyv2", 2);

	Clear(lfakeratout);
	Addto(lfakeratout,							"WFemaleAltDialog.wf_lying_hediditisawv1", 1);
	Addto(lfakeratout,							"WFemaleAltDialog.wf_lying_hediditisawv2", 2);
	Addto(lfakeratout,							"WFemaleAltDialog.wf_lying_imawitnessv1", 1);
	Addto(lfakeratout,							"WFemaleAltDialog.wf_lying_imawitnessv2", 2);
	Addto(lfakeratout,							"WFemaleAltDialog.wf_lying_imawitnessv3", 3);
	Addto(lfakeratout,							"WFemaleAltDialog.wf_lying_imawitnessv4", 4);

	Clear(lcleanshot);
	Addto(lcleanshot,							"WFemaleAltDialog.wf_shotblocked1v1", 1);
	Addto(lcleanshot,							"WFemaleAltDialog.wf_shotblocked2v1", 1);
	Addto(lcleanshot,							"WFemaleAltDialog.wf_shotblocked2v2", 2);
	Addto(lcleanshot,							"WFemaleAltDialog.wf_shotblocked3v1", 1);
	Addto(lcleanshot,							"WFemaleAltDialog.wf_shotblocked4v1", 1);
	Addto(lcleanshot,							"WFemaleAltDialog.wf_shotblocked4v2", 2);
	Addto(lcleanshot,							"WFemaleAltDialog.wf_shotblocked4v3", 3);
	Addto(lcleanshot,							"WFemaleAltDialog.wf_shotblocked5v1", 1);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"WFemaleAltDialog.wf_shotblocked3v1", 1);
	Addto(lCleanMeleeHit,						"WFemaleAltDialog.wf_shotblocked4v1", 1);
	Addto(lCleanMeleeHit,						"WFemaleAltDialog.wf_shotblocked4v2", 2);
	Addto(lCleanMeleeHit,						"WFemaleAltDialog.wf_shotblocked4v3", 3);

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
	Addto(lhmm,									"WFemaleAltDialog.wf_hmmmmv1", 1);
	Addto(lhmm,									"WFemaleAltDialog.wf_hmmmmv2", 1);

	//Clear(lfollowme);
	//Addto(lfollowme,							"", 1);	

	//Clear(lStayHere);
	//Addto(lStayHere,							"", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,						"WFemaleAltDialog.wf_seewang_heybuddyyourbarnv1", 1);
	Addto(lnoticedickout,						"WFemaleAltDialog.wf_seewang_heybuddyyourbarnv2", 2);
	Addto(lnoticedickout,						"WFemaleAltDialog.wf_seewang_somedignityv1", 1);
	Addto(lnoticedickout,						"WFemaleAltDialog.wf_seewang_tinytimv1", 1);
	Addto(lnoticedickout,						"WFemaleAltDialog.wf_seewang_xyzv1", 1);
	Addto(lnoticedickout,						"WFemaleAltDialog.wf_seewang_xyzv2", 2);

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
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_bitcheslooksatmev1", 1);
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_bitcheslooksatmev2", 2);
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_bulletsv1", 1);
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_bulletsv2", 2);
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_godsaysdiev1", 1);
	// These two won't exactly work the way I want to implement this. - K
	//Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_krotchy4xmasv1", 1);
	//Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_krotchy4xmasv2", 2);
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_motherneverlovedmev1", 1);
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_motherneverlovedmev2", 2);
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_stayawayfrommev1", 1);
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_stayawayfrommev2", 2);
	Addto(lGoPostal,							"WFemaleAltDialog.wf_postal_youdontwannaknowv1", 1);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_fearful_getoutv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_fearful_getoutv2", 2);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_fearful_isnthappeningv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_ghaspv2", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_ghaspv3", 2);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_ghaspv4", 3);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_ambulancev1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_ambulancev2", 2);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_aniceguyv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_anyoneseethatv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_back2rehabv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_callthenavyv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_cantbelievehappeningv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_cantbelievehappeningv2", 2);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_cantbelievehedidthatv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_forchristsakev1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_helpv1", 1);
	// Won't always be because of a gun. - K
	//Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_hesgotagunv1", 1);
	//Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_hesgotagunv2", 2);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_holyshitv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_howcanthisbev1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_imgoingtobesickv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_itshorriblev1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_jesushelpv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_killingeveryonev1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_murderedthatguyv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_needcouncellingv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_nightmnarev1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_nightmnarev2", 2);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_ohmygodv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_outtaherev1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_outtaherev2", 2);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_pleasemakeitstopv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_runrunv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_somebodystopv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_sweetlordnov1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_thehorrorv1", 1);
	Addto(lcarnageoccurred,						"WFemaleAltDialog.wf_seecarnage_thiscantberealv1", 1);

	Clear(lCallCat);
	Addto(lCallCat, 							"WFemaleAltDialog.wf_likescat_herekittyv1", 1);

	Clear(lHateCat);
	Addto(lHateCat, 							"WFemaleAltDialog.wf_hatescat_getoutfurballv1", 1);
	Addto(lHateCat, 							"WFemaleAltDialog.wf_hatescat_getoutfurballv2", 2);
	Addto(lHateCat, 							"WFemaleAltDialog.wf_hatescat_goddamcatv1", 1);
	Addto(lHateCat, 							"WFemaleAltDialog.wf_hatescat_herekittyevilv1", 1);

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"WFemaleAltDialog.wf_damage_fuckv1", 1);
	Addto(lStartAttackingAnimal,				"WFemaleAltDialog.wf_damage_fuckv2", 2);
	Addto(lStartAttackingAnimal,				"WFemaleAltDialog.wf_damage_shitv1", 1);
	Addto(lStartAttackingAnimal,				"WFemaleAltDialog.wf_pissedon_christv1", 1);

	// Only used by Habib.
	//Clear(lGettingRobbed);	
	//Addto(lGettingRobbed,						"", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"WFemaleAltDialog.wf_ghaspv2", 1);
	Addto(lGettingMugged,						"WFemaleAltDialog.wf_ghaspv3", 2);
	Addto(lGettingMugged,						"WFemaleAltDialog.wf_ghaspv4", 3);
	Addto(lGettingMugged,						"WFemaleAltDialog.wf_beg_pleasedontkillmev1", 1);
	Addto(lGettingMugged,						"WFemaleAltDialog.wf_getcop_helpv1", 1);
	Addto(lGettingMugged,						"WFemaleAltDialog.wf_fearful_donthurtv1", 1);
	Addto(lGettingMugged,						"WFemaleAltDialog.wf_fearful_donthurtv2", 2);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"WFemaleAltDialog.wf_getcop_helpv1", 1);
	Addto(lAfterMugged,							"WFemaleAltDialog.wf_getcop_policex2v1", 1);

	//Clear(lDoMugging);	
	//Addto(lDoMugging,							"", 3);
	
	Clear(lQuestion);	
	Addto(lQuestion,							"WFemaleAltDialog.wf_question_idontcarev1", 1);
	Addto(lQuestion,							"WFemaleAltDialog.wf_question_whatareyoutalkingv1", 1);
	Addto(lQuestion,							"WFemaleAltDialog.wf_question_whatv1", 1);
	Addto(lQuestion,							"WFemaleAltDialog.wf_question_whyv1", 1);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"WFemaleAltDialog.wf_call_cantgoinsidev1", 1);
	Addto(lGenericQuestion,						"WFemaleAltDialog.wf_call_ipadsareevilv1", 1);
	Addto(lGenericQuestion,						"WFemaleAltDialog.wf_call_knowmyhousev1", 1);
	Addto(lGenericQuestion,						"WFemaleAltDialog.wf_call_plans4laterv1", 1);
	Addto(lGenericQuestion,						"WFemaleAltDialog.wf_call_slutsinhighschoolv1", 1);
	Addto(lGenericQuestion,						"WFemaleAltDialog.wf_call_youseethatshowv1", 1);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_disinterest_lamev1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_disinterest_mehv1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_disinterest_mehv2", 2);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_disinterest_whocaresv1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_ifitwasupyourassv1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_ifitwasupyourassv2", 2);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_iforgetv1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_iforgetv2", 2);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_isthiscandidv1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_isthiscandidv2", 2);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_ithinkineedadrinkv1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_ithinkineedmesomev1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_ithinkineedmesomev2", 2);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_ithinkineedmesomev3", 3);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_whatisabbaalexv1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_whyisitwhenyourev1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_whyisitwhenyourev2", 2);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_williwinaprizev1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_youkeeptalkingillv1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_youthinkicouldv1", 1);
	Addto(lGenericAnswer,						"WFemaleAltDialog.wf_response_youthinkicouldv2", 2);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_followup_areyouevenlisteningv1", 1);
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_followup_areyouoncrackv1", 1);
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_followup_geezstopdoingthatv1", 1);
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_followup_iseeyourecrazyv1", 1);
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_followup_listenjusttellmev1", 1);
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_followup_listenjusttellmev2", 2);
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_followup_whatv1", 1);
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_followup_yourenotreallyv1", 1);
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_nottalking2mev1", 1);
	Addto(lGenericFollowup,						"WFemaleAltDialog.wf_nottalking2mev2", 2);
	
	Clear(lGenericGoodbye);
	Addto(lGenericGoodbye,						"WFemaleAltDialog.wf_leadout_hysterectomyv1", 1);
	Addto(lGenericGoodbye,						"WFemaleAltDialog.wf_leadout_hysterectomyv2", 2);
	Addto(lGenericGoodbye,						"WFemaleAltDialog.wf_leadout_insightfulv1", 1);
	Addto(lGenericGoodbye,						"WFemaleAltDialog.wf_leadout_shankyouv1", 1);
	Addto(lGenericGoodbye,						"WFemaleAltDialog.wf_leadout_wasntinterestingv1", 1);
	Addto(lGenericGoodbye,						"WFemaleAltDialog.wf_leadout_wasntinterestingv2", 1);

	//Clear(linvadeshome);	
	//Addto(linvadeshome,							"", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,						"WFemaleAltDialog.wf_seeonfire_everyonesonfirev1", 1);
	Addto(lsomeoneonfire,						"WFemaleAltDialog.wf_seeonfire_stopdropandrollv1", 1);
	Addto(lsomeoneonfire,						"WFemaleAltDialog.wf_seeonfire_theyreallburningv1", 1);
	Addto(lsomeoneonfire,						"WFemaleAltDialog.wf_seeonfire_youreonfirev1", 1);

	Clear(labouttopuke);
	Addto(labouttopuke,							"WFemaleAltDialog.wf_puke_idontfeelsogoodv1", 1);
	Addto(labouttopuke,							"WFemaleAltDialog.wf_puke_ohgodimv1", 1);
	Addto(labouttopuke,							"WFemaleAltDialog.wf_puke_ohmanimgonnabesickv1", 1);

	//Clear(lbodyfunctions);
	//Addto(lbodyfunctions,						"", 1);

	//Clear(lGettingShocked);
	//Addto(lGettingShocked,						"", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,							"HabibDialog.habib_ailili", 1);

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_call_cantgoinsidev1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_call_ipadsareevilv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_call_knowmyhousev1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_call_plans4laterv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_call_slutsinhighschoolv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_call_youseethatshowv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_concernedsmellv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_greatboredv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_haveyouheardlunaticv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_haveyouheardlunaticv2", 2);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_hmmv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_icantwaitv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_itriedsixoncebutiv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_krotchyebayv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_krotchyebayv2", 2);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_nohappyv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_nonov1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_ohtheyalwaysdothatv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_ohtheyalwaysdothatv2", 2);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_okayv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_stophappyv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_thatsfunnyv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_thatsgreatv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_uhhuhv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_welldidyouseeemv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_wellimnotsurebutv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_yeahbuticanttellv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_youdidntohmygawdv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_youdidntohmygawdv2", 2);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_youknowittakessixv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_yourekiddingv1", 1);
	Addto(lCellPhoneTalk,						"WFemaleAltDialog.wf_cell_youwouldntbelievev1", 1);
	
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
	Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_goddamcommiev1", 1);
	//Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_hereyouforgotonev1", 1);
	//Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_hereyouforgotonev2", 2);
	Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_idiotv1", 1);
	Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_loserv1", 1);
	// This one doesn't quite work. - K
	//Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_onyourfacev1", 1);
	Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_stupidassholev1", 1);
	Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_stupidhairv1", 1);
	Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_suckstobeyouv1", 1);
	Addto(ldudedead,							"WFemaleAltDialog.wf_deadtaunt_usecoverv1", 1);

	Clear(lKickDead);
	//Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_goddamcommiev1", 1);
	Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_hereyouforgotonev1", 1);
	Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_hereyouforgotonev2", 2);
	Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_idiotv1", 1);
	Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_loserv1", 1);
	//Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_onyourfacev1", 1);
	//Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_stupidassholev1", 1);
	//Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_stupidhairv1", 1);
	Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_suckstobeyouv1", 1);
	//Addto(lKickDead,							"WFemaleAltDialog.wf_deadtaunt_usecoverv1", 1);

	//Clear(lNameCalling);
	//Addto(lNameCalling,							"", 1);

	Clear(lRogueCop);
	Addto(lRogueCop,							"WFemaleAltDialog.wf_seescop_atticav1", 1);
	Addto(lRogueCop,							"WFemaleAltDialog.wf_seescop_copsgonebatshitv1", 1);
	Addto(lRogueCop,							"WFemaleAltDialog.wf_seescop_ivelostmyfaithv1", 1);
	Addto(lRogueCop,							"WFemaleAltDialog.wf_seescop_powertohisheadv1", 1);
	Addto(lRogueCop,							"WFemaleAltDialog.wf_seescop_wheresmyvideov1", 1);
	Addto(lRogueCop,							"WFemaleAltDialog.wf_seescop_youtubev1", 1);

	Clear(lgetbumped);
	Addto(lgetbumped,							"WFemaleAltDialog.wf_bumped_cominthroughv1", 1);
	Addto(lgetbumped,							"WFemaleAltDialog.wf_bumped_heywatchitv1", 1);
	Addto(lgetbumped,							"WFemaleAltDialog.wf_bumped_heywatchitv2", 2);
	Addto(lgetbumped,							"WFemaleAltDialog.wf_bumped_lookoutv1", 1);
	Addto(lgetbumped,							"WFemaleAltDialog.wf_bumped_onesidev1", 1);
	Addto(lgetbumped,							"WFemaleAltDialog.wf_bumped_oofidiotv1", 1);
	Addto(lgetbumped,							"WFemaleAltDialog.wf_bumped_oofidiotv2", 2);

	Clear(lGetMad);
	Addto(lGetMad,								"WFemaleAltDialog.wf_bully_yougotanissuev1", 1);
	Addto(lGetMad,								"WFemaleAltDialog.wf_bumped_heywatchitv1", 1);
	Addto(lGetMad,								"WFemaleAltDialog.wf_bumped_heywatchitv2", 2);
	Addto(lGetMad,								"WFemaleAltDialog.wf_bumped_lookoutv1", 1);
	Addto(lGetMad,								"WFemaleAltDialog.wf_bumped_oofidiotv1", 1);
	Addto(lGetMad,								"WFemaleAltDialog.wf_bumped_oofidiotv2", 2);

	Clear(lLynchMob);
	Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_gethimv1", 1);
	Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_heyyouv1", 1);
	Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_idontlikethelookv1", 1);
	Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_idontlikethelookv2", 2);
	Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_thatstheonev1", 1);
	Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_thereheisv1", 1);
	Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_theressomethingv1", 1);
	Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_theressomethingv2", 2);
	Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_theresthekillerv1", 1);
	// doesn't fit. - K
	//Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_youdontbelongherev1", 1);
	//Addto(lLynchMob,							"WFemaleAltDialog.wf_lynch_youdontbelongherev2", 2);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"WFemaleAltDialog.wf_riot1v1", 1);
	Addto(lSeesEnemy,							"WFemaleAltDialog.wf_riot2v1", 1);
	Addto(lSeesEnemy,							"WFemaleAltDialog.wf_riot2v2", 2);
	Addto(lSeesEnemy,							"WFemaleAltDialog.wf_riot3v1", 1);
	Addto(lSeesEnemy,							"WFemaleAltDialog.wf_riot4v1", 1);

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
	Addto(lSignPetition,						"WFemaleAltDialog.wf_positive_imdownv1", 1);
	Addto(lSignPetition,						"WFemaleAltDialog.wf_positive_imdownv2", 2);
	Addto(lSignPetition,						"WFemaleAltDialog.wf_positive_okayilldoitv1", 1);
	Addto(lSignPetition,						"WFemaleAltDialog.wf_positive_okayilldoitv2", 2);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_absolutelynotv1", 1);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_absolutelynotv2", 2);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_asifv1", 1);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_asifv2", 2);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_fuckthatv1", 1);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_fuckthatv2", 2);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_fuckthatv3", 3);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_idontthinksov1", 1);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_idontthinksov2", 2);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_nothanksv1", 1);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_nothanksv2", 2);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_notinterestedv1", 1);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_notinterestedv2", 2);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_sorryv1", 1);
	Addto(lDontSignPetition,					"WFemaleAltDialog.wf_negative_sorryv2", 2);

	Clear(lPetitionBother);
	Addto(lPetitionBother,						"WFemaleAltDialog.wf_negative_goawayv1", 1);
	Addto(lPetitionBother,						"WFemaleAltDialog.wf_negative_goawayv2", 2);
	
	Clear(lChampPhotoReaction);
	Addto(lChampPhotoReaction,					"WFemaleAltDialog.wf_ghaspv2", 1);
	Addto(lChampPhotoReaction,					"WFemaleAltDialog.wf_ghaspv3", 2);
	Addto(lChampPhotoReaction,					"WFemaleAltDialog.wf_ghaspv4", 3);
	Addto(lChampPhotoReaction,					"WFemaleAltDialog.wf_seecarnage_nightmnarev1", 1);
	Addto(lChampPhotoReaction,					"WFemaleAltDialog.wf_seecarnage_nightmnarev2", 2);
	Addto(lChampPhotoReaction,					"WFemaleAltDialog.wf_seecarnage_ohmygodv1", 1);
	Addto(lChampPhotoReaction,					"WFemaleAltDialog.wf_seecarnage_thehorrorv1", 1);

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
	VolumeMult=0.70
}
