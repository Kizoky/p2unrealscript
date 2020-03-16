///////////////////////////////////////////////////////////////////////////////
// DialogMexicanMale
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all Mexican males
//
///////////////////////////////////////////////////////////////////////////////
class DialogMaleMex extends DialogMale;

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();

	Clear(lapplauding);
	AddTo(lApplauding,							"MMaleDialog.mm_cheer_gomanv1", 1);
	AddTo(lApplauding,							"MMaleDialog.mm_cheer_nowayv1", 1);
	AddTo(lApplauding,							"MMaleDialog.mm_cheer_nowayv2", 2);
	AddTo(lApplauding,							"MMaleDialog.mm_cheer_whatimtalkinboutv1", 1);
	AddTo(lApplauding,							"MMaleDialog.mm_cheer_wootv1", 1);
	AddTo(lApplauding,							"MMaleDialog.mm_cheer_yeahx2v1", 1);
	AddTo(lApplauding,							"MMaleDialog.mm_cheer_yeahx2v2", 2);

	Clear(lgreeting);
	Addto(lgreeting,							"MMaleDialog.mm_greet_heyv1", 1);
	Addto(lgreeting,							"MMaleDialog.mm_greet_heyv2", 2);
	Addto(lgreeting,							"MMaleDialog.mm_greet_holav1", 1);
	Addto(lgreeting,							"MMaleDialog.mm_greet_holav2", 2);

	Clear(lhotgreeting);
	Addto(lhotGreeting,							"MMaleDialog.mm_sleez_buenosv1", 1);
	Addto(lhotGreeting,							"MMaleDialog.mm_sleez_buenosv2", 2);
	Addto(lhotGreeting,							"MMaleDialog.mm_sleez_heybabyv1", 1);
	Addto(lhotGreeting,							"MMaleDialog.mm_sleez_heybabyv2", 2);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howareyouv1", 1);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howareyouv2", 2);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howsitgoingv1", 1);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howsitgoingv2", 2);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howsitgoingv3", 3);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howsitgoingv4", 4);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howsitgoingv5", 5);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howsitgoingv6", 6);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howyoudoinv1", 1);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_howyoudoinv2", 2);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_supv1", 1);
	Addto(lGreetingquestions,					"MMaleDialog.mm_greet_supv2", 2);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,				"MMaleDialog.mm_kindacalientev1", 1);
	Addto(lHotGreetingquestions,				"MMaleDialog.mm_kindacalientev2", 2);
	Addto(lHotGreetingquestions,				"MMaleDialog.mm_sleez_howsitgoingv1", 1);
	Addto(lHotGreetingquestions,				"MMaleDialog.mm_sleez_howsitgoingv2", 2);
	Addto(lHotGreetingquestions,				"MMaleDialog.mm_sleez_howyoudoinv1", 1);
	Addto(lHotGreetingquestions,				"MMaleDialog.mm_sleez_howyoudoinv2", 2);

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,				"MMaleDialog.mm_negative_notinterestedv1", 1);
	Addto(lrespondtohotgreeting,				"MMaleDialog.mm_negative_notinterestedv2", 2);
	Addto(lrespondtohotgreeting,				"MMaleDialog.mm_talkingtomev1", 1);
	Addto(lrespondtohotgreeting,				"MMaleDialog.mm_talkingtomev2", 2);
	Addto(lrespondtohotgreeting,				"MMaleDialog.mm_talkingtomev3", 3);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_beenbetterv1", 1);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_beenbetterv2", 2);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_brainwormsv1", 1);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_brainwormsv2", 2);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_brainwormsv3", 3);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_doiknowyouv1", 1);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_doiknowyouv2", 2);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_imhanginv1", 1);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_imhanginv2", 2);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_itsallgoodv1", 1);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_itsallgoodv2", 2);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_itsallgoodv3", 3);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_itsallgoodv4", 4);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_ohokayiguessv1", 1);
	Addto(lrespondtogreeting,					"MMaleDialog.mm_ohokayiguessv2", 2);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_gladtohearitv1", 1);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_gladtohearitv2", 2);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_noproblemv1", 1);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_noproblemv2", 2);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_noworriesv1", 1);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_noworriesv2", 2);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_thatblowsv1", 1);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_thatblowsv2", 2);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_thatsexcelantev1", 1);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_thatsexcelantev2", 2);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_watchyourselfv1", 1);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_watchyourselfv2", 2);
	Addto(lrespondtogreetingresponse,			"MMaleDialog.mm_watchyourselfv3", 3);

	Clear(lHelloCop);
	Addto(lHelloCop,								"MMaleDialog.mm_imamericanv1", 1);
	Addto(lHelloCop,								"MMaleDialog.mm_imamericanv2", 2);
	Addto(lHelloCop,								"MMaleDialog.mm_whatseemstobethev1", 1);
	Addto(lHelloCop,								"MMaleDialog.mm_whatseemstobethev2", 2);
	Addto(lHelloCop,								"MMaleDialog.mm_isanythingwrongv1", 1);
	
	//Clear(lHelloGimp);
	//Addto(lHelloGimp,							"", 1);

	Clear(lApologize);
	Addto(lApologize,							"MMaleDialog.mm_sorryyov1", 1);
	Addto(lApologize,							"MMaleDialog.mm_sorryyov2", 1);

	//Clear(lyourewelcome);
	//Addto(lyourewelcome,						"", 1);

	Clear(lno);
	Addto(lno,									"MMaleDialog.mm_negative_absolutelynotv1", 1);
	Addto(lno,									"MMaleDialog.mm_negative_absolutelynotv2", 2);
	Addto(lno,									"MMaleDialog.mm_negative_asifv1", 1);
	Addto(lno,									"MMaleDialog.mm_negative_asifv2", 2);
	Addto(lno,									"MMaleDialog.mm_negative_chalev1", 1);
	Addto(lno,									"MMaleDialog.mm_negative_chalev2", 2);
	Addto(lno,									"MMaleDialog.mm_negative_ithinknotv1", 1);
	Addto(lno,									"MMaleDialog.mm_negative_ithinknotv2", 2);
	Addto(lno,									"MMaleDialog.mm_negative_ithinknotv3", 3);
	Addto(lno,									"MMaleDialog.mm_negative_nawv1", 1);
	Addto(lno,									"MMaleDialog.mm_negative_nothanksv1", 1);
	Addto(lno,									"MMaleDialog.mm_negative_nothanksv2", 2);
	Addto(lno,									"MMaleDialog.mm_negative_nov1", 1);
	Addto(lno,									"MMaleDialog.mm_negative_nov2", 2);

	Clear(lyes);
	Addto(lyes,									"MMaleDialog.mm_positive_asfarasyouknowv1", 1);
	Addto(lyes,									"MMaleDialog.mm_positive_asfarasyouknowv2", 2);
	Addto(lyes,									"MMaleDialog.mm_positive_siv1", 1);
	Addto(lyes,									"MMaleDialog.mm_positive_siv2", 2);
	Addto(lyes,									"MMaleDialog.mm_positive_uhhunhv1", 1);
	Addto(lyes,									"MMaleDialog.mm_positive_uhhunhv2", 2);
	Addto(lyes,									"MMaleDialog.mm_positive_yeahv1", 1);
	Addto(lyes,									"MMaleDialog.mm_positive_yeahv2", 2);

	Clear(lthanks);
	Addto(lthanks,								"MMaleDialog.mm_coolthanksv1", 1);
	Addto(lthanks,								"MMaleDialog.mm_coolthanksv2", 2);
	Addto(lthanks,								"MMaleDialog.mm_positive_buenov1", 1);
	Addto(lthanks,								"MMaleDialog.mm_positive_buenov2", 2);
	Addto(lthanks,								"MMaleDialog.mm_positive_greatv1", 1);
	Addto(lthanks,								"MMaleDialog.mm_positive_greatv2", 2);
	Addto(lthanks,								"MMaleDialog.mm_positive_kickassv1", 1);
	Addto(lthanks,								"MMaleDialog.mm_positive_kickassv2", 2);
	Addto(lthanks,								"MMaleDialog.mm_positive_suenabienv1", 1);
	Addto(lthanks,								"MMaleDialog.mm_positive_suenabienv2", 2);
	Addto(lthanks,								"MMaleDialog.mm_positive_thatrocksv1", 1);
	Addto(lthanks,								"MMaleDialog.mm_positive_thatrocksv2", 2);
	Addto(lthanks,								"MMaleDialog.mm_positive_thatrocksv3", 3);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_buenov1", 1);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_buenov2", 2);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_greatv1", 1);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_greatv2", 2);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_kickassv1", 1);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_kickassv2", 2);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_suenabienv1", 1);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_suenabienv2", 2);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_thatrocksv1", 1);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_thatrocksv2", 2);
	Addto(lThatsGreat,							"MMaleDialog.mm_positive_thatrocksv3", 3);

	Clear(lGetDown);
	AddTo(lGetDown,								"MMaleDialog.mm_shotblocked1v1", 1);
	AddTo(lGetDown,								"MMaleDialog.mm_shotblocked1v2", 2);
	AddTo(lGetDown,								"MMaleDialog.mm_shotblocked3v1", 1);
	AddTo(lGetDown,								"MMaleDialog.mm_shotblocked3v2", 2);

	//Clear(lGetDownMP);
	//AddTo(lGetDownMP,							"", 1);

	Clear(lCussing);
	Addto(lCussing,								"MMaleDialog.mm_seecarnage_holyshitv1", 1);
	Addto(lCussing,								"MMaleDialog.mm_damage_carajov1", 1);
	Addto(lCussing,								"MMaleDialog.mm_damage_carajov2", 2);
	Addto(lCussing,								"MMaleDialog.mm_damage_chingav1", 1);
	Addto(lCussing,								"MMaleDialog.mm_damage_chingav2", 2);

	//Clear(lgetdownscared);
	//Addto(lgetdownscared,						"", 1);

	Clear(ldefiant);
	Addto(ldefiant,								"MMaleDialog.mm_bully_whatyoulookingatv1", 1);
	Addto(ldefiant,								"MMaleDialog.mm_bully_whatyoulookingatv2", 2);
	Addto(ldefiant,								"MMaleDialog.mm_bully_yougotaproblemv1", 1);
	Addto(ldefiant,								"MMaleDialog.mm_bully_yougotaproblemv2", 2);

	Clear(ldefiantline);
	Addto(ldefiantline,							"MMaleDialog.mm_bully_yougotaproblemv1", 1);
	Addto(ldefiantline,							"MMaleDialog.mm_bully_yougotaproblemv2", 2);
	Addto(ldefiantline,							"MMaleDialog.mm_bumped_heywatchitv1", 1);
	Addto(ldefiantline,							"MMaleDialog.mm_bumped_heywatchitv2", 2);
	Addto(ldefiantline,							"MMaleDialog.mm_bumped_lookoutv1", 1);
	Addto(ldefiantline,							"MMaleDialog.mm_bumped_lookoutv2", 2);
	Addto(ldefiantline,							"MMaleDialog.mm_bumped_lookoutv3", 3);
	Addto(ldefiantline,							"MMaleDialog.mm_bumped_onesidev1", 1);
	Addto(ldefiantline,							"MMaleDialog.mm_bumped_oofchapetev1", 1);
	Addto(ldefiantline,							"MMaleDialog.mm_bumped_oofchapetev2", 2);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"MMaleDialog.mm_seecarnage_holyshitv1", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"MMaleDialog.mm_riot_1v1", 1);
	Addto(ldecidetofight,						"MMaleDialog.mm_riot_2v1", 1);
	Addto(ldecidetofight,						"MMaleDialog.mm_riot_3v1", 1);
	Addto(ldecidetofight,						"MMaleDialog.mm_riot_4v1", 1);
	Addto(ldecidetofight,						"MMaleDialog.mm_riot_4v2", 2);
	Addto(ldecidetofight,						"MMaleDialog.mm_riot_5v1", 1);
	Addto(ldecidetofight,						"MMaleDialog.mm_riot_5v2", 2);

	Clear(llaughing);
	Addto(llaughing,							"MMaleDialog.mm_laughv1", 1);
	Addto(llaughing,							"MMaleDialog.mm_laughv2", 2);

	Clear(lSnickering);
	Addto(lSnickering,							"MMaleDialog.mm_snickerv1", 1);
	Addto(lSnickering,							"MMaleDialog.mm_snickerv2", 2);

	//Clear(lOutOfBreath);
	//Addto(lOutOfBreath,							"", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_followup_areyouonshroomsv1", 1);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_followup_estupidov1", 1);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_seepanic_1v1", 1);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_seepanic_1v2", 2);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_seepanic_1v3", 3);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_seepanic_2v1", 1);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_seepanic_2v2", 2);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_seepanic_2v3", 3);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_seepanic_2v4", 4);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_seepanic_2v5", 5);
	Addto(lWatchingCrazy,						"MMaleDialog.mm_seepanic_4v1", 1);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,					"MMaleDialog.mm_getcop_helppolicev1", 1);
	Addto(lshootingoverthere,					"MMaleDialog.mm_getcop_policex2v1", 1);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,					"MMaleDialog.mm_getcop_helppolicev1", 1);
	Addto(lkillingoverthere,					"MMaleDialog.mm_getcop_policex2v1", 1);
	Addto(lkillingoverthere,					"MMaleDialog.mm_heargun_blastingpeoplev1", 1);
	Addto(lkillingoverthere,					"MMaleDialog.mm_heargun_gunningpeoplev1", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,							"MMaleDialog.mm_scream1", 1);
	Addto(lscreaming,							"MMaleDialog.mm_scream2", 1);
	Addto(lscreaming,							"MMaleDialog.mm_scream3", 1);
	Addto(lscreaming,							"MMaleDialog.mm_scream4", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_awghelpmev1", 1);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_awghelpmev2", 2);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_babyjesusv1", 1);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_babyjesusv2", 2);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_babyjesusv3", 3);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_fiyaaav1", 1);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_fiyaaav2", 2);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_fiyaaav3", 3);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_imburningv1", 1);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_imburningv2", 2);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_imburningv3", 3);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_putmeoutv1", 1);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_yeaghv1", 1);
	Addto(lscreamingonfire,						"MMaleDialog.mm_onfire_yeaghv2", 2);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_bringitv1", 1);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_bringitv2", 2);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_howaboutsomeofthisv1", 1);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_howaboutsomeofthisv2", 2);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_rahv1", 1);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_rahv2", 2);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_rahv3", 3);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_youthinkimscaredv1", 1);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_youthinkimscaredv2", 2);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_youthinkimscaredv3", 3);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_youthinkimscaredv4", 4);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_youthinkyoucanv1", 1);
	Addto(lDoHeroics,							"MMaleDialog.mm_tough_youthinkyoucanv2", 2);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"MMaleDialog.mm_spitoutpissv1", 1);
	Addto(lgettingpissedon,						"MMaleDialog.mm_spitoutpissv2", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_assholev1", 1);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_assholev2", 2);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_disgustingv1", 1);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_disgustingv2", 2);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_eughv1", 1);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_eughv2", 2);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_myshirtv1", 1);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_myshirtv2", 2);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_pinchev1", 1);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_pinchev2", 2);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_sickv1", 1);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_sickv2", 2);
	Addto(laftergettingpissedon,				"MMaleDialog.mm_pissedon_virginmaryv1", 1);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"MMaleDialog.mm_huhv1", 1);
	Addto(lwhatthe,								"MMaleDialog.mm_huhv2", 2);
	Addto(lwhatthe,								"MMaleDialog.mm_pissedon_heeyv1", 1);
	Addto(lwhatthe,								"MMaleDialog.mm_pissedon_heeyv2", 2);
	Addto(lwhatthe,								"MMaleDialog.mm_pissedon_whatthev1", 1);
	Addto(lwhatthe,								"MMaleDialog.mm_pissedon_whatthev2", 2);
	Addto(lwhatthe,								"MMaleDialog.mm_pissedon_whuhv1", 1);
	Addto(lwhatthe,								"MMaleDialog.mm_pissedon_whuhv2", 2);
	Addto(lwhatthe,								"MMaleDialog.mm_thefuckv1", 1);
	Addto(lwhatthe,								"MMaleDialog.mm_thefuckv2", 2);

	Clear(lseeingpisser);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing1v1", 1);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing1v2", 2);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing1v3", 3);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing1v4", 1);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing2v1", 1);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing2v2", 2);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing3v1", 1);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing3v2", 2);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing3v3", 3);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing4v1", 1);
	Addto(lseeingpisser,						"MMaleDialog.mm_seepissing4v2", 2);

	//Clear(lSomethingIsGross);
	//Addto(lSomethingIsGross,					"", 1);

	Clear(lgothit);
	Addto(lgothit,								"MMaleDialog.mm_damage_aghkv1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_aiieev1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_aiieev2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_aiieev3", 3);
	Addto(lgothit,								"MMaleDialog.mm_damage_akv1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_akv2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_arghv1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_arghv2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_aughv1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_badtouchv1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_badtouchv2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_carajov1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_carajov2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_chingav1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_chingav2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_gakv1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_higadov1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_imhitv1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_jesusv1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_jesusv2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_mommav1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_mommav2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_mommav3", 3);
	Addto(lgothit,								"MMaleDialog.mm_damage_myeyev1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_myeyev2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_owv1", 1);
	Addto(lgothit,								"MMaleDialog.mm_damage_owv2", 2);
	Addto(lgothit,								"MMaleDialog.mm_damage_owv3", 3);

	Clear(lAttacked);
	Addto(lAttacked,							"MMaleDialog.mm_damage_aghkv1", 1);
	Addto(lAttacked,							"MMaleDialog.mm_damage_akv1", 1);
	Addto(lAttacked,							"MMaleDialog.mm_damage_akv2", 2);
	Addto(lAttacked,							"MMaleDialog.mm_damage_arghv1", 1);
	Addto(lAttacked,							"MMaleDialog.mm_damage_arghv2", 2);
	Addto(lAttacked,							"MMaleDialog.mm_damage_aughv1", 1);
	Addto(lAttacked,							"MMaleDialog.mm_damage_gakv1", 1);

	Clear(lGrunt);
	Addto(lGrunt,								"MMaleDialog.mm_damage_aghkv1", 1);
	Addto(lGrunt,								"MMaleDialog.mm_damage_akv1", 1);
	Addto(lGrunt,								"MMaleDialog.mm_damage_akv2", 2);
	Addto(lGrunt,								"MMaleDialog.mm_damage_arghv1", 1);
	Addto(lGrunt,								"MMaleDialog.mm_damage_arghv2", 2);
	Addto(lGrunt,								"MMaleDialog.mm_damage_aughv1", 1);
	Addto(lGrunt,								"MMaleDialog.mm_damage_gakv1", 1);

	Clear(lPissing);
	Addto(lPissing,								"MMaleDialog.mm_pissing_floodgatesv1", 1);
	Addto(lPissing,								"MMaleDialog.mm_pissing_littleflowersv1", 1);
	Addto(lPissing,								"MMaleDialog.mm_pissing_ohyeahv1", 1);
	Addto(lPissing,								"MMaleDialog.mm_pissing_ohyeahv2", 2);
	Addto(lPissing,								"MMaleDialog.mm_pissing_talkinboutv1", 1);
	Addto(lPissing,								"MMaleDialog.mm_pissing_talkinboutv2", 2);

	//Clear(lPissOnSelf);
	//Addto(lPissOnSelf,							"", 1);
	
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
	addto(lGotHitInCrotch,						"MMaleDialog.mm_damage_higadov1", 1);	

	Clear(lbegforlife);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_cryingv1", 1);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_cryingv2", 1);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_cryingv3", 1);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_dontsnuffmev1", 1);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_dontsnuffmev2", 2);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_pleasedontkillmev1", 1);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_pleasedontkillmev2", 2);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_pleasepleasenov1", 1);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_pleasepleasenov2", 2);
	Addto(lbegforlife,							"MMaleDialog.mm_beg_snivel1v1", 1);
	Addto(lbegforlife,							"MMaleDialog.mm_fearful_donthurtmev1", 1);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_cryingv1", 1);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_cryingv2", 1);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_cryingv3", 1);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_dontsnuffmev1", 1);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_dontsnuffmev2", 2);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_pleasedontkillmev1", 1);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_pleasedontkillmev2", 2);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_pleasepleasenov1", 1);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_pleasepleasenov2", 2);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_beg_snivel1v1", 1);
	Addto(lbegforlifeMin,						"MMaleDialog.mm_fearful_donthurtmev1", 1);
	
	//Clear(ldying);
	//Addto(ldying,								"", 1);

	Clear(lCrying);
	Addto(lCrying,								"MMaleDialog.mm_beg_cryingv1", 1);
	Addto(lCrying,								"MMaleDialog.mm_beg_cryingv2", 1);
	Addto(lCrying,								"MMaleDialog.mm_beg_cryingv3", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,					"MMaleDialog.mm_beg_didntmeanitv1", 1);	
	Addto(lfrightenedapology,					"MMaleDialog.mm_beg_didntmeanitv2", 2);	
	Addto(lfrightenedapology,					"MMaleDialog.mm_beg_didntmeanitv3", 3);	
	Addto(lfrightenedapology,					"MMaleDialog.mm_beg_neveragainv1", 1);	
	Addto(lfrightenedapology,					"MMaleDialog.mm_beg_neveragainv2", 2);	
	Addto(lfrightenedapology,					"MMaleDialog.mm_beg_neveragainv3", 3);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"MMaleDialog.mm_taunt_cmonfightlikeamanv1", 1);
	Addto(ltrashtalk,							"MMaleDialog.mm_taunt_cmonfightlikeamanv2", 2);
	Addto(ltrashtalk,							"MMaleDialog.mm_taunt_ohyeahbigmanwithav1", 1);
	Addto(ltrashtalk,							"MMaleDialog.mm_taunt_ohyeahbigmanwithav2", 2);
	Addto(ltrashtalk,							"MMaleDialog.mm_taunt_whereyougoingmariconv1", 1);
	Addto(ltrashtalk,							"MMaleDialog.mm_taunt_yourenotsotoughv1", 1);
	Addto(ltrashtalk,							"MMaleDialog.mm_taunt_yourenotsotoughv2", 2);
	Addto(ltrashtalk,							"MMaleDialog.mm_taunt_yourenotsotoughv3", 3);

	Clear(lWhileFighting);
	Addto(lWhileFighting,						"MMaleDialog.mm_taunt_cmonfightlikeamanv1", 1);
	Addto(lWhileFighting,						"MMaleDialog.mm_taunt_cmonfightlikeamanv2", 2);
	Addto(lWhileFighting,						"MMaleDialog.mm_taunt_ohyeahbigmanwithav1", 1);
	Addto(lWhileFighting,						"MMaleDialog.mm_taunt_ohyeahbigmanwithav2", 2);
	Addto(lWhileFighting,						"MMaleDialog.mm_taunt_whereyougoingmariconv1", 1);
	Addto(lWhileFighting,						"MMaleDialog.mm_taunt_yourenotsotoughv1", 1);
	Addto(lWhileFighting,						"MMaleDialog.mm_taunt_yourenotsotoughv2", 2);
	Addto(lWhileFighting,						"MMaleDialog.mm_taunt_yourenotsotoughv3", 3);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,						"MMaleDialog.mm_whatseemstobethev1", 1);
	Addto(laskcopwhatsup,						"MMaleDialog.mm_whatseemstobethev2", 2);

	Clear(lratout);
	Addto(lratout,								"MMaleDialog.mm_report_hediditv1", 1);
	Addto(lratout,								"MMaleDialog.mm_report_hediditv2", 2);
	Addto(lratout,								"MMaleDialog.mm_report_hediditv3", 3);
	Addto(lratout,								"MMaleDialog.mm_report_hestheonev1", 1);
	Addto(lratout,								"MMaleDialog.mm_report_hestheonev2", 2);
	Addto(lratout,								"MMaleDialog.mm_report_itwashimv1", 1);
	Addto(lratout,								"MMaleDialog.mm_report_itwashimv2", 2);
	Addto(lratout,								"MMaleDialog.mm_report_thatguyv1", 1);
	Addto(lratout,								"MMaleDialog.mm_report_thatguyv2", 2);
	Addto(lratout,								"MMaleDialog.mm_report_thatguyv3", 3);
	Addto(lratout,								"MMaleDialog.mm_report_thatguyv4", 4);
	Addto(lratout,								"MMaleDialog.mm_report_thatguyv5", 5);
	Addto(lratout,								"MMaleDialog.mm_report_thechumpovertherev1", 1);
	Addto(lratout,								"MMaleDialog.mm_report_thechumpovertherev2", 2);
	Addto(lratout,								"MMaleDialog.mm_report_thechumpovertherev3", 3);
	Addto(lratout,								"MMaleDialog.mm_report_thechumpovertherev4", 4);

	Clear(lfakeratout);
	Addto(lfakeratout,							"MMaleDialog.mm_lying_hediditisawv1", 1);
	Addto(lfakeratout,							"MMaleDialog.mm_lying_hediditisawv2", 2);
	Addto(lfakeratout,							"MMaleDialog.mm_lying_imawitnessv1", 1);
	Addto(lfakeratout,							"MMaleDialog.mm_lying_imawitnessv2", 2);

	Clear(lcleanshot);
	Addto(lcleanshot,							"MMaleDialog.mm_shotblocked2v1", 1);
	Addto(lcleanshot,							"MMaleDialog.mm_shotblocked2v2", 2);
	Addto(lcleanshot,							"MMaleDialog.mm_shotblocked3v1", 1);
	Addto(lcleanshot,							"MMaleDialog.mm_shotblocked3v2", 2);
	Addto(lcleanshot,							"MMaleDialog.mm_shotblocked4v1", 1);
	Addto(lcleanshot,							"MMaleDialog.mm_shotblocked4v2", 2);
	Addto(lcleanshot,							"MMaleDialog.mm_shotblocked4v3", 3);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"MMaleDialog.mm_shotblocked2v1", 1);
	Addto(lCleanMeleeHit,						"MMaleDialog.mm_shotblocked2v2", 2);
	Addto(lCleanMeleeHit,						"MMaleDialog.mm_shotblocked3v1", 1);
	Addto(lCleanMeleeHit,						"MMaleDialog.mm_shotblocked3v2", 2);

	Clear(lInhale);
	Addto(lInhale,								"WMaleDialog.wm_inhale", 1);
												
	Clear(lExhale);								
	Addto(lExhale,								"WMaleDialog.wm_exhale", 1);
	
	/*
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
	*/
	
	Clear(lhmm);
	Addto(lhmm,									"MMaleDialog.mm_hmmmmv1", 1);
	Addto(lhmm,									"MMaleDialog.mm_hmmmmv2", 2);

	//Clear(lfollowme);
	//Addto(lfollowme,							"", 1);	

	//Clear(lStayHere);
	//Addto(lStayHere,							"", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,						"MMaleDialog.mm_seewang_chillitov1", 1);
	Addto(lnoticedickout,						"MMaleDialog.mm_seewang_chillitov2", 2);
	Addto(lnoticedickout,						"MMaleDialog.mm_seewang_corralisopenv1", 1);
	Addto(lnoticedickout,						"MMaleDialog.mm_seewang_dontmakemeseev1", 1);
	Addto(lnoticedickout,						"MMaleDialog.mm_seewang_havesomedignityv1", 1);
	Addto(lnoticedickout,						"MMaleDialog.mm_seewang_havesomedignityv2", 2);
	Addto(lnoticedickout,						"MMaleDialog.mm_seewang_havesomedignityv3", 3);

	/*
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
	*/

	Clear(lGoPostal);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_gonnaregretv1", 1);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_gonnaregretv2", 2);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_illusethisv1", 1);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_illusethisv2", 2);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_makemealocatev1", 1);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_matracav1", 1);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_matracav2", 2);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_wrongvatov1", 1);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_wrongvatov2", 2);
	Addto(lGoPostal,							"MMaleDialog.mm_postal_wrongvatov3", 3);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_fearful_isnthappeningv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_fearful_shitgetoutv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_fearful_shitgetoutv2", 2);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_ghaspv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_ghaspv2", 2);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_ghaspv3", 3);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_ghaspv4", 4);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_ainthappeningv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_anyoneseethatv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_anyoneseethatv2", 2);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_callambulancev1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_callgalavisionv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_callgalavisionv2", 2);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_callnationalguardv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_goingtohurlv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_helpv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_holyfuckv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_holyshitv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_jesushelpmev1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_jesushelpmev2", 2);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_justkilledthatguyv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_justkilledthatguyv2", 2);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_killingeveryonev1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_killingeveryonev2", 2);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_killingeveryonev3", 3);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_killingeveryonev4", 4);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_makeitstopv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_makeitstopv2", 2);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_makeitstopv3", 3);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_notagainv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_ohmygodv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_outtaherev1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_outtaherev2", 2);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_runrunv1", 1);
	Addto(lcarnageoccurred,						"MMaleDialog.mm_seecarnage_sweetlordnov1", 1);

	Clear(lCallCat);
	Addto(lCallCat, 							"MMaleDialog.mm_likescat_herekittyv1", 1);
	Addto(lCallCat, 							"MMaleDialog.mm_likescat_heytheregatov1", 1);
	Addto(lCallCat, 							"MMaleDialog.mm_likescat_heytheregatov2", 2);

	Clear(lHateCat);
	Addto(lHateCat, 							"MMaleDialog.mm_hatescat_fleabagv1", 1);
	Addto(lHateCat, 							"MMaleDialog.mm_hatescat_fleabagv2", 2);
	Addto(lHateCat, 							"MMaleDialog.mm_hatescat_fleabagv3", 3);
	Addto(lHateCat, 							"MMaleDialog.mm_hatescat_getoutfurballv1", 1);
	Addto(lHateCat, 							"MMaleDialog.mm_hatescat_getoutfurballv2", 2);
	Addto(lHateCat, 							"MMaleDialog.mm_hatescat_herekittyevilv1", 1);
	Addto(lHateCat, 							"MMaleDialog.mm_hatescat_herekittyevilv2", 2);

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"MMaleDialog.mm_seecarnage_holyshitv1", 1);
	Addto(lStartAttackingAnimal,				"MMaleDialog.mm_damage_carajov1", 1);
	Addto(lStartAttackingAnimal,				"MMaleDialog.mm_damage_carajov2", 2);
	Addto(lStartAttackingAnimal,				"MMaleDialog.mm_damage_chingav1", 1);
	Addto(lStartAttackingAnimal,				"MMaleDialog.mm_damage_chingav2", 2);

	//Clear(lGettingRobbed);	
	//Addto(lGettingRobbed,						"", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"MMaleDialog.mm_fearful_donthurtmev1", 1);
	Addto(lGettingMugged,						"MMaleDialog.mm_ghaspv1", 1);
	Addto(lGettingMugged,						"MMaleDialog.mm_ghaspv2", 2);
	Addto(lGettingMugged,						"MMaleDialog.mm_ghaspv3", 3);
	Addto(lGettingMugged,						"MMaleDialog.mm_ghaspv4", 4);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"MMaleDialog.mm_getcop_callacopv1", 1);
	Addto(lAfterMugged,							"MMaleDialog.mm_getcop_callthepigsv1", 1);
	Addto(lAfterMugged,							"MMaleDialog.mm_getcop_helppolicev1", 1);
	Addto(lAfterMugged,							"MMaleDialog.mm_getcop_policex2v1", 1);

	//Clear(lDoMugging);	
	//Addto(lDoMugging,							"", 3);
	
	//Clear(lQuestion);	
	//Addto(lQuestion,							"", 1);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_cincodemayov1", 1);
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_cincodemayov2", 2);
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_dialogissolamev1", 1);
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_marmosetsv1", 1);
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_swallowthewormv1", 1);
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_swallowthewormv2", 2);
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_swallowthewormv3", 3);
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_swallowthewormv4", 4);
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_whatreyouuptov1", 1);
	Addto(lGenericQuestion,						"MMaleDialog.mm_call_whatreyouuptov2", 2);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"MMaleDialog.mm_question_idontcarev1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_question_idontcarev2", 2);
	Addto(lGenericAnswer,						"MMaleDialog.mm_question_whatareyoutalkingv1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_question_whatareyoutalkingv2", 2);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_areyouanidiotv1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_areyouanidiotv2", 2);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_icecreamv1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_isthisatestv1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_isthisatestv2", 2);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_onyoutubev1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_upyourassv1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_upyourassv2", 2);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_upyourassv3", 3);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_whatswrongwithyouv1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_whenyouretalkingv1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_whenyouretalkingv2", 2);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_whothefuckknowsv1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_whothefuckknowsv2", 2);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_youkeeptalkingv1", 1);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_youkeeptalkingv2", 2);
	Addto(lGenericAnswer,						"MMaleDialog.mm_response_youkeeptalkingv3", 3);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"MMaleDialog.mm_followup_areyouevenlisteningv1", 1);
	Addto(lGenericFollowup,						"MMaleDialog.mm_followup_areyouonshroomsv1", 1);
	Addto(lGenericFollowup,						"MMaleDialog.mm_followup_estupidov1", 1);
	Addto(lGenericFollowup,						"MMaleDialog.mm_followup_saywhatv1", 1);
	Addto(lGenericFollowup,						"MMaleDialog.mm_followup_stopdoingthatv1", 1);
	Addto(lGenericFollowup,						"MMaleDialog.mm_followup_whatsthatshitv1", 1);
	Addto(lGenericFollowup,						"MMaleDialog.mm_followup_whatsthatshitv2", 2);

	Clear(lGenericGoodbye);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_checkyoulaterv1", 1);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_confusednowv1", 1);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_greatseeingyouv1", 1);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_greatseeingyouv2", 2);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_lamestv1", 1);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_outtaherev1", 1);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_outtaherev2", 2);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_seeyoulaterv1", 1);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_seeyoulaterv2", 2);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_seeyoulaterv3", 3);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_yourelocov1", 1);
	Addto(lGenericGoodbye,						"MMaleDialog.mm_leadout_yourelocov2", 2);

	//Clear(linvadeshome);	
	//Addto(linvadeshome,							"", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seefire__whatsmellsv1", 1);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seefire__whatsmellsv2", 2);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seefire_firex2v1", 1);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seefire_firex2v2", 2);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seefire_holyshitv1", 1);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seefire_holyshitv2", 2);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seefire_ismellfrijolesv1", 1);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seeonfire_burningv1", 1);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seeonfire_dropandrollv1", 1);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seeonfire_hesonfirev1", 1);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seeonfire_puthimoutv1", 1);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seeonfire_puthimoutv2", 2);
	Addto(lsomeoneonfire,						"MMaleDialog.mm_seeonfire_puthimoutv3", 3);
	
	Clear(labouttopuke);
	Addto(labouttopuke,							"MMaleDialog.mm_puke_ifeellikeshitv1", 1);
	Addto(labouttopuke,							"MMaleDialog.mm_puke_ifeellikeshitv2", 2);
	Addto(labouttopuke,							"MMaleDialog.mm_puke_ohgodimv1", 1);
	Addto(labouttopuke,							"MMaleDialog.mm_puke_ohgodimv2", 2);
	Addto(labouttopuke,							"MMaleDialog.mm_puke_ohmanimgonnahurlv1", 1);
	Addto(labouttopuke,							"MMaleDialog.mm_puke_ohmanimgonnahurlv2", 2);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,						"MMaleDialog.mm_vomitv1", 1);

	//Clear(lGettingShocked);
	//Addto(lGettingShocked,						"", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,							"HabibDialog.habib_ailili", 1);

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_cincodemayov1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_cincodemayov2", 2);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_dialogissolamev1", 1);
	//Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_madscientistlabv1", 1);
	//Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_madscientistlabv2", 2);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_marmosetsv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_swallowthewormv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_swallowthewormv2", 2);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_swallowthewormv3", 3);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_swallowthewormv4", 4);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_whatreyouuptov1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_call_whatreyouuptov2", 2);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_blacklightv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_blacklightv2", 2);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_burningdrippingv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_burningdrippingv2", 2);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_femaleelvisv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_femaleelvisv2", 2);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_hadtowaitv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_horseshitcigarettesv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_okayv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_smelltheculov1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_smelltheculov2", 2);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_somewetov1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_stophappyv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_thatsfunnyv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_thatsgreatv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_thatswhatithoughtv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_thatswhatithoughtv2", 2);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_thatswhatithoughtv3", 3);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_thebadgersv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_uhhuhv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_youcantdothatv1", 1);
	Addto(lCellPhoneTalk,						"MMaleDialog.mm_cell_youcantdothatv2", 2);
	
	/*
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
	*/
	
	Clear(ldudedead);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_blameloudobbsv1", 1);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_blameloudobbsv2", 2);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_bujarronv1", 1);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_bujarronv2", 2);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_cheatcodesv1", 1);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_cheatcodesv2", 2);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_prollyhomov1", 1);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_prollyhomov2", 2);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_prollyhomov3", 3);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_shouldatriedharderv1", 1);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_shouldatriedharderv2", 2);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_whowasthatv1", 1);
	Addto(ldudedead,							"MMaleDialog.mm_deadtaunt_whowasthatv2", 2);

	Clear(lKickDead);
	Addto(lKickDead,							"MMaleDialog.mm_deadtaunt_lookatthisonev1", 1);
	Addto(lKickDead,							"MMaleDialog.mm_deadtaunt_lookatthisonev2", 2);
	Addto(lKickDead,							"MMaleDialog.mm_deadtaunt_oneformotherv1", 1);
	Addto(lKickDead,							"MMaleDialog.mm_deadtaunt_oneformotherv2", 2);
	Addto(lKickDead,							"MMaleDialog.mm_deadtaunt_takethisonev1", 1);
	Addto(lKickDead,							"MMaleDialog.mm_deadtaunt_takethisonev2", 2);

	//Clear(lNameCalling);
	//Addto(lNameCalling,							"", 1);

	Clear(lRogueCop);
	Addto(lRogueCop,							"MMaleDialog.mm_seecarnage_ifihadacamerav1", 1);
	Addto(lRogueCop,							"MMaleDialog.mm_seecarnage_ifihadacamerav2", 2);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_abusev1", 1);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_abusev2", 2);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_gonelocov1", 1);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_keepingusdownv1", 1);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_keepingusdownv2", 2);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_paidleavev1", 1);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_paidleavev2", 2);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_stillhasajobv1", 1);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_stillhasajobv2", 2);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_typicalv1", 1);
	Addto(lRogueCop,							"MMaleDialog.mm_seescop_typicalv2", 2);

	Clear(lgetbumped);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_cominthroughv1", 1);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_cominthroughv2", 2);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_heywatchitv1", 1);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_heywatchitv2", 2);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_lookoutv1", 1);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_lookoutv2", 2);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_lookoutv3", 3);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_onesidev1", 1);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_oofchapetev1", 1);
	Addto(lgetbumped,							"MMaleDialog.mm_bumped_oofchapetev2", 2);

	Clear(lGetMad);
	Addto(lGetMad,								"MMaleDialog.mm_bumped_heywatchitv1", 1);
	Addto(lGetMad,								"MMaleDialog.mm_bumped_heywatchitv2", 2);
	Addto(lGetMad,								"MMaleDialog.mm_bumped_lookoutv1", 1);
	Addto(lGetMad,								"MMaleDialog.mm_bumped_lookoutv2", 2);
	Addto(lGetMad,								"MMaleDialog.mm_bumped_lookoutv3", 3);
	Addto(lGetMad,								"MMaleDialog.mm_bumped_oofchapetev1", 1);
	Addto(lGetMad,								"MMaleDialog.mm_bumped_oofchapetev2", 2);
	Addto(lGetMad,								"MMaleDialog.mm_bully_yougotaproblemv1", 1);
	Addto(lGetMad,								"MMaleDialog.mm_bully_yougotaproblemv2", 2);
	Addto(lGetMad,								"MMaleDialog.mm_damage_owv1", 1);
	Addto(lGetMad,								"MMaleDialog.mm_damage_owv2", 2);
	Addto(lGetMad,								"MMaleDialog.mm_damage_owv3", 3);

	Clear(lLynchMob);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_gethimv1", 1);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_heyyouv1", 1);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_idontlikethelookv1", 1);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_thatstheonev1", 1);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_thatstheonev2", 2);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_thatstheonev3", 3);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_thereheisv1", 1);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_thereheisv2", 2);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_theresthekillerv1", 1);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_theresthekillerv2", 2);
	Addto(lLynchMob,							"MMaleDialog.mm_lynch_theresthekillerv3", 3);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"MMaleDialog.mm_lynch_gethimv1", 1);
	Addto(lSeesEnemy,							"MMaleDialog.mm_lynch_heyyouv1", 1);
	Addto(lSeesEnemy,							"MMaleDialog.mm_lynch_thereheisv1", 1);
	Addto(lSeesEnemy,							"MMaleDialog.mm_lynch_thereheisv2", 2);
	Addto(lSeesEnemy,							"MMaleDialog.mm_tough_howaboutsomeofthisv1", 1);
	Addto(lSeesEnemy,							"MMaleDialog.mm_tough_howaboutsomeofthisv2", 2);
	Addto(lSeesEnemy,							"MMaleDialog.mm_tough_rahv1", 1);
	Addto(lSeesEnemy,							"MMaleDialog.mm_tough_rahv2", 2);
	Addto(lSeesEnemy,							"MMaleDialog.mm_tough_rahv3", 3);

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
	Addto(lSignPetition,						"MMaleDialog.mm_positive_giveitawhirlv1", 1);
	Addto(lSignPetition,						"MMaleDialog.mm_positive_giveitawhirlv2", 2);
	Addto(lSignPetition,						"MMaleDialog.mm_positive_imdownv1", 1);
	Addto(lSignPetition,						"MMaleDialog.mm_positive_imdownv2", 2);
	Addto(lSignPetition,						"MMaleDialog.mm_positive_surethingv1", 1);
	Addto(lSignPetition,						"MMaleDialog.mm_positive_surethingv2", 2);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_absolutelynotv1", 1);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_absolutelynotv2", 2);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_asifv1", 1);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_asifv2", 2);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_chalev1", 1);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_chalev2", 2);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_ithinknotv1", 1);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_ithinknotv2", 2);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_ithinknotv3", 3);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_nothanksv1", 1);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_nothanksv2", 2);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_notinterestedv1", 1);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_notinterestedv2", 2);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_sorryv1", 1);
	Addto(lDontSignPetition,					"MMaleDialog.mm_negative_sorryv2", 2);

	Clear(lPetitionBother);
	Addto(lPetitionBother,						"MMaleDialog.mm_followup_stopdoingthatv1", 1);
	
	Clear(lChampPhotoReaction);
	Addto(lChampPhotoReaction,					"MMaleDialog.mm_ghaspv2", 1);
	Addto(lChampPhotoReaction,					"MMaleDialog.mm_ghaspv3", 2);
	Addto(lChampPhotoReaction,					"MMaleDialog.mm_ghaspv4", 3);
	Addto(lChampPhotoReaction,					"MMaleDialog.mm_seecarnage_holyfuckv1", 1);
	Addto(lChampPhotoReaction,					"MMaleDialog.mm_seecarnage_holyshitv1", 1);
	Addto(lChampPhotoReaction,					"MMaleDialog.mm_seecarnage_jesushelpmev1", 1);
	Addto(lChampPhotoReaction,					"MMaleDialog.mm_seecarnage_jesushelpmev2", 2);
	Addto(lChampPhotoReaction,					"MMaleDialog.mm_seecarnage_ohmygodv1", 1);
	Addto(lChampPhotoReaction,					"MMaleDialog.mm_seecarnage_sweetlordnov1", 1);

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
	VolumeMult=0.8
}
