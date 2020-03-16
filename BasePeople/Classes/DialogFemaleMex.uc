///////////////////////////////////////////////////////////////////////////////
// DialogMexicanFemale
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all Mexican females
//
///////////////////////////////////////////////////////////////////////////////
class DialogFemaleMex extends DialogFemale;

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();

	Clear(lapplauding);
	AddTo(lApplauding,							"MFemaleDialog.mf_cheer_awesomeV1", 1);
	AddTo(lApplauding,							"MFemaleDialog.mf_cheer_booyeahV1", 1);
	AddTo(lApplauding,							"MFemaleDialog.mf_cheer_nowayV1", 1);
	AddTo(lApplauding,							"MFemaleDialog.mf_cheer_whatimtalkinV1", 1);
	AddTo(lApplauding,							"MFemaleDialog.mf_cheer_wootV1", 1);
	AddTo(lApplauding,							"MFemaleDialog.mf_cheer_wootV2", 2);
	AddTo(lApplauding,							"MFemaleDialog.mf_cheer_yeahV1", 1);

	Clear(lgreeting);
	Addto(lgreeting,							"MFemaleDialog.mf_greet_heyV1", 1);
	Addto(lgreeting,							"MFemaleDialog.mf_greet_heyV2", 2);
	Addto(lgreeting,							"MFemaleDialog.mf_greet_holaV1", 1);
	Addto(lgreeting,							"MFemaleDialog.mf_greet_holaV2", 2);
	Addto(lgreeting,							"MFemaleDialog.mf_greet_holaV3", 3);
	Addto(lgreeting,							"MFemaleDialog.mf_greet_yoV1", 1);

	Clear(lhotgreeting);
	Addto(lhotGreeting,							"MFemaleDialog.mf_sleez_helloV1", 1);
	Addto(lhotGreeting,							"MFemaleDialog.mf_sleez_helloV2", 2);
	Addto(lhotGreeting,							"MFemaleDialog.mf_sleez_helloV3", 3);
	Addto(lhotGreeting,							"MFemaleDialog.mf_sleez_helloV4", 4);
	Addto(lhotGreeting,							"MFemaleDialog.mf_sleez_heybabyV1", 1);
	Addto(lhotGreeting,							"MFemaleDialog.mf_sleez_heybabyV2", 2);
	Addto(lhotGreeting,							"MFemaleDialog.mf_sleez_hiV1", 1);
	Addto(lhotGreeting,							"MFemaleDialog.mf_sleez_hiV2", 2);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,					"MFemaleDialog.mf_greet_howareyouV1", 1);
	Addto(lGreetingquestions,					"MFemaleDialog.mf_greet_howareyouV2", 2);
	Addto(lGreetingquestions,					"MFemaleDialog.mf_greet_howsitgoingV1", 1);
	Addto(lGreetingquestions,					"MFemaleDialog.mf_greet_howsitgoingV2", 2);
	Addto(lGreetingquestions,					"MFemaleDialog.mf_greet_howyoudoinV1", 1);
	Addto(lGreetingquestions,					"MFemaleDialog.mf_greet_howyoudoinV2", 2);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,				"MFemaleDialog.mf_sleez_howareyouV1", 1);
	Addto(lHotGreetingquestions,				"MFemaleDialog.mf_sleez_howareyouV2", 2);
	Addto(lHotGreetingquestions,				"MFemaleDialog.mf_sleez_howyoudoinV1", 1);
	Addto(lHotGreetingquestions,				"MFemaleDialog.mf_sleez_howyoudoinV2", 2);

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,				"MFemaleDialog.mf_negative_goawayV1", 1);
	Addto(lrespondtohotgreeting,				"MFemaleDialog.mf_negative_goawayV2", 2);
	Addto(lrespondtohotgreeting,				"MFemaleDialog.mf_negative_notinterestedV1", 1);
	Addto(lrespondtohotgreeting,				"MFemaleDialog.mf_negative_notinterestedV2", 2);
	Addto(lrespondtohotgreeting,				"MFemaleDialog.mf_nottalking2meV1", 1);
	Addto(lrespondtohotgreeting,				"MFemaleDialog.mf_nottalking2meV2", 2);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,					"MFemaleDialog.mf_abuelacamedownV1", 1);
	Addto(lrespondtogreeting,					"MFemaleDialog.mf_abuelacamedownV2", 2);
	Addto(lrespondtogreeting,					"MFemaleDialog.mf_beenbetterV1", 1);
	Addto(lrespondtogreeting,					"MFemaleDialog.mf_beenbetterV2", 2);
	Addto(lrespondtogreeting,					"MFemaleDialog.mf_doiknowyouV1", 1);
	Addto(lrespondtogreeting,					"MFemaleDialog.mf_doiknowyouV2", 2);
	Addto(lrespondtogreeting,					"MFemaleDialog.mf_ohokayiguessV1", 1);
	Addto(lrespondtogreeting,					"MFemaleDialog.mf_ohokayiguessV2", 2);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_gladtohearthatV1", 1);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_gladtohearthatV2", 2);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_itsallgoodV1", 1);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_itsallgoodV2", 2);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_noproblemV1", 1);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_noproblemV2", 2);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_noworriesV1", 1);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_noworriesV2", 2);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_takecareV1", 1);
	Addto(lrespondtogreetingresponse,			"MFemaleDialog.mf_takecareV2", 2);

	Clear(lHelloCop);
	Addto(lHelloCop,								"MFemaleDialog.mf_imamericanV1", 1);
	Addto(lHelloCop,								"MFemaleDialog.mf_imamericanV2", 2);
	Addto(lHelloCop,								"MFemaleDialog.mf_imamericanV3", 3);
	Addto(lHelloCop,								"MFemaleDialog.mf_imamericanV4", 3);
	Addto(lHelloCop,								"MFemaleDialog.mf_whatseemstobetheV1", 1);
	Addto(lHelloCop,								"MFemaleDialog.mf_whatseemstobetheV2", 2);
	Addto(lHelloCop,								"MFemaleDialog.mf_isanythingwrongV1", 1);
	Addto(lHelloCop,								"MFemaleDialog.mf_isanythingwrongV2", 2);
	
	//Clear(lHelloGimp);
	//Addto(lHelloGimp,							"", 1);

	Clear(lApologize);
	Addto(lApologize,							"MFemaleDialog.mf_sorryV1", 1);
	Addto(lApologize,							"MFemaleDialog.mf_sorryV2", 1);

	//Clear(lyourewelcome);
	//Addto(lyourewelcome,						"", 1);

	Clear(lno);
	Addto(lno,									"MFemaleDialog.mf_negative_absolutelynotV1", 1);
	Addto(lno,									"MFemaleDialog.mf_negative_absolutelynotV2", 2);
	Addto(lno,									"MFemaleDialog.mf_negative_asifV1", 1);
	Addto(lno,									"MFemaleDialog.mf_negative_asifV2", 2);
	Addto(lno,									"MFemaleDialog.mf_negative_chaleV1", 1);
	Addto(lno,									"MFemaleDialog.mf_negative_chaleV2", 2);
	Addto(lno,									"MFemaleDialog.mf_negative_idontthinksoV1", 1);
	Addto(lno,									"MFemaleDialog.mf_negative_idontthinksoV2", 2);
	Addto(lno,									"MFemaleDialog.mf_negative_idontthinksoV3", 3);
	Addto(lno,									"MFemaleDialog.mf_negative_nothanksV1", 1);
	Addto(lno,									"MFemaleDialog.mf_negative_nothanksV2", 2);
	Addto(lno,									"MFemaleDialog.mf_negative_notV1", 1);
	Addto(lno,									"MFemaleDialog.mf_negative_notV2", 2);
	Addto(lno,									"MFemaleDialog.mf_negative_noV1", 1);
	Addto(lno,									"MFemaleDialog.mf_negative_noV2", 2);
	Addto(lno,									"MFemaleDialog.mf_negative_noV3", 3);
	Addto(lno,									"MFemaleDialog.mf_negative_noV4", 4);
	Addto(lno,									"MFemaleDialog.mf_negative_sorryV1", 1);
	Addto(lno,									"MFemaleDialog.mf_negative_sorryV2", 2);

	Clear(lyes);
	Addto(lyes,									"MFemaleDialog.mf_positive_asfarasyouknowV1", 1);
	Addto(lyes,									"MFemaleDialog.mf_positive_asfarasyouknowV2", 2);
	Addto(lyes,									"MFemaleDialog.mf_positive_asfarasyouknowV3", 3);
	Addto(lyes,									"MFemaleDialog.mf_positive_asfarasyouknowV4", 4);
	Addto(lyes,									"MFemaleDialog.mf_positive_siV1", 1);
	Addto(lyes,									"MFemaleDialog.mf_positive_siV2", 2);
	Addto(lyes,									"MFemaleDialog.mf_positive_uhhunhV1", 1);
	Addto(lyes,									"MFemaleDialog.mf_positive_uhhunhV2", 2);
	Addto(lyes,									"MFemaleDialog.mf_positive_yeahV1", 1);
	Addto(lyes,									"MFemaleDialog.mf_positive_yeahV2", 2);

	Clear(lthanks);
	Addto(lthanks,								"MFemaleDialog.mf_coolthanksV1", 1);
	Addto(lthanks,								"MFemaleDialog.mf_coolthanksV2", 1);
	Addto(lthanks,								"MFemaleDialog.mf_positive_buenoV1", 1);
	Addto(lthanks,								"MFemaleDialog.mf_positive_buenoV2", 2);
	Addto(lthanks,								"MFemaleDialog.mf_positive_deacachimbaV1", 1);
	Addto(lthanks,								"MFemaleDialog.mf_positive_deacachimbaV2", 2);
	Addto(lthanks,								"MFemaleDialog.mf_positive_kickassV1", 1);
	Addto(lthanks,								"MFemaleDialog.mf_positive_kickassV2", 2);
	Addto(lthanks,								"MFemaleDialog.mf_positive_suenebienV1", 1);
	Addto(lthanks,								"MFemaleDialog.mf_positive_suenebienV2", 2);
	Addto(lthanks,								"MFemaleDialog.mf_positive_suenebienV3", 3);
	Addto(lthanks,								"MFemaleDialog.mf_positive_suenebienV4", 4);
	Addto(lthanks,								"MFemaleDialog.mf_positive_sweetV1", 1);
	Addto(lthanks,								"MFemaleDialog.mf_positive_sweetV2", 2);
	Addto(lthanks,								"MFemaleDialog.mf_positive_thatrocksV1", 1);
	Addto(lthanks,								"MFemaleDialog.mf_positive_thatrocksV2", 2);
	Addto(lthanks,								"MFemaleDialog.mf_positive_youthebombV1", 1);
	Addto(lthanks,								"MFemaleDialog.mf_positive_youthebombV2", 2);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_buenoV1", 1);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_buenoV2", 2);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_deacachimbaV1", 1);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_deacachimbaV2", 2);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_kickassV1", 1);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_kickassV2", 2);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_suenebienV1", 1);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_suenebienV2", 2);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_suenebienV3", 3);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_suenebienV4", 4);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_sweetV1", 1);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_sweetV2", 2);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_thatrocksV1", 1);
	Addto(lThatsGreat,							"MFemaleDialog.mf_positive_thatrocksV2", 2);

	Clear(lGetDown);
	AddTo(lGetDown,								"MFemaleDialog.mf_shotblocked4V1", 1);
	AddTo(lGetDown,								"MFemaleDialog.mf_shotblocked4V2", 2);

	//Clear(lGetDownMP);
	//AddTo(lGetDownMP,							"", 1);

	Clear(lCussing);
	Addto(lCussing,								"MFemaleDialog.mf_seecarnage_holyshitV1", 1);
	Addto(lCussing,								"MFemaleDialog.mf_seecarnage_holyshitV2", 2);
	Addto(lCussing,								"MFemaleDialog.mf_damage_carajoV1", 1);
	Addto(lCussing,								"MFemaleDialog.mf_damage_carajoV2", 2);
	Addto(lCussing,								"MFemaleDialog.mf_damage_chingaV1", 1);
	Addto(lCussing,								"MFemaleDialog.mf_damage_chingaV2", 2);
	Addto(lCussing,								"MFemaleDialog.mf_damage_chingaV3", 3);

	//Clear(lgetdownscared);
	//Addto(lgetdownscared,						"", 1);

	Clear(ldefiant);
	Addto(ldefiant,								"MFemaleDialog.mf_bully_pinchegueyV1", 1);
	Addto(ldefiant,								"MFemaleDialog.mf_bully_pinchegueyV2", 2);
	Addto(ldefiant,								"MFemaleDialog.mf_bully_pinchegueyV3", 3);
	Addto(ldefiant,								"MFemaleDialog.mf_bully_pinchegueyV4", 4);
	Addto(ldefiant,								"MFemaleDialog.mf_bully_youwantdramaV1", 1);
	Addto(ldefiant,								"MFemaleDialog.mf_bully_youwantdramaV2", 2);

	Clear(ldefiantline);
	Addto(ldefiantline,							"MFemaleDialog.mf_bully_pinchegueyV1", 1);
	Addto(ldefiantline,							"MFemaleDialog.mf_bully_pinchegueyV2", 2);
	Addto(ldefiantline,							"MFemaleDialog.mf_bully_pinchegueyV3", 3);
	Addto(ldefiantline,							"MFemaleDialog.mf_bully_pinchegueyV4", 4);
	Addto(ldefiantline,							"MFemaleDialog.mf_bully_youwantdramaV1", 1);
	Addto(ldefiantline,							"MFemaleDialog.mf_bully_youwantdramaV2", 2);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"MFemaleDialog.mf_seecarnage_holyshitV1", 1);
	Addto(lCloseToWeapon,						"MFemaleDialog.mf_seecarnage_holyshitV2", 2);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot1V1", 1);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot1V2", 2);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot2V1", 1);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot2V2", 2);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot3V3", 3);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot3V1", 1);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot3V2", 2);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot4V1", 1);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot4V2", 2);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot5V1", 1);
	Addto(ldecidetofight,						"MFemaleDialog.mf_riot5V2", 2);

	Clear(llaughing);
	Addto(llaughing,							"MFemaleDialog.mf_laughV1", 1);

	Clear(lSnickering);
	Addto(lSnickering,							"MFemaleDialog.mf_snickerV1", 1);
	Addto(lSnickering,							"MFemaleDialog.mf_snickerV2", 1);

	//Clear(lOutOfBreath);
	//Addto(lOutOfBreath,							"", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"MFemaleDialog.mf_seepanic_1V1", 1);
	Addto(lWatchingCrazy,						"MFemaleDialog.mf_seepanic_1V2", 1);
	Addto(lWatchingCrazy,						"MFemaleDialog.mf_seepanic_2V1", 1);
	Addto(lWatchingCrazy,						"MFemaleDialog.mf_seepanic_2V2", 1);
	Addto(lWatchingCrazy,						"MFemaleDialog.mf_seepanic_2V3", 1);
	Addto(lWatchingCrazy,						"MFemaleDialog.mf_followup_completelystupidV1", 1);
	Addto(lWatchingCrazy,						"MFemaleDialog.mf_followup_completelystupidV2", 2);
	Addto(lWatchingCrazy,						"MFemaleDialog.mf_followup_methtalkingV1", 1);
	Addto(lWatchingCrazy,						"MFemaleDialog.mf_followup_methtalkingV2", 2);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,					"MFemaleDialog.mf_getcop_helpV1", 1);
	Addto(lshootingoverthere,					"MFemaleDialog.mf_getcop_helpV2", 2);
	Addto(lshootingoverthere,					"MFemaleDialog.mf_getcop_policex2V1", 1);
	Addto(lshootingoverthere,					"MFemaleDialog.mf_getcop_policex2V2", 2);
	Addto(lshootingoverthere,					"MFemaleDialog.mf_heargun_shootingeveryoneV1", 1);
	Addto(lshootingoverthere,					"MFemaleDialog.mf_heargun_shootingeveryoneV2", 2);
	Addto(lshootingoverthere,					"MFemaleDialog.mf_heargun_shootingeveryoneV3", 3);
	Addto(lshootingoverthere,					"MFemaleDialog.mf_heargun_shootingeveryoneV4", 4);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_getcop_helpV1", 1);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_getcop_helpV2", 2);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_getcop_policex2V1", 1);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_getcop_policex2V2", 2);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_heargun_wastingpeopleV1", 1);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_heargun_wastingpeopleV2", 2);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_seecarnage_chamucoskillingV1", 1);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_seecarnage_chamucoskillingV2", 1);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_seecarnage_locoskillingV1", 1);
	Addto(lkillingoverthere,					"MFemaleDialog.mf_seecarnage_locoskillingV2", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,							"MFemaleDialog.mf_scream1", 1);
	Addto(lscreaming,							"MFemaleDialog.mf_scream2", 1);
	Addto(lscreaming,							"MFemaleDialog.mf_scream3", 1);
	Addto(lscreaming,							"MFemaleDialog.mf_scream4", 1);
	Addto(lscreaming,							"MFemaleDialog.mf_scream5", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"MFemaleDialog.mf_onfire_awghelpmeV1", 1);
	Addto(lscreamingonfire,						"MFemaleDialog.mf_onfire_fiyaaV1", 1);
	Addto(lscreamingonfire,						"MFemaleDialog.mf_onfire_imburningV1", 1);
	Addto(lscreamingonfire,						"MFemaleDialog.mf_onfire_putmeoutV1", 1);
	Addto(lscreamingonfire,						"MFemaleDialog.mf_onfire_sweetvirginmaryV1", 1);
	Addto(lscreamingonfire,						"MFemaleDialog.mf_onfire_sweetvirginmaryV2", 2);
	Addto(lscreamingonfire,						"MFemaleDialog.mf_onfire_yeaghV1", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_bringitV1", 1);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_bringitV2", 2);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_howaboutsomeofthisV1", 1);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_howaboutsomeofthisV2", 2);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_rahV1", 1);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_rahV2", 2);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_youthinkimscaredV1", 1);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_youthinkimscaredV2", 2);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_youthinkyoucanV1", 1);
	Addto(lDoHeroics,							"MFemaleDialog.mf_tough_youthinkyoucanV2", 2);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"MFemaleDialog.mf_spitoutpissV1", 1);
	Addto(lgettingpissedon,						"MFemaleDialog.mf_spitoutpissV2", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_asquerosoV1", 1);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_asquerosoV2", 2);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_calabazoV1", 1);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_calabazoV2", 2);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_eughV1", 1);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_eughV2", 2);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_eughV3", 3);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_eughV4", 4);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_myblouseV1", 1);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_myblouseV2", 2);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_yuckV1", 1);
	Addto(laftergettingpissedon,				"MFemaleDialog.mf_pissedon_yuckV2", 2);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"MFemaleDialog.mf_huhV1", 1);
	Addto(lwhatthe,								"MFemaleDialog.mf_huhV2", 2);
	Addto(lwhatthe,								"MFemaleDialog.mf_pissedon_heeyV1", 1);
	Addto(lwhatthe,								"MFemaleDialog.mf_pissedon_heeyV2", 2);
	Addto(lwhatthe,								"MFemaleDialog.mf_pissedon_whattheV1", 1);
	Addto(lwhatthe,								"MFemaleDialog.mf_pissedon_whattheV2", 2);
	Addto(lwhatthe,								"MFemaleDialog.mf_pissedon_whuhV1", 1);
	Addto(lwhatthe,								"MFemaleDialog.mf_pissedon_whuhV2", 2);

	Clear(lseeingpisser);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing1V1", 1);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing1V2", 2);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing2V1", 1);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing2V2", 2);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing2V3", 3);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing2V4", 4);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing3V1", 1);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing3V2", 2);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing4V1", 1);
	Addto(lseeingpisser,						"MFemaleDialog.mf_seespissing4V2", 2);

	//Clear(lSomethingIsGross);
	//Addto(lSomethingIsGross,					"", 1);

	Clear(lgothit);
	Addto(lgothit,								"MFemaleDialog.mf_damage_aghkV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_aiieeV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_aiieeV2", 2);
	Addto(lgothit,								"MFemaleDialog.mf_damage_akV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_arghV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_aughV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_badtouchV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_badtouchV2", 2);
	Addto(lgothit,								"MFemaleDialog.mf_damage_carajoV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_carajoV2", 2);
	Addto(lgothit,								"MFemaleDialog.mf_damage_chingaV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_chingaV2", 2);
	Addto(lgothit,								"MFemaleDialog.mf_damage_chingaV3", 3);
	Addto(lgothit,								"MFemaleDialog.mf_damage_gakV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_imhitV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_imhitV2", 2);
	Addto(lgothit,								"MFemaleDialog.mf_damage_mommaV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_mommaV2", 2);
	Addto(lgothit,								"MFemaleDialog.mf_damage_myeyeV1", 1);
	Addto(lgothit,								"MFemaleDialog.mf_damage_myeyeV2", 2);
	Addto(lgothit,								"MFemaleDialog.mf_damage_owbitchV1", 1);
//	Addto(lgothit,								"MFemaleDialog.mf_damage_owbitchV2", 2);
	Addto(lgothit,								"MFemaleDialog.mf_damage_owV1", 1);

	Clear(lAttacked);
	Addto(lAttacked,							"MFemaleDialog.mf_damage_aghkV1", 1);
	Addto(lAttacked,							"MFemaleDialog.mf_damage_akV1", 1);
	Addto(lAttacked,							"MFemaleDialog.mf_damage_arghV1", 1);
	Addto(lAttacked,							"MFemaleDialog.mf_damage_aughV1", 1);
	Addto(lAttacked,							"MFemaleDialog.mf_damage_gakV1", 1);
	Addto(lAttacked,							"MFemaleDialog.mf_damage_owV1", 1);

	Clear(lGrunt);
	Addto(lGrunt,								"MFemaleDialog.mf_damage_aghkV1", 1);
	Addto(lGrunt,								"MFemaleDialog.mf_damage_akV1", 1);
	Addto(lGrunt,								"MFemaleDialog.mf_damage_arghV1", 1);
	Addto(lGrunt,								"MFemaleDialog.mf_damage_aughV1", 1);
	Addto(lGrunt,								"MFemaleDialog.mf_damage_gakV1", 1);
	Addto(lGrunt,								"MFemaleDialog.mf_damage_owV1", 1);

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

	//Clear(lGotHitInCrotch);	
	//addto(lGotHitInCrotch,						"", 1);	

	Clear(lbegforlife);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_crazypersonV1", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_crazypersonV2", 2);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_crazypersonV3", 3);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_crying1", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_crying2", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_crying3", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_crying4", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_crying5", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_cryingV1", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_cryingV2", 2);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_pleasedontkillmeV1", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_pleasedontkillmeV2", 2);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_pleasepleasenoV1", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_pleasepleasenoV2", 2);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_snivel1", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_snivel2", 2);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_somebodysmommaV1", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_beg_somebodysmommaV2", 2);
	Addto(lbegforlife,							"MFemaleDialog.mf_fearful_donthurtV1", 1);
	Addto(lbegforlife,							"MFemaleDialog.mf_fearful_donthurtV2", 2);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_crazypersonV1", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_crazypersonV2", 2);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_crazypersonV3", 3);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_crying1", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_crying2", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_crying3", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_crying4", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_crying5", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_cryingV1", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_cryingV2", 2);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_pleasedontkillmeV1", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_pleasedontkillmeV2", 2);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_pleasepleasenoV1", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_pleasepleasenoV2", 2);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_snivel1", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_snivel2", 2);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_somebodysmommaV1", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_beg_somebodysmommaV2", 2);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_fearful_donthurtV1", 1);
	Addto(lbegforlifeMin,						"MFemaleDialog.mf_fearful_donthurtV2", 2);
	
	//Clear(ldying);
	//Addto(ldying,								"", 1);

	Clear(lCrying);
	Addto(lCrying,								"MFemaleDialog.mf_beg_crying1", 1);
	Addto(lCrying,								"MFemaleDialog.mf_beg_crying2", 1);
	Addto(lCrying,								"MFemaleDialog.mf_beg_crying3", 1);
	Addto(lCrying,								"MFemaleDialog.mf_beg_crying4", 1);
	Addto(lCrying,								"MFemaleDialog.mf_beg_crying5", 1);
	Addto(lCrying,								"MFemaleDialog.mf_beg_cryingV1", 1);
	Addto(lCrying,								"MFemaleDialog.mf_beg_cryingV2", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,					"MFemaleDialog.mf_beg_ididntmeanitV1", 1);	
	Addto(lfrightenedapology,					"MFemaleDialog.mf_beg_ididntmeanitV2", 2);	
	Addto(lfrightenedapology,					"MFemaleDialog.mf_beg_ididntmeanitV3", 3);	
	Addto(lfrightenedapology,					"MFemaleDialog.mf_beg_ididntmeanitV4", 4);	
	Addto(lfrightenedapology,					"MFemaleDialog.mf_beg_neveragainV1", 1);	
	Addto(lfrightenedapology,					"MFemaleDialog.mf_beg_neveragainV2", 2);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"MFemaleDialog.mf_taunt_bigguntinyV1", 1);
	Addto(ltrashtalk,							"MFemaleDialog.mf_taunt_bigguntinyV2", 2);
	Addto(ltrashtalk,							"MFemaleDialog.mf_taunt_cmonfightlikeamanV1", 1);
	Addto(ltrashtalk,							"MFemaleDialog.mf_taunt_cmonfightlikeamanV2", 2);
	Addto(ltrashtalk,							"MFemaleDialog.mf_taunt_whatyougonnadoV1", 1);
	Addto(ltrashtalk,							"MFemaleDialog.mf_taunt_whatyougonnadoV2", 2);
	Addto(ltrashtalk,							"MFemaleDialog.mf_taunt_whatyougonnadoV3", 3);
	Addto(ltrashtalk,							"MFemaleDialog.mf_taunt_yourenotsotoughV1", 1);
	Addto(ltrashtalk,							"MFemaleDialog.mf_taunt_yourenotsotoughV2", 2);

	Clear(lWhileFighting);
	Addto(lWhileFighting,						"MFemaleDialog.mf_taunt_bigguntinyV1", 1);
	Addto(lWhileFighting,						"MFemaleDialog.mf_taunt_bigguntinyV2", 2);
	Addto(lWhileFighting,						"MFemaleDialog.mf_taunt_cmonfightlikeamanV1", 1);
	Addto(lWhileFighting,						"MFemaleDialog.mf_taunt_cmonfightlikeamanV2", 2);
	Addto(lWhileFighting,						"MFemaleDialog.mf_taunt_whatyougonnadoV1", 1);
	Addto(lWhileFighting,						"MFemaleDialog.mf_taunt_whatyougonnadoV2", 2);
	Addto(lWhileFighting,						"MFemaleDialog.mf_taunt_whatyougonnadoV3", 3);
	Addto(lWhileFighting,						"MFemaleDialog.mf_taunt_yourenotsotoughV1", 1);
	Addto(lWhileFighting,						"MFemaleDialog.mf_taunt_yourenotsotoughV2", 2);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,						"MFemaleDialog.mf_whatseemstobetheV1", 1);
	Addto(laskcopwhatsup,						"MFemaleDialog.mf_whatseemstobetheV2", 1);

	Clear(lratout);
	Addto(lratout,								"MFemaleDialog.mf_report_hediditV1", 1);
	Addto(lratout,								"MFemaleDialog.mf_report_hediditV2", 2);
	Addto(lratout,								"MFemaleDialog.mf_report_hestheoneV1", 1);
	Addto(lratout,								"MFemaleDialog.mf_report_hestheoneV2", 2);
	Addto(lratout,								"MFemaleDialog.mf_report_hestheoneV3", 3);
	Addto(lratout,								"MFemaleDialog.mf_report_itwashimV1", 1);
	Addto(lratout,								"MFemaleDialog.mf_report_itwashimV2", 2);
	Addto(lratout,								"MFemaleDialog.mf_report_thatguyV1", 1);
	Addto(lratout,								"MFemaleDialog.mf_report_thatguyV2", 2);

	Clear(lfakeratout);
	Addto(lfakeratout,							"MFemaleDialog.mf_lying_hediditisawV1", 1);
	Addto(lfakeratout,							"MFemaleDialog.mf_lying_hediditisawV2", 2);
	Addto(lfakeratout,							"MFemaleDialog.mf_lying_imawitnessV1", 1);
	Addto(lfakeratout,							"MFemaleDialog.mf_lying_imawitnessV2", 2);
	Addto(lfakeratout,							"MFemaleDialog.mf_lying_imawitnessV3", 3);
	Addto(lfakeratout,							"MFemaleDialog.mf_lying_imawitnessV4", 4);

	Clear(lcleanshot);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked1V1", 1);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked1V2", 2);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked1V3", 3);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked2V1", 1);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked2V2", 2);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked3V1", 1);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked3V2", 2);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked3V3", 3);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked4V1", 1);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked4V2", 2);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked5V1", 1);
	Addto(lcleanshot,							"MFemaleDialog.mf_shotblocked5V2", 2);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"MFemaleDialog.mf_shotblocked1V1", 1);
	Addto(lCleanMeleeHit,						"MFemaleDialog.mf_shotblocked1V2", 2);
	Addto(lCleanMeleeHit,						"MFemaleDialog.mf_shotblocked1V3", 3);
	Addto(lCleanMeleeHit,						"MFemaleDialog.mf_shotblocked3V1", 1);
	Addto(lCleanMeleeHit,						"MFemaleDialog.mf_shotblocked3V2", 2);
	Addto(lCleanMeleeHit,						"MFemaleDialog.mf_shotblocked3V3", 3);
	Addto(lCleanMeleeHit,						"MFemaleDialog.mf_shotblocked4V1", 1);
	Addto(lCleanMeleeHit,						"MFemaleDialog.mf_shotblocked4V2", 2);

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
	Addto(lhmm,									"MFemaleDialog.mf_hmmmmV1", 1);
	Addto(lhmm,									"MFemaleDialog.mf_hmmmmV2", 1);
	Addto(lhmm,									"MFemaleDialog.mf_hmmmmV3", 1);

	//Clear(lfollowme);
	//Addto(lfollowme,							"", 1);	

	//Clear(lStayHere);
	//Addto(lStayHere,							"", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_junkawayV1", 1);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_junkawayV2", 2);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_microscopeV1", 1);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_microscopeV2", 2);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_microscopeV3", 3);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_pullyourpantsupV1", 1);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_pullyourpantsupV2", 2);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_zurramatoV1", 1);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_zurramatoV2", 2);
	Addto(lnoticedickout,						"MFemaleDialog.mf_seewang_zurramatoV3", 3);

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
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_betterstepbackV1", 1);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_gonnapayV1", 1);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_gonnapayV2", 2);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_igotammoV1", 1);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_igotammoV2", 2);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_igotammoV3", 3);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_noestesV1", 1);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_noestesV2", 2);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_noestesV3", 3);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_outtamyfaceV1", 1);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_outtamyfaceV2", 2);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_speakglockV1", 1);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_takinyalldownV1", 1);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_takinyalldownV2", 2);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_youdonwannaknowV1", 1);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_youdonwannaknowV2", 2);
	Addto(lGoPostal,							"MFemaleDialog.mf_postal_youdonwannaknowV3", 3);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_fearful_getoutV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_fearful_getoutV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_ghaspV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_ainthappeninV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_ainthappeninV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_ambulanceV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_anyoneseethatV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_anyoneseethatV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_apocalypseV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_apocalypseV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_callnationalguardV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_callnationalguardV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_callunivisionV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_callunivisionV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_cantbelievehappeningV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_cantbelievehappeningV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_cantbelievehedidthatV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_cantbelievehedidthatV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_chamucoskillingV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_chamucoskillingV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_gonnahurlV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_gonnahurlV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_helpV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_helpV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_holyshitV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_holyshitV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_madrediosV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_madrediosV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_madrediosV3", 3);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_makeitstopV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_makeitstopV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_mecagoV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_mecagoV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_needcouncellingV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_needcouncellingV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_notagainV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_notagainV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_ohmygodV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_ohmygodV2", 2);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_outtahereV1", 1);
	Addto(lcarnageoccurred,						"MFemaleDialog.mf_seecarnage_runrunV1", 1);

	Clear(lCallCat);
	Addto(lCallCat, 							"MFemaleDialog.mf_hatescat_herekittyV1", 1);

	Clear(lHateCat);
	Addto(lHateCat, 							"MFemaleDialog.mf_hatescat_getoutfurballV1", 1);
	Addto(lHateCat, 							"MFemaleDialog.mf_hatescat_getoutfurballV2", 2);
	Addto(lHateCat, 							"MFemaleDialog.mf_hatescat_goddamfleabagV1", 1);
	Addto(lHateCat, 							"MFemaleDialog.mf_hatescat_herekittyevilV1", 1);
	Addto(lHateCat, 							"MFemaleDialog.mf_hatescat_herekittyevilV2", 2);

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"MFemaleDialog.mf_seecarnage_holyshitV1", 1);
	Addto(lStartAttackingAnimal,				"MFemaleDialog.mf_seecarnage_holyshitV2", 2);
	Addto(lStartAttackingAnimal,				"MFemaleDialog.mf_damage_carajoV1", 1);
	Addto(lStartAttackingAnimal,				"MFemaleDialog.mf_damage_carajoV2", 2);
	Addto(lStartAttackingAnimal,				"MFemaleDialog.mf_damage_chingaV1", 1);
	Addto(lStartAttackingAnimal,				"MFemaleDialog.mf_damage_chingaV2", 2);
	Addto(lStartAttackingAnimal,				"MFemaleDialog.mf_damage_chingaV3", 3);

	//Clear(lGettingRobbed);	
	//Addto(lGettingRobbed,						"", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"MFemaleDialog.mf_ghaspV1", 1);
	Addto(lGettingMugged,						"MFemaleDialog.mf_beg_crazypersonV1", 1);
	Addto(lGettingMugged,						"MFemaleDialog.mf_beg_crazypersonV2", 2);
	Addto(lGettingMugged,						"MFemaleDialog.mf_beg_crazypersonV3", 3);
	Addto(lGettingMugged,						"MFemaleDialog.mf_beg_snivel1", 1);
	Addto(lGettingMugged,						"MFemaleDialog.mf_beg_snivel2", 2);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"MFemaleDialog.mf_getcop_callacopV1", 1);
	Addto(lAfterMugged,							"MFemaleDialog.mf_getcop_callacopV2", 2);
	Addto(lAfterMugged,							"MFemaleDialog.mf_getcop_callacopV3", 3);
	Addto(lAfterMugged,							"MFemaleDialog.mf_getcop_chotaV1", 1);
	Addto(lAfterMugged,							"MFemaleDialog.mf_getcop_chotaV2", 2);
	Addto(lAfterMugged,							"MFemaleDialog.mf_getcop_helpV1", 1);
	Addto(lAfterMugged,							"MFemaleDialog.mf_getcop_helpV2", 2);
	Addto(lAfterMugged,							"MFemaleDialog.mf_getcop_policex2V1", 1);
	Addto(lAfterMugged,							"MFemaleDialog.mf_getcop_policex2V2", 2);

	//Clear(lDoMugging);	
	//Addto(lDoMugging,							"", 3);
	
	Clear(lQuestion);	
	Addto(lQuestion,							"MFemaleDialog.mf_question_whatareyoutalkingV1", 1);
	Addto(lQuestion,							"MFemaleDialog.mf_question_whatareyoutalkingV2", 2);
	Addto(lQuestion,							"MFemaleDialog.mf_question_whatV1", 1);
	Addto(lQuestion,							"MFemaleDialog.mf_question_whatV2", 2);
	Addto(lQuestion,							"MFemaleDialog.mf_question_whyV1", 1);
	Addto(lQuestion,							"MFemaleDialog.mf_question_whyV2", 2);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_chickenandwafflesV1", 1);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_chickenandwafflesV2", 2);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_cincodemayoV1", 1);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_cincodemayoV2", 2);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_doiknowyouV1", 1);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_doiknowyouV2", 2);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_goodtamalesV1", 1);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_goodtamalesV2", 2);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_goodtamalesV3", 3);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_livearoundhereV1", 1);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_livearoundhereV2", 2);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_uptolaterV1", 1);
	Addto(lGenericQuestion,						"MFemaleDialog.mf_call_uptolaterV2", 2);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"MFemaleDialog.mf_disinterest_boringmeV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_disinterest_boringmeV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_disinterest_mehV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_disinterest_mehV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_disinterest_whocaresV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_disinterest_whocaresV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_question_idontcareV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_question_idontcareV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_question_idontcareV3", 3);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_question_whatareyoutalkingV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_question_whatareyoutalkingV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_alextrebekV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_alextrebekV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_blahblahV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_explosivecarsV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_goodquestionV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_goodquestionV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_howitsgonnabeV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_howitsgonnabeV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_howthehellV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_howthehellV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_inrehabV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_inrehabV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_learntogoogleV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_learntogoogleV2", 2);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_trivialshitV1", 1);
	Addto(lGenericAnswer,						"MFemaleDialog.mf_response_trivialshitV2", 2);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_areyoulocoV1", 1);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_areyoulocoV2", 2);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_areyouseriousV1", 1);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_areyouseriousV2", 2);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_completelystupidV1", 1);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_completelystupidV2", 2);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_methtalkingV1", 1);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_methtalkingV2", 2);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_notpayingattentionV1", 1);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_notpayingattentionV2", 2);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_saywhatV1", 1);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_saywhatV2", 2);
	Addto(lGenericFollowup,						"MFemaleDialog.mf_followup_stopthatshitV1", 1);

	Clear(lGenericGoodbye);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_checkyoulaterV1", 1);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_checkyoulaterV2", 2);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_confusednowV1", 1);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_confusednowV2", 2);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_confusednowV3", 3);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_donehereV1", 1);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_donehereV2", 2);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_greatseeingyouV1", 1);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_greatseeingyouV2", 2);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_seeyoulaterV1", 1);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_seeyoulaterV2", 2);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_seeyoulaterV3", 3);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_stupidestV1", 1);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_stupidestV2", 2);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_youreascrazyV1", 1);
	Addto(lGenericGoodbye,						"MFemaleDialog.mf_leadout_youreascrazyV2", 2);

	//Clear(linvadeshome);	
	//Addto(linvadeshome,							"", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seefire_firex2V1", 1);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seefire_holyshitV1", 1);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seefire_holyshitV2", 2);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seefire_smellsgoodV1", 1);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seefire_smellsgoodV2", 2);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seeonfire_hesonfireV1", 1);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seeonfire_hesonfireV2", 2);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seeonfire_stopdropandrollV1", 1);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seeonfire_stopdropandrollV2", 2);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seeonfire_theyreallburningV1", 1);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seeonfire_theyreallburningV2", 2);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seeonfire_youreonfireV1", 1);
	Addto(lsomeoneonfire,						"MFemaleDialog.mf_seeonfire_youreonfireV2", 2);

	Clear(labouttopuke);
	Addto(labouttopuke,							"MFemaleDialog.mf_puke_idontfeelverygoodV1", 1);
	Addto(labouttopuke,							"MFemaleDialog.mf_puke_idontfeelverygoodV2", 2);
	Addto(labouttopuke,							"MFemaleDialog.mf_puke_ohgodimV1", 1);
	Addto(labouttopuke,							"MFemaleDialog.mf_puke_ohgodimV2", 2);
	Addto(labouttopuke,							"MFemaleDialog.mf_puke_ohmanimgonnaspewV1", 1);
	Addto(labouttopuke,							"MFemaleDialog.mf_puke_ohmanimgonnaspewV2", 2);

	//Clear(lbodyfunctions);
	//Addto(lbodyfunctions,						"", 1);

	//Clear(lGettingShocked);
	//Addto(lGettingShocked,						"", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,							"HabibDialog.habib_ailili", 1);

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_chickenandwafflesV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_chickenandwafflesV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_cincodemayoV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_cincodemayoV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_doiknowyouV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_doiknowyouV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_goodtamalesV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_goodtamalesV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_goodtamalesV3", 3);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_livearoundhereV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_livearoundhereV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_uptolaterV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_call_uptolaterV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_airfreshenerV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_airfreshenerV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_airfreshenerV3", 3);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_birfcontrolV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_birfcontrolV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_borderV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_borderV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_crazyguyV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_crazyguyV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_diadelosmuertosV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_diadelosmuertosV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_excellentV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_excellentV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_nowayhappyV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_nowayhappyV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_seriousV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_seriousV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_thickandsmellyV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_thickandsmellyV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_thinkingthesameV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_thinkingthesameV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_thinkingthesameV3", 3);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_uhhuhV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_uhhuhV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_whatdidyouthinkV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_whatdidyouthinkV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_whatdidyouthinkV3", 3);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_whatithoughtV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_whatithoughtV2", 2);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_whatithoughtV3", 3);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_whatithoughtV4", 4);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_wouldnybelieveV1", 1);
	Addto(lCellPhoneTalk,						"MFemaleDialog.mf_cell_wouldnybelieveV2", 2);
	
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
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_chalkoutlineclubV1", 1);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_chalkoutlineclubV2", 2);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_follacabrasV1", 1);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_follacabrasV2", 2);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_gamefaqsV1", 1);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_gamefaqsV2", 2);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_godmodeV1", 1);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_godmodeV2", 2);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_republicanV1", 1);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_republicanV2", 2);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_republicanV3", 3);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_seriousassholeV1", 1);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_seriousassholeV2", 2);
	Addto(ldudedead,							"MFemaleDialog.mf_deadtaunt_seriousassholeV3", 3);

	Clear(lKickDead);
	Addto(lKickDead,							"MFemaleDialog.mf_deadtaunt_heresapresentV1", 1);
	Addto(lKickDead,							"MFemaleDialog.mf_deadtaunt_heresapresentV2", 2);
	Addto(lKickDead,							"MFemaleDialog.mf_deadtaunt_onefortheroadV1", 1);
	Addto(lKickDead,							"MFemaleDialog.mf_deadtaunt_onefortheroadV2", 2);
	Addto(lKickDead,							"MFemaleDialog.mf_deadtaunt_takethatassholeV1", 1);
	Addto(lKickDead,							"MFemaleDialog.mf_deadtaunt_takethatassholeV2", 2);

	//Clear(lNameCalling);
	//Addto(lNameCalling,							"", 1);

	Clear(lRogueCop);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_araiseV1", 1);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_araiseV2", 2);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_cantdothatV1", 1);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_cantdothatV2", 2);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_coolyourshitV1", 1);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_coolyourshitV2", 2);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_havejobsV1", 1);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_havejobsV2", 2);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_lookatthatV1", 1);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_lookatthatV2", 2);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_officerporkyV1", 1);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_officerporkyV2", 2);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_officerporkyV3", 3);
	Addto(lRogueCop,							"MFemaleDialog.mf_seescop_officerporkyV4", 4);

	Clear(lgetbumped);
	Addto(lgetbumped,							"MFemaleDialog.mf_bumped_cominthroughV1", 1);
	Addto(lgetbumped,							"MFemaleDialog.mf_bumped_cominthroughV2", 2);
	Addto(lgetbumped,							"MFemaleDialog.mf_bumped_heywatchitV1", 1);
	Addto(lgetbumped,							"MFemaleDialog.mf_bumped_heywatchitV2", 2);
	Addto(lgetbumped,							"MFemaleDialog.mf_bumped_onesideV1", 1);
	Addto(lgetbumped,							"MFemaleDialog.mf_bumped_onesideV2", 2);
	Addto(lgetbumped,							"MFemaleDialog.mf_bumped_onesideV3", 3);
	Addto(lgetbumped,							"MFemaleDialog.mf_bumped_stepoverV1", 1);
	Addto(lgetbumped,							"MFemaleDialog.mf_bumped_stepoverV2", 2);

	Clear(lGetMad);
	Addto(lGetMad,								"MFemaleDialog.mf_bumped_heywatchitV1", 1);
	Addto(lGetMad,								"MFemaleDialog.mf_bumped_heywatchitV2", 2);
	Addto(lGetMad,								"MFemaleDialog.mf_bully_pinchegueyV1", 1);
	Addto(lGetMad,								"MFemaleDialog.mf_bully_pinchegueyV2", 2);
	Addto(lGetMad,								"MFemaleDialog.mf_bully_pinchegueyV3", 3);
	Addto(lGetMad,								"MFemaleDialog.mf_bully_pinchegueyV4", 4);
	Addto(lGetMad,								"MFemaleDialog.mf_damage_owbitchV1", 1);

	Clear(lLynchMob);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_gethimV1", 1);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_gethimV2", 2);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_heyyouV1", 1);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_idontlikethelookV1", 1);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_idontlikethelookV2", 2);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_idontlikethelookV3", 3);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_somethingwrongV1", 1);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_somethingwrongV2", 2);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_thatstheoneV1", 1);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_thatstheoneV2", 2);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_thereheisV1", 1);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_thereheisV2", 2);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_thereheisV3", 3);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_theresthekillerV1", 1);
	Addto(lLynchMob,							"MFemaleDialog.mf_lynch_theresthekillerV2", 2);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_lynch_gethimV1", 1);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_lynch_gethimV2", 2);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_lynch_heyyouV1", 1);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_lynch_thereheisV1", 1);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_lynch_thereheisV2", 2);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_lynch_thereheisV3", 3);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_tough_howaboutsomeofthisV1", 1);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_tough_howaboutsomeofthisV2", 2);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_tough_rahV1", 1);
	Addto(lSeesEnemy,							"MFemaleDialog.mf_tough_rahV2", 2);

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
	Addto(lSignPetition,						"MFemaleDialog.mf_positive_imdownV1", 1);
	Addto(lSignPetition,						"MFemaleDialog.mf_positive_imdownV2", 2);
	Addto(lSignPetition,						"MFemaleDialog.mf_positive_surethingV1", 1);
	Addto(lSignPetition,						"MFemaleDialog.mf_positive_surethingV2", 2);
	Addto(lSignPetition,						"MFemaleDialog.mf_positive_surethingV3", 3);
	Addto(lSignPetition,						"MFemaleDialog.mf_positive_surethingV4", 4);
	Addto(lSignPetition,						"MFemaleDialog.mf_positive_surewhynotV1", 1);
	Addto(lSignPetition,						"MFemaleDialog.mf_positive_surewhynotV2", 2);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_absolutelynotV1", 1);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_absolutelynotV2", 2);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_asifV1", 1);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_asifV2", 2);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_chaleV1", 1);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_chaleV2", 2);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_idontthinksoV1", 1);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_idontthinksoV2", 2);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_idontthinksoV3", 3);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_nothanksV1", 1);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_nothanksV2", 2);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_notinterestedV1", 1);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_notinterestedV2", 2);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_sorryV1", 1);
	Addto(lDontSignPetition,					"MFemaleDialog.mf_negative_sorryV2", 2);

	Clear(lPetitionBother);
	Addto(lPetitionBother,						"MFemaleDialog.mf_negative_goawayV1", 1);
	Addto(lPetitionBother,						"MFemaleDialog.mf_negative_goawayV2", 2);
	
	Clear(lChampPhotoReaction);
	Addto(lChampPhotoReaction,					"MFemaleDialog.mf_ghaspV1", 1);
	Addto(lChampPhotoReaction,					"MFemaleDialog.mf_seecarnage_holyshitV1", 1);
	Addto(lChampPhotoReaction,					"MFemaleDialog.mf_seecarnage_holyshitV2", 2);
	Addto(lChampPhotoReaction,					"MFemaleDialog.mf_seecarnage_madrediosV1", 1);
	Addto(lChampPhotoReaction,					"MFemaleDialog.mf_seecarnage_madrediosV3", 2);
	Addto(lChampPhotoReaction,					"MFemaleDialog.mf_seecarnage_ohmygodV2", 1);
	Addto(lChampPhotoReaction,					"MFemaleDialog.mf_seecarnage_ohmygodV1", 2);

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
