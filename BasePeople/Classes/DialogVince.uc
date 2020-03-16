///////////////////////////////////////////////////////////////////////////////
// DialogVince
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for Vince
//
//	History:
//		05/21/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class DialogVince extends DialogMale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	clear(lVince_Greeting);
	Addto(lVince_Greeting, 					"VinceDialog.vince_ayyy", 1);
	Addto(lVince_Greeting, 					"VinceDialog.vince_whatsup", 1);
	
	clear(lPositiveResponse);
	Addto(lPositiveResponse, 				"VinceDialog.vince_sure", 1);

	clear(lNegativeResponse);
	Addto(lNegativeResponse, 				"VinceDialog.vince_nah", 1);
	Addto(lNegativeResponse, 				"VinceDialog.vince_idontthinkso", 1);
	
	clear(lVince_Fired);
	Addto(lVince_Fired, 					"VinceDialog.vince_nothingpersonal", 1);
	
	clear(lVince_GetCheck);
	Addto(lVince_GetCheck, 					"VinceDialog.vince_getcheck", 1);
	
	Clear(lvince_insults);
	Addto(lvince_insults, 					"VinceDialog.vince_stillaposition", 1);
	Addto(lvince_insults, 					"VinceDialog.vince_somebodystole", 1);
	Addto(lvince_insults, 					"VinceDialog.vince_youstillhere", 1);
	
	Clear(lgreeting);
	Addto(lgreeting, 					"VinceDialog.vince_ayyy", 1);
	Addto(lgreeting, 					"VinceDialog.vince_whatsup", 1);

	Clear(lhotgreeting);
	Addto(lhotGreeting, 					"VinceDialog.vince_ayyy", 1);
	Addto(lhotGreeting, 					"VinceDialog.vince_whatsup", 1);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,						"VinceDialog2.VinceBystander-1HowsItGoing", 1);
	Addto(lGreetingquestions,						"VinceDialog2.VinceBystander-1HeyManWhatsUp", 1);

	Clear(lHotgreetingquestions);
	Addto(lHotGreetingquestions,						"VinceDialog2.VinceBystander-1HowsItGoing", 1);
	Addto(lHotGreetingquestions,						"VinceDialog2.VinceBystander-1HeyManWhatsUp", 1);

	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,						"VinceDialog2.VinceBystander-2DontMakeMeCall", 1);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,						"VinceDialog2.VinceBystander-1AllGoodWhatsUp", 1);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,					"VinceDialog2.VinceBystander-1SoundsPrettyGood", 1);
	Addto(lrespondtogreetingresponse,					"VinceDialog2.VinceBystander-1WTFYouTalkingAbout", 1);
	Addto(lrespondtogreetingresponse,					"VinceDialog2.VinceBystander-2OhImSorry", 1);

	Clear(lHelloCop);
	Addto(lHelloCop,								"VinceDialog2.VinceBystander-2HelloOfficer", 1);
	Addto(lHelloCop,								"VinceDialog2.VinceBystander-2HelloPig", 1);

	Clear(lHelloGimp);
	Addto(lHelloGimp,								"VinceDialog2.VinceBystander-2WhatsThatOutfit", 1);

	Clear(lApologize);
	Addto(lApologize,								"VinceDialog2.VinceBystander-2OhImSorry", 1);

	Clear(lyourewelcome);
	Addto(lyourewelcome,							"VinceDialog2.VinceBystander-2YoureWelcome", 1);

	Clear(lno);
	Addto(lno, 								"VinceDialog.vince_nah", 1);
	Addto(lno, 								"VinceDialog.vince_idontthinkso", 1);
	Addto(lno,								"VinceDialog2.VinceBystander-2IDontThinkSo", 1);

	Clear(lyes);
	Addto(lyes, 							"VinceDialog.vince_sure", 1);
	Addto(lyes,								"VinceDialog2.VinceBystander-2Probably", 1);

	Clear(lthanks);
	Addto(lThanks, 								"VinceDialog.vince_positive1", 1);
	Addto(lThanks, 								"VinceDialog.vince_positive2", 1);
	Addto(lthanks,								"VinceDialog2.VinceBystander-2KickAss", 1);
	Addto(lthanks,								"VinceDialog2.VinceBystander-2ThatRocks", 1);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"VinceDialog2.VinceBystander-2KickAssMF", 1);
	Addto(lThatsGreat,							"VinceDialog2.VinceBystander-2KickAss", 1);
	Addto(lThatsGreat,							"VinceDialog2.VinceBystander-2ThatRocks", 1);

	Clear(lGetDown);
	AddTo(lGetDown,								"VinceDialog2.VinceBystander-2GetDownMF", 1);

	Clear(lGetDownMP);
	AddTo(lGetDownMP,							"VinceDialog2.VinceBystander-2GetDownMF", 1);
	Addto(lGetDownMP, 							"VinceDialog.vince_stillaposition", 1);
	Addto(lGetDownMP, 							"VinceDialog.vince_somebodystole", 1);
	Addto(lGetDownMP, 							"VinceDialog.vince_youstillhere", 1);

	Clear(lCussing);
	Addto(lCussing,								"VinceDialog2.VinceBystander-2HolyShit", 1);

	Clear(lgetdownscared);
	Addto(lgetdownscared,							"VinceDialog2.VinceBystander-2GetDownMF", 1);

	Clear(ldefiant);
	Addto(ldefiant,								"VinceDialog2.VinceBystander-2YoMamma", 1);
	Addto(ldefiant,								"VinceDialog2.VinceBystander-4SomeOfThis", 1);
	Addto(ldefiant,								"VinceDialog2.VinceBystander-2NoWayPinko", 1);

	Clear(ldefiantline);
	Addto(ldefiantline,							"VinceDialog2.VinceBystander-2YoMamma", 1);
	Addto(ldefiantline,							"VinceDialog2.VinceBystander-4SomeOfThis", 1);
	Addto(ldefiantline,							"VinceDialog2.VinceBystander-2NoWayPinko", 1);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"VinceDialog2.VinceBystander-2HolyShit", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,							"VinceDialog2.VinceBystander-2CantDoThat", 1);

	//New laughs aren't boisterous enough to match the animation. Using for snickering instead.
	Clear(llaughing);
	//Addto(llaughing,								"VinceDialog2.VinceBystander-3Laugh1", 1);
	//Addto(llaughing,								"VinceDialog2.VinceBystander-3Laugh2", 1);
	Addto(llaughing,								"WMaleDialog.wm_laugh", 1);

	Clear(lSnickering);
	Addto(lSnickering,								"VinceDialog2.VinceBystander-3Laugh1", 1);
	Addto(lSnickering,								"VinceDialog2.VinceBystander-3Laugh2", 1);

	Clear(lOutOfBreath);
	Addto(lOutOfBreath,								"VinceDialog2.VinceBystander-3OutOfBreath", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,							"VinceDialog2.VinceBystander-3Laugh1", 1);
	Addto(lWatchingCrazy,							"VinceDialog2.VinceBystander-3Laugh2", 1);
	Addto(lWatchingCrazy,							"VinceDialog2.VinceBystander-4AreYouOnCrack", 1);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,						"VinceDialog2.VinceBystander-4SomeonesShooting", 1);

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,						"VinceDialog2.VinceBystander-4SomeGuysShooting", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,								"VinceDialog2.VinceBystander-3Scream1", 1);
	Addto(lscreaming,								"VinceDialog2.VinceBystander-3Scream2", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,								"VinceDialog2.VinceBystander-3Scream1", 1);
	Addto(lscreamingonfire,								"VinceDialog2.VinceBystander-3Scream2", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,								"VinceDialog2.VinceBystander-4SomeOfThis", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,						"VinceDialog2.VinceBystander-4YouSickBastard", 1);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"VinceDialog2.VinceBystander-4WhatThe1", 1);
	Addto(lwhatthe,								"VinceDialog2.VinceBystander-4WhatThe2", 1);

	Clear(lseeingpisser);
	Addto(lseeingpisser,							"VinceDialog2.VinceBystander-4ThatsDisgusting", 1);

	Clear(lSomethingIsGross);
	Addto(lSomethingIsGross,							"VinceDialog2.VinceBystander-4ThatsDisgusting", 1);

	Clear(lgothit);
	addto(lgothit,								"WMaleDialog.wm_argh", 1);	
	addto(lgothit,								"VinceDialog2.VinceBystander-3Ow", 1);
	addto(lgothit,								"VinceDialog2.VinceBystander-3OwOw", 1);
	addto(lgothit,								"VinceDialog2.VinceBystander-3Uh1", 1);
	addto(lgothit,								"VinceDialog2.VinceBystander-3Uh2", 1);
	addto(lgothit,								"WMaleDialog.wm_aghk", 1);
	addto(lgothit,								"WMaleDialog.wm_gak", 1);

	Clear(lAttacked);
	addto(lAttacked,								"WMaleDialog.wm_argh", 1);	
	addto(lAttacked,								"VinceDialog2.VinceBystander-3Ow", 1);
	addto(lAttacked,								"VinceDialog2.VinceBystander-3OwOw", 1);
	addto(lAttacked,								"VinceDialog2.VinceBystander-3Uh1", 1);
	addto(lAttacked,								"VinceDialog2.VinceBystander-3Uh2", 1);
	addto(lAttacked,								"WMaleDialog.wm_aghk", 1);
	addto(lAttacked,								"WMaleDialog.wm_gak", 1);

	Clear(lGrunt);
	addto(lGrunt,								"WMaleDialog.wm_argh", 1);	
	addto(lGrunt,								"VinceDialog2.VinceBystander-3Ow", 1);
	addto(lGrunt,								"VinceDialog2.VinceBystander-3OwOw", 1);
	addto(lGrunt,								"VinceDialog2.VinceBystander-3Uh1", 1);
	addto(lGrunt,								"VinceDialog2.VinceBystander-3Uh2", 1);
	addto(lGrunt,								"WMaleDialog.wm_aghk", 1);
	addto(lGrunt,								"WMaleDialog.wm_gak", 1);

	// no pissing talking
	Clear(lPissing);
	Addto(lPissing,								"VinceDialog2.VinceBystander-2FeelsFuckingGood", 1);
	Addto(lPissing, 						"AmbientSounds.vinceAhuh", 1);

	// no pissing myself out talking
	Clear(lPissOutFireOnSelf);
	Addto(lPissOutFireOnSelf,					"VinceDialog2.VinceBystander-2FeelsFuckingGood", 1);
	
	Clear(lGotHealth);
	Addto(lGotHealth,							"VinceDialog2.VinceBystander-2FeelsFuckingGood", 1);
	Addto(lGotHealth, 						"VinceDialog.vince_positive2", 1);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,						"VinceDialog2.VinceBystander-6HardToBelieve", 1);
	Addto(lGotHealthFood, 					"VinceDialog.vince_positive1", 1);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth,						"VinceDialog2.VinceBystander-2FeelsFuckingGood", 1);
	Addto(lGotCrackHealth, 					"AmbientSounds.vinceAhuh", 1);

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"VinceDialog2.VinceBystander-3Uh1", 1);	
	addto(lGotHitInCrotch,						"VinceDialog2.VinceBystander-3Uh2", 1);	

	Clear(lbegforlife);
	Addto(lbegforlife,							"VinceDialog2.VinceBystander-5Crying", 1);
	Addto(lbegforlife,							"VinceDialog2.VinceBystander-5DontKillMe_Virgin", 1);
	Addto(lbegforlife,							"VinceDialog2.VinceBystander-5DontKillMe_Minority", 1);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,							"VinceDialog2.VinceBystander-5Crying", 1);
	Addto(lbegforlifeMin,							"VinceDialog2.VinceBystander-5DontKillMe_Minority", 1);
	Addto(lbegforlifeMin,							"VinceDialog2.VinceBystander-5DontKillMe_Virgin", 1);
	
	Clear(ldying);
	Addto(ldying,								"VinceDialog2.VinceBystander-5CantFeelMyLegs", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl1", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl2", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl3", 1);
	Addto(ldying,								"VinceDialog2.VinceBystander-5Crying", 1);

	Clear(lCrying);
	Addto(lCrying,								"VinceDialog2.VinceBystander-5Crying", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,						"VinceDialog2.VinceBystander-5IDidntMeanIt", 1);

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"VinceDialog2.VinceBystander-2BigManWithAGun", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting,							"VinceDialog2.VinceBystander-2BigManWithAGun", 1);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,								"VinceDialog2.VinceBystander-4WhatsTheProblemOfficer", 1);

	Clear(lratout);
	Addto(lratout,								"VinceDialog2.VinceBystander-4ThatGuyOverThere", 1);
	Addto(lratout,								"VinceDialog2.VinceBystander-4HeDidIt", 1);

	Clear(lfakeratout);
	Addto(lfakeratout,							"VinceDialog2.VinceBystander-4HeDidItisaw", 1);

	Clear(lcleanshot);
	Addto(lcleanshot,							"VinceDialog2.VinceBystander-4GetOutOfTheWay", 1);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"VinceDialog2.VinceBystander-4GetOutOfTheWay", 1);
	
	Clear(lAfterEating);
	Addto(lAfterEating,							"VinceDialog2.VinceBystander-6HardToBelieve", 1);

	Clear(lpleasureresponse);					
	Addto(lpleasureresponse,						"VinceDialog2.VinceBystander-2FeelsFuckingGood", 1);

	Clear(lhmm);
	Addto(lhmm,									"VinceDialog2.VinceBystander-6Hmmm1", 1);
	Addto(lhmm,									"VinceDialog2.VinceBystander-6Hmmm2", 1);

	Clear(lfollowme);
	Addto(lfollowme,						"VinceDialog.vince_ayyy", 1);

	Clear(lStayHere);
	Addto(lStayHere,						"VinceDialog.vince_heyman", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,							"VinceDialog2.VinceBystander-6PullUpYourPants", 1);

	Clear(lilltakenumber);
	Addto(lilltakenumber,							"VinceDialog2.VinceBystander-7IllTakeANumber", 1);

	Clear(lmakedeposit);
	Addto(lmakedeposit,								"VinceDialog2.VinceBystander-7MakeADeposit", 1);

	Clear(lmakewithdrawal);
	Addto(lmakewithdrawal,							"VinceDialog2.VinceBystander-7WithdrawSomeMoney", 1);

	Clear(lconsumerbuy);
	Addto(lconsumerbuy,							"VinceDialog2.VinceBystander-7ThereYouGoThankYou", 1);

	Clear(lconteststoretransaction);
	Addto(lconteststoretransaction,						"VinceDialog2.VinceBystander-7WhatKindaJoint", 1);
	
	Clear(lcontestbanktransaction);
	Addto(lcontestbanktransaction,						"VinceDialog2.VinceBystander-7WhatKindaJoint", 1);

	Clear(lGoPostal);
	Addto(lGoPostal,								"VinceDialog2.VinceBystander-7InYourAss", 1);
	Addto(lGoPostal,								"VinceDialog2.VinceBystander-2GetDownMF", 1);	
	Addto(lGoPostal,								"VinceDialog2.VinceBystander-2BigManWithAGun", 1);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,							"VinceDialog2.VinceBystander-5SomeoneMakeItStop", 1);
	Addto(lcarnageoccurred,							"VinceDialog2.VinceBystander-2HolyShit", 1);

	Clear(lCallCat);
	Addto(lCallCat, 							"VinceDialog2.VinceBystander-2HereKittyKitty", 1);

	Clear(lHateCat);
	Addto(lHateCat, 							"VinceDialog2.VinceBystander-2HereKittyKitty", 1);

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"VinceDialog2.VinceBystander-4WhatThe1", 1);
	Addto(lStartAttackingAnimal,				"VinceDialog2.VinceBystander-4WhatThe2", 1);

	Clear(lGettingRobbed);	
	Addto(lGettingRobbed,							"VinceDialog2.VinceBystander-5SomebodyStopHim", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"VinceDialog2.VinceBystander-5PleaseDontKillMe", 1);
	Addto(lGettingMugged,						"VinceDialog2.VinceBystander-5Crying", 1);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"VinceDialog2.VinceBystander-5SomebodyStopHim", 1);

	Clear(lDoMugging);	
	Addto(lDoMugging,							"VinceDialog2.VinceBystander-2BitchHandOver", 1);
	
	Clear(lQuestion);	
	Addto(lQuestion,							"VinceDialog2.VinceBystander-1WTFYouTalkingAbout", 1);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"VinceDialog2.VinceBystander-1MakeItToThePlayoffs", 1);
	Addto(lGenericQuestion,						"VinceDialog2.VinceBystander-1GoodSpotToEat", 1);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"VinceDialog2.VinceBystander-2UpYourAssYoudKnow", 1);
	Addto(lGenericAnswer,						"VinceDialog2.VinceBystander-2NoWayPinko", 1);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"VinceDialog2.VinceBystander-2AreYouListening", 1);
	Addto(lGenericFollowup,						"VinceDialog2.VinceBystander-1WTFYouTalkingAbout", 1);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"VinceDialog2.VinceBystander-2GetOutOfHereLunatic", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,							"VinceDialog2.VinceBystander-1StopDropRoll", 1);

	Clear(labouttopuke);
	Addto(labouttopuke,							"VinceDialog2.VinceBystander-1GonnaBeSick", 1);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,							"VinceDialog2.VinceBystander-1Vomiting1", 1);
	Addto(lbodyfunctions,							"VinceDialog2.VinceBystander-1Vomiting2", 1);

	Clear(lGettingShocked);
	Addto(lGettingShocked,							"VinceDialog2.VinceBystander-1Vomiting1", 1);
	Addto(lGettingShocked,							"VinceDialog2.VinceBystander-1Vomiting2", 1);

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,							"VinceDialog2.VinceBystander-6Hmmm1", 1);
	Addto(lCellPhoneTalk,							"VinceDialog2.VinceBystander-6Hmmm2", 1);
	Addto(lCellPhoneTalk,							"VinceDialog2.VinceBystander-1MakeItToThePlayoffs", 1);
	Addto(lCellPhoneTalk,							"VinceDialog2.VinceBystander-1BeAroundInAWhile", 1);
	Addto(lCellPhoneTalk,							"VinceDialog2.VinceBystander-1GoodSpotToEat", 1);
	Addto(lCellPhoneTalk,							"VinceDialog2.VinceBystander-1ICanGetOverThere", 1);
	Addto(lCellPhoneTalk,							"VinceDialog2.VinceBystander-1WTFYouTalkingAbout", 1);
	Addto(lCellPhoneTalk,							"VinceDialog2.VinceBystander-1SoundsPrettyGood", 1);
	
	Clear(lKrotchyCustomerComment);
	Addto(lKrotchyCustomerComment,					"VinceDialog2.VinceBystander-8DarkForKrotchy", 1);

	Clear(lKrotchyCustomerWant);
	Addto(lKrotchyCustomerWant,						"VinceDialog2.VinceBystander-8AnyKrotchysLeft", 1);

	Clear(lGaryAutograph);
	Addto(lGaryAutograph,							"VinceDialog2.VinceBystander-8SayThatWillisThing", 1);

	Clear(ldudedead);
	Addto(ldudedead,							"VinceDialog2.VinceBystander-1BlameDoom", 1);
	Addto(ldudedead,							"VinceDialog2.VinceBystander-2HolyShit", 1);
	Addto(ldudedead,							"VinceDialog2.VinceBystander-2YoMamma", 1);
	Addto(ldudedead,							"VinceDialog2.VinceBystander-4ThatsDisgusting", 1);

	Clear(lKickDead);
	Addto(lKickDead,							"VinceDialog2.VinceBystander-2OneForYourMother", 1);

	Clear(lNameCalling);
	Addto(lNameCalling,							"VinceDialog2.VinceBystander-7InYourAss", 1);
	Addto(lNameCalling,							"VinceDialog2.VinceBystander-2HolyShit", 1);
	Addto(lNameCalling,							"VinceDialog2.VinceBystander-1BlameDoom", 1);

	Clear(lRogueCop);
	Addto(lRogueCop,							"VinceDialog2.VinceBystander-1WheresMyVideoCamera", 1);

	Clear(lgetbumped);
	Addto(lgetbumped,							"VinceDialog2.VinceBystander-2HeyWatchIt", 1);
	Addto(lgetbumped,							"VinceDialog2.VinceBystander-3Uh1", 1);
	Addto(lgetbumped,							"VinceDialog2.VinceBystander-3Uh2", 1);
	Addto(lgetbumped,							"VinceDialog2.VinceBystander-7InYourAss", 1);

	Clear(lGetMad);
	Addto(lGetMad,								"VinceDialog2.VinceBystander-3Uh1", 1);
	Addto(lGetMad,								"VinceDialog2.VinceBystander-3Uh2", 1);
	addto(lGetMad,								"VinceDialog2.VinceBystander-3Ow", 1);

	Clear(lLynchMob);
	Addto(lLynchMob,							"VinceDialog2.VinceBystander-2ThatsTheOne", 1);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"VinceDialog2.VinceBystander-2IllKillYou", 1);
	Addto(lSeesEnemy,							"VinceDialog2.VinceBystander-4SomeOfThis", 1);

	Clear(lnextinline);
	Addto(lnextinline,							"VinceDialog2.VinceBystander-9NextPersonInLine", 1);
	
	Clear(lhelpyouoverhere);
	Addto(lhelpyouoverhere,							"VinceDialog2.VinceBystander-9HelpYouOverHere", 1);

	Clear(lsomeonecuts);
	Addto(lsomeonecuts,							"VinceDialog2.VinceBystander-9SorryBackOfTheLine", 1);

	Clear(lpleasemoveforward);
	Addto(lpleasemoveforward,						"VinceDialog2.VinceBystander-9PleaseMoveForward", 1);

	Clear(lcanihelpyou);
	Addto(lcanihelpyou,							"VinceDialog2.VinceBystander-9HowCanIHelp", 1);

	Clear(lNumbers_Thatllbe);
	Addto(lNumbers_Thatllbe,					"VinceDialog2.VinceBystander-9ThatllBe", 1);

	Clear(lNumbers_a);
	Addto(lNumbers_a,							"VinceDialog2.VinceBystander-9A", 1);

	Clear(lNumbers_1);
	Addto(lNumbers_1,							"VinceDialog2.VinceBystander-9One", 1);

	Clear(lNumbers_2);
	Addto(lNumbers_2,							"VinceDialog2.VinceBystander-9Two", 1);

	Clear(lNumbers_3);
	Addto(lNumbers_3,							"VinceDialog2.VinceBystander-9Three", 1);

	Clear(lNumbers_4);
	Addto(lNumbers_4,							"VinceDialog2.VinceBystander-9Four", 1);

	Clear(lNumbers_5);
	Addto(lNumbers_5,							"VinceDialog2.VinceBystander-9Five", 1);

	Clear(lNumbers_10);
	Addto(lNumbers_10,							"VinceDialog2.VinceBystander-9Ten", 1);

	Clear(lNumbers_20);
	Addto(lNumbers_20,							"VinceDialog2.VinceBystander-9Twenty", 1);

	Clear(lNumbers_40);
	Addto(lNumbers_40,							"VinceDialog2.VinceBystander-9Forty", 1);

	Clear(lNumbers_60);
	Addto(lNumbers_60,							"VinceDialog2.VinceBystander-9Sixty", 1);

	Clear(lNumbers_80);
	Addto(lNumbers_80,							"VinceDialog2.VinceBystander-9Eighty", 1);

	Clear(lNumbers_100);
	Addto(lNumbers_100,							"VinceDialog2.VinceBystander-9OneHundred", 1);

	Clear(lNumbers_200);
	Addto(lNumbers_200,							"VinceDialog2.VinceBystander-9TwoHundred", 1);

	Clear(lNumbers_300);
	Addto(lNumbers_300,							"VinceDialog2.VinceBystander-9ThreeHundred", 1);

	Clear(lNumbers_400);
	Addto(lNumbers_400,							"VinceDialog2.VinceBystander-9FourHundred", 1);

	Clear(lNumbers_500);
	Addto(lNumbers_500,							"VinceDialog2.VinceBystander-9FiveHundred", 1);

	Clear(lNumbers_Dollars);
	Addto(lNumbers_Dollars,						"VinceDialog2.VinceBystander-9Dollars", 1);

	Clear(lNumbers_SingleDollar);
	Addto(lNumbers_SingleDollar,				"VinceDialog2.VinceBystander-9Dollar", 1);

	Clear(lsellingitem);
	Addto(lsellingitem,							"VinceDialog2.VinceBystander-9OKGreatThankYou", 1);

	Clear(lIsThisEverything);
	Addto(lIsThisEverything,						"VinceDialog2.VinceBystander-9IsThisEverything", 1);
	
	Clear(llackofmoney);
	Addto(llackofmoney,							"VinceDialog2.VinceBystander-9SorryNeedMoreMoney", 1);

	Clear(lSignPetition);							
	Addto(lSignPetition, 						"VinceDialog.vince_ayyy", 1);
	Addto(lSignPetition, 						"VinceDialog.vince_sure", 1);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,						"VinceDialog2.VinceBystander-2NoWayPinko", 1);

	Clear(lPetitionBother);
	Addto(lPetitionBother,							"VinceDialog2.VinceBystander-2LeaveMeAlone", 1);

	Clear(lcallsecurity);
	Addto(lcallsecurity,							"VinceDialog2.VinceBystander-2DontMakeMeCall", 1);
	
	Clear(lrowdycustomer);
	Addto(lrowdycustomer,							"VinceDialog2.VinceBystander-2DontMakeMeCall", 1);

	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
