///////////////////////////////////////////////////////////////////////////////
// DialogBlackMale
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all black males
//
///////////////////////////////////////////////////////////////////////////////
class DialogMaleBlack extends DialogMale;

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{	
	// Let super go first
	Super.FillInLines();

	Clear(lapplauding);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_booyawV1", 1);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_booyawV2", 2);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_gomanV1", 1);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_gomanV2", 2);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_nowayV1", 1);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_nowayV2", 2);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_offthehookV1", 1);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_offthehookV2", 2);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_whatimtalkinboutV1", 1);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_whatimtalkinboutV2", 2);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_wootV1", 1);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_wootV2", 2);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_yeahx2V1", 1);
	AddTo(lApplauding,							"BMaleDialog.bm_cheer_yeahx2V2", 2);

	Clear(lgreeting);
	Addto(lgreeting,							"BMaleDialog.bm_greet_helloV1", 1);
	Addto(lgreeting,							"BMaleDialog.bm_greet_helloV2", 2);
	Addto(lgreeting,							"BMaleDialog.bm_greet_helloV3", 3);
	Addto(lgreeting,							"BMaleDialog.bm_greet_heyV1", 1);
	Addto(lgreeting,							"BMaleDialog.bm_greet_heyV2", 2);
	Addto(lgreeting,							"BMaleDialog.bm_greet_yoV1", 1);
	Addto(lgreeting,							"BMaleDialog.bm_greet_yoV2", 2);
	Addto(lgreeting,							"BMaleDialog.bm_greet_yoV3", 3);

	Clear(lhotgreeting);
	Addto(lhotGreeting,							"BMaleDialog.bm_sleez_helloV1", 1);
	Addto(lhotGreeting,							"BMaleDialog.bm_sleez_helloV2", 2);
	Addto(lhotGreeting,							"BMaleDialog.bm_sleez_heybabyV1", 1);
	Addto(lhotGreeting,							"BMaleDialog.bm_sleez_heybabyV2", 2);
	Addto(lhotGreeting,							"BMaleDialog.bm_sleez_hiV1", 1);
	Addto(lhotGreeting,							"BMaleDialog.bm_sleez_hiV2", 2);
	Addto(lhotGreeting,							"BMaleDialog.bm_sleez_supbitchV1", 1);
	Addto(lhotGreeting,							"BMaleDialog.bm_sleez_supbitchV2", 2);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,					"BMaleDialog.bm_greet_howareyouV1", 1);
	Addto(lGreetingquestions,					"BMaleDialog.bm_greet_howareyouV2", 2);
	Addto(lGreetingquestions,					"BMaleDialog.bm_greet_howsitgoingV1", 1);
	Addto(lGreetingquestions,					"BMaleDialog.bm_greet_howsitgoingV2", 2);
	Addto(lGreetingquestions,					"BMaleDialog.bm_greet_howyoudoinV1", 1);
	Addto(lGreetingquestions,					"BMaleDialog.bm_greet_howyoudoinV2", 2);
	Addto(lGreetingquestions,					"BMaleDialog.bm_greet_supV1", 1);
	Addto(lGreetingquestions,					"BMaleDialog.bm_greet_supV2", 2);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,				"BMaleDialog.bm_kindasmokinV1", 1);
	Addto(lHotGreetingquestions,				"BMaleDialog.bm_kindasmokinV2", 2);
	Addto(lHotGreetingquestions,				"BMaleDialog.bm_sleez_howareyouV1", 1);
	Addto(lHotGreetingquestions,				"BMaleDialog.bm_sleez_howareyouV2", 2);
	Addto(lHotGreetingquestions,				"BMaleDialog.bm_sleez_howsitgoingV1", 1);
	Addto(lHotGreetingquestions,				"BMaleDialog.bm_sleez_howsitgoingV2", 2);
	Addto(lHotGreetingquestions,				"BMaleDialog.bm_sleez_howyoudoinV1", 1);
	Addto(lHotGreetingquestions,				"BMaleDialog.bm_sleez_howyoudoinV2", 2);

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,				"BMaleDialog.bm_doiknowyouV1", 1);
	Addto(lrespondtohotgreeting,				"BMaleDialog.bm_doiknowyouV2", 2);
	Addto(lrespondtohotgreeting,				"BMaleDialog.bm_doiknowyouV3", 3);
	Addto(lrespondtohotgreeting,				"BMaleDialog.bm_negative_goawayV1", 1);
	Addto(lrespondtohotgreeting,				"BMaleDialog.bm_negative_goawayV2", 2);
	Addto(lrespondtohotgreeting,				"BMaleDialog.bm_negative_notinterestedV1", 1);
	Addto(lrespondtohotgreeting,				"BMaleDialog.bm_negative_notinterestedV2", 2);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_beenbetterV1", 1);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_beenbetterV2", 2);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_doiknowyouV1", 1);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_doiknowyouV2", 2);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_doiknowyouV3", 3);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_grandmawcamedownV1", 1);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_grandmawcamedownV2", 2);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_grandmawcamedownV3", 3);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_imhanginV1", 1);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_ohokayiguessV1", 1);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_talkingtomeV1", 1);
	Addto(lrespondtogreeting,					"BMaleDialog.bm_talkingtomeV2", 2);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_gladtohearitV1", 1);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_gladtohearitV2", 2);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_gladtohearitV3", 3);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_itsallgoodV1", 1);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_itsallgoodV2", 2);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_noproblemV1", 1);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_noproblemV2", 2);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_noworriesV1", 1);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_noworriesV2", 2);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_thatblowsV1", 1);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_thatblowsV2", 2);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_thatsbombV1", 1);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_thatsbombV2", 2);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_thatsbombV3", 3);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_thatsbombV4", 4);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_watchyourselfV1", 1);
	Addto(lrespondtogreetingresponse,			"BMaleDialog.bm_watchyourselfV2", 2);

	Clear(lHelloCop);
	Addto(lHelloCop,								"BMaleDialog.bm_didntseenothinV1", 1);
	Addto(lHelloCop,								"BMaleDialog.bm_didntseenothinV2", 2);
	Addto(lHelloCop,								"BMaleDialog.bm_isanythingwrongV1", 1);
	Addto(lHelloCop,								"BMaleDialog.bm_isanythingwrongV2", 2);
	Addto(lHelloCop,								"BMaleDialog.bm_roscoepcoltrainV1", 1);
	Addto(lHelloCop,								"BMaleDialog.bm_roscoepcoltrainV2", 2);
	Addto(lHelloCop,								"BMaleDialog.bm_whatseemstobetheV1", 1);
	Addto(lHelloCop,								"BMaleDialog.bm_whatseemstobetheV2", 2);
	
	Clear(lHelloGimp);
	Addto(lHelloGimp,								"BMaleDialog.bm_seengimp_adforgarbage", 1);

	Clear(lApologize);
	Addto(lApologize,							"BMaleDialog.bm_sorryyoV1", 1);
	Addto(lApologize,							"BMaleDialog.bm_sorryyoV2", 1);
	Addto(lApologize,							"BMaleDialog.bm_sorryyoV3", 1);

	Clear(lyourewelcome);
	Addto(lyourewelcome,						"BMaleDialog.bm_yourecoolV1", 1);
	Addto(lyourewelcome,						"BMaleDialog.bm_yourecoolV2", 2);

	Clear(lno);
	Addto(lno,									"BMaleDialog.bm_negative_absolutelynotV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_absolutelynotV2", 2);
	Addto(lno,									"BMaleDialog.bm_negative_asifV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_asifV2", 2);
	Addto(lno,									"BMaleDialog.bm_negative_fuckthatV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_fuckthatV2", 2);
	Addto(lno,									"BMaleDialog.bm_negative_idontthinksoV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_idontthinksoV2", 2);
	Addto(lno,									"BMaleDialog.bm_negative_nawV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_nawV2", 2);
	Addto(lno,									"BMaleDialog.bm_negative_nothanksV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_nothanksV2", 2);
	Addto(lno,									"BMaleDialog.bm_negative_notinterestedV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_notinterestedV2", 2);
	Addto(lno,									"BMaleDialog.bm_negative_notV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_notV2", 2);
	Addto(lno,									"BMaleDialog.bm_negative_noV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_noV2", 2);
	Addto(lno,									"BMaleDialog.bm_negative_sorryV1", 1);
	Addto(lno,									"BMaleDialog.bm_negative_sorryV2", 2);

	Clear(lyes);
	Addto(lyes,									"BMaleDialog.bm_positive_aightV1", 1);
	Addto(lyes,									"BMaleDialog.bm_positive_aightV2", 2);
	Addto(lyes,									"BMaleDialog.bm_positive_asfarasyouknowV1", 1);
	Addto(lyes,									"BMaleDialog.bm_positive_asfarasyouknowV2", 2);
	Addto(lyes,									"BMaleDialog.bm_positive_uhhunhV1", 1);
	Addto(lyes,									"BMaleDialog.bm_positive_uhhunhV2", 2);
	Addto(lyes,									"BMaleDialog.bm_positive_yeahV1", 1);
	Addto(lyes,									"BMaleDialog.bm_positive_yeahV2", 2);

	Clear(lthanks);
	Addto(lthanks,								"BMaleDialog.bm_coolthanksV1", 1);
	Addto(lthanks,								"BMaleDialog.bm_coolthanksV2", 2);
	Addto(lthanks,								"BMaleDialog.bm_positive_kickassV1", 1);
	Addto(lthanks,								"BMaleDialog.bm_positive_kickassV2", 2);
	Addto(lthanks,								"BMaleDialog.bm_positive_respectV1", 1);
	Addto(lthanks,								"BMaleDialog.bm_positive_respectV2", 2);
	Addto(lthanks,								"BMaleDialog.bm_positive_shiggetyV1", 1);
	Addto(lthanks,								"BMaleDialog.bm_positive_shiggetyV2", 2);
	Addto(lthanks,								"BMaleDialog.bm_positive_sweetV1", 1);
	Addto(lthanks,								"BMaleDialog.bm_positive_sweetV2", 2);
	Addto(lthanks,								"BMaleDialog.bm_positive_thanksV1", 1);
	Addto(lthanks,								"BMaleDialog.bm_positive_thanksV2", 2);
	Addto(lthanks,								"BMaleDialog.bm_positive_thatrocksV1", 1);
	Addto(lthanks,								"BMaleDialog.bm_positive_thatrocksV2", 2);
	Addto(lthanks,								"BMaleDialog.bm_positive_youthebombV1", 1);
	Addto(lthanks,								"BMaleDialog.bm_positive_youthebombV2", 2);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"BMaleDialog.bm_positive_greatV1", 1);
	Addto(lThatsGreat,							"BMaleDialog.bm_positive_greatV2", 2);
	Addto(lThatsGreat,							"BMaleDialog.bm_positive_kickassV1", 1);
	Addto(lThatsGreat,							"BMaleDialog.bm_positive_kickassV2", 2);
	Addto(lThatsGreat,							"BMaleDialog.bm_positive_sweetV1", 1);
	Addto(lThatsGreat,							"BMaleDialog.bm_positive_sweetV2", 2);
	Addto(lThatsGreat,							"BMaleDialog.bm_positive_thatrocksV1", 1);
	Addto(lThatsGreat,							"BMaleDialog.bm_positive_thatrocksV2", 2);

	Clear(lGetDown);
	AddTo(lGetDown,								"BMaleDialog.bm_shotblocked2V1", 1);
	AddTo(lGetDown,								"BMaleDialog.bm_shotblocked2V2", 2);
	AddTo(lGetDown,								"BMaleDialog.bm_shotblocked4V1", 1);
	AddTo(lGetDown,								"BMaleDialog.bm_shotblocked4V2", 2);

	//Clear(lGetDownMP);
	//AddTo(lGetDownMP,							"", 1);

	Clear(lCussing);
	Addto(lCussing,								"BMaleDialog.bm_damage_christV1", 1);
	Addto(lCussing,								"BMaleDialog.bm_damage_christV2", 2);
	Addto(lCussing,								"BMaleDialog.bm_damage_fuckV1", 1);
	Addto(lCussing,								"BMaleDialog.bm_damage_fuckV2", 2);
	Addto(lCussing,								"BMaleDialog.bm_damage_jesusV1", 1);
	Addto(lCussing,								"BMaleDialog.bm_damage_jesusV2", 2);
	Addto(lCussing,								"BMaleDialog.bm_damage_shitV1", 1);
	Addto(lCussing,								"BMaleDialog.bm_damage_shitV2", 2);

	//Clear(lgetdownscared);
	//Addto(lgetdownscared,						"", 1);

	Clear(ldefiant);
	Addto(ldefiant,								"BMaleDialog.bm_bully_whatyoulookingatV1", 1);
	Addto(ldefiant,								"BMaleDialog.bm_bully_whatyoulookingatV2", 2);
	Addto(ldefiant,								"BMaleDialog.bm_bully_yougotaproblemV1", 1);
	Addto(ldefiant,								"BMaleDialog.bm_bully_yougotaproblemV2", 2);

	Clear(ldefiantline);
	Addto(ldefiantline,							"BMaleDialog.bm_bully_whatyoulookingatV1", 1);
	Addto(ldefiantline,							"BMaleDialog.bm_bully_whatyoulookingatV2", 2);
	Addto(ldefiantline,							"BMaleDialog.bm_bully_yougotaproblemV1", 1);
	Addto(ldefiantline,							"BMaleDialog.bm_bully_yougotaproblemV2", 2);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_damage_shitV1", 1);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_damage_shitV2", 2);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_seecarnage_holyshitV1", 1);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_seecarnage_holyshitV2", 2);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_damage_fuckV1", 1);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_damage_fuckV2", 2);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_seecarnage_holyfuckV1", 1);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_seecarnage_holyfuckV2", 2);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_damage_jesusV1", 1);
	Addto(lCloseToWeapon,						"BMaleDialog.bm_damage_jesusV2", 2);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_1V1", 1);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_1V2", 2);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_2V1", 1);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_2V2", 2);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_3V1", 1);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_3V2", 2);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_4V1", 1);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_4V2", 2);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_5V1", 1);
	Addto(ldecidetofight,						"BMaleDialog.bm_riot_5V2", 2);

	Clear(llaughing);
	Addto(llaughing,							"BMaleDialog.bm_laughV1", 1);

	Clear(lSnickering);
	Addto(lSnickering,							"BMaleDialog.bm_snickerV1", 1);

	//Clear(lOutOfBreath);
	//Addto(lOutOfBreath,							"", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_followup_areyouonmethV1", 1);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_followup_areyouonmethV2", 2);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_followup_yourewackv1", 1);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_followup_yourewackv2", 2);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_seepanic_1V1", 1);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_seepanic_1V2", 2);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_seepanic_2V1", 1);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_seepanic_2V2", 2);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_seepanic_4V1", 1);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_seepanic_4V2", 2);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_seepanic_5V1", 1);
	Addto(lWatchingCrazy,						"BMaleDialog.bm_seepanic_5V2", 2);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,					"BMaleDialog.bm_getcop_helppoliceV1", 1);
	Addto(lshootingoverthere,					"BMaleDialog.bm_getcop_helppoliceV2", 2);
	Addto(lshootingoverthere,					"BMaleDialog.bm_getcop_policex2V1", 1);
	Addto(lshootingoverthere,					"BMaleDialog.bm_getcop_policex2V2", 2);
	Addto(lshootingoverthere,					"BMaleDialog.bm_heargun_blastingpeopleV1", 1);
	Addto(lshootingoverthere,					"BMaleDialog.bm_heargun_blastingpeopleV2", 1);
	Addto(lshootingoverthere,					"BMaleDialog.bm_heargun_shootingoffyoV1", 1);
	Addto(lshootingoverthere,					"BMaleDialog.bm_heargun_shootingoffyoV2", 2);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,					"BMaleDialog.bm_getcop_helppoliceV1", 1);
	Addto(lkillingoverthere,					"BMaleDialog.bm_getcop_helppoliceV2", 2);
	Addto(lkillingoverthere,					"BMaleDialog.bm_getcop_policex2V1", 1);
	Addto(lkillingoverthere,					"BMaleDialog.bm_getcop_policex2V2", 2);
	Addto(lkillingoverthere,					"BMaleDialog.bm_heargun_killingpeopleV1", 1);
	Addto(lkillingoverthere,					"BMaleDialog.bm_heargun_killingpeopleV2", 2);
	Addto(lkillingoverthere,					"BMaleDialog.bm_heargun_killingpeopleV3", 3);
	Addto(lkillingoverthere,					"BMaleDialog.bm_seecarnage_wankstascuttingV1", 1);
	Addto(lkillingoverthere,					"BMaleDialog.bm_seecarnage_wankstascuttingV2", 2);
	
	Clear(lscreaming);
	Addto(lscreaming,							"BMaleDialog.bm_scream1", 1);
	Addto(lscreaming,							"BMaleDialog.bm_scream2", 2);
	Addto(lscreaming,							"BMaleDialog.bm_scream3", 3);
	Addto(lscreaming,							"BMaleDialog.bm_scream4", 4);
	Addto(lscreaming,							"BMaleDialog.bm_scream5", 5);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_awghelpmeV1", 1);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_awghelpmeV2", 2);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_babyjesusV1", 1);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_babyjesusV2", 2);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_fiyaaaV1", 1);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_fiyaaaV2", 2);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_imburningV1", 1);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_imburningV2", 2);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_putmeoutV1", 1);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_putmeoutV2", 2);
	Addto(lscreamingonfire,						"BMaleDialog.bm_onfire_yeaghV1", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_bringitV1", 1);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_bringitV2", 2);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_howaboutsomeofthisV1", 1);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_howaboutsomeofthisV2", 2);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_kingofbrowntownV1", 1);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_kingofbrowntownV2", 2);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_rahV1", 1);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_rahV2", 2);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_youthinkimscaredV1", 1);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_youthinkimscaredV2", 2);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_youthinkyoucanV1", 1);
	Addto(lDoHeroics,							"BMaleDialog.bm_tough_youthinkyoucanV2", 2);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"BMaleDialog.bm_spitoutpissV1", 1);
	Addto(lgettingpissedon,						"BMaleDialog.bm_spitoutpissV2", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_assholeV1", 1);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_assholeV2", 2);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_christV1", 1);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_christV2", 2);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_disgustingV1", 1);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_disgustingV2", 2);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_eughV1", 1);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_eughV2", 2);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_myshirtV1", 1);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_myshirtV2", 2);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_sickV1", 1);
	Addto(laftergettingpissedon,				"BMaleDialog.bm_pissedon_sickV2", 2);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"BMaleDialog.bm_huhV1", 1);
	Addto(lwhatthe,								"BMaleDialog.bm_huhV2", 2);
	Addto(lwhatthe,								"BMaleDialog.bm_pissedon_whattheV1", 1);
	Addto(lwhatthe,								"BMaleDialog.bm_pissedon_whattheV2", 2);
	Addto(lwhatthe,								"BMaleDialog.bm_pissedon_whuhV1", 1);
	Addto(lwhatthe,								"BMaleDialog.bm_pissedon_whuhV2", 2);
	Addto(lwhatthe,								"BMaleDialog.bm_pissedon_heeyV1", 1);
	Addto(lwhatthe,								"BMaleDialog.bm_pissedon_heeyV2", 2);
	Addto(lwhatthe,								"BMaleDialog.bm_thefuckV1", 1);
	Addto(lwhatthe,								"BMaleDialog.bm_thefuckV2", 2);

	Clear(lseeingpisser);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing1V1", 1);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing1V2", 2);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing2V1", 1);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing2V2", 2);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing3V1", 1);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing3V2", 2);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing4V1", 1);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing4V2", 2);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing5V1", 1);
	Addto(lseeingpisser,						"BMaleDialog.bm_seepissing5V2", 2);

	Clear(lSomethingIsGross);
	Addto(lSomethingIsGross,						"BMaleDialog.bm_seepissing3V1", 1);
	Addto(lSomethingIsGross,						"BMaleDialog.bm_seepissing3V2", 2);
	Addto(lSomethingIsGross,						"BMaleDialog.bm_seepissing4V1", 1);
	Addto(lSomethingIsGross,						"BMaleDialog.bm_seepissing4V2", 2);

	Clear(lgothit);
	Addto(lgothit,								"BMaleDialog.bm_damage_aghkV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_aghkV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_aiieeV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_aiieeV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_akV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_akV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_arghV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_arghV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_aughV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_aughV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_badtouchV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_badtouchV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_christV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_christV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_fuckV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_fuckV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_gakV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_gakV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_imhitV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_imhitV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_mommaV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_mommaV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_owV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_owV2", 2);
	Addto(lgothit,								"BMaleDialog.bm_damage_shitV1", 1);
	Addto(lgothit,								"BMaleDialog.bm_damage_shitV2", 2);

	Clear(lAttacked);
	addto(lAttacked,							"BMaleDialog.bm_damage_aghkV1", 1);	
	addto(lAttacked,							"BMaleDialog.bm_damage_aghkV2", 2);	
	addto(lAttacked,							"BMaleDialog.bm_damage_akV1", 1);	
	addto(lAttacked,							"BMaleDialog.bm_damage_akV2", 2);	
	addto(lAttacked,							"BMaleDialog.bm_damage_gakV1", 1);	
	addto(lAttacked,							"BMaleDialog.bm_damage_gakV2", 2);	

	Clear(lGrunt);
	addto(lGrunt,								"BMaleDialog.bm_damage_aghkV1", 1);	
	addto(lGrunt,								"BMaleDialog.bm_damage_aghkV2", 2);	
	addto(lGrunt,								"BMaleDialog.bm_damage_akV1", 1);	
	addto(lGrunt,								"BMaleDialog.bm_damage_akV2", 2);	
	addto(lGrunt,								"BMaleDialog.bm_damage_gakV1", 1);	
	addto(lGrunt,								"BMaleDialog.bm_damage_gakV2", 2);	

	Clear(lPissing);
	Addto(lPissing,								"BMaleDialog.bm_pissing_katrinapantsV1", 1);
	Addto(lPissing,								"BMaleDialog.bm_pissing_katrinapantsV2", 2);
	Addto(lPissing,								"BMaleDialog.bm_pissing_ohyeahV1", 1);
	Addto(lPissing,								"BMaleDialog.bm_pissing_ohyeahV2", 2);
	Addto(lPissing,								"BMaleDialog.bm_pissing_ownbeerV1", 1);
	Addto(lPissing,								"BMaleDialog.bm_pissing_ownbeerV2", 2);
	Addto(lPissing,								"BMaleDialog.bm_pissing_talkinboutV1", 1);
	Addto(lPissing,								"BMaleDialog.bm_pissing_talkinboutV2", 2);

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
	addto(lGotHitInCrotch,						"BMaleDialog.bm_damage_mycolonV1", 1);	
	addto(lGotHitInCrotch,						"BMaleDialog.bm_damage_mycolonV2", 2);	

	Clear(lbegforlife);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_crying1", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_crying2", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_crying3", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_crying4", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_cryingV1", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_cryingV2", 2);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_dontsnuffmeV1", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_dontsnuffmeV2", 2);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_imighthavekidsV1", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_imighthavekidsV2", 2);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_pleasedontkillmeV1", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_pleasedontkillmeV2", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_pleasepleasenoV1", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_pleasepleasenoV2", 2);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_snivel1V1", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_wackcrazymanV1", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_beg_wackcrazymanV2", 2);
	Addto(lbegforlife,							"BMaleDialog.bm_fearful_donthurtmeV1", 1);
	Addto(lbegforlife,							"BMaleDialog.bm_fearful_donthurtmeV2", 2);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_crying1", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_crying2", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_crying3", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_crying4", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_cryingV1", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_cryingV2", 2);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_dontsnuffmeV1", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_dontsnuffmeV2", 2);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_imighthavekidsV1", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_imighthavekidsV2", 2);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_pleasedontkillmeV1", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_pleasedontkillmeV2", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_pleasepleasenoV1", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_pleasepleasenoV2", 2);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_beg_snivel1V1", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_fearful_donthurtmeV1", 1);
	Addto(lbegforlifeMin,						"BMaleDialog.bm_fearful_donthurtmeV2", 2);
	
	Clear(ldying);
	Addto(ldying,								"WMaleDialog.wm_mommy", 1);
	Addto(ldying,								"BMaleDialog.bm_dying_cantfeelmylegs", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl1", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl2", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl3", 1);
	Addto(ldying,								"WMaleDialog.wm_icantbreathe", 1);
	Addto(ldying,								"WMaleDialog.wm_somebodypleasemake", 1);
	Addto(ldying,								"WMaleDialog.wm_godithurts", 1);
	Addto(ldying,								"WMaleDialog.wm_ohgod", 1);
	Addto(ldying,								"WMaleDialog.wm_justfinishit", 1);

	Clear(lCrying);
	Addto(lCrying,								"BMaleDialog.bm_beg_crying1", 1);
	Addto(lCrying,								"BMaleDialog.bm_beg_crying2", 1);
	Addto(lCrying,								"BMaleDialog.bm_beg_crying3", 1);
	Addto(lCrying,								"BMaleDialog.bm_beg_crying4", 1);
	Addto(lCrying,								"BMaleDialog.bm_beg_cryingV1", 1);
	Addto(lCrying,								"BMaleDialog.bm_beg_cryingV2", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,					"BMaleDialog.bm_beg_didntmeanitV1", 1);	
	Addto(lfrightenedapology,					"BMaleDialog.bm_beg_didntmeanitV2", 2);
	Addto(lfrightenedapology,					"BMaleDialog.bm_beg_neveragainV1", 1);	
	Addto(lfrightenedapology,					"BMaleDialog.bm_beg_neveragainV2", 2);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_cmonfightlikeamanV1", 1);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_cmonfightlikeamanV2", 2);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_ohyeahbigmanwithaV1", 1);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_ohyeahbigmanwithaV2", 2);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_wacktacularV1", 1);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_wacktacularV2", 2);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_whereyougoingsissyV1", 1);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_whereyougoingsissyV2", 2);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_yourenotsotoughV1", 1);
	Addto(ltrashtalk,							"BMaleDialog.bm_taunt_yourenotsotoughV2", 2);

	Clear(lWhileFighting);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_cmonfightlikeamanV1", 1);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_cmonfightlikeamanV2", 2);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_ohyeahbigmanwithaV1", 1);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_ohyeahbigmanwithaV2", 2);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_wacktacularV1", 1);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_wacktacularV2", 2);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_whereyougoingsissyV1", 1);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_whereyougoingsissyV2", 2);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_yourenotsotoughV1", 1);
	Addto(lWhileFighting,						"BMaleDialog.bm_taunt_yourenotsotoughV2", 2);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,						"BMaleDialog.bm_whatseemstobetheV1", 1);
	Addto(laskcopwhatsup,						"BMaleDialog.bm_whatseemstobetheV2", 2);

	Clear(lratout);
	Addto(lratout,								"BMaleDialog.bm_report_hediditV1", 1);
	Addto(lratout,								"BMaleDialog.bm_report_hediditV2", 2);
	Addto(lratout,								"BMaleDialog.bm_report_hestheoneV1", 1);
	Addto(lratout,								"BMaleDialog.bm_report_hestheoneV2", 2);
	Addto(lratout,								"BMaleDialog.bm_report_itwashimV1", 1);
	Addto(lratout,								"BMaleDialog.bm_report_itwashimV2", 2);
	Addto(lratout,								"BMaleDialog.bm_report_pureperpetratorV1", 1);
	Addto(lratout,								"BMaleDialog.bm_report_pureperpetratorV2", 2);
	Addto(lratout,								"BMaleDialog.bm_report_thatguyV1", 1);
	Addto(lratout,								"BMaleDialog.bm_report_thatguyV2", 2);
	Addto(lratout,								"BMaleDialog.bm_report_thechumpoverthereV1", 1);
	Addto(lratout,								"BMaleDialog.bm_report_thechumpoverthereV2", 2);

	Clear(lfakeratout);
	Addto(lfakeratout,							"BMaleDialog.bm_lying_hediditisawV1", 1);
	Addto(lfakeratout,							"BMaleDialog.bm_lying_hediditisawV2", 2);
	Addto(lfakeratout,							"BMaleDialog.bm_lying_imawitnessV1", 1);
	Addto(lfakeratout,							"BMaleDialog.bm_lying_imawitnessV2", 2);

	Clear(lcleanshot);
	Addto(lcleanshot,							"BMaleDialog.bm_shotblocked1V1", 1);
	Addto(lcleanshot,							"BMaleDialog.bm_shotblocked1V2", 2);
	Addto(lcleanshot,							"BMaleDialog.bm_shotblocked3V1", 1);
	Addto(lcleanshot,							"BMaleDialog.bm_shotblocked3V2", 2);
	Addto(lcleanshot,							"BMaleDialog.bm_shotblocked4V1", 1);
	Addto(lcleanshot,							"BMaleDialog.bm_shotblocked4V2", 2);
	Addto(lcleanshot,							"BMaleDialog.bm_shotblocked5V1", 1);
	Addto(lcleanshot,							"BMaleDialog.bm_shotblocked5V2", 2);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"BMaleDialog.bm_shotblocked3V1", 1);
	Addto(lCleanMeleeHit,						"BMaleDialog.bm_shotblocked3V2", 2);
	Addto(lCleanMeleeHit,						"BMaleDialog.bm_shotblocked4V1", 1);
	Addto(lCleanMeleeHit,						"BMaleDialog.bm_shotblocked4V2", 2);

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
	Addto(lhmm,									"BMaleDialog.bm_hmmmmV1", 1);
	Addto(lhmm,									"BMaleDialog.bm_hmmmmV2", 1);

	//Clear(lfollowme);
	//Addto(lfollowme,							"", 1);	

	//Clear(lStayHere);
	//Addto(lStayHere,							"", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_dontmakemeseeV1", 1);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_dontmakemeseeV2", 2);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_messawayV1", 1);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_messawayV2", 2);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_openforbidnizV1", 1);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_openforbidnizV2", 2);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_pullyourpantsupV1", 1);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_pullyourpantsupV2", 2);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_pullyourpantsupV3", 3);
	Addto(lnoticedickout,						"BMaleDialog.bm_seewang_whyyourschwartzV1", 1);

	Clear(lilltakenumber);
	Addto(lilltakenumber,							"BMaleDialog.bm_shopper_takeanumber", 1);
	Addto(lilltakenumber,							"BMaleDialog.bm_shopper_takeanumber2", 1);

	Clear(lmakedeposit);
	Addto(lmakedeposit,								"BMaleDialog.bm_shopper_makeadeposit", 1);

	Clear(lmakewithdrawal);
	Addto(lmakewithdrawal,							"BMaleDialog.bm_shopper_withdraw", 1);

	Clear(lconsumerbuy);
	Addto(lconsumerbuy,							"BMaleDialog.bm_shopper_okaygreatthankyou", 1);

	Clear(lconteststoretransaction);
	Addto(lconteststoretransaction,						"BMaleDialog.bm_shopper_kindachopshop", 1);
	
	Clear(lcontestbanktransaction);
	Addto(lcontestbanktransaction,						"BMaleDialog.bm_shopper_kindachopshop", 1);

	Clear(lGoPostal);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_betterecognizeV1", 1);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_betterecognizeV2", 2);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_gonnadieV1", 1);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_gonnadieV2", 2);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_goodbooktoldmeV1", 1);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_goodbooktoldmeV2", 2);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_igotsbulletsV1", 1);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_igotsbulletsV2", 2);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_illusethisV1", 1);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_illusethisV2", 2);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_imeanitV1", 1);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_imeanitV2", 2);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_speakglockV1", 1);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_speakglockV2", 2);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_wackswansonsV1", 1);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_wackswansonsV2", 2);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_youdontwannaknowV1", 1);
	Addto(lGoPostal,							"BMaleDialog.bm_postal_youdontwannaknowV2", 2);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_fearful_isnthappeningV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_fearful_isnthappeningV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_fearful_shitgetoutV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_fearful_shitgetoutV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_ghaspV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_ghaspV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_ainthappeningV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_ainthappeningV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_anyoneseethatV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_anyoneseethatV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_anyoneseethatV3", 3);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_bringamberlampsV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_bringamberlampsV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_bringamberlampsV3", 3);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_callambulanceV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_callambulanceV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_callbetV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_callbetV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_callmarinesV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_callmarinesV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_clocktharejectV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_clocktharejectV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_goingtohurlV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_goingtohurlV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_helpV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_helpV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_holyfuckV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_holyfuckV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_holyshitV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_holyshitV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_jesushelpmeV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_jesushelpmeV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_justkilledthatguyV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_justkilledthatguyV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_killingeveryoneV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_killingeveryoneV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_makeitstopV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_makeitstopV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_notagainV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_notagainV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_ohmygodV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_ohmygodV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_outtahereV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_outtahereV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_runrunV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_runrunV2", 2);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_sweetlordnoV1", 1);
	Addto(lcarnageoccurred,						"BMaleDialog.bm_seecarnage_sweetlordnoV2", 2);

	Clear(lCallCat);
	Addto(lCallCat, 							"BMaleDialog.bm_likescat_herekittyV1", 1);
	Addto(lCallCat, 							"BMaleDialog.bm_likescat_herekittyV2", 2);
	Addto(lCallCat, 							"BMaleDialog.bm_likescat_heytherekittyV1", 1);
	Addto(lCallCat, 							"BMaleDialog.bm_likescat_heytherekittyV2", 2);

	Clear(lHateCat);
	Addto(lHateCat, 							"BMaleDialog.bm_hatescat_fleabagV1", 1);
	Addto(lHateCat, 							"BMaleDialog.bm_hatescat_fleabagV2", 2);
	Addto(lHateCat, 							"BMaleDialog.bm_hatescat_getoutfurballV1", 1);
	Addto(lHateCat, 							"BMaleDialog.bm_hatescat_getoutfurballV2", 2);
	Addto(lHateCat, 							"BMaleDialog.bm_hatescat_herekittyevilV1", 1);
	Addto(lHateCat, 							"BMaleDialog.bm_hatescat_herekittyevilV2", 2);

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"BMaleDialog.bm_damage_christV1", 1);
	Addto(lStartAttackingAnimal,				"BMaleDialog.bm_damage_christV2", 2);
	Addto(lStartAttackingAnimal,				"BMaleDialog.bm_damage_fuckV1", 1);
	Addto(lStartAttackingAnimal,				"BMaleDialog.bm_damage_fuckV2", 2);
	Addto(lStartAttackingAnimal,				"BMaleDialog.bm_damage_jesusV1", 1);
	Addto(lStartAttackingAnimal,				"BMaleDialog.bm_damage_jesusV2", 2);
	Addto(lStartAttackingAnimal,				"BMaleDialog.bm_damage_shitV1", 1);
	Addto(lStartAttackingAnimal,				"BMaleDialog.bm_damage_shitV2", 2);

	Clear(lGettingRobbed);	
	Addto(lGettingRobbed,							"BMaleDialog.bm_getcop_callacopV1", 1);
	Addto(lGettingRobbed,							"BMaleDialog.bm_getcop_callacopV2", 2);
	Addto(lGettingRobbed,							"BMaleDialog.bm_getcop_callthepigsV1", 1);
	Addto(lGettingRobbed,							"BMaleDialog.bm_getcop_callthepigsV2", 2);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"BMaleDialog.bm_ghaspV1", 1);
	Addto(lGettingMugged,						"BMaleDialog.bm_ghaspV2", 2);
	Addto(lGettingMugged,						"BMaleDialog.bm_beg_dontsnuffmeV1", 1);
	Addto(lGettingMugged,						"BMaleDialog.bm_beg_dontsnuffmeV2", 2);
	Addto(lGettingMugged,						"BMaleDialog.bm_beg_snivel1V1", 1);
	Addto(lGettingMugged,						"BMaleDialog.bm_beg_wackcrazymanV1", 1);
	Addto(lGettingMugged,						"BMaleDialog.bm_beg_wackcrazymanV2", 2);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"BMaleDialog.bm_getcop_callacopV1", 1);
	Addto(lAfterMugged,							"BMaleDialog.bm_getcop_callacopV2", 2);
	Addto(lAfterMugged,							"BMaleDialog.bm_getcop_callthepigsV1", 1);
	Addto(lAfterMugged,							"BMaleDialog.bm_getcop_callthepigsV2", 2);

	Clear(lDoMugging);	
	Addto(lDoMugging,							"BMaleDialog.bm_mugger_handoveryourmoney", 1);
	Addto(lDoMugging,							"BMaleDialog.bm_mugger_handoveryourmoney2", 1);
	
	Clear(lQuestion);	
	Addto(lQuestion,							"BMaleDialog.bm_question_whatareyoutalkingV1", 1);
	Addto(lQuestion,							"BMaleDialog.bm_question_whatareyoutalkingV2", 2);
	Addto(lQuestion,							"BMaleDialog.bm_question_whatV1", 1);
	Addto(lQuestion,							"BMaleDialog.bm_question_whatV2", 2);
	Addto(lQuestion,							"BMaleDialog.bm_question_whutchatawkinV1", 1);
	Addto(lQuestion,							"BMaleDialog.bm_question_whutchatawkinV2", 2);
	Addto(lQuestion,							"BMaleDialog.bm_question_whyV1", 1);
	Addto(lQuestion,							"BMaleDialog.bm_question_whyV2", 2);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_chickenwithnobunV1", 1);
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_chickenwithnobunV2", 2);
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_marmosetsV1", 1);
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_marmosetsV2", 2);
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_wackshowV1", 1);
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_wackshowV2", 2);
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_whatdayitisV1", 1);
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_whatdayitisV2", 2);
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_yougotplansV1", 1);
	Addto(lGenericQuestion,						"BMaleDialog.bm_call_yougotplansV2", 2);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"BMaleDialog.bm_disinterest_boringV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_disinterest_boringV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_disinterest_dontcareV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_disinterest_dontcareV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_disinterest_mehV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_disinterest_mehV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_question_idontcareV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_question_idontcareV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_question_whutchatawkinV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_question_whutchatawkinV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_a40iscriticalV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_a40iscriticalV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_callinmylifelineV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_callinmylifelineV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_gatorsinthesewerV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_gatorsinthesewerV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_idontknowV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_idontknowV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_juicebreakfastV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_juicebreakfastV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_onyoutubeV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_onyoutubeV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_upyourassV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_upyourassV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_upyourassV3", 3);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_whatdoigetV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_whatdoigetV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_whenyouretalkingV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_whenyouretalkingV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_whothefuckknowsV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_whothefuckknowsV2", 2);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_youkeeptalkingV1", 1);
	Addto(lGenericAnswer,						"BMaleDialog.bm_response_youkeeptalkingV2", 2);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_areyouevenlisteningV1", 1);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_areyouevenlisteningV2", 2);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_areyouonmethV1", 1);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_areyouonmethV2", 2);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_saywhatV1", 1);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_saywhatV2", 2);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_shutyerpieholeV1", 1);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_shutyerpieholeV2", 2);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_stopdoingthatV1", 1);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_stopdoingthatV2", 2);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_whatsthatshitV1", 1);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_whatsthatshitV2", 2);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_yourewackv1", 1);
	Addto(lGenericFollowup,						"BMaleDialog.bm_followup_yourewackv2", 2);

	Clear(lGenericGoodbye);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_checkyoulaterV1", 1);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_checkyoulaterV2", 2);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_confusednowV1", 1);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_confusednowV2", 2);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_greatseeingyouV1", 1);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_greatseeingyouV2", 2);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_outtahereV1", 1);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_outtahereV2", 2);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_seeyoulaterV1", 1);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_seeyoulaterV2", 2);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_stupidestV1", 1);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_stupidestV2", 2);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_wackasshitV1", 1);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_wackasshitV2", 2);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_yourecrazyV1", 1);
	Addto(lGenericGoodbye,						"BMaleDialog.bm_leadout_yourecrazyV2", 2);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"BMaleDialog.bm_invaded_getouttahere", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seefire__whatsmellsV1", 1);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seefire__whatsmellsV2", 2);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seefire_firex2V1", 1);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seefire_firex2V2", 2);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seefire_holyshitV1", 1);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seefire_holyshitV2", 2);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seefire_ismellbbqV1", 1);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seefire_ismellbbqV2", 2);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seeonfire_allburningV1", 1);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seeonfire_allburningV2", 2);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seeonfire_allburningV3", 3);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seeonfire_dropandrollV1", 1);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seeonfire_dropandrollV2", 2);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seeonfire_hesonfireV1", 1);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seeonfire_hesonfireV2", 2);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seeonfire_ohmygodV1", 1);
	Addto(lsomeoneonfire,						"BMaleDialog.bm_seeonfire_ohmygodV2", 2);

	Clear(labouttopuke);
	Addto(labouttopuke,							"BMaleDialog.bm_puke_idontfeelsogoodV1", 1);
	Addto(labouttopuke,							"BMaleDialog.bm_puke_idontfeelsogoodV2", 2);
	Addto(labouttopuke,							"BMaleDialog.bm_puke_ohgodimV1", 1);
	Addto(labouttopuke,							"BMaleDialog.bm_puke_ohmanimgonnabesickV1", 1);
	Addto(labouttopuke,							"BMaleDialog.bm_puke_ohmanimgonnabesickV2", 2);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,						"BMaleDialog.bm_vomitV1", 1);

	//Clear(lGettingShocked);
	//Addto(lGettingShocked,						"", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,							"HabibDialog.habib_ailili", 1);

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_chickenwithnobunV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_chickenwithnobunV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_marmosetsV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_marmosetsV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_wackshowV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_wackshowV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_whatdayitisV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_whatdayitisV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_yougotplansV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_call_yougotplansV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_burningdrippingV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_burningdrippingV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_chalkedmyipadV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_chalkedmyipadV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_dayumV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_dayumV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_dontfrontmescrubV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_dontfrontmescrubV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_hadtobagitV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_hadtobagitV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_howtheyworkV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_howtheyworkV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_IheardtheressomeV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_IheardtheressomeV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_krotchyebayV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_krotchyebayV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_okayV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_okayV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_quitbugginV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_quitbugginV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_stophappyV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_stophappyV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_thatsfunnyV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_thatsfunnyV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_thatsgreatV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_thatsgreatV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_thatswhatithoughtV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_thatswhatithoughtV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_theysmiraclesV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_theysmiraclesV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_uhhuhV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_uhhuhV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_welldidyouseeemV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_welldidyouseeemV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_yeahbuticanttellV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_yeahbuticanttellV2", 2);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_youwouldntbelieveV1", 1);
	Addto(lCellPhoneTalk,						"BMaleDialog.bm_cell_youwouldntbelieveV2", 2);
	
	//Clear(lZealots);
	//Addto(lZealots,								"", 1);
	
	Clear(lKrotchyCustomerComment);
	Addto(lKrotchyCustomerComment,					"BMaleDialog.bm_darkforkrotchy", 1);

	Clear(lKrotchyCustomerWant);
	Addto(lKrotchyCustomerWant,						"BMaleDialog.bm_shopper_krotchysleft", 1);

	Clear(lGaryAutograph);
	Addto(lGaryAutograph,							"BMaleDialog.bm_gary_willisthing", 1);
	
	//Clear(lProtestorCut);
	//Addto(lProtestorCut,						"", 1);
	
	Clear(ldudedead);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_choadV1", 1);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_choadV2", 2);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_crumbsnowV1", 1);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_crumbsnowV2", 2);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_nextlifeV1", 1);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_nextlifeV2", 2);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_prollyhomoV1", 1);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_prollyhomoV2", 2);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_shouldatriedharderV1", 1);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_shouldatriedharderV2", 2);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_thatdickheadV1", 1);
	Addto(ldudedead,							"BMaleDialog.bm_deadtaunt_thatdickheadV2", 2);

	Clear(lKickDead);
	Addto(lKickDead,							"BMaleDialog.bm_deadtaunt_forgotoneV1", 1);
	Addto(lKickDead,							"BMaleDialog.bm_deadtaunt_forgotoneV2", 2);
	Addto(lKickDead,							"BMaleDialog.bm_deadtaunt_oneformotherV1", 1);
	Addto(lKickDead,							"BMaleDialog.bm_deadtaunt_oneformotherV2", 2);
	Addto(lKickDead,							"BMaleDialog.bm_deadtaunt_takethiswithyouV1", 1);
	Addto(lKickDead,							"BMaleDialog.bm_deadtaunt_takethiswithyouV2", 2);

	Clear(lNameCalling);
	Addto(lNameCalling,								"BMaleDialog.bm_pissedon_heeyV1", 1);
	Addto(lNameCalling,								"BMaleDialog.bm_pissedon_heeyV2", 2);
	Addto(lNameCalling,								"BMaleDialog.bm_thefuckV1", 1);
	Addto(lNameCalling,								"BMaleDialog.bm_thefuckV2", 2);

	Clear(lRogueCop);
	Addto(lRogueCop,							"BMaleDialog.bm_seecarnage_ifihadacameraV1", 1);
	Addto(lRogueCop,							"BMaleDialog.bm_seecarnage_ifihadacameraV2", 2);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_abuseV1", 1);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_abuseV2", 2);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_gankmeacambraV1", 1);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_gankmeacambraV2", 2);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_keepingusdownV1", 1);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_keepingusdownV2", 2);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_pigswackV1", 1);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_pigswackV2", 2);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_stillhasajobV1", 1);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_stillhasajobV2", 2);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_vacationtimeV1", 1);
	Addto(lRogueCop,							"BMaleDialog.bm_seescop_vacationtimeV2", 2);

	Clear(lgetbumped);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_cominthroughV1", 1);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_cominthroughV2", 2);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_heywatchitV1", 1);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_heywatchitV2", 2);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_lookoutV1", 1);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_lookoutV2", 2);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_onesideV1", 1);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_onesideV2", 2);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_oofidiotV1", 1);
	Addto(lgetbumped,							"BMaleDialog.bm_bumped_oofidiotV2", 2);

	Clear(lGetMad);
	Addto(lGetMad,								"BMaleDialog.bm_bully_yougotaproblemV1", 1);
	Addto(lGetMad,								"BMaleDialog.bm_bully_yougotaproblemV2", 2);
	Addto(lGetMad,								"BMaleDialog.bm_bumped_heywatchitV1", 1);
	Addto(lGetMad,								"BMaleDialog.bm_bumped_heywatchitV2", 2);
	Addto(lGetMad,								"BMaleDialog.bm_bumped_lookoutV1", 1);
	Addto(lGetMad,								"BMaleDialog.bm_bumped_lookoutV2", 2);
	Addto(lGetMad,								"BMaleDialog.bm_bumped_oofidiotV1", 1);
	Addto(lGetMad,								"BMaleDialog.bm_bumped_oofidiotV2", 2);

	Clear(lLynchMob);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_gethimV1", 1);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_gethimV2", 2);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_heyyouV1", 1);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_heyyouV2", 2);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_idontlikethelookV1", 1);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_idontlikethelookV2", 2);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_somethingwackV1", 1);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_somethingwackV2", 2);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_thatstheoneV1", 1);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_thatstheoneV2", 2);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_thereheisV1", 1);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_thereheisV2", 2);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_theresthekillerV1", 1);
	Addto(lLynchMob,							"BMaleDialog.bm_lynch_theresthekillerV2", 2);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"BMaleDialog.bm_lynch_gethimV1", 1);
	Addto(lSeesEnemy,							"BMaleDialog.bm_lynch_gethimV2", 2);
	Addto(lSeesEnemy,							"BMaleDialog.bm_lynch_heyyouV1", 1);
	Addto(lSeesEnemy,							"BMaleDialog.bm_lynch_heyyouV2", 2);
	Addto(lSeesEnemy,							"BMaleDialog.bm_tough_howaboutsomeofthisV1", 1);
	Addto(lSeesEnemy,							"BMaleDialog.bm_tough_howaboutsomeofthisV2", 2);
	Addto(lSeesEnemy,							"BMaleDialog.bm_tough_rahV1", 1);
	Addto(lSeesEnemy,							"BMaleDialog.bm_tough_rahV2", 2);

	Clear(lnextinline);
	Addto(lnextinline,							"BMaleDialog.bm_cashier_nextperson", 1);
	
	Clear(lhelpyouoverhere);
	Addto(lhelpyouoverhere,							"BMaleDialog.bm_cashier_helpyou", 1);

	Clear(lsomeonecuts);
	Addto(lsomeonecuts,							"BMaleDialog.bm_cashier_backoftheline", 1);

	Clear(lpleasemoveforward);
	Addto(lpleasemoveforward,						"BMaleDialog.bm_cashier_pleasemoveforward", 1);

	Clear(lcanihelpyou);
	Addto(lcanihelpyou,							"BMaleDialog.bm_cashier_howcanihelp", 1);

	Clear(lNumbers_Thatllbe);
	Addto(lNumbers_Thatllbe,					"BMaleDialog.bm_cashier_thatllbe", 1);

	//Clear(lNumbers_a);
	//Addto(lNumbers_a,							"", 1);

	Clear(lNumbers_1);
	Addto(lNumbers_1,							"BMaleDialog.bm_cashier_1", 1);

	Clear(lNumbers_2);
	Addto(lNumbers_2,							"BMaleDialog.bm_cashier_2", 1);

	Clear(lNumbers_3);
	Addto(lNumbers_3,							"BMaleDialog.bm_cashier_3", 1);

	Clear(lNumbers_4);
	Addto(lNumbers_4,							"BMaleDialog.bm_cashier_4", 1);

	Clear(lNumbers_5);
	Addto(lNumbers_5,							"BMaleDialog.bm_cashier_5", 1);

	Clear(lNumbers_10);
	Addto(lNumbers_10,							"BMaleDialog.bm_cashier_10", 1);

	Clear(lNumbers_20);
	Addto(lNumbers_20,							"BMaleDialog.bm_cashier_20", 1);

	Clear(lNumbers_40);
	Addto(lNumbers_40,							"BMaleDialog.bm_cashier_40", 1);

	Clear(lNumbers_60);
	Addto(lNumbers_60,							"BMaleDialog.bm_cashier_60", 1);

	Clear(lNumbers_80);
	Addto(lNumbers_80,							"BMaleDialog.bm_cashier_80", 1);

	Clear(lNumbers_100);
	Addto(lNumbers_100,							"BMaleDialog.bm_cashier_100", 1);

	Clear(lNumbers_200);
	Addto(lNumbers_200,							"BMaleDialog.bm_cashier_200", 1);

	Clear(lNumbers_300);
	Addto(lNumbers_300,							"BMaleDialog.bm_cashier_300", 1);

	Clear(lNumbers_400);
	Addto(lNumbers_400,							"BMaleDialog.bm_cashier_400", 1);

	Clear(lNumbers_500);
	Addto(lNumbers_500,							"BMaleDialog.bm_cashier_500", 1);

	Clear(lNumbers_Dollars);
	Addto(lNumbers_Dollars,						"BMaleDialog.bm_cashier_dollars", 1);

	Clear(lNumbers_SingleDollar);
	Addto(lNumbers_SingleDollar,				"BMaleDialog.bm_cashier_dollar", 1);

	Clear(lsellingitem);
	Addto(lsellingitem,							"BMaleDialog.bm_cashier_thereyougo", 1);

	Clear(lIsThisEverything);
	Addto(lIsThisEverything,						"BMaleDialog.bm_cashier_thiseverything", 1);
	
	Clear(llackofmoney);
	Addto(llackofmoney,							"BMaleDialog.bm_cashier_needmoremoney", 1);

	Clear(lSignPetition);							
	Addto(lSignPetition,						"BMaleDialog.bm_positive_giveitaspinV1", 1);
	Addto(lSignPetition,						"BMaleDialog.bm_positive_giveitaspinV2", 2);
	Addto(lSignPetition,						"BMaleDialog.bm_positive_icandothatV1", 1);
	Addto(lSignPetition,						"BMaleDialog.bm_positive_icandothatV2", 2);
	Addto(lSignPetition,						"BMaleDialog.bm_positive_surethingV1", 1);
	Addto(lSignPetition,						"BMaleDialog.bm_positive_surethingV2", 2);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_absolutelynotV1", 1);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_absolutelynotV2", 2);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_asifV1", 1);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_asifV2", 2);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_fuckthatV1", 1);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_fuckthatV2", 2);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_idontthinksoV1", 1);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_idontthinksoV2", 2);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_nothanksV1", 1);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_nothanksV2", 2);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_notinterestedV1", 1);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_notinterestedV2", 2);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_sorryV1", 1);
	Addto(lDontSignPetition,					"BMaleDialog.bm_negative_sorryV2", 2);

	Clear(lPetitionBother);
	Addto(lPetitionBother,						"BMaleDialog.bm_negative_goawayV1", 1);
	Addto(lPetitionBother,						"BMaleDialog.bm_negative_goawayV2", 2);
	
	Clear(lChampPhotoReaction);
	Addto(lChampPhotoReaction,					"BMaleDialog.bm_ghaspV2", 1);
	Addto(lChampPhotoReaction,					"BMaleDialog.bm_ghaspV1", 2);
	Addto(lChampPhotoReaction,					"BMaleDialog.bm_seecarnage_holyfuckV2", 1);
	Addto(lChampPhotoReaction,					"BMaleDialog.bm_seecarnage_holyfuckV1", 2);
	Addto(lChampPhotoReaction,					"BMaleDialog.bm_seecarnage_holyshitV1", 1);
	Addto(lChampPhotoReaction,					"BMaleDialog.bm_seecarnage_holyshitV2", 2);
	Addto(lChampPhotoReaction,					"BMaleDialog.bm_seecarnage_sweetlordnoV2", 1);
	Addto(lChampPhotoReaction,					"BMaleDialog.bm_seecarnage_sweetlordnoV1", 2);

	if(bParadiseLost) // xPatch: Crash Fix
	{
		Clear(lPhoto_FindWiseWang);
		Addto(lPhoto_FindWiseWang,					"PL-Dialog.MondayA.BMale-SpeakToTheWiseMan", 1);
	}
	
	Clear(lcallsecurity);
	Addto(lcallsecurity,							"BMaleDialog.bm_callthepolice", 1);
	
	Clear(lrowdycustomer);
	Addto(lrowdycustomer,							"BMaleDialog.bm_callthepolice", 1);
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	VolumeMult=0.80
	bCheckDLCDialog=True
}
