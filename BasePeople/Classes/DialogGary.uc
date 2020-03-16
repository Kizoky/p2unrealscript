///////////////////////////////////////////////////////////////////////////////
// DialogGary
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for Gary Coleman
//
///////////////////////////////////////////////////////////////////////////////
class DialogGary extends DialogGeneric;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lgreeting);
	Addto(lgreeting,							"GaryDialog.gary_hello", 1);
	Addto(lgreeting,							"GaryDialog.gary_hi", 1);
	Addto(lGreeting,							"GaryDialog.gary_hey", 1);

	Clear(lGetDownMP);
	Addto(lGetDownMP,							"GaryDialog.gary_fuckyou", 1);
	Addto(lGetDownMP,							"GaryDialog.gary_whatchutalkin", 1);
	addto(lGetDownMP,							"GaryDialog.gary_youbitch", 1);	
	Addto(lGetDownMP, 							"GaryDialog.gary_igotyerwillis", 1);

	Clear(lFollowMe);
	Addto(lFollowMe,							"GaryDialog.gary_hey", 1);

	Clear(lStayHere);
	Addto(lStayHere,							"GaryDialog.gary_hereyougo", 1);

	Clear(lnextinline);
	Addto(lnextinline,							"GaryDialog.gary_next", 1);
	
	Clear(lhelpyouoverhere);
	Addto(lhelpyouoverhere,						"GaryDialog.gary_next", 1);

	Clear(lsomeonecuts);
	Addto(lsomeonecuts,							"GaryDialog.gary_next", 1);
	Addto(lsomeonecuts, 						"GaryDialog.gary_whatiswrong", 1);

	Clear(lpleasemoveforward);
	Addto(lpleasemoveforward,					"GaryDialog.gary_next", 1);

	Clear(lcanihelpyou);
	Addto(lcanihelpyou,							"GaryDialog.gary_next", 1);

	clear(lGary_ResponseToIdiots);
	Addto(lGary_ResponseToIdiots, 				"GaryDialog.gary_fuckyou", 1);
	Addto(lGary_ResponseToIdiots, 				"GaryDialog.gary_saywhat", 1);
	Addto(lGary_ResponseToIdiots, 				"GaryDialog.gary_whatiswrong", 1);
												
	Clear(lgetbumped);
	Addto(lgetbumped, 							"GaryDialog.gary_fuckyou", 1);
	Addto(lgetbumped, 							"GaryDialog.gary_saywhat", 1);
	Addto(lgetbumped, 							"GaryDialog.gary_whatchutalkin", 1);
	Addto(lgetbumped, 							"GaryDialog.gary_whatiswrong", 1);

	Clear(lGetMad);
	Addto(lGetMad,								"GaryDialog.gary_fuckyou", 1);
	Addto(lGetMad,								"GaryDialog.gary_saywhat", 1);
	Addto(lGetMad,								"GaryDialog.gary_whatchutalkin", 1);
	addto(lGetMad,								"GaryDialog.gary_whatiswrong", 1);

	clear(lGary_GivingAutographToDude);
	Addto(lGary_GivingAutographToDude, 			"GaryDialog.gary_yeahsureitis", 1);

	clear(lGary_GivingAutograph);
	Addto(lGary_GivingAutograph, 				"GaryDialog.gary_hereyougo", 1);
	Addto(lGary_GivingAutograph, 				"GaryDialog.gary_thanksleavenow", 1);
	Addto(lGary_GivingAutograph, 				"GaryDialog.gary_areyoustillhere", 1);
	Addto(lGary_GivingAutograph, 				"GaryDialog.gary_yourecoolgoaway", 1);
												
	Clear(lSignPetition);							
	Addto(lSignPetition,	 					"GaryDialog.gary_hereyougo", 1);
	Addto(lSignPetition, 						"GaryDialog.gary_thanksleavenow", 1);
	Addto(lSignPetition, 						"GaryDialog.gary_areyoustillhere", 1);
	Addto(lSignPetition, 						"GaryDialog.gary_yourecoolgoaway", 1);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,					"GaryDialog.gary_fuckyou", 1);
	Addto(lDontSignPetition,					"GaryDialog.gary_saywhat", 1);
	Addto(lDontSignPetition,					"GaryDialog.gary_whatchutalkin", 1);
	Addto(lDontSignPetition,					"GaryDialog.gary_whatiswrong", 1);

	Clear(lPetitionBother);
	Addto(lPetitionBother,						"GaryDialog.gary_fuckyou", 1);
	Addto(lPetitionBother,						"GaryDialog.gary_saywhat", 1);
	Addto(lPetitionBother,						"GaryDialog.gary_whatchutalkin", 1);
	Addto(lPetitionBother,						"GaryDialog.gary_whatiswrong", 1);

	Clear(lthanks);
	Addto(lthanks,				 				"GaryDialog.gary_thanksleavenow", 1);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"GaryDialog.gary_bwahahaha", 1);

	clear(lGary_ToCops);				
	Addto(lGary_ToCops, 						"GaryDialog.gary_imnotgoingback", 1);
	Addto(lGary_ToCops, 						"GaryDialog.gary_theycankissmy", 1);
	Addto(lGary_ToCops, 						"GaryDialog.gary_idontthinkthey", 1);
	Addto(lGary_ToCops, 						"GaryDialog.gary_gobacktodonut", 1);
												
	clear(lGary_NonViolent);			
	Addto(lGary_NonViolent, 					"GaryDialog.gary_youneedsun", 1);
	Addto(lGary_NonViolent, 					"GaryDialog.gary_ifiseeonebay", 1);
												
	Clear(llaughing);
	Addto(llaughing,							"GaryDialog.gary_bwahahaha", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"GaryDialog.gary_aahputmeout", 1);
	Addto(lscreamingonfire,						"GaryDialog.gary_firescream", 1);

	Clear(lsomeoneonfire);
	addto(lsomeoneonfire,						"GaryDialog.gary_shit", 1);	

	Clear(lgothit);
	addto(lgothit,								"GaryDialog.gary_gak", 1);	
	addto(lgothit,								"GaryDialog.gary_gurgle", 1);	
	addto(lgothit,								"GaryDialog.gary_ak", 1);	
	addto(lgothit,								"GaryDialog.gary_ow", 1);	
	addto(lgothit,								"GaryDialog.gary_shit", 1);	
	addto(lgothit,								"GaryDialog.gary_youbitch", 1);	
	addto(lgothit,								"GaryDialog.gary_argh", 1);	
	addto(lgothit,								"GaryDialog.gary_aaah", 1);	

	Clear(lAttacked);
	addto(lAttacked,								"GaryDialog.gary_gak", 1);	
	addto(lAttacked,								"GaryDialog.gary_gurgle", 1);	
	addto(lAttacked,								"GaryDialog.gary_ak", 1);	
	addto(lAttacked,								"GaryDialog.gary_ow", 1);	
	addto(lAttacked,								"GaryDialog.gary_shit", 1);	
	addto(lAttacked,								"GaryDialog.gary_youbitch", 1);	
	addto(lAttacked,								"GaryDialog.gary_argh", 1);	
	addto(lAttacked,								"GaryDialog.gary_aaah", 1);	

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"GaryDialog.gary_choke", 1);	

	Clear(lGrunt);
	addto(lGrunt,								"GaryDialog.gary_gak", 1);	
	addto(lGrunt,								"GaryDialog.gary_gurgle", 1);	
	addto(lGrunt,								"GaryDialog.gary_choke", 1);	
	addto(lGrunt,								"GaryDialog.gary_ak", 1);	
	addto(lGrunt,								"GaryDialog.gary_ow", 1);	
	addto(lGrunt,								"GaryDialog.gary_argh", 1);	
	addto(lGrunt,								"GaryDialog.gary_aaah", 1);	

	Clear(lCussing);
	addto(lCussing,								"GaryDialog.gary_shit", 1);	
	addto(lCussing,								"GaryDialog.gary_youbitch", 1);	
	addto(lCussing,								"GaryDialog.gary_fuck", 1);	

	// no pissing talking
	//Clear(lPissing);

	Clear(lPissOnSelf);
	Addto(lPissOnSelf,							"GaryDialog.gary_gurgle", 1);
	
	// no pissing myself out talking
	//Clear(lPissOutFireOnSelf);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,					"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lGotHealth);
	Addto(lGotHealth,							"GaryDialog.gary_bwahahaha", 1);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,						"GaryDialog.gary_bwahahaha", 1);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth, 						"GaryDialog.gary_ohmanthisisgreat", 1);

	Clear(lseeingpisser);
	Addto(lseeingpisser,						"GaryDialog.gary_youneedsun", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,						"GaryDialog.gary_youneedsun", 1);

	Clear(lSomethingIsGross);
	addto(lSomethingIsGross,					"GaryDialog.gary_shit", 1);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"GaryDialog.gary_ohnoyouarenot", 1);
	Addto(ltrashtalk,							"GaryDialog.gary_youaintreadyfor", 1);
	Addto(ltrashtalk,							"GaryDialog.gary_dontyouknowwho", 1);
	Addto(ltrashtalk,							"GaryDialog.gary_bringiton", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"GaryDialog.gary_ohnoyouarenot", 1);
	Addto(ldecidetofight,						"GaryDialog.gary_youaintreadyfor", 1);
	Addto(ldecidetofight,						"GaryDialog.gary_dontyouknowwho", 1);
	Addto(ldecidetofight,						"GaryDialog.gary_bringiton", 1);

	Clear(lDoHeroics);
	Addto(lDoHeroics,							"GaryDialog.gary_ohnoyouarenot", 1);
	Addto(lDoHeroics,							"GaryDialog.gary_youaintreadyfor", 1);
	Addto(lDoHeroics,							"GaryDialog.gary_dontyouknowwho", 1);
	Addto(lDoHeroics,							"GaryDialog.gary_bringiton", 1);

	Clear(lCloseToWeapon);
	addto(lCloseToWeapon,						"GaryDialog.gary_youbitch", 1);	
	addto(lCloseToWeapon,						"GaryDialog.gary_shit", 1);	
	addto(lCloseToWeapon,						"GaryDialog.gary_fuck", 1);	

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"GaryDialog.gary_gak", 1);	
	Addto(laftergettingpissedon,				"GaryDialog.gary_gurgle", 1);
	Addto(laftergettingpissedon,				"GaryDialog.gary_shit", 1);	
	Addto(laftergettingpissedon,				"GaryDialog.gary_youbitch", 1);	

	Clear(lWhileFighting);
	Addto(lWhileFighting, 						"GaryDialog.gary_ohmanthisisgreat", 1);
	Addto(lWhileFighting, 						"GaryDialog.gary_youlikethat", 1);
	Addto(lWhileFighting, 						"GaryDialog.gary_wannaseeagain", 1);
	Addto(lWhileFighting, 						"GaryDialog.gary_oneformother", 1);
	Addto(lWhileFighting, 						"GaryDialog.gary_igotyerwillis", 1);

	Clear(ldying);
	Addto(ldying,								"GaryDialog.gary_awmanthissucks", 1);
	Addto(ldying,								"GaryDialog.gary_bloodonebay", 1);
	Addto(ldying,								"GaryDialog.gary_makesuremyass", 1);

	Clear(ldudedead);
	addto(ldudedead,							"GaryDialog.gary_youbitch", 1);	

	Clear(lKickDead);
	Addto(lKickDead, 							"GaryDialog.gary_igotyerwillis", 1);
	Addto(lKickDead, 							"GaryDialog.gary_oneformother", 1);

	Clear(lNameCalling);
	Addto(lNameCalling,							"GaryDialog.gary_youbitch", 1);	

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy, 						"GaryDialog.gary_saywhat", 1);
	Addto(lWatchingCrazy,		 				"GaryDialog.gary_whatiswrong", 1);

	Clear(lbegforlife);
	Addto(lbegforlife,							"GaryDialog.gary_awmanthissucks", 1);
	Addto(lbegforlife,							"GaryDialog.gary_bloodonebay", 1);
	Addto(lbegforlife,							"GaryDialog.gary_makesuremyass", 1);

	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,						"GaryDialog.gary_awmanthissucks", 1);
	Addto(lbegforlifeMin,						"GaryDialog.gary_bloodonebay", 1);
	Addto(lbegforlifeMin,						"GaryDialog.gary_makesuremyass", 1);

	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,						"GaryDialog.gary_hey", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged, 						"GaryDialog.gary_fuckyou", 1);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"GaryDialog.gary_youbitch", 1);	

	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
