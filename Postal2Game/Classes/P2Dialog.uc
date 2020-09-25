///////////////////////////////////////////////////////////////////////////////
// P2Dialog
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all dialog in this game.
//
///////////////////////////////////////////////////////////////////////////////
//
// OVERVIEW
// --------
//
// This class defines the basic mechanism for playing lines of dialog and
// lists all the available lines of dialog for all the characters.
//
// Each specific character (male, female, dude, priest) will have its own
// class extended from this one.  Each of those classes will assign sounds
// to one or more of the available lines.  This way, each character can
// use a different sound (voice) for any particular line.
//
// The sound assignments are done in the FillInLines() function.  It can
// decide to assign no sounds to a particular line, in which case nothing
// will be played if that line is requested, or it can assign multiple
// sounds to a particular line, in which case a different sound is played
// each time that line is requested.
//
// Derived classes can be organized into a typical class hierarchy such that
// sounds assigned by a base class are "inherited" by any derived classes,
// which can then override those sounds or assign their own.  This magic can
// be had by calling FillInLines() in the super class first, thereby allowing
// it to perform its assignments first.  After that, the derived class can
// do whatever it wants.  Alternatively, the derived class can NOT call the
// super class, but then there's no reason to extend from that class in the
// first place.
//
// IMPORTANT!
// When filling in lines, the Clear() function MUST be called at least
// once for any line that has anything being added to it!  In some cases
// a particular class may want to simply add lines to those that the super
// already added.  In this case, the extended class does not have to call
// Clear() because the super will have already called it.  That's assuming
// the super DOES call it, of course!  The point is, someone has to call
// Clear() because FillInLines() may be called multiple times in case
// various dialog options are changed by the user.  If Clear() isn't called,
// then the same sounds will be added over and over to the same line,
// resulting in odd repeat problems.  Nothing horrible, but worth noting.
//
///////////////////////////////////////////////////////////////////////////////
class P2Dialog extends FPSDialog
	config(system)
	abstract;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

const IMPORTANT_DIALOG_VOLUME	=	1.0;
const IMPORTANT_DIALOG_RADIUS	=	256.0;
const DIALOG_VOLUME				=	0.9;
const DIALOG_RADIUS				=	128.0;

const LOG_MISSING_DIALOG = 0;	// we'll turn this off on release, so P2 players don't get logspammed with missing PL lines

const NUMBER_SYSTEM_MAX	=	900;		// This is how high our number system goes, like 1, 2, 3...100, 200...500

// This determines whether sounds are preloaded (during PostBeginPlay) or if
// they are loaded right before they are played for the first time.
var() globalconfig bool			Preload;

// This is a user-configurable value that determines how much memory should be
// used by dialog.  The values are: 1=low, 2=normal, 3=high.
var() globalconfig int			MemUsage;

// This is for testing only.  It loads every known piece of dialog so we can
// check if any of the lines failed to load.
// WARNING: Must be globalconfig so the same value applies to all instances of this class!!!
var() globalconfig bool			bTestMode;


// This determines whether to filter out lines of dialog that contain foul
// language.  As far as the code is concerned, we simply filter out any lines
// that are flagged as containing foul language.  However, some lines that
// contain foul language are NOT flagged as such because they are important
// to the game and can't be dropped.  Just thought I'd mention that here.
var() globalconfig bool			FilterFoulLanguage;

// This determines whether to bleep out any foul language.
var() globalconfig bool			BleepFoulLanguage;

var array<Bleeper>				Bleepers;

// Some of the lines are a bit too loud, and I'm not going to go back and reprocess all those damn lines in Audacity
// so we just set the volume here, on a class-by-class basis.
var() float VolumeMult;

// These are *ALL* the possible lines that *ANY* characters can say.

// General dialog
var SLine lNo;
var SLine lYes;
var SLine lGreeting;
var SLine lHotGreeting;
var SLine lGreetingQuestions;
var SLine lHotGreetingQuestions;
var SLine lRespondToGreeting;
var SLine lRespondToHotGreeting;
var SLine lRespondToGreetingResponse;
var SLine lHelloCop;
var SLine lHelloGimp;
var SLine lPositiveResponse;
var SLine lNegativeResponse;
var SLine lNegativeResponseCashier;
var SLine lApologize;
var SLine lYoureWelcome;
var SLine lAcceptDeal;
var SLine lDontAcceptDeal;
var SLine lDoHeroics;
var SLine lSeeingPisser;
var SLine lSomethingIsGross;
var SLine lCleanShot;
var SLine lCleanMeleeHit;
var SLine lLeaderFormsGroup;
var SLine lBullyTalk;
var SLine lPleasureResponse;
var SLine lInhale;
var SLine lExhale;
var SLine lAfterSitDown;
var SLine lCheckWatch;
var SLine lHmm;
var SLine lPickNose;
var SLine lFollowMe;
var SLine lStayHere;
var SLine lEatingFood;
var SLine lAfterEating;
var SLine lSpitting;
var SLine lIllTakeNumber;
var SLine lMakeDeposit;
var SLine lMakeWithDrawal;
var SLine lConsumerBuy;
var SLine lContestStoreTransaction;
var SLine lContestBankTransaction;
var SLine lGoPostal;
var SLine lGettingRobbed;
var SLine lAfterMugged;
var SLine lGettingMugged;
var SLine lDoMugging;
var SLine lCallCat;
var SLine lHateCat;
var SLine lCallAnimal;
var SLine lStartAttackingAnimal;
var SLine lQuestion;
var SLine lGenericQuestion;
var SLine lGenericAnswer;
var SLine lGenericFollowup;
var SLine lGenericGoodbye;
var SLine lInvadesHome;
//var SLine lActionOutsideHome;
var SLine lSomeoneOnFire;
var SLine lAboutToPuke;
var SLine lBodyFunctions;
var SLine lGettingShocked;
var SLine lCellPhoneTalk;
var SLine lZealots;
var SLine lNormalFastFood;
var SLine lShotCandidate;
var SLine lKrotchyCustomerComment;
var SLine lKrotchyCustomerWant;
var SLine lKrotchyCustomerLying;
var SLine lPostalWorkers;
var SLine lGaryAutograph;
var SLine lLynchMob;
var SLine lSeesEnemy;
var SLine lProtestorCut;
var SLine lDudeDead;
var SLine lKickDead;
var SLine lRogueCop;
var SLine lGetBumped;
var SLine lGetMad;
var SLine lRWSEmployee;
var SLine lCityWorker;
var SLine lNextInLine;
var SLine lHelpYouOverHere;
var SLine lSomeoneCuts;
var SLine lPleaseMoveForward;
var SLine lCanIHelpYou;
var SLine lIsThisEverything;
var SLine lNumbers_Thatllbe;
var SLine lNumbers_a;
var SLine lNumbers_1;
var SLine lNumbers_2;
var SLine lNumbers_3;
var SLine lNumbers_4;
var SLine lNumbers_5;
var SLine lNumbers_6;	// PL
var SLine lNumbers_7;	// PL
var SLine lNumbers_8;	// PL
var SLine lNumbers_9;	// PL
var SLine lNumbers_10;
var SLine lNumbers_11;	// PL
var SLine lNumbers_12;	// PL
var SLine lNumbers_13;	// PL
var SLine lNumbers_14;	// PL
var SLine lNumbers_15;	// PL
var SLine lNumbers_16;	// PL
var SLine lNumbers_17;	// PL
var SLine lNumbers_18;	// PL
var SLine lNumbers_19;	// PL
var SLine lNumbers_20;
var SLine lNumbers_30;	// PL
var SLine lNumbers_40;
var SLine lNumbers_50;	// PL
var SLine lNumbers_60;
var SLine lNumbers_70;	// PL
var SLine lNumbers_80;
var SLine lNumbers_90;	// PL
var SLine lNumbers_100;
var SLine lNumbers_200;
var SLine lNumbers_300;
var SLine lNumbers_400;
var SLine lNumbers_500;
var SLine lNumbers_600;	// PL
var SLine lNumbers_700;	// PL
var SLine lNumbers_800;	// PL
var SLine lNumbers_900;	// PL
var SLine lNumbers_Dollars;
var SLine lNumbers_SingleDollar;
var SLine lSellingItem;
var SLine lAfterSellingItem;
var SLine lLackOfMoney;
var SLine lCallSecurity;
var SLine lRowdyCustomer;
var SLine lScientist;
var SLine lLunatic;
var SLine lInMyWay;
var SLine lThanks;
var SLine lThatsGreat;
var SLine lGetDown;
var SLine lGetDownScared;
var SLine lGetDownMP; // get downs and taunts
var SLine lLaughing;
var SLine lSnickering;
var SLine lOutOfBreath;
var SLine lWatchingCrazy;
var SLine lApplauding;
var SLine lPuking;
var SLine lScreaming;
var SLine lScreamingOnFire;
var SLine lCrying;
var SLine lSniveling;
var SLine lDefiant;
var SLine lDefiantLine;
var SLine lTrashTalk;					// yell at attacker from safe distance
var SLine lNameCalling;
var SLine lFrightenedApology;
var SLine lCarnageOccurred;
var SLine lNoticeDickOut;
var SLine lShootingOverThere;
var SLine lKillingOverThere;
var SLine lGettingPissedOn; 
var SLine lAfterGettingPissedOn;
var SLine lWhatThe;
var SLine lAskCopWhatsUp;
var SLine lRatOut;
var SLine lFakeRatOut;
var SLine lGotHit;
var SLine lGotHitInCrotch;
var SLine lAttacked; //similar to lgothit, just don't say 'i got hit!', becuase you're not really hurt yet
var SLine lCloseToWeapon;
var SLine lGetOutOfTheWay;
var SLine lDecideToFight;
var SLine lBattleCry;
var SLine lWhileFighting;
var SLine lBegForLife;
var SLine lBegForLifeMin;
var SLine lDying;						// can be used repeatedly while dying
var SLine lLastWords;					// absolute final words before death
var SLine lSignPetition;
var SLine lDontSignPetition;
var SLine lPetitionBother;

// Cop dialog
var SLine lCop_SomeoneDisobeyed;
var SLine lCop_GoingToInvestigate;
//var SLine lCop_GotPissedOn;
var SLine lCop_NoticeIllegalThing;
var SLine lCop_NoticeLegalGun;
var SLine lCop_NoticeGasPouring;
var SLine lCop_TurnAround1;
var SLine lCop_TurnAround2;
var SLine lCop_Nevermind;
var SLine lCop_CallForBackup;
var SLine lCop_WhoFiredWeapon;
var SLine lCop_WhoShotMe;
var SLine lCop_Freeze1;
var SLine lCop_Freeze2;
var SLine lCop_Freeze3;
var SLine lCop_PutDownWeapon1;
var SLine lCop_PutDownWeapon2;
var SLine lCop_PutAwayDick1;
var SLine lCop_PutAwayDick2;
var SLine lCop_UnderArrest;
var SLine lCop_HoldStill;
var SLine lCop_Miranda;
var SLine lCop_NothingToSee;
var SLine lCop_CopOuttaLine;
var SLine lCop_SurpriseSomeone;
var SLine lCop_Disappointment;
var SLine lCop_SuspectSighted;
var SLine lCop_RadioBack;
//var SLine lCop_Radio;		this is currently handled as seperate sounds in the PoliceController.

// Military dialog
var SLine lMil_MoveOut;
var SLine lMil_ManDown;
var SLine lMil_OverThere;
var SLine lMil_PickLeader;
var SLine lMil_NewLeader;
var SLine lMil_Commands;
var SLine lMil_AcceptCommand;
var SLine lMil_FindCoward;
var SLine lMil_RoomSecure;
var SLine lMil_BystanderHelp;

// Dude dialog
var SLine lDude_GottaBeKidding;
var SLine lDude_Random;
var SLine lDude_DidSomethingCool;
var SLine lPissing;
var SLine lPissOnSelf;
var SLine lPissOutFireOnSelf;
var SLine lDude_EnteringHabibsStore;
var SLine lDude_AfterKillingPeople;
var SLine lDude_PickingUpWeapon;
var SLine lDude_CallingCat;
var SLine lDude_Arrested;
var SLine lDude_EscapeJail;
var SLine lDude_JailHint;
var SLine lDude_BecomingCop; // Starting to put on cop clothes
var SLine lDude_NowIsCop;	// Just finshed dressing as cop
var SLine lDude_NowIsDude;
var SLine lDude_AttackAsCop;
var SLine lDude_FirstSeenWithWeapon;
var SLine lDude_WeaponFirstUse;
var SLine lDude_ThrowGrenade;
var SLine lDude_KillWithGun;
var SLine lDude_KillWithProjectile;
var SLine lDude_KillWithMelee;
var SLine lDude_PlayerCheating;
var SLine lDude_PlayerSissy;

// This got replaced with the above, slightly more specific kill categories
//var SLine lDude_RandomKilling;

var SLine lDude_QuickKills;
var SLine lDude_QuickKills2;
var SLine lDude_BrickTexture;
var SLine lDude_ReusedPeople;
var SLine lDude_BurningPeople;
var SLine lDude_ShootMinorities;
var SLine lDude_ShootGays;
var SLine lDude_ShootOlds;
var SLine lDude_ShootBum;
var SLine lDude_RetortToNameCalling;
//var SLine lDude_OutOfMoney;		this got moved into lLackOfMoney for normal people, dude just overrides it there
var SLine lDude_LongLine;
var SLine lDude_SniperBreathing;
var SLine lDude_RandomLevel;
var SLine lDude_CantBeGood;
var SLine lGrunt;
var SLine lCussing;
var SLine lDude_CloseEnough;
//var SLine lDude_Suicide;	Not needed, played locally
var SLine lDude_Arcade;
var SLine lDude_Bum;
var SLine lDude_GetFired;
var SLine lDude_FreeHealth;
var SLine lDude_CureSelf;
var SLine lGotHealth;
var SLine lGotHealthFood;
var SLine lDude_CuredGonorrhea;
var SLine lGotCrackHealth;
var SLine lDude_SmokedCatnip;
var SLine lDude_NeedMoreCrackHealth;
var SLine lDude_GotHurtByCrack;
var SLine lDude_LowHealth;
var SLine lDude_VotingBooth;
var SLine lDude_EnterHabibs;
var SLine lDude_EnterHabibsTestes;
var SLine lDude_SeeTestes;
var SLine lDude_CallForHabib;
var SLine lDude_KillHabib;
var SLine lDude_Petition1;
var SLine lDude_Petition2;
var SLine lDude_Petition3;
var SLine lDude_CollectBalk;
var SLine lDude_ConfessSins;
var SLine lDude_LookForTree;
var SLine lDude_PissOnGrave;
var SLine lDude_GimpBoxWakeUp;
var SLine lDude_IsTheGimp;
var SLine lDude_WalkingAsGimp;
var SLine lDude_HaveToPee;
var SLine lDude_HasDisease;
var SLine lDude_BuyAlternator;
var SLine lDude_KillJunkyardGuy;
var SLine lDude_TalkToKrotchy;
var SLine lDude_NoKrotchy;
var SLine lDude_KillKrotchy;
var SLine lDude_FindToy;
var SLine lDude_BribeKrotchyMoney;
var SLine lDude_BribeKrotchyBook;
var SLine lDude_BuySteaks;
var SLine lDude_KillReception;
var SLine lDude_FindSteaks;
var SLine lDude_GetNormalClothes;
var SLine lDude_PoundWorker;
var SLine lDude_CityWorker;
var SLine lDude_SeesChamp;
var SLine lDude_KillChamp;
var SLine lDude_BookStore;
var SLine lDude_GaryTalk1;
var SLine lDude_GaryTalk2;
var SLine lDude_GaryBullhorn;
var SLine lDude_KillGary;
//var SLine lDude_GaryBloodyBook;
var SLine lDude_DropOffBook;
var SLine lDude_BuyNapalm;
var SLine lDude_KillNapalm;
var SLine lDude_FindNapalm;
var SLine lDude_PayTraffic;
var SLine lDude_PayTraffic2;
//var SLine lDude_BuyStamps;
var SLine lDude_GetPackage;
var SLine lDude_KillPostalWorker;
var SLine lDude_GetLunch;
var SLine lDude_KillFastFood;
var SLine lDude_CashingPaycheck;
var SLine lDude_KillBankTeller;
var SLine lDude_RobbersShowUp;
var SLine lDude_EmptyVault;
var SLine lDude_UncleDaveGreeting;
var SLine lDude_GiveToUncleDave;
var SLine lDude_DayChallenge;
var SLine lDude_NeedsItem;
var SLine lDude_KillLibrary;
var SLine lDude_RunRegister;
var SLine lDude_SaveTooMuch;

// Dude unlocked achievement
var SLine lDude_AchievementUnlocked;
// Dude progressing with achievement
var SLine lDude_AchievementProgress;
// Dude unlocked a grindy achievement
var SLine lDude_AchievementUnlockedGrind;

// Dude flips you off
var SLine lDude_FuckYou;

// Habib dialog
var SLine lHabib_Taunt;
var SLine lHabib_Bother;

// Vince
var SLine lVince_Greeting;
var SLine lVince_GreetingResponse;
var SLine lVince_Fired;
var SLine lVince_Insults;
var SLine lVince_GetCheck;

// Arcade game player
var SLine lArcadePlayer;

// Protestors
var SLine lProtest_Church;
var SLine lProtest_Labs;
var SLine lProtest_Books;
var SLine lProtest_Meat;
var SLine lProtest_Games;

// Bank teller
var SLine lTeller_Withdrawal;
var SLine lTeller_Deposit;
var SLine lTeller_UpdateAccount;

// Priest
var SLine lPriest_BlessYou;
var SLine lPriest_Confession1;
var SLine lPriest_Confession2;
var SLine lPriest_Mumble;
var SLine lPriest_Next;

// Junkyard seller
var SLine lJunkyard_DudeBuyingPart;
var SLine lJunkyard_DogsGotOut;

// meat seller
var SLine lMeatSeller_GoBackThere;

// Napalm receptionist
var SLine lNapalm_Directions;
var SLine lNapalm_Police;

// Librarian
var SLine lLibrarian_Quiet;
var SLine lLibrarian_QuietNoKilling;
var SLine lLibrarian_LateFee;

// Gary Coleman
var SLine lGary_ResponseToIdiots;
var SLine lGary_GivingAutograph;
var SLine lGary_GivingAutographToDude;
var SLine lGary_ToCops;
var SLine lGary_NonViolent;

// Krotchy
var SLine lKrotchy_HaveANiceDay;
var SLine lKrotchy_HeyKids;
var SLine lKrotchy_SoldOut1;
var SLine lKrotchy_SoldOut2;
var SLine lKrotchy_TakesBribe;

// Redneck

// Postal worker woman
var SLine lPostalReception_GotPackage1;
var SLine lPostalReception_GotPackage2;

// Nurse at the free health clinic
var SLine lNurse_CheckProblem;
var SLine lNurse_Gonorrhea;

// Cock Asian cashier
var SLine lCockAsianWelcome;
var SLine lCockAsianLargify;
var SLine lCockAsianCondiments;
var SLine lCockAsianEnjoyMeal;
var SLine lCockAsianHAND;

// Photo questioning. Increasingly more agitated and frustrated.
var SLine lPhoto_Dude1;
var SLine lPhoto_Dude2;
var SLine lPhoto_Dude3;
var SLine lPhoto_Dude4;
var SLine lPhoto_Dude5;
var SLine lPhoto_Dude6;
var SLine lPhoto_Dude7;
var SLine lPhoto_Dude8;

// Dude photo reactions
var SLine lPhoto_DudeReact1;
var SLine lPhoto_DudeReact2;
var SLine lPhoto_DudeReact3;
var SLine lPhoto_DudeReact4;
var SLine lPhoto_DudeReact5;
var SLine lPhoto_DudeReact6;
var SLine lPhoto_DudeReact7;

// Dude should ask different people
var SLine lPhoto_DudeAskSomeoneElse;

// Photo reactions
var SLine lChampPhotoReaction;

// Find the Wise Wang
var SLine lPhoto_FindWiseWang;	// Bystander line instructing the Dude to find the Wise Man

// Dude collection can
var SLine lDude_Can1;			// Gimme some money
var SLine lDude_Can2;			// Come on, just gimme some money, I got other shit to do
var SLine lDude_Can3;			// Give me money or you die
var SLine lDude_CanReceived1;	// Thanks for the money
var SLine lDude_CanReceived2;	// What's with these crap donations
var SLine lDude_CanReceived3;	// Crappy donations are really pissing off the Dude now
var SLine lDude_CanReceived4;	// Crappy donations are really pissing off the Dude now
var SLine lDude_CanReceived5;	// Crappy donations are really pissing off the Dude now
var SLine lDude_CanReceived6;	// Crappy donations are really pissing off the Dude now
var SLine lDude_CanReceived7;	// Crappy donations are really pissing off the Dude now
var SLine lDude_CanReceived_SeeZack1;	// Fuck it, let's go find Zack
var SLine lDude_CanReceived_SeeZack2;	// Why you still collecting donations moron, go get Zack

// Wipe House dialog
var SLine lDude_WipeHouse;		// I'll have a roll of your finest asswipes, please
var SLine lWipeHouse_PriceHike1;	// Cashier comments on price hike
var SLine lWipeHouse_PriceHike2;	// Cashier comments on price hike

// Reverse Cashier dialog
var SLine lCashier_ForThatIllGive;	// For that many, I'll give you...

// Waiting Room Cashier Dialog
var SLine lCashier_PleaseTakeATicket;	// Please take a ticket before you are served
var SLine lCashier_PleaseWaitYourTurn;	// Please wait for your number to be called
var SLine lCashier_NowServing;			// Now serving your number
var SLine lChemCashier_ThankYou;		// Chem Cashier - thank you
var SLine lChemCashier_ThatllBe;		// Chem Cashier - that'll be X dollars
var SLine lDude_WantsChems;				// Dude - I need chems
var SLine lDude_FinallyBuy;				// Dude - Okay I waited, can I buy chems now
var SLine lDude_ThatsOutrageous;		// Dude - That price is bogus

// CCCP Dialog
var SLine lCCCP_Cashier_Welcome;		// Welcome to CCCP
var SLine lCCCP_CoreyDude_Ostriches;	// Searching for a herd of ostriches
var SLine lCCCP_Dude_LostDog;			// Actually I'm looking for my dog
var SLine lCCCP_CheckKennels;			// Check in the kennels

// Yeeland dialog
var SLine lArcade_Dude_DeliverGame;			// I'm here to deliver this game
var SLine lArcade_Yeeland_MoralGrounds;		// Reject game on moral grounds
var SLine lArcade_CoreyDude_MoralGrounds;	// Accept this game or else
var SLine lArcade_Yeeland_MeetMeInBack;		// Meet me in the back and we'll work a deal

// Cow milking dialog
var SLine lDude_CowMilking_Empty;		// Target cow is all out of milk.

// Karaoke reactions
var SLine lKaraoke_Response1;			// Karaoke response
var SLine lKaraoke_Response2;

// Dude blasting cap dialog
var SLine lDude_WantsBlastingCap;

// Dual Wielding quotes
var SLine lDude_BeginDualWielding;

// Use cure line
var SLine lDude_ShouldUseCure;

// Sneeze
var SLine lSneezing;

// Dude Uncle Dave lines
var SLine lDude_UncleDaveRadio_Received;	// Received radio
var SLine lDude_UncleDaveRadio_AllClear;	// All clear
var SLine lDude_UncleDaveRadio_FollowMe;	// Follow me
var SLine lDude_UncleDaveRadio_StayHere;	// Stay here

var array<name> TestModeClasses;


///////////////////////////////////////////////////////////////////////////////
// Startup
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
	{
	Super.PostBeginPlay();

	if (bTestMode)
		TestMode();

	MemUsage = Clamp(MemUsage, 1, 3);
	FillInLines();
	}

///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////
function TestMode()
	{
	local int i;
	local class<P2Dialog> DialogClass;
	local P2Dialog Dialog;

	// Avoid re-entrancy (we're creating new dialog actors that will
	// results in another call to PostBeginPlay(), and so on...)
	if (P2GameInfo(Level.Game) != None && !P2GameInfo(Level.Game).bDialogTestMode)
		{
		P2GameInfo(Level.Game).bDialogTestMode = true;

		PreLoad = true;
		MemUsage = 3;

		Log(self @ "TestMode(): BEGIN");
		for (i = 0; i < TestModeClasses.length; i++)
			{
			DialogClass = class<P2Dialog>(DynamicLoadObject(string(TestModeClasses[i]), class'Class', true));
			if (DialogClass != none)
				{
				Dialog = spawn(DialogClass);
				}
			else
				Log(self @ "TestMode(): ERROR: Couldn't load P2Dialog class "$TestModeClasses[i]);
			}
		Log(self @ "TestMode(): END");
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Called after setting was changed for filtering of foul language
///////////////////////////////////////////////////////////////////////////////
function SetFilterFoulLanguage()
	{
	FillInLines();
	}

///////////////////////////////////////////////////////////////////////////////
// Called after setting was changed for bleeping of foul language
///////////////////////////////////////////////////////////////////////////////
function SetBleepFoulLanguage()
	{
	// Don't need to do anything, this will just happen as the lines are played
	}

///////////////////////////////////////////////////////////////////////////////
// Called after setting was changed for memory usage
///////////////////////////////////////////////////////////////////////////////
function SetMemUsage()
	{
	FillInLines();
	}

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines();

///////////////////////////////////////////////////////////////////////////////
//
// Say the specified line.
// Returns the duration of the actual sound being played for this line.
//
// If no sounds are assigned to this line then nothing is played and the
// returned duration is 0.
//
// If multiple sounds are assigned to this line then a different sound is
// played each time this line is played.
//
///////////////////////////////////////////////////////////////////////////////
function float Say(Pawn pawn, out SLine line, float pitch, bool bImportant, 
				   optional bool bIndexValid, optional int SpecIndex)
	{
	local float duration;
	local float UseVolume, UseRadius;
	local Actor UseActor;

	// Make sure there's at least one line
	duration = 0.0;
	if (line.sounds.Length > 0)
		{
		if(bIndexValid)
			{
			// They wanted to use a specific line in the array. 
			// Hopefully now SpecIndex is within the bounds of the array, let's check!
			if(SpecIndex >= 0 && SpecIndex < line.sounds.Length)
				{
				line.i = SpecIndex;
				}
			// If it's not valid, it will default to the 0th index.
			}
		else
			{
			// If there's more than one line, move index forward by random amount
			// between 1 and Length-1 so we'll never use the same index twice in a row.
			// Do this before we use the index so its initial value will be random.
			if (line.sounds.Length > 1)
				line.i = (line.i + Rand(line.sounds.Length - 1) + 1) % line.sounds.Length;
			}

		// Check if sound needs to be loaded
		if (line.sounds[line.i].snd == None)
			LoadDynSound(line.sounds[line.i]);

		// See if this important and needs to be louder
		if(bImportant)
		{
			UseVolume = IMPORTANT_DIALOG_VOLUME;
			UseRadius = IMPORTANT_DIALOG_RADIUS;
		}
		else
		{
			UseVolume = DIALOG_VOLUME;
			UseRadius = DIALOG_RADIUS;
		}
		
		// Reduce (or increase!) volume based on dialog class.
		UseVolume *= VolumeMult;
		
		//log("playing sound at volume"@UseVolume@"(volume mult was"@VolumeMult@")");

		// Play sound via pawn so sound is properly located!
		if (line.sounds[line.i].snd != None)
			{
			if (BleepFoulLanguage && (line.sounds[line.i].BleepTime1 > 0.0))
				{
				GetBleeper().Bleep(
					pawn,
					UseVolume + 0.25,	// play bleep louder to help drown out the voice
					UseRadius,
					line.sounds[line.i].BleepTime1,
					line.sounds[line.i].BleepTime2,
					line.sounds[line.i].BleepTime3);
				}
				
			// Decide where to play the sound (prefer the head so BSP/statics won't block it)
			if (P2MoCapPawn(Pawn) != None
				&& P2MoCapPawn(Pawn).MyHead != None
				&& P2Pawn(Pawn).bHasHead)
				UseActor = P2MoCapPawn(Pawn).MyHead;
			else
				UseActor = Pawn;

			pawn.PlaySound(
				line.sounds[line.i].snd,// sound
				SLOT_Talk,				// slot (see ESoundSlot)
				UseVolume,				// volume (0.0 to 1.0)
				false,					// no override (true=don't let next sound interrupt this one)
				UseRadius,				// radius (attenuation starts at radius)
				pitch);					// pitch (0.5 to 2.0)

			// Get sound's duration (taking pitch adjustment into account)
			duration = pawn.GetSoundDuration(line.sounds[line.i].snd) / pitch;
			}
		}

	return duration;
	}


///////////////////////////////////////////////////////////////////////////////
// Clear all sounds from the specified line.
///////////////////////////////////////////////////////////////////////////////
function Clear(out SLine line)
	{
	// Remove all existing sounds
	if (line.sounds.Length > 0)
		line.sounds.Remove(0, line.sounds.Length);
	}


///////////////////////////////////////////////////////////////////////////////
// Add a sound to the specified line.
//
// Usage determines whether the sound will be used given the user's
// preference for how much memory to use for dialog:
//		1 = always used
//		2 = only used if the user chooses normal memory usage for dialog
//		3 = only used if the user chooses high memory usage for dialog
///////////////////////////////////////////////////////////////////////////////
function AddTo(out SLine line, String SoundName, int Usage, optional float BleepTime1, optional float BleepTime2, optional float BleepTime3)
	{
	local int i;

	Usage = Clamp(Usage, 1, 3);

	if (!(FilterFoulLanguage && (BleepTime1 + BleepTime2 + BleepTime3 > 0.0)))
		{
		// If the specified scheme is less than or equal to how much memory
		// the user wants dialog to take up, then we use this sound.  Otherwise
		// we ignore it and it will never get used.
// Change by NickP: dialog fix
		// if (Usage <= MemUsage)
			// {
// End
			// Add sound to array
			i = line.sounds.Length;
			line.sounds.Insert(i, 1);
			line.sounds[i].Name = SoundName;
			line.sounds[i].BleepTime1 = BleepTime1;
			line.sounds[i].BleepTime2 = BleepTime2;
			line.sounds[i].BleepTime3 = BleepTime3;

			// If preloading is enabled, load sound now (otherwise it will be
			// loaded the first time it is played)
			if (Preload)
				LoadDynSound(line.sounds[i]);
// Change by NickP: dialog fix
			// }
			// else log("hui dialog not loaded" @ self @ MemUsage);
// End
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Load dynamic sound
///////////////////////////////////////////////////////////////////////////////
function LoadDynSound(out DynSound ds)
	{
	ds.Snd = Sound(DynamicLoadObject(ds.Name, class'Sound', true));
	if (ds.Snd == None && LOG_MISSING_DIALOG == 1)
		Log(self @ "LoadDynSound(): ERROR: Couldn't load sound: "$ds.Name);
	}

///////////////////////////////////////////////////////////////////////////////
// Find a number that fits with the numbers dialog
// NUMBER_SYSTEM_MAX is the highest our number system goes
///////////////////////////////////////////////////////////////////////////////
function int GetValidNumber(optional int Min, optional int Max)
{
	local int usenum;

	if(Max == 0 || Max > NUMBER_SYSTEM_MAX)
		Max = NUMBER_SYSTEM_MAX;

	usenum = Min + Rand((Max - Min) + 1);

	//log(self$" use num generated "$usenum);

	// 1 through 5 are handled properly, except 0
	if(usenum == 0)
		usenum = 1;
	else if(usenum <= 5)
	{
		// just let the number pass on through
	}
	else if(usenum > 5 && usenum <= 20)
		usenum = 10;
	else if(usenum < 40)
		usenum = 20;
	else if(usenum < 60)
		usenum = 40;
	else if(usenum < 80)
		usenum = 60;
	else if(usenum < 100)
		usenum = 80;
	else if(usenum < 200)
		usenum = 100;
	else if(usenum < 300)
		usenum = 200;
	else if(usenum < 400)
		usenum = 300;
	else if(usenum < 500)
		usenum = 400;
	else
		usenum = 500;

	//log(self$" use num returned "$usenum);

	return usenum;
}

///////////////////////////////////////////////////////////////////////////////
// Get a bleeper
///////////////////////////////////////////////////////////////////////////////
function Bleeper GetBleeper()
	{
	local int i;

	for (i = 0; i < Bleepers.length; i++)
		{
		if (Bleepers[i].IsAvailable())
			break;
		}
	if (i == Bleepers.length)
		{
		Bleepers.insert(i, 1);
		Bleepers[i] = spawn(class'Bleeper');
		}

	return Bleepers[i];
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	// For testing purposes, list all extended classes here.  I wish there
	// was a way to iterate through these without using a hardcoded list
	// but I don't think there is.
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
	VolumeMult=1.0
	}
