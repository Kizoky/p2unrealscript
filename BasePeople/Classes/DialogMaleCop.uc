///////////////////////////////////////////////////////////////////////////////
// DialogMaleCop
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for Male Cop
//
//	History:
//		02/07/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class DialogMaleCop extends DialogMale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,						"WMaleDialog.wm_creep", 1);
	Addto(lrespondtohotgreeting,						"WMaleDialog.wm_ugh", 1);
	Addto(lrespondtohotgreeting,						"WMaleDialog.wm_loser", 1);
	Addto(lrespondtohotgreeting,						"WMaleDialog.wm_moron", 1);

	Clear(lGetDown);
	AddTo(lGetDown,							"WMaleDialog.wm_cop_getdown", 1);
	AddTo(lGetDown,							"WMaleDialog.wm_cop_getontheground", 1);
	AddTo(lGetDown,							"WMaleDialog.wm_cop_getthefuck", 1);
	AddTo(lGetDown,							"WMaleDialog.wm_cop_getdownor", 2);
	AddTo(lGetDown,							"WMaleDialog.wm_cop_isaidgetdown", 2);
	
	Clear(lcop_nothingtosee);
	AddTo(lcop_nothingtosee,						"WMaleDialog.wm_cop_nothingtosee", 1);
	AddTo(lcop_nothingtosee,						"WMaleDialog.wm_cop_movealong", 1);
	AddTo(lcop_nothingtosee,						"WMaleDialog.wm_cop_moveit", 1);
	
	CLear(lCleanShot);
	AddTo(lCleanShot,							"WMaleDialog.wm_cop_getouttathe", 1);	
	AddTo(lCleanShot,							"WMaleDialog.wm_cop_imgoingto", 1);
	AddTo(lCleanShot,							"WMaleDialog.wm_cop_givemeaclear", 1);
	AddTo(lCleanShot,							"WMaleDialog.wm_cop_clearmyline", 2);

	CLear(lCleanMeleeHit);
	AddTo(lCleanMeleeHit,						"WMaleDialog.wm_cop_getouttathe", 1);	
	AddTo(lCleanMeleeHit,						"WMaleDialog.wm_cop_clearmyline", 1);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"WMaleDialog.wm_heywhoreyou", 1);
	Addto(linvadeshome,							"WMaleDialog.wm_whatareyoudoing", 2);
	Addto(linvadeshome,							"WMaleDialog.wm_getoutyoufreak", 2);
	Addto(linvadeshome,							"WMaleDialog.wm_getthehelloutofmy", 3);
	Addto(linvadeshome,							"WMaleDialog.wm_getoutnow", 3);

	CLear(lGotHit);
	AddTo(lGotHit,								"WMaleDialog.wm_cop_aah", 1);	
	AddTo(lGotHit,								"WMaleDialog.wm_cop_imhit", 1);					
	AddTo(lGotHit,								"WMaleDialog.wm_cop_argh", 1);
	AddTo(lGotHit,								"WMaleDialog.wm_cop_fuck", 1);

	CLear(lcop_someonedisobeyed);
	AddTo(lcop_someonedisobeyed,						"WMaleDialog.wm_cop_wrongmove", 1);
	AddTo(lcop_someonedisobeyed,						"WMaleDialog.wm_cop_youllregret", 1);
	AddTo(lcop_someonedisobeyed,						"WMaleDialog.wm_cop_youjustsigned", 1);

	CLear(lCop_GoingToInvestigate);
	AddTo(lCop_GoingToInvestigate,						"WMaleDialog.wm_cop_staycalmill", 1);
	AddTo(lCop_GoingToInvestigate,						"WMaleDialog.wm_cop_illgocheck", 1);
	AddTo(lCop_GoingToInvestigate,						"WMaleDialog.wm_cop_imonit", 2);

	CLear(laftergettingpissedon);
	Addto(laftergettingpissedon,						"WMaleDialog.wm_cop_jesus", 1);
	Addto(laftergettingpissedon,						"WMaleDialog.wm_cop_yeeuggh", 1);
	Addto(laftergettingpissedon,						"WMaleDialog.wm_cop_yousickbastard", 2);
	Addto(laftergettingpissedon,						"WMaleDialog.wm_cop_ohthatsit", 2);

	CLear(lCop_noticeillegalthing);
	Addto(lCop_noticeillegalthing,						"WMaleDialog.wm_cop_wellwellwhat", 1);
	Addto(lCop_noticeillegalthing,						"WMaleDialog.wm_cop_ohnoiamnot", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,							"WMaleDialog.wm_cop_okaythisoughta", 1);
	Addto(lnoticedickout,							"WMaleDialog.wm_cop_heymisterpeep", 1);

	Clear(lcop_putawaydick1);	
	Addto(lcop_putawaydick1,						"WMaleDialog.wm_cop_pullyourpants", 1);
	Addto(lcop_putawaydick1,						"WMaleDialog.wm_cop_zipyourpants", 1);
	Addto(lcop_putawaydick1,						"WMaleDialog.wm_cop_putthatthing", 2);	

	Clear(lcop_noticelegalgun);
	Addto(lcop_noticelegalgun,						"WMaleDialog.wm_cop_hopeyouhave", 1);
	Addto(lcop_noticelegalgun,						"WMaleDialog.wm_cop_justwatchwhere", 1);
	Addto(lcop_noticelegalgun,						"WMaleDialog.wm_cop_itsprobablynot", 2);

	Clear(lcop_noticegaspouring);	
	Addto(lcop_noticegaspouring,						"WMaleDialog.wm_cop_heywhatdoyou", 1);
	Addto(lcop_noticegaspouring,						"WMaleDialog.wm_cop_heyyoucantdo", 1);
	Addto(lcop_noticegaspouring,						"WMaleDialog.wm_cop_whoaholdup", 2);

	Clear(lcop_turnaround1);
	Addto(lcop_turnaround1,							"WMaleDialog.wm_cop_youthereturn", 1);
	Addto(lcop_turnaround1,							"WMaleDialog.wm_cop_ineedtotalkto", 1);

	Clear(lcop_turnaround2);	
	Addto(lcop_turnaround2,							"WMaleDialog.wm_cop_turnaroundand", 1);

	Clear(lcop_callforbackup);
	Addto(lcop_callforbackup,						"WMaleDialog.wm_cop_ineedbackup", 1);
	Addto(lcop_callforbackup,						"WMaleDialog.wm_cop_sendmebackup", 1);
	Addto(lcop_callforbackup,						"WMaleDialog.wm_cop_wevegotasit", 1);	
	Addto(lcop_callforbackup,						"WMaleDialog.wm_cop_shotsfired", 2);

	// Inherit those from male
	Addto(ldying,									"WMaleDialog.wm_cop_officerdown", 1);

	Clear(lcop_whofiredweapon);
	Addto(lcop_whofiredweapon,						"WMaleDialog.wm_cop_whojustfired", 1);
	Addto(lcop_whofiredweapon,						"WMaleDialog.wm_cop_isupposenobody", 1);
	Addto(lcop_whofiredweapon,						"WMaleDialog.wm_cop_somebodymust", 2);
	Addto(lcop_whofiredweapon,						"WMaleDialog.wm_cop_anyoneseewhat", 2);

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
	Addto(lcop_whoshotme,							"WMaleDialog.wm_cop_whojustshotme", 1);
	Addto(lcop_whoshotme,							"WMaleDialog.wm_cop_tellmewhojust", 2);
	Addto(lcop_whoshotme,							"WMaleDialog.wm_cop_didyousee", 2);

	Clear(lcop_freeze1);
	Addto(lcop_freeze1,							"WMaleDialog.wm_cop_freeze", 1);	
	Addto(lcop_freeze1,							"WMaleDialog.wm_cop_stoprightthere", 1);
	Addto(lcop_freeze1,							"WMaleDialog.wm_cop_stoporill", 1);							

	Clear(lcop_putdownweapon1);
	Addto(lcop_putdownweapon1,						"WMaleDialog.wm_cop_putyourweapon", 1);
	Addto(lcop_putdownweapon1,						"WMaleDialog.wm_cop_dropyourweapon", 1);
	Addto(lcop_putdownweapon1,						"WMaleDialog.wm_cop_dropitasshole", 1);

	Clear(lcop_underarrest);
	Addto(lcop_underarrest,							"WMaleDialog.wm_cop_youreunder", 1);
	Addto(lcop_underarrest,							"WMaleDialog.wm_cop_okayyourecome", 1);
	Addto(lcop_underarrest,							"WMaleDialog.wm_cop_thatsityoure", 1);

	Clear(lcop_holdstill);
	Addto(lcop_holdstill,							"WMaleDialog.wm_cop_nowjusthold", 1);
	Addto(lcop_holdstill,							"WMaleDialog.wm_cop_imgoingtohave", 1);

	Clear(lCop_CopOuttaLine);
	Addto(lCop_CopOuttaLine,					"WMaleDialog.wm_cop_whoaheyman", 1);
	Addto(lCop_CopOuttaLine,					"WMaleDialog.wm_cop_heyitsnotworth", 1);
	Addto(lCop_CopOuttaLine,					"WMaleDialog.wm_cop_heystopman", 2);
	Addto(lCop_CopOuttaLine,					"WMaleDialog.wm_cop_cmonstop", 2);

	Clear(lcop_Miranda);
	Addto(lcop_Miranda,							"WMaleDialog.wm_cop_miranda", 1);

	Clear(lcop_SuspectSighted);
	Addto(lcop_SuspectSighted,					"WMaleDialog.wm_cop_suspectsighted", 1);
	Addto(lcop_SuspectSighted,					"WMaleDialog.wm_cop_ivegottheperp", 1);
	Addto(lcop_SuspectSighted,					"WMaleDialog.wm_cop_gotthescumbag", 1);
	
	Clear(lcop_RadioBack);
	Addto(lcop_RadioBack,						"WMaleDialog.wm_cop_roger", 1);
	Addto(lcop_RadioBack,						"WMaleDialog.wm_cop_rogerthatill", 1);
	Addto(lcop_RadioBack,						"WMaleDialog.wm_cop_uhillhaveto", 2);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
