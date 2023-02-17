///////////////////////////////////////////////////////////////////////////////
// Milo Y.
///////////////////////////////////////////////////////////////////////////////
class DialogMilo extends DialogMale;

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();
	
	Clear(lgreeting);
	Addto(lgreeting,							"BritMaleDialog.BritMale-Greeting-01DarlingSweetie", 1);
	
	Clear(lhotgreeting);
	Addto(lhotGreeting,							"BritMaleDialog.BritMale-Greeting-01DarlingSweetie", 1);
	
	Clear(lgreetingquestions);
	Addto(lGreetingquestions,						"BritMaleDialog.BritMale-GreetingQuestions-01HowAreYouPumpkin", 1);
	Addto(lGreetingquestions,						"BritMaleDialog.BritMale-GreetingQuestions-02HowsItHanging", 1);
	
	Clear(lHotgreetingquestions);
	Addto(lHotgreetingquestions,						"BritMaleDialog.BritMale-GreetingQuestions-01HowAreYouPumpkin", 1);
	Addto(lHotgreetingquestions,						"BritMaleDialog.BritMale-GreetingQuestions-02HowsItHanging", 1);
	
	Clear(lrespondtohotgreeting);
	Addto(lrespondtohotgreeting,						"BritMaleDialog.BritMale-No-01HahaNo", 1);
	Addto(lrespondtohotgreeting,						"BritMaleDialog.BritMale-DontSignPetition-01EwwGetAway", 1);
	
	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,						"BritMaleDialog.BritMale-GreetingResponses-01MightHaveAids", 1);
	Addto(lrespondtogreeting,						"BritMaleDialog.BritMale-GreetingResponses-02CondemnedForEternity", 1);
	Addto(lrespondtogreeting,						"BritMaleDialog.BritMale-GreetingResponses-03MightBeGay", 1);
	
	Clear(lrespondtogreetingresponse);
	Addto(lrespondtogreetingresponse,					"BritMaleDialog.BritMale-RespToGreetingResp-01WhoHurtYou", 1);
	Addto(lrespondtogreetingresponse,					"BritMaleDialog.BritMale-RespToGreetingResp-02WhatIsYourDamage", 1);
	Addto(lrespondtogreetingresponse,					"BritMaleDialog.BritMale-RespToGreetingResp-03TriggerWarning", 1);
	
	Clear(lHelloCop);
	Addto(lHelloCop,								"BritMaleDialog.BritMale-HelloCop-01ManInUniform", 1);
	Addto(lHelloCop,								"BritMaleDialog.BritMale-HelloCop-02BigTruncheon", 1);
	Addto(lHelloCop,								"BritMaleDialog.BritMale-HelloCop-03HelloOfficer", 1);
	
	Clear(lHelloGimp);
	Addto(lHelloGimp,								"BritMaleDialog.BritMale-HelloGimp-01StoleFavouriteOutfit", 1);
	Addto(lHelloGimp,								"BritMaleDialog.BritMale-HelloGimp-02FavouriteOutfitOnYou", 1);
	Addto(lHelloGimp,								"BritMaleDialog.BritMale-HelloGimp-03LoveThatOnYou", 1);

	Clear(lApologize);
	Addto(lApologize,								"BritMaleDialog.BritMale-Apologise-01ImSorry", 1);
	Addto(lApologize,								"BritMaleDialog.BritMale-Apologise-02BehalfOfPatriarche", 1);
	
	Clear(lyourewelcome);
	Addto(lyourewelcome,							"BritMaleDialog.BritMale-YoureWelcome-01OfCourseDarling", 1);
	Addto(lyourewelcome,							"BritMaleDialog.BritMale-YoureWelcome-01YouAreWelcome", 1);

	Clear(lno);
	Addto(lno,								"BritMaleDialog.BritMale-No-01HahaNo", 1);
	Addto(lno,								"BritMaleDialog.BritMale-No-02HaveToForceMe", 1);
	
	Clear(lyes);
	Addto(lyes,								"BritMaleDialog.BritMale-Yes-01UhFine", 1);
	Addto(lyes,								"BritMaleDialog.BritMale-Yes-02Whatever", 1);
	Addto(lyes,								"BritMaleDialog.BritMale-Yes-03Okay", 1);
	
	Clear(lthanks);
	Addto(lthanks,								"BritMaleDialog.BritMale-Thanks-01CheersCool", 1);
	
	Clear(lThatsGreat);
	Addto(lThatsGreat,							"BritMaleDialog.BritMale-ThatsGreat-01ThatIsFabulous", 1);
	Addto(lThatsGreat,							"BritMaleDialog.BritMale-ThatsGreat-02ThatIsFetch", 1);
	
	Clear(lGetDown);
	AddTo(lGetDown,								"BritMaleDialog.BritMale-GetDown-01AssInTheAir", 1);
	AddTo(lGetDown,								"BritMaleDialog.BritMale-GetDown-02OnAllFours", 1);
	AddTo(lGetDown,								"BritMaleDialog.BritMale-GetDown-03ShootAllOverYou", 1);

	Clear(lGetDownMP);
	AddTo(lGetDownMP,								"BritMaleDialog.BritMale-GetDown-01AssInTheAir", 1);
	AddTo(lGetDownMP,								"BritMaleDialog.BritMale-GetDown-02OnAllFours", 1);
	AddTo(lGetDownMP,								"BritMaleDialog.BritMale-GetDown-03ShootAllOverYou", 1);

	/*
	Clear(lCussing);
	Addto(lCussing,								"", 1);
	*/
	
	/*
	Clear(lgetdownscared);
	Addto(lgetdownscared,							"", 1);
	*/
	
	Clear(ldefiant);
	Addto(ldefiant,								"BritMaleDialog.BritMale-Defiant-01BitchPlease", 1);
	Addto(ldefiant,								"BritMaleDialog.BritMale-Defiant-02DarlingReally", 1);
	Addto(ldefiant,								"BritMaleDialog.BritMale-Defiant-03YoMamma1", 1);
	Addto(ldefiant,								"BritMaleDialog.BritMale-Defiant-03YoMamma2", 2);

	Clear(ldefiantline);
	Addto(ldefiantline,								"BritMaleDialog.BritMale-DefiantLine-01SuckADick", 1);
	Addto(ldefiantline,								"BritMaleDialog.BritMale-DefiantLine-02BlackBoyfriend", 1);
	Addto(ldefiantline,								"BritMaleDialog.BritMale-DefiantLine-03FuckingFeminists", 1);
	Addto(ldefiantline,								"BritMaleDialog.BritMale-DefiantLine-04WorseThanSarkeesian", 2);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"BritMaleDialog.BritMale-NearWeapon-01IveHadBigger", 1);
	Addto(lCloseToWeapon,						"BritMaleDialog.BritMale-NearWeapon-02AboutMySize", 1);
	Addto(lCloseToWeapon,						"BritMaleDialog.BritMale-NearWeapon-03HomosexualityDemandsBlood", 1);
	Addto(lCloseToWeapon,						"BritMaleDialog.BritMale-NearWeapon-04HairDemandsJustice", 1);
	
	Clear(ldecidetofight);
	Addto(ldecidetofight,							"BritMaleDialog.BritMale-LynchMob-03ComingForYou", 1);
	
	Clear(llaughing);
	Addto(llaughing,								"BritMaleDialog.BritMale-Laughing-01", 1);
	
	Clear(lSnickering);
	Addto(lSnickering,								"BritMaleDialog.BritMale-Snickering-01", 1);
	
	Clear(lOutOfBreath);
	Addto(lOutOfBreath,								"BritMaleDialog.BritMale-OutOfBreath-01", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,							"BritMaleDialog.BritMale-WatchingCrazy-01AreYouOnCrack", 1);
	Addto(lWatchingCrazy,							"BritMaleDialog.BritMale-WatchingCrazy-02ThatBitchCray", 1);
	Addto(lWatchingCrazy,							"BritMaleDialog.BritMale-WatchingCrazy-03ResultOfSingleMotherhood", 1);
	Addto(lWatchingCrazy,							"BritMaleDialog.BritMale-WatchingCrazy-04AfricanDance", 1);
	
	Clear(lshootingoverthere);
	Addto(lshootingoverthere,						"BritMaleDialog.BritMale-ShootingOverThere-01OfficerTheresAnAssailant", 1);
	Addto(lshootingoverthere,						"BritMaleDialog.BritMale-ShootingOverThere-02ThreateningTheQueen", 1);
	Addto(lshootingoverthere,						"BritMaleDialog.BritMale-ShootingOverThere-03SecondAmendment", 1);
	
	Clear(lkillingoverthere);
	Addto(lkillingoverthere,						"BritMaleDialog.BritMale-KillingOverThere-01CommunistRevolution", 1);
	Addto(lkillingoverthere,						"BritMaleDialog.BritMale-KillingOverThere-02BitchShootingPeople", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,								"BritMaleDialog.BritMale-Scream-01", 1);
	
	Clear(lscreamingonfire);
	Addto(lscreamingonfire,							"BritMaleDialog.BritMale-ScreamOnFire-01ImBurning", 1);
	Addto(lscreamingonfire,							"BritMaleDialog.BritMale-ScreamOnFire-02MyHair", 1);
	Addto(lscreamingonfire,							"BritMaleDialog.BritMale-ScreamOnFire-03DontWannaGetTanned", 1);
	Addto(lscreamingonfire,							"BritMaleDialog.BritMale-ScreamOnFire-04CleansingHomosexuality", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,								"BritMaleDialog.BritMale-Heroics-01TakeThisMF", 1);
	Addto(lDoHeroics,								"BritMaleDialog.BritMale-Heroics-02BloodyWanker", 1);
	Addto(lDoHeroics,								"BritMaleDialog.BritMale-Heroics-03BitchItIsOn", 1);
	Addto(lDoHeroics,								"BritMaleDialog.BritMale-Heroics-04AllOfThis", 1);
	
	Clear(lgettingpissedon);
	Addto(lgettingpissedon,							"BritMaleDialog.BritMale-PissedOn-01YoureNotBlack", 1);
	Addto(lgettingpissedon,							"BritMaleDialog.BritMale-PissedOn-02NotIntoThis", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,						"BritMaleDialog.BritMale-PissedOnAfter-01LiberalArtStudent", 1);
	Addto(laftergettingpissedon,						"BritMaleDialog.BritMale-PissedOnAfter-02CutMeACheque", 1);
	
	Clear(lwhatthe);
	Addto(lwhatthe,								"BritMaleDialog.BritMale-WhatThe-01WhatIsHappening", 1);
	Addto(lwhatthe,								"BritMaleDialog.BritMale-WhatThe-02YouWhatMate", 1);
	
	Clear(lseeingpisser);
	Addto(lseeingpisser,							"BritMaleDialog.BritMale-WhatThe-02YouWhatMate", 1);
	
	Clear(lSomethingIsGross);
	Addto(lSomethingIsGross,							"BritMaleDialog.BritMale-Gross-01Ewww", 1);
	Addto(lSomethingIsGross,							"BritMaleDialog.BritMale-Gross-02WorseThanATranny", 1);
	Addto(lSomethingIsGross,							"BritMaleDialog.BritMale-Gross-03DoneFuckedUpShit", 1);
	Addto(lSomethingIsGross,							"BritMaleDialog.BritMale-Gross-04ThatIsDisgusting", 1);
	
	Clear(lgothit);
	Addto(lgothit,								"BritMaleDialog.BritMale-Hit-01", 1);
	
	Clear(lAttacked);
	addto(lAttacked,								"BritMaleDialog.BritMale-Attacked-01KeepYourBitterness", 1);	
	addto(lAttacked,								"BritMaleDialog.BritMale-Attacked-02KeepGaysDown", 1);	
	addto(lAttacked,								"BritMaleDialog.BritMale-Attacked-03CouldYouNot", 1);	
	
	/*
	Clear(lGrunt);
	addto(lGrunt,								"", 1);	
	*/
	
	Clear(lPissing);
	Addto(lPissing,								"BritMaleDialog.BritMale-Pissing-01", 1);
	Addto(lPissing,								"BritMaleDialog.BritMale-Pissing-02", 1);
	
	/*
	Clear(lPissOnSelf);
	Addto(lPissOnSelf,							"WMaleDialog.wm_spitting", 1);
	
	Clear(lPissOutFireOnSelf);
	Addto(lPissOutFireOnSelf,					"WMaleDialog.wm_ahh", 1);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,					"WeaponSounds.sniper_zoombreathing", 1);
	*/
	
	/*
	Clear(lGotHealth);
	Addto(lGotHealth,							"", 1);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,						"", 1);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth,						"", 1);

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"", 1);	
	*/

	Clear(lbegforlife);
	Addto(lbegforlife,							"BritMaleDialog.BritMale-Begging-01MariahCareyWontForgive", 1);
	Addto(lbegforlife,							"BritMaleDialog.BritMale-Begging-02ImAVirgin", 1);
	Addto(lbegforlife,							"BritMaleDialog.BritMale-FrightenedApology-02BeyonceSucks", 1);
	Addto(lbegforlife,							"BritMaleDialog.BritMale-FrightenedApology-03ILovePokemon", 1);
	Addto(lbegforlife,							"BritMaleDialog.BritMale-FrightenedApology-04NeverWriteClickBait", 1);
	
	Clear(lbegforlifeMin);
	Addto(lbegforlifeMin,							"BritMaleDialog.BritMale-Begging-01MariahCareyWontForgive", 1);
	Addto(lbegforlifeMin,							"BritMaleDialog.BritMale-Begging-02ImAVirgin", 1);
	Addto(lbegforlifeMin,							"BritMaleDialog.BritMale-BeggingMin-01MurderTheQueen", 1);
	Addto(lbegforlifeMin,							"BritMaleDialog.BritMale-FrightenedApology-02BeyonceSucks", 1);
	Addto(lbegforlifeMin,							"BritMaleDialog.BritMale-FrightenedApology-03ILovePokemon", 1);
	Addto(lbegforlifeMin,							"BritMaleDialog.BritMale-FrightenedApology-04NeverWriteClickBait", 1);
	
	Clear(ldying);
	Addto(ldying,								"BritMaleDialog.BritMale-Dying-01DeaderThanSlingBacks", 1);
	Addto(ldying,								"BritMaleDialog.BritMale-Dying-02DeaderThanVersace", 1);
	Addto(ldying,								"BritMaleDialog.BritMale-Dying-03DeaderThanManolos", 1);

	Clear(lCrying);
	Addto(lCrying,								"BritMaleDialog.BritMale-Crying-01", 1);
	Addto(lCrying,								"BritMaleDialog.BritMale-Crying-02", 1);
	Addto(lCrying,								"BritMaleDialog.BritMale-Crying-03", 1);

	Clear(lfrightenedapology);
	Addto(lfrightenedapology,						"BritMaleDialog.BritMale-FrightenedApology-01IDidntMeanIt", 1);
	Addto(lfrightenedapology,						"BritMaleDialog.BritMale-FrightenedApology-02BeyonceSucks", 1);
	Addto(lfrightenedapology,						"BritMaleDialog.BritMale-FrightenedApology-03ILovePokemon", 1);
	Addto(lfrightenedapology,						"BritMaleDialog.BritMale-FrightenedApology-04NeverWriteClickBait", 1);

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"BritMaleDialog.BritMale-TrashTalk-01StrangleWithPearls", 1);
	Addto(ltrashtalk,							"BritMaleDialog.BritMale-TrashTalk-02CheckYouOut", 1);
	Addto(ltrashtalk,							"BritMaleDialog.BritMale-TrashTalk-03BitchReally", 1);
	Addto(ltrashtalk,							"BritMaleDialog.BritMale-TrashTalk-04YoureTheFaggot", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting,							"BritMaleDialog.BritMale-Fighting-01GiveItToMeAgain", 1);
	Addto(lWhileFighting,							"BritMaleDialog.BritMale-Fighting-02OhILikeIt", 1);
	Addto(lWhileFighting,							"BritMaleDialog.BritMale-Fighting-03TryHarder", 1);
	Addto(lWhileFighting,							"BritMaleDialog.BritMale-Fighting-04ILoveItRough", 1);
	Addto(lWhileFighting,							"BritMaleDialog.BritMale-Fighting-05WantSomeMore", 1);
	Addto(lWhileFighting,							"BritMaleDialog.BritMale-Fighting-06HitMeAgain", 1);
	
	Clear(laskcopwhatsup);
	Addto(laskcopwhatsup,							"BritMaleDialog.BritMale-TalkToCop-01CanIHelpYou", 1);
	Addto(laskcopwhatsup,							"BritMaleDialog.BritMale-TalkToCop-02WhatsTheProblem", 1);
	Addto(laskcopwhatsup,							"BritMaleDialog.BritMale-TalkToCop-03MayIServiceYou", 1);

	Clear(lratout);
	Addto(lratout,								"BritMaleDialog.BritMale-RatOut-01OverThereTheLiberal", 1);

	Clear(lfakeratout);
	Addto(lfakeratout,							"BritMaleDialog.BritMale-RatOutFake-01TotallyHim", 1);

	Clear(lcleanshot);
	Addto(lcleanshot,							"BritMaleDialog.BritMale-CleanShot-01MoveBitch", 1);
	
	Clear(lCleanMeleeHit);
	Addto(lCleanMeleeHit,						"BritMaleDialog.BritMale-CleanMeleeHit-01ForcedSubmission", 1);
	Addto(lCleanMeleeHit,						"BritMaleDialog.BritMale-CleanMeleeHit-02PissingMeOff", 1);

	/*
	Clear(lInhale);
	Addto(lInhale,								"WMaleDialog.wm_inhale", 1);
												
	Clear(lExhale);								
	Addto(lExhale,								"WMaleDialog.wm_exhale", 1);
	
	Clear(lEatingFood);
	Addto(lEatingFood,							"WMaleDialog.wm_mmm", 1);
	Addto(lEatingFood,							"WMaleDialog.wm_chewing", 1);
	Addto(lEatingFood,							"WMaleDialog.wm_smacking", 1);
	Addto(lEatingFood,							"WMaleDialog.wm_drinkingsucking", 1);
	*/

	Clear(lAfterEating);
	Addto(lAfterEating,							"BritMaleDialog.BritMale-AfterEating-01MmmMeat", 1);
	Addto(lAfterEating,							"BritMaleDialog.BritMale-AfterEating-02ILoveItRare", 1);

	/*
	Clear(lpleasureresponse);					
	Addto(lpleasureresponse,						"WMaleDialog.wm_ahh", 1);
	Addto(lpleasureresponse,						"WMaleDialog.wm_ohyeah", 1);

	Clear(laftersitdown);
	Addto(laftersitdown,							"WMaleDialog.wm_thatsaloadoff", 1);
	Addto(laftersitdown,							"WMaleDialog.wm_satisfiedsigh", 1);

	Clear(lSpitting);
	Addto(lSpitting,							"WMaleDialog.wm_shortingspitting", 1);
	Addto(lSpitting,							"WMaleDialog.wm_spitting", 1);
	*/
	
	Clear(lhmm);
	Addto(lhmm,									"BritMaleDialog.BritMale-Hmmm-01WhatIsThat", 1);	

	Clear(lfollowme);
	Addto(lfollowme,							"BritMaleDialog.BritMale-FollowMe-01", 1);	

	Clear(lStayHere);
	Addto(lStayHere,							"BritMaleDialog.BritMale-Stay-01", 1);

	Clear(lnoticedickout);
	Addto(lnoticedickout,							"BritMaleDialog.BritMale-NoticeDickOut-01UgliestPenis", 1);
	Addto(lnoticedickout,							"BritMaleDialog.BritMale-NoticeDickOut-02ThatAllYouGot", 1);
	Addto(lnoticedickout,							"BritMaleDialog.BritMale-NoticeDickOut-03DoubleThatSize", 1);
	Addto(lnoticedickout,							"BritMaleDialog.BritMale-NoticeDickOut-04GotYourNumber", 1);

	Clear(lilltakenumber);
	Addto(lilltakenumber,							"BritMaleDialog.BritMale-NoticeDickOut-05TakeANumber", 1);

	Clear(lmakedeposit);
	Addto(lmakedeposit,								"BritMaleDialog.BritMale-MakeDeposit-01", 1);

	Clear(lmakewithdrawal);
	Addto(lmakewithdrawal,							"BritMaleDialog.BritMale-MakeWithdrawal-01", 1);
	Addto(lmakewithdrawal,							"BritMaleDialog.BritMale-MakeWithdrawal-02", 1);
	Addto(lmakewithdrawal,							"BritMaleDialog.BritMale-MakeWithdrawal-03", 1);

	Clear(lconsumerbuy);
	Addto(lconsumerbuy,							"BritMaleDialog.BritMale-ConsumerBuy-01ThereYouGo", 1);

	Clear(lconteststoretransaction);
	Addto(lconteststoretransaction,						"BritMaleDialog.BritMale-ContestTransaction-01AreYouKidding", 1);
	
	Clear(lcontestbanktransaction);
	Addto(lcontestbanktransaction,						"BritMaleDialog.BritMale-ContestTransaction-01AreYouKidding", 1);

	Clear(lcarnageoccurred);
	Addto(lcarnageoccurred,							"BritMaleDialog.BritMale-CarnageOccurred-01ThanksObama", 1);
	Addto(lcarnageoccurred,							"BritMaleDialog.BritMale-CarnageOccurred-02WorseThanBeingOnWelfare", 1);

	Clear(lCallCat);
	Addto(lCallCat, 							"BritMaleDialog.BritMale-CallingCat-01HerePussy", 1);

	/*
	Clear(lHateCat);
	Addto(lHateCat, 							"WMaleDialog.wm_getoutfurball", 1);
	Addto(lHateCat, 							"WMaleDialog.wm_goddamcat", 1);
	*/

	Clear(lStartAttackingAnimal);
	Addto(lStartAttackingAnimal,				"BritMaleDialog.BritMale-AttackingAnimal-01SpawnOfSatan", 1);

	Clear(lGettingRobbed);	
	Addto(lGettingRobbed,							"BritMaleDialog.BritMale-GettingMugged-01AtLeastRapeMe", 1);
	Addto(lGettingRobbed,							"BritMaleDialog.BritMale-GettingMugged-02JustFuckMe", 1);

	Clear(lGettingMugged);	
	Addto(lGettingMugged,							"BritMaleDialog.BritMale-GettingMugged-01AtLeastRapeMe", 1);
	Addto(lGettingMugged,							"BritMaleDialog.BritMale-GettingMugged-02JustFuckMe", 1);

	Clear(lAfterMugged);	
	Addto(lAfterMugged,							"BritMaleDialog.BritMale-AfterMugged-01SomebodyStopHim", 1);
	Addto(lAfterMugged,							"BritMaleDialog.BritMale-AfterMugged-02NeedAHero", 1);

	Clear(lDoMugging);	
	Addto(lDoMugging,							"BritMaleDialog.BritMale-Mugging-01HandOverYourMoney", 1);
	Addto(lDoMugging,							"BritMaleDialog.BritMale-Mugging-02GiveMeYourCash", 1);
	Addto(lDoMugging,							"BritMaleDialog.BritMale-Mugging-03GiveMeTheCashBitch", 1);
	
	/*
	Clear(lQuestion);	
	Addto(lQuestion,							"WMaleDialog.wm_whyyouvebeentold", 1);
	Addto(lQuestion,							"WMaleDialog.wm_whatsomejustasked", 1);
	Addto(lQuestion,							"WMaleDialog.wm_whatareyoutalking", 1);
	Addto(lQuestion,							"WMaleDialog.wm_idontcare", 1);
	*/

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"BritMaleDialog.BritMale-GenericQuestion-01DigimonBetterThanPokemon", 1);
	Addto(lGenericQuestion,						"BritMaleDialog.BritMale-GenericQuestion-02WannaHearPoetry", 1);
	Addto(lGenericQuestion,						"BritMaleDialog.BritMale-GenericQuestion-03GameJournoThing", 1);

	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"BritMaleDialog.BritMale-GenericAnswer-01UpYourAss", 1);
	Addto(lGenericAnswer,						"BritMaleDialog.BritMale-GenericAnswer-02FullMacintosh", 1);

	Clear(lGenericFollowup);	
	Addto(lGenericFollowup,						"BritMaleDialog.BritMale-GenericFollowUp-01AreYouListening", 1);
	Addto(lGenericFollowup,						"BritMaleDialog.BritMale-GenericFollowUp-02ExcuseMe", 1);

	Clear(linvadeshome);	
	Addto(linvadeshome,							"BritMaleDialog.BritMale-InvadesHome-01ZoeQuinn", 1);
	Addto(linvadeshome,							"BritMaleDialog.BritMale-InvadesHome-02GetOutOfHere", 1);
	
/*
never used
	Clear(lactionoutsidehome);
	Addto(lactionoutsidehome,						"WMaleDialog.wm_whatsalltheracket", 1);
	Addto(lactionoutsidehome,						"WMaleDialog.wm_keepitdown", 1);
	Addto(lactionoutsidehome,						"WMaleDialog.wm_thisisaquiet", 1);
	Addto(lactionoutsidehome,						"WMaleDialog.wm_whosoutthere", 1);
	Addto(lactionoutsidehome,						"WMaleDialog.wm_whatsgoingonout", 1);
*/

	Clear(lsomeoneonfire);
	Addto(lsomeoneonfire,							"BritMaleDialog.BritMale-SomeoneOnFire-01OMG", 1);
	Addto(lsomeoneonfire,							"BritMaleDialog.BritMale-SomeoneOnFire-02SomebodyGetWater", 1);
	Addto(lsomeoneonfire,							"BritMaleDialog.BritMale-SomeoneOnFire-03HowImGonnaGo", 1);
	Addto(lsomeoneonfire,							"BritMaleDialog.BritMale-SomeoneOnFire-04PaidMyTaxes", 1);

	Clear(labouttopuke);
	Addto(labouttopuke,							"BritMaleDialog.BritMale-AboutToPuke-01JohnFlint", 1);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,							"BritMaleDialog.BritMale-Puke-01", 1);
	Addto(lbodyfunctions,							"BritMaleDialog.BritMale-Puke-02", 1);
	Addto(lbodyfunctions,							"BritMaleDialog.BritMale-Puke-03", 1);
	Addto(lbodyfunctions,							"BritMaleDialog.BritMale-Puke-04", 1);
	Addto(lbodyfunctions,							"BritMaleDialog.BritMale-Puke-05", 1);
	Addto(lbodyfunctions,							"BritMaleDialog.BritMale-Puke-06", 1);

	/*
	Clear(lGettingShocked);
	Addto(lGettingShocked,							"WMaleDialog.wm_vomit", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,								"HabibDialog.habib_ailili", 1);
	*/

	Clear(lCellPhoneTalk);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-01TriedSixOnce", 1);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-02UhHuh", 1);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-03IdiotsLikeYou", 1);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-04IDontHaveProblems", 1);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-05KeepingABoat", 1);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-06HomosexualityProfitable", 1);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-07HairlineNotReceding", 1);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-08LookMom", 1);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-09MostImportantFreedom", 1);
	Addto(lCellPhoneTalk,							"BritMaleDialog.BritMale-CellPhone-10PositiveReview", 1);
	
	/*
	Clear(lZealots);
	Addto(lZealots,							"WMaleDialog.wm_werenotzealots", 1);
	Addto(lZealots,							"WMaleDialog.wm_thegoodbooktoldme", 1);
	Addto(lZealots,							"WMaleDialog.wm_stopoppressingus", 1);
	*/
	
//	Clear(lNormalFastFood);
//	Addto(lNormalFastFood,							"WMaleDialog.wm_helloandwelcome", 1);
//	Addto(lNormalFastFood,							"WMaleDialog.wm_haveaniceday", 1);
//	Addto(lNormalFastFood,							"WMaleDialog.wm_mayilargifythat", 1);
//	Addto(lNormalFastFood,							"WMaleDialog.wm_hereyouareenjoy", 1);
//	Addto(lNormalFastFood,							"WMaleDialog.wm_pleasehelpyourself", 1);
	
	Clear(lKrotchyCustomerComment);
	Addto(lKrotchyCustomerComment,					"BritMaleDialog.BritMale-KrotchyCustomerComment-01ABitDark", 1);

	Clear(lKrotchyCustomerWant);
	Addto(lKrotchyCustomerWant,						"BritMaleDialog.BritMale-KrotchyCustomerWant-01GotAnyLeft", 1);

	Clear(lGaryAutograph);
	Addto(lGaryAutograph,							"BritMaleDialog.BritMale-GaryAutograph-01SayTheWillisThing", 1);

	/*
	Clear(lProtestorCut);
	Addto(lProtestorCut,							"WMaleDialog.wm_heybuddyifyourenot", 1);
	Addto(lProtestorCut,							"WMaleDialog.wm_yeahyouprobablyeat", 1);
	*/
	
	Clear(ldudedead);
	Addto(ldudedead,							"BritMaleDialog.BritMale-DudeDead-01BlameIanChong", 1);
	Addto(ldudedead,							"BritMaleDialog.BritMale-DudeDead-02FaultOfLiberals", 1);
	Addto(ldudedead,							"BritMaleDialog.BritMale-DudeDead-03SocialJusticeWarriors", 1);
	Addto(ldudedead,							"BritMaleDialog.BritMale-DudeDead-04ShouldntReadKotaku", 1);
	Addto(ldudedead,							"BritMaleDialog.BritMale-DudeDead-05HeReadPolygon", 1);

	Clear(lKickDead);
	Addto(lKickDead,							"BritMaleDialog.BritMale-KickDead-01BackToTheGhetto", 1);

	Clear(lNameCalling);
	Addto(lNameCalling,							"BritMaleDialog.BritMale-TrashTalk-04YoureTheFaggot", 1);

	Clear(lRogueCop);
	Addto(lRogueCop,							"BritMaleDialog.BritMale-RogueCop-01LetMeVineThis", 1);
	Addto(lRogueCop,							"BritMaleDialog.BritMale-RogueCop-02GonnaCallEveryone", 1);

	Clear(lgetbumped);
	Addto(lgetbumped,							"BritMaleDialog.BritMale-Bumped-01ExcuseYou", 1);

	Clear(lGetMad);
	Addto(lGetMad,								"BritMaleDialog.BritMale-Bumped-01ExcuseYou", 1);

	Clear(lLynchMob);
	Addto(lLynchMob,							"BritMaleDialog.BritMale-LynchMob-01ItsHim", 1);
	Addto(lLynchMob,							"BritMaleDialog.BritMale-LynchMob-02OMGItsHim", 1);
	Addto(lLynchMob,							"BritMaleDialog.BritMale-LynchMob-03ComingForYou", 1);

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"BritMaleDialog.BritMale-LynchMob-03ComingForYou", 1);

	Clear(lnextinline);
	Addto(lnextinline,							"BritMaleDialog.BritMale-NextInLine-01NextPersonInLine", 1);
	
	Clear(lhelpyouoverhere);
	Addto(lhelpyouoverhere,							"BritMaleDialog.BritMale-NextInLine-02HelpYouOverHere", 1);

	Clear(lsomeonecuts);
	Addto(lsomeonecuts,							"BritMaleDialog.BritMale-SomeoneCuts-01BackOfTheLine", 1);

	Clear(lpleasemoveforward);
	Addto(lpleasemoveforward,						"BritMaleDialog.BritMale-PleaseMoveForward-01PleaseMoveForward", 1);

	Clear(lcanihelpyou);
	Addto(lcanihelpyou,							"BritMaleDialog.BritMale-PleaseMoveForward-02CanIHelpYou", 1);
	Addto(lcanihelpyou,							"BritMaleDialog.BritMale-PleaseMoveForward-03MayIServiceYou", 1);

	Clear(lNumbers_Thatllbe);
	Addto(lNumbers_Thatllbe,					"BritMaleDialog.BritMale-NumbersThatllBe-OkayThatllBe", 1);

	Clear(lNumbers_a);
	Addto(lNumbers_a,							"BritMaleDialog.BritMale-NumbersThatllBe-1", 1);

	Clear(lNumbers_1);
	Addto(lNumbers_1,							"BritMaleDialog.BritMale-NumbersThatllBe-1", 1);

	Clear(lNumbers_2);
	Addto(lNumbers_2,							"BritMaleDialog.BritMale-NumbersThatllBe-2", 1);

	Clear(lNumbers_3);
	Addto(lNumbers_3,							"BritMaleDialog.BritMale-NumbersThatllBe-3", 1);

	Clear(lNumbers_4);
	Addto(lNumbers_4,							"BritMaleDialog.BritMale-NumbersThatllBe-4", 1);

	Clear(lNumbers_5);
	Addto(lNumbers_5,							"BritMaleDialog.BritMale-NumbersThatllBe-5", 1);

	Clear(lNumbers_10);
	Addto(lNumbers_10,							"BritMaleDialog.BritMale-NumbersThatllBe-10", 1);

	Clear(lNumbers_20);
	Addto(lNumbers_20,							"BritMaleDialog.BritMale-NumbersThatllBe-20", 1);

	Clear(lNumbers_40);
	Addto(lNumbers_40,							"BritMaleDialog.BritMale-NumbersThatllBe-40", 1);

	Clear(lNumbers_60);
	Addto(lNumbers_60,							"BritMaleDialog.BritMale-NumbersThatllBe-60", 1);

	Clear(lNumbers_80);
	Addto(lNumbers_80,							"BritMaleDialog.BritMale-NumbersThatllBe-80", 1);

	Clear(lNumbers_100);
	Addto(lNumbers_100,							"BritMaleDialog.BritMale-NumbersThatllBe-100", 1);

	Clear(lNumbers_200);
	Addto(lNumbers_200,							"BritMaleDialog.BritMale-NumbersThatllBe-200", 1);

	Clear(lNumbers_300);
	Addto(lNumbers_300,							"BritMaleDialog.BritMale-NumbersThatllBe-300", 1);

	Clear(lNumbers_400);
	Addto(lNumbers_400,							"BritMaleDialog.BritMale-NumbersThatllBe-400", 1);

	Clear(lNumbers_500);
	Addto(lNumbers_500,							"BritMaleDialog.BritMale-NumbersThatllBe-500", 1);

	Clear(lNumbers_Dollars);
	Addto(lNumbers_Dollars,						"BritMaleDialog.BritMale-NumbersThatllBe-Dollars", 1);

	Clear(lNumbers_SingleDollar);
	Addto(lNumbers_SingleDollar,				"BritMaleDialog.BritMale-NumbersThatllBe-Dollar", 1);

	Clear(lsellingitem);
	Addto(lsellingitem,							"BritMaleDialog.BritMale-SellingItem-01GreatThankYou", 1);

	Clear(lIsThisEverything);
	Addto(lIsThisEverything,						"BritMaleDialog.BritMale-SellingItem-02IsThisEverything", 1);
	
	Clear(llackofmoney);
	Addto(llackofmoney,							"BritMaleDialog.BritMale-LackOfMoney-01NeedMoreMoney", 1);

	Clear(lSignPetition);							
	Addto(lSignPetition,							"BritMaleDialog.BritMale-SignPetition-01OMGFine", 1);
	Addto(lSignPetition,							"BritMaleDialog.BritMale-SignPetition-02JesusFine", 1);

	Clear(lDontSignPetition);
	Addto(lDontSignPetition,						"BritMaleDialog.BritMale-DontSignPetition-01EwwGetAway", 1);
	Addto(lDontSignPetition,						"BritMaleDialog.BritMale-DontSignPetition-02CharityPerson", 1);
	Addto(lDontSignPetition,						"BritMaleDialog.BritMale-DontSignPetition-03CouldYouFuckOff", 1);
	Addto(lDontSignPetition,						"BritMaleDialog.BritMale-DontSignPetition-04FuckOff1", 1);
	Addto(lDontSignPetition,						"BritMaleDialog.BritMale-DontSignPetition-04FuckOff2", 1);

	Clear(lPetitionBother);
	Addto(lPetitionBother,							"BritMaleDialog.BritMale-PetitionBother-01LeaveMeAlone", 1);

	Clear(lcallsecurity);
	Addto(lcallsecurity,							"BritMaleDialog.BritMale-RowdyCustomer-01MenInUniform", 1);
	
	Clear(lrowdycustomer);
	Addto(lrowdycustomer,							"BritMaleDialog.BritMale-RowdyCustomer-01MenInUniform", 1);
	
	Clear(lRWSemployee);
	Addto(lRWSemployee,							"BritMaleDialog.BritMale-RWSEmployee-01VinceWantsToSeeYou", 1);

	/*
	Clear(lCityWorker);
	Addto(lCityWorker,							"WMaleDialog.wm_city_andletthatbe", 1);

	Clear(lJunkyard_DudeBuyingPart);
	Addto(lJunkyard_DudeBuyingPart,				"WMaleDialog.wm_junkyard_yeahivegot", 1);

	Clear(lJunkyard_DogsGotOut);
	Addto(lJunkyard_DogsGotOut,					"WMaleDialog.wm_junkyard_wholetthedogsou", 1);
	*/
	
	/*
	Clear(lChampPhotoReaction);
	Addto(lChampPhotoReaction,	"", 1);
	*/

	/*
	Clear(lPhoto_FindWiseWang);
	Addto(lPhoto_FindWiseWang,					"PL-Dialog.MondayA.WMale-SpeakToTheWiseMan", 1);

	Clear(lNumbers_6);
	AddTo(lNumbers_6,							"PL-Dialog.TuesdayA.6", 1);
	Clear(lNumbers_7);
	AddTo(lNumbers_7,							"PL-Dialog.TuesdayA.7", 1);
	Clear(lNumbers_8);
	AddTo(lNumbers_8,							"PL-Dialog.TuesdayA.8", 1);
	Clear(lNumbers_9);
	AddTo(lNumbers_9,							"PL-Dialog.TuesdayA.9", 1);
	Clear(lNumbers_11);
	AddTo(lNumbers_11,							"PL-Dialog.TuesdayA.11", 1);
	Clear(lNumbers_12);
	AddTo(lNumbers_12,							"PL-Dialog.TuesdayA.12", 1);
	Clear(lNumbers_13);
	AddTo(lNumbers_13,							"PL-Dialog.TuesdayA.13", 1);
	Clear(lNumbers_14);
	AddTo(lNumbers_14,							"PL-Dialog.TuesdayA.14", 1);
	Clear(lNumbers_15);
	AddTo(lNumbers_15,							"PL-Dialog.TuesdayA.15", 1);
	Clear(lNumbers_16);
	AddTo(lNumbers_16,							"PL-Dialog.TuesdayA.16", 1);
	Clear(lNumbers_17);
	AddTo(lNumbers_17,							"PL-Dialog.TuesdayA.17", 1);
	Clear(lNumbers_18);
	AddTo(lNumbers_18,							"PL-Dialog.TuesdayA.18", 1);
	Clear(lNumbers_19);
	AddTo(lNumbers_19,							"PL-Dialog.TuesdayA.19", 1);
	Clear(lNumbers_30);
	AddTo(lNumbers_30,							"PL-Dialog.TuesdayA.30", 1);
	Clear(lNumbers_50);
	AddTo(lNumbers_50,							"PL-Dialog.TuesdayA.50", 1);
	Clear(lNumbers_70);
	AddTo(lNumbers_70,							"PL-Dialog.TuesdayA.70", 1);
	Clear(lNumbers_90);
	AddTo(lNumbers_90,							"PL-Dialog.TuesdayA.90", 1);
	Clear(lNumbers_600);
	AddTo(lNumbers_600,							"PL-Dialog.TuesdayA.600", 1);
	Clear(lNumbers_700);
	AddTo(lNumbers_700,							"PL-Dialog.TuesdayA.700", 1);
	Clear(lNumbers_800);
	AddTo(lNumbers_800,							"PL-Dialog.TuesdayA.800", 1);
	Clear(lNumbers_900);
	AddTo(lNumbers_900,							"PL-Dialog.TuesdayA.900", 1);
	Clear(lCCCP_Cashier_Welcome);
	AddTo(lCCCP_Cashier_Welcome, "PL-Dialog.MondayB.Receptionist-WelcomeCCCP", 1);
	Clear(lCCCP_CheckKennels);
	AddTo(lCCCP_CheckKennels, "PL-Dialog.MondayB.Receptionist-CheckAroundTheBack", 1);
	Clear(lArcade_Yeeland_MoralGrounds);
	AddTo(lArcade_Yeeland_MoralGrounds, "PL-Dialog.TuesdayB.ArcadeOwner-1MoralGrounds", 1);
	Clear(lArcade_Yeeland_MeetMeInBack);
	AddTo(lArcade_Yeeland_MeetMeInBack, "PL-Dialog.TuesdayB.ArcadeOwner-2YouGotSpunk", 1);
	Clear(lKaraoke_Response1);
	AddTo(lKaraoke_Response1,					"PL-Dialog2.ThursdayErrandC.GenericMaleBystander-1Boo", 1);
	AddTo(lKaraoke_Response1,					"PL-Dialog2.ThursdayErrandC.GenericMaleBystander-1ThatReallySucked", 1);
	Clear(lKaraoke_Response2);
	AddTo(lKaraoke_Response2,					"PL-Dialog2.ThursdayErrandC.GenericMaleBystander-1GetOffTheStage", 1);
	AddTo(lKaraoke_Response2,					"PL-Dialog2.ThursdayErrandC.GenericMaleBystander-1YouSuck", 1);
	
	Clear(lSneezing);
	AddTo(lSneezing, "WMaleDialog.MSneezing01", 1);
	AddTo(lSneezing, "WMaleDialog.MSneezing02", 1);
	*/	
}