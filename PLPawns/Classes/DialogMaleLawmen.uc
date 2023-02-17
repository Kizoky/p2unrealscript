///////////////////////////////////////////////////////////////////////////////
// DialogMaleLawmen
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for Lawmen based on the PIII cop lines
//
//
///////////////////////////////////////////////////////////////////////////////
class DialogMaleLawmen extends DialogMaleAlt;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();
	
	Clear(lgetbumped);
	Addto(lgetbumped,							"WMaleLawmenDialog.cop_warn_getlostv1", 1);
	Addto(lgetbumped,							"WMaleLawmenDialog.cop_warn_getlostv2", 2);
	Addto(lgetbumped,							"WMaleLawmenDialog.cop_warn_keepmovingv1", 1);
	Addto(lgetbumped,							"WMaleLawmenDialog.cop_warn_keepmovingv2", 2);
	Addto(lgetbumped,							"WMaleLawmenDialog.cop_warn_movealongv1", 1);
	Addto(lgetbumped,							"WMaleLawmenDialog.cop_warn_movealongv2", 2);
	Addto(lgetbumped,							"WMaleLawmenDialog.cop_warn_moveawayv1", 1);
	Addto(lgetbumped,							"WMaleLawmenDialog.cop_warn_moveawayv2", 2);
	
	Clear(ldefiant);
	Addto(ldefiant,								"WMaleLawmenDialog.cop_attacking_fuckyouv1", 1);
	Addto(ldefiant,								"WMaleLawmenDialog.cop_attacking_fuckyouv2", 2);
	Addto(ldefiant,								"WMaleLawmenDialog.cop_attacking_suckjusticev1", 1);
	Addto(ldefiant,								"WMaleLawmenDialog.cop_attacking_suckjusticev2", 2);
	
	Clear(lGetMad);
	Addto(lGetMad,								"WMaleLawmenDialog.cop_attacking_fuckyouv1", 1);
	Addto(lGetMad,								"WMaleLawmenDialog.cop_attacking_fuckyouv2", 2);
	Addto(lGetMad,								"WMaleLawmenDialog.cop_attacking_eatitv1", 1);
	Addto(lGetMad,								"WMaleLawmenDialog.cop_attacking_eatitv2", 2);
	Addto(lGetMad,								"WMaleLawmenDialog.cop_disobeyed2v1", 1);
	Addto(lGetMad,								"WMaleLawmenDialog.cop_disobeyed2v2", 2);
	Addto(lGetMad,								"WMaleLawmenDialog.cop_friendlyfire3v1", 1);
	Addto(lGetMad,								"WMaleLawmenDialog.cop_friendlyfire3v2", 2);
	
	Clear(lhmm);
	Addto(lhmm,									"WMaleLawmenDialog.cop_hmmv1", 1);
	Addto(lhmm,									"WMaleLawmenDialog.cop_hmmv2", 1);
	Addto(lhmm,									"WMaleLawmenDialog.cop_hmmv3", 1);
	Addto(lhmm,									"WMaleLawmenDialog.cop_hmmv4", 1);
	
	Clear(ltrashtalk);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_diev1", 1);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_diev2", 2);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_eatitv1", 1);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_eatitv2", 2);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_eatleadv1", 1);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_eatleadv2", 2);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_eatleadv3", 3);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_eatleadv4", 3);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_fuckyouv1", 1);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_fuckyouv2", 2);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_goingdownv1", 1);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_goingdownv2", 2);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_suckjusticev1", 1);
	Addto(ltrashtalk,							"WMaleLawmenDialog.cop_attacking_suckjusticev2", 2);

	Clear(lGetDown);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown1v1", 1);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown1v2", 2);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown2v1", 1);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown2v2", 2);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown3v1", 1);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown3v2", 2);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown4v1", 1);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown4v2", 2);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown5v1", 1);
	AddTo(lGetDown,							"WMaleLawmenDialog.cop_getdown5v2", 2);
	
	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"WMaleLawmenDialog.cop_attacking_fuckyouv1", 1);
	Addto(lDontSignPetition,					"WMaleLawmenDialog.cop_attacking_fuckyouv2", 2);
	
	Clear(lcop_nothingtosee);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_getlostv1", 1);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_getlostv2", 2);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_keepmovingv1", 1);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_keepmovingv2", 2);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_movealongv1", 1);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_movealongv2", 2);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_moveawayv1", 1);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_moveawayv2", 2);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_moveitv1", 1);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_moveitv2", 2);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_nothing2seev1", 1);
	AddTo(lcop_nothingtosee,						"WMaleLawmenDialog.cop_warn_nothing2seev2", 2);
	
	CLear(lCleanShot);
	AddTo(lCleanShot,							"WMaleLawmenDialog.cop_shotblocked1v1", 1);	
	AddTo(lCleanShot,							"WMaleLawmenDialog.cop_shotblocked1v2", 2);
	AddTo(lCleanShot,							"WMaleLawmenDialog.cop_shotblocked2v1", 1);
	AddTo(lCleanShot,							"WMaleLawmenDialog.cop_shotblocked2v2", 2);
	AddTo(lCleanShot,							"WMaleLawmenDialog.cop_shotblocked3v1", 1);	
	AddTo(lCleanShot,							"WMaleLawmenDialog.cop_shotblocked3v2", 2);
	AddTo(lCleanShot,							"WMaleLawmenDialog.cop_shotblocked4v1", 1);
	AddTo(lCleanShot,							"WMaleLawmenDialog.cop_shotblocked4v2", 2);

	CLear(lCleanMeleeHit);
	AddTo(lCleanMeleeHit,							"WMaleLawmenDialog.cop_shotblocked1v1", 1);	
	AddTo(lCleanMeleeHit,							"WMaleLawmenDialog.cop_shotblocked1v2", 2);
	AddTo(lCleanMeleeHit,							"WMaleLawmenDialog.cop_shotblocked4v1", 1);
	AddTo(lCleanMeleeHit,							"WMaleLawmenDialog.cop_shotblocked4v2", 2);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"WMaleLawmenDialog.cop_seebad1v2", 1);
	Addto(linvadeshome,							"WMaleLawmenDialog.cop_seebad1v3", 2);
	Addto(linvadeshome,							"WMaleLawmenDialog.cop_seebad2v1", 1);
	Addto(linvadeshome,							"WMaleLawmenDialog.cop_seebad2v2", 2);
	Addto(linvadeshome,							"WMaleLawmenDialog.cop_seebad3v1", 1);
	Addto(linvadeshome,							"WMaleLawmenDialog.cop_seebad3v2", 2);
	Addto(linvadeshome,							"WMaleLawmenDialog.cop_seebad4v1", 1);
	Addto(linvadeshome,							"WMaleLawmenDialog.cop_seebad4v2", 2);

	CLear(lGotHit);
	AddTo(lGotHit,								"WMaleLawmenDialog.cop_damage_aaghv1", 1);	
	AddTo(lGotHit,								"WMaleLawmenDialog.cop_damage_aaghv2", 1);					
	AddTo(lGotHit,								"WMaleLawmenDialog.cop_damage_aaghv3", 1);
	AddTo(lGotHit,								"WMaleLawmenDialog.cop_damage_arghv1", 1);
	AddTo(lGotHit,								"WMaleLawmenDialog.cop_damage_arghv2", 1);	
	AddTo(lGotHit,								"WMaleLawmenDialog.cop_damage_imhitv1", 1);					
	AddTo(lGotHit,								"WMaleLawmenDialog.cop_damage_imhitv2", 1);

	CLear(lcop_someonedisobeyed);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_disobeyed1v1", 1);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_disobeyed1v2", 2);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_disobeyed2v1", 1);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_disobeyed2v2", 2);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_disobeyed3v1", 1);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_disobeyed3v2", 2);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_friendlyfire_finalv1", 1);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_friendlyfire_finalv2", 2);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_friendlyfire_finalv3", 3);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_friendlyfire4v1", 1);
	AddTo(lcop_someonedisobeyed,						"WMaleLawmenDialog.cop_friendlyfire4v2", 2);

	CLear(lCop_GoingToInvestigate);
	AddTo(lCop_GoingToInvestigate,						"WMaleLawmenDialog.cop_assist1V1", 1);
	AddTo(lCop_GoingToInvestigate,						"WMaleLawmenDialog.cop_assist1v2", 2);
	AddTo(lCop_GoingToInvestigate,						"WMaleLawmenDialog.cop_assist2V1", 1);
	AddTo(lCop_GoingToInvestigate,						"WMaleLawmenDialog.cop_assist2v2", 2);
	AddTo(lCop_GoingToInvestigate,						"WMaleLawmenDialog.cop_assist3V1", 1);
	AddTo(lCop_GoingToInvestigate,						"WMaleLawmenDialog.cop_assist3v2", 2);

	CLear(laftergettingpissedon);
	Addto(laftergettingpissedon,						"WMaleLawmenDialog.cop_seesbrutalact1v1", 1);
	Addto(laftergettingpissedon,						"WMaleLawmenDialog.cop_seesbrutalact1v2", 2);
	Addto(laftergettingpissedon,						"WMaleLawmenDialog.cop_seesbrutalact2v1", 1);
	Addto(laftergettingpissedon,						"WMaleLawmenDialog.cop_seesbrutalact2v2", 2);
	Addto(laftergettingpissedon,						"WMaleLawmenDialog.cop_seesbrutalact3v1", 1);
	Addto(laftergettingpissedon,						"WMaleLawmenDialog.cop_seesbrutalact3v2", 2);
	Addto(laftergettingpissedon,						"WMaleLawmenDialog.cop_seesbrutalact3v3", 3);
	Addto(laftergettingpissedon,						"WMaleLawmenDialog.cop_seesbrutalact4v1", 1);
	Addto(laftergettingpissedon,						"WMaleLawmenDialog.cop_seesbrutalact4v2", 2);

	CLear(lCop_noticeillegalthing);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seebad1v2", 1);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seebad1v3", 2);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seebad2v1", 1);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seebad2v2", 2);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seebad3v1", 1);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seebad3v2", 2);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seebad4v1", 1);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seebad4v2", 2);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seeswrongact1v1", 1);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seeswrongact1v2", 2);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seeswrongact3v1", 1);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seeswrongact3v2", 2);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seeswrongact4v1", 1);
	Addto(lCop_noticeillegalthing,						"WMaleLawmenDialog.cop_seeswrongact4v2", 2);

	Clear(lnoticedickout);
	Addto(lnoticedickout,							"WMaleLawmenDialog.cop_seeswang1v1", 1);
	Addto(lnoticedickout,							"WMaleLawmenDialog.cop_seeswang1v2", 2);
	Addto(lnoticedickout,							"WMaleLawmenDialog.cop_seeswrongact1v1", 1);
	Addto(lnoticedickout,							"WMaleLawmenDialog.cop_seeswrongact1v2", 2);
	Addto(lnoticedickout,							"WMaleLawmenDialog.cop_seeswrongact3v1", 1);
	Addto(lnoticedickout,							"WMaleLawmenDialog.cop_seeswrongact3v2", 2);

	Clear(lcop_putawaydick1);	
	Addto(lcop_putawaydick1,						"WMaleLawmenDialog.cop_seeswang1v1", 1);
	Addto(lcop_putawaydick1,						"WMaleLawmenDialog.cop_seeswang1v2", 2);
	Addto(lcop_putawaydick1,						"WMaleLawmenDialog.cop_seeswang2v1", 1);
	Addto(lcop_putawaydick1,						"WMaleLawmenDialog.cop_seeswang2v2", 2);
	Addto(lcop_putawaydick1,						"WMaleLawmenDialog.cop_seeswang3v1", 1);
	Addto(lcop_putawaydick1,						"WMaleLawmenDialog.cop_seeswang3v2", 2);
	Addto(lcop_putawaydick1,						"WMaleLawmenDialog.cop_seeswang4v1", 1);
	Addto(lcop_putawaydick1,						"WMaleLawmenDialog.cop_seeswang4v2", 2);

	Clear(lcop_noticelegalgun);
	Addto(lcop_noticelegalgun,						"WMaleLawmenDialog.cop_seeswang4v1", 1);
	Addto(lcop_noticelegalgun,						"WMaleLawmenDialog.cop_seeswang4v2", 2);

	Clear(lcop_noticegaspouring);	
	Addto(lcop_noticegaspouring,						"WMaleLawmenDialog.cop_seeswrongact1v1", 1);
	Addto(lcop_noticegaspouring,						"WMaleLawmenDialog.cop_seeswrongact1v2", 2);
	Addto(lcop_noticegaspouring,						"WMaleLawmenDialog.cop_seeswrongact2v1", 1);
	Addto(lcop_noticegaspouring,						"WMaleLawmenDialog.cop_seeswrongact2v2", 2);
	Addto(lcop_noticegaspouring,						"WMaleLawmenDialog.cop_seeswrongact3v1", 1);
	Addto(lcop_noticegaspouring,						"WMaleLawmenDialog.cop_seeswrongact3v2", 2);
	Addto(lcop_noticegaspouring,						"WMaleLawmenDialog.cop_seeswrongact4v1", 1);
	Addto(lcop_noticegaspouring,						"WMaleLawmenDialog.cop_seeswrongact4v2", 2);

	Clear(lcop_turnaround1);
	Addto(lcop_turnaround1,							"WMaleDialog.wm_cop_youthereturn", 1);
	Addto(lcop_turnaround1,							"WMaleDialog.wm_cop_ineedtotalkto", 1);

	Clear(lcop_turnaround2);	
	Addto(lcop_turnaround2,							"WMaleDialog.wm_cop_turnaroundand", 1);

	Clear(lcop_callforbackup);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup1v1", 1);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup1v2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup2v1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup2v2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup3v1", 1);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup3v2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup4v1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup4v2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup5v1", 1);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup5v2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup6v1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup6v2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup7v1", 1);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup7v2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup8v1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_backup8v2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_damage_covermev1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_damage_covermev2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_seesdeadcop_copkillerv1", 1);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_seesdeadcop_copkillerv2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_diev1", 1);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_diev2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_eatitv1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_eatitv2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_eatleadv1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_eatleadv2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_eatleadv3", 3);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_eatleadv4", 3);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_fuckyouv1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_fuckyouv2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_goingdownv1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_goingdownv2", 2);
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_suckjusticev1", 1);	
	Addto(lcop_callforbackup,						"WMaleLawmenDialog.cop_attacking_suckjusticev2", 2);

	Clear(ldying);
	Addto(ldying,									"WMaleDialog.wm_icantfeelmylegs", 1);
	Addto(ldying,									"WMaleDialog.wm_deathcrawl1", 1);
	Addto(ldying,									"WMaleDialog.wm_deathcrawl2", 1);
	Addto(ldying,									"WMaleDialog.wm_deathcrawl3", 1);
	Addto(ldying,									"WMaleDialog.wm_icantbreathe", 1);
	Addto(ldying,									"WMaleDialog.wm_somebodypleasemake", 1);
	Addto(ldying,									"WMaleDialog.wm_godithurts", 1);
	Addto(ldying,									"WMaleDialog.wm_ohgod", 1);
	Addto(ldying,									"WMaleDialog.wm_justfinishit", 1);
	Addto(ldying,									"WMaleLawmenDialog.cop_damage_officerdownv1", 1);
	Addto(ldying,									"WMaleLawmenDialog.cop_damage_officerdownv2", 2);

	Clear(lcop_whofiredweapon);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate1V1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate1v2", 2);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate2V1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate2v2", 2);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate3V1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate3v2", 2);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate4v1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate4v2", 2);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate4v3", 3);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate5v1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate5v2", 2);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate6v1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate6v2", 2);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate7v1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate7v2", 2);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate8v1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate8v2", 2);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate9v1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate9v2", 2);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate10v1", 1);
	Addto(lcop_whofiredweapon,						"WMaleLawmenDialog.cop_investigate10v2", 2);

	Clear(lcop_surprisesomeone);
	Addto(lcop_surprisesomeone,						"WMaleDialog.wm_cop_aha", 1);

	Clear(lcop_disappointment);				
	Addto(lcop_disappointment,						"WMaleDialog.wm_cop_hmmph", 1);
	Addto(lcop_disappointment,						"WMaleDialog.wm_cop_shit", 1);
	Addto(lcop_disappointment,						"WMaleDialog.wm_cop_wrongguy", 1);

	Clear(lcop_nevermind);
	Addto(lcop_nevermind,							"WMaleDialog.wm_cop_nevermind", 1);
	Addto(lcop_nevermind,							"WMaleDialog.wm_cop_youreclean", 1);

	Clear(lcop_whoshotme);
	Addto(lcop_whoshotme,							"WMaleLawmenDialog.cop_whoshotme1v1", 1);
	Addto(lcop_whoshotme,							"WMaleLawmenDialog.cop_whoshotme1v2", 2);
	Addto(lcop_whoshotme,							"WMaleLawmenDialog.cop_whoshotme2v1", 1);
	Addto(lcop_whoshotme,							"WMaleLawmenDialog.cop_whoshotme2v2", 2);
	Addto(lcop_whoshotme,							"WMaleLawmenDialog.cop_whoshotme2v3", 3);
	Addto(lcop_whoshotme,							"WMaleLawmenDialog.cop_whoshotme3v1", 1);
	Addto(lcop_whoshotme,							"WMaleLawmenDialog.cop_whoshotme3v2", 2);

	Clear(lcop_freeze1);
	Addto(lcop_freeze1,							"WMaleLawmenDialog.cop_freeze1v1", 1);	
	Addto(lcop_freeze1,							"WMaleLawmenDialog.cop_freeze1v2", 2);
	Addto(lcop_freeze1,							"WMaleLawmenDialog.cop_freeze2v1", 1);
	Addto(lcop_freeze1,							"WMaleLawmenDialog.cop_freeze2v2", 2);	
	Addto(lcop_freeze1,							"WMaleLawmenDialog.cop_freeze3v1", 1);
	Addto(lcop_freeze1,							"WMaleLawmenDialog.cop_freeze3v2", 2);

	Clear(lcop_putdownweapon1);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_seeweapon1v1", 1);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_seeweapon1v2", 2);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_seeweapon2v1", 1);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_seeweapon2v2", 2);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_seeweapon3v1", 1);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_seeweapon3v2", 2);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_seeweapon3v3", 3);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_dropweapon1v1", 1);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_dropweapon1v2", 2);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_dropweapon2v1", 1);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_dropweapon2v2", 2);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_dropweapon3v1", 1);
	Addto(lcop_putdownweapon1,						"WMaleLawmenDialog.cop_dropweapon3v2", 2);

	Clear(lcop_underarrest);
	Addto(lcop_underarrest,							"WMaleLawmenDialog.cop_arrest1V1", 1);
	Addto(lcop_underarrest,							"WMaleLawmenDialog.cop_arrest1v2", 2);
	Addto(lcop_underarrest,							"WMaleLawmenDialog.cop_arrest2V1", 1);
	Addto(lcop_underarrest,							"WMaleLawmenDialog.cop_arrest2v2", 2);

	Clear(lcop_holdstill);
	Addto(lcop_holdstill,							"WMaleLawmenDialog.cop_arrest3V1", 1);
	Addto(lcop_holdstill,							"WMaleLawmenDialog.cop_arrest3v2", 2);
	//Addto(lcop_holdstill,							"WMaleLawmenDialog.cop_arrest5V1", 1);
	//Addto(lcop_holdstill,							"WMaleLawmenDialog.cop_arrest5v2", 2);

	Clear(lCop_CopOuttaLine);
	Addto(lCop_CopOuttaLine,					"WMaleLawmenDialog.cop_warnplayer1v1", 1);
	Addto(lCop_CopOuttaLine,					"WMaleLawmenDialog.cop_warnplayer1v2", 2);
	Addto(lCop_CopOuttaLine,					"WMaleLawmenDialog.cop_warnplayer2v1", 1);
	Addto(lCop_CopOuttaLine,					"WMaleLawmenDialog.cop_warnplayer2v2", 2);
	Addto(lCop_CopOuttaLine,					"WMaleLawmenDialog.cop_warnplayer3v1", 1);
	Addto(lCop_CopOuttaLine,					"WMaleLawmenDialog.cop_warnplayer3v2", 2);
	Addto(lCop_CopOuttaLine,					"WMaleLawmenDialog.cop_friendlyfire1v1", 1);
	Addto(lCop_CopOuttaLine,					"WMaleLawmenDialog.cop_friendlyfire1v2", 2);

	Clear(lcop_Miranda);
	Addto(lcop_Miranda,							"WMaleLawmenDialog.cop_miranda_shortfunnyv1", 1);
	Addto(lcop_Miranda,							"WMaleLawmenDialog.cop_miranda_shortfunnyv2", 2);
	Addto(lcop_Miranda,							"WMaleLawmenDialog.cop_miranda_shortv1", 1);
	Addto(lcop_Miranda,							"WMaleLawmenDialog.cop_miranda_shortv2", 2);
	//Addto(lcop_Miranda,							"WMaleLawmenDialog.cop_miranda_longv1", 1);
	//Addto(lcop_Miranda,							"WMaleLawmenDialog.cop_miranda_longv2", 2);

	// PIII cops are missing this line, but it actually works pretty well just leaving it blank. Cowboys
	// don't have "suspects", after all.
	Clear(lcop_SuspectSighted);
	
	Clear(lcop_RadioBack);
	Addto(lcop_RadioBack,						"WMaleDialog.wm_cop_roger", 1);
	Addto(lcop_RadioBack,						"WMaleDialog.wm_cop_rogerthatill", 1);
	Addto(lcop_RadioBack,						"WMaleDialog.wm_cop_uhillhaveto", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     VolumeMult=0.900000
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
