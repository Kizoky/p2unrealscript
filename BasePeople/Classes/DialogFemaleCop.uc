///////////////////////////////////////////////////////////////////////////////
// DialogFemaleCop
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for Female Cop
//
//	History:
//		02/07/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class DialogFemaleCop extends DialogFemale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,						"WFemaleDialog.wf_creep", 1);
	Addto(lrespondtohotgreeting,						"WFemaleDialog.wf_ugh", 1);
	Addto(lrespondtohotgreeting,						"WFemaleDialog.wf_loser", 1);
	Addto(lrespondtohotgreeting,						"WFemaleDialog.wf_moron", 1);

	Clear(lGetDown);
	AddTo(lGetDown,							"WFemaleDialog.wf_cop_getdown", 1);
	AddTo(lGetDown,							"WFemaleDialog.wf_cop_getontheground", 1);
	AddTo(lGetDown,							"WFemaleDialog.wf_cop_getthefuck", 1);
	AddTo(lGetDown,							"WFemaleDialog.wf_cop_getdownor", 2);
	AddTo(lGetDown,							"WFemaleDialog.wf_cop_isaidgetdown", 2);
	
	Clear(lGetDownMP);
	AddTo(lGetDownMP,						"WFemaleDialog.wf_cop_getdown", 1);
	AddTo(lGetDownMP,						"WFemaleDialog.wf_cop_getontheground", 1);
	AddTo(lGetDownMP,						"WFemaleDialog.wf_cop_getthefuck", 1);
	AddTo(lGetDownMP,						"WFemaleDialog.wf_cop_getdownor", 2);
	AddTo(lGetDownMP,						"WFemaleDialog.wf_cop_isaidgetdown", 2);
	
	Clear(lcop_nothingtosee);
	AddTo(lcop_nothingtosee,						"WFemaleDialog.wf_cop_nothingtosee", 1);
	AddTo(lcop_nothingtosee,						"WFemaleDialog.wf_cop_movealong", 1);
	AddTo(lcop_nothingtosee,						"WFemaleDialog.wf_cop_moveit", 1);
	
	CLear(lCleanShot);
	AddTo(lCleanShot,							"WFemaleDialog.wf_cop_getouttathe", 1);	
	AddTo(lCleanShot,							"WFemaleDialog.wf_cop_imgoingto", 1);
	AddTo(lCleanShot,							"WFemaleDialog.wf_cop_givemeaclear", 1);
	AddTo(lCleanShot,							"WFemaleDialog.wf_cop_clearmyline", 2);

	CLear(lCleanMeleeHit);
	AddTo(lCleanMeleeHit,						"WFemaleDialog.wf_cop_getouttathe", 1);	
	AddTo(lCleanMeleeHit,						"WFemaleDialog.wf_cop_clearmyline", 1);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"WFemaleDialog.wf_heywhoreyou", 1);
	Addto(linvadeshome,							"WFemaleDialog.wf_whatareyoudoing", 2);
	Addto(linvadeshome,							"WFemaleDialog.wf_getoutyoufreak", 2);
	Addto(linvadeshome,							"WFemaleDialog.wf_getthehelloutofmy", 3);
	Addto(linvadeshome,							"WFemaleDialog.wf_getoutnow", 3);
	
	CLear(lGotHit);
	AddTo(lGotHit,								"WFemaleDialog.wf_cop_aah", 1);	
	AddTo(lGotHit,								"WFemaleDialog.wf_cop_imhit", 1);					
	AddTo(lGotHit,								"WFemaleDialog.wf_cop_argh", 1);
	AddTo(lGotHit,								"WFemaleDialog.wf_cop_fuck", 1);

	CLear(lcop_someonedisobeyed);
	AddTo(lcop_someonedisobeyed,						"WFemaleDialog.wf_cop_wrongmove", 1);
	AddTo(lcop_someonedisobeyed,						"WFemaleDialog.wf_cop_youllregret", 1);
	AddTo(lcop_someonedisobeyed,						"WFemaleDialog.wf_cop_youjustsigned", 1);

	CLear(lCop_GoingToInvestigate);
	AddTo(lCop_GoingToInvestigate,						"WFemaleDialog.wf_cop_staycalmill", 1);
	AddTo(lCop_GoingToInvestigate,						"WFemaleDialog.wf_cop_illgocheck", 1);
	AddTo(lCop_GoingToInvestigate,						"WFemaleDialog.wf_cop_imonit", 2);

	CLear(laftergettingpissedon);
	Addto(laftergettingpissedon,						"WFemaleDialog.wf_cop_jesus", 1);
	Addto(laftergettingpissedon,						"WFemaleDialog.wf_cop_yeeuggh", 1);
	Addto(laftergettingpissedon,						"WFemaleDialog.wf_cop_yousickbastard", 2);
	Addto(laftergettingpissedon,						"WFemaleDialog.wf_cop_ohthatsit", 2);

	CLear(lCop_noticeillegalthing);
	Addto(lCop_noticeillegalthing,						"WFemaleDialog.wf_cop_wellwellwhat", 1);
	Addto(lCop_noticeillegalthing,						"WFemaleDialog.wf_cop_ohnoiamnot", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,							"WFemaleDialog.wf_cop_okaythisoughta", 1);
	Addto(lnoticedickout,							"WFemaleDialog.wf_cop_heymisterpeep", 1);

	Clear(lcop_putawaydick1);	
	Addto(lcop_putawaydick1,						"WFemaleDialog.wf_cop_pullyourpants", 1);
	Addto(lcop_putawaydick1,						"WFemaleDialog.wf_cop_zipyourpants", 1);
	Addto(lcop_putawaydick1,						"WFemaleDialog.wf_cop_putthatthing", 2);	

	Clear(lcop_noticelegalgun);
	Addto(lcop_noticelegalgun,						"WFemaleDialog.wf_cop_hopeyouhave", 1);
	Addto(lcop_noticelegalgun,						"WFemaleDialog.wf_cop_justwatchwhere", 1);
	Addto(lcop_noticelegalgun,						"WFemaleDialog.wf_cop_itsprobablynot", 2);

	Clear(lcop_noticegaspouring);	
	Addto(lcop_noticegaspouring,						"WFemaleDialog.wf_cop_heywhatdoyou", 1);
	Addto(lcop_noticegaspouring,						"WFemaleDialog.wf_cop_heyyoucantdo", 1);
	Addto(lcop_noticegaspouring,						"WFemaleDialog.wf_cop_whoaholdup", 2);

	Clear(lcop_turnaround1);
	Addto(lcop_turnaround1,							"WFemaleDialog.wf_cop_youthereturn", 1);
	Addto(lcop_turnaround1,							"WFemaleDialog.wf_cop_ineedtotalkto", 1);

	Clear(lcop_turnaround2);	
	Addto(lcop_turnaround2,							"WFemaleDialog.wf_cop_turnaroundand", 1);

	Clear(lcop_callforbackup);
	Addto(lcop_callforbackup,						"WFemaleDialog.wf_cop_ineedbackup", 1);
	Addto(lcop_callforbackup,						"WFemaleDialog.wf_cop_sendmebackup", 1);
	Addto(lcop_callforbackup,						"WFemaleDialog.wf_cop_wevegotasit", 1);	
	Addto(lcop_callforbackup,						"WFemaleDialog.wf_cop_shotsfired", 2);

	// Inherit those from female
	Addto(ldying,								"WFemaleDialog.wf_cop_officerdown", 1);

	Clear(lcop_whofiredweapon);
	Addto(lcop_whofiredweapon,						"WFemaleDialog.wf_cop_whojustfired", 1);
	Addto(lcop_whofiredweapon,						"WFemaleDialog.wf_cop_isupposenobody", 1);
	Addto(lcop_whofiredweapon,						"WFemaleDialog.wf_cop_somebodymust", 2);
	Addto(lcop_whofiredweapon,						"WFemaleDialog.wf_cop_anyoneseewhat", 2);

	Clear(lcop_surprisesomeone);
	Addto(lcop_surprisesomeone,						"WFemaleDialog.wf_cop_aha", 1);

	Clear(lcop_disappointment);				
	Addto(lcop_disappointment,						"WFemaleDialog.wf_cop_hmmph", 1);
	Addto(lcop_disappointment,						"WFemaleDialog.wf_cop_shit", 1);
	Addto(lcop_disappointment,						"WFemaleDialog.wf_cop_wrongguy", 1);

	Clear(lcop_nevermind);
	Addto(lcop_nevermind,							"WFemaleDialog.wf_cop_nevermind", 1);
	Addto(lcop_nevermind,							"WFemaleDialog.wf_cop_youreclean", 1);

	Clear(lcop_whoshotme);
	Addto(lcop_whoshotme,							"WFemaleDialog.wf_cop_whojustshotme", 1);
	Addto(lcop_whoshotme,							"WFemaleDialog.wf_cop_tellmewhojust", 2);
	Addto(lcop_whoshotme,							"WFemaleDialog.wf_cop_didyousee", 2);

	Clear(lcop_freeze1);
	Addto(lcop_freeze1,							"WFemaleDialog.wf_cop_freeze", 1);	
	Addto(lcop_freeze1,							"WFemaleDialog.wf_cop_stoprightthere", 1);
	Addto(lcop_freeze1,							"WFemaleDialog.wf_cop_stoporill", 1);							

	Clear(lcop_putdownweapon1);
	Addto(lcop_putdownweapon1,						"WFemaleDialog.wf_cop_putyourweapon", 1);
	Addto(lcop_putdownweapon1,						"WFemaleDialog.wf_cop_dropyourweapon", 1);
	Addto(lcop_putdownweapon1,						"WFemaleDialog.wf_cop_dropitasshole", 1);

	Clear(lcop_underarrest);
	Addto(lcop_underarrest,							"WFemaleDialog.wf_cop_youreunder", 1);
	Addto(lcop_underarrest,							"WFemaleDialog.wf_cop_okayyourecome", 1);
	Addto(lcop_underarrest,							"WFemaleDialog.wf_cop_thatsityoure", 1);

	Clear(lcop_holdstill);
	Addto(lcop_holdstill,							"WFemaleDialog.wf_cop_nowjusthold", 1);
	Addto(lcop_holdstill,							"WFemaleDialog.wf_cop_imgoingtohave", 1);

	Clear(lCop_CopOuttaLine);
	Addto(lCop_CopOuttaLine,					"WFemaleDialog.wf_cop_whoaheyman", 1);
	Addto(lCop_CopOuttaLine,					"WFemaleDialog.wf_cop_heyitsnotworth", 1);
	Addto(lCop_CopOuttaLine,					"WFemaleDialog.wf_cop_heystopman", 2);
	Addto(lCop_CopOuttaLine,					"WFemaleDialog.wf_cop_cmonstop", 2);

	Clear(lcop_Miranda);
	Addto(lcop_Miranda,							"WFemaleDialog.wf_cop_miranda", 1);

	Clear(lcop_SuspectSighted);
	Addto(lcop_SuspectSighted,					"WFemaleDialog.wf_cop_suspectsighted", 1);
	Addto(lcop_SuspectSighted,					"WFemaleDialog.wf_cop_ivegottheperp", 1);
	Addto(lcop_SuspectSighted,					"WFemaleDialog.wf_cop_gotthescumbag", 1);
	
	Clear(lcop_RadioBack);
	Addto(lcop_RadioBack,						"WFemaleDialog.wf_cop_roger", 1);
	Addto(lcop_RadioBack,						"WFemaleDialog.wf_cop_rogerthatill", 1);
	Addto(lcop_RadioBack,						"WFemaleDialog.wf_cop_uhillhaveto", 2);
	}

	
///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
