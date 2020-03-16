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
class DialogGay extends DialogMaleAlt;

// This is mostly an easter egg dialog class so it's okay to inherit from the
// different-sounding Male Alt dialog

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();
	
	Clear(lapplauding);
	AddTo(lApplauding,							"GMaleDialog.gay_cheer_fabulousv1", 1);
	AddTo(lApplauding,							"GMaleDialog.gay_cheer_gobabyv1", 1);
	AddTo(lApplauding,							"GMaleDialog.gay_cheer_woohoov1", 1);
	AddTo(lApplauding,							"GMaleDialog.gay_cheer_wootv1", 1);
	AddTo(lApplauding,							"GMaleDialog.gay_cheer_wootv2", 2);
	AddTo(lApplauding,							"GMaleDialog.gay_cheer_yeahv1", 1);
	AddTo(lApplauding,							"GMaleDialog.gay_cheer_yeahv2", 2);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"GMaleDialog.gay_damage_crapv1", 1);
	Addto(lCloseToWeapon,						"GMaleDialog.gay_damage_aiieev1", 1);
	Addto(lCloseToWeapon,						"GMaleDialog.gay_scream1", 1);
	Addto(lCloseToWeapon,						"GMaleDialog.gay_scream2", 1);
	Addto(lCloseToWeapon,						"GMaleDialog.gay_scream3", 1);
	Addto(lCloseToWeapon,						"GMaleDialog.gay_scream4", 1);
	Addto(lCloseToWeapon,						"GMaleDialog.gay_seecarnage_holyshitv1", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"GMaleDialog.gay_tough_bringitv1", 1);
	Addto(ldecidetofight,						"GMaleDialog.gay_tough_cantstopv1", 1);
	Addto(ldecidetofight,						"GMaleDialog.gay_tough_tryandstopmev1", 1);
	Addto(ldecidetofight,						"GMaleDialog.gay_postal_banzaiv1", 1);
	Addto(ldecidetofight,						"GMaleDialog.gay_postal_gayfuv1", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"GMaleDialog.gay_huhv1", 1);
	Addto(lWatchingCrazy,						"GMaleDialog.gay_pissedon_whuhv1", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"GMaleDialog.gay_huhv1", 1);
	Addto(lWatchingCrazy,						"GMaleDialog.gay_pissedon_whuhv1", 1);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,					"GMaleDialog.gay_getcop_helpv1", 1);
	Addto(lshootingoverthere,					"GMaleDialog.gay_getcop_policex2v1", 1);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,					"GMaleDialog.gay_getcop_helpv1", 1);
	Addto(lkillingoverthere,					"GMaleDialog.gay_getcop_policex2v1", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,							"GMaleDialog.gay_scream1", 1);
	Addto(lscreaming,							"GMaleDialog.gay_scream2", 1);
	Addto(lscreaming,							"GMaleDialog.gay_scream3", 1);
	Addto(lscreaming,							"GMaleDialog.gay_scream4", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"GMaleDialog.gay_onfire_fiyaav1", 1);
	Addto(lscreamingonfire,						"GMaleDialog.gay_onfire_imburningv1", 1);
	Addto(lscreamingonfire,						"GMaleDialog.gay_onfire_putmeoutv1", 1);
	Addto(lscreamingonfire,						"GMaleDialog.gay_onfire_roidsv1", 1);
	Addto(lscreamingonfire,						"GMaleDialog.gay_onfire_roidsv2", 2);
	Addto(lscreamingonfire,						"GMaleDialog.gay_onfire_theironyv1", 1);
	Addto(lscreamingonfire,						"GMaleDialog.gay_onfire_theironyv2", 2);
	Addto(lscreamingonfire,						"GMaleDialog.gay_onfire_yeaghv1", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"GMaleDialog.gay_tough_bringitv1", 1);
	Addto(lDoHeroics,							"GMaleDialog.gay_tough_cantstopv1", 1);
	Addto(lDoHeroics,							"GMaleDialog.gay_tough_howaboutsomeofthisv1", 1);
	Addto(lDoHeroics,							"GMaleDialog.gay_tough_rahv1", 1);
	Addto(lDoHeroics,							"GMaleDialog.gay_tough_rahv2", 2);
	Addto(lDoHeroics,							"GMaleDialog.gay_tough_tryandstopmev1", 1);
	Addto(lDoHeroics,							"GMaleDialog.gay_tough_youthinkimscaredv1", 1);
	Addto(lDoHeroics,							"GMaleDialog.gay_tough_youthinkthatcanv1", 1);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"GMaleDialog.gay_spitoutpissv1", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_asparagusv1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_asparagusv2", 2);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_assholev1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_christv1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_disgustingv1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_eughv1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_myblousev1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_neverexperiencedv1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_notmythingv1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_notthatfreakyv1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_pervov1", 1);
	Addto(laftergettingpissedon,				"GMaleDialog.gay_pissedon_likedthatv1", 1);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"GMaleDialog.gay_huhv1", 1);
	Addto(lwhatthe,								"GMaleDialog.gay_pissedon_heeyv1", 1);
	Addto(lwhatthe,								"GMaleDialog.gay_pissedon_heeyv2", 1);
	Addto(lwhatthe,								"GMaleDialog.gay_pissedon_whatthev1", 1);
	Addto(lwhatthe,								"GMaleDialog.gay_pissedon_whuhv1", 1);

	Clear(lseeingpisser);
	Addto(lseeingpisser,						"GMaleDialog.gay_seespissing_1v1", 1);
	Addto(lseeingpisser,						"GMaleDialog.gay_seespissing_2v1", 1);
	Addto(lseeingpisser,						"GMaleDialog.gay_seespissing_3v1", 1);
	Addto(lseeingpisser,						"GMaleDialog.gay_seespissing_4v1", 1);
	Addto(lseeingpisser,						"GMaleDialog.gay_seespissing_5v1", 1);
	Addto(lseeingpisser,						"GMaleDialog.gay_seespissing_6v1", 1);
	Addto(lseeingpisser,						"GMaleDialog.gay_seespissing_7v1", 1);
	Addto(lseeingpisser,						"GMaleDialog.gay_seespissing_8v1", 1);
	Addto(lseeingpisser,						"GMaleDialog.gay_seespissing_8v2", 2);

	Clear(lgothit);
	Addto(lgothit,								"GMaleDialog.gay_damage_aghkv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_aiieev1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_akv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_aughv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_badtouchv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_crapv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_eekv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_fuckinghurtv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_myspleenv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_nov1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_owbitchv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_owv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_owv2", 2);
	Addto(lgothit,								"GMaleDialog.gay_damage_painv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_shatnerv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_stopitv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_thathurtv1", 1);
	Addto(lgothit,								"GMaleDialog.gay_damage_youbitchv1", 1);

	Clear(lAttacked);
	Addto(lAttacked,							"GMaleDialog.gay_damage_aghkv1", 1);
	Addto(lAttacked,							"GMaleDialog.gay_damage_akv1", 1);
	Addto(lAttacked,							"GMaleDialog.gay_damage_aughv1", 1);
	Addto(lAttacked,							"GMaleDialog.gay_damage_owv1", 1);
	Addto(lAttacked,							"GMaleDialog.gay_damage_owv2", 2);

	Clear(lGrunt);
	Addto(lGrunt,								"GMaleDialog.gay_damage_aghkv1", 1);
	Addto(lGrunt,								"GMaleDialog.gay_damage_akv1", 1);
	Addto(lGrunt,								"GMaleDialog.gay_damage_aughv1", 1);
	Addto(lGrunt,								"GMaleDialog.gay_damage_owv1", 1);
	Addto(lGrunt,								"GMaleDialog.gay_damage_owv2", 2);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,				"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lbegforlife);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_crying1", 1);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_crying2", 1);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_crying3", 2);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_crying4", 2);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_cryingV1", 3);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_dontkillvirginv1", 1);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_nephewsv1", 1);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_pleasedontkillmev1", 1);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_snivel1", 1);
	Addto(lbegforlife,							"GMaleDialog.gay_beg_snivel2", 2);
	Addto(lbegforlife,							"GMaleDialog.gay_fearful_donthurtv1", 1);
	Addto(lbegforlife,							"GMaleDialog.gay_fearful_donthurtv2", 2);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_crying1", 1);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_crying2", 1);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_crying3", 2);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_crying4", 2);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_cryingV1", 3);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_dontkillvirginv1", 1);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_nephewsv1", 1);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_pleasedontkillmev1", 1);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_snivel1", 1);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_snivel2", 2);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_beg_dontkillminorityv1", 1);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_fearful_donthurtv1", 1);
	Addto(lbegforlifeMin,						"GMaleDialog.gay_fearful_donthurtv2", 2);
	
	Clear(lCrying);
	Addto(lCrying,								"GMaleDialog.gay_beg_crying1", 1);
	Addto(lCrying,								"GMaleDialog.gay_beg_crying2", 1);
	Addto(lCrying,								"GMaleDialog.gay_beg_crying3", 1);
	Addto(lCrying,								"GMaleDialog.gay_beg_crying4", 1);
	Addto(lCrying,								"GMaleDialog.gay_beg_cryingV1", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,					"GMaleDialog.gay_beg_didntmeanitv1", 1);	
	Addto(lfrightenedapology,					"GMaleDialog.gay_beg_neverdothatagainv1", 1);	

	Clear(lcleanshot);
	Addto(lcleanshot,							"GMaleDialog.gay_shotblocked1v1", 1);
	Addto(lcleanshot,							"GMaleDialog.gay_shotblocked3v1", 1);
	Addto(lcleanshot,							"GMaleDialog.gay_shotblocked4v1", 1);
	Addto(lcleanshot,							"GMaleDialog.gay_shotblocked5v1", 1);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"GMaleDialog.gay_shotblocked3v1", 1);
	Addto(lCleanMeleeHit,						"GMaleDialog.gay_shotblocked4v1", 1);

	Clear(lInhale);
	Addto(lInhale,								"WMaleDialog.wm_inhale", 1);
												
	Clear(lExhale);								
	Addto(lExhale,								"WMaleDialog.wm_exhale", 1);
	
	Clear(lnoticedickout);
	Addto(lnoticedickout,						"GMaleDialog.gay_seewang_heybuddyyourbarnv1", 1);
	Addto(lnoticedickout,						"GMaleDialog.gay_seewang_somedignityv1", 1);
	Addto(lnoticedickout,						"GMaleDialog.gay_seewang_tinytimv1", 1);
	Addto(lnoticedickout,						"GMaleDialog.gay_seewang_xyzv1", 1);

	Clear(lGoPostal);
	Addto(lGoPostal,							"GMaleDialog.gay_postal_bitcheslooksatmev1", 1);
	Addto(lGoPostal,							"GMaleDialog.gay_postal_bulletsv1", 1);
	Addto(lGoPostal,							"GMaleDialog.gay_postal_dorothysaysdiev1", 1);
	Addto(lGoPostal,							"GMaleDialog.gay_postal_stayawayfrommev1", 1);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_fearful_getoutv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_fearful_getoutv2", 2);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_fearful_isnthappeningv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_fearful_isnthappeningv2", 2);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_ghaspv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_ambulancev1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_aniceguyv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_callthenavyv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_cantbelievehappeningv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_cantbelievehedidthatv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_forchristsakev1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_helpv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_holyshitv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_howcanthisbev1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_imgoingtobesickv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_itshorriblev1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_killingeveryonev1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_needcouncellingv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_nightmnarev1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_ohmygodv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_pleasemakeitstopv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_runrunv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_thehorrorv1", 1);
	Addto(lcarnageoccurred,						"GMaleDialog.gay_seecarnage_thiscantberealv1", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"GMaleDialog.gay_ghaspv1", 1);
	Addto(lGettingMugged,						"GMaleDialog.gay_fearful_donthurtv1", 1);
	Addto(lGettingMugged,						"GMaleDialog.gay_fearful_donthurtv2", 2);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"GMaleDialog.gay_getcop_callacopv1", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,						"GMaleDialog.gay_seeonfire_everyonesonfirev1", 1);
	Addto(lsomeoneonfire,						"GMaleDialog.gay_seeonfire_stopdropandrollv1", 1);
	Addto(lsomeoneonfire,						"GMaleDialog.gay_seeonfire_youreflamingv1", 1);

	Clear(labouttopuke);
	Addto(labouttopuke,							"GMaleDialog.gay_puke_idontfeelsogoodv1", 1);
	Addto(labouttopuke,							"GMaleDialog.gay_puke_ohgodimv1", 1);
	Addto(labouttopuke,							"GMaleDialog.gay_puke_ohmanimgonnabuickv1", 1);

	Clear(ldudedead);
	Addto(ldudedead,							"GMaleDialog.gay_deadtaunt_assholev1", 1);
	Addto(ldudedead,							"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(ldudedead,							"GMaleDialog.gay_deadtaunt_loserv1", 1);
	Addto(ldudedead,							"GMaleDialog.gay_deadtaunt_suckstobeyouv1", 1);
	Addto(ldudedead,							"GMaleDialog.gay_deadtaunt_usecoverv1", 1);

	Clear(lKickDead);
	Addto(lKickDead,							"GMaleDialog.gay_deadtaunt_hereyouforgotonev1", 1);
	Addto(lKickDead,							"GMaleDialog.gay_deadtaunt_stupidhairv1", 1);

	Clear(lGetMad);
	Addto(lGetMad,								"GMaleDialog.gay_damage_owv1", 1);
	Addto(lGetMad,								"GMaleDialog.gay_damage_owv2", 2);
	Addto(lGetMad,								"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(lGetMad,								"GMaleDialog.gay_postal_stayawayfrommev1", 1);

	Clear(lLynchMob);
	Addto(lLynchMob,							"GMaleDialog.gay_tough_howaboutsomeofthisv1", 1);
	Addto(lLynchMob,							"GMaleDialog.gay_tough_rahv1", 1);
	Addto(lLynchMob,							"GMaleDialog.gay_tough_rahv2", 2);
	
	Clear(lgreeting);
	Addto(lgreeting,							"GMaleDialog.gay_sleez_hellov1", 1);
	Addto(lgreeting,							"GMaleDialog.gay_sleez_heyv1", 1);
	Addto(lGreeting,							"GMaleDialog.gay_sleez_hiv1", 1);

	Clear(lhotgreeting);
	Addto(lhotGreeting,							"GMaleDialog.gay_sleez_hellov1", 1);
	Addto(lhotGreeting,							"GMaleDialog.gay_sleez_heyv1", 1);
	Addto(lhotGreeting,							"GMaleDialog.gay_sleez_hiv1", 1);;
	
	Clear(lgreetingquestions);
	Addto(lGreetingquestions,							"GMaleDialog.gay_sleez_howareyouv1", 1);
	Addto(lGreetingquestions,							"GMaleDialog.gay_sleez_howsitgoingv1", 1);
	Addto(lGreetingquestions,							"GMaleDialog.gay_sleez_howyoudoinv1", 1);
	Addto(lGreetingquestions,							"GMaleDialog.gay_sleez_supv1", 1);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,							"GMaleDialog.gay_sleez_howareyouv1", 1);
	Addto(lHotGreetingquestions,							"GMaleDialog.gay_sleez_howsitgoingv1", 1);
	Addto(lHotGreetingquestions,							"GMaleDialog.gay_sleez_howyoudoinv1", 1);
	Addto(lHotGreetingquestions,							"GMaleDialog.gay_sleez_supv1", 1);
	
	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,							"GMaleDialog.gay_deadtaunt_assholev1", 1);
	Addto(lrespondtohotgreeting,							"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(lrespondtohotgreeting,							"GMaleDialog.gay_deadtaunt_loserv1", 1);
	
	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeskrotchy_2v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeskrotchy_6v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeskrotchy_7v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeskrotchy_8v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeskrotchy_9v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seespissing_1v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seespissing_2v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seespissing_3v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seespissing_4v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seespissing_5v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seespissing_6v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seespissing_7v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seespissing_8v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_1v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_2v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_3v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_4v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_5v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_6v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_7v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seesrhino_8v1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_seeonfire_youreflamingv1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_pissedon_asparagusv1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_pissedon_asparagusv2", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_indicate_stupidshitv1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_indicate_kiddingmev1", 1);
	Addto(lrespondtogreeting,						"GMaleDialog.gay_indicate_cantbelieveitv1", 1);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeskrotchy_2v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeskrotchy_6v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeskrotchy_7v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeskrotchy_8v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeskrotchy_9v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seespissing_1v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seespissing_2v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seespissing_3v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seespissing_4v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seespissing_5v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seespissing_6v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seespissing_7v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seespissing_8v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_1v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_2v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_3v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_4v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_5v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_6v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_7v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seesrhino_8v1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_seeonfire_youreflamingv1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_pissedon_asparagusv1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_pissedon_asparagusv2", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_indicate_stupidshitv1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_indicate_kiddingmev1", 1);
	Addto(lrespondtogreetingresponse,						"GMaleDialog.gay_indicate_cantbelieveitv1", 1);
	
	Clear(lHelloCop);
	Addto(lHelloCop,							"GMaleDialog.gay_sleez_hellov1", 1);
	Addto(lHelloCop,							"GMaleDialog.gay_sleez_heyv1", 1);
	Addto(lHelloCop,							"GMaleDialog.gay_sleez_hiv1", 1);

	Clear(lHelloGimp);
	Addto(lHelloGimp,						"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lHelloGimp,						"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lHelloGimp,						"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lHelloGimp,						"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lHelloGimp,						"GMaleDialog.gay_seeskrotchy_6v1", 1);
	
	Clear(lApologize);
	Addto(lApologize,							"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(lApologize,							"GMaleDialog.gay_deadtaunt_loserv1", 1);

	Clear(lyourewelcome);
	Addto(lyourewelcome,								"GMaleDialog.gay_cheer_fabulousv1", 1);
	Addto(lyourewelcome,								"GMaleDialog.gay_cheer_gobabyv1", 1);

	Clear(lno);
	Addto(lno,							"GMaleDialog.gay_deadtaunt_assholev1", 1);
	Addto(lno,							"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(lno,							"GMaleDialog.gay_deadtaunt_loserv1", 1);
	Addto(lno,							"GMaleDialog.gay_deadtaunt_suckstobeyouv1", 1);

	Clear(lyes);
	Addto(lyes,								"GMaleDialog.gay_cheer_fabulousv1", 1);
	Addto(lyes,								"GMaleDialog.gay_cheer_gobabyv1", 1);
	Addto(lyes,								"GMaleDialog.gay_cheer_woohoov1", 1);
	Addto(lyes,								"GMaleDialog.gay_cheer_wootv1", 1);
	Addto(lyes,								"GMaleDialog.gay_cheer_wootv2", 1);
	Addto(lyes,								"GMaleDialog.gay_cheer_yeahv1", 1);
	Addto(lyes,								"GMaleDialog.gay_cheer_yeahv2", 1);

	Clear(lthanks);
	Addto(lthanks,								"GMaleDialog.gay_cheer_fabulousv1", 1);
	Addto(lthanks,								"GMaleDialog.gay_cheer_gobabyv1", 1);
	Addto(lthanks,								"GMaleDialog.gay_cheer_woohoov1", 1);
	Addto(lthanks,								"GMaleDialog.gay_cheer_wootv1", 1);
	Addto(lthanks,								"GMaleDialog.gay_cheer_wootv2", 1);
	Addto(lthanks,								"GMaleDialog.gay_cheer_yeahv1", 1);
	Addto(lthanks,								"GMaleDialog.gay_cheer_yeahv2", 1);

	Clear(lThatsGreat);
	Addto(lThatsGreat,								"GMaleDialog.gay_cheer_fabulousv1", 1);
	Addto(lThatsGreat,								"GMaleDialog.gay_cheer_gobabyv1", 1);
	Addto(lThatsGreat,								"GMaleDialog.gay_cheer_woohoov1", 1);
	Addto(lThatsGreat,								"GMaleDialog.gay_cheer_wootv1", 1);
	Addto(lThatsGreat,								"GMaleDialog.gay_cheer_wootv2", 1);
	Addto(lThatsGreat,								"GMaleDialog.gay_cheer_yeahv1", 1);
	Addto(lThatsGreat,								"GMaleDialog.gay_cheer_yeahv2", 1);
	
	Clear(lGetDown);
	Addto(lGetDown,							"GMaleDialog.gay_shotblocked1v1", 1);
	Addto(lGetDown,							"GMaleDialog.gay_shotblocked2v1", 1);
	Addto(lGetDown,							"GMaleDialog.gay_shotblocked3v1", 1);
	Addto(lGetDown,							"GMaleDialog.gay_shotblocked4v1", 1);
	Addto(lGetDown,							"GMaleDialog.gay_shotblocked5v1", 1);

	Clear(lGetDownMP);
	Addto(lGetDownMP,							"GMaleDialog.gay_shotblocked1v1", 1);
	Addto(lGetDownMP,							"GMaleDialog.gay_shotblocked2v1", 1);
	Addto(lGetDownMP,							"GMaleDialog.gay_shotblocked3v1", 1);
	Addto(lGetDownMP,							"GMaleDialog.gay_shotblocked4v1", 1);
	Addto(lGetDownMP,							"GMaleDialog.gay_shotblocked5v1", 1);
	
	Clear(lCussing);
	Addto(lCussing,								"GMaleDialog.gay_pissedon_assholev1", 1);
	Addto(lCussing,								"GMaleDialog.gay_pissedon_christv1", 1);
	Addto(lCussing,								"GMaleDialog.gay_damage_crapv1", 1);
	Addto(lCussing,								"GMaleDialog.gay_seecarnage_holyshitv1", 1);

	Clear(lgetdownscared);
	Addto(lgetdownscared,							"GMaleDialog.gay_shotblocked1v1", 1);
	Addto(lgetdownscared,							"GMaleDialog.gay_shotblocked2v1", 1);
	Addto(lgetdownscared,							"GMaleDialog.gay_shotblocked3v1", 1);
	Addto(lgetdownscared,							"GMaleDialog.gay_shotblocked4v1", 1);
	Addto(lgetdownscared,							"GMaleDialog.gay_shotblocked5v1", 1);
	
	Clear(ldefiant);
	Addto(ldefiant,								"GMaleDialog.gay_tough_youthinkimscaredv1", 1);
	Addto(ldefiant,								"GMaleDialog.gay_tough_rahv1", 1);
	Addto(ldefiant,								"GMaleDialog.gay_tough_rahv2", 1);
	Addto(ldefiant,								"GMaleDialog.gay_postal_gayfuv1", 1);
	Addto(ldefiant,								"GMaleDialog.gay_pissedon_assholev1", 1);

	Clear(ldefiantline);
	Addto(ldefiantline,								"GMaleDialog.gay_tough_youthinkimscaredv1", 1);
	Addto(ldefiantline,								"GMaleDialog.gay_tough_rahv1", 1);
	Addto(ldefiantline,								"GMaleDialog.gay_tough_rahv2", 1);
	Addto(ldefiantline,								"GMaleDialog.gay_postal_gayfuv1", 1);
	Addto(ldefiantline,								"GMaleDialog.gay_postal_whatsthatv1", 1);
	Addto(ldefiantline,								"GMaleDialog.gay_pissedon_assholev1", 1);
	
	Clear(llaughing);
	Addto(llaughing,							"GMaleDialog.gay_laughv1", 1);
	
	Clear(lSnickering);
	Addto(lSnickering,							"GMaleDialog.gay_snickerv1", 1);
	Addto(lSnickering,							"GMaleDialog.gay_snickerv2", 1);

	Clear(lSomethingIsGross);
	Addto(lSomethingIsGross,					"GMaleDialog.gay_pissedon_disgustingv1", 1);
	Addto(lSomethingIsGross,					"GMaleDialog.gay_pissedon_eughv1", 1);
	
	Clear(ldying);
	Addto(ldying,								"GMaleDialog.gay_puke_idontfeelsogoodv1", 1);
	Addto(ldying,								"GMaleDialog.gay_puke_ohgodimv1", 1);
	Addto(ldying,								"GMaleDialog.gay_puke_ohmanimgonnabuickv1", 1);
	Addto(ldying,								"GMaleDialog.gay_damage_owbitchv1", 1);
	Addto(ldying,								"GMaleDialog.gay_damage_myspleenv1", 1);
	Addto(ldying,								"GMaleDialog.gay_damage_youbitchv1", 1);
	Addto(ldying,								"GMaleDialog.gay_damage_painv1", 1);
	Addto(ldying,								"GMaleDialog.gay_damage_shatnerv1", 1);
	
	Clear(ltrashtalk);
	Addto(ltrashtalk,							"GMaleDialog.gay_taunt_compensatev1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_taunt_ohyeahbigmanv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_taunt_yourenotsotoughv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_postal_dorothysaysdiev1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_tough_bringitv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_tough_cantstopv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_tough_tryandstopmev1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_postal_banzaiv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_postal_gayfuv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_tough_howaboutsomeofthisv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_tough_rahv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_tough_rahv2", 2);
	Addto(ltrashtalk,							"GMaleDialog.gay_tough_youthinkimscaredv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_tough_youthinkthatcanv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_postal_sweetdreamsv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_postal_daddyneverlovedmev1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_postal_didnotseethisv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_postal_teethv1", 1);
	Addto(ltrashtalk,							"GMaleDialog.gay_postal_ohyesididv1", 1);
	
	Clear(lWhileFighting);
	Addto(lWhileFighting,							"GMaleDialog.gay_taunt_compensatev1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_taunt_ohyeahbigmanv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_taunt_yourenotsotoughv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_postal_dorothysaysdiev1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_tough_bringitv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_tough_cantstopv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_tough_tryandstopmev1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_postal_banzaiv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_postal_gayfuv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_tough_howaboutsomeofthisv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_tough_rahv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_tough_rahv2", 2);
	Addto(lWhileFighting,							"GMaleDialog.gay_tough_youthinkimscaredv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_tough_youthinkthatcanv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_postal_sweetdreamsv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_postal_daddyneverlovedmev1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_postal_didnotseethisv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_postal_teethv1", 1);
	Addto(lWhileFighting,							"GMaleDialog.gay_postal_ohyesididv1", 1);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,							"GMaleDialog.gay_sleez_howareyouv1", 1);
	Addto(laskcopwhatsup,							"GMaleDialog.gay_sleez_howsitgoingv1", 1);
	Addto(laskcopwhatsup,							"GMaleDialog.gay_sleez_howyoudoinv1", 1);
	Addto(laskcopwhatsup,							"GMaleDialog.gay_sleez_supv1", 1);
	
	Clear(lratout);
	Addto(lratout,							"GMaleDialog.gay_deadtaunt_assholev1", 1);
	Addto(lratout,							"GMaleDialog.gay_deadtaunt_loserv1", 1);
	Addto(lratout,							"GMaleDialog.gay_deadtaunt_suckstobeyouv1", 1);

	Clear(lfakeratout);
	Addto(lfakeratout,							"GMaleDialog.gay_deadtaunt_assholev1", 1);
	Addto(lfakeratout,							"GMaleDialog.gay_deadtaunt_loserv1", 1);
	Addto(lfakeratout,							"GMaleDialog.gay_deadtaunt_suckstobeyouv1", 1);
	
	Clear(lQuestion);	
	Addto(lQuestion,						"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seeskrotchy_2v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seeskrotchy_6v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seeskrotchy_7v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seeskrotchy_8v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seeskrotchy_9v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seespissing_1v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seespissing_2v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seespissing_3v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seespissing_4v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seespissing_5v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seespissing_6v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seespissing_7v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seespissing_8v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_1v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_2v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_3v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_4v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_5v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_6v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_7v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seesrhino_8v1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_seeonfire_youreflamingv1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_pissedon_asparagusv1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_pissedon_asparagusv2", 1);
	Addto(lQuestion,						"GMaleDialog.gay_indicate_stupidshitv1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_indicate_kiddingmev1", 1);
	Addto(lQuestion,						"GMaleDialog.gay_indicate_cantbelieveitv1", 1);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeskrotchy_2v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeskrotchy_6v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeskrotchy_7v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeskrotchy_8v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeskrotchy_9v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seespissing_1v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seespissing_2v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seespissing_3v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seespissing_4v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seespissing_5v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seespissing_6v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seespissing_7v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seespissing_8v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_1v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_2v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_3v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_4v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_5v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_6v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_7v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seesrhino_8v1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_seeonfire_youreflamingv1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_pissedon_asparagusv1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_pissedon_asparagusv2", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_indicate_stupidshitv1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_indicate_kiddingmev1", 1);
	Addto(lGenericQuestion,						"GMaleDialog.gay_indicate_cantbelieveitv1", 1);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeskrotchy_2v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeskrotchy_6v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeskrotchy_7v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeskrotchy_8v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeskrotchy_9v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seespissing_1v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seespissing_2v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seespissing_3v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seespissing_4v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seespissing_5v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seespissing_6v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seespissing_7v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seespissing_8v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_1v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_2v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_3v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_4v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_5v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_6v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_7v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seesrhino_8v1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_seeonfire_youreflamingv1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_pissedon_asparagusv1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_pissedon_asparagusv2", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_indicate_stupidshitv1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_indicate_kiddingmev1", 1);
	Addto(lGenericAnswer,						"GMaleDialog.gay_indicate_cantbelieveitv1", 1);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeskrotchy_2v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeskrotchy_6v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeskrotchy_7v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeskrotchy_8v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeskrotchy_9v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seespissing_1v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seespissing_2v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seespissing_3v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seespissing_4v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seespissing_5v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seespissing_6v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seespissing_7v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seespissing_8v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_1v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_2v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_3v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_4v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_5v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_6v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_7v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seesrhino_8v1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_seeonfire_youreflamingv1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_pissedon_asparagusv1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_pissedon_asparagusv2", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_indicate_stupidshitv1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_indicate_kiddingmev1", 1);
	Addto(lGenericFollowup,						"GMaleDialog.gay_indicate_cantbelieveitv1", 1);
	
	Clear(linvadeshome);	
	Addto(linvadeshome,							"GMaleDialog.gay_taunt_yourenotsotoughv1", 1);
	Addto(linvadeshome,							"GMaleDialog.gay_tough_bringitv1", 1);
	Addto(linvadeshome,							"GMaleDialog.gay_postal_banzaiv1", 1);
	Addto(linvadeshome,							"GMaleDialog.gay_postal_gayfuv1", 1);
	Addto(linvadeshome,							"GMaleDialog.gay_tough_youthinkimscaredv1", 1);
	Addto(linvadeshome,							"GMaleDialog.gay_tough_youthinkthatcanv1", 1);
	
	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeskrotchy_2v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeskrotchy_6v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeskrotchy_7v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeskrotchy_8v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeskrotchy_9v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seespissing_1v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seespissing_2v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seespissing_3v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seespissing_4v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seespissing_5v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seespissing_6v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seespissing_7v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seespissing_8v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_1v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_2v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_3v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_3v2", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_4v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_5v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_6v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_7v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seesrhino_8v1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_seeonfire_youreflamingv1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_pissedon_asparagusv1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_pissedon_asparagusv2", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_indicate_stupidshitv1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_indicate_kiddingmev1", 1);
	Addto(lCellPhoneTalk,						"GMaleDialog.gay_indicate_cantbelieveitv1", 1);
	
	Clear(lRogueCop);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_ambulancev1", 1);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_aniceguyv1", 1);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_callthenavyv1", 1);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_cantbelievehappeningv1", 1);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_cantbelievehedidthatv1", 1);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_forchristsakev1", 1);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_helpv1", 1);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_holyshitv1", 1);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_killingeveryonev1", 1);
	Addto(lRogueCop,						"GMaleDialog.gay_seecarnage_ohmygodv1", 1);
	
	Clear(lgetbumped);
	Addto(lgetbumped,							"GMaleDialog.gay_damage_owv1", 1);
	Addto(lgetbumped,							"GMaleDialog.gay_damage_owv2", 2);
	Addto(lgetbumped,							"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(lgetbumped,							"GMaleDialog.gay_pissedon_heeyv2", 1);
	
	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"GMaleDialog.gay_taunt_compensatev1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_taunt_ohyeahbigmanv1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_taunt_yourenotsotoughv1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_postal_dorothysaysdiev1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_tough_bringitv1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_tough_cantstopv1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_tough_tryandstopmev1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_postal_banzaiv1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_postal_gayfuv1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_tough_howaboutsomeofthisv1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_tough_rahv1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_tough_rahv2", 2);
	Addto(lSeesEnemy,							"GMaleDialog.gay_tough_youthinkimscaredv1", 1);
	Addto(lSeesEnemy,							"GMaleDialog.gay_tough_youthinkthatcanv1", 1);
	
	Clear(lSignPetition);							
	Addto(lSignPetition,								"GMaleDialog.gay_cheer_fabulousv1", 1);
	Addto(lSignPetition,								"GMaleDialog.gay_cheer_gobabyv1", 1);
	Addto(lSignPetition,								"GMaleDialog.gay_cheer_woohoov1", 1);
	Addto(lSignPetition,								"GMaleDialog.gay_cheer_wootv1", 1);
	Addto(lSignPetition,								"GMaleDialog.gay_cheer_wootv2", 1);
	Addto(lSignPetition,								"GMaleDialog.gay_cheer_yeahv1", 1);
	Addto(lSignPetition,								"GMaleDialog.gay_cheer_yeahv2", 1);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,							"GMaleDialog.gay_deadtaunt_assholev1", 1);
	Addto(lDontSignPetition,							"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(lDontSignPetition,							"GMaleDialog.gay_deadtaunt_loserv1", 1);
	Addto(lDontSignPetition,							"GMaleDialog.gay_deadtaunt_suckstobeyouv1", 1);

	Clear(lPetitionBother);
	Addto(lPetitionBother,							"GMaleDialog.gay_deadtaunt_suckstobeyouv1", 1);
	
	Clear(lKrotchyCustomerComment);
	Addto(lKrotchyCustomerComment,					"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lKrotchyCustomerComment,					"GMaleDialog.gay_seeskrotchy_2v1", 1);
	Addto(lKrotchyCustomerComment,					"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lKrotchyCustomerComment,					"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lKrotchyCustomerComment,					"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lKrotchyCustomerComment,					"GMaleDialog.gay_seeskrotchy_6v1", 1);
	Addto(lKrotchyCustomerComment,					"GMaleDialog.gay_seeskrotchy_7v1", 1);
	Addto(lKrotchyCustomerComment,					"GMaleDialog.gay_seeskrotchy_8v1", 1);
	Addto(lKrotchyCustomerComment,					"GMaleDialog.gay_seeskrotchy_9v1", 1);

	Clear(lKrotchyCustomerWant);
	Addto(lKrotchyCustomerWant,						"GMaleDialog.gay_seeskrotchy_1v1", 1);
	Addto(lKrotchyCustomerWant,						"GMaleDialog.gay_seeskrotchy_2v1", 1);
	Addto(lKrotchyCustomerWant,						"GMaleDialog.gay_seeskrotchy_3v1", 1);
	Addto(lKrotchyCustomerWant,						"GMaleDialog.gay_seeskrotchy_4v1", 1);
	Addto(lKrotchyCustomerWant,						"GMaleDialog.gay_seeskrotchy_5v1", 1);
	Addto(lKrotchyCustomerWant,						"GMaleDialog.gay_seeskrotchy_6v1", 1);
	Addto(lKrotchyCustomerWant,						"GMaleDialog.gay_seeskrotchy_7v1", 1);
	Addto(lKrotchyCustomerWant,						"GMaleDialog.gay_seeskrotchy_8v1", 1);
	Addto(lKrotchyCustomerWant,						"GMaleDialog.gay_seeskrotchy_9v1", 1);

	CLear(lcop_someonedisobeyed);
	Addto(lcop_someonedisobeyed,							"GMaleDialog.gay_postal_dorothysaysdiev1", 1);
	Addto(lcop_someonedisobeyed,							"GMaleDialog.gay_tough_bringitv1", 1);
	Addto(lcop_someonedisobeyed,							"GMaleDialog.gay_postal_banzaiv1", 1);
	Addto(lcop_someonedisobeyed,							"GMaleDialog.gay_tough_youthinkimscaredv1", 1);
	Addto(lcop_someonedisobeyed,							"GMaleDialog.gay_tough_youthinkthatcanv1", 1);
	Addto(lcop_someonedisobeyed,							"GMaleDialog.gay_postal_sweetdreamsv1", 1);

	CLear(lCop_GoingToInvestigate);
	Addto(lCop_GoingToInvestigate,							"GMaleDialog.gay_taunt_compensatev1", 1);
	Addto(lCop_GoingToInvestigate,							"GMaleDialog.gay_taunt_ohyeahbigmanv1", 1);
	Addto(lCop_GoingToInvestigate,							"GMaleDialog.gay_taunt_yourenotsotoughv1", 1);

	CLear(lCop_noticeillegalthing);
	Addto(lCop_noticeillegalthing,							"GMaleDialog.gay_taunt_compensatev1", 1);
	Addto(lCop_noticeillegalthing,							"GMaleDialog.gay_taunt_ohyeahbigmanv1", 1);
	Addto(lCop_noticeillegalthing,							"GMaleDialog.gay_seewang_tinytimv1", 1);

	Clear(lcop_putawaydick1);	
	Addto(lcop_putawaydick1,						"GMaleDialog.gay_seewang_heybuddyyourbarnv1", 1);
	Addto(lcop_putawaydick1,						"GMaleDialog.gay_seewang_somedignityv1", 1);
	Addto(lcop_putawaydick1,						"GMaleDialog.gay_seewang_tinytimv1", 1);
	Addto(lcop_putawaydick1,						"GMaleDialog.gay_seewang_xyzv1", 1);

	Clear(lcop_noticegaspouring);	
	Addto(lcop_noticegaspouring,							"GMaleDialog.gay_taunt_compensatev1", 1);
	Addto(lcop_noticegaspouring,							"GMaleDialog.gay_taunt_ohyeahbigmanv1", 1);
	Addto(lcop_noticegaspouring,							"GMaleDialog.gay_seewang_tinytimv1", 1);

	Clear(lcop_callforbackup);
	Addto(lcop_callforbackup,							"GMaleDialog.gay_postal_bitcheslooksatmev1", 1);
	Addto(lcop_callforbackup,							"GMaleDialog.gay_postal_bulletsv1", 1);
	Addto(lcop_callforbackup,							"GMaleDialog.gay_postal_dorothysaysdiev1", 1);

	Clear(lcop_whofiredweapon);
	Addto(lcop_whofiredweapon,							"GMaleDialog.gay_deadtaunt_assholev1", 1);
	Addto(lcop_whofiredweapon,							"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(lcop_whofiredweapon,							"GMaleDialog.gay_deadtaunt_loserv1", 1);
	Addto(lcop_whofiredweapon,							"GMaleDialog.gay_deadtaunt_suckstobeyouv1", 1);

	Clear(lcop_whoshotme);
	Addto(lcop_whoshotme,							"GMaleDialog.gay_deadtaunt_assholev1", 1);
	Addto(lcop_whoshotme,							"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(lcop_whoshotme,							"GMaleDialog.gay_deadtaunt_loserv1", 1);
	Addto(lcop_whoshotme,							"GMaleDialog.gay_deadtaunt_suckstobeyouv1", 1);

	Clear(lcop_freeze1);
	Addto(lcop_freeze1,						"GMaleDialog.gay_tough_bringitv1", 1);
	Addto(lcop_freeze1,						"GMaleDialog.gay_tough_cantstopv1", 1);
	Addto(lcop_freeze1,						"GMaleDialog.gay_tough_tryandstopmev1", 1);
	Addto(lcop_freeze1,						"GMaleDialog.gay_postal_banzaiv1", 1);
	Addto(lcop_freeze1,						"GMaleDialog.gay_postal_gayfuv1", 1);

	Clear(lcop_putdownweapon1);
	Addto(lcop_putdownweapon1,							"GMaleDialog.gay_taunt_compensatev1", 1);
	Addto(lcop_putdownweapon1,							"GMaleDialog.gay_taunt_ohyeahbigmanv1", 1);
	Addto(lcop_putdownweapon1,							"GMaleDialog.gay_postal_gayfuv1", 1);
	Addto(lcop_putdownweapon1,							"GMaleDialog.gay_tough_rahv1", 1);
	Addto(lcop_putdownweapon1,							"GMaleDialog.gay_tough_rahv2", 2);

	Clear(lcop_underarrest);
	Addto(lcop_underarrest,							"GMaleDialog.gay_taunt_compensatev1", 1);
	Addto(lcop_underarrest,							"GMaleDialog.gay_taunt_ohyeahbigmanv1", 1);

	Clear(lcop_holdstill);
	Addto(lcop_holdstill,							"GMaleDialog.gay_taunt_yourenotsotoughv1", 1);

	Clear(lCop_CopOuttaLine);
	Addto(lCop_CopOuttaLine,							"GMaleDialog.gay_deadtaunt_assholev1", 1);
	Addto(lCop_CopOuttaLine,							"GMaleDialog.gay_deadtaunt_idiotv1", 1);
	Addto(lCop_CopOuttaLine,							"GMaleDialog.gay_deadtaunt_loserv1", 1);
	Addto(lCop_CopOuttaLine,							"GMaleDialog.gay_deadtaunt_suckstobeyouv1", 1);

	Clear(lcop_Miranda);
	Addto(lcop_Miranda,						"GMaleDialog.gay_lawsuit1v1", 1);
	Addto(lcop_Miranda,						"GMaleDialog.gay_lawsuit2v1", 1);
	Addto(lcop_Miranda,						"GMaleDialog.gay_lawsuit3v1", 2);

	Clear(lcop_SuspectSighted);
	Addto(lcop_SuspectSighted,							"GMaleDialog.gay_tough_howaboutsomeofthisv1", 1);
	Addto(lcop_SuspectSighted,							"GMaleDialog.gay_tough_rahv1", 1);
	Addto(lcop_SuspectSighted,							"GMaleDialog.gay_tough_rahv2", 2);
	Addto(lcop_SuspectSighted,							"GMaleDialog.gay_tough_youthinkimscaredv1", 1);
	Addto(lcop_SuspectSighted,							"GMaleDialog.gay_tough_youthinkthatcanv1", 1);
	
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
