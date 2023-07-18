///////////////////////////////////////////////////////////////////////////////
// DialogFanatic
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Dialog for Fanatics
//
///////////////////////////////////////////////////////////////////////////////
class DialogFanatic extends DialogGeneric;

// We don't want these guys using any of the "white male" dialog lines, so extend from Generic.
// Even if it means they don't talk at all, it's better than having them use the white male lines.


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lapplauding);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_amazingV1", 1);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_amazingV2", 2);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_booyawV1", 1);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_booyawV2", 2);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_gomanV1", 1);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_gomanV2", 2);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_gomanV3", 3);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_theoneV1", 1);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_theoneV2", 2);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_whatimtalkinboutV1", 1);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_whatimtalkinboutV2", 2);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_wootV1", 1);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_wootV2", 2);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_yeahx2V1", 1);
	AddTo(lApplauding,							"FanaticDialog.aq_cheer_yeahx2V2", 2);

	Clear(lgreeting);
	Clear(lhotgreeting);
	Clear(lgreetingquestions);
	Clear(lHotgreetingquestions);
	Clear(lrespondtohotgreeting);
	Clear(lRespondtogreeting);
	Clear(lrespondtogreetingresponse);
	Clear(lHelloCop);
	Clear(lHelloGimp);
	Clear(lApologize);
	Clear(lyourewelcome);
	Clear(lno);
	Clear(lyes);
	Clear(lthanks);
	Clear(lThatsGreat);
	Clear(lGetDown);
	Clear(lGetDownMP);

	Clear(lCussing);
	AddTo(lCussing,								"FanaticDialog.aq_damage_allahV1", 1);
	AddTo(lCussing,								"FanaticDialog.aq_damage_allahV2", 2);
	AddTo(lCussing,								"FanaticDialog.aq_damage_fuckV1", 1);
	AddTo(lCussing,								"FanaticDialog.aq_damage_fuckV2", 2);
	AddTo(lCussing,								"FanaticDialog.aq_damage_shitV1", 1);

	Clear(lgetdownscared);

	Clear(ldefiant);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_bitemeV1", 1);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_bitemeV2", 2);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_goscrewyourselfV1", 1);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_goscrewyourselfV2", 2);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_suckitV1", 1);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_suckitV2", 2);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_upyourspigV1", 1);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_yomommaV1", 1);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_yomommaV2", 2);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_yourenottheayatollaV1", 1);
	Addto(ldefiant,								"FanaticDialog.aq_rebel_yourenottheayatollaV2", 2);

	Clear(ldefiantline);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_bitemeV1", 1);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_bitemeV2", 2);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_goscrewyourselfV1", 1);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_goscrewyourselfV2", 2);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_suckitV1", 1);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_suckitV2", 2);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_upyourspigV1", 1);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_yomommaV1", 1);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_yomommaV2", 2);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_yourenottheayatollaV1", 1);
	Addto(ldefiantline,							"FanaticDialog.aq_rebel_yourenottheayatollaV2", 2);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"FanaticDialog.aq_damage_akV1", 1);
	Addto(lCloseToWeapon,						"FanaticDialog.aq_damage_akV2", 2);
	Addto(lCloseToWeapon,						"FanaticDialog.aq_damage_allahV1", 1);
	Addto(lCloseToWeapon,						"FanaticDialog.aq_damage_allahV2", 2);
	Addto(lCloseToWeapon,						"FanaticDialog.aq_damage_fuckV1", 1);
	Addto(lCloseToWeapon,						"FanaticDialog.aq_damage_fuckV2", 2);
	Addto(lCloseToWeapon,						"FanaticDialog.aq_damage_shitV1", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"FanaticDialog.aq_tough_bringitV1", 1);
	Addto(ldecidetofight,						"FanaticDialog.aq_tough_bringitV2", 2);
	Addto(ldecidetofight,						"FanaticDialog.aq_tough_howaboutsomeofthisV1", 1);
	Addto(ldecidetofight,						"FanaticDialog.aq_tough_howaboutsomeofthisV2", 2);
	Addto(ldecidetofight,						"FanaticDialog.aq_tough_lililiV1", 1);
	Addto(ldecidetofight,						"FanaticDialog.aq_tough_lililiV2", 2);

	Clear(llaughing);
	Addto(llaughing,							"WMaleDialog.wm_laugh", 1);

	Clear(lSnickering);
	Addto(lSnickering,							"WMaleDialog.wm_snicker", 1);

	Clear(lOutOfBreath);
	Addto(lOutOfBreath,							"WMaleDialog.wm_outofbreath", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"FanaticDialog.aq_seepanic_1V1", 1);
	Addto(lWatchingCrazy,						"FanaticDialog.aq_seepanic_1V2", 2);
	Addto(lWatchingCrazy,						"FanaticDialog.aq_seepanic_2V1", 1);
	Addto(lWatchingCrazy,						"FanaticDialog.aq_seepanic_2V2", 2);
	Addto(lWatchingCrazy,						"FanaticDialog.aq_seepanic_2V3", 3);

	Clear(lshootingoverthere);
	Clear(lkillingoverthere);
	
	Clear(lscreaming);
	Addto(lscreaming,							"FanaticDialog.aq_scream1", 1);
	Addto(lscreaming,							"FanaticDialog.aq_scream2", 2);
	Addto(lscreaming,							"FanaticDialog.aq_scream3", 3);
	Addto(lscreaming,							"FanaticDialog.aq_scream4", 4);
	Addto(lscreaming,							"FanaticDialog.aq_scream5", 5);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_awghelpme", 1);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_babyjesusV1", 1);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_babyjesusV2", 2);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_burningV1", 1);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_burningV2", 2);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_burningV3", 3);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_burningV4", 4);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_fiyaa", 1);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_putmeout", 1);
	Addto(lscreamingonfire,						"FanaticDialog.aq_onfire_yeagh", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"FanaticDialog.aq_tough_tryandstopmeV1", 1);
	Addto(lDoHeroics,							"FanaticDialog.aq_tough_tryandstopmeV2", 2);
	Addto(lDoHeroics,							"FanaticDialog.aq_tough_youthinkimscaredV1", 1);
	Addto(lDoHeroics,							"FanaticDialog.aq_tough_youthinkimscaredV2", 2);
	Addto(lDoHeroics,							"FanaticDialog.aq_tough_youthinkthatcanV1", 1);
	Addto(lDoHeroics,							"FanaticDialog.aq_tough_youthinkthatcanV2", 2);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"FanaticDialog.aq_spitoutpissV1", 1);
	Addto(lgettingpissedon,						"FanaticDialog.aq_spitoutpissV2", 2);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"FanaticDialog.aq_damage_aghkV1", 1);
	Addto(laftergettingpissedon,				"FanaticDialog.aq_damage_aiieeV1", 1);
	Addto(laftergettingpissedon,				"FanaticDialog.aq_damage_aiieeV2", 2);
	
	Clear(lwhatthe);
	AddTo(lWhatThe,								"FanaticDialog.aq_damage_aghkV1", 1);
	AddTo(lWhatThe,								"FanaticDialog.aq_damage_aughV1", 1);

	Clear(lseeingpisser);
	Clear(lSomethingIsGross);

	Clear(lgothit);
	Addto(lgothit,								"FanaticDialog.aq_damage_aghkV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_aiieeV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_aiieeV2", 2);
	Addto(lgothit,								"FanaticDialog.aq_damage_akV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_akV2", 2);
	Addto(lgothit,								"FanaticDialog.aq_damage_allahV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_allahV2", 2);
	Addto(lgothit,								"FanaticDialog.aq_damage_arghV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_aughV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_badtouchV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_badtouchV2", 2);
	Addto(lgothit,								"FanaticDialog.aq_damage_badtouchV3", 3);
	Addto(lgothit,								"FanaticDialog.aq_damage_fuckV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_fuckV2", 2);
	Addto(lgothit,								"FanaticDialog.aq_damage_gakV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_gakV2", 2);
	Addto(lgothit,								"FanaticDialog.aq_damage_mommyV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_mommyV2", 2);
	Addto(lgothit,								"FanaticDialog.aq_damage_myspineV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_myspineV2", 2);
	Addto(lgothit,								"FanaticDialog.aq_damage_owV1", 1);
	Addto(lgothit,								"FanaticDialog.aq_damage_shitV1", 1);

	Clear(lAttacked);
	Addto(lAttacked,							"FanaticDialog.aq_damage_aghkV1", 1);
	Addto(lAttacked,							"FanaticDialog.aq_damage_akV1", 1);
	Addto(lAttacked,							"FanaticDialog.aq_damage_akV2", 2);
	Addto(lAttacked,							"FanaticDialog.aq_damage_arghV1", 1);
	Addto(lAttacked,							"FanaticDialog.aq_damage_aughV1", 1);
	Addto(lAttacked,							"FanaticDialog.aq_damage_fuckV1", 1);
	Addto(lAttacked,							"FanaticDialog.aq_damage_fuckV2", 2);
	Addto(lAttacked,							"FanaticDialog.aq_damage_gakV1", 1);
	Addto(lAttacked,							"FanaticDialog.aq_damage_gakV2", 2);
	Addto(lAttacked,							"FanaticDialog.aq_damage_owV1", 1);
	Addto(lAttacked,							"FanaticDialog.aq_damage_shitV1", 1);

	Clear(lGrunt);
	Addto(lGrunt,								"FanaticDialog.aq_damage_aghkV1", 1);
	Addto(lGrunt,								"FanaticDialog.aq_damage_akV1", 1);
	Addto(lGrunt,								"FanaticDialog.aq_damage_akV2", 2);
	Addto(lGrunt,								"FanaticDialog.aq_damage_arghV1", 1);
	Addto(lGrunt,								"FanaticDialog.aq_damage_aughV1", 1);
	Addto(lGrunt,								"FanaticDialog.aq_damage_fuckV1", 1);
	Addto(lGrunt,								"FanaticDialog.aq_damage_fuckV2", 2);
	Addto(lGrunt,								"FanaticDialog.aq_damage_gakV1", 1);
	Addto(lGrunt,								"FanaticDialog.aq_damage_gakV2", 2);
	Addto(lGrunt,								"FanaticDialog.aq_damage_owV1", 1);
	Addto(lGrunt,								"FanaticDialog.aq_damage_shitV1", 1);

	Clear(lPissing);
	Clear(lPissOnSelf);
	Clear(lPissOutFireOnSelf);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,				"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lGotHealth);
	Clear(lGotHealthFood);
	Clear(lGotCrackHealth);
	Clear(lGotHitInCrotch);	

	Clear(lbegforlife);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_crying1", 1);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_crying2", 1);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_crying3", 2);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_crying4", 2);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_cryingV1", 3);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_dontkillvirginV1", 1);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_dontkillvirginV2", 2);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_pleasedontkillmeV1", 1);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_pleasedontkillmeV2", 2);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_pleasepleasenoV1", 1);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_snivel1", 1);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_sparemylifewivesV1", 1);
	Addto(lbegforlife,							"FanaticDialog.aq_beg_sparemylifewivesV2", 2);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_crying1", 1);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_crying2", 1);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_crying3", 2);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_crying4", 2);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_cryingV1", 3);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_dontkillvirginV1", 1);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_dontkillvirginV2", 2);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_pleasedontkillmeV1", 1);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_pleasedontkillmeV2", 2);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_pleasepleasenoV1", 1);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_snivel1", 1);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_sparemylifewivesV1", 1);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_sparemylifewivesV2", 2);
	Addto(lbegforlifeMin,						"FanaticDialog.aq_beg_dontkillminorityV1", 1);
	
	Clear(ldying);
	Addto(lDying, 								"HabibDialog.habib_imreadyformy", 1);
	Addto(lDying,								"HabibDialog.habib_dying", 1);

	Clear(lCrying);
	Addto(lCrying,								"FanaticDialog.aq_beg_crying1", 1);
	Addto(lCrying,								"FanaticDialog.aq_beg_crying2", 1);
	Addto(lCrying,								"FanaticDialog.aq_beg_crying3", 1);
	Addto(lCrying,								"FanaticDialog.aq_beg_crying4", 1);
	Addto(lCrying,								"FanaticDialog.aq_beg_cryingV1", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,					"FanaticDialog.aq_beg_neveragainV1", 1);	
	Addto(lfrightenedapology,					"FanaticDialog.aq_beg_onlyjokingV1", 1);	
	Addto(lfrightenedapology,					"FanaticDialog.aq_beg_onlyjokingV2", 2);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"FanaticDialog.aq_taunt_cmonfightlikeaV1", 1);
	Addto(ltrashtalk,							"FanaticDialog.aq_taunt_cmonfightlikeaV2", 2);
	Addto(ltrashtalk,							"FanaticDialog.aq_taunt_cmonfightlikeaV3", 3);
	Addto(ltrashtalk,							"FanaticDialog.aq_taunt_cmonfightlikeaV4", 4);
	Addto(ltrashtalk,							"FanaticDialog.aq_taunt_ohyeahbigmanwithaV1", 1);
	Addto(ltrashtalk,							"FanaticDialog.aq_taunt_ohyeahbigmanwithaV2", 2);
	Addto(ltrashtalk,							"FanaticDialog.aq_taunt_whereyougoingsissyV1", 1);
	Addto(ltrashtalk,							"FanaticDialog.aq_taunt_yourenotsotoughV1", 1);
	Addto(ltrashtalk,							"FanaticDialog.aq_taunt_yourenotsotoughV2", 2);

	Clear(lWhileFighting);
	Addto(lWhileFighting,						"FanaticDialog.aq_taunt_cmonfightlikeaV1", 1);
	Addto(lWhileFighting,						"FanaticDialog.aq_taunt_cmonfightlikeaV2", 2);
	Addto(lWhileFighting,						"FanaticDialog.aq_taunt_cmonfightlikeaV3", 3);
	Addto(lWhileFighting,						"FanaticDialog.aq_taunt_cmonfightlikeaV4", 4);
	Addto(lWhileFighting,						"FanaticDialog.aq_taunt_ohyeahbigmanwithaV1", 1);
	Addto(lWhileFighting,						"FanaticDialog.aq_taunt_ohyeahbigmanwithaV2", 2);
	Addto(lWhileFighting,						"FanaticDialog.aq_taunt_whereyougoingsissyV1", 1);
	Addto(lWhileFighting,						"FanaticDialog.aq_taunt_yourenotsotoughV1", 1);
	Addto(lWhileFighting,						"FanaticDialog.aq_taunt_yourenotsotoughV2", 2);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,						"FanaticDialog.aq_whatseemstobetheV1", 1);
	Addto(laskcopwhatsup,						"FanaticDialog.aq_whatseemstobetheV2", 2);

	Clear(lratout);
	Clear(lfakeratout);

	Clear(lcleanshot);
	Addto(lcleanshot,							"FanaticDialog.aq_shotblocked1V1", 1);
	Addto(lcleanshot,							"FanaticDialog.aq_shotblocked1V2", 2);
	Addto(lcleanshot,							"FanaticDialog.aq_shotblocked3V1", 1);
	Addto(lcleanshot,							"FanaticDialog.aq_shotblocked3V2", 2);
	Addto(lcleanshot,							"FanaticDialog.aq_shotblocked4V1", 1);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"FanaticDialog.aq_shotblocked3V1", 1);
	Addto(lCleanMeleeHit,						"FanaticDialog.aq_shotblocked3V2", 2);
	Addto(lCleanMeleeHit,						"FanaticDialog.aq_shotblocked4V1", 1);

	Clear(lInhale);
	Addto(lInhale,								"WMaleDialog.wm_inhale", 1);
												
	Clear(lExhale);								
	Addto(lExhale,								"WMaleDialog.wm_exhale", 1);
	
	Clear(lEatingFood);
	Clear(lAfterEating);
	Clear(lpleasureresponse);					
	Clear(laftersitdown);
	Clear(lSpitting);
	Clear(lhmm);
	Clear(lfollowme);
	Clear(lStayHere);

	Clear(lnoticedickout);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_mustntlookV1", 1);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_mustntlookV2", 2);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_mustntlookV3", 3);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_pullyourpantsupV1", 1);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_pullyourpantsupV2", 2);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_pullyourpantsupV3", 3);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_whyyourschwartzV1", 1);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_whyyourschwartzV2", 2);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_xyzV1", 1);
	Addto(lnoticedickout,						"FanaticDialog.aq_seewang_xyzV2", 2);

	Clear(lilltakenumber);
	Clear(lmakedeposit);
	Clear(lmakewithdrawal);
	Clear(lconsumerbuy);
	Clear(lconteststoretransaction);
	Clear(lcontestbanktransaction);
	Clear(lGoPostal);
	Clear(lcarnageoccurred);
	Clear(lCallCat);
	Clear(lHateCat);

	Clear(lStartAttackingAnimal);
	AddTo(lStartAttackingAnimal,				"FanaticDialog.aq_damage_allahV1", 1);
	AddTo(lStartAttackingAnimal,				"FanaticDialog.aq_damage_allahV2", 2);
	AddTo(lStartAttackingAnimal,				"FanaticDialog.aq_damage_fuckV1", 1);
	AddTo(lStartAttackingAnimal,				"FanaticDialog.aq_damage_fuckV2", 2);
	AddTo(lStartAttackingAnimal,				"FanaticDialog.aq_damage_shitV1", 1);

	Clear(lGettingRobbed);	
	Addto(lGettingRobbed, 							"HabibDialog.habib_youarestealing", 1);
	Addto(lGettingRobbed,							"HabibDialog.habib_stop", 1);
	Addto(lGettingRobbed,							"HabibDialog.habib_someonestophim", 1);
	Addto(lGettingRobbed,							"HabibDialog.habib_policepolice", 1);

	Clear(lGettingMugged);	
	Clear(lAfterMugged);	
	Clear(lDoMugging);	
	Clear(lQuestion);	
	Clear(lGenericQuestion);	
	Clear(lGenericAnswer);	
	Clear(lGenericFollowup);	
	Clear(lGenericGoodbye);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"FanaticDialog.aq_startfight2V1", 1);
	Addto(linvadeshome,							"FanaticDialog.aq_startfight2V2", 2);
	Addto(linvadeshome,							"FanaticDialog.aq_startfight3V1", 1);
	Addto(linvadeshome,							"FanaticDialog.aq_startfight3V2", 2);
	Addto(linvadeshome,							"FanaticDialog.aq_startfight4V1", 1);
	Addto(linvadeshome,							"FanaticDialog.aq_startfight4V2", 2);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,						"FanaticDialog.aq_seefire__whatsmellsV1", 1);
	Addto(lsomeoneonfire,						"FanaticDialog.aq_seefire__whatsmellsV2", 2);
	Addto(lsomeoneonfire,						"FanaticDialog.aq_seefire_firex2V1", 1);
	Addto(lsomeoneonfire,						"FanaticDialog.aq_seefire_firex2V2", 2);
	Addto(lsomeoneonfire,						"FanaticDialog.aq_seeonfire_dropandrollV1", 1);
	Addto(lsomeoneonfire,						"FanaticDialog.aq_seeonfire_dropandrollV2", 2);

	Clear(labouttopuke);
	Addto(labouttopuke,							"FanaticDialog.aq_puke_idontfeelsogoodV1", 1);
	Addto(labouttopuke,							"FanaticDialog.aq_puke_idontfeelsogoodV2", 2);
	Addto(labouttopuke,							"FanaticDialog.aq_puke_ohgodimV1", 1);
	Addto(labouttopuke,							"FanaticDialog.aq_puke_ohgodimV2", 2);
	Addto(labouttopuke,							"FanaticDialog.aq_puke_ohmanimgonnabesickV1", 1);
	Addto(labouttopuke,							"FanaticDialog.aq_puke_ohmanimgonnabesickV2", 2);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,							"WMaleDialog.wm_vomit", 1);

	Clear(lGettingShocked);
	Addto(lGettingShocked,							"WMaleDialog.wm_vomit", 1);

	Clear(lBattleCry);
	Addto(lBattleCry,							"FanaticDialog.aq_tough_lililiV1", 1);
	Addto(lBattleCry,							"FanaticDialog.aq_tough_lililiV2", 1);

	Clear(lCellPhoneTalk);
	Clear(lZealots);
	Clear(lKrotchyCustomerComment);
	Clear(lKrotchyCustomerWant);
	Clear(lGaryAutograph);
	Clear(lProtestorCut);
	
	Clear(ldudedead);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_bethewasgayV1", 1);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_bethewasgayV2", 2);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_bethewasgayV3", 3);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_blamejewsV1", 1);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_blamejewsV2", 2);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_goddamliberalV1", 1);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_goddamliberalV2", 2);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_nextlifedodge", 1);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_nextlifedodgeV1", 2);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_nextlifedodgeV2", 3);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_saddamV1", 1);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_saddamV2", 2);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_shouldtriedV1", 1);
	Addto(ldudedead,							"FanaticDialog.aq_deadtaunt_shouldtriedV2", 2);

	Clear(lKickDead);
	Addto(lKickDead,							"FanaticDialog.aq_deadtaunt_forgotoneV1", 1);
	Addto(lKickDead,							"FanaticDialog.aq_deadtaunt_oneformotherV1", 1);
	Addto(lKickDead,							"FanaticDialog.aq_deadtaunt_oneformotherV2", 2);
	Addto(lKickDead,							"FanaticDialog.aq_deadtaunt_oneformotherV3", 3);
	Addto(lKickDead,							"FanaticDialog.aq_deadtaunt_takethiswithyouV1", 1);

	Clear(lNameCalling);
	Clear(lRogueCop);

	Clear(lgetbumped);
	Addto(lgetbumped,							"FanaticDialog.aq_damage_aghkV1", 1);
	Addto(lgetbumped,							"FanaticDialog.aq_damage_owV1", 1);
	Addto(lgetbumped,							"FanaticDialog.aq_rebel_bitemeV1", 1);
	Addto(lgetbumped,							"FanaticDialog.aq_rebel_bitemeV2", 2);
	Addto(lgetbumped,							"FanaticDialog.aq_rebel_goscrewyourselfV1", 1);
	Addto(lgetbumped,							"FanaticDialog.aq_rebel_goscrewyourselfV2", 2);
	Addto(lgetbumped,							"FanaticDialog.aq_rebel_suckitV1", 1);
	Addto(lgetbumped,							"FanaticDialog.aq_rebel_suckitV2", 2);
	Addto(lgetbumped,							"FanaticDialog.aq_rebel_upyourspigV1", 1);
	Addto(lgetbumped,							"FanaticDialog.aq_rebel_yomommaV1", 1);
	Addto(lgetbumped,							"FanaticDialog.aq_rebel_yomommaV2", 2);

	Clear(lGetMad);
	Addto(lGetMad,								"FanaticDialog.aq_damage_aghkV1", 1);
	Addto(lGetMad,								"FanaticDialog.aq_damage_owV1", 1);
	Addto(lGetMad,								"FanaticDialog.aq_rebel_bitemeV1", 1);
	Addto(lGetMad,								"FanaticDialog.aq_rebel_bitemeV2", 2);
	Addto(lGetMad,								"FanaticDialog.aq_rebel_goscrewyourselfV1", 1);
	Addto(lGetMad,								"FanaticDialog.aq_rebel_goscrewyourselfV2", 2);
	Addto(lGetMad,								"FanaticDialog.aq_rebel_suckitV1", 1);
	Addto(lGetMad,								"FanaticDialog.aq_rebel_suckitV2", 2);
	Addto(lGetMad,								"FanaticDialog.aq_rebel_upyourspigV1", 1);
	Addto(lGetMad,								"FanaticDialog.aq_rebel_yomommaV1", 1);
	Addto(lGetMad,								"FanaticDialog.aq_rebel_yomommaV2", 2);

	Clear(lLynchMob);
	Addto(lLynchMob,							"FanaticDialog.aq_startfight1V1", 1);
	Addto(lLynchMob,							"FanaticDialog.aq_startfight1V2", 2);
	Addto(lLynchMob,							"FanaticDialog.aq_startfight3V1", 1);
	Addto(lLynchMob,							"FanaticDialog.aq_startfight3V2", 2);
	Addto(lLynchMob,							"FanaticDialog.aq_startfight4V1", 1);
	Addto(lLynchMob,							"FanaticDialog.aq_startfight4V2", 2);
	Addto(lLynchMob,							"FanaticDialog.aq_tough_howaboutsomeofthisV1", 1);
	Addto(lLynchMob,							"FanaticDialog.aq_tough_howaboutsomeofthisV2", 2);
	Addto(lLynchMob,							"FanaticDialog.aq_tough_lililiV1", 1);
	Addto(lLynchMob,							"FanaticDialog.aq_tough_lililiV2", 2);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"FanaticDialog.aq_startfight1V1", 1);
	Addto(lSeesEnemy,							"FanaticDialog.aq_startfight1V2", 2);
	Addto(lSeesEnemy,							"FanaticDialog.aq_startfight3V1", 1);
	Addto(lSeesEnemy,							"FanaticDialog.aq_startfight3V2", 2);
	Addto(lSeesEnemy,							"FanaticDialog.aq_startfight4V1", 1);
	Addto(lSeesEnemy,							"FanaticDialog.aq_startfight4V2", 2);
	Addto(lSeesEnemy,							"FanaticDialog.aq_tough_howaboutsomeofthisV1", 1);
	Addto(lSeesEnemy,							"FanaticDialog.aq_tough_howaboutsomeofthisV2", 2);
	Addto(lSeesEnemy,							"FanaticDialog.aq_tough_lililiV1", 1);
	Addto(lSeesEnemy,							"FanaticDialog.aq_tough_lililiV2", 2);

	Clear(lNextInLine);
	Addto(lNextInLine, 								"HabibDialog.habib_illtakethenext", 1);
	
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

	Clear(lSignPetition);							
	Addto(lSignPetition,						"FanaticDialog.aq_cheer_amazingV1", 1);
	Addto(lSignPetition,						"FanaticDialog.aq_cheer_amazingV2", 2);
	Addto(lSignPetition,						"FanaticDialog.aq_cheer_whatimtalkinboutV1", 1);
	Addto(lSignPetition,						"FanaticDialog.aq_cheer_whatimtalkinboutV2", 2);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"FanaticDialog.aq_rebel_bitemeV1", 1);
	Addto(lDontSignPetition,					"FanaticDialog.aq_rebel_bitemeV2", 2);
	Addto(lDontSignPetition,					"FanaticDialog.aq_rebel_goscrewyourselfV1", 1);
	Addto(lDontSignPetition,					"FanaticDialog.aq_rebel_goscrewyourselfV2", 2);
	Addto(lDontSignPetition,					"FanaticDialog.aq_rebel_hamsandwichV1", 1);
	Addto(lDontSignPetition,					"FanaticDialog.aq_rebel_hamsandwichV2", 2);
	Addto(lDontSignPetition,					"FanaticDialog.aq_rebel_suckitV1", 1);
	Addto(lDontSignPetition,					"FanaticDialog.aq_rebel_suckitV2", 2);
	Addto(lDontSignPetition,					"FanaticDialog.aq_rebel_upyourspigV1", 1);

	Clear(lPetitionBother);
	Addto(lPetitionBother,						"FanaticDialog.aq_rebel_bitemeV1", 1);
	Addto(lPetitionBother,						"FanaticDialog.aq_rebel_bitemeV2", 2);
	Addto(lPetitionBother,						"FanaticDialog.aq_rebel_goscrewyourselfV1", 1);
	Addto(lPetitionBother,						"FanaticDialog.aq_rebel_goscrewyourselfV2", 2);
	Addto(lPetitionBother,						"FanaticDialog.aq_rebel_hamsandwichV1", 1);
	Addto(lPetitionBother,						"FanaticDialog.aq_rebel_hamsandwichV2", 2);
	Addto(lPetitionBother,						"FanaticDialog.aq_rebel_suckitV1", 1);
	Addto(lPetitionBother,						"FanaticDialog.aq_rebel_suckitV2", 2);
	Addto(lPetitionBother,							"FanaticDialog.aq_rebel_upyourspigV1", 1);

	Clear(lcallsecurity);
	
	Clear(lRowdyCustomer);
	Addto(lRowdyCustomer, 						"HabibDialog.habib_pleasecalmdown", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
