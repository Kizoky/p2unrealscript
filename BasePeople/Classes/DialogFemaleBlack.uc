///////////////////////////////////////////////////////////////////////////////
// DialogBlackFemale
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all black females
//
///////////////////////////////////////////////////////////////////////////////
class DialogFemaleBlack extends DialogFemale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();

	Clear(lapplauding);
	AddTo(lApplauding,							"BFemaleDialog.bf_cheer_awesomeV1", 1);
	AddTo(lApplauding,							"BFemaleDialog.bf_cheer_booyeahV1", 1);
	AddTo(lApplauding,							"BFemaleDialog.bf_cheer_nowayV1", 1);
	AddTo(lApplauding,							"BFemaleDialog.bf_cheer_offthehookV1", 1);
	AddTo(lApplauding,							"BFemaleDialog.bf_cheer_whatimtalkinV1", 1);
	AddTo(lApplauding,							"BFemaleDialog.bf_cheer_wootV1", 1);
	AddTo(lApplauding,							"BFemaleDialog.bf_cheer_wootV2", 2);
	AddTo(lApplauding,							"BFemaleDialog.bf_cheer_yeahV1", 1);
	AddTo(lApplauding,							"BFemaleDialog.bf_cheer_yeahV2", 2);

	Clear(lgreeting);
	Addto(lgreeting,							"BFemaleDialog.bf_greet_helloV1", 1);
	Addto(lgreeting,							"BFemaleDialog.bf_greet_helloV2", 2);
	Addto(lgreeting,							"BFemaleDialog.bf_greet_heyV1", 1);
	Addto(lgreeting,							"BFemaleDialog.bf_greet_hiV1", 1);
	Addto(lgreeting,							"BFemaleDialog.bf_greet_supV1", 1);

	Clear(lhotgreeting);
	Addto(lhotGreeting,							"BFemaleDialog.bf_sleez_helloV1", 1);
	Addto(lhotGreeting,							"BFemaleDialog.bf_sleez_heybabyV1", 1);
	Addto(lhotGreeting,							"BFemaleDialog.bf_sleez_hiV1", 1);
	Addto(lhotGreeting,							"BFemaleDialog.bf_sleez_supV1", 1);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,					"BFemaleDialog.bf_greet_howareyouV1", 1);
	Addto(lGreetingquestions,					"BFemaleDialog.bf_greet_howsitgoingV1", 1);
	Addto(lGreetingquestions,					"BFemaleDialog.bf_greet_howyoudoinV1", 1);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,				"BFemaleDialog.bf_sleez_howareyouV1", 1);
	Addto(lHotGreetingquestions,				"BFemaleDialog.bf_sleez_howsitgoingV1", 1);
	Addto(lHotGreetingquestions,				"BFemaleDialog.bf_sleez_howyoudoinV1", 1);

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,				"BFemaleDialog.bf_doiknowyouV1", 1);
	Addto(lrespondtohotgreeting,				"BFemaleDialog.bf_negative_goawayV1", 1);
	Addto(lrespondtohotgreeting,				"BFemaleDialog.bf_negative_notinterestedV1", 1);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,					"BFemaleDialog.bf_beenbetterV1", 1);
	Addto(lrespondtogreeting,					"BFemaleDialog.bf_doiknowyouV1", 1);
	Addto(lrespondtogreeting,					"BFemaleDialog.bf_grandmawcamedownV1", 1);
	Addto(lrespondtogreeting,					"BFemaleDialog.bf_grandmawcamedownV2", 2);
	Addto(lrespondtogreeting,					"BFemaleDialog.bf_hangintightV1", 1);
	Addto(lrespondtogreeting,					"BFemaleDialog.bf_ohokayiguessV1", 1);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,			"BFemaleDialog.bf_gladtohearitV1", 1);
	Addto(lrespondtogreetingresponse,			"BFemaleDialog.bf_gladtohearitV2", 2);
	Addto(lrespondtogreetingresponse,			"BFemaleDialog.bf_gladtohearitV3", 3);
	Addto(lrespondtogreetingresponse,			"BFemaleDialog.bf_gladtohearitV4", 4);
	Addto(lrespondtogreetingresponse,			"BFemaleDialog.bf_noproblemV1", 1);
	Addto(lrespondtogreetingresponse,			"BFemaleDialog.bf_noworriesV1", 1);

	Clear(lHelloCop);
	Addto(lHelloCop,								"BFemaleDialog.bf_isanythingwrongV1", 1);
	Addto(lHelloCop,								"BFemaleDialog.bf_whatseemstobetheV1", 1);
	Addto(lHelloCop,								"BFemaleDialog.bf_onprobationV1", 1);
	Addto(lHelloCop,								"BFemaleDialog.bf_onprobationV2", 2);
	Addto(lHelloCop,								"BFemaleDialog.bf_onprobationV3", 3);
	Addto(lHelloCop,								"BFemaleDialog.bf_nuttinonmeV1", 1);
	
	//Clear(lHelloGimp);
	//Addto(lHelloGimp,							"", 1);

	Clear(lApologize);
	Addto(lApologize,							"BFemaleDialog.bf_sorryV1", 1);
	Addto(lApologize,							"BFemaleDialog.bf_sorryV2", 1);

	//Clear(lyourewelcome);
	//Addto(lyourewelcome,						"", 1);

	Clear(lno);
	Addto(lno,									"BFemaleDialog.bf_negative_absolutelynotV1", 1);
	Addto(lno,									"BFemaleDialog.bf_negative_asifV1", 1);
	Addto(lno,									"BFemaleDialog.bf_negative_fuckthatV1", 1);
	Addto(lno,									"BFemaleDialog.bf_negative_fuckthatV2", 2);
	Addto(lno,									"BFemaleDialog.bf_negative_idontthinksoV1", 1);
	Addto(lno,									"BFemaleDialog.bf_negative_idontthinksoV2", 2);
	Addto(lno,									"BFemaleDialog.bf_negative_nawV1", 1);
	Addto(lno,									"BFemaleDialog.bf_negative_nothanksV1", 1);
	Addto(lno,									"BFemaleDialog.bf_negative_notinterestedV1", 1);
	Addto(lno,									"BFemaleDialog.bf_negative_notV1", 1);
	Addto(lno,									"BFemaleDialog.bf_negative_noV1", 1);
	Addto(lno,									"BFemaleDialog.bf_negative_sorryV1", 1);

	Clear(lyes);
	Addto(lyes,									"BFemaleDialog.bf_positive_aightV1", 1);
	Addto(lyes,									"BFemaleDialog.bf_positive_asfarasyouknowV1", 1);
	Addto(lyes,									"BFemaleDialog.bf_positive_foshizzleV1", 1);
	Addto(lyes,									"BFemaleDialog.bf_positive_sureV1", 1);
	Addto(lyes,									"BFemaleDialog.bf_positive_uhhunhV1", 1);
	Addto(lyes,									"BFemaleDialog.bf_positive_yeahV1", 1);

	Clear(lthanks);
	Addto(lthanks,								"BFemaleDialog.bf_coolthanksV1", 1);
	Addto(lthanks,								"BFemaleDialog.bf_positive_greatV1", 1);
	Addto(lthanks,								"BFemaleDialog.bf_positive_kickassV1", 1);
	Addto(lthanks,								"BFemaleDialog.bf_positive_sweetV1", 1);
	Addto(lthanks,								"BFemaleDialog.bf_positive_sweetV2", 2);
	Addto(lthanks,								"BFemaleDialog.bf_positive_thanksV1", 1);
	Addto(lthanks,								"BFemaleDialog.bf_positive_thatrocksV1", 1);
	Addto(lthanks,								"BFemaleDialog.bf_positive_youthebombV1", 1);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"BFemaleDialog.bf_positive_greatV1", 1);
	Addto(lThatsGreat,							"BFemaleDialog.bf_positive_hollav1", 1);
	Addto(lThatsGreat,							"BFemaleDialog.bf_positive_hollav2", 2);
	Addto(lThatsGreat,							"BFemaleDialog.bf_positive_kickassV1", 1);
	Addto(lThatsGreat,							"BFemaleDialog.bf_positive_sweetV1", 1);
	Addto(lThatsGreat,							"BFemaleDialog.bf_positive_sweetV2", 2);
	Addto(lThatsGreat,							"BFemaleDialog.bf_positive_thatrocksV1", 1);

	Clear(lGetDown);
	AddTo(lGetDown,								"BFemaleDialog.bf_shotblocked2V1", 1);
	AddTo(lGetDown,								"BFemaleDialog.bf_shotblocked2V2", 2);
	AddTo(lGetDown,								"BFemaleDialog.bf_shotblocked4V1", 1);

	//Clear(lGetDownMP);
	//AddTo(lGetDownMP,							"", 1);

	Clear(lCussing);
	Addto(lCussing,								"BFemaleDialog.bf_damage_christV1", 1);
	Addto(lCussing,								"BFemaleDialog.bf_damage_fuckV1", 1);
	Addto(lCussing,								"BFemaleDialog.bf_damage_shitV1", 1);

	//Clear(lgetdownscared);
	//Addto(lgetdownscared,						"", 1);

	Clear(ldefiant);
	//Addto(ldefiant,								"BFemaleDialog.bf_bully_iheardthatV1", 1);
	Addto(ldefiant,								"BFemaleDialog.bf_bully_yougottaissueV1", 1);
	Addto(ldefiant,								"BFemaleDialog.bf_bully_youwantdramaV1", 1);
	Addto(ldefiant,								"BFemaleDialog.bf_nottalking2meV1", 1);
	Addto(ldefiant,								"BFemaleDialog.bf_nottalking2meV2", 2);
	Addto(ldefiant,								"BFemaleDialog.bf_nottalking2meV3", 3);

	Clear(ldefiantline);
	//Addto(ldefiantline,							"BFemaleDialog.bf_bully_iheardthatV1", 1);
	Addto(ldefiantline,							"BFemaleDialog.bf_bully_yougottaissueV1", 1);
	Addto(ldefiantline,							"BFemaleDialog.bf_bully_youwantdramaV1", 1);
	Addto(ldefiantline,							"BFemaleDialog.bf_nottalking2meV1", 1);
	Addto(ldefiantline,							"BFemaleDialog.bf_nottalking2meV2", 2);
	Addto(ldefiantline,							"BFemaleDialog.bf_nottalking2meV3", 3);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"BFemaleDialog.bf_damage_shitV1", 1);
	Addto(lCloseToWeapon,						"BFemaleDialog.bf_damage_fuckV1", 1);
	Addto(lCloseToWeapon,						"BFemaleDialog.bf_seecarnage_holyfuckV1", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"BFemaleDialog.bf_riot1V1", 1);
	Addto(ldecidetofight,						"BFemaleDialog.bf_riot1V2", 2);
	Addto(ldecidetofight,						"BFemaleDialog.bf_riot2V1", 1);
	Addto(ldecidetofight,						"BFemaleDialog.bf_riot3V1", 1);
	Addto(ldecidetofight,						"BFemaleDialog.bf_riot4V1", 1);
	Addto(ldecidetofight,						"BFemaleDialog.bf_riot5V1", 1);

	Clear(llaughing);
	Addto(llaughing,							"BFemaleDialog.bf_laughV1", 1);
	Addto(llaughing,							"BFemaleDialog.bf_laughV2", 1);
	Addto(llaughing,							"BFemaleDialog.bf_laughV3", 1);

	//Clear(lSnickering);
	//Addto(lSnickering,							"", 1);

	//Clear(lOutOfBreath);
	//Addto(lOutOfBreath,							"", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"BFemaleDialog.bf_followup_areyouoncrazyV1", 1);
	Addto(lWatchingCrazy,						"BFemaleDialog.bf_followup_completelywackV1", 1);
	Addto(lWatchingCrazy,						"BFemaleDialog.bf_seepanic_1V1", 1);
	Addto(lWatchingCrazy,						"BFemaleDialog.bf_seepanic_2V1", 1);
	Addto(lWatchingCrazy,						"BFemaleDialog.bf_seepanic_3V1", 1);
	Addto(lWatchingCrazy,						"BFemaleDialog.bf_seepanic_4V1", 1);
	Addto(lWatchingCrazy,						"BFemaleDialog.bf_seepanic_5V1", 1);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,					"BFemaleDialog.bf_getcop_helpV1", 1);
	Addto(lshootingoverthere,					"BFemaleDialog.bf_getcop_policex2V1", 1);
	Addto(lshootingoverthere,					"BFemaleDialog.bf_heargun_shootingoffV1", 1);
	Addto(lshootingoverthere,					"BFemaleDialog.bf_seecarnage_hesgotagunV1", 1);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,					"BFemaleDialog.bf_getcop_helpV1", 1);
	Addto(lkillingoverthere,					"BFemaleDialog.bf_getcop_policex2V1", 1);
	Addto(lkillingoverthere,					"BFemaleDialog.bf_heargun_blastingpeopleV1", 1);
	Addto(lkillingoverthere,					"BFemaleDialog.bf_heargun_killingpeopleV1", 1);
	Addto(lkillingoverthere,					"BFemaleDialog.bf_seecarnage_hesgotagunV1", 1);
	Addto(lkillingoverthere,					"BFemaleDialog.bf_seecarnage_heskillingV1", 1);
	Addto(lkillingoverthere,					"BFemaleDialog.bf_seecarnage_justkilledthatguyV1", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,							"BFemaleDialog.bf_scream1", 1);
	Addto(lscreaming,							"BFemaleDialog.bf_scream2", 1);
	Addto(lscreaming,							"BFemaleDialog.bf_scream3", 1);
	Addto(lscreaming,							"BFemaleDialog.bf_scream4", 1);
	Addto(lscreaming,							"BFemaleDialog.bf_scream5", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"BFemaleDialog.bf_onfire_awghelpmeV1", 1);
	Addto(lscreamingonfire,						"BFemaleDialog.bf_onfire_awghelpmeV2", 2);
	Addto(lscreamingonfire,						"BFemaleDialog.bf_onfire_fiyaaV1", 1);
	Addto(lscreamingonfire,						"BFemaleDialog.bf_onfire_fiyaaV2", 2);
	Addto(lscreamingonfire,						"BFemaleDialog.bf_onfire_fiyaaV3", 3);
	Addto(lscreamingonfire,						"BFemaleDialog.bf_onfire_imburningV1", 1);
	Addto(lscreamingonfire,						"BFemaleDialog.bf_onfire_putmeoutV1", 1);
	Addto(lscreamingonfire,						"BFemaleDialog.bf_onfire_sweetbabyjesusV1", 1);
	Addto(lscreamingonfire,						"BFemaleDialog.bf_onfire_yeaghV1", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"BFemaleDialog.bf_tough_bringitV1", 1);
	Addto(lDoHeroics,							"BFemaleDialog.bf_tough_bringitV2", 2);
	Addto(lDoHeroics,							"BFemaleDialog.bf_tough_howaboutsomeofthisV1", 1);
	Addto(lDoHeroics,							"BFemaleDialog.bf_tough_queenofbrowntownV1", 1);
	Addto(lDoHeroics,							"BFemaleDialog.bf_tough_queenofbrowntownV2", 2);
	Addto(lDoHeroics,							"BFemaleDialog.bf_tough_rahV1", 1);
	Addto(lDoHeroics,							"BFemaleDialog.bf_tough_rahV2", 2);
	Addto(lDoHeroics,							"BFemaleDialog.bf_tough_youthinkimscaredV1", 1);
	Addto(lDoHeroics,							"BFemaleDialog.bf_tough_youthinkthatcanV1", 1);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"BFemaleDialog.bf_spitoutpissV1", 1);
	Addto(lgettingpissedon,						"BFemaleDialog.bf_spitoutpissV2", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"BFemaleDialog.bf_pissedon_assholeV1", 1);
	Addto(laftergettingpissedon,				"BFemaleDialog.bf_pissedon_christV1", 1);
	Addto(laftergettingpissedon,				"BFemaleDialog.bf_pissedon_christV2", 1);
	Addto(laftergettingpissedon,				"BFemaleDialog.bf_pissedon_coiffV1", 1);
	Addto(laftergettingpissedon,				"BFemaleDialog.bf_pissedon_coiffV2", 1);
	Addto(laftergettingpissedon,				"BFemaleDialog.bf_pissedon_disgustingV1", 1);
	Addto(laftergettingpissedon,				"BFemaleDialog.bf_pissedon_eughV1", 1);
	Addto(laftergettingpissedon,				"BFemaleDialog.bf_pissedon_eughV2", 1);
	Addto(laftergettingpissedon,				"BFemaleDialog.bf_pissedon_myblouseV1", 1);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"BFemaleDialog.bf_huhV1", 1);
	Addto(lwhatthe,								"BFemaleDialog.bf_pissedon_heeyV1", 1);
	Addto(lwhatthe,								"BFemaleDialog.bf_pissedon_whattheV1", 1);
	Addto(lwhatthe,								"BFemaleDialog.bf_pissedon_whattheV2", 2);
	Addto(lwhatthe,								"BFemaleDialog.bf_pissedon_whuhV1", 1);
	Addto(lwhatthe,								"BFemaleDialog.bf_pissedon_whuhV2", 2);

	Clear(lseeingpisser);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing1V1", 1);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing2V1", 1);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing3V1", 1);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing3V2", 2);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing3V3", 3);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing3V4", 4);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing4V1", 1);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing5V1", 1);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing5V2", 2);
	Addto(lseeingpisser,						"BFemaleDialog.bf_seespissing5V3", 3);

	//Clear(lSomethingIsGross);
	//Addto(lSomethingIsGross,					"", 1);

	Clear(lgothit);
	Addto(lgothit,								"BFemaleDialog.bf_damage_aghkV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_aiieeV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_akV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_arghV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_aughV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_badtouchV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_christV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_fuckV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_gakV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_gakV2", 2);
	Addto(lgothit,								"BFemaleDialog.bf_damage_imhitV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_imhitV2", 2);
	Addto(lgothit,								"BFemaleDialog.bf_damage_mommaV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_ow", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_owbitchV1", 1);
	Addto(lgothit,								"BFemaleDialog.bf_damage_shitV1", 1);

	Clear(lAttacked);
	addto(lAttacked,							"BFemaleDialog.bf_damage_aghkV1", 1);	
	addto(lAttacked,							"BFemaleDialog.bf_damage_akV1", 1);	
	addto(lAttacked,							"BFemaleDialog.bf_damage_arghV1", 1);	
	addto(lAttacked,							"BFemaleDialog.bf_damage_aughV1", 1);	
	addto(lAttacked,							"BFemaleDialog.bf_damage_gakV1", 1);
	addto(lAttacked,							"BFemaleDialog.bf_damage_gakV2", 2);

	Clear(lGrunt);
	addto(lGrunt,							"BFemaleDialog.bf_damage_aghkV1", 1);	
	addto(lGrunt,							"BFemaleDialog.bf_damage_akV1", 1);	
	addto(lGrunt,							"BFemaleDialog.bf_damage_arghV1", 1);	
	addto(lGrunt,							"BFemaleDialog.bf_damage_aughV1", 1);	
	addto(lGrunt,							"BFemaleDialog.bf_damage_gakV1", 1);
	addto(lGrunt,							"BFemaleDialog.bf_damage_gakV2", 2);

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
	addto(lGotHitInCrotch,						"BFemaleDialog.bf_damage_myuvulaV1", 1);	
	addto(lGotHitInCrotch,						"BFemaleDialog.bf_damage_myuvulaV2", 2);	

	Clear(lbegforlife);
	Addto(lbegforlife,							"BFemaleDialog.bf_beg_crazypersonV1", 1);
	Addto(lbegforlife,							"BFemaleDialog.bf_beg_crying1", 1);
	Addto(lbegforlife,							"BFemaleDialog.bf_beg_crying2", 1);
	Addto(lbegforlife,							"BFemaleDialog.bf_beg_crying3", 1);
	Addto(lbegforlife,							"BFemaleDialog.bf_beg_cryingV1", 1);
	Addto(lbegforlife,							"BFemaleDialog.bf_beg_dontkackmeV1", 1);
	Addto(lbegforlife,							"BFemaleDialog.bf_beg_pleasedontkillmeV1", 1);
	Addto(lbegforlife,							"BFemaleDialog.bf_beg_pleasepleasenoV1", 1);
	Addto(lbegforlife,							"BFemaleDialog.bf_beg_somebodysmommaV1", 1);
	Addto(lbegforlife,							"BFemaleDialog.bf_fearful_donthurtV1", 1);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_beg_crazypersonV1", 1);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_beg_crying1", 1);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_beg_crying2", 1);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_beg_crying3", 1);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_beg_cryingV1", 1);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_beg_dontkackmeV1", 1);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_beg_pleasedontkillmeV1", 1);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_beg_pleasepleasenoV1", 1);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_beg_somebodysmommaV1", 1);
	Addto(lbegforlifeMin,						"BFemaleDialog.bf_fearful_donthurtV1", 1);
	
	//Clear(ldying);
	//Addto(ldying,								"", 1);

	Clear(lCrying);
	Addto(lCrying,								"BFemaleDialog.bf_beg_crying1", 1);
	Addto(lCrying,								"BFemaleDialog.bf_beg_crying2", 1);
	Addto(lCrying,								"BFemaleDialog.bf_beg_crying3", 1);
	Addto(lCrying,								"BFemaleDialog.bf_beg_cryingV1", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,					"BFemaleDialog.bf_beg_ididntmeanitV1", 1);	
	Addto(lfrightenedapology,					"BFemaleDialog.bf_beg_neveragainV1", 1);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"BFemaleDialog.bf_taunt_cmonfightlikeamanV1", 1);
	Addto(ltrashtalk,							"BFemaleDialog.bf_taunt_junkisntasbigV1", 1);
	Addto(ltrashtalk,							"BFemaleDialog.bf_taunt_ohyeahbigmanwithaV1", 1);
	Addto(ltrashtalk,							"BFemaleDialog.bf_taunt_ohyeahbigmanwithaV2", 2);
	Addto(ltrashtalk,							"BFemaleDialog.bf_taunt_whatyougonnadoV1", 1);
	Addto(ltrashtalk,							"BFemaleDialog.bf_taunt_yourenotsotoughV1", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting,						"BFemaleDialog.bf_taunt_cmonfightlikeamanV1", 1);
	Addto(lWhileFighting,						"BFemaleDialog.bf_taunt_junkisntasbigV1", 1);
	Addto(lWhileFighting,						"BFemaleDialog.bf_taunt_ohyeahbigmanwithaV1", 1);
	Addto(lWhileFighting,						"BFemaleDialog.bf_taunt_ohyeahbigmanwithaV2", 2);
	Addto(lWhileFighting,						"BFemaleDialog.bf_taunt_whatyougonnadoV1", 1);
	Addto(lWhileFighting,						"BFemaleDialog.bf_taunt_yourenotsotoughV1", 1);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,						"BFemaleDialog.bf_whatseemstobetheV1", 1);

	Clear(lratout);
	Addto(lratout,								"BFemaleDialog.bf_report_hediditV1", 1);
	Addto(lratout,								"BFemaleDialog.bf_report_hestheoneV1", 1);
	Addto(lratout,								"BFemaleDialog.bf_report_hesyourperpV1", 1);
	Addto(lratout,								"BFemaleDialog.bf_report_hesyourperpV2", 2);
	Addto(lratout,								"BFemaleDialog.bf_report_hesyourperpV3", 3);
	Addto(lratout,								"BFemaleDialog.bf_report_itwashimV1", 1);
	Addto(lratout,								"BFemaleDialog.bf_report_thatguyV1", 1);
	Addto(lratout,								"BFemaleDialog.bf_report_thatonerightthereV1", 1);

	Clear(lfakeratout);
	Addto(lfakeratout,							"BFemaleDialog.bf_lying_hediditisawV1", 1);
	Addto(lfakeratout,							"BFemaleDialog.bf_lying_imawitnessV1", 1);

	Clear(lcleanshot);
	Addto(lcleanshot,							"BFemaleDialog.bf_shotblocked1V1", 1);
	Addto(lcleanshot,							"BFemaleDialog.bf_shotblocked3V1", 1);
	Addto(lcleanshot,							"BFemaleDialog.bf_shotblocked4V1", 1);
	Addto(lcleanshot,							"BFemaleDialog.bf_shotblocked5V1", 1);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"BFemaleDialog.bf_shotblocked3V1", 1);
	Addto(lCleanMeleeHit,						"BFemaleDialog.bf_shotblocked4V1", 1);

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
	Addto(lhmm,									"BFemaleDialog.bf_hmmmmV1", 1);

	//Clear(lfollowme);
	//Addto(lfollowme,							"", 1);	

	//Clear(lStayHere);
	//Addto(lStayHere,							"", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,						"BFemaleDialog.bf_seewang_checkyourselfV1", 1);
	Addto(lnoticedickout,						"BFemaleDialog.bf_seewang_didntneedtoseethatV1", 1);
	Addto(lnoticedickout,						"BFemaleDialog.bf_seewang_magnifyingglassV1", 1);
	Addto(lnoticedickout,						"BFemaleDialog.bf_seewang_messawayV1", 1);
	Addto(lnoticedickout,						"BFemaleDialog.bf_seewang_pullyourpantsupV1", 1);

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
	Addto(lGoPostal,							"BFemaleDialog.bf_postal_betterstepbackV1", 1);
	Addto(lGoPostal,							"BFemaleDialog.bf_postal_getouttamyfaceV1", 1);
	Addto(lGoPostal,							"BFemaleDialog.bf_postal_igotammoV1", 1);
	Addto(lGoPostal,							"BFemaleDialog.bf_postal_illusethisV1", 1);
	Addto(lGoPostal,							"BFemaleDialog.bf_postal_scrubsgonnapayV1", 1);
	Addto(lGoPostal,							"BFemaleDialog.bf_postal_speakglockV1", 1);
	Addto(lGoPostal,							"BFemaleDialog.bf_postal_takinyalldownV1", 1);
	Addto(lGoPostal,							"BFemaleDialog.bf_postal_thegoodbookV1", 1);
	Addto(lGoPostal,							"BFemaleDialog.bf_postal_youdonwannaknowV1", 1);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_fearful_getoutV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_fearful_imleavingV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_fearful_isnthappeningV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_ghasp", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_ghaspV2", 2);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_ainthappeninV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_aintrightV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_amberlampsV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_amberlampsV2", 2);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_amberlampsV3", 3);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_amberlampsV4", 4);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_ambulanceV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_anyoneseethatV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_apocalypseV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_callnationalguardV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_calloprahV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_calloprahV2", 2);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_cantbelievehappeningV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_cantbelievehedidthatV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_clockthatrejectV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_endtimesV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_helpV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_heskillingV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_holyfuckV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_jesushelpV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_jesushelpV2", 2);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_justgetalongV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_makeitstopV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_needcouncellingV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_notagainV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_ohmygodV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_outtahereV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_runrunV1", 1);
	Addto(lcarnageoccurred,						"BFemaleDialog.bf_seecarnage_sweetlordnoV1", 1);

	Clear(lCallCat);
	Addto(lCallCat, 							"BFemaleDialog.bf_hatescat_herekittyV1", 1);
	Addto(lCallCat, 							"BFemaleDialog.bf_likescat_heytherekittyV1", 1);

	Clear(lHateCat);
	Addto(lHateCat, 							"BFemaleDialog.bf_hatescat_getoutfurballV1", 1);
	Addto(lHateCat, 							"BFemaleDialog.bf_hatescat_goddamcatV1", 1);
	Addto(lHateCat, 							"BFemaleDialog.bf_hatescat_herekittyevilV1", 1);

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"BFemaleDialog.bf_damage_christV1", 1);
	Addto(lStartAttackingAnimal,				"BFemaleDialog.bf_damage_fuckV1", 1);
	Addto(lStartAttackingAnimal,				"BFemaleDialog.bf_damage_shitV1", 1);

	//Clear(lGettingRobbed);	
	//Addto(lGettingRobbed,						"", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"BFemaleDialog.bf_fearful_donthurtV1", 1);
	Addto(lGettingMugged,						"BFemaleDialog.bf_ghasp", 1);
	Addto(lGettingMugged,						"BFemaleDialog.bf_ghaspV2", 1);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"BFemaleDialog.bf_getcop_callacopV1", 1);
	Addto(lAfterMugged,							"BFemaleDialog.bf_getcop_helpV1", 1);
	Addto(lAfterMugged,							"BFemaleDialog.bf_getcop_policex2V1", 1);
	Addto(lAfterMugged,							"BFemaleDialog.bf_getcop_popoV1", 1);

	//Clear(lDoMugging);	
	//Addto(lDoMugging,							"", 3);
	
	Clear(lQuestion);	
	Addto(lQuestion,							"BFemaleDialog.bf_question_whatareyoutalkingV1", 1);
	Addto(lQuestion,							"BFemaleDialog.bf_question_whatchutawkinV1", 1);
	Addto(lQuestion,							"BFemaleDialog.bf_question_whatV1", 1);
	Addto(lQuestion,							"BFemaleDialog.bf_question_whyV1", 1);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_chickenandwafflesV1", 1);
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_chickenandwafflesV2", 2);
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_chickenandwafflesV3", 3);
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_howlongV1", 1);
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_needextendedfoodV1", 1);
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_needextendedfoodV2", 2);
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_needextendedfoodV3", 3);
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_placetobuyendoV1", 1);
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_plans4laterV1", 1);
	Addto(lGenericQuestion,						"BFemaleDialog.bf_call_whatmonthV1", 1);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"BFemaleDialog.bf_disinterest_boringmeV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_disinterest_whocaresV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_question_idontcareV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_blahblahV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_explosivecarsV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_fademesomebankV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_goodquestionV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_howthehellV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_inrehabV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_isthisaquizV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_looklikegoogleV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_looklikegoogleV2", 2);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_needafatbluntV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_uglygrillV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_youkeeptalkingV1", 1);
	Addto(lGenericAnswer,						"BFemaleDialog.bf_response_youkeeptalkingV2", 2);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"BFemaleDialog.bf_followup_areyouoncrazyV1", 1);
	Addto(lGenericFollowup,						"BFemaleDialog.bf_followup_areyouseriousV1", 1);
	Addto(lGenericFollowup,						"BFemaleDialog.bf_followup_completelywackV1", 1);
	Addto(lGenericFollowup,						"BFemaleDialog.bf_followup_donttalksmackV1", 1);
	Addto(lGenericFollowup,						"BFemaleDialog.bf_followup_notpayingattentionV1", 1);
	Addto(lGenericFollowup,						"BFemaleDialog.bf_followup_saywhatV1", 1);
	Addto(lGenericFollowup,						"BFemaleDialog.bf_followup_stopthatshitV1", 1);
	Addto(lGenericFollowup,						"BFemaleDialog.bf_followup_stopthatshitV2", 2);

	Clear(lGenericGoodbye);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_checkyoulaterV1", 1);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_confusednowV1", 1);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_confusednowV2", 2);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_confusednowV3", 3);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_donehereV1", 1);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_greatseeingyouV1", 1);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_imhistoricalV1", 1);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_seeyoulaterV1", 1);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_stupidestV1", 1);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_youreascrazyV1", 1);
	Addto(lGenericGoodbye,						"BFemaleDialog.bf_leadout_youreascrazyV2", 2);

	//Clear(linvadeshome);	
	//Addto(linvadeshome,							"", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,						"BFemaleDialog.bf_seefire_assedoutV1", 1);
	Addto(lsomeoneonfire,						"BFemaleDialog.bf_seefire_firex2V1", 1);
	Addto(lsomeoneonfire,						"BFemaleDialog.bf_seefire_holyshitV1", 1);
	Addto(lsomeoneonfire,						"BFemaleDialog.bf_seefire_smellsgoodV1", 1);
	Addto(lsomeoneonfire,						"BFemaleDialog.bf_seeonfire_hesonfireV1", 1);
	Addto(lsomeoneonfire,						"BFemaleDialog.bf_seeonfire_stopdropandrollV1", 1);
	Addto(lsomeoneonfire,						"BFemaleDialog.bf_seeonfire_theyreallburningV1", 1);
	Addto(lsomeoneonfire,						"BFemaleDialog.bf_seeonfire_youreonfireV1", 1);

	Clear(labouttopuke);
	Addto(labouttopuke,							"BFemaleDialog.bf_puke_idontfeelsogoodV1", 1);
	Addto(labouttopuke,							"BFemaleDialog.bf_puke_ohmanimgonnabesickV1", 1);

	//Clear(lbodyfunctions);
	//Addto(lbodyfunctions,						"", 1);

	//Clear(lGettingShocked);
	//Addto(lGettingShocked,						"", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,							"HabibDialog.habib_ailili", 1);

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_chickenandwafflesV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_chickenandwafflesV2", 2);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_chickenandwafflesV3", 3);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_howlongV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_needextendedfoodV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_needextendedfoodV2", 2);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_needextendedfoodV3", 3);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_placetobuyendoV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_plans4laterV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_call_whatmonthV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_airfreshenerV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_amazingV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_boxochoculaV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_boxochoculaV2", 2);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_boxochoculaV3", 3);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_checkthenewflavasV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_checkthenewflavasV2", 2);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_comeoutgreenV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_crazywhiteguyV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_hardcoreV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_hoochiesweaveV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_howmagnetsworkV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_littledizzyV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_nowayhappyV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_okayV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_queenofbrowntownV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_thinkingthesameV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_uhhuhV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_uhhuhV2", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_whatdidyouthinkV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_whatithoughtV1", 1);
	Addto(lCellPhoneTalk,						"BFemaleDialog.bf_cell_wouldnybelieveV1", 1);
	
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
	Addto(ldudedead,							"BFemaleDialog.bf_deadtaunt_assfaceV1", 1);
	Addto(ldudedead,							"BFemaleDialog.bf_deadtaunt_blametmzV1", 1);
	Addto(ldudedead,							"BFemaleDialog.bf_deadtaunt_chalkoutlineclubV1", 1);
	Addto(ldudedead,							"BFemaleDialog.bf_deadtaunt_republicanV1", 1);
	Addto(ldudedead,							"BFemaleDialog.bf_deadtaunt_seriousassholeV1", 1);
	Addto(ldudedead,							"BFemaleDialog.bf_deadtaunt_trynottogetshotV1", 1);
	Addto(ldudedead,							"BFemaleDialog.bf_deadtaunt_withyourfaceV1", 1);
	Addto(ldudedead,							"BFemaleDialog.bf_deadtaunt_withyourfaceV2", 2);

	Clear(lKickDead);
	Addto(lKickDead,							"BFemaleDialog.bf_deadtaunt_heresapresentV1", 1);
	Addto(lKickDead,							"BFemaleDialog.bf_deadtaunt_onefortheroadV1", 1);
	Addto(lKickDead,							"BFemaleDialog.bf_deadtaunt_takethatassholeV1", 1);

	//Clear(lNameCalling);
	//Addto(lNameCalling,							"", 1);

	Clear(lRogueCop);
	Addto(lRogueCop,							"BFemaleDialog.bf_seecarnage_wherescameraV1", 1);
	Addto(lRogueCop,							"BFemaleDialog.bf_seescop_abuseV1", 1);
	Addto(lRogueCop,							"BFemaleDialog.bf_seescop_bumrushV1", 1);
	Addto(lRogueCop,							"BFemaleDialog.bf_seescop_getfiredV1", 1);
	Addto(lRogueCop,							"BFemaleDialog.bf_seescop_milkcartonV1", 1);
	Addto(lRogueCop,							"BFemaleDialog.bf_seescop_pensionW1", 1);
	Addto(lRogueCop,							"BFemaleDialog.bf_seescop_thepowerV1", 1);
	Addto(lRogueCop,							"BFemaleDialog.bf_seescop_typicalV1", 1);

	Clear(lgetbumped);
	Addto(lgetbumped,							"BFemaleDialog.bf_bumped_betterstepV1", 1);
	Addto(lgetbumped,							"BFemaleDialog.bf_bumped_cominthroughV1", 1);
	Addto(lgetbumped,							"BFemaleDialog.bf_bumped_heywatchitV1", 1);
	Addto(lgetbumped,							"BFemaleDialog.bf_bumped_onesideV1", 1);
	Addto(lgetbumped,							"BFemaleDialog.bf_bumped_oofmoronV1", 1);
	Addto(lgetbumped,							"BFemaleDialog.bf_bumped_oofmoronV2", 1);

	Clear(lGetMad);
	Addto(lGetMad,								"BFemaleDialog.bf_bully_yougottaissueV1", 1);
	Addto(lGetMad,								"BFemaleDialog.bf_bully_youwantdramaV1", 1);
	Addto(lGetMad,								"BFemaleDialog.bf_bumped_heywatchitV1", 1);
	Addto(lGetMad,								"BFemaleDialog.bf_bumped_onesideV1", 1);
	Addto(lGetMad,								"BFemaleDialog.bf_bumped_oofmoronV1", 1);
	Addto(lGetMad,								"BFemaleDialog.bf_bumped_oofmoronV2", 1);

	Clear(lLynchMob);
	Addto(lLynchMob,							"BFemaleDialog.bf_lynch_gethimV1", 1);
	Addto(lLynchMob,							"BFemaleDialog.bf_lynch_heyyouV1", 1);
	Addto(lLynchMob,							"BFemaleDialog.bf_lynch_idontlikethelookV1", 1);
	Addto(lLynchMob,							"BFemaleDialog.bf_lynch_somethingwrongV1", 1);
	Addto(lLynchMob,							"BFemaleDialog.bf_lynch_thatstheoneV1", 1);
	Addto(lLynchMob,							"BFemaleDialog.bf_lynch_thereheisV1", 1);
	Addto(lLynchMob,							"BFemaleDialog.bf_lynch_theresthekillerV1", 1);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"BFemaleDialog.bf_lynch_gethimV1", 1);
	Addto(lSeesEnemy,							"BFemaleDialog.bf_lynch_heyyouV1", 1);
	Addto(lSeesEnemy,							"BFemaleDialog.bf_lynch_thereheisV1", 1);
	Addto(lSeesEnemy,							"BFemaleDialog.bf_tough_howaboutsomeofthisV1", 1);
	Addto(lSeesEnemy,							"BFemaleDialog.bf_tough_rahV1", 1);
	Addto(lSeesEnemy,							"BFemaleDialog.bf_tough_rahV2", 2);

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
	Addto(lSignPetition,						"BFemaleDialog.bf_positive_aightV1", 1);
	Addto(lSignPetition,						"BFemaleDialog.bf_positive_icandothatv1", 1);
	Addto(lSignPetition,						"BFemaleDialog.bf_positive_imdownV1", 1);
	Addto(lSignPetition,						"BFemaleDialog.bf_positive_surewhynotV1", 1);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"BFemaleDialog.bf_negative_absolutelynotV1", 1);
	Addto(lDontSignPetition,					"BFemaleDialog.bf_negative_fuckthatV1", 1);
	Addto(lDontSignPetition,					"BFemaleDialog.bf_negative_fuckthatV2", 2);
	Addto(lDontSignPetition,					"BFemaleDialog.bf_negative_idontthinksoV1", 1);
	Addto(lDontSignPetition,					"BFemaleDialog.bf_negative_idontthinksoV2", 2);
	Addto(lDontSignPetition,					"BFemaleDialog.bf_negative_nothanksV1", 1);
	Addto(lDontSignPetition,					"BFemaleDialog.bf_negative_notinterestedV1", 1);
	Addto(lDontSignPetition,					"BFemaleDialog.bf_negative_sorryV1", 1);

	Clear(lPetitionBother);
	Addto(lPetitionBother,						"BFemaleDialog.bf_negative_goawayV1", 1);
	
	Clear(lChampPhotoReaction);
	Addto(lChampPhotoReaction,					"BFemaleDialog.bf_ghaspV2", 1);
	Addto(lChampPhotoReaction,					"BFemaleDialog.bf_ghasp", 2);
	Addto(lChampPhotoReaction,					"BFemaleDialog.bf_seecarnage_heskillingV1", 1);
	Addto(lChampPhotoReaction,					"BFemaleDialog.bf_seecarnage_ohmygodV1", 1);
	Addto(lChampPhotoReaction,					"BFemaleDialog.bf_seecarnage_sweetlordnoV1", 1);

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
