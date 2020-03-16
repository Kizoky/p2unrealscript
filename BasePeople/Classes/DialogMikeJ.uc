///////////////////////////////////////////////////////////////////////////////
// DialogMikeJ
// Copyright 2013 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for Mike J
//
///////////////////////////////////////////////////////////////////////////////
class DialogMikeJ extends DialogMale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,							"MikeJDialog.P2_Cell_Phone_1", 1);
	Addto(lCellPhoneTalk,							"MikeJDialog.P2_Cell_Phone_2", 1);
	Addto(lCellPhoneTalk,							"MikeJDialog.P2_Cell_Phone_3", 1);
	Addto(lCellPhoneTalk,							"MikeJDialog.P2_Cell_Phone_4", 1);
	Addto(lCellPhoneTalk,							"MikeJDialog.P2_Cell_Phone_5", 1);
	Addto(lCellPhoneTalk,							"MikeJDialog.Generic_Question_1", 3);
	Addto(lCellPhoneTalk,							"MikeJDialog.Generic_Question_2", 3);
	Addto(lCellPhoneTalk,							"MikeJDialog.Generic_Question_3", 3);

	Clear(lgreeting);
	Addto(lgreeting,							"MikeJDialog.P2_Greeting_1", 1);
	Addto(lgreeting,							"MikeJDialog.P2_Greeting_2", 1);
	Addto(lgreeting,							"MikeJDialog.P2_Greeting_3", 2);
	Addto(lgreeting,							"MikeJDialog.P2_Greeting_4", 2);

	Clear(lgreetingquestions);
	Addto(lGreetingquestions,						"MikeJDialog.P2_Greeting_3", 1);

	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,						"MikeJDialog.Respond_To_Greeting_2", 1);
	Addto(lrespondtogreeting,						"MikeJDialog.Respond_To_Greeting_1", 2);
	Addto(lrespondtogreeting,						"MikeJDialog.Respond_To_Greeting_3", 2);
	Addto(lrespondtogreeting,						"MikeJDialog.Respond_To_Greeting_4", 3);

	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,					"MikeJDialog.Response_To_Response_1", 1);
	Addto(lrespondtogreetingresponse,					"MikeJDialog.Response_To_Response_2", 1);
	Addto(lrespondtogreetingresponse,					"MikeJDialog.Response_To_Response_3", 2);

	Clear(lHelloCop);
	Addto(lHelloCop,								"MikeJDialog.Hello_Officer_1", 1);
	Addto(lHelloCop,								"MikeJDialog.Hello_Officer_2", 1);

	Clear(lHelloGimp);
	Addto(lHelloGimp,								"MikeJDialog.Hello_Gimp_1", 1);
	Addto(lHelloGimp,								"MikeJDialog.Hello_Gimp_2", 1);

	Clear(lApologize);
	Addto(lApologize,								"MikeJDialog.Apologize", 1);

	Clear(lyourewelcome);
	Addto(lyourewelcome,							"MikeJDialog.Youre_Welcome", 1);

	Clear(lno);
	Addto(lno,								"MikeJDialog.No", 1);
	Addto(lno,								"MikeJDialog.No_2", 2);

	Clear(lyes);
	Addto(lyes,								"MikeJDialog.Yes_1", 1);
	Addto(lyes,								"MikeJDialog.Yes_2", 2);

	Clear(lthanks);
	Addto(lthanks,								"MikeJDialog.Thanks_1", 1);
	Addto(lthanks,								"MikeJDialog.Thanks_2", 2);

	Clear(lThatsGreat);
	Addto(lThatsGreat,							"MikeJDialog.Thats_Great_1", 1);
	Addto(lThatsGreat,							"MikeJDialog.Thats_Great_3", 1);
	Addto(lThatsGreat,							"MikeJDialog.Thats_Great_2", 3);

	Clear(lGetDown);
	AddTo(lGetDown,								"MikeJDialog.Get_Down_1", 1);
	AddTo(lGetDown,								"MikeJDialog.Get_Down_2", 1);
	AddTo(lGetDown,								"MikeJDialog.Get_Down_3", 1);

	Clear(lGetDownMP);
	AddTo(lGetDownMP,								"MikeJDialog.Get_Down_1", 1);
	AddTo(lGetDownMP,								"MikeJDialog.Get_Down_2", 1);
	AddTo(lGetDownMP,								"MikeJDialog.Get_Down_3", 1);

	Clear(lCussing);
	Addto(lCussing,								"MikeJDialog.Cuss_1", 1);
	Addto(lCussing,								"MikeJDialog.Cuss_2", 1);
	Addto(lCussing,								"MikeJDialog.Cuss_3", 1);
	Addto(lCussing,								"MikeJDialog.Cuss_4", 2);
	Addto(lCussing,								"MikeJDialog.Cuss_5", 2);
	Addto(lCussing,								"MikeJDialog.Cuss_6", 2);
	Addto(lCussing,								"MikeJDialog.Cuss_8", 2);
	Addto(lCussing,								"MikeJDialog.Cuss_9", 3);
	Addto(lCussing,								"MikeJDialog.Cuss_10", 3);
	Addto(lCussing,								"MikeJDialog.Cuss_11", 3);

	Clear(ldefiant);
	Addto(ldefiant,								"MikeJDialog.Defiant", 1);
	Addto(ldefiant,								"MikeJDialog.Defiant_2", 1);
	Addto(ldefiant,								"MikeJDialog.Defiant_3", 1);

	Clear(ldefiantline);
	Addto(ldefiantline,								"MikeJDialog.Defiant", 1);
	Addto(ldefiantline,								"MikeJDialog.Defiant_2", 1);
	Addto(ldefiantline,								"MikeJDialog.Defiant_3", 1);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"MikeJDialog.Close_To_Weapon_1", 1);
	Addto(lCloseToWeapon,						"MikeJDialog.Close_To_Weapon_2", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,							"MikeJDialog.Decide_To_Fight", 1);

	Clear(llaughing);
	Addto(llaughing,								"MikeJDialog.Laugh_3", 1);
	Addto(llaughing,								"MikeJDialog.Laugh_1", 2);
	Addto(llaughing,								"MikeJDialog.Laugh_2", 2);

	Clear(lSnickering);
	Addto(lSnickering,								"MikeJDialog.Snicker_1", 1);
	Addto(lSnickering,								"MikeJDialog.Snicker_2", 2);

	Clear(lOutOfBreath);
	Addto(lOutOfBreath,								"MikeJDialog.Out_of_Breath_1", 1);
	Addto(lOutOfBreath,								"MikeJDialog.Out_of_Breath_2", 2);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,							"MikeJDialog.Snicker_2", 1);
	Addto(lWatchingCrazy,							"MikeJDialog.Watching_Crazy_1", 1);
	Addto(lWatchingCrazy,							"MikeJDialog.Watching_Crazy_2", 1);
	Addto(lWatchingCrazy,							"MikeJDialog.Watching_Crazy_3", 2);

	//Clear(lGroupLaugh);
	//Addto(lGroupLaugh,								"WMaleDialog.wm_group_laugh", 1);

	Clear(lshootingoverthere);
	Addto(lshootingoverthere,						"MikeJDialog.Shooting_Over_There_1", 1);
	//Addto(lshootingoverthere,						"MikeJDialog.Shooting_Over_There_2", 1);
	// this one sounds like more of a general "hey everyone" instead of just getting a cop

	Clear(lkillingoverthere);
	Addto(lkillingoverthere,						"MikeJDialog.Killing_Over_There_1", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,								"MikeJDialog.Scream_1", 1);
	Addto(lscreaming,								"MikeJDialog.Scream_2", 1);
	Addto(lscreaming,								"MikeJDialog.Scream_3", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,							"MikeJDialog.Scream_1", 1);
	Addto(lscreamingonfire,							"MikeJDialog.Scream_2", 1);
	Addto(lscreamingonfire,							"MikeJDialog.Scream_3", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,								"MikeJDialog.Do_Heroics_1", 1);
	Addto(lDoHeroics,								"MikeJDialog.Do_Heroics_2", 1);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,							"MikeJDialog.Getting_Pissed_On", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,						"MikeJDialog.After_Getting_Pissed_1", 1);
	Addto(laftergettingpissedon,						"MikeJDialog.After_Getting_Pissed_2", 1);
	Addto(laftergettingpissedon,						"MikeJDialog.After_Getting_Pissed_3", 1);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"MikeJDialog.What_The_2", 1);
	Addto(lwhatthe,								"MikeJDialog.What_The_3", 1);

	Clear(lseeingpisser);
	Addto(lseeingpisser,							"MikeJDialog.Something_Is_Gross_1", 1);
	Addto(lseeingpisser,							"MikeJDialog.Something_Is_Gross_2", 1);

	Clear(lSomethingIsGross);
	Addto(lSomethingIsGross,							"MikeJDialog.Something_Is_Gross_1", 1);
	Addto(lSomethingIsGross,							"MikeJDialog.Something_Is_Gross_2", 1);

	Clear(lgothit);
	Addto(lgothit,								"MikeJDialog.Got_Hit_1", 1);
	addto(lgothit,								"MikeJDialog.Got_Hit_2", 1);	
	addto(lgothit,								"MikeJDialog.Got_Hit_3", 1);
	addto(lgothit,								"MikeJDialog.Got_Hit_4", 2);
	addto(lgothit,								"MikeJDialog.Got_Hit_5", 2);

	Clear(lAttacked);
	addto(lAttacked,								"MikeJDialog.Got_Hit_1", 1);	
	addto(lAttacked,								"MikeJDialog.Got_Hit_2", 1);
	addto(lAttacked,								"MikeJDialog.Got_Hit_3", 2);
	addto(lAttacked,								"MikeJDialog.Got_Hit_4", 2);
	addto(lAttacked,								"MikeJDialog.Got_Hit_5", 3);

	Clear(lGrunt);
	addto(lGrunt,								"MikeJDialog.Got_Hit_2", 1);	
	addto(lGrunt,								"MikeJDialog.Got_Hit_4", 1);
	addto(lGrunt,								"MikeJDialog.Got_Hit_5", 1);

	// no pissing talking
	Clear(lPissing);
	Addto(lPissing,								"WMaleDialog.wm_ahh", 1);
	Addto(lPissing,								"WMaleDialog.wm_ohyeah", 2);
	Addto(lPissing,								"WMaleDialog.wm_satisfiedsigh", 2);

	Clear(lPissOnSelf);
	Addto(lPissOnSelf,							"WMaleDialog.wm_spitting", 2);
	
	// no pissing myself out talking
	Clear(lPissOutFireOnSelf);
	Addto(lPissOutFireOnSelf,					"WMaleDialog.wm_ahh", 1);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,					"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lGotHealth);
	Addto(lGotHealth,							"WMaleDialog.wm_ahh", 1);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,						"MikeJDialog.After_Eating_1", 1);
	Addto(lGotHealthFood,						"MikeJDialog.After_Eating_2", 1);
	Addto(lGotHealthFood,						"MikeJDialog.After_Eating_3", 1);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth,						"MikeJDialog.After_Eating_2", 1);

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"MikeJDialog.Got_Hit_3", 1);	

	Clear(lbegforlife);
	Addto(lbegforlife,							"MikeJDialog.Beg_For_Life_1", 1);
	Addto(lbegforlife,							"MikeJDialog.Crying_1", 2);
	Addto(lbegforlife,							"MikeJDialog.Beg_For_Life_2", 1);
	Addto(lbegforlife,							"MikeJDialog.Crying_2", 2);
	Addto(lbegforlife,							"MikeJDialog.Please_Dont_Kill", 2);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,							"MikeJDialog.Beg_For_Life_1", 1);
	Addto(lbegforlifeMin,							"MikeJDialog.Crying_1", 2);
	Addto(lbegforlifeMin,							"MikeJDialog.Beg_For_Life_2", 1);
	Addto(lbegforlifeMin,							"MikeJDialog.Crying_2", 2);
	Addto(lbegforlifeMin,							"MikeJDialog.Please_Dont_Kill", 2);
	
	Clear(ldying);
	Addto(ldying,								"MikeJDialog.Dying_1", 1);
	Addto(ldying,								"MikeJDialog.Dying_2", 1);
	Addto(ldying,								"MikeJDialog.Dying_3", 1);
	Addto(ldying,								"MikeJDialog.Dying_4", 1);

	Clear(lCrying);
	Addto(lCrying,								"MikeJDialog.Crying_1", 1);
	Addto(lCrying,								"MikeJDialog.Crying_2", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,						"MikeJDialog.Frightened_Apology", 1);	
	Addto(lfrightenedapology,						"MikeJDialog.Frightened_Apology_2", 1);	
	Addto(lfrightenedapology,						"MikeJDialog.Frightened_Apology_3", 1);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"MikeJDialog.Trash_Talk_1", 1);
	Addto(ltrashtalk,							"MikeJDialog.Trash_Talk_2", 1);
	Addto(ltrashtalk,							"MikeJDialog.Trash_Talk_3", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting,							"MikeJDialog.While_Fighting_1", 1);
	Addto(lWhileFighting,							"MikeJDialog.While_Fighting_2", 1);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,							"MikeJDialog.Cop_Whats_Up_1", 1);
	Addto(laskcopwhatsup,							"MikeJDialog.Cop_Whats_Up_1", 2);

	Clear(lratout);
	Addto(lratout,								"MikeJDialog.Rat_Out_1", 1);
	Addto(lratout,								"MikeJDialog.Rat_Out_2", 1);

	Clear(lfakeratout);
	Addto(lfakeratout,							"MikeJDialog.Fake_Rat_Out", 1);
	Addto(lfakeratout,							"MikeJDialog.Fake_Rat_Out_2", 1);

	Clear(lcleanshot);
	Addto(lcleanshot,							"MikeJDialog.Clean_Shot_1", 1);
	Addto(lcleanshot,							"MikeJDialog.Clean_Shot_2", 1);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"MikeJDialog.Clean_Shot_1", 1);
	Addto(lCleanMeleeHit,						"MikeJDialog.Clean_Shot_2", 1);

	Clear(lInhale);
	Addto(lInhale,								"WMaleDialog.wm_inhale", 1);
												
	Clear(lExhale);								
	Addto(lExhale,								"WMaleDialog.wm_exhale", 1);
	
	Clear(lEatingFood);
	Addto(lEatingFood,							"WMaleDialog.wm_mmm", 1);
	Addto(lEatingFood,							"WMaleDialog.wm_chewing", 1);
	Addto(lEatingFood,							"WMaleDialog.wm_smacking", 2);
	Addto(lEatingFood,							"WMaleDialog.wm_drinkingsucking", 3);

	Clear(lAfterEating);
	Addto(lAfterEating,							"MikeJDialog.After_Eating_1", 1);
	Addto(lAfterEating,							"MikeJDialog.After_Eating_2", 1);
	Addto(lAfterEating,							"MikeJDialog.After_Eating_3", 1);

	Clear(lpleasureresponse);					
	Addto(lpleasureresponse,						"WMaleDialog.wm_ahh", 1);
	Addto(lpleasureresponse,						"WMaleDialog.wm_ohyeah", 2);

	Clear(laftersitdown);
	Addto(laftersitdown,							"WMaleDialog.wm_thatsaloadoff", 1);
	Addto(laftersitdown,							"WMaleDialog.wm_satisfiedsigh", 2);

	Clear(lSpitting);
	Addto(lSpitting,							"WMaleDialog.wm_shortingspitting", 1);
	Addto(lSpitting,							"WMaleDialog.wm_spitting", 2);
	
	Clear(lhmm);
	Addto(lhmm,									"MikeJDialog.Hmmm", 1);

	Clear(lfollowme);
	Addto(lfollowme,							"MikeJDialog.FOLLOW_ME", 1);	

	Clear(lStayHere);
	Addto(lStayHere,							"MikeJDialog.STAY_HERE", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,							"MikeJDialog.Noticed_Dick_Out_1", 1);
	Addto(lnoticedickout,							"MikeJDialog.Noticed_Dick_Out_2", 1);
	Addto(lnoticedickout,							"MikeJDialog.Noticed_Dick_Out_3", 1);

	Clear(lilltakenumber);
	Addto(lilltakenumber,							"MikeJDialog.Take_A_Number", 1);

	Clear(lmakedeposit);
	Addto(lmakedeposit,								"MikeJDialog.Make_Deposit", 1);

	Clear(lmakewithdrawal);
	Addto(lmakewithdrawal,							"MikeJDialog.Make_Withdrawal", 1);

	Clear(lconsumerbuy);
	Addto(lconsumerbuy,							"MikeJDialog.Consumer_Buy", 1);

	Clear(lconteststoretransaction);
	Addto(lconteststoretransaction,						"MikeJDialog.Contest_Store_1", 1);
	Addto(lconteststoretransaction,						"MikeJDialog.Contest_Store_2", 1);
	
	/*
	Clear(lcontestbanktransaction);
	Addto(lcontestbanktransaction,						"WMaleDialog.wm_heyihadmoremoney", 1);
	Addto(lcontestbanktransaction,						"WMaleDialog.wm_someonesembezzling", 1);	
	Addto(lcontestbanktransaction,						"WMaleDialog.wm_theremustbesome", 1);

	Clear(lGoPostal);
	Addto(lGoPostal,								"WMaleDialog.wm_postal_howaboutwe", 1);
	Addto(lGoPostal,								"WMaleDialog.wm_postal_ifonemore", 1);	
	Addto(lGoPostal,								"WMaleDialog.wm_postal_godsaidits", 1);
	Addto(lGoPostal,								"WMaleDialog.wm_postal_forgiveme", 1);	
	Addto(lGoPostal,								"WMaleDialog.wm_postal_imsorry", 1);
	*/

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,							"MikeJDialog.Carnage_Occurred", 1);
	Addto(lcarnageoccurred,							"MikeJDialog.Carnage_Occurred_2", 1);

	Clear(lCallCat);
	Addto(lCallCat, 							"MikeJDialog.Here_Kitty", 1);

	/*
	Clear(lHateCat);
	Addto(lHateCat, 							"WMaleDialog.wm_getoutfurball", 1);
	Addto(lHateCat, 							"WMaleDialog.wm_goddamcat", 2);
	*/

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"MikeJDialog.What_The_2", 1);
	Addto(lStartAttackingAnimal,				"MikeJDialog.What_The_3", 1);

	/*
	Clear(lGettingRobbed);	
	Addto(lGettingRobbed,							"WMaleDialog.wm_comebackherewith", 1);
	Addto(lGettingRobbed,							"WMaleDialog.wm_hetookmymoney", 1);
	Addto(lGettingRobbed,							"WMaleDialog.wm_hejustrippedme", 2);
	Addto(lGettingRobbed,							"WMaleDialog.wm_somebodystophim", 3);
	*/

	Clear(lGettingMugged);	
	Addto(lGettingMugged,						"MikeJDialog.Please_Dont_Kill", 1);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"MikeJDialog.After_Mugged", 1);
	Addto(lAfterMugged,							"MikeJDialog.After_Mugged_2", 1);

	Clear(lDoMugging);	
	Addto(lDoMugging,							"MikeJDialog.Do_Mugging", 1);
	
	Clear(lQuestion);	
	Addto(lQuestion,							"MikeJDialog.Generic_Question_1", 1);
	Addto(lQuestion,							"MikeJDialog.Generic_Question_2", 1);
	Addto(lQuestion,							"MikeJDialog.Generic_Question_3", 1);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"MikeJDialog.Generic_Question_1", 1);
	Addto(lGenericQuestion,						"MikeJDialog.Generic_Question_2", 1);
	Addto(lGenericQuestion,						"MikeJDialog.Generic_Question_3", 1);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"MikeJDialog.Generic_Answer_1", 1);
	Addto(lGenericAnswer,						"MikeJDialog.Generic_Answer_2", 1);
	Addto(lGenericAnswer,						"MikeJDialog.Generic_Answer_3", 1);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"MikeJDialog.Generic_Follow_Up_1", 1);
	Addto(lGenericFollowup,						"MikeJDialog.Generic_Follow_Up_2", 1);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"MikeJDialog.Invades_Home_1", 1);
	Addto(linvadeshome,							"MikeJDialog.Invades_Home_2", 1);

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,							"MikeJDialog.Someone_On_Fire_1", 1);
	Addto(lsomeoneonfire,							"MikeJDialog.Someone_On_Fire_2", 1);

	Clear(labouttopuke);
	Addto(labouttopuke,							"MikeJDialog.About_To_Puke", 1);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,							"WMaleDialog.wm_vomit", 1);

	Clear(lGettingShocked);
	Addto(lGettingShocked,							"WMaleDialog.wm_vomit", 1);

	Clear(lKrotchyCustomerComment);
	Addto(lKrotchyCustomerComment,					"MikeJDialog.Krotchy_Customer_Comment_1", 1);
	Addto(lKrotchyCustomerComment,					"MikeJDialog.Krotchy_Customer_Comment_2", 1);

	Clear(lKrotchyCustomerWant);
	Addto(lKrotchyCustomerWant,						"MikeJDialog.Krotchy_Customer_Want_1", 1);
	Addto(lKrotchyCustomerWant,						"MikeJDialog.Krotchy_Customer_Want_2", 1);

	Clear(lGaryAutograph);
	Addto(lGaryAutograph,							"MikeJDialog.Gary_Autograph", 1);
	Addto(lGaryAutograph,							"MikeJDialog.Gary_Autograph_2", 1);
	
	Clear(ldudedead);
	Addto(ldudedead,							"MikeJDialog.Dude_Dead", 1);

	Clear(lKickDead);
	Addto(lKickDead,							"MikeJDialog.Kick_Dead", 1);
	Addto(lKickDead,							"MikeJDialog.Kick_Dead2", 1);

	/*
	Clear(lNameCalling);
	Addto(lNameCalling,							"WMaleDialog.wm_freak", 1);
	Addto(lNameCalling,							"WMaleDialog.wm_creep", 1);
	Addto(lNameCalling,							"WMaleDialog.wm_loser", 1);
	*/

	Clear(lRogueCop);
	Addto(lRogueCop,							"MikeJDialog.Rogue_Cop_1", 1);
	Addto(lRogueCop,							"MikeJDialog.Rogue_Cop_2", 1);

	Clear(lgetbumped);
	Addto(lgetbumped,							"MikeJDialog.Got_Bumped_1", 1);
	Addto(lgetbumped,							"MikeJDialog.Got_Bumped_2", 1);

	Clear(lGetMad);
	Addto(lGetMad,							"MikeJDialog.Got_Bumped_1", 1);
	Addto(lGetMad,							"MikeJDialog.Got_Bumped_2", 1);

	Clear(lLynchMob);
	Addto(lLynchMob,							"MikeJDialog.Lynch_Mob_1", 1);
	Addto(lLynchMob,							"MikeJDialog.Lynch_Mob_2", 1);

	Addto(lSeesEnemy,							"MikeJDialog.Sees_Enemy_1", 1);
	Addto(lSeesEnemy,							"MikeJDialog.Sees_Enemy_2", 1);

	Clear(lnextinline);
	Addto(lnextinline,							"MikeJDialog.Next_In_Line", 1);
	
	Clear(lhelpyouoverhere);
	Addto(lhelpyouoverhere,							"MikeJDialog.Help_You_Over_Here", 1);

	Clear(lsomeonecuts);
	Addto(lsomeonecuts,							"MikeJDialog.Someone_Cuts", 1);

	Clear(lpleasemoveforward);
	Addto(lpleasemoveforward,						"MikeJDialog.Please_Move_Forward", 1);

	Clear(lcanihelpyou);
	Addto(lcanihelpyou,							"MikeJDialog.Can_I_Help_You", 1);

	Clear(lNumbers_Thatllbe);
	Addto(lNumbers_Thatllbe,					"MikeJDialog.Thatll_Be", 1);

	//Clear(lNumbers_a);
	//Addto(lNumbers_a,							"MikeJDialog.a", 1);

	//Clear(lNumbers_1);
	//Addto(lNumbers_1,							"MikeJDialog.1", 1);

	Clear(lNumbers_2);
	Addto(lNumbers_2,							"MikeJDialog.2", 1);

	Clear(lNumbers_3);
	Addto(lNumbers_3,							"MikeJDialog.3", 1);

	Clear(lNumbers_4);
	Addto(lNumbers_4,							"MikeJDialog.4", 1);

	Clear(lNumbers_5);
	Addto(lNumbers_5,							"MikeJDialog.5", 1);

	Clear(lNumbers_10);
	Addto(lNumbers_10,							"MikeJDialog.10", 1);

	Clear(lNumbers_20);
	Addto(lNumbers_20,							"MikeJDialog.20", 1);

	Clear(lNumbers_40);
	Addto(lNumbers_40,							"MikeJDialog.40", 1);

	Clear(lNumbers_60);
	Addto(lNumbers_60,							"MikeJDialog.60", 1);

	Clear(lNumbers_80);
	Addto(lNumbers_80,							"MikeJDialog.80", 1);

	Clear(lNumbers_100);
	Addto(lNumbers_100,							"MikeJDialog.100", 1);

	Clear(lNumbers_200);
	Addto(lNumbers_200,							"MikeJDialog.200", 1);

	Clear(lNumbers_300);
	Addto(lNumbers_300,							"MikeJDialog.300", 1);

	Clear(lNumbers_400);
	Addto(lNumbers_400,							"MikeJDialog.400", 1);

	Clear(lNumbers_500);
	Addto(lNumbers_500,							"MikeJDialog.500", 1);

	Clear(lNumbers_Dollars);
	Addto(lNumbers_Dollars,						"MikeJDialog.dollars", 1);

	Clear(lNumbers_SingleDollar);
	Addto(lNumbers_SingleDollar,				"MikeJDialog.dollar", 1);

	Clear(lsellingitem);
	Addto(lsellingitem,							"MikeJDialog.Selling_Item", 1);
	Addto(lsellingitem,							"MikeJDialog.Selling_Item_2", 1);

	Clear(lIsThisEverything);
	Addto(lIsThisEverything,						"MikeJDialog.Is_This_Everything", 1);
	
	Clear(llackofmoney);
	Addto(llackofmoney,							"MikeJDialog.Lack_Of_Money", 1);

	Clear(lSignPetition);							
	Addto(lSignPetition,							"MikeJDialog.Sign_Petition_1", 1);
	Addto(lSignPetition,							"MikeJDialog.Sign_Petition_2", 1);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,						"MikeJDialog.Dont_Sign_Petition_1", 1);
	Addto(lDontSignPetition,						"MikeJDialog.Dont_Sign_Petition_2", 1);
	Addto(lDontSignPetition,						"MikeJDialog.Dont_Sign_Petition_3", 1);

	Clear(lPetitionBother);
	Addto(lPetitionBother,							"MikeJDialog.Petition_Bother_1", 1);
	Addto(lPetitionBother,							"MikeJDialog.Petition_Bother_2", 1);
	Addto(lPetitionBother,							"MikeJDialog.Petition_Bother_3", 1);

	Clear(lcallsecurity);
	Addto(lcallsecurity,							"MikeJDialog.Rowdy_Customer_1", 1);
	
	Clear(lrowdycustomer);
	Addto(lrowdycustomer,							"MikeJDialog.Rowdy_Customer_1", 1);
	
	Clear(lRWSemployee);
	Addto(lRWSemployee,							"MikeJDialog.RWS_Employee", 1);
	Addto(lrwsemployee,							"MikeJDialog.RWS_Employee_2", 1);
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
